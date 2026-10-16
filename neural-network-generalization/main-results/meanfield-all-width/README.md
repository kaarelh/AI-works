# Mean-field Bayesian circuit learning at every width above target complexity

**Status:** Main result

For gamma = 1, fixed-depth tanh networks have a polynomial sample bound at every width N >= C_L(f), for the exact globally margin-conditioned Bayesian posterior. Success requires correct-label probability strictly above 2/3; the theorem allows an arbitrary input distribution.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/meanfield-all-width.tex) · [Collection index](../../README.md)

## Formal main theorem

The main learning statement is proved by [`MainProofs.meanField`](../../lean/NeuralGeneralization/MeanFieldMain.lean). See the [Lean verification record](../../lean/VERIFICATION.md) for reproduction and the precise scope; this does not claim that every auxiliary assertion in the PDF is formalized.

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF is the existing manuscript copied into this collection; its mathematical text has not been rewritten for publication here. Later results and current scope are summarized in the collection index.
