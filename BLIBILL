      *================================================================*
      * PROGRAM  : BLIBILL         DISPLAY FILE : BLDBILL              *
      *                            PRINTER FILE : BLRINV               *
      * MODULE   : Billing (BL)                                        *
      * LAYER    : Presentation                                        *
      * PURPOSE  : Open a guest folio by reservation, add charge lines,*
      *            recalc totals (CMSBILL), take payment, and print a  *
      *            GST tax invoice.                                     *
      * FKEYS    : F6 AddLine F10 Pay F11 Print F3 Exit F12 Cancel     *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BLIBILL.
       AUTHOR. TEHMS-ARCHITECT.
      *----------------------------------------------------------------*
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT DSP-BILL ASSIGN TO WORKSTATION-BLDBILL-SI
                  ORGANIZATION IS TRANSACTION
                  ACCESS IS DYNAMIC
                  RELATIVE KEY IS WS-RRN
                  FILE STATUS IS WS-DSP-STS.
           SELECT PRT-INV ASSIGN TO FORMATFILE-BLRINV
                  ORGANIZATION IS SEQUENTIAL
                  FILE STATUS IS WS-PRT-STS.
      *----------------------------------------------------------------*
       DATA DIVISION.
       FILE SECTION.
       FD  DSP-BILL.
       01  BILL-REC.
           COPY DDS-ALL-FORMATS OF BLDBILL.
       FD  PRT-INV.
       01  PRT-REC.
           COPY DDS-ALL-FORMATS OF BLRINV.
      *----------------------------------------------------------------*
       WORKING-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  WS-DSP-STS          PIC X(02) VALUE '00'.
       01  WS-PRT-STS          PIC X(02) VALUE '00'.
       01  WS-IND              PIC X(99) VALUE ALL '0'.
       01  WS-RRN              PIC S9(4) COMP-4 VALUE 0.
       01  WS-EXIT-SW          PIC X(01) VALUE 'N'.
           88  WS-EXIT                 VALUE 'Y'.
       01  WS-COUNT            PIC S9(4) COMP-4 VALUE 0.
       01  WS-MSG              PIC X(78).
       01  WS-RESULT           PIC X(01).
       01  WS-CALLMSG          PIC X(78).
      *--- host variables ---
       01  HV.
           05  HV-INVID        PIC S9(9) COMP-4 VALUE 0.
           05  HV-RESID        PIC S9(9) COMP-4.
           05  HV-GSTID        PIC S9(9) COMP-4.
           05  HV-GNAME        PIC X(40).
           05  HV-ROOM         PIC X(6).
           05  HV-SEQ          PIC S9(4) COMP-4.
           05  HV-TYPE         PIC X(4).
           05  HV-DESC         PIC X(40).
           05  HV-QTY          PIC S9(8)V999 COMP-3.
           05  HV-RATE         PIC S9(9)V99  COMP-3.
           05  HV-AMT          PIC S9(11)V99 COMP-3.
           05  HV-GSTP         PIC S9(3)V99  COMP-3.
           05  HV-SUBT         PIC S9(11)V99 COMP-3.
           05  HV-DISC         PIC S9(11)V99 COMP-3.
           05  HV-GST          PIC S9(11)V99 COMP-3.
           05  HV-TOTAL        PIC S9(11)V99 COMP-3.
           05  HV-PAID         PIC S9(11)V99 COMP-3.
           05  HV-MODE         PIC X(4).
           05  HV-PAMT         PIC S9(11)V99 COMP-3.
           05  HV-DATE         PIC X(10).
      *--- audit ---
       01  AUD-USER            PIC X(10).
       01  AUD-PGM             PIC X(10) VALUE 'BLIBILL'.
       01  AUD-ACTN            PIC X(10).
       01  AUD-KEY             PIC X(30).
       01  AUD-TEXT            PIC X(100).
      *----------------------------------------------------------------*
       LINKAGE SECTION.
           COPY CMXSECDS.
      *----------------------------------------------------------------*
       PROCEDURE DIVISION USING SESSION-DATA.
       A000-MAIN.
           MOVE SES-USER-ID TO AUD-USER
           OPEN I-O DSP-BILL
           PERFORM UNTIL WS-EXIT
              PERFORM B100-LOAD-FOLIO
              PERFORM B200-DISPLAY
           END-PERFORM
           CLOSE DSP-BILL
           GOBACK.
      *----------------------------------------------------------------*
      * LOAD FOLIO SUBFILE                                             *
      *----------------------------------------------------------------*
       B100-LOAD-FOLIO.
           MOVE ALL '0' TO WS-IND
           MOVE '1' TO WS-IND(53:1)
           WRITE BILL-REC FORMAT IS 'BLCTL' INDICATORS ARE WS-IND
           MOVE '0' TO WS-IND(53:1)
           MOVE 0 TO WS-RRN
           MOVE 0 TO WS-COUNT
           MOVE 0 TO TSUBT OF BLCTL
           MOVE 0 TO TGST OF BLCTL
           MOVE 0 TO TTOTAL OF BLCTL
           MOVE SPACES TO HGNAME OF BLCTL
           IF HV-INVID > 0
              PERFORM B120-LOAD-LINES
              PERFORM B130-LOAD-HEADER
           END-IF
           IF WS-COUNT > 0
              MOVE '1' TO WS-IND(51:1)
              MOVE '1' TO WS-IND(54:1)
           END-IF
           MOVE '1' TO WS-IND(52:1)
           MOVE HV-INVID TO HINVID OF BLCTL.
      *----------------------------------------------------------------*
       B120-LOAD-LINES.
           EXEC SQL
                DECLARE C2 CURSOR FOR
                SELECT DTL_SEQ, DTL_TYPE, DTL_DESC, DTL_QTY,
                       DTL_RATE, DTL_AMT
                  FROM TEHMSDTA/BLPINVDT
                 WHERE INV_ID = :HV-INVID
                 ORDER BY DTL_SEQ
           END-EXEC
           EXEC SQL OPEN C2 END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL
                   FETCH C2 INTO :HV-SEQ, :HV-TYPE, :HV-DESC,
                                 :HV-QTY, :HV-RATE, :HV-AMT
              END-EXEC
              IF SQLCODE = 0
                 MOVE HV-SEQ  TO BSEQ OF BLSFL
                 MOVE HV-TYPE TO BTYPE OF BLSFL
                 MOVE HV-DESC TO BDESC OF BLSFL
                 MOVE HV-QTY  TO BQTY OF BLSFL
                 MOVE HV-RATE TO BRATE OF BLSFL
                 MOVE HV-AMT  TO BAMT OF BLSFL
                 ADD 1 TO WS-RRN
                 ADD 1 TO WS-COUNT
                 WRITE BILL-REC FORMAT IS 'BLSFL'
                       INDICATORS ARE WS-IND
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C2 END-EXEC.
      *----------------------------------------------------------------*
       B130-LOAD-HEADER.
           EXEC SQL
                SELECT H.RES_ID, H.INV_SUBT, H.INV_GST, H.INV_TOTAL,
                       G.GST_NAME
                  INTO :HV-RESID, :HV-SUBT, :HV-GST, :HV-TOTAL,
                       :HV-GNAME
                  FROM TEHMSDTA/BLPINVHD H
                  JOIN TEHMSDTA/GMPGUEST G ON H.GST_ID = G.GST_ID
                 WHERE H.INV_ID = :HV-INVID
           END-EXEC
           IF SQLCODE = 0
              MOVE HV-RESID TO HRESID OF BLCTL
              MOVE HV-GNAME TO HGNAME OF BLCTL
              MOVE HV-SUBT  TO TSUBT OF BLCTL
              MOVE HV-GST   TO TGST OF BLCTL
              MOVE HV-TOTAL TO TTOTAL OF BLCTL
           END-IF.
      *----------------------------------------------------------------*
      * DISPLAY + KEYS                                                 *
      *----------------------------------------------------------------*
       B200-DISPLAY.
           MOVE WS-MSG TO MSGLIN OF BLCTL
           MOVE SPACES TO WS-MSG
           WRITE BILL-REC FORMAT IS 'BLCTL' INDICATORS ARE WS-IND
           READ DSP-BILL INDICATORS ARE WS-IND
           EVALUATE TRUE
              WHEN WS-IND(3:1) = '1'
                 SET WS-EXIT TO TRUE
              WHEN WS-IND(12:1) = '1'
                 SET WS-EXIT TO TRUE
              WHEN WS-IND(6:1) = '1'
                 PERFORM C100-ADD-LINE
              WHEN WS-IND(10:1) = '1'
                 PERFORM C200-PAYMENT
              WHEN WS-IND(11:1) = '1'
                 PERFORM C300-PRINT
              WHEN OTHER
                 PERFORM C050-LOCATE-FOLIO
           END-EVALUATE.
      *----------------------------------------------------------------*
      * LOCATE OPEN FOLIO BY RESERVATION                              *
      *----------------------------------------------------------------*
       C050-LOCATE-FOLIO.
           MOVE HRESID OF BLCTL TO HV-RESID
           EXEC SQL
                SELECT INV_ID INTO :HV-INVID
                  FROM TEHMSDTA/BLPINVHD
                 WHERE RES_ID = :HV-RESID AND INV_STS = 'O'
                 FETCH FIRST 1 ROW ONLY
           END-EXEC
           IF SQLCODE NOT = 0
              MOVE 0 TO HV-INVID
              MOVE 'No open folio for that reservation' TO WS-MSG
           END-IF.
      *----------------------------------------------------------------*
      * ADD CHARGE LINE                                               *
      *----------------------------------------------------------------*
       C100-ADD-LINE.
           IF HV-INVID = 0
              MOVE 'Locate a folio first (enter Res #)' TO WS-MSG
              GO TO C100-EXIT
           END-IF
           MOVE NTYPE OF BLCTL TO HV-TYPE
           MOVE NDESC OF BLCTL TO HV-DESC
           MOVE NQTY OF BLCTL  TO HV-QTY
           MOVE NRATE OF BLCTL TO HV-RATE
           MOVE NGSTP OF BLCTL TO HV-GSTP
           IF HV-QTY = 0
              MOVE 1 TO HV-QTY
           END-IF
           COMPUTE HV-AMT = HV-QTY * HV-RATE
           EXEC SQL
                SELECT COALESCE(MAX(DTL_SEQ),0) + 1 INTO :HV-SEQ
                  FROM TEHMSDTA/BLPINVDT WHERE INV_ID = :HV-INVID
           END-EXEC
           EXEC SQL
                INSERT INTO TEHMSDTA/BLPINVDT
                   (INV_ID, DTL_SEQ, DTL_TYPE, DTL_DESC, DTL_QTY,
                    DTL_RATE, DTL_AMT, DTL_GSTP, CRT_USR)
                VALUES (:HV-INVID, :HV-SEQ, :HV-TYPE, :HV-DESC,
                    :HV-QTY, :HV-RATE, :HV-AMT, :HV-GSTP, :AUD-USER)
           END-EXEC
           IF SQLCODE = 0
              EXEC SQL COMMIT END-EXEC
              CALL 'CMSBILL' USING HV-INVID WS-RESULT WS-CALLMSG
              EXEC SQL COMMIT END-EXEC
              MOVE 'CHARGE' TO AUD-ACTN
              MOVE HV-DESC  TO AUD-KEY
              MOVE 'Charge line added' TO AUD-TEXT
              CALL 'CMSERROR' USING AUD-USER AUD-PGM AUD-ACTN
                                    AUD-KEY AUD-TEXT
              EXEC SQL COMMIT END-EXEC
              MOVE 'Charge added' TO WS-MSG
           ELSE
              EXEC SQL ROLLBACK END-EXEC
              MOVE 'Charge insert failed' TO WS-MSG
           END-IF.
       C100-EXIT.
           EXIT.
      *----------------------------------------------------------------*
      * PAYMENT                                                       *
      *----------------------------------------------------------------*
       C200-PAYMENT.
           IF HV-INVID = 0
              MOVE 'Locate a folio first (enter Res #)' TO WS-MSG
              GO TO C200-EXIT
           END-IF
           MOVE PMODE OF BLCTL TO HV-MODE
           MOVE PAMT OF BLCTL  TO HV-PAMT
           IF HV-PAMT <= 0
              MOVE 'Enter a payment amount' TO WS-MSG
              GO TO C200-EXIT
           END-IF
           EXEC SQL
                INSERT INTO TEHMSDTA/BLPPAY
                   (INV_ID, PAY_MODE, PAY_AMT, CRT_USR)
                VALUES (:HV-INVID, :HV-MODE, :HV-PAMT, :AUD-USER)
           END-EXEC
           EXEC SQL
                UPDATE TEHMSDTA/BLPINVHD
                   SET INV_PAID = INV_PAID + :HV-PAMT,
                       UPD_USR  = :AUD-USER
                 WHERE INV_ID = :HV-INVID
           END-EXEC
           IF SQLCODE = 0
              EXEC SQL COMMIT END-EXEC
              CALL 'CMSBILL' USING HV-INVID WS-RESULT WS-CALLMSG
              EXEC SQL COMMIT END-EXEC
              MOVE 'PAYMENT' TO AUD-ACTN
              MOVE HV-MODE   TO AUD-KEY
              MOVE 'Payment posted' TO AUD-TEXT
              CALL 'CMSERROR' USING AUD-USER AUD-PGM AUD-ACTN
                                    AUD-KEY AUD-TEXT
              EXEC SQL COMMIT END-EXEC
              MOVE 'Payment posted' TO WS-MSG
           ELSE
              EXEC SQL ROLLBACK END-EXEC
              MOVE 'Payment failed' TO WS-MSG
           END-IF.
       C200-EXIT.
           EXIT.
      *----------------------------------------------------------------*
      * PRINT TAX INVOICE                                             *
      *----------------------------------------------------------------*
       C300-PRINT.
           IF HV-INVID = 0
              MOVE 'Locate a folio first (enter Res #)' TO WS-MSG
              GO TO C300-EXIT
           END-IF
           OPEN OUTPUT PRT-INV
           EXEC SQL
                SELECT H.INV_SUBT, H.INV_DISC, H.INV_GST, H.INV_TOTAL,
                       G.GST_NAME, COALESCE(R.RM_NO,' '),
                       CHAR(H.INV_DATE, ISO)
                  INTO :HV-SUBT, :HV-DISC, :HV-GST, :HV-TOTAL,
                       :HV-GNAME, :HV-ROOM, :HV-DATE
                  FROM TEHMSDTA/BLPINVHD H
                  JOIN TEHMSDTA/GMPGUEST G ON H.GST_ID = G.GST_ID
                  JOIN TEHMSDTA/RSPRESV  R ON H.RES_ID = R.RES_ID
                 WHERE H.INV_ID = :HV-INVID
           END-EXEC
           MOVE HV-INVID TO PINVID OF RHEAD
           MOVE HV-DATE  TO PDATE OF RHEAD
           MOVE HV-GNAME TO PGNAME OF RHEAD
           MOVE HV-ROOM  TO PROOM OF RHEAD
           WRITE PRT-REC FORMAT IS 'RHEAD'
           EXEC SQL
                DECLARE C3 CURSOR FOR
                SELECT DTL_TYPE, DTL_DESC, DTL_QTY, DTL_RATE, DTL_AMT
                  FROM TEHMSDTA/BLPINVDT
                 WHERE INV_ID = :HV-INVID ORDER BY DTL_SEQ
           END-EXEC
           EXEC SQL OPEN C3 END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL
                   FETCH C3 INTO :HV-TYPE, :HV-DESC, :HV-QTY,
                                 :HV-RATE, :HV-AMT
              END-EXEC
              IF SQLCODE = 0
                 MOVE HV-TYPE TO DTYPE OF RDETL
                 MOVE HV-DESC TO DDESC OF RDETL
                 MOVE HV-QTY  TO DQTY OF RDETL
                 MOVE HV-RATE TO DRATE OF RDETL
                 MOVE HV-AMT  TO DAMT OF RDETL
                 WRITE PRT-REC FORMAT IS 'RDETL'
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C3 END-EXEC
           MOVE HV-SUBT TO TSUBT OF RTOT
           WRITE PRT-REC FORMAT IS 'RTOT'
           MOVE HV-DISC TO TDISC OF RTOT2
           WRITE PRT-REC FORMAT IS 'RTOT2'
           MOVE HV-GST TO TGST OF RTOT3
           WRITE PRT-REC FORMAT IS 'RTOT3'
           MOVE HV-TOTAL TO TTOTAL OF RTOT4
           WRITE PRT-REC FORMAT IS 'RTOT4'
           WRITE PRT-REC FORMAT IS 'RFOOT'
           CLOSE PRT-INV
           MOVE 'Tax invoice spooled to printer' TO WS-MSG.
       C300-EXIT.
           EXIT.
      *================================================================*
      * END OF BLIBILL                                                 *
      *================================================================*
