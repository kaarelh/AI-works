# Growing sparse parity under a globally separated neural prior

**Status:** Proved side result

For prior-scaling exponent 0 < gamma < 1, this paper improves the fixed-depth lower bound for parity on a growing set of k <= d^(1-eta) coordinates, where d is the input dimension and eta > 0 is fixed. Failure is proved at specified sample sizes with log n of order max{k^theta t,k t^(2-1/theta)}, where t = log(ed/k) and theta is the paper's depth-dependent exponent. At depth 2, theta = 0.719367150047.

The result lower-bounds an eventual sample threshold. It does not assert failure at every smaller n, and the full natural exponent remains open.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/intermediate-parity.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

## Review record

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
