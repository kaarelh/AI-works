# Symmetric parity predictors require large amplitudes: an exponential lower bound and a consequence for margin repairs

**Status:** Proved side result

Proves L1 amplitude growth exp(c sqrt k), exponential in sqrt k, for symmetric margin-one parity approximants of sufficiently small linear degree, and diverging repair costs in the stated cusp model. Symmetric or block-symmetric sign assumptions are explicit; no general posterior reduction is proved.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/symmetric-parity-amplitudes.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
