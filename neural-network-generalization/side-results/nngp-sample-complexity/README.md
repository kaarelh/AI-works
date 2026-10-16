# Small circuits under Gaussian-process classification: what sample complexity follows from the actual posterior?

**Status:** Proved side result

Separates regression correlation, posterior classification, and confidence. Gives a deep, variance-normalized tanh NNGP family requiring Theta(2^d log(1/epsilon)) samples for >2/3 confidence; the depth grows with dimension. Includes a small-eigenvalue counterexample and exact globally margin-conditioned posterior formulas.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/nngp-sample-complexity.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF is the existing manuscript copied into this collection; its mathematical text has not been rewritten for publication here. Later results and current scope are summarized in the collection index.
