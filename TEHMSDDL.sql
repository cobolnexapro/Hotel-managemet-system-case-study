--==============================================================================
-- TEHMS - TAJ ENTERPRISE HOTEL MANAGEMENT SYSTEM
-- Member : TEHMSDDL   Type : SQL
-- Run    : RUNSQLSTM SRCFILE(TEHMSSRC/QSQLSRC) SRCMBR(TEHMSDDL) COMMIT(*NONE)
-- Purpose: Create all core DB2 for i tables, indexes, FKs, triggers, seed data.
--==============================================================================
SET SCHEMA TEHMSDTA ;
SET CURRENT SCHEMA TEHMSDTA ;

--------------------------------------------------------------------------------
-- 1. CONFIGURATION
--------------------------------------------------------------------------------
CREATE TABLE TEHMSDTA/CMPCONFG (
  CFG_KEY   CHAR(20)      NOT NULL,
  CFG_VAL   CHAR(50)      NOT NULL DEFAULT '',
  CFG_DESC  CHAR(100)     NOT NULL DEFAULT '',
  CRT_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CRT_USR   CHAR(10)      NOT NULL DEFAULT '',
  UPD_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  UPD_USR   CHAR(10)      NOT NULL DEFAULT '',
  REC_STS   CHAR(1)       NOT NULL DEFAULT 'A',
  CONSTRAINT CMPCONFG_PK PRIMARY KEY (CFG_KEY)
) ;
LABEL ON TABLE TEHMSDTA/CMPCONFG IS 'TEHMS System Configuration' ;

--------------------------------------------------------------------------------
-- 2. SECURITY - USERS
--------------------------------------------------------------------------------
CREATE TABLE TEHMSDTA/SMPUSER (
  USR_ID    CHAR(10)      NOT NULL,
  USR_NAME  CHAR(40)      NOT NULL DEFAULT '',
  USR_PWD   CHAR(64)      NOT NULL DEFAULT '',
  USR_SALT  CHAR(16)      NOT NULL DEFAULT '',
  USR_ROLE  CHAR(10)      NOT NULL DEFAULT 'FRONTDESK',
  USR_FAIL  SMALLINT      NOT NULL DEFAULT 0,
  USR_LASTL TIMESTAMP              DEFAULT NULL,
  CRT_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CRT_USR   CHAR(10)      NOT NULL DEFAULT '',
  UPD_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  UPD_USR   CHAR(10)      NOT NULL DEFAULT '',
  REC_STS   CHAR(1)       NOT NULL DEFAULT 'A',
  CONSTRAINT SMPUSER_PK PRIMARY KEY (USR_ID)
) ;
LABEL ON TABLE TEHMSDTA/SMPUSER IS 'TEHMS Application Users' ;

--------------------------------------------------------------------------------
-- 3. SECURITY - AUDIT LOG
--------------------------------------------------------------------------------
CREATE TABLE TEHMSDTA/SMPAUDIT (
  AUD_ID    BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY
                          (START WITH 1 INCREMENT BY 1),
  AUD_USR   CHAR(10)      NOT NULL DEFAULT '',
  AUD_PGM   CHAR(10)      NOT NULL DEFAULT '',
  AUD_ACTN  CHAR(10)      NOT NULL DEFAULT '',
  AUD_KEY   CHAR(30)      NOT NULL DEFAULT '',
  AUD_TEXT  CHAR(100)     NOT NULL DEFAULT '',
  AUD_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT SMPAUDIT_PK PRIMARY KEY (AUD_ID)
) ;
LABEL ON TABLE TEHMSDTA/SMPAUDIT IS 'TEHMS Security Audit Trail' ;

--------------------------------------------------------------------------------
-- 4. GUEST MASTER
--------------------------------------------------------------------------------
CREATE TABLE TEHMSDTA/GMPGUEST (
  GST_ID    INTEGER       NOT NULL GENERATED ALWAYS AS IDENTITY
                          (START WITH 1000 INCREMENT BY 1),
  GST_NAME  CHAR(40)      NOT NULL DEFAULT '',
  GST_ADDR  CHAR(60)      NOT NULL DEFAULT '',
  GST_CITY  CHAR(30)      NOT NULL DEFAULT '',
  GST_NATION CHAR(20)     NOT NULL DEFAULT 'INDIAN',
  GST_PASSPT CHAR(20)     NOT NULL DEFAULT '',
  GST_VISA  CHAR(20)      NOT NULL DEFAULT '',
  GST_PHONE CHAR(15)      NOT NULL DEFAULT '',
  GST_EMAIL CHAR(40)      NOT NULL DEFAULT '',
  GST_VIP   CHAR(1)       NOT NULL DEFAULT 'N',
  GST_BLK   CHAR(1)       NOT NULL DEFAULT 'N',
  GST_LOYAL CHAR(10)      NOT NULL DEFAULT '',
  CRT_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CRT_USR   CHAR(10)      NOT NULL DEFAULT '',
  UPD_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  UPD_USR   CHAR(10)      NOT NULL DEFAULT '',
  REC_STS   CHAR(1)       NOT NULL DEFAULT 'A',
  CONSTRAINT GMPGUEST_PK PRIMARY KEY (GST_ID)
) ;
LABEL ON TABLE TEHMSDTA/GMPGUEST IS 'TEHMS Guest Master' ;

--------------------------------------------------------------------------------
-- 5. ROOM CATEGORY
--------------------------------------------------------------------------------
CREATE TABLE TEHMSDTA/RMPCAT (
  CAT_CODE  CHAR(6)       NOT NULL,
  CAT_DESC  CHAR(30)      NOT NULL DEFAULT '',
  CAT_RATE  DECIMAL(11,2) NOT NULL DEFAULT 0,
  CAT_MAXPX SMALLINT      NOT NULL DEFAULT 2,
  CRT_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CRT_USR   CHAR(10)      NOT NULL DEFAULT '',
  UPD_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  UPD_USR   CHAR(10)      NOT NULL DEFAULT '',
  REC_STS   CHAR(1)       NOT NULL DEFAULT 'A',
  CONSTRAINT RMPCAT_PK PRIMARY KEY (CAT_CODE)
) ;
LABEL ON TABLE TEHMSDTA/RMPCAT IS 'TEHMS Room Categories' ;

--------------------------------------------------------------------------------
-- 6. ROOM MASTER
--------------------------------------------------------------------------------
CREATE TABLE TEHMSDTA/RMPROOM (
  RM_NO     CHAR(6)       NOT NULL,
  CAT_CODE  CHAR(6)       NOT NULL,
  RM_FLOOR  SMALLINT      NOT NULL DEFAULT 0,
  RM_STS    CHAR(1)       NOT NULL DEFAULT 'V',
  RM_CLN    CHAR(1)       NOT NULL DEFAULT 'C',
  CRT_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CRT_USR   CHAR(10)      NOT NULL DEFAULT '',
  UPD_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  UPD_USR   CHAR(10)      NOT NULL DEFAULT '',
  REC_STS   CHAR(1)       NOT NULL DEFAULT 'A',
  CONSTRAINT RMPROOM_PK PRIMARY KEY (RM_NO),
  CONSTRAINT RMPROOM_CAT_FK FOREIGN KEY (CAT_CODE)
       REFERENCES TEHMSDTA/RMPCAT (CAT_CODE)
       ON DELETE RESTRICT ON UPDATE RESTRICT
) ;
LABEL ON TABLE TEHMSDTA/RMPROOM IS 'TEHMS Room Master' ;
-- RM_STS : V=Vacant O=Occupied B=Blocked M=Maintenance
-- RM_CLN : C=Clean D=Dirty I=Inspected

--------------------------------------------------------------------------------
-- 7. RESERVATION
--------------------------------------------------------------------------------
CREATE TABLE TEHMSDTA/RSPRESV (
  RES_ID    INTEGER       NOT NULL GENERATED ALWAYS AS IDENTITY
                          (START WITH 500001 INCREMENT BY 1),
  GST_ID    INTEGER       NOT NULL,
  CAT_CODE  CHAR(6)       NOT NULL,
  RM_NO     CHAR(6)       NOT NULL DEFAULT '',
  RES_FRDT  DATE          NOT NULL,
  RES_TODT  DATE          NOT NULL,
  RES_PAX   SMALLINT      NOT NULL DEFAULT 1,
  RES_TYPE  CHAR(2)       NOT NULL DEFAULT 'WI',
  RES_STS   CHAR(1)       NOT NULL DEFAULT 'R',
  RES_RATE  DECIMAL(11,2) NOT NULL DEFAULT 0,
  RES_ADV   DECIMAL(13,2) NOT NULL DEFAULT 0,
  CRT_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CRT_USR   CHAR(10)      NOT NULL DEFAULT '',
  UPD_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  UPD_USR   CHAR(10)      NOT NULL DEFAULT '',
  REC_STS   CHAR(1)       NOT NULL DEFAULT 'A',
  CONSTRAINT RSPRESV_PK PRIMARY KEY (RES_ID),
  CONSTRAINT RSPRESV_GST_FK FOREIGN KEY (GST_ID)
       REFERENCES TEHMSDTA/GMPGUEST (GST_ID) ON DELETE RESTRICT,
  CONSTRAINT RSPRESV_CAT_FK FOREIGN KEY (CAT_CODE)
       REFERENCES TEHMSDTA/RMPCAT (CAT_CODE) ON DELETE RESTRICT,
  CONSTRAINT RSPRESV_DT_CK CHECK (RES_TODT >= RES_FRDT),
  CONSTRAINT RSPRESV_PAX_CK CHECK (RES_PAX > 0)
) ;
LABEL ON TABLE TEHMSDTA/RSPRESV IS 'TEHMS Reservation' ;
-- RES_TYPE: WI=Walkin OB=Online AB=Advance CB=Corporate GB=Group
-- RES_STS : R=Reserved C=CheckedIn O=CheckedOut X=Cancelled W=Waiting

--------------------------------------------------------------------------------
-- 8. INVOICE HEADER
--------------------------------------------------------------------------------
CREATE TABLE TEHMSDTA/BLPINVHD (
  INV_ID    INTEGER       NOT NULL GENERATED ALWAYS AS IDENTITY
                          (START WITH 900001 INCREMENT BY 1),
  RES_ID    INTEGER       NOT NULL,
  GST_ID    INTEGER       NOT NULL,
  INV_DATE  DATE          NOT NULL DEFAULT CURRENT DATE,
  INV_SUBT  DECIMAL(13,2) NOT NULL DEFAULT 0,
  INV_DISC  DECIMAL(13,2) NOT NULL DEFAULT 0,
  INV_GST   DECIMAL(13,2) NOT NULL DEFAULT 0,
  INV_TOTAL DECIMAL(13,2) NOT NULL DEFAULT 0,
  INV_PAID  DECIMAL(13,2) NOT NULL DEFAULT 0,
  INV_STS   CHAR(1)       NOT NULL DEFAULT 'O',
  CRT_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CRT_USR   CHAR(10)      NOT NULL DEFAULT '',
  UPD_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  UPD_USR   CHAR(10)      NOT NULL DEFAULT '',
  REC_STS   CHAR(1)       NOT NULL DEFAULT 'A',
  CONSTRAINT BLPINVHD_PK PRIMARY KEY (INV_ID),
  CONSTRAINT BLPINVHD_RES_FK FOREIGN KEY (RES_ID)
       REFERENCES TEHMSDTA/RSPRESV (RES_ID) ON DELETE RESTRICT,
  CONSTRAINT BLPINVHD_GST_FK FOREIGN KEY (GST_ID)
       REFERENCES TEHMSDTA/GMPGUEST (GST_ID) ON DELETE RESTRICT
) ;
LABEL ON TABLE TEHMSDTA/BLPINVHD IS 'TEHMS Invoice Header' ;
-- INV_STS : O=Open S=Settled

--------------------------------------------------------------------------------
-- 9. INVOICE DETAIL
--------------------------------------------------------------------------------
CREATE TABLE TEHMSDTA/BLPINVDT (
  INV_ID    INTEGER       NOT NULL,
  DTL_SEQ   SMALLINT      NOT NULL,
  DTL_TYPE  CHAR(4)       NOT NULL DEFAULT 'ROOM',
  DTL_DESC  CHAR(40)      NOT NULL DEFAULT '',
  DTL_QTY   DECIMAL(11,3) NOT NULL DEFAULT 1,
  DTL_RATE  DECIMAL(11,2) NOT NULL DEFAULT 0,
  DTL_AMT   DECIMAL(13,2) NOT NULL DEFAULT 0,
  DTL_GSTP  DECIMAL(5,2)  NOT NULL DEFAULT 0,
  CRT_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CRT_USR   CHAR(10)      NOT NULL DEFAULT '',
  CONSTRAINT BLPINVDT_PK PRIMARY KEY (INV_ID, DTL_SEQ),
  CONSTRAINT BLPINVDT_HD_FK FOREIGN KEY (INV_ID)
       REFERENCES TEHMSDTA/BLPINVHD (INV_ID) ON DELETE CASCADE
) ;
LABEL ON TABLE TEHMSDTA/BLPINVDT IS 'TEHMS Invoice Detail' ;
-- DTL_TYPE: ROOM REST SPA  LAUN MBAR MISC

--------------------------------------------------------------------------------
-- 10. PAYMENT
--------------------------------------------------------------------------------
CREATE TABLE TEHMSDTA/BLPPAY (
  PAY_ID    INTEGER       NOT NULL GENERATED ALWAYS AS IDENTITY
                          (START WITH 1 INCREMENT BY 1),
  INV_ID    INTEGER       NOT NULL,
  PAY_MODE  CHAR(4)       NOT NULL DEFAULT 'CASH',
  PAY_AMT   DECIMAL(13,2) NOT NULL DEFAULT 0,
  PAY_REF   CHAR(30)      NOT NULL DEFAULT '',
  PAY_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CRT_USR   CHAR(10)      NOT NULL DEFAULT '',
  CONSTRAINT BLPPAY_PK PRIMARY KEY (PAY_ID),
  CONSTRAINT BLPPAY_HD_FK FOREIGN KEY (INV_ID)
       REFERENCES TEHMSDTA/BLPINVHD (INV_ID) ON DELETE CASCADE
) ;
LABEL ON TABLE TEHMSDTA/BLPPAY IS 'TEHMS Payments' ;
-- PAY_MODE: CASH CARD UPI  BTC  CORP

--==============================================================================
-- INDEXES (logical access paths)
--==============================================================================
CREATE INDEX TEHMSDTA/RSLRESV1 ON TEHMSDTA/RSPRESV (RES_FRDT, RES_STS) ;
CREATE INDEX TEHMSDTA/RSLRESV2 ON TEHMSDTA/RSPRESV (GST_ID) ;
CREATE INDEX TEHMSDTA/RMLROOM1 ON TEHMSDTA/RMPROOM (CAT_CODE, RM_STS) ;
CREATE INDEX TEHMSDTA/GMLGUEST1 ON TEHMSDTA/GMPGUEST (GST_NAME) ;
CREATE INDEX TEHMSDTA/BLLINV1  ON TEHMSDTA/BLPINVHD (RES_ID, INV_STS) ;
CREATE INDEX TEHMSDTA/SMLAUD1  ON TEHMSDTA/SMPAUDIT (AUD_USR, AUD_TS) ;

--==============================================================================
-- VIEW : available rooms by category
--==============================================================================
CREATE VIEW TEHMSDTA/RMVAVAIL AS
   SELECT R.RM_NO, R.CAT_CODE, C.CAT_DESC, C.CAT_RATE, R.RM_FLOOR
     FROM TEHMSDTA/RMPROOM R
     JOIN TEHMSDTA/RMPCAT  C ON R.CAT_CODE = C.CAT_CODE
    WHERE R.RM_STS = 'V' AND R.RM_CLN IN ('C','I') AND R.REC_STS = 'A' ;
LABEL ON TABLE TEHMSDTA/RMVAVAIL IS 'TEHMS Available Rooms' ;

--==============================================================================
-- TRIGGERS : maintain UPD_TS on update (representative set)
--==============================================================================
CREATE TRIGGER TEHMSDTA/GMPGUEST_UPD
   BEFORE UPDATE ON TEHMSDTA/GMPGUEST
   REFERENCING NEW AS N
   FOR EACH ROW MODE DB2ROW
   SET N.UPD_TS = CURRENT TIMESTAMP ;

CREATE TRIGGER TEHMSDTA/RSPRESV_UPD
   BEFORE UPDATE ON TEHMSDTA/RSPRESV
   REFERENCING NEW AS N
   FOR EACH ROW MODE DB2ROW
   SET N.UPD_TS = CURRENT TIMESTAMP ;

CREATE TRIGGER TEHMSDTA/BLPINVHD_UPD
   BEFORE UPDATE ON TEHMSDTA/BLPINVHD
   REFERENCING NEW AS N
   FOR EACH ROW MODE DB2ROW
   SET N.UPD_TS = CURRENT TIMESTAMP ;

--==============================================================================
-- STORED PROCEDURE : RSQAVAIL - count available rooms for a category
--==============================================================================
CREATE OR REPLACE PROCEDURE TEHMSDTA/RSQAVAIL (
       IN  P_CAT   CHAR(6),
       OUT P_CNT   INTEGER )
   LANGUAGE SQL
   READS SQL DATA
BEGIN
   SELECT COUNT(*) INTO P_CNT
     FROM TEHMSDTA/RMPROOM
    WHERE CAT_CODE = P_CAT
      AND RM_STS  = 'V'
      AND RM_CLN  IN ('C','I')
      AND REC_STS = 'A' ;
END ;

--==============================================================================
-- SEED DATA
--==============================================================================
INSERT INTO TEHMSDTA/CMPCONFG (CFG_KEY, CFG_VAL, CFG_DESC, CRT_USR) VALUES
  ('HOTEL_NAME'  , 'TAJ HOTEL MUMBAI'        , 'Hotel display name'      , 'INSTALL'),
  ('HOTEL_GSTIN' , '27AAAAA0000A1Z5'         , 'Hotel GSTIN'             , 'INSTALL'),
  ('GST_CGST_PCT', '06.00'                   , 'CGST percent'            , 'INSTALL'),
  ('GST_SGST_PCT', '06.00'                   , 'SGST percent'            , 'INSTALL'),
  ('GST_LUX_PCT' , '18.00'                   , 'Luxury room GST percent' , 'INSTALL'),
  ('CURRENCY'    , 'INR'                     , 'Base currency'           , 'INSTALL') ;

INSERT INTO TEHMSDTA/RMPCAT (CAT_CODE, CAT_DESC, CAT_RATE, CAT_MAXPX, CRT_USR) VALUES
  ('DLX'  , 'DELUXE ROOM'          , 08500.00, 2, 'INSTALL'),
  ('EXEC' , 'EXECUTIVE ROOM'       , 12000.00, 3, 'INSTALL'),
  ('STE'  , 'LUXURY SUITE'         , 25000.00, 4, 'INSTALL'),
  ('PRES' , 'PRESIDENTIAL SUITE'   , 75000.00, 6, 'INSTALL') ;

INSERT INTO TEHMSDTA/RMPROOM (RM_NO, CAT_CODE, RM_FLOOR, RM_STS, RM_CLN, CRT_USR) VALUES
  ('101', 'DLX' , 1, 'V', 'C', 'INSTALL'),
  ('102', 'DLX' , 1, 'V', 'C', 'INSTALL'),
  ('103', 'DLX' , 1, 'V', 'C', 'INSTALL'),
  ('201', 'EXEC', 2, 'V', 'C', 'INSTALL'),
  ('202', 'EXEC', 2, 'V', 'C', 'INSTALL'),
  ('301', 'STE' , 3, 'V', 'C', 'INSTALL'),
  ('302', 'STE' , 3, 'V', 'C', 'INSTALL'),
  ('401', 'PRES', 4, 'V', 'C', 'INSTALL') ;

-- ADMIN user: password is blank => first sign-on sets it (see SMILOGIN).
INSERT INTO TEHMSDTA/SMPUSER
  (USR_ID, USR_NAME, USR_PWD, USR_SALT, USR_ROLE, CRT_USR) VALUES
  ('ADMIN'   , 'SYSTEM ADMINISTRATOR', '', '', 'ADMIN'    , 'INSTALL'),
  ('FRONT01' , 'FRONT DESK CLERK 1'  , '', '', 'FRONTDESK', 'INSTALL'),
  ('MGR01'   , 'DUTY MANAGER'        , '', '', 'MANAGER'  , 'INSTALL') ;

--==============================================================================
-- END OF TEHMSDDL
--==============================================================================
