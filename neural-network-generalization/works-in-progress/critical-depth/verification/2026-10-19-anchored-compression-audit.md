# Independent adversarial audit: anchored finite critical-path compression

Auditor: `depth_counter_audit`. Date: 2026-10-19.

Reviewed the complete active draft `anchored-compression.md`, Sections 1--6.
Reviewed draft SHA-256: `ea896304e0366da97194b7e7dcf3927506173953f9608c6fcd7fa48a4161dcfe`.

**Verdict: the finite-representation theorem and its proof pass independent mathematical reconstruction.** No mathematical correction requested. The separate VC theorem and resulting posterior-learning application are outside this record; those require their own check. This is not Lean verification.

## 1. Joint greedy anchors

The increment in projected KL on adjoining one query is exactly its conditional KL under the original reference and controlled laws. Each projected KL is monotone under enlarging the anchor set, even though individual conditional query KLs can increase or decrease. Rechecking after each addition is therefore essential and is explicitly done.

For the readout, if its current projection misses one query by more than `t`, adding that query increases squared projected Hilbert norm by more than `t^2`, because every original terminal feature vector has norm at most one. Both potentials are monotone under every anchor addition. The combined potential has increments exceeding `delta` and total bound `sum D_j + (delta/t^2) 2r`. This proves the anchor count and simultaneous termination guarantees. An already selected coordinate cannot trigger either test.

## 2. Anchored Gaussian geometry

With a fixed anchor Gram, the Gaussian regression coefficient vector in whitened anchor coordinates and the nonnegative residual standard deviation give exactly the displayed per-query conditional coupling cost. The Euclidean distance between these pairs proves the pseudometric triangle inequality. Gaussian anchor conditioning is well-defined on its covariance range when singular.

The second-moment lemma is valid for noncentered controlled feature laws: for each query the joint uncentered second-moment block of the common anchors and two query coordinates is positive semidefinite. Gaussianizing that block supplies a feasible common-anchor Gaussian coupling, so its difference second moment upper-bounds the metric. Different queries may use different extensions; no joint query-query coupling is claimed or needed.

## 3. Removing non-anchor dependence of the controls

The anchor-marginal likelihood ratio defines a law on the original full Gaussian support, with exactly the original controlled anchor marginal and KL equal to projected anchor KL. The average conditional query KL in the greedy criterion is the one appearing in the scalar Gaussian transport inequality. Conditional Gaussian variance is constant in the anchor values and is at most the original diagonal. Thus the injection bound is at most `sqrt(2 delta)` after the first layer and at most `2 sqrt(delta)` at the first layer. Conditional transport can be chosen measurably by scalar quantile coupling. Zero conditional variance forces the same deterministic query under finite KL and causes no exception.

## 4. Propagating an anchor-measurable control

For two references with equal anchor covariance, use one common Gaussian anchor vector and an optimal shared scalar residual at a given query. The same anchor-only likelihood ratio normalizes under both references and gives exactly the intended full-field marginal law in both cases. Its joint KL is the projected anchor KL. Whitening the finite Gaussian coupling on its support and applying Gaussian quadratic transport gives the factor `1+sqrt(2D_T)` for the scalar difference. Applying tanh and then the anchored second-moment lemma proves the transition inequality.

The law being propagated is independent of the chosen query, even though the coupling is query-specific. This is the point that prevents the full-covariance rank obstruction from entering the argument.

## 5. Importance quadrature and exact correction

The whitened anchor vector satisfies `E aa^T=I_s`. Sampling with density `(1+||a||^2)/(s+1)` makes both the whitened anchor vector and each weighted query coordinate bounded by `sqrt(s+1)`, independent of the smallest positive anchor eigenvalue. Entrywise Hoeffding with thresholds `eta/s` for the Gram, `eta/sqrt(s)` for anchor-query correlations, and `eta` for query diagonals gives the stated sample size after the finite union bound. The `s=0` case reduces to diagonal estimates.

With `M=E^T E`, the proposed correction satisfies the exact identities

`B E=E M^{-1}`, and `E^T B E=I_s`.

It has eigenvalues `1/lambda` on a singular direction whose Gram eigenvalue is `lambda`, and eigenvalue one on the orthogonal complement. Thus it is positive definite with norm below two. Writing the sampled anchor matrix as `E C` gives exact anchor covariance `C^T C` after correction. In whitened anchor coordinates the corrected query cross vector is exactly `M^{-1} vhat_x`.

Since `||v_x||<=1`, the stated `4 eta` cross-vector error is conservative. The diagonal correction term is bounded by `||M^{-2}-M^{-1}|| ||vhat_x||^2`, which is below the stated allowance. The `10 eta` diagonal and `26 eta` conditional-variance errors are conservative. The square-root inequality for nonnegative residual variances then yields `d_T^2<=16 eta^2+26 eta<=28 eta<36 eta`. No condition-number factor remains in the number of sampled neurons.

## 6. Physical finite-network realization

Keep the actual neuron outputs as ordinary bounded tanh values `h_i(x)`. If `R` is the diagonal matrix with entries `(n p_i)^(-1/2)`, their stored effective kernel is `h(x)^T R B R h(y)`. The next incoming Gaussian coefficient vector can be sampled with covariance `R B R`; tilting its pushforward by the anchor-only likelihood and then by the next quadrature importance density gives the required finite incoming rows. All these sampled coefficients are finite almost surely. No additional nonlinearity or explicit internal bias is introduced.

The corrected effective covariance can have non-anchor diagonal entries greater than one. This does not invalidate any estimate: the original-reference Rao--Blackwell error uses original diagonals, the propagation estimate is independent of diagonal size, and each subsequent quadrature law consists of bounded tanh activations before correction. Exact anchor blocks remain those of the original path throughout.

At the last layer the final covariance factor is absorbed into a linear readout. For the projected original readout, its anchor coefficient vector has squared anchor-Gram norm at most `2r`; exact equality of the anchor Gram then bounds the output difference by `sqrt(2r) d_T`, without an l1 bound on those coefficients. Thus ill-conditioned anchor coordinates affect finite weight sizes but not approximation error or neuron count.

The error recurrence, its product bound, and the chosen values of `t`, `delta`, and `eta` give output error at most `1/16+1/32`, strictly below `1/4`. The anchor count and quadrature sample count are fixed polynomials in `d,H,A` times `exp(C sum sqrt(D_j))`. Padding layers with zero-output neurons preserves the represented function and weighted depth.

## Scope

The result gives finite width and arbitrary finite real weights at the original depth. It does not establish a product-Frobenius bound, a bound on numerical weight size, or polynomial precision. A learning consequence requires an appropriate uniform VC bound for the actual finite tanh architecture; it cannot be inferred from a finite-description claim that the proof does not make.

## Final TeX audit

Independently read the complete polished source `source/critical-anchored-compression.tex`, SHA-256 `2ba18dca29258d012eacd3b8974a3ebbfb6ea6e5788a1a709785a62631f0320d`. **All final statements and proofs pass.** The source preserves the reviewed singular-covariance handling, simultaneous anchor conditions, physical architecture, and exact correction identities.

The explicit width calculation checks: `delta^-1 <= C H^2 A_0 exp(2 sqrt(2) S)`, hence the number of anchors is at most `C H^2 A_0^2 exp(2 sqrt(2) S)`. Substitution into the quadrature bound gives `C H^12 A_0^10 exp(12 sqrt(2) S)` times the displayed logarithmic factor. Using `S<=sqrt(H A_0)` bounds that factor by a fixed polynomial of degree at most one in `d,H,A_0` after enlarging constants. Thus degree 30 and exponential coefficient 20 are conservative universal choices.

The general theorem does not require an original output margin for its approximation conclusion; its Hilbert projection proof remains valid when `r=0` or the anchor set is empty. The original margin is used only for classification and the near-baseline entropy refinement. The exact error is at most `3/32`, leaving margin at least `13/32` from an original `1/2` margin.

The infimum-rate corollary does not assume a minimizing path exists. A feasible path within `1/L` of the infimum changes the near-baseline factor by at most a universal multiplier, since `sqrt(L epsilon+1)<=sqrt(L epsilon)+1`. Its total action prefactor is polynomially controlled by `1+J_L(f)`.
