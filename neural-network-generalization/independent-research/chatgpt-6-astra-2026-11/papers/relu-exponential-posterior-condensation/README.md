# Exponentially many exceptional neurons in a Gaussian ReLU posterior

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. The main theorem statements are not claimed to be Lean verified.

## Result and scope

Coarse conditioning, energy, kernel, and dimension-asymptotic arguments.

Full-cube observations, fixed dimension, and width tending to infinity. The exceptional-neuron structure alone is not a prediction-error theorem.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

See the [verification inventory](../../verification/README.md) for exact arithmetic, selected Lean lemmas, numerical diagnostics, and their limitations.

## Related papers

- [A critical exponential tilt of a Gaussian ReLU neuron](../relu-critical-tilt-proof/README.md)
