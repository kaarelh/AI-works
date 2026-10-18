# Mean-field Bayesian circuit learning at every width above target complexity

**Status:** Main result

At mean-field Gaussian scaling (gamma = 1), a Bayesian tanh network can learn a small target with a sample bound independent of its own potentially much larger width. The bound holds at every width N >= C_L(f), for the exact globally margin-conditioned posterior. Success requires correct-label probability strictly above 2/3; training and test inputs may follow any common distribution. Depth is fixed: the polynomial degree and constants may depend on it.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/meanfield-all-width.tex) · [Collection index](../../README.md)

## Formal main theorem

The main learning statement is proved by [`MainProofs.meanField`](../../lean/NeuralGeneralization/MeanFieldMain.lean). See the [Lean verification record](../../lean/VERIFICATION.md) for reproduction and the precise scope; this does not claim that every auxiliary assertion in the PDF is formalized.

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The paper includes its own motivation, model, theorem, and proof; no companion paper is needed to follow the argument. The [collection index](../../README.md) compares the results.
