# Fresh publication audit: isotropic online mistakes

Date: 2026-11-06

**Verdict: PASS. No blocking mathematical or scope issue found.**

This was a fresh review of the two publication sources in
`/workspace/nnbayes-isotropic-online-2026-11-05/neural-network-generalization/works-in-progress/online-mistakes/`, their included TeX files, their leaf READMEs, and the new discussion in `TECHNICAL-FAQ.md`, principally Question 32. The fixed-width upper argument also received an independent fresh review recorded in [publication-upper-fresh-audit.md](isotropic-online-upper-fresh-audit-2026-11-05.md). No repository files were edited during this audit.

## Exponential tanh theorem

The lower theorem is correct at its stated scalar learner width. In particular:

- The paired diagonal calibration examples imply `u>=1` and `|s_i|<=u-1`. Averaging the paired negative carry constraints cancels their upper-coordinate terms and forces `w_i>=2^i(1+(u-1)/2)`. The negative query at `t>=k` then forces `v<=-(2t+1)`. These are valid individual lower bounds for every summand of the coefficient norm, so their simultaneous attaining vector is the unique convex optimizer.
- That optimizer is `A_t=-t-(t+1)z+sum_i 2^i(x_i-y_i)`. Its scores on both selector branches are odd integers. Thus it satisfies the required global absolute margin, even though the minimization initially used only observed-label inequalities. It fits every earlier query and predicts the next query positively, whereas the target is negative there.
- There are at most `4k+2` distinct calibration inputs, followed by `q_k`. The subsequent distinct queries number `2^k-k-1`, and appending the remaining cube inputs gives one fixed permutation. The count is at least `2^(k-1)` for every stated `k>=3`.
- At every finite scalar depth, positive downstream tanh weights give a strictly monotone odd chain. Factoring out the smallest signed first preactivation reduces function energy to a coercive scalar variational problem whose value strictly increases with affine cost `Q`. Weak and strict global margins have the same energy infimum by scaling the readout. Gaussian small-noise rates therefore concentrate the actual posterior on the uniquely cheapest function; this is not a MAP tie-rule assertion.
- The finite number of forced rounds permits one common positive-scale threshold and the claimed union bound for sampled predictions. Majority and confidence claims follow from the same correct-label probabilities. No width, dimension, or depth limit is interchanged with the small-scale limit.
- The ordinary Boolean circuit upper bound is linear. All `2k+1` inputs are essential; the ancestor-DAG edge count gives the matching linear lower bound for any fixed complete fan-in-two basis.
- At depth `2k+2`, the scaled affine first layer followed by `2k` weight-two amplifications has strict output margin greater than one half. Its first-layer squared norm is below `8/3`, giving energy below `(40k+11)/3`. The contraction argument excludes an all-weight-one scalar implementation, so `C_L=2` under the repository's complexity convention.

The crucial qualification is accurately stated in the abstract, theorem discussion, corollary, README, and FAQ: **the tanh learner has `N=1<C_L=2`**. This proves neither the tanh lower bound at every sufficient width nor a fixed-depth lower bound with polynomial bounded-weight teacher complexity. Increasing depth preserves the scalar energy ordering; adding a neuron does not. The text does not claim otherwise.

## Linear appendix

The appendix is correctly separated from the tanh result. Its factorization identity

`min kappa_N(theta) = L (d ||A||^2)^(1/L)`

holds at every finite positive width: Frobenius submultiplicativity and AM–GM give the lower bound, and the displayed balanced rank-one factors attain it. The product of layer energy coefficients is exactly `d`, including the `L=2` case. Thus the function energy is `L(d Q(g)/4)^(1/L)`, strictly increasing in `Q` and independent of width. The same posterior argument and fixed input order apply. Its bounded-weight teacher has depth `k+2` and linear-activation complexity exactly two. The claim for every fixed `N>=C_L` is valid, without a width-uniform positive-scale threshold. It supplies no inference for wider tanh networks.

## Subexponential theorem

The scalar proof is valid. Homogenizing the affine threshold permits signed permutations of the augmented coordinate vector, including its constant coordinate. These induce legitimate Boolean-function transformations because the neural score is odd. They preserve the Gaussian law and the global margin event, so masses are exactly equal inside each orbit at every positive scale.

For the unique minimum-margin affine vector, every essential coefficient has magnitude at least one. Two distinct positive coefficient magnitudes less than one apart would induce a label-preserving swap; averaging the two corresponding feasible optimizers would contradict uniqueness. Consequently the number of distinct magnitudes is at most `(3K)^(1/3)` and support size is at most `K`. The canonical-vector packing argument, orbit-size count, and resulting budget all check out.

The shrinking-block lemma does not require equal masses across energy levels or across orbits. Its telescoping bound remains pathwise under adaptive query selection. The posterior outside the target-energy sublevel has a uniformly small bound over every target-consistent history, since the denominator always includes the raw target cell. Repeated inputs incur zero posterior error, so this tail is charged only `2^d` times. This justifies both the uniform finite-scale result and every simultaneous subsequential strong-prior limit. The expectation, majority, confidence, and supermartingale high-probability consequences follow.

The bounded-weight scalar corollary correctly proves `Q(f)<=d+1` by showing that the active augmented target is a signed majority; simply normalizing an arbitrary weight-one vector would not have sufficed, but the supplied symmetry argument does. The exact AND cost `d^2-d+1` also checks out.

The independent fixed-width audit found no gap in the column-clustering symmetries, moment bound, Taylor remainder, finite descriptors, quantization, or growing-order constants. With `q=ceil(log(p+1))`, the constants needed for quantization have logarithms of order `O_n(log^2(p+1))`; the resulting orbit logarithm is `O_n(p^(n/(n+2)) log^(3+n/(n+2))(p+1))`, which implies the stated simpler logarithmic fourth power. The theorem is correctly limited to fixed learner width and one hidden layer, with a `C_2=1` target. It is not uniform in growing width.

## Publication wording and remaining scope

The FAQ and leaf READMEs accurately distinguish the lower and upper regimes, the separate identity-activation appendix, actual posterior prediction, sufficiently small positive scales, and conventional versus Lean verification. The scalar lower example has exponential affine cost, so it does not conflict with the scalar cost-dependent upper bound.

One optional clarity edit is advisable in `isotropic-subexponential/source/upper-moment-section.tex`, in the theorem's alternative epsilon-exponent sentence. Explicitly say that this dimension-only exponent applies to **the bounded-weight targets of the first assertion, equivalently using `K=O(d)`**. The sentence follows a general-`K` formula and could otherwise be misread as a bound independent of arbitrary target energy. Its intended scope and derivation are clear, so this is not a mathematical blocker.

The unanswered case remains the unchanged isotropic tanh posterior at every sufficient width in the general teacher regime. These papers provide a scalar counterexample and restricted subexponential impossibility results, rather than a resolution of that full case.

Publication follow-up: the suggested alternative-exponent qualification was incorporated before the final build.
