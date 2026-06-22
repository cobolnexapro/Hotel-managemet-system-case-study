      *================================================================*
      * MODULE   : CMSSEC          SERVICE PGM : CMSSEC                *
      * LAYER    : Common / Security                                   *
      * PURPOSE  : Authenticate users, bootstrap first password, change*
      *            password, and check role authority for a module.    *
      * OPS      : 'AUTH '  authenticate (or set pwd on first sign-on) *
      *            'CHGPW'  change password (LK-PWD = new password)     *
      *            'AUTHZ'  check LK-ROLE authority for LK-MODULE       *
      * CALL     : CALL 'CMSSEC' USING LK-OP LK-USER LK-PWD            *
      *                                LK-MODULE LK-ROLE               *
      *                                LK-RESULT LK-MSG.               *
      * NOTE     : Hash is a DEMO-GRADE deterministic fold. For        *
      *            production replace HASH-PASSWORD with the Qc3        *
      *            cryptographic services API (Qc3CalculateHash).       *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CMSSEC.
       AUTHOR. TEHMS-ARCHITECT.
      *----------------------------------------------------------------*
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *----------------------------------------------------------------*
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  WS-DB.
           05  HV-USER         PIC X(10).
           05  HV-PWD          PIC X(64).
           05  HV-SALT         PIC X(16).
           05  HV-ROLE         PIC X(10).
           05  HV-FAIL         PIC S9(4) COMP-4.
           05  HV-STS          PIC X(01).
       01  WS-WORK.
           05  WS-MAX-FAIL     PIC 9(01) VALUE 3.
           05  WS-CALC-HASH    PIC X(64).
           05  WS-INPUT        PIC X(36).
           05  WS-LEN          PIC 9(03).
           05  WS-I            PIC 9(03).
           05  WS-IDX          PIC 9(03).
           05  WS-ORD          PIC 9(05).
           05  WS-HEXTAB       PIC X(16) VALUE '0123456789ABCDEF'.
           05  WS-HI           PIC 9(03).
           05  WS-LO           PIC 9(03).
           05  WS-NEWSALT      PIC X(16).
       01  WS-ACC-TABLE.
           05  WS-ACC OCCURS 32 TIMES PIC 9(03).
       01  WS-DT.
           05  WS-D            PIC X(08).
           05  WS-T            PIC X(08).
      *----------------------------------------------------------------*
       LINKAGE SECTION.
       01  LK-OP               PIC X(05).
       01  LK-USER             PIC X(10).
       01  LK-PWD              PIC X(20).
       01  LK-MODULE           PIC X(02).
       01  LK-ROLE             PIC X(10).
       01  LK-RESULT           PIC X(01).
       01  LK-MSG              PIC X(78).
      *----------------------------------------------------------------*
       PROCEDURE DIVISION USING LK-OP LK-USER LK-PWD LK-MODULE
                                LK-ROLE LK-RESULT LK-MSG.
       A000-MAIN.
           MOVE '1'     TO LK-RESULT
           MOVE SPACES  TO LK-MSG
           EVALUATE LK-OP
              WHEN 'AUTH '  PERFORM B100-AUTHENTICATE
              WHEN 'CHGPW'  PERFORM B300-CHANGE-PWD
              WHEN 'AUTHZ'  PERFORM B500-AUTHORIZE
              WHEN OTHER    MOVE 'Invalid security operation' TO LK-MSG
           END-EVALUATE
           GOBACK.
      *----------------------------------------------------------------*
      * AUTHENTICATE                                                    *
      *----------------------------------------------------------------*
       B100-AUTHENTICATE.
           MOVE LK-USER TO HV-USER
           EXEC SQL
                SELECT USR_PWD, USR_SALT, USR_ROLE, USR_FAIL, REC_STS
                  INTO :HV-PWD, :HV-SALT, :HV-ROLE, :HV-FAIL, :HV-STS
                  FROM TEHMSDTA/SMPUSER
                 WHERE USR_ID = :HV-USER
           END-EXEC
           IF SQLCODE = 100
              MOVE 'Invalid user id or password' TO LK-MSG
              GO TO B100-EXIT
           END-IF
           IF SQLCODE NOT = 0
              MOVE 'Security file read error' TO LK-MSG
              GO TO B100-EXIT
           END-IF
           MOVE HV-ROLE TO LK-ROLE
           IF HV-STS = 'I'
              MOVE 'User locked - contact administrator' TO LK-MSG
              GO TO B100-EXIT
           END-IF
           IF HV-PWD = SPACES
              PERFORM B200-BOOTSTRAP
              GO TO B100-EXIT
           END-IF
           MOVE HV-SALT TO HV-SALT
           PERFORM HASH-PASSWORD
           IF WS-CALC-HASH = HV-PWD
              EXEC SQL
                   UPDATE TEHMSDTA/SMPUSER
                      SET USR_FAIL = 0,
                          USR_LASTL = CURRENT TIMESTAMP,
                          UPD_USR  = :HV-USER
                    WHERE USR_ID = :HV-USER
              END-EXEC
              MOVE '0' TO LK-RESULT
              MOVE 'Sign-on successful' TO LK-MSG
           ELSE
              ADD 1 TO HV-FAIL
              IF HV-FAIL >= WS-MAX-FAIL
                 EXEC SQL
                      UPDATE TEHMSDTA/SMPUSER
                         SET USR_FAIL = :HV-FAIL, REC_STS = 'I'
                       WHERE USR_ID = :HV-USER
                 END-EXEC
                 MOVE 'Invalid password - user now locked' TO LK-MSG
              ELSE
                 EXEC SQL
                      UPDATE TEHMSDTA/SMPUSER
                         SET USR_FAIL = :HV-FAIL
                       WHERE USR_ID = :HV-USER
                 END-EXEC
                 MOVE 'Invalid password - try again' TO LK-MSG
              END-IF
           END-IF.
       B100-EXIT.
           EXIT.
      *----------------------------------------------------------------*
      * FIRST SIGN-ON : store typed password as the new password       *
      *----------------------------------------------------------------*
       B200-BOOTSTRAP.
           PERFORM GEN-SALT
           MOVE WS-NEWSALT TO HV-SALT
           PERFORM HASH-PASSWORD
           EXEC SQL
                UPDATE TEHMSDTA/SMPUSER
                   SET USR_PWD  = :WS-CALC-HASH,
                       USR_SALT = :HV-SALT,
                       USR_FAIL = 0,
                       USR_LASTL = CURRENT TIMESTAMP,
                       UPD_USR  = :HV-USER
                 WHERE USR_ID = :HV-USER
           END-EXEC
           IF SQLCODE = 0
              MOVE '0' TO LK-RESULT
              MOVE 'Password set on first sign-on' TO LK-MSG
           ELSE
              MOVE 'Unable to set initial password' TO LK-MSG
           END-IF.
      *----------------------------------------------------------------*
      * CHANGE PASSWORD                                                 *
      *----------------------------------------------------------------*
       B300-CHANGE-PWD.
           MOVE LK-USER TO HV-USER
           PERFORM GEN-SALT
           MOVE WS-NEWSALT TO HV-SALT
           PERFORM HASH-PASSWORD
           EXEC SQL
                UPDATE TEHMSDTA/SMPUSER
                   SET USR_PWD  = :WS-CALC-HASH,
                       USR_SALT = :HV-SALT,
                       UPD_USR  = :HV-USER
                 WHERE USR_ID = :HV-USER
           END-EXEC
           IF SQLCODE = 0
              MOVE '0' TO LK-RESULT
              MOVE 'Password changed' TO LK-MSG
           ELSE
              MOVE 'Password change failed' TO LK-MSG
           END-IF.
      *----------------------------------------------------------------*
      * ROLE AUTHORITY CHECK                                            *
      *----------------------------------------------------------------*
       B500-AUTHORIZE.
           EVALUATE LK-ROLE
              WHEN 'ADMIN'
                 MOVE '0' TO LK-RESULT
              WHEN 'MANAGER'
                 IF LK-MODULE = 'SM' OR LK-MODULE = 'AD'
                    MOVE 'Not authorised to administration' TO LK-MSG
                 ELSE
                    MOVE '0' TO LK-RESULT
                 END-IF
              WHEN 'FRONTDESK'
                 IF LK-MODULE = 'RS' OR LK-MODULE = 'GM'
                 OR LK-MODULE = 'RM' OR LK-MODULE = 'BL'
                    MOVE '0' TO LK-RESULT
                 ELSE
                    MOVE 'Not authorised to this module' TO LK-MSG
                 END-IF
              WHEN OTHER
                 MOVE 'Unknown role' TO LK-MSG
           END-EVALUATE
           IF LK-RESULT = '0'
              MOVE 'Authorised' TO LK-MSG
           END-IF.
      *----------------------------------------------------------------*
      * PASSWORD HASH (demo-grade deterministic fold -> 64 hex)         *
      *----------------------------------------------------------------*
       HASH-PASSWORD.
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 32
              MOVE 7 TO WS-ACC (WS-I)
           END-PERFORM
           MOVE SPACES TO WS-INPUT
           STRING HV-SALT DELIMITED BY SIZE
                  LK-PWD  DELIMITED BY SIZE
                  INTO WS-INPUT
           END-STRING
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
              MOVE FUNCTION ORD (WS-INPUT (WS-I:1)) TO WS-ORD
              COMPUTE WS-IDX = FUNCTION MOD (WS-I - 1, 32) + 1
              COMPUTE WS-ACC (WS-IDX) =
                 FUNCTION MOD
                   ((WS-ACC (WS-IDX) * 31) + WS-ORD + WS-I, 256)
           END-PERFORM
           MOVE SPACES TO WS-CALC-HASH
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 32
              COMPUTE WS-HI = FUNCTION INTEGER (WS-ACC (WS-I) / 16)
              COMPUTE WS-LO = FUNCTION MOD (WS-ACC (WS-I), 16)
              MOVE WS-HEXTAB (WS-HI + 1:1)
                   TO WS-CALC-HASH ((WS-I * 2) - 1:1)
              MOVE WS-HEXTAB (WS-LO + 1:1)
                   TO WS-CALC-HASH (WS-I * 2:1)
           END-PERFORM.
      *----------------------------------------------------------------*
      * GENERATE A 16-CHAR SALT FROM DATE/TIME                          *
      *----------------------------------------------------------------*
       GEN-SALT.
           ACCEPT WS-D FROM DATE YYYYMMDD
           ACCEPT WS-T FROM TIME
           MOVE SPACES TO WS-NEWSALT
           STRING WS-D DELIMITED BY SIZE
                  WS-T DELIMITED BY SIZE
                  INTO WS-NEWSALT
           END-STRING.
      *================================================================*
      * END OF CMSSEC                                                  *
      *================================================================*
