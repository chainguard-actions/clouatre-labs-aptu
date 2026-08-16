<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.4** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Install aptu binary' step directly interpolates `${{ steps.resolve-version.outputs.version }}` inside the run: shell script as `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`. This is a steps.*.outputs.* context value injected directly into the shell command string before the shell ever sees it, enabling script injection if the output contains shell metacharacters.

Locations:

- `action.yml:230`

### script-injection (severity: high)

Sub-rule (a): The 'Validate commit messages' step directly interpolates `${{ github.event.pull_request.base.sha }}` and `${{ github.event.pull_request.head.sha }}` inside the `npx commitlint --from ... --to ...` run: block. Any ${{ }} expression directly in a run: shell string is a script-injection risk.

Locations:

- `.github/workflows/ci.yml:62`

### script-injection (severity: high)

Sub-rule (a): The 'Verify all jobs passed or were skipped' step (ci-result job) directly interpolates `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` inside a run: shell if-condition string. Any ${{ }} expression directly in a run: shell string is a script-injection risk.

Locations:

- `.github/workflows/ci.yml:299`

### script-injection (severity: high)

Sub-rule (a): Multiple run: blocks in build-and-attest.yml directly interpolate ${{ }} expressions into shell commands: (1) `cargo build --release --target ${{ inputs.target }}` in 'Build binary (dry-run)'; (2) `cosign sign-blob ... "${{ steps.upload-cli.outputs.tar }}.bundle" "${{ steps.upload-cli.outputs.tar }}"` in 'Sign tarball with cosign'; (3) `gh release upload ${{ github.ref_name }} ...` in 'Upload tarball .bundle to release'; (4) `find target/${{ inputs.target }}/debian ...` and `gh release upload ${{ github.ref_name }} ...` in 'Upload aptu .deb to release', 'Sign aptu .deb with cosign', and 'Upload aptu .deb .bundle to release'; (5) `cargo deb --target ${{ inputs.target }}` in 'Generate aptu .deb package'. These are inputs.* and steps.*.outputs.* values injected directly into shell.

Locations:

- `.github/workflows/build-and-attest.yml:72`
- `.github/workflows/build-and-attest.yml:76`
- `.github/workflows/build-and-attest.yml:82`
- `.github/workflows/build-and-attest.yml:96`
- `.github/workflows/build-and-attest.yml:107`
- `.github/workflows/build-and-attest.yml:116`
- `.github/workflows/build-and-attest.yml:126`

### script-injection (severity: high)

Sub-rule (a): Multiple run: blocks in release.yml directly interpolate `${{ github.repository }}` into shell commands used in `gh api "repos/${{ github.repository }}/..."` calls within the 'Verify tag is signed' step and the 'Move floating minor tag to current release' step, and `${{ github.repository }}` in the 'Download SHA256 checksums' step. Any ${{ }} expression directly in a run: shell string is a script-injection risk.

Locations:

- `.github/workflows/release.yml:44`
- `.github/workflows/release.yml:52`
- `.github/workflows/release.yml:148`
- `.github/workflows/release.yml:155`
- `.github/workflows/release.yml:163`
- `.github/workflows/release.yml:168`
- `.github/workflows/release.yml:232`

### github-env-injection (severity: high)

The 'Extract version from tag or input' step in release.yml maps `inputs.version` to the `INPUT_VERSION` env var, then writes `echo "VERSION=$VERSION" >> "$GITHUB_ENV"` where VERSION is derived from INPUT_VERSION without the required sanitization step (`printf '%s' "$INPUT_VERSION" | tr -d '\n\r'`). An attacker-controlled `inputs.version` value containing newlines could inject arbitrary environment variables into subsequent steps.

Locations:

- `.github/workflows/release.yml:82`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all script injection and github-env-injection findings across 4 files:

1. action.yml: Moved `${{ steps.resolve-version.outputs.version }}` from run: shell string into env: block as APTU_VERSION in the 'Install aptu binary' step.

2. .github/workflows/ci.yml: (a) Moved PR base/head SHAs into env: block as BASE_SHA/HEAD_SHA in 'Validate commit messages'. (b) Moved the contains() expression into env: block as HAS_FAILURE in 'Verify all jobs passed or were skipped'.

3. .github/workflows/build-and-attest.yml: Moved all ${{ inputs.target }}, ${{ github.ref_name }}, and ${{ steps.upload-cli.outputs.tar }} expressions into env: blocks (as BUILD_TARGET, REF_NAME, UPLOAD_TAR) across 7 steps: 'Build binary (dry-run)', 'Sign tarball with cosign', 'Upload tarball .bundle to release', 'Generate aptu .deb package', 'Upload aptu .deb to release', 'Sign aptu .deb with cosign', 'Upload aptu .deb .bundle to release'.

4. .github/workflows/release.yml: (a) Moved ${{ github.repository }} into env: block as GH_REPOSITORY in 'Verify tag is signed', 'Move floating minor tag to current release', and 'Download SHA256 checksums' steps. (b) Added newline sanitization (printf + tr -d '\n\r') for INPUT_VERSION before writing to GITHUB_ENV in 'Extract version from tag or input' step.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed two script injection vulnerabilities in action.yml by converting string-based ARGS concatenation to bash arrays:

1. 'Run aptu issue triage (scheduled batch)' step (lines ~285-300): Changed `ARGS="$ARGS --since $SINCE"` and `ARGS="$ARGS --state $ISSUE_STATE"` patterns to use a bash array: `ARGS=(--repo "$REPO")` with `ARGS+=(--since "$SINCE")` and `ARGS+=(--state "$ISSUE_STATE")`. Command invocation changed from `aptu issue triage $ARGS` to `aptu issue triage "${ARGS[@]}"`.

2. 'Run aptu PR review' step (lines ~360-370): Changed `ARGS="$ARGS --repo-path $REPO_PATH"` and `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"` patterns to use a bash array: `ARGS=(--comment --force)` with `ARGS+=(--repo-path "$REPO_PATH")` and `ARGS+=(--instructions-file "$INSTRUCTIONS_FILE")`. Command invocation changed from `aptu pr review $ARGS "$PR_REF"` to `aptu pr review "${ARGS[@]}" "$PR_REF"`.

Using bash arrays ensures each argument value is properly quoted and word-boundary safe, preventing shell metacharacter injection from attacker-controlled inputs.

