# Strictly monotone piecewise-linear extension

This note proves an extension of the audited triangle-wave construction to the fixed activation

\[
 \psi(t)=\alpha t+\varepsilon\phi(t),
 \qquad \alpha>\varepsilon>0,
\]

where `phi` is the period-four odd triangle wave, linear with slope one on `[-1,1]`. Two concrete choices are `psi(t)=t+phi(t)/2` (slopes `1/2,3/2`) and `psi(t)=(2t+phi(t))/3` (slopes `1/3,1`, hence strictly increasing and 1-Lipschitz). These are fixed continuous piecewise-linear activations with infinitely many kinks. This is **not** a theorem for ordinary ReLU, hardtanh, or leaky ReLU.

Use the same odd core `C`, even control blocks, and code projection `P` as in the triangle construction. Write `c=|C|`, `D=sum_i|B_i|`, and take the odd core size at least `10^8(D+1)^3`. The calibrated logical set is `G\\U`, where `U` is an affine codimension-four coset not containing zero. The initial calibration includes every physical point in those logical fibers, with labels `chi_C y(z)`.

The triangle atom-rounding theorem is used with `kappa=1/200`.

## 1. Exact weighted code norm survives

For a ridge, every code Fourier character has degree at least three, so it annihilates the affine part:

\[
 \widehat{\psi(\theta\cdot\bar x)}(A_S)
   =\varepsilon\widehat{\phi(\theta\cdot\bar x)}(A_S).
\]

Thus the triangle atomic inequality gives

\[
 \frac1\varepsilon\sum_S\sqrt{|A_S|}
  |\widehat{\psi(\theta\cdot\bar x)}(A_S)|\leq\|\theta\|_2.
\]

The matching upper bound uses four orientations for each odd mode `A`, `|A|≥3`. On its first three coordinates, take the four rows

\[
 (+++),\quad(+--),\quad(-+-),\quad(--+).
\]

Every row has product `+1`, and every column sums to zero. The remaining number of coordinates is even; append them in pairs of identical balanced columns, for example `(++--)` in each coordinate of a pair. Row products remain `+1`, and all column sums remain zero. If these four sign vectors are `u_1,...,u_4`, then

\[
 \frac14\sum_{j=1}^4\psi(u_j\cdot x)
 =\varepsilon(-1)^{(|A|-1)/2}\chi_A(x).
\]

The linear parts cancel exactly, while all triangle parts have the same character sign. All four vectors have norm `sqrt(|A|)`. Therefore, for every code score,

\[
 \boxed{\quad
 \left\|\chi_C g(z)\right\|_{\mathcal V_\psi}
 =\frac1\varepsilon\sum_S\sqrt{c+|B_S|}\,|\widehat g(S)|.
 \quad}
\]

No change to the prior or parameter constraints is involved.

## 2. Triangle rounding also gives an L2 residual bound

For an arbitrary finite network, write

\[
 F=L+\varepsilon T,
 \quad L(x)=\alpha\sum_l v_l\theta_l\cdot\bar x,
 \quad T(x)=\sum_l v_l\phi(\theta_l\cdot\bar x).
\]

Let `A` be the Euclidean norm of the affine coefficient vector of `L`. Put

\[
 V=\sum_l|v_l|\|\theta_l\|_2,
 \quad Q_F=\sum_S\sqrt{|A_S|}\,|\widehat F(A_S)|,
 \quad B=\sum_l|v_l|e(\theta_l),
\]

with the rounding errors `e` from the triangle gap theorem. It gives

\[
 V\geq Q_F/\varepsilon+\kappa B.                       \tag{1}
\]

Each triangle ridge is within L2 distance at most `e(theta)` of its rounded zero or signed code character. This follows from the 1-Lipschitz property and `E(bar X bar X^T)=I`; the modulo-two output sign causes no change. Hence there is a code score `H` with `||T−H||_2≤B`. Since `P` is an orthogonal projection,

\[
 R:=T-PT,\qquad \|R\|_2\leq B.                       \tag{2}
\]

The affine part has zero code projection. Write `PF=chi_C g(z)`. Write `mathcal T(x)=(chi_C(x),chi_B1(x),...,chi_Bm(x))` for the physical parity-fiber map. The previous triangle residual estimates also give

\[
 |F(x)-F(x')|\leq(A+\varepsilon B)\|x-x'\|_2
 \quad\text{when }\mathcal T(x)=\mathcal T(x'),                         \tag{3}
\]

and, at any fixed physical control assignment,

\[
 |E_{X_C}F|\leq\sqrt{D+1}(A+\varepsilon B).           \tag{4}
\]

## 3. Calibration charges the free affine component

Use the explicit training dual

\[
 \lambda(z)=M1_{\{0\}}(z)-2-2\,1_K(z)+2\,1_U(z),
 \quad U=v_0+K,
 \quad L_0=3/2-4/M.
\]

It has Fourier-infinity norm one, is zero on `U`, and has magnitude at least two with the prescribed sign at every calibrated logical point.

Condition on a calibrated logical value `z`, averaging over both core parities and all internal physical fibers. The random variable

\[
 Y=\chi_C(L+\varepsilon R)
\]

has conditional mean zero, because `PL=PR=0`. Calibration gives

\[
 y(z)[g(z)+Y]\geq\tfrac12
\]

pointwise. Consequently

\[
 y(z)g(z)-\tfrac12
 \geq\max(-y(z)Y)
 \geq\tfrac12 E(|L+\varepsilon R|\mid z).
\]

Multiplying by the dual and using `|lambda|≥2` **before** estimating the residual yields

\[
 E\lambda g-L_0
 \geq E[1_{\{z\notin U\}}|L+\varepsilon R|]
 \geq\eta A-\varepsilon B,                           \tag{5}
\]

where

\[
 \eta=1/\sqrt3-1/4>0.32.
\]

Indeed, `E L²=A²` and `E L⁴≤3A⁴` imply `E|L|≥A/sqrt(3)` by interpolation. Removing a set of probability `1/16` costs at most `A/4` by Cauchy-Schwarz. Equation (2) gives `E|R|≤B`. No conditional-moment claim and no large coefficient at the distinguished point are needed.

The unstrengthened training dual also gives `E lambda g≥L0`. Therefore, writing

\[
 E_*:=V-\sqrt c\,L_0/\varepsilon,
 \quad \beta=\varepsilon B,
 \quad E'=\varepsilon E_*,
\]

(1) and (5) imply the two bounds

\[
 E'\geq\kappa\beta,
 \qquad
 E'\geq\sqrt c(\eta A-\beta)+\kappa\beta.            \tag{6}
\]

## 4. A positive gap for every non-code sign completion

Assume the full physical cube has margin at least `1/2`. If signs vary within one parity fiber, (3) and the connected two-coordinate-flip graph give `A+epsilon B≥1/(2sqrt(2))`. If signs are fiber-constant but not odd in core parity, (4) gives `A+epsilon B≥1/(2sqrt(D+1))`. Thus in either non-code case,

\[
 A+\beta\geq K_*:=\frac1{2\sqrt{D+1}}.
\]

The two affine bounds in (6), minimized subject to this constraint, intersect at `beta=eta K_*/(1+eta)`. Hence

\[
 E'\geq\frac{\kappa\eta}{1+\eta}K_*
       >\frac\kappa5K_*.
\]

We obtain the representation-independent bound

\[
 \boxed{\quad
 V\geq\frac{\sqrt c}{\varepsilon}L_0
       +\frac{\kappa}{10\varepsilon\sqrt{D+1}}
 \quad}\tag{7}
\]

for every globally margin-valid, calibrated network whose signs are not code-invariant and core-odd. Taking the infimum over representations preserves the bound.

A feasible star has variation cost at most

\[
 \frac{\sqrt c}{\varepsilon}L_0
       +\frac{3D}{4\varepsilon\sqrt c}.
\]

For `c≥10^8(D+1)^3`, this excess is strictly smaller than the penalty in (7): the ratio is at most `0.15D/(D+1)<1`. Therefore all minimizing sign completions are code-invariant and core-odd. The exact weighted subgroup classification and strict star ordering then apply unchanged, with all costs multiplied by `1/epsilon`.

## 5. Teacher and finite-width remarks

For `epsilon=1/2`, each unit parity term is the sum of the four oriented ridges with readouts of magnitude `1/2`. The margin-one target score

\[
 \chi_C\left[\sum_i\chi_{B_i}-(m-1)\right]
\]

therefore has width `4(2m−1)` and all incoming and readout weights bounded by one. For the strictly increasing 1-Lipschitz choice `alpha=2/3,epsilon=1/3`, the same width works with readouts of magnitude `3/4`.

Explicit finite-width allocation uses the four pure orientations with their stated coefficients. The total optimal allocation mass is at most `3/(2epsilon sqrt(d c))<1`, so zero neurons fill the remainder and integer allocations converge for every sufficiently large width. The activation is unbounded, so a bounded-activation compactness lemma should not be invoked; the direct universal energy lower bound and explicit finite code upper bounds suffice.

Independent audit: `new_lens` checked the L2 residual, conditional-zero-mean slack argument, and optimization in (6). `fresh_full` independently checked an alternative, slightly weaker slack estimate and the four-orientation construction.

Additional independent audit: `positive_symmetry` checked all norm, conditional-slack, moment, minimax, fiber, teacher, and finite-allocation steps. Their notation clarifications (the fiber map `mathcal T` versus triangle component `T`, and unnormalized restricted expectation in (5)) are incorporated.
