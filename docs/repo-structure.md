# Proposed Repository Structure (Monolith, Modular)

```text
/
├─ apps/
│  ├─ web/                      # Next.js UI (learner + educator + admin portals)
│  └─ api/                      # NestJS monolith API
├─ packages/
│  ├─ domain/                   # Shared domain types, rule contracts, enums
│  ├─ ui/                       # Shared React UI components
│  ├─ config/                   # Shared tsconfig/eslint/prettier settings
│  └─ testing/                  # Shared test helpers/fixtures
├─ docs/
│  ├─ product-brief.md
│  ├─ requirements.md
│  ├─ architecture.md
│  ├─ backlog.md
│  ├─ assumptions.md
│  └─ repo-structure.md
├─ infra/
│  ├─ docker/
│  ├─ terraform/                # optional; if infra-as-code is adopted
│  └─ scripts/
├─ database/
│  ├─ schema/                   # Prisma or SQL schema definitions
│  ├─ migrations/
│  └─ seeds/
├─ .github/
│  └─ workflows/                # CI/CD pipelines
├─ tools/
│  ├─ import/                   # legacy data import/validation scripts
│  └─ reporting/                # report generation helpers
├─ README.md
└─ AGENTS.md (optional future local instructions)
```

## Suggested API module directories (`apps/api/src/modules`)
- auth/
- rbac/
- counties/
- program-years/
- cohorts/
- producers/
- curriculum/
- enrollment/
- progress/
- assessments/
- certification/
- reporting/
- audit/
- imports/

## Suggested Web route groups (`apps/web/app`)
- `(auth)/`
- `(learner)/dashboard`
- `(educator)/producers`
- `(educator)/cohorts`
- `(educator)/reports`
- `(admin)/program`
- `(admin)/counties`
- `(admin)/audit`

