      *================================================================*
      * PROGRAM  : IVIITEM         DISPLAY FILE : IVDITEM             *
      * MODULE   : Inventory (IV)                                      *
      * LAYER    : Presentation                                        *
      * PURPOSE  : Maintain inventory items and post stock movements.  *
      *            Receive (R) adds to on-hand; Issue (I) subtracts.    *
      *            Each movement is logged to IVPTXN.                   *
      * SUBFILE  : SEL R/I + Adj qty   F6 = add item                   *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. IVIITEM.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT DSP-IV ASSIGN TO WORKSTATION-IVDITEM-SI
                  ORGANIZATION IS TRANSACTION
                  ACCESS IS DYNAMIC
                  RELATIVE KEY IS WS-RRN
                  FILE STATUS IS WS-DSP-STS.
       DATA DIVISION.
       FILE SECTION.
       FD  DSP-IV.
       01  IV-REC.
           COPY DDS-ALL-FORMATS OF IVDITEM.
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
       01  WS-SEL              PIC X(01).
       01  HV.
           05  HV-ITEM         PIC X(10).
           05  HV-DESC         PIC X(40).
           05  HV-UOM          PIC X(4).
           05  HV-QOH          PIC S9(8)V999 COMP-3.
           05  HV-RATE         PIC S9(9)V99  COMP-3.
           05  HV-ADJ          PIC S9(8)V999 COMP-3.
       01  AUD-USER            PIC X(10).
       01  AUD-PGM             PIC X(10) VALUE 'IVIITEM'.
       01  AUD-ACTN            PIC X(10).
       01  AUD-KEY             PIC X(30).
       01  AUD-TEXT            PIC X(100).
       LINKAGE SECTION.
           COPY CMXSECDS.
       PROCEDURE DIVISION USING SESSION-DATA.
       A000-MAIN.
           MOVE SES-USER-ID TO AUD-USER
           OPEN I-O DSP-IV
           PERFORM UNTIL WS-EXIT
              PERFORM B100-LOAD
              PERFORM B200-DISPLAY
           END-PERFORM
           CLOSE DSP-IV
           GOBACK.
      *----------------------------------------------------------------*
       B100-LOAD.
           MOVE ALL '0' TO WS-IND
           MOVE '1' TO WS-IND(53:1)
           WRITE IV-REC FORMAT IS 'IVCTL' INDICATORS ARE WS-IND
           MOVE '0' TO WS-IND(53:1)
           MOVE 0 TO WS-RRN
           MOVE 0 TO WS-COUNT
           EXEC SQL
                DECLARE CI CURSOR FOR
                SELECT ITM_CODE, ITM_DESC, ITM_UOM, ITM_QOH
                  FROM TEHMSDTA/IVPITEM
                 WHERE REC_STS = 'A' ORDER BY ITM_CODE
           END-EXEC
           EXEC SQL OPEN CI END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL
                   FETCH CI INTO :HV-ITEM, :HV-DESC, :HV-UOM, :HV-QOH
              END-EXEC
              IF SQLCODE = 0
                 MOVE SPACES   TO SEL OF IVSFL
                 MOVE HV-ITEM  TO ZITEM OF IVSFL
                 MOVE HV-DESC  TO ZIDESC OF IVSFL
                 MOVE HV-UOM   TO ZUOM OF IVSFL
                 MOVE HV-QOH   TO ZQTY OF IVSFL
                 MOVE 0        TO ZADJ OF IVSFL
                 ADD 1 TO WS-RRN
                 ADD 1 TO WS-COUNT
                 WRITE IV-REC FORMAT IS 'IVSFL' INDICATORS ARE WS-IND
              END-IF
           END-PERFORM
           EXEC SQL CLOSE CI END-EXEC
           IF WS-COUNT > 0
              MOVE '1' TO WS-IND(51:1)
              MOVE '1' TO WS-IND(54:1)
           END-IF
           MOVE '1' TO WS-IND(52:1).
      *----------------------------------------------------------------*
       B200-DISPLAY.
           MOVE WS-MSG TO MSGLIN OF IVCTL
           MOVE SPACES TO WS-MSG
           WRITE IV-REC FORMAT IS 'IVCTL' INDICATORS ARE WS-IND
           READ DSP-IV INDICATORS ARE WS-IND
           EVALUATE TRUE
              WHEN WS-IND(3:1) = '1'
                 SET WS-EXIT TO TRUE
              WHEN WS-IND(12:1) = '1'
                 SET WS-EXIT TO TRUE
              WHEN WS-IND(5:1) = '1'
                 CONTINUE
              WHEN WS-IND(6:1) = '1'
                 PERFORM C100-ADD-ITEM
              WHEN OTHER
                 PERFORM C300-PROCESS-SEL
           END-EVALUATE.
      *----------------------------------------------------------------*
       C100-ADD-ITEM.
           MOVE NITEM OF IVCTL TO HV-ITEM
           MOVE NDESC OF IVCTL TO HV-DESC
           MOVE NUOM OF IVCTL  TO HV-UOM
           MOVE NRATE OF IVCTL TO HV-RATE
           IF HV-ITEM = SPACES
              MOVE 'Item code is required' TO WS-MSG
              GO TO C100-EXIT
           END-IF
           EXEC SQL
                INSERT INTO TEHMSDTA/IVPITEM
                   (ITM_CODE, ITM_DESC, ITM_UOM, ITM_RATE, CRT_USR)
                VALUES (:HV-ITEM, :HV-DESC, :HV-UOM, :HV-RATE,
                        :AUD-USER)
           END-EXEC
           IF SQLCODE = 0
              EXEC SQL COMMIT END-EXEC
              MOVE 'ADDITEM' TO AUD-ACTN
              MOVE HV-ITEM   TO AUD-KEY
              MOVE 'Inventory item added' TO AUD-TEXT
              CALL 'CMSERROR' USING AUD-USER AUD-PGM AUD-ACTN
                                    AUD-KEY AUD-TEXT
              EXEC SQL COMMIT END-EXEC
              MOVE 'Item added' TO WS-MSG
           ELSE
              EXEC SQL ROLLBACK END-EXEC
              MOVE 'Item add failed (duplicate code?)' TO WS-MSG
           END-IF.
       C100-EXIT.
           EXIT.
      *----------------------------------------------------------------*
       C300-PROCESS-SEL.
           MOVE 'N' TO WS-EOF-SW
           PERFORM UNTIL WS-EOF
              READ DSP-IV NEXT MODIFIED RECORD FORMAT IS 'IVSFL'
                   AT END SET WS-EOF TO TRUE
              END-READ
              IF NOT WS-EOF
                 MOVE SEL OF IVSFL   TO WS-SEL
                 MOVE ZITEM OF IVSFL TO HV-ITEM
                 MOVE ZADJ OF IVSFL  TO HV-ADJ
                 IF WS-SEL = 'R' OR WS-SEL = 'r'
                    PERFORM C400-RECEIVE
                 END-IF
                 IF WS-SEL = 'I' OR WS-SEL = 'i'
                    PERFORM C500-ISSUE
                 END-IF
              END-IF
           END-PERFORM.
      *----------------------------------------------------------------*
       C400-RECEIVE.
           IF HV-ADJ <= 0
              MOVE 'Enter a positive Adj qty to receive' TO WS-MSG
              GO TO C400-EXIT
           END-IF
           EXEC SQL
                INSERT INTO TEHMSDTA/IVPTXN
                   (ITM_CODE, TXN_TYPE, TXN_QTY, CRT_USR)
                VALUES (:HV-ITEM, 'R', :HV-ADJ, :AUD-USER)
           END-EXEC
           EXEC SQL
                UPDATE TEHMSDTA/IVPITEM
                   SET ITM_QOH = ITM_QOH + :HV-ADJ, UPD_USR = :AUD-USER
                 WHERE ITM_CODE = :HV-ITEM
           END-EXEC
           PERFORM C600-FINISH.
       C400-EXIT.
           EXIT.
      *----------------------------------------------------------------*
       C500-ISSUE.
           IF HV-ADJ <= 0
              MOVE 'Enter a positive Adj qty to issue' TO WS-MSG
              GO TO C500-EXIT
           END-IF
           EXEC SQL
                SELECT ITM_QOH INTO :HV-QOH FROM TEHMSDTA/IVPITEM
                 WHERE ITM_CODE = :HV-ITEM
           END-EXEC
           IF HV-QOH < HV-ADJ
              MOVE 'Insufficient stock to issue' TO WS-MSG
              GO TO C500-EXIT
           END-IF
           EXEC SQL
                INSERT INTO TEHMSDTA/IVPTXN
                   (ITM_CODE, TXN_TYPE, TXN_QTY, CRT_USR)
                VALUES (:HV-ITEM, 'I', :HV-ADJ, :AUD-USER)
           END-EXEC
           EXEC SQL
                UPDATE TEHMSDTA/IVPITEM
                   SET ITM_QOH = ITM_QOH - :HV-ADJ, UPD_USR = :AUD-USER
                 WHERE ITM_CODE = :HV-ITEM
           END-EXEC
           PERFORM C600-FINISH.
       C500-EXIT.
           EXIT.
      *----------------------------------------------------------------*
       C600-FINISH.
           IF SQLCODE = 0
              EXEC SQL COMMIT END-EXEC
              MOVE 'STOCKTXN' TO AUD-ACTN
              MOVE HV-ITEM    TO AUD-KEY
              MOVE 'Stock movement posted' TO AUD-TEXT
              CALL 'CMSERROR' USING AUD-USER AUD-PGM AUD-ACTN
                                    AUD-KEY AUD-TEXT
              EXEC SQL COMMIT END-EXEC
              MOVE 'Stock updated' TO WS-MSG
           ELSE
              EXEC SQL ROLLBACK END-EXEC
              MOVE 'Stock movement failed' TO WS-MSG
           END-IF.
      *================================================================*
      * END OF IVIITEM                                                 *
      *================================================================*
