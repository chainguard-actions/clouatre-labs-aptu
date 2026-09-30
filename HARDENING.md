<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.7

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.7** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): In the 'Install aptu binary' step, the expression `${{ steps.resolve-version.outputs.version }}` is directly interpolated inside the `run:` shell script body: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`. Any `${{ ... }}` expression inside a `run:` block is a script-injection risk because the value is substituted by the YAML template engine before the shell ever sees it, allowing an attacker who can influence the step output to inject shell metacharacters.

Locations:

- `action.yml:237`

### script-injection (severity: high)

Sub-rule (b): In the 'Run aptu PR review' step, user-controlled inputs `inputs.repo-path` (env var `$REPO_PATH`) and `inputs.instructions-file` (env var `$INSTRUCTIONS_FILE`) are appended to the `$ARGS` string without quoting: `ARGS="$ARGS --repo-path $REPO_PATH"` and `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"`. The accumulated `$ARGS` is then expanded unquoted in the final command `aptu pr review $ARGS "$PR_REF"`. An attacker supplying shell metacharacters (`;`, `|`, `$(...)`, etc.) in these inputs can inject arbitrary shell commands.

Locations:

- `action.yml:404`
- `action.yml:408`
- `action.yml:412`

### script-injection (severity: high)

Sub-rule (b): In the 'Run aptu issue triage (scheduled batch)' step, user-controlled inputs `inputs.since` (env var `$SINCE`) and `inputs.issue-state` (env var `$ISSUE_STATE`) are appended to `$ARGS` unquoted: `ARGS="$ARGS --since $SINCE"` and `ARGS="$ARGS --state $ISSUE_STATE"`. The accumulated `$ARGS` is then expanded unquoted in `aptu issue triage $ARGS`. An attacker supplying shell metacharacters in these inputs can inject arbitrary shell commands.

Locations:

- `action.yml:321`
- `action.yml:325`
- `action.yml:340`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed all three script-injection findings in hardened/action/action.yml:
1. 'Install aptu binary' step (line 237): Moved `${{ steps.resolve-version.outputs.version }}` from the run: shell body into the step's env: block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`. The shell script now reads it as the environment variable `$APTU_VERSION`.
2. 'Run aptu PR review' step (lines 404, 408, 412): Converted string-based ARGS accumulation to a bash array. `REPO_PATH` and `INSTRUCTIONS_FILE` are now properly quoted as separate array elements (`ARGS+=(--repo-path "$REPO_PATH")` and `ARGS+=(--instructions-file "$INSTRUCTIONS_FILE")`). Final command uses `"${ARGS[@]}"` for safe word-boundary-preserving expansion.
3. 'Run aptu issue triage (scheduled batch)' step (lines 321, 325, 340): Converted string-based ARGS accumulation to a bash array. `SINCE` and `ISSUE_STATE` are now properly quoted as separate array elements (`ARGS+=(--since "$SINCE")` and `ARGS+=(--state "$ISSUE_STATE")`). Final command uses `"${ARGS[@]}"` for safe expansion.

