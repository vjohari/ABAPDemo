*----------------------------------------------------------------------*
***INCLUDE LGRAPF02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DownloadWrap
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BIN_FILESIZE  text
*      -->P_CODEPAGE  text
*      -->P_FILENAME  text
*      -->P_FILETYPE  text
*      -->P_MODE  text
*      -->P_COL_SELECT  text
*      -->P_COL_SELECTMASK  text
*      -->P_NO_AUTH_CHECK  text
*      -->P_DATA_TAB  text
*      <--P_FILELENGTH  text
*      <--P_NDONE  text
*----------------------------------------------------------------------*
FORM DownloadWrap  TABLES   DATA_TAB
                            FIELDNAMES
                   USING    P_BIN_FILESIZE
                            P_CODEPAGE
                            P_FILENAME
                            P_FILETYPE
                            P_MODE
                            P_COL_SELECT
                            P_COL_SELECTMASK
                   CHANGING P_FILELENGTH.

  DATA: FileType(10) TYPE C,
        Mode         TYPE C VALUE ' ',
        ErrorCode    TYPE I VALUE 0,
        FileName     TYPE STRING,
        WriteFieldSeparator TYPE C VALUE ' ',
        TruncTrailingBlanks TYPE C VALUE ' ',
        ColSelect           TYPE C VALUE ' ',
        ColSelectMask(255)  TYPE C VALUE ' ',
        DatMode             TYPE C VALUE ' ',
        BinFileSize         TYPE I VALUE 0,
        WriteLF             TYPE C VALUE 'X',
        Codepage            TYPE ABAP_ENCODING VALUE SPACE,
        FileLength          TYPE I VALUE 0.

  FileName = P_FILENAME.
  CLEAR ColSelectMask.

  IF P_FILETYPE = 'IBM'.
    FileType    = 'ASC'.
    CodePage    = '1103'.
  ELSE.
    FileType = P_FILETYPE.
    IF P_CODEPAGE = 'IBM'.
      Codepage = '1103'.
    ENDIF.
  ENDIF.

  IF P_MODE = 'A'.
    Mode = 'X'.
  ENDIF.

  DATA: FieldnameLine(8192) TYPE C.
  CLEAR FieldnameLine.

  IF FILETYPE = 'ASC' OR FILETYPE = 'DAT'.
    DATA: nCount         TYPE I VALUE 0,
          nMaskMaxOffset TYPE I VALUE 0.

    nMaskMaxOffset = STRLEN( P_COL_SELECTMASK ) - 1.

    LOOP AT FIELDNAMES.
      IF P_COL_SELECT IS INITIAL OR
         nMaskMaxOffset < nCount OR
         P_COL_SELECTMASK+nCount(1) = 'X'.

        IF FieldnameLine IS INITIAL.
          CONCATENATE FieldnameLine FIELDNAMES INTO FieldnameLine.
        ELSE.
          CONCATENATE FieldnameLine cl_abap_char_utilities=>horizontal_tab FIELDNAMES INTO FieldnameLine.
        ENDIF.

      ENDIF.
    ENDLOOP.
  ENDIF.

  CASE FILETYPE.
    WHEN 'ASC'.
    WHEN 'DAT'.
      FileType = 'ASC'.
      WriteFieldSeparator = 'X'.
      TruncTrailingBlanks = 'X'.
      ColSelect     = P_COL_SELECT.
      ColSelectMask = P_COL_SELECTMASK.
      DatMode       = 'X'.
    WHEN 'BIN'.
      BinFileSize   = P_BIN_FILESIZE.
    WHEN 'VSS'.
      FIELD-SYMBOLS: <f_data_tab> TYPE ANY.
      DATA: ComponentsCount TYPE I,
            TableType       TYPE C.

      DESCRIBE FIELD data_tab TYPE TableType COMPONENTS ComponentsCount.
      IF ComponentsCount >= 2.
        FIELD-SYMBOLS: <f_length> TYPE ANY,
                       <f_data>   TYPE ANY.
        DATA: DataTypeLength TYPE C,
              DataTypeData   TYPE C,
              DataLength     TYPE I.
        ASSIGN COMPONENT 1 OF STRUCTURE data_tab TO <f_length>.
        ASSIGN COMPONENT 2 OF STRUCTURE data_tab TO <f_data>.
        DESCRIBE FIELD <f_length> TYPE DataTypeLength.
        DESCRIBE FIELD <f_data>   TYPE DataTypeData LENGTH DataLength IN CHARACTER MODE.
        DataLength = DataLength - 2.

        IF DataTypeLength = 'I' AND DataTypeData = 'C'.
          LOOP AT data_tab ASSIGNING <f_data_tab>.
            ASSIGN COMPONENT 1 OF STRUCTURE <f_data_tab> TO <f_length>.
            ASSIGN COMPONENT 2 OF STRUCTURE <f_data_tab> TO <f_data>.

            IF <f_length> <= DataLength.
              MOVE CL_ABAP_CHAR_UTILITIES=>CR_LF TO <f_data>+<f_length>.
            ELSE.
              RAISE INVALID_TYPE.
            ENDIF.
          ENDLOOP.
        ELSE.
          RAISE INVALID_TYPE.
        ENDIF.
      ELSE.
        RAISE INVALID_TYPE.
      ENDIF.

      FileType      = 'ASC'.
      ColSelect     = 'X'.
      ColSelectMask = ' X'.
      WriteLF       = SPACE.
      TruncTrailingBlanks = 'X'.

    WHEN OTHERS.
      RAISE INVALID_TYPE.
  ENDCASE.

  P_FILELENGTH = 0.

  IF FieldnameLine IS NOT INITIAL.
    DATA: fieldname_data_tab LIKE STANDARD TABLE OF FieldnameLine.
    APPEND FieldnameLine TO fieldname_data_tab.

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        FILENAME                      = FILENAME
        APPEND                        = Mode
        TRUNC_TRAILING_BLANKS         = 'X'
        NO_AUTH_CHECK                 = 'X'
        CODEPAGE                      = Codepage
        IGNORE_CERR                   = 'X'
      IMPORTING
        FILELENGTH                    = FileLength
      TABLES
        DATA_TAB                      = fieldname_data_tab
      EXCEPTIONS
        FILE_WRITE_ERROR              = 1
        NO_BATCH                      = 2
        GUI_REFUSE_FILETRANSFER       = 3
        INVALID_TYPE                  = 4
        NO_AUTHORITY                  = 5
        UNKNOWN_ERROR                 = 6
        HEADER_NOT_ALLOWED            = 7
        SEPARATOR_NOT_ALLOWED         = 8
        FILESIZE_NOT_ALLOWED          = 9
        HEADER_TOO_LONG               = 10
        DP_ERROR_CREATE               = 11
        DP_ERROR_SEND                 = 12
        DP_ERROR_WRITE                = 13
        UNKNOWN_DP_ERROR              = 14
        ACCESS_DENIED                 = 15
        DP_OUT_OF_MEMORY              = 16
        DISK_FULL                     = 17
        DP_TIMEOUT                    = 18
        FILE_NOT_FOUND                = 19
        DATAPROVIDER_EXCEPTION        = 20
        CONTROL_FLUSH_ERROR           = 21
        OTHERS                        = 22.

    IF sy-subrc <> 0.
      CASE sy-subrc.
        WHEN 1.
          RAISE FILE_WRITE_ERROR.
        WHEN 2.
          RAISE NO_BATCH.
        WHEN 3.
          RAISE GUI_REFUSE_FILETRANSFER.
        WHEN 4.
          RAISE INVALID_TYPE.
        WHEN 5.
          RAISE NO_AUTHORITY.
        WHEN OTHERS.
          RAISE UNKNOWN_ERROR.
      ENDCASE.
    ENDIF.
    P_FILELENGTH = FileLength.
    Mode = 'X'.
  ENDIF.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      BIN_FILESIZE                  = BinFileSize
      FILETYPE                      = FILETYPE
      FILENAME                      = FILENAME
      APPEND                        = Mode
      WRITE_FIELD_SEPARATOR         = WriteFieldSeparator
      TRUNC_TRAILING_BLANKS         = TruncTrailingBlanks
      WRITE_LF                      = WriteLF
      COL_SELECT                    = ColSelect
      COL_SELECT_MASK               = ColSelectMask
      DAT_MODE                      = DatMode
*     CONFIRM_OVERWRITE             = ' '
      NO_AUTH_CHECK                 = 'X'
      CODEPAGE                      = Codepage
      IGNORE_CERR                   = 'X'
*     REPLACEMENT                   = '#'
    IMPORTING
      FILELENGTH                    = FileLength
    TABLES
      DATA_TAB                      = data_tab
    EXCEPTIONS
      FILE_WRITE_ERROR              = 1
      NO_BATCH                      = 2
      GUI_REFUSE_FILETRANSFER       = 3
      INVALID_TYPE                  = 4
      NO_AUTHORITY                  = 5
      UNKNOWN_ERROR                 = 6
      HEADER_NOT_ALLOWED            = 7
      SEPARATOR_NOT_ALLOWED         = 8
      FILESIZE_NOT_ALLOWED          = 9
      HEADER_TOO_LONG               = 10
      DP_ERROR_CREATE               = 11
      DP_ERROR_SEND                 = 12
      DP_ERROR_WRITE                = 13
      UNKNOWN_DP_ERROR              = 14
      ACCESS_DENIED                 = 15
      DP_OUT_OF_MEMORY              = 16
      DISK_FULL                     = 17
      DP_TIMEOUT                    = 18
      FILE_NOT_FOUND                = 19
      DATAPROVIDER_EXCEPTION        = 20
      CONTROL_FLUSH_ERROR           = 21
      OTHERS                        = 22.

  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1.
        RAISE FILE_WRITE_ERROR.
      WHEN 2.
        RAISE NO_BATCH.
      WHEN 3.
        RAISE GUI_REFUSE_FILETRANSFER.
      WHEN 4.
        RAISE INVALID_TYPE.
      WHEN 5.
        RAISE NO_AUTHORITY.
      WHEN OTHERS.
        RAISE UNKNOWN_ERROR.
    ENDCASE.
  ENDIF.

  P_FILELENGTH = P_FILELENGTH + FileLength.

ENDFORM.                    " DownloadWrap
