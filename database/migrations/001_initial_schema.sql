-- ============================================================================
-- Africa Community Data Trust (ACDT) - Database Schema
-- Framework: PostgreSQL 15+ / Supabase (with Row Level Security)
-- Purpose: Purpose-Bound Community Data Governance & Consent Engine
-- Note: Synthetic environment testing. No live sensitive clinical data.
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. ORGANIZATIONS (Host & Partner Tenants)
CREATE TABLE IF NOT EXISTS organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    registration_number VARCHAR(100),
    slug VARCHAR(100) UNIQUE NOT NULL,
    country VARCHAR(100) DEFAULT 'Nigeria',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. COMMUNITY PARTICIPANTS (Pseudonymized Registry)
CREATE TABLE IF NOT EXISTS participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    participant_pseudo_id VARCHAR(64) UNIQUE NOT NULL,
    demographic_cluster VARCHAR(100),
    preferred_language VARCHAR(50) DEFAULT 'en',
    contact_token_hash TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. CONSENT RECORDS & GRANULAR PREFERENCES
CREATE TABLE IF NOT EXISTS consent_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    participant_id UUID NOT NULL REFERENCES participants(id) ON DELETE CASCADE,
    study_protocol_ref VARCHAR(100) NOT NULL,
    consent_version VARCHAR(20) NOT NULL,
    allow_research_use BOOLEAN DEFAULT TRUE,
    allow_deidentified_secondary_use BOOLEAN DEFAULT FALSE,
    allow_commercial_ai_training BOOLEAN DEFAULT FALSE,
    allow_cross_border_federation BOOLEAN DEFAULT FALSE,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    revoked_at TIMESTAMPTZ,
    revocation_reason TEXT,
    consent_timestamp TIMESTAMPTZ DEFAULT NOW(),
    signature_verification_hash TEXT NOT NULL
);

-- 4. RESEARCH ACCESS REQUESTS (Purpose-Bound Enforcement)
CREATE TABLE IF NOT EXISTS access_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    requester_name VARCHAR(255) NOT NULL,
    requester_institution VARCHAR(255) NOT NULL,
    project_title VARCHAR(255) NOT NULL,
    stated_purpose TEXT NOT NULL,
    required_cohort_cluster VARCHAR(100),
    target_data_tier VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'PENDING_REVIEW',
    reviewed_by VARCHAR(255),
    review_notes TEXT,
    access_expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. TAMPER-RESISTANT AUDIT TRAIL
CREATE TABLE IF NOT EXISTS governance_audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id UUID REFERENCES access_requests(id),
    actor_id VARCHAR(100) NOT NULL,
    action_type VARCHAR(100) NOT NULL,
    purpose_hash VARCHAR(64) NOT NULL,
    records_impacted INT DEFAULT 0,
    ip_hash VARCHAR(64),
    metadata JSONB DEFAULT '{}'::JSONB,
    timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- 6. COMMUNITY BENEFIT-SHARING AGREEMENTS
CREATE TABLE IF NOT EXISTS benefit_sharing_commitments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    commitment_title VARCHAR(255) NOT NULL,
    commitment_type VARCHAR(100) NOT NULL,
    lead_partner VARCHAR(255) NOT NULL,
    target_community VARCHAR(255) NOT NULL,
    delivery_status VARCHAR(50) DEFAULT 'IN_PROGRESS',
    target_completion_date DATE,
    verification_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE consent_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE access_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE governance_audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE benefit_sharing_commitments ENABLE ROW LEVEL SECURITY;

-- Append-only rule for audit logs
CREATE OR REPLACE RULE no_update_audit AS ON UPDATE TO governance_audit_logs DO INSTEAD NOTHING;
CREATE OR REPLACE RULE no_delete_audit AS ON DELETE TO governance_audit_logs DO INSTEAD NOTHING;

-- SYNTHETIC TEST SEED DATA
INSERT INTO organizations (id, name, registration_number, slug, country)
VALUES 
('11111111-1111-1111-1111-111111111111', 'Slum & Rural Health Initiative (SRHI)', 'CAC/IT/NO/118942', 'srhi-ng', 'Nigeria')
ON CONFLICT (slug) DO NOTHING;

INSERT INTO participants (id, organization_id, participant_pseudo_id, demographic_cluster, preferred_language)
VALUES 
('22222222-2222-2222-2222-222222222221', '11111111-1111-1111-1111-111111111111', 'ACDT-SYN-LAG-001', 'Youth (18-24), Semi-Urban', 'yo'),
('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'ACDT-SYN-LAG-002', 'Community Health Worker', 'en'),
('22222222-2222-2222-2222-222222222223', '11111111-1111-1111-1111-111111111111', 'ACDT-SYN-IBD-003', 'Adolescent Caregiver', 'yo');

INSERT INTO consent_records (participant_id, study_protocol_ref, consent_version, allow_research_use, allow_deidentified_secondary_use, allow_commercial_ai_training, signature_verification_hash)
VALUES
('22222222-2222-2222-2222-222222222221', 'SRHI-MH-2027-ALPHA', 'v1.0', TRUE, TRUE, FALSE, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'),
('22222222-2222-2222-2222-222222222222', 'SRHI-MH-2027-ALPHA', 'v1.0', TRUE, TRUE, FALSE, 'ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb'),
('22222222-2222-2222-2222-222222222223', 'SRHI-MH-2027-ALPHA', 'v1.0', TRUE, FALSE, FALSE, '4e07408562bedb8b60ce05c1decfe3ad16b72230967de01f640b7e4729b49fce');

INSERT INTO benefit_sharing_commitments (organization_id, commitment_title, commitment_type, lead_partner, target_community, delivery_status, target_completion_date)
VALUES
('11111111-1111-1111-1111-111111111111', 'Community Health Worker Tablet & Connectivity Subsidy', 'EQUIPMENT', 'Mozilla Fellow Fund / DanYem', 'Ogba & Agege Communities', 'PROPOSED', '2027-11-30'),
('11111111-1111-1111-1111-111111111111', 'Open Mental Health Literacy & Digital Safety Workshops', 'CAPACITY_BUILDING', 'SRHI Research Team', 'Lagos Slum Settlements', 'PROPOSED', '2028-02-28');
