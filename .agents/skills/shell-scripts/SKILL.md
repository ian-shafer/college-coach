---
name: shell-scripts
description: Core programming standards and safety constraints for writing Unix shell scripts.
---

# 🤖 Skill: Shell Script Standardization

This skill dictates the universal structure and safety guidelines for all shell scripts across the repository to ensure functional robustness and consistent usability.

## 📜 Mandatory Rules
1. **Source Common Context**: 
   - Every script MUST explicitly source the `common` inclusion file at the top (e.g., `source "$(dirname "$0")/common"`).
2. **Fail Fast (`set -e`)**: 
   - Every script MUST declare `set -e` immediately after the bash shebang to ensure the execution halts instantly upon any unexpected command failure. 
   - *Note*: Be cautious with `set -e` around intended boolean failure evaluations (like `kill -0` or running a command you expect to fail). Use `if command; then` or `command || true` to safely capture evaluation codes without triggering the global exit hook.
3. **Centralized Help Function**: 
   - Every script MUST define a `help()` function capable of accepting an optional string argument. If the argument is present, echo it. After echoing the string, print the standard usage instructions and execute `exit 1`.
4. **Standardized Help Flags**: 
   - Every script MUST interpret inbound arguments and intercept `-h` or `--help` explicitly, invoking the `help()` function when triggered.
5. **Dual Option Signatures**: 
   - Every option parsed by a script MUST uniformly support both a short definition and a long definition (e.g., `-p` or `--period`).
6. **Strict Argument Bounding**: 
   - Define exactly what positional parameters are accepted and reject all else. Use exact evaluations (e.g., `if [ "$#" -ne 1 ]; then`) instead of loose minimums (`-lt`) to catch surplus trailing arguments.
