# Final independent audit: strong-prior and deterministic compression

Reviewed on October 18, 2026:

- `paper/strong.tex` in full;
- `paper/norm-compression.tex` in full;
- `paper/paper.tex` model, strong theorem, confidence conversion, and both posterior lemmas;
- the cloning energy bound in `target-mass.tex` and the rounding induction in `tilt-compression.tex`, insofar as used by the strong-prior proof.

**Verdict: no substantive mathematical issue found in the audited statements or proofs.** This is a human-readable mathematical audit, not machine verification.

Specific checks:

1. The conditional prior and posterior are the original globally margin-conditioned, noiseless exact-consistency learner. Global-margin normalization cancels in the needed prior ratio. No posterior-mean or selected-minimizer substitution occurs.
2. The lower integral bound uses a strict target witness and an open positive-volume neighborhood. The upper bound correctly splits the quadratic exponential and integrates the remaining Gaussian envelope. Fixed-width powers of scale and coordinate-density prefactors disappear at the sigma-squared exponential rate.
3. The cutoff `K=(b/a)B_0+1` gives a strictly positive exponential gap for every outside function. Finiteness of the Boolean function space permits summing all ratios. All tied low-energy functions remain in the relevant class.
4. The small-scale threshold is selected only from the prior-tail requirement `epsilon/6`; it is therefore independent of D,n,delta, exactly as stated. Dependence on finite width is allowed and necessary for this proof.
5. The norm-compression proof's rowwise truncation, Hoeffding exponent `rho^4 M/32`, retained row-mass Markov bound, expected sampled energy, and reverse-order propagation inequalities are correct. The events need not be independent, and the union bound guarantees a simultaneous realization. Strict margin is restored by scaling the compressed readout.
6. The compressed width depends only on d,K,L. Rounding all implementations on that single architecture therefore counts the union over original widths, not merely each width separately. The rounding recurrence gives output error at most 1/8 with the displayed Lambda, including d=1, n=1, L=2 boundary cases.
7. The finite relevant-class posterior lemma uses the surviving target as denominator correctly. With `a=tau=epsilon/6`, it gives Gibbs risk epsilon/3; Markov's pointwise confidence inequality then gives F_{2/3} at most epsilon, including ties at the threshold.
8. The asymptotically quadratic ordering proposition correctly obtains global envelopes from positive continuous densities and their two-sided tail limits. The result controls function-event rates even if norm infima are unattained.
9. The amplified cloning witness has energy no greater than the stated B_0. Its larger final constant is harmless. It is a valid witness for all N>=C, including nonmultiples of C.

No edits requested. The stronger claims in the finite-scale gamma>=1 proofs were outside this assigned audit except where their auxiliary definitions were used above.
