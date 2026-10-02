import Paulsen.Paper.Moderate

/-!
# Paper blueprint, Section 5.5: a good sample (`sections/moderate.tex`)

The deterministic exceptional set `𝔅 = {i : ℓ_i > δ₀ a}`, the events (S1)–(S4) of
`lem:sample`, and the explicit-constant claims of its proof.
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

/-! ## The exceptional set -/

/-- `ℓ_i = (1/n) ∑_μ r_μ ‖(Y_{Z_y})_i‖²`, the variance that `R_ρ/n` removes from row `i`. -/
def residualRowLoss {n d : ℕ} (U : Frame n d) (ρ : ℝ) (i : Fin n) : ℝ :=
  (1 / (n : ℝ)) * ∑ j ∈ highNormalizedModes U 0,
    Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) *
      rowNormSq (tangentY U (normalizedNormalFrame U j)) i

/-- `δ₀ = 1/6400`. -/
def delta0 : ℝ := 1 / 6400

/-- `b_max = 2/δ₀`. -/
def bMax : ℝ := 2 / delta0

/-- `𝔅 = {i : ℓ_i > δ₀ a}`, a deterministic set depending only on `U` and `ρ`. -/
def exceptionalSet {n d : ℕ} (U : Frame n d) (ρ : ℝ) : Finset (Fin n) :=
  Finset.univ.filter fun i => delta0 * ((d : ℝ) / n) < residualRowLoss U ρ i

/-- Section 5.5, definition of `𝔅` (unnumbered claims).

TeX: "Since $\fro{Y_{Z_y}}^2=2$, $\sum_i\ell_i\le\frac2n\sum_\mu
r_\mu\le2a$. Fix $\delta_0=1/6400$ and let
\[ \mathfrak B=\{i:\ell_i>\delta_0a\},\qquad b=|\mathfrak B|\le2/\delta_0=:b_{\max}, \]" -/
theorem exceptionalSet_card {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) {ρ : ℝ}
    (hρ : 0 < ρ) :
    (∀ j ∈ highNormalizedModes U 0, frobSq (tangentY U (normalizedNormalFrame U j)) = 2) ∧
    ∑ i, residualRowLoss U ρ i ≤ 2 / n * ∑ j ∈ highNormalizedModes U 0,
      Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) ∧
    2 / n * ∑ j ∈ highNormalizedModes U 0,
      Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) ≤ 2 * ((d : ℝ) / n) ∧
    ((exceptionalSet U ρ).card : ℝ) ≤ bMax ∧ bMax = 12800 := by
  sorry

/-! ## The events (S1)–(S4) -/

/-- (S1): `‖Z‖_op ≤ 16`, `max_i ‖Zᵀv_i‖² ≤ 3a`, `max_i ‖Y_i‖² ≤ 800a`. -/
def SampleS1 {n d : ℕ} (U : Frame n d) (ρ : ℝ) (g : FrameVector n d) : Prop :=
  opNorm (moderateNoise U ρ g) ≤ 16 ∧
  (∀ i, rowNormSq (moderateNoise U ρ g) i ≤ 3 * ((d : ℝ) / n)) ∧
  ∀ i, rowNormSq (tangentY U (moderateNoise U ρ g)) i ≤ 800 * ((d : ℝ) / n)

/-- (S2): `max_i |(𝒜Z)_i| ≤ 3√(ρ a log(2n)/n)` and `max_i |q_i(Z) - E q_i(Z)| ≤ η' a`. -/
def SampleS2 {n d : ℕ} (U : Frame n d) (ρ η' : ℝ) (g : FrameVector n d) : Prop :=
  (∀ i, |diagMap U (moderateNoise U ρ g) i| ≤
    3 * Real.sqrt (ρ * ((d : ℝ) / n) * Real.log (2 * n) / n)) ∧
  ∀ i, |horizontalQuadraticDiagonal U (moderateNoise U ρ g) i -
    ∫ g', horizontalQuadraticDiagonal U (moderateNoise U ρ g') i ∂gaussAmb n d| ≤
      η' * ((d : ℝ) / n)

/-- (S3): every `i ∉ 𝔅` has at least `0.95n` indices `j ≠ i` with
`|P_ij + tY_ij| ≥ h t √(a/n)`. -/
def SampleS3 {n d : ℕ} (U : Frame n d) (ρ t h : ℝ) (g : FrameVector n d) : Prop :=
  ∀ i, i ∉ exceptionalSet U ρ → 95 / 100 * (n : ℝ) ≤
    ((Finset.univ.filter (fun j => j ≠ i ∧ h * t * Real.sqrt (((d : ℝ) / n) / n) ≤
      |frameProjection U i j + t * tangentY U (moderateNoise U ρ g) i j|)).card : ℝ)

/-- (S4): for every `x` supported on `𝔅`,
`|t xᵀ𝒞(Y)x| ≤ η'(xᵀLx + a t²‖x‖²)` and `|xᵀ(𝓛(Y) - E𝓛(Y))x| ≤ η' a ‖x‖²`. -/
def SampleS4 {n d : ℕ} (U : Frame n d) (ρ t η' : ℝ) (g : FrameVector n d) : Prop :=
  ∀ x : Fin n → ℝ, (∀ j, j ∉ exceptionalSet U ρ → x j = 0) →
    |t * matrixQuadratic (crossLaplacian (frameProjection U)
        (tangentY U (moderateNoise U ρ g))) x| ≤
      η' * (matrixQuadratic (projectionLaplacian (frameProjection U)) x +
        (d : ℝ) / n * t ^ 2 * vectorNormSq x) ∧
    |matrixQuadratic (sqLaplacian (tangentY U (moderateNoise U ρ g))) x -
      ∫ g', matrixQuadratic (sqLaplacian (tangentY U (moderateNoise U ρ g'))) x ∂gaussAmb n d| ≤
        η' * ((d : ℝ) / n) * vectorNormSq x

/-- All of (S1)–(S4). -/
def GoodSample {n d : ℕ} (U : Frame n d) (ρ t h η' : ℝ) (g : FrameVector n d) : Prop :=
  SampleS1 U ρ g ∧ SampleS2 U ρ η' g ∧ SampleS3 U ρ t h g ∧ SampleS4 U ρ t η' g

/-- `lem:sample`.

TeX: "There is an absolute $h\in(0,1)$ and, for each $\eta'\in(0,\frac1{32}]$, a
constant $A_{\eta'}$ such that the following holds for all $\rho>0$ and
$0<t\le1$ whenever $d\ge A_{\eta'}\log(2n)$. With positive probability:
(S1) [...] (S2) [...] (S3) [...] (S4) [...]" -/
theorem lem_sample :
    ∃ h : ℝ, 0 < h ∧ h < 1 ∧ ∀ η' : ℝ, 0 < η' → η' ≤ 1 / 32 → ∃ A : ℝ,
      ∀ (n d : ℕ) (U : Frame n d), ModerateStanding U → ∀ ρ : ℝ, 0 < ρ → ∀ t : ℝ, 0 < t →
        t ≤ 1 → A * Real.log (2 * n) ≤ d →
          0 < (gaussAmb n d).real {g | GoodSample U ρ t h η' g} := by
  sorry

/-- The value of `h` chosen in the proof of `lem:sample`.

TeX: "Take $h=1/500$, so that $\E F_i+0.01\le0.04$" -/
def sampleH : ℝ := 1 / 500

/-- The properties of the thresholds `A_{η'}` used later.

TeX: "Finally choose $A_{\eta'}$ so large that $d\ge A_{\eta'}\log(2n)$ implies
$d\ge10^6$ and all failure probabilities above are at most $\frac1{10}$; their
sum is less than $1$." -/
def SampleThreshold (A : ℝ → ℝ) : Prop :=
  ∀ η' : ℝ, 0 < η' → η' ≤ 1 / 32 →
    (∀ n d : ℕ, 1 ≤ n → A η' * Real.log (2 * n) ≤ d → (10 : ℝ) ^ 6 ≤ d) ∧
    ∀ (n d : ℕ) (U : Frame n d), ModerateStanding U → ∀ ρ : ℝ, 0 < ρ → ∀ t : ℝ, 0 < t →
      t ≤ 1 → A η' * Real.log (2 * n) ≤ d →
        0 < (gaussAmb n d).real {g | GoodSample U ρ t sampleH η' g}

/-- `lem:sample` with the explicit `h = 1/500` of its proof. -/
theorem lem_sample_explicit : ∃ A : ℝ → ℝ, SampleThreshold A := by
  sorry

/-! ## Proof of `lem:sample`: explicit constants -/

/-- Proof of `lem:sample`, (S1).

TeX: "The net bound (\cref{lem:gauss}(c)) with $\sigma^2=1/n$ gives
$\Prob(\opn Z>16)\le2\cdot5^ne^{-8n}$. The vector $Z^Tv_i$ has covariance
$\preceq n^{-1}I_d$ and trace $\le a$; \cref{lem:gauss}(a) with $u=2a$ (so
$\min\{u^2/\fro\cdot^2,u/\opn\cdot\}\ge2d$) and a union bound give
$\max\norm{Z^Tv_i}^2\le3a$ off probability $2ne^{-cd}$. Then
$\norm{Y_i}\le\norm{Z^Tv_i}+\norm{Zu_i}\le\sqrt{3a}+16\sqrt{3a/2}$."

(The constant `c` of the paper resolves to `1/4` through `lem:gauss`(a).) -/
theorem sample_S1 {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) {ρ : ℝ} (hρ : 0 < ρ) :
    (gaussAmb n d).real {g | 16 < opNorm (moderateNoise U ρ g)} ≤
      2 * 5 ^ n * Real.exp (-8 * n) ∧
    (∀ i, ∫ g, rowNormSq (moderateNoise U ρ g) i ∂gaussAmb n d ≤ (d : ℝ) / n) ∧
    (∀ i, (gaussAmb n d).real {g | 3 * ((d : ℝ) / n) < rowNormSq (moderateNoise U ρ g) i} ≤
      2 * Real.exp (-(d : ℝ) / 4)) ∧
    (Real.sqrt (3 * ((d : ℝ) / n)) + 16 * Real.sqrt (3 * ((d : ℝ) / n) / 2)) ^ 2 ≤
      800 * ((d : ℝ) / n) := by
  sorry

/-- The coefficient matrix `𝖬_i` of `q_i(Z) = ⟨Z, 𝖬_i Z⟩`, `𝖬_i Z = v_iv_iᵀZ - Zu_iu_iᵀ`
(ambient form `H ↦ e_ie_iᵀH - H u_iu_iᵀ` on `vec H`). -/
def quadraticCoefficient {n d : ℕ} (U : Frame n d) (i : Fin n) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  Matrix.kroneckerMap (· * ·) (Matrix.single i i (1 : ℝ)) (1 : Matrix (Fin d) (Fin d) ℝ) -
    Matrix.kroneckerMap (· * ·) (1 : Matrix (Fin n) (Fin n) ℝ)
      (Matrix.vecMulVec (U i) (U i))

/-- Proof of `lem:sample`, (S2).

TeX: "$(\mathcal AZ)_i$ is Gaussian with variance $\le\rho p_i/n\le3\rho
a/(2n)$ (\cref{lem:filter}(b)); a union bound gives the first claim off
probability $2n(2n)^{-3}$. The form $q_i(Z)=\ip Z{\mathsf M_iZ}$,
$\mathsf M_iZ=v_iv_i^TZ-Zu_iu_i^T$, has $\opn{\mathsf M_i}\le1$ and
$\fro{\mathsf M_i}^2\le2(d+np_i^2)\le7d$; after the covariance factor
$(C_\rho/n)^{1/2}$ these become $\le1/n$ and $\le\sqrt{7d}/n$, and
\cref{lem:gauss}(a) with $u=\eta'a$ gives failure probability $2n\exp(-c\eta'^2d)$."

(The constant `c` resolves to `1/56`.) -/
theorem sample_S2 {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) {ρ η' : ℝ}
    (hρ : 0 < ρ) (hη' : 0 < η') (hη'1 : η' ≤ 1 / 32) :
    (∀ i, ∫ g, diagMap U (moderateNoise U ρ g) i ^ 2 ∂gaussAmb n d ≤ ρ * rowNormSq U i / n ∧
      ρ * rowNormSq U i / n ≤ 3 * ρ * ((d : ℝ) / n) / (2 * n)) ∧
    (∀ i, (gaussAmb n d).real {g | 3 * Real.sqrt (ρ * ((d : ℝ) / n) * Real.log (2 * n) / n) <
      |diagMap U (moderateNoise U ρ g) i|} ≤ 2 * (2 * (n : ℝ)) ^ (-3 : ℤ)) ∧
    (∀ i, (∀ (H : Frame n d), horizontalQuadraticDiagonal U H i =
        matrixQuadratic (quadraticCoefficient U i) (fun q => H q.1 q.2)) ∧
      opNorm (quadraticCoefficient U i) ≤ 1 ∧
      frobSq (quadraticCoefficient U i) ≤ 2 * ((d : ℝ) + n * rowNormSq U i ^ 2) ∧
      2 * ((d : ℝ) + n * rowNormSq U i ^ 2) ≤ 7 * d) ∧
    ∀ i, (gaussAmb n d).real {g | η' * ((d : ℝ) / n) <
      |horizontalQuadraticDiagonal U (moderateNoise U ρ g) i -
        ∫ g', horizontalQuadraticDiagonal U (moderateNoise U ρ g') i ∂gaussAmb n d|} ≤
      2 * Real.exp (-(η' ^ 2 * d / 56)) := by
  sorry

/-- Proof of `lem:sample`, (S3), variance bookkeeping (scalar part).

TeX: "By the proof of \cref{lem:expected-graph}, for $i\ne k$ with $P_{ik}^2\le a/16$ the
unfiltered variance of $Y_{ik}$ is at least $a/(8n)$" -/
theorem sample_S3_unfiltered_scalar {a pi pk Pik : ℝ} (ha : 0 < a) (hpi : a / 2 ≤ pi)
    (hpk : a / 2 ≤ pk) (hpi1 : pi ≤ 3 / 4) (hpk1 : pk ≤ 3 / 4) (hP : Pik ^ 2 ≤ a / 16) :
    a / 8 ≤ pi + pk - 2 * pi * pk - 2 * Pik ^ 2 := by
  sorry

/-- Proof of `lem:sample`, (S3), variance bookkeeping (counts).

TeX: "at most $24$ indices $k$ have $P_{ik}^2>a/16$. Row $i$ of $T_{e_j}$ is
$\delta_{ij}e_j^TP+P_{ij}e_j^T-2P_{ij}e_j^TP$, of squared norm at most
$3(\delta_{ij}p_j+P_{ij}^2+4P_{ij}^2p_j)$, so the base part removes from row $i$
total variance $\frac1n\sum_j\norm{e_i^TT_{e_j}}^2/p_j\le\frac6{an}\cdot5p_i\le
\frac{45}n$, which exceeds $\frac a{32n}$ at no more than $1440n/d$ positions.
For $i\notin\mathfrak B$ the residual part removes at most $\delta_0a$ from row
$i$, hence more than $\frac a{32n}$ at no more than $32\delta_0n$ positions." -/
theorem sample_S3_counts {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) (i : Fin n) :
    ((Finset.univ.filter (fun k => (d : ℝ) / n / 16 < frameProjection U i k ^ 2)).card : ℝ) ≤
      24 ∧
    (∀ j, rowNormSq (tangentY U (ambientNormal U (Pi.single j 1))) i ≤
      3 * ((if i = j then rowNormSq U j else 0) + frameProjection U i j ^ 2 +
        4 * frameProjection U i j ^ 2 * rowNormSq U j)) ∧
    (1 / (n : ℝ)) * ∑ j, rowNormSq (tangentY U (ambientNormal U (Pi.single j 1))) i /
        rowNormSq U j ≤ 6 / ((d : ℝ) / n * n) * (5 * rowNormSq U i) ∧
    6 / ((d : ℝ) / n * n) * (5 * rowNormSq U i) ≤ 45 / n ∧
    (45 / n) / ((d : ℝ) / n / (32 * n)) = 1440 * (n : ℝ) / d ∧
    delta0 * ((d : ℝ) / n) / ((d : ℝ) / n / (32 * n)) = 32 * delta0 * n := by
  sorry

/-- Proof of `lem:sample`, (S3), variance bookkeeping (conclusion).

TeX: "So for $d\ge10^6$ (hence $n\ge2\cdot10^6$, and the excluded indices number at most
$25+0.0065n\le0.01n$) every $i\notin\mathfrak B$ has at least $0.99n$ indices $k\ne i$
with $\Var(Y_{ik})\ge\frac a{16n}$." -/
theorem sample_S3_variance {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U)
    (hd : (10 : ℝ) ^ 6 ≤ d) {ρ : ℝ} (hρ : 0 < ρ) :
    (2 * (10 : ℝ) ^ 6 ≤ n) ∧
    (1440 * (n : ℝ) / d + 32 * delta0 * n ≤ 65 / 10000 * n) ∧
    (25 + 65 / 10000 * (n : ℝ) ≤ 1 / 100 * n) ∧
    ∀ i, i ∉ exceptionalSet U ρ → 99 / 100 * (n : ℝ) ≤
      ((Finset.univ.filter (fun k => k ≠ i ∧ (d : ℝ) / n / (16 * n) ≤
        ∫ g, tangentY U (moderateNoise U ρ g) i k ^ 2 ∂gaussAmb n d)).card : ℝ) := by
  sorry

/-- Proof of `lem:sample`, (S3), small ball.

TeX: "Let $\phi:\R\to[0,1]$ be $C^1$, equal to $1$ on $[-h,h]$,
vanishing outside $[-2h,2h]$, with $|\phi'|\le2/h$, and for $i\notin\mathfrak B$
let $F_i=\frac1n\sum_{k\ne i}\phi\bigl((P_{ik}+tY_{ik})/(t\sqrt{a/n})\bigr)$. By
the density bound for a Gaussian of variance $\ge\frac{at^2}{16n}$,
$\E F_i\le0.01+\frac{4h}{\sqrt{2\pi/16}}\le0.01+7h$. As a function of the row
$(Y_{ik})_k$, $F_i$ has gradient norm at most
$\frac1n\cdot\frac2h\cdot\sqrt{n/a}\cdot\sqrt n=2/(h\sqrt a)$; the row depends on
$Z$ through a linear map of norm $\le2$, and $Z=(C_\rho/n)^{1/2}g$ with $g$
standard. So $F_i$ is $4/(h\sqrt d)$-Lipschitz in $g$, and \cref{lem:gauss}(b)
gives $\Prob(F_i>\E F_i+0.01)\le2\exp(-c\,h^2d)$. Take $h=1/500$, so that
$\E F_i+0.01\le0.04$, and a union bound over $i$. On the complement, at most
$0.04n$ indices $k\ne i$ have $|P_{ik}+tY_{ik}|<ht\sqrt{a/n}$, so at least
$n-1-0.04n\ge0.95n$ have the reverse inequality." -/
theorem sample_S3_smallball {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U)
    (hd : (10 : ℝ) ^ 6 ≤ d) {ρ t h : ℝ} (hρ : 0 < ρ) (ht : 0 < t) (ht1 : t ≤ 1) (hh : 0 < h)
    (φ : ℝ → ℝ) (hφ : ContDiff ℝ 1 φ) (hφ01 : ∀ x, 0 ≤ φ x ∧ φ x ≤ 1)
    (hφ1 : ∀ x, |x| ≤ h → φ x = 1) (hφ0 : ∀ x, 2 * h < |x| → φ x = 0)
    (hφ' : ∀ x, |deriv φ x| ≤ 2 / h) (i : Fin n) (hi : i ∉ exceptionalSet U ρ) :
    let F : FrameVector n d → ℝ := fun g => (1 / (n : ℝ)) * ∑ k ∈ Finset.univ.erase i,
      φ ((frameProjection U i k + t * tangentY U (moderateNoise U ρ g) i k) /
        (t * Real.sqrt (((d : ℝ) / n) / n)))
    ∫ g, F g ∂gaussAmb n d ≤ 1 / 100 + 4 * h / Real.sqrt (2 * Real.pi / 16) ∧
    4 * h / Real.sqrt (2 * Real.pi / 16) ≤ 7 * h ∧
    (∀ g, ‖fderiv ℝ F g‖ ≤ 4 / (h * Real.sqrt d)) ∧
    (gaussAmb n d).real {g | ∫ g', F g' ∂gaussAmb n d + 1 / 100 < F g} ≤
      2 * Real.exp (-2 * (1 / 100) ^ 2 / (Real.pi ^ 2 * (4 / (h * Real.sqrt d)) ^ 2)) := by
  sorry

/-- Proof of `lem:sample`, (S3), the numerics for `h = 1/500`. -/
theorem sample_S3_numerics {n : ℕ} (hn : 100 ≤ n) :
    1 / 100 + 7 * sampleH + 1 / 100 ≤ 4 / 100 ∧
    95 / 100 * (n : ℝ) ≤ (n : ℝ) - 1 - 4 / 100 * n := by
  sorry

/-- The whitened block edge vectors of the (S4) argument:
`J_𝔅 = L_{𝔅𝔅} + a t² I_𝔅` and `ω_{ij} = J_𝔅^{-1/2} Π_𝔅 (e_i - e_j)`. -/
def blockJ {n d : ℕ} (U : Frame n d) (B : Finset (Fin n)) (t : ℝ) : Matrix B B ℝ :=
  (projectionLaplacian (frameProjection U)).submatrix (↑) (↑) +
    ((d : ℝ) / n * t ^ 2) • (1 : Matrix B B ℝ)

/-- `ω_{ij} = J_𝔅^{-1/2} Π_𝔅 (e_i - e_j)`. -/
def blockOmega {n d : ℕ} (U : Frame n d) (B : Finset (Fin n)) (t : ℝ) (i j : Fin n) : B → ℝ :=
  invSqrt (blockJ U B t) *ᵥ fun b => edgeVec i j b

/-- `Ξ = ∑_{i<j} 2t P_{ij} Y_{ij} ω_{ij} ω_{ij}ᵀ`. -/
def blockXi {n d : ℕ} (U : Frame n d) (B : Finset (Fin n)) (t : ℝ)
    (Y : Matrix (Fin n) (Fin n) ℝ) : Matrix B B ℝ :=
  ∑ i, ∑ j, if i < j then (2 * t * frameProjection U i j * Y i j) •
    Matrix.vecMulVec (blockOmega U B t i j) (blockOmega U B t i j) else 0

/-- Proof of `lem:sample`, (S4), first half.

TeX: "Let $\Pi_{\mathfrak B}$ be the coordinate projection onto
$\R^{\mathfrak B}$, $J_{\mathfrak B}=L_{\mathfrak B\mathfrak B}+at^2I_{\mathfrak B}$
and $\omega_{ij}=J_{\mathfrak B}^{-1/2}\Pi_{\mathfrak B}(e_i-e_j)$, so
$\norm{\omega_{ij}}^2\le2/(at^2)$ and
$\sum_{i<j}P_{ij}^2\omega_{ij}\omega_{ij}^T=J_{\mathfrak B}^{-1/2}L_{\mathfrak
B\mathfrak B}J_{\mathfrak B}^{-1/2}\preceq I$. [...] The coefficients $(Y_{ij})_{i<j}$
have covariance $\preceq\frac2nI$ [...], so
\[ \E\fro\Xi^2\le\frac{2t^2}n\sum_{i<j}4P_{ij}^2\norm{\omega_{ij}}^4
 \le\frac{16}{an}\tr\bigl(J_{\mathfrak B}^{-1/2}L_{\mathfrak B\mathfrak B}
 J_{\mathfrak B}^{-1/2}\bigr)\le\frac{16b}d , \]
and Markov's inequality gives the first half off probability $16b/(d\eta'^2)$." -/
theorem sample_S4_cross {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) {ρ t η' : ℝ}
    (hρ : 0 < ρ) (ht : 0 < t) (ht1 : t ≤ 1) (hη' : 0 < η') :
    (∀ i j, ∑ b, blockOmega U (exceptionalSet U ρ) t i j b ^ 2 ≤ 2 / ((d : ℝ) / n * t ^ 2)) ∧
    (∀ c : Fin n → Fin n → ℝ, ∫ g, (∑ i, ∑ j, if i < j then
        c i j * tangentY U (moderateNoise U ρ g) i j else 0) ^ 2 ∂gaussAmb n d ≤
      2 / n * ∑ i, ∑ j, if i < j then c i j ^ 2 else 0) ∧
    (∀ (Y : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ),
      (∀ j, j ∉ exceptionalSet U ρ → x j = 0) →
      t * matrixQuadratic (crossLaplacian (frameProjection U) Y) x =
        matrixQuadratic (blockXi U (exceptionalSet U ρ) t Y)
          (cfc Real.sqrt (blockJ U (exceptionalSet U ρ) t) *ᵥ
            fun b : exceptionalSet U ρ => x b.1)) ∧
    ∫ g, frobSq (blockXi U (exceptionalSet U ρ) t (tangentY U (moderateNoise U ρ g)))
        ∂gaussAmb n d ≤ 16 * ((exceptionalSet U ρ).card : ℝ) / d ∧
    (gaussAmb n d).real {g | η' ^ 2 <
      frobSq (blockXi U (exceptionalSet U ρ) t (tangentY U (moderateNoise U ρ g)))} ≤
      16 * ((exceptionalSet U ρ).card : ℝ) / (d * η' ^ 2) := by
  sorry

/-- Proof of `lem:sample`, (S4), second half.

TeX: "The principal $\mathfrak B$-block of $\Lap(Y)-\E\Lap(Y)$ has diagonal entries
$\sum_{j\ne i}(Y_{ij}^2-\E Y_{ij}^2)$, a centred Gaussian quadratic form of
variance at most $2\cdot\frac2n\cdot\E\norm{Y_i}^2\le\frac{12a}n$
(\cref{lem:gauss}(a), with $\E\norm{Y_i}^2\le a(1-p_i)+(1-a)p_i\le3a$), and
off-diagonal entries $-(Y_{ik}^2-\E Y_{ik}^2)$ of variance at most $8/n^2$. Its
expected squared Frobenius norm is at most $20b^2a/n=20b^2a^2/d$, and Markov
gives the second half off probability $20b^2/(d\eta'^2)$." -/
theorem sample_S4_square {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) {ρ η' : ℝ}
    (hρ : 0 < ρ) (hη' : 0 < η') :
    let B := exceptionalSet U ρ
    let Λc : FrameVector n d → Matrix B B ℝ := fun g =>
      (sqLaplacian (tangentY U (moderateNoise U ρ g))).submatrix (↑) (↑) -
        Matrix.of fun (b c : B) => ∫ g', sqLaplacian (tangentY U (moderateNoise U ρ g'))
          (b : Fin n) (c : Fin n) ∂gaussAmb n d
    (∀ i, ∫ g, rowNormSq (tangentY U (moderateNoise U ρ g)) i ∂gaussAmb n d ≤
        (d : ℝ) / n * (1 - rowNormSq U i) + (1 - (d : ℝ) / n) * rowNormSq U i ∧
      (d : ℝ) / n * (1 - rowNormSq U i) + (1 - (d : ℝ) / n) * rowNormSq U i ≤
        3 * ((d : ℝ) / n)) ∧
    (∀ b : B, ∫ g, Λc g b b ^ 2 ∂gaussAmb n d ≤
      2 * (2 / n) * (3 * ((d : ℝ) / n)) ∧ 2 * (2 / (n : ℝ)) * (3 * ((d : ℝ) / n)) =
        12 * ((d : ℝ) / n) / n) ∧
    (∀ b c : B, b ≠ c → ∫ g, Λc g b c ^ 2 ∂gaussAmb n d ≤ 8 / (n : ℝ) ^ 2) ∧
    ∫ g, frobSq (Λc g) ∂gaussAmb n d ≤ 20 * (B.card : ℝ) ^ 2 * ((d : ℝ) / n) / n ∧
    20 * (B.card : ℝ) ^ 2 * ((d : ℝ) / n) / n = 20 * (B.card : ℝ) ^ 2 * ((d : ℝ) / n) ^ 2 / d ∧
    (gaussAmb n d).real {g | η' * ((d : ℝ) / n) < Real.sqrt (frobSq (Λc g))} ≤
      20 * (B.card : ℝ) ^ 2 / (d * η' ^ 2) := by
  sorry

end

end Paulsen.Paper
