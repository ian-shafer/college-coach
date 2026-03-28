# Implementation Plan: Executable Scripts Standardization & Lifecycle

## Step 1: Initialize Local Directories & Provide Context Anchor
**SDD Traceability:** Part 1, Success Criteria 1 & 6.
- Write `bin/SPEC.md` documenting the new generic daemon architecture and boundary guidelines.

## Step 2: Establish the Generic Daemon Engine Core
**SDD Traceability:** Part 2, Generic Daemon Engine Requirement, Edge Cases 1 & 2.
- Author `bin/start-daemon`. Accept `$SERVICE_NAME`, `$COMMAND`, and `$PORT`. Trigger `mkdir -p var/run var/log` to isolate side-effects. Map `$PORT` securely into `var/run/$SERVICE_NAME.port`. Background the daemon passing `$PORT` natively via environment paths, write logs to `var/log/$SERVICE_NAME.log`, extract `$!` into `var/run/$SERVICE_NAME.pid`, and cleanly loop `bin/check-port $SERVICE_NAME` enforcing a `30s` timeout barrier.
- Author `bin/stop-daemon`. Verify `var/run/$SERVICE_NAME.pid` exists and exit if missing. Signal `kill -15 $PID` then loop `bin/check-daemon $SERVICE_NAME` sequentially until it fails (process is dead). Finally, clean up both the `.pid` and `.port` files.
- Author `bin/check-pid`. Accept `$SERVICE_NAME`. Verify `var/run/$SERVICE_NAME.pid` exists (exit indicating missing process if not). Read the PID, invoke `kill -0 $PID`, and emit specific responses: `RUNNING (PID X)` or `STOPPED`.
- Author `bin/check-port`. Accept `$SERVICE_NAME`. Verify `var/run/$SERVICE_NAME.port` exists (exit indicating missing port if not). Read the port, execute `nc -z localhost $PORT`, and emit port readiness status.
- Author `bin/check-daemon`. Accept `$SERVICE_NAME`. Unify the evaluation process by executing both health sub-routines sequentially: `bin/check-pid $SERVICE_NAME && bin/check-port $SERVICE_NAME`.

## Step 3: Implement Thin Wrappers for `rest-server`
**SDD Traceability:** Success Criteria 1-5, Orphaned Docker Bindings Edge Case.
- Author `bin/start-rest-server`. Strip standalone logic and exclusively invoke `bin/start-daemon "rest-server" "docker compose up rest-server" "8080"` cleanly.
- Update `docker-compose.yml` and `application.conf` directly to map the incoming executing `$PORT` environmental variable fundamentally all the way through the Docker perimeter layer down explicitly to the Kotlin inner Ktor mapping.
- Author `bin/stop-rest-server`. Wrap calls to `bin/stop-daemon "rest-server"`.
- Author `bin/restart-rest-server`. Sequential execution: `bin/stop-rest-server && bin/start-rest-server`.
- Author `bin/check-rest-server`. Execute `bin/check-daemon "rest-server"`.

## Step 4: Validate Script Execution Integrity
**SDD Traceability:** Basic DevOps Standard.
- Execute `chmod +x bin/*-daemon` ensuring structural permissions validate full UNIX functionality on Mac host machines.
