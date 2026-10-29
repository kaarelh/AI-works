# Natural sparse-parity lower bounds at slowly growing depth

**Status:** Proved side result

Obtains exp(Omega(k log(ed/k))) at specified sample sizes for polynomially sparse k when depth L=log_2 log log d+O(1). Actual width-first posterior and >2/3 confidence. Does not resolve fixed-depth natural-scale hardness or assert failure at every smaller sample size.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/growing-depth-parity.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
