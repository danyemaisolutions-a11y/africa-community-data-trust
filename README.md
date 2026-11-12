# Africa Community Data Trust (ACDT)
> **Empowering African Communities to Control, Protect, and Benefit from Their Data.**

[![License: MIT](https://img.shields.io/badge/License-MIT-emerald.svg)](https://opensource.org/licenses/MIT)
[![Framework: Next.js](https://img.shields.io/badge/Framework-Next.js%2014+-black.svg)](https://nextjs.org/)
[![Database: PostgreSQL / Supabase](https://img.shields.io/badge/Database-PostgreSQL%20%2F%20Supabase-3178C6.svg)](https://supabase.com/)
[![Status: Concept / Synthetic Alpha](https://img.shields.io/badge/Status-Synthetic%20Alpha-orange.svg)]()

---

## 🌍 Overview

**Africa Community Data Trust (ACDT)** is an open-source, community-governed data trust and consent infrastructure platform. Designed with a **Nigeria-first, Africa-ready** architectural model, ACDT provides grassroots community organizations, public health researchers, and civil society with verifiable, privacy-preserving tools to govern sensitive datasets.

The platform addresses extractive data collection in global health and AI research by operationalizing:
1. **Granular Informed Consent:** Plain-language digital consent workflows with auditable revocation.
2. **Purpose-Bound Access Controls:** Programmatic enforcement ensuring researchers access only authorized data cohorts.
3. **Equitable Benefit-Sharing:** A transparent tracking ledger monitoring non-monetary and capacity-building returns to communities.
4. **Zero-Harm Synthetic Prototyping:** Complete architectural development and testing gated behind synthetic mock data to ensure zero participant risk prior to formal institutional ethics clearance.

ACDT is an open-source public-interest technology initiative stewarded by **DanYem Innotech AI Solutions Ltd (RC 10003216, Lagos, Nigeria)**.

---

## 🏛️ Core Architectural Modules

| Module | Purpose | Technical Implementation |
| :--- | :--- | :--- |
| **1. Consent Manager** | Granular, plain-language consent recording & withdrawal tracking | Next.js Client, Supabase Auth, UUID tracking |
| **2. Governance Engine** | Purpose-based permissions & organizational tenant boundaries | PostgreSQL Row Level Security (RLS) |
| **3. Privacy Layer** | Complete separation of direct identifiers from research attributes | Deterministic Pseudonymization, AES-256 |
| **4. Audit Trail** | Tamper-resistant logging of all data queries & permission checks | PostgreSQL Append-Only Rules |
| **5. Benefit Tracker** | Tracking community commitments, milestones, and deliverables | Relational ledger & oversight dashboard |
| **6. Advisory AI Assistant** | Accessible language summaries and local translation assistance | Server-side LLM pipeline (strictly advisory) |

---

## 📂 Repository Structure

```text
africa-community-data-trust/
├── apps/
│   └── web/                   # Next.js App Router (Platform UI & Portals)
├── database/
│   ├── migrations/            # PostgreSQL DDL migrations
│   │   └── 001_initial_schema.sql
│   └── seed/                  # Synthetic mock datasets (Zero-risk testing)
│       └── 001_synthetic_seed.sql
├── packages/
│   ├── ui/                    # Reusable Tailwind / accessible UI components
│   ├── consent-core/          # Consent validation and hashing utilities
│   └── audit-logger/          # Tamper-resistant event logging wrappers
├── docs/
│   ├── architecture.md        # Threat model & multi-tenant security design
│   ├── ethics-safeguards.md   # NDPA 2023 alignment & synthetic data policy
│   └── benefit-sharing.md     # Community reciprocity framework
├── .env.example
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```
