# Verification record

This package contains a conventional mathematical proof, not a Lean formalization.

The proof has three components:

1. A Gaussian finite-dictionary theorem for arbitrary globally Lipschitz activations, with a probability bound uniform in finite learner width and all 0 < σ² ≤ 1/N.
2. A Gaussian neighborhood comparison for cloned teachers, including unbounded activations and activations with nonzero value at zero.
3. A localized Bernstein and free-energy argument giving the stated data-dependent calibration and coefficient-one population-risk oracle.

The first complete derivation used a simpler finite-grid calibration. It was independently audited before the sharper localized argument was integrated. The localized abstract argument was separately checked by two research agents. The final seven-source package, including the deterministic-calibration appendix, passed an independent statement-and-proof audit. See [the integrated review](independent-integration-review.md) and [its source hashes](independent-integration-review-hashes.json).

The PDF is built in an isolated temporary directory with three LaTeX passes. The final build logs contain no unresolved references, LaTeX warnings, or overfull boxes. The first-page author order and alphabetical-order footnote were visually checked.
