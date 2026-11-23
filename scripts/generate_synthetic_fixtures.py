#!/usr/bin/env python3
"""
Deterministic synthetic fixture generator for ACDT Phase 2A.

All identifiers are generated with UUID5 (namespace DNS) so that the output is
byte‑for‑byte identical across repeated executions.  Timestamps are fixed to
provide deterministic SQL/JSON files.

The generated data matches the **actual** table definitions in
`database/migrations/001_initial_schema.sql` (plural table names).
Both SQL and JSON outputs contain a clear **TEST ONLY** warning.
"""

import uuid
import json
import os
from datetime import timezone

# Fixed namespace and deterministic names
NAMESPACE = uuid.NAMESPACE_DNS
FIXED_TIME = "2026-11-16T00:00:00+00:00"

def deterministic_uuid(name: str) -> str:
    """Return a deterministic UUID5 string for the given name."""
    return str(uuid.uuid5(NAMESPACE, name))

def main():
    # ----- Organization -----
    org_id = deterministic_uuid("organization")
    organization = {
        "id": org_id,
        "name": "ACDT TEST ORGANIZATION",
        "slug": "acdt-test-org",
        "registration_number": "TEST-REG-001",
        "country": "Testland",
        "created_at": FIXED_TIME,
    }

    # ----- Participants -----
    participants = []
    for i in range(1, 4):
        participants.append({
            "id": deterministic_uuid(f"participant-{i}"),
            "organization_id": org_id,
            "participant_pseudo_id": f"TEST-PSEUDO-{i:03d}",
            "demographic_cluster": "test-cluster",
            "preferred_language": "en",
            "is_active": True,
            "created_at": FIXED_TIME,
        })

    # ----- Consent records -----
    consents = []
    for i, p in enumerate(participants, start=1):
        consents.append({
            "id": deterministic_uuid(f"consent-{i}"),
            "participant_id": p["id"],
            "study_protocol_ref": "TEST-PROTOCOL",
            "consent_version": "v1.0",
            "signature_verification_hash": "deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef",
            "consent_timestamp": FIXED_TIME,
        })

    # ----- Benefit sharing commitments -----
    benefits = []
    for i in range(1, 3):
        benefits.append({
            "id": deterministic_uuid(f"benefit-{i}"),
            "organization_id": org_id,
            "commitment_title": f"Test Benefit Commitment {i}",
            "commitment_type": "TEST_TYPE",
            "lead_partner": "Test Partner",
            "target_community": "Test Community",
            "delivery_status": "PROPOSED",
            "created_at": FIXED_TIME,
        })

    # ----- Build SQL output (plural table names) -----
    sql_lines = [
        "-- TEST ONLY — SYNTHETIC DATA. DO NOT LOAD INTO PRODUCTION.",
        "",
        # organizations
        f"INSERT INTO organizations (id, name, slug, registration_number, country, created_at) VALUES ('{organization['id']}', '{organization['name']}', '{organization['slug']}', '{organization['registration_number']}', '{organization['country']}', '{organization['created_at']}');",
    ]

    for p in participants:
        sql_lines.append(
            f"INSERT INTO participants (id, organization_id, participant_pseudo_id, demographic_cluster, preferred_language, is_active, created_at) VALUES ('{p['id']}', '{p['organization_id']}', '{p['participant_pseudo_id']}', '{p['demographic_cluster']}', '{p['preferred_language']}', {'TRUE' if p['is_active'] else 'FALSE'}, '{p['created_at']}');"
        )

    for c in consents:
        sql_lines.append(
            f"INSERT INTO consent_records (id, participant_id, study_protocol_ref, consent_version, signature_verification_hash, consent_timestamp) VALUES ('{c['id']}', '{c['participant_id']}', '{c['study_protocol_ref']}', '{c['consent_version']}', '{c['signature_verification_hash']}', '{c['consent_timestamp']}');"
        )

    for b in benefits:
        sql_lines.append(
            f"INSERT INTO benefit_sharing_commitments (id, organization_id, commitment_title, commitment_type, lead_partner, target_community, delivery_status, created_at) VALUES ('{b['id']}', '{b['organization_id']}', '{b['commitment_title']}', '{b['commitment_type']}', '{b['lead_partner']}', '{b['target_community']}', '{b['delivery_status']}', '{b['created_at']}');"
        )

    sql_content = "\n".join(sql_lines) + "\n"

    # ----- Write files -----
    out_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "synthetic_fixtures"))
    os.makedirs(out_dir, exist_ok=True)
    sql_path = os.path.join(out_dir, "fixtures.sql")
    json_path = os.path.join(out_dir, "fixtures.json")

    with open(sql_path, "w", encoding="utf-8") as f_sql:
        f_sql.write(sql_content)

    with open(json_path, "w", encoding="utf-8") as f_json:
        json.dump({
            "metadata": "TEST ONLY — SYNTHETIC DATA",
            "organization": organization,
            "participants": participants,
            "consents": consents,
            "benefit_sharing_commitments": benefits,
        }, f_json, indent=2)

    # ----- Report -----
    print("Generated synthetic fixtures:")
    print(f"  SQL file: {sql_path}")
    print(f"  JSON file: {json_path}")
    print(
        f"  Records: 1 organization, {len(participants)} participants, {len(consents)} consent records, {len(benefits)} benefit commitments"
    )

if __name__ == "__main__":
    main()
