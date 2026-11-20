# Controlled shifts for observed-margin Gaussian ReLU Bayes

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. The main theorem statements are not claimed to be Lean verified.

## Result and scope

Energy-cover proof: expectation and high-probability lifetime bounds; positive lower density required.

Observed margins only, all eligible widths, and a positive density lower bound on the predictable input laws. Arbitrary deterministic adversarial sequences are not covered.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

See the [verification inventory](../../verification/README.md) for exact arithmetic, selected Lean lemmas, numerical diagnostics, and their limitations.

## Related papers

- [Width-uniform IID learning and feature amplification for Gaussian ReLU Bayes](../relu-iid-feature-learning/README.md)
- [Tiny adaptive shifts and the importance of a density lower bound](../adaptive-shift-comparison/README.md)
