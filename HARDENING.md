<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.5** was hardened automatically. 3 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): A ${{ }} expression is interpolated directly inside a run: shell command string. In the 'Install aptu binary' step, the line `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"` embeds a GitHub Actions expression directly into the shell script body. Any ${{ ... }} inside a run: block is a script-injection risk because the value is substituted by the YAML template engine before the shell ever sees it, bypassing shell quoting.

Locations:

- `action.yml:234`

### script-injection (severity: high)

Sub-rule (b): Unquoted shell variable expansion of untrusted data. In multiple run: blocks, the variable $ARGS is built by concatenating user-controlled inputs without quoting (e.g., `ARGS="$ARGS --since $SINCE"`, `ARGS="$ARGS --state $ISSUE_STATE"`, `ARGS="$ARGS --repo-path $REPO_PATH"`, `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"`), where $SINCE comes from inputs.since, $ISSUE_STATE from inputs.issue-state, $REPO_PATH from inputs.repo-path, and $INSTRUCTIONS_FILE from inputs.instructions-file. The accumulated $ARGS string is then passed unquoted to the shell (e.g., `aptu issue triage $ARGS "$ISSUE_REF"`, `aptu pr review $ARGS "$PR_REF"`), allowing shell metacharacter injection via any of those inputs.

Locations:

- `action.yml:299`
- `action.yml:338`
- `action.yml:383`
- `action.yml:430`

### script-injection (severity: high)

Sub-rule (b): Unquoted shell variable expansion of untrusted data. In the 'Run aptu scan-security' step, the line `aptu scan-security $SCAN_PATH --output sarif` expands $SCAN_PATH (sourced from inputs.scan-path) without double-quoting, allowing shell metacharacter injection via the scan-path input.

Locations:

- `action.yml:462`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed all three script-injection findings in hardened/action/action.yml:

1. 'Install aptu binary' step (line 234): Moved `${{ steps.resolve-version.outputs.version }}` from the run: shell body into the step's env: block as `APTU_VERSION: ${{ steps.resolve-version.outputs.version }}`. The shell script now uses `$APTU_VERSION` safely.

2. Four steps with unquoted $ARGS expansion (lines 299, 338, 383, 430): Converted all ARGS string concatenation patterns to bash arrays (ARGS=()/ARGS+=(...)). Commands now use `"${ARGS[@]}"` ensuring proper quoting. User-controlled inputs like $SINCE, $ISSUE_STATE, $REPO_PATH, and $INSTRUCTIONS_FILE are now passed as properly quoted separate array elements.

3. 'Run aptu scan-security' step (line 462): The $SCAN_PATH variable is properly quoted as `"$SCAN_PATH"` in the aptu scan-security command.

### Iteration 2

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all three findings:

1. build-and-attest.yml (script-injection): Moved all ${{ inputs.target }}, ${{ steps.upload-cli.outputs.tar }}, and ${{ github.ref_name }} expressions out of run: shell strings and into env: blocks as TARGET, TAR_PATH, and REF_NAME variables. All shell references are double-quoted. Affected steps: 'Build binary (dry-run)', 'Sign tarball with cosign', 'Upload tarball .bundle to release', 'Generate aptu .deb package', 'Upload aptu .deb to release', 'Sign aptu .deb with cosign', 'Upload aptu .deb .bundle to release'.

2. ci.yml (script-injection): (a) Commitlint step: moved ${{ github.event.pull_request.base.sha }} and ${{ github.event.pull_request.head.sha }} into BASE_SHA and HEAD_SHA env vars. (b) ci-result step: moved ${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }} into ANY_FAILED env var.

3. release.yml (github-env-injection): Added sanitization in the 'Extract version from tag or input' step — the raw version is now passed through `printf '%s' "$RAW_VERSION" | tr -d '\n\r'` before being written to $GITHUB_ENV, preventing newline injection from the user-controlled workflow_dispatch version input.

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed all 8 script injection locations in hardened/action/.github/workflows/release.yml. Three steps were affected:
1. 'Verify tag is signed': Added `REPO: ${{ github.repository }}` to the step's `env:` block and replaced both `${{ github.repository }}` occurrences in the `run:` block with `$REPO`.
2. 'Move floating minor tag to current release': Added `REPO: ${{ github.repository }}` to the step's `env:` block and replaced all 5 `${{ github.repository }}` occurrences in the `run:` block with `$REPO`.
3. 'Download SHA256 checksums': Added `REPO: ${{ github.repository }}` to the step's `env:` block and replaced the single `${{ github.repository }}` occurrence in the `run:` block with `$REPO`.

