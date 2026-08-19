<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.11

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.11** was hardened automatically. 5 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in build-and-attest.yml directly interpolate `${{ inputs.target }}` and `${{ steps.upload-cli.outputs.tar }}` into shell commands (sub-rule a). These expressions flow through YAML template substitution before the shell parses them, enabling command injection if a malicious caller passes a crafted value. Affected lines include:
- `run: cargo build --release --target ${{ inputs.target }} -p aptu-cli`
- `cosign sign-blob --yes --bundle "${{ steps.upload-cli.outputs.tar }}.bundle" "${{ steps.upload-cli.outputs.tar }}"`
- `gh release upload $RELEASE_TAG "${{ steps.upload-cli.outputs.tar }}.bundle" --clobber`
- `run: cargo deb --target ${{ inputs.target }} --no-build --package aptu-cli`
- `DEB_FILE=$(find target/${{ inputs.target }}/debian ...)` (three occurrences)
The `# zizmor: ignore[template-injection]` comments do not mitigate the risk. All these values should be passed via `env:` variables and referenced as `"$VAR"` in the shell.

Locations:

- `.github/workflows/build-and-attest.yml:96`
- `.github/workflows/build-and-attest.yml:100`
- `.github/workflows/build-and-attest.yml:107`
- `.github/workflows/build-and-attest.yml:119`
- `.github/workflows/build-and-attest.yml:124`
- `.github/workflows/build-and-attest.yml:131`
- `.github/workflows/build-and-attest.yml:139`

### script-injection (severity: high)

Two `run:` blocks in ci.yml directly interpolate GitHub Actions expressions into shell commands (sub-rule a):
1. The `commitlint` job's `run:` block uses `${{ github.event.pull_request.base.sha }}` and `${{ github.event.pull_request.head.sha }}` as unquoted arguments to `npx commitlint --from ... --to ...`. Any `${{ }}` expression inside a `run:` block is a script-injection risk regardless of context.
2. The `ci-result` job's `run:` block embeds `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` directly inside a shell string comparison. These should be moved to `env:` variables and referenced as `"$VAR"`.

Locations:

- `.github/workflows/ci.yml:79`
- `.github/workflows/ci.yml:80`
- `.github/workflows/ci.yml:330`

### script-injection (severity: high)

Multiple `run:` blocks in release.yml directly interpolate `${{ github.repository }}` into shell commands passed to `gh api` (sub-rule a). Although `github.repository` is GitHub-controlled, any `${{ }}` expression inside a `run:` block undergoes YAML template substitution before the shell parses it and is a script-injection finding. Affected steps: 'Verify tag is signed' (two occurrences), 'Move floating minor tag to current release' (two occurrences), and 'Download SHA256 checksums'. These should be passed via `env: REPO: ${{ github.repository }}` and referenced as `"$REPO"` in the shell.

Locations:

- `.github/workflows/release.yml:50`
- `.github/workflows/release.yml:55`
- `.github/workflows/release.yml:196`
- `.github/workflows/release.yml:201`
- `.github/workflows/release.yml:257`

### github-env-injection (severity: high)

The 'Resolve release tag' step in build-and-attest.yml writes untrusted input values to `$GITHUB_ENV` without sanitization. `INPUT_TAG_NAME` (sourced from `inputs.tag_name`, a workflow_call string input) and `REF_NAME` (sourced from `github.ref_name`) are written directly via `echo "RELEASE_TAG=$INPUT_TAG_NAME" >> "$GITHUB_ENV"` and `echo "RELEASE_TAG=$REF_NAME" >> "$GITHUB_ENV"`. A newline character in either value could inject arbitrary environment variables into subsequent steps. The fix is to sanitize with `safe=$(printf '%s' "$INPUT_TAG_NAME" | tr -d '\n\r')` before writing.

Locations:

- `.github/workflows/build-and-attest.yml:62`
- `.github/workflows/build-and-attest.yml:64`

### github-env-injection (severity: high)

The 'Extract version from tag or input' step in release.yml writes values derived from workflow_dispatch inputs to `$GITHUB_ENV` without sanitization. `VERSION` and `TAG` are derived from `INPUT_VERSION` (sourced from `inputs.version`) and `INPUT_TAG_NAME` (sourced from `inputs.tag_name`) and written via `echo "VERSION=$VERSION" >> "$GITHUB_ENV"` and `echo "TAG=$TAG" >> "$GITHUB_ENV"`. A newline character in a workflow_dispatch input could inject arbitrary environment variables into subsequent steps. The fix is to sanitize each value with `printf '%s' "$VERSION" | tr -d '\n\r'` before writing.

Locations:

- `.github/workflows/release.yml:108`
- `.github/workflows/release.yml:109`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all 5 findings across 3 workflow files:

1. build-and-attest.yml script-injection: Moved `${{ inputs.target }}` into env var TARGET and `${{ steps.upload-cli.outputs.tar }}` into env var UPLOAD_TAR in all affected run: blocks (Build binary dry-run, Sign tarball, Upload tarball bundle, Generate deb, Upload deb, Sign deb, Upload deb bundle). Removed zizmor:ignore comments.

2. ci.yml script-injection: Moved `${{ github.event.pull_request.base.sha }}` and `${{ github.event.pull_request.head.sha }}` into env vars BASE_SHA/HEAD_SHA in the commitlint step. Moved `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` into env var ANY_FAILED in the ci-result step.

3. release.yml script-injection: Moved `${{ github.repository }}` into env var REPO in the 'Verify tag is signed' step (2 occurrences), 'Move floating minor tag to current release' step (2 occurrences), and 'Download SHA256 checksums' step (1 occurrence).

4. build-and-attest.yml github-env-injection: Added `safe=$(printf '%s' "$VAR" | tr -d '\n\r')` sanitization before writing INPUT_TAG_NAME and REF_NAME to GITHUB_ENV in the 'Resolve release tag' step.

5. release.yml github-env-injection: Added `safe_version` and `safe_tag` sanitization with `printf '%s' | tr -d '\n\r'` before writing VERSION and TAG to GITHUB_ENV in the 'Extract version from tag or input' step.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed three occurrences of unquoted `$RELEASE_TAG` in `gh release upload` commands in `.github/workflows/build-and-attest.yml` (lines 108, 127, 148). Changed `gh release upload $RELEASE_TAG ...` to `gh release upload "$RELEASE_TAG" ...` in all three locations: the tarball bundle upload step, the .deb upload step, and the .deb bundle upload step. The variable was already sanitized for newlines but needed quoting to prevent shell metacharacter injection from the `inputs.tag_name` workflow input.

