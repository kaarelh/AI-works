# Locality of parity transfer in a learned neural representation

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. Selected deterministic components are Lean checked; the complete main theorems are not formalized.

## Result and scope

Second-round finite-width near-versus-distant transfer separation, squared-loss lower bound via trace and symmetry.

The same pretrained representation supports nearby parity tasks and obstructs distant tasks for specified Gaussian readouts. The negative criterion is squared prediction error; unrestricted fine-tuning is not covered.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

See the [verification inventory](../../verification/README.md) for exact arithmetic, selected Lean lemmas, numerical diagnostics, and their limitations.

## Related papers

- [Polynomial-data feature transfer for cold Gaussian ReLU Bayes](../near-minimum-energy-transfer/README.md)
- [Gaussian square likelihoods can learn transferable parity features](../square-likelihood-transfer/README.md)
