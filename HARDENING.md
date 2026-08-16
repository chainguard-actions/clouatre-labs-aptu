<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.9.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.9.0** was hardened automatically. 5 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple ${{ ... }} expressions are interpolated directly inside run: shell commands in build-and-attest.yml. Specifically: (1) `cargo build --release --target ${{ inputs.target }} -p aptu-cli` — inputs.target injected directly into shell; (2) `cosign sign-blob --yes --bundle "${{ steps.upload-cli.outputs.tar }}.bundle" "${{ steps.upload-cli.outputs.tar }}"` — steps output injected directly into shell; (3) `cargo deb --target ${{ inputs.target }} --no-build --package aptu-cli` — inputs.target injected directly; (4) `find target/${{ inputs.target }}/debian ...` — inputs.target injected directly (appears in three separate run: blocks). These allow an attacker who controls the workflow inputs to inject arbitrary shell commands.

Locations:

- `.github/workflows/build-and-attest.yml:72`
- `.github/workflows/build-and-attest.yml:76`
- `.github/workflows/build-and-attest.yml:90`
- `.github/workflows/build-and-attest.yml:100`
- `.github/workflows/build-and-attest.yml:110`
- `.github/workflows/build-and-attest.yml:120`

### script-injection (severity: high)

Sub-rule (a): A ${{ ... }} expression is interpolated directly inside a run: shell command in ci.yml. The step 'Verify all jobs passed or were skipped' uses `if [[ "${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}" == "true" ]]` — the needs.*.result context is expanded by the template engine before the shell sees it, allowing injection of shell metacharacters.

Locations:

- `.github/workflows/ci.yml:228`

### script-injection (severity: high)

Sub-rule (a): ${{ github.repository }} is interpolated directly inside run: shell commands in release.yml. It appears in multiple gh api calls such as `gh api "repos/${{ github.repository }}/git/refs/tags/$TAG"` and `gh api "repos/${{ github.repository }}/git/refs"`. While github.repository is GitHub-controlled, any ${{ ... }} expression directly in a run: block is a script-injection risk as the value is substituted by the template engine before the shell parses it.

Locations:

- `.github/workflows/release.yml:55`
- `.github/workflows/release.yml:60`
- `.github/workflows/release.yml:118`
- `.github/workflows/release.yml:122`
- `.github/workflows/release.yml:130`
- `.github/workflows/release.yml:134`
- `.github/workflows/release.yml:175`

### github-env-injection (severity: high)

The 'Resolve release tag' step in build-and-attest.yml writes untrusted input values to $GITHUB_ENV without sanitization. INPUT_TAG_NAME (sourced from ${{ inputs.tag_name }}) and REF_NAME (sourced from ${{ github.ref_name }}) are written via `echo "RELEASE_TAG=$INPUT_TAG_NAME" >> "$GITHUB_ENV"` and `echo "RELEASE_TAG=$REF_NAME" >> "$GITHUB_ENV"`. Neither value is passed through `printf '%s' ... | tr -d '\n\r'` before the write, allowing newline injection to set arbitrary environment variables for subsequent steps.

Locations:

- `.github/workflows/build-and-attest.yml:57`
- `.github/workflows/build-and-attest.yml:59`

### github-env-injection (severity: high)

The 'Extract version from tag or input' step in release.yml writes untrusted input values to $GITHUB_ENV without sanitization. VERSION and TAG are derived from ${{ inputs.version }}, ${{ inputs.tag_name }}, and ${{ github.ref_name }} (via env vars INPUT_VERSION, INPUT_TAG_NAME, EVENT_NAME), then written via `echo "VERSION=$VERSION" >> "$GITHUB_ENV"` and `echo "TAG=$TAG" >> "$GITHUB_ENV"` without the required `printf '%s' ... | tr -d '\n\r'` sanitization step, allowing newline injection.

Locations:

- `.github/workflows/release.yml:96`
- `.github/workflows/release.yml:97`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all script-injection and github-env-injection findings across three workflow files:

1. build-and-attest.yml (script-injection): Moved inputs.target into TARGET env var for 'Build binary (dry-run)', 'Generate aptu .deb package', 'Upload aptu .deb to release', 'Sign aptu .deb with cosign', and 'Upload aptu .deb .bundle to release' steps. Moved steps.upload-cli.outputs.tar into TAR_PATH env var for 'Sign tarball with cosign' and 'Upload tarball .bundle to release' steps.

2. build-and-attest.yml (github-env-injection): Added printf '%s' ... | tr -d '\n\r' sanitization for INPUT_TAG_NAME and REF_NAME before writing to $GITHUB_ENV in the 'Resolve release tag' step.

3. ci.yml (script-injection): Moved contains(needs.*.result, ...) expression into HAS_FAILURE env var in the 'Verify all jobs passed or were skipped' step.

4. release.yml (script-injection): Moved github.repository into GH_REPO env var in three steps: 'Verify tag is signed', 'Move floating minor tag to current release', and 'Download SHA256 checksums'.

5. release.yml (github-env-injection): Added printf '%s' ... | tr -d '\n\r' sanitization for VERSION and TAG before writing to $GITHUB_ENV in the 'Extract version from tag or input' step.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings:
1. hardened/action/.github/workflows/ci.yml: Moved `${{ github.event.pull_request.base.sha }}` and `${{ github.event.pull_request.head.sha }}` from the `run:` block into an `env:` block (as BASE_SHA and HEAD_SHA), then referenced them as double-quoted shell variables `"$BASE_SHA"` and `"$HEAD_SHA"` in the npx commitlint command.
2. hardened/action/.github/workflows/build-and-attest.yml: Quoted all three unquoted `$RELEASE_TAG` expansions in `gh release upload` commands → `"$RELEASE_TAG"`, preventing word splitting and glob expansion on the workflow-controllable tag name value.

