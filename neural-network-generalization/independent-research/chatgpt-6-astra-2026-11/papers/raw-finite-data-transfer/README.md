# Finite-data raw-feature transfer by removing a low-rank component

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. Selected deterministic components are Lean checked; the complete main theorems are not formalized.

## Result and scope

Finite-width deterministic average-task bound and finite polynomial-data raw transfer for each fixed nearby task under a permutation-invariant posterior, with an explicit confidence--dimension condition. No simultaneous-all-task guarantee.

Original raw features and a fixed nearby task, averaged over IID pretraining and an actual permutation-invariant posterior; the confidence--dimension condition is material. The deterministic guarantee averages tasks and is not simultaneous on every task.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

See the [verification inventory](../../verification/README.md) for exact arithmetic, selected Lean lemmas, numerical diagnostics, and their limitations.

## Related papers

- [Polynomial-data feature transfer for cold Gaussian ReLU Bayes](../near-minimum-energy-transfer/README.md)
- [Polynomial-data parity transfer under Gaussian and lighter tails](../power-prior-transfer/README.md)
- [Transfer to nearby parity targets after Bayesian feature learning](../relu-parity-feature-transfer/README.md)
