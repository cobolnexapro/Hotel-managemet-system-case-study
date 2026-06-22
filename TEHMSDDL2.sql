--==============================================================================
-- TEHMS - INVENTORY MODULE TABLES
-- Member : TEHMSDDL2   Type : SQL
-- Run    : RUNSQLSTM SRCFILE(TEHMSSRC/QSQLSRC) SRCMBR(TEHMSDDL2) COMMIT(*NONE)
--==============================================================================
SET SCHEMA TEHMSDTA ;
SET CURRENT SCHEMA TEHMSDTA ;

--------------------------------------------------------------------------------
-- INVENTORY ITEM MASTER
--------------------------------------------------------------------------------
CREATE TABLE TEHMSDTA/IVPITEM (
  ITM_CODE  CHAR(10)      NOT NULL,
  ITM_DESC  CHAR(40)      NOT NULL DEFAULT '',
  ITM_UOM   CHAR(4)       NOT NULL DEFAULT 'EA',
  ITM_QOH   DECIMAL(11,3) NOT NULL DEFAULT 0,
  ITM_RATE  DECIMAL(11,2) NOT NULL DEFAULT 0,
  ITM_REORD DECIMAL(11,3) NOT NULL DEFAULT 0,
  CRT_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CRT_USR   CHAR(10)      NOT NULL DEFAULT '',
  UPD_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  UPD_USR   CHAR(10)      NOT NULL DEFAULT '',
  REC_STS   CHAR(1)       NOT NULL DEFAULT 'A',
  CONSTRAINT IVPITEM_PK PRIMARY KEY (ITM_CODE)
) ;
LABEL ON TABLE TEHMSDTA/IVPITEM IS 'TEHMS Inventory Item Master' ;

--------------------------------------------------------------------------------
-- INVENTORY STOCK TRANSACTIONS
--------------------------------------------------------------------------------
CREATE TABLE TEHMSDTA/IVPTXN (
  TXN_ID    INTEGER       NOT NULL GENERATED ALWAYS AS IDENTITY
                          (START WITH 1 INCREMENT BY 1),
  ITM_CODE  CHAR(10)      NOT NULL,
  TXN_TYPE  CHAR(1)       NOT NULL DEFAULT 'R',
  TXN_QTY   DECIMAL(11,3) NOT NULL DEFAULT 0,
  TXN_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CRT_USR   CHAR(10)      NOT NULL DEFAULT '',
  CONSTRAINT IVPTXN_PK PRIMARY KEY (TXN_ID),
  CONSTRAINT IVPTXN_ITM_FK FOREIGN KEY (ITM_CODE)
       REFERENCES TEHMSDTA/IVPITEM (ITM_CODE) ON DELETE RESTRICT
) ;
LABEL ON TABLE TEHMSDTA/IVPTXN IS 'TEHMS Stock Transactions' ;
-- TXN_TYPE : R=Receive  I=Issue

CREATE INDEX TEHMSDTA/IVLTXN1 ON TEHMSDTA/IVPTXN (ITM_CODE, TXN_TS) ;

CREATE TRIGGER TEHMSDTA/IVPITEM_UPD
   BEFORE UPDATE ON TEHMSDTA/IVPITEM
   REFERENCING NEW AS N
   FOR EACH ROW MODE DB2ROW
   SET N.UPD_TS = CURRENT TIMESTAMP ;

--------------------------------------------------------------------------------
-- SEED
--------------------------------------------------------------------------------
INSERT INTO TEHMSDTA/IVPITEM
  (ITM_CODE, ITM_DESC, ITM_UOM, ITM_QOH, ITM_RATE, ITM_REORD, CRT_USR) VALUES
  ('TOWEL-BTH','Bath towel'              ,'EA' ,200,  450.00, 50,'INSTALL'),
  ('SOAP-LUX' ,'Luxury soap bar'         ,'EA' ,500,   35.00,100,'INSTALL'),
  ('WTR-500'  ,'Mineral water 500ml'     ,'BTL',800,   18.00,200,'INSTALL'),
  ('LINEN-KNG','King bed linen set'      ,'SET',120,  1200.00,30,'INSTALL') ;

--==============================================================================
-- END OF TEHMSDDL2
--==============================================================================
