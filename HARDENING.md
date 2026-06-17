<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.7

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **clouatre-labs--aptu/v0.8.7** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): A ${{ steps.resolve-version.outputs.version }} expression is interpolated directly inside a run: shell script in the 'Install aptu binary' step. The steps.*.outputs.* context is workflow-controllable and flows through YAML template substitution before the shell processes it, enabling script injection. Offending line: APTU_VERSION="${{ steps.resolve-version.outputs.version }}"

Locations:

- `action.yml:232`

### script-injection (severity: high)

Sub-rule (b): Multiple steps build an $ARGS variable by appending unquoted input-derived env vars, then pass $ARGS unquoted to shell commands. Patterns include: ARGS="--repo $REPO" (github.repository unquoted), ARGS="$ARGS --since $SINCE" (inputs.since unquoted), ARGS="$ARGS --state $ISSUE_STATE" (inputs.issue-state unquoted), ARGS="$ARGS --repo-path $REPO_PATH" (inputs.repo-path unquoted), ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE" (inputs.instructions-file unquoted), and the final unquoted aptu issue triage $ARGS and aptu pr review $ARGS invocations. Unquoted expansions of workflow-controllable data allow shell metacharacter injection.

Locations:

- `action.yml:302`
- `action.yml:305`
- `action.yml:316`
- `action.yml:319`
- `action.yml:390`
- `action.yml:393`
- `action.yml:420`
- `action.yml:423`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script injection findings in action.yml:

1. 'Install aptu binary' step (line 232): Moved `${{ steps.resolve-version.outputs.version }}` from the run script body into the step's env block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`. The run script now uses `$APTU_VERSION` as a plain env var.

2. Four steps with unquoted $ARGS expansion (lines 302-423): Converted all string-concatenated ARGS variables to bash arrays in 'Run aptu issue triage', 'Run aptu issue triage (scheduled batch)', 'Run aptu PR label', and 'Run aptu PR review' steps. User-controlled values ($REPO, $SINCE, $ISSUE_STATE, $REPO_PATH, $INSTRUCTIONS_FILE) are now properly double-quoted when appended to the array (e.g., `ARGS+=(--repo "$REPO")`), and commands use `"${ARGS[@]}"` for safe expansion.

