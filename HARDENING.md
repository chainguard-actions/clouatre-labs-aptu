<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: Multiple run: blocks in action.yml expand workflow-controllable env vars without double-quoting inside echo/logging statements.

1. 'Run aptu issue triage' step: `echo "Running: aptu issue triage ${ARGS[*]} $ISSUE_REF"` — $ISSUE_REF (built from $REPO and $ISSUE_NUMBER, sourced from github.repository and github.event.issue.number) and ${ARGS[*]} are unquoted. An attacker-controlled value containing shell metacharacters (spaces, semicolons, backticks, etc.) would be word-split and interpreted by the shell.

2. 'Run aptu issue triage (scheduled batch)' step: `echo "Running: aptu issue triage ${ARGS[*]}"` — ${ARGS[*]} contains values from inputs.since and inputs.issue-state, unquoted.

3. 'Run aptu PR label' step: `echo "Running: aptu pr label ${ARGS[*]} $PR_REF"` — $PR_REF (from github.repository and github.event.pull_request.number) is unquoted.

4. 'Run aptu PR review' step: `echo "Running: aptu pr review ${ARGS[*]} $PR_REF"` — same issue as above.

5. 'Run aptu scan-security' step: `echo "Running: aptu scan-security --diff $SCAN_DIFF --output sarif"` and `echo "Running: aptu scan-security $SCAN_PATH --output sarif"` — $SCAN_DIFF (from inputs.scan-security-diff) and $SCAN_PATH (from inputs.scan-path) are unquoted.

6. 'Run aptu pr queue' step: `echo "Running: aptu pr queue --repo $REPO"` — $REPO (from github.repository) is unquoted.

All these variables should be double-quoted: `echo "Running: aptu issue triage ${ARGS[*]} $ISSUE_REF"` → `echo "Running: aptu issue triage ${ARGS[*]} \"$ISSUE_REF\""`

Locations:

- `action.yml:207`
- `action.yml:240`
- `action.yml:265`
- `action.yml:296`
- `action.yml:318`
- `action.yml:322`
- `action.yml:337`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed 6 script injection locations in action.yml echo/logging statements by adding explicit double-quoting around user-controlled variables:
1. 'Run aptu issue triage': $ISSUE_REF → \"$ISSUE_REF\"
2. 'Run aptu PR label': $PR_REF → \"$PR_REF\"
3. 'Run aptu PR review': $PR_REF → \"$PR_REF\"
4. 'Run aptu scan-security': $SCAN_DIFF → \"$SCAN_DIFF\" and $SCAN_PATH → \"$SCAN_PATH\"
5. 'Run aptu pr queue': $REPO → \"$REPO\"
The actual command invocations already used proper quoting ("${ARGS[@]}" "$VAR"); only the echo logging statements needed fixing. The scheduled batch echo (finding 2) uses ${ARGS[*]} which is already inside a double-quoted string.

