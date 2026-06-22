      *================================================================*
      * PROGRAM  : FNBTRIAL        PRINTER FILE : FNRTRIAL            *
      * MODULE   : Finance / General Ledger (FN)                       *
      * LAYER    : Batch                                              *
      * PURPOSE  : Print a trial balance from the chart of accounts.   *
      *            A positive ACC_BAL shows in the debit column, a      *
      *            negative one (shown positive) in the credit column.  *
      * RUN      : SBMJOB CMD(CALL TEHMSPGM/FNBTRIAL) JOB(TRIALBAL)    *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. FNBTRIAL.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PRT-TB ASSIGN TO FORMATFILE-FNRTRIAL
                  ORGANIZATION IS SEQUENTIAL
                  FILE STATUS IS WS-PRT-STS.
       DATA DIVISION.
       FILE SECTION.
       FD  PRT-TB.
       01  PRT-REC.
           COPY DDS-ALL-FORMATS OF FNRTRIAL.
       WORKING-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  WS-PRT-STS          PIC X(02) VALUE '00'.
       01  WS-T-DR             PIC S9(13)V99 COMP-3 VALUE 0.
       01  WS-T-CR             PIC S9(13)V99 COMP-3 VALUE 0.
       01  WS-DR               PIC S9(13)V99 COMP-3.
       01  WS-CR               PIC S9(13)V99 COMP-3.
       01  HV.
           05  HV-DATE         PIC X(10).
           05  HV-ACC          PIC X(8).
           05  HV-NAME         PIC X(40).
           05  HV-BAL          PIC S9(13)V99 COMP-3.
       PROCEDURE DIVISION.
       A000-MAIN.
           OPEN OUTPUT PRT-TB
           EXEC SQL
                SELECT CHAR(CURRENT DATE, ISO) INTO :HV-DATE
                  FROM SYSIBM.SYSDUMMY1
           END-EXEC
           MOVE HV-DATE TO PDATE OF RHEAD
           WRITE PRT-REC FORMAT IS 'RHEAD'
           EXEC SQL
                DECLARE CT CURSOR FOR
                SELECT ACC_CODE, ACC_NAME, ACC_BAL
                  FROM TEHMSDTA/FNPACCT
                 WHERE REC_STS = 'A' ORDER BY ACC_CODE
           END-EXEC
           EXEC SQL OPEN CT END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL
                   FETCH CT INTO :HV-ACC, :HV-NAME, :HV-BAL
              END-EXEC
              IF SQLCODE = 0
                 MOVE 0 TO WS-DR
                 MOVE 0 TO WS-CR
                 IF HV-BAL >= 0
                    MOVE HV-BAL TO WS-DR
                 ELSE
                    COMPUTE WS-CR = 0 - HV-BAL
                 END-IF
                 MOVE HV-ACC  TO DACC OF RDETL
                 MOVE HV-NAME TO DNAME OF RDETL
                 MOVE WS-DR   TO DDR OF RDETL
                 MOVE WS-CR   TO DCR OF RDETL
                 WRITE PRT-REC FORMAT IS 'RDETL'
                 ADD WS-DR TO WS-T-DR
                 ADD WS-CR TO WS-T-CR
              END-IF
           END-PERFORM
           EXEC SQL CLOSE CT END-EXEC
           MOVE WS-T-DR TO TDR OF RTOT
           MOVE WS-T-CR TO TCR OF RTOT
           WRITE PRT-REC FORMAT IS 'RTOT'
           CLOSE PRT-TB
           STOP RUN.
      *================================================================*
      * END OF FNBTRIAL                                                *
      *================================================================*
