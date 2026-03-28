**Milestone Template:**
# Milestone: Executable Scripts Standardization Lifecycle
This milestone reorganizes the `bin/` scripts to follow standard Unix daemon semantics (`start`, `stop`, `restart`, `check`). This replaces foreground console executions with background processes tracked by PID files in the `var/pid/` directory.

## Success Criteria
- Wrapper scripts manage process tracking, saving the active `$!` Process ID to `var/pid/[executable].pid`.
- The `start` script blocks execution by pinging the host port `:8080` until the service is listening.
- The `stop` script identifies the tracked PID, sends a termination signal, and loops to verify termination.
- The `restart` script delegates to sequential `stop` and `start` operations.
- The `check` script evaluates the saved PID using `kill -0` to ascertain status safely.
- An SDD Context Anchor at `bin/SPEC.md` documents this tracking environment.

## Edge Cases
- **Stale Tracking PIDs:** If the target server crashes, the `.pid` file will persist. Scripts MUST verify the PID corresponds to an active process before making assumptions.
- **Infinite Blocking Timeouts:** The `start` and `stop` wait-loops MUST implement hard timeouts (e.g., 30s) rather than hanging the terminal.
- **Orphaned Docker Bindings:** `start-rest-server` operates Ktor via `docker compose`. Extracting its PID on the host requires resolving the specific binary inside the container or running a bash tracking wrapper that orchestrates Docker signals.

## Dependencies
- None.

# Part 1: Structural File Setup & Anchor Documentation
- Implement the SDD directory baseline at `bin/SPEC.md`.
- Provision the `var/pid/` directory before bash start invocations.

# Part 2: Executable Target Lifecycles
Update and deploy Unix scripts for all core binaries (`start-rest-server`, etc.).
