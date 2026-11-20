# A shortcut trap with trainable hidden biases

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. The main theorem statements are not claimed to be Lean verified.

## Result and scope

Late-stage construction on a different full-support distribution; conical starts.

A different full-support Boolean distribution and a conical initialization condition. This is not a generic Gaussian-initialization theorem.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

See the [verification inventory](../../verification/README.md) for exact arithmetic, selected Lean lemmas, numerical diagnostics, and their limitations.

## Related papers

- [A full-support Boolean shortcut trap](../full-support-shortcut-trap/README.md)
- [Imbalance and one-neuron renewal at the shortcut trap](../shortcut-renewal-and-imbalance/README.md)
