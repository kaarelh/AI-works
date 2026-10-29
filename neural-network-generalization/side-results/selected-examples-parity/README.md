# Learning parity from selected examples under a globally separated neural kernel

**Status:** Proved side result

For sufficiently large odd k and d >= (C_L k)^(C_L k), deliberately selected d^(O_delta(sqrt(k))) examples force every minimum-energy compatible field to share a sign function of error <= delta. Includes the finite Gaussian small-variance confidence corollary. Selected training is not IID uniform and does not refute the intended random-sample lower bound.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/selected-examples-parity.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
