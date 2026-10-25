# The nearcritical supercritical lower bound, and why it does not settle the canonical prior

25 October 2026. Research note. This studies the gap between fixed `t>1` and the canonical `0<t<=1` prior. The free-kernel and reparametrization statements below are elementary proved obstructions to transferring the chaos argument. Section 5 gives a quantified, deliberately inefficient extension of the finite-width lower bound. An independent audit of its uniform constants passed on 25 October 2026. Nothing here proves an exponential-depth lower bound for exact `t<=1`.

## 1. Free covariance memory at and below the critical prefactor

Put

`F(u)=E tanh^2(sqrt(u) Z)`,

and let `w1(u)` be the first squared Hermite coefficient of `tanh(sqrt(u)Z)/sqrt(F(u))`. Gaussian integration by parts gives

`w1(u)=u [E sech^2(sqrt(u)Z)]^2/F(u)`.

As `u` tends to zero,

`F(u)=u-2u^2+(17/3)u^3+O(u^4)`,

`w1(u)=1-(2/3)u^2+O(u^3)`.

On every fixed compact interval `0<=u<=U`, `w1(u)>0`, with the value one at zero, and therefore

`w1(u)>=exp(-C_U u^2)`.                                      (1)

For `0<q<=2`, continuity and the expansion at zero give a constant `c>0` such that

`F(q)<=q-c q^2`.                                             (2)

Consider any sequence of layerwise prefactors `0<t_j<=1`, with common diagonal variances

`q_j=F(t_j^2 q_(j-1))`,    `0<q_0<=2`.

Comparison with the `t_j=1` recursion and (2) show

`q_j<=C/(j+1)`,    `sum_j q_j^2<=C`.                          (3)

For two equal-variance Gaussian coordinates, the normalized tanh covariance map is

`c -> sum_(k odd) w_k(u)c^k`,    `w_k(u)>=0`, `sum w_k(u)=1`.

Hence it preserves the sign of `c`, never increases `|c|`, and is at least `w1(u)|c|` in absolute value. Equations (1)–(3) prove a uniform, depth-independent constant `a>0` with

`a |c_0| <= |c_H| <= |c_0|`                                 (4)

for every depth and every sequence `t_j<=1`. This applies to the free augmented-cube covariance and all its sign conjugates, which have equal diagonals.

Thus the canonical free covariance chain does **not** forget its input correlations. Its unnormalized entries shrink because its variances shrink, but its normalized correlations retain a fixed fraction of their initial values. At exact criticality the variance is asymptotic to `1/(2j)`; below criticality it shrinks still faster.

For a concrete metric check, compare the two-point covariances

`Q_+=q [[1,c],[c,1]]`,    `Q_-=q [[1,-c],[-c,1]]`.

They commute, and

`d_B(Q_+,Q_-)^2=4q[1-sqrt(1-c^2)]>=2q c^2`.                 (5)

Consequently their Bures distance divided by `sqrt(q)` stays bounded below along the free canonical recursion whenever the initial correlation is nonzero. The readout action required for a fixed output margin has scale at least `1/q`; multiplying its square root by (5) cancels the shrinking hidden variance. In particular, the usual Bures-distance readout-error estimate cannot tend to zero merely because `q_H` tends to zero. This is an obstruction to this proof route, not a lower bound on the actual posterior error.

## 2. A precise nearcritical timescale

Let `t=1+epsilon`, with `0<epsilon<=epsilon0` for a sufficiently small fixed constant. The positive variance fixed point satisfies

`q_*=epsilon+O(epsilon^2)`.

At the white fixed point, the two free covariance derivative eigenvalues obey

`r_diag=1-2epsilon+O(epsilon^2)`,

`r_off=1-(2/3)epsilon^2+O(epsilon^3)`.                       (6)

The second identity is especially important: the slow mode is off-diagonal correlation, and its gap is quadratic rather than linear in the distance above criticality.

The scalar recursion from `q_0<=2` satisfies uniformly

`q_j<=C[epsilon+1/(j+1)]`.                                  (7)

To prove this, (2), with the argument `t^2q`, implies `T_t(q)<=q-cq^2` whenever `q>=A epsilon`, for large fixed `A`. The interval below `A epsilon` is invariant by monotonicity. Before first reaching that interval, the reciprocal-variance argument gives `O(1/j)` decay.

Equations (1) and (7) then give the free memory lower bound

`|c_H| >= |c_0| exp[-C(1+epsilon^2 H)]`.                    (8)

Thus `epsilon^2 H` is the effective free decorrelation time. In the other direction, starting from augmented-cube diagonals `q_0=(d+1)/d>=q_*`, the first Hermite weight is at most `1-c epsilon^2` throughout the recursion. The usual cubic Hermite comparison first increases a near-unit pair gap and then contracts correlations. Scalar convergence has rate at most `1-c epsilon`. It follows that the free covariance becomes white in Frobenius norm to absolute tolerance `c epsilon^3` after

`h0 <= C epsilon^-2 [d+1+log(1/epsilon)]`                  (9)

layers. The logarithm of the number of coordinates is `d log 2`; no exponential dimension factor occurs in the mixing time, although exponentially many neurons will be used for concentration.

Here is one justification of the uniform scalar contraction used in (9). On the range `u=t^2q>=t^2q_*`, the expansion `F'(u)=1-4u+O(u^2)` gives `t^2F'(u)<=1-c epsilon` for all sufficiently small `u`. For the rest of a fixed compact interval, strict decrease of `F(u)/u` gives `F'(u)<F(u)/u<1`, with a uniform margin away from zero. Joining the two intervals proves the bound. The normalized nonlinear Hermite mass satisfies `1-w1(u)>=c u^2` on the same compact interval, proving the correlation claim.

## 3. Reparametrization does not preserve the original model

Writing each supercritical weight as `W_j=t U_j`, with `U_j` drawn at canonical critical variance, turns tanh into `psi(u)=tanh(tu)`. This activation has slope `t>1` at zero and Lipschitz constant `t`, precisely the expansion used in the supercritical proof.

A layerwise hidden-variable change `h_j=a_j h'_j` gives activations

`psi_j(u)=a_j^-1 tanh(t a_(j-1) u)`,

whose slopes at zero are `t a_(j-1)/a_j`. Requiring every transformed activation to be one-Lipschitz forces

`a_j>=t a_(j-1)`,    hence `a_H>=t^H a_0`.

The readout then acquires this exponentially growing factor, or equivalently the required output margin shrinks by that factor. It is therefore not a reduction to the same canonical Gaussian prior with the same fixed margin and bounded-resource teacher convention. A common zero-preserving one-Lipschitz activation cannot absorb the supercritical gain for free.

### A genuine corollary for a different, natural activation

There is nevertheless a useful exact transfer if one explicitly changes the activation. The fixed-supercritical proof permits any fixed positive readout prefactor `b`, independently of the hidden prefactor `t>1`: replace readout variance `t^2/N^2` by `b^2/N^2`. The covariance dynamics and occupation proof are unchanged. The all-label readout KL becomes at most `N/(b^2 p_t)`; the readout coupling error becomes `b sqrt(2 B_read) delta`; all other changes are constants. Therefore the same finite-width exponential-depth lower bound holds.

Take canonical critical weight variances `1/d,1/N,1/N^2`, but activation

`phi_a(u)=tanh(a u)`,    fixed `a>1`.

Its hidden-feature law is exactly that of the supercritical tanh model with hidden prefactor `t=a` and readout prefactor `b=1`. Thus the lower bound applies: for `H=Theta_a(d)` and `N=exp(Theta_a(d))`, even a constant target needs `exp(Omega_a(H))` examples under the confidence criterion. This is a natural scaled tanh, with derivative and Lipschitz constant `a>1`; the target still has a width-two, coefficient-at-most-one implementation.

This is a counterexample to a universal polynomial-depth theorem covering all fixed-Lipschitz activations at canonical critical weight scaling without accounting for the activation's gain. It is **not** a counterexample for the exact tanh activation of slope one, or for a class required to be one-Lipschitz. More generally, a constant hidden prior prefactor `t0` and activation `tanh(a u)` have effective gain `a t0`; the supercritical theorem applies when `a t0>1`, with readout prefactor `t0`.

## 4. Conditioning the critical Gaussian into an isotropic excited phase is expensive

At a white entering covariance `q I_m`, a critical Gaussian preactivation row has independent coordinates `N(0,q)`. If a changed row law maintains each output second moment at `q`, instead of its free value `F(q)=q-2q^2+O(q^3)`, then for sufficiently small `q`

`KL(changed row law || N(0,q I_m)) >= c m q^2`.              (10)

Indeed, set `W=tanh^2(sqrt(q)Z)/q`. Its Gaussian mean is `1-2q+O(q^2)`, while the changed-law mean must be one. The variables `W` have uniformly bounded centered exponential moments near zero since `W<=Z^2`. The entropy dual inequality therefore gives marginal KL at least `c q^2`. Relative entropy to a product reference is at least the sum of the marginal relative entropies, proving (10). This permits arbitrary non-Gaussian changed row laws and arbitrary correlations between their coordinates.

For a Gaussian implementation the same cost is explicit. To make `F(sq)=q` one needs `s=1+2q+O(q^2)`, and the Gaussian row entropy is

`(m/2)[s-1-log s]=m q^2+O(m q^3)`.

In a stationary isotropic phase with `q` of order `epsilon`, free decorrelation requires order `epsilon^-2 d` layers. Maintaining that phase at canonical `t=1` consequently costs order `m d` per-row total entropy, rather than the order `d` budget used by the supercritical all-label comparison. With `m=2^d`, that distinction is decisive.

This is not a theorem excluding every possible conditional-excitation strategy. A non-isotropic, label-dependent or strongly varying-variance path can evade the assumptions of (10). It does show why simply conditioning the critical prior into the supercritical white phase does not transfer the cheap-action proof.

## 5. A conservative quantified finite-width corollary approaching criticality

The following statement follows by making the constants in the fixed-supercritical finite-width proof uniform as described below. An independent conventional mathematical audit of the uniform constants passed; this is not a Lean-verified theorem.

There exist absolute constants `epsilon0,A,K,c>0` such that, for every `0<epsilon<=epsilon0` and every integer `d>=1`, put

`D=d+1+log(1/epsilon)`,

`H=ceil(K epsilon^-50 D)`,

`N=ceil((H+1)^2 exp(A epsilon^-2 D))`,

and use the actual finite Gaussian tanh prior with prefactor `t=1+epsilon`, H hidden layers, and the usual first/hidden/readout variances `t^2/d,t^2/N,t^2/N^2`. If

`w_f=Pr{f(x)z(x)>1/2 for all x}`,

then

`max_f w_f/min_f w_f <= 1+exp(-cD)`.                       (11)

In particular the confidence criterion at every unseen input is below `2/3`, after increasing constants if necessary. More than half of the full cube must be observed to achieve confidence failure below one half, even for the constant target with a width-two, coefficient-at-most-one implementation. The exponent 50 is bookkeeping slack, not a predicted optimal depth scale.

### Uniform ingredients

All global scalar, two-feature, matrix, VC and Gaussian-array estimates can have absolute constants for `1<t<=1+epsilon0`, because their variance parameters lie in one fixed compact interval. For the local estimates rescale `Q=q_* R` and use

`phi_epsilon(u)=tanh(t sqrt(q_*)u)/sqrt(q_*)`.

This family is odd, has uniformly bounded Lipschitz constant, and has uniformly bounded second and third derivatives. Its linear growth gives polynomial Gaussian envelopes with absolute constants. The same metric-net proof applies; a cubic rather than quadratic pointwise envelope does not change the `O(m^2 log N)` entropy threshold. Local centered derivative variables remain uniformly subexponential.

Equation (6) yields free Frobenius derivative gain at most `1-c epsilon^2`. On a relative white operator ball

`||R-I||op <= c0 epsilon^2`,

the free derivative changes by at most `C c0 epsilon^2`, and the Bures metric comparison changes by a factor `1+O(c0 epsilon^2)`. Uniform empirical derivative and covariance errors are `C(sqrt(v)+v)`. Thus, choosing `c0` small, the local empirical Bures gain is at most `1-c epsilon^2` whenever `v<=c epsilon^4`.

### Uniform occupation bookkeeping

Use `zeta(v)=v^(1/4)+v` and the same rotation-invariant quality statistic with threshold

`tau=C m^4 log(eN)/N`,    `m=2^d`.

The following deliberately loose powers suffice:

- Scalar free logarithmic drift is `c epsilon min(V,1)`. A relative variance neighborhood of width `c epsilon^2` therefore has at most `C epsilon^-3[D+sum zeta]` bad entering states.
- Pair-gap drift on variance-good steps is `c epsilon^2`. Adding variance-bad steps leaves the scalar/pair count at most the same `C epsilon^-3[D+sum zeta]`.
- For the upper spectral potential choose threshold `epsilon_X=c epsilon^4`. Its free logarithmic drift is `c epsilon^2`; its perturbation term is at most `C epsilon^-4 zeta`. Initial potential is `O(D)`. Exceptional scalar/pair steps each add `C(1+v)`. This gives at most `C epsilon^-6[D+sum zeta]` upper-spectral or previously exceptional states.
- Choose lower spectral threshold `epsilon_Y=c epsilon^2`. The first-Hermite coefficient gap is at least `c epsilon^2`; choosing the constant in `epsilon_X` sufficiently small ensures the offset `y0=c1 epsilon_X/(1-b)<=epsilon_Y/4`. The lower-eigenvalue positive-part potential has decrement `c epsilon^4` whenever bad. Its per-exception increase is at most one. Its count is therefore at most `C epsilon^-10[D+sum zeta]`.
- Current layers with quality exceeding `c epsilon^4` add at most `C epsilon^-4 sum v`, already absorbed.

Applying these bounds to both coupled sign-gauged paths gives

`d_B(Q_H,Q'_H) <= C sqrt(m) exp[-c epsilon^2 H + C epsilon^-10(D+sum zeta(v_j))]`. (12)

The global gain used at exceptional steps has uniform constants for `t<=1+epsilon0`. This is the direct empirical argument, not an entropy assertion about an atomic sample law.

### Uniform all-label mass and probability budget

The finite-width all-label witness has

`w_f >= exp(-C N D)`                                    (13)

with absolute `C`, provided

`H>=C epsilon^-2 D`,    `N>=exp(C epsilon^-2 D) log(H+2)`.

To see the uniformity, the free prefix whitening time is (9), and its crude entrywise error amplification is at most `12^h0`. The required absolute white radius can be `c epsilon^3`; all these concentration costs are absorbed in the displayed width. The rank-one seed has size at least `c epsilon/m`. Its amplification factors, per-step Gaussian KL, and final common-component threshold can all be chosen uniformly for `1<t<=1+epsilon0`. It therefore needs only `O(d+log(1/epsilon))=O(D)` controlled layers. Its smallest residual eigenvalue is at least `exp(-CD)`. The exact empirical-span covariance correction and the final readout shift then cost `O(ND)` entropy, with absolute constants. The free prefix itself costs zero entropy.

The independent quality budget gives, for any desired fixed `M`,

`Pr{sum v_j > C_M D} <= exp(-M N D)`,

once `H tau<=D`; the chosen width has this property. Its Chernoff prefactor `exp(CH)` is harmless because `N>H^2`. On the good event,

`sum zeta(v_j)<=C[H^(3/4)D^(1/4)+D]`.

At `H=K epsilon^-50 D`, the negative exponent in (12) has order `K epsilon^-48 D`, while the leading adverse term has order `K^(3/4) epsilon^-47.5 D`. Choose K sufficiently large after A. Thus (12) is at most

`delta <= exp(-c epsilon^2 H)`.

This is much smaller than `N^-1 D^-3/2`; indeed `log N=O(A epsilon^-2 D+log H)`. Choose the readout cutoff proportional to D. Its tail and the bad-quality probability are smaller than (13) by any prescribed exponential factor. The exact readout dilation inequality then yields (11), just as in the fixed-prefactor proof. No limit exchange or union bound over truth tables is used.

## 6. Interpretation and remaining gap

The quantified corollary allows `t` to approach one along a sequence of growing problems while retaining a strong lower bound. For example, choosing `epsilon=d^-a` gives depth polynomial in d and sample lower bound `2^Omega(d)`, hence a stretched-exponential depth lower bound. These are still priors with `t>1`; under `t=N^((1-gamma)/2)` they have `gamma<1`, approaching one from below.

Neither this limiting family nor activation rescaling reaches exact `t=1`. The canonical free-correlation memory theorem (4), and the entropy cost (10) of sustaining an isotropic positive-variance phase, explain why the proof has a genuine boundary there. The open canonical Boolean-depth question remains unchanged.

## Review record

The independent finite-N audit checked the uniform local concentration after rescaling, the epsilon^-3 / epsilon^-6 / epsilon^-10 occupation powers, the O(ND) all-label witness with an epsilon^-2 free-prefix concentration cost, and the final parameter hierarchy. It passed on 25 October 2026. This remains a conventional proof, not a proof-assistant verification.
