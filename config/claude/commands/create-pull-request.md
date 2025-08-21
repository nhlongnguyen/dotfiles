---
description: Create a pull request to master/main branch using GitHub CLI with PR template support
author: Nhat Long Nguyen
---

<task>
Create a pull request from the current branch to the main branch (master or main) using GitHub CLI. Look for a PULL_REQUEST_TEMPLATE.md file in the project and use it as a template if available, otherwise use a fallback template.
</task>

<context>
This command automates the pull request creation process by:
1. Detecting the main branch (master or main)
2. Finding and using existing PR templates if available
3. Using a comprehensive fallback template when no project template exists
4. Leveraging GitHub CLI for seamless PR creation

Arguments: $ARGUMENTS
- If provided, use as the PR title
- If empty, generate title from recent commits or branch name
</context>

<instructions>
Follow these steps in order:

1. **Detect Main Branch**
   - Use Bash tool: `git remote show origin | grep 'HEAD branch' | cut -d' ' -f5`
   - If that fails, check: `git branch -r | grep -E 'origin/(main|master)' | head -1`
   - Store the main branch name (typically "main" or "master")

2. **Check Current Branch**
   - Use Bash tool: `git branch --show-current`
   - Ensure we're not on the main branch
   - If on main branch, exit with error

3. **Sync Local Branch with Remote**
   - Use Bash tool: `git fetch origin` (update remote refs)
   - Use Bash tool: `git status --porcelain` (check for uncommitted changes)
   - If uncommitted changes exist, exit with error: "Please commit or stash changes first"
   - Use Bash tool: `git status -b --porcelain` (check branch sync status)
   - If local branch doesn't exist on remote:
     - Use Bash tool: `git push -u origin $(git branch --show-current)` (push and set upstream)
   - If local branch is behind remote:
     - Use Bash tool: `git pull origin $(git branch --show-current)` (pull latest changes)
   - If local branch has unpushed commits:
     - Use Bash tool: `git push origin $(git branch --show-current)` (push local commits)
   - Verify branch is fully synced before proceeding

4. **Look for PR Template**
   - Use Read tool to check for these files in order:
     - `PULL_REQUEST_TEMPLATE.md`
     - `pull_request_template.md`
     - `.github/PULL_REQUEST_TEMPLATE.md`
     - `.github/pull_request_template.md`
   - If found, use the existing template content
   - If not found, use the fallback template below

5. **Generate PR Title** (if $ARGUMENTS is empty)
   - Use Bash tool: `git log --oneline -1 --pretty=format:"%s"`
   - Or generate from branch name if commit message is generic
   - Clean up the title to be PR-appropriate

6. **Analyze Branch Changes** (for comprehensive PR body)
   - Use Bash tool: `git log main..HEAD --pretty=format:"- %s (%h)" --reverse` (commit summaries)
   - Use Bash tool: `git diff --stat main..HEAD` (file change statistics)
   - Use Bash tool: `git diff --name-only main..HEAD | cut -d'/' -f1 | sort -u | tr '\n' ', ' | sed 's/,$//'` (affected areas/modules)
   - Use Bash tool: `git diff --name-status main..HEAD` (file modification types)

7. **Create PR Body**
   - Start with the template (project or fallback)
   - If using fallback template, enhance with detailed analysis:
     - Fill "In this PR:" section with commit summaries from step 5
     - Add "Files Changed" section with statistics
     - Add "Areas Affected" section with modules/directories
     - Include modification summary (added/modified/deleted files)

8. **Create Pull Request**
   - Use Bash tool: `gh pr create --title "TITLE" --body "BODY" --base MAIN_BRANCH`
   - Use heredoc for proper body formatting
   - Display the PR URL when successful
</instructions>

<fallback_template>
If no project template is found, use this comprehensive template:

```markdown
# Description

## In this PR:
- [Automatically filled from commits or manual description]

## Files Changed:
```
[Automatically filled with git diff --stat output]
```

## Areas Affected:
[Automatically filled with affected modules/directories]

## Why this change:
- [Brief explanation of the motivation]

## References:
- Issue: #[issue_number]
- Related PRs: #[pr_number]

# Testing & Deployment

## Testing completed:
- [ ] Unit tests pass
- [ ] Integration tests pass  
- [ ] Manual testing completed
- [ ] Code review completed

## Deployment considerations:
- [ ] Database migrations (if any)
- [ ] Configuration changes (if any)
- [ ] Dependencies updated (if any)
- [ ] Breaking changes documented (if any)

# Monitoring & Alerting

## Post-deployment verification:
- [ ] Feature works as expected
- [ ] No new errors in logs
- [ ] Performance metrics stable
- [ ] Monitoring alerts configured (if needed)

## Rollback plan:
- [ ] Rollback procedure documented
- [ ] Rollback tested (if applicable)
```
</fallback_template>

<title_generation>
When generating PR title from $ARGUMENTS or commits:

1. **From Arguments**: Use "$ARGUMENTS" directly as title
2. **From Latest Commit**: Clean up commit message:
   - Remove prefixes like "feat:", "fix:", "chore:"
   - Capitalize first letter
   - Remove trailing punctuation
   - Keep it concise (max 72 characters)
3. **From Branch Name**: Convert branch name to readable title:
   - Replace hyphens/underscores with spaces
   - Remove common prefixes like "feature/", "bugfix/"
   - Capitalize appropriately
</title_generation>

<error_handling>
- If not in a git repository, exit with clear error
- If on main branch, explain why PR can't be created
- If GitHub CLI not installed, provide installation instructions
- If no GitHub remote found, provide setup guidance
- If PR template has placeholder text, preserve it for user to fill
</error_handling>

<output_format>
Report the status and result:
- ✅ Detected main branch: [branch_name]
- ✅ Current branch: [current_branch] 
- ✅ Using template: [project_template | fallback_template]
- ✅ Generated title: "[pr_title]"
- ✅ Pull Request created: [pr_url]

Or show clear error messages for any failures.
</output_format>

<examples>
**Usage Examples:**

```bash
# Create PR with automatic title from commits
/create-pull-request

# Create PR with custom title
/create-pull-request "Add user authentication feature"

# Create PR with multi-word title
/create-pull-request Fix bug in payment processing
```

**Expected Workflow:**
1. You're on a feature branch with commits ready
2. Run the command with optional title
3. Command finds/creates appropriate PR template  
4. PR is created and URL is provided
5. You can edit the PR description in GitHub if needed
</examples>