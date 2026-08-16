<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.0** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in build-and-attest.yml directly interpolate `${{ ... }}` expressions inside shell commands (sub-rule a), allowing script injection. Affected lines include:
- `cargo build --release --target ${{ inputs.target }} -p aptu-cli`
- `cosign sign-blob --yes --bundle "${{ steps.upload-cli.outputs.tar }}.bundle" "${{ steps.upload-cli.outputs.tar }}"`
- `gh release upload $RELEASE_TAG "${{ steps.upload-cli.outputs.tar }}.bundle" --clobber`
- `DEB_FILE=$(find target/${{ inputs.target }}/debian ...)` (appears in three separate steps)
- `cargo deb --target ${{ inputs.target }} --no-build --package aptu-cli`
The `# zizmor: ignore[template-injection]` comments acknowledge but do not remediate the issue. These expressions should be moved to `env:` variables and the shell expansions double-quoted.

Locations:

- `.github/workflows/build-and-attest.yml:82`
- `.github/workflows/build-and-attest.yml:86`
- `.github/workflows/build-and-attest.yml:91`
- `.github/workflows/build-and-attest.yml:100`
- `.github/workflows/build-and-attest.yml:110`
- `.github/workflows/build-and-attest.yml:120`
- `.github/workflows/build-and-attest.yml:130`

### script-injection (severity: high)

Two `run:` blocks in ci.yml directly interpolate `${{ ... }}` expressions inside shell commands (sub-rule a):
1. The 'Validate commit messages' step passes `${{ github.event.pull_request.base.sha }}` and `${{ github.event.pull_request.head.sha }}` directly as CLI arguments to `npx commitlint`. These should be moved to `env:` variables.
2. The 'Verify all jobs passed or were skipped' step in the ci-result job interpolates `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` directly inside an `if [[ ... ]]` shell test. This should be moved to an `env:` variable.

Locations:

- `.github/workflows/ci.yml:72`
- `.github/workflows/ci.yml:73`
- `.github/workflows/ci.yml:313`

### github-env-injection (severity: high)

The 'Resolve release tag' step in build-and-attest.yml writes `$INPUT_TAG_NAME` (sourced from `inputs.tag_name`, a workflow-caller-controlled value) and `$REF_NAME` (sourced from `github.ref_name`) to `$GITHUB_ENV` without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). An attacker-controlled newline in these values could inject arbitrary environment variables into subsequent steps.

Locations:

- `.github/workflows/build-and-attest.yml:57`
- `.github/workflows/build-and-attest.yml:59`

### github-env-injection (severity: high)

The 'Extract version from tag or input' step in release.yml writes `$VERSION` and `$TAG` (both derived from `inputs.version` and/or `inputs.tag_name`, which are `workflow_dispatch` user-supplied inputs) to `$GITHUB_ENV` without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). A newline injected via these inputs could set arbitrary environment variables for subsequent steps in the job.

Locations:

- `.github/workflows/release.yml:100`
- `.github/workflows/release.yml:101`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all four findings across three workflow files:

1. build-and-attest.yml (script-injection): Moved all ${{ inputs.target }} and ${{ steps.upload-cli.outputs.tar }} expressions from run: blocks into env: variables (TARGET, UPLOAD_TAR) and referenced them as double-quoted shell variables. Removed the # zizmor: ignore[template-injection] comments.

2. build-and-attest.yml (github-env-injection): In the 'Resolve release tag' step, added sanitization using `printf '%s' "$VAR" | tr -d '\n\r'` before writing RELEASE_TAG to $GITHUB_ENV.

3. ci.yml (script-injection): (a) Moved ${{ github.event.pull_request.base.sha }} and ${{ github.event.pull_request.head.sha }} to env: variables BASE_SHA/HEAD_SHA in the 'Validate commit messages' step. (b) Moved the ${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }} expression to an env: variable ANY_FAILED in the 'Verify all jobs passed or were skipped' step.

4. release.yml (github-env-injection): In the 'Extract version from tag or input' step, added sanitization using `printf '%s' "$VAR" | tr -d '\n\r'` for both VERSION and TAG before writing them to $GITHUB_ENV.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in three steps of .github/workflows/release.yml by moving `${{ github.repository }}` out of `run:` shell strings and into `env:` blocks as `REPO: ${{ github.repository }}`. Updated all shell references from `${{ github.repository }}` to `$REPO` in: (1) 'Verify tag is signed' step (2 occurrences), (2) 'Move floating minor tag to current release' step (5 occurrences), and (3) 'Download SHA256 checksums' step (1 occurrence). All remaining `${{ github.repository }}` expressions are now only in `env:` declarations, which is the safe pattern.

