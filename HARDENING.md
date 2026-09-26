<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.0** was hardened automatically. 0 finding(s) were identified and resolved across 1 iteration(s).

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed 6 script-injection findings in action.yml by replacing unsafe `echo "...${VAR}..."` patterns with `printf 'format %s\n' "$VAR"` calls. The printf format string is single-quoted (no expansion), and variables are passed as separate arguments, preventing command substitution from attacker-controlled values. Affected steps: 'Run aptu issue triage' (line 248), 'Run aptu PR label' (line 285), 'Run aptu PR review' (line 325), 'Run aptu scan-security' (lines 348 and 351), and 'Run aptu pr queue' (line 374).

