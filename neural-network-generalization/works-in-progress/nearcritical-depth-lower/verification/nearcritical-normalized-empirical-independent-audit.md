# Independent audit of normalized empirical tanh transport

25 October 2026. Auditor: finite-N audit agent. Scratch research record, not a Lean verification.

**Verdict: PASS.** I checked the complete `nearcritical-normalized-empirical-quality.md`, including its new Sections 6–7, against the population metric interface in `nearcritical-normalized-coupling.md`. I found no unresolved mathematical gap in the uniform empirical estimates or their transfer to the global and local normalized Bures couplings. This does not by itself certify the assembled posterior theorem.

Audited SHA256:

- empirical quality: `bb3c4c8de52bcb32f94569239d803a8fa221f710aaa2c5819fabbcb9d4a1e703`;
- population coupling: `beb22e4c02400ad6e9f20465bc6198e3a6a0d92b4b1dc95f6aa4765bb5127228`.

## Scalar classes and the global transfer

The normalized activation `phi_q` and its logarithmic scale derivative extend smoothly to `q=0`. The useful envelopes are genuinely linear in one-dimensional Gaussian projections. Products therefore have a uniform subexponential norm; this argument does not use a positive moment-generating function for a squared cubic Gaussian secant.

The compact parameter nets have dimension `O(m)` for scalar derivative products. On the Gaussian norm cutoff their parameter derivatives have fixed polynomial envelopes; logarithmic covering number `O(m log(eN))` is enough. The independent array quality floor `C m^4 log(eN)/N` dominates this cost.

The spherical/logarithmic path has length at most a constant times the endpoint geometric distance, including antipodal directions when `m>=2`. Integrating derivative-product *errors* twice proves the squared-secant error estimate. The resulting constant multiplies only the empirical error, not the population metric gain. This is the right way to avoid a constant expansion at every nearcritical layer.

I checked the empirical normalization identity directly:

`||a/s-a'/s'||_N^2 = (||a-a'||_N^2-(s-s')^2)/(s s')`.

Its subtraction term can safely be discarded for an upper bound. The derivative-product estimate also bounds the difference of empirical log normalizers. Combining these with the exact population row-coupling estimate gives the asserted joint global gain `1+C q_max^2+C sqrt(v)`.

For large quality, uniform lower empirical feature norm and the empirical Gaussian covariance bound control derivatives of both normalization and logarithmic norm by `exp(Cv)`. The entire path is indexed by the uniform events. No inverse power of the variance or of epsilon enters.

## Matrix derivative quality

The key Frobenius-dual random variable is

`Y=2 (M h)^T [diag(phi'_q) E G + diag(r) R_q(BG)]`,

where `||M||_F=1` and `||B||_op` is bounded on the fixed white correlation ball.

For the angular term, the Cauchy bound uses `||M h|| ||E G||`. The first factor has second moment `O(||M||_F^2)` by Gaussian Poincare, since every coordinate of `h` is odd and its Jacobian is `diag(phi'_q)B`. Its norm is Gaussian-Lipschitz with constant `O(||M||_op)`. Thus its uncentered subGaussian norm is `O(||M||_F)`. The corresponding statement for `EG` is standard.

For the radial term, `R_q` is odd and globally Lipschitz uniformly in `q`, including zero. In its derivative the apparent unbounded terms reduce to bounded functions of the form `x sech^2(x)` and `x sech^2(x) tanh(x)`. Consequently `||diag(r)R_q(BG)||` has uncentered subGaussian norm `O(||r||_2)`. This proves a dimension-free subexponential norm for `Y` proportional to `||E||_F+||r||_2`.

The matrix/tangent net has dimension `O(m^2)`, still dominated by the chosen quality floor. Taking a Frobenius dual supremum is essential; taking entrywise errors and summing would introduce a dimension loss that this proof avoids.

## Local normalization and coupling

The path `C_s=(1-s)C+sC'`, with canonical roots `B_s=sqrt(C_s)`, stays in the fixed white correlation ball and has unit row norms. The square-root derivative estimate controls its Frobenius length by a constant times the input Bures distance. This constant again multiplies only the empirical error.

Because the population output covariance has diagonal one along this path, differentiation of empirical diagonal normalization involves `diag(dot A)` rather than an uncontrolled population diagonal derivative. The remaining normalization terms contain a factor `O(sqrt(v))`. The population covariance derivative has a dimension-free Frobenius bound by the same dual calculation. Therefore the normalized error-map secant and the log-diagonal error secant are both `O(sqrt(v))` times the joint input distance.

Together with the fixed-SPD-ball common-additive-error Bures comparison, this gives local gain `1-c epsilon^2+C sqrt(v)`. Taking `v<=c' epsilon^4` provides strict local contraction. A measurable switch between canonical-root local coupling and optimal-factor global coupling preserves each exact Gaussian transition marginal: all array quality classes are rotation invariant and indexed uniformly over the possible factors.

## Scope and implementation conventions

All small-quality bounds require the fixed cutoff `v_0` to be chosen sufficiently small for empirical normalizers and the SPD comparison. All-quality events can be combined by monotone envelopes, or by the same nested-event construction used for the existing scalar/pair quality. Their union costs only a fixed factor in the exponential tail.

The note proves an empirical coupling interface. Scalar/spectral occupation, the cheap all-label mass witness, total quality-budget control, and the final readout rare-event comparison remain separate inputs to any full posterior-flattening theorem. The entire discussion has `t=1+epsilon>1` and does not settle the canonical `t<=1` problem.
