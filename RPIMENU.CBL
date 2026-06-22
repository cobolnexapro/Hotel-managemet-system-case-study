      *================================================================*
      * PROGRAM  : RPIMENU         DISPLAY FILE : RPDMENU              *
      * MODULE   : Reports (RP)                                        *
      * LAYER    : Presentation                                        *
      * PURPOSE  : Reports sub-menu. Runs each report (a batch program  *
      *            that produces a spooled file) on request.            *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPIMENU.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT DSP-RP ASSIGN TO WORKSTATION-RPDMENU-SI
                  ORGANIZATION IS TRANSACTION
                  ACCESS IS SEQUENTIAL
                  FILE STATUS IS WS-DSP-STS.
       DATA DIVISION.
       FILE SECTION.
       FD  DSP-RP.
       01  RP-REC.
           COPY DDS-ALL-FORMATS OF RPDMENU.
       WORKING-STORAGE SECTION.
       01  WS-DSP-STS          PIC X(02) VALUE '00'.
       01  WS-IND              PIC X(99) VALUE ALL '0'.
       01  WS-EXIT-SW          PIC X(01) VALUE 'N'.
           88  WS-EXIT                 VALUE 'Y'.
       LINKAGE SECTION.
           COPY CMXSECDS.
       PROCEDURE DIVISION USING SESSION-DATA.
       A000-MAIN.
           OPEN I-O DSP-RP
           PERFORM UNTIL WS-EXIT
              PERFORM A100-SHOW
           END-PERFORM
           CLOSE DSP-RP
           GOBACK.
      *----------------------------------------------------------------*
       A100-SHOW.
           MOVE SES-USER-NAME TO WUSER OF RPTMENU
           MOVE SPACES TO OPTION OF RPTMENU
           MOVE ALL '0' TO WS-IND
           WRITE RP-REC FORMAT IS 'RPTMENU' INDICATORS ARE WS-IND
           READ DSP-RP INDICATORS ARE WS-IND
           IF WS-IND(3:1) = '1'
              SET WS-EXIT TO TRUE
              GO TO A100-EXIT
           END-IF
           MOVE SPACES TO MSGLIN OF RPTMENU
           EVALUATE OPTION OF RPTMENU
              WHEN '1'  CALL 'RPBOCCUP'
                        MOVE 'Occupancy & revenue report spooled'
                          TO MSGLIN OF RPTMENU
              WHEN '2'  CALL 'RPBREV'
                        MOVE 'Revenue summary spooled'
                          TO MSGLIN OF RPTMENU
              WHEN '3'  CALL 'RPBSTOCK'
                        MOVE 'Inventory valuation spooled'
                          TO MSGLIN OF RPTMENU
              WHEN '4'  CALL 'FNBTRIAL'
                        MOVE 'Trial balance spooled'
                          TO MSGLIN OF RPTMENU
              WHEN '5'  CALL 'HRBPAY'
                        MOVE 'Payroll register spooled'
                          TO MSGLIN OF RPTMENU
              WHEN '90' SET WS-EXIT TO TRUE
              WHEN OTHER
                        MOVE 'Invalid option' TO MSGLIN OF RPTMENU
           END-EVALUATE.
       A100-EXIT.
           EXIT.
      *================================================================*
      * END OF RPIMENU                                                 *
      *================================================================*
