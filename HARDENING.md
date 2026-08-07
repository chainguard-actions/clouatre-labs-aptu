<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.10

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.10** was hardened automatically. 12 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Validate commit messages' step directly interpolates ${{ github.event.pull_request.base.sha }} and ${{ github.event.pull_request.head.sha }} inside a run: shell command. These GitHub Actions expressions are expanded by the template engine before the shell sees them, enabling script injection if the values contain shell metacharacters.

Locations:

- `.github/workflows/ci.yml:91`

### script-injection (severity: high)

Sub-rule (a): The 'Verify all jobs passed or were skipped' step in the ci-result job directly interpolates ${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }} inside a run: shell command string. Any ${{ }} expression in a run: block is a script-injection risk.

Locations:

- `.github/workflows/ci.yml:394`

### script-injection (severity: high)

Sub-rule (a): The 'Build binary (dry-run)' step directly interpolates ${{ inputs.target }} inside a run: shell command: `cargo build --release --target ${{ inputs.target }} -p aptu-cli`. The inputs.target value is workflow-caller-controlled and is expanded by the template engine before the shell sees it.

Locations:

- `.github/workflows/build-and-attest.yml:102`

### script-injection (severity: high)

Sub-rule (a): The 'Sign tarball with cosign' step directly interpolates ${{ steps.upload-cli.outputs.tar }} inside a run: shell command: `cosign sign-blob --yes --bundle "${{ steps.upload-cli.outputs.tar }}.bundle" "${{ steps.upload-cli.outputs.tar }}"`.

Locations:

- `.github/workflows/build-and-attest.yml:106`

### script-injection (severity: high)

Sub-rule (a): The 'Upload tarball .bundle to release' step directly interpolates ${{ steps.upload-cli.outputs.tar }} inside a run: shell command: `gh release upload $RELEASE_TAG "${{ steps.upload-cli.outputs.tar }}.bundle" --clobber`.

Locations:

- `.github/workflows/build-and-attest.yml:111`

### script-injection (severity: high)

Sub-rule (a): The 'Generate aptu .deb package' step directly interpolates ${{ inputs.target }} inside a run: shell command: `cargo deb --target ${{ inputs.target }} --no-build --package aptu-cli`. The inputs.target value is workflow-caller-controlled.

Locations:

- `.github/workflows/build-and-attest.yml:122`

### script-injection (severity: high)

Sub-rule (a): The 'Upload aptu .deb to release', 'Sign aptu .deb with cosign', and 'Upload aptu .deb .bundle to release' steps each directly interpolate ${{ inputs.target }} inside run: shell commands via `find target/${{ inputs.target }}/debian ...`. The inputs.target value is workflow-caller-controlled.

Locations:

- `.github/workflows/build-and-attest.yml:128`
- `.github/workflows/build-and-attest.yml:140`
- `.github/workflows/build-and-attest.yml:152`

### script-injection (severity: high)

Sub-rule (a): The 'Verify tag is signed' step in the verify-tag-signature job directly interpolates ${{ github.repository }} inside run: shell commands: `gh api "repos/${{ github.repository }}/git/refs/tags/$TAG"` and `gh api "repos/${{ github.repository }}/git/tags/$TAG_SHA"`. Any ${{ }} expression in a run: block is a script-injection risk.

Locations:

- `.github/workflows/release.yml:60`
- `.github/workflows/release.yml:70`

### script-injection (severity: high)

Sub-rule (a): The 'Move floating minor tag to current release' step in the update-marketplace-tag job directly interpolates ${{ github.repository }} inside run: shell commands in multiple gh api calls.

Locations:

- `.github/workflows/release.yml:220`
- `.github/workflows/release.yml:230`
- `.github/workflows/release.yml:240`

### script-injection (severity: high)

Sub-rule (a): The 'Download SHA256 checksums' step in the update-homebrew job directly interpolates ${{ github.repository }} inside a run: shell command: `gh api "repos/${{ github.repository }}/releases/tags/${RELEASE_TAG}" --jq '.assets[]'`.

Locations:

- `.github/workflows/release.yml:280`

### github-env-injection (severity: high)

The 'Resolve release tag' step writes untrusted input values to $GITHUB_ENV without sanitization. INPUT_TAG_NAME (from inputs.tag_name, a workflow_dispatch input) and REF_NAME (from github.ref_name) are written directly: `echo "RELEASE_TAG=$INPUT_TAG_NAME" >> "$GITHUB_ENV"` and `echo "RELEASE_TAG=$REF_NAME" >> "$GITHUB_ENV"`. A newline in either value could inject arbitrary environment variables.

Locations:

- `.github/workflows/build-and-attest.yml:63`

### github-env-injection (severity: high)

The 'Extract version from tag or input' step writes untrusted workflow_dispatch input values to $GITHUB_ENV without sanitization. VERSION (derived from inputs.version or inputs.tag_name) and TAG are written directly: `echo "VERSION=$VERSION" >> "$GITHUB_ENV"` and `echo "TAG=$TAG" >> "$GITHUB_ENV"`. A newline in inputs.version or inputs.tag_name could inject arbitrary environment variables.

Locations:

- `.github/workflows/release.yml:120`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all 12 findings across 3 workflow files:

**ci.yml:**
- 'Validate commit messages': Moved github.event.pull_request.base.sha and github.event.pull_request.head.sha into env: block as BASE_SHA/HEAD_SHA
- 'Verify all jobs passed or were skipped': Moved the contains() expression into env: block as ANY_FAILED

**build-and-attest.yml:**
- 'Resolve release tag': Added printf/tr sanitization before writing INPUT_TAG_NAME and REF_NAME to GITHUB_ENV
- 'Build binary (dry-run)': Moved inputs.target into env: block as TARGET
- 'Sign tarball with cosign': Moved steps.upload-cli.outputs.tar into env: block as TAR_PATH
- 'Upload tarball .bundle to release': Moved steps.upload-cli.outputs.tar into env: block as TAR_PATH
- 'Generate aptu .deb package': Moved inputs.target into env: block as TARGET
- 'Upload aptu .deb to release': Moved inputs.target into env: block as TARGET
- 'Sign aptu .deb with cosign': Moved inputs.target into env: block as TARGET
- 'Upload aptu .deb .bundle to release': Moved inputs.target into env: block as TARGET

**release.yml:**
- 'Verify tag is signed': Moved github.repository into env: block as GH_REPO
- 'Extract version from tag or input': Added printf/tr sanitization before writing VERSION and TAG to GITHUB_ENV
- 'Move floating minor tag to current release': Moved github.repository into env: block as GH_REPO
- 'Download SHA256 checksums': Moved github.repository into env: block as GH_REPO

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed three instances of unquoted `$RELEASE_TAG` in `gh release upload` commands in `.github/workflows/build-and-attest.yml` (lines 88, 101, and 117). Changed `gh release upload $RELEASE_TAG ...` to `gh release upload "$RELEASE_TAG" ...` in all three steps: 'Upload tarball .bundle to release', 'Upload aptu .deb to release', and 'Upload aptu .deb .bundle to release'. This prevents word splitting and glob expansion on the tag value, which is sourced from the workflow-controllable `inputs.tag_name` or `github.ref_name`.

