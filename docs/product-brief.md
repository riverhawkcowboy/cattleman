# Master Cattleman Modernization — Product Brief

## 1) Product Vision
Build a modern, explainable, county-aware CRM + LMS platform for OSU Extension’s Master Cattleman program that replaces the legacy ASP + SQL Server application while preserving long-running program history and enabling future expansion.

The product must:
- Track certification progress deterministically against program rules.
- Support county-led flexibility for electives and cohorts.
- Give educators and administrators operational tools that are currently missing (program years, counties, cleanup/archiving, controlled overrides, exports, and audited administration).
- Prioritize data integrity and reporting correctness over feature novelty.

---

## 2) Program Rules (authoritative requirements)
The system enforces these rules for certification:
1. Certification requires **28 total credit hours**.
2. Curriculum is **county-run and flexible**.
3. Curriculum structure is:
   - **16 required core hours** across six disciplines.
   - **12 elective hours** selected at county level.
4. Learners demonstrate comprehension via **passing quizzes** associated with topics.

---

## 3) Personas

### Persona A: Producer / Learner
**Profile**
- Adult learner enrolled through county extension programming.
- Accesses assigned materials, attends sessions, takes quizzes, and monitors own progress.

**Primary needs**
- Clear visibility into required vs elective progress.
- Access only to relevant chapters/assets for enrolled program year/cohort.
- Confidence in completion status and certificate eligibility.

**Pain points today**
- Opaque progress status.
- Potential inconsistency in records across years/counties.

---

### Persona B: County Educator
**Profile**
- Runs county cohorts, supports learners, tracks attendance/hours, manages communications.
- Needs county-scoped admin and reporting tools.

**Primary needs**
- Manage learners, cohorts, assignments, and outcomes for their county.
- Apply limited administrative corrections (e.g., attendance/grade override) with clear audit history.
- Export communication and performance lists.

**Pain points today**
- Legacy system lacks robust admin workflows.
- County maintenance (add/edit counties, new years) is brittle.

---

### Persona C: State Program Admin
**Profile**
- Oversees statewide program quality, policy enforcement, and data governance.

**Primary needs**
- Manage global program entities (years, county setup, curricula templates, permissions).
- Ensure deterministic rule enforcement and auditability.
- Support legacy data continuity and retention.

**Pain points today**
- Operational maintenance is fragile and high-risk.
- Limited observability into changes and exceptions.

---

### Persona D: Reporting Analyst
**Profile**
- Produces county/state reporting extracts for outcomes, compliance, and program planning.

**Primary needs**
- Trusted, explainable reporting sources.
- Repeatable exports with known filters and audit trace.
- Clear data definitions across hours, completion, and eligibility.

**Pain points today**
- Inconsistent data shape and manual reconciliation.

---

## 4) Jobs-to-be-Done (JTBD)

### Producer / Learner
1. **When I log in**, I want to see my assigned core/elective content and current earned hours so I know exactly what remains for certification.
2. **When I complete a chapter/topic quiz**, I want my status and eligibility to update predictably so I can trust my progress.
3. **When county offerings vary**, I want only relevant electives/assets visible so I am not confused by unavailable material.

### County Educator
1. **When a new cohort starts**, I want to enroll producers and auto-assign required core chapters so setup is fast and consistent.
2. **When county electives are selected**, I want to assign elective packages by cohort so learners see correct content.
3. **When correcting records**, I want authorized override workflows that are simple and always audited.
4. **When I communicate with participants**, I want filtered export lists by county/cohort/status/tags/consent.

### State Program Admin
1. **When a new program year begins**, I want to create it without engineering intervention.
2. **When governance changes occur**, I want role and county access controls updated safely with audit trails.
3. **When data gets stale**, I want archiving/cleanup capabilities that preserve learning history.

### Reporting Analyst
1. **When I run county or statewide reporting**, I want accurate completion/hours/score outputs with filter metadata.
2. **When exports are shared**, I want reproducible CSV output tied to who exported and when.

---

## 5) MVP Scope vs Out-of-Scope

## In-Scope MVP
1. **Identity & Access**
   - Local auth (email/password + reset flow) and RBAC with default deny.
   - County boundary enforcement for educator visibility.
2. **CRM Fundamentals**
   - Producer profile CRUD: demographics, contact info, county, active/inactive status, notes, tags, outreach consent/preferences.
3. **Program Structure Admin**
   - Program years CRUD.
   - Cohorts CRUD and county association.
   - Counties CRUD (fix legacy gap).
4. **LMS Assignment & Access**
   - Auto-assignment of required core chapters.
   - County cohort elective assignment.
   - Asset-level access restrictions inside chapters.
5. **Hours & Certification Engine**
   - Track chapter/session hours.
   - Rollup core vs elective vs total hours.
   - Deterministic certificate eligibility evaluation against 16 core + 12 elective + total 28 + quiz pass requirements.
6. **Assessments**
   - Quiz management per chapter/topic.
   - Configurable passing scores.
   - Attempt tracking.
   - Authorized manual overrides with immutable audit events.
7. **Reporting & Exports**
   - County reports for progress, hours, scores, eligibility.
   - CSV export permission-gated and audited.
8. **Data Lifecycle**
   - Archive/cleanup old cohorts without deleting completion history.

## Out-of-Scope for MVP
- Public-facing course catalog.
- Payment processing.
- Full self-enrollment flows.
- Full badges/micro-credentials engine (plan-ready only).
- Advanced marketing automation beyond export-oriented communication lists.

---

## 6) Success Metrics

### Adoption & Operations
- ≥90% of active counties onboarded in first program cycle.
- New program year setup completed by admins in <30 minutes without engineering support.
- County creation/edit workflow completed in <5 minutes.

### Data Quality & Trust
- 0 critical discrepancies in certification eligibility between system output and policy rules in UAT.
- <1% records needing manual correction after migration validation.
- 100% of manual overrides and CSV exports have audit entries.

### Learner Progress & Experience
- ≥95% of active learners can view current progress without educator intervention.
- Median educator time to enroll and assign a learner reduced by 50% from legacy baseline.

### Reporting
- County completion report generation under 10 seconds for typical county cohort volume.
- CSV export reproducibility: identical filters produce identical result sets within same data version.

---

## 7) Risks and Mitigations
- **Legacy data variability (since 2004)** → Build import staging + mapping validation reports.
- **Policy exceptions/manual fixes** → Controlled override permissions + mandatory reason + audit trail.
- **Cross-county data leakage risk** → Enforce row-level county scope in service and query layers; test access boundaries.
- **Reporting distrust** → Publish metric definitions and deterministic eligibility explanation per learner.

