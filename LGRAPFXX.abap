*----------------------------------------------------------------------*
*   INCLUDE LGRAPFXX                                                   *
*----------------------------------------------------------------------*

* Daten in Zeilenpuffer ablegen
FORM PUT_LINEBUFFER USING DATA LEN.
  IF LEN > 0.
    MOVE DATA TO LINEBUFFER+LINEBUFFERSIZE(LEN).
    LINEBUFFERSIZE = LINEBUFFERSIZE + LEN.
  ENDIF.
ENDFORM.

* Die ersten len Daten aus Warteschlange auslesen
FORM READ_LINEBUFFER USING VALUE(LEN) CHANGING DATA.
  IF LEN > 0.
    LINEBUFFERSIZE = LINEBUFFERSIZE - LEN.
    MOVE LINEBUFFER(LEN) TO DATA.
    IF LINEBUFFERSIZE > 0.
      MOVE LINEBUFFER+LEN(LINEBUFFERSIZE) TO LINEBUFFER.
    ELSE.
      CLEAR LINEBUFFER.
    ENDIF.
  ENDIF.
ENDFORM.

FORM CLEAR_LINEBUFFER.
  CLEAR LINEBUFFER.
  LINEBUFFERSIZE = 0.
ENDFORM.

FORM wrapexecute  USING    p_document
                           p_cd
                           p_commandline
                           p_inform
                           p_program
                           p_stat
                           p_winid
                           p_osmac_script
                           p_osmac_creator
                           p_win16_ext
                           p_exec_rc
                  CHANGING p_rbuff.

  DATA: document    TYPE string,
        application TYPE string,
        parameter   TYPE string,
        defaultdir  TYPE string,
        synchron    TYPE string.

  defaultdir  = p_cd.
  if p_inform is not INITIAL.
       synchron    = 'X'.
  endif.
  If p_document is not INITIAL.
     document    = p_program.
  else.
     application = p_program.
     parameter   = p_commandline.
  endif.

  CALL METHOD cl_gui_frontend_services=>execute
    EXPORTING
      document               = document
      application            = application
      parameter              = parameter
      default_directory      = defaultdir
*     maximized              =
*     minimized              =
      synchronous            = synchron
*     operation              = 'OPEN'
    EXCEPTIONS
      cntl_error             = 1
      error_no_gui           = 2
      bad_parameter          = 3
      file_not_found         = 4
      path_not_found         = 5
      file_extension_unknown = 6
      error_execute_failed   = 7.

  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1 OR 7.
        RAISE frontend_error.
      WHEN 2.
        RAISE no_batch.
      WHEN 4 OR 5 OR 6.
        RAISE prog_not_found.
      WHEN OTHERS.
        RAISE frontend_error.
    ENDCASE.
  ENDIF.


ENDFORM.
