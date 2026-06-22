      *================================================================*
      * MODULE   : CMSBILL         SERVICE PGM : CMSBILL               *
      * LAYER    : Business / Billing                                  *
      * PURPOSE  : Recalculate an invoice header from its detail lines:*
      *            subtotal, line-wise GST, discount and grand total,  *
      *            then set INV_STS (O=open / S=settled).              *
      * CALL     : CALL 'CMSBILL' USING LK-INVID LK-RESULT LK-MSG.     *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CMSBILL.
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
           05  HV-INVID        PIC S9(9) COMP-4.
           05  HV-SUBT         PIC S9(11)V99 COMP-3.
           05  HV-GST          PIC S9(11)V99 COMP-3.
           05  HV-DISC         PIC S9(11)V99 COMP-3.
           05  HV-TOTAL        PIC S9(11)V99 COMP-3.
           05  HV-PAID         PIC S9(11)V99 COMP-3.
           05  HV-STS          PIC X(01).
      *----------------------------------------------------------------*
       LINKAGE SECTION.
       01  LK-INVID            PIC S9(9) COMP-4.
       01  LK-RESULT           PIC X(01).
       01  LK-MSG              PIC X(78).
      *----------------------------------------------------------------*
       PROCEDURE DIVISION USING LK-INVID LK-RESULT LK-MSG.
       A000-MAIN.
           MOVE '1'    TO LK-RESULT
           MOVE SPACES TO LK-MSG
           MOVE LK-INVID TO HV-INVID
      *    Sum detail lines : amount and line-wise GST.
           EXEC SQL
                SELECT COALESCE(SUM(DTL_AMT),0),
                       COALESCE(SUM(DTL_AMT * DTL_GSTP / 100),0)
                  INTO :HV-SUBT, :HV-GST
                  FROM TEHMSDTA/BLPINVDT
                 WHERE INV_ID = :HV-INVID
           END-EXEC
           IF SQLCODE NOT = 0
              MOVE 'Error reading invoice detail' TO LK-MSG
              GO TO A000-EXIT
           END-IF
      *    Read current discount and paid amount from header.
           EXEC SQL
                SELECT INV_DISC, INV_PAID
                  INTO :HV-DISC, :HV-PAID
                  FROM TEHMSDTA/BLPINVHD
                 WHERE INV_ID = :HV-INVID
           END-EXEC
           IF SQLCODE NOT = 0
              MOVE 'Invoice header not found' TO LK-MSG
              GO TO A000-EXIT
           END-IF
           COMPUTE HV-TOTAL = HV-SUBT - HV-DISC + HV-GST
           IF HV-PAID >= HV-TOTAL AND HV-TOTAL > 0
              MOVE 'S' TO HV-STS
           ELSE
              MOVE 'O' TO HV-STS
           END-IF
           EXEC SQL
                UPDATE TEHMSDTA/BLPINVHD
                   SET INV_SUBT  = :HV-SUBT,
                       INV_GST   = :HV-GST,
                       INV_TOTAL = :HV-TOTAL,
                       INV_STS   = :HV-STS
                 WHERE INV_ID = :HV-INVID
           END-EXEC
           IF SQLCODE = 0
              MOVE '0' TO LK-RESULT
              MOVE 'Invoice recalculated' TO LK-MSG
           ELSE
              MOVE 'Unable to update invoice header' TO LK-MSG
           END-IF.
       A000-EXIT.
           GOBACK.
      *================================================================*
      * END OF CMSBILL                                                 *
      *================================================================*
