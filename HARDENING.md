<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.2** was hardened automatically. 5 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): ${{ github.event.pull_request.base.sha }} and ${{ github.event.pull_request.head.sha }} are interpolated directly inside a run: shell command in the 'Validate commit messages' step. Any ${{ ... }} expression in a run: block is a script-injection risk because the value is substituted into the shell command string before the shell parses it.

Locations:

- `.github/workflows/ci.yml:68`

### script-injection (severity: high)

Sub-rule (a): ${{ inputs.target }} is interpolated directly inside run: shell commands in multiple steps: 'Build binary (dry-run)' (run: cargo build --release --target ${{ inputs.target }} ...), 'Generate aptu .deb package' (run: cargo deb --target ${{ inputs.target }} ...), 'Upload aptu .deb to release' (DEB_FILE=$(find target/${{ inputs.target }}/debian ...)), 'Sign aptu .deb with cosign' (same pattern), and 'Upload aptu .deb .bundle to release' (same pattern). These are workflow_call inputs that flow through YAML template substitution before the shell parses them.

Locations:

- `.github/workflows/build-and-attest.yml:82`
- `.github/workflows/build-and-attest.yml:107`
- `.github/workflows/build-and-attest.yml:116`
- `.github/workflows/build-and-attest.yml:126`
- `.github/workflows/build-and-attest.yml:136`

### script-injection (severity: high)

Sub-rule (a): ${{ github.repository }} is interpolated directly inside run: shell commands in multiple steps in release.yml: 'Verify tag is signed' (REF_JSON="$(gh api "repos/${{ github.repository }}/git/refs/tags/$TAG")"), 'Move floating minor tag to current release' (multiple gh api calls with ${{ github.repository }}), and 'Download SHA256 checksums' (gh api "repos/${{ github.repository }}/releases/..."). Any ${{ ... }} expression in a run: block is a script-injection risk.

Locations:

- `.github/workflows/release.yml:52`
- `.github/workflows/release.yml:59`
- `.github/workflows/release.yml:152`
- `.github/workflows/release.yml:157`
- `.github/workflows/release.yml:167`
- `.github/workflows/release.yml:172`
- `.github/workflows/release.yml:200`

### github-env-injection (severity: high)

In the 'Resolve release tag' step, INPUT_TAG_NAME (sourced from ${{ inputs.tag_name }}) and REF_NAME (sourced from ${{ github.ref_name }}) are written directly to $GITHUB_ENV without the required sanitization step (printf '%s' ... | tr -d '\n\r'). An attacker-controlled newline in these values could inject arbitrary environment variables into subsequent steps.

Locations:

- `.github/workflows/build-and-attest.yml:57`
- `.github/workflows/build-and-attest.yml:59`

### github-env-injection (severity: high)

In the 'Extract version from tag or input' step, VERSION and TAG are derived from INPUT_VERSION (${{ inputs.version }}) and INPUT_TAG_NAME (${{ inputs.tag_name }}) — both workflow_dispatch inputs — and written directly to $GITHUB_ENV without the required sanitization step (printf '%s' ... | tr -d '\n\r'). A newline embedded in these inputs could inject arbitrary environment variables into subsequent steps.

Locations:

- `.github/workflows/release.yml:91`
- `.github/workflows/release.yml:92`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all 5 findings across 3 workflow files:

1. ci.yml: Moved github.event.pull_request.base.sha and github.event.pull_request.head.sha into BASE_SHA/HEAD_SHA env vars in 'Validate commit messages' step.

2. build-and-attest.yml (script-injection): Moved inputs.target into TARGET env var in 5 steps: 'Build binary (dry-run)', 'Generate aptu .deb package', 'Upload aptu .deb to release', 'Sign aptu .deb with cosign', 'Upload aptu .deb .bundle to release'.

3. build-and-attest.yml (github-env-injection): Added printf/tr sanitization in 'Resolve release tag' step before writing INPUT_TAG_NAME and REF_NAME to GITHUB_ENV.

4. release.yml (script-injection): Moved github.repository into GH_REPOSITORY env var in 3 steps: 'Verify tag is signed', 'Move floating minor tag to current release', 'Download SHA256 checksums'.

5. release.yml (github-env-injection): Added printf/tr sanitization in 'Extract version from tag or input' step before writing VERSION and TAG to GITHUB_ENV.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings:
1. build-and-attest.yml: Moved `${{ steps.upload-cli.outputs.tar }}` out of both `run:` shell strings (Sign tarball with cosign and Upload tarball .bundle to release steps) into `env:` blocks as `UPLOAD_TAR`. Shell commands now use `${UPLOAD_TAR}` as a plain env var. Removed the `# zizmor: ignore[template-injection]` suppression comments since the issue is now properly fixed.
2. ci.yml: Moved `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` out of the `run:` shell string in the ci-result job into an `env:` block as `ANY_FAILED`. The shell script now references `$ANY_FAILED` as a plain env var.

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed three instances of unquoted $RELEASE_TAG in .github/workflows/build-and-attest.yml: (1) 'gh release upload $RELEASE_TAG "${UPLOAD_TAR}.bundle" --clobber' → quoted as '"$RELEASE_TAG"'; (2) 'gh release upload $RELEASE_TAG "$DEB_FILE" --clobber' → quoted; (3) 'gh release upload $RELEASE_TAG "$DEB_FILE.bundle" --clobber' → quoted. All three gh release upload commands now properly double-quote the variable to prevent shell metacharacter injection.

