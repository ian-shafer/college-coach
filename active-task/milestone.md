# Milestone: Queue Service

We must implement a high-performance asynchronous message queue. This will integrate into the application using Hexagonal Architecture. The domain layer will declare queue interactions through output ports. The infrastructure layer will implement these ports using a postgres outbox architecture, leveraging `SKIP LOCKED` and `LISTEN / NOTIFY` mechanisms. By avoiding external brokers like RabbitMQ or Redis, we reduce architectural complexity while guaranteeing concurrent-safe worker execution.

## Success Criteria
1. **Domain Isolation**: `QueuePublisher` and `QueueListener` interface ports exist in `service/`. The domain has zero dependency on postgres syntax.
2. **Dedicated Worker Server**: A new standalone JVM directory `queue-server` physically separates the asynchronous execution loops from `rest-server`. All background workers natively bind and execute inside this layer.
3. **Low-LOC Queue Abstraction**: Creating a new queue exclusively requires defining a default `QueueItemConfig` struct (containing `max_retries`, `retry_delay_ms`) bound to a `QueueType` enum value and `payloadType`. When calling `publish`, an optional `QueueItemConfig.Patch` struct can override any generic limits recursively for that specific message.
4. **Unified Schema Provisioning**: A schema migration constructs a unified single `queue_messages` table mapping every pipeline by managing a distinguishing `type` column alongside `payload` (JSONB), `status`, `attempt_count`, `max_retries`, `retry_delay_ms`, `process_after` (nullable), `locked_at`, and `locked_until` columns.
5. **Parallel Type Triggers**: The database pushes signals dynamically derived from the table via `NOTIFY` mechanisms parallelized across isolated listener threads mapped by their specific `type` queries.
6. **Concurrency Safety & Scheduling**: Workers process payloads natively using `SELECT ... WHERE type = 'T' AND (process_after IS NULL OR process_after <= NOW()) FOR UPDATE SKIP LOCKED`, preventing slow-processing queue types from paralyzing pipelines, while natively supporting future job scheduling or immediate processing.
7. **Dead-Letter Recovery**: Unacknowledged messages missing their `locked_until` deadline become available to other idle workers assigned to that specific `type` configuration.
8. **Historical Auditing**: When any worker completes a payload, it MUST delete the item from the localized active queue table and simultaneously insert a durable log documenting execution boundaries (`started_at`, `completed_at`, `attempt_count`) directly into a unified `queue_history` archival table parameterized by the origin `type`. Only successful executions should be logged.
9. **Failure Archival**: When an unhandled payload exception is caught, the system increments `attempt_count`. If the loop breaches the `max_retries` defined directly on the active row (resolved dynamically at publish-time), the target item MUST be deleted from the active queue and inserted directly into a `queue_failures` table preserving the original `payload`, `type`, boundary timestamps, and an explicit `error_messages` string.
10. **CLI Administration Suite**: The system must expose natively executable bash administration wrappers in the `/bin/` directory (`queue-status`, `queue-rm`, `queue-truncate`, `queue-insert`) operating securely directly over the database layers to visualize and override asynchronous tasks physically from the host terminal.

## Edge Cases
1. **Dropped Notifications**: If a network connection drops, `NOTIFY` packets are lost. The adapter must incorporate a fallback polling mechanism (e.g., executing a fallback fetch every 60s) to catch unacknowledged timeouts.
2. **Transaction Context Boundaries**: Publishing events to the queue must execute within the same database transaction as the original domain mutation (Outbox Pattern) to prevent ghost data if the request crashes.

## Dependencies
- Extrapolates upon the executed `postgres Migration` database configuration.
- Blocks `Email Authentication` milestone.

# Part 1: Domain & Port Declarations
- Create `domain/events/` defining standard JSON-serializable payloads.
- Define `QueuePublisher` port interface for pushing new events.
- Define `QueueListener` port interface for registering worker callbacks.
- Add boundary `SPEC.md` files for new directories.

# Part 2: postgres Schema Structure
- Write a DDL migration script generating the single generic `queue_messages` table tracking the strict Enum `type` boundary alongside the payload.
- Create the unified `queue_history` audit table defining `started_at`, `completed_at`, and a matching `type` origin value.
- Create the `queue_failures` dead-letter table defining `started_at`, `failed_at`, `error_messages`, `payload` (JSONB), and a matching `type` origin string.
- Define dynamic database-level `NOTIFY` triggers acting upon `INSERT` statements, securely passing the `type` column upstream to wake the specific distinct worker loops.

# Part 3: Architecture Extraction (`queue-server`)
- Create standard `queue-server/build.gradle.kts` declaring JVM and Exposed dependencies.
- Define a dedicated `docker/queue-server-compose.yml` service execution block targeting `queue-server`.
- Wrap lifecycle initialization bindings into `bin/queue-server-*` including the new abstraction `bin/daemon-restart`, migrating `rest-server-restart` and `postgres-restart` symmetrically.

# Part 4: Service Implementations
- Develop a low-LOC `QueueFactory` registry inside `service/` mapping generic handlers against their respective static `QueueItemConfig` configurations.
- Abstract all core database mapping logics internally inside a unified `service/PostgresQueueDao.kt` implementation.
- Bind independent background threads executing discrete `LISTEN` loops derived securely from the central worker registry on the `queue-server` boot.
- Construct the generic `SKIP LOCKED` transaction boundaries injecting the configured `type` filter, updating `status` and `locked_until` upon fetch.
- On successful payload finish, guarantee the transaction formally deletes the active target row and executes the `queue_history` insertion metrics securely. 
- On caught payload exception, guarantee the loop increments `attempt_count` and bumps `locked_until` respecting the row's specific `retry_delay_ms`. If the row's `max_retries` limit is breached, the active target row is definitively deleted and the `error_messages` is explicitly passed structurally into the `queue_failures` tracking table.
- Utilize `org.jetbrains.exposed:exposed-json` interpreting the strict `payloadType` `<T>` passed during setup tightly with postgres standard `JSONB` mappings.

# Part 5: Shell CLI Management Stack
- Establish `bin/queue-status` evaluating dynamic metrics utilizing `psql` counts (`pending`, `completed_at` limits, and `failures`) explicitly partitioned dynamically by `.type`.
- Establish `bin/queue-truncate` executing wiping blocks against the `queue_messages` table relying on explicit `[TYPE|ALL]` constraints.
- Establish `bin/queue-rm` allowing precise payload execution deletions intercepting explicit Postgres message UUID strings.
- Establish `bin/queue-insert` facilitating arbitrary JSONB inserts bound perfectly onto a `type` string directly from standard external terminal parameters.
