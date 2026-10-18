# Depth-uniform Gaussian Bayesian learning of shallow Boolean targets

**Status:** Earlier standalone supporting draft

Earlier standalone presentation of product-norm and Gaussian-distance upper bounds for bounded-weight shallow targets and fixed intrinsic target depth. The newer unrestricted-depth paper incorporates stronger representation and learner-depth results; neither is a promoted main result.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/shallow-target-paper.tex) · [Collection index](../../../README.md)

## Relationship to the current papers

This earlier document is preserved for provenance and useful supporting arguments. Its historical status language and empirical qualifications describe that research round. Consult the collection index and current paper READMEs for the present classification and conventions.

## Build

Run `bash build.sh` from this directory with a standard TeX Live installation. It runs three LaTeX passes in `build/` and refreshes `paper.pdf`. All LaTeX inputs and figures are included under `source/`; no network access is needed.

`verification/source-provenance.json` lists the original source hashes. The publication build check compares extracted PDF text with the preserved manuscript.
