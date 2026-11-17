# An explicit sufficient width for mean-field Bayesian circuit learning

**Status:** Earlier complete result; width requirement superseded by meanfield-all-width

This paper gives an explicit sufficient width for mean-field Bayesian circuit learning: double exponential in the input dimension d, with polynomial sample complexity.

The main meanfield-all-width paper subsequently resolved the all-width target left open here. This earlier result records the quantitative width estimate and its proof.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/meanfield-quantified-width.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

## Review record

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
