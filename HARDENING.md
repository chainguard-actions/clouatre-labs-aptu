<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **clouatre-labs--aptu/v0.8.4** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Install aptu binary' step directly interpolates `${{ steps.resolve-version.outputs.version }}` inside the `run:` shell script: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`. The `steps.*.outputs.*` context is substituted by the YAML template engine before the shell ever sees it, allowing a compromised or attacker-influenced step output to inject arbitrary shell commands.

Locations:

- `action.yml:213`

### script-injection (severity: high)

Sub-rule (b): The 'Run aptu issue triage (scheduled batch)' step appends user-controlled env vars unquoted into `$ARGS`: `ARGS="$ARGS --since $SINCE"` and `ARGS="$ARGS --state $ISSUE_STATE"` (where `$SINCE` and `$ISSUE_STATE` come from `inputs.since` and `inputs.issue-state`), then invokes `aptu issue triage $ARGS` with `$ARGS` unquoted. An attacker-supplied input containing shell metacharacters (`;`, `|`, `$(...)`, etc.) can break out of the argument and execute arbitrary commands.

Locations:

- `action.yml:299`

### script-injection (severity: high)

Sub-rule (b): The 'Run aptu PR review' step appends user-controlled env vars unquoted into `$ARGS`: `ARGS="$ARGS --repo-path $REPO_PATH"` and `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"` (where `$REPO_PATH` and `$INSTRUCTIONS_FILE` come from `inputs.repo-path` and `inputs.instructions-file`), then invokes `aptu pr review $ARGS "$PR_REF"` with `$ARGS` unquoted. An attacker-supplied input containing shell metacharacters can inject arbitrary commands.

Locations:

- `action.yml:367`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed all three script injection findings in action.yml: (1) 'Install aptu binary' step: moved `${{ steps.resolve-version.outputs.version }}` from inline in the run script to the env block as `APTU_VERSION`, eliminating the template injection vector. (2) 'Run aptu issue triage (scheduled batch)' step: replaced unquoted string-based $ARGS concatenation (with user-controlled $SINCE and $ISSUE_STATE) with a bash array, using ARGS+=(--since "$SINCE") and ARGS+=(--state "$ISSUE_STATE"), invoked with aptu issue triage "${ARGS[@]}". (3) 'Run aptu PR review' step: replaced unquoted string-based $ARGS concatenation (with user-controlled $REPO_PATH and $INSTRUCTIONS_FILE) with a bash array, using ARGS+=(--repo-path "$REPO_PATH") and ARGS+=(--instructions-file "$INSTRUCTIONS_FILE"), invoked with aptu pr review "${ARGS[@]}" "$PR_REF".

