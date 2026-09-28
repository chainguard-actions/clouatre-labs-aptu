<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.3** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): In the 'Install aptu binary' step, the expression `${{ steps.resolve-version.outputs.version }}` is directly interpolated inside the `run:` shell script: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`. Any `${{ ... }}` expression inside a `run:` block is a script-injection risk because the value is substituted by the YAML template engine before the shell ever sees it, allowing special characters to break out of the intended context.

Locations:

- `action.yml:218`

### script-injection (severity: high)

Rule (b): Multiple `run:` blocks build a `$ARGS` string from env vars sourced from `inputs.*` and `github.*` contexts (e.g. `REPO_PATH`, `INSTRUCTIONS_FILE`, `SINCE`, `ISSUE_STATE`, `REPO`) without quoting those values when appending to `$ARGS`, and then pass `$ARGS` unquoted to the shell command. Unquoted variable expansions allow shell metacharacters (`;`, `|`, `&`, `$(...)`, whitespace, globs) in attacker-controlled input to be interpreted by the shell.

Affected lines include:
- `ARGS="--repo $REPO"` (scheduled batch step) — `$REPO` from `github.repository` unquoted
- `ARGS="$ARGS --since $SINCE"` — `$SINCE` from `inputs.since` unquoted
- `ARGS="$ARGS --state $ISSUE_STATE"` — `$ISSUE_STATE` from `inputs.issue-state` unquoted
- `ARGS="$ARGS --repo-path $REPO_PATH"` — `$REPO_PATH` from `inputs.repo-path` unquoted
- `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"` — `$INSTRUCTIONS_FILE` from `inputs.instructions-file` unquoted
- `aptu issue triage $ARGS "$ISSUE_REF"` — `$ARGS` itself unquoted in command invocation
- `aptu issue triage $ARGS` — `$ARGS` unquoted
- `aptu pr label $ARGS "$PR_REF"` — `$ARGS` unquoted
- `aptu pr review $ARGS "$PR_REF"` — `$ARGS` unquoted

Locations:

- `action.yml:270`
- `action.yml:305`
- `action.yml:307`
- `action.yml:318`
- `action.yml:340`
- `action.yml:370`
- `action.yml:374`
- `action.yml:380`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in hardened/action/action.yml:

1. Line 218 ('Install aptu binary' step): Moved `${{ steps.resolve-version.outputs.version }}` from inline in the `run:` block to the step's `env:` block as `APTU_VERSION`. The shell script now references `$APTU_VERSION` as a plain environment variable.

2. Multiple lines (ARGS building pattern): Replaced all string-based `$ARGS` concatenation with bash arrays across four steps ('Run aptu issue triage', 'Run aptu issue triage (scheduled batch)', 'Run aptu PR label', 'Run aptu PR review'). User-controlled values like `$REPO`, `$SINCE`, `$ISSUE_STATE`, `$REPO_PATH`, and `$INSTRUCTIONS_FILE` are now properly quoted as individual array elements (e.g., `ARGS+=(--since "$SINCE")`), and commands are invoked with `"${ARGS[@]}"` to preserve argument boundaries and prevent shell metacharacter injection.

