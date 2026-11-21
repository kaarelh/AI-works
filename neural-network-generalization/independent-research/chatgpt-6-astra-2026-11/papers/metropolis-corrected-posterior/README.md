# Finite Metropolis corrections for a condensed ReLU posterior

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. Selected deterministic components are Lean checked; the complete main theorems are not formalized.

## Result and scope

A general independence-Metropolis perturbation hierarchy and sharp neural sampling errors: each fixed correction adds a half-power of width until the omitted-sector floor.

Square or logistic full-cube likelihood, fixed even dimension at least six. Expected linear width cost has unrestricted dimension constants and assumes exact real arithmetic. This is a proposal-started correction theorem, not arbitrary-start mixing.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

The [21 November research payload](../../rounds/2026-11-21/README.md) contains supporting programs, exact finite checks, and numerical diagnostics. The [verification inventory](../../verification/README.md) distinguishes those checks from complete formalization and independent proof review.

## Related papers

- [Independent large-width constructions for Gaussian ReLU posteriors](../relu-independent-posterior/README.md)
- [Polynomial probabilities of extra exceptional neurons](../quantitative-condensate-count/README.md)
