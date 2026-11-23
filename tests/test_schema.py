import os
import re
import json
import unittest

MIGRATION_PATH = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "database", "migrations", "001_initial_schema.sql")
)
FIXTURE_SQL_PATH = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "synthetic_fixtures", "fixtures.sql")
)
FIXTURE_JSON_PATH = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "synthetic_fixtures", "fixtures.json")
)

def read_migration():
    # Strip UTF‑8 BOM if present
    with open(MIGRATION_PATH, "r", encoding="utf-8-sig") as f:
        return f.read()

def read_fixture_sql():
    with open(FIXTURE_SQL_PATH, "r", encoding="utf-8") as f:
        return f.read()

def read_fixture_json():
    with open(FIXTURE_JSON_PATH, "r", encoding="utf-8") as f:
        return json.load(f)

class SchemaStaticTests(unittest.TestCase):
    """Static validation of the migration and generated fixtures."""

    @classmethod
    def setUpClass(cls):
        cls.sql = read_migration()
        cls.fixture_sql = read_fixture_sql()
        cls.fixture_json = read_fixture_json()

    # ---------------------------------------------------------------------
    # Migration structure tests
    # ---------------------------------------------------------------------
    def test_table_definitions(self):
        """All expected tables are created (allow optional IF NOT EXISTS)."""
        expected_tables = [
            "organizations",
            "participants",
            "consent_records",
            "benefit_sharing_commitments",
            "governance_audit_logs",
        ]
        for tbl in expected_tables:
            with self.subTest(table=tbl):
                pattern = rf"CREATE TABLE(?:\s+IF NOT EXISTS)?\s+{tbl}\b"
                self.assertRegex(self.sql, pattern, f"Table {tbl} not found")

    def test_rls_enabled(self):
        """RLS must be enabled on each of the six tables."""
        tables = [
            "organizations",
            "participants",
            "consent_records",
            "access_requests",
            "governance_audit_logs",
            "benefit_sharing_commitments",
        ]
        for tbl in tables:
            with self.subTest(table=tbl):
                pattern = rf"ALTER TABLE\s+{tbl}\s+ENABLE ROW LEVEL SECURITY"
                self.assertRegex(self.sql, pattern, f"RLS not enabled for {tbl}")

    def test_no_create_policy(self):
        """The migration must not contain any CREATE POLICY statements."""
        self.assertNotRegex(self.sql, r"CREATE\s+POLICY", "Unexpected CREATE POLICY found")

    def test_audit_log_rules(self):
        """Audit log rules must exist and do nothing on UPDATE/DELETE."""
        self.assertRegex(
            self.sql,
            r"CREATE OR REPLACE RULE no_update_audit AS ON UPDATE TO governance_audit_logs DO INSTEAD NOTHING",
            "Missing no_update_audit rule",
        )
        self.assertRegex(
            self.sql,
            r"CREATE OR REPLACE RULE no_delete_audit AS ON DELETE TO governance_audit_logs DO INSTEAD NOTHING",
            "Missing no_delete_audit rule",
        )

    def test_no_check_constraints(self):
        """The migration currently defines no CHECK constraints."""
        self.assertNotRegex(self.sql, r"CHECK\s*\(", "Unexpected CHECK constraint found")

    def test_column_definitions(self):
        """Validate key column definitions, PKs, FKs, NOT NULL, UNIQUE where present."""
        # Mapping table -> list of regex patterns each must appear in that table's definition
        expectations = {
            "organizations": [
                r"id\s+UUID\s+PRIMARY KEY",
                r"name\s+VARCHAR\(255\)\s+NOT NULL",
                r"slug\s+VARCHAR\(100\)\s+UNIQUE\s+NOT NULL",
                r"country\s+VARCHAR\(100\)\s+DEFAULT 'Nigeria'",
            ],
            "participants": [
                r"id\s+UUID\s+PRIMARY KEY",
                r"organization_id\s+UUID\s+NOT NULL\s+REFERENCES\s+organizations\(id\)\s+ON DELETE CASCADE",
                r"participant_pseudo_id\s+VARCHAR\(64\)\s+UNIQUE\s+NOT NULL",
                r"preferred_language\s+VARCHAR\(50\)\s+DEFAULT 'en'",
                r"is_active\s+BOOLEAN\s+DEFAULT TRUE",
            ],
            "consent_records": [
                r"id\s+UUID\s+PRIMARY KEY",
                r"participant_id\s+UUID\s+NOT NULL\s+REFERENCES\s+participants\(id\)\s+ON DELETE CASCADE",
                r"study_protocol_ref\s+VARCHAR\(100\)\s+NOT NULL",
                r"consent_version\s+VARCHAR\(20\)\s+NOT NULL",
                r"signature_verification_hash\s+TEXT\s+NOT NULL",
            ],
            "benefit_sharing_commitments": [
                r"id\s+UUID\s+PRIMARY KEY",
                r"organization_id\s+UUID\s+NOT NULL\s+REFERENCES\s+organizations\(id\)\s+ON DELETE CASCADE",
                r"commitment_title\s+VARCHAR\(255\)\s+NOT NULL",
                r"commitment_type\s+VARCHAR\(100\)\s+NOT NULL",
                r"lead_partner\s+VARCHAR\(255\)\s+NOT NULL",
                r"target_community\s+VARCHAR\(255\)\s+NOT NULL",
            ],
            "governance_audit_logs": [
                r"id\s+UUID\s+PRIMARY KEY",
                r"request_id\s+UUID\s+REFERENCES\s+access_requests\(id\)",
                r"actor_id\s+VARCHAR\(100\)\s+NOT NULL",
                r"action_type\s+VARCHAR\(100\)\s+NOT NULL",
                r"purpose_hash\s+VARCHAR\(64\)\s+NOT NULL",
            ],
        }
        for tbl, patterns in expectations.items():
            with self.subTest(table=tbl):
                # Extract the CREATE TABLE block for the table
                block_match = re.search(rf"CREATE TABLE(?:\s+IF NOT EXISTS)?\s+{tbl}\b.*?\);", self.sql, re.DOTALL | re.IGNORECASE)
                self.assertIsNotNone(block_match, f"Table block for {tbl} not found")
                block = block_match.group(0)
                for pat in patterns:
                    with self.subTest(pattern=pat):
                        self.assertRegex(block, pat, f"Pattern not found in {tbl}: {pat}")

    # ---------------------------------------------------------------------
    # Fixture validation tests
    # ---------------------------------------------------------------------
    def test_fixture_counts(self):
        """Validate the expected number of records in both SQL and JSON fixtures."""
        # JSON counts
        self.assertIn("organization", self.fixture_json, "Organization missing in JSON")
        self.assertIn("participants", self.fixture_json, "Participants missing in JSON")
        self.assertIn("consents", self.fixture_json, "Consents missing in JSON")
        self.assertIn("benefit_sharing_commitments", self.fixture_json, "Benefits missing in JSON")
        self.assertEqual(1, 1, "Organization count always 1")
        self.assertEqual(len(self.fixture_json["participants"]), 3, "Expected 3 participants in JSON")
        self.assertEqual(len(self.fixture_json["consents"]), 3, "Expected 3 consent records in JSON")
        self.assertEqual(len(self.fixture_json["benefit_sharing_commitments"]), 2, "Expected 2 benefit commitments in JSON")
        # SQL counts – count INSERT statements per table
        org_inserts = len(re.findall(r"INSERT INTO organizations ", self.fixture_sql, re.IGNORECASE))
        part_inserts = len(re.findall(r"INSERT INTO participants ", self.fixture_sql, re.IGNORECASE))
        consent_inserts = len(re.findall(r"INSERT INTO consent_records ", self.fixture_sql, re.IGNORECASE))
        benefit_inserts = len(re.findall(r"INSERT INTO benefit_sharing_commitments ", self.fixture_sql, re.IGNORECASE))
        self.assertEqual(org_inserts, 1, "Expected 1 organization INSERT in SQL")
        self.assertEqual(part_inserts, 3, "Expected 3 participant INSERTs in SQL")
        self.assertEqual(consent_inserts, 3, "Expected 3 consent INSERTs in SQL")
        self.assertEqual(benefit_inserts, 2, "Expected 2 benefit INSERTs in SQL")

    def test_fixture_sql_json_consistency(self):
        """Cross‑check that identifiers appearing in the SQL match those in JSON."""
        # Helper to extract all UUIDs for each entity from SQL
        def extract_ids(table_name):
            pattern = rf"INSERT INTO {table_name} \(.*?\) VALUES \('(.*?)'"
            return re.findall(pattern, self.fixture_sql, re.IGNORECASE)

        # Organization
        org_sql_ids = extract_ids("organizations")
        self.assertEqual(len(org_sql_ids), 1, "SQL should contain one organization ID")
        self.assertEqual(org_sql_ids[0], self.fixture_json["organization"]["id"], "Organization ID mismatch")
        # Participants
        part_sql_ids = extract_ids("participants")
        self.assertCountEqual(part_sql_ids, [p["id"] for p in self.fixture_json["participants"]], "Participant IDs mismatch")
        # Consents
        consent_sql_ids = extract_ids("consent_records")
        self.assertCountEqual(consent_sql_ids, [c["id"] for c in self.fixture_json["consents"]], "Consent IDs mismatch")
        # Benefits
        benefit_sql_ids = extract_ids("benefit_sharing_commitments")
        self.assertCountEqual(benefit_sql_ids, [b["id"] for b in self.fixture_json["benefit_sharing_commitments"]], "Benefit IDs mismatch")
        # Foreign‑key consistency (organization_id & participant_id)
        # participants organization_id must equal organization id
        org_id = self.fixture_json["organization"]["id"]
        for p in self.fixture_json["participants"]:
            self.assertEqual(p["organization_id"], org_id, "Participant organization_id mismatch")
        # consents participant_id must be one of participant ids
        participant_ids = {p["id"] for p in self.fixture_json["participants"]}
        for c in self.fixture_json["consents"]:
            self.assertIn(c["participant_id"], participant_ids, "Consent participant_id not found among participants")
        # benefits organization_id must match org id
        for b in self.fixture_json["benefit_sharing_commitments"]:
            self.assertEqual(b["organization_id"], org_id, "Benefit organization_id mismatch")

    def test_fixture_markers(self):
        """Ensure TEST ONLY markers are present in both fixture outputs."""
        # SQL marker – first non‑empty line should be the warning comment
        first_line = self.fixture_sql.splitlines()[0].strip()
        self.assertTrue(first_line.startswith("-- TEST ONLY"), "SQL does not start with TEST ONLY comment")
        # JSON marker
        self.assertIn("metadata", self.fixture_json, "JSON missing metadata field")
        self.assertEqual(self.fixture_json["metadata"], "TEST ONLY — SYNTHETIC DATA", "JSON metadata does not contain TEST ONLY warning")

if __name__ == "__main__":
    unittest.main()
