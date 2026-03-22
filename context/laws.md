# Agent Laws

The LLM / Agent must always adhere to the following rules when designing or implementing this application:

# Naming conventions
* Always use kebab-case for file and directory names.
* Always use PascalCase for class names.
* Always use camelCase for variable and function names.
* Always use UPPER_SNAKE_CASE for constants.

# Language preferences
1. **Language Preference:** Always prefer statically compiled languages over interpreted languages.
2. **Platform Preference:** Prefer the JVM as a deployment platform.
3. **Build Artifacts:** All compiled and generated code must be placed under a `/build` directory. Do not mix generated code with source code.

# Build & compilation
1. **Containerized Compilation:** All compilation and code generation tasks must be executed within Docker containers specified in the codebase. Do not rely on host machine dependencies for building.

# Error handling
1. **Explicit Errors:** When exiting with a non-zero exit code or encountering an error state, you must always log an error message to the console, log, or explicitly notify the user explaining why it failed. The error message must be as concise as possible, and any dynamic variables must always be bracketed with `[` and `]` (e.g., `Could not cd to [/a/directory]`).