      *================================================================*
      * PROGRAM  : GMICKOUT        DISPLAY FILE : GMDCKOUT             *
      * MODULE   : Guest Management (GM) / Check-Out                   *
      * LAYER    : Presentation                                        *
      * PURPOSE  : List in-house guests with folio total/paid; on      *
      *            check-out (folio fully paid) settle the invoice,     *
      *            release the room (vacant + dirty) and close the      *
      *            reservation.                                         *
      * SUBFILE  : SEL  O = Check-Out                                  *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. GMICKOUT.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT DSP-CO ASSIGN TO WORKSTATION-GMDCKOUT-SI
                  ORGANIZATION IS TRANSACTION
                  ACCESS IS DYNAMIC
                  RELATIVE KEY IS WS-RRN
                  FILE STATUS IS WS-DSP-STS.
       DATA DIVISION.
       FILE SECTION.
       FD  DSP-CO.
       01  CO-REC.
           COPY DDS-ALL-FORMATS OF GMDCKOUT.
       WORKING-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  WS-DSP-STS          PIC X(02) VALUE '00'.
       01  WS-IND              PIC X(99) VALUE ALL '0'.
       01  WS-RRN              PIC S9(4) COMP-4 VALUE 0.
       01  WS-EXIT-SW          PIC X(01) VALUE 'N'.
           88  WS-EXIT                 VALUE 'Y'.
       01  WS-EOF-SW           PIC X(01) VALUE 'N'.
           88  WS-EOF                  VALUE 'Y'.
       01  WS-COUNT            PIC S9(4) COMP-4 VALUE 0.
       01  WS-MSG              PIC X(78).
       01  HV.
           05  HV-RESID        PIC S9(9) COMP-4.
           05  HV-NAME         PIC X(40).
           05  HV-ROOM         PIC X(6).
           05  HV-INVID        PIC S9(9) COMP-4.
           05  HV-TOTAL        PIC S9(11)V99 COMP-3.
           05  HV-PAID         PIC S9(11)V99 COMP-3.
       01  AUD-USER            PIC X(10).
       01  AUD-PGM             PIC X(10) VALUE 'GMICKOUT'.
       01  AUD-ACTN            PIC X(10).
       01  AUD-KEY             PIC X(30).
       01  AUD-TEXT            PIC X(100).
       LINKAGE SECTION.
           COPY CMXSECDS.
       PROCEDURE DIVISION USING SESSION-DATA.
       A000-MAIN.
           MOVE SES-USER-ID TO AUD-USER
           OPEN I-O DSP-CO
           PERFORM UNTIL WS-EXIT
              PERFORM B100-LOAD
              PERFORM B200-DISPLAY
           END-PERFORM
           CLOSE DSP-CO
           GOBACK.
      *----------------------------------------------------------------*
       B100-LOAD.
           MOVE ALL '0' TO WS-IND
           MOVE '1' TO WS-IND(53:1)
           WRITE CO-REC FORMAT IS 'COCTL' INDICATORS ARE WS-IND
           MOVE '0' TO WS-IND(53:1)
           MOVE 0 TO WS-RRN
           MOVE 0 TO WS-COUNT
           EXEC SQL
                DECLARE CO CURSOR FOR
                SELECT R.RES_ID, G.GST_NAME, R.RM_NO,
                       COALESCE(H.INV_TOTAL,0), COALESCE(H.INV_PAID,0)
                  FROM TEHMSDTA/RSPRESV R
                  JOIN TEHMSDTA/GMPGUEST G ON R.GST_ID = G.GST_ID
                  LEFT JOIN TEHMSDTA/BLPINVHD H
                       ON H.RES_ID = R.RES_ID AND H.INV_STS = 'O'
                 WHERE R.RES_STS = 'C'
                 ORDER BY R.RM_NO
           END-EXEC
           EXEC SQL OPEN CO END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL
                   FETCH CO INTO :HV-RESID, :HV-NAME, :HV-ROOM,
                                 :HV-TOTAL, :HV-PAID
              END-EXEC
              IF SQLCODE = 0
                 MOVE SPACES   TO SEL OF COSFL
                 MOVE HV-RESID TO ZRESID OF COSFL
                 MOVE HV-NAME  TO ZNAME OF COSFL
                 MOVE HV-ROOM  TO ZROOM OF COSFL
                 MOVE HV-TOTAL TO ZTOTAL OF COSFL
                 MOVE HV-PAID  TO ZPAID OF COSFL
                 ADD 1 TO WS-RRN
                 ADD 1 TO WS-COUNT
                 WRITE CO-REC FORMAT IS 'COSFL' INDICATORS ARE WS-IND
              END-IF
           END-PERFORM
           EXEC SQL CLOSE CO END-EXEC
           IF WS-COUNT > 0
              MOVE '1' TO WS-IND(51:1)
              MOVE '1' TO WS-IND(54:1)
           END-IF
           MOVE '1' TO WS-IND(52:1).
      *----------------------------------------------------------------*
       B200-DISPLAY.
           MOVE WS-MSG TO MSGLIN OF COCTL
           MOVE SPACES TO WS-MSG
           WRITE CO-REC FORMAT IS 'COCTL' INDICATORS ARE WS-IND
           READ DSP-CO INDICATORS ARE WS-IND
           EVALUATE TRUE
              WHEN WS-IND(3:1) = '1'
                 SET WS-EXIT TO TRUE
              WHEN WS-IND(12:1) = '1'
                 SET WS-EXIT TO TRUE
              WHEN WS-IND(5:1) = '1'
                 CONTINUE
              WHEN OTHER
                 PERFORM C300-PROCESS-SEL
           END-EVALUATE.
      *----------------------------------------------------------------*
       C300-PROCESS-SEL.
           MOVE 'N' TO WS-EOF-SW
           PERFORM UNTIL WS-EOF
              READ DSP-CO NEXT MODIFIED RECORD FORMAT IS 'COSFL'
                   AT END SET WS-EOF TO TRUE
              END-READ
              IF NOT WS-EOF
                 IF SEL OF COSFL = 'O' OR SEL OF COSFL = 'o'
                    MOVE ZRESID OF COSFL TO HV-RESID
                    PERFORM C350-CHECKOUT
                 END-IF
              END-IF
           END-PERFORM.
      *----------------------------------------------------------------*
       C350-CHECKOUT.
           MOVE SPACES TO HV-ROOM
           MOVE 0 TO HV-INVID
           MOVE 0 TO HV-TOTAL
           MOVE 0 TO HV-PAID
           EXEC SQL
                SELECT RM_NO INTO :HV-ROOM
                  FROM TEHMSDTA/RSPRESV WHERE RES_ID = :HV-RESID
           END-EXEC
           EXEC SQL
                SELECT INV_ID, INV_TOTAL, INV_PAID
                  INTO :HV-INVID, :HV-TOTAL, :HV-PAID
                  FROM TEHMSDTA/BLPINVHD
                 WHERE RES_ID = :HV-RESID AND INV_STS = 'O'
                 FETCH FIRST 1 ROW ONLY
           END-EXEC
           IF HV-INVID > 0 AND HV-PAID < HV-TOTAL
              MOVE 'Balance due - settle folio before check-out'
                TO WS-MSG
              GO TO C350-EXIT
           END-IF
           EXEC SQL
                UPDATE TEHMSDTA/RSPRESV
                   SET RES_STS = 'O', UPD_USR = :AUD-USER
                 WHERE RES_ID = :HV-RESID
           END-EXEC
           EXEC SQL
                UPDATE TEHMSDTA/RMPROOM
                   SET RM_STS = 'V', RM_CLN = 'D', UPD_USR = :AUD-USER
                 WHERE RM_NO = :HV-ROOM
           END-EXEC
           IF HV-INVID > 0
              EXEC SQL
                   UPDATE TEHMSDTA/BLPINVHD
                      SET INV_STS = 'S', UPD_USR = :AUD-USER
                    WHERE INV_ID = :HV-INVID
              END-EXEC
           END-IF
           IF SQLCODE = 0
              EXEC SQL COMMIT END-EXEC
              MOVE 'CHECKOUT' TO AUD-ACTN
              MOVE HV-ROOM    TO AUD-KEY
              MOVE 'Guest checked out, room released' TO AUD-TEXT
              CALL 'CMSERROR' USING AUD-USER AUD-PGM AUD-ACTN
                                    AUD-KEY AUD-TEXT
              EXEC SQL COMMIT END-EXEC
              STRING 'Checked out room ' DELIMITED BY SIZE
                     HV-ROOM DELIMITED BY SIZE INTO WS-MSG
              END-STRING
           ELSE
              EXEC SQL ROLLBACK END-EXEC
              MOVE 'Check-out failed' TO WS-MSG
           END-IF.
       C350-EXIT.
           EXIT.
      *================================================================*
      * END OF GMICKOUT                                                *
      *================================================================*
