      *================================================================*
      * COPYBOOK : CMXERRDS                                            *
      * PURPOSE  : Common error / SQL-status descriptor used by every  *
      *            program for uniform SQL checking and CMSERROR calls.*
      * USAGE    : COPY CMXERRDS.  (in WORKING-STORAGE)                *
      *================================================================*
       01  WS-ERROR-AREA.
           05  WS-ERR-SW           PIC X(01) VALUE 'N'.
               88  WS-ERR-ON               VALUE 'Y'.
               88  WS-ERR-OFF              VALUE 'N'.
           05  WS-ERR-PGM          PIC X(10) VALUE SPACES.
           05  WS-ERR-ACTN         PIC X(10) VALUE SPACES.
           05  WS-ERR-KEY          PIC X(30) VALUE SPACES.
           05  WS-ERR-TEXT         PIC X(100) VALUE SPACES.
           05  WS-SQL-STATE        PIC X(05) VALUE SPACES.
           05  WS-SQL-CODE-N       PIC S9(09) VALUE ZERO.
           05  WS-DISP-MSG         PIC X(78) VALUE SPACES.
