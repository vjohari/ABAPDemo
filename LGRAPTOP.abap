* regenerated at 04.08.1995 15:50:19 by  GRAPH
FUNCTION-POOL GRAP MESSAGE-ID PC.
INCLUDE %3CCTLDEF%3E.
* Systemconstanten, für schnellen Download/Upload hochgestzt
* GL 15.7.1994
*
class CL_ABAP_CHAR_UTILITIES definition load.

CONSTANTS:
C_DPTABLESIZE      TYPE I VALUE 1024. "Länge Übergabetabelle DP

DATA: LINEBUFFER(8200).
DATA: LINEBUFFERSIZE TYPE I.
DATA : BEGIN OF ENTER,
         X(2) TYPE X VALUE '0D0A',
       END OF ENTER.
DATA : BEGIN OF DP_TABLE OCCURS 1,
         TEXT(c_dptablesize),
       END OF DP_TABLE.


* DATA-Definitions for Postscript-Printing
* see Report GR_PRINT for printing native Postscript-Data
*                     called via SUBMIT to SPOOL

DATA: NOGRAPH(4) VALUE 'NOGR'.

DATA: DL_AUTH_FORM(40), DL_AUTH_PROG(40).

DATA: GLOBAL_IS_LIST_DOWNLOAD(1).

DATA: MY_MSGID LIKE SY-MSGID,
      MY_MSGNO LIKE SY-MSGNO,
      MY_MSGTY LIKE SY-MSGTY,
      MY_MSGV1 LIKE SY-MSGV1,
      MY_MSGV2 LIKE SY-MSGV2,
      MY_MSGV3 LIKE SY-MSGV3,
      MY_MSGV4 LIKE SY-MSGV4.

DATA: PRINTERNAME LIKE TSP03-PASTANDORT.
DATA: DELIMITER TYPE C.
DATA: PS_LINE_SIZE LIKE PRI_PARAMS-LINSZ VALUE 200.
DATA: MAX_PS_LINE_SIZE LIKE PRI_PARAMS-LINSZ VALUE 255.
DATA: BEGIN OF PRINTTAB OCCURS 1,
        PLINE(255),                    "// MUST be MAX_PS_LINE_SIZE
      END OF PRINTTAB.

DATA: GLOBAL_FIXLEN_USE(1),
      GLOBAL_FIXLEN_FROM TYPE I,
      GLOBAL_FIXLEN_TO TYPE I,
      GLOBAL_FIXLEN_LEN TYPE I.

DATA: GLOBAL_TRAIL_BLANKS.             "// enable trailing-blanks
                                       "// with WS_DOWNLOAD

DATA: GLOBAL_ASC_UL_OFFSET TYPE I.     "// offset für upload
*     global_bin_ul_offset type i.     "// bei neuer Zeile



DATA: GLOBAL_FILEMASK_MASK(20), GLOBAL_FILEMASK_TEXT(20).
DATA: GLOBAL_FILEMASK_ALL(80).
DATA: GLOBAL_FILESEL_CANCEL.
DATA: GLOBAL_DOWNLOAD_PATH LIKE RLGRAP-FILENAME.
DATA: GLOBAL_UPLOAD_PATH LIKE RLGRAP-FILENAME.

*ATA: GLOBAL_MAX_BIN_WIDTH TYPE I VALUE 8020. "// org: 1022
DATA: GLOBAL_MAX_BIN_ULWID TYPE I VALUE 7950. "// Upload-Limitations
DATA: GLOBAL_UPLD_REST TYPE I.         "// org 7900, Vi:7950
DATA: GLOBAL_UPLD_WID TYPE I.
DATA: GLOBAL_USER_WID TYPE I.
DATA: GLOBAL_UPLD_OFFSET TYPE I.

* GL 16.8.95
DATA: GLOBAL_HPGL_MODE(1).             "// used by GRAPH_RECEIVE
                                       "// set by Form SET_HPGL_MODE

* GL 18.4.1995
DATA: G_BUFF(8022).                    "// org:1024
DATA: MAX_BUFFLEN TYPE I VALUE 8010.   "// org:1000 Platz für <msg>#E#R#
*ATA: GLOBAL_MAX_BIN_WIDTH TYPE I VALUE 1022. "// org: 1022
*ATA: G_BUFF(1024).                    "// org:1024
*ATA: MAX_BUFFLEN TYPE I VALUE 1000.   "// org:1000 Platz für <msg>#E#R#

DATA: GRAPH_C2(2) TYPE C.

*-------------------*
*-------------------*
TABLES: RLGRAP.                        "// Programm- und Dynprofelder
DATA:   TITLE_ITEM(30).                "// Current Item for titlebar
DATA:   USERCMD LIKE SY-UCOMM.         "// Usercommand
DATA:   STATUS  LIKE SY-PFKEY.         "// PF-Status
DATA:   MESSAGELINE(60).               "// Nachrichtenzeile
DATA:   RC.
DATA:   CHILDCOUNT TYPE I.             "// 0-> M_TYP='D' Emulation

* data for Printer-Popup
DATA: SPOOL_IMM(1), SPOOL_DEL(1).
DATA: SPOOL_DAY(1).
DATA: SPOOL_COUNT(1).
* GL 22.7.94

DATA: GLOBAL_ERRORCODE TYPE P.         "// set in GRAPH_RECEIVE

* Benutzermenü global
*ATA: GLOBAL_USER_MENU_EXIST.

* GL 13.4.1994: Fix 'BIN'-Download

DATA: GLOBAL_FSIZE TYPE I.             "// GL 13.4.1994

* GRAPH_RECEIVE / "Power"-Upload
*ATA: GLOBAL_UPLOAD_IS_ACTIVE(1).      "// GL 24.4.1995
DATA: GLOBAL_KONV_ERROR_ROW LIKE SY-INDEX.  "// UL 'DAT'
DATA: GLOBAL_KONV_ERROR_COL LIKE SY-INDEX.  "// UL 'DAT'

DATA: GLOBAL_LINE_EXIT(20).            "// GL 14.2.1994
* DATA: GLOBAL_USER_FORM(80).
* DATA: GLOBAL_USER_PROG(80).
* DATA: GLOBAL_USER_TYPE LIKE RLGRAP-FILETYPE.

DATA: BPOINTLEVEL(1).                  "// B-Point-Level    18.2.1993
                                       "// SPACE, '0' : no BP
                                       "// '1' = TERM_SEND vor send
                                       "// '2' = TERM_SEND nach recv.
                                       "// '3' = vor send + nach recv.
DATA: TRACELEVEL(1).                   "// Trace-Level
                                       "// SPACE, '0' : no Trace
                                       "// '1' = TERM_SEND vor send
                                       "// '2' = TERM_SEND nach recv.
                                       "// '3' = vor send + nach recv.

*---------------------------------------------------------------------*
* GLOBAL DATA                                                         *
*---------------------------------------------------------------------*

DATA: SAVE_WS(10).                     "// Puffer fuer WS_QUERY : WS
DATA: SAVE_XP(240).                    "//                      : XP
DATA: SAVE_OS(10).                     "//                      : OS
DATA: SAVE_GM(4).                      "//                      : GM
DATA: SAVE_XP_FLAG(1).
DATA: SAVE_CD(240).                    "//                      : CD
DATA: SAVE_CD_FLAG(1).
data: front_ini_path like rlgrap-filename.

DATA: BEGIN OF HEXNULFELD,
        X(1) TYPE X VALUE '00',
      END OF HEXNULFELD.
DATA: HEXNUL(1).                       "// Konvertierungen sparen
                                       "// GL 8.5.95
                                       "// Zuweisung in LGRAPFGL

*
* Tabelle für Callbacks
*

DATA: BEGIN OF CALLBACKS OCCURS 1,
        APPTYPE  LIKE GRAPH-APPTYPE,
        EVENT    LIKE GRAPH-EVENT,
        CALLBACK LIKE GRAPH-CALLBACK,
        WINID    LIKE GRAPH-WINID,
        HOOK     LIKE GRAPH-HOOK,
      END OF CALLBACKS.

DATA: BEGIN OF VALID_EVENTS OCCURS 1,
        APPTYPE LIKE GRAPH-APPTYPE,
        EVENT   LIKE GRAPH-EVENT,
      END OF VALID_EVENTS.

DATA: INIT_EVENT(1).

*
* Tabellen fuer Funktionsbaustein GRAPH_SET_CUA_STATUS
*                                 GRAPH_CUA_SEND
* GL 6.10.1994

DATA: GLOBAL_CUA_PROG LIKE TRDIR-NAME,
      GLOBAL_CUA_STAT LIKE RSEU1-STATUS,
      GLOBAL_CUA_FLAG(1).

DATA: BEGIN OF GLOBAL_CUA_EXCLUDE OCCURS 1,
        FCODE LIKE RSMPE_KEYS-CODE,
      END OF GLOBAL_CUA_EXCLUDE.

*
* GL 13.12.1995 erweitertes CUA-EXCLUDE-Handling
*

DATA: GLOBAL_USE_EX_EXCLUDE(1).
DATA: BEGIN OF GLOBAL_CUA_EX_EXCLUDE OCCURS 1,
        CODE LIKE RSMPE_KEYS-CODE,
      END OF GLOBAL_CUA_EX_EXCLUDE.

*
* Tabellen fuer Funktionsbaustein GRAPH_ACTION wegen CUA-Oberfl.
*

DATA: BEGIN OF GRAPH_HELP OCCURS 1,
        KEY(2),
        ABLE(1),
        TEXT(20),
        ACTID(5),
      END OF GRAPH_HELP.

DATA: BEGIN OF GRAPH_ACTION OCCURS 1,
        ACTID(5),
        ACTYP(1),
        ACTSTRING(10),
      END OF GRAPH_ACTION.

DATA: BEGIN OF GRAPH_ACTBAR OCCURS 1,
        OMENU(2),
        SUBMENU(2),
        HELP_ID(3),
        POS(1),
        ACC(2),
        ACT_ID(4),
        ATTR(2),
        TEXT(20),
      END OF GRAPH_ACTBAR.

*------------------*
* data for objects *
*------------------*

DATA: OBJECT_STAT(10).
DATA: OBJECT_ID(8).

DATA: CONST_OBJ_CREATE LIKE OBJECT_STAT VALUE 'CREATE'.

DATA: BEGIN OF GRAPH_OBJ_ID OCCURS 1,  "// Liste aller ID's
        WINID(8),
        START LIKE SY-INDEX,
        COUNT LIKE SY-INDEX,
      END OF GRAPH_OBJ_ID.

DATA: BEGIN OF GRAPH_OBJECT OCCURS 1,  "// Alle Objekte
        WINID(8),                      "// evtl mit start+count arbeiten
        MSG(1),
        TXT(128),
      END OF GRAPH_OBJECT.

CONSTANTS: CONST_DP(6)         VALUE 'DP_OBJ',
           CONST_DP_LEN TYPE I VALUE 1024.
DATA:      DP_BUFF_OFFSET TYPE I.
DATA: BEGIN OF DP_GRAPH_OBJ OCCURS 1,
        C(1024),
      END OF DP_GRAPH_OBJ.

*ata: begin of listchild occurs 1,
*       id(8),
*       parent(8),
*       cua(1),
*       bord(1),
*       x1(3),
*       y1(3),
*       x2(3),
*       y2(3),
*     end of listchild.

*----------------*
* end of objects *
*----------------*

DATA: TEXT(4000).                      "// globaler Returnbuffer
                                       "// 4000 am 27.1.1992 wg
                                       "// Mail
* needed in GRAPH_HIERARCHY_ALL for out+in
* GRAPH_DIALOG out+in
* LGRAPFGL for GRAP_RECEIVE


* soll nur in GRAP_RECEIVE sein
* sonst nicht gebraucht
* alle FB's bekommen eigenen Outbuffer, der lokal auch text heisst

DATA: GLOBAL_GRAPH_INIT,
      GLOBAL_GRAPH_INIT_G,
      GBUFF_OFFSET TYPE I,
      GRAPH_CONV_ID(8),
      GRAPH_RC LIKE SY-SUBRC,
*     SYMDEST(20),
*     FIELDLN(2) TYPE X,               "// GL 17.9.1993
      FIELDLN TYPE I,
*     RECV_LN(4) TYPE X,
      LEN TYPE I,
      DECIMALE VALUE '.',
      DECIMALG VALUE ',',
      DECIMAL(1),
      GLOBAL_SEND_DATA_TYPE.
*     GLOBAL_RECV_DATA_TYPE,
*     BUFFER(512).   "// Fuer Receive 1 Zeile 15.12.1992
DATA: BEGIN OF SENDTAB OCCURS 1,
        BUF LIKE G_BUFF,
      END OF SENDTAB.
DATA: BEGIN OF RECVTAB OCCURS 1,
        BUF LIKE G_BUFF,
      END OF RECVTAB.

DATA: GLOBAL_MCODE.
DATA: GLOBAL_RWNID(20).
DATA: GLOBAL_RBUFF LIKE G_BUFF.
DATA: ORG_RBUFF LIKE G_BUFF.

*
* Pufferdaten fuer V01
*
DATA: BEGIN OF RTAB_V01 OCCURS 1,
        TEXT LIKE G_BUFF,
      END OF RTAB_V01.
*
* Pufferdaten fuer Mail
*
DATA: BEGIN OF MAIL_TAB OCCURS 0.
        INCLUDE STRUCTURE SOLI.
DATA: END OF MAIL_TAB.
DATA: BEGIN OF CRLF,
        X(1) TYPE X VALUE '0A',
      END OF CRLF.
data: TMASK(2).
* move not allowed KL 04.01.2001
*      move CL_ABAP_CHAR_UTILITIES=>MINCHAR to TMASK(1).
*      move '{' to TMASK+1(1).

DATA: PROTOCOL_ID(3) VALUE 'V01',      "// GL 15.02.1994
      WAN_IS_ACTIV,
      WAN_LAST_BLOCK.
*     CONVERT_CODEPAGE.

TABLES: TSP03.

* Column-Attributes for WS_DOWNLOAD

DATA: GLOBAL_FIELDNAMES LIKE G_BUFF.   "// 30A

DATA: GLOBAL_COL_SELECTMASK(128).      "// 30B
DATA: GLOBAL_COL_SELECT(1).

FORM Check_Grap_Security USING NO_AUTH_CHECK TYPE C CHANGING CheckResult TYPE I.

  DATA: RESULT.
  CLEAR RESULT.

  CheckResult = 0.
  IF no_auth_check = SPACE.
    authority-check object 'S_GUI'
                        ID 'ACTVT'
                     FIELD '61'.
    IF sy-subrc <> 0.
      CheckResult = 1. " RAISE no_authority.
      EXIT.
    ENDIF.
  ENDIF.

  IF ( DL_AUTH_PROG IS INITIAL ) AND ( DL_AUTH_FORM IS INITIAL ).
*   no check here
  ELSE.
*   perform check
    PERFORM (DL_AUTH_FORM) IN PROGRAM (DL_AUTH_PROG) USING RESULT.
  ENDIF.
  IF RESULT <> 0.
    CheckResult = 2. " MESSAGE I013.
    EXIT.                              "// leave download
  ENDIF.

* call customer function (is_list_download, no_auth_check) here
*                         (other system fields ??)

  SY-SUBRC = 0.
  CALL CUSTOMER-FUNCTION '001'
    EXPORTING
      IS_LIST_DOWNLOAD = GLOBAL_IS_LIST_DOWNLOAD
      NO_AUTH_CHECK    = NO_AUTH_CHECK
    EXCEPTIONS
      NO_AUTHORITY = 1
      OTHERS       = 2.
  IF SY-SUBRC NE 0.
    CheckResult = 3. " MESSAGE I013 raising CUSTOMER_ERROR.
    EXIT.
  ENDIF.

ENDFORM. "Check_Grap_Security
