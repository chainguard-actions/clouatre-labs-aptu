<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.7

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.7** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a) violation: The 'Install aptu binary' step directly interpolates `${{ steps.resolve-version.outputs.version }}` inside a `run:` shell command string: `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`.

Per the check rules, `steps.*.outputs.*` is an untrusted-input source, and any `${{ ... }}` expression directly inside a `run:` block is a script injection finding. The GitHub Actions template engine substitutes this value into the shell script before the shell executes it, so a malicious value in that step output could inject arbitrary shell commands.

Fix: move the value into an `env:` variable and reference it as a quoted shell variable:
```yaml
env:
  APTU_VERSION: ${{ steps.resolve-version.outputs.version }}
run: |
  set -euo pipefail
  echo "::group::Installing aptu v$APTU_VERSION"
  ...
```

Locations:

- `action.yml:242`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in the 'Install aptu binary' step of action.yml. Moved `${{ steps.resolve-version.outputs.version }}` from the `run:` shell string into the step's `env:` block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`, and removed the inline shell assignment `APTU_VERSION="${{ ... }}"`. The rest of the script already used `$APTU_VERSION` as a shell variable, so no further changes were needed.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed all four script-injection findings in action.yml by converting string-based $ARGS variable accumulation to bash arrays in each affected step:
1. 'Run aptu issue triage' (line ~329): ARGS="" → ARGS=(), ARGS+=(--flag), aptu issue triage "${ARGS[@]}" "$ISSUE_REF"
2. 'Run aptu issue triage (scheduled batch)' (lines ~356, 359, 371): ARGS="--repo $REPO" → ARGS=(--repo "$REPO"), ARGS+=(--since "$SINCE"), ARGS+=(--state "$ISSUE_STATE"), aptu issue triage "${ARGS[@]}"
3. 'Run aptu PR label' (line ~402): ARGS="" → ARGS=(), ARGS+=(--dry-run), aptu pr label "${ARGS[@]}" "$PR_REF"
4. 'Run aptu PR review' (lines ~448, 454, 458): ARGS="--comment --force" → ARGS=(--comment --force), ARGS+=(--repo-path "$REPO_PATH"), ARGS+=(--instructions-file "$INSTRUCTIONS_FILE"), aptu pr review "${ARGS[@]}" "$PR_REF"

Using "${ARGS[@]}" ensures each element is a separate, properly quoted argument, preventing word splitting and glob expansion on user-controlled values like $SINCE, $ISSUE_STATE, $REPO_PATH, and $INSTRUCTIONS_FILE.

