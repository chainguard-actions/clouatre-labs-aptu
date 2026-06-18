<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **clouatre-labs--aptu/v0.8.5** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): A ${{ }} expression is interpolated directly inside a run: shell script in the 'Install aptu binary' step. The line `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"` embeds a GitHub Actions expression directly into the shell command string before the shell ever sees it, allowing template substitution to inject arbitrary content into the script.

Locations:

- `action.yml:232`

### script-injection (severity: high)

Rule (b): Multiple run: blocks build an $ARGS string from user-controlled inputs (inputs.repo-path → $REPO_PATH, inputs.instructions-file → $INSTRUCTIONS_FILE, inputs.since → $SINCE, inputs.issue-state → $ISSUE_STATE, inputs.dry-run → $DRY_RUN, etc.) and then expand $ARGS unquoted in shell commands. Unquoted expansion allows shell metacharacters in any of these input values to be interpreted by the shell. Affected commands include: `aptu issue triage $ARGS "$ISSUE_REF"` (issue triage step), `aptu issue triage $ARGS` (scheduled batch step), `aptu pr label $ARGS "$PR_REF"` (PR label step), and `aptu pr review $ARGS "$PR_REF"` (PR review step). Additionally, `--repo-path $REPO_PATH` and `--instructions-file $INSTRUCTIONS_FILE` are appended to $ARGS unquoted before the final command.

Locations:

- `action.yml:284`
- `action.yml:322`
- `action.yml:362`
- `action.yml:415`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in action.yml:

1. 'Install aptu binary' step (line 232): Moved `${{ steps.resolve-version.outputs.version }}` from the run: shell body into the step's env: block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`. The shell script now uses the plain env var `$APTU_VERSION`.

2. Four run: blocks (lines 284, 322, 362, 415) that built an `$ARGS` string and expanded it unquoted were converted to use bash arrays. Each step now uses `ARGS=()` and appends flags with `ARGS+=(--flag)` or `ARGS+=(--flag "$VALUE")`, then invokes the command with `"${ARGS[@]}"`. This prevents shell metacharacters in user-controlled inputs (repo-path, instructions-file, since, issue-state, dry-run, etc.) from being interpreted by the shell. The PR review step also fixed the previously unquoted `--repo-path $REPO_PATH` and `--instructions-file $INSTRUCTIONS_FILE` appended to the args string.

