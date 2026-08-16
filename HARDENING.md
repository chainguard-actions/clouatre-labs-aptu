<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.3** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): The 'install-aptu' step in action.yml directly interpolates `${{ steps.resolve-version.outputs.version }}` inside a `run:` shell command string (`APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`). Any `${{ ... }}` expression inside a run: block is a script-injection risk because YAML template substitution occurs before the shell ever sees the value.

Locations:

- `action.yml:215`

### script-injection (severity: high)

Rule (a): Multiple `run:` steps in build-and-attest.yml directly interpolate `${{ inputs.target }}`, `${{ steps.upload-cli.outputs.tar }}`, and `${{ github.ref_name }}` inside shell command strings. Affected steps: 'Build binary (dry-run)' (`cargo build --release --target ${{ inputs.target }}`), 'Sign tarball with cosign' (`cosign sign-blob ... "${{ steps.upload-cli.outputs.tar }}"`), 'Upload tarball .bundle to release' (`gh release upload ${{ github.ref_name }}`), 'Generate aptu .deb package' (`cargo deb --target ${{ inputs.target }}`), 'Upload aptu .deb to release' (`find target/${{ inputs.target }}/debian`), 'Sign aptu .deb with cosign' (`find target/${{ inputs.target }}/debian`), 'Upload aptu .deb .bundle to release' (`find target/${{ inputs.target }}/debian` and `gh release upload ${{ github.ref_name }}`). These are marked with `# zizmor: ignore[template-injection]` but remain real script-injection findings.

Locations:

- `.github/workflows/build-and-attest.yml:68`
- `.github/workflows/build-and-attest.yml:72`
- `.github/workflows/build-and-attest.yml:77`
- `.github/workflows/build-and-attest.yml:87`
- `.github/workflows/build-and-attest.yml:93`
- `.github/workflows/build-and-attest.yml:100`
- `.github/workflows/build-and-attest.yml:107`

### script-injection (severity: high)

Rule (a): The 'Validate commit messages' step in ci.yml directly interpolates `${{ github.event.pull_request.base.sha }}` and `${{ github.event.pull_request.head.sha }}` inside a `run:` shell command string (`npx commitlint --from ${{ github.event.pull_request.base.sha }} --to ${{ github.event.pull_request.head.sha }}`). These are attacker-controllable values (a PR author controls the head SHA reference) that flow through YAML template substitution before the shell processes them.

Locations:

- `.github/workflows/ci.yml:57`

### script-injection (severity: high)

Rule (a): The 'ci-result' job's 'Verify all jobs passed or were skipped' step in ci.yml directly interpolates `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` inside a `run:` shell command string. Even though `needs.*.result` values are GitHub-controlled, any `${{ ... }}` expression inside a run: block is a script-injection finding because it flows through YAML template substitution before the shell processes it.

Locations:

- `.github/workflows/ci.yml:290`

### script-injection (severity: high)

Rule (b): Multiple `run:` steps in action.yml build a shell variable `$ARGS` by appending values sourced from workflow-controllable inputs (`$SINCE` from `inputs.since`, `$ISSUE_STATE` from `inputs.issue-state`, `$REPO_PATH` from `inputs.repo-path`, `$INSTRUCTIONS_FILE` from `inputs.instructions-file`) and then pass `$ARGS` unquoted to shell commands (e.g., `aptu issue triage $ARGS`, `aptu pr review $ARGS "$PR_REF"`). Unquoted expansion allows shell metacharacter injection from these input values. Affected steps: 'Run aptu issue triage (scheduled batch)' (appends `$SINCE` and `$ISSUE_STATE` to `$ARGS` unquoted), 'Run aptu PR review' (appends `$REPO_PATH` and `$INSTRUCTIONS_FILE` to `$ARGS` unquoted).

Locations:

- `action.yml:310`
- `action.yml:380`

### github-env-injection (severity: high)

The 'Extract version from tag or input' step in release.yml writes `$INPUT_VERSION` (sourced from `${{ inputs.version }}`, a workflow_dispatch user-controlled input) to `$GITHUB_ENV` without sanitization: `echo "VERSION=$VERSION" >> "$GITHUB_ENV"`. An attacker triggering a workflow_dispatch could inject a newline into `inputs.version` to set arbitrary environment variables for subsequent steps. The required sanitization step (`printf '%s' "$INPUT_VERSION" | tr -d '\n\r'`) is absent.

Locations:

- `.github/workflows/release.yml:77`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all 6 findings across 4 files:

1. action.yml (install-aptu step, line 215): Moved `${{ steps.resolve-version.outputs.version }}` from run: block to env: block as APTU_VERSION.

2. build-and-attest.yml (7 locations): Moved ${{ inputs.target }}, ${{ steps.upload-cli.outputs.tar }}, and ${{ github.ref_name }} from run: blocks to env: blocks as BUILD_TARGET, UPLOAD_TAR, and REF_NAME. Removed zizmor:ignore comments.

3. ci.yml (commitlint step, line 57): Moved ${{ github.event.pull_request.base.sha }} and ${{ github.event.pull_request.head.sha }} to env: block as BASE_SHA and HEAD_SHA.

4. ci.yml (ci-result step, line 290): Moved ${{ contains(needs.*.result, ...) }} expression to env: block as HAS_FAILURE.

5. action.yml (scheduled batch triage and PR review steps, lines 310/380): Converted string-based $ARGS to bash arrays (ARGS=() with ARGS+=() appends) so all user-controlled values ($SINCE, $ISSUE_STATE, $REPO_PATH, $INSTRUCTIONS_FILE) are properly quoted as individual array elements.

6. release.yml (Extract version step, line 77): Added `printf '%s' "$INPUT_VERSION" | tr -d '\n\r'` sanitization before writing to $GITHUB_ENV to prevent newline injection.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed all 9 script injection occurrences of `${{ github.repository }}` in run: blocks across 3 steps in .github/workflows/release.yml:
1. 'Verify tag is signed' step (verify-tag-signature job): Added `REPO: ${{ github.repository }}` to env: block and replaced 2 occurrences of `${{ github.repository }}` with `$REPO` in the shell script.
2. 'Move floating minor tag to current release' step (update-marketplace-tag job): Added `REPO: ${{ github.repository }}` to env: block and replaced 6 occurrences of `${{ github.repository }}` with `$REPO` in the shell script (including one in a comment).
3. 'Download SHA256 checksums' step (update-homebrew job): Added `REPO: ${{ github.repository }}` to env: block and replaced 1 occurrence of `${{ github.repository }}` with `$REPO` in the shell script.

