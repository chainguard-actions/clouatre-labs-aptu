<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.8.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.8.6** was hardened automatically. 8 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): The 'Install aptu binary' step interpolates `${{ steps.resolve-version.outputs.version }}` directly inside a `run:` shell command string (`APTU_VERSION="${{ steps.resolve-version.outputs.version }}"`). Any `${{ ... }}` expression inside a run: block is a script-injection risk because the value is substituted into the shell script before the shell parses it.

Locations:

- `action.yml:197`

### script-injection (severity: high)

Rule (b): Multiple steps in action.yml expand untrusted input-derived env vars without double-quoting them. In the 'Run aptu issue triage (scheduled batch)' step: `ARGS="$ARGS --since $SINCE"` and `ARGS="$ARGS --state $ISSUE_STATE"` leave `$SINCE` (from inputs.since) and `$ISSUE_STATE` (from inputs.issue-state) unquoted, allowing shell metacharacter injection. The final `aptu issue triage $ARGS` call also expands `$ARGS` unquoted, enabling word-splitting attacks. Similarly, in 'Run aptu PR review': `ARGS="$ARGS --repo-path $REPO_PATH"` and `ARGS="$ARGS --instructions-file $INSTRUCTIONS_FILE"` leave `$REPO_PATH` (inputs.repo-path) and `$INSTRUCTIONS_FILE` (inputs.instructions-file) unquoted, and `aptu pr review $ARGS "$PR_REF"` expands `$ARGS` unquoted. The same unquoted `$ARGS` pattern appears in 'Run aptu issue triage' and 'Run aptu PR label' steps.

Locations:

- `action.yml:253`
- `action.yml:290`
- `action.yml:330`
- `action.yml:360`

### script-injection (severity: high)

Rule (a): The 'Validate commit messages' step interpolates `${{ github.event.pull_request.base.sha }}` and `${{ github.event.pull_request.head.sha }}` directly inside a `run:` shell command string passed to `npx commitlint --from ${{ github.event.pull_request.base.sha }} --to ${{ github.event.pull_request.head.sha }}`. Any `${{ ... }}` expression inside a run: block is substituted before the shell parses it.

Locations:

- `.github/workflows/ci.yml:72`

### script-injection (severity: high)

Rule (a): The 'Verify all jobs passed or were skipped' step in the ci-result job interpolates `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` directly inside a `run:` shell command string (`if [[ "${{ contains(...) }}" == "true" ]]`). Any `${{ ... }}` expression inside a run: block is a script-injection risk.

Locations:

- `.github/workflows/ci.yml:316`

### script-injection (severity: high)

Rule (a): Multiple steps in build-and-attest.yml interpolate `${{ ... }}` expressions directly inside `run:` shell command strings. The 'Build binary (dry-run)' step uses `${{ inputs.target }}` directly: `cargo build --release --target ${{ inputs.target }} -p aptu-cli`. The 'Sign tarball with cosign' step uses `${{ steps.upload-cli.outputs.tar }}` directly in the cosign command. Additional steps ('Upload tarball .bundle to release', 'Upload aptu .deb to release', 'Sign aptu .deb with cosign', 'Upload aptu .deb .bundle to release') also embed `${{ inputs.target }}` and `${{ steps.upload-cli.outputs.tar }}` directly in run: blocks. The `# zizmor: ignore[template-injection]` comments do not mitigate the actual injection risk.

Locations:

- `.github/workflows/build-and-attest.yml:102`
- `.github/workflows/build-and-attest.yml:106`
- `.github/workflows/build-and-attest.yml:112`
- `.github/workflows/build-and-attest.yml:122`
- `.github/workflows/build-and-attest.yml:130`
- `.github/workflows/build-and-attest.yml:140`

### script-injection (severity: high)

Rule (a): Multiple steps in release.yml interpolate `${{ github.repository }}` directly inside `run:` shell command strings. The 'Verify tag is signed' step embeds `${{ github.repository }}` in gh api calls within the run block. The 'Move floating minor tag to current release' step similarly embeds `${{ github.repository }}` in multiple gh api calls within the run block. The 'Download SHA256 checksums' step also embeds `${{ github.repository }}` in a gh api call within the run block.

Locations:

- `.github/workflows/release.yml:59`
- `.github/workflows/release.yml:65`
- `.github/workflows/release.yml:163`
- `.github/workflows/release.yml:170`
- `.github/workflows/release.yml:176`
- `.github/workflows/release.yml:183`
- `.github/workflows/release.yml:228`

### github-env-injection (severity: high)

The 'Resolve release tag' step writes `RELEASE_TAG=$INPUT_TAG_NAME` (where INPUT_TAG_NAME comes from `inputs.tag_name`, a workflow_call input) and `RELEASE_TAG=$REF_NAME` (where REF_NAME comes from `github.ref_name`) to `$GITHUB_ENV` without sanitization. An attacker-controlled tag name containing newlines could inject arbitrary environment variables into subsequent steps. The required sanitization (`printf '%s' "$VAR" | tr -d '\n\r'`) is absent.

Locations:

- `.github/workflows/build-and-attest.yml:63`
- `.github/workflows/build-and-attest.yml:65`

### github-env-injection (severity: high)

The 'Extract version from tag or input' step in release.yml writes `VERSION=$VERSION` and `TAG=$TAG` to `$GITHUB_ENV` without sanitization. These values are derived from `inputs.version` and `inputs.tag_name` (workflow_dispatch inputs) or from `GITHUB_REF`. A malicious version or tag_name value containing newlines could inject arbitrary environment variables into subsequent steps. The required sanitization (`printf '%s' "$VAR" | tr -d '\n\r'`) is absent.

Locations:

- `.github/workflows/release.yml:96`
- `.github/workflows/release.yml:97`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all 8 security findings across 4 files:

1. action.yml (script-injection, line 197): Moved `${{ steps.resolve-version.outputs.version }}` from run: block to env: block as APTU_VERSION.

2. action.yml (script-injection, lines 253/290/330/360): Converted all four steps from unquoted string-concatenation ARGS pattern to bash arrays (ARGS+=(...)) with proper double-quoting of all user-controlled values. Final commands use "${ARGS[@]}".

3. ci.yml (script-injection, line 72): Moved ${{ github.event.pull_request.base.sha }} and ${{ github.event.pull_request.head.sha }} to env: block as BASE_SHA/HEAD_SHA.

4. ci.yml (script-injection, line 316): Moved ${{ contains(needs.*.result, ...) }} expression to env: block as HAS_FAILURE.

5. build-and-attest.yml (script-injection, lines 102/106/112/122/130/140): Moved ${{ inputs.target }} to BUILD_TARGET env var and ${{ steps.upload-cli.outputs.tar }} to UPLOAD_TAR env var for all affected steps. Also fixed unquoted $RELEASE_TAG in gh commands.

6. build-and-attest.yml (github-env-injection, lines 63/65): Added printf '%s' | tr -d '\n\r' sanitization before writing RELEASE_TAG to $GITHUB_ENV.

7. release.yml (script-injection, lines 59/65/163/170/176/183/228): Moved ${{ github.repository }} to GH_REPO env var in all three affected steps.

8. release.yml (github-env-injection, lines 96/97): Added printf '%s' | tr -d '\n\r' sanitization before writing VERSION and TAG to $GITHUB_ENV.

