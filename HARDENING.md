<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.3** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Install aptu binary' run block directly interpolates a ${{ }} expression inside the shell script: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`. Any ${{ ... }} expression directly inside a run: block is a script-injection risk because the value is substituted by the template engine before the shell ever sees it, bypassing shell quoting. The value should instead be passed via an env: variable and referenced as `"$APTU_VERSION"` (which it already is for the env: block in other steps).

Locations:

- `action.yml:258`

### script-injection (severity: high)

Sub-rule (b): The 'Run aptu issue triage (scheduled batch)' step builds $ARGS by appending unquoted user-controlled values and then passes $ARGS unquoted to the shell command. Specifically: `ARGS="--repo $REPO"` (REPO from github.repository), `ARGS="$ARGS --since $SINCE"` (SINCE from inputs.since), `ARGS="$ARGS --state $ISSUE_STATE"` (ISSUE_STATE from inputs.issue-state), and finally `aptu issue triage $ARGS` with $ARGS unquoted. An attacker-controlled value containing shell metacharacters (spaces, semicolons, backticks, etc.) in inputs.since or inputs.issue-state would be word-split by the shell, enabling command injection. These values must be double-quoted when appended and when used.

Locations:

- `action.yml:345`
- `action.yml:347`
- `action.yml:350`
- `action.yml:352`

### script-injection (severity: high)

Sub-rule (b): The 'Run aptu PR review' step builds $ARGS by appending unquoted user-controlled values and then passes $ARGS unquoted to the shell command. Specifically: `ARGS="$ARGS --repo-path $REPO_PATH"` (REPO_PATH from inputs.repo-path) and `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"` (INSTRUCTIONS_FILE from inputs.instructions-file), followed by `aptu pr review $ARGS "$PR_REF"` with $ARGS unquoted. An attacker-controlled path value containing shell metacharacters would be word-split by the shell, enabling command injection. These values must be double-quoted when appended and when used.

Locations:

- `action.yml:415`
- `action.yml:420`
- `action.yml:422`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed all three script-injection findings in hardened/action/action.yml:
1. 'Install aptu binary' step (line 258): Moved `${{ steps.resolve-version.outputs.version }}` from inside the run block to the env block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`, removing the inline template expression from the shell script.
2. 'Run aptu issue triage (scheduled batch)' step (lines 345-352): Converted ARGS from a string variable to a bash array (`ARGS=("--repo" "$REPO")`), using `ARGS+=("--since" "$SINCE")` and `ARGS+=("--state" "$ISSUE_STATE")` to properly quote user-controlled values as separate array elements, and changed the command invocation to `aptu issue triage "${ARGS[@]}"`.
3. 'Run aptu PR review' step (lines 415-422): Converted ARGS from a string variable to a bash array (`ARGS=("--comment" "--force")`), using `ARGS+=("--repo-path" "$REPO_PATH")` and `ARGS+=("--instructions-file" "$INSTRUCTIONS_FILE")` to properly quote user-controlled path values as separate array elements, and changed the command invocation to `aptu pr review "${ARGS[@]}" "$PR_REF"`.

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in hardened/action/action.yml:
1. 'Run aptu issue triage' step: Changed ARGS from a string variable to a bash array. Flags are now appended with ARGS+=("--flag") and the command uses "${ARGS[@]}" instead of unquoted $ARGS.
2. 'Run aptu PR label' step: Same fix — ARGS converted to array, expanded safely with "${ARGS[@]}".
Both steps now match the pattern already used by the 'Run aptu issue triage (scheduled batch)' step, which was already correct.

