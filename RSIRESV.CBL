      *================================================================*
      * PROGRAM  : RSIRESV         DISPLAY FILE : RSDRESV              *
      * MODULE   : Reservation (RS)                                    *
      * LAYER    : Presentation                                        *
      * PURPOSE  : List / add reservations, allocate a room on check-in*
      *            (opening a guest folio), and cancel reservations.   *
      * FKEYS    : F3 Exit  F5 Refresh  F6 Add  F12 Cancel  F13 Process*
      * SUBFILE  : SEL  C=Check-In  X=Cancel                           *
      * INDICATR : 51 SFLDSP 52 SFLDSPCTL 53 SFLCLR 54 SFLEND          *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. RSIRESV.
       AUTHOR. TEHMS-ARCHITECT.
      *----------------------------------------------------------------*
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT DSP-RESV ASSIGN TO WORKSTATION-RSDRESV-SI
                  ORGANIZATION IS TRANSACTION
                  ACCESS IS DYNAMIC
                  RELATIVE KEY IS WS-RRN
                  FILE STATUS IS WS-DSP-STS.
      *----------------------------------------------------------------*
       DATA DIVISION.
       FILE SECTION.
       FD  DSP-RESV.
       01  RESV-REC.
           COPY DDS-ALL-FORMATS OF RSDRESV.
      *----------------------------------------------------------------*
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
      *--- host variables ---
       01  HV.
           05  HV-RESID        PIC S9(9) COMP-4.
           05  HV-GSTID        PIC S9(9) COMP-4.
           05  HV-NAME         PIC X(40).
           05  HV-CAT          PIC X(6).
           05  HV-ROOM         PIC X(6).
           05  HV-FRDT         PIC X(10).
           05  HV-TODT         PIC X(10).
           05  HV-STS          PIC X(1).
           05  HV-FSTS         PIC X(1).
           05  HV-PAX          PIC S9(4) COMP-4.
           05  HV-TYPE         PIC X(2).
           05  HV-ADV          PIC S9(11)V99 COMP-3.
           05  HV-RATE         PIC S9(9)V99  COMP-3.
           05  HV-CNT          PIC S9(9) COMP-4.
      *--- date conversion ---
       01  WS-IN-DT            PIC X(6).
       01  WS-ISO-DT          PIC X(10).
      *--- audit ---
       01  AUD-USER            PIC X(10).
       01  AUD-PGM             PIC X(10) VALUE 'RSIRESV'.
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
           OPEN I-O DSP-RESV
           MOVE SPACES TO HV-FSTS
           PERFORM UNTIL WS-EXIT
              PERFORM B100-LOAD-SUBFILE
              PERFORM B200-DISPLAY
           END-PERFORM
           CLOSE DSP-RESV
           GOBACK.
      *----------------------------------------------------------------*
      * LOAD SUBFILE                                                   *
      *----------------------------------------------------------------*
       B100-LOAD-SUBFILE.
           MOVE ALL '0' TO WS-IND
           MOVE '1' TO WS-IND(53:1)
           WRITE RESV-REC FORMAT IS 'RSCTL' INDICATORS ARE WS-IND
           MOVE '0' TO WS-IND(53:1)
           MOVE 0 TO WS-RRN
           MOVE 0 TO WS-COUNT
           MOVE HV-FSTS TO HV-FSTS
           EXEC SQL
                DECLARE C1 CURSOR FOR
                SELECT R.RES_ID, G.GST_NAME, R.CAT_CODE, R.RM_NO,
                       CHAR(R.RES_FRDT, ISO), CHAR(R.RES_TODT, ISO),
                       R.RES_STS
                  FROM TEHMSDTA/RSPRESV R
                  JOIN TEHMSDTA/GMPGUEST G ON R.GST_ID = G.GST_ID
                 WHERE (:HV-FSTS = ' ' OR R.RES_STS = :HV-FSTS)
                   AND R.REC_STS = 'A'
                 ORDER BY R.RES_ID
           END-EXEC
           EXEC SQL OPEN C1 END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL
                   FETCH C1 INTO :HV-RESID, :HV-NAME, :HV-CAT,
                                 :HV-ROOM, :HV-FRDT, :HV-TODT, :HV-STS
              END-EXEC
              IF SQLCODE = 0
                 PERFORM B150-WRITE-SFL-LINE
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C1 END-EXEC
           IF WS-COUNT > 0
              MOVE '1' TO WS-IND(51:1)
              MOVE '1' TO WS-IND(54:1)
           END-IF
           MOVE '1' TO WS-IND(52:1).
      *----------------------------------------------------------------*
       B150-WRITE-SFL-LINE.
           MOVE SPACES        TO SEL OF RSSFL
           MOVE HV-RESID      TO ZRESID OF RSSFL
           MOVE HV-NAME       TO ZNAME OF RSSFL
           MOVE HV-CAT        TO ZCAT OF RSSFL
           MOVE HV-ROOM       TO ZROOM OF RSSFL
           MOVE HV-FRDT       TO ZFRDT OF RSSFL
           MOVE HV-TODT       TO ZTODT OF RSSFL
           MOVE HV-STS        TO ZSTS OF RSSFL
           ADD 1 TO WS-RRN
           ADD 1 TO WS-COUNT
           WRITE RESV-REC FORMAT IS 'RSSFL' INDICATORS ARE WS-IND.
      *----------------------------------------------------------------*
      * DISPLAY CONTROL + HANDLE KEYS                                  *
      *----------------------------------------------------------------*
       B200-DISPLAY.
           MOVE WS-MSG TO MSGLIN OF RSCTL
           MOVE SPACES TO WS-MSG
           WRITE RESV-REC FORMAT IS 'RSCTL' INDICATORS ARE WS-IND
           READ DSP-RESV INDICATORS ARE WS-IND
           EVALUATE TRUE
              WHEN WS-IND(3:1) = '1'
                 SET WS-EXIT TO TRUE
              WHEN WS-IND(12:1) = '1'
                 SET WS-EXIT TO TRUE
              WHEN WS-IND(5:1) = '1'
                 MOVE FSTS OF RSCTL TO HV-FSTS
              WHEN WS-IND(6:1) = '1'
                 PERFORM C100-ADD-RESERVATION
              WHEN OTHER
                 MOVE FSTS OF RSCTL TO HV-FSTS
                 PERFORM C300-PROCESS-SELECTIONS
           END-EVALUATE.
      *----------------------------------------------------------------*
      * ADD RESERVATION                                               *
      *----------------------------------------------------------------*
       C100-ADD-RESERVATION.
           MOVE ALL '0' TO WS-IND
           MOVE 0       TO DRESID OF RSDETL
           MOVE SPACES  TO DGSTID OF RSDETL
           MOVE SPACES  TO DGNAME OF RSDETL
           MOVE SPACES  TO DCAT OF RSDETL
           MOVE SPACES  TO DFRDT OF RSDETL
           MOVE SPACES  TO DTODT OF RSDETL
           MOVE 1       TO DPAX OF RSDETL
           MOVE 'WI'    TO DTYPE OF RSDETL
           MOVE 0       TO DADV OF RSDETL
           MOVE SPACES  TO DMSG OF RSDETL
           WRITE RESV-REC FORMAT IS 'RSDETL' INDICATORS ARE WS-IND
           READ DSP-RESV INDICATORS ARE WS-IND
           IF WS-IND(12:1) = '1'
              GO TO C100-EXIT
           END-IF
           MOVE DGSTID OF RSDETL TO HV-GSTID
           MOVE DCAT OF RSDETL   TO HV-CAT
           MOVE DPAX OF RSDETL   TO HV-PAX
           MOVE DTYPE OF RSDETL  TO HV-TYPE
           MOVE DADV OF RSDETL   TO HV-ADV
      *    validate guest
           EXEC SQL
                SELECT GST_NAME INTO :HV-NAME FROM TEHMSDTA/GMPGUEST
                 WHERE GST_ID = :HV-GSTID AND REC_STS = 'A'
           END-EXEC
           IF SQLCODE NOT = 0
              MOVE 'Guest id not found' TO WS-MSG
              GO TO C100-EXIT
           END-IF
      *    validate category and get rate
           EXEC SQL
                SELECT CAT_RATE INTO :HV-RATE FROM TEHMSDTA/RMPCAT
                 WHERE CAT_CODE = :HV-CAT AND REC_STS = 'A'
           END-EXEC
           IF SQLCODE NOT = 0
              MOVE 'Invalid room category' TO WS-MSG
              GO TO C100-EXIT
           END-IF
      *    availability check
           CALL 'CMSSEC' USING 'AUTHZ' SES-USER-ID SPACES 'RS'
                               SES-USER-ROLE WS-DSP-STS WS-MSG
           MOVE DFRDT OF RSDETL TO WS-IN-DT
           PERFORM D100-CONVERT-DATE
           MOVE WS-ISO-DT TO HV-FRDT
           MOVE DTODT OF RSDETL TO WS-IN-DT
           PERFORM D100-CONVERT-DATE
           MOVE WS-ISO-DT TO HV-TODT
           EXEC SQL
                INSERT INTO TEHMSDTA/RSPRESV
                   (GST_ID, CAT_CODE, RES_FRDT, RES_TODT, RES_PAX,
                    RES_TYPE, RES_STS, RES_RATE, RES_ADV, CRT_USR)
                VALUES (:HV-GSTID, :HV-CAT, DATE(:HV-FRDT),
                    DATE(:HV-TODT), :HV-PAX, :HV-TYPE, 'R',
                    :HV-RATE, :HV-ADV, :AUD-USER)
           END-EXEC
           IF SQLCODE = 0
              EXEC SQL COMMIT END-EXEC
              MOVE 'RESV' TO AUD-ACTN
              MOVE HV-NAME TO AUD-KEY
              MOVE 'Reservation created' TO AUD-TEXT
              CALL 'CMSERROR' USING AUD-USER AUD-PGM AUD-ACTN
                                    AUD-KEY AUD-TEXT
              EXEC SQL COMMIT END-EXEC
              MOVE 'Reservation created successfully' TO WS-MSG
           ELSE
              EXEC SQL ROLLBACK END-EXEC
              MOVE 'Reservation insert failed' TO WS-MSG
           END-IF.
       C100-EXIT.
           EXIT.
      *----------------------------------------------------------------*
      * PROCESS SUBFILE SELECTIONS                                     *
      *----------------------------------------------------------------*
       C300-PROCESS-SELECTIONS.
           MOVE 'N' TO WS-EOF-SW
           PERFORM UNTIL WS-EOF
              READ DSP-RESV NEXT MODIFIED RECORD FORMAT IS 'RSSFL'
                   AT END SET WS-EOF TO TRUE
              END-READ
              IF NOT WS-EOF
                 MOVE ZRESID OF RSSFL TO HV-RESID
                 EVALUATE SEL OF RSSFL
                    WHEN 'C' PERFORM C400-CHECK-IN
                    WHEN 'c' PERFORM C400-CHECK-IN
                    WHEN 'X' PERFORM C500-CANCEL
                    WHEN 'x' PERFORM C500-CANCEL
                    WHEN OTHER CONTINUE
                 END-EVALUATE
              END-IF
           END-PERFORM.
      *----------------------------------------------------------------*
      * CHECK-IN : allocate room, open folio                          *
      *----------------------------------------------------------------*
       C400-CHECK-IN.
           EXEC SQL
                SELECT CAT_CODE, GST_ID INTO :HV-CAT, :HV-GSTID
                  FROM TEHMSDTA/RSPRESV WHERE RES_ID = :HV-RESID
           END-EXEC
           IF SQLCODE NOT = 0
              MOVE 'Reservation not found for check-in' TO WS-MSG
              GO TO C400-EXIT
           END-IF
           EXEC SQL
                SELECT MIN(RM_NO) INTO :HV-ROOM
                  FROM TEHMSDTA/RMPROOM
                 WHERE CAT_CODE = :HV-CAT AND RM_STS = 'V'
                   AND RM_CLN IN ('C','I') AND REC_STS = 'A'
           END-EXEC
           IF HV-ROOM = SPACES OR SQLCODE NOT = 0
              MOVE 'No vacant room in category' TO WS-MSG
              GO TO C400-EXIT
           END-IF
           EXEC SQL
                UPDATE TEHMSDTA/RSPRESV
                   SET RES_STS = 'C', RM_NO = :HV-ROOM,
                       UPD_USR = :AUD-USER
                 WHERE RES_ID = :HV-RESID
           END-EXEC
           EXEC SQL
                UPDATE TEHMSDTA/RMPROOM
                   SET RM_STS = 'O', UPD_USR = :AUD-USER
                 WHERE RM_NO = :HV-ROOM
           END-EXEC
           EXEC SQL
                INSERT INTO TEHMSDTA/BLPINVHD
                   (RES_ID, GST_ID, CRT_USR)
                VALUES (:HV-RESID, :HV-GSTID, :AUD-USER)
           END-EXEC
           IF SQLCODE = 0
              EXEC SQL COMMIT END-EXEC
              MOVE 'CHECKIN' TO AUD-ACTN
              MOVE HV-ROOM   TO AUD-KEY
              MOVE 'Guest checked-in, folio opened' TO AUD-TEXT
              CALL 'CMSERROR' USING AUD-USER AUD-PGM AUD-ACTN
                                    AUD-KEY AUD-TEXT
              EXEC SQL COMMIT END-EXEC
              STRING 'Checked-in to room ' DELIMITED BY SIZE
                     HV-ROOM DELIMITED BY SIZE
                     INTO WS-MSG
              END-STRING
           ELSE
              EXEC SQL ROLLBACK END-EXEC
              MOVE 'Check-in failed' TO WS-MSG
           END-IF.
       C400-EXIT.
           EXIT.
      *----------------------------------------------------------------*
      * CANCEL RESERVATION                                            *
      *----------------------------------------------------------------*
       C500-CANCEL.
           EXEC SQL
                UPDATE TEHMSDTA/RSPRESV
                   SET RES_STS = 'X', UPD_USR = :AUD-USER
                 WHERE RES_ID = :HV-RESID AND RES_STS = 'R'
           END-EXEC
           IF SQLCODE = 0
              EXEC SQL COMMIT END-EXEC
              MOVE 'Reservation cancelled' TO WS-MSG
           ELSE
              EXEC SQL ROLLBACK END-EXEC
              MOVE 'Only reserved bookings can be cancelled' TO WS-MSG
           END-IF.
      *----------------------------------------------------------------*
      * DATE CONVERT  DDMMYY -> 20YY-MM-DD                             *
      *----------------------------------------------------------------*
       D100-CONVERT-DATE.
           MOVE SPACES TO WS-ISO-DT
           STRING '20' DELIMITED BY SIZE
                  WS-IN-DT(5:2) DELIMITED BY SIZE
                  '-' DELIMITED BY SIZE
                  WS-IN-DT(3:2) DELIMITED BY SIZE
                  '-' DELIMITED BY SIZE
                  WS-IN-DT(1:2) DELIMITED BY SIZE
                  INTO WS-ISO-DT
           END-STRING.
      *================================================================*
      * END OF RSIRESV                                                 *
      *================================================================*
