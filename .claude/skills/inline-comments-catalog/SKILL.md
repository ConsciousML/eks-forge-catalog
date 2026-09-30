---
name: inline-comments-catalog
description: Rules for writing or editing an inline code comment (HCL, YAML, JSON, shell, templates) in this repo or its sibling repos. Use before writing or editing any comment.
---

Write the fewest characters possible while keeping the comment readable and keeping every
important fact.

- Keep only the why, the gotcha, or the link to what must stay in sync. Drop anything the code
  already says.
- One or two lines max. More than that usually means a fact belongs in a doc instead.
- Cut filler ("Note that", "This is used to", "so that we can"). Start with the fact.
- Name the file or key to keep in sync instead of explaining the whole mechanism.

Example, before:

```hcl
# Shared by the root Application and every child Application (config.spec.source below),
# so github.hcl alone points a deployment at an app of apps fork.
```

After:

```hcl
# Root and child Applications, so github.hcl alone switches the app of apps fork.
```

Other style rules (punctuation, lists) are in
[`how-to-write-docs-catalog`](../how-to-write-docs-catalog/SKILL.md).
