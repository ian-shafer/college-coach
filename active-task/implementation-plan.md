# Implementation Plan: postgres Queue Service

This plan physically maps the architecture definitions approved during Phase 2 natively into code generation targets, adhering fundamentally to Hexagonal dependencies scaling a discrete worker environment off the Ktor thread path.

## User Review Required

> [!WARNING]
> **Hikari Connection Pool Limits**
> We are extending the backend Hikari config to statically calculate maximum pool widths dynamically at startup (`10 + NumRegisteredQueues`) since parallel `LISTEN` loops permanently hog explicit DB connections. Are you satisfied with dynamically linking this initialization scaling?

## Proposed Changes

---

### [Part 1: Domain & Port Declarations]

#### [NEW] [QueueType.kt](file:///Users/ian/Work/echo-app/queue-server/src/main/kotlin/com/echo/service/domain/events/QueueType.kt)
Declares the strict Enum tracking all permitted background pipeline names cleanly and safely rather than loosely matching un-typed strings.

#### [NEW] [QueueItemConfig.kt](file:///Users/ian/Work/echo-app/queue-server/src/main/kotlin/com/echo/service/domain/events/QueueItemConfig.kt)
Declares the base system struct tracking default limits (`maxRetries`, `retryDelayMs`). It also internally nests a `data class Patch(...)` explicitly emulating TypeScript's `Partial<T>` utility conceptually, exposing nullable fields (`maxRetries: Int? = null`, `processAfter: Instant? = null`) to explicitly patch defaults symmetrically per-publish.

#### [NEW] [QueuePublisher.kt](file:///Users/ian/Work/echo-app/queue-server/src/main/kotlin/com/echo/service/QueuePublisher.kt)
Declares the outbound Hexagonal interface mapping `publish<T>(type: QueueType, payload: T, patch: QueueItemConfig.Patch? = null)`.

#### [NEW] [QueueListener.kt](file:///Users/ian/Work/echo-app/queue-server/src/main/kotlin/com/echo/service/QueueListener.kt)
Declares the native callback interface signature.

#### [NEW] [QueuePayloads.kt](file:///Users/ian/Work/echo-app/queue-server/src/main/kotlin/com/echo/service/domain/events/QueuePayloads.kt)
Stub models abstracting `kotlinx.serialization` payload trees isolated under `service/`.

---

### [Part 2: postgres Schema Structure]

#### [NEW] [0002-create-queue-tables.sql](file:///Users/ian/Work/echo-app/db/schema/0002-create-queue-tables.sql)
Executes DDL statements allocating the unified schema space:
- Creates `queue_messages` with explicit computed properties bounding execution logic on the literal row: `max_retries`, `retry_delay_ms`, `process_after (nullable)`, `locked_until` (nullable), `attempt_count`, and core limits natively avoiding string parsing statuses cleanly.
- Creates `queue_history` resolving successful execution boundaries (`started_at`, `completed_at`, `attempt_count`).
- Creates `queue_failures` trapping dead-letter stack bounds (`error_messages`, `failed_at`).
- Defines native **PL/pgSQL Functions** (`fn_on_queue_message_complete`, `fn_on_queue_message_failure`) encapsulating state shifts organically. These functions execute complex `INSERT ... DELETE` boundaries automatically via a single JDBC call natively isolating logical invariants perfectly in the DB.
- Creates a Postgres Database `TRIGGER` on the table. Every time a new row is inserted, the DB fires a native Postgres `NOTIFY` event directly to our app forwarding the `type` column's name. The Kotlin workers maintain a sleeping `LISTEN` connection that wakes up instantly when it hears its mapped type without needing to actively poll the database every X seconds.

---

### [Part 3: Architecture Extraction (`queue-server`)]

#### [NEW] [build.gradle.kts](file:///Users/ian/Work/echo-app/queue-server/build.gradle.kts)
Allocates standard JVM execution framework declaring Exposed, Hikari, and Kotlinx dependencies isolated natively from `rest-server`.

#### [NEW] [queue-server-compose.yml](file:///Users/ian/Work/echo-app/docker/queue-server-compose.yml)
Adds `queue-server` execution target mapping `.env` and tracking JVM volume mounts completely isolated traversing dynamically alongside the `rest-server` configurations.

#### [NEW] [queue-server-start](file:///Users/ian/Work/echo-app/bin/queue-server-start)
#### [NEW] [queue-server-stop](file:///Users/ian/Work/echo-app/bin/queue-server-stop)
#### [NEW] [queue-server-check](file:///Users/ian/Work/echo-app/bin/queue-server-check)
#### [NEW] [queue-server-restart](file:///Users/ian/Work/echo-app/bin/queue-server-restart)
Standard `bin/` layer daemon scripts strictly wrapping PID evaluation sequences mapping the boot bounds into `var/run/queue-server.pid`.

#### [NEW] [daemon-restart](file:///Users/ian/Work/echo-app/bin/daemon-restart)
Creates a unified `stop` then `start` shell execution utility functionally abstracting restart bounds.

#### [MODIFY] [postgres-restart](file:///Users/ian/Work/echo-app/bin/postgres-restart)
#### [MODIFY] [rest-server-restart](file:///Users/ian/Work/echo-app/bin/rest-server-restart)
Refactors the legacy inline restart shells securely connecting the unified generic `daemon-restart` path.

---

### [Part 4: Service Implementations]

#### [NEW] [PostgresQueueDao.kt](file:///Users/ian/Work/echo-app/queue-server/src/main/kotlin/com/echo/service/PostgresQueueDao.kt)
Maps internal JetBrains Exposed `object : Table("...")` definitions binding to `queue_messages`, `queue_history`, and `queue_failures` schemas natively using `exposed-json`.

#### [NEW] [QueueFactory.kt](file:///Users/ian/Work/echo-app/queue-server/src/main/kotlin/com/echo/service/QueueFactory.kt)
Establishes the generic low-LOC worker registry seamlessly mapping Enum types explicitly to their default `QueueItemConfig` structs.

#### [NEW] [QueueWorkerService.kt](file:///Users/ian/Work/echo-app/queue-server/src/main/kotlin/com/echo/service/QueueWorkerService.kt)
Translates the `SKIP LOCKED` and `process_after` pipeline mechanics spanning the physical background HTTP loops trapping the `locked_until` timeout mutations recursively parsing row-level overrides natively against `max_retries` / `queue_failures` limits organically.

---

### [Part 5: Shell CLI Management Stack]

#### [NEW] [queue-status](file:///Users/ian/Work/echo-app/bin/queue-status)
Bash execution aggregating dynamic queue counts parsing via `docker compose -f docker/postgres-compose.yml exec postgres psql`.

#### [NEW] [queue-insert](file:///Users/ian/Work/echo-app/bin/queue-insert)
Script wrapping generic postgres JSONB string inserts onto `queue_messages` targeting parallel listener verifications.

#### [NEW] [queue-rm](file:///Users/ian/Work/echo-app/bin/queue-rm)
#### [NEW] [queue-truncate](file:///Users/ian/Work/echo-app/bin/queue-truncate)
Administration scripts clearing pipeline blocks safely by `type`.

## Verification Plan

### Automated Tests
- Will deploy automated loop verifications bypassing HTTP, directly parsing domains via the DB constraints.
- Will write unit tests for the queue adapter implementations.

### Manual Verification
- Invoking `bin/queue-server-start` physically in the isolated host OS and verifying the PID lifecycle safely.
- Inserting arbitrary JSON payloads via `bin/queue-insert` and watching the `queue_history` tables increment organically using `bin/queue-status`.
