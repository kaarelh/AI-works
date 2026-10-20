# Order of the two human authors

20 October 2026. Dmitry Vaintrob and Kaarel Hänni are the two human authors of most papers in this collection. This record fixes the order of their two names on each paper and shows how anyone can check it.

## The rule

Three orders were decided by the authors:

| paper | order |
|---|---|
| [strong-prior-generalization](../main-results/strong-prior-generalization/) | Hänni first |
| [gamma-above-one](../main-results/gamma-above-one/) | Vaintrob first |
| [meanfield-all-width](../main-results/meanfield-all-width/) | Vaintrob first |

Every other paper or note with both names as authors was randomized: 35 in all, 33 catalogued papers and two Markdown notes. The draw gives one order to 18 of them and the other to 17, and a separate random bit decides which order gets 18.

1. **Ranking.** Each title is hashed with SHA-256 (UTF-8 encoding); the digests, read as integers, rank the 35 items, smallest first. The title is the `title` field in [catalog.json](../catalog.json), or a note's first heading, as recorded in [author-order-2026-10-20.json](author-order-2026-10-20.json).
2. **Split bit.** The 35 titles are sorted in code-point order, joined with newlines and hashed with SHA-256. If the last bit of the digest is 0, Kaarel Hänni is first on the first 18 items in the ranking. If it is 1, he is first on the first 17.
3. **Other authors.** Every other author keeps their position; only the two human names move.

Given the titles, the hash ranking behaves like a uniformly random permutation, and its first $m$ items like a uniformly random set of $m$. Each paper therefore gets either order with probability 1/2, and the total split is 18/17 one way or the other. Unlike independent coin flips per paper, the outcomes are not independent across papers: fixing the totals makes them slightly negatively correlated.

**The draw.** The split digest is `058250d591652459c3073746f1f7f9ceaa740ae2ac1371bea445f81a5c661240`. Its last bit is 0, so Kaarel Hänni is first on 18 randomized items and Dmitry Vaintrob on 17. With the three fixed papers, each is first on 19 of the 38.

## Commit order

The rule was committed before it was computed, so that the outcome could not have shaped it.

- Commit `50f6df57` fixed a first rule: the parity of each title's letter sum. When computed, it gave 21 items to one order and 14 to the other. At the authors' request it was replaced, before it was applied to any paper.
- Commit `52360309` fixed the rule above, again before it was computed. Its rule code is unchanged in [author_order.py](author_order.py); the script later gained only a check of the sources.

The canonical certified protocol is the American Economic Association's author randomization tool. It records each draw publicly, and papers using it mark the order with ⓡ ([Ray ⓡ Robson, 2018](https://doi.org/10.1257/aer.20161492)). This record uses an offline hash draw instead, which anyone can rerun without a third party.

## Result

Randomized items, in ranking order (the first 18 get Kaarel Hänni first):

| rank | paper | order | title SHA-256 |
|---|---|---|---|
| 1 | [fisher-degree-reductions](../side-results/fisher-degree-reductions/) | Hänni first | `0945f0fe16d7…` |
| 2 | [symmetric-parity-amplitudes](../side-results/symmetric-parity-amplitudes/) | Hänni first | `0fa15bd4b2a7…` |
| 3 | [subcritical-circuit-prior](../side-results/subcritical-circuit-prior/) | Hänni first | `10b7043c365c…` |
| 4 | [gamma-zero-mean-energy](../side-results/gamma-zero-mean-energy/) | Hänni first | `12297eef940e…` |
| 5 | [parity-contact-calibration](../side-results/parity-contact-calibration/) | Hänni first | `12eedd1648d2…` |
| 6 | [critical-depth](../works-in-progress/critical-depth/) | Hänni first | `2c5b6dadde3f…` |
| 7 | [growing-sparse-positive](../side-results/growing-sparse-positive/) | Hänni first | `43aba7703787…` |
| 8 | [slt-likelihood](../works-in-progress/slt-likelihood/) (note) | Hänni first | `53297b33d296…` |
| 9 | [subcritical-gaussian-conditioning](../side-results/subcritical-gaussian-conditioning/) | Hänni first | `5ec6205c9f68…` |
| 10 | [positive-subcritical-sample-complexity](../works-in-progress/positive-subcritical-sample-complexity/) | Hänni first | `605e61e1d695…` |
| 11 | [continuous-domains](../side-results/continuous-domains/) | Hänni first | `642fefc5b5cb…` |
| 12 | [intermediate-parity](../side-results/intermediate-parity/) | Hänni first | `678497dfb2b2…` |
| 13 | [non-gaussian-priors](../side-results/non-gaussian-priors/) | Hänni first | `712295eef0bc…` |
| 14 | [gaussian-exponential-lower-bound](../side-results/gaussian-exponential-lower-bound/) | Hänni first | `7cfcd48b316d…` |
| 15 | [zero-gamma-conditioning-note](../side-results/zero-gamma-conditioning-note/) | Hänni first | `8fdf160ccd0e…` |
| 16 | [finite-width-subcritical](../side-results/finite-width-subcritical/) | Hänni first | `8fff5e17dabc…` |
| 17 | [slt-finite-sample](../works-in-progress/slt-finite-sample/) (note) | Hänni first | `90e225548b3c…` |
| 18 | [cubic-parity-repair-certificate](../side-results/cubic-parity-repair-certificate/) | Hänni first | `930bd517d627…` |
| 19 | [robust-polynomial-depth](../main-results/robust-polynomial-depth/) | Vaintrob first | `98b50a810832…` |
| 20 | [meanfield-quantified-width](../side-results/meanfield-quantified-width/) | Vaintrob first | `9a283901754b…` |
| 21 | [gamma-below-one](../side-results/gamma-below-one/) | Vaintrob first | `a5c91a90a69a…` |
| 22 | [unrestricted-depth](../works-in-progress/unrestricted-depth/) | Vaintrob first | `a8c394d0c6a2…` |
| 23 | [depth-round2-shallow-targets](../works-in-progress/depth-supporting-notes/round2-shallow-targets/) | Vaintrob first | `aa05d9e97a7d…` |
| 24 | [subcritical-exponential](../main-results/subcritical-exponential/) | Vaintrob first | `c0566bee4d11…` |
| 25 | [gamma-ge1-endpoint](../side-results/gamma-ge1-endpoint/) | Vaintrob first | `c1c4020b5717…` |
| 26 | [nngp-sample-complexity](../side-results/nngp-sample-complexity/) | Vaintrob first | `c2a357a6fcb5…` |
| 27 | [homogeneous-cell-calibration](../side-results/homogeneous-cell-calibration/) | Vaintrob first | `c368aebffb02…` |
| 28 | [subcritical-sample-complexity](../side-results/subcritical-sample-complexity/) | Vaintrob first | `c616d3e7a968…` |
| 29 | [continuous-depth-lower-bound](../works-in-progress/continuous-depth-lower-bound/) | Vaintrob first | `cb60ea96b4df…` |
| 30 | [sparse-parity](../side-results/sparse-parity/) | Vaintrob first | `d0aa8ca67205…` |
| 31 | [selected-examples-parity](../side-results/selected-examples-parity/) | Vaintrob first | `dbe77a741da7…` |
| 32 | [growing-depth-parity](../side-results/growing-depth-parity/) | Vaintrob first | `e442c8784aef…` |
| 33 | [depth-round2-critical-rates](../works-in-progress/depth-supporting-notes/round2-critical-rates/) | Vaintrob first | `eac1a80278d1…` |
| 34 | [structured-parity-repair-certificates](../side-results/structured-parity-repair-certificates/) | Vaintrob first | `ff564a3cd4f9…` |
| 35 | [gaussian-exponential-schedule](../side-results/gaussian-exponential-schedule/) | Vaintrob first | `ff73f85a5874…` |

## What changed

- **Author lines.** The `\author` line and PDF metadata of the 17 papers that now have Kaarel Hänni first: strong-prior-generalization and the 16 catalogued items above whose order changed. Before this change every paper and note listed Dmitry Vaintrob first, so only the items assigned Kaarel Hänni first changed. The strong-prior paper's README and catalog entry, and the bylines of the two notes, were updated too. These PDFs were rebuilt, and nothing else in them changed.
- **Citations.** One citation inside the collection changed: the continuous-domains paper cites the non-Gaussian-priors paper, whose order changed. The other citations of collection papers were checked and need no change, because they cite papers whose order is unchanged:
  - gamma-above-one cites meanfield-all-width, gamma-below-one and subcritical-exponential;
  - gamma-below-one cites nngp-sample-complexity;
  - meanfield-quantified-width cites gamma-ge1-endpoint;
  - standard-nngp-parity cites subcritical-exponential and nngp-sample-complexity.
- **A stale title.** standard-nngp-parity cited main result 4 under its former title. The citation now uses the current title, and that paper was rebuilt.

## Not covered by the rule

- **Papers without both names as authors:**
  - standard-nngp-parity (Claude);
  - gamma-proof-audit (OpenAI Codex);
  - the two depth round reports (OpenAI Codex and Claude);
  - strong-prior-appendix-audit (prepared by ChatGPT for the two authors).
- **Works outside the collection.** Citations of the Vaintrob–Hänni lecture notes and slides, and of the arXiv paper *Width-Robust Learnability in Mean-Field Bayesian Neural Networks*, keep their published order.
- **Byline and records.** The collection README's byline is unchanged. So are historical records and frozen build inputs: the copies in `works-in-progress/depth-experiments/` and its `root-audits/`, and the earlier JSON records.

## How to check

From the collection root:

```sh
python3 verification/author_order.py --check
```

This recomputes the ranking, the split bit and every assignment from the titles frozen in the record. It also checks each paper's `\author` line, PDF metadata, README `**Authors:**` line and catalog entry, and each note's byline, against the record. It exits nonzero on any mismatch. The commit order can be checked with `git log --follow verification/author_order.py`.
