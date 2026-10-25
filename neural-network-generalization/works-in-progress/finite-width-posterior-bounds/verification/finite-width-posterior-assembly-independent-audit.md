# Independent audit of the finite-width posterior manuscript

25 October 2026. Audited `manuscripts/finite-width-posterior-bounds.tex`, SHA256
`a30ab8a81329824484f1c8243b468c4ad72bc655083e3cf662544ae16647eb2c`.

Verdict: **PASS** for the full assembled upper bound, projective-symmetry lower, and width-monotonicity counterexample. This is a conventional mathematical audit, not formal verification.

## Actual-posterior upper

- The unequal-clone construction is exact. First/readout weighted energy ratios are at most two; internal norms gain only the maximum ratio of clone counts, at most two. The displayed K0 includes the augmented input and linear readout.
- Energy coordinates give the rescaled zero-preserving 1-Lipschitz activation phi_N, and initial state norm at most sqrt(2). The block-derivative/AM--GM bound is uniform on the convex energy ball. The chosen teacher ball stays inside energy K and retains signed margin at least 3/4.
- The Gaussian density lower bound is integrated over a cube of half-side min(r/sqrt(p),sigma). Its logarithmic volume cost is bounded by the displayed T uniformly in t; no inverse-temperature logarithm is omitted.
- Dividing the raw Gaussian energy tail by this lower bound gives the stated conditional tail because 1/(N sigma^2)=1/t^2>=1. Global margin and training labels remain present in the denominator throughout.
- Net centers stay inside the energy ball, and their signs agree everywhere with every clean-margin network they cover. The finite-class consistency event is fixed before sampling and uniform over the scale. Posterior Gibbs error is bounded by alpha+beta, and the 2/3-confidence failure mass is at most three times this quantity.
- The strong-prior limit uses continuity only of Gibbs error on the finite truth-table simplex, avoiding an invalid continuity claim for a strict confidence event.
- With polynomial d,C,B and fixed statistical parameters, the upper has N² times polynomial(L) size when log N<=cL, yielding the exponential-width corollary with coefficient c/2.

## Exact symmetry lower

The signed swap maps augmented inputs to sx_j(1,Tx), preserves both conditioning events, and gives complementary posterior votes on x_j=-s. The k-column argument correctly accounts for distinct paired levels, the self-paired middle level, and the unpaired all-positive level. The binomial identity sum min(w_r,w_(r-1))=1-max w_r is valid, including a two-point plateau. The iid constant-column count and fixed-epsilon logarithmic sample necessity follow with the stated quantifiers. The result is for confidence thresholds above one half; the majority tie caveat is appropriately separate.

The orbit-size limitation concerns only exact symmetry transforms of one target, not the entire posterior. This scope is stated correctly.

## Width-monotonicity example

Width one has affine-threshold signs, so the three observed labels force the unique realizable completion. The width-two negative-parity witness has strict margins by the stated elementary tanh bounds. Both cube completions have positive Gaussian mass at every finite positive scale, giving strict loss of correct-label probability at the unseen point. The text correctly does not claim a crossing of 2/3, a uniform gap, or strictness after a cold limit.

One optional presentation addition was suggested: the extension to arbitrary odd activations/invariant priors should explicitly assume its conditioning event has positive probability. This is automatic in the stated Gaussian tanh model and does not affect any main theorem.

## Final-source update

Final TeX SHA256 `183071b828f5f10045d331709292fe674ffa3b5813428a01851faec86a8db744` adds only the suggested phrase requiring a positive-probability conditioning event in the general-prior extension. This resolves the optional presentation point; the PASS verdict applies to this final source as well.
