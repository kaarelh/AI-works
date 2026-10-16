# Growing sparse parity under a globally separated neural prior

**Status:** Proved side result

Current fixed-depth improvement for 0 < gamma < 1 and growing k <= d^(1-eta): failure at specified sample sizes with log n of order max{k^theta H,k H^(2-1/theta)}, H=log(ed/k). At depth 2, theta=0.719367150047. This lower-bounds an eventual sample threshold and does not assert failure at every smaller n. The full natural exponent remains open.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/intermediate-parity.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF is the existing manuscript copied into this collection; its mathematical text has not been rewritten for publication here. Later results and current scope are summarized in the collection index.
