# Verification record

The paper and supporting note have conventional mathematical proofs and independent AI-agent checks. **They have not been formalized in Lean.** The checks below are not an unrestricted-posterior learning lower bound.

The [independent cross-audit](independent-cross-audit.md) checks the paper's four principal statements against their proofs:

1. The first-layer SVD, normalized code, quantization, margin separation, and bounded-integer threshold implementation give the stated rank-to-TC⁰ size bound.
2. Distinguishing rows of the inner-product truth table, cube isotropy, and packing in the actual image rank give the exponential product bound.
3. Exact affine-code counting gives the common-denominator lower bound, without using continuity of later layers.
4. The explicit wide tanh construction computes the pairwise conjunctions and their parity, while charging all constant rails, matrix entries, and readout coefficients.

The width-24 bounded-coefficient representation consequence imports the compiler proved and audited in the [companion paper](../../boolean-depth-barriers/paper.pdf). The four principal theorems in this paper do not depend on that compiler.

The same cross-audit separately checks the [supporting note](../research-notes/precision-and-oscillation.md): its sharper analog rounding estimate and its fixed-width tanh construction with exponentially many Boolean-grid sign changes. The publication explicitly incorporates the audit's clarification that the inverse image of the reference interval consists of exactly two branches. The oscillation result concerns an implementation, and is not an intrinsic Boolean circuit or learning lower bound.

[Publication checks](publication-check.json) record the isolated source rebuild, five-page PDF, absence of final LaTeX warnings, and relative-link check. [SHA256SUMS.json](SHA256SUMS.json) identifies the curated source, PDF, build script, research note, and audit record. A successful TeX build verifies document construction, not mathematical validity.
