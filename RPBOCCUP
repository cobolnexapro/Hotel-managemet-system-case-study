      *================================================================*
      * PROGRAM  : RPBOCCUP        PRINTER FILE : RPROCCUP            *
      * MODULE   : Reports (RP)                                        *
      * LAYER    : Batch                                              *
      * PURPOSE  : Occupancy and revenue summary by room category.    *
      *            Read-only; run from CL / Job Scheduler:             *
      *            SBMJOB CMD(CALL TEHMSPGM/RPBOCCUP) JOB(OCCRPT)      *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPBOCCUP.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PRT-OCC ASSIGN TO FORMATFILE-RPROCCUP
                  ORGANIZATION IS SEQUENTIAL
                  FILE STATUS IS WS-PRT-STS.
       DATA DIVISION.
       FILE SECTION.
       FD  PRT-OCC.
       01  PRT-REC.
           COPY DDS-ALL-FORMATS OF RPROCCUP.
       WORKING-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  WS-PRT-STS          PIC X(02) VALUE '00'.
       01  WS-TOT.
           05  WS-T-ROOMS      PIC S9(7) COMP-4 VALUE 0.
           05  WS-T-OCC        PIC S9(7) COMP-4 VALUE 0.
           05  WS-T-VAC        PIC S9(7) COMP-4 VALUE 0.
           05  WS-T-REV        PIC S9(13)V99 COMP-3 VALUE 0.
       01  HV.
           05  HV-DATE         PIC X(10).
           05  HV-CAT          PIC X(6).
           05  HV-DESC         PIC X(30).
           05  HV-ROOMS        PIC S9(7) COMP-4.
           05  HV-OCC          PIC S9(7) COMP-4.
           05  HV-VAC          PIC S9(7) COMP-4.
           05  HV-REV          PIC S9(13)V99 COMP-3.
       PROCEDURE DIVISION.
       A000-MAIN.
           OPEN OUTPUT PRT-OCC
           EXEC SQL
                SELECT CHAR(CURRENT DATE, ISO) INTO :HV-DATE
                  FROM SYSIBM.SYSDUMMY1
           END-EXEC
           MOVE HV-DATE TO PDATE OF RHEAD
           WRITE PRT-REC FORMAT IS 'RHEAD'
           EXEC SQL
                DECLARE CP CURSOR FOR
                SELECT C.CAT_CODE, C.CAT_DESC,
                  (SELECT COUNT(*) FROM TEHMSDTA/RMPROOM R
                     WHERE R.CAT_CODE = C.CAT_CODE AND R.REC_STS='A'),
                  (SELECT COUNT(*) FROM TEHMSDTA/RMPROOM R
                     WHERE R.CAT_CODE = C.CAT_CODE AND R.RM_STS='O'),
                  (SELECT COUNT(*) FROM TEHMSDTA/RMPROOM R
                     WHERE R.CAT_CODE = C.CAT_CODE AND R.RM_STS='V'),
                  (SELECT COALESCE(SUM(H.INV_TOTAL),0)
                     FROM TEHMSDTA/BLPINVHD H
                     JOIN TEHMSDTA/RSPRESV S ON H.RES_ID = S.RES_ID
                     WHERE S.CAT_CODE = C.CAT_CODE)
                  FROM TEHMSDTA/RMPCAT C
                 WHERE C.REC_STS = 'A'
                 ORDER BY C.CAT_CODE
           END-EXEC
           EXEC SQL OPEN CP END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL
                   FETCH CP INTO :HV-CAT, :HV-DESC, :HV-ROOMS,
                                 :HV-OCC, :HV-VAC, :HV-REV
              END-EXEC
              IF SQLCODE = 0
                 MOVE HV-CAT   TO DCAT OF RDETL
                 MOVE HV-DESC  TO DDESC OF RDETL
                 MOVE HV-ROOMS TO DTOT OF RDETL
                 MOVE HV-OCC   TO DOCC OF RDETL
                 MOVE HV-VAC   TO DVAC OF RDETL
                 MOVE HV-REV   TO DREV OF RDETL
                 WRITE PRT-REC FORMAT IS 'RDETL'
                 ADD HV-ROOMS TO WS-T-ROOMS
                 ADD HV-OCC   TO WS-T-OCC
                 ADD HV-VAC   TO WS-T-VAC
                 ADD HV-REV   TO WS-T-REV
              END-IF
           END-PERFORM
           EXEC SQL CLOSE CP END-EXEC
           MOVE WS-T-ROOMS TO TTOT OF RTOT
           MOVE WS-T-OCC   TO TOCC OF RTOT
           MOVE WS-T-VAC   TO TVAC OF RTOT
           MOVE WS-T-REV   TO TREV OF RTOT
           WRITE PRT-REC FORMAT IS 'RTOT'
           CLOSE PRT-OCC
           STOP RUN.
      *================================================================*
      * END OF RPBOCCUP                                                *
      *================================================================*
