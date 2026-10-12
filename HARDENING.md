<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.13.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.13.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): The 'Roll up anonymized review-context telemetry' step interpolates `${{ github.action_path }}` directly inside the `run:` shell command string. Any `${{ ... }}` expression directly in a run: block is a script-injection risk because the value is substituted by the YAML template engine before the shell ever sees it, bypassing shell quoting. The offending line is: `run: "${{ github.action_path }}/scripts/telemetry-rollup.sh ..."`. Fix: use the `$GITHUB_ACTION_PATH` environment variable instead (e.g. `run: "$GITHUB_ACTION_PATH/scripts/telemetry-rollup.sh ..."`).

Locations:

- `action.yml:430`

### script-injection (severity: high)

Rule (b): Multiple run: blocks expand untrusted input-derived env vars without double-quoting, allowing the shell to parse metacharacters (word splitting, globbing, command substitution) from attacker-controlled values.

1. 'Run aptu issue triage' step: `echo "Running: aptu issue triage ${ARGS[*]} $ISSUE_REF"` — $ISSUE_REF is unquoted and is composed of $REPO (from inputs.repo or github.repository) and $ISSUE_NUMBER (from inputs['issue-number'] or github.event.issue.number).

2. 'Run aptu scan-security' step: `echo "Running: aptu scan-security --diff $SCAN_DIFF ..."` and `echo "Running: aptu scan-security $SCAN_PATH ..."` — $SCAN_DIFF (from inputs.scan-security-diff) and $SCAN_PATH (from inputs.scan-path) are unquoted.

3. 'Run aptu lint-issue' step: `echo "Running: aptu lint-issue --file $LINT_ISSUE_FILE --issue-type $LINT_ISSUE_TYPE ..."` — $LINT_ISSUE_FILE (from inputs.lint-issue-file) and $LINT_ISSUE_TYPE (from inputs.lint-issue-type) are unquoted.

Fix: double-quote all expansions, e.g. `echo "Running: aptu issue triage ${ARGS[*]} \"$ISSUE_REF\""`.

Locations:

- `action.yml:270`
- `action.yml:340`
- `action.yml:342`
- `action.yml:393`
- `action.yml:395`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in hardened/action/action.yml:

1. Replaced `${{ github.action_path }}` with `$GITHUB_ACTION_PATH` in the 'Roll up anonymized review-context telemetry' step's run command (line 430). The template expression was being substituted before the shell saw it, bypassing shell quoting.

2. Added double-quotes around unquoted variable expansions in diagnostic echo statements:
   - 'Run aptu issue triage' step: `$ISSUE_REF` → `\"$ISSUE_REF\"`
   - 'Run aptu scan-security' step: `$SCAN_DIFF` → `\"$SCAN_DIFF\"` and `$SCAN_PATH` → `\"$SCAN_PATH\"`
   - 'Run aptu lint-issue' step: `$LINT_ISSUE_FILE` → `\"$LINT_ISSUE_FILE\"` and `$LINT_ISSUE_TYPE` → `\"$LINT_ISSUE_TYPE\"`

The actual command invocations already had proper quoting; only the echo diagnostic lines were missing quotes.

