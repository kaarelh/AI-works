# Kernel fluctuations within a ReLU orientation sector

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. The main theorem statements are not claimed to be Lean verified.

## Result and scope

Late-stage conditional CLT. No finite-width moment expansion asserted.

A conditional distributional limit within an orientation sector. Uniform integrability and finite-width moment expansions are not asserted.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

See the [verification inventory](../../verification/README.md) for exact arithmetic, selected Lean lemmas, numerical diagnostics, and their limitations.

## Related papers

- [The orientation law of Gaussian ReLU condensates](../relu-orientation-law/README.md)
