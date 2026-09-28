<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.4** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): A `${{ ... }}` expression is interpolated directly inside a `run:` shell script in the 'Install aptu binary' step. The line `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"` embeds a GitHub Actions expression directly into the shell command string before the shell ever sees it, bypassing any quoting. Any `${{ ... }}` inside a `run:` block is a script-injection risk regardless of the source context.

Locations:

- `action.yml:261`

### script-injection (severity: high)

Sub-rule (b): Multiple `run:` blocks expand `$ARGS` unquoted in the final command invocation (e.g. `aptu issue triage $ARGS "$ISSUE_REF"`, `aptu pr label $ARGS "$PR_REF"`, `aptu pr review $ARGS "$PR_REF"`, `aptu issue triage $ARGS`). The `$ARGS` variable is built by appending values sourced from user-controlled inputs without quoting: `$SINCE` (from `inputs.since`), `$ISSUE_STATE` (from `inputs.issue-state`), `$REPO_PATH` (from `inputs.repo-path`), and `$INSTRUCTIONS_FILE` (from `inputs.instructions-file`) are all concatenated into `$ARGS` unquoted. An attacker-supplied value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) in any of these inputs would be word-split and interpreted by the shell when `$ARGS` is expanded without double-quotes.

Locations:

- `action.yml:330`
- `action.yml:370`
- `action.yml:400`
- `action.yml:450`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in hardened/action/action.yml:

1. Line 261 ('Install aptu binary' step): Moved `${{ steps.resolve-version.outputs.version }}` from the `run:` block into the step's `env:` block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`. The shell script now references it as `$APTU_VERSION`.

2. Lines 330, 370, 400, 450 (four `run:` blocks): Converted all unquoted `$ARGS` string-concatenation patterns to bash arrays. Each step now uses `args=()` and appends flags with `args+=(--flag "$VALUE")`, then invokes the command with `"${args[@]}"`. This ensures user-controlled inputs (`$SINCE`, `$ISSUE_STATE`, `$REPO_PATH`, `$INSTRUCTIONS_FILE`) are always properly quoted and cannot be interpreted as shell metacharacters.

