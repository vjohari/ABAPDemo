*----------------------------------------------------------------------*
***INCLUDE LGRAPF03 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  UploadWrap
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DATA_TAB  text
*      -->P_CODEPAGE  text
*      -->P_FILENAME  text
*      -->P_FILETYPE  text
*      -->P_DAT_D_FORMAT  text
*      <--P_FILELENGTH  text
*----------------------------------------------------------------------*
FORM UploadWrap  TABLES   P_DATA_TAB
                 USING    P_CODEPAGE
                          P_FILENAME
                          P_FILETYPE
                          P_DAT_D_FORMAT
                 CHANGING P_FILELENGTH.

  DATA: FileType(10)      TYPE C,
        DatMode           TYPE C VALUE SPACE,
        HasFieldSeparator TYPE C VALUE ' ',
        Codepage          TYPE ABAP_ENCODING VALUE SPACE,
        Filename          TYPE STRING,
        FileLength        TYPE I.

  Filename = P_FILENAME.

  IF P_FILETYPE = 'IBM'.
    FileType = 'ASC'.
    Codepage = '1103'.
  ELSE.
    FileType = P_FILETYPE.
    IF P_CODEPAGE = 'IBM'.
      Codepage = '1103'.
    ENDIF.
  ENDIF.

  CASE FileType.
    WHEN 'ASC'.
    WHEN 'DAT'.
      FileType = 'ASC'.
      DatMode  = 'X'.
      HasFieldSeparator = 'X'.
    WHEN 'BIN'.
    WHEN OTHERS.
      RAISE INVALID_TYPE.
  ENDCASE.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME                      = Filename
      FILETYPE                      = FileType
      HAS_FIELD_SEPARATOR           = HasFieldSeparator
*     HEADER_LENGTH                 = 0
*     READ_BY_LINE                  = 'X'
      DAT_MODE                      = DatMode
      CODEPAGE                      = Codepage
*     IGNORE_CERR                   = ABAP_TRUE
*     REPLACEMENT                   = '#'
    IMPORTING
      FILELENGTH                    = FileLength
*     HEADER                        =
    TABLES
      DATA_TAB                      = data_tab
   EXCEPTIONS
      FILE_OPEN_ERROR               = 1
      FILE_READ_ERROR               = 2
      NO_BATCH                      = 3
      GUI_REFUSE_FILETRANSFER       = 4
      INVALID_TYPE                  = 5
      NO_AUTHORITY                  = 6
      UNKNOWN_ERROR                 = 7
      BAD_DATA_FORMAT               = 8
      HEADER_NOT_ALLOWED            = 9
      SEPARATOR_NOT_ALLOWED         = 10
      HEADER_TOO_LONG               = 11
      UNKNOWN_DP_ERROR              = 12
      ACCESS_DENIED                 = 13
      DP_OUT_OF_MEMORY              = 14
      DISK_FULL                     = 15
      DP_TIMEOUT                    = 16
      OTHERS                        = 17.

  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1.
        RAISE FILE_OPEN_ERROR.
      WHEN 2.
        RAISE FILE_READ_ERROR.
      WHEN 3.
        RAISE NO_BATCH.
      WHEN 4.
        RAISE GUI_REFUSE_FILETRANSFER.
      WHEN 5.
        RAISE INVALID_TYPE.
      WHEN 6.
        RAISE NO_AUTHORITY.
      WHEN OTHERS.
        RAISE UNKNOWN_ERROR.
    ENDCASE.
  ENDIF.

 P_FILELENGTH = FileLength.
ENDFORM.                    " UploadWrap
