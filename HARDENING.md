<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.7

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.7** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): In the 'Install aptu binary' step's run: block, a ${{ ... }} expression is directly interpolated into the shell script: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`. The steps.*.outputs.* context is explicitly listed as a failing pattern — any ${{ ... }} inside a run: block is a script-injection risk because the value is substituted by the template engine before the shell ever sees it, bypassing quoting.

Locations:

- `action.yml:226`

### script-injection (severity: high)

Sub-rule (b): In the 'Run aptu issue triage (scheduled batch)' step, the env vars $SINCE (from inputs.since) and $ISSUE_STATE (from inputs.issue-state) are appended unquoted into $ARGS (`ARGS="$ARGS --since $SINCE"`, `ARGS="$ARGS --state $ISSUE_STATE"`), and $ARGS is then used unquoted in the final command `aptu issue triage $ARGS`. Unquoted expansion of workflow-controllable env vars allows shell metacharacter injection.

Locations:

- `action.yml:290`

### script-injection (severity: high)

Sub-rule (b): In the 'Run aptu PR review' step, the env vars $REPO_PATH (from inputs.repo-path) and $INSTRUCTIONS_FILE (from inputs.instructions-file) are appended unquoted into $ARGS (`ARGS="$ARGS --repo-path $REPO_PATH"`, `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"`), and $ARGS is then used unquoted in `aptu pr review $ARGS "$PR_REF"`. Unquoted expansion of workflow-controllable env vars allows shell metacharacter injection.

Locations:

- `action.yml:360`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed all three script-injection findings in hardened/action/action.yml:
1. 'Install aptu binary' step (line 226): Moved `${{ steps.resolve-version.outputs.version }}` from the run block into the env block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`, then referenced it as `$APTU_VERSION` in the shell script.
2. 'Run aptu issue triage (scheduled batch)' step (line 290): Replaced unquoted string-based ARGS building with a bash array. `$SINCE` and `$ISSUE_STATE` are now properly quoted as individual array elements (`ARGS+=(--since "$SINCE")`, `ARGS+=(--state "$ISSUE_STATE")`), and the command uses `"${ARGS[@]}"` for safe expansion.
3. 'Run aptu PR review' step (line 360): Same bash array fix. `$REPO_PATH` and `$INSTRUCTIONS_FILE` are now properly quoted as individual array elements, and the command uses `"${ARGS[@]}"` for safe expansion.

