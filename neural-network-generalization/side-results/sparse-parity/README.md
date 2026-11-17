# Sparse parity under globally conditioned neural priors

**Status:** Proved side result

For prior-scaling exponent gamma < 0, this paper proves a sparse-parity lower bound at the natural scale exp(Omega(k log(ed/k))), where k is the number of parity coordinates and d is the input dimension. For d >= d_0 and each specified sample size below that scale, with probability at least 3/4 over uniform IID samples, a universal fraction epsilon of about 7.85e-6 of inputs has correct-label posterior probability at most 2/3 in the width-first limit. The guaranteed fraction is positive but small; no larger failure fraction is asserted here.

For 0 < gamma < 1, the paper instead shows that one-coordinate parity learns with O(log d) samples. Growing sparse parity at gamma = 0 and the natural lower-bound scale in the positive regime remain outside this result.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/sparse-parity.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

## Review record

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
