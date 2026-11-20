# Checking and moving between posterior sectors

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. The main theorem statements are not claimed to be Lean verified.

## Result and scope

Algorithmic derivations and diagnostics, without a mixing certificate.

Exact real-arithmetic conditional-update identities and exploratory implementations. No chain-mixing or posterior-computation complexity certificate is supplied.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

See the [verification inventory](../../verification/README.md) for exact arithmetic, selected Lean lemmas, numerical diagnostics, and their limitations.

## Related papers

- [The orientation law of Gaussian ReLU condensates](../relu-orientation-law/README.md)
- [A critical exponential tilt of a Gaussian ReLU neuron](../relu-critical-tilt-proof/README.md)
- [Ordinary feature adaptation under faster-than-Gaussian ReLU priors](../relu-quartic-posterior/README.md)
