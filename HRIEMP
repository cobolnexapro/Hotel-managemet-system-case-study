      *================================================================*
      * PROGRAM  : HRIEMP          DISPLAY FILE : HRDEMP              *
      * MODULE   : Human Resources (HR)                               *
      * LAYER    : Presentation                                        *
      * PURPOSE  : List / filter employees, add and edit employee      *
      *            master records (salary components, department).      *
      * SUBFILE  : SEL S=Edit   F6=Add                                *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. HRIEMP.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT DSP-HR ASSIGN TO WORKSTATION-HRDEMP-SI
                  ORGANIZATION IS TRANSACTION
                  ACCESS IS DYNAMIC
                  RELATIVE KEY IS WS-RRN
                  FILE STATUS IS WS-DSP-STS.
       DATA DIVISION.
       FILE SECTION.
       FD  DSP-HR.
       01  HR-REC.
           COPY DDS-ALL-FORMATS OF HRDEMP.
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
       01  WS-MODE             PIC X(01) VALUE 'A'.
       01  WS-MSG              PIC X(78).
       01  HV.
           05  HV-EID          PIC S9(9) COMP-4.
           05  HV-NAME         PIC X(40).
           05  HV-DPT          PIC X(6).
           05  HV-DESIG        PIC X(30).
           05  HV-BASIC        PIC S9(11)V99 COMP-3.
           05  HV-HRA          PIC S9(11)V99 COMP-3.
           05  HV-DED          PIC S9(11)V99 COMP-3.
           05  HV-PHONE        PIC X(15).
           05  HV-LIKE         PIC X(42).
           05  HV-DCNT         PIC S9(9) COMP-4.
       01  AUD-USER            PIC X(10).
       01  AUD-PGM             PIC X(10) VALUE 'HRIEMP'.
       01  AUD-ACTN            PIC X(10).
       01  AUD-KEY             PIC X(30).
       01  AUD-TEXT            PIC X(100).
       LINKAGE SECTION.
           COPY CMXSECDS.
       PROCEDURE DIVISION USING SESSION-DATA.
       A000-MAIN.
           MOVE SES-USER-ID TO AUD-USER
           OPEN I-O DSP-HR
           MOVE '%' TO HV-LIKE
           PERFORM UNTIL WS-EXIT
              PERFORM B100-LOAD
              PERFORM B200-DISPLAY
           END-PERFORM
           CLOSE DSP-HR
           GOBACK.
      *----------------------------------------------------------------*
       B100-LOAD.
           MOVE ALL '0' TO WS-IND
           MOVE '1' TO WS-IND(53:1)
           WRITE HR-REC FORMAT IS 'HRCTL' INDICATORS ARE WS-IND
           MOVE '0' TO WS-IND(53:1)
           MOVE 0 TO WS-RRN
           MOVE 0 TO WS-COUNT
           EXEC SQL
                DECLARE CH CURSOR FOR
                SELECT EMP_ID, EMP_NAME, DPT_CODE, EMP_DESIG, EMP_BASIC
                  FROM TEHMSDTA/HRPEMP
                 WHERE REC_STS = 'A'
                   AND UPPER(EMP_NAME) LIKE UPPER(:HV-LIKE)
                 ORDER BY EMP_NAME
           END-EXEC
           EXEC SQL OPEN CH END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL
                   FETCH CH INTO :HV-EID, :HV-NAME, :HV-DPT,
                                 :HV-DESIG, :HV-BASIC
              END-EXEC
              IF SQLCODE = 0
                 MOVE SPACES   TO SEL OF HRSFL
                 MOVE HV-EID   TO ZEID OF HRSFL
                 MOVE HV-NAME  TO ZENAME OF HRSFL
                 MOVE HV-DPT   TO ZDPT OF HRSFL
                 MOVE HV-DESIG TO ZDESIG OF HRSFL
                 MOVE HV-BASIC TO ZBASIC OF HRSFL
                 ADD 1 TO WS-RRN
                 ADD 1 TO WS-COUNT
                 WRITE HR-REC FORMAT IS 'HRSFL' INDICATORS ARE WS-IND
              END-IF
           END-PERFORM
           EXEC SQL CLOSE CH END-EXEC
           IF WS-COUNT > 0
              MOVE '1' TO WS-IND(51:1)
              MOVE '1' TO WS-IND(54:1)
           END-IF
           MOVE '1' TO WS-IND(52:1).
      *----------------------------------------------------------------*
       B200-DISPLAY.
           MOVE WS-MSG TO MSGLIN OF HRCTL
           MOVE SPACES TO WS-MSG
           WRITE HR-REC FORMAT IS 'HRCTL' INDICATORS ARE WS-IND
           READ DSP-HR INDICATORS ARE WS-IND
           EVALUATE TRUE
              WHEN WS-IND(3:1) = '1'
                 SET WS-EXIT TO TRUE
              WHEN WS-IND(12:1) = '1'
                 SET WS-EXIT TO TRUE
              WHEN WS-IND(5:1) = '1'
                 MOVE FNAME OF HRCTL TO HV-LIKE
              WHEN WS-IND(6:1) = '1'
                 MOVE 'A' TO WS-MODE
                 PERFORM C100-EDIT
              WHEN OTHER
                 MOVE FNAME OF HRCTL TO HV-LIKE
                 PERFORM C300-PROCESS-SEL
           END-EVALUATE.
      *----------------------------------------------------------------*
       C100-EDIT.
           MOVE ALL '0' TO WS-IND
           IF WS-MODE = 'A'
              MOVE 0 TO HV-EID
              INITIALIZE HV-NAME HV-DPT HV-DESIG HV-PHONE
              MOVE 0 TO HV-BASIC
              MOVE 0 TO HV-HRA
              MOVE 0 TO HV-DED
           END-IF
           MOVE HV-EID   TO DEID OF HRDETL
           MOVE HV-NAME  TO DENAME OF HRDETL
           MOVE HV-DPT   TO DDPT OF HRDETL
           MOVE HV-DESIG TO DDESIG OF HRDETL
           MOVE HV-BASIC TO DBASIC OF HRDETL
           MOVE HV-HRA   TO DHRA OF HRDETL
           MOVE HV-DED   TO DDED OF HRDETL
           MOVE HV-PHONE TO DPHONE OF HRDETL
           MOVE SPACES   TO DMSG OF HRDETL
           WRITE HR-REC FORMAT IS 'HRDETL' INDICATORS ARE WS-IND
           READ DSP-HR INDICATORS ARE WS-IND
           IF WS-IND(12:1) = '1'
              GO TO C100-EXIT
           END-IF
           MOVE DENAME OF HRDETL TO HV-NAME
           MOVE DDPT OF HRDETL   TO HV-DPT
           MOVE DDESIG OF HRDETL TO HV-DESIG
           MOVE DBASIC OF HRDETL TO HV-BASIC
           MOVE DHRA OF HRDETL   TO HV-HRA
           MOVE DDED OF HRDETL   TO HV-DED
           MOVE DPHONE OF HRDETL TO HV-PHONE
           IF HV-NAME = SPACES
              MOVE 'Employee name is required' TO WS-MSG
              GO TO C100-EXIT
           END-IF
           EXEC SQL
                SELECT COUNT(*) INTO :HV-DCNT FROM TEHMSDTA/HRPDEPT
                 WHERE DPT_CODE = :HV-DPT AND REC_STS = 'A'
           END-EXEC
           IF HV-DCNT = 0
              MOVE 'Invalid department code' TO WS-MSG
              GO TO C100-EXIT
           END-IF
           IF WS-MODE = 'A'
              EXEC SQL
                   INSERT INTO TEHMSDTA/HRPEMP
                      (EMP_NAME, DPT_CODE, EMP_DESIG, EMP_BASIC,
                       EMP_HRA, EMP_DED, EMP_PHONE, CRT_USR)
                   VALUES (:HV-NAME, :HV-DPT, :HV-DESIG, :HV-BASIC,
                       :HV-HRA, :HV-DED, :HV-PHONE, :AUD-USER)
              END-EXEC
              MOVE 'ADDEMP' TO AUD-ACTN
           ELSE
              EXEC SQL
                   UPDATE TEHMSDTA/HRPEMP
                      SET EMP_NAME = :HV-NAME, DPT_CODE = :HV-DPT,
                          EMP_DESIG = :HV-DESIG, EMP_BASIC = :HV-BASIC,
                          EMP_HRA = :HV-HRA, EMP_DED = :HV-DED,
                          EMP_PHONE = :HV-PHONE, UPD_USR = :AUD-USER
                    WHERE EMP_ID = :HV-EID
              END-EXEC
              MOVE 'UPDEMP' TO AUD-ACTN
           END-IF
           IF SQLCODE = 0
              EXEC SQL COMMIT END-EXEC
              MOVE HV-NAME TO AUD-KEY
              MOVE 'Employee saved' TO AUD-TEXT
              CALL 'CMSERROR' USING AUD-USER AUD-PGM AUD-ACTN
                                    AUD-KEY AUD-TEXT
              EXEC SQL COMMIT END-EXEC
              MOVE 'Employee saved' TO WS-MSG
           ELSE
              EXEC SQL ROLLBACK END-EXEC
              MOVE 'Save failed' TO WS-MSG
           END-IF.
       C100-EXIT.
           EXIT.
      *----------------------------------------------------------------*
       C300-PROCESS-SEL.
           MOVE 'N' TO WS-EOF-SW
           PERFORM UNTIL WS-EOF
              READ DSP-HR NEXT MODIFIED RECORD FORMAT IS 'HRSFL'
                   AT END SET WS-EOF TO TRUE
              END-READ
              IF NOT WS-EOF
                 IF SEL OF HRSFL = 'S' OR SEL OF HRSFL = 's'
                    MOVE ZEID OF HRSFL TO HV-EID
                    PERFORM C350-LOAD-ONE
                    MOVE 'E' TO WS-MODE
                    PERFORM C100-EDIT
                 END-IF
              END-IF
           END-PERFORM.
      *----------------------------------------------------------------*
       C350-LOAD-ONE.
           EXEC SQL
                SELECT EMP_NAME, DPT_CODE, EMP_DESIG, EMP_BASIC,
                       EMP_HRA, EMP_DED, EMP_PHONE
                  INTO :HV-NAME, :HV-DPT, :HV-DESIG, :HV-BASIC,
                       :HV-HRA, :HV-DED, :HV-PHONE
                  FROM TEHMSDTA/HRPEMP WHERE EMP_ID = :HV-EID
           END-EXEC.
      *================================================================*
      * END OF HRIEMP                                                  *
      *================================================================*
