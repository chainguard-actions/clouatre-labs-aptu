<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.4** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): A ${{ }} expression is directly interpolated inside a run: shell command string. In the 'Install aptu binary' step, the line `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"` injects the steps context value directly into the shell script via YAML template substitution before the shell executes it. Although steps.*.outputs.* is not directly attacker-controlled, any ${{ }} expression inside a run: block is a script-injection finding per the check rules.

Locations:

- `action.yml:218`

### script-injection (severity: high)

Rule (b): Multiple run: blocks accumulate CLI flags into an unquoted `$ARGS` shell variable that is then expanded unquoted when invoking aptu commands. The ARGS variable is built from user-controlled inputs (e.g., $SINCE from inputs.since, $ISSUE_STATE from inputs.issue-state, $REPO_PATH from inputs.repo-path, $INSTRUCTIONS_FILE from inputs.instructions-file) which are workflow-controllable. Unquoted expansion of $ARGS allows shell metacharacter injection (semicolons, pipes, backticks, etc.).

Affected commands:
- `aptu issue triage $ARGS "$ISSUE_REF"` (Run aptu issue triage step)
- `aptu issue triage $ARGS` (Run aptu issue triage scheduled batch step)
- `aptu pr label $ARGS "$PR_REF"` (Run aptu PR label step)
- `aptu pr review $ARGS "$PR_REF"` (Run aptu PR review step)

Locations:

- `action.yml:270`
- `action.yml:302`
- `action.yml:330`
- `action.yml:380`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in hardened/action/action.yml:

1. Line 218 ('Install aptu binary' step): Moved `${{ steps.resolve-version.outputs.version }}` out of the `run:` block and into the `env:` block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`. The shell script now references `$APTU_VERSION` as a plain environment variable.

2. Lines 270, 302, 330, 380 (four aptu command steps): Replaced string-concatenated `ARGS=""` / `ARGS="$ARGS --flag"` patterns with bash arrays (`ARGS=()` / `ARGS+=(--flag)` / `ARGS+=(--flag "$VALUE")`). Final invocations use `"${ARGS[@]}"` to properly quote each argument, preventing shell metacharacter injection from user-controlled inputs (since, issue-state, repo-path, instructions-file). The four affected steps are: 'Run aptu issue triage', 'Run aptu issue triage (scheduled batch)', 'Run aptu PR label', and 'Run aptu PR review'.

