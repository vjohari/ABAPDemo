***INCLUDE LGRAPFTO .

********************************************************************
* GL 15.3.1993
*
* Allgemeine Fehlermeldung, wenn Kommunikation falsch
* Token der Laenge 0 sind nichtzulaessig
*
********************************************************************

FORM TOKENERROR USING MESS.
* RAISE GRAPH_ERROR.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM TOKENTEST                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  MESS                                                          *
*  -->  VALUE                                                         *
*---------------------------------------------------------------------*
FORM TOKENTEST USING MESS VALUE.
  IF VALUE = 0.
    PERFORM TOKENERROR USING MESS.
  ENDIF.
ENDFORM.


*---------------------------------------------------------------*
* GR_TOKEN, Tokenizer with delimiter = SPACE                    *
*---------------------------------------------------------------*

FORM GR_TOKEN USING
                        BUFF     TYPE C
                        T_COUNT  TYPE I
                        TO_1     TYPE C
                        TL_1     TYPE I
                        TO_2     TYPE C
                        TL_2     TYPE I
                        TO_3     TYPE C
                        TL_3     TYPE I
                        TO_4     TYPE C
                        TL_4     TYPE I
                        TO_5     TYPE C
                        TL_5     TYPE I
                        TO_6     TYPE C
                        TL_6     TYPE I
                        TO_7     TYPE C
                        TL_7     TYPE I
                        TO_8     TYPE C
                        TL_8     TYPE I
                        TO_9     TYPE C
                        TL_9     TYPE I.

  DATA: CHAR(1), LAST(1), TOKEN(100).
  DATA: LEN TYPE I.
  DATA: TOKENLEN TYPE I.
  DATA: COUNT TYPE I.
  FIELD-SYMBOLS: <F>.

  LAST = SPACE.
  COUNT = 0.
  T_COUNT = 0.

  ASSIGN BUFF TO <F>.
  LEN = STRLEN( <F> ).

  DO LEN TIMES.
    ASSIGN BUFF+COUNT(1) TO <F>.
    CHAR = <F>.

    IF CHAR NE SPACE AND CHAR NE HEXNUL.
                                       "// character is valid
      IF LAST EQ SPACE.                "// a new token begins here
        CLEAR TOKEN.
        TOKENLEN = 0.
      ENDIF.                           "// new token.
      WRITE CHAR TO TOKEN+TOKENLEN.
      ADD 1 TO TOKENLEN.
      LAST = 'X'.

    ELSE.
                                       "// character is space
      IF LAST EQ 'X'.                  "// a token just ended
        ASSIGN TOKEN(TOKENLEN) TO <F>.
        ADD 1 TO T_COUNT.
        CASE T_COUNT.
          WHEN 1.
            TO_1 = <F>. TL_1 = TOKENLEN.
          WHEN 2.
            TO_2 = <F>. TL_2 = TOKENLEN.
          WHEN 3.
            TO_3 = <F>. TL_3 = TOKENLEN.
          WHEN 4.
            TO_4 = <F>. TL_4 = TOKENLEN.
          WHEN 5.
            TO_5 = <F>. TL_5 = TOKENLEN.
          WHEN 6.
            TO_6 = <F>. TL_6 = TOKENLEN.
          WHEN 7.
            TO_7 = <F>. TL_7 = TOKENLEN.
          WHEN 8.
            TO_8 = <F>. TL_8 = TOKENLEN.
          WHEN 9.
            TO_9 = <F>. TL_9 = TOKENLEN.
        ENDCASE.
      ENDIF.
      LAST = SPACE.
    ENDIF.
    COUNT = COUNT + 1.
  ENDDO.
  IF LAST EQ 'X'. "// a token ended at end of buffer
    ASSIGN TOKEN(TOKENLEN) TO <F>.
    ADD 1 TO T_COUNT.
    CASE T_COUNT.
      WHEN 1.
        TO_1 = <F>. TL_1 = TOKENLEN.
      WHEN 2.
        TO_2 = <F>. TL_2 = TOKENLEN.
      WHEN 3.
        TO_3 = <F>. TL_3 = TOKENLEN.
      WHEN 4.
        TO_4 = <F>. TL_4 = TOKENLEN.
      WHEN 5.
        TO_5 = <F>. TL_5 = TOKENLEN.
      WHEN 6.
        TO_6 = <F>. TL_6 = TOKENLEN.
      WHEN 7.
        TO_7 = <F>. TL_7 = TOKENLEN.
      WHEN 8.
        TO_8 = <F>. TL_8 = TOKENLEN.
      WHEN 9.
        TO_9 = <F>. TL_9 = TOKENLEN.
    ENDCASE.
  ENDIF.
ENDFORM.


*---------------------------------------------------------------*
* GR_NUL_TOKEN, Tokenizer with delimiter = HEXNUL               *
*---------------------------------------------------------------*

FORM GR_NUL_TOKEN USING
                        BUFF        TYPE C
                        T_COUNT     TYPE I
                        TO_1        TYPE C
                        TL_1        TYPE I
                        TO_2        TYPE C
                        TL_2        TYPE I
                        TO_3        TYPE C
                        TL_3        TYPE I
                        TO_4        TYPE C
                        TL_4        TYPE I
                        TO_5        TYPE C
                        TL_5        TYPE I
                        TO_6        TYPE C
                        TL_6        TYPE I
                        TO_7        TYPE C
                        TL_7        TYPE I
                        TO_8        TYPE C
                        TL_8        TYPE I
                        TO_9        TYPE C
                        TL_9        TYPE I.

  DATA: CHAR(1), LAST(1), TOKEN(100).
  DATA: LEN TYPE I.
  DATA: TOKENLEN TYPE I.
  DATA: COUNT TYPE I.
  FIELD-SYMBOLS: <F>.

  LAST = SPACE.
  COUNT = 0.
  T_COUNT = 0.
  ASSIGN BUFF TO <F>.

  LEN = STRLEN( <F> ).

  DO LEN TIMES.
    ASSIGN BUFF+COUNT(1) TO <F>.
    CHAR = <F>.

    IF CHAR NE HEXNUL.
                                       "// character is valid
      IF LAST EQ SPACE.                "// a new token begins here
        CLEAR TOKEN.
        TOKENLEN = 0.
      ENDIF.                           "// new token.
      WRITE CHAR TO TOKEN+TOKENLEN.
      ADD 1 TO TOKENLEN.
      LAST = 'X'.

    ELSE.
                                       "// character is HEXNUL
      IF LAST EQ 'X'.                  "// a token just ended
        ASSIGN TOKEN(TOKENLEN) TO <F>.
        ADD 1 TO T_COUNT.
        CASE T_COUNT.
          WHEN 1.
            TO_1 = <F>. TL_1 = TOKENLEN.
          WHEN 2.
            TO_2 = <F>. TL_2 = TOKENLEN.
          WHEN 3.
            TO_3 = <F>. TL_3 = TOKENLEN.
          WHEN 4.
            TO_4 = <F>. TL_4 = TOKENLEN.
          WHEN 5.
            TO_5 = <F>. TL_5 = TOKENLEN.
          WHEN 6.
            TO_6 = <F>. TL_6 = TOKENLEN.
          WHEN 7.
            TO_7 = <F>. TL_7 = TOKENLEN.
          WHEN 8.
            TO_8 = <F>. TL_8 = TOKENLEN.
          WHEN 9.
            TO_9 = <F>. TL_9 = TOKENLEN.
        ENDCASE.
      ENDIF.
      LAST = SPACE.
    ENDIF.
    COUNT = COUNT + 1.
  ENDDO.
  IF LAST EQ 'X'. "// a token ended at end of buffer
    ASSIGN TOKEN(TOKENLEN) TO <F>.
    ADD 1 TO T_COUNT.
    CASE T_COUNT.
      WHEN 1.
        TO_1 = <F>. TL_1 = TOKENLEN.
      WHEN 2.
        TO_2 = <F>. TL_2 = TOKENLEN.
      WHEN 3.
        TO_3 = <F>. TL_3 = TOKENLEN.
      WHEN 4.
        TO_4 = <F>. TL_4 = TOKENLEN.
      WHEN 5.
        TO_5 = <F>. TL_5 = TOKENLEN.
      WHEN 6.
        TO_6 = <F>. TL_6 = TOKENLEN.
      WHEN 7.
        TO_7 = <F>. TL_7 = TOKENLEN.
      WHEN 8.
        TO_8 = <F>. TL_8 = TOKENLEN.
      WHEN 9.
        TO_9 = <F>. TL_9 = TOKENLEN.
    ENDCASE.
  ENDIF.
ENDFORM.


*---------------------------------------------------------------*
* GR_TOKEN_TAB, Tokenizer with delimiter = HEXNUL               *
*---------------------------------------------------------------*

FORM GR_TOKEN_TAB TABLES TOKENTAB TOKEN_LEN_TAB USING BUFF TYPE C.

  TYPES: BEGIN OF TOKEN_LEN_LINE_TYPE,
            L TYPE I,
         END OF TOKEN_LEN_LINE_TYPE.

  DATA: CHAR(1), LAST(1), TOKEN(100).
  DATA: LEN TYPE I.
  DATA: TOKENLEN TYPE I.
  DATA: COUNT TYPE I.
  DATA: TOKEN_LEN_WA TYPE TOKEN_LEN_LINE_TYPE.
  FIELD-SYMBOLS: <F>.
  DATA: T_COUNT TYPE I.

  LAST = SPACE.
  COUNT = 0.
  T_COUNT = 0.
  ASSIGN BUFF TO <F>.

  LEN = STRLEN( <F> ).

  DO LEN TIMES.
    ASSIGN BUFF+COUNT(1) TO <F>.
    CHAR = <F>.

    IF CHAR NE HEXNUL.
                                       "// character is valid
      IF LAST EQ SPACE.                "// a new token begins here
        CLEAR TOKEN.
        TOKENLEN = 0.
      ENDIF.                           "// new token.
      WRITE CHAR TO TOKEN+TOKENLEN.
      ADD 1 TO TOKENLEN.
      LAST = 'X'.

    ELSE.
                                       "// character is HEXNUL
      IF LAST EQ 'X'.                  "// a token just ended
        ASSIGN TOKEN(TOKENLEN) TO <F>.
        ADD 1 TO T_COUNT.
        TOKENTAB = <F>. APPEND TOKENTAB.
        TOKEN_LEN_WA-L = TOKENLEN.
        APPEND TOKEN_LEN_WA TO TOKEN_LEN_TAB.
      ENDIF.
      LAST = SPACE.
    ENDIF.
    COUNT = COUNT + 1.
  ENDDO.
  IF LAST EQ 'X'. "// a token ended at end of buffer
    ASSIGN TOKEN(TOKENLEN) TO <F>.
    ADD 1 TO T_COUNT.
    TOKENTAB = <F>. APPEND TOKENTAB.
    TOKEN_LEN_WA-L = TOKENLEN.
    APPEND TOKEN_LEN_WA TO TOKEN_LEN_TAB.
  ENDIF.
ENDFORM.
