      *================================================================*
      * PROGRAM  : SMILOGIN        DISPLAY FILE : SMDLOGIN             *
      * MODULE   : Security Management (SM)                            *
      * LAYER    : Presentation                                        *
      * PURPOSE  : Authenticate the user via CMSSEC, write an audit    *
      *            record via CMSERROR, then transfer control to the   *
      *            main menu CMMMAIN carrying the session descriptor.  *
      * FKEYS    : F3 / F12 = Exit                                     *
      * INDICATR : 03 = exit   12 = cancel                             *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SMILOGIN.
       AUTHOR. TEHMS-ARCHITECT.
      *----------------------------------------------------------------*
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT DSP-LOGIN ASSIGN TO WORKSTATION-SMDLOGIN-SI
                  ORGANIZATION IS TRANSACTION
                  ACCESS IS SEQUENTIAL
                  FILE STATUS IS WS-DSP-STS.
      *----------------------------------------------------------------*
       DATA DIVISION.
       FILE SECTION.
       FD  DSP-LOGIN.
       01  LOGIN-REC.
           COPY DDS-ALL-FORMATS OF SMDLOGIN.
      *----------------------------------------------------------------*
       WORKING-STORAGE SECTION.
       01  WS-DSP-STS          PIC X(02) VALUE '00'.
       01  WS-IND              PIC X(99) VALUE ALL '0'.
       01  WS-EXIT-SW          PIC X(01) VALUE 'N'.
           88  WS-EXIT                 VALUE 'Y'.
      *--- security call parameters ---
       01  SEC-OP              PIC X(05).
       01  SEC-USER            PIC X(10).
       01  SEC-PWD             PIC X(20).
       01  SEC-MODULE          PIC X(02) VALUE SPACES.
       01  SEC-ROLE            PIC X(10).
       01  SEC-RESULT          PIC X(01).
       01  SEC-MSG             PIC X(78).
      *--- audit call parameters ---
       01  AUD-USER            PIC X(10).
       01  AUD-PGM             PIC X(10) VALUE 'SMILOGIN'.
       01  AUD-ACTN            PIC X(10).
       01  AUD-KEY             PIC X(30).
       01  AUD-TEXT            PIC X(100).
           COPY CMXSECDS.
      *----------------------------------------------------------------*
       PROCEDURE DIVISION.
       A000-MAIN.
           OPEN I-O DSP-LOGIN
           PERFORM UNTIL WS-EXIT
              PERFORM A100-SIGN-ON
           END-PERFORM
           CLOSE DSP-LOGIN
           STOP RUN.
      *----------------------------------------------------------------*
       A100-SIGN-ON.
           MOVE SPACES TO MSGLIN OF LOGIN
           MOVE SPACES TO USERID OF LOGIN
           MOVE SPACES TO PASSWD OF LOGIN
           MOVE ALL '0' TO WS-IND
           WRITE LOGIN-REC FORMAT IS 'LOGIN'
                 INDICATORS ARE WS-IND
           READ DSP-LOGIN INDICATORS ARE WS-IND
           IF WS-IND(3:1) = '1' OR WS-IND(12:1) = '1'
              SET WS-EXIT TO TRUE
              GO TO A100-EXIT
           END-IF
           MOVE 'AUTH ' TO SEC-OP
           MOVE USERID OF LOGIN TO SEC-USER
           MOVE PASSWD OF LOGIN TO SEC-PWD
           CALL 'CMSSEC' USING SEC-OP SEC-USER SEC-PWD
                               SEC-MODULE SEC-ROLE
                               SEC-RESULT SEC-MSG
           MOVE SEC-USER TO AUD-USER
           IF SEC-RESULT = '0'
              MOVE 'SIGNON'   TO AUD-ACTN
              MOVE SEC-USER   TO AUD-KEY
              MOVE 'User signed on successfully' TO AUD-TEXT
              CALL 'CMSERROR' USING AUD-USER AUD-PGM AUD-ACTN
                                    AUD-KEY  AUD-TEXT
              EXEC SQL COMMIT END-EXEC
              MOVE SEC-USER TO SES-USER-ID
              MOVE SEC-ROLE TO SES-USER-ROLE
              MOVE '0'      TO SES-RETURN-CD
              PERFORM A200-GET-NAME
              CALL 'CMMMAIN' USING SESSION-DATA
           ELSE
              MOVE 'SIGNFAIL' TO AUD-ACTN
              MOVE SEC-USER   TO AUD-KEY
              MOVE SEC-MSG    TO AUD-TEXT
              CALL 'CMSERROR' USING AUD-USER AUD-PGM AUD-ACTN
                                    AUD-KEY  AUD-TEXT
              EXEC SQL COMMIT END-EXEC
              MOVE SEC-MSG TO MSGLIN OF LOGIN
           END-IF.
       A100-EXIT.
           EXIT.
      *----------------------------------------------------------------*
       A200-GET-NAME.
           EXEC SQL
                SELECT USR_NAME INTO :SES-USER-NAME
                  FROM TEHMSDTA/SMPUSER
                 WHERE USR_ID = :SES-USER-ID
           END-EXEC
           IF SQLCODE NOT = 0
              MOVE SPACES TO SES-USER-NAME
           END-IF.
      *================================================================*
      * END OF SMILOGIN                                                *
      *================================================================*
