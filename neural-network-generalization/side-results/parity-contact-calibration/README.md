# Parity, polynomial degree, and contact-weighted error costs

**Status:** Proved side result

This paper proves a quantitative degree obstruction for parity under an explicit contact-weighted amplitude-cost hypothesis. Its exponent is 0.719367 at cost parameter beta = 1/2. The paper develops stability, transport, and analytic refinements of the bound.

To apply the obstruction to a learner, one must separately establish the contact-cost hypothesis for that learner.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/parity-contact-calibration.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

## Review record

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
