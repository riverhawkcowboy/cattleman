# Master Cattleman Modernization — Assumptions

1. Program rule baseline is fixed for MVP: 16 core hours + 12 elective hours + 28 total + passing quizzes.
2. County flexibility applies to elective selection and local delivery cadence, not to minimum statewide certification thresholds.
3. Existing legacy data quality is heterogeneous; migration will require mapping and validation steps rather than direct one-shot import.
4. Program records dating to at least 2004 are in scope for retention, though not all historical fields must be immediately editable in MVP.
5. Local authentication is acceptable for MVP; SSO is optional and can be phased in later.
6. County educators generally operate within one county; cross-county permissions are rare and must be explicit.
7. Communication capability in MVP is export-first (CSV lists), not full outbound campaign sending.
8. Quiz authoring complexity (question banks, randomization, proctoring) is out of MVP unless already trivial in existing content.
9. Deterministic eligibility logic is treated as a domain service with versioning support to preserve explainability over time.
10. “Manual override” use cases are necessary for operational reality and must be constrained by role + reason + audit.
11. Archiving means removing from default active workflows while preserving all learning evidence and reportability.
12. County, cohort, and program-year administration must be self-service for admins without engineering intervention.
13. Reporting analyst role is read-only except explicitly granted export capability.
14. Sensitive PII handling will follow least privilege and institutional data handling expectations; exact compliance mappings can be finalized during implementation.
15. Monolith architecture is preferred to reduce operational overhead and accelerate delivery for current team size.
16. Badges/micro-credentials, public catalog, self-enrollment, and payments are roadmap items, not MVP deliverables.
17. Asset-level restrictions are required within chapters because not all supporting files are appropriate for all cohorts.
18. Event/session-based hours may be entered manually by educators in MVP where integrations do not exist.
19. CSV export audit metadata should include actor, filter criteria, timestamp, and row count; cryptographic file hash is recommended but optional if time-constrained.
20. This document captures current assumptions and should be updated as discovery clarifies policy or operational constraints.

