# Milestone: User Authentication

Implement secure user registration and login flows using email verification. After this milestone is complete, the REST API will support user registration and login flows using email verification, and will issue JSON Web Tokens (JWT) to access protected API endpoints.

# Part 1: Spec-Driven Integrity

The REST API and Swift client must strictly agree on the exact data schemas prior to implementation. The design involves authoring `User`, `AuthRequest` (email, password), and `AuthResponse` (token) mapping models natively inside TypeSpec. This generates the cross-platform OpenAPI bindings simultaneously for Swift and Kotlin.

# Part 2: Database Storage

Securely persist user profiles natively. The design requires configuring an internal SQLite database mapped securely against the JetBrains Exposed DSL library.

* **Table**: `users`
* **Columns**:
  - `id`: char(8), primary key, randomized `[a-z0-9]`
  - `email`: varchar, unique index, not null
  - `password_hash`: varchar, not null
  - `created_at`: timestamp, default current_timestamp, not null
  - `updated_at`: timestamp, default current_timestamp, not null
  - `full_name`: varchar, not null
  - `display_name`: varchar, not null

# Part 3: Cryptographic JWT Validation

Store passwords securely and issue verifiable stateless access tokens over HTTP. The design assigns the BCrypt algorithm to mathematically convert plaintext passwords into irreversible hashes globally during registration. We will structurally integrate the Ktor `auth-jwt` runtime internally to evaluate submitted credentials against the SQLite database natively and dynamically mint valid bearer tokens upon success.
