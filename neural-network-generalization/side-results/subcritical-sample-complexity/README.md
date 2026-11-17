# Superpolynomial sample lower bounds for globally margin-conditioned Bayesian neural networks below the mean-field scaling

**Status:** Earlier complete result; sample scale strengthened by subcritical-exponential

For full parity on k coordinates and every prior-scaling exponent gamma < 1, this paper proves a sample lower bound of exp(Omega(sqrt(k) log k)) for every training set of the indicated size.

The main subcritical-exponential paper strengthens the scale to exp(Omega(k)) for IID training. The earlier theorem retains a distinct guarantee for every training set.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/subcritical-sample-complexity.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

## Review record

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
