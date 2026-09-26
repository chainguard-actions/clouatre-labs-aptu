<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.7

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.7** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): In the 'Install aptu binary' step, the expression `${{ steps.resolve-version.outputs.version }}` is interpolated directly inside a `run:` shell script: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`. Any `${{ ... }}` expression inside a run block undergoes YAML template substitution before the shell sees it, allowing shell metacharacters in the value to be interpreted. The value should be passed via an `env:` variable instead.

Locations:

- `action.yml:232`

### script-injection (severity: high)

Sub-rule (b): Multiple steps expand workflow-controllable env vars unquoted inside shell commands, allowing shell metacharacters to be interpreted:

1. 'Run aptu issue triage' step: `aptu issue triage $ARGS "$ISSUE_REF"` — `$ARGS` is unquoted; it is built from `$DRY_RUN`, `$APPLY_LABELS`, `$NO_COMMENT` (all sourced from `inputs.*`).

2. 'Run aptu issue triage (scheduled batch)' step: `ARGS="$ARGS --since $SINCE"` and `ARGS="$ARGS --state $ISSUE_STATE"` — `$SINCE` and `$ISSUE_STATE` (from `inputs.since` and `inputs.issue-state`) are unquoted when appended to ARGS; then `aptu issue triage $ARGS` expands `$ARGS` unquoted.

3. 'Run aptu PR label' step: `aptu pr label $ARGS "$PR_REF"` — `$ARGS` unquoted.

4. 'Run aptu PR review' step: `ARGS="$ARGS --repo-path $REPO_PATH"` and `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"` — `$REPO_PATH` (from `inputs.repo-path`) and `$INSTRUCTIONS_FILE` (from `inputs.instructions-file`) are unquoted when appended to ARGS; then `aptu pr review $ARGS "$PR_REF"` expands `$ARGS` unquoted.

5. 'Run aptu scan-security' step: `echo "Running: aptu scan-security --diff $SCAN_DIFF --output sarif"` — `$SCAN_DIFF` (from `inputs.scan-security-diff`) is unquoted inside the double-quoted echo string.

All these variables should be double-quoted wherever they are expanded.

Locations:

- `action.yml:285`
- `action.yml:310`
- `action.yml:320`
- `action.yml:348`
- `action.yml:383`
- `action.yml:387`
- `action.yml:395`
- `action.yml:415`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in action.yml:

1. (Finding a, line 232) 'Install aptu binary' step: Moved `${{ steps.resolve-version.outputs.version }}` out of the `run:` block and into the `env:` block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`. The shell script already referenced `$APTU_VERSION` so no further changes were needed in the script body.

2. (Finding b, multiple lines) Five steps with unquoted variable expansions:
   - 'Run aptu issue triage': Converted `ARGS=""` string to `ARGS=()` bash array; used `ARGS+=("--flag")` for flag accumulation; used `"${ARGS[@]}"` for safe expansion in the final command.
   - 'Run aptu issue triage (scheduled batch)': Converted to array `ARGS=(--repo "$REPO")`; properly quoted `$SINCE` and `$ISSUE_STATE` when appended via `ARGS+=(--since "$SINCE")` and `ARGS+=(--state "$ISSUE_STATE")`; used `"${ARGS[@]}"` for safe expansion.
   - 'Run aptu PR label': Converted `ARGS=""` to `ARGS=()` array with proper array expansion.
   - 'Run aptu PR review': Converted `ARGS="--comment --force"` to `ARGS=(--comment --force)` array; properly quoted `$REPO_PATH` and `$INSTRUCTIONS_FILE` via `ARGS+=(--repo-path "$REPO_PATH")` and `ARGS+=(--instructions-file "$INSTRUCTIONS_FILE")`; used `"${ARGS[@]}"` for safe expansion.
   - 'Run aptu scan-security': Added double-quotes around `$SCAN_DIFF` in the echo string.

