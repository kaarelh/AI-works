# A logarithmic separation between local smoothing and rare neural features

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. Selected deterministic components are Lean checked; the complete main theorems are not formalized.

## Result and scope

Joint width/activation-temperature count exponents at square root of width divided by log width; singular highest-finite-moment responses; positive Fourier moment ordering and centered random-feature and initialization tangent-kernel ordering, including a strict shift of normalized variance toward higher Fourier degrees; and signed second- and third-order boundary formulas for the critical normalizer.

Fixed dimension and full-cube conditioning for the count theorem. Critical moment statements concern individual neurons. The six-dimensional covariance response is rank 38; even dimensions at least eight have a regular second-order covariance response. No full-posterior fluctuation or sampler theorem is claimed in the joint regime.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

The [21 November research payload](../../rounds/2026-11-21/README.md) contains supporting programs, exact finite checks, and numerical diagnostics. The [verification inventory](../../verification/README.md) distinguishes those checks from complete formalization and independent proof review.

## Related papers

- [Smoothing changes the fluctuations of Bayesian neural condensates](../softplus-sector-asymptotics/README.md)
- [Polynomial probabilities of extra exceptional neurons](../quantitative-condensate-count/README.md)
- [Exponential online mistakes from widening Gaussian softplus and tanh learners](../softplus-gaussian-width-separation/README.md)
