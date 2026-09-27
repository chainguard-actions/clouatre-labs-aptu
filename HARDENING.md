<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.4** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Install aptu binary' step directly interpolates `${{ steps.resolve-version.outputs.version }}` inside the `run:` shell script body: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`. The expression is substituted into the shell command string before the shell parses it, so a malicious value in that step output could inject arbitrary shell commands. It should be passed via an `env:` variable and referenced as `"$APTU_VERSION"` instead.

Locations:

- `action.yml:228`

### script-injection (severity: high)

Sub-rule (b): The 'Run aptu issue triage (scheduled batch)' step appends untrusted input values to `$ARGS` without quoting: `ARGS="$ARGS --since $SINCE"` (where `$SINCE` comes from `inputs.since`) and `ARGS="$ARGS --state $ISSUE_STATE"` (where `$ISSUE_STATE` comes from `inputs.issue-state`). The accumulated `$ARGS` is then passed unquoted to `aptu issue triage $ARGS`, allowing shell metacharacters in those inputs to break out of the intended argument context. Each value should be quoted: `ARGS="$ARGS --since \"$SINCE\""`

Locations:

- `action.yml:310`
- `action.yml:313`

### script-injection (severity: high)

Sub-rule (b): The 'Run aptu PR review' step appends untrusted input values to `$ARGS` without quoting: `ARGS="$ARGS --repo-path $REPO_PATH"` (where `$REPO_PATH` comes from `inputs.repo-path`) and `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"` (where `$INSTRUCTIONS_FILE` comes from `inputs.instructions-file`). The accumulated `$ARGS` is then passed unquoted to `aptu pr review $ARGS "$PR_REF"`, allowing shell metacharacters in those inputs to inject arbitrary commands. Each value should be quoted when appended.

Locations:

- `action.yml:395`
- `action.yml:400`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed all three script-injection findings in hardened/action/action.yml:
1. 'Install aptu binary' step (line 228): Moved `${{ steps.resolve-version.outputs.version }}` from the run: shell body into the env: block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`, removing the inline expression interpolation.
2. 'Run aptu issue triage (scheduled batch)' step (lines 310, 313): Added double-quote escaping around $SINCE and $ISSUE_STATE when appending to $ARGS to prevent shell metacharacter injection.
3. 'Run aptu PR review' step (lines 395, 400): Added double-quote escaping around $REPO_PATH and $INSTRUCTIONS_FILE when appending to $ARGS to prevent shell metacharacter injection.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed all four script-injection findings in action.yml by replacing the unquoted `$ARGS` string variable pattern with bash arrays in all four affected steps:

1. **"Run aptu issue triage"** (line ~248): Changed `ARGS=""` to `ARGS=()`, replaced `ARGS="$ARGS --flag"` with `ARGS+=(--flag)`, and changed `aptu issue triage $ARGS "$ISSUE_REF"` to `aptu issue triage "${ARGS[@]}" "$ISSUE_REF"`.

2. **"Run aptu issue triage (scheduled batch)"** (line ~281): Changed `ARGS="--repo $REPO"` to `ARGS=(--repo "$REPO")`, replaced string interpolation of `$SINCE` and `$ISSUE_STATE` with `ARGS+=(--since "$SINCE")` and `ARGS+=(--state "$ISSUE_STATE")`, and changed `aptu issue triage $ARGS` to `aptu issue triage "${ARGS[@]}"`.

3. **"Run aptu PR label"** (line ~310): Changed `ARGS=""` to `ARGS=()`, replaced `ARGS="$ARGS --flag"` with `ARGS+=(--flag)`, and changed `aptu pr label $ARGS "$PR_REF"` to `aptu pr label "${ARGS[@]}" "$PR_REF"`.

4. **"Run aptu PR review"** (line ~358): Changed `ARGS="--comment --force"` to `ARGS=(--comment --force)`, replaced string interpolation of `$REPO_PATH` and `$INSTRUCTIONS_FILE` with `ARGS+=(--repo-path "$REPO_PATH")` and `ARGS+=(--instructions-file "$INSTRUCTIONS_FILE")`, and changed `aptu pr review $ARGS "$PR_REF"` to `aptu pr review "${ARGS[@]}" "$PR_REF"`.

Using bash arrays ensures each argument remains a separate, properly-quoted token, preventing shell metacharacter injection from attacker-controlled input values.

