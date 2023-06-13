*----------------------------------------------------------------------*
***INCLUDE LGRAPF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  QueryWrap_WS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_TMP_RETURN  text
*----------------------------------------------------------------------*
FORM QueryWrap_WS  CHANGING RETURN
                            nDone TYPE I.

DATA: nPlatform TYPE I.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GET_PLATFORM
    RECEIVING
      PLATFORM             = len
    EXCEPTIONS
      ERROR_NO_GUI         = 1
      CNTL_ERROR           = 2
      NOT_SUPPORTED_BY_GUI = 3
      others               = 4.

  IF sy-subrc <> 0.
    nDone = -1.
  ELSE.
    nDone = 1.
    CASE len.
      WHEN CL_GUI_FRONTEND_SERVICES=>PLATFORM_WINDOWS95.
        RETURN = 'WN32_95'.
      WHEN CL_GUI_FRONTEND_SERVICES=>PLATFORM_WINDOWS98.
        RETURN = 'WN32_98'.
      WHEN CL_GUI_FRONTEND_SERVICES=>PLATFORM_NT351.
        RETURN = 'WN32'.
      WHEN CL_GUI_FRONTEND_SERVICES=>PLATFORM_NT40.
        RETURN = 'WN32'.
      WHEN CL_GUI_FRONTEND_SERVICES=>PLATFORM_NT50.
        RETURN = 'WN32'.
      WHEN CL_GUI_FRONTEND_SERVICES=>PLATFORM_MAC.
        RETURN = 'MC'.
      WHEN CL_GUI_FRONTEND_SERVICES=>PLATFORM_OS2.
        RETURN = 'PM'.
      WHEN CL_GUI_FRONTEND_SERVICES=>PLATFORM_LINUX.
        RETURN = 'MF'.
      WHEN CL_GUI_FRONTEND_SERVICES=>PLATFORM_HPUX.
        RETURN = 'MF'.
      WHEN CL_GUI_FRONTEND_SERVICES=>PLATFORM_TRU64.
        RETURN = 'MF'.
      WHEN CL_GUI_FRONTEND_SERVICES=>PLATFORM_AIX.
        RETURN = 'MF'.
      WHEN CL_GUI_FRONTEND_SERVICES=>PLATFORM_SOLARIS.
        RETURN = 'MF'.
      WHEN CL_GUI_FRONTEND_SERVICES=>PLATFORM_MACOSX.
        RETURN = 'MF'.
      WHEN 14. "PLATFORM_WINDOWSXP
        RETURN = 'WN32'.
      WHEN 15. "VISTA
        RETURN = 'WN32'.
      WHEN CL_GUI_FRONTEND_SERVICES=>PLATFORM_UNKNOWN.
        RETURN = '??'.
      WHEN OTHERS.
        RETURN = '??'.
    ENDCASE.
  ENDIF.
ENDFORM.                    " QueryWrap_WS
*&---------------------------------------------------------------------*
*&      Form  QueryWrap_OS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SAVE_WS  text
*      <--P_TMP_RETURN  text
*----------------------------------------------------------------------*
FORM QueryWrap_OS  USING    SAVE_WS
                   CHANGING RETURN
                            nDone TYPE I.
  nDone = 1.

  CASE SAVE_WS.
    WHEN 'WN32_95'.
      RETURN = 'NT'.
    WHEN 'WN32_98'.
      RETURN = 'NT'.
    WHEN 'WN32'.
      RETURN = 'NT'.
    WHEN 'MC'.
      RETURN = 'MAC'.
    WHEN 'PM'.
      RETURN = 'OS2'.
    WHEN OTHERS.
      RETURN = '??'.
      nDone = 0.
  ENDCASE.
ENDFORM.                    " QueryWrap_OS
*&---------------------------------------------------------------------*
*&      Form  QueryWrap_CD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_TMP_RETURN  text
*----------------------------------------------------------------------*
FORM QueryWrap_CD  CHANGING RETURN
                            nDone TYPE I.

  DATA ret TYPE STRING.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_GET_CURRENT
    CHANGING
      CURRENT_DIRECTORY            = ret
    EXCEPTIONS
     DIRECTORY_GET_CURRENT_FAILED = 1
     CNTL_ERROR                   = 2
     ERROR_NO_GUI                 = 3
     NOT_SUPPORTED_BY_GUI         = 4
     others                       = 5.

  CALL METHOD CL_GUI_CFW=>FLUSH.

  IF SY-SUBRC <> 0.
    nDone = -1.
  ELSE.
    nDone = 1.
  ENDIF.

  IF nDone = 1.
    IF SAVE_WS IS INITIAL.
      PERFORM QueryWrap_WS CHANGING SAVE_WS nDone.
    ENDIF.

    CASE SAVE_WS.
      WHEN 'WN32_95'.
        CONCATENATE ret '\' INTO ret in CHARACTER MODE.
      WHEN 'WN32_98'.
        CONCATENATE ret '\' INTO ret in CHARACTER MODE.
      WHEN 'WN32'.
        CONCATENATE ret '\' INTO ret in CHARACTER MODE.
      WHEN 'MC'.
        CONCATENATE ret ':' INTO ret in CHARACTER MODE.
      WHEN 'PM'.
        CONCATENATE ret '\' INTO ret in CHARACTER MODE.
      WHEN 'MF'.
        CONCATENATE ret '/' INTO ret in CHARACTER MODE.
    ENDCASE.
  ENDIF.

  RETURN = ret.
ENDFORM.                    " QueryWrap_CD
*&---------------------------------------------------------------------*
*&      Form  QueryWrap_EN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ENVIRONMENT  text
*      <--P_TMP_RETURN  text
*----------------------------------------------------------------------*
FORM QueryWrap_EN  USING    ENVIRONMENT
                   CHANGING RETURN
                            nDone TYPE I.
DATA: env TYPE STRING,
      ret TYPE STRING.

  env = ENVIRONMENT.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>ENVIRONMENT_GET_VARIABLE
    EXPORTING
      VARIABLE             = env
    CHANGING
      VALUE                = ret
    EXCEPTIONS
      CNTL_ERROR           = 1
      ERROR_NO_GUI         = 2
      NOT_SUPPORTED_BY_GUI = 3
      others               = 4.

  CALL METHOD CL_GUI_CFW=>FLUSH.

  IF SY-SUBRC <> 0.
    nDone = -1.
  ELSE.
    nDone = 1.
  ENDIF.

  RETURN = ret.
ENDFORM.                    " QueryWrap_EN
*&---------------------------------------------------------------------*
*&      Form  QueryWrap_FL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FILENAME  text
*      <--P_TMP_RETURN  text
*----------------------------------------------------------------------*
FORM QueryWrap_FL  USING    FILENAME
                   CHANGING RETURN
                            nDone TYPE I.

DATA: fn    TYPE STRING,
      nSize TYPE I.

  fn = FILENAME.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_GET_SIZE
    EXPORTING
      FILE_NAME           = fn
   IMPORTING
     FILE_SIZE            = nSize
   EXCEPTIONS
     FILE_GET_SIZE_FAILED = 1
     CNTL_ERROR           = 2
     ERROR_NO_GUI         = 3
     NOT_SUPPORTED_BY_GUI = 4
     others               = 5.

  CALL METHOD CL_GUI_CFW=>FLUSH.

  IF SY-SUBRC <> 0.
    nDone = -1.
  ELSE.
    nDone = 1.
    IF nSize >= 0.
      MOVE nSize TO RETURN.
      CONDENSE RETURN.
    ELSE.
      CLEAR RETURN.
    ENDIF.
  ENDIF.

ENDFORM.                    " QueryWrap_FL
*&---------------------------------------------------------------------*
*&      Form  QueryWrap_FE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FILENAME  text
*      <--P_TMP_RETURN  text
*----------------------------------------------------------------------*
FORM QueryWrap_FE  USING    FILENAME
                   CHANGING RETURN
                            nDone TYPE I.

DATA: fn  TYPE STRING,
      ret TYPE ABAP_BOOL.

  fn = FILENAME.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_EXIST
    EXPORTING
      FILE                 = fn
    RECEIVING
      RESULT               = ret
    EXCEPTIONS
      CNTL_ERROR           = 1
      ERROR_NO_GUI         = 2
      WRONG_PARAMETER      = 3
      NOT_SUPPORTED_BY_GUI = 4
      others               = 5.

  CALL METHOD CL_GUI_CFW=>FLUSH.

  IF SY-SUBRC <> 0.
    nDone = -1.
  ELSE.
    IF ret = ABAP_TRUE.
      MOVE 1 TO RETURN.
    ELSE.
      MOVE 0 TO RETURN.
    ENDIF.
    CONDENSE RETURN.
    nDone = 1.
  ENDIF.

ENDFORM.                    " QueryWrap_FE
*&---------------------------------------------------------------------*
*&      Form  QueryWrap_DE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FILENAME  text
*      <--P_TMP_RETURN  text
*----------------------------------------------------------------------*
FORM QueryWrap_DE  USING    FILENAME
                   CHANGING RETURN
                            nDone TYPE I.

DATA: dir TYPE STRING,
      res TYPE ABAP_BOOL.

  dir = FILENAME.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_EXIST
    EXPORTING
      DIRECTORY            = dir
    RECEIVING
      RESULT               = res
    EXCEPTIONS
      CNTL_ERROR           = 1
      ERROR_NO_GUI         = 2
      WRONG_PARAMETER      = 3
      NOT_SUPPORTED_BY_GUI = 4
      others               = 5.

  CALL METHOD CL_GUI_CFW=>FLUSH.

  IF SY-SUBRC <> 0.
    nDone = -1.
  ELSE.
    IF res = ABAP_TRUE.
      MOVE 1 TO RETURN.
    ELSE.
      MOVE 0 TO RETURN.
    ENDIF.
    CONDENSE RETURN.
    nDone = 1.
  ENDIF.

ENDFORM.                    " QueryWrap_DE
*&---------------------------------------------------------------------*
*&      Form  QueryWrap_XP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_TMP_RETURN  text
*----------------------------------------------------------------------*
FORM QueryWrap_XP  CHANGING RETURN
                            nDone TYPE I.

DATA: dir TYPE STRING.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GET_SAPGUI_DIRECTORY
    CHANGING
      SAPGUI_DIRECTORY     = dir
    EXCEPTIONS
      CNTL_ERROR           = 1
      NOT_SUPPORTED_BY_GUI = 2
      ERROR_NO_GUI         = 3
      others               = 4.

  CALL METHOD CL_GUI_CFW=>FLUSH.

  IF SY-SUBRC <> 0.
    nDone = -1.
  ELSE.
    RETURN = dir.
    nDone = 1.
  ENDIF.

ENDFORM.                    " QueryWrap_XP
