# Module Specification: Queue Server

## 🎯 Primary Purpose
This module encapsulates the background execution loop, polling the Postgre Native queue via `SKIP LOCKED` and `LISTEN/NOTIFY` channels. It manages asynchronous job workers entirely disconnected from incoming web-server traffic.

## 🏗 Architectural Boundaries
- **Allowed Inbound Callers:** The `rest-server` module is explicitly AUTHORIZED to depend upon and import code from `queue-server` (e.g., fetching domain events or queue publisher abstractions housed in `service/`).
- **Allowed Outbound Dependencies:** The `queue-server` module MUST NEVER depend on `rest-server`. It sits fundamentally beneath the HTTP wrapper layers in the architectural stack and operates completely isolated from web contexts.

## 🧩 Core Components
- **Generic Queue Factory / Registry:** The architecture exposes a unified registration interface binding human-readable `QueueItemConfig` defaults (Enum `QueueType`, `max_retries`, `retry_delay_ms`) to a Kotlin `payloadType`. A unified `publish(type, payload, patch: QueueItemConfig.Patch?)` port allows callers to patch/override any limits exclusively for that specific message footprint natively.
- **Unified Persistence DAO:** Rather than implementing massive polymorphic abstractions, a singular engine operates symmetrically upon a unified `queue_messages` table mapping independent workers against explicit `type` index bounds dynamically.
- **QueueWorkerService:** Orchestrator loop binding the database event triggers into actual functional execution blocks utilizing the mapped `type` execution handlers seamlessly across the system.

## 🔄 State & Data Flow
- **Data Mutability:** Internal database adapters receive serialized `JSONB` domain payloads and execute side-effects statelessley. Upon successful completion, workers MUST securely delete the active row from `queue_messages` and vigorously insert a permanent execution trace (including metric timestamps `started_at` and `completed_at`) into a historical `queue_history` audit table.
- **Dead-Letter Recovery Mechanism:** Items tracking an expired `locked_until` parameter without a matching completion or failure signal MUST seamlessly re-enter the idle pool to be natively picked up and re-attempted by adjacent `queue-server` processing threads matching that specific `type`.
- **Error Handling:** Unrecoverable worker exceptions must gracefully catch, log standard error signals, and physically increment the schema `attempt_count` while delaying `locked_until` explicitly based on the row's literal `retry_delay_ms` integer. Only if `attempt_count > max_retries` (reading from the explicit row calculation patched during insertion) should it avoid crashing the listener thread by definitively deleting the offending `queue_messages` row and dumping its payload, original `type`, and error stack-trace explicitly into the `queue_failures` dead-letter table (`error_messages` column).
- **Administration Visibility:** The table architectures strictly support real-time state introspection mapping directly to external host-layer CLI execution layers (e.g. `bin/queue-status`, `bin/queue-rm`).

## ⚠️ Strict Constraints & Known Gotchas
- **Database Thread Starvation (Multi-Queue):** Every distinct physical queue worker maps a dedicated `LISTEN` thread binding an exclusive database connection. The Hikari pool must explicitly expand by the exact number of dynamically configured `type` handlers, or execution starvation will physically crush Ktor routing processes.
- **Low-Boilerplate Abstraction:** Utilize a standard generic JDBC/Exposed table schema definition referencing `queue_messages`. Do NOT manually scale distinct Singletons defining fragmented execution schemas redundantly.
- **Head of Line Blocking Prevention:** Distinct workloads absolutely must declare rigorous constraints operating purely upon their explicit `WHERE type = 'X' AND (process_after IS NULL OR process_after <= NOW())` logic string to bypass gridlock spanning monolithic asynchronous delays, while structurally allowing tasks to be natively scheduled into the future or grabbed instantly.
- **Unidirectional Build Logic:** In `gradle` dependencies, `rest-server` maintains a `implementation(project(":queue-server"))` link, but injecting the inverse immediately causes circular dependency panics or architectural collapse.
- **Container Orchestration Scaling:** The queue execution environment must NEVER pollute the root `docker-compose.yml`. Instead, all `queue-server` bindings natively reside inside a dedicated `docker/queue-server-compose.yml` deployment target preserving cleanly delineated networking setups.
