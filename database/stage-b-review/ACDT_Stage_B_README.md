# ACDT M6.2 Stage B — review package

## Files

### Published Stage B Package Files
The following four files constitute the Stage B source package recorded in Git commit `70a241b`:
- `ACDT_Stage_B_README.md`: this package guide and trust-boundary reference.
- `ACDT_Stage_B_01_migration.sql`: additive profile, organization-trust, membership, and role tables/functions for the reported Supabase schema.
- `ACDT_Stage_B_02_first_governor_bootstrap.sql`: explicit, one-time first-governor setup. It contains placeholders and cannot be run safely until those are deliberately replaced. The template source must remain unpopulated; any local filled-in copy must remain strictly outside the public repository.
- `ACDT_Stage_B_03_security_tests.sql`: suggested SQL checks for privileges and RPC behavior; run in a disposable copy with fixture identities.

### Local-Only Development Rehearsal Artifact (Excluded from Published Repository)
- `ACDT_Stage_B_REHEARSAL_ONLY.sql`: a local, generated convenience artifact combining migration and security-test content with preflight rehearsal guards and ending with `ROLLBACK;`. It was used for transaction-and-rollback testing in development and is retained locally only; it is **NOT included in the published repository checkout**, is not an additional migration, and is not an alternative source of truth. **Never change its final ROLLBACK to COMMIT.** Note that a rollback transaction does not make arbitrary SQL inherently harmless; always inspect the complete script and target database before execution.

## Status and assumptions
Review artifacts only. In the Supabase development project `acdt-dev`, the project owner reported the following development checkpoint results:
- The Stage B migration was committed to the database. (This database COMMIT is distinct from Git commit; the four Stage B source/package files are recorded in Git commit `70a241b`, while the generated rehearsal bundle remains local-only.)
- A transaction-and-rollback security rehearsal reported 52 passing sequential assertions.
- The five checked Stage B tables were confirmed present after commit.
- The first platform governor was appointed, and the saved role and active profile were verified in a separate query.

**Important:** These are project-owner-reported development checkpoint results, not independent security certification, comprehensive audit coverage, or evidence of production readiness. Migration installation and the initial governor appointment are already completed in the owner's `acdt-dev` checkpoint; the historical sequence below is preserved for reference and must not be interpreted as directions to rerun migration or bootstrap against that already-initialized database (which would fail preflight guards).

The local `apps/web` directory is currently an empty placeholder. End-to-end application sign-in, user authentication, and application-layer authorization workflows are not established. Furthermore, complete consent and revocation handling, decision-to-grant consistency, consent-aware data release, and benefit-sharing workflows have not been established by these database checks. Under no circumstances should real participant, health, clinical, or sensitive community research data be processed using this prototype.

## Trust boundaries
- Registration can create only the authenticated caller's profile. The RPC must run with a JWT identity; direct SQL as `postgres` has no user `auth.uid()`.
- Organisation records are not automatically verified. The first governor must explicitly set trust using `acdt_set_org_trust` with a reason.
- First governor setup requires a verified `auth.users.id` and privileged database-admin execution. It is not exposed to authenticated clients; never choose or share a secret key in place of the user UUID.
- Organization admins can assign researcher role only. Platform governance appoints organization administrators and governance reviewers. Reviewers/admins cannot approve their own membership.
- Membership suspension removes all org roles. Suspended users cannot reapply through this workflow. Reactivation is a controlled review transition.
- Internal trust, identity and role tables have RLS enabled and no client table grants. Public RPCs have explicit execute grants for authenticated, plus revokes for PUBLIC/anon/service_role to counter Supabase defaults.
- A singleton gate serializes Stage B RPC calls under READ COMMITTED. This is conservative and should be benchmarked.
- Existing records in organizations, participants, consents, requests, commitments, and audits are not rewritten. No profile is auto-created for a participant, and no initial org admin is guessed.

## Important limitations
- RPC audit rows are part of the calling transaction; caller rollback also removes the audit row. Use a trusted API transaction and external logs for durable security-event collection.
- A database administrator/superuser can bypass ordinary RLS and privileges. Secure privileged credentials and monitor administrative access.
- Stage B does not yet establish a participant-to-auth identity link, access decisions/grants, consent event history, or a data-release boundary. It is not a complete access control system.
- The existing audit table `actor_id` is text, so audit actor identity is recorded as text. New profile and role tables use auth UUIDs.
- If your Stage A SQL differs from the supplied script or the audit columns differ, stop and adapt rather than bypass preflight.

## Historical development and testing sequence
*Note: This sequence describes the testing and staging procedure used for review. It does not direct re-execution against the already-initialized `acdt-dev` project.*

1. Verify app remains in development/test and take a managed backup/snapshot.
2. Create a disposable project/copy matching this schema; apply Stage A and then Stage B migration.
3. Inspect `has_function_privilege` for anon/authenticated/service_role and run positive/negative tests under actual role and JWT claims.
4. Review first-governor identity through a trusted process; only then use the separate bootstrap script in a new environment. Keep any filled-in bootstrap file local and uncommitted.
5. Verify `acdt_my_identity`, membership request/review transitions, role scope, and audit output.
6. Commit to the real dev project only after review and successful tests; proceed to Stage C afterward.

## Policy decisions encoded for review
An active org admin can grant/revoke only `researcher`. Platform governors manage `org_admin` and `governance_reviewer`. This two-tier assignment policy avoids an org admin creating another approver but must be approved by your governance owners.
