# Master Cattleman Modernization — Requirements

## 1) Functional Requirements

## 1.1 Identity, Authentication, and Authorization
1. The system shall support local username/email + password authentication for MVP.
2. The system shall support password reset using expiring tokens.
3. The system shall enforce RBAC with default deny semantics.
4. The system shall enforce county-level data boundaries for county educators unless explicitly granted cross-county or statewide roles.
5. The system shall allow role assignment and revocation by authorized admins only.

## 1.2 CRM: Producer/Learner Management
1. The system shall provide CRUD for producer records including:
   - Legal/preferred name
   - Contact fields (email, phone, mailing address)
   - Demographics fields (configurable and optional where appropriate)
   - County association
   - Status (active/inactive)
   - Notes (internal)
   - Tags (multi-value)
   - Outreach consent/preferences
2. The system shall track created/updated timestamps and actor identity on producer records.
3. The system shall support list filtering by county, cohort, status, tags, and consent preferences.

## 1.3 Program Structure and Administration
1. The system shall provide CRUD for counties.
2. The system shall provide CRUD for program years with start/end dates and status (planned/active/closed/archived).
3. The system shall provide CRUD for cohorts linked to a county and program year.
4. The system shall support archiving cohorts while preserving learner progress and history.
5. The system shall prevent destructive deletion of records referenced by learning history; archive/inactivate patterns must be used.

## 1.4 Curriculum and Content Access
1. The system shall model curriculum as core chapters and county-selectable electives.
2. The system shall auto-assign required core chapters to each enrolled learner.
3. The system shall allow county educators/admins to assign elective sets by cohort.
4. The system shall allow asset-level restrictions within chapters (e.g., PDF/PPT visible/not visible by cohort).
5. The system shall maintain assignment history for audit and troubleshooting.

## 1.5 Enrollment and Progress Tracking
1. The system shall support learner enrollment into cohorts.
2. The system shall track credit hours per chapter and per event/session attendance entry.
3. The system shall calculate rollups for:
   - Core hours earned
   - Elective hours earned
   - Total hours earned
4. The system shall expose learner progress status and remaining requirement calculations.

## 1.6 Assessments and Completion Rules
1. The system shall support quizzes/tests associated with chapters/topics.
2. The system shall support configurable passing score thresholds.
3. The system shall track each assessment attempt with timestamp and score.
4. The system shall support authorized manual overrides for grades/completion.
5. The system shall require a reason for manual override and shall log before/after values.
6. The system shall determine certificate eligibility deterministically using:
   - At least 16 core hours
   - At least 12 elective hours
   - At least 28 total hours
   - Passing required quizzes/topics

## 1.7 Reporting and Exports
1. The system shall provide county-scoped reporting for:
   - Completion status
   - Hours earned (core/elective/total)
   - Quiz scores/grades
   - Certificate eligibility
2. The system shall allow CSV export of report results for authorized roles.
3. The system shall store export audit data (actor, timestamp, filters, row count, file hash/checksum if feasible).

## 1.8 Communications Support
1. The system shall support filtered list exports for communications by county/cohort/status/tags/consent.
2. The system shall enforce consent preference filters where configured.
3. The system shall not send email directly in MVP (export-first approach), but must preserve fields needed for future integrated messaging.

## 1.9 Legacy Data and Migration Support
1. The system shall support import staging for historical records dating back to at least 2004.
2. The system shall preserve provenance for imported records (source file/date/operator).
3. The system shall provide validation reports identifying invalid or incomplete imported rows.

---

## 2) Non-Functional Requirements

## 2.1 Security
1. RBAC with default deny and least privilege.
2. Strong password policy and secure hashing.
3. Session security with inactivity timeout.
4. Sensitive action protection (CSRF defenses where applicable).
5. Audit logs must be immutable to standard application users.

## 2.2 Privacy and Compliance
1. Personally identifiable information shall be restricted by role and county scope.
2. Export capabilities must be permission-gated and auditable.
3. Consent/preferences fields must be persisted and available for filtering.
4. Data retention/archival policy shall support long-lived program history without uncontrolled access.

## 2.3 Reporting Accuracy and Explainability
1. Eligibility calculations must be deterministic and reproducible.
2. Every reported eligibility state should be explainable by component conditions (core/elective/total/quiz).
3. Report filters and generation metadata shall be retained for traceability.

## 2.4 Performance & Scalability (MVP target)
1. Typical county report requests should return in <10 seconds for expected cohort sizes.
2. Learner dashboard load should be <2 seconds at P95 under normal load.
3. CSV exports should stream for large datasets to avoid timeouts.

## 2.5 Reliability
1. Daily automated backups for primary data store.
2. Point-in-time recovery target defined for production.
3. No hard deletes for learning evidence records.

## 2.6 Maintainability
1. Monolith architecture with clear internal modules and boundaries.
2. Business rules centralized in domain services, not duplicated in UI.
3. Database migrations version-controlled.
4. Test coverage for certification logic and authorization boundaries.

## 2.7 Observability
1. Structured application logs with correlation IDs.
2. Operational dashboards for errors, job outcomes, and report latency.
3. Audit event query capability for compliance investigations.

---

## 3) Role-Based Permissions Matrix (MVP)

Legend:
- ✅ Allowed
- ➖ Not applicable
- ❌ Denied
- * Scoped to county unless explicitly granted broader scope

| Capability | Producer/Learner | County Educator* | State Program Admin | Reporting Analyst |
|---|---:|---:|---:|---:|
| Log in / manage own password | ✅ | ✅ | ✅ | ✅ |
| View own profile/progress | ✅ (self only) | ✅ (assigned learners) | ✅ | ✅ (read-only reporting views) |
| Create/edit producer records | ❌ | ✅* | ✅ | ❌ |
| Add notes/tags on producer | ❌ | ✅* | ✅ | ❌ |
| Manage outreach consent fields | ❌ | ✅* | ✅ | ❌ |
| Manage counties | ❌ | ❌ | ✅ | ❌ |
| Manage program years | ❌ | ❌ | ✅ | ❌ |
| Manage cohorts | ❌ | ✅* | ✅ | ❌ |
| Enroll learners into cohorts | ❌ | ✅* | ✅ | ❌ |
| Assign electives/assets | ❌ | ✅* | ✅ | ❌ |
| Auto-assign core (system action) | ➖ | ➖ | ➖ | ➖ |
| Record attendance/session hours | ❌ | ✅* | ✅ | ❌ |
| Manage quizzes/pass thresholds | ❌ | ✅* (if granted curriculum manager permission) | ✅ | ❌ |
| Enter assessment scores/attempts | ❌ | ✅* | ✅ | ❌ |
| Manual override (grade/completion) | ❌ | ✅* (explicit permission only) | ✅ | ❌ |
| View county reports | ❌ | ✅* | ✅ | ✅ (as granted) |
| Export CSV reports | ❌ | ✅* (permission-gated) | ✅ | ✅ (permission-gated) |
| View audit log | ❌ | Limited* | ✅ | Limited read-only |
| Modify roles/permissions | ❌ | ❌ | ✅ | ❌ |
| Archive cohorts | ❌ | ❌ | ✅ | ❌ |

### Permission Notes
1. County Educator access is county-scoped by default.
2. Manual overrides require an explicit sub-role/permission and mandatory reason capture.
3. Reporting Analyst is read-only except export rights when granted.
4. State Program Admin has statewide authority and governance responsibilities.

