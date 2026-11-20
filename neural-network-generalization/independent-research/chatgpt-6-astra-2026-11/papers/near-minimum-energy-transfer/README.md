# Polynomial-data feature transfer for cold Gaussian ReLU Bayes

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. Selected deterministic components are Lean checked; the complete main theorems are not formalized.

## Result and scope

Finite-width actual cold posterior with polynomial IID pretraining and downstream data; exact near-optimal-energy obstruction for unmodified raw features. Selected deterministic Lean proofs; full probabilistic theorem not formalized or independently reviewed.

Finite polynomial width and IID pretraining, an accuracy-dependent cold Gaussian prior, and frozen even features or raw features with a linear input skip. Exact posterior sampling is assumed.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

See the [verification inventory](../../verification/README.md) for exact arithmetic, selected Lean lemmas, numerical diagnostics, and their limitations.

## Related papers

- [Transfer to nearby parity targets after Bayesian feature learning](../relu-parity-feature-transfer/README.md)
- [Locality of parity transfer in a learned neural representation](../transfer-locality/README.md)
