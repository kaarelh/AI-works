# Width-uniform Bayesian generalization above the mean-field scaling

**Status:** Main result

**Authors:** Dmitry Vaintrob, Kaarel Hänni, OpenAI Codex, and Claude.

If a Boolean target has a small bounded-weight neural-network implementation, the Bayesian learner needs polynomially many examples even when its own width is arbitrarily larger. For every fixed gamma > 1 and fixed depth, the bound holds at every width N >= C_L(f), at the specified nonzero Gaussian variance. The model uses hidden activations with values in [-1,1] and Lipschitz constant 1, a linear readout, and global margin conditioning. The polynomial, including its degree, may depend on depth and on gamma, with no uniform claim as gamma decreases to one; this is not a polynomial-depth bound.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/gamma-above-one.tex) · [Collection index](../../README.md)

## Formal main theorem

The main learning statement is proved by [`MainProofs.aboveMeanField`](../../lean/NeuralGeneralization/AboveMeanFieldMain.lean). See the [Lean verification record](../../lean/VERIFICATION.md) for reproduction and the precise scope; this does not claim that every auxiliary assertion in the PDF is formalized.

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The introduction and abstract present the model and result independently of the companion papers. The [collection index](../../README.md) compares their scope.
