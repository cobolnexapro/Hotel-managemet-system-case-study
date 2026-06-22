      *================================================================*
      * PROGRAM  : RPBREV          PRINTER FILE : RPRREV             *
      * MODULE   : Reports (RP)                                        *
      * LAYER    : Batch                                              *
      * PURPOSE  : Revenue summary across all invoices - count, sub    *
      *            total, GST, grand total, collected and outstanding.  *
      * RUN      : SBMJOB CMD(CALL TEHMSPGM/RPBREV) JOB(REVRPT)        *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPBREV.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PRT-RV ASSIGN TO FORMATFILE-RPRREV
                  ORGANIZATION IS SEQUENTIAL
                  FILE STATUS IS WS-PRT-STS.
       DATA DIVISION.
       FILE SECTION.
       FD  PRT-RV.
       01  PRT-REC.
           COPY DDS-ALL-FORMATS OF RPRREV.
       WORKING-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  WS-PRT-STS          PIC X(02) VALUE '00'.
       01  HV.
           05  HV-DATE         PIC X(10).
           05  HV-CNT          PIC S9(9) COMP-4.
           05  HV-SUBT         PIC S9(13)V99 COMP-3.
           05  HV-GST          PIC S9(13)V99 COMP-3.
           05  HV-TOT          PIC S9(13)V99 COMP-3.
           05  HV-PAID         PIC S9(13)V99 COMP-3.
           05  HV-OUT          PIC S9(13)V99 COMP-3.
       PROCEDURE DIVISION.
       A000-MAIN.
           OPEN OUTPUT PRT-RV
           EXEC SQL
                SELECT CHAR(CURRENT DATE, ISO),
                       COUNT(*),
                       COALESCE(SUM(INV_SUBT),0),
                       COALESCE(SUM(INV_GST),0),
                       COALESCE(SUM(INV_TOTAL),0),
                       COALESCE(SUM(INV_PAID),0),
                       COALESCE(SUM(INV_TOTAL - INV_PAID),0)
                  INTO :HV-DATE, :HV-CNT, :HV-SUBT, :HV-GST,
                       :HV-TOT, :HV-PAID, :HV-OUT
                  FROM TEHMSDTA/BLPINVHD
           END-EXEC
           MOVE HV-DATE TO PDATE OF RBODY
           MOVE HV-CNT  TO PCNT OF RBODY
           MOVE HV-SUBT TO PSUBT OF RBODY
           MOVE HV-GST  TO PGST OF RBODY
           MOVE HV-TOT  TO PTOT OF RBODY
           MOVE HV-PAID TO PPAID OF RBODY
           MOVE HV-OUT  TO POUT OF RBODY
           WRITE PRT-REC FORMAT IS 'RBODY'
           CLOSE PRT-RV
           STOP RUN.
      *================================================================*
      * END OF RPBREV                                                  *
      *================================================================*
