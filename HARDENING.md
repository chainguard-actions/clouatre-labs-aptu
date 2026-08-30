<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.17

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.17** was hardened automatically. 7 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple ${{ }} expressions are interpolated directly inside run: shell command strings in build-and-attest.yml. Specifically, ${{ inputs.target }} appears in 'cargo build --release --target ${{ inputs.target }}' and in 'DEB_FILE=$(find target/${{ inputs.target }}/debian ...)'; ${{ steps.upload-cli.outputs.tar }} appears in 'cosign sign-blob ... "${{ steps.upload-cli.outputs.tar }}.bundle"' and 'gh release upload $RELEASE_TAG "${{ steps.upload-cli.outputs.tar }}.bundle"'. These are marked with '# zizmor: ignore[template-injection]' comments but remain script-injection violations — any ${{ ... }} directly inside a run: script is a finding regardless of suppression comments.

Locations:

- `.github/workflows/build-and-attest.yml:56`
- `.github/workflows/build-and-attest.yml:60`
- `.github/workflows/build-and-attest.yml:64`
- `.github/workflows/build-and-attest.yml:68`
- `.github/workflows/build-and-attest.yml:75`
- `.github/workflows/build-and-attest.yml:82`
- `.github/workflows/build-and-attest.yml:89`

### script-injection (severity: high)

Sub-rule (a): ${{ }} expressions are interpolated directly inside run: shell command strings in ci.yml. In the 'Validate commit messages' step: '--from ${{ github.event.pull_request.base.sha }} --to ${{ github.event.pull_request.head.sha }}'. In the 'Verify all jobs passed or were skipped' step: 'if [[ "${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}" == "true" ]]'. All ${{ ... }} inside run: blocks are script-injection findings.

Locations:

- `.github/workflows/ci.yml:73`
- `.github/workflows/ci.yml:74`
- `.github/workflows/ci.yml:363`

### script-injection (severity: high)

Sub-rule (a): ${{ github.repository }} is interpolated directly inside run: shell command strings in release.yml. Affected steps include 'Verify tag is signed' (e.g., 'gh api "repos/${{ github.repository }}/git/refs/tags/$TAG"' and 'gh api "repos/${{ github.repository }}/git/tags/$TAG_SHA"'), 'Move floating minor tag to current release' (multiple gh api calls), and 'Download SHA256 checksums' ('gh api "repos/${{ github.repository }}/releases/tags/${RELEASE_TAG}"'). Any ${{ ... }} directly inside a run: script is a script-injection finding.

Locations:

- `.github/workflows/release.yml:47`
- `.github/workflows/release.yml:55`
- `.github/workflows/release.yml:120`
- `.github/workflows/release.yml:131`
- `.github/workflows/release.yml:137`
- `.github/workflows/release.yml:175`

### script-injection (severity: high)

Sub-rule (a): ${{ github.repository }} is interpolated directly inside a run: shell command string in scorecard.yml. The 'Run OpenSSF Scorecard' step contains: './scorecard --repo=github.com/${{ github.repository }} --format=sarif --show-details > results.sarif'. Any ${{ ... }} directly inside a run: script is a script-injection finding.

Locations:

- `.github/workflows/scorecard.yml:40`

### script-injection (severity: high)

Sub-rule (a): ${{ needs.secrets.result }} and ${{ needs.zizmor.result }} are interpolated directly inside a run: shell command string in security.yml. The 'Check all security jobs passed' step contains: 'for result in "${{ needs.secrets.result }}" "${{ needs.zizmor.result }}"'. Any ${{ ... }} directly inside a run: script is a script-injection finding.

Locations:

- `.github/workflows/security.yml:55`

### github-env-injection (severity: high)

The 'Resolve release tag' step in build-and-attest.yml writes values derived from untrusted inputs to $GITHUB_ENV without sanitization. $INPUT_TAG_NAME (from inputs.tag_name, a workflow_call input) is written as 'echo "RELEASE_TAG=$INPUT_TAG_NAME" >> "$GITHUB_ENV"', and $REF_NAME (from github.ref_name) is written as 'echo "RELEASE_TAG=$REF_NAME" >> "$GITHUB_ENV"'. Neither value is passed through 'printf "%s" ... | tr -d "\n\r"' before the write.

Locations:

- `.github/workflows/build-and-attest.yml:50`
- `.github/workflows/build-and-attest.yml:52`

### github-env-injection (severity: high)

The 'Extract version from tag or input' step in release.yml writes values derived from untrusted workflow_dispatch inputs to $GITHUB_ENV without sanitization. $VERSION and $TAG are derived from $INPUT_VERSION (inputs.version), $INPUT_TAG_NAME (inputs.tag_name), and GITHUB_REF, then written as 'echo "VERSION=$VERSION" >> "$GITHUB_ENV"' and 'echo "TAG=$TAG" >> "$GITHUB_ENV"'. Neither value is passed through 'printf "%s" ... | tr -d "\n\r"' before the write.

Locations:

- `.github/workflows/release.yml:96`
- `.github/workflows/release.yml:97`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all script-injection and github-env-injection findings across 5 workflow files:

1. build-and-attest.yml: Moved ${{ inputs.target }} into INPUT_TARGET env var for 'Build binary (dry-run)', 'Generate aptu .deb package', 'Upload aptu .deb to release', 'Sign aptu .deb with cosign', and 'Upload aptu .deb .bundle to release' steps. Moved ${{ steps.upload-cli.outputs.tar }} into UPLOAD_TAR env var for 'Sign tarball with cosign' and 'Upload tarball .bundle to release' steps. Fixed github-env-injection in 'Resolve release tag' by sanitizing values with printf/tr before writing to GITHUB_ENV.

2. ci.yml: Moved ${{ github.event.pull_request.base.sha }} and ${{ github.event.pull_request.head.sha }} into PR_BASE_SHA/PR_HEAD_SHA env vars. Moved ${{ contains(needs.*.result, ...) }} expression into ANY_FAILED env var.

3. release.yml: Moved ${{ github.repository }} into GH_REPOSITORY env var in 'Verify tag is signed', 'Move floating minor tag to current release', and 'Download SHA256 checksums' steps. Fixed github-env-injection in 'Extract version from tag or input' by sanitizing VERSION and TAG with printf/tr before writing to GITHUB_ENV.

4. scorecard.yml: Moved ${{ github.repository }} into GH_REPOSITORY env var in 'Run OpenSSF Scorecard' step.

5. security.yml: Moved ${{ needs.secrets.result }} and ${{ needs.zizmor.result }} into SECRETS_RESULT/ZIZMOR_RESULT env vars in 'Check all security jobs passed' step.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed all three unquoted `$RELEASE_TAG` usages in `hardened/action/.github/workflows/build-and-attest.yml`. Changed `gh release upload $RELEASE_TAG ...` to `gh release upload "$RELEASE_TAG" ...` in the 'Upload tarball .bundle to release', 'Upload aptu .deb to release', and 'Upload aptu .deb .bundle to release' steps. This prevents word splitting and glob expansion from the caller-controlled `inputs.tag_name` / `github.ref_name` value.

