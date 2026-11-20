# The orientation law of Gaussian ReLU condensates

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. The main theorem statements are not claimed to be Lean verified.

## Result and scope

Orientation probability law, exact six-bit combinatorics, and a typical Fourier-concentration theorem using the cited resilient-function enumeration; covariance weights are numerical estimates.

Limiting probabilities over balanced orientation sectors. Combinatorial counts are exact; evaluated covariance weights are numerical estimates.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

See the [verification inventory](../../verification/README.md) for exact arithmetic, selected Lean lemmas, numerical diagnostics, and their limitations.

## Related papers

- [The exact ReLU condensate count and its polynomial evidence cost](../relu-sharp-condensate-count/README.md)
