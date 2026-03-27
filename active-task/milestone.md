# Milestone: Logout Endpoint

We will expose an official `/auth/logout` endpoint in the REST API. This will verify the user's active session before resolving successfully. 

Since we are using stateless JWTs for authentication and adhering to the "Statelessness" Architecture Rule, "logging out" on the backend primarily serves as a verifiable handshake for client applications to clear their local credentials. We will avoid implementing a stateful database blacklist unless explicitly required.

# Part 1: API Contract (TypeSpec)
Update `main.tsp` to feature an `@post /logout` path under the core Auth namespace. It should require an active `Authorization` header and securely return a `200 OK` on success.

# Part 2: Ktor Endpoint
Define a `post("/logout")` block inside the explicit `authenticate("auth-jwt") { }` router inside `AuthRoutes.kt`. The endpoint will confirm the JWT is structurally valid and immediately return `200 OK`, officially signaling the client application to destroy the token natively from local device storage.
