# Master Cattleman Modernization — Architecture

## 1) Architectural Principles
1. **Boring technology first**: prefer mature, widely supported tooling over novelty.
2. **Monolith with modules**: one deployable unit, explicit internal boundaries.
3. **Data correctness over feature velocity**: reporting and eligibility decisions must be reproducible.
4. **Security-by-default**: least privilege, county isolation, auditable exceptions.
5. **Legacy continuity**: historical data preservation from long-running program operations.

---

## 2) Recommended Stack (MVP)

## Application
- **Backend**: TypeScript + Node.js + NestJS (modular monolith structure).
  - Why: strong ecosystem, clear module boundaries, DI patterns, widely available talent, good fit for CRUD + domain rules.
- **Frontend**: React + TypeScript + Next.js (App Router) for admin and learner dashboards.
  - Why: mainstream stack, maintainable component architecture, SSR/CSR flexibility.

## Data & Persistence
- **Primary DB**: PostgreSQL.
  - Why: reliable relational modeling, transactional integrity, JSONB for flexible metadata, robust reporting queries.
- **ORM / Query layer**: Prisma (or TypeORM; prefer Prisma for productivity and typed schema workflows).
- **Cache/queue (optional for MVP)**: Redis for job queue and short-lived cache.

## Infra & Ops
- **Containerization**: Docker.
- **Hosting**: single cloud environment (e.g., Azure App Service / AWS ECS / Fly.io equivalent) with managed PostgreSQL.
- **CI/CD**: GitHub Actions with lint/test/migration checks.
- **Observability**: structured logs + metrics (OpenTelemetry-compatible) + error tracking (e.g., Sentry).

### Why this is “boring” and appropriate
- No microservices complexity.
- Widely proven components reduce maintenance risk for a small-to-medium public program team.
- Strong fit for long-lived forms/reporting workloads and deterministic business rules.

---

## 3) Monolith Module Layout
1. **Auth & Identity Module**
2. **RBAC & Permissions Module**
3. **County & Program Admin Module**
4. **CRM (Producer) Module**
5. **Curriculum & Content Access Module**
6. **Enrollment & Progress Module**
7. **Assessment Module**
8. **Certification Rules Engine Module**
9. **Reporting & Export Module**
10. **Audit Log Module**
11. **Data Import/Migration Module**

Each module owns service logic and persistence adapters, while shared domain contracts are versioned within the monolith.

---

## 4) Tenant / Isolation Strategy

### Model
- **Single database, shared schema, row-level partitioning by county**.
- Key records include `county_id` (or derivable county path through cohort/enrollment).
- State Program Admin role bypasses county filter intentionally and explicitly.

### Enforcement
1. Authorization middleware computes effective data scope per request.
2. Repository/query layer applies mandatory scope filters by default.
3. Sensitive queries require explicit “statewide” permission token in service layer.
4. Automated tests validate no cross-county leakage.

### Why this approach
- Lower operational overhead than per-tenant databases.
- Supports statewide reporting with controlled privilege.
- Adequate for expected scale and governance needs.

---

## 5) Authentication Strategy

## MVP
- Local authentication (email + password).
- Password reset with expiring token links.
- Session/JWT approach with short-lived access token + refresh token rotation.

## Optional future
- SSO integration (OSU/Extension identity provider via SAML/OIDC).
- MFA for privileged roles.

---

## 6) Audit Logging Requirements

Audit logs are mandatory for high-risk actions and must be immutable in normal operations.

### Required audited events
1. Role/permission changes.
2. County assignment changes for users.
3. Learner enrollment changes.
4. Curriculum assignment changes (core/elective/assets).
5. Grade/attempt edits and manual overrides (with reason and before/after).
6. Completion status overrides.
7. CSV/report exports (with filter payload and row count).
8. Program year/cohort/county create/update/archive operations.

### Audit event schema (minimum)
- `event_id`
- `timestamp_utc`
- `actor_user_id`
- `actor_role_snapshot`
- `action_type`
- `entity_type`
- `entity_id`
- `county_scope`
- `before_state` (redacted as needed)
- `after_state` (redacted as needed)
- `reason` (required for overrides)
- `request_id` / correlation id

### Audit retention
- Retain for multi-year historical analysis (recommend 7+ years, ideally aligned with OSU policy).
- Logs queryable by authorized admin/auditor roles.

---

## 7) Data Model Highlights
- `users`, `roles`, `user_roles`
- `counties`
- `program_years`
- `cohorts`
- `producers`
- `enrollments`
- `chapters`, `topics`, `assets`
- `cohort_elective_assignments`, `asset_access_rules`
- `session_events`, `hour_credits`
- `quizzes`, `quiz_attempts`, `quiz_rules`
- `certification_evaluations` (derived snapshots for explainable reporting)
- `audit_events`
- `imports`, `import_rows`, `import_errors`

---

## 8) Deterministic Certification Evaluation
Implement a dedicated domain service:
- Inputs:
  - earned core hours
  - earned elective hours
  - earned total hours
  - required quiz pass statuses
- Output:
  - `eligible: boolean`
  - unmet conditions list
  - evaluation timestamp and ruleset version

This enables reproducible historical reporting when policy versions evolve.

---

## 9) Deployment Plan

## Environments
1. **Dev**: shared developer environment.
2. **Staging/UAT**: production-like, includes migrated sample legacy data.
3. **Production**: hardened environment with backup/restore drills.

## Release process
1. PR checks: lint, unit tests, authorization tests, migration validation.
2. Merge to main triggers staging deploy.
3. Manual approval gate for production deployment.
4. Run DB migrations during deploy window with rollback plan.

## Operational safeguards
- Daily backups + tested restore procedure.
- Feature flags for risky admin capabilities.
- Export throttling/rate limits for large data pulls.

---

## 10) Security Notes
- Default deny at route and service layer.
- PII minimized in logs; no raw secrets.
- CSV exports watermarkable and traceable by audit ID.
- Manual override endpoints require elevated permission + reason payload.

