# Taj Enterprise Hotel Management System (TEHMS) - IBM i

[span_2](start_span)[span_3](start_span)This repository houses the design and implementation of the Taj Enterprise Hotel Management System (TEHMS), a comprehensive, enterprise-grade hospitality solution tailored for the Taj Hotel Mumbai[span_2](end_span)[span_3](end_span). [span_4](start_span)[span_5](start_span)Built natively for the IBM i (AS/400) platform, it utilizes a strictly layered architecture separating presentation, business logic, and database operations[span_4](end_span)[span_5](end_span).

## Technology Stack

* **[span_6](start_span)Platform:** IBM i (AS/400)[span_6](end_span)
* **[span_7](start_span)Programming Language:** ILE COBOL / COBOL400 (using Free Format where possible)[span_7](end_span)
* **[span_8](start_span)[span_9](start_span)[span_10](start_span)Database:** DB2 for i (utilizing embedded SQL, triggers, and stored procedures)[span_8](end_span)[span_9](end_span)[span_10](end_span)
* **[span_11](start_span)[span_12](start_span)User Interface:** DDS Display Files (featuring subfiles and window screens)[span_11](end_span)[span_12](end_span)
* **[span_13](start_span)Reporting:** Printer DDS[span_13](end_span)
* **[span_14](start_span)Batch Operations:** Control Language (CL) Programs and IBM Job Scheduler[span_14](end_span)

## System Architecture

The application enforces a rigorous layered architecture to ensure modularity and maintainability:
* **[span_15](start_span)Presentation Layer:** 5250 interactive screens defined via DDS[span_15](end_span).
* **[span_16](start_span)Business Layer:** Modular ILE COBOL programs handling core business rules[span_16](end_span).
* **[span_17](start_span)[span_18](start_span)[span_19](start_span)Database Layer:** DB2 SQL tables with enforced primary/foreign keys, constraints, and journaling support[span_17](end_span)[span_18](end_span)[span_19](end_span).
* **[span_20](start_span)Utilities & Copybooks:** Centralized copybooks and reusable service programs for common routines[span_20](end_span).

## Core Modules

The system spans 12 major operational areas:
1. **[span_21](start_span)Login Management:** Role-based security, profile management, and audit logging[span_21](end_span).
2. **[span_22](start_span)Reservation System:** Walk-in, online, corporate, and group bookings with waitlist capabilities[span_22](end_span).
3. **[span_23](start_span)Guest Management:** Registration, check-in/out, VIP tracking, and loyalty member handling[span_23](end_span).
4. **[span_24](start_span)Room Management:** Allocation, maintenance blocking, and real-time availability tracking[span_24](end_span).
5. **[span_25](start_span)Billing System:** Consolidated invoicing (room, restaurant, spa, laundry) with GST calculation and split bills[span_25](end_span).
6. **[span_26](start_span)Restaurant Management:** Table reservations, kitchen orders, and inventory[span_26](end_span).
7. **[span_27](start_span)Housekeeping:** Daily cleaning tracking, inspections, and lost & found[span_27](end_span).
8. **[span_28](start_span)Inventory Management:** Purchase orders, goods receipt, expiry tracking, and vendor management[span_28](end_span).
9. **[span_29](start_span)HR Module:** Employee master, attendance, payroll, and shift management[span_29](end_span).
10. **[span_30](start_span)Finance:** Accounts receivable/payable, general ledger, and daily/month-end closing[span_30](end_span).
11. **[span_31](start_span)Reports:** Occupancy, revenue, guest history, and management dashboards[span_31](end_span).
12. **[span_32](start_span)Administration:** Master data configuration, backup/restore routines, and system auditing[span_32](end_span).

## Project Scope & Scale

[span_33](start_span)This is a massive enterprise undertaking designed to yield over 10,000 lines of production-ready COBOL code[span_33](end_span). The targeted object counts include:
* [span_34](start_span)~100 COBOL Programs[span_34](end_span)
* [span_35](start_span)~60 Database Tables[span_35](end_span)
* [span_36](start_span)~50 SQL Procedures[span_36](end_span)
* [span_37](start_span)~40 Display Files[span_37](end_span)
* [span_38](start_span)~25 CL Programs[span_38](end_span)
* [span_39](start_span)~20 Printer Files & Copybooks[span_39](end_span)

## Development Phasing

The project is built and structured in sequential phases:
* **[span_40](start_span)Phase 1:** Overall Architecture, module breakdown, and library structuring[span_40](end_span).
* **[span_41](start_span)Phase 2:** Database Design (SQL DDL for tables, keys, and indexes)[span_41](end_span).
* **[span_42](start_span)Phase 3:** Display Files generation[span_42](end_span).
* **[span_43](start_span)Phase 4:** Copybooks creation[span_43](end_span).
* **[span_44](start_span)Phase 5:** Phased COBOL Program generation (producing ~300-500 line modular, compilable components)[span_44](end_span).
