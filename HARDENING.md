<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.4** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Install aptu binary' run: block directly interpolates a ${{ }} expression inside the shell script: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`  Any ${{ ... }} expression inside a run: block is substituted by the YAML template engine before the shell sees it, bypassing all shell quoting. If the step output contains shell metacharacters (e.g. injected via a compromised upstream step), they will be executed by the shell.

Locations:

- `action.yml:232`

### script-injection (severity: high)

Sub-rule (b): Multiple run: blocks build an $ARGS string by appending unquoted env vars sourced from inputs.* (e.g. `ARGS="$ARGS --since $SINCE"` where SINCE=${{ inputs.since }}, `ARGS="$ARGS --state $ISSUE_STATE"` where ISSUE_STATE=${{ inputs.issue-state }}, `ARGS="$ARGS --repo-path $REPO_PATH"` where REPO_PATH=${{ inputs.repo-path }}, `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"` where INSTRUCTIONS_FILE=${{ inputs.instructions-file }}), then pass $ARGS unquoted to the CLI (e.g. `aptu issue triage $ARGS "$ISSUE_REF"`, `aptu pr review $ARGS "$PR_REF"`). An attacker-controlled input value containing shell metacharacters (`;`, `|`, `&`, `$(...)`) will be word-split and executed by the shell.

Locations:

- `action.yml:290`
- `action.yml:325`
- `action.yml:400`
- `action.yml:415`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in hardened/action/action.yml:

1. Line 232 (Install aptu binary step): Moved `${{ steps.resolve-version.outputs.version }}` from the run: block into the env: block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`. The shell script now uses `$APTU_VERSION` as a regular environment variable.

2. Lines 290, 325, 400, 415 (four run: blocks): Converted all ARGS string concatenation patterns to bash arrays. User-controlled inputs (SINCE, ISSUE_STATE, REPO_PATH, INSTRUCTIONS_FILE) are now properly quoted as individual array elements (e.g., `ARGS+=(--since "$SINCE")`), and commands use `"${ARGS[@]}"` for safe array expansion. This prevents shell metacharacters in input values from being executed.

