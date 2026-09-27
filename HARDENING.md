<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.7

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.7** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): In the 'Install aptu binary' step, the expression `${{ steps.resolve-version.outputs.version }}` is interpolated directly inside the `run:` shell script: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`. The Actions runner substitutes this value before the shell sees it, so any newlines or shell metacharacters in the step output can break out of the assignment and execute arbitrary commands. The value should be passed via an `env:` variable instead.

Locations:

- `action.yml:237`

### script-injection (severity: high)

Rule (b): Multiple `run:` blocks expand workflow-controllable env vars without double-quoting, allowing shell metacharacter injection:

1. 'Run aptu issue triage' step: `aptu issue triage $ARGS "$ISSUE_REF"` — `$ARGS` is unquoted; it is built from inputs (`$DRY_RUN`, `$APPLY_LABELS`, `$NO_COMMENT`) and word-splits on whitespace, allowing shell metacharacters to escape.

2. 'Run aptu issue triage (scheduled batch)' step: `ARGS="--repo $REPO"` (unquoted `$REPO` from `github.repository`), `ARGS="$ARGS --since $SINCE"` (unquoted `$SINCE` from `inputs.since`), `ARGS="$ARGS --state $ISSUE_STATE"` (unquoted `$ISSUE_STATE` from `inputs.issue-state`), and `aptu issue triage $ARGS` (unquoted `$ARGS`).

3. 'Run aptu PR label' step: `aptu pr label $ARGS "$PR_REF"` — `$ARGS` is unquoted.

4. 'Run aptu PR review' step: `ARGS="$ARGS --repo-path $REPO_PATH"` (unquoted `$REPO_PATH` from `inputs.repo-path`), `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"` (unquoted `$INSTRUCTIONS_FILE` from `inputs.instructions-file`), and `aptu pr review $ARGS "$PR_REF"` (unquoted `$ARGS`). All these variables should be double-quoted: `"$VAR"` or `"${VAR}"`.


Locations:

- `action.yml:295`
- `action.yml:310`
- `action.yml:315`
- `action.yml:320`
- `action.yml:325`
- `action.yml:360`
- `action.yml:400`
- `action.yml:405`
- `action.yml:415`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in action.yml:

1. 'Install aptu binary' step (line 237): Moved `${{ steps.resolve-version.outputs.version }}` from the `run:` shell script into the `env:` block as `APTU_VERSION`, eliminating direct expression interpolation in the shell.

2. Multiple run steps: Converted all string-based `ARGS` variables to bash arrays (`ARGS=()`) with `ARGS+=()` appends, and changed all final command invocations from unquoted `$ARGS` to `"${ARGS[@]}"`. User-controlled values (`$REPO`, `$SINCE`, `$ISSUE_STATE`, `$REPO_PATH`, `$INSTRUCTIONS_FILE`) are now properly double-quoted when added to the array. This was applied to: 'Run aptu issue triage', 'Run aptu issue triage (scheduled batch)', 'Run aptu PR label', and 'Run aptu PR review' steps.

