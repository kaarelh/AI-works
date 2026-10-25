# Reusing a critical target program uniformly at every subcritical variance

Supporting proof, 24 October 2026; curated 25 October 2026. Conventionally reviewed, not Lean verified. The current all-scale statements are in the companion `uniform-target-classes.pdf`; the package README gives the dependency map.

## Statement

Let a layered threshold teacher have depth `h`, width `C`, normalized gate margins at least one, and gate coefficient norms at most `B`. Write `H=L-1`,

`T=log(d+2)+h log(d+C+B+h+H+3)`.

For universal constants, if `H-h>=C_0 T`, then at every `N>=exp(C_1 T)` and every `0<t<=1` there is an `N`-independent upper budget

`Abar_t=H c_t+V_*+C_2[theta T+T^2/H]`,

where `theta=(t^{-2}-1)/2` and `c_t=(t^{-2}-1+2 log t)/2`, for which

`mu_{N,t}{ f(x)z_w(x)>1/2 for all Boolean x } >= exp(-N Abar_t)`.

Increasing constants absorbs the finite-width comparison slack `1/(t^2 H)`: it is at most a constant times `theta T+T^2/H`. The coefficient on `V_*` remains exactly one; this matters for the nearcritical capacity comparison.

The construction reuses the critical circuit prefix and critical scalar program from the current source. It does not require solving a new scalar Bellman problem at `t<1`.

## 1. Scalar change of Gaussian reference

Let `rho` be a physical scalar control law and write `m=E_rho Z^2`, with reference variance one. Then

`D(rho || N(0,t^2)) = D(rho || N(0,1)) + c_t + theta(m-1)`.

This follows directly from the Gaussian log density ratio. In the normalized-coordinate formulation, the physical scalar preactivation is `sqrt(v) Z`; its residual Gaussian term has variance `t^2 r`. Under the reference law `Z~N(0,t^2)`, the resulting row law is exactly the original Gaussian with variance `t^2/N`.

If `D=D(rho||N(0,1))`, Gaussian entropy duality gives

`(m-1)_+ <= C(sqrt(D)+D)`.

Indeed `D >= (m-1-log m)/2`; for `m>=1`, inversion gives the displayed bound. Consequently a critical scalar program with `sum sqrt(D_j)=O(T)` and `sum D_j=O(T)` incurs only `O(theta T)` additional cost beyond one `c_t` per scalar stage.

## 2. Monotonicity under smaller residual noise

Put `psi_r(z)=E tanh(z+sqrt(r) G)`. For `z>0`, `psi_r(z)` is nonnegative and nonincreasing in `r`. For `r>0`,

`partial_r psi_r(z)=(1/2) E tanh''(z+sqrt(r) G) <=0`.

To see the sign, pair the integral at positive and negative arguments. The function `tanh''(u)` is odd and negative for `u>0`, while the Gaussian density difference `phi_r(u-z)-phi_r(u+z)` is nonnegative for `u,z>0`. Continuity covers `r=0`. Oddness gives the absolute-value comparison for negative `z`.

Consider a critical Gaussian control with physical scalar variance `a` acting on an exact target component `v ff^T` and residual diagonal `r_crit`. Suppose the subcritical construction has the same `v` and residual `r<=r_crit`. Its preactivation is

`sqrt(a v) f Z + t sqrt(r) G`.

Its total postactivation variance is at most the critical total variance because `F(u)=E tanh^2(sqrt(u)Z)` is increasing and `av+t^2 r<=av+r_crit`. Its available conditional-mean component is at least the critical one by the monotonicity of `psi`. Therefore one may keep exactly the critical prescribed component and a residual no larger than the critical residual.

## 3. Exact score downgrade has zero entropy cost

Suppose the current conditional-mean score `b_0` has `E b_0^2=1` and correlation `E[b_0 h(x)]=sqrt(v_available) f(x)`. For any desired `0<v<=v_available`, let `xi` be an independent uniform sign and put

`b=sqrt(v/v_available) b_0 + sqrt(1-v/v_available) xi`.

Then `E b^2=1`, `E[b h(x)]=sqrt(v) f(x)`, and `|b|<=|b_0|+1`. Include the same independent auxiliary sign under both the reference and controlled laws. It contributes zero relative entropy and is later forgotten. The exact covariance decomposition using this score has residual diagonal `q-v`.

This applies to every deliberate component reduction in the critical program. In particular, by induction through all Gaussian cooling, holding, prescribed-growth, and purification stages, the subcritical program has exactly the prescribed critical component and residual at most its critical comparator. No variance inflation of the entire residual space is used.

## 4. The circuit seed and Gaussian stages

Use the same deterministic groups, group fractions, and mean shifts as the critical finite circuit prefix, with `a_seed=K T` and `eta=8 exp(4-a_seed)`. Keep the original variance `t^2/d` or `t^2/N` in every row. The prefix cost is its critical cost divided by `t^2`; thus

`E_prefix,t <= 1/(8L t^2)`.

All gate noise bounds remain valid since `t<=1`. The ideal diagonal satisfies `qbar_h(t)<=qbar_h(1)` by induction through the increasing free map `F(t^2 q)`, with the same deterministic group fractions. The target group supplies the same seed component `p_N in [p_h,2p_h]`; its actual ideal residual is at most the critical residual.

Choose the critical continuation and its stage lengths from the critical comparator `(p_N,qbar_h(1)-p_N)`. Apply sections 2 and 3 to its Gaussian stages at the actual variance `t`. Their physical scalar laws are unchanged. A Gaussian variance-`a` control has

`D_t(a)=D_1(a)+c_t+theta(a-1)`.

The critical square-root-entropy budget bounds the sum of these positive moment increments by `O(T)`. Cooling has `a=1` and therefore costs precisely `c_t` per stage in this comparison. Any unused layers are the same exact holding layers used by the critical construction. Purification leaves the prescribed component `p` and a residual no larger than the critical bound `O(delta L^{-4})`.

Here the entropy budget is applied to the **scalar entropy upper costs charged by the critical construction**, not to smaller vector relative entropies obtained after data processing. Those charged scalar costs obey the same critical potential and Bellman-suffix inequalities, and their total including the readout is at most `V_*+O(T^2/H)`. Thus the occupation argument bounds their square-root sum by `O(T)` as required for the scalar moment increments. Replacing these charged costs by the vector KL and then attempting to recover scalar moments would not be justified.

## 5. Reuse the final scalar path

Take the increasing nominal scalar path used by the critical proof, with nominal state `q_j` and physical preactivation law `eta_j`. Its relative normalized scalar law is `rho_j=eta_j/sqrt(q_j)`, whose second moment is `m_j=E eta_j^2/q_j`.

If the actual tracked component is `v_j`, use physical preactivation `sqrt(v_j/q_j) eta_j` and add the residual Gaussian with variance `t^2 r_j`. Thus the normalized scalar law is still exactly `rho_j`, independent of the actual `v_j`. The existing stable-lift proof applies verbatim with the smaller residual: residuals never increase, and

`v_{j+1}/q_{j+1} >= (1-delta_res)^2 min(1,v_j/q_j)`.

Here the purified `delta_res=O(delta L^{-4})` is the same upper bound as at criticality. Consequently the final readout retains the critical upper cost `V_*+O(T^2/H)` when evaluated at variance one. The final nominal scalar path, including its readout, costs at most three, so multiplication of the readout cost by `t^{-2}=1+2theta` adds only `O(theta)`.

The scalar law identity of section 1 gives additional hidden cost at most `c_t` per remaining stage plus `O(theta T)`, because `sum sqrt(D_1,j)=O(T)` and `sum D_1,j=O(T)`. These statements hold for arbitrarily large `theta`, not merely near one. The prefix's extra `2theta E_prefix,1` is also absorbed by `O(theta T)`. Since there are at most `H` hidden scalar/reference contributions, the total ideal cost is

`A_t <= H c_t+V_*+C(theta T+T^2/H)`.

## 6. Finite width remains polynomial

This is the part where a bound based on absolute subcritical entropies would be too crude. In the scalar-channel metric, the actual physical preactivation variance multiplier is `sqrt(max(t^2,m_j))`, at most `sqrt(max(1,m_j))`. Gaussian entropy duality therefore bounds it by the same `exp(sqrt(D_1,j))` as in the critical program. Hence total metric amplification is `exp(O(T))`, uniformly for every `0<t<=1`.

Every tracked component stays at least `exp(-C T)`, and the auxiliary-score downgrade increases the score bound by at most one. All scores are therefore bounded by `exp(C T)`. The finite circuit prefix has the same `exp(-C T)` seed-relative accuracy after choosing `K` sufficiently large; the usual gain/accuracy fixed point remains linear in `K` versus logarithmic in `K`.

Apply the finite scalar-channel concentration and change-of-measure proof with comparison slack `tau=1/(t^2 H)`. The normalized action obeys `t^2 A_t<=C(H+T+T^2/H)`, because `t^2 c_t<=1/2` and `t^2 theta<=1/2`. Choose the controlled success loss `kappa` as a sufficiently small fixed multiple of `1/[H(1+t^2 Abar_t)]`, with a deterministic uniform upper budget. This is bounded below by an inverse polynomial in `H,T`, independently of `t`, and makes the binary-KL multiplicative overhead `O(kappa A_t)` at most `tau/2`. The readout adjustment has the same bound. The remaining binary-entropy term is also at most `tau/2` at polynomial width, since `tau>=1/H`.

Thus all required moment accuracies are inverse-polynomial in `H` times `exp(-C T)`, independently of `t`. Since `T` already contains `log H`, a width `N>=exp(C T)` suffices uniformly for every `0<t<=1`. The readout noise variance is no larger than the critical one. The binary relative-entropy comparison adds `1/(t^2 H)=(1+2theta)/H`, which is absorbed by `C(theta T+T^2/H)`.

The ideal seed and program may depend on `N` through `p_N`, but all displayed upper budgets are independent of `N`, using `p_h<=p_N<=2p_h`. This gives the stated raw target-mass bound for every width beyond one uniform polynomial threshold at fixed teacher depth.

## Audit status

The scalar residual monotonicity, score downgrade, and final stable-lift reuse were independently checked by the critical-depth and complexity-barrier agents. The extension from a fixed lower bound on `t` to the full interval uses the normalized slack argument suggested by the critical-depth agent and independently checked here. The source critical finite-width circuit-prefix and scalar-channel results supply the quantitative concentration arguments. This is a conventional analytic proof, not a Lean formalization.
