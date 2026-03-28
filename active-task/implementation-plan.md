# Implementation Plan: Backend Profile Fetch Endpoint

This plan executes the requirements defined in the `active-task/milestone.md` to expose a GET `/users/me` endpoint.

## 📋 Proposed Changes

### Step 1: Extending TypeSpec Definition
* **Requirement Tracked:** `TypeSpec` outputs a new explicit `@get` `getProfile` signature under `/users/me`.
* **Action:**
  - Modify `specs/api/main.tsp` to add `@route("/users/me") @get op getProfile(): User | UnauthorizedResponse;`.
  - Execute the TypeSpec compiler (e.g., `npx tsp compile .`) within `specs/api` to regenerate the server interface schemas.

### Step 2: Extrapolate Shared Logic (DRY)
* **Requirement Tracked:** Architectural integrity constraint (Never duplicate logic unnecessarily).
* **Action:**
  - In `UserRoutes.kt`, extract the `ApiUser` mapping logic (currently nested inside `updateProfile`) into a functional extension `fun com.echoapp.domain.User.toApiModel(): com.echoapp.models.User`.
  - Refactor the existing `patch("/users/me")` return chain to utilize this new extension function instead of defining inline variable assignments twice.

### Step 3: Implement Ktor Routing
* **Requirement Tracked:** Kotlin Ktor endpoints secure the route validating the UUID mapping matching the active requester returning a valid `User`.
* **Action:**
  - Open `rest-server/src/main/kotlin/com/echoapp/server/routes/UserRoutes.kt`.
  - Inside the existing `authenticate("auth-jwt")` block, append `get("/users/me")`.
  - Extract the UUID from the `JWTPrincipal` payload claims. Return `HttpStatusCode.Unauthorized` if the principal is missing.
  - **Exhaustive Evaluation:** Invoke `userRepository.findById(userId)`. If null is returned, output `HttpStatusCode.NotFound` and a static formatted constraint error message (e.g., `User not found` without dynamic brackets).
  - If found, map the user via `.toApiModel()` and execute `call.respond()` returning `HttpStatusCode.OK` and the mapped payload structure.
