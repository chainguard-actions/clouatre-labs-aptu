<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **clouatre-labs--aptu/v0.10.0** was hardened automatically. 0 finding(s) were identified and resolved across 1 iteration(s).

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed all 6 unquoted variable expansions in echo statements within action.yml:
1. `echo "Running: aptu issue triage ${ARGS[*]} \"$ISSUE_REF\""` — $ISSUE_REF now double-quoted
2. `echo "Running: aptu pr label ${ARGS[*]} \"$PR_REF\""` — $PR_REF now double-quoted
3. `echo "Running: aptu pr review ${ARGS[*]} \"$PR_REF\""` — $PR_REF now double-quoted
4. `echo "Running: aptu scan-security --diff \"$SCAN_DIFF\" --output sarif"` — $SCAN_DIFF now double-quoted
5. `echo "Running: aptu scan-security \"$SCAN_PATH\" --output sarif"` — $SCAN_PATH now double-quoted
6. `echo "Running: aptu pr queue --repo \"$REPO\""` — $REPO now double-quoted

The actual aptu command invocations were already properly quoted and were not modified.

