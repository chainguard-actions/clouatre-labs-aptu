<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.12.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.12.5** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Roll up anonymized review-context telemetry' step interpolates `${{ github.action_path }}` directly inside the `run:` shell command string: `run: "${{ github.action_path }}/scripts/telemetry-rollup.sh ..."`. Any `${{ ... }}` expression directly inside a run: script is a script-injection finding. Fix: set an env var (e.g. `ACTION_PATH: ${{ github.action_path }}`) and reference `"$ACTION_PATH"` in the run script instead.

Locations:

- `action.yml:556`

### script-injection (severity: high)

Sub-rule (b): The 'Run aptu lint-issue' step expands `$LINT_ISSUE_FILE` and `$LINT_ISSUE_TYPE` unquoted inside the run: script: `echo "Running: aptu lint-issue --file $LINT_ISSUE_FILE --issue-type $LINT_ISSUE_TYPE --output github-annotations"`. Both variables are sourced from `inputs.*` (workflow-controllable), so unquoted expansion allows shell metacharacter injection. Fix: quote the expansions: `"$LINT_ISSUE_FILE"` and `"$LINT_ISSUE_TYPE"`.

Locations:

- `action.yml:492`

### script-injection (severity: high)

Sub-rule (b): The 'Run aptu scan-security' step expands `$SCAN_DIFF` and `$SCAN_PATH` unquoted inside the run: script in the echo/logging lines: `echo "Running: aptu scan-security --diff $SCAN_DIFF ..."` and `echo "Running: aptu scan-security $SCAN_PATH ..."`. Both variables are sourced from `inputs.*` (workflow-controllable), so unquoted expansion allows shell metacharacter injection. Fix: quote the expansions: `"$SCAN_DIFF"` and `"$SCAN_PATH"`.

Locations:

- `action.yml:461`
- `action.yml:464`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed three script-injection findings in hardened/action/action.yml:
1. 'Run aptu scan-security' step (lines ~461/464): Quoted $SCAN_DIFF and $SCAN_PATH in the echo/logging lines using escaped double-quotes (\"$SCAN_DIFF\" and \"$SCAN_PATH\") to prevent shell metacharacter injection.
2. 'Run aptu lint-issue' step (line ~492): Quoted $LINT_ISSUE_FILE and $LINT_ISSUE_TYPE in the echo line using escaped double-quotes to prevent shell metacharacter injection.
3. 'Roll up anonymized review-context telemetry' step (line ~556): Moved ${{ github.action_path }} out of the run: shell string into an env var ACTION_PATH, and replaced the inline expression with $ACTION_PATH in the run script.

