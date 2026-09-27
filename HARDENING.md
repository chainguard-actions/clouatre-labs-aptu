<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.6** was hardened automatically. 6 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): A ${{ }} expression is directly interpolated inside a run: shell script. In the 'Install aptu binary' step, the line `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"` substitutes the steps context value through YAML template expansion before the shell sees it, enabling script injection if the value contains shell metacharacters.

Locations:

- `action.yml:232`

### script-injection (severity: high)

Rule (b): Unquoted shell variable expansion of workflow-controllable data. In the 'Run aptu issue triage' step, `$ARGS` is expanded unquoted in `aptu issue triage $ARGS "$ISSUE_REF"`. The ARGS variable is built from env vars sourced from inputs (DRY_RUN, APPLY_LABELS, NO_COMMENT) and the final command passes $ARGS unquoted, allowing shell metacharacter injection.

Locations:

- `action.yml:285`

### script-injection (severity: high)

Rule (b): Unquoted shell variable expansion of workflow-controllable data. In the 'Run aptu issue triage (scheduled batch)' step, `$ARGS` is built with unquoted `$REPO` (from github.repository) via `ARGS="--repo $REPO"`, and then `aptu issue triage $ARGS` expands $ARGS unquoted. Additionally, $SINCE and $ISSUE_STATE (from inputs) are appended to $ARGS unquoted.

Locations:

- `action.yml:316`

### script-injection (severity: high)

Rule (b): Unquoted shell variable expansion of workflow-controllable data. In the 'Run aptu PR label' step, `$ARGS` is expanded unquoted in `aptu pr label $ARGS "$PR_REF"`. The ARGS variable is built from DRY_RUN (from inputs.dry-run) without quoting.

Locations:

- `action.yml:345`

### script-injection (severity: high)

Rule (b): Unquoted shell variable expansion of workflow-controllable data. In the 'Run aptu PR review' step, `$ARGS` is expanded unquoted in `aptu pr review $ARGS "$PR_REF"`. ARGS is built from REPO_PATH (inputs.repo-path) and INSTRUCTIONS_FILE (inputs.instructions-file) appended without quoting, e.g. `ARGS="$ARGS --repo-path $REPO_PATH"` and `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"`.

Locations:

- `action.yml:390`

### script-injection (severity: high)

Rule (b): Unquoted shell variable expansion of workflow-controllable data. In the 'Run aptu scan-security' step, the echo statements use unquoted `$SCAN_DIFF` and `$SCAN_PATH` (sourced from inputs.scan-security-diff and inputs.scan-path): `echo "Running: aptu scan-security --diff $SCAN_DIFF --output sarif"` and `echo "Running: aptu scan-security $SCAN_PATH --output sarif"`. While the actual aptu invocations quote these variables, the unquoted echo expansions still allow shell metacharacter interpretation.

Locations:

- `action.yml:418`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed all 6 script-injection findings in hardened/action/action.yml:

1. 'Install aptu binary' step (line 232): Moved `${{ steps.resolve-version.outputs.version }}` from the run script body into the step's `env:` block as `APTU_VERSION`, eliminating the inline template expression.

2. 'Run aptu issue triage' step (line 285): Replaced string-based ARGS accumulation and unquoted `$ARGS` expansion with a bash array (`ARGS=()`, `ARGS+=(--flag)`, `"${ARGS[@]}"`), ensuring each flag is a separate, properly-bounded argument.

3. 'Run aptu issue triage (scheduled batch)' step (line 316): Same bash array fix; `$REPO`, `$SINCE`, and `$ISSUE_STATE` are now quoted as separate array elements (`ARGS=(--repo "$REPO")`, etc.).

4. 'Run aptu PR label' step (line 345): Same bash array fix for the single `--dry-run` flag.

5. 'Run aptu PR review' step (line 390): Same bash array fix; `$REPO_PATH` and `$INSTRUCTIONS_FILE` are now properly quoted as separate array elements (`ARGS+=(--repo-path "$REPO_PATH")`, `ARGS+=(--instructions-file "$INSTRUCTIONS_FILE")`).

6. 'Run aptu scan-security' step (line 418): Quoted `$SCAN_DIFF` and `$SCAN_PATH` inside the echo statements using escaped double-quotes to prevent shell metacharacter interpretation during display.

