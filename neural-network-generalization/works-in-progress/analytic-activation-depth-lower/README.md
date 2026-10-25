# Exponential sample complexity for an analytic activation arbitrarily close to tanh

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Critical appendix](source/critical-appendix.tex) · [Verification record](verification/README.md)

There is one fixed, computable activation arbitrarily close to tanh for which the original Gaussian NNbayes learner needs exponentially many examples in teacher depth, even though the Boolean target has a teacher with polynomial width, coefficient magnitudes, and coefficient bit length. No robustness restriction is imposed on the prior.

**The activation is deliberately engineered to encode hard truth tables. This does not prove a depth lower bound for exact tanh, ReLU, or GELU.** Evaluating the constructed activation to the accuracy used by its teachers requires exponentially large Boolean circuits; its computation is not captured by counting the teacher's neurons and weights alone.

## Result

For every fixed derivative order `r≥1` and tolerance `η>0`, the paper constructs a single activation `φ` that is:

- odd, real analytic, strictly increasing, and strictly concave on the positive half-line;
- globally 1-Lipschitz, with `φ(0)=0`, `φ′(0)=1`, and range `(−1,1)`;
- within `η` of tanh in the global `C^r` norm.

On the uniform Boolean cube of dimension `d`, a computable family of targets has `φ`-network teachers with depth `L=Dd+O(1)`, width and coefficient magnitudes `O(d)`, polynomial coefficient bit length, and global signed output greater than one. Nevertheless, for some fixed `c>0`, **every training sample of at most `exp(cd)` points leaves posterior correct-label probability at most `2/3` on at least `139/1024` of the cube**.

This holds at the actual Gaussian scales `σ²=N^(−γ)` for every fixed `γ≥1`, at every sufficiently large width `N≥exp(Cγ d)`. The critical case `γ=1` has a separate finite-width proof. The constants can depend on the chosen activation and, above one, on `γ`; uniformity for exponents approaching one is not claimed. A fixed-width strong-prior-limit version is also proved at every width above a polynomial memorizer threshold.

The Gaussian variances are `t²/d` in the first layer, `t²/N` internally, and `t²/N²` in the readout, with `σ²=t²/N`. The learner first conditions on absolute output greater than `1/2` at every cube input, then on exact noiseless training labels. The lower bound concerns the posterior confidence criterion, including arbitrary mixtures of predictors.

## Why the example works

Tiny analytic bumps far into the activation's tails store truth tables chosen to be far from every small Boolean circuit. A constant-width finite-difference construction cancels the ordinary tanh background and reads the relevant table entry. A linear number of amplification layers makes its output margin constant. The perturbation can be made small enough to preserve monotonicity, concavity, the exact slope at zero, and any prescribed finite number of derivative bounds.

The Bayesian lower bound uses a different fact: after few observations, the posterior places almost all its mass on functions with small Boolean circuits. Above the critical scaling this follows by subtracting a typical Gaussian perturbation to obtain a low-product representative. At the critical scaling the proof extracts entropy-controlled paths directly at finite width and converts near-baseline paths into small circuits. Neither argument imports a tanh-specific parameter-counting bound for the engineered activation.

This shows that regularity and closeness to tanh alone do not give a universal polynomial-depth theorem over activation functions. The question for the original exact-tanh prior remains open; see [Boolean depth barriers and circuit complexity](../boolean-depth-barriers/README.md).

## Status and reproduction

This is a **conventional mathematical proof with independent AI-agent reviews**, not a Lean formalization or human peer-reviewed result. The [verification record](verification/README.md) separates mathematical review from the isolated PDF build. It remains a work in progress and does not change either batch of formalized main results.

Run `bash build.sh` from this folder, or invoke the script by its path. It requires `latexmk` and a LaTeX installation with the packages declared in the source. The two files in `source/` contain the complete manuscript; no private scratch files are needed. Build output stays in the ignored `.build/` directory.

Authors: ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob.
