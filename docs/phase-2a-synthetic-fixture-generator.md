# Phase‑2A Synthetic Fixture Generator

This document records the **corrected** Phase 2A implementation.

## Files added / updated
- `scripts/generate_synthetic_fixtures.py` – deterministic UUID5‑based generator (no `random.seed`).
- `tests/test_schema.py` – proper `unittest.TestCase` suite with discoverable `test_` methods.
- `docs/phase-2a-synthetic-fixture-generator.md` – this documentation, now reflecting the final state.

## How to run the generator
```powershell
python scripts\generate_synthetic_fixtures.py
```
The script prints the locations of the generated files and a summary of **record counts**.  It writes to `synthetic_fixtures/fixtures.sql` and `synthetic_fixtures/fixtures.json`.

## How to run the tests
```powershell
python -m unittest discover -s tests -v
```
The test suite inspects the **static migration SQL** only; **no live database connection** is attempted, regardless of `DATABASE_URL`.

## Safety warnings
- All generated data is **TEST ONLY** – the SQL file begins with the comment:
  `-- TEST ONLY — SYNTHETIC DATA. DO NOT LOAD INTO PRODUCTION.`
- The JSON payload includes `"metadata": "TEST ONLY — SYNTHETIC DATA"`.
- The generator never modifies existing project files; it only writes to the `synthetic_fixtures/` directory.

## Implementation status
- **Implemented:** deterministic fixture generator, unittest suite, schema‑aligned INSERT statements.
- **Tested:** static migration checks (table existence, RLS enablement, audit‑log rules, absence of `CREATE POLICY`).
- **Static checks performed:** see `tests/test_schema.py`.
- **Not tested:** live PostgreSQL validation (explicitly excluded).
- **Not implemented:** any changes to the migration, RLS policies, or authentication.
- **Future work:** extend static tests to cover column‑level constraints (NOT NULL, UNIQUE, CHECK) if needed.

---
*Generated as part of Phase‑2A development.  No production‑ready fixtures are provided.*

This document describes the synthetic‑fixture generator and schema‑validation tests that were added to the ACDT repository.

## Files added
- `scripts/generate_synthetic_fixtures.py` – Python script that creates deterministic, **TEST ONLY** synthetic data matching the tables defined in `database/migrations/001_initial_schema.sql`.  It outputs:
  - `synthetic_fixtures/fixtures.sql` – SQL INSERT statements prefixed with a clear warning comment.
  - `synthetic_fixtures/fixtures.json` – JSON representation of the same records, also marked with a `metadata` field indicating test‑only data.
- `tests/test_schema.py` – Validation suite that performs static analysis of the migration file (and optionally live DB checks if `DATABASE_URL` is provided).  It verifies table existence, column constraints, RLS enablement, absence of `CREATE POLICY` statements, and presence of audit‑log rules.
- `docs/phase-2a-synthetic-fixture-generator.md` – This documentation file (the one you are reading).

## How to run the generator
```powershell
python scripts\generate_synthetic_fixtures.py
```
The script prints the locations of the generated files and a summary of record counts.

## How to run the tests
```powershell
python -m unittest discover -s tests
```
If a PostgreSQL instance is reachable via the `DATABASE_URL` environment variable, the test suite will attempt live checks (not implemented in this environment).  Otherwise it falls back to static checks of the migration SQL.

## Safety warnings
- All generated data is **TEST ONLY** – the SQL file begins with the comment:
  `-- TEST ONLY — SYNTHETIC DATA. DO NOT LOAD INTO PRODUCTION.`
- The JSON payload includes `"metadata": "TEST ONLY — SYNTHETIC DATA"`.
- The generator will **not** touch any existing project files; it writes only to the newly created `synthetic_fixtures/` directory.
- No changes have been staged, committed, or pushed.

---
*Generated as part of Phase‑2A development.  No production‑ready fixtures are provided.*
