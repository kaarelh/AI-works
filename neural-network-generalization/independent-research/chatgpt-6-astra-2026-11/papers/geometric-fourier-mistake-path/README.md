# An explicit exponential mistake path in signed Fourier completion

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. Selected deterministic components are Lean checked; the complete main theorems are not formalized.

## Result and scope

A complete inductive primal-dual proof of an exponential vertex path for geometrically decaying Fourier priorities, plus obstructions for inverse-power priorities and for slowly decaying geometric priorities.

A reduced signed-mass optimization problem, not a continuous-prior conditioning theorem. Its economical neural realization remains open; the separate control-rail companion proves the observed-margin-only neural lower bound by a different construction.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

The [21 November research payload](../../rounds/2026-11-21/README.md) contains supporting programs, exact finite checks, and numerical diagnostics. The [verification inventory](../../verification/README.md) distinguishes those checks from complete formalization and independent proof review.

## Related papers

- [Observed-margin ReLU mistakes on four and five bits](../observed-margin-relu-fifteen-errors/README.md)
- [Superpolynomial strong-prior ReLU mistakes with margins only on observed inputs](../observed-margin-control-lower-bound/README.md)
