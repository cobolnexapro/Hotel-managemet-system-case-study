/* ================================================================ */
/* BINDER SOURCE : CMSUTIL                                           */
/* PURPOSE       : Export the common service procedures so that any  */
/*                 program bound to service program CMSUTIL can      */
/*                 CALL them by name (static binding).               */
/* BUILD         : CRTSRVPGM SRVPGM(TEHMSPGM/CMSUTIL)                */
/*                   MODULE(TEHMSPGM/CMSERROR TEHMSPGM/CMSSEC        */
/*                          TEHMSPGM/CMSBILL)                        */
/*                   SRCFILE(TEHMSSRC/QSRVSRC) SRCMBR(CMSUTIL)       */
/*                   EXPORT(*SRCFILE)                                */
/* ================================================================ */
STRPGMEXP PGMLVL(*CURRENT) SIGNATURE('TEHMS_CMSUTIL_V1')
  EXPORT SYMBOL(CMSERROR)
  EXPORT SYMBOL(CMSSEC)
  EXPORT SYMBOL(CMSBILL)
ENDPGMEXP
