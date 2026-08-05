<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.8

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.8** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple run: blocks in build-and-attest.yml directly interpolate ${{ }} expressions inside shell commands. Specifically: (1) `cargo build --release --target ${{ inputs.target }} -p aptu-cli` — inputs.target flows through YAML template substitution before the shell sees it; (2) `cosign sign-blob --yes --bundle "${{ steps.upload-cli.outputs.tar }}.bundle" "${{ steps.upload-cli.outputs.tar }}"` — steps.*.outputs.* interpolated directly; (3) `gh release upload $RELEASE_TAG "${{ steps.upload-cli.outputs.tar }}.bundle"` — same; (4) `cargo deb --target ${{ inputs.target }}` — same; (5) `find target/${{ inputs.target }}/debian` — appears in three separate run: blocks. All of these are annotated with `# zizmor: ignore[template-injection]` but remain genuine script-injection risks per the check rules.

Locations:

- `.github/workflows/build-and-attest.yml:88`
- `.github/workflows/build-and-attest.yml:91`
- `.github/workflows/build-and-attest.yml:96`
- `.github/workflows/build-and-attest.yml:103`
- `.github/workflows/build-and-attest.yml:108`
- `.github/workflows/build-and-attest.yml:115`
- `.github/workflows/build-and-attest.yml:122`

### script-injection (severity: high)

Sub-rule (a): Two run: blocks in ci.yml directly interpolate ${{ }} expressions inside shell commands. (1) The 'Validate commit messages' step uses `--from ${{ github.event.pull_request.base.sha }} \ --to ${{ github.event.pull_request.head.sha }}` — github.* context values are interpolated directly into the npx commitlint invocation. (2) The 'Verify all jobs passed or were skipped' step uses `if [[ "${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}" == "true" ]]` — a ${{ }} expression is interpolated directly inside a shell conditional string.

Locations:

- `.github/workflows/ci.yml:82`
- `.github/workflows/ci.yml:130`

### github-env-injection (severity: high)

The 'Resolve release tag' step writes workflow-controlled values to $GITHUB_ENV without sanitization. `INPUT_TAG_NAME` is sourced from `${{ inputs.tag_name }}` (a workflow_call input) and `REF_NAME` from `${{ github.ref_name }}`. Both are written directly: `echo "RELEASE_TAG=$INPUT_TAG_NAME" >> "$GITHUB_ENV"` and `echo "RELEASE_TAG=$REF_NAME" >> "$GITHUB_ENV"`. A newline in either value would allow injection of arbitrary environment variables into subsequent steps. The required sanitization step (`printf '%s' ... | tr -d '\n\r'`) is absent.

Locations:

- `.github/workflows/build-and-attest.yml:60`
- `.github/workflows/build-and-attest.yml:62`

### github-env-injection (severity: high)

The 'Extract version from tag or input' step in release.yml writes workflow-controlled values to $GITHUB_ENV without sanitization. `VERSION` and `TAG` are derived from `inputs.version` and `inputs.tag_name` (workflow_dispatch inputs) via env vars `INPUT_VERSION` and `INPUT_TAG_NAME`, then written as `echo "VERSION=$VERSION" >> "$GITHUB_ENV"` and `echo "TAG=$TAG" >> "$GITHUB_ENV"`. A newline embedded in either input would allow injection of arbitrary environment variables into subsequent steps. The required sanitization step (`printf '%s' ... | tr -d '\n\r'`) is absent.

Locations:

- `.github/workflows/release.yml:95`
- `.github/workflows/release.yml:96`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all 4 findings across 3 workflow files:

1. build-and-attest.yml script-injection (7 locations): Moved all ${{ inputs.target }} and ${{ steps.upload-cli.outputs.tar }} expressions out of run: shell strings into step env: blocks, referencing them as $INPUT_TARGET and $UPLOAD_TAR respectively. Removed # zizmor: ignore[template-injection] comments.

2. ci.yml script-injection (2 locations): (a) 'Validate commit messages' - moved github.event.pull_request.base.sha and head.sha to BASE_SHA/HEAD_SHA env vars; (b) 'Verify all jobs passed or were skipped' - moved the contains(needs.*.result, ...) boolean expression to HAS_FAILURE env var.

3. build-and-attest.yml github-env-injection: 'Resolve release tag' step now sanitizes INPUT_TAG_NAME and REF_NAME with `printf '%s' "$VAR" | tr -d '\n\r'` before writing to GITHUB_ENV.

4. release.yml github-env-injection: 'Extract version from tag or input' step now sanitizes VERSION and TAG with `printf '%s' "$VAR" | tr -d '\n\r'` before writing to GITHUB_ENV.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed all three script-injection findings in hardened/action/.github/workflows/release.yml by moving `${{ github.repository }}` out of `run:` shell strings and into each step's `env:` block as `REPOSITORY: ${{ github.repository }}`. The shell scripts now reference `$REPOSITORY` as a plain environment variable. Affected steps: (1) 'Verify tag is signed' — two gh api calls updated; (2) 'Move floating minor tag to current release' — three gh api calls updated; (3) 'Download SHA256 checksums' — one gh api call updated.

