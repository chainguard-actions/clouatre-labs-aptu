<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.7

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.7** was hardened automatically. 5 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): Multiple `${{ }}` expressions are interpolated directly inside `run:` shell command strings in build-and-attest.yml. Specifically: (1) `run: cargo build --release --target ${{ inputs.target }} -p aptu-cli` — `inputs.target` is injected directly into the shell command; (2) `cosign sign-blob --yes --bundle "${{ steps.upload-cli.outputs.tar }}.bundle" "${{ steps.upload-cli.outputs.tar }}"` — step output injected directly; (3) `gh release upload $RELEASE_TAG "${{ steps.upload-cli.outputs.tar }}.bundle" --clobber` — step output injected directly; (4) `run: cargo deb --target ${{ inputs.target }} --no-build --package aptu-cli` — inputs.target injected directly; (5) `DEB_FILE=$(find target/${{ inputs.target }}/debian ...)` — inputs.target injected directly (appears in three separate steps). These allow an attacker who controls the workflow inputs to inject arbitrary shell commands.

Locations:

- `.github/workflows/build-and-attest.yml:88`
- `.github/workflows/build-and-attest.yml:91`
- `.github/workflows/build-and-attest.yml:97`
- `.github/workflows/build-and-attest.yml:107`
- `.github/workflows/build-and-attest.yml:113`
- `.github/workflows/build-and-attest.yml:120`
- `.github/workflows/build-and-attest.yml:128`

### script-injection (severity: high)

Rule (a): `${{ github.event.pull_request.base.sha }}` and `${{ github.event.pull_request.head.sha }}` are interpolated directly inside a `run:` shell command in the 'Validate commit messages' step: `npx commitlint --from ${{ github.event.pull_request.base.sha }} --to ${{ github.event.pull_request.head.sha }} --verbose`. These are attacker-controlled values from the pull_request event that flow through YAML template substitution before the shell sees them. Additionally, in the 'Verify all jobs passed or were skipped' step (ci-result job), `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` is interpolated directly inside an `if [[ ... ]]` shell construct.

Locations:

- `.github/workflows/ci.yml:74`
- `.github/workflows/ci.yml:75`
- `.github/workflows/ci.yml:310`

### script-injection (severity: high)

Rule (a): `${{ github.repository }}` is interpolated directly inside `run:` shell command strings in multiple steps of release.yml. In the 'Verify tag is signed' step: `gh api "repos/${{ github.repository }}/git/refs/tags/$TAG"` and `gh api "repos/${{ github.repository }}/git/tags/$TAG_SHA"`. In the 'Move floating minor tag to current release' step: multiple `gh api "repos/${{ github.repository }}/..."` calls. In the 'Download SHA256 checksums' step: `gh api "repos/${{ github.repository }}/releases/tags/${RELEASE_TAG}"`. Although `github.repository` is typically not attacker-controlled, any `${{ ... }}` expression directly in a `run:` block is a script-injection finding per the check rules.

Locations:

- `.github/workflows/release.yml:47`
- `.github/workflows/release.yml:55`
- `.github/workflows/release.yml:152`
- `.github/workflows/release.yml:160`
- `.github/workflows/release.yml:196`
- `.github/workflows/release.yml:204`
- `.github/workflows/release.yml:211`
- `.github/workflows/release.yml:247`

### github-env-injection (severity: high)

The 'Resolve release tag' step in build-and-attest.yml writes untrusted input values to $GITHUB_ENV without sanitization. `INPUT_TAG_NAME` (sourced from `inputs.tag_name`, a workflow_call input) is written as `echo "RELEASE_TAG=$INPUT_TAG_NAME" >> "$GITHUB_ENV"`, and `REF_NAME` (sourced from `github.ref_name`) is written as `echo "RELEASE_TAG=$REF_NAME" >> "$GITHUB_ENV"`. Neither value is passed through `printf '%s' ... | tr -d '\n\r'` before the write. A newline in either value would allow injection of additional environment variables.

Locations:

- `.github/workflows/build-and-attest.yml:62`
- `.github/workflows/build-and-attest.yml:64`

### github-env-injection (severity: high)

The 'Extract version from tag or input' step in release.yml writes untrusted workflow_dispatch input values to $GITHUB_ENV without sanitization. `VERSION` (derived from `inputs.version` via env var `INPUT_VERSION`) is written as `echo "VERSION=$VERSION" >> "$GITHUB_ENV"`, and `TAG` (derived from `inputs.tag_name` via env var `INPUT_TAG_NAME`) is written as `echo "TAG=$TAG" >> "$GITHUB_ENV"`. Neither value is sanitized with `printf '%s' ... | tr -d '\n\r'` before the write. An attacker with workflow_dispatch access could inject newlines to set arbitrary environment variables.

Locations:

- `.github/workflows/release.yml:101`
- `.github/workflows/release.yml:102`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all script-injection and github-env-injection findings across three workflow files:

1. build-and-attest.yml (github-env-injection): Sanitized INPUT_TAG_NAME and REF_NAME with `printf '%s' ... | tr -d '\n\r'` before writing to $GITHUB_ENV in the 'Resolve release tag' step.

2. build-and-attest.yml (script-injection): Moved all ${{ inputs.target }} and ${{ steps.upload-cli.outputs.tar }} expressions out of run: blocks into step-level env: blocks (INPUT_TARGET and UPLOAD_TAR variables) across 7 steps: 'Build binary (dry-run)', 'Sign tarball with cosign', 'Upload tarball .bundle to release', 'Generate aptu .deb package', 'Upload aptu .deb to release', 'Sign aptu .deb with cosign', 'Upload aptu .deb .bundle to release'.

3. ci.yml (script-injection): Moved ${{ github.event.pull_request.base.sha }} and ${{ github.event.pull_request.head.sha }} into BASE_SHA/HEAD_SHA env vars in 'Validate commit messages'. Moved the ${{ contains(needs.*.result, ...) }} expression into HAS_FAILURE env var in 'Verify all jobs passed or were skipped'.

4. release.yml (github-env-injection): Sanitized VERSION and TAG with `printf '%s' ... | tr -d '\n\r'` before writing to $GITHUB_ENV in 'Extract version from tag or input'.

5. release.yml (script-injection): Moved ${{ github.repository }} into GITHUB_REPOSITORY_NAME env var in 'Verify tag is signed' (2 occurrences), 'Move floating minor tag to current release' (6 occurrences), and 'Download SHA256 checksums' (1 occurrence).

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed three instances of unquoted `$RELEASE_TAG` in `gh release upload` commands in `.github/workflows/build-and-attest.yml` (lines 108, 127, 143). Changed `gh release upload $RELEASE_TAG ...` to `gh release upload "$RELEASE_TAG" ...` in all three steps: 'Upload tarball .bundle to release', 'Upload aptu .deb to release', and 'Upload aptu .deb .bundle to release'. This prevents word-splitting and command injection from crafted tag names containing shell metacharacters such as spaces or semicolons.

