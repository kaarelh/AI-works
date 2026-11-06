# Verification and exact scope

**Author-order revision, 6 November 2026.** The author declarations, alphabetical-order footnotes, and PDF author metadata were updated without changing the document bodies. [Current hashes and clean rebuild checks](../../../../verification/author-order-2026-11-06.md) supersede the earlier manuscript hashes below; the dated mathematical reviews remain records of their original snapshots.

5 November 2026. [Paper](../paper.pdf) · [Source](../source/paper.tex)

Conventional proofs with independent AI-agent mathematical checks. **Not Lean formalized or human peer reviewed.**

The scalar argument was independently checked for unique affine-margin minimizers, separation of distinct coefficient magnitudes, packing of canonical representatives, exact augmented-coordinate Gaussian symmetries, and the pathwise shrinking-block error bound. The strong-prior tail estimate is uniform over histories; repeated inputs contribute no tail error. Sampling, majority, and confidence criteria are kept distinct.

The wider, shallow-network argument received separate checks of:

- The original Gaussian normalization `(d/n)‖A‖²+n‖b‖²`.
- Exact Boolean invariance under swaps of nearby input columns.
- The packing estimate for the number of column groups.
- Sampling-without-replacement moment bounds and the Taylor remainder.
- The partition formulas expressing moments through group power sums.
- Uniform quantization of those descriptors, including descriptions that need not correspond to a real network.
- Growth of the combinatorial and derivative constants with Taylor order. Taking order proportional to `log d` gives the displayed `log⁴(d+2)` factor; a separately stated fixed-order theorem does not require this refinement.
- The target restriction `C₂=1`: a depth-two width-one teacher with **every weight at most one**, not an arbitrary bounded-weight teacher.

The [scalar and integrated review](orbit-review.txt) and [higher-moment audit](upper-final-audit.txt) record these checks. The integrating agent separately reviewed the complete final argument. The publication [record](record.json) identifies the final source hashes, superseding intermediate hashes in the review notes.

The conclusions are subexponential bounds on expected sampled mistakes, majority mistakes, and confidence failures, with high-probability sampled-error consequences. They do not rule out an exceptionally unlikely sampled path with more mistakes. Constants for the wider theorem depend on its fixed width, and that theorem has one hidden layer. Neither a uniform growing-width theorem nor a polynomial mistake bound is claimed.

Isolated rebuilds produced matching PDF text, with no unresolved references or LaTeX warnings. Title/abstract and theorem pages were visually checked.
