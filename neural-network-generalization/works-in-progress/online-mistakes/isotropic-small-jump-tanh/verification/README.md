# Verification record

This paper is not Lean verified. Its mathematical statements and proofs were checked by independent AI agents, with particular attention to the relationship between the energy optimization and the actual posterior.

The review covers:

- The exact affine reduction for `tanh(t)+ε sign(t)`, including all nonlinear competitors and every hidden width.
- Equality rigidity and a compact probability-measure relaxation proving a **uniform-in-width** energy gap after the first new query, when the next full covariance certificate is not yet available.
- The explicit pairwise-independent calibration, its KKT means and covariance bound, the fixed input order, and all example counts.
- The Gaussian product-box estimate, fixed-width cold limits, direct `γ > 1` width limits, and uniform small-prefactor `γ ≥ 1` quantifiers.
- The bounded-monotone compression into a majority of affine thresholds and the resulting IID confidence bound.
- The bounded teacher, Boolean circuit complexity, and the distinction between a small discontinuous perturbation and ordinary tanh.

The individual review files identify the exact source snapshots they checked. The publication build record lists final source and PDF hashes; the isolated rebuild checks the extracted PDF text. Review and build success do not constitute a formal proof.

## Review and build files

- [Full manuscript review](full-paper-review.md)
- [Independent integrated review](independent-review.md)
- [Dual, posterior, and compression review](dual-and-compression-review.md)
- [Independent selector review](selector-review.md)
- [Final hashes and build record](publication-build.json)
- [Isolated rebuild comparison](isolated-build.txt)

The PDF was visually checked on pages 1, 2, 5, and 10, including the title/authors/footnote, main theorem, uniform-gap argument, and compression proof.
