FUNCTION REGISTRY_GET.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(KEY) DEFAULT SPACE
*"     VALUE(SECTION) DEFAULT SPACE
*"  EXPORTING
*"     VALUE(VALUE)
*"----------------------------------------------------------------------

  DATA: PLACEHOLDER(8).                "// filename bei profile

  DATA: TEXT(255), MCODE, RBUFF(255).
  DATA: SLEN TYPE I.
  FIELD-SYMBOLS: <TEMP>.

  PERFORM GR_SEND USING 'B' 'PROF'.
  PERFORM GR_SEND USING 'I' 'PROF'.
  PERFORM GR_SEND_C USING 'MODE = GET'.
  PERFORM GR_SEND_C USING 'TYPE = REG'."// registry
  TEXT = 'STRINGS = '.                 "// header
  SLEN = STRLEN( TEXT ).
  WRITE PLACEHOLDER TO TEXT+SLEN.      "// Filename
  SLEN = STRLEN( TEXT ).
  WRITE ',' TO TEXT+SLEN.              "// ,
  SLEN = STRLEN( TEXT ).
  WRITE SECTION TO TEXT+SLEN.          "// Section
  SLEN = STRLEN( TEXT ).
  WRITE ',' TO TEXT+SLEN.              "// ,
  SLEN = STRLEN( TEXT ).
  WRITE KEY TO TEXT+SLEN.              "// key
  PERFORM GR_SEND_C USING TEXT.
  CALL FUNCTION 'GRAPH_RECEIVE'.
  CALL FUNCTION 'GRAPH_GET_PARAM'
       IMPORTING
            MCODE = MCODE
            RBUFF = RBUFF.
  CASE MCODE.
    WHEN 'D'.
    WHEN 'I'.
      IF RBUFF(4) = 'RC=0'.
        SLEN = STRLEN( RBUFF ) - 6.    "// nutzlänge
        IF SLEN < 1.
          CLEAR VALUE.
        ELSE.
          ASSIGN RBUFF+5(SLEN) TO <TEMP>.
          VALUE = <TEMP>.
        ENDIF.
        CALL FUNCTION 'GRAPH_DIALOG'   "// kill and wait
        EXPORTING
        KWDID = 'PROF'.
      ELSE.
        CALL FUNCTION 'GRAPH_DIALOG'   "// kill and wait
        EXPORTING
        KWDID = 'PROF'.
      ENDIF.
    WHEN OTHERS.
      CALL FUNCTION 'GRAPH_DIALOG'     "// kill and wait
      EXPORTING
      KWDID = 'PROF'.
  ENDCASE.
ENDFUNCTION.
