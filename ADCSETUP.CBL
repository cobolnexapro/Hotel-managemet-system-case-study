/*================================================================*/
/* PROGRAM : ADCSETUP                                             */
/* MODULE  : Administration (AD)                                  */
/* PURPOSE : One-time environment build - libraries, SQL schema   */
/*           (schema gives automatic journalling so commitment    */
/*           control works), and the source physical files.       */
/* RUN     : CALL TEHMSPGM/ADCSETUP   (or compile then CALL)      */
/*================================================================*/
             PGM

             DCL        VAR(&MSG) TYPE(*CHAR) LEN(80)

/* ---- program / message / source libraries -------------------- */
             CRTLIB     LIB(TEHMSPGM) TEXT('TEHMS Programs')
             MONMSG     MSGID(CPF2111)
             CRTLIB     LIB(TEHMSMSG) TEXT('TEHMS Messages')
             MONMSG     MSGID(CPF2111)
             CRTLIB     LIB(TEHMSSRC) TEXT('TEHMS Source')
             MONMSG     MSGID(CPF2111)

/* ---- data schema : CREATE SCHEMA auto-creates a journal ------ */
/*      so every table is journalled => commitment control OK.    */
             RUNSQL     SQL('CREATE SCHEMA TEHMSDTA') COMMIT(*NONE)
             MONMSG     MSGID(CPF0000 SQL0000)

/* ---- source physical files ----------------------------------- */
             CRTSRCPF   FILE(TEHMSSRC/QCLSRC)   RCDLEN(112) +
                          TEXT('CL source')
             MONMSG     MSGID(CPF5812 CPF7302)
             CRTSRCPF   FILE(TEHMSSRC/QSQLSRC)  RCDLEN(112) +
                          TEXT('SQL source')
             MONMSG     MSGID(CPF5812 CPF7302)
             CRTSRCPF   FILE(TEHMSSRC/QDDSSRC)  RCDLEN(112) +
                          TEXT('DDS source')
             MONMSG     MSGID(CPF5812 CPF7302)
             CRTSRCPF   FILE(TEHMSSRC/QCPYSRC)  RCDLEN(112) +
                          TEXT('Copybooks')
             MONMSG     MSGID(CPF5812 CPF7302)
             CRTSRCPF   FILE(TEHMSSRC/QSRVSRC)  RCDLEN(112) +
                          TEXT('Binder source')
             MONMSG     MSGID(CPF5812 CPF7302)
             CRTSRCPF   FILE(TEHMSSRC/QCBLLESRC) RCDLEN(112) +
                          TEXT('COBOL source')
             MONMSG     MSGID(CPF5812 CPF7302)

             SNDPGMMSG  MSG('TEHMS environment created. Now upload +
                          source members and CALL TEHMSPGM/TEHMSBLD.')
             ENDPGM
