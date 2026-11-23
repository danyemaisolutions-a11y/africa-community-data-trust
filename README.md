# Africa Community Data Trust (ACDT)

The Africa Community Data Trust (ACDT) is an **open‑source research proposal and prototype architecture** exploring community‑centred data governance and digital consent models.

ACDT's intended starting point is Nigeria, with an architecture designed to be evaluated and adapted with communities and institutional collaborators across African contexts. The project is currently at an early documentation and database-control prototyping stage. **It is not an operational data trust, an established community‑governed platform, or a production‑ready research infrastructure** for collecting or managing real participant data.

## Mission and Context

Communities frequently contribute data to research and technological initiatives without meaningful visibility, ongoing choice, or influence over how that data is stewarded, who accesses it, or what non‑monetary benefits flow back locally. ACDT explores practical, accountable technical models to support community participation and informed decision‑making throughout the research data lifecycle.

The project vision explores:

- **Community‑informed governance:** Exploring consultative mechanisms to help communities shape data‑use rules and research priorities.
- **Understandable consent choices:** Investigating granular consent models, localized summaries, and accessible routes to change or withdraw permission where consent serves as the applicable lawful basis.
- **Purpose‑bound research access:** Technical designs to limit prospective access to verified, specific research purposes reviewed through an accountable process.
- **Decision transparency:** Exploring auditable record‑keeping designs to help communities understand access decisions and data stewardship.
- **Equitable reciprocity:** Transparent tracking of non‑monetary, educational, and capacity‑building returns pledged to participating communities.

These represent design goals and exploratory concepts for future consultation, prototyping, and independent validation – **not claims that the current repository delivers operational capabilities**.

## Technology and Architecture Vision

The proposed architecture is a multi-tenant web application backed by
an API/service layer and PostgreSQL.

The initial database migration is stored in
`database/migrations/001_initial_schema.sql`. Additional local development
work includes Stage B migration, security-test, and administrator-bootstrap
scripts under `database/stage-b-review/`. The four Stage B source/package files are recorded in Git commit `70a241b`; the generated rehearsal bundle remains local-only.

For the Supabase development project `acdt-dev`, the project owner reported:

- The Stage B migration was committed.
- A transaction-and-rollback security rehearsal reported 52 passing
  sequential assertions.
- The five checked Stage B tables were confirmed present after commit.
- The first platform governor was appointed, and the saved role and active
  profile were verified in a separate query.

These are development checkpoint results, not independent security
certification or evidence of production readiness.

The local `apps/web` directory is currently an empty placeholder.
No implemented web application, API layer, or end-to-end application
sign-in workflow has been established by this review.

Technical administration does not constitute community representation,
institutional approval, or authorization to process participant data.

## Implementation Status

Technical capabilities within this repository and ongoing development are categorised according to verified repository evidence and project-owner-reported development checkpoints:

| Category | Implementation Status in Repository and Development |
| :--- | :--- |
| **1. Original baseline migration** | Initial PostgreSQL DDL migration (`database/migrations/001_initial_schema.sql`) represents the original baseline schema rather than the entirety of current development. It defines six core relational tables, enables PostgreSQL Row‑Level Security (RLS), defines SQL‑level update/delete suppression rules on the audit table (`no_update_audit`, `no_delete_audit` DO INSTEAD NOTHING), and inserts illustrative synthetic sample records. In this original baseline migration specifically, no explicit `CREATE POLICY` statements were defined, and its SQL rules prevent routine modification via standard queries but do not constitute a cryptographically verifiable or independently tamper‑evident audit system. The complete current database security posture cannot be inferred from this baseline migration alone. |
| **2. Stage B development checkpoint (reported)** | In the Supabase development project `acdt-dev`, the project owner reported the following development checkpoint results: the Stage B migration was committed; a transaction-and-rollback security rehearsal reported 52 passing sequential assertions; the five checked Stage B tables were confirmed present after commit; and the first platform governor was appointed, with the saved role and active profile verified in a separate query. The Stage B migration, security-test, administrator-bootstrap template, and package README under `database/stage-b-review/` are recorded in Git commit `70a241b`. The generated rehearsal bundle remains local-only. |
| **3. Prototype & synthetic demonstrations** | Synthetic mock datasets (`synthetic_fixtures/fixtures.json`, `synthetic_fixtures/fixtures.sql`) and fixture generator scripts (`scripts/generate_synthetic_fixtures.py`) demonstrating schema relationships in test environments only. (The directory `database/seed/` is an empty local placeholder, and `001_synthetic_seed.sql` was an early proposed path, not an included file.) The schema represents fields for consent records, pseudonymous identifiers, access requests, and benefit commitments. |
| **4. Architectural concepts & unestablished workflows** | Purpose‑based cohort access controls, deterministic pseudonymisation pipelines, a cryptographically verifiable tamper‑evident audit architecture, and reciprocity registers. While Stage B checks validated database-level security assertions in development, complete consent and revocation handling, decision-to-grant consistency, consent-aware data release, and benefit-sharing workflows are not established by the Stage B checks. |
| **5. Planned future capabilities** | Production web application and client portals (`apps/web` is currently an empty placeholder), server-side API layer, end-to-end application sign-in and authorization workflows, multilingual translation tools, and formal community governance tooling. |

**Important:** Development checkpoint results in `acdt-dev` are project-owner-reported milestones, not independent security certification or evidence of production readiness. The local `apps/web` directory is currently an empty placeholder, and end-to-end application sign-in and authorization have not been established. Prototyping must never process real participant or sensitive community research data.

## Security Status

ACDT is an early‑stage research prototype. In the original baseline migration (`database/migrations/001_initial_schema.sql`), Row‑Level Security was enabled on six core database tables without explicit `CREATE POLICY` statements, and SQL rules provided basic update/delete suppression on the audit table rather than comprehensive audit protection. The complete current database security posture cannot be inferred from the original baseline migration alone, as subsequent local development includes Stage B migration, security-test, and administrator-bootstrap scripts (`database/stage-b-review/`).

For the Supabase development project `acdt-dev`, the project owner reported development checkpoint results including 52 passing sequential assertions during a transaction-and-rollback security rehearsal, confirmation of five Stage B tables, and verified appointment of an initial platform governor. However, these checkpoint results do not constitute independent security certification, comprehensive audit coverage, or evidence of production readiness.

The local `apps/web` directory is currently an empty placeholder; end-to-end application sign-in, authentication, and application-layer authorization workflows are not established. Furthermore, complete consent and revocation handling, decision-to-grant consistency, consent-aware data release, and benefit-sharing workflows have not been established by the Stage B checks. The project's encryption configuration, key-management arrangements, operational monitoring, and audit coverage have not been comprehensively reviewed at this checkpoint. No claim of independently verified tamper-evidence or production security is made. Under no circumstances should real participant, health, clinical, or sensitive community research data be processed using this prototype.

## Development Principles & Safeguards

- **Community‑centred:** Governance arrangements must be defined with affected communities. DanYem may provide technical development and maintenance support, but is not the sole governance authority and does not unilaterally represent participating communities.
- **Purpose‑limited:** Any prospective data access should be specific, reviewed, and restricted to agreed research purposes.
- **Transparent:** Implemented controls must be strictly distinguished from proposals, and technical limitations must be documented openly.
- **Privacy‑conscious:** Minimise data, separate identifiers from research attributes, and conduct thorough risk assessments before handling any sensitive data.
- **Human‑accountable:** Any future AI‑assisted language tools (such as translations into Nigerian languages including Yoruba, Hausa, or Nigerian Pidgin) must remain strictly exploratory and subject to qualified human review. Autonomous data approvals and automated consent decisions are explicitly prohibited.
- **Synthetic‑data‑only:** Research fixtures, cohort tables, and prototype research datasets must consist strictly of synthetic mock data; no real participant, health, clinical, or community research records may be placed in this repository or development environments. This synthetic requirement applies strictly to all research data, distinguished from necessary developer or administrator authentication account details used in isolated development environments. Under no circumstances should real credentials, secrets, API keys, or real personal records be committed to the repository.
- **Zero‑harm (design aspiration only):** Zero‑harm represents a core ethical design objective and safety standard, **not** a self‑executing technical guarantee.
- **Evidence‑led:** Capabilities, security controls, and governance models must not be described as operational, effective, or production‑ready without rigorous testing and independent review.

## Governance and Accountability

- **Proposed Community Governance Council:** The proposed Community Governance Council described in project documentation is a **conceptual governance design**. It is **not currently constituted, elected, or delegated authority**. No community mandate, membership, or endorsement should be inferred.
- **Stewardship role:** Technical stewardship by DanYem Innotech AI Solutions Ltd (Lagos, Nigeria) represents open‑source code contributions and technical maintenance. It does not establish unilateral community oversight.
- **Community participation:** Operating arrangements, stewardship roles, and community benefit agreements require open consultation, independent validation, and democratic community agreement prior to any operational deployment.

## Data Protection, Lawful Basis, and Ethics

- **Consent vs. Lawful Basis:** Consent and lawful basis are distinct; consent alone does not guarantee lawful processing under the Nigeria Data Protection Act 2023 (NDPA) or other applicable law.
- **Compliance & safeguards:** ACDT does not claim any NDPA certification or statutory approval. Real‑world processing will only occur after appropriate legal, ethical, institutional and community safeguards are in place. Where the nature of the proposed research necessitates it, formal review and approval from an Institutional Review Board (IRB), Health Research Ethics Committee (HREC), or other competent ethics‑review body must be obtained before the relevant activities begin.

## Documentation

- [Proposed architecture](docs/architecture.md)
- [Proposed governance framework](docs/governance-framework.md)
- [Privacy and security principles](docs/privacy-and-security.md)
- [Staged development roadmap](docs/development-roadmap.md)
- [Factual implementation register](docs/implementation-status.md)

## Project Links

- **GitHub repository:** https://github.com/danyemaisolutions-a11y/africa-community-data-trust
- **DanYem corporate website:** https://danyem-ai-solutions.vercel.app
- **ACDT partnership landing page:** https://danyem-ai-solutions.vercel.app/acdt-partnership
- **ACDT technical research brief:** https://danyem-ai-solutions.vercel.app/research/africa-community-data-trust
- **Partnership enquiry portal:** https://danyem-ai-solutions.vercel.app/contact?service=acdt-partnership&source=acdt-readme

*Note: The DanYem website provides corporate and partnership information; it is not an operational ACDT participant portal or data service.*

## Contributing

Contributions to documentation, architectural discussion, and synthetic‑only technical prototypes are welcome through GitHub issues and pull requests. Before contributing:

1. Review the development principles and the [implementation register](docs/implementation-status.md).
2. Do not submit secrets, real participant information, clinical records, or personal data.
3. All code and documentation contributions are subject to the project principles and licence terms.

## Licence

This project is distributed under the MIT License. See [LICENSE](LICENSE).

The MIT License applies to the software and associated documentation covered by the repository licence. It does not grant ownership of, or unrestricted rights to use, participant records, personal information, community datasets or third‑party materials.