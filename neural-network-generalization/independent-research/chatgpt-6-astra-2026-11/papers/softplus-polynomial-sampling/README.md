# Arbitrary polynomial accuracy for softplus posterior sampling

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. Selected deterministic components are Lean checked; the complete main theorems are not formalized.

## Result and scope

A truncated slightly supercritical proposal and pilot-independent leading error observable give a sharp quarter-power improvement per fixed Metropolis correction, including after pilot averaging.

Square or logistic full-cube likelihood, fixed dimension and activation temperature. A positive amplitude enclosure is supplied, or obtained explicitly when the target margin exceeds 3/8. Linear expected width cost is in idealized exact real arithmetic.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

The [21 November research payload](../../rounds/2026-11-21/README.md) contains supporting programs, exact finite checks, and numerical diagnostics. The [verification inventory](../../verification/README.md) distinguishes those checks from complete formalization and independent proof review.

## Related papers

- [Smoothing changes the fluctuations of Bayesian neural condensates](../softplus-sector-asymptotics/README.md)
- [Finite Metropolis corrections for a condensed ReLU posterior](../metropolis-corrected-posterior/README.md)
