<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.2** was hardened automatically. 0 finding(s) were identified and resolved across 1 iteration(s).

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed three unquoted shell variable expansions in echo diagnostic lines in action.yml:
1. Line ~397: `echo "Running: aptu scan-security --diff $SCAN_DIFF --output sarif"` → added double-quotes around `$SCAN_DIFF`
2. Line ~401: `echo "Running: aptu scan-security $SCAN_PATH --output sarif"` → added double-quotes around `$SCAN_PATH`
3. Line ~415: `echo "Running: aptu pr queue --repo $REPO"` → added double-quotes around `$REPO`

The actual command invocations (aptu scan-security, aptu pr queue) already had proper quoting; only the diagnostic echo lines were missing quotes around the caller-controlled values.

