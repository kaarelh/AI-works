# Finite-width bounds for the globally margined tanh posterior

**[Read the paper](paper.pdf)** · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

Research proof draft, updated 26 October 2026. These results concern the actual Gaussian posterior conditioned on absolute output margin greater than `1/2` on the entire Boolean cube and then on exact training labels. They are not limiting-width or selected-minimum statements.

The paper proves four finite-width facts for tanh hidden layers with augmented input, no internal biases, and a linear readout:

- **An upper bound essentially quadratic in learner width.** A width-`C`, depth-`L`, globally unit-margined teacher with weights bounded by `B` is learned at every width `N ≥ C` with sufficient samples `O([Nd + LN²] L log(d+C+L+B+N+2))` at fixed accuracy and confidence. The theorem supplies the general accuracy/confidence factors and is uniform over every common canonical Gaussian prefactor `0 < t ≤ 1`, including strong-prior limits. It retains learner-width dependence; it is not the sought universal polynomial bound in teacher resources alone.
- **A linear-width upper bound for Boolean circuit targets.** A layered bounded-fan-in circuit with `H` stages and width `C`, counting constant wires, has raw correct-margin mass at least `exp(-2002N(d+CH)/t²)` once `N ≥ 1600C[d log 2 + log(8CH)]`. The actual posterior therefore learns it with `O((N(d+CH)/t² + log(1/(εδ)))/ε)` examples. This is linear in width at the critical scale `t=1`; it retains an inverse-scale factor and does not give a cold-limit bound. Layerwise widths replace `CH` by their sum. The target hypothesis is a digital Boolean circuit, not an arbitrary tanh teacher with soft hidden states.
- **A logarithmic-dimension lower bound for a constant target.** Exact signed permutations of augmented input coordinates preserve the full conditioned posterior. If `k` input-coordinate columns are constant across the observed sample, the correct-label confidence-failure mass is at least `1/2 − 2^(−k−1) binom(k, floor(k/2))`. Uniform iid examples therefore require `Ω(log d)` samples for any fixed desired failure mass below `1/2`. The result holds at every finite width and depth, and at every positive Gaussian prefactor.
- **Correct-label posterior probability need not increase with width.** A two-dimensional, three-example construction has correct-label posterior probability exactly one at width one and strictly below one at width two. This does **not** show a crossing of the original `2/3` confidence threshold, a uniform probability gap, or strictness after a cold limit.

When `d`, `C`, and `B` are polynomial in depth, the upper bound forces any `exp(cL)` sample lower bound to occur at widths with `log N ≥ cL/2 − O(log L)`. The symmetry lower grows only logarithmically with dimension, and the width example blocks only a proposed pointwise monotonicity principle. **The original canonical-tanh polynomial-versus-exponential depth question remains open.**

## Proof notes

- [Canonical finite-width posterior cover](research-notes/canonical-finite-width-posterior-cover.md): teacher cloning, uniform Gaussian neighborhood mass, posterior energy tail, margin-stable net, and the confidence guarantee.
- [Gaussian mean-shift Boolean-circuit bound](research-notes/finite-width-boolean-circuit-mean-shift-learning.md): deterministic circuit planting, all-cube concentration, exact entropy cost, and the actual posterior sample guarantee.
- [Projective symmetry lower](research-notes/finite-width-projective-symmetry-lower.md): exact posterior symmetry, multiple constant columns, iid consequence, and the limitation of a single symmetry orbit.
- [Width-monotonicity obstruction](research-notes/finite-width-posterior-monotonicity-obstruction.md): explicit strict-margin networks and the distinction between raw-prior averaging and margin-conditioned sign laws.

The [independent mean-shift audit](verification/finite-width-boolean-circuit-mean-shift-learning-audit.md) covers the new circuit result. The assembled paper includes the proofs and does not require the notes as prerequisites. The [independent full-manuscript audit](verification/finite-width-posterior-assembly-independent-audit.md) and [upper-bound audit](verification/canonical-finite-width-posterior-cover-independent-audit.md) are conventional mathematical checks. **These results are not Lean verified.**

## Build

Run `./build.sh` from this directory. It requires `pdflatex` and the standard packages listed in the source. Auxiliary files go in `.build/`; the final document is copied to `paper.pdf`. The [build manifest](verification/build-manifest.json) records exact source and PDF hashes.

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
