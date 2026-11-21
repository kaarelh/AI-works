# Exponential online mistakes from widening Gaussian softplus and tanh learners

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. Selected deterministic components are Lean checked; the complete main theorems are not formalized.

## Result and scope

A standard-softplus or tanh shallow learner makes 2^(d-1) confident observed-margin-only mistakes at prior variance of order d^-3 and sufficient finite width exp(O(d log(d+1))), at fixed confidence. The parity target has a rational width-(d+1) teacher with polynomial coefficients; that narrow learner has an O(d^8) lifetime mistake bound under the same Gaussian scale. Narrow and wide priors have exactly the same output covariance kernel at this scale.

Odd dimension at least three for softplus; even dimension at least two for tanh; central-limit normalization; deterministic Gaussian-mean-selected input order with one initial label. The inverse-parity spectrum dominates by an explicit positive-integral moment bound. This is a finite-parameter, exponential-width result, not a polynomial-width ReLU or fixed-width strong-prior theorem. Conventional proof with selected finite precision inequalities in Lean, not full formalization or independent review. At that prior scale, widths at least d+1 need N = Omega(2^d/d^3) for softplus or Omega(2^d/d^4) for tanh for an exponential majority mistake count. Requiring all 2^(d-1) designated fresh posterior draws to be wrong simultaneously with fixed high probability strengthens these necessary widths to Omega(2^d/d^2) and Omega(2^d/d^3), respectively, by an arithmetic-geometric-mean bound on history probability.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

The [21 November research payload](../../rounds/2026-11-21/README.md) contains supporting programs, exact finite checks, and numerical diagnostics. The [verification inventory](../../verification/README.md) distinguishes those checks from complete formalization and independent proof review.

## Related papers

- [Maximal confident mistakes for a Gaussian cosine-network limit](../gaussian-cosine-mistake-path/README.md)
- [A logarithmic separation between local smoothing and rare neural features](../logarithmic-smoothing-threshold/README.md)
- [Superpolynomial strong-prior ReLU mistakes with margins only on observed inputs](../observed-margin-control-lower-bound/README.md)
- [Maximal lexicographic parity mistakes for degree-ordered kernels](../lexicographic-degree-kernel-mistakes/README.md)
