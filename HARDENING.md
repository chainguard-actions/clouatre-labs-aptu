<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.6** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): A `${{ }}` expression is directly interpolated inside a `run:` shell script in the "Install aptu binary" step. The line `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"` injects a `steps.*.outputs.*` context value directly into the shell before the shell ever sees it, bypassing any quoting. An attacker who can influence the step output (e.g. via a compromised release API response) could inject shell metacharacters.

Sub-rule (b): Multiple unquoted shell variable expansions of workflow-controllable data appear across several steps:
- In "Run aptu issue triage": `aptu issue triage $ARGS "$ISSUE_REF"` — `$ARGS` is unquoted and built from `$REPO` (`github.repository`), which is itself unquoted in `ARGS="--repo $REPO"`.
- In "Run aptu issue triage (scheduled batch)": `ARGS="--repo $REPO"` (unquoted `$REPO` from `github.repository`), `ARGS="$ARGS --since $SINCE"` (unquoted `$SINCE` from `inputs.since`), `ARGS="$ARGS --state $ISSUE_STATE"` (unquoted `$ISSUE_STATE` from `inputs.issue-state`), and final `aptu issue triage $ARGS` (unquoted `$ARGS`).
- In "Run aptu PR label": `aptu pr label $ARGS "$PR_REF"` — `$ARGS` unquoted.
- In "Run aptu PR review": `ARGS="$ARGS --repo-path $REPO_PATH"` (unquoted `$REPO_PATH` from `inputs.repo-path`), `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"` (unquoted `$INSTRUCTIONS_FILE` from `inputs.instructions-file`), and final `aptu pr review $ARGS "$PR_REF"` (unquoted `$ARGS`).
All these allow shell word-splitting and glob expansion on attacker-controlled values.

Locations:

- `action.yml:230`
- `action.yml:296`
- `action.yml:316`
- `action.yml:322`
- `action.yml:330`
- `action.yml:334`
- `action.yml:338`
- `action.yml:356`
- `action.yml:380`
- `action.yml:386`
- `action.yml:390`
- `action.yml:394`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed all script injection issues in action.yml:
1. Moved `${{ steps.resolve-version.outputs.version }}` from inside the 'Install aptu binary' run: script to the step's env: block as `APTU_VERSION`.
2. Replaced string-based ARGS building (unquoted `$ARGS` expansions) with bash arrays in four steps: 'Run aptu issue triage', 'Run aptu issue triage (scheduled batch)', 'Run aptu PR label', and 'Run aptu PR review'. Each flag and its value are now separate quoted array elements, preventing word-splitting and glob expansion on attacker-controlled values like `$REPO`, `$SINCE`, `$ISSUE_STATE`, `$REPO_PATH`, and `$INSTRUCTIONS_FILE`.

