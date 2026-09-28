<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.6** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): The 'Install aptu binary' step directly interpolates `${{ steps.resolve-version.outputs.version }}` inside a `run:` shell script: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`. The `steps.*.outputs.*` context flows through YAML template substitution before the shell processes it, enabling script injection if the output value contains shell metacharacters.

Locations:

- `action.yml:230`

### script-injection (severity: high)

Rule (b): The 'Run aptu issue triage (scheduled batch)' step builds $ARGS with unquoted input-derived variables: `ARGS="$ARGS --since $SINCE"` and `ARGS="$ARGS --state $ISSUE_STATE"`, where $SINCE and $ISSUE_STATE come from inputs.since and inputs.issue-state. The accumulated $ARGS is then passed unquoted to `aptu issue triage $ARGS`, allowing shell metacharacter injection from attacker-controlled input values.

Locations:

- `action.yml:318`
- `action.yml:322`

### script-injection (severity: high)

Rule (b): The 'Run aptu PR review' step builds $ARGS with unquoted input-derived variables: `ARGS="$ARGS --repo-path $REPO_PATH"` and `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"`, where $REPO_PATH and $INSTRUCTIONS_FILE come from inputs.repo-path and inputs.instructions-file. The accumulated $ARGS is then passed unquoted to `aptu pr review $ARGS "$PR_REF"`, allowing shell metacharacter injection from attacker-controlled input values.

Locations:

- `action.yml:381`
- `action.yml:387`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed all three script-injection findings in hardened/action/action.yml:

1. 'Install aptu binary' step (line 230): Moved `${{ steps.resolve-version.outputs.version }}` from the run: script into the env: block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`, referencing it as `$APTU_VERSION` in the shell script.

2. 'Run aptu issue triage (scheduled batch)' step (lines 318, 322): Replaced string-based ARGS accumulation with a bash array. Changed `ARGS="$ARGS --since $SINCE"` to `ARGS+=(--since "$SINCE")` and `ARGS="$ARGS --state $ISSUE_STATE"` to `ARGS+=(--state "$ISSUE_STATE")`. Command invocation changed from `aptu issue triage $ARGS` to `aptu issue triage "${ARGS[@]}"` to preserve argument boundaries.

3. 'Run aptu PR review' step (lines 381, 387): Same array-based fix. Changed `ARGS="$ARGS --repo-path $REPO_PATH"` to `ARGS+=(--repo-path "$REPO_PATH")` and `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"` to `ARGS+=(--instructions-file "$INSTRUCTIONS_FILE")`. Command invocation changed from `aptu pr review $ARGS "$PR_REF"` to `aptu pr review "${ARGS[@]}" "$PR_REF"`.

