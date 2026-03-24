# Implementation Plan: User Authentication

## Step 1: Spec-Driven Schema
Write the `User`, `AuthRequest`, and `AuthResponse` models inside `specs/api/main.tsp`. Define the `/auth/login` and `/auth/register` endpoints.

## Step 2: Exposed Database Object
Create `DatabaseFactory.kt` implementing the `Users` table schema via JetBrains Exposed DSL, handling the 8-character `id` and tracking timestamps. Inject `exposed-core`, `exposed-jdbc`, and `sqlite-jdbc` dependencies into `rest-server/build.gradle.kts`.

## Step 3: Application Bootstrapping
Initialize `DatabaseFactory.init()` inside `Application.module()` contained within `Application.kt`.

## Step 4: BCrypt Hashing Utility
Implement a Kotlin object designed to hash and verify plaintext passwords via the BCrypt algorithm. Inject the `jbcrypt` dependency into `rest-server/build.gradle.kts`.

## Step 5: ID Generation Utility
Implement a Kotlin utility method to generate strongly randomized 8-character alphanumeric strings `[a-z0-9]` to calculate user primary keys.

## Step 6: Registration Route Logic
Implement the routing hook for `/auth/register` inside Ktor to map an incoming `AuthRequest`, generate the ID using the step 5 utility, hash the password via the step 4 utility, uniquely insert the user into the SQLite `Users` table, and return standard HTTP status responses on validation failure.

## Step 7: JWT Issuance Utility
Implement a Kotlin class handling JWT creation utilizing the Ktor `auth-jwt` module. Inject `ktor-server-auth` and `ktor-server-auth-jwt` dependencies into `rest-server/build.gradle.kts`.

## Step 8: Login Route Logic
Implement the `auth/login` hook to verify the database credentials. If valid, trigger the step 7 JWT utility to produce and return an `AuthResponse` object.
