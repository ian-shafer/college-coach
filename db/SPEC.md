# Module Specification: db

## 🎯 Primary Purpose
This directory encapsulates the physical footprint containing Postgres definition scripts and initialization architectures for all overarching environment systems.

## 🏗 Architectural Boundaries
- **Schema Directory Enforcement:** All physical database DDL definitions and raw `.sql` files absolutely **MUST** be placed exclusively inside the nested `db/schema/` subdirectory correctly following its own isolated `SPEC.md`.
- **NO Generic Migration Paths:** Standard infrastructure scripts (like `bin/db-migrate` and `bin/db-init`) inherently parse definitions from `db/schema/`. Never accidentally create generic `db/migrations/` folders, as they will be permanently ignored by all validation lifecycles and cause execution desynchronization panics.
