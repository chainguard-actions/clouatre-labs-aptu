<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.7

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.7** was hardened automatically. 7 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): ${{ steps.resolve-version.outputs.version }} is interpolated directly inside a run: shell command string in the 'Install aptu binary' step. The expression `APTU_VERSION="${{ steps.resolve-version.outputs.version }}"` is expanded by the template engine before the shell sees it, allowing injection if the step output contains shell metacharacters.

Locations:

- `action.yml:233`

### script-injection (severity: high)

Sub-rule (a): Multiple ${{ }} expressions are interpolated directly inside run: shell command strings in build-and-attest.yml. Affected steps and patterns: (1) 'Build binary (dry-run)': `cargo build --release --target ${{ inputs.target }}`; (2) 'Sign tarball with cosign': `"${{ steps.upload-cli.outputs.tar }}.bundle" "${{ steps.upload-cli.outputs.tar }}"`; (3) 'Upload tarball .bundle to release': `"${{ steps.upload-cli.outputs.tar }}.bundle"`; (4) 'Generate aptu .deb package': `cargo deb --target ${{ inputs.target }}`; (5) 'Upload aptu .deb to release': `find target/${{ inputs.target }}/debian`; (6) 'Sign aptu .deb with cosign': `find target/${{ inputs.target }}/debian`; (7) 'Upload aptu .deb .bundle to release': `find target/${{ inputs.target }}/debian`. These expressions are expanded by the template engine before the shell parses the command.

Locations:

- `.github/workflows/build-and-attest.yml:100`
- `.github/workflows/build-and-attest.yml:105`
- `.github/workflows/build-and-attest.yml:112`
- `.github/workflows/build-and-attest.yml:126`
- `.github/workflows/build-and-attest.yml:134`
- `.github/workflows/build-and-attest.yml:148`
- `.github/workflows/build-and-attest.yml:160`

### script-injection (severity: high)

Sub-rule (a): ${{ github.repository }} is interpolated directly inside run: shell command strings in release.yml. Affected steps: (1) 'Verify tag is signed': `gh api "repos/${{ github.repository }}/git/refs/tags/$TAG"` and `gh api "repos/${{ github.repository }}/git/tags/$TAG_SHA"`; (2) 'Move floating minor tag to current release': multiple `gh api "repos/${{ github.repository }}/..."` calls; (3) 'Download SHA256 checksums': `gh api "repos/${{ github.repository }}/releases/tags/${RELEASE_TAG}"`. The github.repository value is expanded by the template engine before the shell sees it.

Locations:

- `.github/workflows/release.yml:43`
- `.github/workflows/release.yml:185`
- `.github/workflows/release.yml:300`

### script-injection (severity: high)

Sub-rule (a): ${{ }} expressions are interpolated directly inside run: shell command strings in ci.yml. (1) 'Validate commit messages' step: `--from ${{ github.event.pull_request.base.sha }}` and `--to ${{ github.event.pull_request.head.sha }}` are expanded directly in the npx commitlint command. (2) 'Verify all jobs passed or were skipped' step: `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` is expanded directly inside an if [[ ... ]] shell test.

Locations:

- `.github/workflows/ci.yml:65`
- `.github/workflows/ci.yml:340`

### script-injection (severity: high)

Sub-rule (b): Unquoted shell variable expansions of untrusted input-derived data in action.yml run: blocks. (1) 'Run aptu issue triage (scheduled batch)' step: `$SINCE` (from inputs.since) and `$ISSUE_STATE` (from inputs.issue-state) are appended to $ARGS unquoted (`ARGS="$ARGS --since $SINCE"`, `ARGS="$ARGS --state $ISSUE_STATE"`), and `$REPO` (from github.repository) is used unquoted in `ARGS="--repo $REPO"`. The final `aptu issue triage $ARGS` expands $ARGS unquoted. (2) 'Run aptu PR review' step: `$REPO_PATH` (from inputs.repo-path) and `$INSTRUCTIONS_FILE` (from inputs.instructions-file) are appended to $ARGS unquoted (`ARGS="$ARGS --repo-path $REPO_PATH"`, `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"`). Shell metacharacters in these values would be interpreted by the shell.

Locations:

- `action.yml:315`
- `action.yml:385`

### github-env-injection (severity: high)

In build-and-attest.yml, the 'Resolve release tag' step writes untrusted input-derived values to $GITHUB_ENV without sanitization. `INPUT_TAG_NAME` (sourced from `inputs.tag_name`) is written as `echo "RELEASE_TAG=$INPUT_TAG_NAME" >> "$GITHUB_ENV"` and `REF_NAME` (sourced from `github.ref_name`) is written as `echo "RELEASE_TAG=$REF_NAME" >> "$GITHUB_ENV"`. Neither value is passed through `printf '%s' ... | tr -d '\n\r'` before the write, allowing newline injection to set arbitrary environment variables.

Locations:

- `.github/workflows/build-and-attest.yml:56`

### github-env-injection (severity: high)

In release.yml, the 'Extract version from tag or input' step writes untrusted input-derived values to $GITHUB_ENV without sanitization. `INPUT_VERSION` (from `inputs.version`) and `INPUT_TAG_NAME` (from `inputs.tag_name`) flow into the `VERSION` and `TAG` shell variables, which are then written as `echo "VERSION=$VERSION" >> "$GITHUB_ENV"` and `echo "TAG=$TAG" >> "$GITHUB_ENV"`. Neither value is sanitized with `printf '%s' ... | tr -d '\n\r'` before the write, allowing newline injection to set arbitrary environment variables.

Locations:

- `.github/workflows/release.yml:100`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all 7 findings across 4 files:

1. action.yml (script-injection line 233): Moved ${{ steps.resolve-version.outputs.version }} from run: shell string to env: block as APTU_VERSION.

2. action.yml (script-injection sub-rule b, lines 315 & 385): Converted string-based ARGS variable to bash arrays in 'Run aptu issue triage (scheduled batch)' and 'Run aptu PR review' steps, properly quoting all user-controlled values ($REPO, $SINCE, $ISSUE_STATE, $REPO_PATH, $INSTRUCTIONS_FILE).

3. build-and-attest.yml (script-injection, lines 100/105/112/126/134/148/160): Moved ${{ inputs.target }} and ${{ steps.upload-cli.outputs.tar }} expressions from run: shell strings to env: blocks (as TARGET and TAR_PATH respectively) in all 7 affected steps. Also fixed unquoted $RELEASE_TAG references.

4. build-and-attest.yml (github-env-injection, line 56): Added printf '%s' ... | tr -d '\n\r' sanitization before writing INPUT_TAG_NAME and REF_NAME to $GITHUB_ENV.

5. release.yml (script-injection, lines 43/185/300): Moved ${{ github.repository }} to env: block as GITHUB_REPOSITORY_VAR in 'Verify tag is signed', 'Move floating minor tag to current release', and 'Download SHA256 checksums' steps.

6. release.yml (github-env-injection, line 100): Added printf '%s' ... | tr -d '\n\r' sanitization before writing VERSION and TAG to $GITHUB_ENV.

7. ci.yml (script-injection, lines 65/340): Moved ${{ github.event.pull_request.base.sha }} and head.sha to env: block in 'Validate commit messages'; moved the contains() expression to env: block as HAS_FAILURE in 'Verify all jobs passed or were skipped'.

