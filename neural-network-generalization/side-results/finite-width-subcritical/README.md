# Finite-width circuit learning below mean-field scaling

**Status:** Proved side result

For fixed depth and gamma < 1, gives sufficient sample size poly(d,C) N log(eN) at width N >= C. Polynomial widths therefore admit polynomial sample learning. This is a finite-width/joint-limit upper bound and does not contradict width-first lower bounds.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/finite-width-subcritical.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
