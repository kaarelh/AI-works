**Current formalization status:** The main learning statements now have Lean proofs. [Exact scope and exclusions](../../../lean/review/BatchTwo-coverage.md). The earlier conventional-proof and review record below describes the pre-formalization snapshot.

# Review and publication checks

The manuscript has a conventional mathematical proof, not a Lean formalization. Independent AI-agent reviews checked the expanding-map construction, sample separation, exact interpolation at low energy, strong-prior concentration, finite-scale Gaussian-distance argument, and the posterior-mixture obstruction. These reviews are not external peer review.

The mathematical reviews are:

- [Final assembled manuscript audit](manuscript-audit.md), covering all four source files and recording their hashes.
- [Independent mean-field audit](meanfield-audit.md), including the finite-probe extension to the fixed nonatomic distribution.
- [Additional mean-field construction and source audit](meanfield-construction-audit.md).

The [build record](build.json) identifies the published sources and PDF and records an isolated rebuild, matching extracted text, and absence of unresolved references or LaTeX warnings. The proof keeps the continuous-output result separate from the unresolved original Boolean-cube question.

The main quantifier distinction is between a sufficiently large finite width at every fixed exponent above one and a width-first limiting result at the mean-field endpoint. The endpoint gives a samplewise lower limit of confidence error at least one half; it does not assert that the error is already at least exactly one half at every sufficiently large finite width. Exact-interpolation claims concern the strong-prior setting and the specified order of limits.

The [Boolean-depth investigation](boolean-depth-investigation.md) records the remaining representation barriers and unsuccessful approaches. It is a research record, not a new Boolean learning theorem.
