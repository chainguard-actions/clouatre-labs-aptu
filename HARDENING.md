<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.5** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): In the 'Install aptu binary' step, the expression `${{ steps.resolve-version.outputs.version }}` is interpolated directly inside a `run:` shell block: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`  This injects the `steps.*.outputs.*` context value through YAML template substitution before the shell ever sees it. A compromised or manipulated step output could inject arbitrary shell commands. The value should instead be passed via an `env:` variable and referenced as `"$APTU_VERSION"` (which it already is set to, but the initial assignment itself is the injection point).

Locations:

- `action.yml:244`

### script-injection (severity: high)

Sub-rule (b): Multiple `run:` blocks expand the `$ARGS` shell variable unquoted when invoking `aptu` commands. `$ARGS` is built by appending values sourced from `inputs.*` context variables (e.g. `$SINCE`, `$ISSUE_STATE`, `$REPO_PATH`, `$INSTRUCTIONS_FILE`). Unquoted expansion allows shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) embedded in those inputs to be interpreted by the shell. Affected commands:
- `aptu issue triage $ARGS "$ISSUE_REF"` (Run aptu issue triage step)
- `aptu issue triage $ARGS` (Run aptu issue triage scheduled batch step)
- `aptu pr label $ARGS "$PR_REF"` (Run aptu PR label step)
- `aptu pr review $ARGS "$PR_REF"` (Run aptu PR review step)
All occurrences of `$ARGS` in these final command invocations must be double-quoted: `"$ARGS"` or the argument list must be built as a proper array.

Locations:

- `action.yml:296`
- `action.yml:323`
- `action.yml:349`
- `action.yml:393`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in hardened/action/action.yml:

1. 'Install aptu binary' step (line 244): Moved `${{ steps.resolve-version.outputs.version }}` from the `run:` shell block into the step's `env:` block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`. The shell script now references `$APTU_VERSION` as a plain environment variable.

2. Four `aptu` command invocations (lines 296, 323, 349, 393): Converted the `$ARGS` string variable to a bash array `ARGS=()` in all four affected steps. Flags are appended with `ARGS+=(--flag)` or `ARGS+=(--flag "$VALUE")`, and the final commands use `"${ARGS[@]}"` to properly quote each element as a separate argument, preventing shell metacharacter injection while preserving correct argument boundaries.

