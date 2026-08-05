<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.9

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.9** was hardened automatically. 5 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): Direct expression interpolation inside run: blocks. The 'Validate commit messages' step interpolates `${{ github.event.pull_request.base.sha }}` and `${{ github.event.pull_request.head.sha }}` directly into the shell command (`npx commitlint --from ${{ github.event.pull_request.base.sha }} --to ${{ github.event.pull_request.head.sha }}`). The 'Verify all jobs passed or were skipped' step interpolates `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` directly into an if-condition string inside the run block. Any ${{ }} expression in a run: block is a script-injection risk.

Locations:

- `.github/workflows/ci.yml:75`
- `.github/workflows/ci.yml:313`

### script-injection (severity: high)

Rule (a): Direct expression interpolation inside run: blocks in build-and-attest.yml. Multiple steps interpolate `${{ inputs.target }}` and `${{ steps.upload-cli.outputs.tar }}` directly into shell commands: 'Build binary (dry-run)' uses `cargo build --release --target ${{ inputs.target }}`; 'Sign tarball with cosign' uses `"${{ steps.upload-cli.outputs.tar }}"`; 'Upload tarball .bundle to release' uses `"${{ steps.upload-cli.outputs.tar }}.bundle"`; 'Generate aptu .deb package' uses `cargo deb --target ${{ inputs.target }}`; 'Upload aptu .deb to release', 'Sign aptu .deb with cosign', and 'Upload aptu .deb .bundle to release' all use `find target/${{ inputs.target }}/debian`. All these steps carry `# zizmor: ignore[template-injection]` suppression comments but remain genuine injection risks.

Locations:

- `.github/workflows/build-and-attest.yml:96`
- `.github/workflows/build-and-attest.yml:100`
- `.github/workflows/build-and-attest.yml:105`
- `.github/workflows/build-and-attest.yml:113`
- `.github/workflows/build-and-attest.yml:119`
- `.github/workflows/build-and-attest.yml:127`
- `.github/workflows/build-and-attest.yml:135`

### script-injection (severity: high)

Rule (a): Direct expression interpolation inside run: blocks in release.yml. The 'Verify tag is signed' step interpolates `${{ github.repository }}` directly into shell commands: `gh api "repos/${{ github.repository }}/git/refs/tags/$TAG"` and `gh api "repos/${{ github.repository }}/git/tags/$TAG_SHA"`. The 'Move floating minor tag to current release' step similarly uses `${{ github.repository }}` in multiple `gh api` calls within the run block. These should be routed through env vars instead.

Locations:

- `.github/workflows/release.yml:55`
- `.github/workflows/release.yml:58`
- `.github/workflows/release.yml:152`
- `.github/workflows/release.yml:157`
- `.github/workflows/release.yml:163`

### github-env-injection (severity: high)

The 'Resolve release tag' step writes values derived from workflow inputs (`inputs.tag_name` via env var `$INPUT_TAG_NAME`) and `github.ref_name` (via env var `$REF_NAME`) to `$GITHUB_ENV` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker-controlled tag name containing newlines could inject arbitrary environment variables into subsequent steps.

Locations:

- `.github/workflows/build-and-attest.yml:62`

### github-env-injection (severity: high)

The 'Extract version from tag or input' step writes values derived from workflow_dispatch inputs (`inputs.version` via `$INPUT_VERSION` and `inputs.tag_name` via `$INPUT_TAG_NAME`) to `$GITHUB_ENV` (as `VERSION` and `TAG`) without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). A malicious actor triggering the workflow_dispatch with a crafted version or tag_name containing newlines could inject arbitrary environment variables into subsequent steps.

Locations:

- `.github/workflows/release.yml:88`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all 5 findings across 3 workflow files:

1. ci.yml script-injection (lines 75, 313): Moved PR SHA expressions and needs.*.result expression to env: blocks (BASE_SHA, HEAD_SHA, HAS_FAILURE).

2. build-and-attest.yml script-injection (lines 96, 100, 105, 113, 119, 127, 135): Moved inputs.target to INPUT_TARGET env var and steps.upload-cli.outputs.tar to TAR_PATH env var across all affected steps. Removed zizmor suppression comments.

3. release.yml script-injection (lines 55, 58, 152, 157, 163): Moved github.repository to REPOSITORY env var in 'Verify tag is signed' and 'Move floating minor tag to current release' steps. Also fixed an additional github.repository usage in 'Download SHA256 checksums' step.

4. build-and-attest.yml github-env-injection (line 62): Added printf '%s' ... | tr -d '\n\r' sanitization before writing RELEASE_TAG to GITHUB_ENV.

5. release.yml github-env-injection (line 88): Added printf '%s' ... | tr -d '\n\r' sanitization before writing VERSION and TAG to GITHUB_ENV.

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed unquoted $RELEASE_TAG variable in three 'gh release upload' commands in .github/workflows/build-and-attest.yml. Changed `gh release upload $RELEASE_TAG ...` to `gh release upload "$RELEASE_TAG" ...` in the 'Upload tarball .bundle to release', 'Upload aptu .deb to release', and 'Upload aptu .deb .bundle to release' steps. This prevents shell word-splitting and glob expansion on the tag value, which could allow command injection if the tag contained spaces, semicolons, or other shell metacharacters.

