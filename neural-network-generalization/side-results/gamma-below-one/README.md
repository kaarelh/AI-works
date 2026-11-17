# The fixed-kernel regime of a margin-conditioned Bayesian neural-network prior

**Status:** Proved side result

This paper derives the fixed-kernel description of the prior when width tends to infinity first. The prior-scaling exponent gamma determines which of three limits appears:

- For 0 < gamma < 1, minimum kernel-margin energy.
- At gamma = 0, a globally truncated Gaussian.
- For gamma < 0, Gaussian sign conditioning.

Its sample-bound discussion predates the stronger main exponential paper.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/gamma-below-one.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

## Review record

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
