<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **clouatre-labs--aptu/v0.8.6** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): The 'Install aptu binary' step interpolates `${{ steps.resolve-version.outputs.version }}` directly inside a `run:` shell script block: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`. Any `${{ ... }}` expression inside a run: block is a script-injection risk because YAML template substitution occurs before the shell ever sees the string, allowing a workflow-controllable value to inject shell metacharacters.

Locations:

- `action.yml:238`

### script-injection (severity: high)

Rule (b): Multiple steps build a `$ARGS` string by appending unquoted user-controlled input values — `$SINCE` (inputs.since), `$ISSUE_STATE` (inputs.issue-state), `$REPO_PATH` (inputs.repo-path), and `$INSTRUCTIONS_FILE` (inputs.instructions-file) — and then expand `$ARGS` unquoted in the final command invocations (`aptu issue triage $ARGS`, `aptu pr label $ARGS`, `aptu pr review $ARGS`). An attacker-controlled input containing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) can break out of the intended argument context and execute arbitrary commands. Affected steps: 'Run aptu issue triage', 'Run aptu issue triage (scheduled batch)', 'Run aptu PR label', 'Run aptu PR review'.

Locations:

- `action.yml:302`
- `action.yml:330`
- `action.yml:362`
- `action.yml:415`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in action.yml:

1. 'Install aptu binary' step (line 238): Moved `${{ steps.resolve-version.outputs.version }}` from the run: block into the step's env: block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`. The shell script now references it as the plain env var `$APTU_VERSION`.

2. Four steps building unquoted $ARGS strings with user-controlled values: Converted all four affected steps ('Run aptu issue triage', 'Run aptu issue triage (scheduled batch)', 'Run aptu PR label', 'Run aptu PR review') from string-concatenation `ARGS="$ARGS --flag $USER_VALUE"` patterns to bash arrays `ARGS+=(--flag "$USER_VALUE")`. The final command invocations use `"${ARGS[@]}"` to keep each argument properly quoted and separate, preventing shell metacharacter injection from inputs like `inputs.since`, `inputs.issue-state`, `inputs.repo-path`, and `inputs.instructions-file`.

