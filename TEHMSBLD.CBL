/*================================================================*/
/* PROGRAM : TEHMSBLD                                             */
/* MODULE  : Administration (AD)                                  */
/* PURPOSE : Compile the entire TEHMS core in dependency order:   */
/*           DDL -> DDS -> SQL COBOL modules -> service program   */
/*           -> binding directory -> interactive programs.        */
/* PRE-REQ : ADCSETUP has run and all source members uploaded to  */
/*           TEHMSSRC. Run:  CALL TEHMSPGM/TEHMSBLD               */
/*================================================================*/
             PGM

             ADDLIBLE   LIB(TEHMSDTA)
             MONMSG     MSGID(CPF2103)
             ADDLIBLE   LIB(TEHMSPGM)
             MONMSG     MSGID(CPF2103)

/* ---- 1. DATABASE ------------------------------------------- */
             RUNSQLSTM  SRCFILE(TEHMSSRC/QSQLSRC) SRCMBR(TEHMSDDL) +
                          COMMIT(*NONE) ERRLVL(20)

/* ---- 2. DISPLAY / PRINTER FILES ---------------------------- */
             CRTDSPF    FILE(TEHMSPGM/SMDLOGIN) +
                          SRCFILE(TEHMSSRC/QDDSSRC) SRCMBR(SMDLOGIN)
             MONMSG     MSGID(CPF0000)
             CRTDSPF    FILE(TEHMSPGM/CMDMAIN) +
                          SRCFILE(TEHMSSRC/QDDSSRC) SRCMBR(CMDMAIN)
             MONMSG     MSGID(CPF0000)
             CRTDSPF    FILE(TEHMSPGM/RSDRESV) +
                          SRCFILE(TEHMSSRC/QDDSSRC) SRCMBR(RSDRESV)
             MONMSG     MSGID(CPF0000)
             CRTDSPF    FILE(TEHMSPGM/BLDBILL) +
                          SRCFILE(TEHMSSRC/QDDSSRC) SRCMBR(BLDBILL)
             MONMSG     MSGID(CPF0000)
             CRTPRTF    FILE(TEHMSPGM/BLRINV) +
                          SRCFILE(TEHMSSRC/QDDSSRC) SRCMBR(BLRINV)
             MONMSG     MSGID(CPF0000)

/* ---- 3. SERVICE MODULES (embedded SQL -> CRTSQLCBLI *MODULE)- */
             CRTSQLCBLI OBJ(TEHMSPGM/CMSERROR) +
                          SRCFILE(TEHMSSRC/QCBLLESRC) +
                          SRCMBR(CMSERROR) OBJTYPE(*MODULE) +
                          COMMIT(*CHG)
             MONMSG     MSGID(CPF0000)
             CRTSQLCBLI OBJ(TEHMSPGM/CMSSEC) +
                          SRCFILE(TEHMSSRC/QCBLLESRC) +
                          SRCMBR(CMSSEC) OBJTYPE(*MODULE) +
                          COMMIT(*CHG)
             MONMSG     MSGID(CPF0000)
             CRTSQLCBLI OBJ(TEHMSPGM/CMSBILL) +
                          SRCFILE(TEHMSSRC/QCBLLESRC) +
                          SRCMBR(CMSBILL) OBJTYPE(*MODULE) +
                          COMMIT(*CHG)
             MONMSG     MSGID(CPF0000)

/* ---- 4. SERVICE PROGRAM ------------------------------------ */
             CRTSRVPGM  SRVPGM(TEHMSPGM/CMSUTIL) +
                          MODULE(TEHMSPGM/CMSERROR +
                                 TEHMSPGM/CMSSEC +
                                 TEHMSPGM/CMSBILL) +
                          SRCFILE(TEHMSSRC/QSRVSRC) SRCMBR(CMSUTIL) +
                          EXPORT(*SRCFILE)
             MONMSG     MSGID(CPF0000)

/* ---- 5. BINDING DIRECTORY ---------------------------------- */
             CRTBNDDIR  BNDDIR(TEHMSPGM/TEHMSBND)
             MONMSG     MSGID(CPF0000)
             ADDBNDDIRE BNDDIR(TEHMSPGM/TEHMSBND) +
                          OBJ((TEHMSPGM/CMSUTIL *SRVPGM))
             MONMSG     MSGID(CPF0000)

/* ---- 6. PROGRAMS ------------------------------------------- */
/*        CMMMAIN has no embedded SQL -> CRTBNDCBL.             */
             CRTBNDCBL  PGM(TEHMSPGM/CMMMAIN) +
                          SRCFILE(TEHMSSRC/QCBLLESRC) +
                          SRCMBR(CMMMAIN) +
                          BNDDIR(TEHMSPGM/TEHMSBND)
             MONMSG     MSGID(CPF0000)
/*        The rest embed SQL -> CRTSQLCBLI *PGM + BNDDIR.       */
             CRTSQLCBLI OBJ(TEHMSPGM/SMILOGIN) +
                          SRCFILE(TEHMSSRC/QCBLLESRC) +
                          SRCMBR(SMILOGIN) OBJTYPE(*PGM) +
                          COMMIT(*CHG) BNDDIR(TEHMSPGM/TEHMSBND)
             MONMSG     MSGID(CPF0000)
             CRTSQLCBLI OBJ(TEHMSPGM/RSIRESV) +
                          SRCFILE(TEHMSSRC/QCBLLESRC) +
                          SRCMBR(RSIRESV) OBJTYPE(*PGM) +
                          COMMIT(*CHG) BNDDIR(TEHMSPGM/TEHMSBND)
             MONMSG     MSGID(CPF0000)
             CRTSQLCBLI OBJ(TEHMSPGM/BLIBILL) +
                          SRCFILE(TEHMSSRC/QCBLLESRC) +
                          SRCMBR(BLIBILL) OBJTYPE(*PGM) +
                          COMMIT(*CHG) BNDDIR(TEHMSPGM/TEHMSBND)
             MONMSG     MSGID(CPF0000)

             SNDPGMMSG  MSG('TEHMS build complete. Start with +
                          CALL TEHMSPGM/SMILOGIN')
             ENDPGM
