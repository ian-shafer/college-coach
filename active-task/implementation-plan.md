# Implementation Plan: Logout Endpoint

## Step 1: Update API Contract
Update `specs/api/main.tsp` to define the new `/auth/logout` interface.
- Expose an `@post` operation `logout` at path `/auth/logout`.
- Return `void` to enforce stateless idempotency, bypassing authorization rejections.

## Step 2: Regenerate Models
Run `./bin/build` to refresh Kotlin and iOS Swift SDKs against the new endpoint contract.

## Step 3: Implement Endpoint
Update `AuthRoutes.kt`.
- Attach `post("/logout")` entirely outside the `authenticate("auth-jwt") { }` domain restriction.
- Return `HttpStatusCode.NoContent` unconditionally, returning the pure 204 REST signal so clients easily drop local tokens bypassing 401 loops.
