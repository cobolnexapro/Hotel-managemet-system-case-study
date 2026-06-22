# TAJ ENTERPRISE HOTEL MANAGEMENT SYSTEM (TEHMS)
## Phase 1 — Architecture, Standards & Object Framework

| Item | Value |
|------|-------|
| Hotel | Taj Hotel Mumbai |
| Project | TAJ ENTERPRISE HOTEL MANAGEMENT SYSTEM (TEHMS) |
| Platform | IBM i (AS/400) — V7Rx |
| Languages | ILE COBOL (COBOL400) primary, RPGLE only where unavoidable |
| Database | DB2 for i (embedded SQL, journaled, commitment control) |
| UI | DDS Display Files (subfiles, windows, function keys) |
| Reports | Printer DDS |
| Batch | CL + batch ILE COBOL |
| Scheduling | IBM Advanced Job Scheduler (WRKJOBSCDE / ADDJOBSCDE) |
| Phase | 1 of 5 — **Architecture only (no source members yet)** |

> Phase 1 establishes the skeleton every later phase must obey: library layout, source files, naming rules, object inventory, call hierarchy and the cross-cutting services (security, journaling, audit, error handling). Phases 2–5 will never contradict anything fixed here.

---

## 1. Overall Solution Architecture

TEHMS uses a strict **5-layer ILE architecture**. COBOL programs are bound into service programs through a binding directory; no interactive program talks to DB2 directly except through the database-access layer, and no business rule lives in a screen program.

```
+==============================================================================+
|                         TEHMS  -  LAYERED ARCHITECTURE                        |
+==============================================================================+

  TERMINAL USER (5250)              PRINTER (*PRTF)            JOB SCHEDULER
        |                                |                          |
        v                                v                          v
+------------------------------------------------------------------------------+
| 1. PRESENTATION LAYER                                                         |
|    - DDS Display Files (subfiles, window groups, FKEY definitions)            |
|    - Interactive COBOL programs  (type 'I')  drive screens & subfiles only    |
|    - Menu driver programs        (type 'M')                                   |
|    - Printer DDS + report driver programs                                     |
+------------------------------------------------------------------------------+
        |  (CALL / CALLPRC with parameter list - see copybooks)
        v
+------------------------------------------------------------------------------+
| 2. BUSINESS LAYER                                                             |
|    - Service programs (type 'S') exporting business procedures                |
|    - Validation, GST/tax calc, billing engine, availability engine,          |
|      loyalty, payroll calc, GL posting, room-status state machine            |
|    - No screen I/O, no hard-coded literals (uses message file)               |
+------------------------------------------------------------------------------+
        |  (embedded SQL / CALLPRC)
        v
+------------------------------------------------------------------------------+
| 3. DATABASE-ACCESS LAYER                                                      |
|    - DB2 for i tables (PF) + logical files (LF) + SQL views/indexes          |
|    - SQL stored procedures & functions (type 'Q')                            |
|    - All access via embedded SQL with SQLCA checking + commitment control    |
|    - Journaling on every transactional table                                 |
+------------------------------------------------------------------------------+
        ^                                ^                          ^
        |                                |                          |
+------------------------------------------------------------------------------+
| 4. BATCH LAYER                                                                |
|    - CL programs (type 'C') : night audit, EOD, month-end, backup, restore   |
|    - Batch COBOL programs (type 'B') : posting, ageing, occupancy build      |
|    - Submitted via SBMJOB to dedicated job queue TEHMSJOBQ                    |
+------------------------------------------------------------------------------+
        |
        v
+------------------------------------------------------------------------------+
| 5. COMMON / UTILITY LAYER  (cross-cutting - used by every layer)             |
|    - Copybooks (type 'X')   : SQLCA, error DS, function keys, audit DS        |
|    - CMSERROR  (error/exception service)                                      |
|    - CMSMSG    (message-queue & message-file service)                         |
|    - CMSSEC    (authentication / role check)                                  |
|    - CMSDATE   (date/time conversion)   CMSNUM (sequence/number generator)    |
|    - CMSGST    (GST calculation)        CMSVAL (common field validation)      |
|    - Journal management, audit-log writer                                     |
+------------------------------------------------------------------------------+
```

**Cross-cutting concerns** (applied uniformly, not a layer):
Security & RBAC, Journaling & commitment control, Audit logging, Message-queue handling, Error handling, Configuration. Every program participates in these through the Common layer.

---

## 2. Module Breakdown

Twelve functional modules. Each two-letter **module code** is the first two characters of every object that belongs to it.

| # | Module | Code | Key sub-functions |
|---|--------|------|-------------------|
| 1 | Security Management (Login) | `SM` | RBAC, password encryption, user profile, audit log, forgot-password, inactive-user lockout |
| 2 | Reservation System | `RS` | Walk-in, online, advance, corporate, group booking, modify, cancel, history, waiting list, confirmation |
| 3 | Guest Management | `GM` | Registration, check-in, check-out, history, passport/visa, VIP, blacklist, loyalty |
| 4 | Room Management | `RM` | Categories, allocation, status, cleaning, maintenance, upgrade, transfer, blocking, availability |
| 5 | Billing System | `BL` | Room/restaurant/spa/laundry/mini-bar charges, discount, GST, multi-mode payment, split bill, invoice, refund |
| 6 | Restaurant Management | `RT` | Table reservation, kitchen orders, menu, order billing, food inventory, chef dashboard |
| 7 | Housekeeping | `HK` | Daily cleaning, inspection, laundry, lost & found, room-service requests |
| 8 | Inventory Management | `IV` | Vendors, purchase orders, goods receipt, stock, issue, return, expiry tracking |
| 9 | Human Resources | `HR` | Employee master, attendance, payroll, leave, shift, department |
| 10 | Finance | `FN` | AR, AP, cash book, general ledger, daily closing, month-end |
| 11 | Reports | `RP` | Occupancy, revenue, availability, guest history, GST, audit, management dashboard |
| 12 | Administration | `AD` | Master data, backup, restore, audit, configuration |
| — | Common / Shared | `CM` | Reusable services, copybooks, utilities (not a business module) |

---

## 3. Naming Standards (IBM Enterprise convention)

### 3.1 Object name format

All IBM i object names obey the 10-character limit and a fixed positional pattern:

```
  Position :  1  2     3      4 5 6 7 8 9 10
              [ MM ] [ T ] [   m n e m o n i c (<=7)  ]
                |      |          |
                |      |          +-- meaningful function/entity/action
                |      +------------- object TYPE code (see 3.3)
                +-------------------- MODULE code (see section 2)
```

### 3.2 Module codes
`SM RS GM RM BL RT HK IV HR FN RP AD CM` (defined in section 2).

### 3.3 Object type codes (position 3)

| Code | Object type | Example | Meaning |
|------|-------------|---------|---------|
| `P` | Physical file (DB2 table) | `RSPRESV` | Reservation master table |
| `L` | Logical file / SQL index/view | `RSLRESV1` | Reservation LF keyed by date |
| `D` | Display file (DDS) | `RSDRESV` | Reservation screen |
| `R` | Printer file (report DDS) | `BLRINV` | Invoice print file |
| `I` | Interactive COBOL program | `RSIRESV` | Reservation maintenance program |
| `B` | Batch COBOL program | `RPBDOCC` | Daily occupancy build |
| `C` | CL program | `ADCNAUDIT` | Night audit driver |
| `S` | Service program (ILE) | `CMSERROR` | Error-handling service |
| `Q` | SQL procedure / function | `RSQAVAIL` | Availability procedure |
| `G` | RPGLE program (only where unavoidable) | `CMGSPOOL` | Spool utility |
| `X` | Copybook member | `CMXSQLCA` | SQLCA include |
| `M` | Menu driver | `CMMMAIN` | Main system menu |

### 3.4 Database field / column standards

* Columns use an entity prefix + meaningful name: `RES_ID`, `GST_NAME`, `RM_NO`, `INV_AMT`.
* Money columns are `DECIMAL(13,2)`; quantities `DECIMAL(11,3)`; flags `CHAR(1)`.
* **Every transactional table carries these five audit/control columns:**

| Column | Type | Purpose |
|--------|------|---------|
| `CRT_TS` | TIMESTAMP | Row created timestamp |
| `CRT_USR` | CHAR(10) | Created-by user profile |
| `UPD_TS` | TIMESTAMP | Last-updated timestamp |
| `UPD_USR` | CHAR(10) | Updated-by user profile |
| `REC_STS` | CHAR(1) | `A`=Active `I`=Inactive `D`=Logically deleted |

### 3.5 Program-internal naming (COBOL)

| Element | Rule | Example |
|---------|------|---------|
| Working-storage fields | `WS-` prefix | `WS-EOF-SW` |
| Linkage fields | `LK-` prefix | `LK-RES-ID` |
| Switches/flags | `-SW` suffix, value `'Y'/'N'` | `WS-ERROR-SW` |
| Counters | `WS-CTR-` | `WS-CTR-SFL` |
| Paragraphs | `Annn-VERB-NOUN` | `A100-MAIN-PROCESS` |
| Copybook host vars | `HV-` prefix | `HV-RES-STS` |
| Indicators (DDS) | numbered + commented | `*IN50` = SFLDSP |

### 3.6 Indicator usage convention (DDS / COBOL)

| Indicator range | Reserved for |
|-----------------|--------------|
| 50–59 | Subfile control (SFLDSP, SFLDSPCTL, SFLCLR, SFLEND) |
| 60–69 | Field-level error conditions |
| 70–79 | Conditioning / protect / hide |
| 90–99 | Function-key response indicators (F3, F5, F12 …) |

### 3.7 Standard function keys (system-wide)

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| F3 | Exit | F9 | Retrieve / Accept |
| F4 | Prompt (list window) | F10 | Additional options |
| F5 | Refresh | F11 | Toggle view |
| F6 | Create / Add | F12 | Cancel / Previous |
| F7 | Backward page | F22 | Delete (with confirm) |
| F8 | Forward page | F24 | More keys |

---

## 4. Library Structure

Three environments (**DEV / TST / PRD**); each environment has the same set of object libraries. Source is shared from a single source-control library and promoted by CL.

### 4.1 Production library set (pattern repeated for `DEV`/`TST`)

| Library | Contains |
|---------|----------|
| `TEHMSPGM` | `*PGM`, `*SRVPGM`, `*MODULE`, `*MENU`, binding directories |
| `TEHMSDTA` | `*FILE` — physical files, logical files, SQL views/indexes |
| `TEHMSJRN` | `*JRN`, `*JRNRCV` (journals & receivers) |
| `TEHMSMSG` | `*MSGF` message files, data areas |
| `TEHMSBKP` | `*SAVF` save files / archive |

For DEV and TST prefix with `D`/`T`: `DTEHMSPGM`, `DTEHMSDTA`, `TTEHMSPGM`, etc. (10-char limit respected).

### 4.2 Source library (single, shared)

`TEHMSSRC` — holds all source physical files (section 5).

### 4.3 Library list at runtime (set by job description `TEHMSJOBD`)

```
  *LIBL order :  QTEMP  >  TEHMSPGM  >  TEHMSDTA  >  TEHMSMSG  >  QGPL
  CURLIB      :  TEHMSDTA
  JOBQ        :  TEHMSJOBQ        (single-threaded for night audit / EOD)
  OUTQ        :  TEHMSOUTQ
```

---

## 5. Source Physical Files (in `TEHMSSRC`)

| Source file | RCDLEN | Member type | Holds |
|-------------|--------|-------------|-------|
| `QCBLLESRC` | 112 | `CBLLE` | ILE COBOL programs (interactive + batch) |
| `QRPGLESRC` | 112 | `RPGLE` | RPGLE utilities (only where unavoidable) |
| `QDDSSRC` | 92 | `PF`/`LF`/`DSPF`/`PRTF` | DDS for tables, logicals, display & printer files |
| `QCLSRC` | 92 | `CLLE` | CL programs |
| `QSQLSRC` | 92 | `SQL` | CREATE TABLE/VIEW/INDEX, procedures, triggers |
| `QSRVSRC` | 92 | `BND` | Binder-language source for service programs |
| `QCPYSRC` | 92 | `CBLLE` | Copybooks (COPY members) |

---

## 6. Object Inventory & Targets

Planned distribution that meets the project targets. Exact member names are enumerated in their respective phases (tables in Phase 2, screens in Phase 3, copybooks in Phase 4, programs in Phase 5).

### 6.1 COBOL programs — target ~100

| Module | Pgms | Module | Pgms |
|--------|------|--------|------|
| Security `SM` | 6 | Housekeeping `HK` | 7 |
| Reservation `RS` | 12 | Inventory `IV` | 8 |
| Guest `GM` | 10 | HR `HR` | 8 |
| Room `RM` | 10 | Finance `FN` | 9 |
| Billing `BL` | 12 | Reports `RP` | 6 |
| Restaurant `RT` | 8 | Admin `AD` | 4 |
| | | **Total** | **100** |

### 6.2 Other objects — targets

| Object type | Target | Allocation summary |
|-------------|--------|--------------------|
| Display files (`D`) | 40 | SM 3, RS 6, GM 5, RM 4, BL 5, RT 4, HK 3, IV 3, HR 3, FN 2, RP 1, AD 1 |
| Printer files (`R`) | 20 | BL 5, RS 2, GM 2, RM 1, RP 6, HR 2, FN 2 |
| Tables (`P`) | 60 | SM 4, RS 6, GM 6, RM 6, BL 8, RT 5, HK 4, IV 6, HR 5, FN 5, CM 5 |
| SQL procedures (`Q`) | 50 | availability, billing, GST, posting, payroll, ageing, loyalty, etc. |
| Service programs (`S`) | 20 | CM 7 shared + 13 module business services |
| Copybooks (`X`) | 20 | section 6.4 |
| CL programs (`C`) | 25 | section 6.3 |

### 6.3 CL program categories (25)

Build/compile (3), library setup/init (2), backup (1), restore (1), save/restore objects (2), journal management (2), daily batch driver (1), night audit driver (1), end-of-day (1), month-end (1), AR/AP ageing submit (2), report-submission wrappers (4), purge/archive (2), scheduler wrappers (2).

### 6.4 Copybook inventory (20)

| Copybook | Purpose | Copybook | Purpose |
|----------|---------|----------|---------|
| `CMXSQLCA` | SQLCA structure | `CMXAUDIT` | Audit-log record DS |
| `CMXERRDS` | Error/exception DS | `CMXJRNL` | Journal entry helper |
| `CMXWSCMN` | Common working-storage | `CMXSTSCD` | Status-code constants |
| `CMXFKEYS` | Function-key constants | `CMXGSTC` | GST rate constants |
| `CMXMSGDS` | Message API DS | `CMXDATE` | Date format DS |
| `CMXHDR` | Standard program header | `CMXPRTHDR` | Common report header |
| `CMXSFLCTL` | Subfile control DS | `CMXSECDS` | Security/session DS |
| `RSXRESV` | Reservation record layout | `GMXGUEST` | Guest record layout |
| `RMXROOM` | Room record layout | `BLXBILL` | Billing record layout |
| `CMXPROTO` | Service-program prototypes | `CMXENV` | Environment/config DS |

---

## 7. Object Relationships (high-level ER overview)

Detailed DDL with PK/FK/index/trigger comes in Phase 2. The core entity relationships:

```
                          +---------------+
                          |   SMPUSER     |  (user / RBAC)
                          +-------+-------+
                                  | logs
                                  v
                          +---------------+
                          |   SMPAUDIT     |  audit-log
                          +---------------+

   +-----------+        +-----------+        +-----------+
   |  RMPCAT   |1------*|  RMPROOM   |1------*| RMPRMSTS  |
   | room cat  |        |  room      |        | status hx |
   +-----------+        +-----+-----+        +-----------+
                              | allocated to
                              v
   +-----------+        +-----------+        +-----------+
   |  GMPGUEST |1------*|  RSPRESV   |*------1| GMPCORP   |
   |  guest    |        |reservation|        | corporate |
   +-----+-----+        +-----+-----+        +-----------+
         | history            | bills
         v                    v
   +-----------+        +-----------+        +-----------+
   |  GMPHIST  |        |  BLPINVHD |1------*| BLPINVDT  |
   |guest hist |        | invoice hd|        | inv detail|
   +-----------+        +-----+-----+        +-----------+
                              | settled by
                              v
                        +-----------+
                        |  BLPPAY    |  payments (multi-mode)
                        +-----------+

   Restaurant : RTPMENU --< RTPORDR --< RTPORDT  (order header/detail)
   Inventory  : IVPVEND --< IVPPO    --< IVPGRN  --< IVPSTOCK
   HR         : HRPDEPT --< HRPEMP   --< HRPATTN / HRPPAY / HRPLEAVE
   Finance    : FNPGL (general ledger) <-- posted from BL / IV / HR
```

`1------*` = one-to-many; `*------1` = many-to-one.

---

## 8. Program Call Hierarchy

### 8.1 Menu / sign-on flow

```
SIGN-ON (QSYS)
   |
   v
SMILOGIN  (login program)
   |  validates via CMSSEC.authenticateUser()
   |  writes SMPAUDIT via CMSERROR/audit writer
   v
CMMMAIN   (main menu driver)
   |
   +--> RSMMENU  (Reservation menu) ---> RSIRESV, RSIGRP, RSICANC, RSIWAIT ...
   +--> GMMMENU  (Guest menu)       ---> GMICHKIN, GMICHKOUT, GMIGUEST ...
   +--> RMMMENU  (Room menu)        ---> RMIROOM, RMIALLOC, RMISTAT ...
   +--> BLMMENU  (Billing menu)     ---> BLIBILL, BLIINVPR, BLIREFND ...
   +--> RTMMENU  (Restaurant menu)
   +--> HKMMENU  (Housekeeping menu)
   +--> IVMMENU  (Inventory menu)
   +--> HRMMENU  (HR menu)
   +--> FNMMENU  (Finance menu)
   +--> RPMMENU  (Reports menu)
   +--> ADMMENU  (Admin menu, *SECADM only)
```

### 8.2 Representative transaction call tree (new reservation)

```
RSIRESV  (interactive - drives RSDRESV display file)
   |
   |-- CALLPRC CMSSEC   : checkAuthority('RS','ADD')
   |-- CALLPRC RSSAVAIL : checkAvailability(roomCat, fromDt, toDt)  -> SQL RSQAVAIL
   |-- CALLPRC CMSVAL   : validateDates / validatePax
   |-- CALLPRC CMSNUM   : nextReservationNo()                       -> SQL CMQSEQ
   |-- EXEC SQL INSERT INTO RSPRESV ...        (under commitment control)
   |-- CALLPRC BLSBILL  : createProforma(resId)
   |-- CALLPRC CMSMSG   : sendConfirmation(resId)  -> printer RSRCONF
   |-- on error: CALLPRC CMSERROR.logAndRollback()
   |-- COMMIT / ROLLBACK
   v
returns status to RSDRESV (message subfile)
```

### 8.3 Night-audit batch tree

```
ADCNAUDIT (CL driver, scheduled 02:00 daily)
   |
   |-- RTVDTAARA  business date
   |-- SBMJOB --> RPBDOCC   (build daily occupancy snapshot)
   |-- SBMJOB --> BLBPOST   (post room charges to open folios)
   |-- SBMJOB --> FNBDCLOSE (daily closing -> FNPGL)
   |-- CALL    ADCBACKUP    (save changed objects to TEHMSBKP)
   |-- roll business date  (CHGDTAARA)
   |-- send completion msg to TEHMSMSGQ
```

---

## 9. Cross-Cutting Design Decisions (binding for all phases)

**Security / RBAC.** `SMPUSER` holds user profiles; `SMPROLE` and `SMPROLEF` (role-function matrix) drive authority. Passwords stored as a one-way hash (salted) — never plaintext. `CMSSEC` exposes `authenticateUser`, `checkAuthority`, `lockInactiveUser`. Three failed attempts → `REC_STS='I'` and audit entry.

**Journaling & commitment control.** Every transactional PF is journaled to `TEHMSJRN/TEHMSJRN`. All update/insert/delete runs under commitment control; programs `COMMIT` on success and `ROLLBACK` on any SQL error. Read-only inquiry programs run without commit.

**Audit logging.** `SMPAUDIT` records user, program, action, key values, before/after where relevant, timestamp. Written through the audit writer in `CMSERROR` so logging is uniform.

**Message handling.** All user-visible text lives in message file `TEHMSMSGF` (library `TEHMSMSG`). Programs send via `CMSMSG` to the program message queue / display-file message subfile — no hard-coded literals.

**Error & file-status handling.** Every COBOL program: declares file status fields, checks `SQLCODE`/`SQLSTATE` after each embedded SQL statement, traps `*PSSR`-style errors, calls `CMSERROR` to log + (where transactional) roll back, then displays a meaningful message. Standard structure: `A000-INIT`, `A100-MAIN`, `A900-EOJ`, `Z100-SQL-CHECK`, `Z900-ERROR`.

**Configuration.** `CMPCONFG` table + data areas hold environment parameters (GST rates, hotel codes, sequence ranges) so values are never compiled in.

---

## 10. Build / Promotion Approach (detail in Phase 5)

1. Create libraries & source files (`ADCSETUP`).
2. Create journals/receivers, start journaling on data library.
3. Compile order: copybooks resolved → DDS PF/LF (`CRTPF`/`CRTLF` or run DDL) → display/printer files (`CRTDSPF`/`CRTPRTF`) → service-program modules (`CRTSQLCBLI`/`CRTCBLMOD` → `CRTSRVPGM`) → interactive & batch programs (`CRTBNDCBL`/`CRTSQLCBLI`) bound to binding directory `TEHMSBND` → menus.
4. Promote DEV → TST → PRD by object save/restore CL.

---

## 11. Phase Roadmap

| Phase | Deliverable | Status |
|-------|-------------|--------|
| **1** | Architecture, standards, library & object framework, call hierarchy | ✅ this document |
| 2 | Database design — all DDL (CREATE TABLE/VIEW/INDEX), PK/FK, constraints, triggers, stored procedures; DDS PF/LF | pending |
| 3 | Display files — DDS for every transaction (subfiles, windows, validation, FKEYs) | pending |
| 4 | Copybooks — all 20 reusable COPY members | pending |
| 5 | COBOL programs — one complete, compilable 300–500 line program at a time until all modules complete (target > 10,000 lines) | pending |

---

*End of Phase 1. Type **NEXT** to begin Phase 2 (Database Design). Every name fixed in this document will be reused exactly and never regenerated.*
