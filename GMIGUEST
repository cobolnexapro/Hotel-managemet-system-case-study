      *================================================================*
      * PROGRAM  : GMIGUEST        DISPLAY FILE : GMDGUEST             *
      * MODULE   : Guest Management (GM)                               *
      * LAYER    : Presentation                                        *
      * PURPOSE  : List / filter guest profiles, add new guests, and   *
      *            edit existing ones.                                  *
      * FKEYS    : F3 Exit  F5 Refresh  F6 Add  F12 Cancel             *
      * SUBFILE  : SEL  S=Edit                                         *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. GMIGUEST.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT DSP-GST ASSIGN TO WORKSTATION-GMDGUEST-SI
                  ORGANIZATION IS TRANSACTION
                  ACCESS IS DYNAMIC
                  RELATIVE KEY IS WS-RRN
                  FILE STATUS IS WS-DSP-STS.
       DATA DIVISION.
       FILE SECTION.
       FD  DSP-GST.
       01  GST-REC.
           COPY DDS-ALL-FORMATS OF GMDGUEST.
       WORKING-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  WS-DSP-STS          PIC X(02) VALUE '00'.
       01  WS-IND              PIC X(99) VALUE ALL '0'.
       01  WS-RRN              PIC S9(4) COMP-4 VALUE 0.
       01  WS-EXIT-SW          PIC X(01) VALUE 'N'.
           88  WS-EXIT                 VALUE 'Y'.
       01  WS-EOF-SW           PIC X(01) VALUE 'N'.
           88  WS-EOF                  VALUE 'Y'.
       01  WS-COUNT            PIC S9(4) COMP-4 VALUE 0.
       01  WS-MODE             PIC X(01) VALUE 'A'.
       01  WS-MSG              PIC X(78).
       01  HV.
           05  HV-GID          PIC S9(9) COMP-4.
           05  HV-NAME         PIC X(40).
           05  HV-ADDR         PIC X(60).
           05  HV-CITY         PIC X(30).
           05  HV-NAT          PIC X(20).
           05  HV-PHONE        PIC X(15).
           05  HV-EMAIL        PIC X(40).
           05  HV-VIP          PIC X(1).
           05  HV-LIKE         PIC X(42).
       01  AUD-USER            PIC X(10).
       01  AUD-PGM             PIC X(10) VALUE 'GMIGUEST'.
       01  AUD-ACTN            PIC X(10).
       01  AUD-KEY             PIC X(30).
       01  AUD-TEXT            PIC X(100).
       LINKAGE SECTION.
           COPY CMXSECDS.
       PROCEDURE DIVISION USING SESSION-DATA.
       A000-MAIN.
           MOVE SES-USER-ID TO AUD-USER
           OPEN I-O DSP-GST
           MOVE '%' TO HV-LIKE
           PERFORM UNTIL WS-EXIT
              PERFORM B100-LOAD
              PERFORM B200-DISPLAY
           END-PERFORM
           CLOSE DSP-GST
           GOBACK.
      *----------------------------------------------------------------*
       B100-LOAD.
           MOVE ALL '0' TO WS-IND
           MOVE '1' TO WS-IND(53:1)
           WRITE GST-REC FORMAT IS 'GMCTL' INDICATORS ARE WS-IND
           MOVE '0' TO WS-IND(53:1)
           MOVE 0 TO WS-RRN
           MOVE 0 TO WS-COUNT
           EXEC SQL
                DECLARE CG CURSOR FOR
                SELECT GST_ID, GST_NAME, GST_CITY, GST_PHONE
                  FROM TEHMSDTA/GMPGUEST
                 WHERE REC_STS = 'A'
                   AND UPPER(GST_NAME) LIKE UPPER(:HV-LIKE)
                 ORDER BY GST_NAME
           END-EXEC
           EXEC SQL OPEN CG END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL
                   FETCH CG INTO :HV-GID, :HV-NAME, :HV-CITY, :HV-PHONE
              END-EXEC
              IF SQLCODE = 0
                 MOVE SPACES  TO SEL OF GMSFL
                 MOVE HV-GID  TO ZGID OF GMSFL
                 MOVE HV-NAME TO ZNAME OF GMSFL
                 MOVE HV-CITY TO ZCITY OF GMSFL
                 MOVE HV-PHONE TO ZPHONE OF GMSFL
                 ADD 1 TO WS-RRN
                 ADD 1 TO WS-COUNT
                 WRITE GST-REC FORMAT IS 'GMSFL' INDICATORS ARE WS-IND
              END-IF
           END-PERFORM
           EXEC SQL CLOSE CG END-EXEC
           IF WS-COUNT > 0
              MOVE '1' TO WS-IND(51:1)
              MOVE '1' TO WS-IND(54:1)
           END-IF
           MOVE '1' TO WS-IND(52:1).
      *----------------------------------------------------------------*
       B200-DISPLAY.
           MOVE WS-MSG TO MSGLIN OF GMCTL
           MOVE SPACES TO WS-MSG
           WRITE GST-REC FORMAT IS 'GMCTL' INDICATORS ARE WS-IND
           READ DSP-GST INDICATORS ARE WS-IND
           EVALUATE TRUE
              WHEN WS-IND(3:1) = '1'
                 SET WS-EXIT TO TRUE
              WHEN WS-IND(12:1) = '1'
                 SET WS-EXIT TO TRUE
              WHEN WS-IND(5:1) = '1'
                 MOVE FNAME OF GMCTL TO HV-LIKE
              WHEN WS-IND(6:1) = '1'
                 MOVE 'A' TO WS-MODE
                 PERFORM C100-EDIT
              WHEN OTHER
                 MOVE FNAME OF GMCTL TO HV-LIKE
                 PERFORM C300-PROCESS-SEL
           END-EVALUATE.
      *----------------------------------------------------------------*
       C100-EDIT.
           MOVE ALL '0' TO WS-IND
           IF WS-MODE = 'A'
              MOVE 0 TO HV-GID
              INITIALIZE HV-NAME HV-ADDR HV-CITY HV-PHONE HV-EMAIL
              MOVE 'INDIAN' TO HV-NAT
              MOVE 'N' TO HV-VIP
           END-IF
           MOVE HV-GID   TO DGID OF GMDETL
           MOVE HV-NAME  TO DNAME OF GMDETL
           MOVE HV-ADDR  TO DADDR OF GMDETL
           MOVE HV-CITY  TO DCITY OF GMDETL
           MOVE HV-NAT   TO DNAT OF GMDETL
           MOVE HV-PHONE TO DPHONE OF GMDETL
           MOVE HV-EMAIL TO DEMAIL OF GMDETL
           MOVE HV-VIP   TO DVIP OF GMDETL
           MOVE SPACES   TO DMSG OF GMDETL
           WRITE GST-REC FORMAT IS 'GMDETL' INDICATORS ARE WS-IND
           READ DSP-GST INDICATORS ARE WS-IND
           IF WS-IND(12:1) = '1'
              GO TO C100-EXIT
           END-IF
           MOVE DNAME OF GMDETL  TO HV-NAME
           MOVE DADDR OF GMDETL  TO HV-ADDR
           MOVE DCITY OF GMDETL  TO HV-CITY
           MOVE DNAT OF GMDETL   TO HV-NAT
           MOVE DPHONE OF GMDETL TO HV-PHONE
           MOVE DEMAIL OF GMDETL TO HV-EMAIL
           MOVE DVIP OF GMDETL   TO HV-VIP
           IF HV-NAME = SPACES
              MOVE 'Guest name is required' TO WS-MSG
              GO TO C100-EXIT
           END-IF
           IF WS-MODE = 'A'
              EXEC SQL
                   INSERT INTO TEHMSDTA/GMPGUEST
                      (GST_NAME, GST_ADDR, GST_CITY, GST_NATION,
                       GST_PHONE, GST_EMAIL, GST_VIP, CRT_USR)
                   VALUES (:HV-NAME, :HV-ADDR, :HV-CITY, :HV-NAT,
                       :HV-PHONE, :HV-EMAIL, :HV-VIP, :AUD-USER)
              END-EXEC
              MOVE 'ADDGUEST' TO AUD-ACTN
           ELSE
              EXEC SQL
                   UPDATE TEHMSDTA/GMPGUEST
                      SET GST_NAME = :HV-NAME, GST_ADDR = :HV-ADDR,
                          GST_CITY = :HV-CITY, GST_NATION = :HV-NAT,
                          GST_PHONE = :HV-PHONE, GST_EMAIL = :HV-EMAIL,
                          GST_VIP = :HV-VIP, UPD_USR = :AUD-USER
                    WHERE GST_ID = :HV-GID
              END-EXEC
              MOVE 'UPDGUEST' TO AUD-ACTN
           END-IF
           IF SQLCODE = 0
              EXEC SQL COMMIT END-EXEC
              MOVE HV-NAME TO AUD-KEY
              MOVE 'Guest profile saved' TO AUD-TEXT
              CALL 'CMSERROR' USING AUD-USER AUD-PGM AUD-ACTN
                                    AUD-KEY AUD-TEXT
              EXEC SQL COMMIT END-EXEC
              MOVE 'Guest saved' TO WS-MSG
           ELSE
              EXEC SQL ROLLBACK END-EXEC
              MOVE 'Save failed' TO WS-MSG
           END-IF.
       C100-EXIT.
           EXIT.
      *----------------------------------------------------------------*
       C300-PROCESS-SEL.
           MOVE 'N' TO WS-EOF-SW
           PERFORM UNTIL WS-EOF
              READ DSP-GST NEXT MODIFIED RECORD FORMAT IS 'GMSFL'
                   AT END SET WS-EOF TO TRUE
              END-READ
              IF NOT WS-EOF
                 IF SEL OF GMSFL = 'S' OR SEL OF GMSFL = 's'
                 OR SEL OF GMSFL = '2'
                    MOVE ZGID OF GMSFL TO HV-GID
                    PERFORM C350-LOAD-ONE
                    MOVE 'E' TO WS-MODE
                    PERFORM C100-EDIT
                 END-IF
              END-IF
           END-PERFORM.
      *----------------------------------------------------------------*
       C350-LOAD-ONE.
           EXEC SQL
                SELECT GST_NAME, GST_ADDR, GST_CITY, GST_NATION,
                       GST_PHONE, GST_EMAIL, GST_VIP
                  INTO :HV-NAME, :HV-ADDR, :HV-CITY, :HV-NAT,
                       :HV-PHONE, :HV-EMAIL, :HV-VIP
                  FROM TEHMSDTA/GMPGUEST WHERE GST_ID = :HV-GID
           END-EXEC.
      *================================================================*
      * END OF GMIGUEST                                                *
      *================================================================*
