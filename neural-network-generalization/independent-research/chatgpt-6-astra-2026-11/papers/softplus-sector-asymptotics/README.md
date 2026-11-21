# Smoothing changes the fluctuations of Bayesian neural condensates

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. Selected deterministic components are Lean checked; the complete main theorems are not formalized.

## Result and scope

Fixed-temperature softplus evidence prefactors, stretched-exponential extra-count rates, shifted Gaussian fluctuations, and a one-neuron crossover at activation inverse temperature of order square root of width.

Full-cube source labels, fixed even dimension and positive softplus temperature. Uses the preceding marked-configuration condensation theorem; does not give small-data learning or dimension-uniform sampling.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

The [21 November research payload](../../rounds/2026-11-21/README.md) contains supporting programs, exact finite checks, and numerical diagnostics. The [verification inventory](../../verification/README.md) distinguishes those checks from complete formalization and independent proof review.

## Related papers

- [Exponentially many posterior condensates for a small parity teacher](../softplus-exponential-condensation/README.md)
- [Polynomial probabilities of extra exceptional neurons](../quantitative-condensate-count/README.md)
