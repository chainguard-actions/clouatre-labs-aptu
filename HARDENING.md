<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.6** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Install aptu binary' step directly interpolates `${{ steps.resolve-version.outputs.version }}` inside a `run:` shell command string. The `steps.*.outputs.*` context is workflow-controllable and flows through YAML template substitution before the shell parses it, enabling script injection. The offending line is: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`

Locations:

- `action.yml:232`

### script-injection (severity: high)

Sub-rule (b): Multiple steps build a `$ARGS` shell variable by appending unquoted values sourced from workflow-controllable inputs (`$SINCE` from inputs.since, `$ISSUE_STATE` from inputs.issue-state, `$REPO_PATH` from inputs.repo-path, `$INSTRUCTIONS_FILE` from inputs.instructions-file), then invoke commands with the unquoted `$ARGS` variable (e.g. `aptu issue triage $ARGS`, `aptu pr review $ARGS`). An attacker-controlled input containing shell metacharacters (`;`, `|`, `&`, `$(...)`) would be word-split and executed by the shell. Affected steps: 'Run aptu issue triage', 'Run aptu issue triage (scheduled batch)', 'Run aptu PR label', 'Run aptu PR review'.

Locations:

- `action.yml:302`
- `action.yml:340`
- `action.yml:374`
- `action.yml:430`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in hardened/action/action.yml:

1. Line 232 ('Install aptu binary' step): Moved `${{ steps.resolve-version.outputs.version }}` from the inline run: shell string into the step's env: block as `APTU_VERSION`. The shell script now references `$APTU_VERSION` as a plain environment variable, preventing YAML template substitution from injecting attacker-controlled content directly into the shell command.

2. Lines 302, 340, 374, 430 (four 'Run aptu ...' steps): Replaced the unquoted string-based `$ARGS` pattern with bash arrays (`ARGS=()`, `ARGS+=(--flag)`, `"${ARGS[@]}"`). User-controlled inputs ($SINCE, $ISSUE_STATE, $REPO_PATH, $INSTRUCTIONS_FILE) are now properly quoted as individual array elements, preventing shell metacharacters from being interpreted as shell commands.

