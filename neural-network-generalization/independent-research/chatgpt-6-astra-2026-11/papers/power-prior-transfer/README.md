# Polynomial-data parity transfer under Gaussian and lighter tails

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. The main theorem statements are not claimed to be Lean verified.

## Result and scope

Finite posterior transfer for every fixed p >= 2; a narrower continuous bias prior improves sufficient pretraining exponents. Continuous-product initial-feature bound; exact sampling assumed.

Every fixed p >= 2 at a specified cold prior scale, with exact posterior pretraining and an even frozen feature map. The optimization comparison concerns a separately specified noisy correlation-loss algorithm.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

See the [verification inventory](../../verification/README.md) for exact arithmetic, selected Lean lemmas, numerical diagnostics, and their limitations.

## Related papers

- [Polynomial-data feature transfer for cold Gaussian ReLU Bayes](../near-minimum-energy-transfer/README.md)
- [Heavy-tail sparsity can obstruct frozen-feature transfer](../heavy-tail-transfer-obstruction/README.md)
- [Continuous smoothing of parity features: a quantitative initialization threshold](../continuous-initialization-parity/README.md)
