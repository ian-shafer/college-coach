# Module Specification: bin

## 🎯 Primary Purpose
Contains the core Unix-based executable shell scripts responsible for managing and standardizing application lifecycle operations (start, stop, check, restart) across isolated backend binaries.

## 🏗 Architectural Boundaries
- **Allowed Inbound Callers:** Developers or CI/CD pipelines invoking local scripts.
- **Allowed Outbound Dependencies:** Pure POSIX shell commands, `docker`, and shared sub-scripts within `bin/`.

## 🧩 Core Components
- **wait-for:** Generic polling utility extracting loops into a single timeout script.
- **daemon-start:** Core functional hook trapping PID values and invoking ports.
- **daemon-stop:** Universal termination execution blocking on `daemon-check` verification.
- **daemon-check:** High-level validation unifying process testing across `.pid` and `.port` outputs.

## 🔄 State & Data Flow
- **Data Mutability:** State tracks into persistent cache files mapping `.pid` and `.port` states inside isolated `var/run/` directories.
- **Execution Validation:** Health and operational status evaluations rely on standard Unix exit status codes (e.g., evaluating `$?`) rather than fragile text parsing or scraping script output strings.

## ⚠️ Strict Constraints & Known Gotchas
- **No Unnecessary Side-Effects**: Execution side-effects (`mkdir`, writing `.pid` objects) must reside inside target files like `daemon-start`. Global inclusions (like `common`) omit active execution commands.
- **MacOS VM Docker Abstractions**: Because container boundaries obscure raw application processes inside hidden VM paths, `.pid` mappings utilize the host `$!` terminal bash ID holding the `docker compose` execution layer.

---

## 📝 System Output & Interface Routing Policies
- **Strict Explicitness Over Implicit Magic**: Daemon engines and wrappers strictly forbid relying on ambient environment variable injection (e.g., `export COMPOSE_FILE="..."`) for core execution paths. Required configurations MUST map natively as explicitly passed positional routing arguments (e.g., `bin/daemon-start <SERVICE> <COMPOSE_FILE> <PORT>`).
- **Dynamic Variable Hard-Boundaries**: Scripts must NEVER encapsulate dynamic variables into terminal strings via single quotes (`'$DB_NAME'`), as standard quotes fail to draw hard visual boundaries. Variables MUST be explicitly wrapped in brackets natively (`Database [$DB_NAME] is up`).
- **Heredoc Help Interfaces (`stdout`)**: Usage and `help()` payload functions must natively stream explicitly formatted multiline strings completely to standard output using raw heredocs (`cat << EOF`), isolating UI payloads from execution trace histories.

## 📡 Centralized Logging Traces (`stderr`)
All `bin/` execution tracing completely abandons direct `echo` and instead relies on the abstract `_log` layer inside `bin/functions`. This guarantees `stdout` stays pristine strictly for data-pipelining between scripts.
- **`log-info "Msg"`**: Unmarked diagnostics explicitly logging string updates dynamically up to `stderr`.
- **`log-error "Msg"`**: For localized or recoverable failure states. Wraps messages automatically with the explicit `[ERROR]` prefix dynamically.
- **`fatal "Msg" [code]`**: For definitively terminal failure logic. Drops an absolute `[FATAL]` prefix onto `stderr` and terminates execution cleanly utilizing the given status code (defaulting safely to `exit 1`).

---

## 🗄️ Database Script Addendum
- **Dependencies:** The overarching Postgres infrastructure (`POSTGRES_DB`, `POSTGRES_USER`) maps implicitly from the `.env` root configuration file inherited by `docker compose`.
- **Architectural Rules:** Database scripts MUST NOT utilize host `psql` bindings. They MUST invoke `docker compose exec postgres psql` abstractions natively to assure isolation. 
- **Graceful Failure State:** If the database container is uninitialized or unmapped, wrappers (`db-status`, `db-init`) MUST handle verification loops utilizing boundary scripts (`docker compose exec postgres pg_isready`) before dumping traces.
