--==============================================================================
-- TEHMS - HR & FINANCE / GENERAL LEDGER TABLES
-- Member : TEHMSDDL3   Type : SQL
-- Run    : RUNSQLSTM SRCFILE(TEHMSSRC/QSQLSRC) SRCMBR(TEHMSDDL3) COMMIT(*NONE)
--==============================================================================
SET SCHEMA TEHMSDTA ;
SET CURRENT SCHEMA TEHMSDTA ;

--------------------------------------------------------------------------------
-- HR : DEPARTMENT
--------------------------------------------------------------------------------
CREATE TABLE TEHMSDTA/HRPDEPT (
  DPT_CODE  CHAR(6)       NOT NULL,
  DPT_NAME  CHAR(30)      NOT NULL DEFAULT '',
  CRT_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CRT_USR   CHAR(10)      NOT NULL DEFAULT '',
  UPD_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  UPD_USR   CHAR(10)      NOT NULL DEFAULT '',
  REC_STS   CHAR(1)       NOT NULL DEFAULT 'A',
  CONSTRAINT HRPDEPT_PK PRIMARY KEY (DPT_CODE)
) ;
LABEL ON TABLE TEHMSDTA/HRPDEPT IS 'TEHMS Departments' ;

--------------------------------------------------------------------------------
-- HR : EMPLOYEE MASTER
--------------------------------------------------------------------------------
CREATE TABLE TEHMSDTA/HRPEMP (
  EMP_ID    INTEGER       NOT NULL GENERATED ALWAYS AS IDENTITY
                          (START WITH 5000 INCREMENT BY 1),
  EMP_NAME  CHAR(40)      NOT NULL DEFAULT '',
  DPT_CODE  CHAR(6)       NOT NULL DEFAULT '',
  EMP_DESIG CHAR(30)      NOT NULL DEFAULT '',
  EMP_BASIC DECIMAL(13,2) NOT NULL DEFAULT 0,
  EMP_HRA   DECIMAL(13,2) NOT NULL DEFAULT 0,
  EMP_DED   DECIMAL(13,2) NOT NULL DEFAULT 0,
  EMP_DOJ   DATE                   DEFAULT NULL,
  EMP_PHONE CHAR(15)      NOT NULL DEFAULT '',
  CRT_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CRT_USR   CHAR(10)      NOT NULL DEFAULT '',
  UPD_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  UPD_USR   CHAR(10)      NOT NULL DEFAULT '',
  REC_STS   CHAR(1)       NOT NULL DEFAULT 'A',
  CONSTRAINT HRPEMP_PK PRIMARY KEY (EMP_ID),
  CONSTRAINT HRPEMP_DPT_FK FOREIGN KEY (DPT_CODE)
       REFERENCES TEHMSDTA/HRPDEPT (DPT_CODE) ON DELETE RESTRICT
) ;
LABEL ON TABLE TEHMSDTA/HRPEMP IS 'TEHMS Employee Master' ;

CREATE INDEX TEHMSDTA/HRLEMP1 ON TEHMSDTA/HRPEMP (DPT_CODE, EMP_NAME) ;

--------------------------------------------------------------------------------
-- HR : PAYROLL RESULTS
--------------------------------------------------------------------------------
CREATE TABLE TEHMSDTA/HRPPAY (
  PAY_ID    INTEGER       NOT NULL GENERATED ALWAYS AS IDENTITY
                          (START WITH 1 INCREMENT BY 1),
  EMP_ID    INTEGER       NOT NULL,
  PAY_PERIOD CHAR(7)      NOT NULL DEFAULT '',
  PAY_BASIC DECIMAL(13,2) NOT NULL DEFAULT 0,
  PAY_HRA   DECIMAL(13,2) NOT NULL DEFAULT 0,
  PAY_DED   DECIMAL(13,2) NOT NULL DEFAULT 0,
  PAY_NET   DECIMAL(13,2) NOT NULL DEFAULT 0,
  PAY_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CRT_USR   CHAR(10)      NOT NULL DEFAULT '',
  CONSTRAINT HRPPAY_PK PRIMARY KEY (PAY_ID),
  CONSTRAINT HRPPAY_EMP_FK FOREIGN KEY (EMP_ID)
       REFERENCES TEHMSDTA/HRPEMP (EMP_ID) ON DELETE RESTRICT
) ;
LABEL ON TABLE TEHMSDTA/HRPPAY IS 'TEHMS Payroll Results' ;

--------------------------------------------------------------------------------
-- FINANCE : CHART OF ACCOUNTS
--------------------------------------------------------------------------------
CREATE TABLE TEHMSDTA/FNPACCT (
  ACC_CODE  CHAR(8)       NOT NULL,
  ACC_NAME  CHAR(40)      NOT NULL DEFAULT '',
  ACC_TYPE  CHAR(1)       NOT NULL DEFAULT 'E',
  ACC_BAL   DECIMAL(15,2) NOT NULL DEFAULT 0,
  CRT_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CRT_USR   CHAR(10)      NOT NULL DEFAULT '',
  UPD_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  UPD_USR   CHAR(10)      NOT NULL DEFAULT '',
  REC_STS   CHAR(1)       NOT NULL DEFAULT 'A',
  CONSTRAINT FNPACCT_PK PRIMARY KEY (ACC_CODE)
) ;
LABEL ON TABLE TEHMSDTA/FNPACCT IS 'TEHMS Chart of Accounts' ;
-- ACC_TYPE : A=Asset L=Liability I=Income E=Expense Q=Equity
-- ACC_BAL  : accumulated (debits - credits)

--------------------------------------------------------------------------------
-- FINANCE : JOURNAL HEADER
--------------------------------------------------------------------------------
CREATE TABLE TEHMSDTA/FNPJRNH (
  JRN_ID    INTEGER       NOT NULL GENERATED ALWAYS AS IDENTITY
                          (START WITH 1 INCREMENT BY 1),
  JRN_DATE  DATE          NOT NULL DEFAULT CURRENT DATE,
  JRN_DESC  CHAR(50)      NOT NULL DEFAULT '',
  JRN_STS   CHAR(1)       NOT NULL DEFAULT 'D',
  JRN_DR    DECIMAL(15,2) NOT NULL DEFAULT 0,
  JRN_CR    DECIMAL(15,2) NOT NULL DEFAULT 0,
  CRT_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CRT_USR   CHAR(10)      NOT NULL DEFAULT '',
  UPD_TS    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  UPD_USR   CHAR(10)      NOT NULL DEFAULT '',
  REC_STS   CHAR(1)       NOT NULL DEFAULT 'A',
  CONSTRAINT FNPJRNH_PK PRIMARY KEY (JRN_ID)
) ;
LABEL ON TABLE TEHMSDTA/FNPJRNH IS 'TEHMS GL Journal Header' ;
-- JRN_STS : D=Draft P=Posted

--------------------------------------------------------------------------------
-- FINANCE : JOURNAL LINES
--------------------------------------------------------------------------------
CREATE TABLE TEHMSDTA/FNPJRNL (
  JRN_ID    INTEGER       NOT NULL,
  LIN_SEQ   SMALLINT      NOT NULL,
  ACC_CODE  CHAR(8)       NOT NULL,
  LIN_DR    DECIMAL(15,2) NOT NULL DEFAULT 0,
  LIN_CR    DECIMAL(15,2) NOT NULL DEFAULT 0,
  LIN_MEMO  CHAR(40)      NOT NULL DEFAULT '',
  CRT_USR   CHAR(10)      NOT NULL DEFAULT '',
  CONSTRAINT FNPJRNL_PK PRIMARY KEY (JRN_ID, LIN_SEQ),
  CONSTRAINT FNPJRNL_HD_FK FOREIGN KEY (JRN_ID)
       REFERENCES TEHMSDTA/FNPJRNH (JRN_ID) ON DELETE CASCADE,
  CONSTRAINT FNPJRNL_ACC_FK FOREIGN KEY (ACC_CODE)
       REFERENCES TEHMSDTA/FNPACCT (ACC_CODE) ON DELETE RESTRICT
) ;
LABEL ON TABLE TEHMSDTA/FNPJRNL IS 'TEHMS GL Journal Lines' ;

CREATE TRIGGER TEHMSDTA/HRPEMP_UPD
   BEFORE UPDATE ON TEHMSDTA/HRPEMP
   REFERENCING NEW AS N FOR EACH ROW MODE DB2ROW
   SET N.UPD_TS = CURRENT TIMESTAMP ;

CREATE TRIGGER TEHMSDTA/FNPACCT_UPD
   BEFORE UPDATE ON TEHMSDTA/FNPACCT
   REFERENCING NEW AS N FOR EACH ROW MODE DB2ROW
   SET N.UPD_TS = CURRENT TIMESTAMP ;

--------------------------------------------------------------------------------
-- SEED
--------------------------------------------------------------------------------
INSERT INTO TEHMSDTA/HRPDEPT (DPT_CODE, DPT_NAME, CRT_USR) VALUES
  ('FO'  , 'Front Office'   , 'INSTALL'),
  ('HK'  , 'Housekeeping'   , 'INSTALL'),
  ('FB'  , 'Food & Beverage', 'INSTALL'),
  ('FIN' , 'Finance'        , 'INSTALL'),
  ('ADM' , 'Administration' , 'INSTALL') ;

INSERT INTO TEHMSDTA/HRPEMP
  (EMP_NAME, DPT_CODE, EMP_DESIG, EMP_BASIC, EMP_HRA, EMP_DED,
   EMP_PHONE, CRT_USR) VALUES
  ('ANITA DESAI'  , 'FO' , 'Front Office Manager', 65000, 26000, 8000,
   '9820011111', 'INSTALL'),
  ('RAVI KUMAR'   , 'HK' , 'Housekeeping Supervisor', 38000, 15000, 4500,
   '9820022222', 'INSTALL'),
  ('SUNIL RAO'    , 'FB' , 'Restaurant Captain', 32000, 12800, 3800,
   '9820033333', 'INSTALL'),
  ('PRIYA NAIR'   , 'FIN', 'Accountant', 55000, 22000, 6500,
   '9820044444', 'INSTALL') ;

INSERT INTO TEHMSDTA/FNPACCT (ACC_CODE, ACC_NAME, ACC_TYPE, CRT_USR) VALUES
  ('1000', 'Cash in Hand'         , 'A', 'INSTALL'),
  ('1010', 'Bank Account'         , 'A', 'INSTALL'),
  ('1200', 'Accounts Receivable'  , 'A', 'INSTALL'),
  ('2000', 'Accounts Payable'     , 'L', 'INSTALL'),
  ('2100', 'GST Payable'          , 'L', 'INSTALL'),
  ('3000', 'Share Capital'        , 'Q', 'INSTALL'),
  ('4000', 'Room Revenue'         , 'I', 'INSTALL'),
  ('4100', 'Food & Beverage Sales', 'I', 'INSTALL'),
  ('5000', 'Salaries Expense'     , 'E', 'INSTALL'),
  ('5100', 'Utilities Expense'    , 'E', 'INSTALL') ;

--==============================================================================
-- END OF TEHMSDDL3
--==============================================================================
