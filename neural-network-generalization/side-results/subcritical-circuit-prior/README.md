# Small circuits can have exponentially large prior complexity below the mean-field scaling

**Status:** Proved side result

Full parity has a small neural implementation but exponentially large normalized prior complexity for every fixed gamma < 1. These are prior-mass separations; tiny prior mass alone does not prove a sample lower bound.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/subcritical-circuit-prior.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
