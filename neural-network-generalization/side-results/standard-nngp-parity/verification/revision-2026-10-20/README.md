# Records of the 20 October 2026 revision

These files support the revision described in [../review.md](../review.md#revision-of-20-october-2026). They are working records written by AI agents. They are kept for reproducibility and are not part of the paper.

| File | Content |
|---|---|
| [exploration-synthesis.md](exploration-synthesis.md) | Ranked synthesis of the strategies explored for an $\exp(\Omega(d))$ bound, with their vetting |
| [S1-proof.md](S1-proof.md) | Full write-up of the typical-sample theorem and its referee responses. It records the earlier version, which was conditional on [SE, Lemma 4.1] and had probability $3/4$; the paper's Theorem 6.13 supersedes it |
| [ThmA-proof.md](ThmA-proof.md) | Full write-up of the sharper conditioning-cost lower bound, and the replacement text for the old Section 6 |
| [lemma-C-attempt.md](lemma-C-attempt.md) | Attempt at a log-free one-sided coercivity lemma at linear degree. It remains open; one check of the attempt is in [lemma-C-check.json](lemma-C-check.json) |
| [lemma-T-draft.md](lemma-T-draft.md) | Draft argument for the two-sided bound $\theta_r\asymp r^{-1/2}$. It had one informal AI check, which found no fatal flaw ([lemma-T-check.json](lemma-T-check.json)); it is not a full review, and the paper does not use the bound as a result |
| `scripts/` | Check scripts and their outputs |

The write-ups refer to a scratch directory where they were produced; those paths do not exist in this repository. The scripts read and write files relative to that directory, and a few need intermediate `.npy` files that are not included. They document the checks that were run; they are not a packaged reproduction. The paper's own numerics are in [../../numerics/](../../numerics/) and are reproducible.
