<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.3** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): A `${{ }}` expression is interpolated directly inside a `run:` shell command string. In the 'Install aptu binary' step, the line `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"` embeds a GitHub Actions expression directly into the shell script. Any `${{ ... }}` inside a `run:` block is a script-injection risk because the value is substituted by the Actions template engine before the shell ever sees it, bypassing shell quoting.

Locations:

- `action.yml:232`

### script-injection (severity: high)

Sub-rule (b): Unquoted shell variable expansion of untrusted data. Multiple `run:` blocks build an `$ARGS` string by appending values from env vars that hold workflow-controllable inputs (e.g., `$SINCE`, `$ISSUE_STATE`, `$REPO_PATH`, `$INSTRUCTIONS_FILE`) and then invoke `aptu` commands with the unquoted `$ARGS` variable (e.g., `aptu issue triage $ARGS "$ISSUE_REF"`, `aptu issue triage $ARGS`, `aptu pr label $ARGS "$PR_REF"`, `aptu pr review $ARGS "$PR_REF"`). An unquoted `$ARGS` allows the shell to parse metacharacters (`;`, `|`, `&`, `$(...)`, etc.) out of the value, enabling command injection. Additionally, `aptu scan-security $SCAN_PATH --output sarif` uses an unquoted `$SCAN_PATH` (sourced from `inputs.scan-path`).

Locations:

- `action.yml:302`
- `action.yml:340`
- `action.yml:370`
- `action.yml:418`
- `action.yml:449`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in action.yml:

1. Line 232 ('Install aptu binary' step): Moved `${{ steps.resolve-version.outputs.version }}` from the `run:` block into the step's `env:` block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`. The shell script now uses `$APTU_VERSION` as a plain environment variable.

2. Lines 302, 340, 370, 418, 449 (multiple run steps): Converted all `$ARGS` string-building patterns to bash arrays. Each step now initializes `ARGS=()` and appends flags with `ARGS+=(--flag)` or `ARGS+=(--flag "$VALUE")`. Commands are invoked with `"${ARGS[@]}"` which properly quotes each element and prevents shell metacharacter injection. This covers: 'Run aptu issue triage', 'Run aptu issue triage (scheduled batch)', 'Run aptu PR label', 'Run aptu PR review', and 'Run aptu scan-security' (where $SCAN_PATH was already double-quoted in the command invocation).

