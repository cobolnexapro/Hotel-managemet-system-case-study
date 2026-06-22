      *================================================================*
      * PROGRAM  : CMMMAIN         DISPLAY FILE : CMDMAIN              *
      * MODULE   : Common (CM)                                         *
      * LAYER    : Presentation                                        *
      * PURPOSE  : Main menu. Receives the session descriptor, checks  *
      *            module authority via CMSSEC 'AUTHZ', and routes to  *
      *            the selected module program. Option 90 / F3 returns *
      *            to the sign-on program.                             *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CMMMAIN.
       AUTHOR. TEHMS-ARCHITECT.
      *----------------------------------------------------------------*
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT DSP-MENU ASSIGN TO WORKSTATION-CMDMAIN-SI
                  ORGANIZATION IS TRANSACTION
                  ACCESS IS SEQUENTIAL
                  FILE STATUS IS WS-DSP-STS.
      *----------------------------------------------------------------*
       DATA DIVISION.
       FILE SECTION.
       FD  DSP-MENU.
       01  MENU-REC.
           COPY DDS-ALL-FORMATS OF CMDMAIN.
      *----------------------------------------------------------------*
       WORKING-STORAGE SECTION.
       01  WS-DSP-STS          PIC X(02) VALUE '00'.
       01  WS-IND              PIC X(99) VALUE ALL '0'.
       01  WS-EXIT-SW          PIC X(01) VALUE 'N'.
           88  WS-EXIT                 VALUE 'Y'.
       01  WS-NAME-ROLE        PIC X(40).
      *--- authority call ---
       01  SEC-OP              PIC X(05) VALUE 'AUTHZ'.
       01  SEC-USER            PIC X(10).
       01  SEC-PWD             PIC X(20) VALUE SPACES.
       01  SEC-MODULE          PIC X(02).
       01  SEC-ROLE            PIC X(10).
       01  SEC-RESULT          PIC X(01).
       01  SEC-MSG             PIC X(78).
      *----------------------------------------------------------------*
       LINKAGE SECTION.
           COPY CMXSECDS.
      *----------------------------------------------------------------*
       PROCEDURE DIVISION USING SESSION-DATA.
       A000-MAIN.
           OPEN I-O DSP-MENU
           MOVE SES-USER-ID   TO SEC-USER
           MOVE SES-USER-ROLE TO SEC-ROLE
           PERFORM UNTIL WS-EXIT
              PERFORM A100-SHOW-MENU
           END-PERFORM
           CLOSE DSP-MENU
           GOBACK.
      *----------------------------------------------------------------*
       A100-SHOW-MENU.
           STRING SES-USER-NAME DELIMITED BY '  '
                  ' ('  DELIMITED BY SIZE
                  SES-USER-ROLE DELIMITED BY '  '
                  ')'   DELIMITED BY SIZE
                  INTO WS-NAME-ROLE
           END-STRING
           MOVE WS-NAME-ROLE TO WUSER OF MAINMENU
           MOVE SPACES TO OPTION OF MAINMENU
           MOVE ALL '0' TO WS-IND
           WRITE MENU-REC FORMAT IS 'MAINMENU'
                 INDICATORS ARE WS-IND
           READ DSP-MENU INDICATORS ARE WS-IND
           IF WS-IND(3:1) = '1'
              SET WS-EXIT TO TRUE
              GO TO A100-EXIT
           END-IF
           PERFORM A200-ROUTE.
       A100-EXIT.
           EXIT.
      *----------------------------------------------------------------*
       A200-ROUTE.
           MOVE SPACES TO MSGLIN OF MAINMENU
           EVALUATE OPTION OF MAINMENU
              WHEN '1'  PERFORM A300-RESERVATION
              WHEN '4'  PERFORM A400-BILLING
              WHEN '90' SET WS-EXIT TO TRUE
              WHEN '2'
              WHEN '3'
              WHEN '5'
              WHEN '6'
              WHEN '7'
                 MOVE 'Module available in full build - pattern as 1/4'
                   TO MSGLIN OF MAINMENU
              WHEN OTHER
                 MOVE 'Invalid option' TO MSGLIN OF MAINMENU
           END-EVALUATE.
      *----------------------------------------------------------------*
       A300-RESERVATION.
           MOVE 'RS' TO SEC-MODULE
           PERFORM A900-CHECK-AUTH
           IF SEC-RESULT = '0'
              CALL 'RSIRESV' USING SESSION-DATA
           ELSE
              MOVE SEC-MSG TO MSGLIN OF MAINMENU
           END-IF.
      *----------------------------------------------------------------*
       A400-BILLING.
           MOVE 'BL' TO SEC-MODULE
           PERFORM A900-CHECK-AUTH
           IF SEC-RESULT = '0'
              CALL 'BLIBILL' USING SESSION-DATA
           ELSE
              MOVE SEC-MSG TO MSGLIN OF MAINMENU
           END-IF.
      *----------------------------------------------------------------*
       A900-CHECK-AUTH.
           CALL 'CMSSEC' USING SEC-OP SEC-USER SEC-PWD
                               SEC-MODULE SEC-ROLE
                               SEC-RESULT SEC-MSG.
      *================================================================*
      * END OF CMMMAIN                                                 *
      *================================================================*
