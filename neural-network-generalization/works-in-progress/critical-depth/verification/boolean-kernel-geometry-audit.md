# Independent audit of Boolean free-kernel geometry

Auditor: `depth_counter_audit`, 18 October 2026. The theorem and proof in `boolean-kernel-geometry.md` pass independent mathematical review. This is not Lean verification.

The scalar recurrence checks: `F(q)=q-2q²+O(q³)` and strict `F(q)<q` imply `q-F(q)>=a q²` uniformly on `(0,2]` by compactness. The reciprocal recurrence gives the claimed upper variance bound. The inequality `tanh²(t)>=t²/(1+t²)` and Cauchy–Schwarz give `F(q)>=q/(1+3q)`, yielding the lower variance bound.

For constant-diagonal Gaussian covariance, integration by parts gives `E[tanh(G)G^T]=(1-F(q))Q`. Subtracting this linear projection leaves an orthogonal residual, including when `Q` is singular. Therefore the positive-semidefinite recurrence lower bound is valid.

The relative first-chaos retention factor is `R(q)=q(1-F(q))²/F(q)=1+O(q²)`. It is strictly positive on `(0,2]`, so `|log R(q)|<=Aq²` there. Since `sum_s q_s²<=2/a`, its products are bounded below uniformly in depth. The normalization starts from `r_0/q_0=1/(d+1)`, proving the matrix lower bound.

Applying the matrix inequality to `e_x-e_y` and using squared augmented-input distance `4d_H(x,y)` gives both normalized and unnormalized pair-distance estimates with universal constants. The kernel recurrence does not use the input sampling law, so restriction to any Boolean code or nonuniform law creates no loophole.

The scope is stated correctly: this rules out exponential contraction through an uncontrolled critical prefix at polynomial dimension and depth. It imposes no such restriction on entropy-controlled paths and does not prove posterior learning or a posterior lower bound.

## Additional audit: controlled contraction of one pair

The subsequently appended controlled-pair proposition also passes independent review. The common/contrast decomposition has independent Gaussian components because the two diagonal entries agree. In the full Gaussian process, the conditional decomposition `G=E[G|B]+R` changes only the contrast marginal when its first term is multiplied by `t`. This is valid on the covariance range even when the full covariance is singular, and the KL divergence is exactly the scalar divergence `(t²-1-log(t²))/2`. Taking `t=exp(-sqrt(J/T))` makes that divergence at most `J/T` by `exp(-2u)<=1-2u+2u²`.

The selected contrast variance is initially positive and remains positive under these finite contractions and strictly increasing tanh, so the conditional Gaussian operation is well-defined at every step. Tanh preserves the equality of the two diagonal entries and gives `b_(s+1)<=t² b_s`.

Both monotonicity and the one-Lipschitz property of `F` hold globally on nonnegative variances. They imply that the controlled diagonal deficit relative to the free path is at most `sum_(j<s)(1-t²)b_j<=1/d`. The dimension requirement gives the claimed lower diagonal bound. Finally `1-c_T/q_T=2b_T/q_T` yields exactly

`[8(1+3T)/(3d)] exp(-2sqrt(TJ))`.

Thus the proposition genuinely excludes a uniform polynomial separation lower bound for all bounded-entropy controlled Boolean paths, even when `d` is proportional to `T`. Its limitation to one selected pair is material; it makes no posterior-rate comparison and supplies no learning lower bound.

## Final TeX source and directional-stability corollary

Independently read the complete frozen source `source/critical-boolean-kernel-geometry.tex`, SHA-256 `46251125cb73544efa8a6a4d31aa900613c7161822eb097903aae4f261b5b142`. Both geometry propositions match the reviewed mathematics and pass. The new no-depth-uniform-stability corollary also passes.

For the corollary, the fixed target `f(u)=u_1 u_2` on three coordinates has a bichromatic anchor edge whose stabilizer exchanges coordinates two and three. Two exchanged inputs have opposite target labels, so invariant real outputs have uniform error at least one, and invariant Boolean outputs disagree at at least one input. The existing all-function rate bound supplies feasible paths with excess `O((1+log L)^2/L)`. An arbitrarily small additional approximation to the variational infimum causes no problem. For sufficiently large depth the hypotheses `A<=3` and `epsilon<=1` hold.

The independently audited near-baseline decomposition gives a vanishing minimum variance and hence vanishing prefix-plus-conditional KL and readout residual. The anchored-section corollary identifies the resulting classifier with the original target for all sufficiently large depths. Thus vanishing directional entropy alone cannot force approximation by the exact zero-entropy invariant class with a modulus independent of depth. The text correctly allows stability involving depth, and correctly notes that the example does not obstruct polynomial intrinsic product complexity or prove any posterior learning lower bound.
