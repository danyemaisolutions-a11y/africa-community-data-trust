# Privacy and security principles

## Status and review

This document states proposed principles, **not a security certification** or evidence that controls are deployed. The original baseline database migration is stored in `database/migrations/001_initial_schema.sql` (defining six core relational tables with Row-Level Security enabled, but with no explicit `CREATE POLICY` statements). Subsequent local development includes Phase 2A synthetic fixtures and tests, and a Stage B review package under `database/stage-b-review/`. The complete current database security posture cannot be inferred from the original baseline migration alone.

In the Supabase development project `acdt-dev`, the project owner reported development checkpoint results: the Stage B migration was committed, a transaction-and-rollback security rehearsal reported 52 passing sequential assertions, five checked Stage B tables were confirmed present after commit, and the first platform governor was appointed (with saved role and active profile verified in a separate query). These database commits are distinct from Git commits; the four Stage B source/package files are recorded in Git commit `70a241b`, while the generated rehearsal bundle remains local-only.

These development checkpoints do not constitute an independent security certification, comprehensive audit coverage, or evidence of production readiness. The local `apps/web` directory is currently an empty placeholder; end-to-end application sign-in, authentication, and application-layer authorization workflows are not established. Furthermore, complete consent and revocation handling, decision-to-grant consistency, consent-aware data release, and benefit-sharing workflows have not been established by the Stage B checks. Under no circumstances should real participant, health, clinical, or sensitive community research data be processed using this prototype. See the [implementation status register](implementation-status.md) for a concrete inventory.

Before any processing of personal or sensitive data, obtain qualified Nigerian data‑protection and legal review, including consideration of the Nigeria Data Protection Act 2023 and applicable Nigeria Data Protection Commission (NDPC) guidance. This document is not legal advice and does not establish compliance.

## Data minimisation and purpose limitation

- Collect and retain only data necessary for a clearly stated, reviewed purpose.
- Avoid direct identifiers in research datasets wherever feasible.
- Separate optional information from information needed for a specific service or study.
- Do not repurpose data, share it, or use it for model training merely because it is technically available.
- Review each new use and recipient against the original purpose, consent, applicable approvals, and legal requirements.

These are design principles; no collection application or purpose‑enforcement service exists.

## Informed consent and withdrawal

Consent should be voluntary, informed, specific, understandable, accessible, and recorded with enough context to establish what was presented and selected. Where relevant, preferences for distinct purposes should be separable rather than bundled.

A withdrawal process should explain how to submit a request, how it will be acted on, what downstream users will be notified, and any limits on withdrawal after data has been used or transformed. Access and processing should be reviewed promptly when consent changes, subject to applicable law and approved research arrangements.

The migration has consent‑related fields, including version, preference, status, and revocation fields. It does not implement a consent interface, record‑evidence workflow, withdrawal process, or enforcement.

## Pseudonymisation and identity separation

Pseudonymisation reduces direct identification but does not make data anonymous. Re‑identification risk can remain through the pseudonym, linkage data, or combinations of attributes.

A future system should:

- Minimise direct identifiers and keep any identity‑linking information in a separately controlled store.
- Restrict and log any authorised linkage, with defined roles and purpose.
- Assess re‑identification risks, including small cohorts and indirect identifiers.
- Define a reviewed, tested pseudonym generation method and its lifecycle.
- Avoid placing secrets or reversible identity mappings in source control.

The current `participant_pseudo_id` and `contact_token_hash` columns do not demonstrate a pseudonymisation implementation or identity separation. No deterministic pseudonymisation or AES‑256 encryption implementation is present in the audited repository.

## Encryption and key management

Encryption at rest and in transit should be requirements for any future deployment, selected and configured according to a documented threat model and applicable standards. The deployment must verify storage encryption and transport security rather than infer them from the database technology.

Key management should define key generation, storage, access, rotation, backup, recovery, revocation, and separation of duties. Keys and credentials must not be committed to source control. The project's encryption configuration, key-management arrangements, and cryptographic controls have not been comprehensively reviewed at this checkpoint; do not claim encryption is implemented or verified based on this documentation.

## Authentication and authorisation

Future authentication must reliably establish actor identity and account lifecycle. Authorization should apply least privilege and distinguish participant, researcher, reviewer, governance, and operational roles as justified by the agreed governance model.

Sensitive decisions must be checked server‑side and must not rely solely on UI controls. The repository currently has no authentication or application‑level authorisation implementation.

## PostgreSQL Row‑Level Security

In the original baseline migration (`001_initial_schema.sql`), Row-Level Security was enabled on six tables, but no explicit `CREATE POLICY` statements were defined. Enabling RLS without creating, reviewing, and testing appropriate policies does **not** establish a complete access‑control system. 

Subsequent local Stage B review scripts (`database/stage-b-review/`) introduced additive tables with RLS enabled and security definer RPC functions. For the Supabase development project `acdt-dev`, the project owner reported development checkpoint results including 52 passing sequential assertions during a transaction-and-rollback security rehearsal. However, these checks do not establish complete application-level authorization, consent-aware release controls, or independent security certification. Future production design must continue to account for privileged database roles and service credentials that may bypass policies.

## Audit trail integrity

Security‑relevant events should be captured with defined actor, action, purpose, time, and outcome details, while minimising sensitive content. Access to audit records should be restricted and monitored. Integrity protections should be assessed against privileged operators, database administrators, compromised credentials, and infrastructure‑level threats.

The migration defines `governance_audit_logs` and database rules intended to suppress updates and deletes. This is not equivalent to a fully validated, tamper‑proof audit system. No event‑capture integration, independent integrity verification, alerting, or audit review process is implemented or verified.

## Retention and deletion

Before data collection, define approved retention periods by data category and purpose, hold and deletion exceptions, secure deletion procedures, and how deletion or withdrawal is handled across derived data, exports, and recipients. Retention should not be indefinite by default.

No retention schedule, deletion workflow, or verified deletion process is present in the repository.

## Backups and recovery

Any future deployment should define encrypted, access‑controlled backups, backup retention, restoration testing, recovery objectives, and controls preventing backups from becoming an ungoverned copy of data. Recovery procedures should preserve applicable consent and access restrictions.

No backup or recovery arrangement is configured or documented as operational.

## Incident response

A future operational plan should define how to detect, triage, contain, investigate, and remediate suspected incidents; preserve evidence; communicate with affected parties; and assess notification obligations with qualified legal and data‑protection advice. Responsibilities and contact routes should be established before processing data.

Operational monitoring and incident-response procedures have not been reviewed or established at this development checkpoint. No claim of operational monitoring is made.

## Synthetic‑data‑only development

Development, demonstrations, and tests must use synthetic data only. Research fixtures, cohort tables, and prototype research datasets must consist strictly of synthetic mock data; no real participant, health, clinical, or community research records may be placed in source files, test fixtures, issue reports, logs, or development environments. This synthetic requirement applies strictly to all research data, distinguished from necessary developer or administrator authentication account details used in isolated development environments. Under no circumstances should real credentials, secrets, API keys, or real personal records be committed to the repository.

The original baseline SQL migration (`001_initial_schema.sql`) labels its sample inserts as synthetic. Their synthetic status was not independently verified. The presence of sample rows does not establish a tested synthetic‑data gate or guarantee that future environments will not contain real data.
