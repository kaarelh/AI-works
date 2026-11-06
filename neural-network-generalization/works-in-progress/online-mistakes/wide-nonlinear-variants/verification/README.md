# Verification and exact scope

[Paper](../paper.pdf) · [Source](../source/paper.tex)

These are conventional mathematical proofs, not Lean formalizations. A [full standalone-manuscript review](full-paper-review.md) checked all seven source files, including the larger-perturbation corollary, its IID extension, and both tanh appendices, and found no mathematical correction necessary. It records the exact reviewed source hashes. Earlier independent reviews of the two main arguments are also retained:

- [Near-identity review](near-identity-review.md): uniformity in learner width, activation perturbation constants, the energy gap for all correct-at-next-query parameters, the general activation extension, and the exact teacher complexity.
- [One-nonlinear-layer review](odd-projection-review.md): the exact odd projection, equality cases and all minimizers, the softplus/ReLU monotonicity argument, antipodal input order, and teacher width/depth/weight bounds.

These review notes were written against the research proofs before integration into the standalone manuscript. The integrating agent rederived the core inequalities while writing the manuscript; the contributing agents checked their integrated sections afterward. The full-manuscript review then checked the integrated proofs and the added IID corollary, including its uniformity over all target-consistent histories. An additional review checked the improved perturbation allowance, which uses the exact affine energy increase to retain exactly `2^(k−1)` forced rounds, and verified that the same IID guarantee applies. The manuscript includes the complete comparator/calibration proof, so its main results do not require a previous paper.

The tanh appendix's construction, constants, layer counts, margins, and limitation to scalar implementations were checked against its research proof. The finite certificate is reproduced by:

```sh
python3 check_finite_certificate.py
```

Run that command from this verification folder. All assertions use exact `Fraction` arithmetic. The script proves a full-target margin greater than 1/2, a wider-network energy below 15.7, and a scalar wrong-function energy above 15.7. Printed decimals are explanatory only. The analytic inputs are monotonicity of tanh, `tanh(u) ≥ u−u³/3` for nonnegative `u`, and the matrix-product/AM–GM inequality. The all-width population proportion bound is proved in the paper.

The scope qualifications are part of the results:

- The near-identity activation depends on target size and depth, though its closeness requirement does not depend on learner width.
- The fixed standard-activation theorem has exactly one nonlinear hidden layer and no biases.
- All widths means every fixed finite width; the small-prior-scale threshold may depend on that width.
- The tanh comparisons exclude replicated scalar minimizers, not all wider implementations of their sign functions. They do not identify the actual wider posterior's next prediction.
- No iid sample-complexity lower bound and no fixed-standard-activation all-high-width result for the fully nonlinear biased architecture is claimed.

The [publication build record](publication-build.json) records final source/PDF hashes, clean isolated rebuilding, and exact-certificate execution. Any later source revisions require corresponding updates to that record.
