# Depth dependence of Gaussian prior costs in critical neural networks

**Status:** Non-main research draft / work in progress

At gamma = 1, studies depth-dependent variational costs, target comparisons, and a polynomial width-first parity sample lower bound. Absolute prior-cost statements are distinguished from learning lower bounds. These results remain outside the main-results list.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/critical-paper.tex) · [Collection index](../../README.md)

## Scope and status

This paper is a non-main research draft for informal public sharing. Its results may be useful independently, but it is not included among the promoted main results. Mathematical audit notes are retained under `verification/`; they are independent AI-agent reviews, not a claim of Lean formalization.

[Technical FAQ](../../TECHNICAL-FAQ.md)

## Build

Run `bash build.sh` from this directory with a standard TeX Live installation. It runs three LaTeX passes in `build/` and refreshes `paper.pdf`. All LaTeX inputs and figures are included under `source/`; no network access is needed.

`verification/source-provenance.json` lists the original source hashes. The publication build check compares extracted PDF text with the preserved manuscript.
