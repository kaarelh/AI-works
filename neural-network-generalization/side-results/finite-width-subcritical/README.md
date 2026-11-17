# Finite-width circuit learning below mean-field scaling

**Status:** Proved side result

At fixed depth and prior-scaling exponent gamma < 1, a Bayesian network of width N >= C has sufficient sample size poly(d,C) N log(eN). Here d is the input dimension and C is the target's bounded-weight network complexity. Polynomial learner widths therefore permit polynomial sample complexity.

The bound allows width and dimension to grow together. It does not contradict lower bounds that first send width to infinity at each fixed dimension.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/finite-width-subcritical.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

## Review record

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
