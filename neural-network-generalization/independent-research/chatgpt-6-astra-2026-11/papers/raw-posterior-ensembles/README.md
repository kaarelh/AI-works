# Raw-feature transfer from ensembles of pretrained networks

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. Selected deterministic components are Lean checked; the complete main theorems are not formalized.

## Result and scope

Simultaneous nearby-parity transfer from independent raw posterior banks; an antithetic reflected pair gives a separate one-trained-bank construction with no comparator-norm increase.

Paired source data and cold finite-width energy hypotheses. Independent banks and deliberately coupled reflected banks are distinct protocols. Exact posterior pretraining is assumed; the deterministic implication also applies to optimization attaining the stated bounds.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

The [21 November research payload](../../rounds/2026-11-21/README.md) contains supporting programs, exact finite checks, and numerical diagnostics. The [verification inventory](../../verification/README.md) distinguishes those checks from complete formalization and independent proof review.

## Related papers

- [Finite-data raw-feature transfer by removing a low-rank component](../raw-finite-data-transfer/README.md)
- [Polynomial-data feature transfer for cold Gaussian ReLU Bayes](../near-minimum-energy-transfer/README.md)
