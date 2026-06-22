# TEHMS — Taj Enterprise Hotel Management System
## Runnable Core — Deployment & Operations Guide

This package is a **complete, compilable vertical slice** of TEHMS for IBM i
(AS/400). It runs end to end: **sign-on → main menu → reservation → check-in
(room allocation + folio) → billing (charges, GST, payment) → tax invoice
print → night audit**. Every other module in the master spec (Housekeeping,
Inventory, HR, Finance, etc.) is built by repeating the exact patterns shown
here, so this core doubles as the project's reference implementation.

Target stack: **IBM i 7.3+**, ILE COBOL, DB2 for i (embedded SQL), DDS
display/printer files, ILE CL, IBM Job Scheduler.

---

## 1. Source members in this package

| Source file | Member | Type | Purpose |
|-------------|--------|------|---------|
| QSQLSRC  | TEHMSDDL | SQL  | All tables, indexes, view, triggers, procedure, seed |
| QCPYSRC  | CMXSECDS | CPY  | Session/security descriptor (passed program→program) |
| QCPYSRC  | CMXFKEYS | CPY  | Function-key response indicators |
| QCPYSRC  | CMXERRDS | CPY  | Common error / SQL-status descriptor |
| QCBLLESRC| CMSERROR | CBLLE| Service module: audit / error writer |
| QCBLLESRC| CMSSEC   | CBLLE| Service module: auth, bootstrap, hash, authority |
| QCBLLESRC| CMSBILL  | CBLLE| Service module: invoice recompute (subtotal/GST/total) |
| QSRVSRC  | CMSUTIL  | BND  | Binder source exporting the three service procedures |
| QDDSSRC  | SMDLOGIN | DSPF | Sign-on screen |
| QDDSSRC  | CMDMAIN  | DSPF | Main menu |
| QDDSSRC  | RSDRESV  | DSPF | Reservation maintenance (subfile + detail) |
| QDDSSRC  | BLDBILL  | DSPF | Billing / folio (subfile) |
| QDDSSRC  | BLRINV   | PRTF | GST tax invoice |
| QCBLLESRC| SMILOGIN | CBLLE| Sign-on program |
| QCBLLESRC| CMMMAIN  | CBLLE| Main-menu driver |
| QCBLLESRC| RSIRESV  | CBLLE| Reservation maintenance program |
| QCBLLESRC| BLIBILL  | CBLLE| Billing program |
| QCLSRC   | ADCSETUP | CLLE | One-time environment build |
| QCLSRC   | TEHMSBLD | CLLE | Compile-all orchestration |
| QCLSRC   | ADCNAUDIT| CLLE | Night-audit batch job |

Libraries created: **TEHMSDTA** (data, as an SQL schema so it is
auto-journalled), **TEHMSPGM** (programs/service program/display files/binding
directory), **TEHMSMSG**, **TEHMSSRC** (source).

---

## 2. Upload the source

Create the environment first so the source files exist:

```
CALL ADCSETUP        /* after compiling it, or run the CRTLIB/CRTSRCPF by hand */
```

Then upload each member into the matching source physical file in `TEHMSSRC`
(FTP `quote site`, IBM i Access, RDi, or `CPYFRMSTMF`). Member names must match
the table above. Example with FTP:

```
ftp> quote site namefmt 1
ftp> put SMILOGIN /QSYS.LIB/TEHMSSRC.LIB/QCBLLESRC.FILE/SMILOGIN.MBR
```

(If you prefer, compile `ADCSETUP` itself first:
`CRTBNDCL PGM(TEHMSPGM/ADCSETUP) SRCFILE(TEHMSSRC/QCLSRC) SRCMBR(ADCSETUP)`.)

---

## 3. Build everything

```
CRTBNDCL PGM(TEHMSPGM/TEHMSBLD) SRCFILE(TEHMSSRC/QCLSRC) SRCMBR(TEHMSBLD)
CALL     TEHMSPGM/TEHMSBLD
```

`TEHMSBLD` runs the dependency order automatically:

1. `RUNSQLSTM` TEHMSDDL — tables, indexes, view, triggers, procedure, seed
2. `CRTDSPF` / `CRTPRTF` — display and printer files
3. `CRTSQLCBLI ... OBJTYPE(*MODULE)` — the three service modules
4. `CRTSRVPGM CMSUTIL` — bound from the modules, exports via `EXPORT(*SRCFILE)`
5. `CRTBNDDIR TEHMSBND` + `ADDBNDDIRE` — so callers bind to CMSUTIL statically
6. `CRTBNDCBL` / `CRTSQLCBLI ... OBJTYPE(*PGM) BNDDIR(TEHMSBND)` — the programs

`CALL 'CMSSEC'` etc. resolve **statically** to the service program because the
binding directory is supplied at compile time.

---

## 4. Run it

```
CALL TEHMSPGM/SMILOGIN
```

**Sign-on / first-password bootstrap.** The seed creates three users with
*blank* passwords: `ADMIN` (role ADMIN), `MGR01` (MANAGER), `FRONT01`
(FRONTDESK). On the *first* sign-on for a user, whatever password you type is
hashed, salted and stored as that user's password (`CMSSEC` op `AUTH`). After
that it is validated normally; three consecutive failures lock the user
(`REC_STS = 'I'`).

**Walkthrough**

1. Sign on as `ADMIN`, set a password.
2. From the menu choose **1 = Reservations**. Press **F6** to add: enter a
   guest id (`1000`+ if you seed guests, or insert a guest first — see §6),
   category (`DLX`/`EXEC`/`STE`/`PRES`), dates `DDMMYY`, pax, type, advance.
3. Back on the list, type **C** beside a reservation and press Enter (or F13)
   to **check in** — the system allocates the first vacant room in that
   category, marks it occupied, and opens a folio (invoice header).
4. From the menu choose **4 = Billing**. Enter the **Res #** and press Enter to
   load the folio. **F6** adds charge lines (type/desc/qty/rate/GST%); totals
   recompute via `CMSBILL`. **F10** posts a payment. **F11** prints the GST
   tax invoice (`BLRINV` → spooled file).
5. Run **night audit** to post room nights and roll up open folios:
   ```
   SBMJOB CMD(CALL TEHMSPGM/ADCNAUDIT) JOB(NIGHTAUD)
   ```
   Schedule it with `ADDJOBSCDE JOB(NIGHTAUD) CMD(CALL TEHMSPGM/ADCNAUDIT)
   FRQ(*WEEKLY) SCDDAY(*ALL) SCDTIME(030000)`.

---

## 5. Design notes carried from Phase 1

- **5-layer ILE separation.** Screens never touch DB2 directly except for
  read-only inquiry; all writes/business rules sit in the `CMSxxx` service
  procedures bound through `CMSUTIL`.
- **Naming** `MM + T + mnemonic` (≤10). e.g. `RSPRESV` = Reservation /
  Physical, `RSIRESV` = Reservation / Interactive, `RSDRESV` = Reservation /
  Display.
- **Audit columns** `CRT_TS/CRT_USR/UPD_TS/UPD_USR/REC_STS` on every
  transactional table; `UPD_TS` maintained by BEFORE-UPDATE triggers.
- **Commitment control.** Transactional updates run under `COMMIT(*CHG)` with
  explicit `COMMIT`/`ROLLBACK`; inquiry programs do not commit. Because
  `TEHMSDTA` is an SQL **schema**, all tables are journalled automatically.
- **Money** `DECIMAL(13,2)`, **qty** `DECIMAL(11,3)`, **flags** `CHAR(1)`.
- **GST** modelled per line (`DTL_GSTP`); India CGST/SGST/luxury rates seeded in
  `CMPCONFG` for reporting and rate lookups.

---

## 6. Two things to know before go-live

1. **Password hashing is demo-grade.** `CMSSEC.HASH-PASSWORD` is a deterministic
   salted fold so the package is self-contained and runnable. For production,
   replace that one paragraph with the IBM cryptographic services API
   `Qc3CalculateHash` (SHA-256). The salt column and call sites do not change.
2. **Audit insert shares the caller's commit scope.** A rolled-back transaction
   also rolls back its audit row. For tamper-evident logging, run `CMSERROR`
   in a separate activation group / isolated commit. The seed has no guests;
   add one to exercise reservations:
   ```
   INSERT INTO TEHMSDTA/GMPGUEST (GST_NAME, GST_CITY, GST_PHONE, CRT_USR)
   VALUES ('RATAN MEHTA','MUMBAI','9820012345','ADMIN');
   ```

---

## 7. Extending to the full 12-module system

Each remaining module is a clone of this slice:

- **Housekeeping (HK):** `HKPTASK` table, `HKDTASK` subfile screen, `HKITASK`
  program, status updates to `RMPROOM.RM_CLN` — mirrors RSIRESV.
- **Inventory (IV) / HR / Finance (FN):** master + transaction tables, a subfile
  maintenance program, a service module for the business rule, a printer file
  for the document — mirror the Billing trio (`BLPINVHD/DT`, `BLIBILL`,
  `CMSBILL`, `BLRINV`).
- **Reports (RP):** batch COBOL driven by CL + Job Scheduler, writing externally
  described printer files — mirror `ADCNAUDIT` + `BLRINV`.

Drop new members into the same source files, add their compile lines to
`TEHMSBLD`, and the architecture, security, audit and commitment-control
patterns all carry over unchanged.
