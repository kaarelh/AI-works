# Polynomial probabilities of extra exceptional neurons

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. Selected deterministic components are Lean checked; the complete main theorems are not formalized.

## Result and scope

Sharp fixed-count ReLU posterior hierarchy: each extra macroscopic neuron costs width to the power minus (r-3)/2. A count-and-rank formula identifies the additional cost of new output directions.

Full-cube source labels, fixed even dimension at least six, fixed sufficiently small norm cutoff. Conventional asymptotic probability proof, not an online mistake theorem.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

The [21 November research payload](../../rounds/2026-11-21/README.md) contains supporting programs, exact finite checks, and numerical diagnostics. The [verification inventory](../../verification/README.md) distinguishes those checks from complete formalization and independent proof review.

## Related papers

- [The exact ReLU condensate count and its polynomial evidence cost](../relu-sharp-condensate-count/README.md)
- [Independent large-width constructions for Gaussian ReLU posteriors](../relu-independent-posterior/README.md)
