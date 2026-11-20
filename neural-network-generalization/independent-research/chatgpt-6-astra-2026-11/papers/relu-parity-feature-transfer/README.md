# Transfer to nearby parity targets after Bayesian feature learning

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. The main theorem statements are not claimed to be Lean verified.

## Result and scope

Full-data raw-feature transfer; typical-sector extension uniform in cold positive prior scales, after the width limit. The later low-rank companion separately proves finite-data raw transfer with weaker confidence quantifiers.

Raw frozen features after full-cube, width-first pretraining. The Gaussian finite-data companion uses even features or a linear input skip; the later low-rank companion treats raw features for each fixed nearby task with a confidence--dimension condition.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

See the [verification inventory](../../verification/README.md) for exact arithmetic, selected Lean lemmas, numerical diagnostics, and their limitations.

## Related papers

- [The exact ReLU condensate count and its polynomial evidence cost](../relu-sharp-condensate-count/README.md)
- [The orientation law of Gaussian ReLU condensates](../relu-orientation-law/README.md)
- [Polynomial-data feature transfer for cold Gaussian ReLU Bayes](../near-minimum-energy-transfer/README.md)
