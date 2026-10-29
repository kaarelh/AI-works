# Exponential depth dependence at a supercritical mean-field prefactor

[Paper PDF](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

**A natural mean-field Gaussian prior can require exponentially many examples in depth, even for a constant target.** The result uses tanh, exact training-label conditioning, and the usual global absolute output margin. Its hidden-weight variance is `t²/N` for any fixed `t>1`; the first-layer and readout variances are `t²/d` and `t²/N²`.

These are the same width powers as the original mean-field prior, with a different fixed variance prefactor. The original coefficient-one case `t=1`, and the stronger canonical priors `0<t<1`, remain open with respect to unrestricted Boolean depth. This paper is a work in progress with conventional proofs and independent AI-agent checks; it is **not Lean formalized**.

## Main result

For each fixed `t>1`, there are constants `p>4`, `K,c>0` such that, at sufficiently large input dimension `d`, take

- `H = ceil(K(d+1))` hidden layers;
- hidden width `N = ceil(2^(pd))`;
- input domain the full Boolean cube, with the uniform test distribution.

The raw probabilities of **all** Boolean truth tables realized with signed margin greater than `1/2` differ by a ratio of at most `1+exp(-cd)`. After conditioning on the absolute margin and any consistent training sample, every unseen input therefore has correct-label posterior probability within `O(exp(-cd))` of one half.

Consequently, more than `2^(d-1) = exp(Ω_t(H))` examples are required to reduce the fraction of inputs failing the `>2/3` confidence criterion below one half. This holds for every target and every realized sample. The constant target already suffices; it has a width-two implementation at every depth with all coefficients bounded by one and output margin greater than one.

## What this establishes

The proof controls the actual finite-width posterior, including all its mixtures. A Gaussian-process limit or a comparison of leading large-deviation rates would not be sufficient. The argument instead combines:

1. uniform empirical covariance contraction, allowing rare unfavorable layers;
2. an exceptional-event probability smaller than every full-margin truth-table probability;
3. an exact Gaussian readout comparison that turns covariance closeness into a ratio of function probabilities.

Fixed-depth polynomial learning remains compatible with this lower bound. The width-independent polynomial guarantee extends to every fixed prefactor `t>0`; its coefficients and degree may depend on depth. For `t>1`, that dependence cannot be polynomial jointly in dimension, teacher width, and depth.

The prefactor cannot be removed merely by changing the teacher-complexity convention or output margin. Writing weights as `W=tU` changes the hidden activation to `tanh(tu)`, whose derivative at zero is `t`. The positive-variance white equilibrium used in the proof exists for `t>1` and is absent at `t≤1`.

## Limits of the theorem

- It gives a lower bound for the specified confidence criterion and for Gibbs prediction. It does **not** prove a lower bound for exact deterministic posterior-majority prediction: an exponentially small bias could still have the correct sign.
- It holds at the stated finite depth–width sequence. It does not assert the conclusion at every larger width.
- It does not settle unrestricted depth for the exact coefficient-one tanh prior. Expressing the new prior as `N^(-γ_N)` gives `γ_N=1-2 log(t)/log(N)<1`, approaching one from below; it is not a fixed subcritical exponent.
- No algorithmic assumption is used, and no statement about efficient posterior computation is proved.

## Supporting research notes

- [Training only on output signs, without a global margin](research-notes/sign-only-conditioning.md): a simpler exponential-depth confidence lower bound, valid at every width above an exponential threshold and for any positive isotropic Gaussian readout scale. It does not cover a fixed nonzero margin at training inputs. [Independent audit](verification/sign-only-audit.md).
- [Approaching the critical prefactor](research-notes/nearcritical-prefactor.md): a quantified extension for `t=1+ε`, with deliberately loose depth overhead `ε^(-50)`, and an explanation of why the covariance argument does not reach exact `t=1`. It also gives the exact corollary for the canonical Gaussian prior with activation `tanh(au)`, `a>1`. [Independent audit](verification/nearcritical-audit.md).
- [Majority prediction and finite posterior ensembles](research-notes/majority-prediction.md): why nearly uniform function probabilities do not settle exact majority prediction, and a lower bound for majority voting over independent posterior samples. [Independent audit](verification/majority-audit.md).

These supporting notes are conventionally checked research results, not additional Lean-verified main results.

## Build

Run `./build.sh` with TeX Live and the packages listed in the source. It creates the PDF and places temporary files in the ignored `build/` directory. The source is self-contained. An isolated rebuild and its source/PDF hashes are recorded in [publication-build.json](verification/publication-build.json).

Authors: ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob.

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
