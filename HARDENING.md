<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.6** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): ${{ }} expressions are interpolated directly inside run: shell command strings in multiple steps.

1. ci.yml 'Validate commit messages' step: `--from ${{ github.event.pull_request.base.sha }}` and `--to ${{ github.event.pull_request.head.sha }}` are interpolated directly into the npx commitlint command. Although these are SHA values, any ${{ }} expression in a run: block is a script-injection vector.

2. ci.yml 'Verify all jobs passed or were skipped' step: `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` is interpolated directly into an if [[ ... ]] shell test.

3. build-and-attest.yml 'Build binary (dry-run)' step: `run: cargo build --release --target ${{ inputs.target }} -p aptu-cli` — inputs.target is a workflow_call input interpolated directly into the shell command.

4. build-and-attest.yml 'Sign tarball with cosign' step: `cosign sign-blob --yes --bundle "${{ steps.upload-cli.outputs.tar }}.bundle" "${{ steps.upload-cli.outputs.tar }}"` — step output interpolated directly.

5. build-and-attest.yml 'Upload tarball .bundle to release' step: `gh release upload $RELEASE_TAG "${{ steps.upload-cli.outputs.tar }}.bundle"` — step output interpolated directly.

6. build-and-attest.yml 'Generate aptu .deb package' step: `run: cargo deb --target ${{ inputs.target }} --no-build --package aptu-cli` — inputs.target interpolated directly.

7. build-and-attest.yml 'Upload aptu .deb to release' and 'Sign aptu .deb with cosign' steps: `find target/${{ inputs.target }}/debian` — inputs.target interpolated directly.

8. release.yml 'Verify tag is signed' step: `gh api "repos/${{ github.repository }}/git/refs/tags/$TAG"` — github.repository interpolated directly into the shell command string.

9. release.yml 'Move floating minor tag to current release' step: multiple `gh api "repos/${{ github.repository }}/..."` calls with github.repository interpolated directly.

All of these should use env: variables instead of direct ${{ }} interpolation in run: blocks.

Locations:

- `.github/workflows/ci.yml:68`
- `.github/workflows/ci.yml:69`
- `.github/workflows/ci.yml:289`
- `.github/workflows/build-and-attest.yml:83`
- `.github/workflows/build-and-attest.yml:89`
- `.github/workflows/build-and-attest.yml:95`
- `.github/workflows/build-and-attest.yml:101`
- `.github/workflows/build-and-attest.yml:109`
- `.github/workflows/build-and-attest.yml:117`
- `.github/workflows/release.yml:47`
- `.github/workflows/release.yml:56`
- `.github/workflows/release.yml:148`
- `.github/workflows/release.yml:157`

### github-env-injection (severity: high)

Untrusted input values are written to $GITHUB_ENV without sanitization (no `printf '%s' ... | tr -d '\n\r'` step applied before the write).

1. build-and-attest.yml 'Resolve release tag' step: The env vars INPUT_TAG_NAME (from ${{ inputs.tag_name }}) and REF_NAME (from ${{ github.ref_name }}) are written directly to $GITHUB_ENV via `echo "RELEASE_TAG=$INPUT_TAG_NAME" >> "$GITHUB_ENV"` and `echo "RELEASE_TAG=$REF_NAME" >> "$GITHUB_ENV"`. An attacker controlling inputs.tag_name (via workflow_dispatch) could inject newlines to set arbitrary environment variables.

2. release.yml 'Extract version from tag or input' step: The env vars INPUT_VERSION (from ${{ inputs.version }}) and INPUT_TAG_NAME (from ${{ inputs.tag_name }}) are used to construct VERSION and TAG, which are then written to $GITHUB_ENV via `echo "VERSION=$VERSION" >> "$GITHUB_ENV"` and `echo "TAG=$TAG" >> "$GITHUB_ENV"`. An attacker controlling inputs.version or inputs.tag_name (via workflow_dispatch) could inject newlines to set arbitrary environment variables.

Locations:

- `.github/workflows/build-and-attest.yml:60`
- `.github/workflows/build-and-attest.yml:62`
- `.github/workflows/release.yml:93`
- `.github/workflows/release.yml:94`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all script-injection and github-env-injection findings across three workflow files:

**ci.yml:**
1. 'Validate commit messages' step: Moved `${{ github.event.pull_request.base.sha }}` and `${{ github.event.pull_request.head.sha }}` to env: block as BASE_SHA and HEAD_SHA.
2. 'Verify all jobs passed or were skipped' step: Moved `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` to env: block as HAS_FAILURE.

**build-and-attest.yml:**
3. 'Resolve release tag' step (github-env-injection): Added `printf '%s' ... | tr -d '\n\r'` sanitization before writing RELEASE_TAG to $GITHUB_ENV.
4. 'Build binary (dry-run)' step: Moved `${{ inputs.target }}` to env: block as TARGET.
5. 'Sign tarball with cosign' step: Moved `${{ steps.upload-cli.outputs.tar }}` to env: block as TAR_PATH.
6. 'Upload tarball .bundle to release' step: Moved `${{ steps.upload-cli.outputs.tar }}` to env: block as TAR_PATH.
7. 'Generate aptu .deb package' step: Moved `${{ inputs.target }}` to env: block as TARGET.
8. 'Upload aptu .deb to release' step: Moved `${{ inputs.target }}` to env: block as TARGET.
9. 'Sign aptu .deb with cosign' step: Moved `${{ inputs.target }}` to env: block as TARGET.
10. 'Upload aptu .deb .bundle to release' step: Moved `${{ inputs.target }}` to env: block as TARGET.

**release.yml:**
11. 'Verify tag is signed' step: Moved `${{ github.repository }}` to env: block as GH_REPO; replaced all `${{ github.repository }}` interpolations in the run: block with `$GH_REPO`.
12. 'Extract version from tag or input' step (github-env-injection): Added `printf '%s' ... | tr -d '\n\r'` sanitization for VERSION and TAG before writing to $GITHUB_ENV.
13. 'Move floating minor tag to current release' step: Moved `${{ github.repository }}` to env: block as GH_REPO; replaced all `${{ github.repository }}` interpolations in the run: block with `$GH_REPO`.
14. 'Download SHA256 checksums' step (update-homebrew job): Also fixed `${{ github.repository }}` interpolation in run: block by moving to env: block as GH_REPO (additional fix beyond listed findings).

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script injection vulnerability in hardened/action/.github/workflows/build-and-attest.yml at three locations (lines 97, 117, 131). The shell variable $RELEASE_TAG was used unquoted in `gh release upload` commands, allowing shell metacharacters in the tag name to be interpreted by the shell. Added double quotes around $RELEASE_TAG in all three occurrences: `gh release upload "$RELEASE_TAG" ...`.

