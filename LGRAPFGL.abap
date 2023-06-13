***INCLUDE LGRAPFGL .
DATA: NO_ASC_CRLF(1).
DATA: GLOBAL_WS(4).

* GL 17.07.1996 : New Value 'NOGR'

*
* BIN 26.07.1995 (3.0a)
*

* Bpoint-Routine, called via BPOINTLEVEL by TERM_SEND
* NUR FUER ENTWICKLUNGS-DEBUGGING !!

FORM BPOINT.
*-----------------------*
  SET EXTENDED CHECK OFF.
*-----------------------*
  BREAK-POINT.       "// nicht melden !! Nur fuer Entwicklungs-Debugging
*-----------------------*
  SET EXTENDED CHECK ON.
*-----------------------*
ENDFORM.             "// wird beim Kunden NIE angesprungen

* Setze bpointlevel
* NUR FUER ENTWICKLUNGS-DEBUGGING !!

FORM BREAKLEVEL_SET USING LEVEL TYPE C.
  BPOINTLEVEL = LEVEL.
ENDFORM.                    "BREAKLEVEL_SET

* Setze Tracelevel
* NUR FUER ENTWICKLUNGS-DEBUGGING !!

FORM TRACELEVEL_SET USING LEVEL TYPE C.
  TRACELEVEL = LEVEL.
ENDFORM.                    "TRACELEVEL_SET

*---------------------------------------------------------------------*
*       FORM PROTOCOL_ID_SET
*---------------------------------------------------------------------*
*       Erlaube Protokollerweiterung fuer Massendaten etc.
*---------------------------------------------------------------------*
FORM PROTOCOL_ID_SET USING ID.
  IF ID NE 'V01'.
* RAISE INVALID_PROTOCOL_ID.       "// force error to check applications
  ENDIF.
  PROTOCOL_ID = ID.
ENDFORM.                    "PROTOCOL_ID_SET

*---------------------------------------------------------------------*
*       FORM PROTOCOL_ID_CLEAR
*---------------------------------------------------------------------*
*       Ruecksetzen Protokollerweiterung                              *
*---------------------------------------------------------------------*
FORM PROTOCOL_ID_CLEAR.
* RAISE INVALID_PROTOCOL_ID.       "// force error to check applications
  CLEAR PROTOCOL_ID.
ENDFORM.                    "PROTOCOL_ID_CLEAR

*---------------------------------------------------------------------*
*       FORM PROTOCOL_ID_GET                                          *
*---------------------------------------------------------------------*
*       Query Protokollerweiterung
*---------------------------------------------------------------------*
*  -->  ID                                                            *
*---------------------------------------------------------------------*
FORM PROTOCOL_ID_GET USING ID.
  ID = PROTOCOL_ID.
  IF PROTOCOL_ID NE 'V01'.
*   RAISE INVALID_PROTOCOL_ID.
  ENDIF.
ENDFORM.                    "PROTOCOL_ID_GET

*---------------------------------------------------------------------*
*       FORM IS_GR_INIT                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  INIT                                                          *
*---------------------------------------------------------------------*
FORM IS_GR_INIT USING INIT.
  INIT = GLOBAL_GRAPH_INIT.
ENDFORM.                    "IS_GR_INIT

*---------------------------------------------------------------------*
*       FORM SET_HPGL_MODE                                            *
*---------------------------------------------------------------------*
*       Used in GRAPH_RECEIVE for Upload 'WRITE'                      *
*---------------------------------------------------------------------*
*  -->  MODE                                                          *
*---------------------------------------------------------------------*
FORM SET_HPGL_MODE USING MODE.
  GLOBAL_HPGL_MODE = MODE.
ENDFORM.                    "SET_HPGL_MODE


*---------------------------------------------------------------------*
*       FORM GR_SEND_TAB                                              *
*---------------------------------------------------------------------*
*       langsamer, do not use                                         *
*---------------------------------------------------------------------*
*  -->  DATA_TAB                                                      *
*---------------------------------------------------------------------*
FORM GR_SEND_TAB TABLES DATA_TAB.

  FIELD-SYMBOLS: <KEY>, <F2>, <F15>, <F80>.

  ASSIGN COMPONENT 1 OF STRUCTURE DATA_TAB TO <KEY>.
  ASSIGN COMPONENT 2 OF STRUCTURE DATA_TAB TO <F80>.
  ASSIGN <F80>(2)  TO <F2>.
  ASSIGN <F80>(15) TO <F15>.

* Statische Zuweisungen mit Längenangaben(l) gleichschnell wie ohne (l)
*    ... und schöner, weil Wissen explizit kodiert ist

* Problem: auswerten von Feldsymbolen 'etwas' langsamer
* Idee   : Tabelle als C81 auffassen

  IF OBJECT_STAT = CONST_OBJ_CREATE.   "// Store in Object
    GRAPH_OBJECT-WINID = OBJECT_ID.
    LOOP AT DATA_TAB.
      CASE <KEY>.
        WHEN 'I'.                      "// 15 Byte Int
          GRAPH_OBJECT-MSG = 'N'.      "// its a number (negativ eg)
          GRAPH_OBJECT-TXT = <F15>.
          APPEND GRAPH_OBJECT.
        WHEN '1'.                      "// 2 Byte Char
          GRAPH_OBJECT-MSG = 'C'.
          GRAPH_OBJECT-TXT = <F2>.
          APPEND GRAPH_OBJECT.
        WHEN '2'.                      "// 80 Byte Char
          GRAPH_OBJECT-MSG = 'C'.
          GRAPH_OBJECT-TXT = <F80>.
          APPEND GRAPH_OBJECT.
        WHEN OTHERS.                   "// should not happen, ignore
      ENDCASE.
    ENDLOOP.
  ELSE.                                "// Send it
    LOOP AT DATA_TAB.

      CASE <KEY>.
        WHEN 'I'.                      "// INTEGER 15
*         Check Len
          LEN = GBUFF_OFFSET + 17.
          IF LEN > MAX_BUFFLEN.
            PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
            CLEAR: G_BUFF, GBUFF_OFFSET.
          ENDIF.
          MOVE 'N' TO G_BUFF+GBUFF_OFFSET(1).      "// 'N', nicht N_VAR
          ADD 1 TO GBUFF_OFFSET.
*         MOVE <F15> TO G_BUFF+GBUFF_OFFSET(15).
          MOVE DATA_TAB+1(15) TO G_BUFF+GBUFF_OFFSET(15).  "// ohne <f>
          ADD 15 TO GBUFF_OFFSET.
        WHEN '1'.                                           "// C2
*         Check Len
          LEN = GBUFF_OFFSET + 4.
          IF LEN > MAX_BUFFLEN.
            PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
            CLEAR: G_BUFF, GBUFF_OFFSET.
          ENDIF.
          MOVE 'C' TO G_BUFF+GBUFF_OFFSET(1).
          ADD 1 TO GBUFF_OFFSET.
*         MOVE <F2> TO G_BUFF+GBUFF_OFFSET.
          MOVE DATA_TAB+1(2) TO G_BUFF+GBUFF_OFFSET(2).  "// ohne <f>
          ADD 2 TO GBUFF_OFFSET.
        WHEN '2'.                                           "// C80
*         Check Len
          LEN = GBUFF_OFFSET + 82.
          IF LEN > MAX_BUFFLEN.
            PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
            CLEAR: G_BUFF, GBUFF_OFFSET.
          ENDIF.
          MOVE 'C' TO G_BUFF+GBUFF_OFFSET.
          ADD 1 TO GBUFF_OFFSET.
*         MOVE <F80> TO G_BUFF+GBUFF_OFFSET.
          MOVE DATA_TAB+1(80) TO G_BUFF+GBUFF_OFFSET(80).  "// ohne <f>
          ADD 80 TO GBUFF_OFFSET.
        WHEN OTHERS.                   "// should not happen
      ENDCASE.
*     Move Delimiter
      MOVE HEXNUL TO G_BUFF+GBUFF_OFFSET(1).
      ADD 1 TO GBUFF_OFFSET.
    ENDLOOP.
  ENDIF.                               "// Send it
ENDFORM.                    "GR_SEND_TAB


*---------------------------------------------------------------------*
*       FORM GR_SEND_C10_C2_C_L                                       *
*---------------------------------------------------------------------*
*       This is special version for NETZ / BARC                       *
*---------------------------------------------------------------------*
*  -->  C10                                                           *
*  -->  C2                                                            *
*  -->  C                                                             *
*  -->  SLEN                                                          *
*---------------------------------------------------------------------*
FORM GR_SEND_C10_C2_C_L USING C10  TYPE C
                              C2   LIKE GRAPH_C2
                              C    TYPE C
                              SLEN TYPE I.

  IF OBJECT_STAT = CONST_OBJ_CREATE.
    IF OBJECT_ID = CONST_DP.
      PERFORM DP_ADD_C10 USING C10.
      PERFORM DP_ADD_C2 USING C2.
      PERFORM DP_ADD_C_L USING C SLEN.
    ELSE.                              "// const_dp
*   append C10
      GRAPH_OBJECT-WINID = OBJECT_ID.
      GRAPH_OBJECT-MSG = 'C'.
      GRAPH_OBJECT-TXT = C10.
      APPEND GRAPH_OBJECT.
*   append C2
      GRAPH_OBJECT-WINID = OBJECT_ID.
      GRAPH_OBJECT-MSG = 'C'.
      GRAPH_OBJECT-TXT = C2.
      APPEND GRAPH_OBJECT.
*   append C
      GRAPH_OBJECT-WINID = OBJECT_ID.
      GRAPH_OBJECT-MSG = 'C'.
      GRAPH_OBJECT-TXT = C.
      APPEND GRAPH_OBJECT.
    ENDIF.                             "// const_dp
  ELSE.
*   nur 1 x LEN-check
    LEN = GBUFF_OFFSET + 10 + 2 + 2 + 2 + SLEN + 2.
    IF LEN > MAX_BUFFLEN.
      PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
      CLEAR: G_BUFF, GBUFF_OFFSET.
    ENDIF.

*   send C10
*   LEN = GBUFF_OFFSET + 12.           "// 10 + 2
*   IF LEN > MAX_BUFFLEN.
*     PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
*     CLEAR: G_BUFF, GBUFF_OFFSET.
*   ENDIF.
    MOVE 'C' TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.
    MOVE C10 TO G_BUFF+GBUFF_OFFSET(10).
    ADD 10 TO GBUFF_OFFSET.
    MOVE HEXNUL TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.
*   send C2

*   LEN = GBUFF_OFFSET + 4.            "// 2 + 2
*   IF LEN > MAX_BUFFLEN.
*     PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
*     CLEAR: G_BUFF, GBUFF_OFFSET.
*   ENDIF.
    MOVE 'C' TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.
    MOVE C2 TO G_BUFF+GBUFF_OFFSET(2).
    ADD 2 TO GBUFF_OFFSET.
    MOVE HEXNUL TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.
*   send C(SLEN)

*   LEN = GBUFF_OFFSET + SLEN + 2.     "// SLEN + 2
*   IF LEN > MAX_BUFFLEN.
*     PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
*     CLEAR: G_BUFF, GBUFF_OFFSET.
*   ENDIF.
    MOVE 'C' TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.
    IF SLEN > 0.
      MOVE C TO G_BUFF+GBUFF_OFFSET(SLEN).
      ADD SLEN TO GBUFF_OFFSET.
    ENDIF.
    MOVE HEXNUL TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.
  ENDIF.
ENDFORM.                    "GR_SEND_C10_C2_C_L

*---------------------------------------------------------------------*
*       FORM GR_SEND_I_C2_C_L                                         *
*---------------------------------------------------------------------*
*       This is special version for NETZ / BARC                       *
*       This replaces GR_SEND_I_C2_C80                                *
* GL      : 26.7.95
* Benfits : eliminate all spaces from integers
* Costs   : Condense(15-Byte), Strlen(15-Byte), Move(Strlen)
*---------------------------------------------------------------------*
*  -->  I                                                             *
*  -->  C2                                                            *
*  -->  C                                                             *
*  -->  SLEN                                                          *
*---------------------------------------------------------------------*
FORM GR_SEND_I_C2_C_L USING I    TYPE I
                            C2   LIKE GRAPH_C2
                            C    TYPE C
                            SLEN TYPE I.
  DATA: I_CHAR(15).
  DATA: I_LEN TYPE I.

  IF OBJECT_STAT = CONST_OBJ_CREATE.
    IF OBJECT_ID = CONST_DP.
      PERFORM DP_ADD_I USING I.
      PERFORM DP_ADD_C2 USING C2.
      PERFORM DP_ADD_C_L USING C SLEN.
    ELSE.                              "// const_dp
*   append I
      GRAPH_OBJECT-WINID = OBJECT_ID.
      GRAPH_OBJECT-MSG = 'N'.          "// its a number (negativ eg)
*   graph_object-txt = i.              "// ohne Aufbereitung
      I_CHAR = I.                        "// move-left-justified, no write
      GRAPH_OBJECT-TXT = I_CHAR.       "// faster than condense
      APPEND GRAPH_OBJECT.
*   append C2
      GRAPH_OBJECT-WINID = OBJECT_ID.
      GRAPH_OBJECT-MSG = 'C'.
      GRAPH_OBJECT-TXT = C2.
      APPEND GRAPH_OBJECT.
*   append C
      GRAPH_OBJECT-WINID = OBJECT_ID.
      GRAPH_OBJECT-MSG = 'C'.
      GRAPH_OBJECT-TXT = C.
      APPEND GRAPH_OBJECT.
    ENDIF.
  ELSE.

* gesamtlänge: 15 + 2 + 2 + 2 + SLEN + 2 = 23 + SLEN
* nur 1 x buffergrenzen checken
* Annahme: G_BUFF ist gross genug ( > 23 + SLEN )

*   LEN = GBUFF_OFFSET + 23 + SLEN.
*   IF LEN > MAX_BUFFLEN.
*     PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
*     CLEAR: G_BUFF, GBUFF_OFFSET.
*   ENDIF.

*   send I
    MOVE I TO I_CHAR.
    CONDENSE I_CHAR NO-GAPS.
    I_LEN = STRLEN( I_CHAR ).

    LEN = GBUFF_OFFSET + I_LEN + 2.                         "// 15 + 2
*   LEN = GBUFF_OFFSET + 17.           "// 15 + 2

    IF LEN > MAX_BUFFLEN.
      PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
      CLEAR: G_BUFF, GBUFF_OFFSET.
    ENDIF.
    MOVE 'N' TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.

    MOVE I_CHAR TO G_BUFF+GBUFF_OFFSET(I_LEN).
    ADD I_LEN TO GBUFF_OFFSET.
*   MOVE I TO G_BUFF+GBUFF_OFFSET(15).
*   ADD 15 TO GBUFF_OFFSET.

    MOVE HEXNUL TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.

*   send C2

    LEN = GBUFF_OFFSET + 4.                                 "// 2 + 2
    IF LEN > MAX_BUFFLEN.
      PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
      CLEAR: G_BUFF, GBUFF_OFFSET.
    ENDIF.
    MOVE 'C' TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.
    MOVE C2 TO G_BUFF+GBUFF_OFFSET(2).
    ADD 2 TO GBUFF_OFFSET.
    MOVE HEXNUL TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.

*   send C(SLEN)

    LEN = GBUFF_OFFSET + SLEN + 2.     "// SLEN + 2
    IF LEN > MAX_BUFFLEN.
      PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
      CLEAR: G_BUFF, GBUFF_OFFSET.
    ENDIF.
    MOVE 'C' TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.
    IF SLEN > 0.
      MOVE C TO G_BUFF+GBUFF_OFFSET(SLEN).
      ADD SLEN TO GBUFF_OFFSET.
    ENDIF.
    MOVE HEXNUL TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.
  ENDIF.
ENDFORM.                    "GR_SEND_I_C2_C_L

*---------------------------------------------------------------------*
*       FORM GR_SEND_I_I_C2_C_L                                       *
*---------------------------------------------------------------------*
*       This is a special version for NETZ / BARC                     *
*       This replaces GR_SEND_I_I_C2_C80                              *
* GL      : 26.7.95
* Benfits : eliminate all spaces from integers
* Costs   : Condense(15-Byte), Strlen(15-Byte), Move(Strlen)
*---------------------------------------------------------------------*
*  -->  I                                                             *
*  -->  J                                                             *
*  -->  C2                                                            *
*  -->  C                                                             *
*  -->  SLEN                                                          *
*---------------------------------------------------------------------*
FORM GR_SEND_I_I_C2_C_L USING I    TYPE I
                              J    TYPE I
                              C2   LIKE GRAPH_C2
                              C    TYPE C
                              SLEN TYPE I.
  DATA: I_CHAR(15).
  DATA: I_LEN TYPE I.

  IF OBJECT_STAT = CONST_OBJ_CREATE.
    IF OBJECT_ID = CONST_DP.
      PERFORM DP_ADD_I USING I.
      PERFORM DP_ADD_I USING J.
      PERFORM DP_ADD_C2 USING C2.
      PERFORM DP_ADD_C_L USING C SLEN.
    ELSE.                              "// const_dp
*   append I
      GRAPH_OBJECT-WINID = OBJECT_ID.
      GRAPH_OBJECT-MSG = 'N'.          "// its a number (negativ eg)
*   graph_object-txt = i.              "// ohne Aufbereitung
      I_CHAR = I.
      GRAPH_OBJECT-TXT = I_CHAR.
      APPEND GRAPH_OBJECT.
*   append J
      GRAPH_OBJECT-WINID = OBJECT_ID.
      GRAPH_OBJECT-MSG = 'N'.          "// its a number (negativ eg)
*   graph_object-txt = j.              "// ohne Aufbereitung
      I_CHAR = J.
      GRAPH_OBJECT-TXT = I_CHAR.
      APPEND GRAPH_OBJECT.
*   append C2
      GRAPH_OBJECT-WINID = OBJECT_ID.
      GRAPH_OBJECT-MSG = 'C'.
      GRAPH_OBJECT-TXT = C2.
      APPEND GRAPH_OBJECT.
*   append C
      GRAPH_OBJECT-WINID = OBJECT_ID.
      GRAPH_OBJECT-MSG = 'C'.
      GRAPH_OBJECT-TXT = C.
      APPEND GRAPH_OBJECT.
    ENDIF.                             "// const_dp
  ELSE.
*   send I
    MOVE I TO I_CHAR.
    CONDENSE I_CHAR NO-GAPS.
    I_LEN = STRLEN( I_CHAR ).

    LEN = GBUFF_OFFSET + I_LEN + 2.                         "// 15 + 2
*   LEN = GBUFF_OFFSET + 17.           "// 15 + 2

    IF LEN > MAX_BUFFLEN.
      PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
      CLEAR: G_BUFF, GBUFF_OFFSET.
    ENDIF.
    MOVE 'N' TO G_BUFF+GBUFF_OFFSET(1)."// it's a number(neg)
    ADD 1 TO GBUFF_OFFSET.

    MOVE I_CHAR TO G_BUFF+GBUFF_OFFSET(I_LEN).
    ADD I_LEN TO GBUFF_OFFSET.
*   MOVE I TO G_BUFF+GBUFF_OFFSET(15).
*   ADD 15 TO GBUFF_OFFSET.

    MOVE HEXNUL TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.
*   send J
    MOVE J TO I_CHAR.
    CONDENSE I_CHAR NO-GAPS.
    I_LEN = STRLEN( I_CHAR ).

    LEN = GBUFF_OFFSET + I_LEN + 2.                         "// 15 + 2
*   LEN = GBUFF_OFFSET + 17.           "// 15 + 2

    IF LEN > MAX_BUFFLEN.
      PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
      CLEAR: G_BUFF, GBUFF_OFFSET.
    ENDIF.
    MOVE 'N' TO G_BUFF+GBUFF_OFFSET(1)."// it's a number(neg)
    ADD 1 TO GBUFF_OFFSET.

    MOVE I_CHAR TO G_BUFF+GBUFF_OFFSET(I_LEN).
    ADD I_LEN TO GBUFF_OFFSET.
*   MOVE J TO G_BUFF+GBUFF_OFFSET(15).
*   ADD 15 TO GBUFF_OFFSET.

    MOVE HEXNUL TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.
*   send C2
    LEN = GBUFF_OFFSET + 4.                                 "// 2 + 2
    IF LEN > MAX_BUFFLEN.
      PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
      CLEAR: G_BUFF, GBUFF_OFFSET.
    ENDIF.
    MOVE 'C' TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.
    MOVE C2 TO G_BUFF+GBUFF_OFFSET(2).
    ADD 2 TO GBUFF_OFFSET.
    MOVE HEXNUL TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.
*   send C(SLEN)
    LEN = GBUFF_OFFSET + SLEN + 2.     "// SLEN + 2
    IF LEN > MAX_BUFFLEN.
      PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
      CLEAR: G_BUFF, GBUFF_OFFSET.
    ENDIF.
    MOVE 'C' TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.
    IF SLEN > 0.
      MOVE C TO G_BUFF+GBUFF_OFFSET(SLEN).
      ADD SLEN TO GBUFF_OFFSET.
    ENDIF.
    MOVE HEXNUL TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.
  ENDIF.
ENDFORM.                    "GR_SEND_I_I_C2_C_L


*---------------------------------------------------------------------*
*       FORM GR_SEND_C                                                *
*---------------------------------------------------------------------*
*       Optimierter Character-Send                                    *
*---------------------------------------------------------------------*
*  -->  TEXT : Sendstring                                             *
*---------------------------------------------------------------------*
FORM GR_SEND_C USING TEXT TYPE C.
* Object-Handler GL 31.1.1994
  IF OBJECT_STAT = CONST_OBJ_CREATE.
    IF OBJECT_ID = CONST_DP.
      PERFORM DP_ADD_C USING TEXT.
    ELSE.                              "// const_dp
      GRAPH_OBJECT-WINID = OBJECT_ID.
      GRAPH_OBJECT-MSG = 'C'.          "// Char ?? optimieren ??
      GRAPH_OBJECT-TXT = TEXT.
      APPEND GRAPH_OBJECT.
    ENDIF.                             "// const_Dp
  ELSE.
    FIELDLN = STRLEN( TEXT ).
    LEN = GBUFF_OFFSET + FIELDLN + 2.
    IF LEN > MAX_BUFFLEN.
      PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
      CLEAR: G_BUFF, GBUFF_OFFSET.
    ENDIF.
    MOVE 'C' TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.
    IF FIELDLN > 0.
      MOVE TEXT TO G_BUFF+GBUFF_OFFSET(FIELDLN).
      ADD FIELDLN TO GBUFF_OFFSET.
    ENDIF.
    WRITE HEXNUL TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.
  ENDIF.
ENDFORM.                    "GR_SEND_C

*---------------------------------------------------------------------*
*       FORM GR_SEND_C_L                                              *
*---------------------------------------------------------------------*
*       Optimierter Character-Send                                    *
*---------------------------------------------------------------------*
*  -->  TEXT : Sendstring                                             *
*       SLEN : Stringlänge
*---------------------------------------------------------------------*
FORM GR_SEND_C_L USING TEXT TYPE C
                       SLEN TYPE I.
* Object-Handler GL 31.1.1994
  IF OBJECT_STAT = CONST_OBJ_CREATE.
    IF OBJECT_ID = CONST_DP.
      PERFORM DP_ADD_C_L USING TEXT SLEN.
    ELSE.                              "// const_dp
      GRAPH_OBJECT-WINID = OBJECT_ID.
      GRAPH_OBJECT-MSG = 'C'.          "// Char ?? optimieren ??
      GRAPH_OBJECT-TXT = TEXT.
      APPEND GRAPH_OBJECT.
    ENDIF.                             "// const_Dp
  ELSE.
    LEN = GBUFF_OFFSET + SLEN + 2.
    IF LEN > MAX_BUFFLEN.
      PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
      CLEAR: G_BUFF, GBUFF_OFFSET.
    ENDIF.
    WRITE 'C' TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.
    IF SLEN > 0.
      MOVE TEXT TO G_BUFF+GBUFF_OFFSET(SLEN).
      ADD SLEN TO GBUFF_OFFSET.
    ENDIF.
    WRITE HEXNUL TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.
  ENDIF.
ENDFORM.                    "GR_SEND_C_L


*---------------------------------------------------------------------*
*       FORM GR_SEND_INT                                              *
*---------------------------------------------------------------------*
*       optimiertes senden von INTEGER an Grafik                      *
*---------------------------------------------------------------------*
*  -->  MYINT                                                         *
*---------------------------------------------------------------------*
FORM GR_SEND_INT USING MYINT TYPE I.
* DO NOT USE 'WRITE' for MYINT => would have 1000er-delimiters

* 3.0-spezifische optimierungen (Typisierung, move offset/len)
*

  DATA: I_CHAR(15).
  DATA: I_LEN TYPE I.

  IF OBJECT_STAT = CONST_OBJ_CREATE.
    IF OBJECT_ID = CONST_DP.
      PERFORM DP_ADD_I USING MYINT.
    ELSE.                              "// const_dp
      GRAPH_OBJECT-WINID = OBJECT_ID.
      GRAPH_OBJECT-MSG = 'N'.          "// its a number (negativ eg)
*   graph_object-txt = myint.          "// ohne Aufbereitung
*   CONDENSE GRAPH_OBJECT-TXT.         "// nicht notwendig
      I_CHAR = MYINT.
      GRAPH_OBJECT-TXT = I_CHAR.
      APPEND GRAPH_OBJECT.
    ENDIF.                             "// const_dp
  ELSE.
    MOVE MYINT TO I_CHAR.
    CONDENSE I_CHAR NO-GAPS.
    I_LEN = STRLEN( I_CHAR ).

    LEN = GBUFF_OFFSET + I_LEN + 2.                         "// 15 + 2
*   LEN = GBUFF_OFFSET + 17.           "// 15 + 2

    IF LEN > MAX_BUFFLEN.
      PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
      CLEAR: G_BUFF, GBUFF_OFFSET.
    ENDIF.

    MOVE 'N' TO G_BUFF+GBUFF_OFFSET(1)."// 2 konvertierungen ??
    ADD 1 TO GBUFF_OFFSET.

    MOVE I_CHAR TO G_BUFF+GBUFF_OFFSET(I_LEN).
    ADD I_LEN TO GBUFF_OFFSET.
*   MOVE MYINT TO G_BUFF+GBUFF_OFFSET(15).
*   ADD 15 TO GBUFF_OFFSET.

    MOVE HEXNUL TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.
  ENDIF.
ENDFORM.                    "GR_SEND_INT


*---------------------------------------------------------------------*
*       FORM GR_SEND                                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  MSG                                                           *
*  -->  TEXT                                                          *
*---------------------------------------------------------------------*
FORM GR_SEND USING MSG TYPE C TEXT.

  DATA P(3) TYPE P DECIMALS 2 VALUE 0.
  DATA P_TMP(10).
* DATA INDEX LIKE SY-FDPOS.
  DATA TYP(1).
  DATA TTEXT(511).                     "// maxlen inkl 0x00 = 512
  "// nur für Typ C sinnvoll

  CHECK GRAPH_RC EQ 0.

  HEXNUL = CL_ABAP_CHAR_UTILITIES=>MINCHAR.             "// GL 8.5.95

  DESCRIBE FIELD TEXT TYPE TYP.

* handle objects

  IF OBJECT_STAT = CONST_OBJ_CREATE.   "// Object-Buffer
    IF OBJECT_ID = CONST_DP.
      CASE MSG.
        WHEN 'C'.
          PERFORM DP_ADD_C USING TEXT.
        WHEN 'N'.
          CASE TYP.
            WHEN 'I'.
              PERFORM DP_ADD_I USING TEXT.
            WHEN 'P'.
              PERFORM DP_ADD_P USING TEXT.
            WHEN 'F'.
              PERFORM DP_ADD_F USING TEXT.
            WHEN OTHERS.
*             break-point.
          ENDCASE.
        WHEN 'T'.
          PERFORM DP_ADD_T USING TEXT.
        WHEN OTHERS.
*         ignore I, G, $
      ENDCASE.
    ELSE.                              "// const_dp
      GRAPH_OBJECT-WINID = OBJECT_ID.
      GRAPH_OBJECT-MSG = MSG.
      GRAPH_OBJECT-TXT = TEXT.
      IF MSG = 'N'.
        IF TYP = 'P'.                  "// Error 15.2.1993
          WRITE TEXT TO GRAPH_OBJECT-TXT."// Write-Formatierung
        ELSE.
          MOVE TEXT TO GRAPH_OBJECT-TXT.
        ENDIF.
        CONDENSE GRAPH_OBJECT-TXT.
      ENDIF.
      APPEND GRAPH_OBJECT.
    ENDIF.                             "// const_dp
  ELSE.                                "// normal Send

*----------------------------------------
*   einzelne GR_SEND bearbeiten
*----------------------------------------

*   Do not allow old 4.3-coding
*   IF MSG = 'Q' OR MSG = 'E'.
*     RAISE INV_GR_SEND_TYP.
*   ENDIF.

    CASE MSG.                          "// B, C, N, R, E, Q, D
*     C
      WHEN 'C'.
        IF TYP = 'C'.
          FIELDLN = STRLEN( TEXT ).
        ELSE.
          MOVE TEXT TO TTEXT.          "// konvert to Typ 'C'
          CONDENSE TTEXT.
          FIELDLN = STRLEN( TTEXT ).
        ENDIF.
        LEN = GBUFF_OFFSET + FIELDLN + 2.
        IF LEN > MAX_BUFFLEN.
          PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
          CHECK GRAPH_RC EQ 0.
          CLEAR: G_BUFF,GBUFF_OFFSET.
        ENDIF.
        WRITE 'C' TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
        IF TYP = 'C'.
          WRITE TEXT TO G_BUFF+GBUFF_OFFSET(FIELDLN).
        ELSE.
          WRITE TTEXT TO G_BUFF+GBUFF_OFFSET(FIELDLN).
        ENDIF.
        ADD FIELDLN TO GBUFF_OFFSET.
        WRITE HEXNUL     TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
*     N
      WHEN 'N'.
        IF TYP = 'P'.                  "// Error 15.2.1993
          WRITE TEXT TO TTEXT.         "// Write-Formatierung
        ELSE.
          MOVE TEXT TO TTEXT.
        ENDIF.
        CONDENSE TTEXT.
        FIELDLN = STRLEN( TTEXT ).
        LEN = GBUFF_OFFSET + FIELDLN + 2.
        IF LEN > MAX_BUFFLEN.
          PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
          CHECK GRAPH_RC EQ 0.
          CLEAR: G_BUFF,GBUFF_OFFSET.
        ENDIF.
        WRITE MSG TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
        WRITE TTEXT TO G_BUFF+GBUFF_OFFSET(FIELDLN).
        ADD FIELDLN TO GBUFF_OFFSET.
        WRITE HEXNUL     TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
*     Optmimiertes Character-Send, nur Typ C
      WHEN 'O'.                        "// Ohh
        FIELDLN = STRLEN( TEXT ).
        LEN = GBUFF_OFFSET + FIELDLN + 2.
        IF LEN > MAX_BUFFLEN.
          PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
          CLEAR: G_BUFF,GBUFF_OFFSET.
        ENDIF.
        WRITE 'C' TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
        WRITE TEXT TO G_BUFF+GBUFF_OFFSET(FIELDLN).
        ADD FIELDLN TO GBUFF_OFFSET.
        WRITE HEXNUL     TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
*     B
      WHEN 'B'.                        "// Start Child
        SY-SUBRC = 0.
        IF GLOBAL_GRAPH_INIT EQ SPACE.
          GLOBAL_GRAPH_INIT = 'X'.
          GLOBAL_GRAPH_INIT_G = 'X'.
          EXPORT GLOBAL_GRAPH_INIT_G TO MEMORY
                   ID 'global_graph_init_g'.
          CLEAR: G_BUFF,GBUFF_OFFSET.

          CALL FUNCTION 'WS_QUERY'
            EXPORTING
              QUERY          = 'WS'
            IMPORTING
              RETURN         = GLOBAL_WS
            EXCEPTIONS
              INV_QUERY      = 1
              NO_BATCH       = 2
              FRONTEND_ERROR = 3
              OTHERS         = 4.
          IF SY-SUBRC = 3.
            RAISE FRONTEND_ERROR.
          ENDIF.

        ENDIF.

*       IF GLOBAL_WS = 'JAVA'.         "// to be removed
*         GLOBAL_WS = NOGRAPH.
*       ENDIF.

        IF GLOBAL_WS = NOGRAPH.
          RAISE FRONTEND_ERROR.
        ENDIF.

        FIELDLN = STRLEN( TEXT ).
        LEN = GBUFF_OFFSET + FIELDLN + 5.
        IF LEN > MAX_BUFFLEN.
          PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
          CHECK GRAPH_RC EQ 0.
          CLEAR: G_BUFF,GBUFF_OFFSET.
        ENDIF.
*       WRITE '1V3.3' TO G_BUFF+GBUFF_OFFSET(5).   "// SAP-ABAP-Version
*       GL 25.3.1996
*       new version 3.4 : enables DblClk on StatusLine
        WRITE '1V3.4' TO G_BUFF+GBUFF_OFFSET(5).   "// SAP-ABAP-Version
        ADD 5 TO GBUFF_OFFSET.
        WRITE HEXNUL   TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
        WRITE 'L' TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
* Bei write wird sy-langu Konv-Exit ausgeführt der zu falscher Sprache
* führt. Siehe CSS 0000083732 1998 und Hinweis 92012 K.L. 10.02.98
*       WRITE sy-langu TO g_buff+gbuff_offset(1).    "// OLD
        MOVE SY-LANGU TO G_BUFF+GBUFF_OFFSET(1).     "// NEW
        ADD 1 TO GBUFF_OFFSET.
        WRITE HEXNUL     TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
        WRITE MSG TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
        WRITE TEXT TO G_BUFF+GBUFF_OFFSET(FIELDLN).
        ADD FIELDLN TO GBUFF_OFFSET.
        WRITE HEXNUL     TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
        WRITE 'D' TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
        IF DECIMAL IS INITIAL.
          CLEAR P_TMP.
          WRITE P TO P_TMP(10).
          SEARCH P_TMP FOR DECIMALG.
          IF SY-SUBRC EQ 0.
            DECIMAL =  DECIMALG.
          ELSE.
            DECIMAL =  DECIMALE.
          ENDIF.
        ENDIF.
        WRITE DECIMAL TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
        WRITE HEXNUL   TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
      WHEN 'R'.                        "// Receive
        CALL FUNCTION 'GRAPH_RECEIVE'.
        TEXT = ORG_RBUFF.
*     Z
      WHEN 'Z'.                        "// Kill all
        WRITE MSG TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
        WRITE HEXNUL     TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
        CALL FUNCTION 'GRAPH_RECEIVE'. "// jetzt e#r# dabei
*     E
      WHEN 'E'.                        "// disabled
*     Q
      WHEN 'Q'.                        "// disabled
*     D
      WHEN 'D'.
        CLEAR: G_BUFF,GBUFF_OFFSET.
        CLEAR: GLOBAL_GRAPH_INIT, GRAPH_CONV_ID.
        CLEAR GLOBAL_GRAPH_INIT_G.
        EXPORT GLOBAL_GRAPH_INIT_G TO MEMORY
                   ID 'global_graph_init_g'.
*     I
      WHEN 'I'.                        "// vgl 'C'.
*       IF TYP NE 'C'.
*         RAISE INV_GR_SEND_I_TYPE.
*       ENDIF.

        FIELDLN = STRLEN( TEXT ).
        LEN = GBUFF_OFFSET + FIELDLN + 2.
        IF LEN > MAX_BUFFLEN.
          PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
          CHECK GRAPH_RC EQ 0.
          CLEAR: G_BUFF,GBUFF_OFFSET.
        ENDIF.
        WRITE 'I' TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
        WRITE TEXT TO G_BUFF+GBUFF_OFFSET(FIELDLN).
        ADD FIELDLN TO GBUFF_OFFSET.
        WRITE HEXNUL     TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
        WRITE 'D' TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
        WRITE DECIMAL TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
        WRITE HEXNUL   TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
        WRITE '13' TO G_BUFF+GBUFF_OFFSET(2).
        ADD 2 TO GBUFF_OFFSET.
        WRITE HEXNUL   TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
        CASE PROTOCOL_ID.
          WHEN 'V01'.
            WRITE '$V01' TO G_BUFF+GBUFF_OFFSET(4).
            ADD 4 TO GBUFF_OFFSET.
            WRITE HEXNUL   TO G_BUFF+GBUFF_OFFSET(1).
            ADD 1 TO GBUFF_OFFSET.
          WHEN OTHERS.
*           RAISE INVALID_PROTOCOL_ID.
            WRITE '$V00' TO G_BUFF+GBUFF_OFFSET(4).
            ADD 4 TO GBUFF_OFFSET.
            WRITE HEXNUL   TO G_BUFF+GBUFF_OFFSET(1).
            ADD 1 TO GBUFF_OFFSET.
        ENDCASE.
*     others
      WHEN OTHERS.                     "// MSG =
        IF MSG EQ '1'.
          GLOBAL_GRAPH_INIT = 'X'.
          GLOBAL_GRAPH_INIT_G = 'X'.
          EXPORT GLOBAL_GRAPH_INIT_G TO MEMORY
                  ID 'global_graph_init_g'.
        ENDIF.
        "// GL 11.12.1992
        MOVE TEXT TO TTEXT.
        IF TYP NE 'C'.
          CONDENSE TTEXT.
        ENDIF.
        FIELDLN = STRLEN( TTEXT ).
        LEN = GBUFF_OFFSET + FIELDLN + 2.
        IF LEN > MAX_BUFFLEN.
          PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
          CHECK GRAPH_RC EQ 0.
          CLEAR: G_BUFF,GBUFF_OFFSET.
        ENDIF.
        WRITE MSG TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
        WRITE TTEXT TO G_BUFF+GBUFF_OFFSET(FIELDLN).
        ADD FIELDLN TO GBUFF_OFFSET.
        WRITE HEXNUL     TO G_BUFF+GBUFF_OFFSET(1).
        ADD 1 TO GBUFF_OFFSET.
    ENDCASE.

    SY-SUBRC = GRAPH_RC.
  ENDIF.                               "// object_stat
ENDFORM.                    "GR_SEND

*---------------------------------------------------------------------*
*       FORM GR_SENDT                                               *
*---------------------------------------------------------------------*
*       text                                                          *
*---------------------------------------------------------------------*
*       keine USING-Parameter                                         *
*---------------------------------------------------------------------*
FORM GR_SENDT TABLES SEND_TAB USING NAME.

  DATA TYP.
  FIELD-SYMBOLS: <F>.

  FIELDLN = STRLEN( NAME ).
  LEN = GBUFF_OFFSET + FIELDLN + 2.
  IF LEN > MAX_BUFFLEN.
    PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
    CHECK GRAPH_RC EQ 0.
    CLEAR: G_BUFF,GBUFF_OFFSET.
  ENDIF.
  WRITE 'T' TO G_BUFF+GBUFF_OFFSET(1).
  ADD 1 TO GBUFF_OFFSET.
  WRITE NAME   TO G_BUFF+GBUFF_OFFSET(FIELDLN).
  ADD FIELDLN TO GBUFF_OFFSET.
  WRITE HEXNUL TO G_BUFF+GBUFF_OFFSET(1).
  ADD 1 TO GBUFF_OFFSET.
  FIELDLN = 0.
  DO.
    ASSIGN COMPONENT SY-INDEX OF STRUCTURE SEND_TAB TO <F>.
    IF SY-SUBRC > 0. EXIT. ENDIF.
    DESCRIBE FIELD <F> OUTPUT-LENGTH LEN.
    FIELDLN = FIELDLN + LEN.
  ENDDO.
  LOOP AT SEND_TAB.
    LEN = GBUFF_OFFSET + FIELDLN + 2.
    IF LEN > MAX_BUFFLEN.
      PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
      CHECK GRAPH_RC EQ 0.
      CLEAR: G_BUFF,GBUFF_OFFSET.
    ENDIF.
    DO.
      ASSIGN COMPONENT SY-INDEX OF STRUCTURE SEND_TAB TO <F>.
      IF SY-SUBRC > 0. EXIT. ENDIF.
      DESCRIBE FIELD <F> TYPE TYP OUTPUT-LENGTH LEN.
      CASE TYP.
        WHEN 'P'.                      " Type P
          WRITE 'N' TO G_BUFF+GBUFF_OFFSET(1).
          ADD 1 TO GBUFF_OFFSET.
          WRITE <F> TO G_BUFF+GBUFF_OFFSET(LEN).
          ADD LEN TO GBUFF_OFFSET.
        WHEN 'F'.                      " Type F
          WRITE 'N' TO G_BUFF+GBUFF_OFFSET(1).
          ADD 1 TO GBUFF_OFFSET.
          WRITE <F> TO G_BUFF+GBUFF_OFFSET(LEN).
          ADD LEN TO GBUFF_OFFSET.
        WHEN 'C'.                      " Type C
          WRITE 'C' TO G_BUFF+GBUFF_OFFSET(1).
          ADD 1 TO GBUFF_OFFSET.
          SY-FDPOS = STRLEN( <F> ).
          WRITE <F> TO G_BUFF+GBUFF_OFFSET(SY-FDPOS).
          ADD SY-FDPOS TO GBUFF_OFFSET.
      ENDCASE.
      WRITE HEXNUL   TO G_BUFF+GBUFF_OFFSET(1).
      ADD 1 TO GBUFF_OFFSET.
    ENDDO.
  ENDLOOP.
  SY-SUBRC = GRAPH_RC.
ENDFORM.                    "GR_SENDT

*---------------------------------------------------------------------*
*       FORM SEND_DOWNLOAD_TAB                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  DATA_TAB                                                      *
*  -->  FTYPE      A : Ascii                                          *
*                  B : Binary                                         *
*                  C : Clipboard (Ascii)                              *
*                  D : 'DAT' (Ascii)                                  *
*                  V : 'VSS' (Ascii) GL 30.11.1995                    *
*                                                                     *
* Global settings: GLOBAL_FIXLEN_*                                    *
*                  GLOBAL_TRAIL_BLANKS                                *
*                                                                     *
*---------------------------------------------------------------------*
FORM SEND_DOWNLOAD_TAB TABLES DATA_TAB USING FTYPE.
* GL 30.11.95
* Implemented fix-size-ascii, trailing blanks -> only Ascii-Types
* GLOBAL_FIXLEN_USE / GLOBAL_TRAIL_BLANKS only in OTHERS ('A' / 'C')
* tested all combinations ASC / Clipboard with FIXLEN and TRAIL
* VSS always has trailing Blanks

  DATA: REST TYPE I.
  DATA: LINECOUNT LIKE SY-TABIX.
  DATA: LINES(1).  "// indicates 'lines are processed'
  FIELD-SYMBOLS: <FIX>.                "// if GLOBAL_FIXLEN_USE
  FIELD-SYMBOLS: <VSS_LEN>, <VSS_LINE>.

  CLEAR GLOBAL_SEND_DATA_TYPE.
  REST = GLOBAL_FSIZE.
  DESCRIBE TABLE DATA_TAB LINES LINECOUNT.

* Vorarbeiten.
  CASE FTYPE.
    WHEN 'B'.                          "// Binary
      GLOBAL_SEND_DATA_TYPE = 'B'.
    WHEN 'V'.                          "// VSS
      ASSIGN COMPONENT 1 OF STRUCTURE DATA_TAB TO <VSS_LEN>.
      ASSIGN COMPONENT 2 OF STRUCTURE DATA_TAB TO <VSS_LINE>.
*     check sy-subrc
  ENDCASE.


  DESCRIBE FIELD DATA_TAB LENGTH FIELDLN in byte mode.

  LEN = 0.
  CLEAR LINES.

* Assign part of entry, if wanted
  IF NOT GLOBAL_FIXLEN_USE IS INITIAL.
    IF GLOBAL_FIXLEN_TO >= FIELDLN.
      GLOBAL_FIXLEN_TO = FIELDLN - 1.
    ENDIF.
    GLOBAL_FIXLEN_LEN = GLOBAL_FIXLEN_TO - GLOBAL_FIXLEN_FROM + 1.
    ASSIGN DATA_TAB+GLOBAL_FIXLEN_FROM(GLOBAL_FIXLEN_LEN) TO <FIX>.
    FIELDLN = GLOBAL_FIXLEN_LEN.
  ENDIF.

  LOOP AT DATA_TAB.

    IF REST = 0 AND GLOBAL_SEND_DATA_TYPE EQ 'B'.
      EXIT.
    ENDIF.
    LINES = 'x'.

    CASE FTYPE.
      WHEN 'B'.                        "// binary
        DATA: ANZAHL TYPE I, FREE TYPE I, DATA_OFFSET TYPE I.
        FIELD-SYMBOLS: <HELP>.

        IF REST < FIELDLN.
          ANZAHL = REST.
        ELSE.
          ANZAHL = FIELDLN.
        ENDIF.

        DATA_OFFSET = 0.
        DO.                            "// langzeilen-loop
          FREE = MAX_BUFFLEN - GBUFF_OFFSET - 2.
          IF ANZAHL < FREE.
            ASSIGN DATA_TAB+DATA_OFFSET(ANZAHL) TO <HELP>.
            WRITE <HELP> TO G_BUFF+GBUFF_OFFSET(ANZAHL).
            ADD ANZAHL TO GBUFF_OFFSET.
            REST = REST - ANZAHL.
            ANZAHL = 0.
            EXIT.                      "// langzeilen-loop
          ENDIF.
          IF ANZAHL = FREE.
            ASSIGN DATA_TAB+DATA_OFFSET(ANZAHL) TO <HELP>.
            WRITE <HELP> TO G_BUFF+GBUFF_OFFSET(ANZAHL).
            ADD ANZAHL TO GBUFF_OFFSET.
            PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
            CHECK GRAPH_RC EQ 0.
            CLEAR: G_BUFF, GBUFF_OFFSET.
            REST = REST - ANZAHL.
            ANZAHL = 0.
            EXIT.                      "// langzeilen-loop
          ENDIF.
          IF ANZAHL > FREE.
            ASSIGN DATA_TAB+DATA_OFFSET(FREE) TO <HELP>.
            WRITE <HELP> TO G_BUFF+GBUFF_OFFSET(FREE).
            ADD FREE TO GBUFF_OFFSET.
            PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
            CHECK GRAPH_RC EQ 0.
            CLEAR: G_BUFF, GBUFF_OFFSET.
            ANZAHL = ANZAHL - FREE.
            ADD FREE TO DATA_OFFSET.
            REST = REST - FREE.
          ENDIF.
        ENDDO.                         "// langzeilen-loop
* bei BIN nur dann umbruch, wenn > ANZAHL
*       LEN = GBUFF_OFFSET + FIELDLN + 2.
*       IF LEN > MAX_BUFFLEN.
*         PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
*         CHECK GRAPH_RC EQ 0.
*         CLEAR: G_BUFF, GBUFF_OFFSET.
*       ENDIF.
* check rest:
*       IF REST > 0.
*         IF NOT REST < FIELDLN.       "// REST vgl FIELDLN
*           WRITE DATA_TAB TO G_BUFF+GBUFF_OFFSET(FIELDLN).
*           ADD FIELDLN TO GBUFF_OFFSET.
*           REST = REST - FIELDLN.
*         ELSE.                        "// REST < FIELDLN
*           WRITE DATA_TAB TO G_BUFF+GBUFF_OFFSET(REST).
*           ADD REST TO GBUFF_OFFSET.
*           REST = 0.
*         ENDIF.                       "// REST vgl FIELDLN
*       ENDIF.                         "// REST > 0
      WHEN 'V'.                        "// VSS, Ascii
*       GL 30.11.1995
*       VSS is Ascii with Line-Length <len> <string>
*       VSS always has trailing Blanks
        FIELDLN = <VSS_LEN>.
        LEN = GBUFF_OFFSET + FIELDLN + 2.
        IF LEN > MAX_BUFFLEN.
          PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
          CHECK GRAPH_RC EQ 0.
          CLEAR: G_BUFF, GBUFF_OFFSET.
        ENDIF.

        move CL_ABAP_CHAR_UTILITIES=>MINCHAR to TMASK(1).
        move '{' to TMASK+1(1).
        TRANSLATE <VSS_LINE> USING TMASK.

        WRITE <VSS_LINE> TO G_BUFF+GBUFF_OFFSET(FIELDLN).
        ADD FIELDLN TO GBUFF_OFFSET.
        IF GBUFF_OFFSET > MAX_BUFFLEN.
          GBUFF_OFFSET = MAX_BUFFLEN.  "// Abschneiden
        ENDIF.
        WRITE CL_ABAP_CHAR_UTILITIES=>NEWLINE TO G_BUFF+GBUFF_OFFSET.

        ADD 1 TO GBUFF_OFFSET.
      WHEN 'D'.                        "//  DAT, Ascii
*       GL 29.8.95
*       DAT will be generated in A2DAT for each line
*       DAT never has trailing Blanks
        DATA: A2DAT LIKE G_BUFF.
        IF NOT ( GLOBAL_FIELDNAMES IS INITIAL ).
*         Transfer Fieldnames only once
          FIELDLN = STRLEN( GLOBAL_FIELDNAMES ).
          LEN = GBUFF_OFFSET + FIELDLN + 2.
          IF LEN > MAX_BUFFLEN.
            PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
            CHECK GRAPH_RC EQ 0.
            CLEAR: G_BUFF, GBUFF_OFFSET.
          ENDIF.

          move CL_ABAP_CHAR_UTILITIES=>MINCHAR to TMASK(1).
          move '{' to TMASK+1(1).
          TRANSLATE GLOBAL_FIELDNAMES USING TMASK.

          WRITE GLOBAL_FIELDNAMES TO G_BUFF+GBUFF_OFFSET(FIELDLN).
          ADD FIELDLN TO GBUFF_OFFSET.
          IF GBUFF_OFFSET > MAX_BUFFLEN.
            GBUFF_OFFSET = MAX_BUFFLEN."// Abschneiden
          ENDIF.
          WRITE CL_ABAP_CHAR_UTILITIES=>NEWLINE TO G_BUFF+GBUFF_OFFSET.

          ADD 1 TO GBUFF_OFFSET.
          CLEAR GLOBAL_FIELDNAMES.
        ENDIF.                         "// Fieldnames
        PERFORM ABAP_2_DAT USING DATA_TAB A2DAT.
        FIELDLN = STRLEN( A2DAT ).
        LEN = GBUFF_OFFSET + FIELDLN + 2.
        IF LEN > MAX_BUFFLEN.
          PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
          CHECK GRAPH_RC EQ 0.
          CLEAR: G_BUFF, GBUFF_OFFSET.
        ENDIF.

        move CL_ABAP_CHAR_UTILITIES=>MINCHAR to TMASK(1).
        move '{' to TMASK+1(1).
        TRANSLATE A2DAT USING TMASK.

        WRITE A2DAT TO G_BUFF+GBUFF_OFFSET(FIELDLN).
        ADD FIELDLN TO GBUFF_OFFSET.
        IF GBUFF_OFFSET > MAX_BUFFLEN.
          GBUFF_OFFSET = MAX_BUFFLEN.  "// Abschneiden
        ENDIF.
        WRITE CL_ABAP_CHAR_UTILITIES=>NEWLINE TO G_BUFF+GBUFF_OFFSET.

        ADD 1 TO GBUFF_OFFSET.
      WHEN OTHERS.                     "// Ascii, Clipboard ('A', 'C')
* Fieldln has length of Table or length of part, if global_fixlen_use
* ASC or IBM can have trailing blanks
* ASC or IBM can have FIXLEN <from> <to>

        DATA: AKT_LEN TYPE I.

        IF GLOBAL_TRAIL_BLANKS IS INITIAL.
*         delete trainling blanks, so  take STRLEN
          IF GLOBAL_FIXLEN_USE IS INITIAL. "<< INSERT GL 24.07.97
            AKT_LEN = STRLEN( DATA_TAB ).
          ELSE.                        "<< INSERT GL 24.07.97
            AKT_LEN = STRLEN( <FIX> ). "<< INSERT GL 24.07.97
          ENDIF.                       "<< INSERT GL 24.07.97
        ELSE.
          AKT_LEN = FIELDLN.
        ENDIF.
        LEN = GBUFF_OFFSET + AKT_LEN + 2.
        IF LEN > MAX_BUFFLEN.
          PERFORM SEND_BUF USING G_BUFF GBUFF_OFFSET.
          CHECK GRAPH_RC EQ 0.
          CLEAR: G_BUFF, GBUFF_OFFSET.
        ENDIF.
* GL 15.3.1995 : Bei überlangen Feldern jetzt korrekter Truncate
*                Es werden maximal MAX_BUFFLEN NutzZeichen übertragen,
*                CRLF passt auch bei MAX_BUFFLEN noch hintendran !!

        IF GLOBAL_FIXLEN_USE IS INITIAL.

          move CL_ABAP_CHAR_UTILITIES=>MINCHAR to TMASK(1).
          move '{' to TMASK+1(1).
          TRANSLATE DATA_TAB USING TMASK.

          WRITE DATA_TAB TO G_BUFF+GBUFF_OFFSET(AKT_LEN).
        ELSE.                          "// use <fix> here

          move CL_ABAP_CHAR_UTILITIES=>MINCHAR to TMASK(1).
          move '{' to TMASK+1(1).
          TRANSLATE <FIX> USING TMASK.

          WRITE <FIX> TO G_BUFF+GBUFF_OFFSET(AKT_LEN).
        ENDIF.
        ADD AKT_LEN TO GBUFF_OFFSET.
*       evtl. Ueberschreiber, wenn SY-FDPOS zu gross -> truncate
        IF GBUFF_OFFSET > MAX_BUFFLEN.
          GBUFF_OFFSET = MAX_BUFFLEN.  "// Abschneiden
        ENDIF.
*       GL 11.02.1997: ASC-Download w/o CRLF
        IF NOT NO_ASC_CRLF IS INITIAL.
*         no CRLF
        ELSE.
          WRITE CL_ABAP_CHAR_UTILITIES=>NEWLINE TO G_BUFF+GBUFF_OFFSET.
          ADD 1 TO GBUFF_OFFSET.
        ENDIF.
    ENDCASE.
  ENDLOOP.
* Download abschliessen
  CASE FTYPE.
    WHEN 'B'.                          "// nothing
    WHEN 'A'.
      WRITE HEXNUL   TO G_BUFF+GBUFF_OFFSET(1).
      ADD 1 TO GBUFF_OFFSET.
    WHEN 'V'.                          "// Ascii 'DAT'
      WRITE HEXNUL   TO G_BUFF+GBUFF_OFFSET(1).
      ADD 1 TO GBUFF_OFFSET.
    WHEN 'D'.                          "// Ascii 'DAT'
      WRITE HEXNUL   TO G_BUFF+GBUFF_OFFSET(1).
      ADD 1 TO GBUFF_OFFSET.
    WHEN 'C'.                                               "// ohne 0A
*     letzte Zeile ohne CRLF
*     geht nur, wenn > 0 Zeilen
      IF LINECOUNT > 0.
        GBUFF_OFFSET = GBUFF_OFFSET - 1.                    "ohne 0A
      ENDIF.
      WRITE HEXNUL   TO G_BUFF+GBUFF_OFFSET(1).
      ADD 1 TO GBUFF_OFFSET.
  ENDCASE.
  IF NOT LINES IS INITIAL.             "// also keine Zeilen !!
    WRITE 'E'  TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.
    WRITE HEXNUL     TO G_BUFF+GBUFF_OFFSET(1).
    ADD 1 TO GBUFF_OFFSET.
  ENDIF.
* CLEAR DATA_TYPE.
ENDFORM.                    "SEND_DOWNLOAD_TAB

*---------------------------------------------------------------------*
*       FORM SO_OBJECT_INSERT                                         *
*---------------------------------------------------------------------*
*       insert graphic object into  SAPoffice                         *
*---------------------------------------------------------------------*
FORM SO_OBJECT_INSERT USING
            UNAME        TYPE C
            OBJ_TYPE     TYPE C
            OBJECT_TITLE
            OBJECT_CONTENTS TYPE C.
*ORM SO_OBJECT_INSERT                  "// TABLES OBJTAB
*              USING UNAME OBJ_TYPE OBJECT_TITLE OBJECT_CONTENTS.
  DATA: BEGIN OF NAME_STRU.
          INCLUDE STRUCTURE SOUD3.
  DATA: END OF NAME_STRU.
  DATA: BEGIN OF OBJECT_FL_CHANGE.
          INCLUDE STRUCTURE SOFM1.
  DATA: END OF OBJECT_FL_CHANGE.
  DATA: BEGIN OF OBJECT_HD_CHANGE.
          INCLUDE STRUCTURE SOOD1.
  DATA: END OF OBJECT_HD_CHANGE.
  DATA: BEGIN OF OBJHEAD OCCURS 0.
          INCLUDE STRUCTURE SOLI.
  DATA: END OF OBJHEAD.
  DATA: BEGIN OF OBJPARA OCCURS 0.
          INCLUDE STRUCTURE SELC.
  DATA: END OF OBJPARA.
  DATA: BEGIN OF OBJPARB OCCURS 0.
          INCLUDE STRUCTURE SOOP1.
  DATA: END OF OBJPARB.
  DATA: BEGIN OF OBJECTS OCCURS 0.
          INCLUDE STRUCTURE SOOD4.
  DATA: END OF OBJECTS.
  DATA: OBJECT_FL_DISPLAY LIKE SOFM2,
        OBJECT_HD_DISPLAY LIKE SOOD2,
        FOLDER_ID LIKE SOODK,
        FORWARDER LIKE SOUBK-USRNAM,
*       ONAME LIKE SY-UNAME,
        OBJECT_ID LIKE SOODK,
        OBJECT_TYPE LIKE SOOD-OBJTP,
        OUTBOX_FLAG LIKE SONV-FLAG,
        STORE_FLAG  LIKE SONV-FLAG.

  DATA: BEGIN OF OBJECT_ID_NEW.
          INCLUDE STRUCTURE SOODK.
  DATA: END OF OBJECT_ID_NEW.
  DATA: BEGIN OF RECEIVERS OCCURS 0.
          INCLUDE STRUCTURE SOOS1.
  DATA: END OF RECEIVERS.
  DATA: ON  LIKE SONV-FLAG VALUE 'X'.
*       OFF LIKE SONV-FLAG VALUE ' '.
  data: receiver_given type c value 'X'.

  REFRESH: OBJHEAD,
           OBJPARA,
           OBJPARB,
           RECEIVERS.

* Construct specific header for the graphics
  MOVE: OBJ_TYPE TO OBJHEAD.
  APPEND OBJHEAD.

  CLEAR: OBJECT_FL_CHANGE,
         OBJECT_HD_CHANGE.
  MOVE 'GRA'   TO OBJECT_TYPE.
* Assemble header information
  MOVE: SY-LANGU         TO OBJECT_HD_CHANGE-OBJLA,
        OBJECT_TITLE     TO OBJECT_HD_CHANGE-OBJNAM,
        OBJECT_CONTENTS  TO OBJECT_HD_CHANGE-OBJDES,
      'F'              TO OBJECT_HD_CHANGE-OBJSNS.    "Functional object

* Detect the SAPoffice user name for the SAP user SY-UNAME
  IF UNAME EQ SPACE.
    MOVE SY-UNAME TO NAME_STRU-SAPNAM.
    receiver_given = space.
  ELSE.
    IF  OBJ_TYPE EQ 'GMUX'.
      MOVE 'GRAPH' TO NAME_STRU-SAPNAM.
    ELSE.
      MOVE UNAME TO NAME_STRU-SAPNAM.
    ENDIF.
  ENDIF.
  CALL FUNCTION 'SO_NAME_CONVERT'
    EXPORTING
      NAME_IN               = NAME_STRU  " SY-UNAME comes in
    IMPORTING
      NAME_OUT              = NAME_STRU               " SAPoffice user name comes out
    EXCEPTIONS
      OFFICE_NAME_NOT_EXIST = 1
      PARAMETER_ERROR       = 2
      SAP_NAME_NOT_EXIST    = 3.
  CHECK SY-SUBRC EQ 0.

  IF SY-UNAME EQ SPACE.                " <--- immer mit SO_SEND
    IF  OBJ_TYPE EQ 'GMUX'.
      MOVE 'RAW'   TO OBJECT_TYPE.
    ENDIF.
* Find this persons personal root folder
    CALL FUNCTION 'SO_FOLDER_ROOT_ID_GET'
      EXPORTING
        OWNER           = NAME_STRU-USRNAM      " NEVER use SY-UNAME here
        REGION          = 'P'    " 'P' is personal folder
      IMPORTING
        FOLDER_ID       = FOLDER_ID  "ID of his root folder
      EXCEPTIONS
        OWNER_NOT_EXIST = 1.
    CHECK SY-SUBRC EQ 0.

* Ready to insert the new document into SAPoffice
    CALL FUNCTION 'SO_OBJECT_INSERT'
      EXPORTING
        FOLDER_ID                  = FOLDER_ID  "Root folder
        OBJECT_FL_CHANGE           = OBJECT_FL_CHANGE      "Folder data
        OBJECT_HD_CHANGE           = OBJECT_HD_CHANGE      "Header data
        OBJECT_TYPE                = OBJECT_TYPE  "See table TSOTD
        OWNER                      = NAME_STRU-USRNAM      "NOT SY-UNAME
      IMPORTING
        OBJECT_FL_DISPLAY          = OBJECT_FL_DISPLAY     "Trash in this
        OBJECT_HD_DISPLAY          = OBJECT_HD_DISPLAY     "... context
        OBJECT_ID                  = OBJECT_ID  "...
      TABLES
        OBJCONT                    = MAIL_TAB  "Contents
        OBJHEAD                    = OBJHEAD  "Header
        OBJPARA                    = OBJPARA  "Parameters
        OBJPARB                    = OBJPARB  "...
      EXCEPTIONS
        ACTIVE_USER_NOT_EXIST      = 1
        COMPONENT_NOT_AVAILABLE    = 2
        FOLDER_NO_AUTHORIZATION    = 3
        FOLDER_NOT_EXIST           = 4
        OBJECT_TYPE_NOT_EXIST      = 5
        OPERATION_NO_AUTHORIZATION = 6
        OWNER_NOT_EXIST            = 7
        PARAMETER_ERROR            = 8
        SUBSTITUTE_NOT_ACTIVE      = 9
        SUBSTITUTE_NOT_DEFINED     = 10.
    CHECK SY-SUBRC EQ 0.
  ELSE.

*      da das Objekt in den Ausgang soll
    MOVE ON TO OUTBOX_FLAG.
*      da das Objekt nicht in eine andere Mappe abgelegt werden soll
    CLEAR FOLDER_ID.
    CLEAR OBJECT_ID.
    CLEAR FORWARDER.
    CLEAR OBJECT_FL_CHANGE.
    CLEAR STORE_FLAG.
*      der spezifische Kopf, hier fuer RAW-Texte
*   CLEAR RECEIVERS.
*   MOVE NAME_STRU-USRNAM TO RECEIVERS-RECNAM.
*   MOVE OFF              TO RECEIVERS-ACALL.
*   MOVE OFF              TO RECEIVERS-FORFB.
*   MOVE OFF              TO RECEIVERS-PRIFB.
*   APPEND RECEIVERS.

* to enable sending of business grafik to receiver
    IF obj_type = 'BUSG' AND NOT uname EQ space.
      MOVE name_stru-usrnam TO receivers-recnam.
      MOVE name_stru-usrtp  TO receivers-rectp.
      MOVE name_stru-usryr  TO receivers-recyr.
      MOVE name_stru-usrno  TO receivers-recno.
    ENDIF.

* Detect the SAPoffice user name for the SAP user SY-UNAME
    CLEAR NAME_STRU.
    MOVE SY-UNAME TO NAME_STRU-SAPNAM.
    CALL FUNCTION 'SO_NAME_CONVERT'
      EXPORTING
        NAME_IN               = NAME_STRU  " SY-UNAME comes in
      IMPORTING
        NAME_OUT              = NAME_STRU             " SAPoffice user name comes out
      EXCEPTIONS
        OFFICE_NAME_NOT_EXIST = 1
        PARAMETER_ERROR       = 2
        SAP_NAME_NOT_EXIST    = 3.
    CHECK SY-SUBRC EQ 0.
    MOVE: OBJECT_TITLE     TO OBJECT_HD_CHANGE-OBJSRT.   "Sortiertfeld
*         'T'              TO OBJECT_HD_CHANGE-VMTYP,       "TA
*      'SO02'           TO OBJECT_HD_CHANGE-ACNAM.    "SAPOffice Ausgang
    move name_stru-usrnam to receivers-recnam.
    move name_stru-usrtp to receivers-RECtp.
    move name_stru-USRYR to receivers-RECYR.
    move name_stru-usrno to receivers-recno.
    append receivers.
* Senden
    if  receiver_given = space.
      CALL FUNCTION 'SO_DYNP_OBJECT_SEND'
        EXPORTING
          FOLDER_ID        = FOLDER_ID
          OBJECT_FL_CHANGE = OBJECT_FL_CHANGE
          OBJECT_HD_CHANGE = OBJECT_HD_CHANGE
          OBJECT_TYPE      = OBJECT_TYPE
          OUTBOX_FLAG      = 'S'
        IMPORTING
          OBJECT_ID_NEW    = OBJECT_ID_NEW
        TABLES
          OBJCONT          = MAIL_TAB
          OBJECTS          = OBJECTS
          OBJHEAD          = OBJHEAD
          OBJPARA          = OBJPARA
          OBJPARB          = OBJPARB
          REC_TAB          = RECEIVERS
        EXCEPTIONS
          OBJECT_NOT_SENT  = 01
          OWNER_NOT_EXIST  = 02
          PARAMETER_ERROR  = 03.
      CHECK SY-SUBRC EQ 0.
    else.
      CALL FUNCTION 'SO_OBJECT_SEND'
        EXPORTING
          FOLDER_ID                  = FOLDER_ID
          OBJECT_FL_CHANGE           = OBJECT_FL_CHANGE
          OBJECT_HD_CHANGE           = OBJECT_HD_CHANGE
          OBJECT_TYPE                = OBJECT_TYPE
          OUTBOX_FLAG                = 'S'
        IMPORTING
          OBJECT_ID_NEW              = OBJECT_ID_NEW
        TABLES
          OBJCONT                    = MAIL_TAB
          OBJHEAD                    = OBJHEAD
          OBJPARA                    = OBJPARA
          OBJPARB                    = OBJPARB
          RECEIVERS                  = RECEIVERS
          APPLICATION_OBJECT         = OBJECTS
        EXCEPTIONS
          ACTIVE_USER_NOT_EXIST      = 1
          COMMUNICATION_FAILURE      = 2
          COMPONENT_NOT_AVAILABLE    = 3
          FOLDER_NOT_EXIST           = 4
          FOLDER_NO_AUTHORIZATION    = 5
          FORWARDER_NOT_EXIST        = 6
          NOTE_NOT_EXIST             = 7
          OBJECT_NOT_EXIST           = 8
          OBJECT_NOT_SENT            = 9
          OBJECT_NO_AUTHORIZATION    = 10
          OBJECT_TYPE_NOT_EXIST      = 11
          OPERATION_NO_AUTHORIZATION = 12
          OWNER_NOT_EXIST            = 13
          PARAMETER_ERROR            = 14
          SUBSTITUTE_NOT_ACTIVE      = 15
          SUBSTITUTE_NOT_DEFINED     = 16
          SYSTEM_FAILURE             = 17
          TOO_MUCH_RECEIVERS         = 18
          USER_NOT_EXIST             = 19
          ORIGINATOR_NOT_EXIST       = 20
          X_ERROR                    = 21
          OTHERS                     = 22.
      check sy-subrc eq 0.
    endif.
    COMMIT WORK.
    CALL FUNCTION 'SO_DEQUEUE_UPDATE_LOCKS'.
  ENDIF.

  FREE: OBJHEAD,
*       OBJCONT,
        OBJPARA,
        OBJPARB,
        RECEIVERS.

ENDFORM.                    "SO_OBJECT_INSERT

*---------------------------------------------------------------------*
*       FORM SEND_BUF                                                 *
*---------------------------------------------------------------------*
*       fuegt an BUFFER noch 0x00 an,   macht APPEND SENDTAB          *
*---------------------------------------------------------------------*
*  -->  BUFFER                                                        *
*---------------------------------------------------------------------*
FORM SEND_BUF USING
*           BUFFER
            BUFFER       TYPE C
            LENGTH       LIKE GBUFF_OFFSET.
*ORM SEND_BUF USING BUFFER LENGTH.

* GL 19.3.1993
* Achtung: Aufpassen, dass nicht ueber die Grenze geschrieben wird
*          Im Abap-Runtime wird dies in 2.0 Basis nicht getestet
*          Vorher im GR_SEND auch fuer R, Q, Z etc. sicherstellen
*          Natuerlich auch im GR_RECVT


* Entwicklungs-Dokumentation
* --------------------------
* Die Sendetabelle wird zeilenweise mit einem Zeichen <> SPACE
* begrenzt. Dieses Zeichen wird vom DIAG abgeschnitten.
* Deswegen muss sowohl am Ende jeden Records ein HEXNUL als auch
* zusaetzlich am Ende jeder Zeile ein Zeichen stehen. Dafuer wird
* ebenfalls HEXNUL verwendet.

* CLEAR SENDTAB.
  CLEAR SENDTAB-BUF.
* WRITE BUFFER TO SENDTAB-BUF(LENGTH).
* WRITE HEXNUL TO SENDTAB-BUF+LENGTH(1).      "// evtl 2x HEXNUL
  MOVE BUFFER TO SENDTAB-BUF(LENGTH).
  MOVE HEXNUL TO SENDTAB-BUF+LENGTH(1)."// evtl 2x HEXNUL
  APPEND SENDTAB.
ENDFORM.                    "SEND_BUF
*---------------------------------------------------------------------*
*       FORM TERM_RECV                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  BUFFER                                                        *
*---------------------------------------------------------------------*
FORM TERM_RECV USING BUFFER.
  LOOP AT RECVTAB.
    MOVE RECVTAB TO BUFFER.
    EXIT.
  ENDLOOP.
ENDFORM.                    "TERM_RECV
*---------------------------------------------------------------------*
*       FORM TERM_SEND                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  BUFFER                                                        *
*---------------------------------------------------------------------*
FORM TERM_SEND USING BUFFER TYPE C LENGTH TYPE I.

  DATA PLEN TYPE I.                    "// Read it better
  PLEN = LENGTH.

  CASE BPOINTLEVEL.
    WHEN '1'.
      PERFORM BPOINT.
    WHEN '3'.
      PERFORM BPOINT.
  ENDCASE.

  CASE TRACELEVEL.
    WHEN '1'.
      WRITE: / 'SENDTAB_TRACE'.
      WRITE: / '============='.
      LOOP AT SENDTAB.
        WRITE: / SY-TABIX, '::', SENDTAB.
      ENDLOOP.
    WHEN '3'.
      WRITE: / 'SENDTAB_TRACE'.
      WRITE: / '============='.
      LOOP AT SENDTAB.
        WRITE: / SY-TABIX, '::', SENDTAB.
      ENDLOOP.
  ENDCASE.

  PERFORM SEND_BUF USING BUFFER LENGTH.
  REFRESH RECVTAB.

  IF WAN_IS_ACTIV EQ 'X'.              "Einzelner Satz senden

    REFRESH RTAB_V01.
    LOOP AT SENDTAB.
      RTAB_V01 = SENDTAB.
      APPEND RTAB_V01.
    ENDLOOP.
    REFRESH SENDTAB.
    CLEAR SENDTAB.
    WRITE '1BX' TO SENDTAB(3).
    WRITE HEXNUL TO SENDTAB+3(1).
    WRITE 'E' TO SENDTAB+4(1).
    WRITE HEXNUL TO SENDTAB+5(1).
    WRITE 'R' TO SENDTAB+6(1).
    WRITE HEXNUL TO SENDTAB+7(1).
    WRITE HEXNUL TO SENDTAB+8(1).
    APPEND SENDTAB.
    CALL SCREEN 100.
    REFRESH RECVTAB.
    REFRESH SENDTAB.
    LOOP AT RTAB_V01.
      CLEAR SENDTAB.
      WRITE 'BA' TO SENDTAB(2).
      WRITE RTAB_V01 TO SENDTAB+2(1022).
      APPEND SENDTAB.
      CALL SCREEN 100.
      REFRESH SENDTAB.
    ENDLOOP.
    REFRESH RTAB_V01.
    CLEAR SENDTAB.
    WRITE 'B0' TO SENDTAB(2).
    WRITE HEXNUL TO SENDTAB+2(1).
    APPEND SENDTAB.
    CALL SCREEN 100.
  ELSE.

    CALL SCREEN 100.

  ENDIF.

  REFRESH SENDTAB.

  CASE BPOINTLEVEL.
    WHEN '2'.
      PERFORM BPOINT.
    WHEN '3'.
      PERFORM BPOINT.
  ENDCASE.

  CASE TRACELEVEL.
    WHEN '2'.
      WRITE: / 'RECVTAB_TRACE'.
      WRITE: / '============='.
      LOOP AT RECVTAB.
        WRITE: / SY-TABIX, '::', RECVTAB.
      ENDLOOP.
    WHEN '3'.
      WRITE: / 'RECVTAB_TRACE'.
      WRITE: / '============='.
      LOOP AT RECVTAB.
        WRITE: / SY-TABIX, '::', RECVTAB.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    "TERM_SEND

*---------------------------------------------------------------------*
*       FORM GR_RECVT / GR_RECVT_NEU                                  *
*---------------------------------------------------------------------*
*       Fuer Protokol $V01 und SPACE                                  *
*       inklusive Massendaten-Loop, z.B. WS_UPLOAD                    *
*---------------------------------------------------------------------*
FORM GR_RECVT TABLES RTAB USING WINID ACTION.
  CALL FUNCTION 'GRAPH_RECEIVE'.       "// Receive inkl. Print
  CALL FUNCTION 'GRAPH_GET_RECVTAB'    "// Get Receivetable
       IMPORTING
            RWNID     = WINID
            MCODE     = ACTION
       TABLES
            G_RECVTAB = RTAB.
ENDFORM.                    "GR_RECVT
*------------------just the same--------------------------------------*
*ORM GR_RECVT_NEU TABLES RTAB USING WINID ACTION.
* CALL FUNCTION 'GRAPH_RECEIVE'.       "// Receive inkl. Print
* CALL FUNCTION 'GRAPH_GET_RECVTAB'    "// Get Receivetable
*      IMPORTING
*           RWNID     = WINID
*           MCODE     = ACTION
*      TABLES
*           G_RECVTAB = RTAB.
*NDFORM.                               "// GR_RECVT_NEU


*---------------------------------------------------------------------*
*       FORM GR_MAIL_INSERT                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  APPL : Application-Type, used to find correct Mail-Browser    *
*---------------------------------------------------------------------*
FORM GR_MAIL_INSERT USING APPL.

  DATA: MAIL_TITLE(40).
  DATA: MAIL_CONTENTS(80).
  DATA: MAIL_RECEIVER LIKE SY-UNAME.
  DATA: INDEX LIKE SY-TABIX.
  FIELD-SYMBOLS: <F>.

* GL 21.6.1995
* Direct Mail-insert into MAIL_TAB
*

* REFRESH MAIL_TAB.
* FREE MAIL_TAB.

  CLEAR INDEX.
* CALL FUNCTION 'GRAPH_GET_RECVTAB'    "// GL 16.7.1993
*      TABLES   G_RECVTAB = MAIL_TAB.

* Aufbau der Mail-Tabelle : GL 16.7.1993
*
* 0. Zeile         'T'-Message fuer Mail generell
* 1. Zeile (alt)   /$MAIL#          -> use Parameter APPL
*          (neu)   <application-key>#      "STAT"
*                  :<title>#
*                  :<contents>#
*                  :<receiver># (must be UPPERCASE)

  DATA: APP_KEY(4).

  LOOP AT MAIL_TAB.
    ADD 1 TO INDEX.
    IF MAIL_TAB CA HEXNUL.             "// Search 0x00
    ENDIF.
    CASE INDEX.
      WHEN 1.                          "// ignore 'T'-Message
      WHEN 2.                          "// '/$MAIL' or <app_key>
        IF MAIL_TAB(6) = '/$MAIL'.     "// old
          APP_KEY = APPL.
        ELSE.                          "// new
          APP_KEY = MAIL_TAB(4).
        ENDIF.
        DELETE MAIL_TAB.
      WHEN 3.                          "// :Title
        SY-FDPOS = SY-FDPOS - 1.
        IF SY-FDPOS NE 0.
          ASSIGN MAIL_TAB+1(SY-FDPOS) TO <F>.
          WRITE <F> TO MAIL_TITLE.
        ELSE.
          CLEAR MAIL_TITLE.
        ENDIF.
        DELETE MAIL_TAB.
      WHEN 4.                          "// :Contents
        SY-FDPOS = SY-FDPOS - 1.
        IF SY-FDPOS NE 0.
          ASSIGN MAIL_TAB+1(SY-FDPOS) TO <F>.
          WRITE <F> TO MAIL_CONTENTS.
        ELSE.
          CLEAR MAIL_CONTENTS.
        ENDIF.
        DELETE MAIL_TAB.
      WHEN 5.                          "// :Receiver
        SY-FDPOS = SY-FDPOS - 1.
        IF SY-FDPOS NE 0.
          ASSIGN MAIL_TAB+1(SY-FDPOS) TO <F>.
          TRANSLATE <F> TO UPPER CASE.
          WRITE <F> TO MAIL_RECEIVER.
        ELSE.
          CLEAR MAIL_RECEIVER.
        ENDIF.
        DELETE MAIL_TAB.
      WHEN OTHERS.                     "// raw graphic-data
        ASSIGN MAIL_TAB(SY-FDPOS) TO <F>.
        WRITE <F> TO MAIL_TAB.
        MODIFY MAIL_TAB.
    ENDCASE.
  ENDLOOP.

  PERFORM SO_OBJECT_INSERT             "// TABLES MAIL_TAB
          USING MAIL_RECEIVER APP_KEY MAIL_TITLE MAIL_CONTENTS.

  REFRESH MAIL_TAB.
  FREE MAIL_TAB.
ENDFORM.                               "// GR_MAIL_INSERT

*---------------------------------------------------------------------*
*       FORM SEND_HELP                                                *
*---------------------------------------------------------------------*
*       globale GRAPH_HELP schicken und danach löschen                *
*---------------------------------------------------------------------*
FORM SEND_HELP.
  DATA: ANZ TYPE I.
  DESCRIBE TABLE GRAPH_HELP LINES ANZ.
  IF ANZ NE 0.
    PERFORM GR_SEND USING 'T' '$HELP'.
    LOOP AT GRAPH_HELP.
      PERFORM GR_SEND_C USING GRAPH_HELP-KEY.
      PERFORM GR_SEND_C USING GRAPH_HELP-ABLE.
      PERFORM GR_SEND_C USING GRAPH_HELP-TEXT.
      PERFORM GR_SEND_C USING GRAPH_HELP-ACTID.
    ENDLOOP.
    REFRESH GRAPH_HELP.
  ENDIF.
ENDFORM.                    "SEND_HELP

*---------------------------------------------------------------------*
*       FORM SEND_ACTION                                              *
*---------------------------------------------------------------------*
*       globale GRAPH_ACTION schicken und danach löschen              *
*---------------------------------------------------------------------*
FORM SEND_ACTION.
  DATA: ANZ TYPE I.
  DESCRIBE TABLE GRAPH_ACTION LINES ANZ.
  IF ANZ NE 0.
    PERFORM GR_SEND USING 'T' '$ACTION'.
    LOOP AT GRAPH_ACTION.
      PERFORM GR_SEND_C USING GRAPH_ACTION-ACTID.
      PERFORM GR_SEND_C USING GRAPH_ACTION-ACTYP.
      PERFORM GR_SEND_C USING GRAPH_ACTION-ACTSTRING.
    ENDLOOP.
    REFRESH GRAPH_ACTION.
  ENDIF.
ENDFORM.                    "SEND_ACTION

*---------------------------------------------------------------------*
*       FORM SEND_ACTBAR                                              *
*---------------------------------------------------------------------*
*       globale GRAPH_ACTBAR schicken und danach löschen              *
*---------------------------------------------------------------------*
FORM SEND_ACTBAR.
  DATA: ANZ TYPE I.
  DESCRIBE TABLE GRAPH_ACTBAR LINES ANZ.
  IF ANZ NE 0.
    PERFORM GR_SEND USING 'T' '$ACTBAR'.
    LOOP AT GRAPH_ACTBAR.
      PERFORM GR_SEND_C USING GRAPH_ACTBAR-OMENU.
      PERFORM GR_SEND_C USING GRAPH_ACTBAR-SUBMENU.
      PERFORM GR_SEND_C USING GRAPH_ACTBAR-HELP_ID.
      PERFORM GR_SEND_C USING GRAPH_ACTBAR-POS.
      PERFORM GR_SEND_C USING GRAPH_ACTBAR-ATTR.
      PERFORM GR_SEND_C USING GRAPH_ACTBAR-ACT_ID.
      PERFORM GR_SEND_C USING GRAPH_ACTBAR-TEXT.
    ENDLOOP.
    REFRESH GRAPH_ACTBAR.
  ENDIF.
ENDFORM.                    "SEND_ACTBAR

*---------------------------------------------------------------------*
*       FORM GR_WINPOS                                                *
*---------------------------------------------------------------------*
*       Ermittlung Start-String mit Windowposition                    *
*---------------------------------------------------------------------*
*       DEFAULT_ID                                                    *
*       WINPOS                                                        *
*       WINSZX                                                        *
*       WINSZY                                                        *
*       STRING                                                        *
*---------------------------------------------------------------------*
FORM GR_WINPOS USING
            DEFAULT_ID
            WINPOS
            WINSZX
            WINSZY
            STRING       TYPE C.
*ORM GR_WINPOS USING DEFAULT_ID WINPOS WINSZX WINSZY STRING.

  DATA: W_X(10) , W_Y(10) , W_WD(10) , W_HT(10).
  DATA: W_P(1) , WTMP(50).

  IF WINPOS NE SPACE.
    W_P  = WINPOS.                                          "// typ C1
    CASE W_P.
      WHEN '1'.
        W_X = '0'.                     "// Toleranz 10 wg window-manager
        W_Y = ( 90 - WINSZY ).
      WHEN '2'.
        W_X = ( 50 - WINSZX / 2 ).
        W_Y = ( 90 - WINSZY ).
      WHEN '3'.
        W_X = ( 90 - WINSZY ).
        W_Y = ( 90 - WINSZY ).
      WHEN '4'.
        W_X = '0'.
        W_Y = ( 50 - WINSZY / 2 ).
      WHEN '5'.
        W_X = ( 50 - WINSZX / 2 ).
        W_Y = ( 50 - WINSZY / 2 ).
      WHEN '6'.
        W_X = ( 90 - WINSZY ).
        W_Y = ( 50 - WINSZY / 2 ).
      WHEN '7'.
        W_X = '0'.
        W_Y = '10'.
      WHEN '8'.
        W_X = ( 50 - WINSZX / 2 ).
        W_Y = '10'.
      WHEN '9'.
        W_X = ( 90 - WINSZX ).
        W_Y = '10'.
      WHEN OTHERS.
        W_X = '33'.
        W_Y = '33'.
    ENDCASE.
    W_WD = WINSZX.                                          "// typ C10
    W_HT = WINSZY.                                          "// typ C10
    WRITE W_X TO WTMP.  WRITE ',' TO WTMP+15.
    WRITE W_Y TO WTMP+16. WRITE ',' TO WTMP+26.
    WRITE W_WD TO WTMP+27. WRITE ',' TO WTMP+37.
    WRITE W_HT TO WTMP+38. WRITE ',R' TO WTMP+48.
    CONDENSE WTMP NO-GAPS.             "// alle SPACES raus
    STRING = DEFAULT_ID.               "// 4 Characters
    WRITE '$S=' TO STRING+5.
    WRITE WTMP TO STRING+8.
  ELSE.
    STRING = DEFAULT_ID.
  ENDIF.
ENDFORM.                    "GR_WINPOS


*---------------------------------------------------------------------*
*       FORM GR_START                                                 *
*---------------------------------------------------------------------*
*       text                                                          *
*---------------------------------------------------------------------*
*       P_STAT                                                        *
*       P_TEXT                                                        *
*---------------------------------------------------------------------*
FORM GR_START USING P_STAT P_TEXT.

  CASE P_STAT.
    WHEN ' '.
      PERFORM GR_SEND USING 'B' P_TEXT.
      ADD 1 TO CHILDCOUNT.
    WHEN '1'.
      PERFORM GR_SEND USING 'B' P_TEXT.
      ADD 1 TO CHILDCOUNT.
    WHEN '2'.
      PERFORM GR_SEND USING 'B' P_TEXT.
      ADD 1 TO CHILDCOUNT.
    WHEN '3'.
    WHEN '4'.
    WHEN '5'.
    WHEN '6'.
    WHEN '7'.
      PERFORM GR_SEND USING 'B' P_TEXT.
      ADD 1 TO CHILDCOUNT.
    WHEN OTHERS.
      P_STAT = '6'.
  ENDCASE.
ENDFORM.                    "GR_START

*---------------------------------------------------------------------*
*       FORM ABAP2FP                                                  *
*---------------------------------------------------------------------*
*       Konvertiert ABAP-Zahlen in Festpunktformat fuer Grafik        *
*---------------------------------------------------------------------*
*  -->  VAL         : Input, beliebiger Typ                           *
*  -->  RESULT      : Output vom Typ C                                *
*---------------------------------------------------------------------*
FORM ABAP2FP USING VAL RESULT TYPE C.
  DATA: VAL_TMP(40), TYP(1).
  CLEAR VAL_TMP.
  DESCRIBE FIELD VAL TYPE TYP.
  IF TYP = 'I' OR TYP = 'N' OR TYP = 'b' OR TYP = 's'.
* neu GL 11.10.94 'b' und 's'
    TYP = 'P'.
  ENDIF.
  CASE TYP.
    WHEN 'P'.
      IF VAL < 0.
*       WRITE '-' TO VAL_TMP.
*       VAL = ( VAL * -1 ).
*       MOVE VAL TO VAL_TMP+1.         "// immer Punkt
*       VAL = ( VAL * -1 ).
*
*       wegen Oberflow kein Multiplizieren
        MOVE VAL TO VAL_TMP+1.
        TRANSLATE VAL_TMP USING '- '.  "// minus weg
        WRITE '-' TO VAL_TMP(1).
        CONDENSE VAL_TMP NO-GAPS.
      ELSE.
        MOVE VAL TO VAL_TMP.
      ENDIF.
      CONDENSE VAL_TMP NO-GAPS.
    WHEN 'F'.
      IF VAL = 0.
        VAL_TMP = '0'.
      ELSE.
        WRITE VAL TO VAL_TMP EXPONENT 0.
      ENDIF.
      TRANSLATE VAL_TMP USING ',.'.
      CONDENSE VAL_TMP NO-GAPS.
    WHEN 'C'.                          "// evtl. Minuszeichen vor.
      IF VAL CA '-'.
        WRITE VAL TO VAL_TMP+1.
        TRANSLATE VAL_TMP USING '- '.
        WRITE '-' TO VAL_TMP(1).
        CONDENSE VAL_TMP NO-GAPS.
      ELSE.
        WRITE VAL TO VAL_TMP.
      ENDIF.
    WHEN OTHERS.
      VAL_TMP = VAL.                   "// uncontrolled move
  ENDCASE.
  RESULT = VAL_TMP.
ENDFORM.                                                    "ABAP2FP

*---------------------------------------------------------------------*
*       FORM W_COLOR_CHECK                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  COL                                                           *
*  -->  RET                                                           *
*---------------------------------------------------------------------*
FORM W_COLOR_CHECK USING COL TYPE C RET TYPE C.
  RET = '1'.                           "// true
  CASE COL.
    WHEN 'BLACK'.
    WHEN 'WHITE'.
    WHEN 'BLUE'.
    WHEN 'YELLOW'.
    WHEN 'GREEN'.
    WHEN 'MAGENTA'.
    WHEN 'RED'.
    WHEN 'CYAN'.
    WHEN 'GRAY'.
    WHEN 'GREY'.                       "// not in Doku
    WHEN 'DARKGRAY'.
    WHEN 'DARKGREY'.                   "// not in Doku
    WHEN 'DARKBLUE'.
    WHEN 'DARKYELLOW'.
    WHEN 'DARKGREEN'.
    WHEN 'DARKMAGENTA'.
    WHEN 'DARKRED'.
    WHEN 'DARKCYAN'.
    WHEN OTHERS.
      RET = '0'.                       "// false
  ENDCASE.

ENDFORM.                    "W_COLOR_CHECK

*---------------------------------------------------------------------*
*       FORM SEND_STATUS                                              *
*---------------------------------------------------------------------*
*       Absetzen der Parameter für Statuszeile                        *
*---------------------------------------------------------------------*
FORM SEND_STATUS.

  DATA: ID(50).

  ID = 'SET SYSID '.                   "// Reihenfolge für HIER
  WRITE SY-SYSID TO ID+10.             "// sehr wichtig
  CONDENSE ID.
  PERFORM GR_SEND_C USING ID.
  ID = 'SET SAPRL '.
  WRITE SY-SAPRL TO ID+10.
  CONDENSE ID.
  PERFORM GR_SEND_C USING ID.
  ID = 'SET SAPSYS R/3'.
  PERFORM GR_SEND_C USING ID.
ENDFORM.                    "SEND_STATUS

*---------------------------------------------------------------------*
*       FORM F_PROF_GET                                               *
*---------------------------------------------------------------------*
*       Vorabversion für FB PROFILE_GET                               *
*---------------------------------------------------------------------*
*  -->  FILENAME                                                      *
*  -->  SECTION                                                       *
*  -->  KEY                                                           *
*  -->  VALUE                                                         *
*---------------------------------------------------------------------*
*FORM F_PROF_GET USING FILENAME SECTION KEY VALUE.
*
*  CALL FUNCTION 'PROFILE_GET'
*       EXPORTING
*            FILENAME = FILENAME
*            KEY      = KEY
*            SECTION  = SECTION
*       IMPORTING
*            VALUE    = VALUE.
*
*ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  HELP_REQUEST
*&---------------------------------------------------------------------*
*       F1 / DblClk auf Statuszeile einer Grafik
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM HELP_REQUEST.

  TABLES: T100.
  DATA: HELP_INFO LIKE HELP_INFO.
  DATA: T1(80), T2(80), T3(80), T4(80), T5(80), MSGLI(128).
  DATA: BEGIN OF DUMMY_DYNPSELECT OCCURS 1.
          INCLUDE STRUCTURE DSELC.
  DATA: END OF DUMMY_DYNPSELECT.

  DATA: BEGIN OF DUMMY_DYNPVALUETAB OCCURS 1.
          INCLUDE STRUCTURE DVAL.
  DATA: END OF DUMMY_DYNPVALUETAB.

* check: not sy-msgid is initial,
*        not sy-msgno is initial,
*        sy-msgty = 'S'.               "nur S-Messages
  CHECK: NOT MY_MSGID IS INITIAL,
         NOT MY_MSGNO IS INITIAL,
         MY_MSGTY = 'S'.               "nur S-Messages

  CLEAR HELP_INFO.
* select single * from t100 where sprsl = sy-langu
*                             and arbgb = sy-msgid
*                             and msgnr = sy-msgno.
  SELECT SINGLE * FROM T100 WHERE SPRSL = SY-LANGU
                              AND ARBGB = MY_MSGID
                              AND MSGNR = MY_MSGNO.

  IF SY-SUBRC IS INITIAL.
    MSGLI = T100-TEXT.
*   perform substitute_message_text using msgli '&1' sy-msgv1.
*   perform substitute_message_text using msgli '&2' sy-msgv2.
*   perform substitute_message_text using msgli '&3' sy-msgv3.
*   perform substitute_message_text using msgli '&4' sy-msgv4.
*   if msgli cs '&'.
*     split msgli at '&' into t1 t2 t3 t4 t5.
*     concatenate t1 sy-msgv1 t2 sy-msgv2 t3 sy-msgv3 t4 sy-msgv4 t5
*                 into msgli separated by space.
*   endif.
    PERFORM SUBSTITUTE_MESSAGE_TEXT USING MSGLI '&1' MY_MSGV1.
    PERFORM SUBSTITUTE_MESSAGE_TEXT USING MSGLI '&2' MY_MSGV2.
    PERFORM SUBSTITUTE_MESSAGE_TEXT USING MSGLI '&3' MY_MSGV3.
    PERFORM SUBSTITUTE_MESSAGE_TEXT USING MSGLI '&4' MY_MSGV4.
    IF MSGLI CS '&'.
      SPLIT MSGLI AT '&' INTO T1 T2 T3 T4 T5.
      CONCATENATE T1 MY_MSGV1 T2 MY_MSGV2 T3 MY_MSGV3 T4 MY_MSGV4 T5
                  INTO MSGLI SEPARATED BY SPACE.
    ENDIF.
  ENDIF.

  HELP_INFO-CALL       = 'D'.
  HELP_INFO-SPRAS      = SY-LANGU.
  HELP_INFO-OBJECT     = 'N'.
  HELP_INFO-DOCUID     = 'NA'.
* HELP_INFO-DYNPRO     = MESSDYNNR.
  HELP_INFO-MESSAGE    = MSGLI.
* help_info-messageid  = sy-msgid.
* help_info-messagenr  = sy-msgno.
* help_info-msgv1      = sy-msgv1.
* help_info-msgv2      = sy-msgv2.
* help_info-msgv3      = sy-msgv3.
* help_info-msgv4      = sy-msgv4.
  HELP_INFO-MESSAGEID  = MY_MSGID.
  HELP_INFO-MESSAGENR  = MY_MSGNO.
  HELP_INFO-MSGV1      = MY_MSGV1.
  HELP_INFO-MSGV2      = MY_MSGV2.
  HELP_INFO-MSGV3      = MY_MSGV3.
  HELP_INFO-MSGV4      = MY_MSGV4.

* HELP_INFO-PFKEY      = MESSPFKEY.
* HELP_INFO-PROGRAM    = MESSPROGR.
* HELP_INFO-TITLE      = MESSTITLE.

  CALL FUNCTION 'HELP_START'
    EXPORTING
      HELP_INFOS   = HELP_INFO
    TABLES
      DYNPSELECT   = DUMMY_DYNPSELECT
      DYNPVALUETAB = DUMMY_DYNPVALUETAB.

* clear: sy-msgid, sy-msgty, sy-msgno.
ENDFORM.                               " HELP_REQUEST

*---------------------------------------------------------------------*
*       FORM SUBSTITUTE_MESSAGE_TEXT                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  TEXT                                                          *
*  -->  PARAM                                                         *
*  -->  MSGV                                                          *
*---------------------------------------------------------------------*
FORM SUBSTITUTE_MESSAGE_TEXT USING TEXT  TYPE C
                                   PARAM TYPE C
                                   MSGV  LIKE SY-MSGV1.

  DATA: T1(80), T2(80), T3(80), T4(80), T5(80).

  CHECK TEXT CS PARAM.
  SPLIT TEXT AT PARAM INTO T1 T2 T3 T4 T5.
  IF NOT T5 IS INITIAL.
    CONCATENATE T1 MSGV T2 MSGV T3 MSGV T4 MSGV T5
                INTO TEXT SEPARATED BY SPACE.
  ELSEIF NOT T4 IS INITIAL.
    CONCATENATE T1 MSGV T2 MSGV T3 MSGV T4
                INTO TEXT SEPARATED BY SPACE.
  ELSEIF NOT T3 IS INITIAL.
    CONCATENATE T1 MSGV T2 MSGV T3
                INTO TEXT SEPARATED BY SPACE.
  ELSE.
    CONCATENATE T1 MSGV T2
                INTO TEXT SEPARATED BY SPACE.
  ENDIF.

ENDFORM.                               "SUBSTITUTE_MESSAGE_TEXT

*---------------------------------------------------------------------*
*       FORM QUERY_FILENAME                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM QUERY_FILENAME USING DEF_PATH LIKE RLGRAP-FILENAME
                          MODE     TYPE C.

  DATA: TMP_FILENAME LIKE RLGRAP-FILENAME.
  DATA: TMP_MASK LIKE GLOBAL_FILEMASK_ALL.
  FIELD-SYMBOLS: <TMP_SYM>.

* Build Filter for Fileselektor

  IF GLOBAL_FILEMASK_MASK IS INITIAL.
    TMP_MASK = ',*.*,*.*.'.
  ELSE.
    TMP_MASK = ','.
    WRITE GLOBAL_FILEMASK_TEXT TO TMP_MASK+1.
    WRITE ',' TO TMP_MASK+21.
    WRITE GLOBAL_FILEMASK_MASK TO TMP_MASK+22.
    WRITE '.' TO TMP_MASK+42.
    CONDENSE TMP_MASK NO-GAPS.
  ENDIF.

  IF NOT GLOBAL_FILEMASK_ALL IS INITIAL.
    TMP_MASK = GLOBAL_FILEMASK_ALL.
  ENDIF.

  FIELDLN = STRLEN( DEF_PATH ) - 1.
  ASSIGN DEF_PATH+FIELDLN(1) TO <TMP_SYM>.
  IF <TMP_SYM> = '/' OR <TMP_SYM> = '\'.
    CLEAR <TMP_SYM>.
  ENDIF.

  CALL FUNCTION 'WS_FILENAME_GET'
       EXPORTING
            DEF_FILENAME     = RLGRAP-FILENAME
            DEF_PATH         = DEF_PATH
*           MASK             = ',*.*,*.*.'
            MASK             = TMP_MASK
            MODE             = MODE
*           TITLE            = ' '
       IMPORTING
            FILENAME         = TMP_FILENAME
*         RC               =
       EXCEPTIONS
            INV_WINSYS       = 01
            NO_BATCH         = 02
            SELECTION_CANCEL = 03
            SELECTION_ERROR  = 04.

  IF SY-SUBRC = 0.
    RLGRAP-FILENAME = TMP_FILENAME.
  ELSE.
* IF SY-SUBRC = 01.    "// Does not work, why ???
*   MESSAGELINE = 'Not supported'.
* ENDIF.
  ENDIF.

ENDFORM.                    "QUERY_FILENAME

*---------------------------------------------------------------------*
*       FORM SET_NO_ASC_CRLF                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  VAL                                                           *
*---------------------------------------------------------------------*
FORM SET_NO_ASC_CRLF USING VAL TYPE C.
  NO_ASC_CRLF = VAL.
ENDFORM.                    "SET_NO_ASC_CRLF

*---------------------------------------------------------------------*
*       FORM GET_CUA_INFO                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  CUA_PROG                                                      *
*  -->  CUA_STAT                                                      *
*  -->  CUA_FLAG                                                      *
*---------------------------------------------------------------------*
FORM GET_CUA_INFO USING CUA_PROG TYPE C CUA_STAT TYPE C CUA_FLAG TYPE C.
  CUA_PROG = GLOBAL_CUA_PROG.
  CUA_STAT = GLOBAL_CUA_STAT.
  CUA_FLAG = GLOBAL_CUA_FLAG.
ENDFORM.                    "GET_CUA_INFO


*---------------------------------------------------------------------*
*       FORM DP_ADD_C                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  C                                                             *
*---------------------------------------------------------------------*
FORM DP_ADD_C USING C TYPE C.
  DATA: S_LEN TYPE I.
  S_LEN = STRLEN( C ).
  LEN = DP_BUFF_OFFSET + S_LEN + 2.
  IF LEN > CONST_DP_LEN.
    APPEND DP_GRAPH_OBJ.
    CLEAR: DP_GRAPH_OBJ, DP_BUFF_OFFSET.
  ENDIF.
  MOVE ':' TO DP_GRAPH_OBJ+DP_BUFF_OFFSET(1).
  ADD 1 TO DP_BUFF_OFFSET.
  IF S_LEN > 0.
    MOVE C TO DP_GRAPH_OBJ+DP_BUFF_OFFSET(S_LEN).
    ADD S_LEN TO DP_BUFF_OFFSET.
  ENDIF.
  MOVE HEXNUL TO DP_GRAPH_OBJ+DP_BUFF_OFFSET(1).
  ADD 1 TO DP_BUFF_OFFSET.
ENDFORM.                    "DP_ADD_C
*---------------------------------------------------------------------*
*       FORM DP_ADD_C10                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  C10                                                           *
*---------------------------------------------------------------------*
FORM DP_ADD_C10 USING C10 TYPE C.
  CONSTANTS: S_LEN TYPE I VALUE 10.
  LEN = DP_BUFF_OFFSET + S_LEN + 2.
  IF LEN > CONST_DP_LEN.
    APPEND DP_GRAPH_OBJ.
    CLEAR: DP_GRAPH_OBJ, DP_BUFF_OFFSET.
  ENDIF.
  MOVE ':' TO DP_GRAPH_OBJ+DP_BUFF_OFFSET(1).
  ADD 1 TO DP_BUFF_OFFSET.
  MOVE C10 TO DP_GRAPH_OBJ+DP_BUFF_OFFSET(S_LEN).
  ADD S_LEN TO DP_BUFF_OFFSET.
  MOVE HEXNUL TO DP_GRAPH_OBJ+DP_BUFF_OFFSET(1).
  ADD 1 TO DP_BUFF_OFFSET.
ENDFORM.                                                    "DP_ADD_C10
*---------------------------------------------------------------------*
*       FORM DP_ADD_C2                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  C2                                                            *
*---------------------------------------------------------------------*
FORM DP_ADD_C2 USING C2 TYPE C.
  CONSTANTS: S_LEN TYPE I VALUE 2.
  LEN = DP_BUFF_OFFSET + S_LEN + 2.
  IF LEN > CONST_DP_LEN.
    APPEND DP_GRAPH_OBJ.
    CLEAR: DP_GRAPH_OBJ, DP_BUFF_OFFSET.
  ENDIF.
  MOVE ':' TO DP_GRAPH_OBJ+DP_BUFF_OFFSET(1).
  ADD 1 TO DP_BUFF_OFFSET.
  MOVE C2 TO DP_GRAPH_OBJ+DP_BUFF_OFFSET(S_LEN).
  ADD S_LEN TO DP_BUFF_OFFSET.
  MOVE HEXNUL TO DP_GRAPH_OBJ+DP_BUFF_OFFSET(1).
  ADD 1 TO DP_BUFF_OFFSET.
ENDFORM.                                                    "DP_ADD_C2
*---------------------------------------------------------------------*
*       FORM DP_ADD_C_L                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  C                                                             *
*  -->  SLEN                                                          *
*---------------------------------------------------------------------*
FORM DP_ADD_C_L USING C TYPE C S_LEN TYPE I.
  LEN = DP_BUFF_OFFSET + S_LEN + 2.
  IF LEN > CONST_DP_LEN.
    APPEND DP_GRAPH_OBJ.
    CLEAR: DP_GRAPH_OBJ, DP_BUFF_OFFSET.
  ENDIF.
  MOVE ':' TO DP_GRAPH_OBJ+DP_BUFF_OFFSET(1).
  ADD 1 TO DP_BUFF_OFFSET.
  IF S_LEN >  0.
    MOVE C TO DP_GRAPH_OBJ+DP_BUFF_OFFSET(S_LEN).
    ADD S_LEN TO DP_BUFF_OFFSET.
  ENDIF.
  MOVE HEXNUL TO DP_GRAPH_OBJ+DP_BUFF_OFFSET(1).
  ADD 1 TO DP_BUFF_OFFSET.
ENDFORM.                    "DP_ADD_C_L
*---------------------------------------------------------------------*
*       FORM DP_ADD_T                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  TEXT                                                          *
*---------------------------------------------------------------------*
FORM DP_ADD_T USING TEXT TYPE C.
* add /$
  DATA: S_LEN TYPE I.
  S_LEN = STRLEN( TEXT ).
  LEN = DP_BUFF_OFFSET + S_LEN + 2.
  IF LEN > CONST_DP_LEN.
    APPEND DP_GRAPH_OBJ.
    CLEAR: DP_GRAPH_OBJ, DP_BUFF_OFFSET.
  ENDIF.
  MOVE '/' TO DP_GRAPH_OBJ+DP_BUFF_OFFSET(1).
  ADD 1 TO DP_BUFF_OFFSET.
  IF S_LEN > 0.
    MOVE TEXT TO DP_GRAPH_OBJ+DP_BUFF_OFFSET(S_LEN).
    ADD S_LEN TO DP_BUFF_OFFSET.
  ENDIF.
  MOVE HEXNUL TO DP_GRAPH_OBJ+DP_BUFF_OFFSET(1).
  ADD 1 TO DP_BUFF_OFFSET.
ENDFORM.                    "DP_ADD_T
*---------------------------------------------------------------------*
*       FORM DP_ADD_I                                                 *
*---------------------------------------------------------------------*
FORM DP_ADD_I USING MYINT TYPE I.
* I->MOVE
  DATA: N_LEN TYPE I.
  DATA: N_CHAR(15).
  MOVE MYINT TO N_CHAR.
  CONDENSE N_CHAR NO-GAPS.
  N_LEN = STRLEN( N_CHAR ).
  LEN = DP_BUFF_OFFSET + N_LEN + 2.
  IF LEN > CONST_DP_LEN.
    APPEND DP_GRAPH_OBJ.
    CLEAR: DP_GRAPH_OBJ, DP_BUFF_OFFSET.
  ENDIF.
* (-) vor, move I->C never generates delimiters
  IF MYINT < 0.
    MOVE ':-' TO DP_GRAPH_OBJ+DP_BUFF_OFFSET(2).
    ADD 2 TO DP_BUFF_OFFSET.
    N_LEN = N_LEN - 1.
  ELSE.
    MOVE ':' TO DP_GRAPH_OBJ+DP_BUFF_OFFSET(1).
    ADD 1 TO DP_BUFF_OFFSET.
  ENDIF.
  MOVE N_CHAR TO DP_GRAPH_OBJ+DP_BUFF_OFFSET(N_LEN).
  ADD N_LEN TO DP_BUFF_OFFSET.
  MOVE HEXNUL TO DP_GRAPH_OBJ+DP_BUFF_OFFSET(1).
  ADD 1 TO DP_BUFF_OFFSET.
ENDFORM.                    "DP_ADD_I
*---------------------------------------------------------------------*
*       FORM DP_ADD_P                                                 *
*---------------------------------------------------------------------*
FORM DP_ADD_P USING P TYPE P.
* P->WRITE, (-) vor, get rid of 1000er, Dez = '.'
  DATA: N_LEN TYPE I.
  DATA: N_CHAR(128).
  WRITE P TO N_CHAR.
  CONDENSE N_CHAR NO-GAPS.
  N_LEN = STRLEN( N_CHAR ).
  LEN = DP_BUFF_OFFSET + N_LEN + 2.
  IF LEN > CONST_DP_LEN.
    APPEND DP_GRAPH_OBJ.
    CLEAR: DP_GRAPH_OBJ, DP_BUFF_OFFSET.
  ENDIF.
  MOVE ':' TO DP_GRAPH_OBJ+DP_BUFF_OFFSET(1).
  ADD 1 TO DP_BUFF_OFFSET.
* (-) vor, get rid of 1000er, Dez = '.'
  DATA: CONVERTED LIKE N_CHAR.
  PERFORM DP_CONVERT USING N_CHAR CHANGING CONVERTED.
  N_CHAR = CONVERTED.
  MOVE N_CHAR TO DP_GRAPH_OBJ+DP_BUFF_OFFSET(N_LEN).
  ADD N_LEN TO DP_BUFF_OFFSET.
  MOVE HEXNUL TO DP_GRAPH_OBJ+DP_BUFF_OFFSET(1).
  ADD 1 TO DP_BUFF_OFFSET.
ENDFORM.                    "DP_ADD_P
*---------------------------------------------------------------------*
*       FORM DP_ADD_F                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  F                                                             *
*---------------------------------------------------------------------*
FORM DP_ADD_F USING F TYPE F.
* F->MOVE -> (-) vor
  DATA: F_CHAR(40).
  F_CHAR = F.
  IF F < 0.
    F = F * ( -1 ).
    F_CHAR = F.
    CONCATENATE '-' F_CHAR INTO F_CHAR.
  ENDIF.
  PERFORM DP_ADD_C USING F_CHAR.
ENDFORM.                    "DP_ADD_F
*---------------------------------------------------------------------*
*       FORM DP_CONVERT                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IN                                                            *
*  -->  OUT                                                           *
*---------------------------------------------------------------------*
FORM DP_CONVERT USING IN OUT.
* Decimals
  DATA: P_TMP(20).
  DATA P(3) TYPE P DECIMALS 2 VALUE 0.
  IF DECIMAL IS INITIAL.
    CLEAR P_TMP.
    WRITE P TO P_TMP(10).
    SEARCH P_TMP FOR DECIMALG.
    IF SY-SUBRC EQ 0.
      DECIMAL =  DECIMALG.
    ELSE.
      DECIMAL =  DECIMALE.
    ENDIF.
  ENDIF.
* (-) vor, get rid of 1000er, Dez = '.'
  DATA: LEN TYPE I.
  FIELD-SYMBOLS: <LAST>, <BODY>.
  LEN = STRLEN( IN ) - 1.

  IF LEN > 0.
    ASSIGN IN+LEN(1) TO <LAST>.
    ASSIGN IN(LEN) TO <BODY>.
    IF <LAST> = '-'.
      CONCATENATE '-' <BODY> INTO OUT.
    ELSE.
      OUT = IN.
    ENDIF.
  ELSE.
    OUT = IN.
  ENDIF.                                                    "// len > 0
  IF DECIMAL = ','.
    TRANSLATE OUT USING '. '.          "// get rid of 1000er
    CONDENSE OUT NO-GAPS.
    TRANSLATE OUT USING ',.'.          "// DECIMAL = '.'
  ELSE.
    TRANSLATE OUT USING ', '.          "// get rid of 1000er
    CONDENSE OUT NO-GAPS.
  ENDIF.
ENDFORM.                    "DP_CONVERT

*&---------------------------------------------------------------------*
*&      Form  IS_GR_INIT_GLOBAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->INIT       text
*----------------------------------------------------------------------*
FORM IS_GR_INIT_GLOBAL CHANGING INIT.
  IMPORT GLOBAL_GRAPH_INIT_G FROM MEMORY ID 'global_graph_init_g'.
  INIT = GLOBAL_GRAPH_INIT_G.
ENDFORM.                    "IS_GR_INIT_GLOBAL
