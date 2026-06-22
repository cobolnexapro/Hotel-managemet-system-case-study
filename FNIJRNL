      *================================================================*
      * PROGRAM  : FNIJRNL         DISPLAY FILE : FNDJRNL              *
      * MODULE   : Finance / General Ledger (FN)                       *
      * LAYER    : Presentation                                        *
      * PURPOSE  : Capture a double-entry GL journal. Lines are added  *
      *            to a draft header; the journal can only be POSTED    *
      *            when total debits = total credits (and > 0). Posting *
      *            stamps the header and rolls each line into the       *
      *            account balance (ACC_BAL += debit - credit).         *
      * FKEYS    : F6 AddLine  F10 Post  F3 Exit  F12 Cancel           *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. FNIJRNL.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT DSP-FJ ASSIGN TO WORKSTATION-FNDJRNL-SI
                  ORGANIZATION IS TRANSACTION
                  ACCESS IS DYNAMIC
                  RELATIVE KEY IS WS-RRN
                  FILE STATUS IS WS-DSP-STS.
       DATA DIVISION.
       FILE SECTION.
       FD  DSP-FJ.
       01  FJ-REC.
           COPY DDS-ALL-FORMATS OF FNDJRNL.
       WORKING-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  WS-DSP-STS          PIC X(02) VALUE '00'.
       01  WS-IND              PIC X(99) VALUE ALL '0'.
       01  WS-RRN              PIC S9(4) COMP-4 VALUE 0.
       01  WS-EXIT-SW          PIC X(01) VALUE 'N'.
           88  WS-EXIT                 VALUE 'Y'.
       01  WS-COUNT            PIC S9(4) COMP-4 VALUE 0.
       01  WS-MSG              PIC X(78).
       01  HV.
           05  HV-JID          PIC S9(9) COMP-4.
           05  HV-DESC         PIC X(50).
           05  HV-SEQ          PIC S9(4) COMP-4.
           05  HV-ACC          PIC X(8).
           05  HV-ACCN         PIC X(40).
           05  HV-DR           PIC S9(13)V99 COMP-3.
           05  HV-CR           PIC S9(13)V99 COMP-3.
           05  HV-MEMO         PIC X(40).
           05  HV-TDR          PIC S9(13)V99 COMP-3.
           05  HV-TCR          PIC S9(13)V99 COMP-3.
           05  HV-ACNT         PIC S9(9) COMP-4.
       01  AUD-USER            PIC X(10).
       01  AUD-PGM             PIC X(10) VALUE 'FNIJRNL'.
       01  AUD-ACTN            PIC X(10).
       01  AUD-KEY             PIC X(30).
       01  AUD-TEXT            PIC X(100).
       LINKAGE SECTION.
           COPY CMXSECDS.
       PROCEDURE DIVISION USING SESSION-DATA.
       A000-MAIN.
           MOVE SES-USER-ID TO AUD-USER
           OPEN I-O DSP-FJ
           PERFORM B050-NEW-JOURNAL
           PERFORM UNTIL WS-EXIT
              PERFORM B100-LOAD
              PERFORM B200-DISPLAY
           END-PERFORM
           PERFORM B900-CLEANUP
           CLOSE DSP-FJ
           GOBACK.
      *----------------------------------------------------------------*
       B050-NEW-JOURNAL.
           EXEC SQL
                INSERT INTO TEHMSDTA/FNPJRNH (JRN_DESC, CRT_USR)
                VALUES ('', :AUD-USER)
           END-EXEC
           EXEC SQL
                SELECT IDENTITY_VAL_LOCAL() INTO :HV-JID
                  FROM SYSIBM.SYSDUMMY1
           END-EXEC
           EXEC SQL COMMIT END-EXEC
           MOVE SPACES TO HV-DESC.
      *----------------------------------------------------------------*
       B100-LOAD.
           MOVE ALL '0' TO WS-IND
           MOVE '1' TO WS-IND(53:1)
           WRITE FJ-REC FORMAT IS 'FJCTL' INDICATORS ARE WS-IND
           MOVE '0' TO WS-IND(53:1)
           MOVE 0 TO WS-RRN
           MOVE 0 TO WS-COUNT
           EXEC SQL
                DECLARE CJ CURSOR FOR
                SELECT L.LIN_SEQ, L.ACC_CODE, A.ACC_NAME,
                       L.LIN_DR, L.LIN_CR
                  FROM TEHMSDTA/FNPJRNL L
                  JOIN TEHMSDTA/FNPACCT A ON L.ACC_CODE = A.ACC_CODE
                 WHERE L.JRN_ID = :HV-JID
                 ORDER BY L.LIN_SEQ
           END-EXEC
           EXEC SQL OPEN CJ END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL
                   FETCH CJ INTO :HV-SEQ, :HV-ACC, :HV-ACCN,
                                 :HV-DR, :HV-CR
              END-EXEC
              IF SQLCODE = 0
                 MOVE HV-SEQ  TO ZSEQ OF FJSFL
                 MOVE HV-ACC  TO ZACC OF FJSFL
                 MOVE HV-ACCN TO ZACCN OF FJSFL
                 MOVE HV-DR   TO ZDR OF FJSFL
                 MOVE HV-CR   TO ZCR OF FJSFL
                 ADD 1 TO WS-RRN
                 ADD 1 TO WS-COUNT
                 WRITE FJ-REC FORMAT IS 'FJSFL' INDICATORS ARE WS-IND
              END-IF
           END-PERFORM
           EXEC SQL CLOSE CJ END-EXEC
           PERFORM B150-TOTALS
           IF WS-COUNT > 0
              MOVE '1' TO WS-IND(51:1)
              MOVE '1' TO WS-IND(54:1)
           END-IF
           MOVE '1' TO WS-IND(52:1)
           MOVE HV-JID  TO HJID OF FJCTL
           MOVE HV-DESC TO HDESC OF FJCTL
           MOVE HV-TDR  TO TDR OF FJCTL
           MOVE HV-TCR  TO TCR OF FJCTL
           COMPUTE TBAL OF FJCTL = HV-TDR - HV-TCR.
      *----------------------------------------------------------------*
       B150-TOTALS.
           EXEC SQL
                SELECT COALESCE(SUM(LIN_DR),0), COALESCE(SUM(LIN_CR),0)
                  INTO :HV-TDR, :HV-TCR
                  FROM TEHMSDTA/FNPJRNL WHERE JRN_ID = :HV-JID
           END-EXEC.
      *----------------------------------------------------------------*
       B200-DISPLAY.
           MOVE WS-MSG TO MSGLIN OF FJCTL
           MOVE SPACES TO WS-MSG
           WRITE FJ-REC FORMAT IS 'FJCTL' INDICATORS ARE WS-IND
           READ DSP-FJ INDICATORS ARE WS-IND
           MOVE HDESC OF FJCTL TO HV-DESC
           EVALUATE TRUE
              WHEN WS-IND(3:1) = '1'
                 SET WS-EXIT TO TRUE
              WHEN WS-IND(12:1) = '1'
                 SET WS-EXIT TO TRUE
              WHEN WS-IND(6:1) = '1'
                 PERFORM C100-ADD-LINE
              WHEN WS-IND(10:1) = '1'
                 PERFORM C200-POST
              WHEN OTHER
                 CONTINUE
           END-EVALUATE.
      *----------------------------------------------------------------*
       C100-ADD-LINE.
           MOVE NACC OF FJCTL  TO HV-ACC
           MOVE NDR OF FJCTL   TO HV-DR
           MOVE NCR OF FJCTL   TO HV-CR
           MOVE NMEMO OF FJCTL TO HV-MEMO
           EXEC SQL
                SELECT COUNT(*) INTO :HV-ACNT FROM TEHMSDTA/FNPACCT
                 WHERE ACC_CODE = :HV-ACC AND REC_STS = 'A'
           END-EXEC
           IF HV-ACNT = 0
              MOVE 'Invalid account code' TO WS-MSG
              GO TO C100-EXIT
           END-IF
           IF (HV-DR > 0 AND HV-CR > 0)
              OR (HV-DR = 0 AND HV-CR = 0)
              MOVE 'Enter a debit OR a credit (not both)' TO WS-MSG
              GO TO C100-EXIT
           END-IF
           EXEC SQL
                SELECT COALESCE(MAX(LIN_SEQ),0) + 1 INTO :HV-SEQ
                  FROM TEHMSDTA/FNPJRNL WHERE JRN_ID = :HV-JID
           END-EXEC
           EXEC SQL
                INSERT INTO TEHMSDTA/FNPJRNL
                   (JRN_ID, LIN_SEQ, ACC_CODE, LIN_DR, LIN_CR,
                    LIN_MEMO, CRT_USR)
                VALUES (:HV-JID, :HV-SEQ, :HV-ACC, :HV-DR, :HV-CR,
                    :HV-MEMO, :AUD-USER)
           END-EXEC
           IF SQLCODE = 0
              EXEC SQL
                   UPDATE TEHMSDTA/FNPJRNH SET JRN_DESC = :HV-DESC
                    WHERE JRN_ID = :HV-JID
              END-EXEC
              EXEC SQL COMMIT END-EXEC
              MOVE 'Line added' TO WS-MSG
           ELSE
              EXEC SQL ROLLBACK END-EXEC
              MOVE 'Line insert failed' TO WS-MSG
           END-IF.
       C100-EXIT.
           EXIT.
      *----------------------------------------------------------------*
       C200-POST.
           PERFORM B150-TOTALS
           IF HV-TDR <= 0
              MOVE 'Nothing to post' TO WS-MSG
              GO TO C200-EXIT
           END-IF
           IF HV-TDR NOT = HV-TCR
              MOVE 'Journal does not balance - cannot post' TO WS-MSG
              GO TO C200-EXIT
           END-IF
           EXEC SQL
                UPDATE TEHMSDTA/FNPACCT A
                   SET ACC_BAL = ACC_BAL +
                       (SELECT COALESCE(SUM(L.LIN_DR - L.LIN_CR),0)
                          FROM TEHMSDTA/FNPJRNL L
                         WHERE L.JRN_ID = :HV-JID
                           AND L.ACC_CODE = A.ACC_CODE),
                       UPD_USR = :AUD-USER
                 WHERE A.ACC_CODE IN
                       (SELECT ACC_CODE FROM TEHMSDTA/FNPJRNL
                         WHERE JRN_ID = :HV-JID)
           END-EXEC
           IF SQLCODE NOT = 0
              EXEC SQL ROLLBACK END-EXEC
              MOVE 'Posting failed updating balances' TO WS-MSG
              GO TO C200-EXIT
           END-IF
           EXEC SQL
                UPDATE TEHMSDTA/FNPJRNH
                   SET JRN_STS = 'P', JRN_DR = :HV-TDR,
                       JRN_CR = :HV-TCR, JRN_DESC = :HV-DESC,
                       UPD_USR = :AUD-USER
                 WHERE JRN_ID = :HV-JID
           END-EXEC
           IF SQLCODE = 0
              EXEC SQL COMMIT END-EXEC
              MOVE 'POSTJRNL' TO AUD-ACTN
              MOVE HV-JID     TO AUD-KEY
              MOVE 'Journal posted to ledger' TO AUD-TEXT
              CALL 'CMSERROR' USING AUD-USER AUD-PGM AUD-ACTN
                                    AUD-KEY AUD-TEXT
              EXEC SQL COMMIT END-EXEC
              MOVE 'Journal posted' TO WS-MSG
              SET WS-EXIT TO TRUE
           ELSE
              EXEC SQL ROLLBACK END-EXEC
              MOVE 'Posting failed stamping header' TO WS-MSG
           END-IF.
       C200-EXIT.
           EXIT.
      *----------------------------------------------------------------*
      * Remove an empty unposted draft on exit.                        *
      *----------------------------------------------------------------*
       B900-CLEANUP.
           EXEC SQL
                SELECT COUNT(*) INTO :HV-ACNT FROM TEHMSDTA/FNPJRNL
                 WHERE JRN_ID = :HV-JID
           END-EXEC
           IF HV-ACNT = 0
              EXEC SQL
                   DELETE FROM TEHMSDTA/FNPJRNH
                    WHERE JRN_ID = :HV-JID AND JRN_STS = 'D'
              END-EXEC
              EXEC SQL COMMIT END-EXEC
           END-IF.
      *================================================================*
      * END OF FNIJRNL                                                 *
      *================================================================*
