# Independent audit of the Gaussian scalar baseline gap

25 October 2026. Finite-N audit agent. Conventional mathematical audit, not Lean verification.

**PASS for Sections 1–5.** Audited `gaussian-scalar-baseline-gap.md`, snapshot `d5783f2a5878ca04022dce9c0fda9ba0115d39efb0e6a7c47ab5bad3e04cb493`. I also read the Gaussian growth and small-state bridge in `critical-rate-foundations.tex`, the last-exit proof in `critical-rate-lower-proof.tex`, and the maximum-variance occupation proof in `manuscripts/parallel-complexity.tex`.

The scalar constrained entropy optimizer is the unique bounded-potential exponential tilt. Its mean map covers (0,1), is strictly increasing, and has positive derivative. This makes the cost continuous on the compact crossing set. Equality between such an optimizer and a Gaussian law forces its Gaussian log density ratio to be a bounded quadratic polynomial, hence constant, so the control is free. A free tanh step cannot cross upwards through the chosen variance threshold. The minimum entropy saving on the compact set is therefore strictly positive.

Every Gaussian path of total cost below two must end above the threshold 1/16. At its first crossing, a preceding variance below 1/160 would force a second-moment ratio at least ten, costing more than two. Thus every such path encounters the compact crossing set. Replacing that one transition by its exact entropy optimizer preserves the next scalar state and every later cost while saving a common positive amount. The explicit all-Gaussian upper bound 199/200+log(5/2)<2 is valid, so these paths approximate the Gaussian infimum. This proves V_*^G>=V_*+delta uniformly, not just finite-path strictness.

Gaussian monotonicity, deletion of nonincreasing steps, and the small-state bridge all stay in the Gaussian class, including when means are nonzero. Therefore the Gaussian value has the same small-state Lipschitz bound and Bellman inequality. A scalar projection of an actual Gaussian control is Gaussian; data processing bounds its entropy by the full layer cost. These facts supply the genuine Gaussian suffix lower bound, not an approximate replacement.

The maximum-variance dissipation step is valid after decreasing c so p-cp^2 is increasing on [0,2]: project onto an input attaining the NEW maximum, then replace its incoming variance by the old maximum in the correct inequality direction. The prefix entropy bound follows from a Gaussian scalar suffix at an input attaining the current maximum. Consequently the existing last-exit/forced-cooling proof applies with V_G and gives the stated occupation near V_*^G. The initial variance up to two is harmless after the same reduction of c.

For the inverse-depth lower bound, one fixed input suffices. If action is at most V_*^G, each prefix entropy is at most C times its endpoint variance. The last-exit lemma yields a variance at most C/H, and the Gaussian scalar suffix then costs at least V_*^G-C/H. No variational optimizer is assumed.

Hence the earlier corollary conditional on Gaussian action at most V_*+epsilon was logically correct but is eventually empty when epsilon tends to zero. The useful Gaussian corollary must be stated relative to V_*^G. The direct Gaussian entropy-budget compiler remains unchanged.

This audit does not assert target-specific attainability of V_*^G from the augmented-cube input. That separate construction is explicitly left outside Sections 1–5 and is being checked independently.
