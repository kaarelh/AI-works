# Heavy-tail sparsity can obstruct frozen-feature transfer

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. The main theorem statements are not claimed to be Lean verified.

## Result and scope

Second-round width-first theorem, dimension-dependent tail exponent; frozen regression, not end-to-end classification.

The exponent p=1/log(r) changes with dimension, and width tends to infinity first. The lower bound concerns frozen Gaussian-readout regression, not end-to-end classification.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

See the [verification inventory](../../verification/README.md) for exact arithmetic, selected Lean lemmas, numerical diagnostics, and their limitations.

## Related papers

- [Sparse posterior condensation under heavier-than-Gaussian ReLU priors](../relu-heavy-tail-posterior/README.md)
- [Polynomial-data feature transfer for cold Gaussian ReLU Bayes](../near-minimum-energy-transfer/README.md)
