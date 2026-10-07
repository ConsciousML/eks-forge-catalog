---
name: reference-docs-catalog
description: Rules for writing or editing a reference doc in this repo, a unit README under units/ or a module header.md or footer.md. Use before writing or editing one. Not for inline comments, tutorials, how-tos, or explanations.
---

## Scope

- Unit READMEs under `units/`, and module `header.md` and `footer.md`.
- Existing pages under `docs/reference/`. A new one needs a site wrapper, so it belongs to the
  `eks-forge` agent.
- Never write a module `README.md`, CI generates it.
- Tutorials, how-tos, and explanations belong to the `eks-forge` agent, even when the file is in
  this repo. There, fix only a fact your change made wrong.

## Source of Truth

Read two or three sibling docs of the same kind and match their structure. Verify every claim
against the code, not against another doc.

## Reference Style

Write in [Diataxis reference](https://diataxis.fr/reference/) style:

- Describe, don't instruct. Neutral facts only.
- Be austere and authoritative. No ambiguity.
- Use the same wording for the same thing everywhere.

## Content

- Only document facts that aren't obvious from the code.
- Don't restate a value that can drift out of sync with the code (a pinned version, a count, an
  exclusivity claim like "the only" or "single"). Point at the file that holds the value instead.

## Dependencies

- List what a component depends on under `## Upstream Dependencies`. Don't also list who depends
  on it, that's the same fact stated twice.
- Keep a downstream mention only if it warns of a real gotcha (a name that must match, a required
  order, a silent failure). Otherwise cut it.
- Before cutting one, check it isn't the only record of that dependency (compare against the
  `dependency` blocks in `terragrunt.hcl`). If it is, move it to the consumer's own doc instead of
  deleting it.
- `## What's Inside` must list every piece of the group, including ones deployed through
  app-of-apps instead of Terraform. Those are part of the group, not a dependency.

## Style

- Write the fewest characters possible while staying readable.
- Join list items with commas and "and", never slashes (e.g. `dev`, `staging`, and `prod`).
- Never use `;`, `-`, or an em dash (`—`) in the middle of a sentence. Use commas, parentheses, or
  split into two sentences instead.
- Never join two independent clauses with a comma. Split into two sentences instead.
- One idea per short sentence or paragraph.
