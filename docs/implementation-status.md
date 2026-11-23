# Implementation status register

## Assessment scope

This register describes repository artefacts and user-reported local verification in the ACDT working tree. It does not establish the state of any external private system, production environment, or deployment. No live database, service account, identity provider, deployment, or external provider was accessed to establish implementation status.

Status terms:
- **Present:** file or artefact identified in the reviewed repository state.
- **User-reported local test:** user ran a command locally and supplied its output; not independently executed by this register.
- **Proposed:** documented but not implemented.
- **Not verified:** no evidence supplied or observed establishes the capability.
- **Missing from reviewed repository:** not identified in the reviewed repository state; this is not a claim about external systems.

## Current repository artefacts

The reviewed repository includes:
- `README.md`: project vision and initial information.
- `LICENSE`: MIT License.
- `database/migrations/001_initial_schema.sql`: Original baseline PostgreSQL-oriented schema and sample inserts. RLS is enabled on six tables; in this baseline migration specifically, no explicit `CREATE POLICY` statements were identified. Audit-log rules are defined.
- `database/stage-b-review/`: Local Stage B review package. Four source/package files are recorded in Git commit `70a241b`: migration (`ACDT_Stage_B_01_migration.sql`), bootstrap template (`ACDT_Stage_B_02_first_governor_bootstrap.sql`), security test suite (`ACDT_Stage_B_03_security_tests.sql`), and package README (`ACDT_Stage_B_README.md`). A fifth file, `ACDT_Stage_B_REHEARSAL_ONLY.sql`, is a local generated convenience bundle retained locally and excluded from the published checkout. The four source/package files are committed; the generated rehearsal bundle remains outside version control. This records repository status, not remote publication or independent verification.
- `apps/web/`: reported present as an empty local placeholder directory; no tracked implementation files exist in the audited state.
- `database/seed/`: reported present as an empty local placeholder directory; no seed-data script (such as early proposed `001_synthetic_seed.sql`) is present or tracked. Actual included synthetic fixtures are located in `synthetic_fixtures/fixtures.json` and `synthetic_fixtures/fixtures.sql`.
- `docs/`: project documentation, including architecture, governance, privacy/security, roadmap, implementation status, Phase 2A and supporting design documents.
- `scripts/generate_synthetic_fixtures.py`: Phase 2A generator, reported present in working tree.
- `synthetic_fixtures/fixtures.sql`: Phase 2A SQL fixture, reported present in working tree.
- `synthetic_fixtures/fixtures.json`: Phase 2A JSON fixture, reported present in working tree.
- `tests/test_schema.py`: Phase 2A Python tests, reported present in working tree.
- `ACDT-Link-Verification.ps1`: local documentation-link verification script, reported present in working tree.

The previously supplied Git status showed Phase 2A and Stage B directories/files as untracked. Untracked status does not establish when or by whom they were created. `ACDT_Phase1_Documentation_Review.txt` is an internal review artefact and is intentionally excluded from this public implementation inventory.

Recheck Git status, branch, and file inventory before staging, committing, migration, or implementation work. No such action is authorized by this register.

## Database tables

| Table | Present in migration | Schema represents | Not established |
|---|---|---|---|
| `organizations` | Yes | Organization/tenant identifiers and basic fields | Verified tenancy boundaries, operational management, or access policies |
| `participants` | Yes | Organization relation, pseudonymous identifier, demographic cluster, language, contact-token hash, active flag | Tested pseudonymisation, identity separation, or protection from re-identification |
| `consent_records` | Yes | Protocol reference, consent version, preference flags, status, revocation fields, timestamp, signature-verification hash field | Consent capture, evidence validation, version lifecycle, withdrawal workflow, or enforcement |
| `access_requests` | Yes | Requester, institution, project, purpose, cohort/data-tier fields, status, reviewer fields, expiry | Request workflow, review authority, approval enforcement, or time-limited data access |
| `governance_audit_logs` | Yes | Event-like actor/action/purpose/record-count/IP-hash/metadata/timestamp fields | Complete capture, validated integrity, monitoring, independent review, or tamper-proof guarantees |
| `benefit_sharing_commitments` | Yes | Organization-linked commitment, type, lead partner, target community, status, target date, notes | Operational agreements, verification, feedback, delivery tracking, or public reporting |

## Database controls and validation

- The original baseline migration (`001_initial_schema.sql`) enables RLS on all six tables, but in that baseline migration specifically, no explicit `CREATE POLICY` statements were defined. RLS enablement without appropriate policies is not a complete access-control system.
- `governance_audit_logs` has rules intended to suppress updates and deletes. These alone do not establish a fully validated, cryptographically immutable, or tamper-proof audit system.
- The baseline migration invokes PostgreSQL's `uuid-ossp` extension and uses PostgreSQL-specific types and syntax.
- Sample inserts in the baseline migration are labelled synthetic; synthetic status and provenance must not be inferred solely from labels. The M0.2 assurance review records concerns and restrictions for embedded sample rows.
- The nine reported Python unit tests validate schema definitions and synthetic fixture consistency statically, but do not test live PostgreSQL RLS or database privilege behaviour.

### Stage B development checkpoint (project-owner-reported)

In the Supabase development project `acdt-dev`, the project owner reported the following development checkpoint results:
- The Stage B migration (`ACDT_Stage_B_01_migration.sql`) was committed to the database. (This database COMMIT is distinct from Git commit; the four Stage B source/package files are recorded in Git commit `70a241b`, while the generated rehearsal bundle remains local-only.)
- A transaction-and-rollback security rehearsal reported 52 passing sequential assertions.
- The five checked Stage B tables (`user_profiles`, `org_memberships`, `membership_roles`, `platform_roles`, and `acdt_security.organization_trust`) were confirmed present after commit.
- The first platform governor was appointed using the bootstrap procedure, and the saved role and active profile were verified in a separate query.

**Limits of the Stage B checkpoint:**
- These are project-owner-reported development milestones, not independent security certification, comprehensive audit coverage, or evidence of production readiness.
- The local `apps/web/` directory remains an empty placeholder; end-to-end application sign-in, authentication, and application-layer authorization workflows are not established.
- Complete consent and revocation handling, decision-to-grant consistency, consent-aware data release, and benefit-sharing workflows are not established by the Stage B checks.
- Real participant, health, clinical, or sensitive community research data remains strictly prohibited.

## Phase 2A synthetic fixture work

| Artefact | Status | Evidence/limitation |
|---|---|---|
| `scripts/generate_synthetic_fixtures.py` | Present in working tree | Not independently re-executed for this register |
| `synthetic_fixtures/fixtures.sql` | Present in working tree | Not evidence of a live database or migration |
| `synthetic_fixtures/fixtures.json` | Present in working tree | Not evidence of production data |
| `tests/test_schema.py` | Present in working tree | User supplied local output showing nine tests passed |
| `docs/phase-2a-synthetic-fixture-generator.md` | Present in working tree | Documentation does not establish production security |

### User-reported Python test result

The user supplied this local execution result:

```text
Python 3.11.9
python -m unittest discover -s tests -v
Ran 9 tests in 0.089s
OK
```

Reported test names:
- `test_audit_log_rules`
- `test_column_definitions`
- `test_fixture_counts`
- `test_fixture_markers`
- `test_fixture_sql_json_consistency`
- `test_no_check_constraints`
- `test_no_create_policy`
- `test_rls_enabled`
- `test_table_definitions`

This is a user-reported local result, not an independent execution by this register. It does not demonstrate PostgreSQL installation, migration execution, or database access-control behaviour.

The user also supplied `git diff --check` output with no whitespace errors reported and a benign line-ending warning that `README.md` may be converted from LF to CRLF on a future Git operation.

## Documentation and link verification

The user reported that the local link-verification script completed with exit code 0 and checked 40 local documentation links: 40 valid, zero broken, and zero unverified. The report also stated that all 10 expected documentation files were present and specified relative-path counts matched expected values.

This is user-reported local verification. It does not establish that external URLs, emailed links, production routes, or deployment redirects are valid. The internal documentation review file remains excluded from public links and this register.

## Application and operational components

| Component | Status | Evidence/limitation |
|---|---|---|
| Web application and routes | Missing from reviewed repository | No tracked application source identified; `apps/web/` reported empty placeholder |
| API endpoints and service layer | Missing from reviewed repository | No route handlers, backend service, or API implementation identified |
| Authentication | Database hooks in Stage B; app layer missing | Database-level Auth integration hooks in local Stage B scripts (`auth.users`, `auth.uid()`); application-layer authentication and end-to-end sign-in workflows missing |
| Application authorization | Database roles in Stage B; app layer missing | Database-level role assignments in local Stage B scripts; application-layer authorization logic and UI workflows missing |
| Explicit RLS policies | Partial in Stage B; missing from baseline | Missing from original baseline migration; Stage B introduced additive tables with RLS and security definer RPCs, but complete application-level RLS policies and workflow release controls not established |
| Encryption and key management | Not comprehensively reviewed | Not comprehensively reviewed at this checkpoint; no cryptographic implementation or key lifecycle controls established in repository |
| Pseudonymisation and identity separation | Partial schema representation only | Pseudonymous ID/hash columns exist; no transformation, separate identity store, or operational controls identified |
| Consent and withdrawal | Partial schema representation only | Consent/revocation columns exist; no user or service workflow identified |
| Research access review/enforcement | Partial schema representation only | `access_requests` exists; no review or access-grant workflow identified |
| Audit capture/integrity | Partial schema representation only | Audit table and update/delete rules exist; end-to-end capture and integrity validation not established |
| Benefit-sharing operations | Partial schema representation only | Commitment table exists; no operational tracking or community review established |
| AI integrations | Missing from reviewed repository | No provider, API route, prompt, or safeguard implementation identified |
| Python unit tests | Present in working tree; nine passed in user-reported local run | Does not establish PostgreSQL, authentication, authorization, or production security |
| PostgreSQL security tests | Rehearsal reported in `acdt-dev`; M1 proposed | 52 sequential assertions reported passed in project-owner rollback rehearsal in `acdt-dev`; M1 proposed 24 additional tests; independent verification not performed by this register |
| CI/automated pipeline | Missing from reviewed repository | No CI workflow or test pipeline identified |
| Deployment configuration | Missing from reviewed repository | No deployment manifest or hosting configuration identified |
| Monitoring/incident response | Not reviewed / established | Operational monitoring and incident-response procedures have not been reviewed or established at this checkpoint |
| Retention/deletion/backup/recovery | Not verified / proposed | No operational policy or implementation verified |

## Proposed architecture and design documents

These are design documents, not operational controls:
- `docs/architecture.md`: conceptual web, API/service, and PostgreSQL layers.
- `docs/governance-framework.md`: proposed community-centred governance; no Council or community mandate is established.
- `docs/privacy-and-security.md`: proposed principles; not a security certification.
- `docs/development-roadmap.md`: proposed development direction.
- `docs/supporting-docs/m0-synthetic-fixture-assurance.md`: synthetic fixture assurance review.
- `docs/supporting-docs/m1-database-security-design.md`: proposed database, consent, separation-of-duties, tenant-context, RLS, audit, and future PostgreSQL test design.
- `docs/supporting-docs/phase-2-m0-readiness-review.md`: readiness review.
- `docs/supporting-docs/phase-2-technical-specification.md`: technical specification and protected-link requirements.
- `docs/phase-2a-synthetic-fixture-generator.md`: Phase 2A generator documentation.
- `docs/supporting-docs/phase-2b-2-identity-and-access-control-architecture.md`: proposed Phase 2B.2 design, once separately approved and added.

All proposed controls require appropriate human authority, implementation, testing, and review before they can be described as operational.

## Overall status

The repository is an early-stage project description, baseline PostgreSQL schema artefact, supporting documentation, Phase 2A synthetic-fixture/test work, and local Stage B review package. It is not an operational ACDT platform.

Database structure, documentation, synthetic fixtures, passing Python unit tests, and reported development checkpoints must not be interpreted as working user-facing features, enforceable governance, legal compliance, security certification, production readiness, or proof of a live deployment.

No real participant, health, personal, or community data use is authorized by this register. No live pilot, operational governance body, production consent workflow, authentication service, application authorization service, explicit RLS policy set, trusted identity assertion service, production research-access infrastructure, or cryptographically verified audit system is established.

See [architecture](architecture.md), [governance framework](governance-framework.md), [privacy and security principles](privacy-and-security.md), [development roadmap](development-roadmap.md), and the M1 and Phase 2B.2 supporting designs.

## Change-control note

This register is a documentation artefact. Updating it does not authorize staging, committing, pushing, merging, installing packages, connecting external accounts, deploying, running migrations, or processing real data. Those actions require separate explicit approval.
