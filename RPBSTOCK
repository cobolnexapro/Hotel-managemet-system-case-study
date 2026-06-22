      *================================================================*
      * PROGRAM  : RPBSTOCK        PRINTER FILE : RPRSTOCK           *
      * MODULE   : Reports (RP) / Inventory                            *
      * LAYER    : Batch                                              *
      * PURPOSE  : Inventory valuation - on-hand x rate per item, a     *
      *            reorder flag when on-hand <= reorder level, and the   *
      *            total stock value.                                    *
      * RUN      : SBMJOB CMD(CALL TEHMSPGM/RPBSTOCK) JOB(STOCKRPT)    *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPBSTOCK.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PRT-ST ASSIGN TO FORMATFILE-RPRSTOCK
                  ORGANIZATION IS SEQUENTIAL
                  FILE STATUS IS WS-PRT-STS.
       DATA DIVISION.
       FILE SECTION.
       FD  PRT-ST.
       01  PRT-REC.
           COPY DDS-ALL-FORMATS OF RPRSTOCK.
       WORKING-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  WS-PRT-STS          PIC X(02) VALUE '00'.
       01  WS-T-VAL            PIC S9(13)V99 COMP-3 VALUE 0.
       01  WS-VAL              PIC S9(13)V99 COMP-3.
       01  HV.
           05  HV-DATE         PIC X(10).
           05  HV-ITEM         PIC X(10).
           05  HV-DESC         PIC X(40).
           05  HV-QOH          PIC S9(8)V999 COMP-3.
           05  HV-RATE         PIC S9(9)V99  COMP-3.
           05  HV-REORD        PIC S9(8)V999 COMP-3.
       PROCEDURE DIVISION.
       A000-MAIN.
           OPEN OUTPUT PRT-ST
           EXEC SQL
                SELECT CHAR(CURRENT DATE, ISO) INTO :HV-DATE
                  FROM SYSIBM.SYSDUMMY1
           END-EXEC
           MOVE HV-DATE TO PDATE OF RHEAD
           WRITE PRT-REC FORMAT IS 'RHEAD'
           EXEC SQL
                DECLARE CS CURSOR FOR
                SELECT ITM_CODE, ITM_DESC, ITM_QOH, ITM_RATE, ITM_REORD
                  FROM TEHMSDTA/IVPITEM
                 WHERE REC_STS = 'A' ORDER BY ITM_CODE
           END-EXEC
           EXEC SQL OPEN CS END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL
                   FETCH CS INTO :HV-ITEM, :HV-DESC, :HV-QOH,
                                 :HV-RATE, :HV-REORD
              END-EXEC
              IF SQLCODE = 0
                 COMPUTE WS-VAL = HV-QOH * HV-RATE
                 MOVE HV-ITEM TO DITEM OF RDETL
                 MOVE HV-DESC TO DDESC OF RDETL
                 MOVE HV-QOH  TO DQOH OF RDETL
                 MOVE HV-RATE TO DRATE OF RDETL
                 MOVE WS-VAL  TO DVAL OF RDETL
                 IF HV-QOH <= HV-REORD
                    MOVE '<<' TO DRO OF RDETL
                 ELSE
                    MOVE SPACES TO DRO OF RDETL
                 END-IF
                 WRITE PRT-REC FORMAT IS 'RDETL'
                 ADD WS-VAL TO WS-T-VAL
              END-IF
           END-PERFORM
           EXEC SQL CLOSE CS END-EXEC
           MOVE WS-T-VAL TO TVAL OF RTOT
           WRITE PRT-REC FORMAT IS 'RTOT'
           CLOSE PRT-ST
           STOP RUN.
      *================================================================*
      * END OF RPBSTOCK                                                *
      *================================================================*
