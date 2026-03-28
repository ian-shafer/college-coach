# Agent Operational Learnings

*This file is an autonomous memory buffer actively maintained by the Agent to permanently log hard-learned architectural quirks, project-specific syntax hacks, and rigorous rules established during implementation. It does not require an `LGTM` to update or commit.*

## SQLite & Exposed Extrapolations
1. **Never String-Match SQLExceptions**: When tracking SQLite violations via Exposed, never parse `e.message` dynamically. Map `e.cause as? java.sql.SQLException` natively. The SQLite integer codes for strict constraints are `errorCode == 19` (Constraint) and `errorCode == 2067` (Unique Constraint).

## Ktor Plugin Architecture
1. **JWT Routing Crashes**: Using an `authenticate("auth-jwt") { }` block anywhere in Ktor's routing tree unconditionally mandates that `install(Authentication)` is formally registered strictly onto the `Application` module boot cycle BEFORE the routes evaluate; otherwise Ktor instantly crashes with `MissingApplicationPluginException` upon startup.

## Domain Mapping Behaviors
1. **TypeSpec Timestamp Serialization**: TypeSpec natively parses `@doc("...") createdAt: utcDateTime` into `OffsetDateTime` string constructs globally, but pure Hexagonal Kotlin domains strictly rely on structural `java.time.Instant`. During HTTP Adapter routing extraction, correctly map the domain Instant utilizing `DateTimeFormatter.ISO_INSTANT.format(...)` to directly satisfy the DTO generation strings flawlessly.
2. **Dynamic Error Interpolation**: Only *dynamic runtime variables* (like unique user IDs, email inputs) get wrapped aggressively inside `[]` bracket syntax structures (e.g. `[${email}] is already taken`). Do NOT wrap standard static identifiers (e.g. `First name cannot be blank` should strictly not have brackets). Never include sensitive system components (like plaintext passwords) within error outputs natively. No inline magic numbers. Always explicitly use class `companion object` constants natively.
