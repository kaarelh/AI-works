# Independent audit: depth alignment and majority combinations

Auditor: `depth_counter_audit`. Date: 2026-10-18.

Reviewed frozen source: `source/unrestricted-primary-majority-closure.tex`.
SHA-256: `00be77e79c34160843236daf5edf32585c95593e6195fe65c71e671b86ae8cba`.

**Verdict: all statements and proofs pass.** This final-source audit confirms the earlier review of `majority-product-closure.md`, including the corrected treatment of neuronwise cloning. No mathematical correction requested.

1. Scalar padding: the output bound `|z| <= P sqrt(d+1)`, cubic tanh lower bound, and Bernoulli inequality give preserved unit margin. Multiplying the old readout by `eta` and adding the final `3/(2 eta)` factor costs exactly `3/2` in the product, independently of the number of added layers.
2. Disjoint branches: the Frobenius identity at each stacked or block-diagonal layer and generalized Holder give the exact displayed bound. A bichromatic cube edge forces every nonconstant unit-margin branch to have product at least one. The averaging coefficient then gives the stated `m^(D/2-1)` architectural lower bound. Actual post-cloning branch products are used; the source correctly rejects false invariance under neuronwise cloning.
3. Shared-feature voting: the tanh sign approximation error is at most `gamma/2`, leaving unit output margin after scaling by `2/gamma`. The cloning formula is exact. Choosing clone counts proportional to `lambda_i / ||v_i||` asymptotically attains the weighted sum of readout norms; a sufficiently large finite integer choice gives the factor-two construction. No new bias is used.
4. Shared-feature minimax: on the finite cube only finitely many sign patterns occur. One admissible representative per pattern suffices, and finite minimax converts distribution-wise correlation into a pointwise voting margin. Applying the preceding theorem proves the intrinsic-product bound. The subsequent finite-size conclusion uses the already established depth-independent normal form.
5. Shallow closure limitation: the previously audited inner-product example supplies shallow polynomial-product voters on shared pairwise-AND features. Their alternating votes, with the optional constant vote, form the target by an odd majority. The target has exponential product at the original shallow depth and polynomial product after one additional layer. This does not disprove unrestricted-depth majority closure.

The statements preserve the substantive shared-feature hypothesis and do not assert a general weak-to-exact or posterior-learning equivalence.
