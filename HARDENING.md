<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.5** was hardened automatically. 4 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): ${{ github.event.pull_request.base.sha }} and ${{ github.event.pull_request.head.sha }} are interpolated directly inside a run: shell command in the commitlint step. Any ${{ ... }} expression in a run: block is a script-injection risk because the value is substituted into the shell script before the shell parses it. Offending lines: `--from ${{ github.event.pull_request.base.sha }}` and `--to ${{ github.event.pull_request.head.sha }}`.

Locations:

- `.github/workflows/ci.yml:68`

### script-injection (severity: high)

Sub-rule (a): Multiple run: blocks in build-and-attest.yml interpolate ${{ inputs.target }} and ${{ steps.upload-cli.outputs.tar }} directly into shell commands. These expressions are substituted before the shell parses the script, enabling injection. Offending lines include: `cargo build --release --target ${{ inputs.target }}`, `cosign sign-blob --yes --bundle "${{ steps.upload-cli.outputs.tar }}.bundle"`, `gh release upload $RELEASE_TAG "${{ steps.upload-cli.outputs.tar }}.bundle"`, `find target/${{ inputs.target }}/debian ...`, and `cargo deb --target ${{ inputs.target }}`. The # zizmor: ignore comments do not mitigate the injection risk.

Locations:

- `.github/workflows/build-and-attest.yml:87`
- `.github/workflows/build-and-attest.yml:91`
- `.github/workflows/build-and-attest.yml:97`
- `.github/workflows/build-and-attest.yml:107`
- `.github/workflows/build-and-attest.yml:113`
- `.github/workflows/build-and-attest.yml:121`
- `.github/workflows/build-and-attest.yml:130`

### github-env-injection (severity: high)

The 'Resolve release tag' step in build-and-attest.yml writes INPUT_TAG_NAME (sourced from ${{ inputs.tag_name }}, a workflow_call input) and REF_NAME (sourced from ${{ github.ref_name }}) to $GITHUB_ENV without sanitization. An attacker who controls the tag_name input or ref_name could inject newlines to set arbitrary environment variables for subsequent steps. The required sanitization step (printf '%s' "$VAR" | tr -d '\n\r') is absent before the echo ... >> "$GITHUB_ENV" writes.

Locations:

- `.github/workflows/build-and-attest.yml:55`

### github-env-injection (severity: high)

The 'Extract version from tag or input' step in release.yml writes VERSION and TAG (derived from inputs.version and inputs.tag_name, which are workflow_dispatch inputs) to $GITHUB_ENV without sanitization. A malicious workflow_dispatch invocation could supply a version or tag_name containing newlines to inject arbitrary environment variables for subsequent steps. The required sanitization step (printf '%s' "$VAR" | tr -d '\n\r') is absent before the echo "VERSION=$VERSION" >> "$GITHUB_ENV" and echo "TAG=$TAG" >> "$GITHUB_ENV" writes.

Locations:

- `.github/workflows/release.yml:97`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all four findings across three workflow files:

1. ci.yml: Moved github.event.pull_request.base.sha and head.sha into env block (BASE_SHA, HEAD_SHA) for the 'Validate commit messages' step.

2. build-and-attest.yml (script-injection): Moved inputs.target into env block (BUILD_TARGET) for 'Build binary (dry-run)', 'Generate aptu .deb package', 'Upload aptu .deb to release', 'Sign aptu .deb with cosign', and 'Upload aptu .deb .bundle to release' steps. Moved steps.upload-cli.outputs.tar into env block (UPLOAD_TAR) for 'Sign tarball with cosign' and 'Upload tarball .bundle to release' steps.

3. build-and-attest.yml (github-env-injection): Added printf '%s' | tr -d '\n\r' sanitization for INPUT_TAG_NAME and REF_NAME before writing RELEASE_TAG to $GITHUB_ENV in the 'Resolve release tag' step.

4. release.yml (github-env-injection): Added printf '%s' | tr -d '\n\r' sanitization for VERSION and TAG before writing to $GITHUB_ENV in the 'Extract version from tag or input' step.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed all script injection findings:

1. hardened/action/.github/workflows/release.yml: Replaced all 8 occurrences of `${{ github.repository }}` inside `run:` shell blocks with `$GITHUB_REPOSITORY` (the standard GitHub Actions environment variable already available on all runners). Affected steps: 'Verify tag is signed' (lines 57, 65), 'Move floating minor tag to current release' (lines 155, 160, 178, 184, 191), and 'Download SHA256 checksums' (line 225).

2. hardened/action/.github/workflows/ci.yml: Moved `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` from the `run:` block to an `env:` variable named `HAS_FAILURE` in the ci-result job's 'Verify all jobs passed or were skipped' step (line 295). The shell script now references `$HAS_FAILURE` instead of the inline template expression.

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed three instances of unquoted `$RELEASE_TAG` in `gh release upload` commands in `.github/workflows/build-and-attest.yml`. Changed `gh release upload $RELEASE_TAG ...` to `gh release upload "$RELEASE_TAG" ...` in the 'Upload tarball .bundle to release', 'Upload aptu .deb to release', and 'Upload aptu .deb .bundle to release' steps. This prevents shell metacharacter injection from caller-controlled tag name values.

