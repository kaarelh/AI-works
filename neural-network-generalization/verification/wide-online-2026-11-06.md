# All-width online-mistake research and publication

This record covers two supporting manuscripts added on 6 November 2026. Neither is Lean formalized. Existing mathematical sources and Lean files are unchanged.

## Standard tanh with arbitrarily small covariance asymmetry

[Paper and source](../works-in-progress/online-mistakes/anisotropic-allwidth/) · [independent reviews and build record](../works-in-progress/online-mistakes/anisotropic-allwidth/verification/)

The learner has one tanh hidden layer, a constant input coordinate, a linear readout, the global absolute output-margin condition, and exact labels. Its target is ordinary majority, with a unit-weight, one-neuron teacher (`C₂=1`). The proof controls every nonlinear network at every width through an essential-coordinate energy bound and a quantitative rigidity lemma.

For odd `q≥3`, take `d=9q` and input precision factors `λ_i=1+δ 2^(-i)`, where `0<δ≤1/(80000 q³)`. After `2q` calibration inputs, a fixed sequence has exactly `9^((q+1)/2)` designated errors in the strong-prior limit, for every learner width. All designated sampled errors occur with arbitrarily high probability at sufficiently small positive scale. Majority prediction and strict `>2/3` confidence fail too. A separate construction permits one fixed positive perturbation amplitude across dimensions and uses a larger calibration prefix.

The paper also proves:

- one sufficiently small positive mean-field scale works at every width;
- for every fixed `γ>1`, the corresponding unit-prefactor prior has the lower bound at every sufficiently large width;
- a sufficiently small common prefactor works for every width and every `γ≥1`;
- the same priors have IID confidence-error sample complexity `O((d⁴+log(1/β))/ρ)`, independent of width.

The first-layer variances are unequal. **This is not a resolution for the exactly isotropic prior.** The paper proves that exact isotropy leaves equal function masses in the relevant majority tier, and explains why that changes the posterior argument. The unit-prefactor mean-field case is also not covered.

Final PDF: 15 pages, SHA-256 `bfc57e65a638f5f589ce18bbe08ac69aae7623322a6de1d56c0a7306ad5cf394`. Final source: SHA-256 `c95fda1b984ef3153b1ec95f41e209855da5ca7f5b8c5c89f89ba68e8cc8a9f1`. Two independent reviews check that source snapshot, including the rigidity constants, posterior argument, calibration, uniform scale, IID comparison, and exponent corollary. A clean isolated three-pass build has matching extracted PDF text and no LaTeX warnings or unresolved references.

## Two explicitly restricted nonlinear variants

[Paper and source](../works-in-progress/online-mistakes/wide-nonlinear-variants/) · [independent reviews and build record](../works-in-progress/online-mistakes/wide-nonlinear-variants/verification/)

This paper gives an all-width lower bound with nonlinear activations approaching the identity as the target grows, and a separate result with one fixed standard nonlinear layer followed by linear layers without biases. The near-identity family also has a polynomial IID bound. These qualifications are part of the theorem statements; neither proves the original fixed-activation, fully nonlinear, exactly isotropic result.

The tanh appendices rigorously show that widening can introduce implementations cheaper than the scalar witnesses. One is a three-bit shortcut fitting the entire short calibration and query suffix; another is an exact finite-dimensional certificate for the true target. These are implementation-energy comparisons, not proofs of the wider posterior's prediction.

Final PDF: 15 pages, SHA-256 `9a94a1799a409bd4599778c4fbe4de46da673930d9b827e5e78bc9512804638e`. The paper's publication record and final full-paper review contain all seven source hashes. Its isolated rebuild matches extracted PDF text and has no unresolved references or LaTeX warnings. The exact rational tanh certificate was independently replayed and passed.

## Collection checks and remaining question

The collection inventory contains 76 canonical manuscripts. Its PDF-hash, file, and Markdown-link checks pass. The folder and repository READMEs, online-learning index, and technical FAQ distinguish these results from the unresolved exactly isotropic all-width problem. Current file checksums are in the folder's `SHA256SUMS` manifest.

All new author rosters follow the alphabetical convention and carry its footnote. The preceding author-only publication is recorded separately in [the author-order record](author-order-2026-11-06.md).

For the exactly isotropic prior on the exact Boolean cube, the outstanding task is to prove or disprove an exponential mistake lower bound for a standard coordinatewise activation at every sufficiently large width. A full-comparator calibration removes the three-bit shortcut but still needs a comparison between the best *arbitrary-width* correct and incorrect extensions. Scalar implementation energies, local numerical minima, and selecting one member of a tied minimum class do not supply that comparison.
