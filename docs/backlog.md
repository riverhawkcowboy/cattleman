# Master Cattleman Modernization — Backlog

## 1) Epics → User Stories → Acceptance Criteria

## Epic 1: Identity, RBAC, and County Isolation
### Story 1.1: User can authenticate via local credentials
**As** a user, **I want** to log in securely **so that** I can access authorized features.
- Acceptance Criteria:
  1. Valid credentials create authenticated session.
  2. Invalid credentials are rejected with non-revealing errors.
  3. Password reset flow works with expiring token.

### Story 1.2: System enforces role-based access with default deny
**As** a state admin, **I want** explicit permissions by role **so that** unauthorized actions are blocked.
- Acceptance Criteria:
  1. Unpermitted actions return authorization error.
  2. Role changes are auditable.
  3. New endpoints default to denied until permission mapped.

### Story 1.3: County educators are county-scoped
**As** a county educator, **I want** to view only my county data **so that** privacy boundaries are respected.
- Acceptance Criteria:
  1. County educator cannot query another county’s producers/cohorts.
  2. State admin can view all counties.
  3. Scope exceptions require explicit grant and are audited.

---

## Epic 2: CRM for Producer Records
### Story 2.1: Manage producer profiles
**As** a county educator, **I want** to create/update producer records **so that** participation can be tracked.
- Acceptance Criteria:
  1. Required fields validated.
  2. Status active/inactive supported.
  3. Notes and tags persisted.

### Story 2.2: Track outreach consent/preferences
**As** a county educator, **I want** to capture consent preferences **so that** outreach is compliant.
- Acceptance Criteria:
  1. Consent fields editable by authorized roles.
  2. Consent data appears in filtered exports.

---

## Epic 3: Program Year, County, and Cohort Administration
### Story 3.1: Manage counties
**As** state admin, **I want** to add/edit counties **so that** the system reflects real program structure.
- Acceptance Criteria:
  1. County CRUD available only to state admin.
  2. County changes are audited.

### Story 3.2: Manage program years and cohorts
**As** state admin or county educator, **I want** to create program years/cohorts **so that** enrollment cycles are organized.
- Acceptance Criteria:
  1. Program year lifecycle states enforced.
  2. Cohorts must link to county + program year.
  3. Archived cohorts remain reportable.

---

## Epic 4: Curriculum Assignment and Content Access
### Story 4.1: Auto-assign core chapters on enrollment
**As** county educator, **I want** required core chapters assigned automatically **so that** setup is consistent.
- Acceptance Criteria:
  1. Enrollment triggers core assignment.
  2. Idempotent behavior prevents duplicate assignments.

### Story 4.2: Assign electives by cohort
**As** county educator, **I want** to configure cohort electives **so that** county flexibility is preserved.
- Acceptance Criteria:
  1. Elective assignment applies to all cohort learners.
  2. Assignment changes are versioned and auditable.

### Story 4.3: Restrict access to specific assets
**As** county educator, **I want** to hide/show chapter assets **so that** learners see approved materials only.
- Acceptance Criteria:
  1. Asset access rules evaluated at request time.
  2. Unauthorized assets are not listed or downloadable.

---

## Epic 5: Hours and Progress Tracking
### Story 5.1: Record chapter/session hours
**As** county educator, **I want** to record hours by chapter/event **so that** credit is accurate.
- Acceptance Criteria:
  1. Hours entry supports source type (chapter/session/manual).
  2. Negative or invalid hour entries rejected.

### Story 5.2: Show rollups and remaining requirements
**As** learner, **I want** core/elective/total rollups **so that** I know certification status.
- Acceptance Criteria:
  1. Rollups refresh after relevant activity.
  2. Remaining requirements shown clearly.

---

## Epic 6: Assessments and Overrides
### Story 6.1: Manage quizzes and passing score rules
**As** authorized educator/admin, **I want** to set passing thresholds **so that** standards are configurable.
- Acceptance Criteria:
  1. Quiz linked to topic/chapter.
  2. Passing score configurable per quiz.

### Story 6.2: Track attempts and outcomes
**As** educator/admin, **I want** attempt-level history **so that** progress is evidence-based.
- Acceptance Criteria:
  1. Each attempt stores score and timestamp.
  2. Best/latest pass logic is clearly defined and test-covered.

### Story 6.3: Manual overrides are controlled and audited
**As** state admin, **I want** override capability with reason **so that** exceptions are handled safely.
- Acceptance Criteria:
  1. Override endpoint restricted to authorized roles.
  2. Reason field required.
  3. Before/after audit record created.

---

## Epic 7: Reporting and CSV Export
### Story 7.1: County completion report
**As** county educator, **I want** completion reports **so that** I can manage cohort outcomes.
- Acceptance Criteria:
  1. Report includes completion, hours, scores, eligibility.
  2. Report honors county scope.

### Story 7.2: CSV export with audit trail
**As** reporting analyst, **I want** CSV exports **so that** I can share results externally.
- Acceptance Criteria:
  1. Export available only with permission.
  2. Export action logs filters + row count + actor.

---

## Epic 8: Data Lifecycle and Legacy Migration
### Story 8.1: Import historical data in staging pipeline
**As** state admin, **I want** historical data migrated **so that** program continuity is preserved.
- Acceptance Criteria:
  1. Import job validates schema and logs row-level errors.
  2. Import provenance retained.

### Story 8.2: Archive old cohorts without deleting evidence
**As** state admin, **I want** archival tools **so that** active operations stay clean while history remains accessible.
- Acceptance Criteria:
  1. Archived cohorts hidden from default active views.
  2. Learning records remain intact and reportable.

---

## 2) Delivery Slices

## 2-week MVP slice (Foundation)
**Goal:** establish secure base + core data model + first end-to-end flow.

- Auth (local login/reset) + baseline RBAC.
- Counties, program years, cohorts CRUD (admin scoped).
- Producer CRUD (county scoped).
- Enrollment workflow with auto core assignment.
- Initial audit log framework for critical admin actions.
- Minimal learner progress view with placeholder rollups.

**Definition of Done (2 weeks)**
- County educator can create producer, enroll in cohort, and see assigned core chapters.
- State admin can create county/program year/cohort.
- Access boundary tests pass for cross-county denial.

## 6-week plan (MVP completion)
**Goal:** satisfy hard MVP requirements end-to-end.

- Elective + asset-level access controls.
- Hours capture and rollups (core/elective/total).
- Quiz engine (attempts + passing thresholds).
- Deterministic eligibility evaluator.
- Manual override flow with audited reason.
- County reports + permission-gated CSV export with audit.
- Archiving old cohorts without deleting learning records.
- Consent/preferences and communication list exports.

**Definition of Done (6 weeks)**
- Hard requirements checklist fully met.
- UAT validates deterministic eligibility outputs.
- Audit trail present for all key actions.

## 12-week plan (Post-MVP hardening + expansion prep)
**Goal:** production hardening and future-feature readiness.

- Legacy migration tooling and validation dashboards.
- Performance tuning for reporting and export throughput.
- Enhanced observability (dashboards + alerting).
- Policy/ruleset versioning for future curriculum changes.
- Foundations for badges/micro-credentials (schema + UX placeholders).
- Optional SSO spike and implementation plan.

**Definition of Done (12 weeks)**
- Production runbook complete.
- Migration dry-run with reconciliation reports.
- Prioritized roadmap for nice-to-have features.

