# Natural sparse-parity lower bounds at slowly growing depth

**Status:** Proved side result

For parity on k coordinates in input dimension d, this paper obtains a lower bound at the natural scale exp(Omega(k log(ed/k))) when k is polynomially sparse and depth grows as L = log_2 log log d + O(1). The guarantee concerns the actual width-first posterior and the requirement that correct-label probability exceed 2/3.

Failure is proved at specified sample sizes. The result does not assert failure at every smaller sample size or resolve natural-scale hardness at fixed depth.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/growing-depth-parity.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

## Review record

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
