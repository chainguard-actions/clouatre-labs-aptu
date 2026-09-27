<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.17

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.17** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b): Multiple `run:` blocks expand env vars that hold workflow-controllable data (inputs.* / github.*) without double-quoting, allowing shell metacharacter injection.

• "Run aptu issue triage" step: `echo "Running: aptu issue triage ${ARGS[*]} $ISSUE_REF"` — `$ISSUE_REF` is built from `$REPO` (inputs.repo / github.repository) and `$ISSUE_NUMBER` (inputs.issue-number / github.event.issue.number), both unquoted.

• "Run aptu issue triage (scheduled batch)" step: `echo "Running: aptu issue triage ${ARGS[*]}"` — `${ARGS[*]}` (unquoted array expansion) contains values from inputs.since and inputs.issue-state.

• "Run aptu PR label" step: `echo "Running: aptu pr label ${ARGS[*]} $PR_REF"` — `$PR_REF` is built from inputs.pull-number / github.event.pull_request.number, unquoted.

• "Run aptu PR review" step: `echo "Running: aptu pr review ${ARGS[*]} $PR_REF"` — same as above.

• "Run aptu scan-security" step: `echo "Running: aptu scan-security --diff $SCAN_DIFF ..."` and `echo "Running: aptu scan-security $SCAN_PATH ..."` — `$SCAN_DIFF` (inputs.scan-security-diff) and `$SCAN_PATH` (inputs.scan-path) are unquoted.

• "Run aptu pr queue" step: `echo "Running: aptu pr queue --repo $REPO"` — `$REPO` (github.repository) is unquoted.

An attacker who controls any of these input values can embed shell metacharacters (e.g. `$(cmd)`, backticks, `;`, `|`) that the shell will interpret when the unquoted variable is expanded inside the echo command.

Locations:

- `action.yml:380`
- `action.yml:410`
- `action.yml:440`
- `action.yml:490`
- `action.yml:535`
- `action.yml:540`
- `action.yml:570`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed 7 script injection vulnerabilities in action.yml by replacing `echo "Running: ... $VAR"` statements (where variables inside double-quoted strings can trigger command substitution) with `printf 'Running: ... %s\n' "$VAR"` calls. The static format string in printf prevents shell metacharacter interpretation of user-controlled values. Affected steps: 'Run aptu issue triage' (ISSUE_REF, ARGS[*]), 'Run aptu issue triage (scheduled batch)' (ARGS[*]), 'Run aptu PR label' (ARGS[*], PR_REF), 'Run aptu PR review' (ARGS[*], PR_REF), 'Run aptu scan-security' (SCAN_DIFF, SCAN_PATH, FAIL_ON_ARGS[*], EXCLUDE_ARGS[*]), and 'Run aptu pr queue' (REPO). The actual aptu command invocations were already properly quoted and did not need changes.

