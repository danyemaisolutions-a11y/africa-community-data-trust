# ACDT Phase 2B.4 — Security Verification and Test Strategy

**Status:** PROPOSED — test strategy only; tests not executed by this document  
**Project:** Africa Community Data Trust (ACDT)  
**Dependencies:** M1 Database Security Design; Phase 2B.2 Identity and Access-Control Architecture; Phase 2B.3 Threat Model and Risk Assessment  
**Scope boundary:** Design and planning only. No code, SQL, policies, roles, configuration, database, accounts, or repository files are changed.

## 1. Purpose

This document defines how future ACDT security and access-control requirements should be verified before any real-data use or pilot. It organizes the existing proposed test baselines, adds risk-driven verification priorities, defines environments and evidence requirements, and establishes pass/fail and defect-handling principles.

This document does not claim that any security test has been run, that any control is implemented, or that ACDT is secure, compliant, production-ready, or approved for real-data use.

## 2. Current evidence and test status

| Test/evidence item | Current status | What it does and does not establish |
|---|---|---|
| Phase 2A Python unit tests | Nine tests reported passing by the user | Supports the reported static schema/fixture checks only; does not establish live PostgreSQL behaviour or application security |
| Phase 2A fixture generation | Generator and SQL/JSON fixtures present in the working tree | Supports deterministic synthetic fixture generation as documented; does not prove production data handling |
| M1 PostgreSQL tests T01–T24 | Proposed; not run | Future database privilege, RLS, tenant-context, consent, grant, audit and lifecycle verification |
| Phase 2B.2 application/authentication tests A01–A15 | Proposed; not run | Future identity, session, authorization, separation-of-duties and export verification |
| Phase 2B.3 threat-focused tests B01–B15 | Proposed; not run | Future verification against prioritized attack scenarios |
| Live penetration test / independent assessment | Not evidenced | No security assurance conclusion can be drawn |

Do not combine these into one undifferentiated “tests passed” statement. Report Python, application, PostgreSQL, integration, operational, and independent assessment results separately.

## 3. Verification principles

1. **Synthetic data only:** All pre-pilot testing must use clearly labelled synthetic fixtures in isolated disposable environments. Do not copy production or real participant data into tests.
2. **Fail closed:** Missing, invalid, expired, ambiguous, revoked, or unverifiable identity and authorization context must deny protected access.
3. **Negative tests are essential:** Demonstrate that unauthorized actions and cross-organization access are denied; successful login alone is not evidence of authorization.
4. **Test the real trust boundary:** A custom PostgreSQL setting supplied by a shared application role is not, by itself, proof of trusted identity or tenant membership.
5. **Least privilege:** Verify effective privileges, including ownership, `PUBLIC`, inherited memberships, `SET ROLE`, default privileges, sequences, functions, and privileged bypass roles.
6. **Person-level separation:** Different accounts for the same person do not satisfy requester/reviewer/operator separation.
7. **Current-state checks:** Revoked memberships, roles, grants, sessions, and consent states must take effect according to the approved lifecycle policy.
8. **Evidence before claims:** A test is passed only when its environment, version, inputs, expected result, actual result, and review evidence are retained.
9. **Independent review:** High-impact controls and residual critical/high risks require review by suitably independent and competent reviewers.
10. **No scope creep:** Passing synthetic security tests does not authorize real-data use, a pilot, deployment, or legal/ethics decisions.

## 4. Test environments and controls

| Environment | Permitted purpose | Required safeguards | Prohibited use |
|---|---|---|---|
| Developer workstation | Static checks, Python unit tests, fixture generation | Synthetic data; secrets excluded; no production credentials | Real participant data or production database access |
| Disposable local PostgreSQL | Migration, grants, RLS, tenant-context and database tests | Isolated instance/database; synthetic fixtures; known PostgreSQL version; resettable environment | Shared or production database |
| Isolated application integration environment | Authentication, API, workflow, session and export tests | Test identity provider/tenant; synthetic identities; restricted test secrets; network isolation | Real researcher or participant accounts |
| CI test environment | Repeatable static and automated tests | Ephemeral credentials; protected secrets; pinned dependencies; no production access | Privileged production credentials |
| Independent assessment environment | Authorized security review and penetration testing | Written scope, rules of engagement, approved test accounts, evidence handling and stop conditions | Unapproved testing against third-party or production systems |

The PostgreSQL major version, extensions, role attributes, application framework, identity provider, hosting region, and network topology have not been selected or verified. The test plan must be adapted to the eventual approved implementation rather than assuming a specific stack.

## 5. Test layers and coverage

### 5.1 Static and repository checks
- Verify migration and schema definitions against the approved design.
- Verify RLS enablement and enumerate explicit policies.
- Inspect table ownership, grants, role memberships, `PUBLIC` privileges, default privileges, sequences and function execution rights.
- Check source and configuration for committed secrets, unsafe defaults, debug endpoints, and accidental real-data fixtures.
- Check fixture markers, deterministic output, and SQL/JSON consistency.
- Run formatting, linting, dependency and static-analysis checks when a real application exists.

Static checks cannot prove runtime authorization or database isolation.

### 5.2 Authentication and account lifecycle
- Missing, malformed, expired, wrong-issuer, wrong-audience, invalid-signature, revoked and replayed tokens.
- Disabled/suspended accounts and stale sessions.
- MFA and step-up requirements for privileged actions.
- Recovery-token expiry, replay, notification and MFA-bypass attempts.
- Logout, session rotation, refresh-token reuse and revocation.
- Identity-provider outage or unverifiable claims.

### 5.3 Application authorization and workflow
- Organization membership, project assignment, role scope and data-tier restrictions.
- Every protected API operation, including direct requests that bypass the user interface.
- Ownership and approval-field mass assignment.
- Purpose, research approval, grant scope, expiry and withdrawal dependencies.
- Requester/reviewer/operator separation by stable person identity.
- Service identity scope and privilege boundaries.
- Export, bulk operations, filtering, pagination and object-level authorization.

### 5.4 PostgreSQL privileges and RLS
- Unauthenticated and non-member roles.
- Cross-organization SELECT, INSERT, UPDATE and DELETE attempts.
- `USING` and `WITH CHECK` behaviour for each policy.
- Missing tenant context and invalid, expired, mismatched or revoked context.
- App role is not table owner, superuser or `BYPASSRLS`.
- Owner bypass and `FORCE ROW LEVEL SECURITY` behaviour where used.
- `PUBLIC`, inherited roles, membership options, `SET ROLE`, ownership, default privileges, sequences and functions.
- Transaction rollback and cleanup after errors, timeouts and cancellation.
- Privileged migration and break-glass paths.

RLS must be tested using the actual runtime roles and connection path. A test run as a superuser or table owner is not evidence that the restricted application role is correctly isolated.

### 5.5 Tenant-context and connection-pool tests
- Tenant A request followed by Tenant B on the same pooled connection.
- Context cleanup after success, exception, timeout, cancellation and rollback.
- Missing or invalid context denies access.
- Client-supplied tenant identifiers cannot forge accepted context.
- If signed assertions are adopted: issuer separation, signature validation, audience, expiry, replay resistance, key rotation/revocation and current membership checks.
- If brokered per-user DB principals are adopted: broker identity mapping, role selection, pool separation and revocation.

The selected mechanism must be documented and independently reviewed before implementation. Do not assume either option is already approved.

### 5.6 Audit and accountability
- Required events are captured for successful and denied sensitive operations.
- Actor, stable principal, role/assignment snapshot, organization/project, action, target category, outcome, timestamp and correlation identifier are accurate and minimized.
- Ordinary app roles cannot alter or delete audit records.
- Audit failures have a defined fail-safe outcome for sensitive operations.
- Privileged changes are independently recorded and reviewed.
- Logs exclude passwords, access/refresh tokens, signing keys and unnecessary personal data.
- Existing `DO INSTEAD NOTHING` rules are not treated as proof of cryptographic integrity or complete event capture.

### 5.7 Privacy, consent and data lifecycle
- Consent version, purpose, status and relevant expiry are evaluated correctly.
- Consent and lawful basis are not conflated.
- Withdrawal triggers the approved access/grant review and invalidation process.
- Retention and deletion rules distinguish primary records, backups, exports, recipient copies and derived datasets.
- Data minimization is enforced in application responses, logs, analytics and external integrations.
- No test assumes every downstream copy can be immediately erased.

### 5.8 Operational resilience
- Backup restore into an isolated environment.
- Recovery time and recovery point objectives once approved.
- Credential/key rotation and emergency revocation.
- Incident detection, escalation, containment and evidence preservation.
- Dependency outage, identity-provider outage, database outage and audit-service outage.
- Secure decommissioning and access revocation.

## 6. Existing test catalogue integration

Keep the catalogues distinct and cross-reference them rather than duplicating or silently changing their requirements.

| Catalogue | Coverage | Status |
|---|---|---|
| M1 T01–T24 | Database roles, RLS, tenant context, separation of duties, consent, grants, audit, export and lifecycle | Proposed; unrun |
| Phase 2B.2 A01–A15 | Token validation, account state, client tampering, membership, session lifecycle, MFA, service identity, mass assignment, person-level separation, fail-closed behaviour and exports | Proposed; unrun |
| Phase 2B.3 B01–B15 | Threat-focused tenant isolation, spoofing, pool leakage, role bypass, separation, revocation, export, secrets, audit, restore, fixtures and AI data minimization | Proposed; unrun |
| Phase 2A Python tests | Static schema and synthetic fixture checks | Nine user-reported passing tests; limited scope |

Before execution, reconcile overlapping tests into a traceability matrix while preserving the original IDs and source documents. If a test is changed, record the reason and retain the original requirement reference.

## 7. Minimum pre-pilot acceptance gates

No real-data pilot should be considered until all applicable gates below are met and signed off by the appropriate authority.

| Gate | Minimum evidence | Required reviewer/authority |
|---|---|---|
| Governance authority | Legitimate community governance process, roles, mandates, conflicts and complaints/appeals process | Affected communities and authorized governance process |
| Legal and privacy | Qualified review of controller/processor roles, lawful basis, NDPA/NDPC obligations, rights, retention and transfers | Qualified Nigerian legal/data-protection reviewer |
| Research ethics | Protocol-specific ethics/institutional review where applicable | Competent ethics/institutional body |
| Identity and authentication | Approved provider, secure MFA/recovery/session lifecycle, identity-to-principal mapping | Security and privacy reviewers |
| Application authorization | Server-side checks for every protected operation; negative tests pass | Independent application/security reviewer |
| Separation of duties | Stable person-level mapping and verified requester/reviewer/operator separation | Governance authority and independent reviewer |
| Database security | Least-privilege roles, explicit RLS policies, bypass review, cross-tenant negative tests pass | DBA/security reviewer |
| Trusted tenant context | Selected mechanism independently reviewed; pool and spoofing tests pass | Security architect, DBA and independent reviewer |
| Consent and lifecycle | Approved consent/versioning, withdrawal, grant invalidation, retention and export rules | Governance, privacy/legal and research leads |
| Audit and monitoring | Required event capture, restricted access, integrity controls, alerting and review process | Security/operations owner and independent reviewer |
| Cryptography and secrets | Approved encryption, key custody, rotation, recovery and secret management | Security/operations reviewer |
| Resilience and response | Tested restore, incident runbook, named owners and exercised escalation | Operations owner and independent reviewer |
| Independent assurance | Findings, remediation evidence and residual-risk statement | Competent independent assessor |
| Formal go/no-go | Recorded decision, scope, conditions, expiry/review date and named approvers | Authorized project and governance authorities |

Passing technical tests does not substitute for governance, legal, privacy, or ethics approvals. No single technical reviewer can authorize all of these domains.

## 8. Severity, defect handling and retesting

Use a consistent defect scale:
- **Critical:** cross-tenant exposure, broad unauthorized access, trusted-context forgery, material privilege bypass, or compromise of signing keys/privileged control. Block progression; contain and investigate.
- **High:** material access-control, consent, export, audit, or identity weakness. Block affected pilot scope until fixed and retested.
- **Medium:** bounded weakness with a credible mitigation. Assign owner and due date; obtain documented risk decision.
- **Low:** limited impact or hardening issue. Track and resolve according to an approved schedule.

For every defect, record:
- Unique ID, date, environment and affected component.
- Test ID(s), steps to reproduce, expected and actual result.
- Evidence with secrets and unnecessary personal data removed.
- Severity and impact rationale.
- Root cause, affected data/tenants and exploitability.
- Owner, corrective action, due date and dependencies.
- Retest result and independent reviewer.
- Residual risk and authorized acceptance, if applicable.

A critical or high defect must not be closed solely because a code change was made. Retest the original failure and relevant regression cases. Risk acceptance must be explicit, time-bounded, owned by an authorized person, and must not override legal, ethical or community authority.

## 9. Evidence and reporting standard

Each test run should retain:
- Test ID and source requirement.
- Date/time and tester/reviewer.
- Commit or source version under test.
- Environment and dependency/database versions.
- Exact runtime role and identity context.
- Synthetic dataset/fixture version.
- Preconditions, steps, expected result and actual result.
- Pass/fail/blocked/not-run status.
- Logs, screenshots or query output with secrets and unnecessary personal data redacted.
- Defect references and retest status.

Use only these status labels:
- **PASS — evidenced:** expected result achieved and evidence retained.
- **FAIL:** expected result not achieved.
- **BLOCKED:** could not be run because a dependency or environment was unavailable.
- **NOT RUN:** planned but not executed.
- **NOT APPLICABLE:** documented rationale approved by the test owner/reviewer.

Do not report “secure”, “compliant”, “certified”, “production-ready” or “independently validated” based solely on a passing test suite.

## 10. Roles and responsibilities

Proposed responsibilities, subject to formal appointment:
- **Test owner:** maintains scope, traceability, schedule and evidence.
- **Developer:** implements approved corrections and supplies technical details; does not independently accept their own critical/high security findings.
- **DBA/security engineer:** reviews database roles, RLS, tenant context, secrets and privileged paths.
- **Privacy/legal reviewer:** assesses privacy and legal requirements within their competence.
- **Governance authority:** determines legitimate approval authority, role appointment and community-facing processes.
- **Independent assessor:** reviews high-impact design and test evidence and performs authorized independent testing.
- **Project owner:** resolves resourcing and records formal scope/go-no-go decisions within their authority.

These roles are proposals, not existing appointments or an established ACDT governance body.

## 11. Execution sequence

1. Confirm the approved architecture and unresolved owner decisions; do not begin tests against an assumed design.
2. Establish a disposable, isolated, synthetic-only environment and record exact versions.
3. Verify migration/schema and least-privilege database topology.
4. Implement only after separate authorization, then run M1 T01–T24.
5. Implement approved identity and application controls, then run A01–A15.
6. Run threat-focused B01–B15 and integration/regression tests.
7. Conduct authorized independent security assessment.
8. Remediate and retest critical/high findings; document residual risks.
9. Complete governance, legal/privacy, ethics and operational readiness gates.
10. Obtain a formal, scoped go/no-go decision before any pilot.

This sequence is a proposed dependency order, not authorization to implement or execute any step.

## 12. Outstanding decisions

- Which PostgreSQL major version and actual application stack will be used?
- Which tenant-context mechanism will be selected and independently reviewed?
- Which identity provider, MFA methods and recovery process will be approved?
- What are the exact data tiers, research workflows, export cases and retention periods?
- Who owns testing, security operations, privacy review and residual-risk acceptance?
- Which independent assessor and test scope will be commissioned?
- What evidence format and retention period will be approved?
- What measurable recovery objectives and incident escalation commitments are required?
- Which formal authority can issue a pilot go/no-go decision, and what community participation is required?

## 13. Conclusion

ACDT has a useful proposed verification baseline across M1, Phase 2B.2 and Phase 2B.3, but the security tests and operational controls described by those documents have not thereby been executed or validated. The immediate deliverable is a traceable, evidence-based test plan. Actual testing depends on approved architecture decisions, separate implementation authorization, an isolated synthetic environment, and competent review.

**Final status: PROPOSED — SECURITY VERIFICATION AND TEST STRATEGY ONLY.**  
**No implementation, database execution, deployment, real-data use, or pilot is authorized by this document.**
