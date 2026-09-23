<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.12.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.12.1** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Roll up anonymized review-context telemetry' step directly interpolates `${{ github.action_path }}` inside the `run:` shell command string. Any `${{ ... }}` expression embedded directly in a `run:` block is a script-injection risk because the value is substituted by the YAML template engine before the shell ever sees it, bypassing shell quoting. The offending line is: `run: "${{ github.action_path }}/scripts/telemetry-rollup.sh \"$APTU_CONTEXT_FILE\" \"$TELEMETRY_ROLLUP_PATH\" || true"`. The fix is to use the `$GITHUB_ACTION_PATH` environment variable instead: `run: "$GITHUB_ACTION_PATH/scripts/telemetry-rollup.sh ..."`, which is already available as a safe env var in composite actions.

Locations:

- `action.yml:490`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script-injection vulnerability in the 'Roll up anonymized review-context telemetry' step (action.yml line 490). Replaced `${{ github.action_path }}/scripts/telemetry-rollup.sh` with `$GITHUB_ACTION_PATH/scripts/telemetry-rollup.sh`. The `$GITHUB_ACTION_PATH` environment variable is automatically set by GitHub Actions for composite actions and is the safe alternative to the template expression, which was being substituted by the YAML engine before the shell could apply any quoting.

