# Independent audit: supercritical scalar/pair and spectral occupation

25 October 2026. This is an adversarial conventional mathematical audit, not a Lean verification. Scope: the deterministic occupation and local transport inputs for the proposed finite-width theorem at fixed `t>1`. It does not settle the original `0<t<=1` problem, or by itself prove a posterior sample lower bound.

## Result

**Pass for the stated occupation and local Bures claims, including their empirical use with `zeta(v)=v^(1/4)+v`.** I found no substantive error in the two source arguments after checking the calculations below. The finite-width application must use the separate uniform Gaussian-array events, not infer empirical entropy bounds from the atomic empirical law.

Audited sources:

- `supercritical-scalar-pair-occupation.md`;
- Sections 2–6 of `supercritical-turnpike.md`;
- the explicit local geodesic calculation in `supercritical-empirical-matrix-quality.md`;
- the interface (not the entire VC proof) of `supercritical-empirical-scalar-pair-quality.md`.

## Simultaneous scalar and pair bounds

There is no hidden factor equal to the number of inputs or pairs. For the scalar potential, the free drift map `v -> v-c min(v,1)` is increasing after reducing `c`; hence taking a maximum over input coordinates preserves the same drift and the same one-step error. Initially the maximum scalar potential is `O_t(1)`.

For pairs, the normalized Hermite estimate gives

`|c_free| <= lambda |c|+(1-lambda)|c|^3`.

For `|c|>=1/2`, its gap from one grows by at least `1+(3/4)(1-lambda)`. If a pair is below `1/2`, its new logarithmic gap potential is at most `log 2`, whereas the maximum-pair potential being charged is at least `log 4`. These two cases give a uniform decrement of the maximum over all pairs. Initially that maximum is at most `log((d+1)/2)` (with the stated separate `d=1` convention).

The two-feature fourth-moment proof handles both degeneracies correctly. The divided-difference basis `(f_v,h_(v,w))` has uniformly nonsingular Gaussian `L2` Gram matrix: its Taylor coefficients at orders one and three are `(1,-v/3)` and `(0,-1/3)`. The additional angular term is controlled from below by the conditional first Hermite coefficient in the independent Gaussian coordinate. Combining that lower bound with the triangle estimate for the collinear part proves the stated norm equivalence, rather than merely assuming absence of cancellation.

The small-entropy pair estimate requires only a negative exponential moment of a squared feature combination; its proof correctly avoids a positive exponential moment of the limiting cubic feature.

The large-entropy strip proof is uniform in tiny entering variances. The crucial cancellation is `sigma/sqrt(q'_x) >= sqrt(delta_in/Gain(D))`. On a Gaussian cutoff the tanh derivative is bounded below exponentially in the cutoff radius. With `R=sqrt(log(1/z))`, both the Gaussian tail and the strip-width term are bounded by a constant times `sqrt(z)`. Markov and binary relative entropy then give a logarithmic gap loss `O_t(D+1)`, which is `O_t(D)` above a fixed threshold. This excludes an uncharged doubly exponential collapse of the pair gap.

For the empirical application, replace small-entropy loss by `C v^(1/4)`, and large-entropy loss by `Cv`. A large-quality step may forgo the free drift; its count is bounded by `sum v/v_*`. Thus the same potential proof yields

`# scalar/pair-bad entering states <= C_t[1+log(d+1)+sum zeta(v_j)]`.

## Spectral occupation

For a correlation matrix `C`,

`sum_(j != i) C_ij^2 = (C^2)_ii-1 <= lambda_max(C)-1 = X`.

The inequality is valid even when `C` is singular, since `C^2 <= lambda_max(C) C` in PSD order. When all off-diagonal entries have absolute value at most `rho<1`, the higher odd Hermite terms have row sums bounded by `rho(1-r_off+epsilon)X`. Allowing different diagonal variances only changes the Hermite coefficients; Cauchy–Schwarz bounds their sum uniformly. Consequently

`X_free <= r X`,  `Y_free <= aY+cX`,

with `r,a<1`, follow as claimed. An upper-eigenvalue estimate alone would not control the lower eigenvalue; the source correctly tracks `Y=1-lambda_min(C)` separately.

For `X`, the potential `log(1+X/epsilon_X)` has a constant decrement whenever `X>=epsilon_X`, up to `C zeta(v)`. At exceptional steps the coarse normalized covariance bound gives an upward increment at most `C(1+v)`. The already-bounded number of scalar/pair exceptions pays for the additive constant. Initial potential is `O(log m)=O(d)`.

For `Y`, put `y0=c epsilon_X/(1-a)` and choose `epsilon_X` so that `y0<=epsilon_Y/4`. On the remaining good steps,

`(Y'-y0)_+ <= a(Y-y0)_+ + C zeta(v)`.

If `Y>=epsilon_Y`, the drift is bounded below by a fixed positive constant. At any exceptional step this bounded potential increases by at most one. Summation proves the claimed second count. Combined with diagonal control, all but

`C_t[d+sum zeta(v_j)]`

entering states lie in the required white operator neighborhood. No union bound over inputs is used anywhere in this occupation argument.

## Local Bures contraction

The free covariance derivative at `q_* I` has diagonal eigenvalue `t^2 F'(t^2 q_*)<1` and off-diagonal eigenvalue `t^2(E sech^2(t sqrt(q_*) Z))^2<1`. The latter is the first normalized Hermite weight, strictly below one because tanh is nonlinear. Near the equilibrium, Price differentiation gives cross terms bounded by `C|Q_ij|`; their Frobenius operator norm is at most `C ||Q-q_*I||op`. Thus the dimension-independent tangent contraction is valid.

For the controlled/empirical derivative, the Frobenius-dual integrand is bounded by `2t ||M h|| ||E G||`. Gaussian Poincare controls the first factor's second moment by `C ||M||_F^2`; Gaussian concentration controls its tails with the same dimension-independent scale. The second factor has scale `||E||_F`. Hence the product is subexponential with scale `C ||M||_F ||E||_F`; there is no hidden `sqrt(m)` loss.

The explicit horizontal-geodesic argument in the empirical note preserves the necessary `1+O(epsilon)` metric factor. Its covariance tangent bound, the output minimum-eigenvalue bound, and the Sylvester lift give gain `r0+C epsilon+C eta(v)`. A crude fixed norm-equivalence factor could destroy contraction, but the written proof does not incur it.

## Application requirements

1. The quality events must hold uniformly over all orientations and be exactly rotation invariant, as specified in the empirical notes. This lets past-adapted optimal factor rotations preserve both Gaussian marginals and the independent quality-budget variables.
2. Use the empirical per-layer inequalities directly. An empirical atomic measure has infinite relative entropy against a Gaussian and cannot be substituted into the entropy-controlled theorem literally.
3. Apply the occupation count separately to both coupled covariance paths, then take the union of their exceptional layer sets. This costs only a constant factor, not a factor `m`.
4. The count concerns entering states, and local gains additionally require the current quality below a fixed threshold. Charge the remaining current-quality exceptions by `sum v/v_*`.
5. This audit does not replace the separate finite-N all-label mass lower bound or strict-orthant/readout comparison. Those are essential for the posterior conclusion.
