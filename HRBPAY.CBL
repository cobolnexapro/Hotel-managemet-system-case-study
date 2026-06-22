      *================================================================*
      * PROGRAM  : HRBPAY          PRINTER FILE : HRRPAY              *
      * MODULE   : Human Resources (HR) / Payroll                      *
      * LAYER    : Batch                                              *
      * PURPOSE  : Compute monthly pay (basic + HRA - deductions) for  *
      *            every active employee, record it in HRPPAY and       *
      *            print the payroll register.                          *
      * RUN      : SBMJOB CMD(CALL TEHMSPGM/HRBPAY) JOB(PAYROLL)       *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. HRBPAY.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PRT-PAY ASSIGN TO FORMATFILE-HRRPAY
                  ORGANIZATION IS SEQUENTIAL
                  FILE STATUS IS WS-PRT-STS.
       DATA DIVISION.
       FILE SECTION.
       FD  PRT-PAY.
       01  PRT-REC.
           COPY DDS-ALL-FORMATS OF HRRPAY.
       WORKING-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  WS-PRT-STS          PIC X(02) VALUE '00'.
       01  WS-T-NET            PIC S9(13)V99 COMP-3 VALUE 0.
       01  HV.
           05  HV-PER          PIC X(7).
           05  HV-EID          PIC S9(9) COMP-4.
           05  HV-NAME         PIC X(40).
           05  HV-DPT          PIC X(6).
           05  HV-BASIC        PIC S9(11)V99 COMP-3.
           05  HV-HRA          PIC S9(11)V99 COMP-3.
           05  HV-DED          PIC S9(11)V99 COMP-3.
           05  HV-NET          PIC S9(11)V99 COMP-3.
       PROCEDURE DIVISION.
       A000-MAIN.
           OPEN OUTPUT PRT-PAY
           EXEC SQL
                SELECT SUBSTR(CHAR(CURRENT DATE, ISO),1,7)
                  INTO :HV-PER FROM SYSIBM.SYSDUMMY1
           END-EXEC
           MOVE HV-PER TO PPER OF RHEAD
           WRITE PRT-REC FORMAT IS 'RHEAD'
           EXEC SQL
                DECLARE CE CURSOR FOR
                SELECT EMP_ID, EMP_NAME, DPT_CODE,
                       EMP_BASIC, EMP_HRA, EMP_DED
                  FROM TEHMSDTA/HRPEMP
                 WHERE REC_STS = 'A' ORDER BY EMP_ID
           END-EXEC
           EXEC SQL OPEN CE END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL
                   FETCH CE INTO :HV-EID, :HV-NAME, :HV-DPT,
                                 :HV-BASIC, :HV-HRA, :HV-DED
              END-EXEC
              IF SQLCODE = 0
                 COMPUTE HV-NET = HV-BASIC + HV-HRA - HV-DED
                 EXEC SQL
                      INSERT INTO TEHMSDTA/HRPPAY
                         (EMP_ID, PAY_PERIOD, PAY_BASIC, PAY_HRA,
                          PAY_DED, PAY_NET, CRT_USR)
                      VALUES (:HV-EID, :HV-PER, :HV-BASIC, :HV-HRA,
                          :HV-DED, :HV-NET, 'PAYROLL')
                 END-EXEC
                 MOVE HV-EID   TO DEID OF RDETL
                 MOVE HV-NAME  TO DNAME OF RDETL
                 MOVE HV-DPT   TO DDPT OF RDETL
                 MOVE HV-BASIC TO DBASIC OF RDETL
                 MOVE HV-HRA   TO DHRA OF RDETL
                 MOVE HV-NET   TO DNET OF RDETL
                 WRITE PRT-REC FORMAT IS 'RDETL'
                 ADD HV-NET TO WS-T-NET
              END-IF
           END-PERFORM
           EXEC SQL CLOSE CE END-EXEC
           MOVE WS-T-NET TO TNET OF RTOT
           WRITE PRT-REC FORMAT IS 'RTOT'
           CLOSE PRT-PAY
           STOP RUN.
      *================================================================*
      * END OF HRBPAY                                                  *
      *================================================================*
