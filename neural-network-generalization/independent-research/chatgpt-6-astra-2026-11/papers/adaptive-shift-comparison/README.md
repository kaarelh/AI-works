# Tiny adaptive shifts and the importance of a density lower bound

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. The main theorem statements are not claimed to be Lean verified.

## Result and scope

Positive comparison and transport of the existing globally conditioned star example.

The positive and negative examples use different learner conventions. The negative example retains the original global-margin restriction.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

See the [verification inventory](../../verification/README.md) for exact arithmetic, selected Lean lemmas, numerical diagnostics, and their limitations.
