      *================================================================*
      * PROGRAM  : ADIUSER         DISPLAY FILE : ADDUSER             *
      * MODULE   : Administration (AD) / Security (SM)                 *
      * LAYER    : Presentation                                        *
      * PURPOSE  : List application users; add a user (blank password  *
      *            so it is set on first sign-on); reset password,      *
      *            lock or unlock a user. Reached only by role ADMIN.   *
      * SUBFILE  : SEL  R=Reset Pwd  L=Lock  U=Unlock                  *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ADIUSER.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT DSP-US ASSIGN TO WORKSTATION-ADDUSER-SI
                  ORGANIZATION IS TRANSACTION
                  ACCESS IS DYNAMIC
                  RELATIVE KEY IS WS-RRN
                  FILE STATUS IS WS-DSP-STS.
       DATA DIVISION.
       FILE SECTION.
       FD  DSP-US.
       01  US-REC.
           COPY DDS-ALL-FORMATS OF ADDUSER.
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
           05  HV-UID          PIC X(10).
           05  HV-NAME         PIC X(40).
           05  HV-ROLE         PIC X(10).
           05  HV-STS          PIC X(1).
       01  AUD-USER            PIC X(10).
       01  AUD-PGM             PIC X(10) VALUE 'ADIUSER'.
       01  AUD-ACTN            PIC X(10).
       01  AUD-KEY             PIC X(30).
       01  AUD-TEXT            PIC X(100).
       LINKAGE SECTION.
           COPY CMXSECDS.
       PROCEDURE DIVISION USING SESSION-DATA.
       A000-MAIN.
           MOVE SES-USER-ID TO AUD-USER
           OPEN I-O DSP-US
           PERFORM UNTIL WS-EXIT
              PERFORM B100-LOAD
              PERFORM B200-DISPLAY
           END-PERFORM
           CLOSE DSP-US
           GOBACK.
      *----------------------------------------------------------------*
       B100-LOAD.
           MOVE ALL '0' TO WS-IND
           MOVE '1' TO WS-IND(53:1)
           WRITE US-REC FORMAT IS 'USCTL' INDICATORS ARE WS-IND
           MOVE '0' TO WS-IND(53:1)
           MOVE 0 TO WS-RRN
           MOVE 0 TO WS-COUNT
           EXEC SQL
                DECLARE CU CURSOR FOR
                SELECT USR_ID, USR_NAME, USR_ROLE, REC_STS
                  FROM TEHMSDTA/SMPUSER ORDER BY USR_ID
           END-EXEC
           EXEC SQL OPEN CU END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL
                   FETCH CU INTO :HV-UID, :HV-NAME, :HV-ROLE, :HV-STS
              END-EXEC
              IF SQLCODE = 0
                 MOVE SPACES  TO SEL OF USSFL
                 MOVE HV-UID  TO ZUID OF USSFL
                 MOVE HV-NAME TO ZUNAME OF USSFL
                 MOVE HV-ROLE TO ZUROLE OF USSFL
                 MOVE HV-STS  TO ZUSTS OF USSFL
                 ADD 1 TO WS-RRN
                 ADD 1 TO WS-COUNT
                 WRITE US-REC FORMAT IS 'USSFL' INDICATORS ARE WS-IND
              END-IF
           END-PERFORM
           EXEC SQL CLOSE CU END-EXEC
           IF WS-COUNT > 0
              MOVE '1' TO WS-IND(51:1)
              MOVE '1' TO WS-IND(54:1)
           END-IF
           MOVE '1' TO WS-IND(52:1).
      *----------------------------------------------------------------*
       B200-DISPLAY.
           MOVE WS-MSG TO MSGLIN OF USCTL
           MOVE SPACES TO WS-MSG
           WRITE US-REC FORMAT IS 'USCTL' INDICATORS ARE WS-IND
           READ DSP-US INDICATORS ARE WS-IND
           EVALUATE TRUE
              WHEN WS-IND(3:1) = '1'
                 SET WS-EXIT TO TRUE
              WHEN WS-IND(12:1) = '1'
                 SET WS-EXIT TO TRUE
              WHEN WS-IND(5:1) = '1'
                 CONTINUE
              WHEN WS-IND(6:1) = '1'
                 PERFORM C100-ADD-USER
              WHEN OTHER
                 PERFORM C300-PROCESS-SEL
           END-EVALUATE.
      *----------------------------------------------------------------*
       C100-ADD-USER.
           MOVE ALL '0' TO WS-IND
           MOVE SPACES TO DUID OF USDETL
           MOVE SPACES TO DUNAME OF USDETL
           MOVE 'FRONTDESK' TO DUROLE OF USDETL
           MOVE SPACES TO DMSG OF USDETL
           WRITE US-REC FORMAT IS 'USDETL' INDICATORS ARE WS-IND
           READ DSP-US INDICATORS ARE WS-IND
           IF WS-IND(12:1) = '1'
              GO TO C100-EXIT
           END-IF
           MOVE DUID OF USDETL   TO HV-UID
           MOVE DUNAME OF USDETL TO HV-NAME
           MOVE DUROLE OF USDETL TO HV-ROLE
           IF HV-UID = SPACES
              MOVE 'User id is required' TO WS-MSG
              GO TO C100-EXIT
           END-IF
           IF HV-ROLE NOT = 'ADMIN' AND HV-ROLE NOT = 'MANAGER'
              AND HV-ROLE NOT = 'FRONTDESK'
              MOVE 'Role must be ADMIN/MANAGER/FRONTDESK' TO WS-MSG
              GO TO C100-EXIT
           END-IF
           EXEC SQL
                INSERT INTO TEHMSDTA/SMPUSER
                   (USR_ID, USR_NAME, USR_ROLE, CRT_USR)
                VALUES (:HV-UID, :HV-NAME, :HV-ROLE, :AUD-USER)
           END-EXEC
           IF SQLCODE = 0
              EXEC SQL COMMIT END-EXEC
              MOVE 'ADDUSER' TO AUD-ACTN
              MOVE HV-UID    TO AUD-KEY
              MOVE 'New user created' TO AUD-TEXT
              CALL 'CMSERROR' USING AUD-USER AUD-PGM AUD-ACTN
                                    AUD-KEY AUD-TEXT
              EXEC SQL COMMIT END-EXEC
              MOVE 'User created (password set on first sign-on)'
                TO WS-MSG
           ELSE
              EXEC SQL ROLLBACK END-EXEC
              MOVE 'User create failed (duplicate id?)' TO WS-MSG
           END-IF.
       C100-EXIT.
           EXIT.
      *----------------------------------------------------------------*
       C300-PROCESS-SEL.
           MOVE 'N' TO WS-EOF-SW
           PERFORM UNTIL WS-EOF
              READ DSP-US NEXT MODIFIED RECORD FORMAT IS 'USSFL'
                   AT END SET WS-EOF TO TRUE
              END-READ
              IF NOT WS-EOF
                 MOVE SEL OF USSFL  TO WS-SEL
                 MOVE ZUID OF USSFL TO HV-UID
                 PERFORM C350-APPLY
              END-IF
           END-PERFORM.
      *----------------------------------------------------------------*
       C350-APPLY.
           EVALUATE WS-SEL
              WHEN 'R'
              WHEN 'r'
                 EXEC SQL
                      UPDATE TEHMSDTA/SMPUSER
                         SET USR_PWD = '', USR_SALT = '',
                             USR_FAIL = 0, REC_STS = 'A',
                             UPD_USR = :AUD-USER
                       WHERE USR_ID = :HV-UID
                 END-EXEC
                 PERFORM C400-FINISH
              WHEN 'L'
              WHEN 'l'
                 EXEC SQL
                      UPDATE TEHMSDTA/SMPUSER
                         SET REC_STS = 'I', UPD_USR = :AUD-USER
                       WHERE USR_ID = :HV-UID
                 END-EXEC
                 PERFORM C400-FINISH
              WHEN 'U'
              WHEN 'u'
                 EXEC SQL
                      UPDATE TEHMSDTA/SMPUSER
                         SET REC_STS = 'A', USR_FAIL = 0,
                             UPD_USR = :AUD-USER
                       WHERE USR_ID = :HV-UID
                 END-EXEC
                 PERFORM C400-FINISH
              WHEN OTHER
                 CONTINUE
           END-EVALUATE.
      *----------------------------------------------------------------*
       C400-FINISH.
           IF SQLCODE = 0
              EXEC SQL COMMIT END-EXEC
              MOVE 'USRADMIN' TO AUD-ACTN
              MOVE HV-UID     TO AUD-KEY
              MOVE 'User account maintained' TO AUD-TEXT
              CALL 'CMSERROR' USING AUD-USER AUD-PGM AUD-ACTN
                                    AUD-KEY AUD-TEXT
              EXEC SQL COMMIT END-EXEC
              MOVE 'User updated' TO WS-MSG
           ELSE
              EXEC SQL ROLLBACK END-EXEC
              MOVE 'User update failed' TO WS-MSG
           END-IF.
      *================================================================*
      * END OF ADIUSER                                                 *
      *================================================================*
