# Representation constraints and polynomial-depth learning in Gaussian Bayesian networks

**Status:** Non-main research draft / work in progress

Investigates the original Gaussian prior without an additional internal-stability restriction, retaining its global output-margin conditioning. Product-norm representation conditions, structured-target bounds, width compression, and learner-depth improvements are supporting results; a general joint polynomial-depth learning theorem remains open.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/unrestricted-paper.tex) · [Collection index](../../README.md)

## Scope and status

This paper is a non-main research draft for informal public sharing. Its results may be useful independently, but it is not included among the promoted main results. Mathematical audit notes are retained under `verification/`; they are independent AI-agent reviews, not a claim of Lean formalization.

[Technical FAQ](../../TECHNICAL-FAQ.md)

## Build

Run `bash build.sh` from this directory with a standard TeX Live installation. It runs three LaTeX passes in `build/` and refreshes `paper.pdf`. All LaTeX inputs and figures are included under `source/`; no network access is needed.

`verification/source-provenance.json` lists the original source hashes. The publication build check compares extracted PDF text with the preserved manuscript.
