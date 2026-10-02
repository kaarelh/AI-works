import Paulsen.Paper.Moderate
import Paulsen.Paper.SampleAuxBall3
import Paulsen.Paper.SampleAuxBump
import Paulsen.Paper.SampleAuxFinal

/-!
# Paper blueprint, Section 5.5: a good sample (`sections/moderate.tex`)

The deterministic exceptional set `𝔅 = {i : ℓ_i > δ₀ a}`, the events (S1)–(S4) of
`lem:sample`, and the explicit-constant claims of its proof.

All proofs are complete (modulo the upstream paper lemmas of `Gaussian.lean`, `Moderate.lean`
and `Toolbox.lean` that they cite).  The generic analytic and linear-algebra steps are in the
helper files `SampleAux*.lean`.  `lem_sample` and `lem_sample_explicit` are placed at the end of
the file, after the proof-step lemmas `sample_S1`–`sample_S4_square` from which they are derived
(assembly: `sampleBad`, `sampleBad_S1`–`sampleBad_S4`, `good_of_not_sampleBad`,
`sample_good_pos`; the thresholds are `A_{η'} = 10¹²/η'²`).
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
  have hU := hs.parseval
  have hd : (0 : ℝ) < d := Nat.cast_pos.mpr hs.pos
  have hn : (0 : ℝ) < n := by
    have h1 := hs.density
    have h2 := hs.pos
    exact_mod_cast (by omega : 0 < n)
  have ha : 0 < (d : ℝ) / n := div_pos hd hn
  have hp : ∀ i, 0 < rowNormSq U i := fun i =>
    lt_of_lt_of_le (by positivity) (hs.rows i).1
  have hfc := lem_filter_c U hU hp hρ
  have hY : ∀ j ∈ highNormalizedModes U 0,
      frobSq (tangentY U (normalizedNormalFrame U j)) = 2 := fun j hj =>
    normalTangentFrame_sq_sum hU j (Finset.mem_filter.mp hj).2
  have hsum : ∑ i, residualRowLoss U ρ i = 2 / n * ∑ j ∈ highNormalizedModes U 0,
      Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) := by
    unfold residualRowLoss
    rw [← Finset.mul_sum, Finset.sum_comm]
    have he : ∀ j ∈ highNormalizedModes U 0,
        ∑ i, Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) *
          rowNormSq (tangentY U (normalizedNormalFrame U j)) i =
        Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) * 2 := by
      intro j hj
      rw [← Finset.mul_sum, ← hY j hj]
      rfl
    rw [Finset.sum_congr rfl he, ← Finset.sum_mul]
    ring
  have hnonneg : ∀ i, 0 ≤ residualRowLoss U ρ i := by
    intro i
    unfold residualRowLoss
    apply mul_nonneg (by positivity)
    apply Finset.sum_nonneg
    intro j hj
    exact mul_nonneg (hfc.2.1 j hj).2 (rowNormSq_nonneg _ i)
  have hmass : 2 / n * ∑ j ∈ highNormalizedModes U 0,
      Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) ≤ 2 * ((d : ℝ) / n) := by
    have h := mul_le_mul_of_nonneg_left hfc.2.2.1 (show (0 : ℝ) ≤ 2 / n by positivity)
    calc _ ≤ 2 / (n : ℝ) * d := h
      _ = _ := by ring
  have hbmax : bMax = 12800 := by unfold bMax delta0; norm_num
  refine ⟨hY, hsum.le, hmass, ?_, hbmax⟩
  have hδ : (0 : ℝ) < delta0 * ((d : ℝ) / n) := by unfold delta0; positivity
  have hcard : ((exceptionalSet U ρ).card : ℝ) * (delta0 * ((d : ℝ) / n)) ≤
      2 * ((d : ℝ) / n) := by
    calc
      _ = ∑ _i ∈ exceptionalSet U ρ, delta0 * ((d : ℝ) / n) := by simp
      _ ≤ ∑ i ∈ exceptionalSet U ρ, residualRowLoss U ρ i :=
        Finset.sum_le_sum fun i hi => (Finset.mem_filter.mp hi).2.le
      _ ≤ ∑ i, residualRowLoss U ρ i :=
        Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
          (fun i _ _ => hnonneg i)
      _ ≤ _ := hsum.le.trans hmass
  have hb : bMax = 2 * ((d : ℝ) / n) / (delta0 * ((d : ℝ) / n)) := by
    unfold bMax
    field_simp
  rw [hb]
  exact (le_div_iff₀ hδ).mpr hcard

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
  have hU := hs.parseval
  have hd0 := hs.pos
  have hn0 : 0 < n := by have := hs.density; omega
  have hdn : d ≤ n := by have := hs.density; omega
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn0
  have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hd0
  have ha : 0 < (d : ℝ) / n := div_pos hdR hnR
  have hp : ∀ i, 0 < rowNormSq U i := fun i =>
    lt_of_lt_of_le (by positivity) (hs.rows i).1
  refine ⟨noise_opNorm_tail hU hn0 hdn hp hρ, fun i => ?_, fun i => noise_row_tail hU hn0 hd0 hρ.le i,
    ?_⟩
  · exact integral_rowNormSq_gaussianImage_le (noiseF U ρ) (opNorm_noiseF_sq hU hρ.le) i
  · set x := Real.sqrt (3 * ((d : ℝ) / n))
    set y := Real.sqrt (3 * ((d : ℝ) / n) / 2)
    have hx : x ^ 2 = 3 * ((d : ℝ) / n) := Real.sq_sqrt (by positivity)
    have hy : y ^ 2 = 3 * ((d : ℝ) / n) / 2 := Real.sq_sqrt (by positivity)
    nlinarith [sq_nonneg (x - y)]

/-- The coefficient matrix `𝖬_i` of `q_i(Z) = ⟨Z, 𝖬_i Z⟩`, `𝖬_i Z = v_iv_iᵀZ - Zu_iu_iᵀ`
(ambient form `H ↦ e_ie_iᵀH - H u_iu_iᵀ` on `vec H`). -/
def quadraticCoefficient {n d : ℕ} (U : Frame n d) (i : Fin n) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  Matrix.kroneckerMap (· * ·) (Matrix.single i i (1 : ℝ)) (1 : Matrix (Fin d) (Fin d) ℝ) -
    Matrix.kroneckerMap (· * ·) (1 : Matrix (Fin n) (Fin n) ℝ)
      (Matrix.vecMulVec (U i) (U i))

/-- Bridge (not in the paper): `𝖬_i` is the library's `horizontalQuadraticCoefficient`. -/
theorem quadraticCoefficient_eq {n d : ℕ} (U : Frame n d) (i : Fin n) :
    quadraticCoefficient U i = Smooth.horizontalQuadraticCoefficient U i := by
  ext ⟨a, b⟩ ⟨a', b'⟩
  simp only [quadraticCoefficient, Smooth.horizontalQuadraticCoefficient, Matrix.sub_apply,
    Matrix.kroneckerMap_apply, Matrix.kronecker, Matrix.diagonal_apply, Prod.mk.injEq,
    Matrix.single_apply, Matrix.one_apply]
  by_cases ha : a = a' <;> by_cases hb : b = b' <;> by_cases hi : i = a <;> simp_all [eq_comm]

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
  have hU := hs.parseval
  have hd0 := hs.pos
  have hn0 : 0 < n := by have := hs.density; omega
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn0
  have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hd0
  have h2dn : 2 * (d : ℝ) ≤ n := by exact_mod_cast hs.density
  have ha : 0 < (d : ℝ) / n := div_pos hdR hnR
  have hp : ∀ i, 0 < rowNormSq U i := fun i =>
    lt_of_lt_of_le (by positivity) (hs.rows i).1
  have hvar : ∀ i, ∫ g, diagMap U (moderateNoise U ρ g) i ^ 2 ∂gaussAmb n d ≤
      ρ * rowNormSq U i / n := by
    intro i
    obtain ⟨h1, h2⟩ := lem_filter_b U hU hp hρ (Pi.single i 1)
    have hl : ∀ g, ∑ j, (Pi.single i (1 : ℝ) : Fin n → ℝ) j * diagMap U (moderateNoise U ρ g) j =
        diagMap U (moderateNoise U ρ g) i := fun g => by simp [Pi.single_apply]
    have hr : ∑ j, rowNormSq U j * (Pi.single i (1 : ℝ) : Fin n → ℝ) j ^ 2 = rowNormSq U i := by
      simp [Pi.single_apply]
    simp_rw [hl] at h1
    rw [hr] at h2
    rw [h1]
    calc _ ≤ ρ / n * rowNormSq U i := h2
      _ = _ := by ring
  have hvar2 : ∀ i, ρ * rowNormSq U i / n ≤ 3 * ρ * ((d : ℝ) / n) / (2 * n) := by
    intro i
    have := (hs.rows i).2
    calc ρ * rowNormSq U i / n ≤ ρ * (3 * ((d : ℝ) / n) / 2) / n :=
          div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_left this hρ.le) hnR.le
      _ = _ := by ring
  refine ⟨fun i => ⟨hvar i, hvar2 i⟩, fun i => ?_, fun i => ?_, fun i => ?_⟩
  · have hlog : 0 ≤ Real.log (2 * n) := Real.log_nonneg (by
      have : (1 : ℝ) ≤ n := by exact_mod_cast hn0
      linarith)
    have hv : 0 < 3 * ρ * ((d : ℝ) / n) / (2 * n) := by positivity
    have ht := diagMap_tail hU i hv (by positivity) ((hvar i).trans (hvar2 i))
      (u := 3 * Real.sqrt (ρ * ((d : ℝ) / n) * Real.log (2 * n) / n))
    have hsq : (3 * Real.sqrt (ρ * ((d : ℝ) / n) * Real.log (2 * n) / n)) ^ 2 =
        9 * (ρ * ((d : ℝ) / n) * Real.log (2 * n) / n) := by
      rw [mul_pow, Real.sq_sqrt (by positivity)]
      norm_num
    have hexp : -(3 * Real.sqrt (ρ * ((d : ℝ) / n) * Real.log (2 * n) / n)) ^ 2 /
        (2 * (3 * ρ * ((d : ℝ) / n) / (2 * n))) = -(3 * Real.log (2 * n)) := by
      rw [hsq]
      field_simp
      ring
    rw [hexp, exp_neg_three_log hn0] at ht
    exact ht
  · have hpi := (hs.rows i).2
    have hpi0 := (hp i).le
    refine ⟨fun H => ?_, ?_, ?_, ?_⟩
    · rw [quadraticCoefficient_eq]
      exact (Smooth.horizontalQuadraticCoefficient_identity U H i).symm
    · rw [quadraticCoefficient_eq]
      exact Smooth.horizontalQuadraticCoefficient_operator_norm_le U i (hU.leverage_le_one i)
    · rw [quadraticCoefficient_eq]
      exact Smooth.horizontalQuadraticCoefficient_sq_sum_le U i
    · have hsq : (n : ℝ) * rowNormSq U i ^ 2 ≤ 9 / 8 * d := by
        have h1 : rowNormSq U i ^ 2 ≤ (3 * ((d : ℝ) / n) / 2) ^ 2 :=
          pow_le_pow_left₀ hpi0 hpi 2
        have h2 : (n : ℝ) * (3 * ((d : ℝ) / n) / 2) ^ 2 = 9 / 4 * d * ((d : ℝ) / n) := by
          field_simp; norm_num
        have h3 : (d : ℝ) / n ≤ 1 / 2 := by
          rw [div_le_iff₀ hnR]; linarith
        calc (n : ℝ) * rowNormSq U i ^ 2 ≤ (n : ℝ) * (3 * ((d : ℝ) / n) / 2) ^ 2 :=
              mul_le_mul_of_nonneg_left h1 hnR.le
          _ = 9 / 4 * d * ((d : ℝ) / n) := h2
          _ ≤ 9 / 4 * d * (1 / 2) := mul_le_mul_of_nonneg_left h3 (by positivity)
          _ = 9 / 8 * d := by ring
      linarith
  · have hfrob : frobSq (Smooth.horizontalQuadraticCoefficient U i) ≤ 7 * d := by
      have h1 := Smooth.horizontalQuadraticCoefficient_sq_sum_le U i
      have hpi := (hs.rows i).2
      have hpi0 := (hp i).le
      have hsq : (n : ℝ) * rowNormSq U i ^ 2 ≤ 9 / 8 * d := by
        have h1 : rowNormSq U i ^ 2 ≤ (3 * ((d : ℝ) / n) / 2) ^ 2 :=
          pow_le_pow_left₀ hpi0 hpi 2
        have h2 : (n : ℝ) * (3 * ((d : ℝ) / n) / 2) ^ 2 = 9 / 4 * d * ((d : ℝ) / n) := by
          field_simp; norm_num
        have h3 : (d : ℝ) / n ≤ 1 / 2 := by
          rw [div_le_iff₀ hnR]; linarith
        calc (n : ℝ) * rowNormSq U i ^ 2 ≤ (n : ℝ) * (3 * ((d : ℝ) / n) / 2) ^ 2 :=
              mul_le_mul_of_nonneg_left h1 hnR.le
          _ = 9 / 4 * d * ((d : ℝ) / n) := h2
          _ ≤ 9 / 4 * d * (1 / 2) := mul_le_mul_of_nonneg_left h3 (by positivity)
          _ = 9 / 8 * d := by ring
      change ∑ p, ∑ q, Smooth.horizontalQuadraticCoefficient U i p q ^ 2 ≤ 7 * d
      linarith
    exact quadDiag_tail hU hn0 hd0 hρ.le i hfrob hη' (by linarith)

/-- Proof of `lem:sample`, (S3), variance bookkeeping (scalar part).

TeX: "By the proof of \cref{lem:expected-graph}, for $i\ne k$ with $P_{ik}^2\le a/16$ the
unfiltered variance of $Y_{ik}$ is at least $a/(8n)$" -/
theorem sample_S3_unfiltered_scalar {a pi pk Pik : ℝ} (ha : 0 < a) (hpi : a / 2 ≤ pi)
    (hpk : a / 2 ≤ pk) (hpi1 : pi ≤ 3 / 4) (hpk1 : pk ≤ 3 / 4) (hP : Pik ^ 2 ≤ a / 16) :
    a / 8 ≤ pi + pk - 2 * pi * pk - 2 * Pik ^ 2 := by
  have h1 : pi * pk ≤ 3 / 4 * pk := mul_le_mul_of_nonneg_right hpi1 (by linarith)
  have h2 : pi * pk ≤ 3 / 4 * pi := by
    rw [mul_comm]; exact mul_le_mul_of_nonneg_right hpk1 (by linarith)
  linarith

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
  have hU := hs.parseval
  have hd : (0 : ℝ) < d := Nat.cast_pos.mpr hs.pos
  have hn0 : 0 < n := by have := hs.density; have := hs.pos; omega
  have hn : (0 : ℝ) < n := Nat.cast_pos.mpr hn0
  have h2dn : 2 * (d : ℝ) ≤ n := by exact_mod_cast hs.density
  have ha : 0 < (d : ℝ) / n := div_pos hd hn
  have hahalf : (d : ℝ) / n ≤ 1 / 2 := by rw [div_le_iff₀ hn]; linarith
  have hp : ∀ i, 0 < rowNormSq U i := fun i =>
    lt_of_lt_of_le (by positivity) (hs.rows i).1
  have hp34 : ∀ j, rowNormSq U j ≤ 3 / 4 := fun j => by linarith [(hs.rows j).2]
  have hrow := hU.projection_row_squares
  -- the row of `T_{e_j}`
  have hT : ∀ j k, tangentY U (ambientNormal U (Pi.single j 1)) i k =
      (if i = j then frameProjection U j k else 0) + frameProjection U i j *
        (if j = k then 1 else 0) - 2 * (frameProjection U i j * frameProjection U j k) := by
    intro j k
    have hf : ∀ l, |(Pi.single j (1 : ℝ) : Fin n → ℝ) l| ≤ 1 := by
      intro l; by_cases hl : l = j <;> simp [hl]
    rw [(lem_commutator_b U hU (Pi.single j 1) zero_le_one hf).1]
    rw [Matrix.sub_apply, Matrix.add_apply, Matrix.diagonal_mul, Matrix.mul_diagonal,
      Matrix.smul_apply, smul_eq_mul, Matrix.mul_apply]
    simp_rw [Matrix.mul_diagonal]
    simp only [Pi.single_apply]
    rw [Finset.sum_eq_single j]
    · by_cases hij : i = j
      · subst hij
        by_cases hk : i = k
        · subst hk; simp
        · simp [hk, Ne.symm hk]
      · by_cases hjk : j = k
        · subst hjk; simp [hij]
        · simp [hij, Ne.symm hjk, hjk]
    · intro l _ hl; simp [hl]
    · simp
  have hTrow : ∀ j, rowNormSq (tangentY U (ambientNormal U (Pi.single j 1))) i ≤
      3 * ((if i = j then rowNormSq U j else 0) + frameProjection U i j ^ 2 +
        4 * frameProjection U i j ^ 2 * rowNormSq U j) := by
    intro j
    have e1 : ∑ k, (if i = j then frameProjection U j k else 0) ^ 2 =
        if i = j then rowNormSq U j else 0 := by
      split_ifs
      · exact hrow j
      · simp
    have e2 : ∑ k, (frameProjection U i j * (if j = k then (1 : ℝ) else 0)) ^ 2 =
        frameProjection U i j ^ 2 := by
      rw [Finset.sum_eq_single j]
      · simp
      · intro k _ hk; simp [Ne.symm hk]
      · simp
    have e3 : ∑ k, (2 * (frameProjection U i j * frameProjection U j k)) ^ 2 =
        4 * frameProjection U i j ^ 2 * rowNormSq U j := by
      rw [← hrow j, Finset.mul_sum]
      apply Finset.sum_congr rfl; intro k _; ring
    calc rowNormSq (tangentY U (ambientNormal U (Pi.single j 1))) i
        = ∑ k, ((if i = j then frameProjection U j k else 0) + frameProjection U i j *
          (if j = k then 1 else 0) - 2 * (frameProjection U i j * frameProjection U j k)) ^ 2 := by
          unfold rowNormSq; simp_rw [hT]
      _ ≤ ∑ k, 3 * ((if i = j then frameProjection U j k else 0) ^ 2 +
          (frameProjection U i j * (if j = k then 1 else 0)) ^ 2 +
          (2 * (frameProjection U i j * frameProjection U j k)) ^ 2) := by
          apply Finset.sum_le_sum; intro k _
          set x := (if i = j then frameProjection U j k else 0)
          set y := frameProjection U i j * (if j = k then (1 : ℝ) else 0)
          set z := 2 * (frameProjection U i j * frameProjection U j k)
          nlinarith [sq_nonneg (x - y), sq_nonneg (x + z), sq_nonneg (y + z)]
      _ = _ := by
          rw [← Finset.mul_sum, Finset.sum_add_distrib, Finset.sum_add_distrib, e1, e2, e3]
  have hbase : (1 / (n : ℝ)) * ∑ j, rowNormSq (tangentY U (ambientNormal U (Pi.single j 1))) i /
      rowNormSq U j ≤ 6 / ((d : ℝ) / n * n) * (5 * rowNormSq U i) := by
    have hterm : ∀ j, rowNormSq (tangentY U (ambientNormal U (Pi.single j 1))) i /
        rowNormSq U j ≤ 6 / ((d : ℝ) / n) * ((if i = j then rowNormSq U j else 0) +
          frameProjection U i j ^ 2 + 3 * frameProjection U i j ^ 2) := by
      intro j
      have hpj := hp j
      have hinv : 1 / rowNormSq U j ≤ 2 / ((d : ℝ) / n) := by
        rw [div_le_div_iff₀ hpj ha]; linarith [(hs.rows j).1]
      have hnn : 0 ≤ (if i = j then rowNormSq U j else 0) + frameProjection U i j ^ 2 +
          4 * frameProjection U i j ^ 2 * rowNormSq U j := by
        have : 0 ≤ (if i = j then rowNormSq U j else 0) := by split_ifs <;> linarith
        positivity
      calc rowNormSq (tangentY U (ambientNormal U (Pi.single j 1))) i / rowNormSq U j
          = rowNormSq (tangentY U (ambientNormal U (Pi.single j 1))) i * (1 / rowNormSq U j) := by
            ring
        _ ≤ (3 * ((if i = j then rowNormSq U j else 0) + frameProjection U i j ^ 2 +
            4 * frameProjection U i j ^ 2 * rowNormSq U j)) * (2 / ((d : ℝ) / n)) :=
            mul_le_mul (hTrow j) hinv (by positivity) (by positivity)
        _ ≤ (3 * ((if i = j then rowNormSq U j else 0) + frameProjection U i j ^ 2 +
            4 * frameProjection U i j ^ 2 * (3 / 4))) * (2 / ((d : ℝ) / n)) := by
            gcongr; exact hp34 j
        _ = _ := by ring
    have hsum : ∑ j, ((if i = j then rowNormSq U j else 0) + frameProjection U i j ^ 2 +
        3 * frameProjection U i j ^ 2) = 5 * rowNormSq U i := by
      rw [Finset.sum_add_distrib, Finset.sum_add_distrib, ← Finset.mul_sum, hrow i]
      simp
      ring
    calc (1 / (n : ℝ)) * ∑ j, rowNormSq (tangentY U (ambientNormal U (Pi.single j 1))) i /
          rowNormSq U j ≤ (1 / (n : ℝ)) * ∑ j, 6 / ((d : ℝ) / n) * ((if i = j then rowNormSq U j
            else 0) + frameProjection U i j ^ 2 + 3 * frameProjection U i j ^ 2) :=
          mul_le_mul_of_nonneg_left (Finset.sum_le_sum fun j _ => hterm j) (by positivity)
      _ = (1 / (n : ℝ)) * (6 / ((d : ℝ) / n) * (5 * rowNormSq U i)) := by
          rw [← Finset.mul_sum, hsum]
      _ = 6 / ((d : ℝ) / n * n) * (5 * rowNormSq U i) := by
          field_simp
  refine ⟨?_, hTrow, hbase, ?_, ?_, ?_⟩
  · have hc : ((Finset.univ.filter (fun k => (d : ℝ) / n / 16 < frameProjection U i k ^ 2)).card
        : ℝ) ≤ (3 * ((d : ℝ) / n) / 2) / ((d : ℝ) / n / 16) :=
      card_filter_lt_le (fun k => frameProjection U i k ^ 2) (fun k => sq_nonneg _)
        (by positivity) ((hrow i).le.trans (hs.rows i).2)
    have he : (3 * ((d : ℝ) / n) / 2) / ((d : ℝ) / n / 16) = 24 := by field_simp; norm_num
    linarith
  · have hpi := (hs.rows i).2
    rw [show (d : ℝ) / n * n = d by field_simp]
    rw [div_mul_eq_mul_div, div_le_div_iff₀ hd hn]
    have : 6 * (5 * rowNormSq U i) * n ≤ 6 * (5 * (3 * ((d : ℝ) / n) / 2)) * n := by gcongr
    have e : 6 * (5 * (3 * ((d : ℝ) / n) / 2)) * n = 45 * d := by field_simp; ring
    linarith
  · field_simp; ring
  · field_simp

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
  have hU := hs.parseval
  have hd0 : (0 : ℝ) < d := Nat.cast_pos.mpr hs.pos
  have hn0 : 0 < n := by have := hs.density; have := hs.pos; omega
  have hn : (0 : ℝ) < n := Nat.cast_pos.mpr hn0
  have h2dn : 2 * (d : ℝ) ≤ n := by exact_mod_cast hs.density
  have ha : 0 < (d : ℝ) / n := div_pos hd0 hn
  have hp : ∀ i, 0 < rowNormSq U i := fun i =>
    lt_of_lt_of_le (by positivity) (hs.rows i).1
  have hahalf : (d : ℝ) / n ≤ 1 / 2 := by rw [div_le_iff₀ hn]; linarith
  have hp34 : ∀ j, rowNormSq U j ≤ 3 / 4 := fun j => by linarith [(hs.rows j).2]
  have hn2 : 2 * (10 : ℝ) ^ 6 ≤ n := by linarith
  have hnum1 : 1440 * (n : ℝ) / d + 32 * delta0 * n ≤ 65 / 10000 * n := by
    have h1 : 1440 * (n : ℝ) / d ≤ 1440 * n / 10 ^ 6 :=
      div_le_div_of_nonneg_left (by positivity) (by positivity) hd
    have e : 1440 * (n : ℝ) / 10 ^ 6 = 144 / 100000 * n := by ring
    unfold delta0
    linarith
  have hnum2 : 25 + 65 / 10000 * (n : ℝ) ≤ 1 / 100 * n := by linarith
  refine ⟨hn2, hnum1, hnum2, fun i hi => ?_⟩
  have hℓ : Smooth.positiveResidualRowLoss U ρ i ≤ delta0 * ((d : ℝ) / n) := by
    rw [← residualRowLoss_formula_eq U hρ i]
    simp only [exceptionalSet, Finset.mem_filter, Finset.mem_univ, true_and, not_lt] at hi
    exact hi
  obtain ⟨hc1, -, hc3, hc4, hc5, hc6⟩ := sample_S3_counts U hs i
  set T1 := Finset.univ.filter (fun k => (d : ℝ) / n / 16 < frameProjection U i k ^ 2)
  set T2 := Finset.univ.filter (fun k => (d : ℝ) / n / (32 * n) < baseNormalTangentVariance U i k)
  set T3 := Finset.univ.filter
    (fun k => (d : ℝ) / n / (32 * n) < Smooth.positiveResidualEntryLoss U ρ i k)
  have hc : (0 : ℝ) < (d : ℝ) / n / (32 * n) := by positivity
  have hT2 : (T2.card : ℝ) ≤ 1440 * (n : ℝ) / d := by
    have hnn : ∀ k, 0 ≤ baseNormalTangentVariance U i k := fun k => by
      simp only [baseNormalTangentVariance, Matrix.of_apply]
      exact mul_nonneg (by positivity) (Finset.sum_nonneg fun _ _ => sq_nonneg _)
    have hS : ∑ k, baseNormalTangentVariance U i k ≤ 45 / n := by
      rw [baseVariance_row_sum U hs i]; exact hc3.trans hc4
    have h := card_filter_lt_le (fun k => baseNormalTangentVariance U i k) hnn hc hS
    rwa [hc5] at h
  have hT3 : (T3.card : ℝ) ≤ 32 * delta0 * n := by
    have hnn : ∀ k, 0 ≤ Smooth.positiveResidualEntryLoss U ρ i k := fun k =>
      Smooth.positiveResidualEntryLoss_nonneg hU hp ρ i k
    have h := card_filter_lt_le (fun k => Smooth.positiveResidualEntryLoss U ρ i k) hnn hc hℓ
    rwa [hc6] at h
  set X := insert i (T1 ∪ T2 ∪ T3)
  have hX : ∀ k, k ∉ X → k ≠ i ∧ (d : ℝ) / n / (16 * n) ≤
      ∫ g, tangentY U (moderateNoise U ρ g) i k ^ 2 ∂gaussAmb n d := by
    intro k hk
    simp only [X, Finset.mem_insert, Finset.mem_union, not_or, T1, T2, T3, Finset.mem_filter,
      Finset.mem_univ, true_and, not_lt] at hk
    obtain ⟨hki, ⟨hk1, hk2⟩, hk3⟩ := hk
    refine ⟨hki, ?_⟩
    rw [integral_sq_tangentY_eq]
    have hlow := Smooth.retainedTangentEntryVariance_lower hU hp hρ.le i k (Ne.symm hki)
    have hsc := sample_S3_unfiltered_scalar ha (hs.rows i).1 (hs.rows k).1 (hp34 i) (hp34 k)
      hk1
    have hsc' : (d : ℝ) / n / 8 / n ≤ (rowNormSq U i + rowNormSq U k -
        2 * rowNormSq U i * rowNormSq U k - 2 * frameProjection U i k ^ 2) / n :=
      div_le_div_of_nonneg_right hsc hn.le
    have e1 : (d : ℝ) / n / 8 / n = 4 * ((d : ℝ) / n / (32 * n)) := by field_simp; ring
    have e2 : (d : ℝ) / n / (16 * n) = 2 * ((d : ℝ) / n / (32 * n)) := by field_simp; ring
    rw [e2]
    linarith
  have hcard := card_filter_ge_of_compl _ X hX
  have hXc : (X.card : ℝ) ≤ 1 + (24 + 1440 * (n : ℝ) / d + 32 * delta0 * n) := by
    have h1 : X.card ≤ (T1 ∪ T2 ∪ T3).card + 1 := Finset.card_insert_le _ _
    have h2 : (T1 ∪ T2 ∪ T3).card ≤ T1.card + T2.card + T3.card :=
      (Finset.card_union_le _ _).trans (Nat.add_le_add_right (Finset.card_union_le _ _) _)
    have h3 : (X.card : ℝ) ≤ T1.card + T2.card + T3.card + 1 := by exact_mod_cast (h1.trans
      (Nat.add_le_add_right h2 1))
    linarith
  linarith

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
  intro F
  have hU := hs.parseval
  have hd0 := hs.pos
  have hn0 : 0 < n := by have := hs.density; omega
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn0
  have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hd0
  have ha : 0 < (d : ℝ) / n := div_pos hdR hnR
  have hF : F = softCount U ρ t (t * Real.sqrt (((d : ℝ) / n) / n)) φ i :=
    softCount_eq U ρ t _ φ i
  rw [hF]
  refine ⟨integral_softCount_le U hn0 ht hh ha hφ hφ01 hφ0 i
      ((sample_S3_variance U hs hd hρ).2.2.2 i hi), ?_,
    fun g => norm_fderiv_softCount_le hU hn0 hd0 hρ.le ht hh hφ hφ' i g,
    softCount_tail hU hn0 hd0 hρ.le ht hh hφ hφ' i⟩
  have hsq : 4 / 7 ≤ Real.sqrt (2 * Real.pi / 16) := by
    rw [show (4 / 7 : ℝ) = Real.sqrt ((4 / 7) ^ 2) by rw [Real.sqrt_sq (by norm_num)]]
    apply Real.sqrt_le_sqrt
    nlinarith [Real.pi_gt_three]
  rw [div_le_iff₀ (lt_of_lt_of_le (by norm_num) hsq)]
  nlinarith

/-- Proof of `lem:sample`, (S3), the numerics for `h = 1/500`. -/
theorem sample_S3_numerics {n : ℕ} (hn : 100 ≤ n) :
    1 / 100 + 7 * sampleH + 1 / 100 ≤ 4 / 100 ∧
    95 / 100 * (n : ℝ) ≤ (n : ℝ) - 1 - 4 / 100 * n := by
  have hn' : (100 : ℝ) ≤ n := by exact_mod_cast hn
  refine ⟨by unfold sampleH; norm_num, by linarith⟩

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

/-- Auxiliary (for `sample_S4_cross`): the block facts for an arbitrary deterministic `B`. -/
theorem block_cross_aux {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) {ρ t : ℝ}
    (hρ : 0 < ρ) (ht : 0 < t) (B : Finset (Fin n)) :
    (blockJ U B t).PosDef ∧
    (∀ i j, ∑ b, blockOmega U B t i j b ^ 2 =
      (fun b : B => edgeVec i j b) ⬝ᵥ ((blockJ U B t)⁻¹ *ᵥ fun b : B => edgeVec i j b)) ∧
    (∀ i j, ∑ b, blockOmega U B t i j b ^ 2 ≤ 2 / ((d : ℝ) / n * t ^ 2)) ∧
    (∀ (Y : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ), (∀ j, j ∉ B → x j = 0) →
      t * matrixQuadratic (crossLaplacian (frameProjection U) Y) x =
        matrixQuadratic (blockXi U B t Y) (cfc Real.sqrt (blockJ U B t) *ᵥ
          fun b : B => x b.1)) ∧
    ∫ g, frobSq (blockXi U B t (tangentY U (moderateNoise U ρ g))) ∂gaussAmb n d ≤
      16 * (B.card : ℝ) / d ∧
    Integrable (fun g => frobSq (blockXi U B t (tangentY U (moderateNoise U ρ g))))
      (gaussAmb n d) := by
  have hU := hs.parseval
  have hd0 : (0 : ℝ) < d := Nat.cast_pos.mpr hs.pos
  have hn0 : 0 < n := by have := hs.density; have := hs.pos; omega
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn0
  have ha : 0 < (d : ℝ) / n := div_pos hd0 hnR
  have hc : 0 < (d : ℝ) / n * t ^ 2 := by positivity
  obtain ⟨hJ, hJlow⟩ := block_posDef hU B hc
  change (blockJ U B t).PosDef at hJ
  change ∀ y : B → ℝ, (d : ℝ) / n * t ^ 2 * (y ⬝ᵥ y) ≤ y ⬝ᵥ (blockJ U B t *ᵥ y) at hJlow
  set eB : Fin n → Fin n → B → ℝ := fun i j b => edgeVec i j b with heB
  have hω : ∀ i j, ∑ b, blockOmega U B t i j b ^ 2 = eB i j ⬝ᵥ ((blockJ U B t)⁻¹ *ᵥ eB i j) := by
    intro i j
    rw [← invSqrt_norm_sq hJ (eB i j)]
    simp only [blockOmega, dotProduct, pow_two]
    rfl
  have hωle : ∀ i j, ∑ b, blockOmega U B t i j b ^ 2 ≤ 2 / ((d : ℝ) / n * t ^ 2) := by
    intro i j
    rw [hω]
    refine (dot_inv_le hJ hc hJlow _).trans ?_
    apply div_le_div_of_nonneg_right _ hc.le
    have := edgeVec_sq_sum_le B i j
    simpa [dotProduct, pow_two, eB] using this
  have hid : ∀ (Y : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ), (∀ j, j ∉ B → x j = 0) →
      t * matrixQuadratic (crossLaplacian (frameProjection U) Y) x =
        matrixQuadratic (blockXi U B t Y) (cfc Real.sqrt (blockJ U B t) *ᵥ
          fun b : B => x b.1) := by
    intro Y x hx
    rw [crossLaplacian, matrixQuadratic_sum_rankOne, blockXi, matrixQuadratic_sum_rankOne,
      Finset.mul_sum]
    apply Finset.sum_congr rfl; intro i _
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl; intro j _
    split_ifs
    · have h1 : (cfc Real.sqrt (blockJ U B t) *ᵥ fun b : B => x b.1) ⬝ᵥ blockOmega U B t i j =
          (fun b : B => x b.1) ⬝ᵥ eB i j := sqrtM_invSqrt_dot hJ _ _
      rw [h1, dotProduct_subtype_eq B x (edgeVec i j) hx]
      ring
    · simp
  -- entries of `Ξ`
  have hentry : ∀ (Y : Matrix (Fin n) (Fin n) ℝ) (b c : B), blockXi U B t Y b c =
      ∑ i, ∑ j, if i < j then (2 * t * frameProjection U i j * blockOmega U B t i j b *
        blockOmega U B t i j c) * Y i j else 0 := by
    intro Y b c
    simp only [blockXi, Matrix.sum_apply]
    apply Finset.sum_congr rfl; intro i _
    apply Finset.sum_congr rfl; intro j _
    split_ifs
    · simp [Matrix.vecMulVec_apply]; ring
    · simp
  set γ : B → B → Fin n → Fin n → ℝ := fun b c i j =>
    2 * t * frameProjection U i j * blockOmega U B t i j b * blockOmega U B t i j c
  have hint : ∀ b c : B, Integrable (fun g =>
      (blockXi U B t (tangentY U (moderateNoise U ρ g)) b c) ^ 2) (gaussAmb n d) := by
    intro b c
    simp_rw [hentry]
    exact integrable_upper_sum_sq U ρ (γ b c)
  have hEbc : ∀ b c : B, ∫ g, (blockXi U B t (tangentY U (moderateNoise U ρ g)) b c) ^ 2
      ∂gaussAmb n d ≤ 2 / n * ∑ i, ∑ j, if i < j then γ b c i j ^ 2 else 0 := by
    intro b c
    simp_rw [hentry]
    exact integral_upper_sum_sq_le hU hρ.le (γ b c)
  have hfrob_int : Integrable (fun g => frobSq (blockXi U B t (tangentY U (moderateNoise U ρ g))))
      (gaussAmb n d) := by
    unfold frobSq
    exact integrable_finsetSum _ fun b _ => integrable_finsetSum _ fun c _ => hint b c
  have hE : ∫ g, frobSq (blockXi U B t (tangentY U (moderateNoise U ρ g))) ∂gaussAmb n d =
      ∑ b, ∑ c, ∫ g, (blockXi U B t (tangentY U (moderateNoise U ρ g)) b c) ^ 2 ∂gaussAmb n d := by
    unfold frobSq
    rw [integral_finsetSum _ fun b _ => integrable_finsetSum _ fun c _ => hint b c]
    apply Finset.sum_congr rfl; intro b _
    rw [integral_finsetSum _ fun c _ => hint b c]
  -- the deterministic sum
  set W : Fin n → Fin n → ℝ := fun i j => ∑ b, blockOmega U B t i j b ^ 2
  have hγsum : ∀ i j, ∑ b, ∑ c, γ b c i j ^ 2 = 4 * t ^ 2 * frameProjection U i j ^ 2 * W i j ^ 2 := by
    intro i j
    simp only [γ, W, pow_two, Finset.sum_mul, Finset.mul_sum]
    apply Finset.sum_congr rfl; intro b _
    apply Finset.sum_congr rfl; intro c _
    ring
  have hW0 : ∀ i j, 0 ≤ W i j := fun i j => Finset.sum_nonneg fun b _ => sq_nonneg _
  have htrace : ∑ i, ∑ j, (if i < j then frameProjection U i j ^ 2 * W i j else 0) ≤ B.card := by
    have h1 : ∀ i j, W i j = ∑ b, ∑ c, eB i j b * ((blockJ U B t)⁻¹ b c * eB i j c) := by
      intro i j
      simp only [W, hω, dotProduct, Matrix.mulVec, Finset.mul_sum]
    have h2 : ∑ i, ∑ j, (if i < j then frameProjection U i j ^ 2 * W i j else 0) =
        ∑ b, ∑ c, (blockJ U B t)⁻¹ b c *
          ((projectionLaplacian (frameProjection U)).submatrix (↑) (↑) : Matrix B B ℝ) b c := by
      have hR : ∀ b c : B, (blockJ U B t)⁻¹ b c *
          ((projectionLaplacian (frameProjection U)).submatrix (↑) (↑) : Matrix B B ℝ) b c =
          ∑ i, ∑ j, if i < j then frameProjection U i j ^ 2 *
            (eB i j b * ((blockJ U B t)⁻¹ b c * eB i j c)) else 0 := by
        intro b c
        rw [block_laplacian_apply hU B, Finset.mul_sum]
        apply Finset.sum_congr rfl; intro i _
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl; intro j _
        split_ifs
        · simp only [eB]; ring
        · simp
      have hL : ∀ i j, (if i < j then frameProjection U i j ^ 2 * W i j else 0) =
          ∑ b, ∑ c, if i < j then frameProjection U i j ^ 2 *
            (eB i j b * ((blockJ U B t)⁻¹ b c * eB i j c)) else 0 := by
        intro i j
        rw [h1, Finset.mul_sum]
        simp_rw [Finset.mul_sum]
        exact ite_sum_sum _ _
      simp_rw [hR, hL]
      exact sum4_comm _
    have h3 : ((projectionLaplacian (frameProjection U)).submatrix (↑) (↑) : Matrix B B ℝ) =
        blockJ U B t - ((d : ℝ) / n * t ^ 2) • (1 : Matrix B B ℝ) := by
      simp [blockJ]
    rw [h2, h3]
    have := trace_inv_mul_le hJ hc.le
    simpa using this
  have hsum : ∑ b, ∑ c, 2 / (n : ℝ) * ∑ i, ∑ j, (if i < j then γ b c i j ^ 2 else 0) ≤
      16 * (B.card : ℝ) / d := by
    have e1 : ∑ b, ∑ c, 2 / (n : ℝ) * ∑ i, ∑ j, (if i < j then γ b c i j ^ 2 else 0) =
        2 / (n : ℝ) * ∑ i, ∑ j, (if i < j then 4 * t ^ 2 * frameProjection U i j ^ 2 *
          W i j ^ 2 else 0) := by
      simp_rw [← Finset.mul_sum]
      congr 1
      rw [sum4_comm]
      apply Finset.sum_congr rfl; intro i _
      apply Finset.sum_congr rfl; intro j _
      rw [← hγsum i j, ite_sum_sum]
    have e2 : ∀ i j, (if i < j then 4 * t ^ 2 * frameProjection U i j ^ 2 * W i j ^ 2 else 0) ≤
        8 / ((d : ℝ) / n) * (if i < j then frameProjection U i j ^ 2 * W i j else 0) := by
      intro i j
      split_ifs
      · have hWle := hωle i j
        have : 4 * t ^ 2 * frameProjection U i j ^ 2 * W i j ^ 2 ≤
            4 * t ^ 2 * frameProjection U i j ^ 2 * W i j * (2 / ((d : ℝ) / n * t ^ 2)) := by
          rw [pow_two (W i j), ← mul_assoc]
          exact mul_le_mul_of_nonneg_left hWle (by have := hW0 i j; positivity)
        refine this.trans (le_of_eq ?_)
        field_simp
        ring
      · simp
    rw [e1]
    calc 2 / (n : ℝ) * ∑ i, ∑ j, (if i < j then 4 * t ^ 2 * frameProjection U i j ^ 2 *
          W i j ^ 2 else 0)
        ≤ 2 / (n : ℝ) * ∑ i, ∑ j, 8 / ((d : ℝ) / n) *
          (if i < j then frameProjection U i j ^ 2 * W i j else 0) :=
          mul_le_mul_of_nonneg_left (Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ =>
            e2 i j) (by positivity)
      _ = 2 / (n : ℝ) * (8 / ((d : ℝ) / n)) *
          ∑ i, ∑ j, (if i < j then frameProjection U i j ^ 2 * W i j else 0) := by
          simp_rw [← Finset.mul_sum]; ring
      _ ≤ 2 / (n : ℝ) * (8 / ((d : ℝ) / n)) * B.card :=
          mul_le_mul_of_nonneg_left htrace (by positivity)
      _ = 16 * (B.card : ℝ) / d := by field_simp; ring
  refine ⟨hJ, hω, hωle, hid, ?_, hfrob_int⟩
  rw [hE]
  exact (Finset.sum_le_sum fun b _ => Finset.sum_le_sum fun c _ => hEbc b c).trans hsum

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
  obtain ⟨-, -, hωle, hid, hE, hint⟩ := block_cross_aux U hs hρ ht (exceptionalSet U ρ)
  refine ⟨hωle, fun c => integral_upper_sum_sq_le hs.parseval hρ.le c, hid, hE, ?_⟩
  have hη2 : 0 < η' ^ 2 := by positivity
  have hm := mul_meas_ge_le_integral_of_nonneg (μ := gaussAmb n d)
    (ae_of_all _ fun g => frobSq_nonneg _) hint (η' ^ 2)
  have hsub : {g : FrameVector n d | η' ^ 2 <
      frobSq (blockXi U (exceptionalSet U ρ) t (tangentY U (moderateNoise U ρ g)))} ⊆
      {g | η' ^ 2 ≤ frobSq (blockXi U (exceptionalSet U ρ) t
        (tangentY U (moderateNoise U ρ g)))} := by
    intro g hg; simp only [Set.mem_setOf_eq] at hg ⊢; exact hg.le
  have hd0 : (0 : ℝ) < d := Nat.cast_pos.mpr hs.pos
  calc (gaussAmb n d).real {g | η' ^ 2 <
        frobSq (blockXi U (exceptionalSet U ρ) t (tangentY U (moderateNoise U ρ g)))}
      ≤ (gaussAmb n d).real {g | η' ^ 2 ≤ frobSq (blockXi U (exceptionalSet U ρ) t
        (tangentY U (moderateNoise U ρ g)))} := measureReal_mono hsub
    _ ≤ (16 * ((exceptionalSet U ρ).card : ℝ) / d) / η' ^ 2 := by
        rw [le_div_iff₀ hη2, mul_comm]
        exact hm.trans hE
    _ = _ := by rw [div_div]

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
  intro B Λc
  have hU := hs.parseval
  have hd0 : (0 : ℝ) < d := Nat.cast_pos.mpr hs.pos
  have hd1 : (1 : ℝ) ≤ d := by exact_mod_cast hs.pos
  have hn0 : 0 < n := by have := hs.density; have := hs.pos; omega
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn0
  have h2dn : 2 * (d : ℝ) ≤ n := by exact_mod_cast hs.density
  have ha : 0 < (d : ℝ) / n := div_pos hd0 hnR
  have ha1 : (d : ℝ) / n ≤ 1 := by rw [div_le_one hnR]; linarith
  have hp : ∀ i, 0 < rowNormSq U i := fun i =>
    lt_of_lt_of_le (by positivity) (hs.rows i).1
  set R := tangentF U ρ
  set Y : FrameVector n d → Matrix (Fin n) (Fin n) ℝ := fun g => tangentY U (moderateNoise U ρ g)
  have hYsym : ∀ g, (Y g).transpose = Y g := by
    intro g
    simp only [Y, tangentY, Matrix.transpose_add, Matrix.transpose_mul, Matrix.transpose_transpose]
    abel
  have hY : ∀ g (i j : Fin n), Y g i j = Matrix.toEuclideanLin R g (i, j) :=
    fun g i j => tangentY_moderateNoise_apply U ρ g i j
  have hRop := opNorm_tangentF_sq hU hρ.le
  -- row moments
  have hrow : ∀ i, ∫ g, rowNormSq (tangentY U (moderateNoise U ρ g)) i ∂gaussAmb n d ≤
      (d : ℝ) / n * (1 - rowNormSq U i) + (1 - (d : ℝ) / n) * rowNormSq U i ∧
      (d : ℝ) / n * (1 - rowNormSq U i) + (1 - (d : ℝ) / n) * rowNormSq U i ≤
        3 * ((d : ℝ) / n) := by
    intro i
    refine ⟨integral_rowNormSq_tangentY_le hU hp hρ i hn0, ?_⟩
    have := (hs.rows i).2
    have := (hp i).le
    nlinarith
  -- the diagonal factor
  have hdiag : ∀ b : B, ∫ g, Λc g b b ^ 2 ∂gaussAmb n d ≤ 2 * (2 / n) * (3 * ((d : ℝ) / n)) := by
    intro b
    set D : Matrix (Fin n) (Fin n × Fin d) ℝ :=
      Matrix.of fun j p => if j = (b : Fin n) then 0 else R ((b : Fin n), j) p
    have hDg : ∀ g, ‖Matrix.toEuclideanLin D g‖ ^ 2 = sqLaplacian (Y g) b b := by
      intro g
      rw [sqLaplacian_diag _ (hYsym g), EuclideanSpace.real_norm_sq_eq]
      apply Finset.sum_congr rfl; intro j _
      simp only [D, Matrix.toLpLin_apply, Matrix.mulVec, dotProduct, Matrix.of_apply, hY]
      split_ifs <;> simp
    have hDop : opNorm D ^ 2 ≤ 2 / n := by
      have hc : opNorm D ≤ Real.sqrt (2 / n) := by
        apply opNorm_le_of_norm_sq_le _ (Real.sqrt_nonneg _)
        intro g
        rw [Real.sq_sqrt (by positivity)]
        have h1 : ‖Matrix.toEuclideanLin D g‖ ^ 2 ≤ ‖Matrix.toEuclideanLin R g‖ ^ 2 := by
          rw [EuclideanSpace.real_norm_sq_eq, EuclideanSpace.real_norm_sq_eq, Fintype.sum_prod_type]
          refine le_trans ?_ (Finset.single_le_sum (f := fun i => ∑ j : Fin n,
            (Matrix.toEuclideanLin R g (i, j)) ^ 2) (fun i _ => Finset.sum_nonneg fun j _ =>
              sq_nonneg _) (Finset.mem_univ (b : Fin n)))
          apply Finset.sum_le_sum; intro j _
          simp only [D, Matrix.toLpLin_apply, Matrix.mulVec, dotProduct, Matrix.of_apply]
          split_ifs
          · simp only [zero_mul, Finset.sum_const_zero]
            nlinarith [sq_nonneg (∑ x, R ((b : Fin n), j) x * g x)]
          · exact le_rfl
        have h2 : ‖Matrix.toEuclideanLin R g‖ ^ 2 ≤ opNorm R ^ 2 * ‖g‖ ^ 2 := by
          rw [← mul_pow]
          exact pow_le_pow_left₀ (norm_nonneg _)
            ((Matrix.toEuclideanLin R).toContinuousLinearMap.le_opNorm g) 2
        nlinarith [sq_nonneg ‖g‖]
      calc opNorm D ^ 2 ≤ Real.sqrt (2 / n) ^ 2 := pow_le_pow_left₀ (opNorm_nonneg' _) hc 2
        _ = 2 / n := Real.sq_sqrt (by positivity)
    have hΛ : ∀ g, Λc g b b = ‖Matrix.toEuclideanLin D g‖ ^ 2 -
        ∫ g', ‖Matrix.toEuclideanLin D g'‖ ^ 2 ∂gaussAmb n d := by
      intro g
      simp only [Λc, Matrix.sub_apply, Matrix.submatrix_apply, Matrix.of_apply]
      rw [hDg g]
      congr 1
      apply integral_congr_ae
      exact ae_of_all _ fun g' => (hDg g').symm
    have hmean : ∫ g, ‖Matrix.toEuclideanLin D g‖ ^ 2 ∂gaussAmb n d ≤ 3 * ((d : ℝ) / n) := by
      have h1 : ∀ g, ‖Matrix.toEuclideanLin D g‖ ^ 2 ≤ rowNormSq (Y g) b := by
        intro g
        rw [hDg g, sqLaplacian_diag _ (hYsym g)]
        apply Finset.sum_le_sum; intro j _
        split_ifs
        · positivity
        · exact le_rfl
      have hi1 : Integrable (fun g => ‖Matrix.toEuclideanLin D g‖ ^ 2) (gaussAmb n d) :=
        (memLp_norm_sq_gaussianImage D).integrable (by norm_num)
      have hi2 : Integrable (fun g => rowNormSq (Y g) b) (gaussAmb n d) := by
        simp only [Y, rowNormSq]
        simp_rw [tangentY_moderateNoise_apply]
        exact integrable_finsetSum _ fun j _ =>
          (memLp_sq_gaussianCoordinate R ((b : Fin n), j)).integrable (by norm_num)
      exact (integral_mono hi1 hi2 h1).trans ((hrow b).1.trans (hrow b).2)
    simp_rw [hΛ]
    refine (centered_norm_sq_var_le D hDop).trans ?_
    exact mul_le_mul_of_nonneg_left hmean (by positivity)
  have hoff : ∀ b c : B, b ≠ c → ∫ g, Λc g b c ^ 2 ∂gaussAmb n d ≤ 8 / (n : ℝ) ^ 2 := by
    intro b c hbc
    have hbc' : (b : Fin n) ≠ (c : Fin n) := fun h => hbc (Subtype.ext h)
    set D : Matrix (Fin 1) (Fin n × Fin d) ℝ := Matrix.of fun _ p => R ((b : Fin n), c) p
    have hDg : ∀ g, ‖Matrix.toEuclideanLin D g‖ ^ 2 = -sqLaplacian (Y g) b c := by
      intro g
      rw [sqLaplacian_offdiag _ (hYsym g) hbc', neg_neg, EuclideanSpace.real_norm_sq_eq]
      simp only [Finset.univ_unique, Finset.sum_singleton, D, Matrix.toLpLin_apply,
        Matrix.mulVec, dotProduct, Matrix.of_apply, hY]
    have hDop : opNorm D ^ 2 ≤ 2 / n := by
      have hc : opNorm D ≤ Real.sqrt (2 / n) := by
        apply opNorm_le_of_norm_sq_le _ (Real.sqrt_nonneg _)
        intro g
        rw [Real.sq_sqrt (by positivity)]
        have h1 : ‖Matrix.toEuclideanLin D g‖ ^ 2 ≤ ‖Matrix.toEuclideanLin R g‖ ^ 2 := by
          rw [EuclideanSpace.real_norm_sq_eq, EuclideanSpace.real_norm_sq_eq]
          simp only [Finset.univ_unique, Finset.sum_singleton, D, Matrix.toLpLin_apply,
            Matrix.mulVec, dotProduct, Matrix.of_apply]
          exact Finset.single_le_sum (f := fun p => (∑ q, R p q * g q) ^ 2)
            (fun p _ => sq_nonneg _) (Finset.mem_univ ((b : Fin n), (c : Fin n)))
        have h2 : ‖Matrix.toEuclideanLin R g‖ ^ 2 ≤ opNorm R ^ 2 * ‖g‖ ^ 2 := by
          rw [← mul_pow]
          exact pow_le_pow_left₀ (norm_nonneg _)
            ((Matrix.toEuclideanLin R).toContinuousLinearMap.le_opNorm g) 2
        nlinarith [sq_nonneg ‖g‖]
      calc opNorm D ^ 2 ≤ Real.sqrt (2 / n) ^ 2 := pow_le_pow_left₀ (opNorm_nonneg' _) hc 2
        _ = 2 / n := Real.sq_sqrt (by positivity)
    have hΛ : ∀ g, Λc g b c ^ 2 = (‖Matrix.toEuclideanLin D g‖ ^ 2 -
        ∫ g', ‖Matrix.toEuclideanLin D g'‖ ^ 2 ∂gaussAmb n d) ^ 2 := by
      intro g
      have e : Λc g b c = -(‖Matrix.toEuclideanLin D g‖ ^ 2 -
          ∫ g', ‖Matrix.toEuclideanLin D g'‖ ^ 2 ∂gaussAmb n d) := by
        simp only [Λc, Matrix.sub_apply, Matrix.submatrix_apply, Matrix.of_apply]
        rw [hDg g]
        have : ∫ g', sqLaplacian (tangentY U (moderateNoise U ρ g')) ↑b ↑c ∂gaussAmb n d =
            -∫ g', ‖Matrix.toEuclideanLin D g'‖ ^ 2 ∂gaussAmb n d := by
          rw [← integral_neg]
          apply integral_congr_ae
          exact ae_of_all _ fun g' => by
            have := hDg g'
            simp only [Y] at this ⊢
            linarith
        rw [this]; ring
      rw [e, neg_sq]
    have hmean : ∫ g, ‖Matrix.toEuclideanLin D g‖ ^ 2 ∂gaussAmb n d ≤ 2 / n := by
      rw [integral_norm_sq_gaussianImage]
      simp only [Finset.univ_unique, Finset.sum_singleton, D, Matrix.of_apply]
      have h2 := pow_le_pow_left₀ (norm_nonneg _) (gaussianCoordinate_norm_le R
        ((b : Fin n), (c : Fin n))) 2
      have h3 : ‖gaussianCoordinate R ((b : Fin n), (c : Fin n))‖ ^ 2 =
          ∑ q, R ((b : Fin n), (c : Fin n)) q ^ 2 := by
        rw [← integral_sq_dual_stdGaussian]
        simp only [gaussianCoordinate_apply]
        rw [integral_sq_gaussianCoordinate_eq_covariance]
        simp [Matrix.mul_apply, pow_two]
      rw [← h3]
      exact h2.trans hRop
    simp_rw [hΛ]
    refine (centered_norm_sq_var_le D hDop).trans ?_
    calc 2 * (2 / (n : ℝ)) * ∫ g, ‖Matrix.toEuclideanLin D g‖ ^ 2 ∂gaussAmb n d
        ≤ 2 * (2 / (n : ℝ)) * (2 / n) := mul_le_mul_of_nonneg_left hmean (by positivity)
      _ = 8 / (n : ℝ) ^ 2 := by ring
  -- integrability of the entries
  have hint : ∀ b c : B, Integrable (fun g => Λc g b c ^ 2) (gaussAmb n d) := by
    intro b c
    have hentry : ∀ g, Λc g b c = sqLaplacian (Y g) b c -
        ∫ g', sqLaplacian (Y g') b c ∂gaussAmb n d := fun g => by
      simp only [Λc, Matrix.sub_apply, Matrix.submatrix_apply, Matrix.of_apply, Y]
    simp_rw [hentry]
    by_cases hbc : (b : Fin n) = c
    · rw [← hbc]
      set D : Matrix (Fin n) (Fin n × Fin d) ℝ :=
        Matrix.of fun j p => if j = (b : Fin n) then 0 else R ((b : Fin n), j) p
      have hDg : ∀ g, sqLaplacian (Y g) b b = ‖Matrix.toEuclideanLin D g‖ ^ 2 := by
        intro g
        rw [sqLaplacian_diag _ (hYsym g), EuclideanSpace.real_norm_sq_eq]
        apply Finset.sum_congr rfl; intro j _
        simp only [D, Matrix.toLpLin_apply, Matrix.mulVec, dotProduct, Matrix.of_apply, hY]
        split_ifs <;> simp
      simp_rw [hDg]
      exact integrable_centered_norm_sq_sq D _
    · set D : Matrix (Fin 1) (Fin n × Fin d) ℝ := Matrix.of fun _ p => R ((b : Fin n), c) p
      have hDg : ∀ g, sqLaplacian (Y g) b c = -‖Matrix.toEuclideanLin D g‖ ^ 2 := by
        intro g
        rw [sqLaplacian_offdiag _ (hYsym g) hbc, EuclideanSpace.real_norm_sq_eq]
        simp only [Finset.univ_unique, Finset.sum_singleton, D, Matrix.toLpLin_apply,
          Matrix.mulVec, dotProduct, Matrix.of_apply, hY]
      simp_rw [hDg]
      have := integrable_centered_norm_sq_sq D
        (-∫ g', -‖Matrix.toEuclideanLin D g'‖ ^ 2 ∂gaussAmb n d)
      refine this.congr (ae_of_all _ fun g => ?_)
      simp only
      ring
  have hentry_le : ∀ b c : B, ∫ g, Λc g b c ^ 2 ∂gaussAmb n d ≤ 20 * ((d : ℝ) / n) / n := by
    intro b c
    by_cases hbc : b = c
    · subst hbc
      refine (hdiag b).trans ?_
      have : 2 * (2 / (n : ℝ)) * (3 * ((d : ℝ) / n)) = 12 * ((d : ℝ) / n) / n := by ring
      rw [this]
      exact div_le_div_of_nonneg_right (by linarith) hnR.le
    · refine (hoff b c hbc).trans ?_
      rw [div_le_div_iff₀ (by positivity) hnR, show (n : ℝ) ^ 2 = n * n by ring]
      have : 8 * (n : ℝ) ≤ 20 * ((d : ℝ) / n) * (n * n) := by
        rw [show 20 * ((d : ℝ) / n) * (n * n) = 20 * d * n by field_simp]
        nlinarith
      linarith
  have hE : ∫ g, frobSq (Λc g) ∂gaussAmb n d ≤ 20 * (B.card : ℝ) ^ 2 * ((d : ℝ) / n) / n := by
    have h1 : ∫ g, frobSq (Λc g) ∂gaussAmb n d = ∑ b, ∑ c, ∫ g, Λc g b c ^ 2 ∂gaussAmb n d := by
      unfold frobSq
      rw [integral_finsetSum _ fun b _ => integrable_finsetSum _ fun c _ => hint b c]
      apply Finset.sum_congr rfl; intro b _
      rw [integral_finsetSum _ fun c _ => hint b c]
    rw [h1]
    calc ∑ b, ∑ c, ∫ g, Λc g b c ^ 2 ∂gaussAmb n d ≤ ∑ _b : B, ∑ _c : B, 20 * ((d : ℝ) / n) / n :=
          Finset.sum_le_sum fun b _ => Finset.sum_le_sum fun c _ => hentry_le b c
      _ = 20 * (B.card : ℝ) ^ 2 * ((d : ℝ) / n) / n := by
          simp only [Finset.sum_const, Finset.card_univ, Fintype.card_coe, nsmul_eq_mul]
          ring
  have heq : 20 * (B.card : ℝ) ^ 2 * ((d : ℝ) / n) / n =
      20 * (B.card : ℝ) ^ 2 * ((d : ℝ) / n) ^ 2 / d := by
    field_simp
  refine ⟨hrow, fun b => ⟨hdiag b, by ring⟩, hoff, hE, heq, ?_⟩
  -- Markov
  have hfint : Integrable (fun g => frobSq (Λc g)) (gaussAmb n d) := by
    unfold frobSq
    exact integrable_finsetSum _ fun b _ => integrable_finsetSum _ fun c _ => hint b c
  have hu : 0 < (η' * ((d : ℝ) / n)) ^ 2 := by positivity
  have hsub : {g | η' * ((d : ℝ) / n) < Real.sqrt (frobSq (Λc g))} ⊆
      {g | (η' * ((d : ℝ) / n)) ^ 2 ≤ frobSq (Λc g)} := by
    intro g hg
    simp only [Set.mem_setOf_eq] at hg ⊢
    exact ((Real.lt_sqrt (by positivity)).mp hg).le
  have hm := mul_meas_ge_le_integral_of_nonneg (μ := gaussAmb n d)
    (ae_of_all _ fun g => frobSq_nonneg (Λc g)) hfint ((η' * ((d : ℝ) / n)) ^ 2)
  calc (gaussAmb n d).real {g | η' * ((d : ℝ) / n) < Real.sqrt (frobSq (Λc g))}
      ≤ (gaussAmb n d).real {g | (η' * ((d : ℝ) / n)) ^ 2 ≤ frobSq (Λc g)} :=
        measureReal_mono hsub
    _ ≤ (20 * (B.card : ℝ) ^ 2 * ((d : ℝ) / n) / n) / (η' * ((d : ℝ) / n)) ^ 2 := by
        rw [le_div_iff₀ hu, mul_comm]
        exact hm.trans hE
    _ = 20 * (B.card : ℝ) ^ 2 / (d * η' ^ 2) := by
        field_simp

/-! ## Proof of `lem:sample`: assembly -/

/-- `xᵀJ_𝔅x = xᵀLx + at²‖x‖²` for `x` supported on `𝔅`. -/
theorem blockJ_quadratic {n d : ℕ} (U : Frame n d) (B : Finset (Fin n)) (t : ℝ)
    (x : Fin n → ℝ) (hx : ∀ j, j ∉ B → x j = 0) :
    matrixQuadratic (blockJ U B t) (fun b : B => x b) =
      matrixQuadratic (projectionLaplacian (frameProjection U)) x +
        (d : ℝ) / n * t ^ 2 * vectorNormSq x := by
  have h1 : matrixQuadratic (blockJ U B t) (fun b : B => x b) =
      matrixQuadratic ((projectionLaplacian (frameProjection U)).submatrix (↑) (↑) : Matrix B B ℝ)
        (fun b : B => x b) + (d : ℝ) / n * t ^ 2 * ((fun b : B => x b) ⬝ᵥ (fun b : B => x b)) := by
    simp only [blockJ, matrixQuadratic, Matrix.add_apply, mul_add, add_mul, Finset.sum_add_distrib]
    congr 1
    simp only [dotProduct, Finset.mul_sum]
    apply Finset.sum_congr rfl; intro b _
    rw [Finset.sum_eq_single b]
    · simp; ring
    · intro c _ hc; simp [Matrix.one_apply_ne (Ne.symm hc)]
    · simp
  rw [h1, matrixQuadratic_submatrix_eq B _ x hx, dotProduct_subtype_eq B x x hx]
  simp [vectorNormSq, dotProduct, pow_two]

/-- The soft count `F_i` of (S3) with the bump `φ_h`, `h = 1/500`. -/
def sampleSoftCount {n d : ℕ} (U : Frame n d) (ρ t : ℝ) (i : Fin n) (g : FrameVector n d) : ℝ :=
  (1 / (n : ℝ)) * ∑ k ∈ Finset.univ.erase i, bump sampleH
    ((frameProjection U i k + t * tangentY U (moderateNoise U ρ g) i k) /
      (t * Real.sqrt (((d : ℝ) / n) / n)))

/-- The principal `𝔅`-block of `𝓛(Y) - E𝓛(Y)`. -/
def sampleLapBlock {n d : ℕ} (U : Frame n d) (ρ : ℝ) (g : FrameVector n d) :
    Matrix (exceptionalSet U ρ) (exceptionalSet U ρ) ℝ :=
  (sqLaplacian (tangentY U (moderateNoise U ρ g))).submatrix (↑) (↑) -
    Matrix.of fun (b c : exceptionalSet U ρ) => ∫ g', sqLaplacian (tangentY U (moderateNoise U ρ g'))
      (b : Fin n) (c : Fin n) ∂gaussAmb n d

/-- The seven failure events of the proof of `lem:sample`. -/
def sampleBad {n d : ℕ} (U : Frame n d) (ρ t η' : ℝ) : Fin 7 → Set (FrameVector n d) :=
  ![{g | 16 < opNorm (moderateNoise U ρ g)},
    ⋃ i, {g | 3 * ((d : ℝ) / n) < rowNormSq (moderateNoise U ρ g) i},
    ⋃ i, {g | 3 * Real.sqrt (ρ * ((d : ℝ) / n) * Real.log (2 * n) / n) <
      |diagMap U (moderateNoise U ρ g) i|},
    ⋃ i, {g | η' * ((d : ℝ) / n) < |horizontalQuadraticDiagonal U (moderateNoise U ρ g) i -
      ∫ g', horizontalQuadraticDiagonal U (moderateNoise U ρ g') i ∂gaussAmb n d|},
    ⋃ i, {g | i ∉ exceptionalSet U ρ ∧
      ∫ g', sampleSoftCount U ρ t i g' ∂gaussAmb n d + 1 / 100 < sampleSoftCount U ρ t i g},
    {g | η' ^ 2 < frobSq (blockXi U (exceptionalSet U ρ) t (tangentY U (moderateNoise U ρ g)))},
    {g | η' * ((d : ℝ) / n) < Real.sqrt (frobSq (sampleLapBlock U ρ g))}]

/-- The numerical consequences of `d ≥ (10¹²/η'²) log(2n)` used in the budgets. -/
theorem sample_numeric_facts {η' : ℝ} (hη' : 0 < η') (hη'1 : η' ≤ 1 / 32) {n d : ℕ}
    (hd0 : 0 < d) (h2dn : 2 * (d : ℝ) ≤ n) (hA : 10 ^ 12 / η' ^ 2 * Real.log (2 * n) ≤ d) :
    1 ≤ Real.log (2 * n) ∧ Real.log n ≤ Real.log (2 * n) ∧
    10 ^ 12 * Real.log (2 * n) ≤ η' ^ 2 * d ∧ 10 ^ 15 * Real.log (2 * n) ≤ d ∧
    (10 : ℝ) ^ 6 ≤ d ∧ (100 : ℝ) ≤ n := by
  have hd1 : (1 : ℝ) ≤ d := by exact_mod_cast hd0
  have hnR : (0 : ℝ) < n := by linarith
  have hL1 : 1 ≤ Real.log (2 * n) := by
    have h4 : (4 : ℝ) ≤ 2 * n := by linarith
    have h44 := Real.log_le_log (by norm_num) h4
    have hl4 : 1 < Real.log 4 := by
      rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.log_pow]
      have := Real.log_two_gt_d9
      push_cast
      linarith
    linarith
  have hlogn : Real.log n ≤ Real.log (2 * n) := Real.log_le_log hnR (by linarith)
  have hη2 : 0 < η' ^ 2 := by positivity
  have hη2le : η' ^ 2 ≤ 1 / 1024 := by nlinarith
  have hdη : 10 ^ 12 * Real.log (2 * n) ≤ η' ^ 2 * d := by
    have h1 := mul_le_mul_of_nonneg_left hA hη2.le
    have e : η' ^ 2 * (10 ^ 12 / η' ^ 2 * Real.log (2 * n)) = 10 ^ 12 * Real.log (2 * n) := by
      field_simp
    linarith
  have hdL : 10 ^ 15 * Real.log (2 * n) ≤ d := by
    have h1 : (10 : ℝ) ^ 15 ≤ 10 ^ 12 / η' ^ 2 := by
      rw [le_div_iff₀ hη2]; nlinarith
    have h2 := mul_le_mul_of_nonneg_right h1 (by linarith : (0 : ℝ) ≤ Real.log (2 * n))
    linarith
  have hd6 : (10 : ℝ) ^ 6 ≤ d := by nlinarith
  exact ⟨hL1, hlogn, hdη, hdL, hd6, by nlinarith⟩

theorem measureReal_iUnion_le_mul {n : ℕ} {α : Type*} [MeasurableSpace α] (μ : Measure α)
    (E : Fin n → Set α) (c : ℝ) (hE : ∀ i, μ.real (E i) ≤ c) : μ.real (⋃ i, E i) ≤ n * c := by
  calc μ.real (⋃ i, E i) ≤ ∑ i, μ.real (E i) := measureReal_iUnion_fintype_le E
    _ ≤ ∑ _i : Fin n, c := Finset.sum_le_sum fun i _ => hE i
    _ = n * c := by simp

/-- Budgets for (S1). -/
theorem sampleBad_S1 {η' : ℝ} {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) {ρ t : ℝ}
    (hρ : 0 < ρ) (hL1 : 1 ≤ Real.log (2 * n)) (hlogn : Real.log n ≤ Real.log (2 * n))
    (hdL : 10 ^ 15 * Real.log (2 * n) ≤ d) (hn100 : (100 : ℝ) ≤ n) :
    (gaussAmb n d).real (sampleBad U ρ t η' 0) ≤ 1 / 10 ∧
    (gaussAmb n d).real (sampleBad U ρ t η' 1) ≤ 1 / 10 := by
  have hn0 : 0 < n := by have := hs.density; have := hs.pos; omega
  obtain ⟨hS1a, -, hS1c, -⟩ := sample_S1 U hs hρ
  constructor
  · refine hS1a.trans ?_
    have h5 : (5 : ℝ) ≤ Real.exp 5 := by linarith [Real.add_one_le_exp (5 : ℝ)]
    have hpow : (5 : ℝ) ^ n ≤ Real.exp (n * 5) := by
      rw [Real.exp_nat_mul]; exact pow_le_pow_left₀ (by norm_num) h5 n
    have h3 : 1 + 3 * (n : ℝ) ≤ Real.exp (3 * n) := by
      linarith [Real.add_one_le_exp (3 * (n : ℝ))]
    calc 2 * 5 ^ n * Real.exp (-8 * n) ≤ 2 * Real.exp (n * 5) * Real.exp (-8 * n) := by
          gcongr
      _ = 2 / Real.exp (3 * n) := by
          rw [mul_assoc, ← Real.exp_add, div_eq_mul_inv, ← Real.exp_neg]; ring_nf
      _ ≤ 2 / (1 + 3 * n) := div_le_div_of_nonneg_left (by norm_num) (by positivity) h3
      _ ≤ 1 / 10 := by rw [div_le_div_iff₀ (by positivity) (by norm_num)]; linarith
  · refine (measureReal_iUnion_le_mul _ _ _ hS1c).trans ?_
    have := union_budget hn0 (b := (d : ℝ) / 4) (by linarith only [hL1, hlogn, hdL])
    calc (n : ℝ) * (2 * Real.exp (-(d : ℝ) / 4)) = 2 * n * Real.exp (-((d : ℝ) / 4)) := by
          rw [neg_div]; ring
      _ ≤ 1 / 10 := this

/-- Budgets for (S2). -/
theorem sampleBad_S2 {η' : ℝ} (hη' : 0 < η') (hη'1 : η' ≤ 1 / 32) {n d : ℕ} (U : Frame n d)
    (hs : ModerateStanding U) {ρ t : ℝ} (hρ : 0 < ρ) (hL1 : 1 ≤ Real.log (2 * n))
    (hlogn : Real.log n ≤ Real.log (2 * n)) (hdη : 10 ^ 12 * Real.log (2 * n) ≤ η' ^ 2 * d)
    (hn100 : (100 : ℝ) ≤ n) :
    (gaussAmb n d).real (sampleBad U ρ t η' 2) ≤ 1 / 10 ∧
    (gaussAmb n d).real (sampleBad U ρ t η' 3) ≤ 1 / 10 := by
  have hn0 : 0 < n := by have := hs.density; have := hs.pos; omega
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn0
  obtain ⟨-, hS2b, -, hS2d⟩ := sample_S2 U hs hρ hη' hη'1
  constructor
  · refine (measureReal_iUnion_le_mul _ _ _ hS2b).trans ?_
    rw [_root_.zpow_neg, zpow_ofNat]
    rw [show (n : ℝ) * (2 * ((2 * (n : ℝ)) ^ 3)⁻¹) = 1 / (4 * (n : ℝ) ^ 2) by field_simp; ring]
    rw [div_le_div_iff₀ (by positivity) (by norm_num)]
    nlinarith
  · refine (measureReal_iUnion_le_mul _ _ _ hS2d).trans ?_
    have := union_budget hn0 (b := η' ^ 2 * d / 56) (by
      rw [le_div_iff₀ (by norm_num)]; linarith only [hL1, hlogn, hdη])
    calc (n : ℝ) * (2 * Real.exp (-(η' ^ 2 * d / 56))) = 2 * n * Real.exp (-(η' ^ 2 * d / 56)) := by
          ring
      _ ≤ 1 / 10 := this

/-- Budget for (S3). -/
theorem sampleBad_S3 {η' : ℝ} {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) {ρ t : ℝ}
    (hρ : 0 < ρ) (ht : 0 < t) (ht1 : t ≤ 1) (hL1 : 1 ≤ Real.log (2 * n))
    (hlogn : Real.log n ≤ Real.log (2 * n)) (hdL : 10 ^ 15 * Real.log (2 * n) ≤ d)
    (hd6 : (10 : ℝ) ^ 6 ≤ d) :
    (gaussAmb n d).real (sampleBad U ρ t η' 4) ≤ 1 / 10 := by
  have hn0 : 0 < n := by have := hs.density; have := hs.pos; omega
  have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hs.pos
  have hh : 0 < sampleH := by unfold sampleH; norm_num
  have hexp5 : -2 * (1 / 100) ^ 2 / (Real.pi ^ 2 * (4 / (sampleH * Real.sqrt d)) ^ 2) =
      -((d : ℝ) / (2 * 10 ^ 10 * Real.pi ^ 2)) := by
    have hsd : Real.sqrt d ^ 2 = d := Real.sq_sqrt hdR.le
    have e1 : (4 / (sampleH * Real.sqrt d)) ^ 2 = 16 / (sampleH ^ 2 * d) := by
      rw [div_pow, mul_pow, hsd]; norm_num
    rw [e1]; unfold sampleH
    field_simp
    ring
  refine (measureReal_iUnion_le_mul _ _ (2 * Real.exp (-((d : ℝ) / (2 * 10 ^ 10 * Real.pi ^ 2))))
    ?_).trans ?_
  · intro i
    by_cases hi : i ∈ exceptionalSet U ρ
    · have : {g : FrameVector n d | i ∉ exceptionalSet U ρ ∧
          ∫ g', sampleSoftCount U ρ t i g' ∂gaussAmb n d + 1 / 100 <
            sampleSoftCount U ρ t i g} = ∅ := by
        ext g
        simp only [Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false, not_and]
        intro h'; exact absurd hi h'
      rw [this, measureReal_empty]; positivity
    · obtain ⟨-, -, -, h4⟩ := sample_S3_smallball U hs hd6 hρ ht ht1 hh (bump sampleH)
        (contDiff_bump _) (bump_mem _) (fun x hx => bump_eq_one hh hx)
        (fun x hx => bump_eq_zero hh hx) (abs_deriv_bump_le hh) i hi
      rw [← hexp5]
      refine (measureReal_mono ?_).trans h4
      intro g hg
      exact hg.2
  · have hpi : Real.pi ^ 2 ≤ 10 := by nlinarith [Real.pi_lt_d2, Real.pi_pos]
    have hb : Real.log n + 200 ≤ (d : ℝ) / (2 * 10 ^ 10 * Real.pi ^ 2) := by
      rw [le_div_iff₀ (by positivity)]
      have hl0 : 0 ≤ Real.log n + 200 := by
        have := Real.log_natCast_nonneg n; linarith
      have := mul_le_mul_of_nonneg_left hpi hl0
      nlinarith only [this, hL1, hlogn, hdL, hl0]
    have := union_budget hn0 hb
    calc (n : ℝ) * (2 * Real.exp (-((d : ℝ) / (2 * 10 ^ 10 * Real.pi ^ 2)))) =
        2 * n * Real.exp (-((d : ℝ) / (2 * 10 ^ 10 * Real.pi ^ 2))) := by ring
      _ ≤ 1 / 10 := this

/-- Budgets for (S4). -/
theorem sampleBad_S4 {η' : ℝ} (hη' : 0 < η') {n d : ℕ} (U : Frame n d)
    (hs : ModerateStanding U) {ρ t : ℝ} (hρ : 0 < ρ) (ht : 0 < t) (ht1 : t ≤ 1)
    (hL1 : 1 ≤ Real.log (2 * n)) (hdη : 10 ^ 12 * Real.log (2 * n) ≤ η' ^ 2 * d) :
    (gaussAmb n d).real (sampleBad U ρ t η' 5) ≤ 1 / 10 ∧
    (gaussAmb n d).real (sampleBad U ρ t η' 6) ≤ 1 / 10 := by
  have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hs.pos
  obtain ⟨-, -, -, hBcard, hbMax⟩ := exceptionalSet_card U hs hρ
  have hBc : ((exceptionalSet U ρ).card : ℝ) ≤ 12800 := hbMax ▸ hBcard
  have hB0 : (0 : ℝ) ≤ (exceptionalSet U ρ).card := Nat.cast_nonneg _
  have hη2 : 0 < η' ^ 2 := by positivity
  obtain ⟨-, -, -, -, hS4e⟩ := sample_S4_cross U hs hρ ht ht1 hη'
  obtain ⟨-, -, -, -, -, hS4f⟩ := sample_S4_square U hs hρ hη'
  constructor
  · refine hS4e.trans ?_
    rw [div_le_div_iff₀ (by positivity) (by norm_num)]
    nlinarith only [hBc, hdη, hL1, hB0]
  · refine hS4f.trans ?_
    rw [div_le_div_iff₀ (by positivity) (by norm_num)]
    have hB2 : ((exceptionalSet U ρ).card : ℝ) ^ 2 ≤ 12800 ^ 2 := pow_le_pow_left₀ hB0 hBc 2
    nlinarith only [hB2, hdη, hL1]

/-- Off the failure events the sample is good. -/
theorem good_of_not_sampleBad {η' : ℝ} (hη' : 0 < η') {n d : ℕ}
    (U : Frame n d) (hs : ModerateStanding U) {ρ t : ℝ} (hρ : 0 < ρ) (ht : 0 < t) (ht1 : t ≤ 1)
    (hd6 : (10 : ℝ) ^ 6 ≤ d) (hn100 : (100 : ℝ) ≤ n) {g : FrameVector n d}
    (hg : g ∉ ⋃ k, sampleBad U ρ t η' k) : GoodSample U ρ t sampleH η' g := by
  have hU := hs.parseval
  have hd0 := hs.pos
  have hn0 : 0 < n := by have := hs.density; omega
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn0
  have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hd0
  have ha : 0 < (d : ℝ) / n := div_pos hdR hnR
  have hp : ∀ i, 0 < rowNormSq U i := fun i =>
    lt_of_lt_of_le (by positivity) (hs.rows i).1
  have hgk : ∀ k, g ∉ sampleBad U ρ t η' k := fun k hk => hg (Set.mem_iUnion.mpr ⟨k, hk⟩)
  have g1 : ¬ 16 < opNorm (moderateNoise U ρ g) := hgk 0
  have g2 : ∀ i, ¬ 3 * ((d : ℝ) / n) < rowNormSq (moderateNoise U ρ g) i :=
    fun i hi => hgk 1 (Set.mem_iUnion.mpr ⟨i, hi⟩)
  have g3 : ∀ i, ¬ 3 * Real.sqrt (ρ * ((d : ℝ) / n) * Real.log (2 * n) / n) <
      |diagMap U (moderateNoise U ρ g) i| :=
    fun i hi => hgk 2 (Set.mem_iUnion.mpr ⟨i, hi⟩)
  have g4 : ∀ i, ¬ η' * ((d : ℝ) / n) < |horizontalQuadraticDiagonal U (moderateNoise U ρ g) i -
      ∫ g', horizontalQuadraticDiagonal U (moderateNoise U ρ g') i ∂gaussAmb n d| :=
    fun i hi => hgk 3 (Set.mem_iUnion.mpr ⟨i, hi⟩)
  have g5 : ∀ i, i ∉ exceptionalSet U ρ →
      ¬ ∫ g', sampleSoftCount U ρ t i g' ∂gaussAmb n d + 1 / 100 < sampleSoftCount U ρ t i g :=
    fun i hiB hi => hgk 4 (Set.mem_iUnion.mpr ⟨i, hiB, hi⟩)
  have g6 : ¬ η' ^ 2 < frobSq (blockXi U (exceptionalSet U ρ) t
      (tangentY U (moderateNoise U ρ g))) := hgk 5
  have g7 : ¬ η' * ((d : ℝ) / n) < Real.sqrt (frobSq (sampleLapBlock U ρ g)) := hgk 6
  refine ⟨⟨le_of_not_gt g1, fun i => le_of_not_gt (g2 i), fun i => ?_⟩,
    ⟨fun i => le_of_not_gt (g3 i), fun i => le_of_not_gt (g4 i)⟩, fun i hi => ?_,
    fun x hx => ?_⟩
  · -- (S1), third claim
    obtain ⟨-, -, -, hS1d⟩ := sample_S1 U hs hρ
    have hsplit := (tangentY_facts U _ hU ((moderateNoise_spec U hU hp hρ).2.2 g)).1 i
    have hUH := rowNormSq_mul_transpose_le U (moderateNoise U ρ g) i
    have hop : opNorm (moderateNoise U ρ g) ^ 2 ≤ 16 ^ 2 :=
      pow_le_pow_left₀ (opNorm_nonneg' _) (le_of_not_gt g1) 2
    have hpi := (hs.rows i).2
    have hUH' : rowNormSq (U * (moderateNoise U ρ g).transpose) i ≤
        (16 * Real.sqrt (3 * ((d : ℝ) / n) / 2)) ^ 2 := by
      rw [mul_pow, Real.sq_sqrt (by positivity)]
      calc rowNormSq (U * (moderateNoise U ρ g).transpose) i
          ≤ opNorm (moderateNoise U ρ g) ^ 2 * rowNormSq U i := hUH
        _ ≤ 16 ^ 2 * (3 * ((d : ℝ) / n) / 2) :=
          mul_le_mul hop hpi (hp i).le (by positivity)
    have hH : rowNormSq (moderateNoise U ρ g) i ≤ (Real.sqrt (3 * ((d : ℝ) / n))) ^ 2 := by
      rw [Real.sq_sqrt (by positivity)]; exact le_of_not_gt (g2 i)
    have hcross : 0 ≤ 2 * Real.sqrt (3 * ((d : ℝ) / n)) *
        (16 * Real.sqrt (3 * ((d : ℝ) / n) / 2)) := by positivity
    rw [hsplit]
    nlinarith only [hS1d, hUH', hH, hcross]
  · -- (S3)
    have hh : 0 < sampleH := by unfold sampleH; norm_num
    have hn100' : 100 ≤ n := by exact_mod_cast hn100
    have hnum := sample_S3_numerics hn100'
    set s := t * Real.sqrt (((d : ℝ) / n) / n) with hsdef
    have hs0 : 0 < s := by positivity
    have hsb := sample_S3_smallball U hs hd6 hρ ht ht1 hh (bump sampleH)
      (contDiff_bump _) (bump_mem _) (fun x hx => bump_eq_one hh hx)
      (fun x hx => bump_eq_zero hh hx) (abs_deriv_bump_le hh) i hi
    obtain ⟨h1, h2, -, -⟩ := hsb
    have hF : sampleSoftCount U ρ t i g ≤ 4 / 100 := by
      have h0 := le_of_not_gt (g5 i hi)
      have h1' : ∫ g', sampleSoftCount U ρ t i g' ∂gaussAmb n d ≤
          1 / 100 + 4 * sampleH / Real.sqrt (2 * Real.pi / 16) := h1
      linarith only [h0, h1', h2, hnum.1]
    set S := Finset.univ.erase i
    set T := S.filter (fun k => |frameProjection U i k + t * tangentY U (moderateNoise U ρ g) i k|
      < sampleH * s)
    have hT : (T.card : ℝ) ≤ 4 / 100 * n := by
      have hsum : (T.card : ℝ) ≤ ∑ k ∈ S, bump sampleH ((frameProjection U i k +
          t * tangentY U (moderateNoise U ρ g) i k) / s) := by
        calc (T.card : ℝ) = ∑ _k ∈ T, (1 : ℝ) := by simp
          _ = ∑ k ∈ T, bump sampleH ((frameProjection U i k +
              t * tangentY U (moderateNoise U ρ g) i k) / s) := by
              apply Finset.sum_congr rfl; intro k hk
              have hk' := (Finset.mem_filter.mp hk).2
              symm; apply bump_eq_one hh
              rw [abs_div, abs_of_pos hs0, div_le_iff₀ hs0]
              exact hk'.le
          _ ≤ _ := Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _)
              (fun k _ _ => (bump_mem _ _).1)
      have he : sampleSoftCount U ρ t i g = (1 / (n : ℝ)) * ∑ k ∈ S, bump sampleH
          ((frameProjection U i k + t * tangentY U (moderateNoise U ρ g) i k) / s) := rfl
      have hmul : ∑ k ∈ S, bump sampleH ((frameProjection U i k +
          t * tangentY U (moderateNoise U ρ g) i k) / s) ≤ 4 / 100 * n := by
        have h3 := mul_le_mul_of_nonneg_left hF hnR.le
        rw [he] at h3
        have e2 : (n : ℝ) * (1 / (n : ℝ) * ∑ k ∈ S, bump sampleH ((frameProjection U i k +
            t * tangentY U (moderateNoise U ρ g) i k) / s)) = ∑ k ∈ S, bump sampleH
              ((frameProjection U i k + t * tangentY U (moderateNoise U ρ g) i k) / s) := by
          field_simp
        rw [e2] at h3
        linarith only [h3]
      linarith only [hsum, hmul]
    have hcard := Finset.card_filter_add_card_filter_not (s := S)
      (fun k => |frameProjection U i k + t * tangentY U (moderateNoise U ρ g) i k| < sampleH * s)
    have hScard : S.card = n - 1 := by
      rw [Finset.card_erase_of_mem (Finset.mem_univ i), Finset.card_univ, Fintype.card_fin]
    have hG : Finset.univ.filter (fun j => j ≠ i ∧
        sampleH * t * Real.sqrt (((d : ℝ) / n) / n) ≤
          |frameProjection U i j + t * tangentY U (moderateNoise U ρ g) i j|) =
        S.filter (fun k => ¬ |frameProjection U i k + t * tangentY U (moderateNoise U ρ g) i k|
          < sampleH * s) := by
      ext k
      simp only [Finset.mem_filter, Finset.mem_univ, true_and, S, Finset.mem_erase, not_lt,
        hsdef, mul_assoc, and_true]
    change 95 / 100 * (n : ℝ) ≤ ((Finset.univ.filter (fun j => j ≠ i ∧
      sampleH * t * Real.sqrt (((d : ℝ) / n) / n) ≤
        |frameProjection U i j + t * tangentY U (moderateNoise U ρ g) i j|)).card : ℝ)
    rw [hG]
    have h3 : (T.card : ℝ) + ((S.filter (fun k => ¬ |frameProjection U i k +
        t * tangentY U (moderateNoise U ρ g) i k| < sampleH * s)).card : ℝ) = (n : ℝ) - 1 := by
      have h4 : ((n - 1 : ℕ) : ℝ) = (n : ℝ) - 1 := by rw [Nat.cast_sub (by omega)]; simp
      rw [← h4, ← hScard]; exact_mod_cast hcard
    linarith only [hnum.2, h3, hT]
  · -- (S4)
    obtain ⟨-, -, hS4c, -, -⟩ := sample_S4_cross U hs hρ ht ht1 hη'
    obtain ⟨hJ, -⟩ := block_posDef hU (exceptionalSet U ρ)
      (show 0 < (d : ℝ) / n * t ^ 2 by positivity)
    change (blockJ U (exceptionalSet U ρ) t).PosDef at hJ
    constructor
    · rw [hS4c (tangentY U (moderateNoise U ρ g)) x hx]
      refine (abs_matrixQuadratic_le_of_frobSq _ _ hη'.le (le_of_not_gt g6)).trans (le_of_eq ?_)
      rw [sqrtM_norm_sq hJ, blockJ_quadratic U _ t x hx]
    · rw [integral_matrixQuadratic_sqLaplacian, ← matrixQuadratic_sub,
        ← matrixQuadratic_submatrix_eq (exceptionalSet U ρ) _ x hx]
      have hle := abs_matrixQuadratic_le_frob (sampleLapBlock U ρ g) (fun b => x b)
      have hww : (fun b : exceptionalSet U ρ => x b) ⬝ᵥ (fun b : exceptionalSet U ρ => x b) =
          vectorNormSq x := by
        rw [dotProduct_subtype_eq _ x x hx]; simp [vectorNormSq, dotProduct, pow_two]
      rw [hww] at hle
      exact hle.trans (mul_le_mul_of_nonneg_right (le_of_not_gt g7)
        (by unfold vectorNormSq; positivity))

/-- The heart of `lem_sample_explicit`: for `A_{η'} = 10¹²/η'²` all seven failure
probabilities are at most `1/10`, their sum is `< 1`, and off their union the sample is good. -/
theorem sample_good_pos {η' : ℝ} (hη' : 0 < η') (hη'1 : η' ≤ 1 / 32) {n d : ℕ}
    (U : Frame n d) (hs : ModerateStanding U) {ρ : ℝ} (hρ : 0 < ρ) {t : ℝ} (ht : 0 < t)
    (ht1 : t ≤ 1) (hA : 10 ^ 12 / η' ^ 2 * Real.log (2 * n) ≤ d) :
    0 < (gaussAmb n d).real {g | GoodSample U ρ t sampleH η' g} := by
  have h2dn : 2 * (d : ℝ) ≤ n := by exact_mod_cast hs.density
  obtain ⟨hL1, hlogn, hdη, hdL, hd6, hn100⟩ :=
    sample_numeric_facts hη' hη'1 hs.pos h2dn hA
  obtain ⟨hb0, hb1⟩ := sampleBad_S1 (η' := η') (t := t) U hs hρ hL1 hlogn hdL hn100
  obtain ⟨hb2, hb3⟩ := sampleBad_S2 (t := t) hη' hη'1 U hs hρ hL1 hlogn hdη hn100
  have hb4 := sampleBad_S3 (η' := η') U hs hρ ht ht1 hL1 hlogn hdL hd6
  obtain ⟨hb5, hb6⟩ := sampleBad_S4 hη' U hs hρ ht ht1 hL1 hdη
  have hbad : ∀ k, (gaussAmb n d).real (sampleBad U ρ t η' k) ≤ 1 / 10 := by
    intro k
    fin_cases k
    · exact hb0
    · exact hb1
    · exact hb2
    · exact hb3
    · exact hb4
    · exact hb5
    · exact hb6
  have htotal : (gaussAmb n d).real (⋃ k, sampleBad U ρ t η' k) ≤ 7 / 10 := by
    calc (gaussAmb n d).real (⋃ k, sampleBad U ρ t η' k)
        ≤ ∑ k, (gaussAmb n d).real (sampleBad U ρ t η' k) := measureReal_iUnion_fintype_le _
      _ ≤ ∑ _k : Fin 7, (1 / 10 : ℝ) := Finset.sum_le_sum fun k _ => hbad k
      _ = 7 / 10 := by norm_num
  have hgood : (⋃ k, sampleBad U ρ t η' k)ᶜ ⊆ {g | GoodSample U ρ t sampleH η' g} :=
    fun g hg => good_of_not_sampleBad hη' U hs hρ ht ht1 hd6 hn100 hg
  calc (0 : ℝ) < 1 - 7 / 10 := by norm_num
    _ ≤ 1 - (gaussAmb n d).real (⋃ k, sampleBad U ρ t η' k) := by linarith
    _ ≤ (gaussAmb n d).real (⋃ k, sampleBad U ρ t η' k)ᶜ := measureReal_compl_ge _ _
    _ ≤ _ := measureReal_mono hgood

/-- `lem:sample` with the explicit `h = 1/500` of its proof. -/
theorem lem_sample_explicit : ∃ A : ℝ → ℝ, SampleThreshold A := by
  refine ⟨fun η' => 10 ^ 12 / η' ^ 2, fun η' hη' hη'1 => ⟨fun n d hn hAd => ?_,
    fun n d U hs ρ hρ t ht ht1 hAd => sample_good_pos hη' hη'1 U hs hρ ht ht1 hAd⟩⟩
  have hη2 : 0 < η' ^ 2 := by positivity
  have hη2le : η' ^ 2 ≤ 1 / 1024 := by nlinarith
  have h1 : (10 : ℝ) ^ 15 ≤ 10 ^ 12 / η' ^ 2 := by rw [le_div_iff₀ hη2]; nlinarith
  have hL : Real.log 2 ≤ Real.log (2 * n) := Real.log_le_log (by norm_num) (by
    have : (1 : ℝ) ≤ n := by exact_mod_cast hn
    linarith)
  have h2 := Real.log_two_gt_d9
  have h3 := mul_le_mul h1 hL (by linarith) (by positivity)
  simp only at hAd
  nlinarith

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
  obtain ⟨A, hA⟩ := lem_sample_explicit
  refine ⟨sampleH, by unfold sampleH; norm_num, by unfold sampleH; norm_num, fun η' hη' hη'1 => ?_⟩
  exact ⟨A η', fun n d U hs ρ hρ t ht ht1 hAd => (hA η' hη' hη'1).2 n d U hs ρ hρ t ht ht1 hAd⟩

end

end Paulsen.Paper
