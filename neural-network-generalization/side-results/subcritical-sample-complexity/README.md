# Superpolynomial sample lower bounds for globally margin-conditioned Bayesian neural networks below the mean-field scaling

**Status:** Earlier complete result; sample scale strengthened by subcritical-exponential

Proves exp(Omega(sqrt(k) log k)) hardness for full parity throughout gamma < 1, for every training set of the indicated size. The stronger exp(Omega(k)) IID theorem is now the main subcritical-exponential paper; the deterministic-training scope is distinct.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/subcritical-sample-complexity.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF is the existing manuscript copied into this collection; its mathematical text has not been rewritten for publication here. Later results and current scope are summarized in the collection index.
