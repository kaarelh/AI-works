# Exact sector sampling for condensed ReLU posteriors

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. Selected deterministic components are Lean checked; the complete main theorems are not formalized.

## Result and scope

Exact ReLU posterior draws conditional on a specified finite union of count sectors. Including finitely many extra-neuron sectors gives any fixed polynomial total-variation accuracy at expected linear width cost.

Hard margins and square/logistic full-cube likelihoods; fixed dimension and number of retained sectors. Constants may be enormous. Dummy critical draws cancel unknown normalizers in the multisector mixture; no practical dimension-uniform or bit-complexity bound.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

The [21 November research payload](../../rounds/2026-11-21/README.md) contains supporting programs, exact finite checks, and numerical diagnostics. The [verification inventory](../../verification/README.md) distinguishes those checks from complete formalization and independent proof review.

## Related papers

- [Polynomial probabilities of extra exceptional neurons](../quantitative-condensate-count/README.md)
- [Finite Metropolis corrections for a condensed ReLU posterior](../metropolis-corrected-posterior/README.md)
