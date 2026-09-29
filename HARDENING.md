<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.6** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): In the 'Install aptu binary' step, the expression `${{ steps.resolve-version.outputs.version }}` is directly interpolated inside the `run:` shell script: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`. The `steps.*.outputs.*` context is workflow-controllable and must not be embedded directly in shell commands — it should be passed via an `env:` variable and then double-quoted in the script.

Locations:

- `action.yml:233`

### script-injection (severity: high)

Rule (b): Multiple `run:` steps build an `$ARGS` string from `inputs.*`-sourced env vars (e.g. `$DRY_RUN`, `$APPLY_LABELS`, `$NO_COMMENT`, `$REPO_PATH`, `$INSTRUCTIONS_FILE`) and then invoke `aptu ... $ARGS` with `$ARGS` unquoted, allowing shell metacharacter injection. Additionally, the scheduled batch triage step uses `ARGS="--repo $REPO"` with `$REPO` (from `github.repository`) unquoted. Offending lines include: `aptu issue triage $ARGS "$ISSUE_REF"`, `aptu issue triage $ARGS`, `aptu pr label $ARGS "$PR_REF"`, `aptu pr review $ARGS "$PR_REF"`.

Locations:

- `action.yml:286`
- `action.yml:316`
- `action.yml:340`
- `action.yml:390`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in action.yml:

1. 'Install aptu binary' step (line 233): Moved `${{ steps.resolve-version.outputs.version }}` from inline shell interpolation to the step's `env:` block as `APTU_VERSION`. Removed the inline `APTU_VERSION="${{ ... }}"` assignment from the run script.

2. Four steps using unquoted `$ARGS` string expansion (lines 286, 316, 340, 390): Converted all four steps ('Run aptu issue triage', 'Run aptu issue triage (scheduled batch)', 'Run aptu PR label', 'Run aptu PR review') from string-based ARGS building to bash arrays. Each flag is now appended as a separate array element (e.g., `ARGS+=(--dry-run)`, `ARGS+=(--repo "$REPO")`), and commands use `"${ARGS[@]}"` for safe, properly-quoted expansion. This prevents shell metacharacter injection from workflow-controllable values like `$REPO`, `$SINCE`, `$ISSUE_STATE`, `$REPO_PATH`, and `$INSTRUCTIONS_FILE`.

