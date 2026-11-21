# Maximal lexicographic parity mistakes for degree-ordered kernels

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. Selected deterministic components are Lean checked; the complete main theorems are not formalized.

## Result and scope

Every positive radial Boolean-cube kernel with nonincreasing degree eigenvalues and a strict final drop makes 2^d-1 lexicographic parity mistakes under exact minimum-norm interpolation. Covers Gaussian ReLU and softplus random-feature kernels in odd dimension and tanh in even dimension, and sufficiently wide finite random-feature readout fitting. Also covers nonnegative layer-weighted ReLU/softplus initialization tangent kernels in odd dimension at least three, including both-layer and incoming-gradient-only training. A positive-power-series criterion also covers the explicitly normalized fixed ReLU NNGP and NTK recursions at every depth at least two and every dimension at least two.

Exact output observations, fixed hidden features, and minimum-norm readout fitting or fixed-kernel gradient flow run to interpolation. A compact teacher exists in the same activation class. For each fixed activation temperature, width exp(C d) log(2/zeta) suffices with probability at least 1-zeta; full-cube Gram rank also requires exponentially many scalar features. Positive-margin conditioning and hidden-feature learning are not proved by this recursion. Conventional proof, exact finite matrix checks, no full Lean formalization or independent review. The finite-Jacobian extension uses frozen Gaussian Jacobian features and a zero-output linearized model; evolving nonlinear training and uncentered initial outputs are excluded. The deep-kernel corollary fixes the input-bias normalization and does not assert a finite-deep-network width bound or nonlinear training result. The margin-activity conjecture is proved for dyadic and two-block prefix families in every dimension; the general prefix case remains open. An exact seven-dimensional Hamming-ball counterexample rules out the broader coordinatewise-downset activity conjecture.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

The [21 November research payload](../../rounds/2026-11-21/README.md) contains supporting programs, exact finite checks, and numerical diagnostics. The [verification inventory](../../verification/README.md) distinguishes those checks from complete formalization and independent proof review.

## Related papers

- [Exponential online mistakes from widening Gaussian softplus and tanh learners](../softplus-gaussian-width-separation/README.md)
- [A logarithmic separation between local smoothing and rare neural features](../logarithmic-smoothing-threshold/README.md)
- [Maximal confident mistakes for a Gaussian cosine-network limit](../gaussian-cosine-mistake-path/README.md)
