# Gaussian square likelihoods can learn transferable parity features

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. Selected deterministic components are Lean checked; the complete main theorems are not formalized.

## Result and scope

Second-round finite posterior theorem with explicit likelihood scaling and ordinary-likelihood corollary.

The likelihood scaling is explicit. The ordinary fixed-variance likelihood corollary relates width, sample size, and prior variance. Frozen features use even projection or a linear skip.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

See the [verification inventory](../../verification/README.md) for exact arithmetic, selected Lean lemmas, numerical diagnostics, and their limitations.

## Related papers

- [Polynomial-data feature transfer for cold Gaussian ReLU Bayes](../near-minimum-energy-transfer/README.md)
