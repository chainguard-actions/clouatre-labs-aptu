<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.6** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): In the 'Install aptu binary' step, the expression `${{ steps.resolve-version.outputs.version }}` is interpolated directly inside the `run:` shell command string: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`. Any `steps.*.outputs.*` value is a workflow-controllable context that flows through YAML template substitution before the shell sees it, making this a script injection risk. The value should be passed via an `env:` variable and then referenced as `"$APTU_VERSION"` (which it already is later in the script — the fix is to move the assignment into the `env:` block instead of the `run:` block).

Locations:

- `action.yml:232`

### script-injection (severity: high)

Sub-rule (b): Multiple `run:` steps build a `$ARGS` string by appending unquoted user-controlled inputs, then invoke `aptu` with unquoted `$ARGS`, allowing word-splitting and shell metacharacter injection. Affected patterns:

1. Scheduled batch triage step: `ARGS="$ARGS --since $SINCE"` and `ARGS="$ARGS --state $ISSUE_STATE"` append `$SINCE` (from `inputs.since`) and `$ISSUE_STATE` (from `inputs.issue-state`) unquoted, then `aptu issue triage $ARGS` is called with unquoted `$ARGS`.

2. PR review step: `ARGS="$ARGS --repo-path $REPO_PATH"` and `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"` append `$REPO_PATH` (from `inputs.repo-path`) and `$INSTRUCTIONS_FILE` (from `inputs.instructions-file`) unquoted, then `aptu pr review $ARGS "$PR_REF"` is called with unquoted `$ARGS`.

All these inputs are `required: false` and caller-controlled, so a value containing shell metacharacters (`;`, `|`, `$(...)`, etc.) would be interpreted by the shell.

Locations:

- `action.yml:330`
- `action.yml:336`
- `action.yml:344`
- `action.yml:399`
- `action.yml:411`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed three script-injection issues in hardened/action/action.yml:
1. 'Install aptu binary' step (line 232): Moved `${{ steps.resolve-version.outputs.version }}` from the run: shell string into the env: block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`, removing the inline template substitution.
2. 'Run aptu issue triage (scheduled batch)' step (lines 330, 336, 344): Replaced unquoted string-based ARGS building (`ARGS="$ARGS --since $SINCE"`, `ARGS="$ARGS --state $ISSUE_STATE"`) with a bash array (`ARGS=(...)`, `ARGS+=(...)`), with $SINCE and $ISSUE_STATE properly quoted as separate array elements. Final invocation uses `"${ARGS[@]}"` for safe expansion.
3. 'Run aptu PR review' step (lines 399, 411): Replaced unquoted string-based ARGS building (`ARGS="$ARGS --repo-path $REPO_PATH"`, `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"`) with a bash array, with $REPO_PATH and $INSTRUCTIONS_FILE properly quoted as separate array elements. Final invocation uses `"${ARGS[@]}"` for safe expansion.

