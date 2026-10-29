# Failure of Bayesian Gaussian process classification at exponentially large sample sizes

**Status:** Earlier complete result; strengthened by gaussian-exponential-lower-bound and subcritical-exponential

For gamma < 0, proves actual-posterior confidence failure at a specified exponentially large sample schedule. Does not claim failure at every smaller sample size; later papers fill that gap and handle further regimes.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/gaussian-exponential-schedule.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
