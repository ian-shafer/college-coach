# Milestone: Backend Profile Fetch Endpoint
To provide clients with access to the user's existing profile properties, we must expose a secure REST endpoint referencing the active session's parameters. This necessitates extending the TypeSpec definition, compiling the new schema definitions, and implementing the Kotlin auth route querying the database.

## Success Criteria
- `TypeSpec` outputs a new explicit `@get` `getProfile` signature under `/users/me`.
- Kotlin Ktor endpoints secure the route validating the UUID mapping matching the active requester.
- The endpoint returns a valid `User` model payload passing standard authentication checks.

## Edge Cases
- Invalid or expired tokens requesting `/users/me` throwing `UnauthorizedResponse`.

## Dependencies
- Active JWT Authentication infrastructure validating mapped headers.

# Part 1: TypeSpec & API Generation
Add the `@get` endpoint structural rule mapping a `User` model output. Trigger local code generation.

# Part 2: Backend Implementation
Add `.get("/me")` routing under the Auth block translating the JWT principal into a structured `User` payload referencing the Exposed `Users` table.
