<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.5** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): A ${{ }} expression is directly interpolated inside a run: shell command string in the 'Install aptu binary' step: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`. This causes the expression to be substituted into the shell script before the shell parses it, enabling script injection if the value contains shell metacharacters.

Locations:

- `action.yml:233`

### script-injection (severity: high)

Sub-rule (b): Unquoted shell variable expansions of workflow-controllable data in multiple run: blocks. (1) 'Run aptu issue triage' step: `aptu issue triage $ARGS "$ISSUE_REF"` — $ARGS is unquoted and built from inputs. (2) 'Run aptu issue triage (scheduled batch)' step: `ARGS="$ARGS --since $SINCE"`, `ARGS="$ARGS --state $ISSUE_STATE"`, and `aptu issue triage $ARGS` — $SINCE (from inputs.since) and $ISSUE_STATE (from inputs.issue-state) are unquoted. (3) 'Run aptu PR label' step: `aptu pr label $ARGS "$PR_REF"` — $ARGS unquoted. (4) 'Run aptu PR review' step: `ARGS="$ARGS --repo-path $REPO_PATH"`, `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"`, and `aptu pr review $ARGS "$PR_REF"` — $REPO_PATH (from inputs.repo-path) and $INSTRUCTIONS_FILE (from inputs.instructions-file) are unquoted, allowing shell metacharacter injection.

Locations:

- `action.yml:271`
- `action.yml:272`
- `action.yml:297`
- `action.yml:300`
- `action.yml:303`
- `action.yml:330`
- `action.yml:355`
- `action.yml:358`
- `action.yml:361`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in action.yml:

1. Line 233: Moved `${{ steps.resolve-version.outputs.version }}` from the run: script body into the step's env: block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`. The script now uses `$APTU_VERSION` safely.

2. Multiple lines: Converted string-based ARGS variable to bash arrays in four steps ('Run aptu issue triage', 'Run aptu issue triage (scheduled batch)', 'Run aptu PR label', 'Run aptu PR review'). Changed `ARGS=""` to `ARGS=()`, `ARGS="$ARGS --flag"` to `ARGS+=(--flag)`, and `command $ARGS` to `command "${ARGS[@]}"`. Values like $SINCE, $ISSUE_STATE, $REPO_PATH, and $INSTRUCTIONS_FILE are now properly quoted within array elements (e.g., `ARGS+=(--since "$SINCE")`), preventing shell metacharacter injection.

