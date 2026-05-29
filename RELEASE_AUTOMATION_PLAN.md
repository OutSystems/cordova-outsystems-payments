# Release Automation Plan — Option 3 (per-PR version bumps)

This document describes the plan for testing **option 3** of the release automation strategy in `cordova-outsystems-payments` (fork at `OS-pedrogustavobilro/cordova-outsystems-payments`).

The goal is to compare this approach against the semantic-release flow proposed in [`cordova-outsystems-healthfitness#173`](https://github.com/OutSystems/cordova-outsystems-healthfitness/pull/173) and let the team decide which to adopt.

## Constraints

- Cannot push to `main` directly.
- Cannot change branch protection rules.
- Some target repos require 2 approvals on PRs.
- `main` must reflect the released version files (`package.json`, `plugin.xml`, `CHANGELOG.md`).

## Current state of the target fork

- Version: `1.2.15` (in `package.json` and `plugin.xml`).
- CHANGELOG format: `## X.Y.Z` (no brackets) with `### Fixes` / `### Chores` subsections.
- Git tags: `X.Y.Z` (no `v` prefix).
- No `.github/` folder yet.

## Workflow architecture

Three GitHub Actions workflows:

### 1. `validate_pr_title.yml`

- Triggers: `pull_request` on `opened`, `edited`, `reopened`, `synchronize`.
- Validates PR title against angular convention (`feat:`, `fix:`, `chore:`, etc.).
- Carried over from `cordova-outsystems-healthfitness` for consistency.

### 2. `bump_version_in_pr.yml`

- Triggers: `pull_request_target` on `opened`, `synchronize`, `reopened`, `edited`; also `workflow_dispatch`.
- **Early exit if `github.event.pull_request.base.ref != 'main'`** — only PRs targeting `main` are bumped.
- Computes target version based on PR title + latest version on `origin/main`'s CHANGELOG.
- Rewrites `package.json`, `plugin.xml`, `CHANGELOG.md` on the PR head branch.
- Commits and pushes **only if anything changed** (loop-breaker).
- Uses `pull_request_target` so the workflow runs in the base repo's context and has a write token. The workflow does NOT execute PR code — it only runs the trusted Node script from the base.

**Security model:**

- The workflow uses two working trees:
  - A `main` clone that hosts the trusted Node script. The script runs from this clone.
  - A separate clone/worktree of the PR head where the computed files are written, committed, and pushed.
  - PR code is never executed — only `git` plumbing touches the PR working tree.
  - The script uses only Node built-ins (`node:fs`, `node:path`) and standard regex — no `npm install` step needed.
- PR title and PR body are passed to the script via environment variables, never interpolated into shell commands (avoids injection).
- **Fork PRs are skipped**: workflow exits early if `github.event.pull_request.head.repo.full_name != github.repository`. Reason: even with the base-script protection, `GITHUB_TOKEN` cannot push to a fork's branch, so the bump can't be applied anyway. Fork contributions would need a maintainer to either rebranch into the base repo or accept the PR without a bump (with a follow-up bump PR).

**Concurrency:**

- `concurrency: group: bump-${{ github.event.pull_request.number }}, cancel-in-progress: true` — serializes runs per PR. A new event (synchronize, edit, or dispatch from `release_on_main.yml`) cancels an in-flight run and starts fresh, avoiding `git push` races.

**Dispatch input:**

- When triggered by `workflow_dispatch` (from `release_on_main.yml` re-triggering open PRs), the workflow takes a `pr` input with the PR number. The script reads from that input instead of `github.event.pull_request.*` so the two code paths share the same logic.

**Token:**

- Uses the default `GITHUB_TOKEN` provided by `pull_request_target`, which has `contents: write` and `pull-requests: read`. GitHub's "GITHUB_TOKEN doesn't trigger workflows" rule prevents the workflow's own pushes from re-triggering itself, which is the desired behavior — re-triggers happen explicitly from `release_on_main.yml` via `gh workflow run`.

**CHANGELOG ownership:**

- The workflow rebuilds `CHANGELOG.md` from `main`'s version on every run. Any manual edits to `CHANGELOG.md` made by the PR author will be overwritten silently. This is intentional — the workflow is the single source of truth for the CHANGELOG.

### 3. `release_on_main.yml`

- Triggers: `push` on `main`.
- If `package.json`'s version on main has no matching git tag, creates the tag + a GitHub Release using the matching CHANGELOG section as the release body.
- Dispatches `bump_version_in_pr.yml` on every open PR (that targets `main`) so they recompute against the updated main.
- **Dispatch failures fail the workflow loudly** — if `gh workflow run` fails for any open PR, the job fails. Stale PRs left behind from a transient API error must be visible immediately rather than discovered later.

## Version computation logic

### Inputs

- **Last logged version**: top `## X.Y.Z` entry in `origin/main`'s `CHANGELOG.md`. Falls back to `1.0.0` if no entries exist (first-release default).
- **PR title**: parsed for the angular type prefix and optional `!`.
- **PR body**: scanned for a `BREAKING CHANGE:` line.
- **Commit footers**: each commit on the PR is fetched via `gh api repos/{owner}/{repo}/pulls/{number}/commits`, and the commit message is scanned for a `BREAKING CHANGE:` footer (the standard angular convention).

Scanning all three sources mirrors what semantic-release does and covers every place a breaking change could be declared — commit footers (canonical), PR title `!` (shorthand), PR body (used by reviewers and merge UIs when editing the squash commit body).

### Bump rules

Evaluation order — highest wins:

1. Any of: a commit footer contains `BREAKING CHANGE:`, PR body contains `BREAKING CHANGE:`, or PR title has `!` before the `:` (e.g., `feat!:`, `fix(scope)!:`) → **major**
2. PR title starts with `feat:` → **minor**
3. PR title starts with `fix:`, `chore:`, or `refactor:` → **patch**
4. PR title starts with `docs:`, `ci:`, `test:`, `style:`, `perf:`, `build:` → **no release** — workflow exits silently

Matches the `releaseRules` in `cordova-outsystems-healthfitness`'s `release.config.cjs` plus the standard angular `BREAKING CHANGE:` footer convention referenced in PR #173.

### CHANGELOG entry format

```
## X.Y.Z

### <Subsection>

- <PR title> (#<PR number>)
```

Subsection mapping:

| Bump type           | Subsection header        |
| ------------------- | ------------------------ |
| `feat:`             | `### Features`           |
| `fix:`              | `### Fixes`              |
| `chore:`            | `### Chores`             |
| `refactor:`         | `### Chores`             |
| breaking (any source) | `### BREAKING CHANGES` |

A breaking change (declared via PR title `!`, PR body `BREAKING CHANGE:`, or commit-footer `BREAKING CHANGE:`) lands under `### BREAKING CHANGES` regardless of the original type prefix.

## Race-condition handling

- The workflow reads version state from `origin/main` only. It never merges `main` into the PR branch — that would cause conflicts on version files.
- The PR branch's version files are recomputed each run as: `latest version on main + this PR's bump`.
- When `main` moves (any PR squash-merged), `release_on_main.yml` invokes `gh workflow run bump_version_in_pr.yml --ref <pr-head> --field pr=<NN>` for every open PR. Each PR recomputes its version against the new main state.
- **No external safety net assumed**: we cannot change branch protection, so the workflow's re-trigger is the only mechanism that keeps open PRs in sync. If a PR is squash-merged before its re-triggered run finishes, the squash-merge will conflict on the version files and GitHub will block the merge until the PR is updated. The workflow is the only thing pulling it forward; there's no "branch must be up to date" rule to lean on.
- Each re-trigger pushes a new bump commit if the version changed. Under heavy merge cadence this can be noisy on long-lived PRs — accepted trade-off.

## Squash-merge contract

- PRs are merged via squash (assumed, not enforced by the workflow). The PR's bump commit (plus any cleanup commits the workflow added) collapses into a single squash commit on `main`.
- Post-merge, `release_on_main.yml` tags the squash commit with `X.Y.Z`.

## Files to create

```
.github/
├── workflows/
│   ├── validate_pr_title.yml
│   ├── bump_version_in_pr.yml
│   └── release_on_main.yml
└── scripts/
    └── compute_release.cjs    # bump + CHANGELOG logic, Node built-ins only
```

No changes to `package.json` are required — the script uses only Node built-ins (regex for `plugin.xml`, plain JSON parse for `package.json`), so no devDependencies and no lockfile are introduced.

## Decisions

1. **Scripts always run from `main`** — workflow uses a `main` clone for `npm ci` + script execution, and a separate PR-head clone for file writes / commit / push. No PR code is executed. PR title and body are passed via env vars (no shell interpolation). Fork PRs are skipped entirely because `GITHUB_TOKEN` can't push to a fork branch.
2. **Squash-only merge strategy** — workflow assumes one squash commit per PR. Tagging on `push: main` uses the squash commit SHA.
3. **PR number included in CHANGELOG** — each entry is `- <PR title> (#<NN>)`, matching the fork's existing CHANGELOG style.
4. **Seed version stays at `1.2.15`** — first new PR bumps from there.
5. **No `release` branch** — only `main`.
6. **CHANGELOG fully owned by the workflow** — manual edits to `CHANGELOG.md` in a PR are overwritten on every workflow run.
7. **Token: default `GITHUB_TOKEN`** — no PAT or GitHub App needed. The recursion-prevention rule (GITHUB_TOKEN doesn't trigger other workflows) is what stops the bump push from looping.

## Bootstrap

- The PR that introduces these three workflows will **not have a version bump applied** to itself — `pull_request_target` reads the workflow file from `main`, and the bootstrap PR is what puts those files on `main`. The bootstrap PR's version stays at `1.2.15`.
- After merge, the first feature/fix PR opened against `main` will be the first one to exercise the system.
- Testing happens in this fork with mocked PRs; the bootstrap PR itself is not part of the test matrix.

## Acceptance criteria

Test scenarios to validate the implementation in the fork. All checked items were exercised end-to-end on `OS-pedrogustavobilro/cordova-outsystems-payments` and observed to behave as described.

### Version computation

- [x] **AC-1**: Opening a PR with title `feat: <desc>` updates `package.json`, `plugin.xml` to `1.3.0` and adds a `## 1.3.0` / `### Features` entry in `CHANGELOG.md` on the PR branch.
- [x] **AC-2**: Opening a PR with title `fix: <desc>` bumps to `1.2.16` under `### Fixes`.
- [x] **AC-3**: Opening a PR with title `chore: <desc>` bumps to `1.2.16` under `### Chores`.
- [x] **AC-4**: Opening a PR with title `refactor: <desc>` bumps to `1.2.16` under `### Chores`.
- [x] **AC-5**: Opening a PR with title `feat!: <desc>` bumps to `2.0.0` under `### BREAKING CHANGES`.
- [x] **AC-6**: Opening a PR with title `feat: <desc>` and body containing `BREAKING CHANGE: <note>` bumps to `2.0.0` under `### BREAKING CHANGES`.
- [x] **AC-7**: Opening a PR with a commit message footer `BREAKING CHANGE: <note>` (title is just `fix: <desc>`) bumps to `2.0.0` under `### BREAKING CHANGES`.
- [x] **AC-8**: Opening a PR with title `docs: <desc>` results in **no commit, no push, no file changes** — workflow exits silently.
- [x] **AC-9**: Opening a PR with title `ci: <desc>` results in no changes.

### PR lifecycle

- [x] **AC-10**: Editing a PR's title from `fix:` to `feat:` (after the first run) updates the bump from `1.2.16` → `1.3.0` and rewrites the CHANGELOG section in the next bump commit.
- [x] **AC-11**: Re-running the workflow on a PR whose files are already at the correct target version produces **no new commit** (loop-breaker verified).
- [x] **AC-12**: A PR author manually edits `CHANGELOG.md` and pushes; on the next workflow run, those manual edits are overwritten by the workflow's regenerated CHANGELOG.

### Race / concurrency

- [x] **AC-13**: Two PRs open simultaneously, both `feat:`. PR-A merges first and main is tagged `1.3.0`. PR-B's workflow auto-re-triggers and recomputes its bump to `1.4.0`, pushing an updated bump commit.
- [x] **AC-14**: Rapid edits to a PR's title result in only the final state being pushed (concurrency `cancel-in-progress: true` verified — `gh run list` showed the earlier run as `cancelled`).

### Release on main

- [x] **AC-15**: Squash-merging a `feat:` PR to main creates a git tag `1.3.0` on the squash commit SHA and a GitHub Release with body extracted from the matching CHANGELOG section.
- [x] **AC-16**: Squash-merging a `docs:` PR (no version bump) does NOT create a new tag (`package.json` version unchanged, log: `Tag X.Y.Z already exists — no release needed.`). Dispatch step to re-trigger open PRs still runs unconditionally.
- [x] **AC-17**: After tagging, the workflow successfully dispatches `bump_version_in_pr.yml` for every other open PR.

### Edge cases

- [ ] **AC-18** *(skipped)*: A PR from a fork is detected and the workflow exits without error. Skipped — requires a fork-of-the-fork to test cleanly; code path is straightforward (`PR_HEAD_REPO != GITHUB_REPOSITORY` early-exit).
- [x] **AC-19** *(validated separately)*: A PR targeting a non-`main` base branch is detected and the workflow exits without making any changes.
- [ ] **AC-20** *(skipped)*: The "no prior version" fallback (`1.0.0`) is exercised by manually clearing CHANGELOG + tags on a test branch — first PR there should produce `1.0.0` regardless of bump type. Skipped — not relevant for repos with an existing version history (which is every repo we'd actually deploy this in).

### Side-effect findings from testing

A few behaviors not captured in the AC list but worth noting:

- **CHANGELOG sync commits on idempotent re-runs**: when main moves and `release_on_main` re-triggers open PRs, even PRs whose target version is *unchanged* (e.g., a `feat!:` PR at 2.0.0 when main goes from 1.2.15 → 1.3.0) get a new bot commit. Reason: their CHANGELOG was missing the now-released main entry, and the workflow always rebuilds `CHANGELOG = main's + new entry`. The version field doesn't move; only the CHANGELOG syncs. Correct behavior, just verbose.
- **`chore(release): revert version bump` commit message** on no-release PRs (`docs:`, `ci:`, etc.) appears when main moves and the PR's CHANGELOG needs syncing. There's no actual revert happening — the message just signals "this is the no-release path."

## Verified commits

Bot commits are created via the GitHub Git Data REST API (`POST /git/blobs` → `POST /git/trees` → `POST /git/commits` → `PATCH /git/refs/heads/<branch>`) rather than `git commit` + `git push`. GitHub signs API-created commits server-side using the `github-actions` App's GPG key, so the bot's commits show the green **Verified** badge in the GitHub UI. This makes the workflow compatible with `Require signed commits` branch protection.

No new secrets or keys are required — the default `GITHUB_TOKEN` (which is the `github-actions` App's installation token) is what triggers the server-side signing.

## Comparison — Option 3 vs PR #173 (semantic-release + release PR)

| Dimension | Option 3 (this plan) | PR #173 (semantic-release) |
| --- | --- | --- |
| **Number of workflows** | 3 (`validate_pr_title`, `bump_version_in_pr`, `release_on_main`) | 2 (`release_plugin`, `trigger_semantic_release`) |
| **Custom Node code** | ~250 LOC (`compute_release.cjs`) | None — semantic-release config (~80 LOC) |
| **Release PR** | None — each feature PR carries its bump | Yes — separate PR from `release` branch, must be merged |
| **Manual trigger to release** | None (releases happen on feature-PR merge) | `workflow_dispatch` on `release_plugin.yml` |
| **Approvals needed per release** | Built into the feature PR's normal review | Reviewer(s) on the release PR (extra round) |
| **Merge strategy on PR head** | Squash (clean history) | Merge commit required (to preserve semantic-release tags) |
| **Where the tag is created** | After squash-merge, by `release_on_main.yml` on the squash commit SHA | By `semantic-release` inside the `release` branch, before the PR merges |
| **Verified bot commits** | Yes (Git Data API + `GITHUB_TOKEN`) | No (commits made by `git push`, unsigned) |
| **Branch protection: "Require signed commits"** | Compatible | Incompatible without extra signing setup |
| **Concurrent open PRs** | Re-trigger cascade keeps them in sync; final safety is squash-merge conflict on `CHANGELOG.md` | Serialized — only one release PR is open at a time |
| **Diff visibility during code review** | Bump shows up inside each feature PR | Bump shows up only in the release PR |
| **Reverting a release** | Revert the feature PR (single commit on main) | Revert the release PR's merge commit (chain of bot commits) |
| **Adding the system to a new repo** | Copy 3 YAML files + 1 script; adjust the CHANGELOG format detection if non-standard | Copy 2 YAML files + `release.config.cjs`; install npm deps |

### Recommendation criteria

- If the team's main pain point is **"verified commits required by branch protection"**, Option 3 is the only one that works without extra signing infrastructure.
- If the team values **a single rolling release PR for visibility** (so reviewers can see "what's about to ship" in one place), PR #173 fits better.
- If **per-PR diff visibility** of the version bump matters during code review (it's right there in the feature PR), Option 3 wins.
- If **operational simplicity** (fewer custom scripts to maintain) is the priority, PR #173 wins — semantic-release is well-trodden territory.
- If **automation depth** matters (no manual trigger, no manual merge of a release PR), Option 3 is more end-to-end.
