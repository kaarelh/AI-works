# Exponentially many posterior condensates for a small parity teacher

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. The main theorem statements are not claimed to be Lean verified.

## Result and scope

Full even parity; second exponential order selects the count.

The model conventions, order of limits, and verification qualifications are stated in the manuscript.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

See the [verification inventory](../../verification/README.md) for exact arithmetic, selected Lean lemmas, numerical diagnostics, and their limitations.

## Related papers

- [Gaussian softplus neurons need not have entropy projections](../softplus-critical-tilt-proof/README.md)
- [The exact ReLU condensate count and its polynomial evidence cost](../relu-sharp-condensate-count/README.md)
