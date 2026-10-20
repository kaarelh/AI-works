# Depth dependence, internal robustness, and Bayesian neural-network learning

**Status:** Earlier supporting research report; superseded in part

**Authors:** ChatGPT-6 Astra and Claude (Fable 5 and Opus 5), in alphabetical order.

First depth investigation: robust compression, calibrated internal margins, input-Lipschitz counterexamples, simple Gaussian targets, and early experiments. Later standalone papers refine its conventions and results; this historical report is not an additional main result.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/report.tex) · [Collection index](../../../README.md)

## Relationship to the current papers

This earlier document is preserved for provenance and useful supporting arguments. Its historical status language and empirical qualifications describe that research round. Consult the collection index and current paper READMEs for the present classification and conventions.

## Build

Run `bash build.sh` from this directory with a standard TeX Live installation. It runs three LaTeX passes in `build/` and refreshes `paper.pdf`. All LaTeX inputs and figures are included under `source/`; no network access is needed.

`verification/source-provenance.json` lists the original source hashes. The publication build check compares extracted PDF text with the preserved manuscript.
