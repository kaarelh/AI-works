# Polynomial depth from stability of clipped neural-network predictions

**Status:** Main result; public research draft

A support restriction on finite internal perturbations gives one polynomial sample bound jointly in input dimension, Boolean circuit size/depth, and statistical parameters, uniformly over every learner width above circuit width and every gamma >= 1. No global clean-output margin is assumed; the training likelihood and lower-margin test criterion are explicit.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/robustness-paper.tex) · [Collection index](../../README.md)

## Formal verification status

The [exact qualitative main learning theorem](../../lean/NeuralGeneralization/RobustStatements.lean) has a [closed Lean proof](../../lean/NeuralGeneralization/RobustMain.lean), using only `propext`, `Classical.choice`, and `Quot.sound`. It has no unproved compression or analytic premise. The [verification record](../../lean/VERIFICATION.md) documents the independent project-source rebuild and exact-type checks.

The formal proof uses a looser Pinsker-and-energy construction and verifies a sufficient universal polynomial bound. This does not certify the manuscript's sharper constants, optional extra all-input-margin learning variant, other extensions, or every appendix. Its comparator is the stated layered Boolean circuit, not every small analog neural circuit.

The empirical findings are separate from the learning theorem: trained-network accuracy does not validate a Bayesian posterior guarantee. Exact integer/interval certificates are computational proofs with their own documented trusted components, not Lean proofs.

[Empirical source and reproduction scope](../../works-in-progress/depth-experiments/README.md) · [Technical FAQ](../../TECHNICAL-FAQ.md)

## Build

Run `bash build.sh` from this directory with a standard TeX Live installation. It runs three LaTeX passes in `build/` and refreshes `paper.pdf`. All LaTeX inputs and figures are included under `source/`; no network access is needed.

`verification/source-provenance.json` retains the original source hashes and records the editorial verification-status update. The publication build check compares the revised PDF text with an independent rebuild of the published source.
