# Small circuits under Gaussian-process classification: what sample complexity follows from the actual posterior?

**Status:** Proved side result

Separates regression correlation, posterior classification, and confidence. Gives a deep, variance-normalized tanh NNGP family requiring Theta(2^d log(1/epsilon)) samples for >2/3 confidence; the depth grows with dimension. Includes a small-eigenvalue counterexample and exact globally margin-conditioned posterior formulas.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/nngp-sample-complexity.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
