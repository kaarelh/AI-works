# Bayesian circuit learning at mean-field scaling: a variational principle and width-independent generalization

**Status:** Earlier complete result; learning guarantee superseded by meanfield-all-width

At mean-field scaling (gamma = 1), this paper proves a learning theorem above an unquantified sufficiently-large-width threshold, using a variational and stationarity argument.

The main meanfield-all-width paper subsequently removed that width threshold. Statements here that the all-width theorem is open describe the earlier state of the problem; the variational proof route remains part of this paper.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/gamma-ge1-endpoint.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

## Review record

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
