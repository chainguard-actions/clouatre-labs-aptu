<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **clouatre-labs--aptu/v0.8.3** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): A ${{ }} expression is interpolated directly inside a run: shell script in the 'Install aptu binary' step. The line `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"` embeds the expression value directly into the shell command string before the shell processes it, enabling script injection if the value contains shell metacharacters.

Locations:

- `action.yml:230`

### script-injection (severity: high)

Sub-rule (b): Multiple steps build a $ARGS variable by appending unquoted env vars that hold workflow-controllable inputs (e.g. $SINCE from inputs.since, $ISSUE_STATE from inputs.issue-state, $REPO_PATH from inputs.repo-path, $INSTRUCTIONS_FILE from inputs.instructions-file), then invoke the CLI with unquoted `$ARGS` (e.g. `aptu issue triage $ARGS "$ISSUE_REF"`, `aptu issue triage $ARGS`, `aptu pr label $ARGS "$PR_REF"`, `aptu pr review $ARGS "$PR_REF"`). Unquoted expansion of $ARGS allows the shell to parse metacharacters (`;`, `|`, `&`, `$(...)`, etc.) from attacker-controlled input values, enabling command injection.

Locations:

- `action.yml:289`
- `action.yml:316`
- `action.yml:340`
- `action.yml:380`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in action.yml:

1. 'Install aptu binary' step (line 230): Moved `${{ steps.resolve-version.outputs.version }}` from the run: shell body into the step's env: block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`. The shell script now uses the plain env var `$APTU_VERSION`.

2. Four steps ('Run aptu issue triage', 'Run aptu issue triage (scheduled batch)', 'Run aptu PR label', 'Run aptu PR review') at lines 289, 316, 340, 380: Replaced string-based `ARGS=""` / `$ARGS` (unquoted) pattern with bash arrays `ARGS=()` / `ARGS+=()` / `"${ARGS[@]}"`. Each flag and its value are now separate array elements (e.g., `ARGS+=(--since "$SINCE")`), preventing shell metacharacters in user-controlled inputs from being interpreted as shell commands.

