/*================================================================*/
/* PROGRAM : ADCNAUDIT                                            */
/* MODULE  : Administration (AD) / Night Audit                    */
/* PURPOSE : End-of-day batch. For every OPEN folio of a checked- */
/*           in guest, post one night's room charge, then recompute*/
/*           subtotal / GST / grand total set-based (mirrors       */
/*           CMSBILL). Schedule via ADDJOBSCDE / WRKJOBSCDE.       */
/* RUN     : SBMJOB CMD(CALL TEHMSPGM/ADCNAUDIT) JOB(NIGHTAUD)     */
/*================================================================*/
             PGM

             ADDLIBLE   LIB(TEHMSDTA)
             MONMSG     MSGID(CPF2103)

/* ---- 1. post one room-night to each in-house open folio ----- */
             RUNSQL     SQL('INSERT INTO TEHMSDTA/BLPINVDT +
                          (INV_ID, DTL_SEQ, DTL_TYPE, DTL_DESC, +
                           DTL_QTY, DTL_RATE, DTL_AMT, DTL_GSTP, +
                           CRT_USR) +
                          SELECT H.INV_ID, +
                            COALESCE((SELECT MAX(D.DTL_SEQ) +
                              FROM TEHMSDTA/BLPINVDT D +
                              WHERE D.INV_ID = H.INV_ID),0)+1, +
                            ''ROOM'', ''Room charge - night audit'', +
                            1, R.RES_RATE, R.RES_RATE, 18.00, +
                            ''NIGHTAUD'' +
                          FROM TEHMSDTA/BLPINVHD H +
                          JOIN TEHMSDTA/RSPRESV R +
                            ON H.RES_ID = R.RES_ID +
                          WHERE H.INV_STS = ''O'' +
                            AND R.RES_STS = ''C''') +
                          COMMIT(*NONE)
             MONMSG     MSGID(CPF0000 SQL0000)

/* ---- 2. recompute subtotal and GST -------------------------- */
             RUNSQL     SQL('UPDATE TEHMSDTA/BLPINVHD H SET +
                          INV_SUBT = (SELECT COALESCE(SUM(DTL_AMT),0) +
                            FROM TEHMSDTA/BLPINVDT D +
                            WHERE D.INV_ID = H.INV_ID), +
                          INV_GST = (SELECT +
                            COALESCE(SUM(DTL_AMT*DTL_GSTP/100),0) +
                            FROM TEHMSDTA/BLPINVDT D +
                            WHERE D.INV_ID = H.INV_ID) +
                          WHERE H.INV_STS = ''O''') +
                          COMMIT(*NONE)
             MONMSG     MSGID(CPF0000 SQL0000)

/* ---- 3. recompute grand total ------------------------------- */
             RUNSQL     SQL('UPDATE TEHMSDTA/BLPINVHD SET +
                          INV_TOTAL = INV_SUBT - INV_DISC + INV_GST +
                          WHERE INV_STS = ''O''') +
                          COMMIT(*NONE)
             MONMSG     MSGID(CPF0000 SQL0000)

/* ---- 4. write an audit marker ------------------------------- */
             RUNSQL     SQL('INSERT INTO TEHMSDTA/SMPAUDIT +
                          (AUD_USR, AUD_PGM, AUD_ACTN, AUD_KEY, +
                           AUD_TEXT) +
                          VALUES (''NIGHTAUD'', ''ADCNAUDIT'', +
                           ''EOD'', '' '', +
                           ''Night audit completed'')') +
                          COMMIT(*NONE)
             MONMSG     MSGID(CPF0000 SQL0000)

             SNDPGMMSG  MSG('TEHMS night audit completed.')
             ENDPGM
