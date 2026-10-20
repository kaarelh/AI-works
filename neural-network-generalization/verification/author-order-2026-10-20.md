# Order of the two human authors

20 October 2026. Dmitry Vaintrob and Kaarel Hänni are the two human authors of most papers in this collection. This record fixes the order of their two names on each paper or note that lists both of them, and shows how anyone can check it.

## The rule

Three orders were decided by the authors:

| paper | order |
|---|---|
| [strong-prior-generalization](../main-results/strong-prior-generalization/) | Hänni first |
| [gamma-above-one](../main-results/gamma-above-one/) | Vaintrob first |
| [meanfield-all-width](../main-results/meanfield-all-width/) | Vaintrob first |

Every other paper or note with both names as authors was randomized: 35 in all, 33 catalogued papers and two Markdown notes. The draw gives one order to 18 of them and the other to 17, and a separate random bit decides which order gets 18.

1. **Ranking.** Each title is hashed with SHA-256 (UTF-8 encoding). The digests, read as 256-bit big-endian integers (equivalently, the hex digests sorted as strings), rank the 35 items, smallest first. The title is the `title` field in [catalog.json](../catalog.json), or a note's first heading, as recorded in [author-order-2026-10-20.json](author-order-2026-10-20.json).
2. **Split bit.** The 35 titles are sorted in code-point order and joined with single newlines, with no trailing newline; the UTF-8 bytes are hashed with SHA-256. If the last bit of the digest is 0 (its last hex digit is even), Kaarel Hänni is first on the first 18 items in the ranking. If it is 1, he is first on the first 17.
3. **Other authors.** Every other author keeps their position; only the two human names move.

Treat SHA-256 as a random function, the usual heuristic for hash draws. The ranking is then a uniformly random permutation of the 35 items. The split bit is an independent fair coin, since its input, all titles joined, differs from every single title. So each item gets Kaarel Hänni first with probability ½·18/35 + ½·17/35 = 1/2, and the totals are exactly 18/17 one way or the other. Unlike independent coin flips, the outcomes for different items are not independent: fixing the totals gives any two items a correlation of −1/35.

**The draw.** The split digest is `058250d591652459c3073746f1f7f9ceaa740ae2ac1371bea445f81a5c661240`. Its last bit is 0, so Kaarel Hänni is first on 18 randomized items and Dmitry Vaintrob on 17. With the three fixed papers, each is first on 19 of the 38.

## Commit order

Each rule was committed, and pushed to GitHub, before it was run and before any paper was changed. Git records this order. It cannot by itself show that a rule was not computed privately before it was committed.

- Commit `50f6df57` fixed a first rule: the parity of each title's letter sum. When computed, it put Kaarel Hänni first on 21 items and Dmitry Vaintrob first on 14. That is not the exact 18/17 split the authors asked for, so at their request it was replaced before it was applied to any paper. With the three fixed papers, the replacement lowered Kaarel Hänni's total from 22 to 19.
- Commit `52360309` fixed the rule above, before it was run. Its rule code is unchanged in [author_order.py](author_order.py); the script later gained only checks of the sources. The docstring committed there says "before any outcome was computed" and "before this script was first run". Both refer to the second rule and that version of the script; the first rule had been computed with the `50f6df57` version. Its "21 papers" means 21 items, including the two notes.

These commits are on the working branch `claude/sharp-brahmagupta-6rkm74`, not on `main`, which receives one publish commit per update. To check their order:

```sh
git fetch origin claude/sharp-brahmagupta-6rkm74
git log --format="%h %cI %s" origin/claude/sharp-brahmagupta-6rkm74 -- neural-network-generalization/verification/author_order.py
git show 52360309:neural-network-generalization/verification/author_order.py
```

## Other protocols

The best-known protocol for certified random author order is the American Economic Association's randomization tool. It records each draw publicly, and papers using it mark the order with ⓡ ([Ray ⓡ Robson, 2018](https://doi.org/10.1257/aer.20161492)). This record uses an offline hash draw instead, which anyone can rerun without a third party. The papers carry no ⓡ mark, since this draw is not an independent uniform order for each paper. A future draw could also hash in a public randomness value fixed in advance, such as a named round of a public randomness beacon, so that the outcome could not be computed before that round.

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

- **Author lines.** The `\author` line of the 17 papers that now have Kaarel Hänni first, and their PDF author metadata where the source sets it: strong-prior-generalization and the 16 catalogued items above whose order changed. Two of them, cubic-parity-repair-certificate and gamma-zero-mean-energy, set no PDF author metadata, before or after. Before this change every paper and note listed Dmitry Vaintrob first, so only the items assigned Kaarel Hänni first changed. The strong-prior paper's README and catalog entry, and the bylines of the two notes, were updated too. These PDFs were rebuilt; apart from the citation below, nothing else in them changed, as a comparison of their extracted text before and after confirms.
- **Citations.** One citation inside the collection changed: the continuous-domains paper cites the non-Gaussian-priors paper, whose order changed. The other citations of collection papers that name the authors cite papers whose order is unchanged:
  - gamma-above-one cites meanfield-all-width, gamma-below-one and subcritical-exponential;
  - gamma-below-one cites nngp-sample-complexity;
  - meanfield-quantified-width cites gamma-ge1-endpoint;
  - standard-nngp-parity cites subcritical-exponential and nngp-sample-complexity;
  - the round-1 depth report cites the collection as a whole, under its unchanged byline.

  The remaining citations of collection papers give only titles or paths, so nothing in them depends on author order.
- **A stale title.** While checking citations, a stale title unrelated to author order was also fixed. standard-nngp-parity cited subcritical-exponential (main result 4) under its former title, *Exponential parity sample complexity throughout the subcritical width regime*. It now uses the current title, and that paper was rebuilt.
- **Two papers with one printed title.** positive-subcritical-sample-complexity, an earlier version, prints the same title as subcritical-sample-complexity. Their catalog titles differ, and the draw used those, so the two now have opposite orders.

## Not covered by the rule

- **Papers without both names as authors:**
  - standard-nngp-parity (Claude);
  - gamma-proof-audit (OpenAI Codex);
  - the two depth round reports (OpenAI Codex and Claude);
  - strong-prior-appendix-audit (prepared by ChatGPT for the two authors).
- **Works outside the collection.** Citations of the Vaintrob–Hänni lecture notes (also cited as slides), and of the arXiv paper *Width-Robust Learnability in Mean-Field Bayesian Neural Networks*, keep their published order. So does the credit to the two authors for the outline of the Claude Fable 5 draft cited by gamma-above-one.
- **Byline and records.** The collection README's byline is unchanged. So are historical records and frozen build inputs: the copies in `works-in-progress/depth-experiments/` and its `root-audits/`, and the earlier JSON records. In particular, the strong-prior author order and PDF hashes in [claude-authorship-2026-10-19.json](claude-authorship-2026-10-19.json) are superseded by this record.

## How to check

From the collection root:

```sh
python3 verification/author_order.py --check
```

This recomputes the ranking, the split bit and every assignment from the titles frozen in the record. It confirms that the record covers exactly the papers and notes that currently list both authors, with the same titles. It checks the following against the record, and exits nonzero on any mismatch, including a missing name:

- each paper's `\author` line;
- the `pdfauthor` setting in its source;
- its README `**Authors:**` line and catalog entry;
- each note's byline;
- every bibliography entry in the collection that cites a recorded title and names both authors.

It does not open the PDFs. Their checksums, which `verify_collection.py` checks against the catalog, tie them to these sources.

Running the script without `--check` recomputes everything from the current catalog titles and note headings, and gives the same assignment. To confirm that the frozen titles are the ones that stood when the rule was committed, compare the record with `git show 52360309:neural-network-generalization/catalog.json` on the working branch; the commands are under [Commit order](#commit-order).
