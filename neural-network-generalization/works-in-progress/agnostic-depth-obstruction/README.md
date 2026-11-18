# Exponential depth costs in Bayesian neural regression with a one-neuron target

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

A deep Bayesian tanh network can need exponentially many IID examples in its **learner depth**, even when the conditional mean is one tanh neuron. The example has independent label noise and inputs on a unit sphere. Every positive Gaussian likelihood temperature fails on the same sample event, including data-dependent temperature choices and mixtures of the resulting predictions.

For each fixed `ν_max < 1`, the tanh result holds simultaneously at all sufficiently large widths and all prior scales `0 < Ns ≤ ν_max`. This includes every fixed scaling exponent `γ > 1`, and mean-field scaling with any fixed variance prefactor below one. At depth `H`, the construction has input dimension `O(H)`, sample count `exp(Ω(H))`, a width threshold `exp(O(H))`, and a fixed positive excess squared loss. The constants may depend on `ν_max`.

The manuscript also proves:

- A correctly specified Gaussian-noise version, including the true observation variance among the allowed likelihood choices.
- A version with any independent centered Gaussian output bias and direct linear input features. Their covariance can be arbitrary and singular; this version concerns raw posterior means.
- Versions with final clipping or tanh inside the likelihood, and several conventions for clipping predictions.
- A ReLU analogue with a fixed width-two target, for all fixed `γ > 1` at sufficiently large widths.
- A fixed-width strong-prior corollary.

The proof compares the posterior with both zero and a low-cost memorizer of the empirical label means. A matching lower bound on the prior cost of nonzero predictions places the posterior near the segment joining those two functions. A single sample witness separates that entire segment from the true regression function, so averaging temperatures or widths does not remove the obstruction.

The canonical mean-field prefactor `Ns = 1` is outside this paper's exponential-in-depth theorem. The result also does not assert a fixed-dimension or noiseless lower bound. These are conventional mathematical proofs with independent source-specific reviews; no Lean verification is claimed.

Run `./build.sh` to rebuild the PDF with pdfLaTeX.
