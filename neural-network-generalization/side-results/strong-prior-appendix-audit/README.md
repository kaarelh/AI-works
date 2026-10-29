# A proof audit of strong-prior Bayesian neural-network generalization

**Status:** Companion proof audit

Checks source-slide Appendices A-L, records repaired claims and major mistakes, and explains what was retained in the strong-prior paper. It is an audit report, not an additional generalization theorem.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/appendix-audit.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
