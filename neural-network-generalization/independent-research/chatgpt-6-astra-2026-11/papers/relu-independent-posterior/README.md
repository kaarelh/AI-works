# Independent large-width constructions for Gaussian ReLU posteriors

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. The main theorem statements are not claimed to be Lean verified.

## Result and scope

Independent asymptotically exact constructions in total variation for full-cube hard-margin and square/logistic posteriors, with expected O_dimension(width) real-arithmetic cost. No finite-width rate or dimension-uniform guarantee; depends on the exact-count and orientation-law companions.

Full-cube data, fixed even dimension at least six, and a width-first limit. Independent proposals have linear expected width cost at fixed dimension; no finite-width total-variation rate, practical dimension bound, or bit-complexity claim.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

See the [verification inventory](../../verification/README.md) for exact arithmetic, selected Lean lemmas, numerical diagnostics, and their limitations.

## Related papers

- [A critical exponential tilt of a Gaussian ReLU neuron](../relu-critical-tilt-proof/README.md)
- [The exact ReLU condensate count and its polynomial evidence cost](../relu-sharp-condensate-count/README.md)
- [The orientation law of Gaussian ReLU condensates](../relu-orientation-law/README.md)
