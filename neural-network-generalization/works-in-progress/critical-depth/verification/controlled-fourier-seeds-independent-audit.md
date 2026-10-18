# Audit: controlled first-layer seeds for parity and Fourier spectral norm

Auditor: depth_memorization. This checks the new controlled-seed argument proposed by depth_critical and the Fourier extension proposed by root. The argument is valid, provided the free-cooling lemma explicitly permits initial constant diagonal in `[F(1),1]`, rather than its narrower published interval `[F(1),F(2)]`. The existing proof extends to the larger interval with universal constants, as detailed below.

This is an absolute critical-rate result. It supplies neither a sample-complexity bound nor a comparison of the fine rates of different functions.

## 1. A parity mean seed with polynomial entropy

For a character `χ_S` of degree `k>=1`, put `q(x)=(k−Σ_{i in S}x_i)/2`. This takes integer values from zero through `k`. Define step signs

`s_j(x)=sign(q(x)−j+1/2)`, `1<=j<=k`.

The exact parity identity is

`χ_S(x)=c_0+Σ_{j=1}^k (−1)^j s_j(x)`,

where `c_0=1+Σ_{j=1}^k(−1)^j` is either zero or one.

A first-row Gaussian mean shift with preactivation mean `A(q(x)−j+1/2)`, where `A=4+log(64(k+1))`, gives an expected tanh feature within `1/[32(k+1)]` of each step sign on the entire cube. Its preactivation variance is `(d+1)/d<=2`. The required weight mean has input coefficients `−A/2` on the chosen coordinates and bias `A(k/2−j+1/2)`, so its relative entropy is `O(d k² A²)`.

Mix these shifted first-row laws with signed coefficients of magnitude `lambda=1/[4(k+1)]`, using output-negated laws for negative signs. Implement the constant, when present, using a Gaussian bias shift with constant expected feature at least one half; its mixture weight is at most `2lambda`. The total mixture weight is below one, so put the remainder on the unshifted law. The resulting mean `m` satisfies

`χ_S(x)m(x)>=1/[8(k+1)]` at every cube point,

and its entropy is bounded by a universal polynomial in `d,k`. No count of the cube vertices enters this entropy bound.

For the empty character use a positive Gaussian bias shift directly.

## 2. Symmetrization is legitimate in the first layer

For `b in {−1,1}^d`, transform a feature by

`(T_b h)(x)=χ_S(b) h(b⊙x)`.

The uncontrolled first-feature law is invariant under this transformation: in weight space it is an orthogonal diagonal sign transformation, multiplying all weights by `χ_S(b)` and multiplying the selected input coordinates by `b`. The centered isotropic Gaussian law is unchanged. Therefore averaging transformed controlled laws cannot increase relative entropy.

The resulting mean is exactly

`E_b χ_S(b)m(b⊙x)=c_S χ_S(x)`,

where `c_S=E_x χ_S(x)m(x)>=1/[8(k+1)]`. Its feature second moment has constant diagonal, since cube translations act transitively and the output sign disappears upon squaring. Consequently it dominates `c_S² χ_S χ_S^T`.

This operation only symmetrizes one law relative to a fixed invariant reference. It does not average nonlinear covariance paths or assume joint convexity of their rate functional.

## 3. Fourier mixtures give exact arbitrary Boolean mean seeds

Let `A_f=Σ_S |hat f(S)|` be the normalized Fourier `l1` norm of a Boolean function. It satisfies `A_f>=1` by Parseval. Set a common amplitude

`a_*=1/[8(d+1)]`.

For every character, dilute its symmetrized law with the raw first-feature law until its mean is exactly `a_* χ_S`. This is possible because `c_S>=a_*`; dilution preserves constant diagonal and does not increase entropy. There is a common bound

`D_*=C(d+1)^3[1+log(d+1)]²>=1`

for every resulting law.

Now mix these laws, applying output sign reversal according to `sign(hat f(S))`, with weights `|hat f(S)|/A_f`. Its mean is exactly

`m_f(x)=(a_*/A_f) f(x)`.

Its diagonal is constant, and convexity bounds its entropy by `D_*`, regardless of the number of nonzero Fourier coefficients. The mixture has at most `2^d` components, so it is an ordinary finite mixture. No algorithmic efficiency is claimed or needed.

All these laws are mixtures of shifted first-row Gaussians with unchanged covariance. At every cube point, their expected squared tanh feature is at least its unshifted value. To see this, `|G+m|` stochastically dominates `|G|` for a centered scalar Gaussian `G`, and `tanh²` increases with absolute value. Therefore the constant diagonal lies in

`[q_raw,1]`, where `q_raw=F((d+1)/d) in [F(1),F(2)]`.

## 4. Negligible prefix cost and the steering bound

At a specified learner depth `L`, dilute the preceding law into the raw first-feature law with weight

`theta=1/(D_* L)`.

The first-layer entropy cost is at most `1/L`. Its constant-diagonal covariance has an exact target component

`Q_1 >= v f f^T`, `v=a_*²/(A_f² D_* L)`.

Thus

`S:=1+log(1/v) <= C[log(d+L)+log A_f]`.

The subsequent stages of the existing target-component theorem depend on the first law only through its constant diagonal and the component size `v`. They do not require that the first layer itself be uncontrolled. The replacement does not consume an additional layer. Adding its prefix cost `1/L` to that theorem therefore gives

`J_L(f)<=V_*+C[log(d+L)+log A_f]²/L`,

provided

`L>=C[log(d+L)+log A_f]`.

The `log(2L)` term from the existing steering theorem is absorbed by the displayed expression. In particular, a fixed universal absolute rate budget is attained once

`L>=C[1+log(d+1)+log A_f]²`.

For parity, `A_f=1`, so all parity degrees achieve the same `O(log²(d+1))` sufficient depth scale as constants and dictators. The statement remains about absolute rate, not learning or relative preference.

## 5. Extending the free-cooling interval

The published free-cooling proof assumes initial constant diagonal in `[F(1),F(2)]`. The controlled laws above can have larger diagonal, so this hypothesis must be changed explicitly.

Its proof works on the entire interval `[F(1),1]`. The function `F(q)=E tanh²(sqrt(q)Z)` is increasing, has `0<F(q)<q` for `q>0`, and satisfies `F(q)=q−2q²+O(q³)` near zero. Hence `(q−F(q))/q²` has a positive lower bound on `(0,1]`. Likewise

`R(q)=q[1−F(q)]²/F(q)`

is positive there and satisfies `R(q)=1+O(q²)` near zero, so `|log R(q)|<=Cq²` on `(0,1]`. The same telescoping argument bounds `Σq_j²` by a universal constant. The first-hitting estimate and the retained target-component estimate therefore hold with altered universal constants. The final step uses only `q_0<=1`, so it remains valid at the enlarged endpoint. No dimension dependence is introduced.

## 6. Final check of the assembled Fourier theorem

I also checked Section 6 of `critical-boolean.md`, including its direct weighted mixture with

`Z=Σ_S |hat f(S)|/c_S`.

This is equivalent to the common-amplitude construction above: the probabilities `|hat f(S)|/(c_S Z)` sum to one, yield exact mean `f/Z`, and retain the common polynomial entropy bound. Since `c_S>=1/[8(d+1)]`, one has `Z<=8(d+1)A_f`. Its dilution, covariance domination, logarithmic seed parameter, and prefix entropy accounting are correct. The source explicitly includes the enlarged free-cooling interval, so the qualification identified at the start has been addressed.

The stated `k`-junta corollary follows from `A_f<=2^{k/2}` by Parseval and Cauchy–Schwarz. Consequently a bounded absolute critical rate is obtained at depth `O((k+log(d+2))²)`. For all parity degrees the matching necessary and sufficient bounded-rate depth scale is `Theta(log²(d+2))`, using the published universal entropy-transport lower bound. Neither statement supplies a generalization theorem.

No substantive gap was found in the assembled argument. This audit relies on the published target-component steering theorem, while checking explicitly that every one of its initial-covariance hypotheses continues to hold and that the altered first-layer entropy cost is added. It is not a Lean verification.

## 7. Near-baseline actual posterior ceiling

I checked Section 7 of `critical-boolean.md`. The point-indicator Fourier identity gives norm exactly one, so the memorizing extension has `A(g_S)<=1+2n`. Substitution into the Fourier theorem gives the stated ceiling

`U=V_*+C log²(2+d+n+L)/L`

under its logarithmic depth condition. The finite-class posterior comparison and the approximation-rate obstruction are valid. In fact, for fixed dimension and depth, posterior mass on the event `J_L(g)>U` itself tends to zero: if this event is nonempty, finiteness supplies a positive minimum rate gap above `U`. Thus the optional `eta` is not mathematically necessary in this fixed-domain limit.

A universal polynomial learning guarantee consequently forces weak approximants with normalized excess `L(J_L(g)−V_*)` at most a squared logarithm in the target resources. An arbitrarily small fixed error slack can be used when extracting a single good approximant from a Gibbs guarantee. This requirement remains meaningful even when all function rates flatten to `V_*`, since the published all-function estimate controls the normalized excess only by `O(d²+log²L)`.

## 8. Final TeX source audit

I checked the assembled TeX files on 2026-10-18:

- `source/controlled-fourier-seeds.tex`, SHA-256 `0f07133d1b146607a964fa05db8bf1cb68e0d0fbeb1e122e3c98376b281fbc05`;
- `source/near-baseline-posterior.tex`, SHA-256 `2cbd5cfb94c7161f42bcd14a0484bdde54c3e1ba91b8ba450c2ddd7d0794a1f6`.

The proofs preserve the audited constructions, make the free-cooling extension explicit, and give the finite-class posterior argument without an unnecessary positive rate slack. The confidence-error conversion is correct: Gibbs error is at most `1/3+2e/3`, so its lower limit at least `epsilon` forces `liminf e>=(3epsilon−1)/2` when positive. No new mathematical gap was found. These are mathematical AI-agent checks, not Lean verification.
