      *================================================================*
      * MODULE   : CMSERROR        SERVICE PGM : CMSERROR              *
      * LAYER    : Common / Utility                                    *
      * PURPOSE  : Write a uniform audit / error record to SMPAUDIT.   *
      *            Every program calls this for both successful audit  *
      *            actions and trapped errors.                         *
      * CALL     : CALL 'CMSERROR' USING LK-USER LK-PGM LK-ACTN        *
      *                                  LK-KEY  LK-TEXT.              *
      * NOTE     : Audit insert participates in the caller commit      *
      *            scope. For tamper-proof logging in production,       *
      *            route through a separate isolated activation group.  *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CMSERROR.
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
       01  WS-HV.
           05  HV-USER         PIC X(10).
           05  HV-PGM          PIC X(10).
           05  HV-ACTN         PIC X(10).
           05  HV-KEY          PIC X(30).
           05  HV-TEXT         PIC X(100).
      *----------------------------------------------------------------*
       LINKAGE SECTION.
       01  LK-USER             PIC X(10).
       01  LK-PGM              PIC X(10).
       01  LK-ACTN             PIC X(10).
       01  LK-KEY              PIC X(30).
       01  LK-TEXT             PIC X(100).
      *----------------------------------------------------------------*
       PROCEDURE DIVISION USING LK-USER LK-PGM LK-ACTN
                                LK-KEY  LK-TEXT.
       A000-MAIN.
           MOVE LK-USER  TO HV-USER
           MOVE LK-PGM   TO HV-PGM
           MOVE LK-ACTN  TO HV-ACTN
           MOVE LK-KEY   TO HV-KEY
           MOVE LK-TEXT  TO HV-TEXT
           EXEC SQL
                INSERT INTO TEHMSDTA/SMPAUDIT
                       (AUD_USR, AUD_PGM, AUD_ACTN, AUD_KEY, AUD_TEXT)
                VALUES (:HV-USER, :HV-PGM, :HV-ACTN,
                        :HV-KEY,  :HV-TEXT)
           END-EXEC
      *    A failed audit insert must never abort the caller.
           IF SQLCODE NOT = 0
              CONTINUE
           END-IF
           GOBACK.
      *================================================================*
      * END OF CMSERROR                                                *
      *================================================================*
