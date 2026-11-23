---
name: site-docs-issue-catalog
description: Draft and open the `doc-site` issue that tells the `eks-forge` doc agent what a merged catalog change means for the site. Use once a change's PRs are merged, as the last step of `github-workflow-catalog`, or when asked to open a site docs issue.
---

# Site Docs Issue

Runs once the PRs are merged, so the issue cites the final change. It tells the agent of the
`eks-forge` repo what changed in the catalog. That agent decides which site pages to update, so
don't investigate the site docs yourself. Skip if the change only touches skills or comments.

## Content

The doc agent reads the PRs and the code itself. State only what it can't get from the diff:

- what a site reader would notice: a new bootstrap pipeline, a changed `.hcl` file, a new unit or
  module, a new or removed step, a changed command or output
- why the change was made, when the reason changes how a reader should use it
- gotchas, accepted risks, and constraints a reader must know

Never restate what the code shows: resource names, policy statements, input lists, file
contents. Never list CI-only or internal changes a site reader never sees.

## Steps

1. Read recent ones and match their style:
   ```bash
   gh issue list -R <owner>/eks-forge --label doc-site --state all -L 5
   ```
2. Draft it:
   - Title: `docs: <what changed in the catalog>`.
   - Body: one sentence citing each PR as `<owner>/<repo>#<N>` and what it changes. Then one
     bullet per item from [Content](#content). End with: `Evaluate the site docs against these
     changes and align them if necessary.`
3. **Wait**: ask the user whether to open it, even in an autonomous run.
4. Open it with
   `gh issue create -R <owner>/eks-forge --label doc-site --assignee @me --title "<title>" --body "<body>"`
   and report the link.
