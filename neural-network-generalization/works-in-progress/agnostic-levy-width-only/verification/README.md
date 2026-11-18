# Verification record

The 40-page manuscript was rebuilt from the exact LaTeX sources with three isolated `pdflatex` passes. The build has no undefined references, undefined citations, overfull boxes, or LaTeX warnings. PDF metadata and the alphabetical-author footnote are present.

The proofs are **not Lean formalized**. The records below are independent AI-agent mathematical reviews. The final integration record and its portable SHA-256 snapshot cover every source included in the current manuscript; earlier module snapshots retain the exact versions reviewed at those stages.

- [Final integration review](independent-final-seventeen-source-review.md) checks all seventeen included sources, model conventions, quantifiers, resource substitutions, and statistical interfaces. [Current source hashes](independent-final-seventeen-source-review-hashes.json).
- [Finite-variance transfer](independent-finite-variance-review.md) checks the direct leave-one-out inequality with unchanged labels and its marginal tail term. [Imported module snapshot](independent-finite-variance-review-hashes.json).
- [Formula compactification](independent-formula-review.md) checks the no-fanout normalization, integer linear constraints, contracting prior comparison, continuous extension, and hidden-bias variant. Its original file was imported with only a display line break; the final integration record covers the included version.
- [Bounded output reset](bounded-reset-padding-independent-review.md) and [scalar output padding](scalar-output-padding-independent-review.md) check the additive learner-depth refinement. The scalar module is included only through its ReLU results; the final integration record covers that selected text.
- [Compiler and growing-class review](robust-agent-compiler-review.md) checks the original actual-formula counts and the `N ≥ n` conjecture-style corollary. The final integration review also covers the sharper additive-depth substitution.
- [Exact Boolean shallow compactification](shallow-boolean-independent-review.md) checks the closed-mask polyhedron and same-width quadratic bound.
- [Continuous shallow grid compactification](shallow-continuous-grid-fresh-reader-review.md) and [a second independent review](shallow-continuous-grid-oracle-review.md) check the rational-grid extension and final-tanh variant.
- [Univariate approximation and nearby-input obstruction](univariate-close-input-fresh-reader-review.md) checks the linear-width approximation and both atomic and atomless negative examples.
- [Logarithmic-comparison statistics](statistics-independent-review.md) records the original statistical module. The final integration review covers its explicit relative-loss PAC–Bayes and conditional quantization-net proofs.

The primary guarantees are **in expectation over the training sample**, for one final posterior trained on all observations. Under only finite-variance labels the bounded output range and Gaussian observation variance follow deterministic schedules, and the theorem retains an explicit marginal label-tail term. Under bounded conditional means and conditional sub-Gaussian noise, one fixed likelihood gives the sharper stated costs. The optional deterministic all-width theorem uses a potentially extremely small, nonexplicit variance at smaller widths; it is not a fixed-likelihood guarantee. The separate general-depth high-probability theorem selects a variance on a validation half and returns the posterior trained on the other half; no all-data refit guarantee is claimed.

The manuscript states and cites prior-localization and compiler interfaces imported from companion papers. It proves the statistical reductions, coefficient-free wrappers, same-width compactification, refinements, and nearby-input obstruction. Its reviews do not claim to re-prove every cited external complexity or probability theorem.

`SHA256SUMS` records the complete publication snapshot. `build.log` is the final clean compilation log.
