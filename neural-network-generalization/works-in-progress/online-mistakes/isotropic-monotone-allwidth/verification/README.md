# Verification record

This is a standalone conventional mathematical proof. It is not Lean formalized. The checks below were performed by separate AI agents during the research session, not by external peer reviewers.

The main theorem uses the fixed strictly increasing 1-Lipschitz activation `ψ(t)=(2t+φ(t))/3`, where `φ` is the period-four triangle wave. All proofs used in the theorem, including the underlying triangle atomic norm, appear in the source. The external NeurIPS reference supplies only precedent for the triangle component as an activation; no result about its prior or learning behavior is imported.

The scope is `2^(m-4)` designated mistakes, dimension and Boolean-circuit size `Θ(m^6)`, teacher width `8m-4`, calibration on `15/16` of the full cube, and every sufficiently large fixed learner width followed by the strong-prior limit. No polynomial sufficient-width bound, width-uniform variance threshold, or result for ordinary tanh, ReLU, GELU, or hardtanh is asserted.

Complete manuscript reviews:

- [Exact-search whole-theorem audit](exact-search-whole-theorem-audit.md): full proof chain, scaling, teacher convention, finite-width allocation, and actual posterior.
- [Tanh full-source audit](tanh-full-source-audit.md): affine calibration gap, all `1/ε` factors, strict margins, four-orientation replication, and source/PDF checks.
- [New-lens full-source audit](new-lens-full-source-audit.md): full main proof and atomic appendix, including the residual L² estimate and the arbitrary-small-perturbation qualification.

Supporting checks and derivations:

- [Independent monotone-extension audit](positive-monotone-extension-audit.md).
- [Monotone calibration derivation](monotone-calibration-derivation.md).
- [Atomic norm audit](atomic-norm-audit.md).
- [Weighted subgroup and star audit](weighted-star-audit.md).
- [Triangle-activation reference verification](triangle-reference-audit.md).

All reviews found no substantive mathematical gap. Minor resolved edits handle the zero-norm and zero-perturbation endpoints in strict inequalities, distinguish the known logical set from the number of designated rounds, and enlarge the core prefactor in the general small-`ε` remark when needed for the allocation mass. The final exact-search and tanh audits record the final source hash.

[build-record.json](build-record.json) records the source/PDF hashes and build checks. Three `pdflatex` passes produced a 14-page PDF with no final warnings or overfull/underfull boxes. The first page was visually checked for its title, activation display, author order, and alphabetical-author footnote. No numerical optimization or experiment is a proof premise.
