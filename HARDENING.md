<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.7

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.7** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): In the 'Install aptu binary' step, the expression `${{ steps.resolve-version.outputs.version }}` is interpolated directly inside a `run:` shell script: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`. The `steps.*.outputs.*` context flows through YAML template substitution before the shell processes it, allowing an attacker who can influence the step output to inject arbitrary shell commands.

Locations:

- `action.yml:231`

### script-injection (severity: high)

Rule (b): Multiple `run:` steps build an `$ARGS` string by appending unquoted values from `inputs.*`-sourced env vars (e.g. `ARGS="$ARGS --since $SINCE"`, `ARGS="$ARGS --state $ISSUE_STATE"`, `ARGS="$ARGS --repo-path $REPO_PATH"`, `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"`), then expand `$ARGS` unquoted in the final command (e.g. `aptu issue triage $ARGS "$ISSUE_REF"`, `aptu issue triage $ARGS`, `aptu pr label $ARGS "$PR_REF"`, `aptu pr review $ARGS "$PR_REF"`). An attacker-controlled input containing shell metacharacters (`;`, `|`, `&`, `$(...)`) can break out of the intended argument and execute arbitrary commands.

Locations:

- `action.yml:280`
- `action.yml:320`
- `action.yml:355`
- `action.yml:410`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in action.yml:

1. 'Install aptu binary' step (line 231): Moved `${{ steps.resolve-version.outputs.version }}` from the run: shell script into the step's env: block as APTU_VERSION, eliminating direct YAML template interpolation into the shell.

2. Four run: steps (lines 280, 320, 355, 410): Replaced all unquoted string-concatenation ARGS patterns with bash arrays (ARGS=()/ARGS+=(...)/"${ARGS[@]}"). Each flag and its value are now separate, properly-quoted array elements, preventing shell metacharacter injection from attacker-controlled inputs like `since`, `issue-state`, `repo-path`, and `instructions-file`.

