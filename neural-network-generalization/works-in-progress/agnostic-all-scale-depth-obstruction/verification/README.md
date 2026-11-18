# Verification record

The latest complete reviewed snapshot is the [independent integration review](independent-final-twentythree-source-review.md), with [exact source hashes](independent-final-twentythree-source-review-hashes.json). These hashes match the current sources. Earlier review files record narrower snapshots.

The manuscript has undergone mathematical review by a separate AI agent. This review is not Lean verification.

The [independent full review](independent-full-review.md) covers the critical-variance estimates, sharp coefficient-four exponential moments, finite-set Gaussian feature encoding, covariance-spike comparison, actual function-neighborhood probabilities, and the canonical all-temperature learning obstruction. The [final integration review](independent-final-integration-review.md) and its hash record cover the assembled manuscript and its later extensions. Exact-source hashes identify the versions reviewed.

The build runs LaTeX three times and rejects undefined references, undefined citations, LaTeX errors, or overfull boxes. `build-hashes.json` records the final source and PDF.

Main scope checks:

- The learner prior remains an independent Gaussian law; the dependent Gaussian laws are variational comparisons only.
- The function comparison is finite-width and uniform over all target values in its stated amplitude range.
- The statistical event is common to every eligible width, prior scale, likelihood variance, and stated prediction mixture.
- Bounded-noise, Gaussian-noise, bounded-likelihood, and affine-output statements have explicitly distinguished conventions and constants.
- Affine-output extensions concern raw posterior means under the raw Gaussian likelihood.
- The theorem concerns noisy regression and does not claim a noiseless Boolean lower bound.
