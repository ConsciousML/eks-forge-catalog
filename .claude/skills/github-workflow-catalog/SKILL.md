---
name: github-workflow-catalog
description: End-to-end process for a catalog change, from issue to branch, implementation, live deploy and test, PR, user review, destroy, and merge. Use when starting a change that needs an issue or a branch, or when asked to commit, push, open a PR, tear down after a review, or merge.
---

# GitHub Workflow

Never hardcode a GitHub owner, this repo is forked. Run `gh` from the repo's directory so it infers
the repo from `origin`. Read the owner with `gh repo view --json owner -q .owner.login` when you
need a cross-repo reference (`<owner>/<repo>#<N>`).

If the change also touches `argocd-app-of-apps-template`, use the same branch name there, set
`APP_OF_APPS_BRANCH` to it in `.env`, and open and merge its PR before this repo's.

## 1. Issue

Skip if the user gives an existing issue.
Search existing issue, if one exists skip too.

1. Read similar issues and match their title and body style:
   ```bash
   gh issue list --state all -L 10
   gh issue view <N>
   ```
2. Draft a minimal issue: a title, and a body of one or two sentences or a few bullets saying what is needed. No implementation detail the user didn't give.
3. **Wait** for the user to validate the draft. If they asked for an autonomous run, skip the wait.
4. Post it with `gh issue create --title "<title>" --body "<body>"` and report the link.

## 2. Branch

Kebab-case, never `/` (it breaks Terragrunt).

**Wait**: ask the user whether to work in a git worktree, so other sessions can keep working in the
main checkout on other branches. In an autonomous run, don't create one unless the user asked.

Without a worktree, create the branch in place:
```bash
git checkout main && git pull && git checkout -b <branch>
```

With a worktree, create it with the branch and link the ignored `.env` into it. Then switch the
session into it with the `EnterWorktree` tool (`path: .claude/worktrees/<branch>`):
```bash
git fetch origin main
git worktree add --no-track .claude/worktrees/<branch> -b <branch> origin/main
ln -s "$PWD/.env" .claude/worktrees/<branch>/.env
```

## 3. Implement

Match the patterns of existing modules and units.

**Wait** on any meaningful design decision. In an autonomous run, pick the option closest to
existing patterns and report it.

- Provider added, removed, or bumped: run the `reproducibility-catalog` skill.
- Docs and comments: `how-to-write-docs-catalog` and `inline-comments-catalog`.
- Never write a module `README.md`, CI generates it from `header.md` and `footer.md`.

## 4. Deploy and Test

Follow the `working-against-live-infra-catalog` skill. It commits and pushes to the branch first,
because `pipelines/version.hcl` resolves module sources at the current branch on GitHub.

Before the first apply, note whether the stack was already up. Step 7 destroys only what this
workflow applied.

Verify against live AWS state, not plan output. Fix and repeat until it passes. Then report what
was verified, and what was not.

## 5. Pull Request

1. Draft the PR:
   - Title: the main commit subject.
   - Body: `Closes #<issue>` when the issue is in this repo, otherwise
     `Part of <owner>/<repo>#<issue>`. Then one or two lines or bullets.
2. **Wait** for the user to validate the draft. If they asked for an autonomous run, skip the wait.
3. Commit and push with `git push -u origin <branch>` if step 4 was skipped (a change with no
   infra to deploy).
4. Open it with `gh pr create --title "<title>" --body "<body>"` and report the link.

Never open it as a draft, CI fails on draft PRs. CI also fails on a leftover `TEMP:` marker or a
missing provider lock file.

CI pushes a terraform-docs commit back to the branch. Run `git pull` before any later push.

## 6. Review

**Wait** for the user's review, even in an autonomous run. A change requested after the destroy
costs a full redeploy.

Keep the infra up so requested changes can be retested. For each requested change, redo steps 3
and 4, then push.

## 7. Destroy

**Wait** for the user to say the review is done, even in an autonomous run.

Destroy before merging. The merge deletes the branch that module sources resolve at, and a destroy
after that fails.

Follow "Tearing down" in `working-against-live-infra-catalog`, limited to what step 4 applied.

Then check with read-only `aws` calls that the resources are gone, and report one of:

- **Succeeded**: every destroy exited 0 and nothing is left.
- **Failed**: the unit, the decisive error line, and what is left behind.

Never merge after a failed destroy.

## 8. Merge

**Wait** for the user to say CI passed. In an autonomous run, run `gh pr checks <N> --watch`
instead, and stop on any failure. Then:
```bash
gh pr merge <N> --merge --subject "<PR title> #<N>" --body "" --delete-branch
git checkout main && git pull
```

Merge commit (not squash), subject `<PR title> #<N>`, empty body, head branch deleted.

If the work was done in a worktree, `main` is checked out elsewhere, so skip the checkout and pull
there. **Wait** for the user to confirm the worktree can go. In an autonomous run, skip the wait.
Then leave it with the `ExitWorktree` tool (`action: keep`) and, from the main checkout:
```bash
git worktree remove .claude/worktrees/<branch>
git branch -D <branch>
git pull   # only if the main checkout is on main
```

`git worktree remove` refuses when the worktree holds uncommitted or untracked files. Check
`git status` there instead of forcing it.
