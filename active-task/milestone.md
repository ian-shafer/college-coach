# Milestone: Structured API Errors (Sub-Milestone)

We will completely refactor the REST API to return structured, field-level error messages in a JSON map format, ensuring robust error handling for all future clients.

# Part 1: Schema Definitions
Update `specs/api/main.tsp` to restructure the 400, 401, and 409 error models. The error envelope will output both a global `messages: string[]` list (for high-level errors) and an `errors: Record<string>` map (for field-specific validation failures).

# Part 2: Backend Mapping
Refactor the Kotlin `ErrorResponse` model in `com.echoapp.models.ErrorResponse.kt` to serialize both `messages: List<String>?` and `errors: Map<String, String>?`. Update `AuthRoutes.kt` and `Application.kt` (StatusPages) to populate the correct structures (e.g., `["email"] = "Email cannot be empty"` goes into `errors`, while "Invalid credentials" goes into `messages`).

# Part 3: Test Fuzzer Alignment
Rebuild the OpenAPI Swift specifications and run the backend tests to ensure the Ktor router flawlessly outputs the exact JSON dictionary structures expected by the updated schemas.
