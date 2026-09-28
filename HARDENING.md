<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.5** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Install aptu binary' step directly interpolates `${{ steps.resolve-version.outputs.version }}` inside the run: shell script body (`APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`). Any `${{ ... }}` expression inside a run: block is a script-injection risk because YAML template substitution occurs before the shell processes the string, allowing injected content to be interpreted as shell commands. This should be passed via an env: variable instead.

Locations:

- `action.yml:260`

### script-injection (severity: high)

Sub-rule (b): Multiple run: blocks construct an $ARGS string by appending unquoted workflow-controllable env vars, then pass $ARGS unquoted to shell commands. Unquoted variable expansion allows shell metacharacters (`;`, `|`, `&`, `$(...)`, whitespace, globs) in attacker-controlled inputs to be interpreted by the shell.

- 'Run aptu issue triage': `ARGS="$ARGS --dry-run"` etc., then `aptu issue triage $ARGS "$ISSUE_REF"` (unquoted $ARGS)
- 'Run aptu issue triage (scheduled batch)': `ARGS="--repo $REPO"` (unquoted $REPO in assignment), then `aptu issue triage $ARGS` (unquoted $ARGS)
- 'Run aptu PR label': `aptu pr label $ARGS "$PR_REF"` (unquoted $ARGS)
- 'Run aptu PR review': `ARGS="$ARGS --repo-path $REPO_PATH"` and `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"` (unquoted user-controlled values in string), then `aptu pr review $ARGS "$PR_REF"` (unquoted $ARGS)
- 'Run aptu scan-security': `echo "Running: aptu scan-security --diff $SCAN_DIFF --output sarif"` (unquoted $SCAN_DIFF in echo)

All affected env vars ($REPO_PATH, $INSTRUCTIONS_FILE, $SINCE, $ISSUE_STATE, $REPO) are sourced from inputs.* or github.* contexts and must be double-quoted wherever they are expanded.

Locations:

- `action.yml:307`
- `action.yml:340`
- `action.yml:370`
- `action.yml:415`
- `action.yml:450`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in action.yml:

1. (a) Line 260 - 'Install aptu binary' step: Moved `${{ steps.resolve-version.outputs.version }}` from the run: shell body into the step's env: block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`, eliminating the inline template expression.

2. (b) Multiple steps - Replaced all string-concatenation-based `$ARGS` patterns with bash arrays to prevent word-splitting and shell injection:
   - 'Run aptu issue triage': `ARGS=()` with `ARGS+=(--flag)` pattern, invoked as `"${ARGS[@]}"`
   - 'Run aptu issue triage (scheduled batch)': `ARGS=(--repo "$REPO")` with `"$SINCE"` and `"$ISSUE_STATE"` properly quoted as separate array elements
   - 'Run aptu PR label': `ARGS=()` array pattern
   - 'Run aptu PR review': `ARGS=(--comment --force)` with `"$REPO_PATH"` and `"$INSTRUCTIONS_FILE"` properly quoted as separate array elements
   - 'Run aptu scan-security': Quoted `$SCAN_DIFF` in the echo statement

