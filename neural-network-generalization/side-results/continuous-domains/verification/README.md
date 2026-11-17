# Review and publication checks

**Current formalization status:** The main learning statements and the important extensions identified in the audit now have Lean proofs. See the [15 November completion record](../../../lean/review/coverage-completion-2026-11-15.txt) and [current coverage inventory](../../../lean/review/coverage-extension-2026-10-30.txt). The [second-batch coverage record](../../../lean/review/BatchTwo-coverage.md) is an earlier baseline; the conventional-proof reviews below describe the pre-formalization snapshot.

## Mathematical review

The snapshot reviewed here had a conventional mathematical proof and no Lean formalization. The main statements were formalized later. (Status clarification revised 10 November 2026.) Independent AI-agent reviews checked the continuous-domain extension, the posterior and covering arguments, and the exact-interpolation corollary. They are not external peer review.

- [Independent mathematical audit](mathematical-audit.md).
- [Independent cross-check of regression and mean-field arguments](cross-audit.md).
- [Assembled manuscript review](manuscript-audit.md).
- [Additional assembled mean-field review](meanfield-audit.md).

The reviews check the separation between teacher width and weight magnitude, the uniformity over learner width, the train/test tolerance gap, and the distinction between binary labels and real-valued scores. The exact-interpolation argument requires the stated order of limits: strong prior first, zero training tolerance second.

## Build evidence and source paths

The [build record](build.json) identifies the source and PDF hashes of the 18 October snapshot. It records an isolated rebuild, extracted-text agreement, and checks for unresolved references and LaTeX warnings. That snapshot predates later revisions; use the collection's `SHA256SUMS` for the current files. (Snapshot clarification noted 10 November 2026.) Complete source is included under [source/](../source/). The manuscript explicitly cites the shared finite-input compression ingredients from the [non-Gaussian paper](../../non-gaussian-priors/paper.pdf); its continuous-domain reductions and exact-interpolation argument are proved in the paper.

The review files refer to research-note filenames or a `paper/` source directory used during development. The final source hashes in the build record identify the version published on 18 October.
