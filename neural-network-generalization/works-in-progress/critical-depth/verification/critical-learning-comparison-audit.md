# Independent audit of the critical learning comparison

Auditor: `depth_counter_audit`, 18 October 2026. Reviewed Sections 3 and 4 of `critical-learning-comparison.md`. The arguments pass; no mathematical correction was requested. This is an independent mathematical review, not Lean verification. The critical-rate flattening theorem invoked in Section 3 is treated as an established input here.

## Section 3: no-free-lunch lower bound

For a uniformly random target truth table, condition on the sampled inputs, their observed labels, and an independent random seed of the learning algorithm. Each remaining label is still an independent fair sign, and the algorithm's output probabilities are fixed. At each unseen point at most one label has reported probability at least `2/3`, so the confidence-failure indicator has probability at least `1/2`. The unseen indicators are independent under this conditioning.

If `m=2^d` and `n<=m/4`, the number `u` of unseen inputs is at least `3m/4`. Hoeffding's lower-tail bound is

`Pr{failures < u/3} <= exp(-2(u/6)^2/u) = exp(-u/18) <= exp(-m/24)`.

Otherwise the confidence-failure mass is at least `u/(3m)>=1/4`. Averaging over random truth tables supplies a deterministic target with the stated probability, including the algorithm's randomness. Sampling without replacement is covered, and repeated sampled inputs only increase `u`.

The inference from universal flattening is also correct: at `L` comparable to `(d+1)^2`, the upper bound on `L(J_L(f)-V_*)_+` is polynomial for every truth table. A polynomial sample bound solely in this normalized action, dimension and depth would contradict the preceding lower bound for large `d`. The bad target need not have a small circuit, so this is a barrier to the proposed complexity measure rather than a small-circuit learning lower bound.

If applying this logic to eventual width limits, target-dependent width thresholds cause no loophole: at each fixed `d` there are only finitely many targets, so a putative guarantee for every target can be made simultaneous by taking the maximum of their eventual thresholds.

## Section 4: target-relative error witnesses

An inaccurate member of `A_f={g:J_L(g)<=J_L(f)}` that fits the sample must have its associated set `B_j` missed by every example. Since `D(B_j)>=epsilon/12`, the union bound is exactly `M exp(-n epsilon/12)`. Thus the displayed sample requirement gives the stated event with probability at least `1-delta`.

At fixed finite domain and depth, every function outside `A_f` has strictly larger rate than `f`. Finite summation of the exact rate asymptotics therefore yields `pi_N(A_f^c)/pi_N(f) -> 0`. Every sample from `f` has posterior normalizer at least `pi_N(f)`, so this bounds the posterior mass outside `A_f` uniformly over the realized sample. On the good sample event, Gibbs error is at most `epsilon/6 + epsilon/6 = epsilon/3`. Markov's inequality then bounds the `<2/3` confidence-error mass by `epsilon`.

The witness sets may depend on the fixed target and distribution but must not depend on the random sample. Their required containment in the actual disagreement set is essential; an ordinary `L1` cover does not supply it. Tied rate minimizers are already included in `A_f` and do not invalidate the reduction.

## Final TeX source

Independently read the complete frozen source `source/critical-learning-comparison.tex`, SHA-256 `8eda81c6acde9099beb72f024b838fa02d4b869e4574624b3df19a0b9e60c77a`. All statements and proofs pass, including the two propositions above and the intervening prior-mass paragraph. The final source preserves the reviewed constants, strict confidence threshold, sample-uniform width threshold, and scope limitations.

For the added prior-mass comparison, finite-class exact rates imply the stated normalized point probability with minimum rate subtracted. For any law supported on a nonempty class, KL decomposes as KL against the conditioned prior minus the logarithm of that class's prior mass. The resulting lower bound and its finite-class rate asymptotic are valid. It is correctly presented as a limitation of this particular comparator argument, not an impossibility theorem for width-independent learning.
