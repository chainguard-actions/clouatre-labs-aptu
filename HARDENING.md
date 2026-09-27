<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.5** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Install aptu binary' step directly interpolates `${{ steps.resolve-version.outputs.version }}` inside a `run:` shell script: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`.

Any `${{ ... }}` expression is substituted by the Actions runner before the shell ever sees the script, meaning a maliciously crafted value (e.g. containing `$(...)`, backticks, or semicolons) would be executed as shell code. The value should instead be passed via an `env:` variable and referenced as `"$APTU_VERSION"` (which it already is — but the initial assignment still uses direct interpolation, creating the injection window).

Locations:

- `action.yml:232`

### script-injection (severity: high)

Sub-rule (b): Multiple `run:` steps build a `$ARGS` string by appending unquoted user-controlled env vars, then pass `$ARGS` unquoted to shell commands. Affected patterns:

- 'Run aptu PR review': `ARGS="$ARGS --repo-path $REPO_PATH"` (REPO_PATH from inputs.repo-path) and `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"` (INSTRUCTIONS_FILE from inputs.instructions-file), then `aptu pr review $ARGS "$PR_REF"` — $ARGS is unquoted.
- 'Run aptu issue triage (scheduled batch)': `ARGS="$ARGS --since $SINCE"` (SINCE from inputs.since) and `ARGS="$ARGS --state $ISSUE_STATE"` (ISSUE_STATE from inputs.issue-state), then `aptu issue triage $ARGS` — $ARGS is unquoted.
- 'Run aptu issue triage' and 'Run aptu PR label': `aptu issue triage $ARGS "$ISSUE_REF"` and `aptu pr label $ARGS "$PR_REF"` — $ARGS is unquoted.

Unquoted `$ARGS` allows the shell to word-split and glob-expand the value, and if any user-controlled input embedded in ARGS contains shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.), it enables command injection. All user-controlled values appended to ARGS should be double-quoted at the point of appending (e.g. `ARGS="$ARGS --repo-path \"$REPO_PATH\""`), and $ARGS should be replaced with an array (`ARGS=(); ARGS+=(--repo-path "$REPO_PATH")`) to avoid word-splitting.

Locations:

- `action.yml:316`
- `action.yml:319`
- `action.yml:322`
- `action.yml:338`
- `action.yml:341`
- `action.yml:344`
- `action.yml:347`
- `action.yml:350`
- `action.yml:353`
- `action.yml:356`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in action.yml:

1. 'Install aptu binary' step (line 232): Moved `${{ steps.resolve-version.outputs.version }}` from the inline run script into the step's env block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`, then referenced it as `$APTU_VERSION` in the shell script. This eliminates the direct expression interpolation injection window.

2. All four 'Run aptu ...' steps (lines 316-356): Converted string-based ARGS accumulation (`ARGS="$ARGS --flag $VALUE"`) to bash array-based accumulation (`ARGS=(); ARGS+=("--flag" "$VALUE")`). Final command invocations now use `"${ARGS[@]}"` (properly quoted array expansion) instead of unquoted `$ARGS`. This prevents word-splitting/glob-expansion of user-controlled values (REPO_PATH, INSTRUCTIONS_FILE, SINCE, ISSUE_STATE) and ensures each argument remains a separate, properly quoted token. Affected steps: 'Run aptu issue triage', 'Run aptu issue triage (scheduled batch)', 'Run aptu PR label', 'Run aptu PR review'.

