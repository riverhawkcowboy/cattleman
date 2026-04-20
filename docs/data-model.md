# Master Cattleman Modernization — Data Model

## 1) Modeling Goals
- Keep reporting paths explicit and SQL-friendly (county, cohort, program year, hours, scores, eligibility).
- Keep critical evidence immutable where required (`assessment_attempts`, `earned_credits`, `audit_logs`).
- Support county boundaries now and multi-county educator assignments later.
- Preserve deterministic eligibility outcomes with explainable components.

---

## 2) Table List (Key Fields)

All tables include: `id`, `created_at`, `updated_at`.

## 2.1 Identity & Access
1. `users`
   - `email` (unique), `password_hash`, `status`, `last_login_at`
2. `roles`
   - `name` (unique), `description`
3. `permissions`
   - `code` (unique), `description`
4. `role_permissions`
   - `role_id`, `permission_id` (unique pair)
5. `user_roles`
   - `user_id`, `role_id` (unique pair)
6. `user_county_access`
   - `user_id`, `county_id`, `scope` (`primary`, `secondary`, `supervisory`) for multi-county educators

## 2.2 Geographic / Program Structure
1. `counties`
   - `name`, `code` (unique), `active`
2. `program_years`
   - `label` (e.g., 2026), `start_date`, `end_date`, `status`
3. `cohorts`
   - `county_id`, `program_year_id`, `name`, `status`, `start_date`, `end_date`

## 2.3 CRM
1. `organizations` (optional affiliation)
   - `name`, `organization_type`, `county_id` (nullable)
2. `persons`
   - producer/contact profile fields: name, demographics, email, phone, address, `county_id`, `organization_id`, `status`
3. `person_notes`
   - immutable operational notes/interactions: `person_id`, `author_user_id`, `note_type`, `body`
4. `tags`
   - `name` (unique), `category`
5. `person_tags`
   - `person_id`, `tag_id` (unique pair)
6. `consents`
   - `person_id`, `consent_type`, `status`, `source`, `effective_at`, `expires_at`

## 2.4 Enrollment
1. `enrollments`
   - `person_id`, `cohort_id`, `status`, `enrolled_at`, `completed_at`, `completion_override_reason`

## 2.5 Curriculum
1. `disciplines`
   - `name` (unique), `is_core` (true for the six required core disciplines)
2. `chapters`
   - `discipline_id`, `code` (unique), `title`, `chapter_type` (`core`/`elective`), `active`
3. `chapter_credit_hours`
   - `chapter_id`, `hours`, `effective_start`, `effective_end` (versionable defaults)
4. `assets`
   - `chapter_id`, `title`, `asset_type` (pdf/ppt/video/link), `storage_url`, `active`
5. `cohort_chapter_assignments`
   - `cohort_id`, `chapter_id`, `assignment_type` (`core_auto`,`elective`,`manual`)
6. `cohort_asset_access`
   - `cohort_id`, `asset_id`, `is_visible`

## 2.6 Assessments
1. `quizzes`
   - `chapter_id`, `title`, `active`
2. `quiz_thresholds`
   - `quiz_id`, `passing_score`, `effective_start`, `effective_end`
3. `questions`
   - `quiz_id`, `prompt`, `question_type`, `position`, `active`
4. `assessment_attempts` (immutable)
   - `quiz_id`, `person_id`, `enrollment_id`, `attempt_no`, `started_at`, `submitted_at`, `score`, `max_score`, `passed`
5. `attempt_answers` (optional immutable evidence)
   - `attempt_id`, `question_id`, `answer_payload`, `is_correct`, `awarded_points`

## 2.7 Progress / Credits
1. `earned_credits` (immutable)
   - `person_id`, `enrollment_id`, `chapter_id` (nullable), `credit_source` (`chapter`,`session`,`manual_override`), `hours_earned`, `awarded_at`, `awarded_by_user_id`, `source_ref`, `reason`
2. `certification_rule_sets`
   - stores deterministic requirements (`required_core_hours=16`, `required_elective_hours=12`, `required_total_hours=28`, `required_core_disciplines=6`)
3. `certification_evaluations`
   - derived snapshots by person/enrollment/ruleset: `core_hours`, `elective_hours`, `total_hours`, `core_disciplines_met_count`, `quiz_requirements_met`, `eligible`, `unmet_conditions_json`, `evaluated_at`

## 2.8 Reporting / Export
1. `report_exports`
   - `export_type`, `requested_by_user_id`, `county_id` (nullable statewide), `filter_json`, `row_count`, `file_uri`, `file_checksum`

## 2.9 Audit
1. `audit_logs` (immutable)
   - `actor_user_id`, `action`, `object_type`, `object_id`, `county_id`, `before_json`, `after_json`, `reason`, `occurred_at`, `request_id`

---

## 3) Relationship Summary
- `counties 1—N cohorts`, `counties 1—N persons`, `counties 1—N organizations`.
- `program_years 1—N cohorts`.
- `persons N—N tags` via `person_tags`.
- `persons 1—N person_notes`, `persons 1—N consents`, `persons 1—N enrollments`.
- `cohorts 1—N enrollments`.
- `disciplines 1—N chapters`; `chapters 1—N assets`; `chapters 1—N quizzes`; `chapters 1—N chapter_credit_hours`.
- `cohorts N—N chapters` via `cohort_chapter_assignments`.
- `cohorts N—N assets` via `cohort_asset_access`.
- `quizzes 1—N questions`, `quizzes 1—N quiz_thresholds`, `quizzes 1—N assessment_attempts`.
- `assessment_attempts 1—N attempt_answers`.
- `enrollments 1—N earned_credits`, `persons 1—N earned_credits`.
- `certification_rule_sets 1—N certification_evaluations`; `enrollments 1—N certification_evaluations`.
- `users N—N roles` via `user_roles`; `roles N—N permissions` via `role_permissions`; `users N—N counties` via `user_county_access`.

---

## 4) Requirements Logic in Data Model
1. Core/elective/total requirements are represented in `certification_rule_sets`.
2. Core discipline breadth is measurable from chapter discipline linkage and earned credits.
3. Quiz pass/fail is computed from immutable attempts + active threshold version, then persisted in evaluation snapshots.
4. Eligibility is derived, explainable, and reproducible via `certification_evaluations` + ruleset version.

---

## 5) Index Strategy (Reporting-first)

## 5.1 High-value composite indexes
- `enrollments (cohort_id, status, person_id)`
- `cohorts (county_id, program_year_id, status)`
- `persons (county_id, status, last_name, first_name)`
- `earned_credits (enrollment_id, awarded_at)` and `(person_id, awarded_at)`
- `assessment_attempts (person_id, quiz_id, submitted_at desc)`
- `certification_evaluations (enrollment_id, evaluated_at desc)`
- `report_exports (requested_by_user_id, created_at)`
- `audit_logs (county_id, occurred_at desc)` and `(actor_user_id, occurred_at desc)`

## 5.2 Uniqueness and integrity indexes
- `counties.code` unique
- `program_years.label` unique
- `chapters.code` unique
- `(user_id, role_id)` on `user_roles`
- `(role_id, permission_id)` on `role_permissions`
- `(person_id, tag_id)` on `person_tags`
- `(cohort_id, chapter_id)` on `cohort_chapter_assignments`
- `(cohort_id, asset_id)` on `cohort_asset_access`

## 5.3 Partitioning guidance (future)
- If data volume grows materially, partition `audit_logs`, `assessment_attempts`, and `earned_credits` by time (e.g., yearly).

---

## 6) Data Retention & Audit Approach
1. `assessment_attempts`, `earned_credits`, and `audit_logs` are append-only evidence tables.
2. Corrections are represented by compensating records (e.g., manual override credit entries), not destructive updates.
3. Cohort archiving updates cohort status; does not remove enrollment/credits/attempts.
4. Export actions recorded both in `report_exports` and `audit_logs`.
5. Retention baseline:
   - Learning and certification evidence: retained long-term (7+ years minimum, policy-aligned).
   - Audit logs: long-term retention with queryable access controls.

---

## 7) Why This Model Avoids Over-Polymorphism
- Primary entities are explicit tables (person, cohort, chapter, quiz, attempt, credit).
- Source-specific evidence uses constrained enums (`credit_source`, `assignment_type`) rather than generic polymorphic blobs.
- JSON is reserved for audit before/after snapshots and structured filter/unmet-condition metadata where schema fluidity is useful.

