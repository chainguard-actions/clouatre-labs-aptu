<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.12.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.12.3** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): A ${{ ... }} expression is directly interpolated inside a `run:` shell command string in the 'Roll up anonymized review-context telemetry' step. The run: value is: `"${{ github.action_path }}/scripts/telemetry-rollup.sh \"$APTU_CONTEXT_FILE\" \"$TELEMETRY_ROLLUP_PATH\" || true"`. Per the check rules, any ${{ ... }} expression directly inside a run: shell string is a script-injection finding — the YAML template substitution occurs before the shell ever sees the string, meaning a malicious value could alter the command. The fix is to use the $GITHUB_ACTION_PATH environment variable instead: `run: "$GITHUB_ACTION_PATH/scripts/telemetry-rollup.sh ..."`.

Locations:

- `action.yml:490`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed script-injection in the 'Roll up anonymized review-context telemetry' step in action.yml. Replaced `${{ github.action_path }}` in the `run:` shell command with `$GITHUB_ACTION_PATH` — the standard GitHub Actions environment variable that holds the same value. This eliminates the YAML template substitution before shell execution, preventing potential script injection.

