# Implementation Plan: Executable Scripts Standardization & Lifecycle

## Step 1: Initialize Local Directories & Provide Context Anchor
**SDD Traceability:** Part 1, Success Criteria 1 & 6.
- Write `bin/SPEC.md` documenting the new generic daemon architecture and boundary guidelines.
- Update `bin/common` to trigger `mkdir -p var/run` ensuring the tracking directory exists prior to any process initialization.

## Step 2: Establish the Generic Daemon Engine Core
**SDD Traceability:** Part 2, Generic Daemon Engine Requirement, Edge Cases 1 & 2.
- Author `bin/start-daemon`. Accept `$SERVICE_NAME`, `$COMMAND`, and `$PORT`. Background the execution via `&`, route logs, map `$!` into `var/run/$SERVICE_NAME.pid`, and loop `nc -z localhost $PORT` enforcing a `30s` timeout barrier to catch boot failures.
- Author `bin/stop-daemon`. Read the PID from `var/run/$SERVICE_NAME.pid`, signal `kill -15 $PID`, loop `kill -0 $PID` awaiting exit completion, and delete the `.pid` file.
- Author `bin/check-daemon`. Read the `$PID` mapping, assert `kill -0 $PID`, and emit standard text formats `RUNNING (PID X)` or `STOPPED (Stale PID)` without masking background states.

## Step 3: Implement Thin Wrappers for `rest-server`
**SDD Traceability:** Success Criteria 1-5, Orphaned Docker Bindings Edge Case.
- Author `bin/start-rest-server`. Strip complex payloads and invoke `bin/start-daemon "rest-server" "docker compose up rest-server" "8080"` bridging Docker wrapper host layers.
- Author `bin/stop-rest-server`. Wrap calls to `bin/stop-daemon "rest-server"`.
- Author `bin/restart-rest-server`. Sequential execution: `bin/stop-rest-server && bin/start-rest-server`.
- Author `bin/check-rest-server`. Execute `bin/check-daemon "rest-server"`.

## Step 4: Validate Script Execution Integrity
**SDD Traceability:** Basic DevOps Standard.
- Execute `chmod +x bin/*-daemon` ensuring structural permissions validate full UNIX functionality on Mac host machines.
