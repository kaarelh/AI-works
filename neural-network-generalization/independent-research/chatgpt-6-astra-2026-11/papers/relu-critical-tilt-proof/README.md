# A critical exponential tilt of a Gaussian ReLU neuron

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. The main theorem statements are not claimed to be Lean verified.

## Result and scope

Critical local density, scalar-conditioning evidence, independent asymptotic posterior construction in total variation, stable/Gaussian fluctuations, and an explicit sampled-network classification failure. Uses a cited local large-deviation theorem; not individual-label conditioning. An angular-volume criterion explains the endpoint moment thresholds.

The model conventions, order of limits, and verification qualifications are stated in the manuscript.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

See the [verification inventory](../../verification/README.md) for exact arithmetic, selected Lean lemmas, numerical diagnostics, and their limitations.
