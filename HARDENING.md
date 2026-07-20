<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.4** was hardened automatically. 5 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple run: blocks in build-and-attest.yml directly interpolate ${{ }} expressions into shell commands without routing through env: variables first. Specifically: (a) 'Build binary (dry-run)' uses `${{ inputs.target }}` directly in the cargo command; (b) 'Sign tarball with cosign' uses `${{ steps.upload-cli.outputs.tar }}` directly in the cosign command; (c) 'Upload tarball .bundle to release' uses `${{ steps.upload-cli.outputs.tar }}` directly in the gh command; (d) 'Generate aptu .deb package' uses `${{ inputs.target }}` directly in the cargo deb command; (e) 'Upload aptu .deb to release', 'Sign aptu .deb with cosign', and 'Upload aptu .deb .bundle to release' all use `${{ inputs.target }}` directly in find commands. These are workflow_call inputs that a calling workflow controls, enabling script injection.

Locations:

- `.github/workflows/build-and-attest.yml:97`
- `.github/workflows/build-and-attest.yml:100`
- `.github/workflows/build-and-attest.yml:105`
- `.github/workflows/build-and-attest.yml:113`
- `.github/workflows/build-and-attest.yml:118`
- `.github/workflows/build-and-attest.yml:124`
- `.github/workflows/build-and-attest.yml:131`

### script-injection (severity: high)

Two run: blocks in ci.yml directly interpolate ${{ }} expressions into shell commands. (a) The 'Validate commit messages' step uses `${{ github.event.pull_request.base.sha }}` and `${{ github.event.pull_request.head.sha }}` as arguments to npx commitlint — these are PR-event values that could be attacker-controlled on pull_request events. (b) The 'Verify all jobs passed or were skipped' step in the ci-result job embeds `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` directly inside an if [[ ... ]] shell test, which is evaluated by the shell after YAML template substitution.

Locations:

- `.github/workflows/ci.yml:57`
- `.github/workflows/ci.yml:58`
- `.github/workflows/ci.yml:270`

### script-injection (severity: high)

Multiple run: blocks in release.yml directly interpolate `${{ github.repository }}` into shell command strings (inside gh api URL arguments). While github.repository is not directly attacker-controlled, any ${{ }} expression interpolated directly into a run: shell command is a script-injection risk per the check rules, as the value flows through YAML template substitution before the shell parses it. Affected steps: 'Verify tag is signed' (two gh api calls), 'Move floating minor tag to current release' (three gh api calls), and 'Download SHA256 checksums' (one gh api call).

Locations:

- `.github/workflows/release.yml:51`
- `.github/workflows/release.yml:57`
- `.github/workflows/release.yml:155`
- `.github/workflows/release.yml:163`
- `.github/workflows/release.yml:175`
- `.github/workflows/release.yml:183`
- `.github/workflows/release.yml:230`

### github-env-injection (severity: high)

The 'Resolve release tag' step in build-and-attest.yml writes workflow-controlled values to $GITHUB_ENV without sanitization. The env vars INPUT_TAG_NAME (from ${{ inputs.tag_name }}) and REF_NAME (from ${{ github.ref_name }}) are written directly with `echo "RELEASE_TAG=$INPUT_TAG_NAME" >> "$GITHUB_ENV"` and `echo "RELEASE_TAG=$REF_NAME" >> "$GITHUB_ENV"`. A calling workflow can supply a tag_name containing newlines to inject arbitrary environment variables into subsequent steps. The required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`) is absent.

Locations:

- `.github/workflows/build-and-attest.yml:63`
- `.github/workflows/build-and-attest.yml:65`

### github-env-injection (severity: high)

The 'Extract version from tag or input' step in release.yml writes workflow-controlled values to $GITHUB_ENV without sanitization. The variables VERSION and TAG are derived from ${{ inputs.version }}, ${{ inputs.tag_name }}, or GITHUB_REF (all workflow-dispatch or tag-push controlled), and written with `echo "VERSION=$VERSION" >> "$GITHUB_ENV"` and `echo "TAG=$TAG" >> "$GITHUB_ENV"`. A malicious actor with write access to trigger workflow_dispatch could supply a version or tag_name containing newlines to inject arbitrary environment variables. The required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`) is absent.

Locations:

- `.github/workflows/release.yml:110`
- `.github/workflows/release.yml:111`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all 5 findings across 3 workflow files:

**build-and-attest.yml:**
- github-env-injection: Added `printf '%s' "$VAR" | tr -d '\n\r'` sanitization before writing INPUT_TAG_NAME and REF_NAME to GITHUB_ENV in 'Resolve release tag' step.
- script-injection (7 locations): Moved `${{ inputs.target }}` into TARGET env var for 'Build binary (dry-run)', 'Generate aptu .deb package', 'Upload aptu .deb to release', 'Sign aptu .deb with cosign', and 'Upload aptu .deb .bundle to release' steps. Moved `${{ steps.upload-cli.outputs.tar }}` into TAR_PATH env var for 'Sign tarball with cosign' and 'Upload tarball .bundle to release' steps.

**ci.yml:**
- script-injection: Moved `${{ github.event.pull_request.base.sha }}` and `${{ github.event.pull_request.head.sha }}` into BASE_SHA/HEAD_SHA env vars in 'Validate commit messages' step. Moved `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` into ANY_FAILED env var in 'Verify all jobs passed or were skipped' step.

**release.yml:**
- github-env-injection: Added `printf '%s' "$VAR" | tr -d '\n\r'` sanitization before writing VERSION and TAG to GITHUB_ENV in 'Extract version from tag or input' step.
- script-injection (7 locations): Added GH_REPO env var set to `${{ github.repository }}` in 'Verify tag is signed', 'Move floating minor tag to current release', and 'Download SHA256 checksums' steps, replacing all inline `${{ github.repository }}` interpolations with `$GH_REPO`.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed three unquoted `$RELEASE_TAG` expansions in `.github/workflows/build-and-attest.yml` by quoting them as `"$RELEASE_TAG"` in all three `gh release upload` commands:
1. Line ~97: `gh release upload "$RELEASE_TAG" "${TAR_PATH}.bundle" --clobber` (Upload tarball .bundle to release)
2. Line ~113: `gh release upload "$RELEASE_TAG" "$DEB_FILE" --clobber` (Upload aptu .deb to release)
3. Line ~131: `gh release upload "$RELEASE_TAG" "$DEB_FILE.bundle" --clobber` (Upload aptu .deb .bundle to release)

This prevents shell metacharacters (spaces, semicolons, etc.) in the tag name from being interpreted by the shell, closing the script injection vector.

