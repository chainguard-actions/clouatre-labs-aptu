<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.12

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.12** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The `commitlint` step directly interpolates `${{ github.event.pull_request.base.sha }}` and `${{ github.event.pull_request.head.sha }}` inside a `run:` shell command string. Any `${{ }}` expression directly in a `run:` block is a script-injection risk regardless of the context. Offending lines: `--from ${{ github.event.pull_request.base.sha }}` and `--to ${{ github.event.pull_request.head.sha }}`

Locations:

- `.github/workflows/ci.yml:75`

### script-injection (severity: high)

Sub-rule (a): The `ci-result` step directly interpolates `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` inside a `run:` shell command string. Offending line: `if [[ "${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}" == "true" ]]`

Locations:

- `.github/workflows/ci.yml:310`

### script-injection (severity: high)

Sub-rule (a): Multiple `run:` blocks directly interpolate `${{ inputs.target }}` and `${{ steps.upload-cli.outputs.tar }}` inside shell commands. Offending lines include: `cargo build --release --target ${{ inputs.target }}`, `cosign sign-blob ... "${{ steps.upload-cli.outputs.tar }}"`, `gh release upload $RELEASE_TAG "${{ steps.upload-cli.outputs.tar }}.bundle"`, `cargo deb --target ${{ inputs.target }}`, and `find target/${{ inputs.target }}/debian ...`. These are workflow_call inputs that can be attacker-controlled.

Locations:

- `.github/workflows/build-and-attest.yml:97`
- `.github/workflows/build-and-attest.yml:101`
- `.github/workflows/build-and-attest.yml:107`
- `.github/workflows/build-and-attest.yml:120`
- `.github/workflows/build-and-attest.yml:130`
- `.github/workflows/build-and-attest.yml:143`
- `.github/workflows/build-and-attest.yml:155`

### script-injection (severity: high)

Sub-rule (a): The `verify-tag-signature` and `update-marketplace-tag` steps directly interpolate `${{ github.repository }}` inside `run:` shell command strings. Offending lines: `gh api "repos/${{ github.repository }}/git/refs/tags/$TAG"`, `gh api "repos/${{ github.repository }}/git/tags/$TAG_SHA"`, `gh api "repos/${{ github.repository }}/git/refs/tags/$MINOR_TAG"`, `gh api "repos/${{ github.repository }}/git/refs"`, and `gh api "repos/${{ github.repository }}/releases/tags/${RELEASE_TAG}"`

Locations:

- `.github/workflows/release.yml:55`
- `.github/workflows/release.yml:62`
- `.github/workflows/release.yml:196`
- `.github/workflows/release.yml:204`
- `.github/workflows/release.yml:244`

### github-env-injection (severity: high)

The `resolve-tag` step writes `$INPUT_TAG_NAME` (sourced from `${{ inputs.tag_name }}`, a workflow_call input) and `$REF_NAME` (sourced from `${{ github.ref_name }}`) to `$GITHUB_ENV` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). A newline in either value could inject arbitrary environment variables into subsequent steps. Offending lines: `echo "RELEASE_TAG=$INPUT_TAG_NAME" >> "$GITHUB_ENV"` and `echo "RELEASE_TAG=$REF_NAME" >> "$GITHUB_ENV"`

Locations:

- `.github/workflows/build-and-attest.yml:60`
- `.github/workflows/build-and-attest.yml:62`

### github-env-injection (severity: high)

The `extract-version` step writes `VERSION` and `TAG` (derived from `$INPUT_VERSION` and `$INPUT_TAG_NAME`, sourced from `inputs.version` and `inputs.tag_name`, which are `workflow_dispatch` inputs) to `$GITHUB_ENV` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). A newline in either value could inject arbitrary environment variables into subsequent steps. Offending lines: `echo "VERSION=$VERSION" >> "$GITHUB_ENV"` and `echo "TAG=$TAG" >> "$GITHUB_ENV"`

Locations:

- `.github/workflows/release.yml:109`
- `.github/workflows/release.yml:110`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all 6 security findings across 3 workflow files:

1. ci.yml (line 75): Moved `${{ github.event.pull_request.base.sha }}` and `${{ github.event.pull_request.head.sha }}` to env block (BASE_SHA, HEAD_SHA) in the commitlint step.

2. ci.yml (line 310): Moved `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` to env block (HAS_FAILURE) in the ci-result step.

3. build-and-attest.yml (lines 60/62): Added `printf '%s' ... | tr -d '\n\r'` sanitization before writing RELEASE_TAG to $GITHUB_ENV in the resolve-tag step.

4. build-and-attest.yml (lines 97, 101, 107, 120, 130, 143, 155): Moved `${{ inputs.target }}` to env block (INPUT_TARGET) and `${{ steps.upload-cli.outputs.tar }}` to env block (UPLOAD_TAR) in all affected run: steps.

5. release.yml (lines 55, 62, 196, 204, 244): Moved `${{ github.repository }}` to env block (GH_REPOSITORY) in verify-tag-signature, update-marketplace-tag, and update-homebrew steps.

6. release.yml (lines 109/110): Added `printf '%s' ... | tr -d '\n\r'` sanitization before writing VERSION and TAG to $GITHUB_ENV in the extract-version step.

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed three instances of unquoted `$RELEASE_TAG` in `gh release upload` commands in `.github/workflows/build-and-attest.yml` (lines 100, 117, and 131). Changed `gh release upload $RELEASE_TAG ...` to `gh release upload "$RELEASE_TAG" ...` in all three locations: the tarball bundle upload step, the .deb upload step, and the .deb bundle upload step. This prevents word splitting and glob expansion on the workflow-controllable tag name value.

