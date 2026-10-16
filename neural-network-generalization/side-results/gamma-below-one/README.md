# The fixed-kernel regime of a margin-conditioned Bayesian neural-network prior

**Status:** Proved side result

Derives kernel freezing and the three width-first limits: minimum kernel-margin energy for 0 < gamma < 1, a globally truncated Gaussian at gamma = 0, and Gaussian sign conditioning at gamma < 0. Its sample-bound discussion predates the stronger main exponential paper.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/gamma-below-one.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF is the existing manuscript copied into this collection; its mathematical text has not been rewritten for publication here. Later results and current scope are summarized in the collection index.
