# Module Specification: db/schema

## 🎯 Primary Purpose
The single source of truth for the physical Postgres database domain, containing all forward-only DDL schemas sequenced strictly chronologically. This directory entirely manages definitions that Exposed ORM connects to. 

## 🏗 Architectural Boundaries
- **Immutable Sequence Rule**: Once a `.sql` file is committed to `main` and applied via `bin/db-migrate`, it MUST NEVER be edited. All structural corrections must manifest as novel migration files appended sequentially.
- **Pure SQL Only**: DDL definitions must never be abstracted behind ORM classes (like Exposed). Raw `.sql` limits domain magic.
- **Stateless Files**: Each `.sql` acts statelessly. `bin/db-migrate` encapsulates file injection within `BEGIN...COMMIT` blocks. Therefore, do NOT explicitly place `BEGIN;` or `COMMIT;` statements inside `db/schema/` files themselves to avoid nest collisions.

## 🔤 Naming Conventions & Alphabetical Sort Constraint
Every file MUST prepend a rigid zero-padded 4-digit version identifier to ensure chronologic numeric sorting natively handles state logic (e.g., `0001-initial-schema.sql`, `0002-add-email-index.sql`).

**CRITICAL BASH LOOP DEPENDENCY:** The `.sql` files MUST strictly sort in ascending alphabetical order based on their numerical prefixes. The underlying migration engines (`bin/db-init`, `bin/db-migrate`, `bin/db-status`) natively utilize standard Shell globbing (`for f in db/schema/*.sql`). Bash expands globs in explicit alphabetical order. If files are not named so that their alphabetical sort perfectly matches their chronological dependency sequence, the database boot procedure will fail structurally by applying them out of order!
