      *================================================================*
      * PROGRAM  : RMIROOM         DISPLAY FILE : RMDROOM             *
      * MODULE   : Room (RM) / Housekeeping (HK)                       *
      * LAYER    : Presentation                                        *
      * PURPOSE  : List rooms and update occupancy / block / maint     *
      *            status and housekeeping (cleaning) status.          *
      * SUBFILE  : SEL  V/O/B/M = room status   C/D/I = cleaning       *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. RMIROOM.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT DSP-RM ASSIGN TO WORKSTATION-RMDROOM-SI
                  ORGANIZATION IS TRANSACTION
                  ACCESS IS DYNAMIC
                  RELATIVE KEY IS WS-RRN
                  FILE STATUS IS WS-DSP-STS.
       DATA DIVISION.
       FILE SECTION.
       FD  DSP-RM.
       01  RM-REC.
           COPY DDS-ALL-FORMATS OF RMDROOM.
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
           05  HV-RNO          PIC X(6).
           05  HV-CAT          PIC X(6).
           05  HV-FLR          PIC S9(4) COMP-4.
           05  HV-STS          PIC X(1).
           05  HV-CLN          PIC X(1).
       01  AUD-USER            PIC X(10).
       01  AUD-PGM             PIC X(10) VALUE 'RMIROOM'.
       01  AUD-ACTN            PIC X(10).
       01  AUD-KEY             PIC X(30).
       01  AUD-TEXT            PIC X(100).
       LINKAGE SECTION.
           COPY CMXSECDS.
       PROCEDURE DIVISION USING SESSION-DATA.
       A000-MAIN.
           MOVE SES-USER-ID TO AUD-USER
           OPEN I-O DSP-RM
           PERFORM UNTIL WS-EXIT
              PERFORM B100-LOAD
              PERFORM B200-DISPLAY
           END-PERFORM
           CLOSE DSP-RM
           GOBACK.
      *----------------------------------------------------------------*
       B100-LOAD.
           MOVE ALL '0' TO WS-IND
           MOVE '1' TO WS-IND(53:1)
           WRITE RM-REC FORMAT IS 'RMCTL' INDICATORS ARE WS-IND
           MOVE '0' TO WS-IND(53:1)
           MOVE 0 TO WS-RRN
           MOVE 0 TO WS-COUNT
           EXEC SQL
                DECLARE CR CURSOR FOR
                SELECT RM_NO, CAT_CODE, RM_FLOOR, RM_STS, RM_CLN
                  FROM TEHMSDTA/RMPROOM
                 WHERE REC_STS = 'A' ORDER BY RM_NO
           END-EXEC
           EXEC SQL OPEN CR END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL
                   FETCH CR INTO :HV-RNO, :HV-CAT, :HV-FLR,
                                 :HV-STS, :HV-CLN
              END-EXEC
              IF SQLCODE = 0
                 MOVE SPACES  TO SEL OF RMSFL
                 MOVE HV-RNO  TO ZRNO OF RMSFL
                 MOVE HV-CAT  TO ZCAT OF RMSFL
                 MOVE HV-FLR  TO ZFLR OF RMSFL
                 MOVE HV-STS  TO ZSTS OF RMSFL
                 MOVE HV-CLN  TO ZCLN OF RMSFL
                 PERFORM B150-DESCRIBE
                 ADD 1 TO WS-RRN
                 ADD 1 TO WS-COUNT
                 WRITE RM-REC FORMAT IS 'RMSFL' INDICATORS ARE WS-IND
              END-IF
           END-PERFORM
           EXEC SQL CLOSE CR END-EXEC
           IF WS-COUNT > 0
              MOVE '1' TO WS-IND(51:1)
              MOVE '1' TO WS-IND(54:1)
           END-IF
           MOVE '1' TO WS-IND(52:1).
      *----------------------------------------------------------------*
       B150-DESCRIBE.
           EVALUATE HV-STS
              WHEN 'V' MOVE 'Vacant'      TO ZSTSD OF RMSFL
              WHEN 'O' MOVE 'Occupied'    TO ZSTSD OF RMSFL
              WHEN 'B' MOVE 'Blocked'     TO ZSTSD OF RMSFL
              WHEN 'M' MOVE 'Maintenance' TO ZSTSD OF RMSFL
              WHEN OTHER MOVE SPACES      TO ZSTSD OF RMSFL
           END-EVALUATE
           EVALUATE HV-CLN
              WHEN 'C' MOVE 'Clean'     TO ZCLND OF RMSFL
              WHEN 'D' MOVE 'Dirty'     TO ZCLND OF RMSFL
              WHEN 'I' MOVE 'Inspected' TO ZCLND OF RMSFL
              WHEN OTHER MOVE SPACES    TO ZCLND OF RMSFL
           END-EVALUATE.
      *----------------------------------------------------------------*
       B200-DISPLAY.
           MOVE WS-MSG TO MSGLIN OF RMCTL
           MOVE SPACES TO WS-MSG
           WRITE RM-REC FORMAT IS 'RMCTL' INDICATORS ARE WS-IND
           READ DSP-RM INDICATORS ARE WS-IND
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
              READ DSP-RM NEXT MODIFIED RECORD FORMAT IS 'RMSFL'
                   AT END SET WS-EOF TO TRUE
              END-READ
              IF NOT WS-EOF
                 MOVE SEL OF RMSFL  TO WS-SEL
                 MOVE ZRNO OF RMSFL TO HV-RNO
                 PERFORM C350-APPLY
              END-IF
           END-PERFORM.
      *----------------------------------------------------------------*
       C350-APPLY.
           EVALUATE WS-SEL
              WHEN 'V'
              WHEN 'O'
              WHEN 'B'
              WHEN 'M'
                 EXEC SQL
                      UPDATE TEHMSDTA/RMPROOM
                         SET RM_STS = :WS-SEL, UPD_USR = :AUD-USER
                       WHERE RM_NO = :HV-RNO
                 END-EXEC
                 PERFORM C400-COMMIT
              WHEN 'C'
              WHEN 'D'
              WHEN 'I'
                 EXEC SQL
                      UPDATE TEHMSDTA/RMPROOM
                         SET RM_CLN = :WS-SEL, UPD_USR = :AUD-USER
                       WHERE RM_NO = :HV-RNO
                 END-EXEC
                 PERFORM C400-COMMIT
              WHEN OTHER
                 CONTINUE
           END-EVALUATE.
      *----------------------------------------------------------------*
       C400-COMMIT.
           IF SQLCODE = 0
              EXEC SQL COMMIT END-EXEC
              MOVE 'RMSTS' TO AUD-ACTN
              MOVE HV-RNO  TO AUD-KEY
              MOVE 'Room/cleaning status changed' TO AUD-TEXT
              CALL 'CMSERROR' USING AUD-USER AUD-PGM AUD-ACTN
                                    AUD-KEY AUD-TEXT
              EXEC SQL COMMIT END-EXEC
              MOVE 'Status updated' TO WS-MSG
           ELSE
              EXEC SQL ROLLBACK END-EXEC
              MOVE 'Update failed' TO WS-MSG
           END-IF.
      *================================================================*
      * END OF RMIROOM                                                 *
      *================================================================*
