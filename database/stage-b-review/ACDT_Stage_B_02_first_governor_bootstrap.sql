-- ACDT Stage B / one-time bootstrap / REVIEW and fill placeholders first
-- Run ONLY after Stage B migration committed. Run as postgres.
-- Replace the three placeholders with the VERIFIED Supabase Auth user UUID,
-- that user's chosen display name, and a meaningful governance record.
BEGIN;
SELECT acdt_security.bootstrap_first_governor(
  'REPLACE-WITH-VERIFIED-AUTH-USER-UUID'::uuid,
  'REPLACE-WITH-ADMIN-DISPLAY-NAME',
  'REPLACE-WITH-APPROVAL-REFERENCE-AND-REASON'
);
COMMIT;
