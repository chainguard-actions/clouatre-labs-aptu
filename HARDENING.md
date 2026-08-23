<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.13

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.13** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): ${{ }} expressions are interpolated directly inside run: shell command strings in multiple workflow files.

• ci.yml 'Validate commit messages' step: `--from ${{ github.event.pull_request.base.sha }}` and `--to ${{ github.event.pull_request.head.sha }}` are injected directly into the npx commitlint command. Although SHA values are typically hex strings, any ${{ }} in a run: block is a script-injection risk.

• ci.yml 'ci-result' step: `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` is interpolated directly into an if [[ ... ]] shell condition.

• scorecard.yml 'Run OpenSSF Scorecard' step: `${{ github.repository }}` is interpolated directly into the scorecard CLI invocation: `./scorecard --repo=github.com/${{ github.repository }}`.

• security.yml 'Check all security jobs passed' step: `${{ needs.secrets.result }}`, `${{ needs.zizmor.result }}`, and `${{ needs.poutine.result }}` are interpolated directly into a for-loop shell command.

• build-and-attest.yml 'Sign tarball with cosign' and 'Upload tarball .bundle to release' steps: `${{ steps.upload-cli.outputs.tar }}` is interpolated directly into cosign and gh CLI commands. Similarly, `${{ inputs.target }}` is interpolated into find commands in the .deb steps.

• release.yml 'Verify tag is signed' step: `${{ github.repository }}` is interpolated directly into gh api URL strings inside the run: block.

Locations:

- `.github/workflows/ci.yml:76`
- `.github/workflows/ci.yml:77`
- `.github/workflows/ci.yml:330`
- `.github/workflows/scorecard.yml:38`
- `.github/workflows/security.yml:90`
- `.github/workflows/build-and-attest.yml:80`
- `.github/workflows/build-and-attest.yml:88`
- `.github/workflows/build-and-attest.yml:103`
- `.github/workflows/build-and-attest.yml:110`
- `.github/workflows/release.yml:49`
- `.github/workflows/release.yml:55`

### github-env-injection (severity: high)

Untrusted input values are written to $GITHUB_ENV without the required sanitization step (printf '%s' ... | tr -d '\n\r').

• build-and-attest.yml 'Resolve release tag' step: The env vars INPUT_TAG_NAME (from inputs.tag_name) and REF_NAME (from github.ref_name) are written directly to $GITHUB_ENV:
  `echo "RELEASE_TAG=$INPUT_TAG_NAME" >> "$GITHUB_ENV"`
  `echo "RELEASE_TAG=$REF_NAME" >> "$GITHUB_ENV"`
  A caller workflow can supply a tag_name containing newlines to inject arbitrary environment variables.

• release.yml 'Extract version from tag or input' step: The variables VERSION and TAG are derived from inputs.version and inputs.tag_name (workflow_dispatch inputs) and written to $GITHUB_ENV without sanitization:
  `echo "VERSION=$VERSION" >> "$GITHUB_ENV"`
  `echo "TAG=$TAG" >> "$GITHUB_ENV"`
  A workflow_dispatch caller can supply a version string containing newlines to inject arbitrary environment variables.

Locations:

- `.github/workflows/build-and-attest.yml:60`
- `.github/workflows/build-and-attest.yml:62`
- `.github/workflows/release.yml:91`
- `.github/workflows/release.yml:92`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all script-injection and github-env-injection findings across 5 workflow files:

1. ci.yml: Moved PR SHA expressions (base.sha, head.sha) to env vars in commitlint step; moved contains() expression to env var in ci-result step.

2. scorecard.yml: Moved github.repository to env var REPOSITORY in Run OpenSSF Scorecard step.

3. security.yml: Moved needs.*.result values to env vars (SECRETS_RESULT, ZIZMOR_RESULT, POUTINE_RESULT) in security-result step.

4. build-and-attest.yml: (a) Sanitized GITHUB_ENV writes with printf/tr -d '\n\r' for RELEASE_TAG; (b) Moved steps.upload-cli.outputs.tar to env var TAR_PATH in cosign and gh release upload steps; (c) Moved inputs.target to env var TARGET in Upload .deb, Sign .deb, Upload .deb .bundle, Build binary dry-run, and Generate .deb package steps.

5. release.yml: (a) Sanitized GITHUB_ENV writes with printf/tr -d '\n\r' for VERSION and TAG; (b) Moved github.repository to env var REPOSITORY in Verify tag is signed, update-marketplace-tag, and update-homebrew steps.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed three instances of unquoted `$RELEASE_TAG` in `gh release upload` commands in `.github/workflows/build-and-attest.yml` (lines 103, 120, 133). Changed `gh release upload $RELEASE_TAG ...` to `gh release upload "$RELEASE_TAG" ...` in all three upload steps: 'Upload tarball .bundle to release', 'Upload aptu .deb to release', and 'Upload aptu .deb .bundle to release'. The value was already sanitized of newlines when written to $GITHUB_ENV, but other shell metacharacters (spaces, semicolons, &, etc.) could still cause injection without proper quoting.

