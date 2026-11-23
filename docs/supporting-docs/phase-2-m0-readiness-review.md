# ACDT Phase 2 M0 Readiness Review

**Review date:** 2026-11-13

**Project state:** Early-stage; proposed controls and workflows are not implemented unless explicitly stated otherwise.

## 1. Executive summary

**Recommendation: READY FOR M1 DESIGN WITH CONDITIONS.**

The repository is suitable for the next design-only milestone: resolving the data model, authorization boundaries, audit events, synthetic fixtures, and test cases. The Phase 2 specification describes important proposed controls, but it does not demonstrate that those controls exist in an application or database.

There is no evidence in the repository of a verified backup that includes the current modified and untracked work, or of a restore test. The migration contains sample rows labelled synthetic, but their provenance cannot be established from repository contents alone. Do not treat those rows as verified synthetic fixtures or use them in a demonstration until they are verified or replaced with unmistakably fictional data.

Proceeding to M1 must not be interpreted as approval to create or execute migrations, load real data, connect to a live service, deploy, or conduct a research pilot. Before any migration is created or executed, preserve and verify the working state, settle the outstanding design decisions below, and confirm the protected-link inventory.

## 2. Scope and method

This review covers the repository working tree and the following material:

- [README.md](../../README.md)
- ACDT_Phase1_Documentation_Review.txt
- [architecture.md](../architecture.md)
- [governance-framework.md](../governance-framework.md)
- [privacy-and-security.md](../privacy-and-security.md)
- [development-roadmap.md](../development-roadmap.md)
- [implementation-status.md](../implementation-status.md)
- [phase-2-technical-specification.md](phase-2-technical-specification.md)
- [001_initial_schema.sql](../../database/migrations/001_initial_schema.sql)

The review was read-only with respect to the existing project files. It did not execute SQL, inspect email systems, check live URLs, connect to an external service or database, or establish the provenance of any sample value.

## 3. Verified repository structure and Git state

Before this report was added, the repository had one PostgreSQL migration, six documentation files under `docs`, a README, and the untracked Phase 1 review export. This report brings the documentation count to seven. The `database/seed` directory and `apps/web` directory contain no files. No application source, explicit test suite, or separate seed script was found in the inspected project tree.

**Branch:** `acdt-phase1-foundation`

**Latest commit:** `21ce683 chore: remove web showcase page from open-source ACDT repository`

Git status before creating this report:

```text
## acdt-phase1-foundation
 M README.md
?? ACDT_Phase1_Documentation_Review.txt
?? docs/architecture.md
?? docs/development-roadmap.md
?? docs/governance-framework.md
?? docs/implementation-status.md
?? docs/phase-2-technical-specification.md
?? docs/privacy-and-security.md
```

The README has pre-existing tracked modifications. The Phase 1 export and listed documentation files are pre-existing untracked work. The latest commit does not include those current changes.

## 4. Backup and recovery assessment

**Finding — NOT VERIFIED:** No backup/archive file or backup/archive directory was found inside the repository. No restore test or external backup location was verified.

The current working state therefore cannot be confirmed as backed up or recoverable as a whole. Git can provide the committed baseline, but that is not a backup of the modified README or the untracked files listed above. A backup outside this repository may exist, but was not inspected.

Before creating or executing a migration, the project owner should approve a backup that includes the complete repository working state, including modified and untracked files, and a restore verification. No backup was created as part of this review.

## 5. Protected-link inventory

The following exact URLs are known protected links. They were found in the repository working tree, including the README, Phase 1 review export, and Phase 2 specification.

| Exact URL | Repository locations | Assessment |
|---|---|---|
| `https://github.com/danyemaisolutions-a11y/africa-community-data-trust` | [README.md](../../README.md), ACDT_Phase1_Documentation_Review.txt, [phase-2-technical-specification.md](phase-2-technical-specification.md) | Repository destination; preserve exactly. |
| `https://danyem-ai-solutions.vercel.app` | [README.md](../../README.md), ACDT_Phase1_Documentation_Review.txt, [phase-2-technical-specification.md](phase-2-technical-specification.md) | Existing site destination; preserve exactly. Live availability was not checked. |
| `https://danyem-ai-solutions.vercel.app/contact?topic=acdt-partnership` | [README.md](../../README.md), ACDT_Phase1_Documentation_Review.txt, [phase-2-technical-specification.md](phase-2-technical-specification.md) | Existing contact destination and query string; preserve exactly. Live availability was not checked. |

No other absolute HTTP(S) URL strings were found in the reviewed repository working-tree files. This is **not** an exhaustive inventory of links distributed by email or through other channels. Absence from the repository does not establish that a URL is unused. Email and other distribution records were not inspected, and no link was tested or changed.

**Action:** Before any routing, architecture, or deployment change, confirm the full distributed-link inventory with the project owner. Preserve each exact hostname, path, and query string; if preservation cannot be established, stop and escalate rather than changing the URL.

## 6. Embedded sample data and provenance

The migration contains sample inserts labelled synthetic. That label is not independently verifiable evidence of provenance. The repository does not establish whether the realistic-looking values were invented, copied, or adapted from real entities or communities.

| Sample-value category | Assessment | Required action before reuse |
|---|---|---|
| Organization name and registration-style value | **Ambiguous / potentially misleading.** Their fictional status and relationship to real organizations cannot be established from the files. | Verify provenance or replace with clearly fictional, non-resolvable values. |
| Partner/funder names and community or location labels | **Ambiguous / potentially misleading.** Names may resemble real entities or communities; the migration alone cannot establish whether they are real. | Verify provenance or replace; do not imply actual participation or partnership. |
| Participant-style IDs and demographic/cohort labels | **Potentially misleading.** Synthetic-looking IDs and generic labels do not prove that records or categories are wholly fabricated. | Verify the fixture-generation process and document it; avoid realistic identifiers. |
| Consent signature/hash-like sample values | **Potentially misleading.** Static values do not demonstrate a signing, verification, or consent workflow. | Use clearly invalid test-only placeholders and ensure they cannot be mistaken for evidence of consent. |

No participant names or direct contact details were observed in the embedded sample rows. This limited observation does not establish that all values are synthetic or safe. No separate seed files were found; the migration's embedded inserts are the sample data source identified in this review.

**Recommendation:** Before any demo or data load, replace or independently verify every ambiguous fixture. Use unmistakably fictional organizations, locations, and identifiers, with provenance documented. Do not use real participant, health, or personal data.

## 7. M0 decision register

The Phase 2 specification contains proposed requirements; the items below distinguish those documented proposals from unresolved design choices and absent implementation.

| Area | Documented proposal or repository evidence | Decision still required for M1 |
|---|---|---|
| Governance and authority | The documentation describes an early-stage project. The proposed Community Governance Council is not established; no research pilot is approved or operational. DanYem is not the sole authority for community data or research approval. | Identify the accountable community, governance, legal, research-ethics, and data-protection reviewers and their authority before any real-world use. Obtain qualified Nigerian legal, data-protection, research-ethics, and community review. |
| Separation of duties | The Phase 2 specification proposes different individuals and individually assigned accounts for requester, governance reviewer, and technical operator, with server-side enforcement and recorded actors. These roles are not evidence of appointed people or implemented controls. | Define how distinct individuals and role authorization will be established. Two accounts for one person or shared accounts must not satisfy separation; if separation cannot be established, deny the grant. |
| Consent and withdrawal | The specification distinguishes consent granted, withdrawal pending, withdrawal completed/approved, and withdrawal rejected or otherwise resolved by an authorized decision. Pending withdrawal blocks new grants and suspends dependent active grants; a pending request is not itself a completed withdrawal. | Define authorized decision-makers, permissible outcomes, timing, re-consent rules, and treatment of copies, exports, backups, and derived datasets. No state transition may silently restore access. |
| Organization authorization and PostgreSQL RLS | The specification proposes deriving organization membership from trusted server-side records, validating membership before protected operations, establishing context per transaction, and applying RLS as a second authorization layer. The migration enables RLS on six tables but contains no explicit policies. | Design a context mechanism safe for pooled connections and verify it cannot be selected or overridden by a browser user. Define policies and roles; test owner, superuser, and `BYPASSRLS` behavior. Keep administrative and migration privileges separate from the restricted application role. |
| Audit behavior | The specification proposes recording security-critical workflow changes with required audit events in the same transaction, failing closed when the audit event cannot be reliably recorded, and handling transaction failures explicitly. It does not claim tamper-proof logging. | Define the required events, actor identity fields, retention, access restrictions, failure reporting, and any independent protection or monitoring. Do not describe the current database audit design as independently protected or tamper-proof. |
| Schema integrity | The migration has six tables and RLS enablement but no explicit RLS policies. `allow_research_use` defaults to `TRUE`; consent, request, and status consistency constraints require further review. Cascade deletion and audit-reference behavior also require design decisions. | Resolve defaults, allowed state transitions, referential behavior, deletion/retention rules, and constraints before drafting a migration. |
| Privacy and deployment gates | Existing documentation requires synthetic-data development and recognizes limitations; this review found no implemented authentication, application authorization, encryption/key management, pseudonymization, or retention/deletion workflow. | Keep prototype fixtures synthetic. Obtain the required independent legal, privacy, ethics, and community review before any real data, pilot, or deployment is considered. |

## 8. M0 readiness checklist

For this checklist, **VERIFIED** means the stated repository fact or documentation requirement was confirmed in the reviewed files; it does not mean a control is implemented or operational.

| Check | Status | Evidence / limitation |
|---|---|---|
| Branch, commit, and pre-existing modified/untracked work recorded | VERIFIED | Captured in Section 3. |
| In-repository backup/archive candidates checked | VERIFIED | No matching backup/archive files or directories were found in the repository. |
| Current working state has a verified, restorable backup | NOT VERIFIED | No backup including the working tree or restore test was identified. |
| Three known protected URLs recorded exactly | VERIFIED | Exact strings and repository locations are listed in Section 5. |
| Inventory includes every URL distributed outside the repository | NOT VERIFIED | Email and other distribution records were not inspected. |
| Embedded sample values are verified synthetic | NOT VERIFIED | Provenance cannot be established from repository contents. |
| Direct participant names/contact details observed in sample rows | VERIFIED | None observed in the embedded rows; this is not proof of overall synthetic provenance. |
| Phase 2 security/governance controls are implemented | NOT VERIFIED | They are specification proposals; no application implementation was found, and the migration has no explicit RLS policies. |
| M0 design gaps and conditions for M1 recorded | VERIFIED | See the decision register and recommendation below. |
| Migration, installation, external connection, or deployment performed in this review | VERIFIED | None was performed. |

## 9. M1 recommendation and entry conditions

**Recommendation: READY FOR M1 DESIGN WITH CONDITIONS.**

M1 may proceed as a design-only activity: schema and state-transition design, role/privilege design, trusted organization-context design, audit-event definition, fixture-generation rules, and test-case specification. The existing specification is a starting point, not evidence that these controls have been built or validated.

Before creating or executing any migration:

1. Obtain owner approval for a complete working-state backup and verify that it can be restored.
2. Verify or replace all ambiguous sample values with unmistakably fictional fixtures and record their provenance.
3. Confirm the full previously distributed URL inventory with the project owner; preserve all exact destinations.
4. Resolve the M0 decisions on governance authority, individual separation of duties, consent/withdrawal outcomes, database privileges, pooled-connection organization context, explicit RLS policies, and audit failure behavior.
5. Keep real participant, health, and personal data out of the prototype. Do not approve a pilot, live deployment, or real-data processing through this design recommendation.

Any real-world deployment or research activity remains gated on qualified Nigerian legal, data-protection, research-ethics, and community review and appropriate authorization. No compliance, certification, operational readiness, or community approval is asserted here.

## 10. Review boundaries and preservation

- The target path was absent before this report was added.
- No existing file, URL, migration, seed file, source file, package, configuration, or deployment was changed.
- No existing URL was changed, redirected, or live-tested.
- No SQL, migration, seed script, package installation, database connection, or deployment was run.
- No email or external backup location was inspected.
- No backup was created; owner approval is required before creating one.
- All pre-existing modified and untracked files listed in Section 3 remain outside the scope of this report.
