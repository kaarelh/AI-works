# Sparse parity under globally conditioned neural priors

**Status:** Proved side result

For gamma < 0, proves the natural exp(Omega(k log(ed/k))) sparse-parity lower bound at every specified sample size below the bound. For 0 < gamma < 1, a one-coordinate parity instead learns with O(log d) samples. Growing sparse parity at gamma = 0 and the positive-regime natural scale remain outside this result.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/sparse-parity.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF is the existing manuscript copied into this collection; its mathematical text has not been rewritten for publication here. Later results and current scope are summarized in the collection index.
