# Agent Operational Learnings

*This file is an autonomous memory buffer maintained by the Agent to log hard-learned architectural quirks, project-specific syntax hacks, and rules established during implementation. It does not require an `LGTM` to update or commit.*

## Communication Constraints
1. **Adverb Restriction**: Avoid using superfluous "-ly" adverbs (e.g., aggressively, natively, strictly, rigorously). Keep technical communication clean, direct, and readable.

## Scripting Constraints
1. **No Unnecessary Side-Effects**: Do not place executing logic (e.g., `mkdir -p`) inside shared sourcing scripts like `bin/common` if not every caller needs it. Always scope side-effects tightly to the explicit scripts (e.g., `start-daemon`) that actually require them.
2. **Enforce DRY in Scripts**: Extract duplicated loops, condition checks, and command chains into shared utilities before writing new wrappers.

## SQLite & Exposed Extrapolations
1. **Never String-Match SQLExceptions**: When tracking SQLite violations via Exposed, never parse `e.message` dynamically. Map `e.cause as? java.sql.SQLException` natively. The SQLite integer codes for strict constraints are `errorCode == 19` (Constraint) and `errorCode == 2067` (Unique Constraint).

## Ktor Plugin Architecture
1. **JWT Routing Crashes**: Using an `authenticate("auth-jwt") { }` block anywhere in Ktor's routing tree unconditionally mandates that `install(Authentication)` is formally registered strictly onto the `Application` module boot cycle BEFORE the routes evaluate; otherwise Ktor instantly crashes with `MissingApplicationPluginException` upon startup.

## Domain Mapping Behaviors
1. **TypeSpec Timestamp Serialization**: TypeSpec natively parses `@doc("...") createdAt: utcDateTime` into `OffsetDateTime` string constructs globally, but pure Hexagonal Kotlin domains strictly rely on structural `java.time.Instant`. During HTTP Adapter routing extraction, correctly map the domain Instant utilizing `DateTimeFormatter.ISO_INSTANT.format(...)` to directly satisfy the DTO generation strings flawlessly.
2. **Dynamic Error Interpolation**: Only *dynamic runtime variables* (like unique user IDs, email inputs) get wrapped aggressively inside `[]` bracket syntax structures (e.g. `[${email}] is already taken`). Do NOT wrap standard static identifiers (e.g. `First name cannot be blank` should strictly not have brackets). Never include sensitive system components (like plaintext passwords) within error outputs natively. No inline magic numbers. Always explicitly use class `companion object` constants natively.

## State Management
1. **Functional State Mutations**: All persistent state engines (like `Keychain` interfaces or Domain models tracking properties) must structure immutable objects preventing `Void` side-effects. State variables and endpoints must emit exhaustive representations or return formal `Result` payloads resolving operation success margins out in the open.
## Swift Error Handling
1. **LocalizedError Conformance**: When defining custom Domain `Error` enums in Swift, ALWAYS ensure they conform to the `LocalizedError` protocol and override `public var errorDescription: String?`. If custom enums only conform to the standard `Error` protocol, calling `error.localizedDescription` inside UI layers will discard any embedded string payloads and render a generic class dump (e.g., `"The operation couldn't be completed"`).
