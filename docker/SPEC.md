# Module Specification: docker

## 🎯 Primary Purpose
Holds the physical Infrastructure-as-Code definitions isolating discrete microservice constraints across specific container execution bounds.

## 🏗 Architectural Boundaries
- **Allowed Inbound Callers:** `bin/` execution shell scripts.
- **Allowed Outbound Dependencies:** Standard published Dockerhub images and localized compiled `.jar` binaries.

## 🧩 Core Components
- **postgres-compose.yml:** Bootstraps the primary database target avoiding root port collisions.
- **queue-server-compose.yml:** Spawns background worker pools totally decoupled from the Ktor HTTP framework mapping directly onto Postgres execution layers.

## 🔄 State & Data Flow
- **Data Mutability:** Docker networks gracefully discard transient data. Persistent data volumes statically lock out to target directories.

## ⚠️ Strict Constraints & Known Gotchas
- **Container Isolation:** Do not merge services into monolithic `.yml` compose files unless they strictly require shared container networking. Independent modules (like `queue-server`) MUST explicitly stand up their own discrete `-compose.yml` declarations naturally isolating runtime memory overhead.
