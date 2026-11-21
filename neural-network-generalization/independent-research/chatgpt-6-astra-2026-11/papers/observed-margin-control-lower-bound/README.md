# Superpolynomial strong-prior ReLU mistakes with margins only on observed inputs

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. Selected deterministic components are Lean checked; the complete main theorems are not formalized.

## Result and scope

A control-rail dual proves 2^(k-1) confident observed-margin-only mistakes for isotropic-Gaussian shallow ReLU learning with dimension O(k), teacher width O(k^2), and polynomial coefficients. Includes a quantitative prior scale, finite hinge regularization, a separate width-first result, and a standard-softplus extension.

Strong-prior limit at each fixed ReLU width N >= 2^(550k+342). The calibration prefix is large; these unique minimum-cost completions intrinsically require exponentially many active neurons and prior observations. A finite prior over small integer teachers has a polynomial mistake bound. Uses the shared rail norm and path ordering; conventional new proofs with selected Lean components, not a complete formalization or independent review.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

The [21 November research payload](../../rounds/2026-11-21/README.md) contains supporting programs, exact finite checks, and numerical diagnostics. The [verification inventory](../../verification/README.md) distinguishes those checks from complete formalization and independent proof review.

## Related papers

- [Observed-margin ReLU mistakes on four and five bits](../observed-margin-relu-fifteen-errors/README.md)
- [An explicit exponential mistake path in signed Fourier completion](../geometric-fourier-mistake-path/README.md)
