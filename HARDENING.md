<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.4** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Install aptu binary' step directly interpolates a ${{ steps.resolve-version.outputs.version }} expression inside the run: shell script: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`. Any ${{ ... }} expression inside a run: block is a script-injection risk because YAML template substitution occurs before the shell ever sees the value, allowing an attacker who can influence step outputs to inject arbitrary shell commands.

Locations:

- `action.yml:233`

### script-injection (severity: high)

Sub-rule (b): Multiple run: blocks build a $ARGS string by appending unquoted user-controlled inputs, then pass $ARGS unquoted to the aptu CLI. Specifically: (1) `ARGS="$ARGS --since $SINCE"` — $SINCE comes from inputs.since; (2) `ARGS="$ARGS --state $ISSUE_STATE"` — $ISSUE_STATE comes from inputs.issue-state; (3) `ARGS="$ARGS --repo-path $REPO_PATH"` — $REPO_PATH comes from inputs.repo-path; (4) `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"` — $INSTRUCTIONS_FILE comes from inputs.instructions-file. The accumulated $ARGS is then used unquoted in `aptu issue triage $ARGS`, `aptu pr label $ARGS`, and `aptu pr review $ARGS`, allowing shell metacharacters in any of these inputs to break out of the argument context and execute arbitrary commands.

Locations:

- `action.yml:310`
- `action.yml:314`
- `action.yml:319`
- `action.yml:323`
- `action.yml:395`
- `action.yml:399`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script injection issues in action.yml:

1. 'Install aptu binary' step (line 233): Moved `${{ steps.resolve-version.outputs.version }}` from the run: shell script into the step's env: block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`. The inline assignment `APTU_VERSION="${{ ... }}"` was removed; the variable is now referenced as `$APTU_VERSION` from the environment.

2. 'Run aptu issue triage (scheduled batch)' and 'Run aptu PR review' steps: Converted string-based `ARGS` variable to bash arrays (`ARGS=(...)` and `ARGS+=(...)`), with user-controlled values (`$SINCE`, `$ISSUE_STATE`, `$REPO_PATH`, `$INSTRUCTIONS_FILE`) properly double-quoted inside array elements. Final commands use `"${ARGS[@]}"` to expand the array with proper word-splitting boundaries, preventing shell metacharacters in any input from breaking out of argument context.

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script injection findings in action.yml:
1. 'Run aptu issue triage' step (~line 247): Converted `ARGS=""` string with unquoted `$ARGS` expansion to a bash array (`ARGS=()`, `ARGS+=(--flag)`, `"${ARGS[@]}"`). 
2. 'Run aptu PR label' step (~line 296): Same conversion from string to bash array.
Both now match the safe pattern already used in the 'Run aptu issue triage (scheduled batch)' step.

