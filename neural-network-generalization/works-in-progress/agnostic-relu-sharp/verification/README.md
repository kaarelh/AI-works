# Verification record

This paper has conventional mathematical proofs, constructive numerical checks, and a reproducible LaTeX build. It is not Lean verified.

## Scope of the current revision

The positive result keeps the earlier full proof, with an improved exact comparator-balancing constant obtained from a localized ReLU realization. The finite positive regime remains `γ≥2`, with all `γ≥1` in the one-hidden-layer case.

The new negative proof covers every finite scale `0<σ²≤1/N`, every positive likelihood temperature, and every learner width above `O(m+n log n)`. Its selective Gaussian comparison preserves the dense unconditioned learner prior. Only a proof comparison measure narrows active incoming rows; no support restriction is introduced.

The new mixture theorem uses a Gaussian-readout sector inequality and a common linear witness. It covers arbitrary data-dependent mixtures of raw posterior means, including components clipped before mixing. It does not transfer the sector argument to the mean of clipped posterior draws, or assert that clipping an arbitrary mixture afterward preserves the lower bound.

The negative law has `ceil(log2 n)+2` input coordinates and a teacher of the stated width and weight cap. The number of nuisance atoms lies between `n` and `2n`; that factor is explicitly included in the population witness norm. All integer sample counts are covered. The noise is localized in input space.

## Checks

- A separate audit agent checked the localized balanced teacher, selective Gaussian KL calculation, pointwise RMS recurrence, and variable active-width profile. It confirmed that collapsing nonnegative clone-group isometries preserves both ReLU outputs and all weighted layer energies.
- A final independent mathematical review checked the assembled negative proof, mixture geometry, and consequences. It verified the nuisance-atom counting factors, collision variance, mixture-witness norm, localized-noise constants, and all-width/all-scale quantifiers. See [the review record](independent-review.md).
- The deterministic gated memorizer has been checked on 50 combinations of dimension, depth, and learner width, including unequal group sizes. Fourier values, vanishing signal outputs, coefficient norms, active profiles, and balanced energies passed, with maximum output discrepancy below `7e-15`.
- The PDF builds in three isolated passes, with no unresolved references, LaTeX warnings, or overfull boxes in the final pass.

The numerical checks verify the stated finite constructions; they are not a substitute for the mathematical proofs. The public theorem statements and their scope are in the PDF.
