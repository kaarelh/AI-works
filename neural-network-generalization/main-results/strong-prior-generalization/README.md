# Width-independent generalization in the strong-prior limit of Bayesian neural networks

**Status:** Main result

Writeup of the strong-prior slides. At fixed depth, polynomial sample complexity uniformly over learner widths N >= C_L(f), with the Gaussian variance tending to zero separately at each fixed width; no width-uniform variance threshold is claimed.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection index](../../README.md)

## Formal main theorem

The main learning statement is proved by [`MainProofs.strongPrior`](../../lean/NeuralGeneralization/StrongPriorMain.lean). See the [Lean verification record](../../lean/VERIFICATION.md) for reproduction and the precise scope; this does not claim that every auxiliary assertion in the PDF is formalized.

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF is the existing manuscript copied into this collection; its mathematical text has not been rewritten for publication here. Later results and current scope are summarized in the collection index.
