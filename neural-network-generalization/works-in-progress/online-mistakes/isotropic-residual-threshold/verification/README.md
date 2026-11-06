# Verification record

The manuscript has been checked by independent AI research agents. It has **not** been formalized in Lean.

- [Independent mathematical review](independent-review.md): exact linear and bounded residual profiles, all-width competitor bounds, selector geometry, product-box posterior estimate, theorem quantifiers, teacher complexity, and IID confidence guarantee.
- [Additional full-paper review](full-paper-review.md): a separate reading of the final source and all included proofs.

The reviews identify the exact source hashes examined. The paper uses two source files, [paper.tex](../source/paper.tex) and [selector.tex](../source/selector.tex), and builds with [build.sh](../build.sh). The final source compiles to ten pages with no undefined references or layout warnings.

The review scope includes the activation's discontinuity and the distinction between every fixed width in the cold limit, direct γ > 1 limits, and sufficiently small mean-field prefactors. No result for ordinary tanh, ReLU, hardtanh, or the unit-prefactor mean-field boundary is asserted.
