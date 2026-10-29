# Exponential sample lower bounds for Bayesian Gaussian process classification

**Status:** Earlier complete result; included and strengthened by later subcritical and sparse-parity papers

For gamma < 0, full parity has a fixed positive confidence-failure fraction for each n <= exp(c d), with sample probability at least 3/4. Contains the standalone Gaussian classification proof; excludes gamma = 0 and 0 < gamma < 1.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/gaussian-exponential-lower-bound.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
