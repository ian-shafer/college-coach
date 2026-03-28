# Milestone: Profile Editing Endpoint

Implement a REST endpoint allowing authenticated users to modify their profile information (email, password, first name, last name, and display name). This implements the new Hexagonal Architecture and Functional Programming laws to isolate database state.

# Part 1: API Contract (TypeSpec)
Update `main.tsp` to define:
- `UpdateProfileRequest` mapping optional parameters for email, password, and names.
- An authenticated `@patch /users/me` endpoint.

# Part 2: Domain Layer (Ports)
Create a `UserRepository` interface for data interactions (e.g., `updateProfile`). Following the "Return values instead of exceptions" rule, operations will return functional Kotlin `Result` types capturing constraints without throwing exceptions.

# Part 3: Data Layer (Adapters)
Implement `SqlUserRepository` conforming to `UserRepository`. This adapter executes Exposed `Users.update` logic, encapsulating the database from the HTTP router.

# Part 4: Domain Layer (Validators)
Create a generic `Validator<T>` interface port returning a structured `ValidationResult`. Implement a pure, stateless `ProfileValidator : Validator<UpdateProfileRequest>` responsible exclusively for input constraints (e.g., enforcing name length >= 1). This enforces both the Single Responsibility and Interface-First laws by decoupling validation logic predictably.

# Part 5: API Layer (Ktor Endpoints)
Define `UserRoutes.kt`. Inject `UserRepository` and `ProfileValidator` into the router via constructor injection. The route will strictly route traffic, passing inputs to the validator and repository, and mapping output models sequentially into `200 OK`, `400 BadRequest`, or `409 Conflict` JSON responses.
