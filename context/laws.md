# Agent Laws

The LLM / Agent must always adhere to the following rules when designing or implementing this application:

# Communication & Tone
1. **Concise Communication:** When writing Markdown files, be as concise as possible. Do not use flowery language or over-explain. Communicate like a Linux man page: direct, factual, and strictly detailed without unnecessary adverbs or conversational filler.
2. **Minimal Word Set:** Use a minimal and consistent set of nouns and verbs in all code and output messages (e.g., use "remove" instead of "wipeout"). 
3. **Standard API Verbs:** Prefer standard words like `get`, `create`, `update`, and `delete` in endpoints and functions.

# Planning & Architecture
1. **Active Task Lifecycle:** The current task is always specified in the `/active-task` directory and follows a strict 3-Phase lifecycle:
   * **Phase 1: Author the Milestone Definition (`active-task/milestone.md`)**:
     1. Define the high-level milestone. What will be different after this milestone is complete? What new features will be available to the user?
     2. Identify the parts of the milestone (e.g., database, schema).
     3. Go through each part identified and discuss/document the design.
     4. Review the milestone definition with fresh eyes to determine readiness. If the milestone definition is not clear, concise, and well-structured, edit it until it is.
     
     **Milestone Template:**
     # Milestone: {milestone_name}
     {milestone_definition: paragraphs and lists explaining what is changing}
     
     # Part n: {part_name}
     {part_design: paragraphs and lists, maybe pseudo-code}
     
   * **Phase 2: Implementation Plan (`active-task/implementation-plan.md`)**: Discuss the steps for implementation. Always prefer smaller steps (e.g., Step 1: write a utility method. Step 2: use the method). Each step represents a single code submission. Steps must be ordered sequentially. Adding dependencies (e.g., modifying `build.gradle.kts`) should never be its own standalone step, but rather considered a side-effect of the code requiring those libraries.
   * **Phase 3: Implementation**: Implement, review, and submit each step sequentially as defined in the plan.
2. **Unspecified Choices:** When encountering an implementation detail or library choice not explicitly specified by the user (e.g., a hashing algorithm or database driver), ALWAYS ask the user before adding it to the implementation plan. Never make unprompted architectural assumptions.
3. **Presenting Options:** When presenting architectural or library options to the user, provide a short description for each option and include a clear recommendation.

# Programming paradigms
1. **Functional Programming:** Always prefer functional programming ideas. Emphasize immutability and pure functions throughout the codebase.
2. **Robust Encapsulation:** Make code as robust as possible. A change in one part of the codebase should not break another. Enforce separation of concerns and strict boundary limits.
3. **No Magic Values:** Never use hard-coded "magic" numbers or strings directly inline. Always extract them strictly into named arguments, functional parameters, or explicit structural constants.

# Language preferences
1. **Language Preference:** Prefer statically compiled languages over interpreted languages.
2. **Platform Preference:** Prefer the JVM as a deployment platform.
3. **Build Artifacts:** All compiled and generated code must be placed under a `/build` directory. Do not mix generated code with source code.
4. **Containerized Compilation:** All compilation and code generation tasks must be executed within Docker containers. Do not rely on host machine dependencies.

# Error handling
1. Errors must always be logged in a manner visible to the user.
2. **Explicit Errors:** When generating error messages, formatting must be concise, and dynamic variables must be bracketed with `[` and `]` (e.g., `Could not cd to [/a/directory]`).
3. **User Review Required:** Never run `git commit` without allowing the user to view the full `git diff`. The user must manually approve code changes before they are committed.

# Code Formatting
1. **Trailing Whitespace (Temporary):** Before adding files to git staging, ensure all trailing whitespaces are stripped (e.g. matching `s/\s+$//`).