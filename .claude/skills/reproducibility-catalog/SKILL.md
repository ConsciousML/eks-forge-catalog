---
name: reproducibility-catalog
description: Regenerate and commit provider lock files (`.terraform.lock.hcl`). Use after adding a unit, or adding or bumping a provider version, and before calling that change done. CI fails on a unit without a committed lock file.
---

Follow [Commit the Lock File](../../../docs/add-a-unit.md#commit-the-lock-file) for the steps.
Run it unprompted whenever a change adds, removes, or bumps a provider requirement, don't wait for CI or
the user to notice a stale lock file.
