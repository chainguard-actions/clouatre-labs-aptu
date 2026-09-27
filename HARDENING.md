<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.3** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Install aptu binary' step directly interpolates `${{ steps.resolve-version.outputs.version }}` inside a `run:` shell script. Any `${{ ... }}` expression interpolated directly into a shell command string is a script-injection risk — the YAML template substitution happens before the shell ever sees the value, so a malicious value could inject shell commands. The offending line is: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`

Locations:

- `action.yml:233`

### script-injection (severity: high)

Sub-rule (b): Multiple `run:` steps build a `$ARGS` string by appending unquoted user-controlled env vars, then pass `$ARGS` unquoted to `aptu` command invocations. This allows shell metacharacter injection. Affected steps and variables:
- 'Run aptu issue triage (scheduled batch)': `$SINCE` and `$ISSUE_STATE` (from `inputs.since` and `inputs.issue-state`) are appended unquoted to `$ARGS`, and `aptu issue triage $ARGS` is called without quoting `$ARGS`.
- 'Run aptu PR review': `$REPO_PATH` (from `inputs.repo-path`) and `$INSTRUCTIONS_FILE` (from `inputs.instructions-file`) are appended unquoted to `$ARGS`, and `aptu pr review $ARGS "$PR_REF"` is called without quoting `$ARGS`.
- 'Run aptu scan-security': `$SCAN_PATH` and `$SCAN_DIFF` (from `inputs.scan-path` and `inputs.scan-security-diff`) are used unquoted in `aptu scan-security $SCAN_PATH --output sarif` and in the echo statement.
All these env vars hold values sourced from `inputs.*` and must be double-quoted wherever they are expanded.

Locations:

- `action.yml:313`
- `action.yml:340`
- `action.yml:390`
- `action.yml:420`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed all script-injection findings in hardened/action/action.yml:

1. 'Install aptu binary' step (line 233): Moved `${{ steps.resolve-version.outputs.version }}` from the run: shell script into the step's env: block as `APTU_VERSION`. The shell script now references `$APTU_VERSION` safely.

2. 'Run aptu issue triage (scheduled batch)' step (line 313): Converted string-concatenation `$ARGS` to a bash array `ARGS=()`. `$SINCE` and `$ISSUE_STATE` are now properly double-quoted when appended (`ARGS+=(--since "$SINCE")`). Final invocation uses `"${ARGS[@]}"`.

3. 'Run aptu PR review' step (line 340): Converted string-concatenation `$ARGS` to a bash array. `$REPO_PATH` and `$INSTRUCTIONS_FILE` are now properly double-quoted when appended. Final invocation uses `"${ARGS[@]}"`.

4. 'Run aptu scan-security' step (lines 390/420): Fixed echo statements to properly quote `$SCAN_DIFF` and `$SCAN_PATH` (the aptu command invocations already had them quoted).

5. Also fixed 'Run aptu issue triage' (non-scheduled) and 'Run aptu PR label' steps which had the same unquoted `$ARGS` pattern — converted to arrays for consistency and safety.

