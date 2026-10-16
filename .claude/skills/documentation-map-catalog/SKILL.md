---
name: documentation-map-catalog
description: Map of every EKS Forge site page. Read before planning or implementing a change.
---

Read the map:
```bash
gh api repos/ConsciousML/eks-forge/contents/documentation-map.csv -H "Accept: application/vnd.github.raw"
```

One row per site page: `route`, `type`, `title`, `description`, and `source`.

Find the pages related to your task and read them first. A `source` containing
`eks-forge-catalog/` is a file of this repo. `route` is the page's path under
https://eks-forge.readthedocs.io/latest.

A page whose `source` is empty, or has no `_external/` path, lives in the `eks-forge` repo. The
docs agent owns it. Never edit it. When your change affects one, follow step 9 "Site Docs Issue"
of the `github-workflow-catalog` skill.
