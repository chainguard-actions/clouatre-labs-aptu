<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.16

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.16** was hardened automatically. 7 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple run: blocks in build-and-attest.yml directly interpolate ${{ }} expressions into shell commands (sub-rule a). (1) Line 99: `run: cargo build --release --target ${{ inputs.target }} -p aptu-cli` — inputs.target interpolated directly. (2) Line 103: `cosign sign-blob --yes --bundle "${{ steps.upload-cli.outputs.tar }}.bundle" "${{ steps.upload-cli.outputs.tar }}"` — steps output interpolated directly. (3) Line 109: `gh release upload $RELEASE_TAG "${{ steps.upload-cli.outputs.tar }}.bundle"` — steps output interpolated directly. (4) Line 117: `run: cargo deb --target ${{ inputs.target }}` — inputs.target interpolated directly. (5) Line 123: `DEB_FILE=$(find target/${{ inputs.target }}/debian ...)` — inputs.target interpolated directly. (6) Line 130: same pattern. (7) Line 139: same pattern. An attacker who controls the workflow_call inputs can inject arbitrary shell commands.

Locations:

- `.github/workflows/build-and-attest.yml:99`
- `.github/workflows/build-and-attest.yml:103`
- `.github/workflows/build-and-attest.yml:109`
- `.github/workflows/build-and-attest.yml:117`
- `.github/workflows/build-and-attest.yml:123`
- `.github/workflows/build-and-attest.yml:130`
- `.github/workflows/build-and-attest.yml:139`

### script-injection (severity: high)

scorecard.yml line 46: `run: ./scorecard --repo=github.com/${{ github.repository }} --format=sarif --show-details > results.sarif` — ${{ github.repository }} is interpolated directly into the run: shell command (sub-rule a). Although github.repository is GitHub-controlled, any ${{ }} expression inside a run: block is a script-injection finding per the check rules.

Locations:

- `.github/workflows/scorecard.yml:46`

### script-injection (severity: high)

ci.yml: The 'Validate commit messages' step (lines 80-81) interpolates ${{ github.event.pull_request.base.sha }} and ${{ github.event.pull_request.head.sha }} directly into the npx commitlint run: command (sub-rule a): `--from ${{ github.event.pull_request.base.sha }} \ --to ${{ github.event.pull_request.head.sha }}`. Additionally, the ci-result step interpolates `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` directly into a run: block shell condition.

Locations:

- `.github/workflows/ci.yml:80`
- `.github/workflows/ci.yml:81`

### script-injection (severity: high)

security.yml line 63: The 'Check all security jobs passed' run: block interpolates ${{ needs.secrets.result }} and ${{ needs.zizmor.result }} directly into a shell for-loop: `for result in "${{ needs.secrets.result }}" "${{ needs.zizmor.result }}"; do`. Any ${{ }} expression inside a run: block is a script-injection finding per the check rules (sub-rule a).

Locations:

- `.github/workflows/security.yml:63`

### script-injection (severity: high)

release.yml: The 'Verify tag is signed' step (lines 59 and 69) interpolates ${{ github.repository }} directly into gh api URL strings inside a run: block (sub-rule a): `REF_JSON="$(gh api "repos/${{ github.repository }}/git/refs/tags/$TAG")"` and `TAG_OBJ_JSON="$(gh api "repos/${{ github.repository }}/git/tags/$TAG_SHA")"`. Additionally, the 'update-marketplace-tag' step (lines ~155, ~165, ~171) uses ${{ github.repository }} in gh api calls inside run: blocks.

Locations:

- `.github/workflows/release.yml:59`
- `.github/workflows/release.yml:69`

### github-env-injection (severity: high)

build-and-attest.yml: The 'Resolve release tag' step writes env vars sourced from untrusted inputs to $GITHUB_ENV without sanitization. INPUT_TAG_NAME (from ${{ inputs.tag_name }}) is written as `echo "RELEASE_TAG=$INPUT_TAG_NAME" >> "$GITHUB_ENV"` (line 60), and REF_NAME (from ${{ github.ref_name }}) is written as `echo "RELEASE_TAG=$REF_NAME" >> "$GITHUB_ENV"` (line 62). Neither write is preceded by the required `printf '%s' ... | tr -d '\n\r'` sanitization step. A newline in the tag_name input could inject arbitrary environment variables.

Locations:

- `.github/workflows/build-and-attest.yml:60`
- `.github/workflows/build-and-attest.yml:62`

### github-env-injection (severity: high)

release.yml: The 'Extract version from tag or input' step writes values derived from workflow_dispatch inputs to $GITHUB_ENV without sanitization. VERSION (derived from inputs.version / inputs.tag_name) is written as `echo "VERSION=$VERSION" >> "$GITHUB_ENV"` (line 118), and TAG (also derived from inputs) is written as `echo "TAG=$TAG" >> "$GITHUB_ENV"` (line 119). Neither write is preceded by the required `printf '%s' ... | tr -d '\n\r'` sanitization step. A newline in the version or tag_name input could inject arbitrary environment variables.

Locations:

- `.github/workflows/release.yml:118`
- `.github/workflows/release.yml:119`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all script-injection and github-env-injection findings across 5 workflow files:

1. build-and-attest.yml: Moved inputs.target into INPUT_TARGET env var for 'Build binary (dry-run)', 'Generate aptu .deb package', 'Upload aptu .deb to release', 'Sign aptu .deb with cosign', and 'Upload aptu .deb .bundle to release' steps. Moved steps.upload-cli.outputs.tar into UPLOAD_TAR env var for 'Sign tarball with cosign' and 'Upload tarball .bundle to release' steps. Added printf+tr sanitization before writing to GITHUB_ENV in 'Resolve release tag' step.

2. scorecard.yml: Moved github.repository into REPO env var for 'Run OpenSSF Scorecard' step.

3. ci.yml: Moved PR base/head SHAs into BASE_SHA/HEAD_SHA env vars for 'Validate commit messages' step. Moved contains() expression into HAS_FAILURE env var for 'Verify all jobs passed or were skipped' step.

4. security.yml: Moved needs job results into SECRETS_RESULT/ZIZMOR_RESULT env vars for 'Check all security jobs passed' step.

5. release.yml: Moved github.repository into GH_REPO env var for 'Verify tag is signed', 'Move floating minor tag to current release', and 'Download SHA256 checksums' steps. Added printf+tr sanitization before writing VERSION and TAG to GITHUB_ENV in 'Extract version from tag or input' step.

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed all three occurrences of unquoted `$RELEASE_TAG` in `hardened/action/.github/workflows/build-and-attest.yml` at lines 91, 107, and 122. Changed `gh release upload $RELEASE_TAG ...` to `gh release upload "$RELEASE_TAG" ...` in the 'Upload tarball .bundle to release', 'Upload aptu .deb to release', and 'Upload aptu .deb .bundle to release' steps. This prevents word-splitting on shell metacharacters (spaces, glob chars, etc.) in the release tag value.

