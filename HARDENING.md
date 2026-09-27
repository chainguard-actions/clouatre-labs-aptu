<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.3** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Install aptu binary' step directly interpolates `${{ steps.resolve-version.outputs.version }}` inside a `run:` shell script: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`. Any `${{ ... }}` expression inside a `run:` block is a script-injection risk because YAML template substitution happens before the shell ever sees the value. `steps.*.outputs.*` is a workflow-controllable context and must be passed via an `env:` variable instead.

Locations:

- `action.yml:237`

### script-injection (severity: high)

Sub-rule (b): Multiple steps build a `$ARGS` string from user-controlled inputs and then expand it unquoted in shell commands. Unquoted variable expansion allows shell metacharacter injection (`;`, `|`, `&`, `$(...)`, etc.).

- 'Run aptu issue triage (scheduled batch)': `ARGS="--repo $REPO"` (unquoted `$REPO`) and `aptu issue triage $ARGS` (unquoted `$ARGS` built from `$SINCE`, `$ISSUE_STATE`).
- 'Run aptu issue triage': `aptu issue triage $ARGS "$ISSUE_REF"` (unquoted `$ARGS`).
- 'Run aptu PR label': `aptu pr label $ARGS "$PR_REF"` (unquoted `$ARGS`).
- 'Run aptu PR review': `ARGS="$ARGS --repo-path $REPO_PATH"` and `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"` (unquoted inputs), then `aptu pr review $ARGS "$PR_REF"` (unquoted `$ARGS`).

All of `$REPO`, `$SINCE`, `$ISSUE_STATE`, `$REPO_PATH`, and `$INSTRUCTIONS_FILE` are sourced from `inputs.*` or `github.*` via `env:` and must be double-quoted at every expansion site.

Locations:

- `action.yml:295`
- `action.yml:330`
- `action.yml:340`
- `action.yml:365`
- `action.yml:410`
- `action.yml:415`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in action.yml:

1. Finding (a) line 237: Moved `${{ steps.resolve-version.outputs.version }}` from the `run:` block into the `env:` block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`. The shell script now uses `$APTU_VERSION` safely as an environment variable.

2. Finding (b) multiple lines: Converted all string-concatenation `$ARGS` patterns to bash arrays (`ARGS=()`) across four steps:
   - 'Run aptu issue triage': `ARGS=()` with `ARGS+=(--flag)` and `"${ARGS[@]}"`
   - 'Run aptu issue triage (scheduled batch)': `ARGS+=(--repo "$REPO")`, `ARGS+=(--since "$SINCE")`, `ARGS+=(--state "$ISSUE_STATE")` — all values properly quoted
   - 'Run aptu PR label': `ARGS=()` with `"${ARGS[@]}"`
   - 'Run aptu PR review': `ARGS+=(--repo-path "$REPO_PATH")` and `ARGS+=(--instructions-file "$INSTRUCTIONS_FILE")` — all values properly quoted, and `"${ARGS[@]}"` for safe expansion

All user-controlled inputs are now properly quoted at every expansion site, preventing shell metacharacter injection.

