# Implementation Plan: Profile Editing Endpoint

## Step 1: Update API Contract (Ports)
Update `specs/api/main.tsp`.
- Define model `UpdateProfileRequest` with optional `email`, `password`, `firstName`, `lastName`, and `displayName` fields.
- Expose `@patch /users/me` resolving `User | BadRequestResponse | UnauthorizedResponse | ConflictResponse`.

## Step 2: Regenerate SDKs
Execute `./bin/build` unifying the TypeSpec contract into strict Kotlin DTO wrappers.

## Step 3: Domain Layer Core Interfaces
Create `src/main/kotlin/com/echoapp/domain/Entity.kt`.
- Define `interface Entity { val id: String; val createdAt: java.time.Instant; val updatedAt: java.time.Instant }`.
- Define generic base repository: `interface EntityRepository<T : Entity>`.

## Step 4: Domain Layer User Model
Create `src/main/kotlin/com/echoapp/domain/User.kt`.
- Define pure domain entity natively extending the core structure: `data class User(override val id: String, val email: String, val firstName: String?, val lastName: String?, val displayName: String?, val createdAt: java.time.Instant, val updatedAt: java.time.Instant) : Entity`.

## Step 5: Domain Layer Verification Models
Create `src/main/kotlin/com/echoapp/domain/Validation.kt`.
- Define `sealed class ValidationResult { object Valid : ValidationResult(); data class Invalid(val messages: List<String> = emptyList(), val errors: Map<String, String> = emptyMap()) : ValidationResult() }`.
- Define `interface Validator<T> { fun validate(subject: T): ValidationResult }`.
- Implement `ProfileValidator : Validator<UserUpdate>` asserting constraints independent of external framework logic.

## Step 6: Domain Layer Data Output Models
Create `src/main/kotlin/com/echoapp/domain/UserRepository.kt`.
- Define `data class UserUpdate(val email: String? = null, val password: String? = null, val firstName: String? = null, val lastName: String? = null, val displayName: String? = null)`.
- Define `sealed class ProfileUpdateResult { data class Success(val user: User) : ProfileUpdateResult(); data class Conflict(val reason: String) : ProfileUpdateResult() }`.
- Define dynamic port: `interface UserRepository : EntityRepository<User> { fun updateProfile(userId: String, updates: UserUpdate): ProfileUpdateResult }`.

## Step 7: Data Layer SQLite Adapter
Create `src/main/kotlin/com/echoapp/server/adapters/SqlUserRepository.kt`.
- Implement `UserRepository` executing Exposed relational operations.
- Detect duplicate emails natively resolving outputs into raw `ProfileUpdateResult.Conflict` constraints.

## Step 8: HTTP Router Adapter
Create `src/main/kotlin/com/echoapp/server/routes/UserRoutes.kt`.
- Intercept `@patch /users/me` enforcing the `authenticate("auth-jwt")` boundary.
- Rigorously map HTTP inputs into the `UserUpdate` domain object.
- Explicitly map the resulting Domain `User` natively back into the generated TypeSpec `com.echoapp.models.User` DTO structure.

## Step 9: Application Hand-Wiring
Modify `Application.kt` manually injecting the adapter structures explicitly down into `userRoutes(...)`.
