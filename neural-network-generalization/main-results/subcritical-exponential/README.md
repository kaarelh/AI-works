# Exponential parity sample complexity below the mean-field scaling

**Status:** Main result

Parity has a Boolean circuit with O(d) gates and a polynomial-size, polynomial-weight tanh network, yet the Bayesian learner studied here requires exp(Omega(d)) examples. The result holds for every fixed prior-scaling exponent gamma < 1 and fixed depth, under uniform IID training and the width-first posterior. For each n <= exp(c d), with sample probability at least 3/4, confidence failure is at least 1/16 in the infinite-width limit (a liminf as N tends to infinity, at fixed dimension and sample). Here failure means that the correct label has posterior probability at most 2/3.

The paper defines the prior and conditioning conventions independently. The result concerns full parity; the fixed-depth natural sparse-parity scale exp(Omega(k log(ed/k))) remains open.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/subcritical-exponential.tex) · [Collection index](../../README.md)

## Formal main theorem

The main learning statement is proved by [`MainProofs.subcriticalExponential`](../../lean/NeuralGeneralization/SubcriticalMain.lean). See the [Lean verification record](../../lean/VERIFICATION.md) for reproduction and the precise scope; this does not claim that every auxiliary assertion in the PDF is formalized.

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The abstract and introduction were revised for a standalone presentation; the mathematical statements and proofs are unchanged. Later results and current scope are summarized in the collection index.
