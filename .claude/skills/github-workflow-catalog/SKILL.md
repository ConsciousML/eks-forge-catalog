---
name: github-workflow-catalog
description: End-to-end process for a catalog change, from issue to branch, implementation, PR, live deploy and test, user review, destroy, and merge. Use when starting a change that needs an issue or a branch, or when asked to commit, push, open a PR, tear down after a review, or merge.
---

# GitHub Workflow

Never hardcode a GitHub owner, this repo is forked. Run `gh` from the repo's directory so it infers
the repo from `origin`. Read the owner with `gh repo view --json owner -q .owner.login` when you
need a cross-repo reference (`<owner>/<repo>#<N>`).

## 1. Issue

Skip if the user gives an existing issue.
Search existing issues with `gh issue list --state all --search "<keywords>"`, if one exists skip
too.

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

### App-of-apps branch

If the change also touches `argocd-app-of-apps-template`, create a branch there, named after the
feature.

The stack deploys app-of-apps from `APP_OF_APPS_BRANCH` in `.env`. It must be that branch, or
`main` when the change doesn't touch that repo. Check it from the main checkout:
```bash
source .env && printf '%s\n' "$APP_OF_APPS_BRANCH"
```

If it's wrong, **wait**, even in an autonomous run: ask the user to set it in `.env`.

### Without a worktree

Create the branch in place:
```bash
git checkout main && git pull && git checkout -b <branch>
```

### With a worktree

Create it with the branch and link the ignored `.env` into it. Then switch the session into it
with the `EnterWorktree` tool (`path: .claude/worktrees/<branch>`):
```bash
git fetch origin main
git worktree add --no-track .claude/worktrees/<branch> -b <branch> origin/main
ln -s "$PWD/.env" .claude/worktrees/<branch>/.env
```

Then run `source .env` on its own. If it runs, carry on.

If it's refused, the session can't load `.env` and only holds the env vars Claude Code was
launched with. Check them:
```bash
test -n "$SLACK_BOT_TOKEN" && printf 'set\n' || printf 'unset\n'
```

If it prints `unset`, **wait**, even in an autonomous run:
ask the user to relaunch Claude Code from the repo root with `.env` loaded, and to pick this
session. Then enter the worktree again:
```bash
set -a; source .env; set +a; claude --resume
```

## 3. Implement

Match the patterns of existing modules and units.

**Wait** on any meaningful design decision. In an autonomous run, pick the option closest to
existing patterns and report it.

## 4. Pull Request

Opened before the deploy, so the user can review the change before anything is applied.

If the change has an `argocd-app-of-apps-template` branch, open its PR too, with the same steps as
below.

1. Draft the PR:
   - Title: the main commit subject.
   - Body: `Closes #<issue>` when the issue is in this repo, otherwise
     `Part of <owner>/<repo>#<issue>`. Then one or two lines or bullets.
2. **Wait** for the user to validate the draft. If they asked for an autonomous run, skip the wait.
3. Commit and push with `git push -u origin <branch>`.
4. Open it with `gh pr create --title "<title>" --body "<body>"` and report the link.

Never open it as a draft, CI fails on draft PRs. CI also fails on a leftover `TEMP:` marker or a
missing provider lock file.

CI pushes a terraform-docs commit back to the branch. Run `git pull` before any later push.

## 5. Deploy and Test

Skip for a change with no infra to deploy.

A worktree isolates code, not state. Every session and worktree applies to the same `dev` stack.
**Wait** before the first apply: ask the user whether another session is using it. If one is, wait
for it. In an autonomous run, skip the wait.

Follow the `working-against-live-infra-catalog` skill. It commits and pushes each new change to
the branch first, because `pipelines/version.hcl` resolves module sources at the current branch on
GitHub. If `source .env` is refused in the worktree session (see step 2), skip that step of its loop. The
session already holds the vars.

Before the first apply, note whether the stack was already up. If it was, step 7 destroys nothing.

Verify against live AWS state, not plan output. Fix and repeat until it passes. Then report what
was verified, and what was not.

## 6. Review

**Wait** for the user's review, even in an autonomous run. A change requested after the destroy
costs a full redeploy.

Keep the infra up so requested changes can be retested. For each requested change, redo step 3,
commit and push, then redo step 5.

## 7. Destroy

Skip if step 5 was skipped, or if the stack was already up before step 5.

**Wait**, even in an autonomous run: ask the user to confirm the destroy. The review being done is
not a destroy request.

Destroy before merging. The merge deletes the branch that module sources resolve at, and a destroy
after that fails.

Follow "Tearing down" in `working-against-live-infra-catalog`.

Then check with read-only `aws` calls that the resources are gone, and report one of:

- **Succeeded**: every destroy exited 0 and nothing is left.
- **Failed**: the unit, the decisive error line, and what is left behind.

Never merge after a failed destroy.

## 8. Merge

Run `gh pr checks <N> --watch`. `check-docs-changes` fails by design whenever terraform-docs pushed
a commit. When it does, run `git pull` and watch again. Stop on any other failure.

If the change has an `argocd-app-of-apps-template` PR, merge it first, with the same
`gh pr merge` command, from that repo's directory. Merging it before the review would force a new
branch and PR for any change requested there.

Delete its branch only if step 7 destroyed the stack. A stack still up syncs from that branch and
gets stuck without it. Otherwise keep the branch until that stack is destroyed.

Then:
```bash
gh pr merge <N> --merge --subject "<PR title> #<N>" --body ""
git push origin --delete <branch>
```

Merge commit (not squash), subject `<PR title> #<N>`, empty body. The head branch is deleted
explicitly, since `--delete-branch` also switches the local checkout to `main`, which a worktree
can't do.

Without a worktree, finish with:
```bash
git checkout main && git pull && git branch -D <branch>
```

With a worktree, **wait** for the user to confirm it can go. In an autonomous run, skip the wait.
Then leave it with the `ExitWorktree` tool (`action: keep`) and, from the main checkout:
```bash
git worktree remove .claude/worktrees/<branch>
git branch -D <branch>
git pull   # only if the main checkout is on main
```

`git worktree remove` refuses when the worktree holds uncommitted or untracked files. Check
`git status` there instead of forcing it.

If an `argocd-app-of-apps-template` PR was merged, ask the user to reset `APP_OF_APPS_BRANCH` to
`main` in `.env`.
