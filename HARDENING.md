<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.15

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.15** was hardened automatically. 7 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): ${{ inputs.target }} is interpolated directly in run: shell commands in multiple steps. This allows a workflow caller to inject arbitrary shell content via the `target` input. Affected steps: 'Build binary (dry-run)' (`cargo build --release --target ${{ inputs.target }}`), 'Generate aptu .deb package' (`cargo deb --target ${{ inputs.target }}`), and three 'find target/${{ inputs.target }}/debian' invocations. Additionally, ${{ steps.upload-cli.outputs.tar }} is interpolated directly in 'Sign tarball with cosign' and 'Upload tarball .bundle to release' run: blocks.

Locations:

- `.github/workflows/build-and-attest.yml:97`
- `.github/workflows/build-and-attest.yml:103`
- `.github/workflows/build-and-attest.yml:108`
- `.github/workflows/build-and-attest.yml:116`
- `.github/workflows/build-and-attest.yml:130`
- `.github/workflows/build-and-attest.yml:140`
- `.github/workflows/build-and-attest.yml:153`

### script-injection (severity: high)

Rule (a): ${{ github.event.pull_request.base.sha }} and ${{ github.event.pull_request.head.sha }} are interpolated directly in the 'Validate commit messages' run: block (`npx commitlint --from ${{ github.event.pull_request.base.sha }} --to ${{ github.event.pull_request.head.sha }}`). These are github.* context values injected directly into a shell command without going through an env: variable. Additionally, ${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }} is interpolated directly in the 'Verify all jobs passed or were skipped' run: block.

Locations:

- `.github/workflows/ci.yml:68`
- `.github/workflows/ci.yml:69`
- `.github/workflows/ci.yml:341`

### script-injection (severity: high)

Rule (a): ${{ github.repository }} is interpolated directly in multiple run: shell commands in the 'verify-tag-signature' and 'update-marketplace-tag' jobs. Examples: `gh api "repos/${{ github.repository }}/git/refs/tags/$TAG"`, `gh api "repos/${{ github.repository }}/git/tags/$TAG_SHA"`, `gh api --method PATCH "repos/${{ github.repository }}/git/refs/tags/$MINOR_TAG"`, and `gh api "repos/${{ github.repository }}/releases/tags/${RELEASE_TAG}"`. These github.* context values are injected directly into shell commands.

Locations:

- `.github/workflows/release.yml:48`
- `.github/workflows/release.yml:55`
- `.github/workflows/release.yml:183`
- `.github/workflows/release.yml:191`
- `.github/workflows/release.yml:197`
- `.github/workflows/release.yml:243`

### script-injection (severity: high)

Rule (a): ${{ github.repository }} is interpolated directly in the 'Run OpenSSF Scorecard' run: block: `./scorecard --repo=github.com/${{ github.repository }} --format=sarif --show-details > results.sarif`. This github.* context value is injected directly into a shell command without going through an env: variable.

Locations:

- `.github/workflows/scorecard.yml:43`

### script-injection (severity: high)

Rule (a): ${{ needs.secrets.result }}, ${{ needs.zizmor.result }}, and ${{ needs.poutine.result }} are interpolated directly in the 'Check all security jobs passed' run: block: `for result in "${{ needs.secrets.result }}" "${{ needs.zizmor.result }}" "${{ needs.poutine.result }}"; do`. These needs.*.result context values are injected directly into a shell command.

Locations:

- `.github/workflows/security.yml:89`

### github-env-injection (severity: high)

The 'Resolve release tag' step writes $INPUT_TAG_NAME (sourced from inputs.tag_name) and $REF_NAME (sourced from github.ref_name) to $GITHUB_ENV without sanitization: `echo "RELEASE_TAG=$INPUT_TAG_NAME" >> "$GITHUB_ENV"` and `echo "RELEASE_TAG=$REF_NAME" >> "$GITHUB_ENV"`. An attacker-controlled tag_name input or ref_name could inject newlines to set arbitrary environment variables.

Locations:

- `.github/workflows/build-and-attest.yml:55`
- `.github/workflows/build-and-attest.yml:57`

### github-env-injection (severity: high)

The 'Extract version from tag or input' step writes $INPUT_VERSION and $INPUT_TAG_NAME (both sourced from workflow_dispatch inputs.*) to $GITHUB_ENV without sanitization: `echo "VERSION=$VERSION" >> "$GITHUB_ENV"` and `echo "TAG=$TAG" >> "$GITHUB_ENV"`. When triggered via workflow_dispatch, a user-supplied version or tag_name value could inject newlines to set arbitrary environment variables.

Locations:

- `.github/workflows/release.yml:100`
- `.github/workflows/release.yml:101`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all 7 findings across 5 workflow files:

1. build-and-attest.yml (github-env-injection): Sanitized INPUT_TAG_NAME and REF_NAME with `printf '%s' | tr -d '\n\r'` before writing to GITHUB_ENV.

2. build-and-attest.yml (script-injection): Moved `${{ inputs.target }}` to INPUT_TARGET env var in 5 steps (Build binary dry-run, Generate .deb, Upload .deb, Sign .deb, Upload .deb .bundle). Moved `${{ steps.upload-cli.outputs.tar }}` to UPLOAD_TAR env var in 2 steps (Sign tarball, Upload tarball .bundle).

3. ci.yml (script-injection): Moved PR base/head SHAs to PR_BASE_SHA/PR_HEAD_SHA env vars in 'Validate commit messages'. Moved contains() expression to ANY_FAILED env var in 'Verify all jobs passed or were skipped'.

4. release.yml (github-env-injection): Sanitized VERSION and TAG with `printf '%s' | tr -d '\n\r'` before writing to GITHUB_ENV in 'Extract version from tag or input'.

5. release.yml (script-injection): Moved `${{ github.repository }}` to GH_REPOSITORY env var in 3 steps across verify-tag-signature, update-marketplace-tag, and update-homebrew jobs.

6. scorecard.yml (script-injection): Moved `${{ github.repository }}` to GH_REPOSITORY env var in 'Run OpenSSF Scorecard'.

7. security.yml (script-injection): Moved needs.*.result expressions to SECRETS_RESULT, ZIZMOR_RESULT, POUTINE_RESULT env vars in 'Check all security jobs passed'.

