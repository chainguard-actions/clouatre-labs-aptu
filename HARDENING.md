<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.5** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Install aptu binary' step directly interpolates `${{ steps.resolve-version.outputs.version }}` inside a `run:` shell script: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`.

This `steps.*.outputs.*` context value flows through YAML template substitution before the shell ever sees it. If the value contains shell metacharacters (e.g. injected via a compromised release API response), it could execute arbitrary commands. The value should be passed via an `env:` variable and then referenced as `"$APTU_VERSION"` (which it already is for subsequent use, but the initial assignment itself is the injection point).

Locations:

- `action.yml:237`

### script-injection (severity: high)

Sub-rule (b): Multiple `run:` steps build an `$ARGS` string by appending user-controlled input values without quoting, then pass `$ARGS` unquoted to `aptu` commands. This allows word splitting and glob expansion on attacker-controlled data.

Affected patterns:
- 'Run aptu issue triage': `aptu issue triage $ARGS "$ISSUE_REF"` — `$ARGS` unquoted
- 'Run aptu issue triage (scheduled batch)': `ARGS="$ARGS --since $SINCE"` and `ARGS="$ARGS --state $ISSUE_STATE"` (where `$SINCE` = `inputs.since` and `$ISSUE_STATE` = `inputs.issue-state`), then `aptu issue triage $ARGS` — `$ARGS` unquoted
- 'Run aptu PR label': `aptu pr label $ARGS "$PR_REF"` — `$ARGS` unquoted
- 'Run aptu PR review': `ARGS="$ARGS --repo-path $REPO_PATH"` and `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"` (where `$REPO_PATH` = `inputs.repo-path` and `$INSTRUCTIONS_FILE` = `inputs.instructions-file`), then `aptu pr review $ARGS "$PR_REF"` — `$ARGS` unquoted

Fix: use an array (`ARGS=(); ARGS+=(--since "$SINCE")`) and expand as `"${ARGS[@]}"`.

Locations:

- `action.yml:290`
- `action.yml:316`
- `action.yml:330`
- `action.yml:356`
- `action.yml:400`
- `action.yml:408`
- `action.yml:412`
- `action.yml:416`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in hardened/action/action.yml:

1. Sub-rule (a) at line 237: Moved `${{ steps.resolve-version.outputs.version }}` out of the `run:` shell script and into the step's `env:` block as `APTU_VERSION`. The shell script now references `$APTU_VERSION` as a plain environment variable.

2. Sub-rule (b) at lines 290, 316, 330, 356, 400, 408, 412, 416: Converted all four affected steps from string-concatenation `ARGS="$ARGS --flag $VALUE"` patterns to bash arrays (`ARGS=()`/`ARGS+=(--flag "$VALUE")`). All user-controlled values (`$SINCE`, `$ISSUE_STATE`, `$REPO_PATH`, `$INSTRUCTIONS_FILE`) are now properly quoted as individual array elements. All `aptu` command invocations now use `"${ARGS[@]}"` for safe, properly-quoted expansion.

