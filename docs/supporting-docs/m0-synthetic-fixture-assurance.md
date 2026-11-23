# ACDT M0.2 Synthetic Fixture Assurance Review

**Review date:** 2026-11-13
**Scope:** Read-only review of existing sample, seed, fixture, and demonstration data. This report does not authorize or implement fixture changes.

## 1. Executive summary

**Recommendation: DO NOT APPROVE THE CURRENT SAMPLE ROWS FOR PROTOTYPE OR DEMONSTRATION USE.**

The only data-bearing fixture source found is the sample `INSERT` section in the PostgreSQL migration. The `database/seed/` and `apps/web/` directories are empty, and no separate seed, fixture, or demonstration-data files were found in the repository working tree.

The migration labels its rows synthetic, and some identifiers have obvious test-like patterns. Those cues do not establish the provenance of the organization, registration-style value, community/location labels, partner/funder references, participant categories, consent records, hashes, or proposed benefit records. Several rows could be read as evidence of real consent, local participation, existing institutional relationships, or proposed commitments. No sample research-access request is inserted, but the schema itself does not make future records unmistakably test-only.

Do not execute the migration or use its current sample rows in a prototype or demonstration. The consistent fictional replacement proposal in Section 6 is for review only. Obtain approval before changing any fixture or migration; verify and label any future fixture so it remains recognizable as test data in exports and outside the application.

## 2. Files inspected

- [001_initial_schema.sql](../../database/migrations/001_initial_schema.sql), including its schema and embedded sample `INSERT` statements.
- Repository file inventory outside `.git`, including hidden files. No additional seed, fixture, or demonstration-data files were found.
- [README.md](../../README.md), ACDT_Phase1_Documentation_Review.txt, and the files under [docs/](.) were searched for sample-data, fixture, and demonstration references.
- The local placeholder directories `database/seed/` and `apps/web/` contain no files (and are local empty placeholders, not published components).

No SQL was executed. No database or external service was contacted, and no organization, person, community, or institution was contacted to establish provenance.

## 3. Sample-data categories and classifications

The migration’s inserts encode one organization row, three participant rows, three consent rows, and two benefit-sharing rows. There are no inserted access-request or audit-log rows. These are counts of values in the SQL text, not claims about rows in a database.

| Sample category | Classification | Reason |
|---|---|---|
| Organization name, slug, and country context | **POTENTIALLY REAL OR MISLEADING** | The human-readable name and Nigeria context could be interpreted as identifying a real organization or asserting a real relationship. The repository does not establish that they are fictional. |
| Registration-style identifier | **POTENTIALLY REAL OR MISLEADING** | Its format resembles a real registration identifier. No source or reserved test namespace is documented. |
| Community and location labels | **POTENTIALLY REAL OR MISLEADING** | The named locations and community descriptions may refer to real places or populations. They could imply that those communities participated. |
| Partner and funder references | **POTENTIALLY REAL OR MISLEADING** | The named entities and internal team references can imply actual partnerships, funding, or research activity. No relationship is confirmed by these rows. |
| Participant records and demographic clusters | **POTENTIALLY REAL OR MISLEADING** | There are no participant names or direct contact fields in the inserts, but the person-like records and plausible demographic or health-adjacent categories could be interpreted as describing real participants. |
| Participant pseudo-identifiers | **AMBIGUOUS** | A synthetic-looking prefix suggests test intent, but location-coded portions and the absence of provenance do not prove the records are fictional. |
| Fixed, repeated-pattern primary-key UUID literals | **CLEARLY FICTIONAL** as identifier values only | The repeated-digit patterns are obvious fixture-style identifiers. They do not prove that the linked descriptive values or relationships are fictional. |
| Consent records and permission values | **POTENTIALLY REAL OR MISLEADING** | The rows indicate research-use permission, and omitted status/timestamp values would receive schema defaults of `ACTIVE` and the current time if executed. This can look like valid, current consent. |
| Signature or verification hash values | **POTENTIALLY REAL OR MISLEADING** | Fixed digest-like literals in a field named for signature verification can imply verified evidence. The repository documents no signature source, verification process, or relationship between these values and a consent act. |
| Research access request records | **NOT APPLICABLE** | No access-request rows are inserted. The table’s `PENDING_REVIEW` default is schema behavior, not a sample approval or access grant. |
| Benefit-sharing commitments | **POTENTIALLY REAL OR MISLEADING** | The specific partner, community, and target descriptions can imply real proposals or institutional relationships. A `PROPOSED` status does not establish that the records are fictional. |
| Sample audit events | **NOT APPLICABLE** | No audit-log rows are inserted. |

## 4. Provenance limitations

- The SQL comment labels the seed section synthetic and says it is for synthetic-environment testing. That is an assertion in the file, not independently verifiable provenance.
- No fixture-generation script, provenance record, or source documentation was found.
- No real-world validation was attempted, as required. This review cannot determine whether any value matches a real organization, identifier, partner, location, community, or person.
- No participant names or direct contact details were observed in the embedded participant inserts. That observation does not establish that the records are wholly synthetic or safe.
- The consent rows explicitly set research-use permission to true. Their status and timestamp are omitted, so executing the SQL would apply the schema defaults. A digest-like value is not proof of consent, signature, identity, or verification.
- No access request is seeded, so the migration does not contain a sample approved research request. This does not make the other consent or benefit records safe to present as real.
- No SQL was run, so no statement here describes the state of a database.

## 5. Proposed fictional data standard

Use one consistent, conspicuous test namespace across records and exports:

1. Prefix every fixture alias and every free-text record label with `TEST-` or `TEST ONLY`; include a persistent statement such as `SYNTHETIC TEST DATA — NOT REAL PEOPLE, COMMUNITIES, APPROVALS, OR AGREEMENTS`.
2. Use invented organization names such as `ACDT TEST ONLY — Example Organization 001`, a registration placeholder such as `TEST-NOT-REAL-ORG-001`, and slugs such as `test-org-001`. Do not use real registration formats or plausible organization names.
3. Use `TEST COMMUNITY 001 — FICTIONAL — NO REAL LOCATION` rather than named communities, neighborhoods, or settlements. Do not imply actual community participation.
4. Use invented partner/funder labels, for example `TEST PARTNER 001 — FICTIONAL`, and reserved example-domain addresses such as `test-contact-001@example.org` only when a contact value is needed. Avoid real phone numbers; use an explicitly non-routable test token or omit them.
5. Use deterministic participant aliases such as `TEST-P001` and `TEST-P002`, and generic categories such as `TEST-COHORT-A`. Do not include real names, contact data, health data, or demographic combinations that could identify or suggest actual people. Use a private-use language tag such as `x-test` only if the eventual application validates it as a test tag.
6. Map logical fixture aliases to deterministic UUIDs from a dedicated test-only namespace if a database schema requires UUIDs. Keep the alias-to-UUID map with the fixture specification; do not rely on ordinary production-style identifiers to convey test status.
7. Represent consent only as test workflow state, with every permission explicitly set to false, a conspicuous state such as `TEST_NOT_CONSENTED`, and a placeholder such as `TEST-NO-SIGNATURE-EVIDENCE`. Never use a digest-like value as mock consent evidence or allow a test placeholder to pass a real consent verifier.
8. Use request states such as `TEST_NOT_APPROVED`. If a positive authorization path must be exercised, use only an isolated simulation with test actors and a state explicitly named `TEST_APPROVED_SIMULATION`; it must never grant access to real or non-test data or be represented as a real governance decision.
9. Keep benefit-sharing records at `TEST_NOT_APPROVED` or `TEST_PROPOSED_SIMULATION`; do not present them as agreed, funded, delivered, or verified.
10. Do not rely on `NOW()` defaults to imply real activity. Set nullable event timestamps explicitly to `NULL` where appropriate or use a fixed, documented test timestamp; never use the time a migration happens to run as evidence of consent, review, or delivery.
11. Carry a row-level fixture marker and dataset-level label through application views, downloads, logs, and exports. A banner alone is insufficient because rows can be detached from the application.

## 6. Replacement fixture proposal

The following is a coherent proposal, not data to insert. The aliases define relationships; a future approved fixture process would map them to deterministic UUIDs for UUID columns.

| Existing record category | Concern | Proposed fictional replacement | Reason |
|---|---|---|---|
| Organization and registration-style identifier | Could identify or resemble a real organization and registry entry. | `ORG-TEST-001`: `ACDT TEST ONLY — Example Organization 001`; registration `TEST-NOT-REAL-ORG-001`; slug `test-org-001`; country `TEST-ONLY` or explicitly `NULL` (do not rely on the Nigeria default). | Makes the entity and identifier visibly non-real and avoids asserting a real location. |
| Community/location | Could imply participation by a real place or population. | `COMM-TEST-001`: `TEST COMMUNITY 001 — FICTIONAL — NO REAL LOCATION`. | Preserves a relationship target for workflow tests without naming an actual community. |
| Partner/funder | Could imply a real partnership, funding, or endorsement. | `PARTNER-TEST-001`: `TEST PARTNER 001 — FICTIONAL`; optional contact `test-contact-001@example.org`. | Uses a fabricated label and a reserved example domain. |
| Participants and identifiers | Person-like records and location-coded identifiers may suggest actual people or cohorts. | `P-TEST-001` and `P-TEST-002`, linked only to `ORG-TEST-001`; use `TEST-COHORT-A/B`, no personal/health details, and `x-test` only where validated. | Stable, deterministic test actors with no real demographic or location claims. |
| Consent records and signature evidence | Active-looking permission and hash fields can be mistaken for actual consent or verified identity. | `CONSENT-TEST-001/002`, linked respectively to `P-TEST-001/002`; protocol `TEST-PROTOCOL-001`; status `TEST_NOT_CONSENTED`; all permission flags explicitly false; evidence `TEST-NO-SIGNATURE-EVIDENCE`; set the nullable consent timestamp explicitly to `NULL`. | Tests record relationships without asserting a real consent event or evidence. |
| Research access request | A valid-looking request or approval could be mistaken for research authorization. | `REQ-TEST-001`, linked to `ORG-TEST-001`, with requester institution `PARTNER-TEST-001 — FICTIONAL` and cohort `TEST-COHORT-A`; purpose `SIMULATION ONLY — SYNTHETIC DATA`; explicitly set status `TEST_NOT_APPROVED`. An isolated positive-path test may use `TEST_APPROVED_SIMULATION` with fictional, distinct test actors. | Makes the request non-operational and differentiates simulated workflow outcomes from real approval. |
| Benefit-sharing commitment | Could imply an actual agreement, partner, beneficiary community, or delivery plan. | `BENEFIT-TEST-001`, linked to `ORG-TEST-001`, `PARTNER-TEST-001`, and `COMM-TEST-001`; title `TEST ONLY — Simulated Benefit Record`; status `TEST_NOT_APPROVED`; target date explicitly `NULL`; no claim of delivery. | Keeps the relationship graph internally consistent while clearly denying real agreement or delivery. |

Do not use this table as authorization to change or execute the migration. Schema support for fixture markers, test-only states, and export labels requires separate design and approval.

## 7. Data-model implications

The current sample records could be misread in several ways:

- **Real consent:** Explicit research-use permission, an `ACTIVE` default, a current-time default, and digest-like values create a strong appearance of consent. None of those fields proves that informed consent was obtained or validated.
- **Research authorization:** No access-request sample is present, and no approval is seeded. Consent permission alone must not be presented as institutional, ethics, governance, or technical access approval.
- **Community participation:** Named community/location labels and participant-like rows can suggest that people from those communities participated, even without names.
- **Institutional partnerships:** Organization and partner/funder references can imply actual relationships or endorsement. No partnership is established by the SQL.
- **Benefit-sharing agreements:** `PROPOSED` status is not approval, but specific counterparties and targets can still look like real commitments.
- **Verified identity or signatures:** Pseudonymous IDs and hash-shaped strings do not verify a person, a signature, consent, or an authorized actor.

For a future prototype, visibly label every screen and record with `TEST ONLY — SYNTHETIC DATA`. Keep the label on each row and in exported files, and use unmistakable test values in every linked table. Positive-path approvals must be marked as simulations and isolated from real data and real authorization. These are recommendations, not controls implemented in the current repository.

## 8. Outstanding risks

1. **Unverified provenance:** No method in the repository establishes that the current sample values are invented.
2. **Consent implication:** The seeded permissions and defaults could create apparent active consent if the migration were executed.
3. **Misleading identity evidence:** Hash-like values and pseudonyms may be mistaken for verified signatures or identity controls.
4. **Real-world association:** Organization, registration-style, partner, and location values may identify or suggest actual entities or communities.
5. **Export detachment:** Application-only labels would not protect records once copied into a file or report.
6. **Schema limitations:** The current schema has no explicit fixture marker or database-enforced test-only namespace; the request table has no sample rows, but future rows could still be misrepresented.

## 9. Recommendation for approval

**Current embedded sample rows: NOT APPROVED for a prototype, demo, or future data load.**

Approve only the proposed fictional-data convention for further review, subject to owner approval and a check that each replacement is unmistakably fictional and remains labelled in exports. Any changes to fixtures or migrations require separate explicit approval. Do not execute the migration or use real participant, health, or personal data.

This review does not assert legal compliance, security certification, actual community approval, valid consent, research authorization, or an existing partnership. Wait for approval before modifying any fixture or migration.
