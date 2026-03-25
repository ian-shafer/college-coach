# Implementation Plan: Structured API Errors

## Step 1: Update API Spec Envelopes
Modify `specs/api/main.tsp` by restructuring all standard 400, 401, 409, and 500 error responses to contain two optional parameters:
- `messages?: string[];`
- `errors?: Record<string>;`

## Step 2: Refactor Kotlin Error Response Data Class
Update `rest-server/src/main/kotlin/com/echoapp/models/ErrorResponse.kt` to serialize the new map format:
```kotlin
@Serializable
data class ErrorResponse(
    val messages: List<String>? = null,
    val errors: Map<String, String>? = null
)
```

## Step 3: Shift Client-Side Validations
Refactor the `AuthRequest.validate()` function in `AuthRoutes.kt` to return a `Map<String, String>` dictionary pointing explicitly to the failed fields (e.g. `["email"] = "Email cannot be empty"`). Update both `login` and `register` endpoints to inject this map directly into `ErrorResponse(errors = validationErrors)`.

## Step 4: Map Global Messages
Update all generic error bindings in the codebase to use the new `messages` array or the `errors` map respectively:
- In `AuthRoutes.kt`, patch the `[Invalid credentials]` and `[Registration failed]` messages to map correctly into `ErrorResponse(messages = listOf(...))`.
- In `AuthRoutes.kt`, update the `ExposedSQLException` for duplicate emails to be specifically mapped into `ErrorResponse(errors = mapOf("email" to "[Email already exists]"))`.
- In `Application.kt` (`StatusPages`), patch the generic JSON deserialization exception handlers into `ErrorResponse(messages = listOf(...))`.

## Step 5: SDK Compilation and Validation
Execute `./bin/build && ./bin/restart-rest-server && ./bin/test` to regenerate the Swift structural logic models explicitly and trigger the Schemathesis fuzzer to validate the schemas seamlessly across the endpoints.
