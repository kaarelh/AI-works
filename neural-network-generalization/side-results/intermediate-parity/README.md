# Growing sparse parity under a globally separated neural prior

**Status:** Proved side result

Current fixed-depth improvement for 0 < gamma < 1 and growing k <= d^(1-eta): failure at specified sample sizes with log n of order max{k^theta t,k t^(2-1/theta)}, t=log(ed/k). At depth 2, theta=0.719367150047. This lower-bounds an eventual sample threshold and does not assert failure at every smaller n. The full natural exponent remains open.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/intermediate-parity.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
