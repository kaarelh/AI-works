# Exponential online mistakes at every width for isotropic threshold networks with a residual

[Read the paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

A fixed **threshold activation with a residual** gives exponentially many online mistakes at every hidden width in the usual strong-prior limit, under the unchanged Gaussian prior. The paper covers both `sign(t) + t` and the bounded activation `sign(t) + tanh(t)`. The bounded result also holds for `sign(t) + c tanh(t)` with any fixed `0 < c ≤ 1`, however small.

For each k ≥ 3, the target on d = 2k + 1 Boolean inputs has a Boolean circuit of size Θ(k) and a **width-one teacher with every weight bounded by one**. A fixed input permutation contains at most 4k + 3 calibration examples followed by 2^k − k − 1 designated errors. Every competing network at every width is included in the proof.

The learner retains the full Boolean cube, one constant input coordinate, global output margin greater than 1/2, exact labels, and the Gaussian variances

- First layer: `N σ²/d`, equally for every coordinate, including the bias.
- Readout: `σ²/N`.

There is no coordinate anisotropy or extra readout penalty. The posterior wrong-label probability at every designated round tends to one as σ tends to zero at **each fixed width N ≥ 1**. The paper also proves direct width-dependent statements for `σ² = τ² N^(−γ)`:

- For every fixed γ > 1 and τ > 0, the errors occur at all sufficiently large widths.
- For any desired confidence, one sufficiently small fixed τ gives all designated errors uniformly at every N ≥ 1 and every γ ≥ 1.

For the same target and prior, IID sample complexity is polynomial: `O((d² + log(1/β))/ε)` examples suffice for correct-label posterior probability greater than 2/3 outside a set of input mass at most ε, with sample confidence at least 1 − β, in the stated prior limits.

The proof has two main ingredients. The minimum network energy at any width is an explicit strictly increasing function of the minimum affine unit-margin squared norm. A convex-hull certificate gives an energy gap to every nonthreshold Boolean function. A product-box Gaussian estimate transfers these comparisons to the actual posterior, including growing width.

**The activations are discontinuous.** The proof uses their jump at zero; it does not establish the corresponding result for ordinary tanh, ReLU, or hardtanh. Nor does it establish the unit-prefactor mean-field case γ = 1, τ = 1.

Authors: ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob, in alphabetical order.

The result has independent AI-agent mathematical reviews. It has not been formalized in Lean. To rebuild the PDF, run `./build.sh` (requires `pdflatex`).
