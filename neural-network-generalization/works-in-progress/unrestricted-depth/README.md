# Representation constraints and polynomial-depth learning in Gaussian Bayesian networks

**Status:** Non-main research draft / work in progress

Investigates the original Gaussian prior without an additional internal-stability restriction, retaining its global output-margin conditioning. Product-norm representation conditions, structured-target bounds, width compression, and learner-depth improvements are supporting results; a general joint polynomial-depth learning theorem remains open.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/unrestricted-paper.tex) · [Collection index](../../README.md)

A positive result covers deep teachers with polynomially many possible hidden states after a fixed number of initial layers. Its sample bound is polynomial in teacher depth, learner depth, width, weight bound, and state count, at every learner depth at least the teacher depth and every admissible learner width, for each fixed exponent above one. No robustness restriction is added to the prior. Examples include fixed-width first layers with polynomial-denominator weights and teachers driven by a fixed number of coordinate-block bit counts. The [proof](source/unrestricted-primary-finite-bottleneck.tex) and [independent audit](verification/boolean-bottleneck-independent-audit.md) are included. The prefix depth is fixed; arbitrary small deep Boolean circuits remain open.

## Scope and status

This paper is a non-main research draft for informal public sharing. Its results may be useful independently, but it is not included among the promoted main results. Mathematical audit notes are retained under `verification/`; they are independent AI-agent reviews, not a claim of Lean formalization.

[Technical FAQ](../../TECHNICAL-FAQ.md)

## Build

Run `bash build.sh` from this directory with a standard TeX Live installation. It runs three LaTeX passes in `build/` and refreshes `paper.pdf`. All LaTeX inputs and figures are included under `source/`; no network access is needed.

`verification/source-provenance.json` lists the original source hashes. The publication build check compares extracted PDF text with the preserved manuscript.

The [Boolean-depth revision record](../../verification/boolean-depth-progress-2026-10-18.json) records the current source and PDF hashes and matching isolated rebuild. The finite-bottleneck learning theorem and shallow/deep norm separation have separate independent mathematical audits in `verification/`; neither addition is Lean verified.
