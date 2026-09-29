<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.3** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): A `${{ steps.resolve-version.outputs.version }}` expression (a workflow-controllable `steps.*` context) is interpolated directly inside a `run:` shell script in the "Install aptu binary" step: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`. This allows YAML template substitution to inject arbitrary shell content before the shell parses the command.

Locations:

- `action.yml:236`

### script-injection (severity: high)

Rule (b): Multiple unquoted shell variable expansions of inputs-derived env vars in the "Run aptu issue triage (scheduled batch)" step. `$SINCE` (from `inputs.since`) and `$ISSUE_STATE` (from `inputs.issue-state`) are appended unquoted inside double-quoted strings when building `$ARGS` (`ARGS="$ARGS --since $SINCE"`, `ARGS="$ARGS --state $ISSUE_STATE"`), and `$ARGS` is then passed unquoted to the final command (`aptu issue triage $ARGS`). An attacker-controlled input value containing shell metacharacters (`;`, `|`, `&`, `$(...)`) can break out of the string context.

Locations:

- `action.yml:316`
- `action.yml:320`
- `action.yml:332`

### script-injection (severity: high)

Rule (b): Unquoted shell variable expansions of inputs-derived env vars in the "Run aptu PR review" step. `$REPO_PATH` (from `inputs.repo-path`) and `$INSTRUCTIONS_FILE` (from `inputs.instructions-file`) are appended unquoted when building `$ARGS` (`ARGS="$ARGS --repo-path $REPO_PATH"`, `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"`), and `$ARGS` is then passed unquoted to `aptu pr review $ARGS`. Attacker-controlled path inputs containing shell metacharacters can cause command injection.

Locations:

- `action.yml:399`
- `action.yml:403`
- `action.yml:408`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed all three script-injection findings in hardened/action/action.yml:
1. 'Install aptu binary' step (line 236): Moved `${{ steps.resolve-version.outputs.version }}` from the run: shell into the env: block as APTU_VERSION, eliminating direct YAML template interpolation into shell.
2. 'Run aptu issue triage (scheduled batch)' step (lines 316, 320, 332): Converted string-based ARGS variable to a bash array. $SINCE and $ISSUE_STATE are now appended with proper quoting (ARGS+=(--since "$SINCE")), and the final command uses "${ARGS[@]}" preventing shell metacharacter injection.
3. 'Run aptu PR review' step (lines 399, 403, 408): Same bash array approach - $REPO_PATH and $INSTRUCTIONS_FILE are now appended with proper quoting (ARGS+=(--repo-path "$REPO_PATH")), and the final command uses "${ARGS[@]}" preventing shell metacharacter injection.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed three script-injection findings in hardened/action/action.yml:
1. 'Run aptu issue triage' (line ~269): Converted ARGS from a string variable (expanded unquoted as `$ARGS`) to a bash array. Now built with `ARGS+=()` and expanded safely as `"${ARGS[@]}"`.
2. 'Run aptu PR label' (line ~330): Same fix — ARGS string converted to bash array with proper `"${ARGS[@]}"` expansion.
3. 'Run aptu scan-security' (lines ~394, ~397): Added quotes around `$SCAN_DIFF` and `$SCAN_PATH` inside the echo strings (escaped as `\"$SCAN_DIFF\"` and `\"$SCAN_PATH\"`) to prevent command substitution from unquoted variable expansions inside double-quoted strings. The actual command invocations already had proper quoting.

