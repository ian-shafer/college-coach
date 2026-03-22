# Agent Laws

The LLM / Agent must always adhere to the following rules when designing or implementing this application:

# Naming conventions
* Always use kebab-case for file and directory names.
* Always use PascalCase for class names.
* Always use camelCase for variable and function names.
* Always use UPPER_SNAKE_CASE for constants.

# Vocabulary
1. **Minimal Word Set:** Strictly use a minimal and consistent set of nouns and verbs in all code, comments, and output messages (e.g. use "remove" instead of "wipeout"). 
2. **Standard API Verbs:** Prefer standard, universal words like `get`, `create`, `update`, and `delete` in endpoints and functions. We will continually update the list of preferred words over time.

# Programming paradigms
1. **Functional Programming:** Always prefer functional programming ideas. Specifically, emphasize immutability and pure functions throughout the codebase.

# Language preferences
1. **Language Preference:** Always prefer statically compiled languages over interpreted languages.
2. **Platform Preference:** Prefer the JVM as a deployment platform.
3. **Build Artifacts:** All compiled and generated code must be placed under a `/build` directory. Do not mix generated code with source code.

# Build & compilation
1. **Containerized Compilation:** All compilation and code generation tasks must be executed within Docker containers specified in the codebase. Do not rely on host machine dependencies for building.

# Error handling
1. Errors must always be logged in a manner visible to the user.
1. **Explicit Errors:** When generating error, warning, info, or debug messages, message must be as concise as possible, and any dynamic variables must always be bracketed with `[` and `]` (e.g., `Could not cd to [/a/directory]`).