<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.3** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): `${{ github.event.pull_request.base.sha }}` and `${{ github.event.pull_request.head.sha }}` are interpolated directly inside a `run:` shell command in the 'Validate commit messages' step: `npx commitlint --from ${{ github.event.pull_request.base.sha }} --to ${{ github.event.pull_request.head.sha }} --verbose`. These GitHub context expressions are substituted into the shell command before execution, enabling script injection if the values contain shell metacharacters. Fix: move the SHAs into env vars and reference them as `"$BASE_SHA"` / `"$HEAD_SHA"`.

Locations:

- `.github/workflows/ci.yml:69`

### script-injection (severity: high)

Sub-rule (a): `${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}` is interpolated directly inside a `run:` shell command in the 'Verify all jobs passed or were skipped' step: `if [[ "${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}" == "true" ]]`. Any `${{ ... }}` expression inside a run block is a script-injection risk. Fix: move the expression into an env var and reference it as a quoted shell variable.

Locations:

- `.github/workflows/ci.yml:218`

### script-injection (severity: high)

Sub-rule (a): Multiple `run:` blocks in build-and-attest.yml interpolate `${{ inputs.target }}` and `${{ steps.upload-cli.outputs.tar }}` directly into shell commands:
- `cargo build --release --target ${{ inputs.target }} -p aptu-cli` (Build binary dry-run step)
- `cosign sign-blob --yes --bundle "${{ steps.upload-cli.outputs.tar }}.bundle" "${{ steps.upload-cli.outputs.tar }}"` (Sign tarball step)
- `gh release upload $RELEASE_TAG "${{ steps.upload-cli.outputs.tar }}.bundle"` (Upload tarball step)
- `cargo deb --target ${{ inputs.target }} --no-build ...` (Generate .deb step)
- `find target/${{ inputs.target }}/debian ...` (Upload/Sign .deb steps)
These expressions are substituted before the shell sees the command. Fix: route all values through env vars and reference them with double-quotes.

Locations:

- `.github/workflows/build-and-attest.yml:91`
- `.github/workflows/build-and-attest.yml:95`
- `.github/workflows/build-and-attest.yml:100`
- `.github/workflows/build-and-attest.yml:107`
- `.github/workflows/build-and-attest.yml:113`

### script-injection (severity: high)

Sub-rule (a): Multiple `run:` blocks in release.yml interpolate `${{ github.repository }}` directly into shell commands passed to `gh api`, for example: `gh api "repos/${{ github.repository }}/git/refs/tags/$TAG"`. Although `github.repository` is GitHub-controlled, any `${{ ... }}` expression directly inside a `run:` block is a script-injection finding per the check rules. Fix: set `GITHUB_REPOSITORY` (already available as an env var) or assign to an explicit env var and reference it quoted.

Locations:

- `.github/workflows/release.yml:55`
- `.github/workflows/release.yml:63`
- `.github/workflows/release.yml:148`
- `.github/workflows/release.yml:156`
- `.github/workflows/release.yml:165`
- `.github/workflows/release.yml:175`
- `.github/workflows/release.yml:222`

### github-env-injection (severity: high)

The 'Resolve release tag' step writes workflow-controlled values to `$GITHUB_ENV` without sanitization. `INPUT_TAG_NAME` is sourced from `${{ inputs.tag_name }}` (a workflow_dispatch input) and `REF_NAME` from `${{ github.ref_name }}`. Both are written directly: `echo "RELEASE_TAG=$INPUT_TAG_NAME" >> "$GITHUB_ENV"` and `echo "RELEASE_TAG=$REF_NAME" >> "$GITHUB_ENV"`. A value containing a newline could inject additional environment variables. Fix: sanitize with `safe=$(printf '%s' "$INPUT_TAG_NAME" | tr -d '\n\r')` before writing.

Locations:

- `.github/workflows/build-and-attest.yml:63`

### github-env-injection (severity: high)

The 'Extract version from tag or input' step writes workflow-controlled values to `$GITHUB_ENV` without sanitization. `VERSION` and `TAG` are derived from `inputs.version` and `inputs.tag_name` (workflow_dispatch inputs) or `GITHUB_REF`, then written as `echo "VERSION=$VERSION" >> "$GITHUB_ENV"` and `echo "TAG=$TAG" >> "$GITHUB_ENV"`. A newline embedded in a workflow_dispatch input could inject additional environment variables. Fix: sanitize each value with `printf '%s' "$VERSION" | tr -d '\n\r'` before writing to GITHUB_ENV.

Locations:

- `.github/workflows/release.yml:100`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all 6 findings across 3 workflow files:

**ci.yml:**
- 'Validate commit messages' step: moved `${{ github.event.pull_request.base.sha }}` and `${{ github.event.pull_request.head.sha }}` into env vars `BASE_SHA`/`HEAD_SHA`.
- 'Verify all jobs passed or were skipped' step: moved the `contains(needs.*.result, ...)` expression into env var `HAS_FAILURE`.

**build-and-attest.yml:**
- 'Resolve release tag' step: sanitized `INPUT_TAG_NAME` and `REF_NAME` with `printf '%s' | tr -d '\n\r'` before writing to `$GITHUB_ENV`.
- 'Build binary (dry-run)' step: moved `${{ inputs.target }}` into env var `TARGET`.
- 'Sign tarball with cosign' step: moved `${{ steps.upload-cli.outputs.tar }}` into env var `TAR_PATH`.
- 'Upload tarball .bundle to release' step: moved `${{ steps.upload-cli.outputs.tar }}` into env var `TAR_PATH`.
- 'Generate aptu .deb package' step: moved `${{ inputs.target }}` into env var `TARGET`.
- 'Upload aptu .deb to release', 'Sign aptu .deb with cosign', 'Upload aptu .deb .bundle to release' steps: moved `${{ inputs.target }}` into env var `TARGET` for each.

**release.yml:**
- 'Extract version from tag or input' step: sanitized `VERSION` and `TAG` with `printf '%s' | tr -d '\n\r'` before writing to `$GITHUB_ENV`.
- 'Verify tag is signed' step: replaced `${{ github.repository }}` with `$GITHUB_REPOSITORY` (built-in env var).
- 'Move floating minor tag to current release' step: replaced all 5 occurrences of `${{ github.repository }}` with `$GITHUB_REPOSITORY`.
- 'Download SHA256 checksums' step: replaced `${{ github.repository }}` with `$GITHUB_REPOSITORY`.

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed all 7 script injection locations in action.yml by replacing `echo "Running: ... $VAR"` diagnostic lines with `printf 'Running: ... %s\n' "$VAR"` form. This moves the user-controlled variables out of the double-quoted format string and into separate, properly-quoted printf arguments, preventing shell metacharacter interpretation. Affected steps: 'Run aptu issue triage' ($ISSUE_REF), 'Run aptu issue triage scheduled batch' (${ARGS[*]} containing $REPO), 'Run aptu PR label' ($PR_REF), 'Run aptu PR review' ($PR_REF), 'Run aptu scan-security' ($SCAN_DIFF and $SCAN_PATH), and 'Run aptu pr queue' ($REPO). The actual command invocations already used properly double-quoted variables and were not modified.

