# Small circuits under Gaussian-process classification: what sample complexity follows from the actual posterior?

**Status:** Proved side result

This paper constructs a deep, variance-normalized tanh neural-network Gaussian process (NNGP) family requiring Theta(2^d log(1/epsilon)) samples for correct-label confidence above 2/3. Here d is the input dimension, epsilon is the error tolerance, and depth grows with dimension.

The argument distinguishes regression correlation, posterior classification, and posterior confidence. The paper includes a small-eigenvalue counterexample and exact formulas for the globally margin-conditioned posterior.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/nngp-sample-complexity.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

## Review record

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
