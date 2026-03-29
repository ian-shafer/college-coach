# Implementation Plan: PostgreSQL Migration

## Step 1: Provisions Platform Network Instances (Docker)
Create `.env` at the project root to centralize environment definitions (`POSTGRES_DB=unicoach`, `POSTGRES_USER=postgres`, `POSTGRES_HOST_AUTH_METHOD=trust`, `POSTGRES_PORT=5432`).
Create `docker/postgres-compose.yml` specifying the Postgres node isolation.
- Map image `postgres:16-alpine`.
- Use `env_file: ../.env` to inherit the isolated variables into the Postgres container cleanly.
- Bind exposed port dynamically via `ports: - "${POSTGRES_PORT}:5432"`.

## Step 2: Formulate Scripts Layer
Develop three discrete execution shells nested inside `bin/` referencing the Docker service interface.
- **SDD Anchor:** Construct a `/bin/SPEC.md` file explicitly detailing the architectural boundaries and responsibilities of these bash scripts, per the local SDD directory specification law.
- Establish `bin/db-status` checking four granular states and returning strict error vectors:
  1. Process up? (`pg_isready`) -> If false, exit code 1.
  2. Database `unicoach` created? -> If false, exit code 2.
  3. Version tracking `schema_migrations` created? -> If false, exit code 3.
  4. On the latest version? (Matches highest `db/schema/*.sql`) -> If false, exit code 4.
  If all succeed, return 0.
- Establish `bin/db-init`. It must first connect to the default `postgres` database to execute `CREATE DATABASE <POSTGRES_DB>;` (handling failures cleanly if it exists), then connect to `<POSTGRES_DB>` explicitly to send the `CREATE TABLE schema_migrations` payload, exiting safely if the table exists.
- Establish `bin/db-migrate` iterating `db/schema/*.sql`. It must securely handle missing tables (e.g., running before `db-init`) by verifying database state bounds beforehand.
- Establish `bin/db-connect` creating an interactive psql shell `docker compose -f docker/postgres-compose.yml exec postgres psql -U postgres -d unicoach`. It must execute `./bin/db-status` internally first to verify the database is initialized and reachable before dropping into the shell.
- Establish `bin/db-destroy` dropping the `$POSTGRES_DB` completely. Gate this action using user prompt `read` demanding `DESTROY` or `--destroy-my-data-forever`.
- Establish `bin/postgres-start`, `bin/postgres-stop`, `bin/postgres-restart`, and `bin/postgres-check`. They act as thin wrappers around `bin/{action}-daemon "postgres" "$POSTGRES_PORT"`. We will export `COMPOSE_FILE=docker/postgres-compose.yml` inside them to direct the underlying `docker compose` invocations gracefully without requiring `start-daemon` edits.

## Step 3: Scaffold Migrations Sequence (db/schema)
- **SDD Anchor:** Construct a `/db/schema/SPEC.md` file dictating the rigid SQL naming conventions, stateless restrictions, and dependency rules for adding new migrations.
- Construct `/db/schema/0001_initial_schema.sql` mapping the current SQLite structural model to formal PostgreSQL dialect (`CREATE TABLE users ...`).

## Step 4: Map Server Drivers
- Replace Exposed SQLite dependencies inside `rest-server/build.gradle.kts` targeting `org.postgresql:postgresql:42.7.2`.
- Update `com.echoapp.server.DatabaseFactory.kt`. Define connection strings mapping directly to the `System.getenv("POSTGRES_DB")` variables (with graceful fallbacks) and truncate the `SchemaUtils.create` function block.

## Step 5: Adapter Exceptions
- Target `com.echoapp.server.adapters.SqlUserRepository.kt`.
- Replace SQLite integer parsing logic with PostgreSQL SQLState checks (`sqlState == "23505"`).
- Remove static constants mapped inherently to SQLite.
