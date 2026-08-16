<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.1** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Direct ${{ }} expression interpolation in run: blocks. The 'Validate commit messages' step interpolates `${{ github.event.pull_request.base.sha }}` and `${{ github.event.pull_request.head.sha }}` directly into the shell command string: `npx commitlint --from ${{ github.event.pull_request.base.sha }} --to ${{ github.event.pull_request.head.sha }}`. These should be passed via env: variables and double-quoted in the script.

Locations:

- `.github/workflows/ci.yml:68`

### script-injection (severity: high)

Sub-rule (a): Direct ${{ }} expression interpolation in run: block. The 'Verify all jobs passed or were skipped' step in the ci-result job interpolates `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` directly into the shell command string inside an if-condition. This should be passed via an env: variable.

Locations:

- `.github/workflows/ci.yml:307`

### script-injection (severity: high)

Sub-rule (a): Direct ${{ }} expression interpolation in multiple run: blocks in build-and-attest.yml. The 'Build binary (dry-run)' step uses `${{ inputs.target }}` directly in the cargo build command. The 'Sign tarball with cosign' step uses `${{ steps.upload-cli.outputs.tar }}` directly. The 'Generate aptu .deb package', 'Upload aptu .deb to release', 'Sign aptu .deb with cosign', and 'Upload aptu .deb .bundle to release' steps all use `${{ inputs.target }}` directly in run: blocks. These expressions should be routed through env: variables and double-quoted.

Locations:

- `.github/workflows/build-and-attest.yml:88`
- `.github/workflows/build-and-attest.yml:92`
- `.github/workflows/build-and-attest.yml:101`
- `.github/workflows/build-and-attest.yml:110`
- `.github/workflows/build-and-attest.yml:118`
- `.github/workflows/build-and-attest.yml:127`

### script-injection (severity: high)

Sub-rule (a): Direct ${{ }} expression interpolation in multiple run: blocks in release.yml. The 'Verify tag is signed' step uses `${{ github.repository }}` directly in gh api URL strings. The 'Move floating minor tag to current release' step uses `${{ github.repository }}` multiple times in gh api calls. The 'Download SHA256 checksums' step also uses `${{ github.repository }}` in a run: block. These github.* context values should be passed via env: variables and double-quoted.

Locations:

- `.github/workflows/release.yml:44`
- `.github/workflows/release.yml:51`
- `.github/workflows/release.yml:163`
- `.github/workflows/release.yml:170`
- `.github/workflows/release.yml:196`
- `.github/workflows/release.yml:203`
- `.github/workflows/release.yml:210`
- `.github/workflows/release.yml:244`

### github-env-injection (severity: high)

The 'Resolve release tag' step writes env vars sourced from workflow inputs and github context to $GITHUB_ENV without sanitization. INPUT_TAG_NAME (from ${{ inputs.tag_name }}) is written as `echo "RELEASE_TAG=$INPUT_TAG_NAME" >> "$GITHUB_ENV"` and REF_NAME (from ${{ github.ref_name }}) is written as `echo "RELEASE_TAG=$REF_NAME" >> "$GITHUB_ENV"`. Neither write is preceded by the required `printf '%s' ... | tr -d '\n\r'` sanitization step.

Locations:

- `.github/workflows/build-and-attest.yml:57`
- `.github/workflows/build-and-attest.yml:59`

### github-env-injection (severity: high)

The 'Extract version from tag or input' step writes env vars sourced from workflow_dispatch inputs to $GITHUB_ENV without sanitization. INPUT_VERSION (from ${{ inputs.version }}) and INPUT_TAG_NAME (from ${{ inputs.tag_name }}) flow into VERSION and TAG variables which are then written as `echo "VERSION=$VERSION" >> "$GITHUB_ENV"` and `echo "TAG=$TAG" >> "$GITHUB_ENV"` without the required `printf '%s' ... | tr -d '\n\r'` sanitization step.

Locations:

- `.github/workflows/release.yml:88`
- `.github/workflows/release.yml:89`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all script-injection and github-env-injection findings across three workflow files:

**ci.yml:**
- 'Validate commit messages': Moved `github.event.pull_request.base.sha` and `github.event.pull_request.head.sha` to env vars `BASE_SHA`/`HEAD_SHA`.
- 'Verify all jobs passed or were skipped': Moved the `contains(needs.*.result, ...)` expression to env var `ANY_FAILED`.

**build-and-attest.yml:**
- 'Resolve release tag': Added `printf '%s' ... | tr -d '\n\r'` sanitization before writing to `$GITHUB_ENV`.
- 'Build binary (dry-run)': Moved `inputs.target` to env var `TARGET`.
- 'Sign tarball with cosign': Moved `steps.upload-cli.outputs.tar` to env var `UPLOAD_TAR`.
- 'Upload tarball .bundle to release': Moved `steps.upload-cli.outputs.tar` to env var `UPLOAD_TAR`.
- 'Generate aptu .deb package': Moved `inputs.target` to env var `TARGET`.
- 'Upload aptu .deb to release': Moved `inputs.target` to env var `TARGET`.
- 'Sign aptu .deb with cosign': Moved `inputs.target` to env var `TARGET`.
- 'Upload aptu .deb .bundle to release': Moved `inputs.target` to env var `TARGET`.

**release.yml:**
- 'Verify tag is signed': Moved `github.repository` to env var `REPOSITORY`.
- 'Extract version from tag or input': Added `printf '%s' ... | tr -d '\n\r'` sanitization before writing `VERSION` and `TAG` to `$GITHUB_ENV`.
- 'Move floating minor tag to current release': Moved `github.repository` to env var `REPOSITORY` (used in multiple gh api calls).
- 'Download SHA256 checksums': Moved `github.repository` to env var `REPOSITORY`.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed all three occurrences of unquoted $RELEASE_TAG in gh release upload commands in hardened/action/.github/workflows/build-and-attest.yml. Changed `gh release upload $RELEASE_TAG ...` to `gh release upload "$RELEASE_TAG" ...` in the 'Upload tarball .bundle to release' (line 108), 'Upload aptu .deb to release' (line 126), and 'Upload aptu .deb .bundle to release' (line 145) steps. This prevents word splitting and glob expansion on the RELEASE_TAG value.

