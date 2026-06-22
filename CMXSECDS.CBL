      *================================================================*
      * COPYBOOK : CMXSECDS                                            *
      * PURPOSE  : Shared session / security descriptor. Passed by    *
      *            reference from SMILOGIN through every program so    *
      *            the signed-on user and role travel with the call.  *
      * USAGE    : COPY CMXSECDS.  (in LINKAGE or WORKING-STORAGE)     *
      *================================================================*
       01  SESSION-DATA.
           05  SES-USER-ID         PIC X(10).
           05  SES-USER-NAME       PIC X(40).
           05  SES-USER-ROLE       PIC X(10).
           05  SES-SIGNON-TS       PIC X(26).
           05  SES-RETURN-CD       PIC X(01).
               88  SES-OK                  VALUE '0'.
               88  SES-FAILED              VALUE '1'.
           05  SES-MESSAGE         PIC X(78).
