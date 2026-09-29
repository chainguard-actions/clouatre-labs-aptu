<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.5** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Install aptu binary' step interpolates `${{ steps.resolve-version.outputs.version }}` directly inside a `run:` shell script block. The expression `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"` is expanded by the GitHub Actions template engine before the shell sees it, allowing any newlines or shell metacharacters in the value to be interpreted by bash. The value should be passed via an `env:` variable and referenced as `"$APTU_VERSION"` instead.

Locations:

- `action.yml:228`

### script-injection (severity: high)

Sub-rule (b): Multiple steps build a `$ARGS` shell variable from user-controlled inputs (SINCE from `inputs.since`, ISSUE_STATE from `inputs.issue-state`, REPO_PATH from `inputs.repo-path`, INSTRUCTIONS_FILE from `inputs.instructions-file`, REPO from `github.repository`) and then invoke the `aptu` binary with `$ARGS` unquoted (e.g. `aptu issue triage $ARGS "$ISSUE_REF"`, `aptu pr review $ARGS "$PR_REF"`). An unquoted `$ARGS` allows the shell to word-split and glob-expand the value, enabling injection of shell metacharacters. All final command invocations using `$ARGS` should use `"$ARGS"` or, better, an array (`ARGS=(); ARGS+=(--flag); aptu ... "${ARGS[@]}"`).

Locations:

- `action.yml:295`
- `action.yml:330`
- `action.yml:363`
- `action.yml:406`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in hardened/action/action.yml:

1. 'Install aptu binary' step (line 228): Moved `${{ steps.resolve-version.outputs.version }}` out of the `run:` shell block and into the step's `env:` block as `APTU_VERSION`. The shell script now references `$APTU_VERSION` as a plain environment variable.

2. Four command invocation steps (lines 295, 330, 363, 406): Converted all `ARGS` string variables to bash arrays (`ARGS=()`/`ARGS+=(...)`). All final `aptu` command invocations now use `"${ARGS[@]}"` instead of unquoted `$ARGS`, preventing word-splitting and glob-expansion. Individual argument values like `$REPO`, `$SINCE`, `$ISSUE_STATE`, `$REPO_PATH`, and `$INSTRUCTIONS_FILE` are now properly double-quoted when appended to the array.

