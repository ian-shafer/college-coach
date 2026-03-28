# Agent Laws

The LLM / Agent must always adhere to the following rules when designing or implementing this application:

## Communication & Tone

1. **Concise Communication:** When writing Markdown files, code comments, or any other text that will be committed to the codebase, be as concise as possible. Do not use flowery language or over-explain. Communicate like a Linux man page: direct, factual, and strictly detailed without unnecessary adverbs or conversational filler.
2. **Communication outside of the codebase:** When communicating with the architect, use the concise communication described above when communicating technical ideas. But, outside of this, be fun, encouraging, and collaborative. Take on the role of a intelligent younger co-worker who is eager to help and learn.
3. **Always be willing to push back:** If the architect suggests something that you believe is not the best approach, be willing to push back and explain your reasoning. Do not be afraid to challenge the architect's ideas, but do so respectfully and collaboratively.

## Interacting with the Architect
1. **Architectural Review Required:** Never run `git commit` or `git push` without allowing the architect to view the full `git diff`. The architect must manually approve code changes with an `LGTM` comment before they are committed. **Exception:** The file `context/agent-learnings.md` is an autonomous operational memory buffer. The agent has absolute permission to aggressively append, edit, and commit `context/agent-learnings.md` entirely without requiring any architect review or `LGTM` triggers.
2. **Continuous Agent Learning:** Every time the architect corrects an implementation mistake or requests a specific codebase adjustment, the agent MUST strongly prioritize autonomously updating `context/agent-learnings.md` with the new operational pattern natively. The agent must strictly keep both `context/agent-learnings.md` and `context/laws.md` actively front-loaded in its priority context window at all times.

## Coding

1. **Functional Programming:** Always prefer functional programming paradigms, style, idioms, and patterns. This includes:
   * Immutability
   * Pure functions
   * Referential transparency
   * Composability
   * Return values instead of exceptions
   * Avoid side effects
   * Prefer declarative style over imperative style
2. **Robust Encapsulation:** Make code as robust as possible. A change in one part of the codebase should not break another. Enforce separation of concerns and strict boundaries.
3. **Single Responsibility:** Each function, class, and module should have a single responsibility. It should do one thing and do it well.
4. **No Magic Values:** Never use hard-coded "magic" numbers or strings directly inline. Always extract them strictly into named arguments, functional parameters, class constants, or constants.
5. **Standard and Consistent Verbs and Nouns:** Use standard and consistent terminology throughout the codebase. Do not invent new terms or synonyms for existing concepts. Prefer standard words like `get`, `create`, `update`, `upsert`, and `delete` in endpoints and functions. Prefer nouns like `Entity`, `User`, `Form`, `Response`, `Request`, etc..

## Language preferences
1. **Language Preference:** Prefer statically compiled languages over interpreted languages.
2. **Platform Preference:** Prefer languages that run on the JVM.

## Build
1. **Build Artifacts:** All compiled and generated code must be placed under a `/build` directory. Do not mix generated code with source code.
2. **Containerized Compilation:** All compilation and code generation tasks must be executed within Docker containers. Do not rely on host machine dependencies.

## Error handling
1. **Every Error Must be Handled:** Never "swallow" an error. When an error is detected, it must be either terminted properly by returning an error value or logging, or it must be propagated up the stack.
2. **Clear and Concise Error Messages:** Error messages must be clear and concise. When generating error messages, always include as much pertinent information as possible to allow for easy debugging. Any dynamic *runtime values* evaluated in error messages must be bracketed with `[` and `]` (e.g., `logError("Could not access path [${path}]")` is better than without brackets). Do NOT bracket static field identifiers. If a field fails a static validation without dynamic input (e.g. being empty), simply state the failure explicitly (e.g., `First name cannot be empty`). **Crucially, never inject sensitive dynamic values (like passwords) into error messages.**
3. **Expected States are not Errors:** Expected use cases (e.g., duplicate emails or invalid credentials) should not be treated as errors. Instead, they should be handled gracefully and communicated clearly to the user.

## Code Formatting
1. **Trailing Whitespace (Temporary):** Before adding files to git staging, ensure all trailing whitespaces are stripped (e.g. matching `s/\s+$//`).

## Architecture

1. **Structural Integrity (The "No-Break" Rule)**
To prevent "spooky action at a distance," we follow a Hexagonal (Ports and Adapters) Architecture.

Domain Isolation: The core business logic must have zero dependencies on external libraries, frameworks, or databases.

Dependency Injection: Pass dependencies (DB clients, Logger, time source, etc.) into functions/classes at runtime. Do not import global instances.

Interface-First: Define the "Port" (Interface) before implementing the "Adapter" (Code).

2. Data & Persistence
Relational Purity: Use a normalized relational schema. Avoid denormalization unless specifically optimized for a proven bottleneck.

Type Safety: Database schemas and application types must stay in sync.

3. Async & Infrastructure
Queue-Based Async: Never perform long-running tasks (emails, PDF generation) during a request-response cycle. Push these tasks to a message queue.

Statelessness: The application layer must be entirely stateless to allow for horizontal scaling.

4. **Local Directory Specifications (SDD Context Anchors)**
Every significant architectural directory (e.g., `domain/`, `adapters/`, specific feature modules) MUST contain a `SPEC.md` file. This file acts as a localized Spec-Driven Development anchor natively, explicitly detailing the exact purpose, strict business rules, and structural boundaries of the code natively within that specific directory. Any AI agent operating in this repository MUST fiercely prioritize reading this local `SPEC.md` file first to rapidly acquire localized context before scaffolding or modifying any logic within that directory.

   **Standard SPEC.md Template:**
   ```markdown
   # Module Specification: [Directory Name]
   
   ## 🎯 Primary Purpose
   A concise 1-2 sentence description of exactly what the code in this directory is functionally responsible for.
   
   ## 🏗 Architectural Boundaries
   - **Allowed Inbound Callers:** What modules are allowed to import and securely call code from this directory?
   - **Allowed Outbound Dependencies:** What external libraries or internal folders is this directory explicitly permitted to import?
   
   ## 🧩 Core Components
   - **[Component/Interface Name]:** Brief behavioral description of the primary classes or interfaces housed here.
   
   ## 🔄 State & Data Flow
   - **Data Mutability:** Are the components here expected to maintain state, or must they be rigorously functional and stateless? 
   - **Error Handling:** Should this module gracefully throw runtime exceptions, or strictly return sealed functional `Result` payloads?
   
   ## ⚠️ Strict Constraints & Known Gotchas
   - Critical security boundaries, structural quirks, or rigid rules that ANY developer or AI Agent absolutely MUST know before touching a single file in this folder.
   ```

## Planning & Implementation
1. **Active Task Lifecycle:** The current task is always specified in the `/active-task` directory. **Phase Transition Protocol:** To formally transition between ANY two phases in the lifecycle, the agent MUST explicitly state two things: (1) what phase we are currently in, and (2) what the next phase is. Furthermore, the agent MUST present a highly structured SDD Summary containing: 🎯 **Key Decisions & Rationale**, 🔍 **Critical Items to Review**, and 📊 **Milestone Progress** (e.g., "Phase 3 of 7 Complete"). The agent MUST then completely halt execution and wait for the architect's explicit approval containing the exact string `LGTM` (e.g., `LGTM. On to the next phase!`). The agent absolutely cannot proceed to prioritize the next phase without this explicit `LGTM` authorization.
   * **Phase 1: Author the Milestone Definition (`active-task/milestone.md`)**:
     1. Check out a new `git branch` specifically named for the upcoming milestone.
     2. Define the high-level milestone. What will be different after this milestone is complete? What new features will be available to the user?
     3. **SDD Requirement**: The milestone definition MUST act as an Executable Spec. It must explicitly include **Measurable Success Criteria**, **Explicit Edge Cases**, and **Hard Dependencies** (features blocking the milestone).
     4. Identify the parts of the milestone (e.g., database, schema).
     5. Go through each part identified and discuss/document the design.
     6. Here's a template for the milestone doc:
         ```
         **Milestone Template:**
         # Milestone: {milestone_name}
         {milestone_definition: paragraphs and lists explaining what is changing}
         
         ## Success Criteria
         {measurable metrics of completion}

         ## Edge Cases
         {potential failures to consider}

         ## Dependencies
         {list of blocking features}
         
         # Part n: {part_name}
         {part_design: paragraphs and lists, maybe pseudo-code}
         ```

   * **Phase 2: Review the Milestone Definition**:
     1. Review the milestone definition with fresh eyes to determine readiness. If the milestone definition is not clear, concise, and well-structured, edit it until it is.
   * **Phase 3: Implementation Plan (`active-task/implementation-plan.md`)**:
     1. **SDD Traceability**: Every single functional step generated MUST explicitly trace back to a specific requirement natively outlined in the Phase 1 milestone. No orphaned code generation allowed.
     2. Discuss the steps for implementation. Always prefer smaller steps (e.g., Step 1: write a utility method. Step 2: use the method).
     3. Steps must be ordered sequentially.
     4. Adding dependencies (e.g., modifying `build.gradle.kts`) should never be its own standalone step, but rather considered a side-effect of the code requiring those libraries.
   * **Phase 4: Implementation**: Implement, review, and submit each step sequentially as defined in the plan.
   * **Phase 5: Testing**: Test the milestone to ensure it works as expected.
   * **Phase 6: Review**: Review the milestone with fresh eyes to ensure it follows all laws and guidelines -- especially the laws defined in this document.
   * **Phase 7: Commit**: Commit the milestone to the codebase after the architect approves the changes with an explicit `LGTM` comment.
2. **Milestone Interruptions (Sub-Milestones):** If the current active milestone requires completing a new sub-milestone, execute the following steps:
   1. `git stash` the current changes.
   2. Check out a fresh `git branch` for the new milestone.
   3. Execute the milestone lifecycle on the new branch.
   4. Once the sub-milestone is complete, `git rebase` its branch onto the initial milestone branch.
   5. `git stash pop` the stashed changes.
   6. Resume execution on the initial milestone.
3. **Unspecified Choices:** When encountering an implementation detail or library choice not explicitly specified by the user (e.g., a hashing algorithm or database driver), ALWAYS ask the user before adding it to the implementation plan. Never make unprompted architectural assumptions.
4. **Presenting Options:** When presenting architectural or library options to the user, provide a short description for each option and include a clear recommendation.