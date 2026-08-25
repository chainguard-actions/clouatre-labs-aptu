<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.14

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.14** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): ${{ }} expressions are directly interpolated inside run: shell commands in multiple workflow files.

• ci.yml — 'commitlint' step: `--from ${{ github.event.pull_request.base.sha }}` and `--to ${{ github.event.pull_request.head.sha }}` are interpolated directly into the npx commitlint command. An attacker who controls the PR base/head SHA string could inject shell metacharacters.

• ci.yml — 'ci-result' step: `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` is interpolated directly inside a double-quoted string in a run: block.

• build-and-attest.yml — 'Build binary (dry-run)' step: `cargo build --release --target ${{ inputs.target }}` — the workflow_call input `target` is interpolated directly into the shell command.

• build-and-attest.yml — 'Sign tarball with cosign' step: `${{ steps.upload-cli.outputs.tar }}` is interpolated directly into the cosign command string.

• build-and-attest.yml — 'Upload tarball .bundle to release', 'Generate aptu .deb package', 'Sign aptu .deb with cosign', 'Upload aptu .deb to release', 'Upload aptu .deb .bundle to release' steps: `${{ inputs.target }}` and `${{ steps.upload-cli.outputs.tar }}` are interpolated directly into run: shell commands.

• release.yml — 'Verify tag is signed' step: `gh api "repos/${{ github.repository }}/git/refs/tags/$TAG"` and `gh api "repos/${{ github.repository }}/git/tags/$TAG_SHA"` — `github.repository` is interpolated directly into shell commands.

• release.yml — 'update-marketplace-tag' step: `gh api "repos/${{ github.repository }}/git/refs/tags/$MINOR_TAG"` and related gh api calls — `github.repository` is interpolated directly into shell commands.

• release.yml — 'update-homebrew' step: `gh api "repos/${{ github.repository }}/releases/tags/${RELEASE_TAG}"` — `github.repository` is interpolated directly into a shell command.

• scorecard.yml — 'Run OpenSSF Scorecard' step: `./scorecard --repo=github.com/${{ github.repository }}` — `github.repository` is interpolated directly into the shell command.

• security.yml — 'security-result' step: `for result in "${{ needs.secrets.result }}" "${{ needs.zizmor.result }}" "${{ needs.poutine.result }}"` — needs context values are interpolated directly into a shell for-loop.

Locations:

- `.github/workflows/ci.yml:60`
- `.github/workflows/ci.yml:290`
- `.github/workflows/build-and-attest.yml:77`
- `.github/workflows/build-and-attest.yml:82`
- `.github/workflows/build-and-attest.yml:88`
- `.github/workflows/build-and-attest.yml:97`
- `.github/workflows/release.yml:45`
- `.github/workflows/release.yml:185`
- `.github/workflows/release.yml:225`
- `.github/workflows/scorecard.yml:38`
- `.github/workflows/security.yml:80`

### github-env-injection (severity: high)

Untrusted input values are written to $GITHUB_ENV without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`).

• build-and-attest.yml — 'Resolve release tag' step: `INPUT_TAG_NAME` (sourced from `inputs.tag_name`) and `REF_NAME` (sourced from `github.ref_name`) are written directly to $GITHUB_ENV via `echo "RELEASE_TAG=$INPUT_TAG_NAME" >> "$GITHUB_ENV"` and `echo "RELEASE_TAG=$REF_NAME" >> "$GITHUB_ENV"`. A caller workflow can supply a `tag_name` containing newlines to inject arbitrary environment variables.

• release.yml — 'Extract version from tag or input' step: `VERSION` and `TAG` are derived from `$INPUT_VERSION` and `$INPUT_TAG_NAME` (both sourced from `inputs.version` and `inputs.tag_name` respectively) and written to $GITHUB_ENV via `echo "VERSION=$VERSION" >> "$GITHUB_ENV"` and `echo "TAG=$TAG" >> "$GITHUB_ENV"` without sanitization. A workflow_dispatch caller can supply a version or tag_name containing newlines to inject arbitrary environment variables.

Locations:

- `.github/workflows/build-and-attest.yml:60`
- `.github/workflows/build-and-attest.yml:62`
- `.github/workflows/release.yml:100`
- `.github/workflows/release.yml:101`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all script-injection and github-env-injection findings across 5 workflow files:

**script-injection fixes:**
- ci.yml: Moved PR base/head SHA expressions to env block in commitlint step; moved contains() expression to env block in ci-result step
- build-and-attest.yml: Moved inputs.target to env block (INPUT_TARGET) in Build binary (dry-run), Generate aptu .deb package, Upload aptu .deb to release, Sign aptu .deb with cosign, Upload aptu .deb .bundle to release steps; moved steps.upload-cli.outputs.tar to env block (TAR_PATH) in Sign tarball with cosign and Upload tarball .bundle to release steps
- release.yml: Moved github.repository to env block (GITHUB_REPOSITORY) in Verify tag is signed, update-marketplace-tag, and update-homebrew steps
- scorecard.yml: Moved github.repository to env block (GITHUB_REPOSITORY) in Run OpenSSF Scorecard step
- security.yml: Moved needs.*.result values to env block (SECRETS_RESULT, ZIZMOR_RESULT, POUTINE_RESULT) in security-result step

**github-env-injection fixes:**
- build-and-attest.yml: Added printf '%s' ... | tr -d '\n\r' sanitization before writing INPUT_TAG_NAME and REF_NAME to $GITHUB_ENV in Resolve release tag step
- release.yml: Added printf '%s' ... | tr -d '\n\r' sanitization before writing VERSION and TAG to $GITHUB_ENV in Extract version from tag or input step

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed all three instances of unquoted $RELEASE_TAG in gh release upload commands in .github/workflows/build-and-attest.yml (lines 68, 85, 101). Changed `gh release upload $RELEASE_TAG ...` to `gh release upload "$RELEASE_TAG" ...` in: (1) the tarball bundle upload step, (2) the .deb upload step, and (3) the .deb bundle upload step. The existing newline sanitization (tr -d '\n\r') was already in place; the missing double-quotes were the only gap.

