# Module Specification: bin

## 🎯 Primary Purpose
Contains the core Unix-based executable shell scripts responsible for managing and standardizing application lifecycle operations (start, stop, check, restart) across isolated backend binaries.

## 🏗 Architectural Boundaries
- **Allowed Inbound Callers:** Developers or CI/CD pipelines invoking local scripts.
- **Allowed Outbound Dependencies:** Pure POSIX shell commands, `docker`, and shared sub-scripts within `bin/`.

## 🧩 Core Components
- **wait-for:** Generic polling utility extracting loops into a single timeout script.
- **start-daemon:** Core functional hook trapping PID values and invoking ports.
- **stop-daemon:** Universal termination execution blocking on `check-daemon` verification.
- **check-daemon:** High-level validation unifying process testing across `.pid` and `.port` outputs.

## 🔄 State & Data Flow
- **Data Mutability:** State tracks into persistent cache files mapping `.pid` and `.port` states inside isolated `var/run/` directories.

## ⚠️ Strict Constraints & Known Gotchas
- **No Unnecessary Side-Effects**: Execution side-effects (`mkdir`, writing `.pid` objects) must reside inside target files like `start-daemon`. Global inclusions (like `common`) omit active execution commands.
- **MacOS VM Docker Abstractions**: Because container boundaries obscure raw application processes inside hidden VM paths, `.pid` mappings utilize the host `$!` terminal bash ID holding the `docker compose` execution layer.
