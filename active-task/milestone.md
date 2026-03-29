# Milestone: PostgreSQL Migration

The current backend relies on SQLite for state storage. This sub-milestone migrates the primary database infrastructure from SQLite to PostgreSQL. Transitioning to PostgreSQL unlocks high-performance asynchronous `SKIP LOCKED` constraints critical for queue development and structured JSONB query capacity. This involves provisioning the local Docker network constraints, updating the Kotlin dependencies to load the PostgreSQL driver, altering the Exposed `DatabaseFactory` connection logic, and adjusting shell configurations.

It also introduces a custom, script-based DDL migration runner architecture (`db-init`, `db-migrate`, `db-status`) to formally track schema state without relying on Exposed's auto-creation tools.

## Success Criteria
1. `docker/postgres-compose.yml` encapsulates a working PostgreSQL 16 image and local developer credentials for a database named `unicoach`.
2. `build.gradle.kts` utilizes `org.postgresql:postgresql`.
3. The Ktor application connects to PostgreSQL successfully upon Application boot, bypassing Exposed auto-schema-creation.
5. `bin/db-init` idempotently provisions initial roles and an internal tracking table. The internal tracking table strictly conforms to: `CREATE TABLE schema_migrations (version VARCHAR PRIMARY KEY, applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);`
6. `bin/db-migrate` applies sequential DDL files from `db/schema/` safely, tracking updates. This script should be idempotent and can be run multiple times without causing any issues. This script should gracefully handle being called at any time e.g. before the database is initialized.
6. `bin/db-status` accurately reports database uptime and current schema version identifiers. This script should be idempotent and can be run multiple times without causing any issues. This script should gracefully handle being called at any time e.g. before the database is initialized.
7. `bin/db-connect` connects to the database and provides a `psql` prompt. This script is an easy way for the architect to verify the database state. This script should gracefully handle being called at any time e.g. before the database is initialized.
8. `bin/db-destroy` irreversibly drops the database. Requires explicit verification (typing `DESTROY` or passing `--destroy-my-data-forever`).
9. `bin/postgres-{start,stop,restart,check}` wrapped daemon scripts exist enforcing the daemon script skill guidelines securely tracking the postgres node.

## Edge Cases
1. **Dialect Mismatches / Exceptions**: Exposed handles query mapping, but specific SQLite constraint exceptions (e.g., Unique Violation code `2067`) mapped dynamically inside `SqlUserRepository.kt` must reflect PostgreSQL unique index violations (SQLState `23505`) to maintain existing profile update logic. *(Note: A dedicated integration testing sub-milestone will be executed immediately post-migration to verify this edge case).*
2. **[IMPORTANT] Partial Migrations**: Ensuring `db-migrate` uses transactions so a failing script does not leave the database logic partially applied.
3. **Docker Decomposition**: We will leave the existing non-Postgres VMs inside the primary `docker-compose.yml` for now. A dedicated sub-milestone will tackle migrating those into the `docker/` structure strictly after this milestone completes.

## Dependencies
- Local Docker environment.

# Part 1: Shell Migration Framework
- Implement a rigid bash `db/schema/` execution structure avoiding third-party software.
- Establish `bin/db-status` to test `pg_isready` and query the schema metadata table.
- Establish `bin/db-init` to execute the structural foundation.
- Establish `bin/db-migrate` with sorted iteration blocks running `.sql` scripts through `psql`.

# Part 2: Infrastructure Manifest
- Create `docker/postgres-compose.yml` defining a standard `postgres` service instance mapped to the `unicoach` database.
- Disable manual `SchemaUtils.create()` traces from `com.echoapp.server.DatabaseFactory.kt` anticipating the DDL scripts assume control.

# Part 3: Database Reconnection
- Modify `build.gradle.kts` adding the PostgreSQL JDBC driver.
- Update `DatabaseFactory.kt` to define PostgreSQL connection bindings (`jdbc:postgresql:`).

# Part 4: Exception Mapping (Adapter Review)
- Audit `SqlUserRepository.kt` and rewrite the SQLite constraint evaluation exception block to identify standard PostgreSQL SQLState `23505`.
