# An audit of Gaussian-prior scaling arguments for Bayesian neural-network learning

**Status:** Companion proof audit

This report audits the supplied finite-exponent manuscript and its cited mean-field argument. It identifies avoidable width restrictions and proof gaps addressed by the replacement proofs.

Its descriptions of unresolved targets record the state of the work when the audit was written; they are not a current list of open problems.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/proof-audit.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

## Review record

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
