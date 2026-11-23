# ACDT Phase 2B.5 — Implementation Readiness Assessment and Go/No-Go Criteria

**Document status:** Proposed design and readiness assessment  
**Programme:** Africa Community Data Trust (ACDT)  
**Phase:** 2B.5 — Implementation Readiness Assessment  
**Basis:** Phase 2B.1 Governance and Stakeholder Requirements; Phase 2B.2 Identity and Access Control Architecture; Phase 2B.3 Threat Model and Risk Assessment; Phase 2B.4 Security Verification and Test Strategy; current Phase 1 and Phase 2A evidence described in the project record.  
**Limitation:** Internal planning document only. It is not a legal opinion, security certification, ethics approval, community mandate, production-readiness certification, or authorization to process real personal or community data.

---

## 1. Executive assessment

ACDT has an early-stage documented foundation and a useful set of design artefacts for structured technical and governance review. The available evidence supports **continued design review and preparation for a narrowly scoped implementation proposal**.

It does **not** establish readiness for production implementation as a complete trusted data-trust service, a live community pilot, or the collection, storage, sharing, or research use of real personal or community data.

The principal constraints are accountable governance decisions, verified identity and organizational-membership arrangements, a trusted authorization model, executable database controls, operational security arrangements, privacy and legal review, and an independently evidenced test programme.

### 1.1 Overall readiness position

| Dimension | Assessment | Basis |
|---|---|---|
| Concept and documentation | Ready for continued review | Foundational and Phase 2 design documents exist, subject to owner and stakeholder review |
| Governance legitimacy | Not ready | Proposed governance arrangements are not constituted or community-authorized |
| Identity and authentication | Not ready | No operational identity provider, principal mapping, or account lifecycle evidenced |
| Authorization and tenant isolation | Design only | No implemented application authorization or RLS policies evidenced |
| Database security | Not ready for real data | RLS is enabled in the current migration without applicable policies; no hardened production role model evidenced |
| Audit and accountability | Design only | Existing update/delete suppression rules are not cryptographic or independently verifiable audit controls |
| Privacy, legal and ethics | Not cleared | Qualified legal/data-protection and, where applicable, ethics review remain outstanding |
| Security verification | Test plan only | Phase 2B.4 specifies future tests; the security test suite has not been executed |
| Operations and incident readiness | Not ready | No operational monitoring, incident response capability, backup/recovery assurance, or key-management operation evidenced |
| Synthetic-data foundation | Limited provisional readiness | Phase 2A Python unit tests were reported as passing; no live PostgreSQL security testing evidenced |

**Overall conclusion:** Suitable for further design review. Any move into controlled implementation must be conditional on the gates below. Not ready for real-data processing or a live community pilot.

## 2. Readiness categories and permitted activities

Readiness must be assessed by activity, not by one general label.

### R0 — Documentation and design review

**Meaning:** Proposed designs and documents can be reviewed, challenged, corrected, and approved as planning artefacts.

**Permitted:** Review architecture, governance, privacy, threat-model and test-plan documents; record decisions and unresolved issues; conduct non-binding stakeholder discovery and consultation; use clearly synthetic examples in documentation and isolated local tests.

**Not implied:** Governance approval, legal compliance, implementation approval, or permission to collect real data.

### R1 — Controlled implementation preparation

**Meaning:** Approved requirements and accountable ownership exist for a bounded, non-production implementation.

**Entry conditions:**
- Written approval of the exact implementation scope and affected files/systems.
- Named technical owner and reviewers.
- Approved architecture decisions for the first increment.
- Isolated development and test environments.
- Synthetic-only data controls and a prohibition on production data.
- Version-control, backup, change-review, and rollback arrangements.
- Security requirements and acceptance tests agreed before implementation.

**Permitted after approval:** Limited implementation of that increment in an isolated environment. This is not production or real-data authorization.

### R2 — Synthetic-data technical pilot

**Meaning:** An isolated, non-production technical environment validates implemented controls using synthetic data only.

**Additional entry conditions:**
- Implemented authentication and authorization suitable for the pilot.
- Implemented database roles, least privilege, tenant isolation, and RLS policies.
- Selected trusted tenant-context mechanism independently tested.
- Separation-of-duties controls implemented where the workflow requires them.
- Security tests executed against the actual application and target PostgreSQL version.
- No unresolved Critical or High security defects affecting the pilot scope.
- Synthetic fixtures clearly labelled and not confusable with participant records.
- Access, logs, backups, secrets, and incident procedures bounded and reviewed.

**Permitted:** Controlled technical testing with synthetic data only. No public launch, community data collection, or real research access.

### R3 — Real-data readiness assessment

**Meaning:** Evidence and external review, where required, demonstrate that a defined real-data activity has the necessary governance, legal, privacy, ethics, security, and operational safeguards.

**Not currently met.** It requires activity-specific approval and evidence, including:
- Legitimate, documented governance mandate and appropriate community engagement.
- Controller/processor and other relevant legal roles determined with qualified advice.
- Documented purposes, lawful basis, transparency information, and consent arrangements where consent is used.
- Data minimization, retention, rights-handling, withdrawal, deletion, and backup treatment.
- Qualified privacy/data-protection and legal review, including NDPA applicability and cross-border issues.
- Ethics review where required by the research, institution, funder, or applicable rules.
- Security assessment and successful testing of implemented controls.
- Operational staff, access review, incident response, backup/recovery, and vendor oversight.
- Specific authorization for the exact data, purpose, population, location, recipients, and duration.

### R4 — Production operation

Production is a separate decision after R3. It requires operational acceptance, support ownership, monitoring, resilience, change management, incident exercises, vendor agreements, and ongoing governance. This assessment grants no such approval.

## 3. Gate-based implementation decision

A gate passes only when its evidence is recorded and the authorized decision-maker approves it. A document describing a control is not evidence that the control is implemented or effective.

| Gate | Required decision/evidence | Current position |
|---|---|---|
| G0 — Scope and change control | Written scope, owner, affected components, backup/version-control and rollback plan | Confirm for each increment |
| G1 — Governance requirements | Owner decisions, authority boundaries, stakeholder requirements, consultation plan | Partially documented; formal decisions and legitimacy outstanding |
| G2 — Architecture | Approved identity, tenant context, app authorization, DB roles, RLS and audit designs | Design documented; review and unresolved choices remain |
| G3 — Privacy/legal/ethics | Activity-specific legal, privacy, data-protection and conditional ethics assessment | Not cleared |
| G4 — Implementation controls | Actual authentication, authorization, privilege, RLS, workflow and audit controls | Not evidenced |
| G5 — Verification | Relevant static, app, database, adversarial and operational tests pass with retained evidence | Phase 2A unit tests reported passing; Phase 2B security suite not run |
| G6 — Synthetic pilot authorization | Written approval for a bounded synthetic-only pilot, with isolation and stop conditions | Not approved/evidenced |
| G7 — Real-data authorization | Activity-specific governance, legal, privacy, ethics, security and operational approvals | **NO-GO** |
| G8 — Production authorization | Operational acceptance and formal production decision | **NO-GO** |

## 4. Critical prerequisites and gap register

The following consolidates dependencies identified in the Phase 2B design work. Owners are proposed responsibility categories, not appointed individuals.

| ID | Prerequisite / gap | Evidence required to close | Proposed accountable role | Priority |
|---|---|---|---|---|
| P-01 | Governance authority not constituted | Approved mandate, appointment and representation process, terms, quorum, conflicts and appeals | Project owner with community stakeholders | Critical before real-data activity |
| P-02 | Community participation and legitimacy | Documented consultation, accessible information, feedback and response record | Governance lead / community representatives | Critical before community pilot |
| P-03 | Legal roles unresolved | Qualified legal/data-protection assessment for each activity and provider | Project owner with counsel | Critical before real-data activity |
| P-04 | Identity authority not selected | Approved IdP/account lifecycle, stable person mapping and recovery process | Technical/security lead | Critical before access implementation |
| P-05 | Membership and role assignment not operational | Authoritative membership source, approval/review, expiry and revocation | Governance and technical leads | Critical before multi-tenant access |
| P-06 | Trusted tenant context unresolved | Selected assertion/broker design, issuer trust, key protection, expiry, audience, replay and revocation controls | Security architect | Critical before RLS implementation |
| P-07 | Database role model not implemented | Least-privilege roles, ownership, grants, default privileges, migration and break-glass controls | Database/security lead | Critical before database pilot |
| P-08 | RLS policies absent | Table-by-table policies, FORCE RLS decision, USING/WITH CHECK and bypass tests | Database/security lead | Critical before multi-tenant pilot |
| P-09 | Separation of duties not enforceable | Stable-person mapping, independent assignments and negative tests | Governance and technical leads | Critical for research-access workflow |
| P-10 | Consent and purpose model incomplete | Approved versioned notices, purpose, status transitions, withdrawal and lawful-basis rules | Privacy/legal and governance leads | Critical before real-data activity |
| P-11 | Audit design not implemented | Append-only event design, restricted access, integrity controls, monitoring and failure behaviour | Security/technical lead | High; critical for sensitive workflows |
| P-12 | Retention/deletion/backup treatment unresolved | Retention schedule, legal holds, backup expiry, export and derived-copy handling | Privacy/legal and operations leads | Critical before real-data activity |
| P-13 | Security test plan not executed | Test reports for relevant A01–A15, B01–B15 and M1 T01–T24 cases | Independent tester / technical lead | Critical before synthetic pilot |
| P-14 | Incident response not operational | Named responders, escalation, containment, notification assessment and exercise evidence | Operations/security lead | Critical before real-data activity |
| P-15 | Encryption/key management not evidenced | Data-flow-specific encryption design, key custody, rotation, access and recovery tests | Security/operations lead | Critical before real-data activity |
| P-16 | Vendor/cross-border controls unresolved | Provider inventory, contracts, subprocessors, locations and transfer assessment | Project owner with counsel | Critical where applicable |
| P-17 | Production resilience not evidenced | Tested backups, restore, recovery objectives, monitoring and operational ownership | Operations lead | Before production |
| P-18 | AI use boundaries need enforcement | Approved use cases, no autonomous consent/access decisions, human review and disclosure controls | Governance and technical leads | Before AI-enabled workflow |

## 5. Candidate scope for a first controlled implementation increment

If relevant G0–G3 prerequisites are approved for a synthetic-only increment, the first implementation should be narrow. It should not attempt to build the entire platform at once.

A candidate increment for separate approval could:
1. Create a disposable, isolated development/test database using a documented PostgreSQL version.
2. Integrate minimal non-production identity using test identities only.
3. Implement the selected trusted tenant-context mechanism. A client-supplied organization ID or freely settable GUC is not proof of identity.
4. Implement a small, explicitly scoped set of database roles and grants.
5. Implement and test RLS policies for selected tables, including cross-organization denial and owner/BYPASSRLS review.
6. Implement a minimal authorization workflow with requester/reviewer/operator separation where relevant.
7. Implement security-relevant audit events with defined failure behaviour.
8. Run approved tests and preserve reproducible evidence.
9. Demonstrate that the environment contains synthetic data only and cannot connect to production systems.

Exact tables, endpoints, roles, and workflow must be approved before implementation. This is a candidate scope, not an instruction to modify the repository.

## 6. Non-negotiable no-go conditions

Do not proceed to the relevant higher readiness category if:
- There is no identifiable accountable owner or written approval for the proposed scope.
- Governance authority is assumed rather than established for a community-facing activity.
- Real data is proposed before legal, privacy, governance and applicable ethics requirements have been assessed.
- A client-controlled organization identifier is trusted as authorization.
- Tenant context can be forged by an ordinary application user or service without an independently trusted verification boundary.
- The application database role is superuser, has BYPASSRLS, owns protected tables without an appropriate control strategy, or has unnecessary DDL/privilege powers.
- RLS is relied upon without testing owner bypass, privileged roles, PUBLIC grants, role membership, SET ROLE, default privileges and connection-pool reuse.
- A requester can approve their own request, or reviewer/operator can bypass the approved separation-of-duties workflow.
- Membership revocation does not invalidate relevant access paths and sessions within a defined, tested timeframe.
- Audit events can be silently altered or deleted by ordinary application actors, or audit failure behaviour is undefined for a sensitive action.
- Consent is treated as the only possible lawful basis, or withdrawal is represented as automatically erasing every retained record, backup or derived copy.
- Synthetic fixtures can be mistaken for real participant data.
- Critical or High security defects remain open in the scope being approved.
- Required test evidence is missing, irreproducible, or based only on documentation assertions.
- No incident escalation or containment owner exists for the proposed environment.
- NDPA/GDPR compliance, certification, community authorization, or production security is claimed without the necessary evidence and qualified review.

A no-go decision should identify the unmet condition, responsible owner, remediation evidence, and authority required to reconsider it.

## 7. Required test evidence before a synthetic-data technical pilot

Before G6, evidence must show that the actual implementation—not just the design—passes relevant tests.

### 7.1 Identity and authorization
- Unauthenticated and disabled accounts are denied.
- Account-to-person mapping is stable and cannot be self-asserted.
- Membership and role changes take effect as designed.
- Expired and revoked memberships are denied.
- Client-supplied tenant identifiers cannot grant access.
- Requester, reviewer and operator separation is enforced and tested.

### 7.2 PostgreSQL and tenant isolation
- Runtime roles are least-privileged and are not owners, superusers or BYPASSRLS roles.
- Grants, PUBLIC privileges, role memberships, inheritance, SET ROLE and default privileges are reviewed.
- RLS policies use appropriate USING and WITH CHECK conditions.
- Cross-tenant SELECT, INSERT, UPDATE and DELETE attempts are denied as intended.
- Owner, migration and break-glass bypass paths are constrained and documented.
- Connection-pool reuse, rollback, timeout and error paths do not leak tenant context.

### 7.3 Audit and workflow
- Sensitive actions create attributable events with actor, action, scope, time, outcome and correlation identifiers.
- Application actors cannot modify or erase audit history through ordinary paths.
- Audit failure behaviour is tested; sensitive operations fail safely where required.
- Research-access state transitions and independent approvals are tested.
- Grant expiry, suspension and revocation are tested end-to-end.

### 7.4 Privacy and data lifecycle
- Test data is synthetic and clearly labelled.
- Purpose limitation and consent-state rules are enforced where applicable.
- Withdrawal, retention, deletion, exports, backups and derived-copy handling are tested against approved rules.
- Logs and error messages do not expose secrets or unnecessary personal information.

### 7.5 Evidence quality

Each test record should include a unique test ID and requirement mapping; environment and software/database versions; preconditions and synthetic data identifier; exact steps or automated command; expected and actual result; pass/fail status, timestamp and tester; relevant logs/output with secrets removed; and defect/retest references.

A passing Python schema test is evidence only for the assertions it actually tests. It does not prove PostgreSQL permissions, RLS behaviour, authentication, tenant isolation, cryptographic integrity, or production operations.

## 8. Governance and approval responsibilities

Assign these functions before implementation. Names and appointment processes remain to be determined.

| Function | Responsibility | Boundary |
|---|---|---|
| Project owner / sponsor | Approves scope, resources, risk acceptance and project-level decisions | Does not replace community authority or independent legal/ethics review |
| Governance body (proposed) | Exercises only the mandate formally delegated to it; reviews relevant access and benefit-sharing matters | Not yet constituted; authority must not be assumed |
| Community representatives | Participate in consultation and shape representation, safeguards and benefit arrangements | Consultation does not automatically confer authority to consent for individuals |
| Technical lead | Owns architecture and implementation quality within approved scope | Cannot self-approve legal, ethics or community legitimacy |
| Security reviewer | Independently reviews threat controls, test evidence and unresolved security risks | Must have sufficient independence from implementation |
| Privacy/legal adviser | Advises on legal roles, lawful basis, NDPA and other applicable obligations | No compliance conclusion without qualified review |
| Ethics committee / HREC / IRB, where applicable | Reviews research ethics under the applicable institutional, funder or legal framework | Applicability depends on the specific activity |
| Operations owner | Owns monitoring, access lifecycle, incident response, backup and recovery | Must be appointed and operational before relevant live use |

If one individual holds multiple roles in an early prototype, explicitly identify conflicts and compensating review. Role labels or multiple accounts for one person do not create genuine independence.

## 9. Decision record template

For every gate, record:
- Gate ID and decision date.
- Exact scope and environment being considered.
- Decision: **GO**, **CONDITIONAL GO**, or **NO-GO**.
- Decision-maker and basis of authority.
- Evidence reviewed, including test IDs and document versions.
- Open risks, severity, owner and due date.
- Conditions, restrictions and expiry/review date.
- Data classification and confirmation whether real data is present.
- Stop conditions and escalation contact.

A conditional GO must state conditions explicitly. It must not be interpreted as permission to process real data unless that activity is expressly within the approved scope.

## 10. Recommended sequence

1. Confirm Phase 2B.1–2B.4 document versions and resolve inconsistencies.
2. Hold an owner-level review of governance, architecture, threat model and test strategy.
3. Record unresolved decisions and assign accountable owners.
4. Conduct appropriate stakeholder/community consultation before describing the governance design as accepted.
5. Obtain qualified privacy/legal advice on intended activities; determine whether ethics review is required.
6. Select and document identity, membership and trusted tenant-context approaches.
7. Approve a narrow, synthetic-only implementation scope and change-control plan.
8. Implement only the approved increment in an isolated environment.
9. Execute relevant security tests against the actual application and PostgreSQL deployment.
10. Conduct independent review and record a formal G6 decision before any synthetic technical pilot.
11. Treat real-data activity as a separate proposal requiring G7 evidence and approval.
12. Treat production operation as a separate G8 decision.

## 11. Current evidence statement

The project record indicates that:
- Phase 1 foundational documentation and supporting technical/governance documents have been prepared.
- Phase 2A synthetic-fixture and schema-test work was reported by the user as passing nine Python unit tests.
- Phase 2A tests are repository-level Python tests; no live PostgreSQL security test was evidenced.
- Phase 2B.1 governance and stakeholder requirements were reviewed as design.
- Phase 2B.2 identity and access-control architecture was prepared as design.
- Phase 2B.3 threat model and risk assessment was prepared as design.
- Phase 2B.4 security verification and test strategy was prepared as design.
- No production authentication/authorization service, RLS policies, trusted identity assertion service, operational governance body, real-data pilot, production audit service, encryption/key-management operation, or production research-access infrastructure has been evidenced.

This statement is bounded by the evidence available for this assessment. It is not an independent audit of the local repository or deployed systems.

## 12. Final recommendation

**GO** for continued documentation review and decision closure.  
**CONDITIONAL GO** to prepare a narrowly scoped synthetic-only implementation proposal, subject to the relevant gates and separate written approval.  
**NO-GO** for real-data use, a live community pilot, public launch, or production operation.

The next practical activity should be a formal Phase 2B design review and decision register—not immediate broad implementation. Once the owner has approved the specific technical and governance decisions, a separate implementation proposal can define the first increment, exact files/components, test environment, acceptance criteria, rollback plan and required approvals.

No file changes, database changes, package installation, staging, commit, push, deployment, or real-data processing are authorized by this document.

---

**End of document**
