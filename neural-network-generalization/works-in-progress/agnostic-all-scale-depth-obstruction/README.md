# A depth obstruction for Gaussian Bayesian tanh networks

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

A deep Bayesian tanh network can retain fixed positive excess squared risk after **exponentially many samples in the square root of its depth**, even when the conditional mean has a width-two, one-hidden-layer implementation. One sample event covers every learner width above a fixed polynomial in the sample count, every Gaussian scale at or stronger than mean field, and every positive Gaussian-likelihood variance, including data-dependent choices and mixtures of posterior means.

The independent weight variances are `Ns/d` in the first layer, `s` internally, and `s/N` in the readout, for every `0 < s ≤ 1/N`. This includes every exponent `s = N^(-gamma)` with `gamma ≥ 1`. Inputs lie on a unit sphere. The prior has full support and is not modified for the proof.

There is also a quantitative transition below critical mean field. If the allowed scales obey `Ns ≤ 1−Delta`, the obstruction holds after `exp(Omega(sqrt(H)+Delta*H))` samples, in dimension `O(sqrt(H)+Delta*H)`, with constants uniform in the gap. Thus the crossover to the linear-depth exponent begins at a gap of order `1/sqrt(H)`.

The crossover applies to each version below, with its stated prediction conventions:

- Bounded independent label noise, with raw or clipped posterior predictions.
- Gaussian label noise, including the correctly specified observation variance.
- An arbitrary independent centered Gaussian affine output component, including any Gaussian output bias, under the raw Gaussian observation model. This also permits Gaussian label noise and arbitrary mixtures over all the learner parameters.
- A final clip or tanh used inside both the likelihood and prediction, with bounded label noise. This version concerns the mean of the bounded network output and does not include an affine skip.

The proof identifies the function prior at canonical mean-field scaling. On a domain with `exp(O(sqrt(H)))` inputs, every sufficiently small bounded function has precision-normalized relative-entropy cost nearly `4 ||f||∞`, with a matching lower bound. The posterior consequently behaves like a capped empirical predictor. For smaller variance prefactors, a depth-dependent baseline enters the prior cost and cancels in the statistical comparison. Noisy singleton labels give a common error witness across the learner family. The paper also proves actual function-neighborhood probabilities and sharp one-input output tails.

The lower bound rules out a sample guarantee polynomial jointly in learner depth, input dimension, and teacher complexity, uniformly over learner width, for this unrestricted Gaussian family. It does not rule out sample bounds that depend polynomially on learner width. It is compatible with fixed-depth polynomial guarantees. The construction uses label noise; it does not settle the corresponding noiseless Boolean problem.

The proofs have undergone independent AI-agent mathematical review. They are not Lean formalized. Run `./build.sh` to rebuild the PDF. Authors are listed alphabetically.
