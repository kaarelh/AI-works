# Observed-margin ReLU mistakes on four and five bits

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. The main theorem statements are not claimed to be Lean verified.

## Result and scope

Exact four-bit and five-bit certificates prove 15 and 17 designated mistakes, respectively; no scalable lower-bound family.

Certified four-bit and five-bit examples, with separate fixed-width cold and fixed-temperature width-first limits. They are not an asymptotic superpolynomial lower-bound family.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

See the [verification inventory](../../verification/README.md) for exact arithmetic, selected Lean lemmas, numerical diagnostics, and their limitations.
