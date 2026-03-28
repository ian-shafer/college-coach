# Milestone: Executable Scripts Standardization & Lifecycle
This milestone reorganizes the `bin/` scripts to follow standard Unix daemon semantics (`start`, `stop`, `restart`, `check`). This replaces foreground console executions with background processes tracked by PID files in the `var/run/` directory.

## Success Criteria
- Wrapper scripts manage process tracking, saving the active `$!` Process ID to `var/run/[executable].pid`.
- The `start` script blocks execution until the service is ready to serve requests. This could be done by pinging the host port (e.g. `localhost:8080`) until the service responds.
- The `stop` script identifies the tracked PID, sends a termination signal, and loops until the process is terminated (it should use the `check` script for this).
- The `restart` script delegates to sequential `stop` and `start` operations.
- The `check` script evaluates the saved PID using `kill -0` to ascertain status safely.
- An SDD Context Anchor at `bin/SPEC.md` documents this tracking environment.
- **Generic Daemon Engine**: Core logic must exist in foundational scripts (`start-daemon`, `stop-daemon`, `check-daemon`). Executable-specific files (e.g., `start-rest-server`) will act as thin wrappers that simply invoke these shared foundational scripts (e.g., `start-daemon rest-server`).

## Edge Cases
- **Stale Tracking PIDs:** If the target server crashes or is terminated externally, the `.pid` file will persist. Scripts MUST verify the PID corresponds to an active process before making assumptions.
- **Infinite Blocking Timeouts:** The `start` and `stop` wait-loops MUST implement hard timeouts (e.g., 30s) rather than hanging the terminal.
- **Orphaned Docker Bindings:** `start-rest-server` operates Ktor via `docker compose`. Extracting its PID on the host requires resolving the specific binary inside the container or running a bash tracking wrapper that orchestrates Docker signals.

## Dependencies
- None.

# Part 1: Structural File Setup & Anchor Documentation
- Implement the SDD directory baseline at `bin/SPEC.md`.
- Provision the `var/run/` directory before bash start invocations.

# Part 2: Executable Target Lifecycles
Update and deploy Unix scripts for all core binaries (`start-rest-server`, etc.).
