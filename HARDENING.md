<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.18

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.18** was hardened automatically. 8 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): `${{ github.repository }}` is interpolated directly inside a `run:` shell command string. The offending line is: `run: ./scorecard --repo=github.com/${{ github.repository }} --format=sarif --show-details > results.sarif`. This goes through YAML template substitution before the shell sees it, enabling script injection.

Locations:

- `.github/workflows/scorecard.yml:40`

### script-injection (severity: high)

Rule (a): `${{ github.event.pull_request.base.sha }}` and `${{ github.event.pull_request.head.sha }}` are interpolated directly inside a `run:` shell command string in the commitlint step. Offending lines: `--from ${{ github.event.pull_request.base.sha }} \` and `--to ${{ github.event.pull_request.head.sha }}`. These go through YAML template substitution before the shell sees them.

Locations:

- `.github/workflows/ci.yml:75`

### script-injection (severity: high)

Rule (a): `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` is interpolated directly inside a `run:` shell command string in the ci-result step. Offending line: `if [[ "${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}" == "true" ]]`. This goes through YAML template substitution before the shell sees it.

Locations:

- `.github/workflows/ci.yml:338`

### script-injection (severity: high)

Rule (a): `${{ needs.secrets.result }}` and `${{ needs.zizmor.result }}` are interpolated directly inside a `run:` shell command string in the security-result step. Offending line: `for result in "${{ needs.secrets.result }}" "${{ needs.zizmor.result }}"; do`. These go through YAML template substitution before the shell sees them.

Locations:

- `.github/workflows/security.yml:57`

### script-injection (severity: high)

Rule (a): Multiple `${{ ... }}` expressions are interpolated directly inside `run:` shell command strings in build-and-attest.yml. Offending lines include: `cargo build --release --target ${{ inputs.target }} -p aptu-cli`, `cosign sign-blob --yes --bundle "${{ steps.upload-cli.outputs.tar }}.bundle" "${{ steps.upload-cli.outputs.tar }}"`, `gh release upload $RELEASE_TAG "${{ steps.upload-cli.outputs.tar }}.bundle" --clobber`, `cargo deb --target ${{ inputs.target }} --no-build --package aptu-cli`, and `DEB_FILE=$(find target/${{ inputs.target }}/debian ...)`. These go through YAML template substitution before the shell sees them.

Locations:

- `.github/workflows/build-and-attest.yml:89`
- `.github/workflows/build-and-attest.yml:93`
- `.github/workflows/build-and-attest.yml:100`
- `.github/workflows/build-and-attest.yml:113`
- `.github/workflows/build-and-attest.yml:120`

### script-injection (severity: high)

Rule (a): `${{ github.repository }}` is interpolated directly inside `run:` shell command strings in multiple steps of release.yml. Offending lines include: `REF_JSON="$(gh api "repos/${{ github.repository }}/git/refs/tags/$TAG")"`, `TAG_OBJ_JSON="$(gh api "repos/${{ github.repository }}/git/tags/$TAG_SHA")"`, `EXISTING_REF=$(gh api "repos/${{ github.repository }}/git/refs/tags/$MINOR_TAG" ...)`, `"repos/${{ github.repository }}/git/refs/tags/$MINOR_TAG"` (PATCH), `"repos/${{ github.repository }}/git/refs"` (POST), and `ALL_ASSETS=$(gh api "repos/${{ github.repository }}/releases/tags/${RELEASE_TAG}" ...)`. These go through YAML template substitution before the shell sees them.

Locations:

- `.github/workflows/release.yml:47`
- `.github/workflows/release.yml:56`
- `.github/workflows/release.yml:183`
- `.github/workflows/release.yml:191`
- `.github/workflows/release.yml:198`
- `.github/workflows/release.yml:233`

### github-env-injection (severity: high)

The 'Resolve release tag' step writes untrusted workflow inputs to GITHUB_ENV without sanitization. `INPUT_TAG_NAME` (from `${{ inputs.tag_name }}`) and `REF_NAME` (from `${{ github.ref_name }}`) are written via `echo "RELEASE_TAG=$INPUT_TAG_NAME" >> "$GITHUB_ENV"` and `echo "RELEASE_TAG=$REF_NAME" >> "$GITHUB_ENV"` without applying `printf '%s' ... | tr -d '\n\r'` before the write. A newline in the input value could inject arbitrary environment variables.

Locations:

- `.github/workflows/build-and-attest.yml:47`

### github-env-injection (severity: high)

The 'Extract version from tag or input' step writes untrusted workflow inputs to GITHUB_ENV without sanitization. `INPUT_VERSION` (from `${{ inputs.version }}`), `INPUT_TAG_NAME` (from `${{ inputs.tag_name }}`), and `EVENT_NAME` (from `${{ github.event_name }}`) are used to compute VERSION and TAG, which are then written via `echo "VERSION=$VERSION" >> "$GITHUB_ENV"` and `echo "TAG=$TAG" >> "$GITHUB_ENV"` without applying `printf '%s' ... | tr -d '\n\r'` before the write. A newline in the input value could inject arbitrary environment variables.

Locations:

- `.github/workflows/release.yml:87`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all 8 findings across 5 workflow files:

1. scorecard.yml: Moved `${{ github.repository }}` to env block as GITHUB_REPOSITORY, referenced as $GITHUB_REPOSITORY in run.

2. ci.yml (commitlint step): Moved `${{ github.event.pull_request.base.sha }}` and `${{ github.event.pull_request.head.sha }}` to env block as PR_BASE_SHA and PR_HEAD_SHA.

3. ci.yml (ci-result step): Moved `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` to env block as HAS_FAILURE.

4. security.yml: Moved `${{ needs.secrets.result }}` and `${{ needs.zizmor.result }}` to env block as SECRETS_RESULT and ZIZMOR_RESULT.

5. build-and-attest.yml (github-env-injection): Added `printf '%s' ... | tr -d '\n\r'` sanitization before writing RELEASE_TAG to $GITHUB_ENV.

6. build-and-attest.yml (script-injection): Moved `${{ inputs.target }}` to env block as INPUT_TARGET in Build binary, Generate .deb, Upload .deb, Sign .deb, and Upload .deb .bundle steps. Moved `${{ steps.upload-cli.outputs.tar }}` to env block as UPLOAD_TAR in Sign tarball and Upload tarball steps.

7. release.yml (script-injection): Moved `${{ github.repository }}` to env block as GITHUB_REPOSITORY_NAME in verify-tag-signature, update-marketplace-tag, and update-homebrew steps.

8. release.yml (github-env-injection): Added `printf '%s' ... | tr -d '\n\r'` sanitization before writing VERSION and TAG to $GITHUB_ENV in the Extract version step.

