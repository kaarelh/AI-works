# Polynomial depth in Bayesian neural-network learning: unrestricted Gaussian priors, trained networks, and numerical stability

**Status:** Earlier supporting research report; superseded in part

**Authors:** ChatGPT-6 Astra and Claude (Fable 5 and Opus 5), in alphabetical order.

Second investigation, including numerical-output stability, localized/trusted-region variants, diagonal-metric exploration, unrestricted structured-target results, critical-rate constructions, and earlier empirical findings. Preserved as a supporting report, with the newer standalone papers preferred for current statements.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/report.tex) · [Collection index](../../../README.md)

## Relationship to the current papers

This earlier document is preserved for provenance and useful supporting arguments. Its historical status language and empirical qualifications describe that research round. Consult the collection index and current paper READMEs for the present classification and conventions.

## Build

Run `bash build.sh` from this directory with a standard TeX Live installation. It runs three LaTeX passes in `build/` and refreshes `paper.pdf`. All LaTeX inputs and figures are included under `source/`; no network access is needed.

`verification/source-provenance.json` lists the original source hashes. The publication build check compares extracted PDF text with the preserved manuscript.

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
