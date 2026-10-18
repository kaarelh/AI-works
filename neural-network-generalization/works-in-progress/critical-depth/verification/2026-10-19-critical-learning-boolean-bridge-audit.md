# Independent audit: critical-rate sublevel learning

Source checked in full: `source/critical-rate-sublevel-learning.tex`.

Frozen SHA256: `daf24a7bbba273b0e8b85101604a0a17b64d343db44d186455dc15eb04655093`.

The statements and proofs pass independent mathematical review, conditional on the independently audited anchored-compression theorem, the existing exact critical-rate formula, and the cited classical polynomial VC bound for sigmoid networks. I checked the dependencies in the current sources, rather than imposing the small-excess assumptions of the unrelated terminal-rank-one theorem.

## Quantifier and algebra checks

1. The square-root entropy lemma in the repository is explicitly valid for every excess epsilon>=0. Its epsilon>=1/4 branch uses total entropy <=9epsilon and Cauchy--Schwarz. The anchored-compression theorem also allows arbitrary finite action, retaining a polynomial factor in A_0=max(1,A). Therefore the sublevel bound is valid for arbitrary finite a, not only a<=3.

2. Choosing an admissible path with action at most a+1/L is sufficient even when J_L(g) is an unattained infimum. Subtracting the scalar baseline then contributes at most one to L times the excess, hence only a universal factor in the exponential. The case a<V_* is correctly covered by the positive-part notation. Empty sublevel classes cause no problem.

3. The fixed-width tanh class can be embedded in the same-width sigmoid class by tanh(t)=2sigma(2t)-1 and allowing biases. The fully connected padded architecture has W=O((d+L+1)(M+1)^2) parameters. A quartic-in-W VC upper bound and Sauer's lemma give the displayed logarithmic cardinality bound. Arbitrary real weight magnitudes and precision do not invalidate this counting argument. The external VC bound itself is a cited dependency; this audit does not independently reprove that classical theorem.

4. The posterior argument uses the finite class of all Boolean functions at fixed d. For functions with rate strictly above J_L(f), the minimum finite positive rate gap is positive, and infinite-rate terms also have vanishing prior ratio. This yields a width threshold uniform in the realized sample because the posterior normalizer is always at least the target's prior mass. Tied rate minimizers are retained inside the finite Occam class. No unjustified concentration on a single minimizer is used.

5. On the good-sample event, every consistent member of the target-relative class has error <=epsilon/6, and posterior mass outside that class is <=epsilon/6. Thus Gibbs error <=epsilon/3. The set on which correct-label probability is <=2/3 has measure <=epsilon, including the non-strict endpoint. The theorem gives all sufficiently large widths, with no quantified N_0; it does not assert the earlier all-widths-above-complexity guarantee.

## Corollary depth restrictions

The existing controlled Fourier-seed theorem requires L>=C_0 T_f and gives excess C_1 T_f^2/L, with T_f=log(d+L+2)+log A_F. Consequently sqrt(L excess)=sqrt(C_1)T_f, making the exponential capacity term a universal power of (d+L+2)A_F. The remaining action prefactor is polynomial in the same quantity. Because the entropy lemma and compression both retain the large-excess case, **no squared-logarithmic depth restriction is needed** for this learning corollary. Such a restriction would be needed only if one insisted on an absolute action budget <=3, which this proof does not.

The analog-teacher corollary correctly uses the existing rate theorem with L>=C(D+1)log R and excess C(D+1)^2 log^2 R/L. It yields sample complexity R^{C(D+1)}, polynomial in learner depth for each fixed teacher depth, but not jointly polynomial in teacher depth and width. The source states this limitation explicitly.

No correction is requested.
