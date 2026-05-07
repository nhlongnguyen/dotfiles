---
name: create-pull-request
description: Create a pull request from the current branch to main/master using GitHub CLI. Use this skill whenever the user wants to open a PR, create a pull request, submit changes for review, or push a branch for merging — even if they don't say "pull request" explicitly. Handles branch syncing, commit message validation (Conventional Commits + Jira ticket prefix), PR template lookup, and PR body generation automatically.
---

# Create Pull Request

Automates opening a GitHub pull request: syncs the branch, validates commit messages against the Conventional Commits convention (with Jira ticket prefix), finds or builds a PR body, and creates the PR via `gh`.

**Bundled resources:**

- `references/conventional-commits.md` — full commit message spec and validation checklist
- `assets/pr-template-fallback.md` — minimal fallback PR body template

---

## Arguments

```
/create-pull-request [PR title] [--ticket-url <url>]
```

- **PR title** (optional): use directly as the PR title; if omitted, derive from commits or branch name
- **--ticket-url** (optional): include a ticket link in the PR body References section

---

## Steps

### Step 0 — Validate commit messages

Read `references/conventional-commits.md` now, before doing anything else. It contains the required format and validation checklist.

Get the unpushed commits on the current branch:

```bash
git log origin/HEAD..HEAD --oneline
```

For each commit, check that it matches: `[JIRA-TICKET] type[(scope)]: description`

**Jira ticket:** extract from the branch name first:

```bash
git branch --show-current
```

Look for the first `[A-Z]+-\d+` segment in the branch name (e.g. `PROJ-123-my-feature` → `PROJ-123`). If found, every commit on this branch should carry that prefix. If the branch name has no ticket number, and no `--ticket-url` flag was provided, ask the user: "What's the Jira ticket number for this branch? (e.g. PROJ-123)"

**If commits don't conform:** explain which commits fail and why (wrong format, missing ticket prefix, non-standard type, multi-line message). Offer to amend them with `git commit --amend` or `git rebase -i` before continuing. Do not proceed until commits are valid or the user explicitly overrides.

---

### Step 1 — Detect main branch

```bash
git remote show origin | grep 'HEAD branch' | cut -d' ' -f5
```

If that fails:

```bash
git branch -r | grep -E 'origin/(main|master)' | head -1
```

Store the result (typically `main` or `master`).

---

### Step 2 — Check current branch

```bash
git branch --show-current
```

If the current branch IS the main branch, stop with: "You're on the main branch — create a feature branch first."

---

### Step 3 — Sync branch with remote

```bash
git fetch origin
git status --porcelain
```

If there are uncommitted changes, stop with: "Please commit or stash your changes first."

```bash
git status -b --porcelain
```

Then handle the branch state:

- Branch not on remote → `git push -u origin $(git branch --show-current)`
- Branch behind remote → `git pull origin $(git branch --show-current)`
- Branch has unpushed commits → `git push origin $(git branch --show-current)`

Verify the branch is fully synced before continuing.

---

### Step 4 — Find PR template

Check for project templates using the Read tool, in order:

1. `PULL_REQUEST_TEMPLATE.md`
2. `pull_request_template.md`
3. `.github/PULL_REQUEST_TEMPLATE.md`
4. `.github/pull_request_template.md`

If a project template is found, use it. If not, load `assets/pr-template-fallback.md` as the base.

---

### Step 5 — Parse arguments and generate PR title

Extract `--ticket-url` flag and the title from the arguments if provided.

If no title was given, derive one from the most recent commit:

```bash
git log --oneline -1 --pretty=format:"%s"
```

Strip the conventional commit prefix to produce a human-readable title:

- Remove leading `[JIRA-XXX] ` ticket prefix
- Remove `type(scope): ` or `type: ` prefix
- Capitalise first letter, remove trailing punctuation
- Keep it under 72 characters

If the commit message is generic (e.g. "WIP", "update"), fall back to the branch name:

- Remove ticket prefix and common branch prefixes (`feature/`, `bugfix/`, `fix/`)
- Replace hyphens/underscores with spaces and capitalise appropriately

---

### Step 6 — Summarise changes for PR body

Analyse the commits and diff to produce a concise description:

```bash
git log origin/HEAD..HEAD --oneline
git diff origin/HEAD..HEAD --stat
```

Generate 2–4 bullet points describing what changed — factual, no jargon, no padding. These fill the **Description** section of the PR body.

---

### Step 7 — Build PR body

Start with the template from Step 4.

- Fill the **Description** section with the bullet points from Step 6.
- If `--ticket-url` was provided, add it to the **References** section.
- If a project template has placeholder text (e.g. `<!-- ... -->`), preserve it for the author to fill in on GitHub.
- Keep the body minimal — no unnecessary headers or boilerplate.

---

### Step 8 — Create the pull request

```bash
gh pr create --title "TITLE" --body "$(cat <<'EOF'
BODY
EOF
)" --base MAIN_BRANCH
```

Use a heredoc so multi-line body formatting is preserved.

Display the PR URL on success.

---

## Output format

```
✅ Detected main branch: main
✅ Current branch: feat/PROJ-123-add-auth
✅ Commits validated (Conventional Commits + Jira prefix)
✅ Branch synced with origin
✅ Using template: project / fallback
✅ Generated title: "Add JWT token validation"
✅ Pull Request created: https://github.com/org/repo/pull/42
```

Show clear error messages for any failures instead.

---

## Error handling

- Not a git repo → exit with explanation
- On main branch → explain, suggest creating a feature branch
- Uncommitted changes → ask to commit or stash first
- `gh` not installed → "Install GitHub CLI: brew install gh"
- No GitHub remote → "Add a GitHub remote: git remote add origin <url>"
- Commits don't conform → explain failures, offer to help fix before continuing

---

## Examples

```bash
# Automatic title from latest commit
/create-pull-request

# Custom PR title
/create-pull-request "Add user authentication feature"

# With ticket URL in references
/create-pull-request --ticket-url https://company.atlassian.net/browse/PROJ-123

# Custom title + ticket URL
/create-pull-request "Fix user authentication bug" --ticket-url https://company.atlassian.net/browse/PROJ-456
```
