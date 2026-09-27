<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.4** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): A `steps.*.outputs.*` expression is directly interpolated inside a `run:` shell script. In the "Install aptu binary" step, the line `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"` injects the expression value directly into the shell before the shell ever sees it. Any `${{ ... }}` inside a `run:` block is a script-injection risk regardless of which context it reads from. Fix: pass the value via an `env:` variable (e.g. `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`) and reference `"$APTU_VERSION"` in the script.

Locations:

- `action.yml:261`

### script-injection (severity: high)

Rule (b): Multiple `run:` blocks expand `$ARGS` unquoted when invoking `aptu` commands. The `$ARGS` variable is built by appending values sourced from user-controlled inputs (`$SINCE` from `inputs.since`, `$ISSUE_STATE` from `inputs.issue-state`, `$REPO_PATH` from `inputs.repo-path`, `$INSTRUCTIONS_FILE` from `inputs.instructions-file`) without quoting. An unquoted expansion lets the shell parse metacharacters (`;`, `|`, `&`, `$(...)`, etc.) out of the value. Additionally, `aptu scan-security $SCAN_PATH` expands `$SCAN_PATH` (from `inputs.scan-path`) unquoted. All of these should be double-quoted: `aptu issue triage $ARGS` → `aptu issue triage $ARGS` with each component quoted, or restructured to use arrays. Affected steps: "Run aptu issue triage", "Run aptu issue triage (scheduled batch)", "Run aptu PR label", "Run aptu PR review", "Run aptu scan-security".

Locations:

- `action.yml:275`
- `action.yml:312`
- `action.yml:337`
- `action.yml:383`
- `action.yml:407`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in hardened/action/action.yml:

1. Line 261 (Install aptu binary step): Moved `${{ steps.resolve-version.outputs.version }}` from the `run:` block into the `env:` block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`. The script now references `$APTU_VERSION` safely.

2. Lines 275, 312, 337, 383 (Run aptu issue triage, Run aptu issue triage scheduled batch, Run aptu PR label, Run aptu PR review): Converted all string-based `ARGS` accumulation patterns to bash arrays (`ARGS=()`, `ARGS+=(...)`). All user-controlled values (`$SINCE`, `$ISSUE_STATE`, `$REPO_PATH`, `$INSTRUCTIONS_FILE`) are now properly double-quoted when added to the array. Final command invocations use `"${ARGS[@]}"` for safe expansion. Line 407 (scan-security) already had `$SCAN_PATH` properly double-quoted in the actual command.

