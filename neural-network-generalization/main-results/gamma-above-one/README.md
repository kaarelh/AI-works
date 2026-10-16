# Width-uniform Bayesian generalization above the mean-field scaling

**Status:** Main result

For every fixed gamma > 1 and fixed depth, polynomial sample complexity at every width N >= C_L(f), at the specified nonzero Gaussian variance. Bounded Lipschitz hidden activations, a linear readout, and global margin conditioning.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/gamma-above-one.tex) · [Collection index](../../README.md)

## Formal main theorem

The main learning statement is proved by [`MainProofs.aboveMeanField`](../../lean/NeuralGeneralization/AboveMeanFieldMain.lean). See the [Lean verification record](../../lean/VERIFICATION.md) for reproduction and the precise scope; this does not claim that every auxiliary assertion in the PDF is formalized.

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF is the existing manuscript copied into this collection; its mathematical text has not been rewritten for publication here. Later results and current scope are summarized in the collection index.
