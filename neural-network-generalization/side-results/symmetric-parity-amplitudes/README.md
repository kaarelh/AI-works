# Symmetric parity predictors require large amplitudes: an exponential lower bound and a consequence for margin repairs

**Status:** Proved side result

A symmetric margin-one parity approximant of sufficiently small linear degree must have L1 amplitude at least exp(c sqrt k), where k is the number of parity coordinates. Thus its required amplitude grows exponentially in sqrt k. The paper derives diverging repair costs in the stated cusp model.

The conclusions require the stated symmetric or block-symmetric sign assumptions. No reduction of a general posterior to this structured model is proved.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/symmetric-parity-amplitudes.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

## Review record

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
