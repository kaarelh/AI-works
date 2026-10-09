# Repository conventions

This repository holds several independent projects, one top-level folder each.

| folder | working branch |
|---|---|
| `paulsen/` | `claude/charming-lovelace-olmdo9` |
| `inferential-learning/`, `axiom-schemas/`, `axiom-induction/` | `claude/sleepy-gauss-u4kem1` |
| `christiano-point/` | `claude/vibrant-wright-pdohvb` |
| `foom-coom-transition/` | `codex/foom-coom-transition-2026-10-08` |
| `computational-cosmology/` | `codex/computational-cosmology-2026-10-08` |

## Working branches

* **Do the work on your session's own branch.** Drafts, scratch scripts, logs and orchestration files all stay there.
* **Find a project's full working state on its branch,** listed above or in that project's README.
* **Add a new project as a new top-level folder,** with its own README, and add it to the table above when you first publish it.

## Publishing to `main`

`main` is the public face of the repository: one curated copy of each project.

* **What to publish:** the README, the paper sources and PDF, code with its tests and results, and the records that support the claims (verification, referee reports, check scripts and their outputs).
* **What stays on the working branch:** scratch files, orchestration scripts, and build output.
* **When:** at milestones, or when the user asks.

Each project's README marks the paths that stay on its working branch. To publish, replace the project's folder on `main` with the version on the working branch, then remove those paths:

```
git fetch origin main && git checkout -B main origin/main
git rm -r -q --ignore-unmatch <folder>
git checkout <working-branch> -- <folder>
git rm -r -q <paths that stay on the working branch>
git commit -m "<folder>: publish <what changed>"
git push origin main
git checkout <working-branch>
```

## Rules for `main`

* **Change only your own project's folder.** Shared root files (this file, `.gitignore`) change only when the user asks.
* **If a push is rejected because `main` moved,** pull it again and redo the steps above. Never force-push `main` or rewrite its history.
