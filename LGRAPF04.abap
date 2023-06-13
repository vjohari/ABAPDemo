*----------------------------------------------------------------------*
***INCLUDE LGRAPF04 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DialogWrap
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DEF_FILENAME  text
*      -->P_DEF_PATH  text
*      -->P_MASK  text
*      -->P_MODE  text
*      -->P_TITLE  text
*      <--P_FILENAME  text
*      <--P_RC  text
*----------------------------------------------------------------------*
FORM DialogWrap  USING    P_DEF_FILENAME
                          P_DEF_PATH
                          P_MASK
                          P_MODE
                          P_TITLE
                 CHANGING P_FILENAME.
DATA: prc_window_title      TYPE STRING,
      prc_default_file_name TYPE STRING,
      prc_file_filter       TYPE STRING,
      prc_initial_directory TYPE STRING,
      prc_file_name         TYPE STRING,
      prc_path              TYPE STRING,
      prc_full_path         TYPE STRING,
      prc_file_table        TYPE FILETABLE,
      prc_file_table_wa     TYPE FILE_TABLE,
      prc_user_action       TYPE I,
      prc_sel_count         TYPE I,
      prc_filter_length     TYPE I.

  prc_window_title      = P_TITLE.
  prc_default_file_name = P_DEF_FILENAME.
  prc_file_filter       = P_MASK.
  prc_initial_directory = P_DEF_PATH.

  prc_filter_length = STRLEN( prc_file_filter ).
  IF prc_filter_length > 0.
    SHIFT prc_file_filter LEFT BY 1 PLACES.
    prc_filter_length = prc_filter_length - 2.
    prc_file_filter = prc_file_filter(prc_filter_length).
    REPLACE ALL OCCURRENCES OF ',' IN prc_file_filter WITH '|'.
    CONCATENATE prc_file_filter '||' INTO prc_file_filter.
  ENDIF.

  IF P_MODE = 'S'.
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
       EXPORTING
         WINDOW_TITLE         = prc_window_title
*        DEFAULT_EXTENSION    =
         DEFAULT_FILE_NAME    = prc_default_file_name
         FILE_FILTER          = prc_file_filter
         INITIAL_DIRECTORY    = prc_initial_directory
      CHANGING
        FILENAME             = prc_file_name
        PATH                 = prc_path
        FULLPATH             = prc_full_path
        USER_ACTION          = prc_user_action
       EXCEPTIONS
         CNTL_ERROR           = 1
         ERROR_NO_GUI         = 2
         NOT_SUPPORTED_BY_GUI = 3
         others               = 4.
  ELSE.
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
       EXPORTING
         WINDOW_TITLE            = prc_window_title
*        DEFAULT_EXTENSION       =
         DEFAULT_FILENAME        = prc_default_file_name
         FILE_FILTER             = prc_file_filter
         INITIAL_DIRECTORY       = prc_initial_directory
         MULTISELECTION          = ABAP_FALSE
      CHANGING
        FILE_TABLE              = prc_file_table
        RC                      = prc_sel_count
        USER_ACTION             = prc_user_action
       EXCEPTIONS
         CNTL_ERROR              = 1
         ERROR_NO_GUI            = 2
         NOT_SUPPORTED_BY_GUI    = 3
*         FILE_OPEN_DIALOG_FAILED = 1
         others                  = 4.
  ENDIF.

  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1.
        RAISE INV_WINSYS.
      WHEN 2.
        RAISE INV_WINSYS.
      WHEN 3.
        RAISE INV_WINSYS.
      WHEN 4.
        RAISE INV_WINSYS.
    ENDCASE.
  ENDIF.

  IF prc_user_action = CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL.
    RAISE SELECTION_CANCEL.
  ENDIF.

  IF P_MODE = 'S'.
    P_FILENAME = prc_full_path.
  ELSE.
    LOOP AT prc_file_table INTO prc_file_table_wa.
      P_FILENAME = prc_file_table_wa-FILENAME.
      EXIT.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " DialogWrap
