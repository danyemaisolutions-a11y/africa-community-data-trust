# Development roadmap

## Status

This is a proposed sequence, not an approved delivery commitment. Progress between phases should require review of evidence and explicit decisions by the appropriate community, legal, research, and technical stakeholders. Development and testing remain synthetic-data-only.

## Phase 1 — Foundation and documentation

**Objectives**

- Establish an accurate account of the current repository and project boundaries.
- Document proposed architecture, governance, privacy/security principles, staged development, and implementation status.
- Make the difference between existing schema artefacts and future capabilities clear.

**Deliverables**

- Project README that reflects the current implementation.
- Architecture, governance, privacy/security, roadmap, and implementation-status documentation.
- A protected local working branch and verified repository backup for the documentation work.

**Dependencies**

- Review of the existing README, migration, licence, Git state, and public project links.

**Exit criteria**

- Documentation is reviewed for accuracy, consistent terminology, and internal links.
- Existing project links and licence are preserved.
- No application, database migration, deployment, or live service is changed.
- Project stakeholders identify any substantive governance, legal, or technical decisions needed for Phase 2.

## Phase 2 — Synthetic-data MVP

**Objectives**

- Build a minimal demonstrator using only verified synthetic records.
- Explore consent, access-request, governance-review, audit, and benefit-sharing workflows without real participant data.

**Deliverables**

- Proposed web, API/service, and database components defined and implemented as an explicitly non-production prototype.
- Input validation, access-control design, explicit RLS policies, and tests for allowed and denied operations.
- Synthetic fixtures, setup instructions, and focused automated tests.
- Clear user-facing prototype limitations and no live-data capability by default.

**Dependencies**

- Phase 1 exit; stakeholder agreement on scope, roles, data model changes, consent concepts, technology choices, and threat model.
- Separate authorization before any SQL migration changes or service integrations.

**Exit criteria**

- Demonstrator behavior and tests are reproducible in a local or isolated synthetic environment.
- Access-control tests cover relevant roles and deny unauthorized paths.
- No real participant data, production credentials, or live integrations are used.
- Limitations and unresolved risks are documented for independent review.

## Phase 3 — Security and independent validation

**Objectives**

- Test the prototype against a documented threat model and validate governance and privacy assumptions.
- Obtain independent technical, community, research-ethics, and qualified Nigerian legal/data-protection review appropriate to the intended use.

**Deliverables**

- Independent security assessment and documented remediation outcomes.
- Verified RLS, authentication, authorization, consent, audit, retention, backup/recovery, and incident-response designs.
- Review of data minimisation, re-identification risk, and proposed operational responsibilities.
- Updated documentation and go/no-go recommendations.

**Dependencies**

- Phase 2 demonstrator and reproducible test environment.
- Appropriate independent reviewers and community participation; no review is implied by this roadmap.

**Exit criteria**

- Review findings are addressed or explicitly accepted by the accountable decision-makers.
- Security and operational controls are demonstrated in a controlled environment.
- Legal and ethics requirements and responsible roles are documented.
- Any unresolved high-impact risk blocks progression to a pilot.

## Phase 4 — Controlled pilot subject to necessary approvals

**Objectives**

- Consider a narrowly scoped pilot only after all required governance, legal, regulatory, ethics, security, and community approvals are in place.

**Deliverables**

- Approved pilot protocol, purpose, participant information and consent materials, data-handling plan, access conditions, benefit-sharing arrangements, and incident/complaint routes.
- Defined pilot roles, operational controls, monitoring, evaluation, and exit/decommission plan.
- Pilot evaluation based on agreed community and institutional criteria.

**Dependencies**

- Phase 3 exit and all approvals required for the proposed context.
- Informed agreement from relevant communities and participating institutions.
- Qualified determination of legal basis, regulatory requirements, and safeguards.

**Exit criteria**

- Pilot objectives and safety limits are met under documented review.
- Complaints, incidents, withdrawals, access decisions, and benefits are assessed against the approved plan.
- Accountable stakeholders decide whether to stop, revise, or propose a further phase.

No pilot is currently approved or operational.

## Phase 5 — Africa-wide expansion

**Objectives**

- Explore adaptation for additional African contexts without assuming that Nigerian processes, law, languages, infrastructure, or governance arrangements transfer unchanged.

**Deliverables**

- Context-specific community co-design and legal/data-protection assessments.
- Local governance arrangements, language and accessibility evaluation, and infrastructure/security review.
- Documented interoperability and cross-border data-transfer analysis where relevant.

**Dependencies**

- Evidence from an appropriately evaluated pilot and explicit approval to expand.
- Local community representation, partner due diligence, and jurisdiction-specific legal review.

**Exit criteria**

- Each context has its own documented approval, governance, risk, and operational readiness decisions.
- Cross-border or multi-jurisdiction processing is reviewed and authorized where required.
- Expansion remains contingent on local community decisions and demonstrated safeguards.

