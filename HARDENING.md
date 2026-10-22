<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.14.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.14.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): the 'Roll up anonymized review-context telemetry' step puts a GitHub Actions expression directly in its run: string: `run: "${{ github.action_path }}/scripts/telemetry-rollup.sh \"$APTU_CONTEXT_FILE\" \"$TELEMETRY_ROLLUP_PATH\" || true"`. The template is filled in before the shell parses the command. Fix: pass it through env (ACTION_PATH: ${{ github.action_path }}) and call "$ACTION_PATH/scripts/telemetry-rollup.sh". You can also use the existing $GITHUB_ACTION_PATH variable.

Locations:

- `action.yml:559`

### github-env-injection (severity: high)

The 'Setup PATH' step writes an inherited process env var to $GITHUB_PATH without sanitizing it: `echo "$HOME/.local/bin" >> "$GITHUB_PATH"`. The script never sets HOME, and a composite action inherits it from the calling workflow, which can override it. The value is written without the required `printf '%s' ... | tr -d '\n\r'` step.

Locations:

- `action.yml:306`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed both findings in action.yml:

- script-injection: The telemetry rollup step now gets github.action_path through a new env var, ACTION_PATH. The run line calls "$ACTION_PATH/scripts/telemetry-rollup.sh" with the path quoted and passes the same arguments as before.
- github-env-injection: In the Setup PATH step, newline and carriage-return characters are now removed from $HOME/.local/bin (with printf and tr -d '\n\r') before it is written to $GITHUB_PATH.

I haven't run the action or its tests since making these edits.

