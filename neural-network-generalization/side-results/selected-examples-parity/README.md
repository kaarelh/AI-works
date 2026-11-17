# Learning parity from selected examples under a globally separated neural kernel

**Status:** Proved side result

Deliberately selected examples can force a globally separated neural kernel to learn sparse parity. For sufficiently large odd k and input dimension d >= (C_L k)^(C_L k), a set of d^(O_delta(sqrt(k))) examples forces every minimum-energy compatible field to have the same sign function, with error at most delta. Here k is the number of parity coordinates, delta is the error tolerance, and C_L is a depth-dependent constant. The paper includes the finite Gaussian small-variance confidence corollary.

The examples are selected rather than IID uniform. This result therefore does not refute the intended random-sample lower bound.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/selected-examples-parity.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

## Review record

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
