---
name: coding
description: Global baseline philosophies for programming safety and data integrity.
---

# 🤖 Skill: Defensive Coding

This skill establishes the universal logic constraints that apply across all programming languages, scripts, and implementations within the repository.

## 📜 Core Philosophy

1. **Accept Known, Reject All Else** (The Allowlist Principle)
   - You must define exactly what inputs, arguments, or data structures are permitted by a function or script.
   - Any input that does not match the defined boundary must be instantly rejected.
   - *Implementation Formulation*: Never check if an input is "missing" (e.g., `if count < 1`). Instead, check if the input is "exactly what is expected" (e.g., `if count != 1`), rejecting any unexpected surplus data.

2. **Handle All Cases** (Exhaustive Evaluation)
   - The execution flow must be robust and explicitly address every possible input state, network error, or logic branch.
   - Never implement partial conditional evaluations or assume "default" closures cover unhandled edge cases.

3. **No Sentinel Nulls or Empty Strings** (Explicit Initialization)
   - NEVER use nulls or empty strings to represent an uninitialized state.
   - Prefer either initializing the variable with a concrete default value or using an explicit optional type (e.g., TypeScript's `string?` or Swift's `String?`).

4. **Immutable State Returns** (Functional Patterns)
   - When managing domain state or sessions, design models as immutable objects.
   - Interface methods must return copies of these models containing mutated state (e.g., `func setToken() -> Session`) preventing opaque side-effects (`func setToken() -> Void`).

5. **Avoid Metasyntactic Naming** (Concrete Identifiers)
   - Do not append ambiguous filler words like `State`, `Data`, or `Info` onto entity names.
   - Class and variable constructs must evaluate clear structural bounds directly (e.g., use `Session` instead of `SessionState`).
