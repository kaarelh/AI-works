import Paulsen.SmoothNoiseBounds
import Paulsen.GaussianOperatorNet
import Paulsen.SmoothTangentMoments
import Paulsen.SmoothQuadraticTail

/-!
# Basic probability budgets for the actual moderate-row seed

Operator and maximum-row events use the concrete smoothly filtered Gaussian factor.
The first-order diagonal term is represented by its actual linear functional,
whose covariance is the already proved smooth normal covariance.
-/

namespace Paulsen.Smooth
open Matrix MeasureTheory ProbabilityTheory Set
open scoped BigOperators ProbabilityTheory
noncomputable section

theorem normalMap_transpose_horizontal {n d : ℕ} {U H : Frame n d}
    (_hU : IsParseval U) (hH : U.transpose * H = 0) (i : Fin n) :
    ((normalMapMatrix U).transpose *ᵥ (fun p => H p.1 p.2)) i = (H * U.transpose) i i := by
  have hQ : frameComplementProjection U * H = H := by
    simp only [frameComplementProjection, frameProjection, Matrix.sub_mul,
      Matrix.one_mul, Matrix.mul_assoc, hH, Matrix.mul_zero, sub_zero]
  have he : ((normalMapMatrix U).transpose *ᵥ (fun p => H p.1 p.2)) i =
      ∑ a, U i a * (frameComplementProjection U * H) i a := by
    simp only [Matrix.mulVec, dotProduct, Matrix.transpose_apply, normalMapMatrix,
      Fintype.sum_prod_type, Matrix.mul_apply, Finset.mul_sum]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro a _
    apply Finset.sum_congr rfl
    intro r _
    have hsym := congrArg (fun M : Matrix (Fin n) (Fin n) ℝ => M i r)
      (frameComplementProjection_transpose U)
    simp only [Matrix.transpose_apply] at hsym
    rw [hsym]
    ring
  rw [he, hQ]
  simp only [Matrix.mul_apply, Matrix.transpose_apply, mul_comm]

def normalDiagonalNoiseDual {n d : ℕ} (U : Frame n d) (ρ : ℝ) (i : Fin n) :
    StrongDual ℝ (FrameVector n d) :=
  innerSL ℝ (WithLp.toLp 2 (fun p =>
    ((normalMapMatrix U).transpose * normalizedTangentNoiseFactor U ρ) i p))

theorem normalDiagonalNoiseDual_apply {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (ρ : ℝ) (i : Fin n) (g : FrameVector n d) :
    normalDiagonalNoiseDual U ρ i g =
      (frameOfVector (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g) * U.transpose) i i := by
  have hd : normalDiagonalNoiseDual U ρ i g =
      (((normalMapMatrix U).transpose * normalizedTangentNoiseFactor U ρ) *ᵥ (fun p => g p)) i := by
    simp only [normalDiagonalNoiseDual, innerSL_apply_apply, PiLp.inner_apply,
      Real.inner_apply, Matrix.mulVec, dotProduct]
  rw [hd, ← Matrix.mulVec_mulVec]
  exact normalMap_transpose_horizontal hU (normalizedTangentNoiseFactor_horizontal hU ρ (fun p => g p)) i

theorem normalDiagonalNoiseDual_norm_sq_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 ≤ ρ) (i : Fin n) :
    ‖normalDiagonalNoiseDual U ρ i‖ ^ 2 ≤ ρ * rowNormSq U i / (n : ℝ) := by
  let M := (normalMapMatrix U).transpose * normalizedTangentNoiseFactor U ρ
  have he : ‖normalDiagonalNoiseDual U ρ i‖ ^ 2 = (M * M.transpose) i i := by
    simp only [normalDiagonalNoiseDual, innerSL_apply_norm, EuclideanSpace.real_norm_sq_eq,
      Matrix.mul_apply, Matrix.transpose_apply, ← sq]
    rfl
  rw [he]
  have hm : M * M.transpose = (normalMapMatrix U).transpose *
      (normalizedTangentNoiseFactor U ρ * (normalizedTangentNoiseFactor U ρ).transpose) * normalMapMatrix U := by
    simp only [M, Matrix.transpose_mul, Matrix.transpose_transpose, Matrix.mul_assoc]
  rw [hm]
  exact normal_noise_covariance_diagonal_le hU hp hρ i

/-- Simultaneous first-order diagonal control with the normalized leverage variance. -/
theorem normalizedTangentNoise_diagonal_max_tail {n d : ℕ}
    (hn : 0 < n) (hd : 0 < d) {U : Frame n d} (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) (hnear : ∀ i, rowNormSq U i ≤ 2 * (d : ℝ)/n)
    {ρ u : ℝ} (hρ : 0 < ρ) (hu : 0 ≤ u) :
    (stdGaussian (FrameVector n d)).real {g | ∃ i,
      u ≤ |(frameOfVector (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g) * U.transpose) i i|} ≤
        2*n * Real.exp (-(n:ℝ)^2*u^2/(4*ρ*d)) := by
  have hnR : (0:ℝ) < n := Nat.cast_pos.mpr hn
  have hdR : (0:ℝ) < d := Nat.cast_pos.mpr hd
  let v := 2*ρ*d/(n:ℝ)^2
  have hv : 0 < v := by dsimp [v]; positivity
  have hnorm (i : Fin n) : ‖normalDiagonalNoiseDual U ρ i‖^2 ≤ v := by
    apply (normalDiagonalNoiseDual_norm_sq_le hU hp hρ.le i).trans
    calc
      _ ≤ ρ * (2*(d:ℝ)/n) / n := by gcongr; exact hnear i
      _ = v := by dsimp [v]; ring
  let bad (i : Fin n) : Set (FrameVector n d) := {g | u ≤ |normalDiagonalNoiseDual U ρ i g|}
  have hevent : {g | ∃ i,
      u ≤ |(frameOfVector (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g) * U.transpose) i i|} =
      ⋃ i, bad i := by
    ext g
    simp only [mem_setOf_eq, mem_iUnion, bad, normalDiagonalNoiseDual_apply hU]
  rw [hevent]
  have hexp : -u^2/(2*v) = -(n:ℝ)^2*u^2/(4*ρ*d) := by dsimp [v]; field_simp; ring
  calc
    _ ≤ ∑ i, (stdGaussian (FrameVector n d)).real (bad i) := measureReal_iUnion_fintype_le bad
    _ ≤ ∑ _i : Fin n, 2 * Real.exp (-u^2/(2*v)) :=
      Finset.sum_le_sum fun i _ => stdGaussian_dual_abs_tail _ v u hv hu (hnorm i)
    _ = _ := by rw [hexp]; simp; ring

theorem normalizedTangentNoise_operator_failure_le {n d : ℕ} (hn : 0 < n) (hdn : d ≤ n)
    {U : Frame n d} (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ) :
    (stdGaussian (FrameVector n d)).real {g |
      128 < ‖(Matrix.toEuclideanLin (frameOfVector (Matrix.toEuclideanLin
        (normalizedTangentNoiseFactor U ρ) g))).toContinuousLinearMap‖} ≤ 1/100 :=
  gaussian_matrix_operator_failure_le hn hdn _ (normalizedTangentNoiseFactor_operator_norm_sq_le hU hρ)

theorem gaussian_maximum_row_tail {κ : Type*} [Fintype κ] [DecidableEq κ]
    {n d : ℕ} [NeZero n] (C : Matrix (Fin n × Fin d) κ ℝ)
    (q M : ℝ) (hq : 0 < q)
    (hmean : (∫ g, finiteMaximum
      (fun i g => rowNormSq (frameOfVector (Matrix.toEuclideanLin C g)) i) g
      ∂stdGaussian (EuclideanSpace ℝ κ)) ≤ M) :
    (stdGaussian (EuclideanSpace ℝ κ)).real {g | ∃ i,
      q ≤ rowNormSq (frameOfVector (Matrix.toEuclideanLin C g)) i} ≤ M / q := by
  let f := finiteMaximum (fun i g => rowNormSq (frameOfVector (Matrix.toEuclideanLin C g)) i)
  have hi : Integrable f (stdGaussian (EuclideanSpace ℝ κ)) :=
    finiteMaximum_integrable _ _ (fun i =>
      (memLp_rowNormSq_gaussianImage C i).integrable (by norm_num))
  have hnonneg (g : EuclideanSpace ℝ κ) : 0 ≤ f g := by
    let i : Fin n := 0
    exact (rowNormSq_nonneg _ i).trans (Finset.le_sup' _ (Finset.mem_univ i))
  have hsub : {g | ∃ i, q ≤ rowNormSq (frameOfVector (Matrix.toEuclideanLin C g)) i} ⊆
      {g | q ≤ f g} := by
    rintro g ⟨i,hi⟩
    exact hi.trans (Finset.le_sup' _ (Finset.mem_univ i))
  apply (measureReal_mono hsub).trans
  apply (le_div_iff₀ hq).mpr
  have hm := mul_meas_ge_le_integral_of_nonneg (ae_of_all _ hnonneg) hi q
  simpa only [mul_comm] using hm.trans hmean

theorem normalizedTangentNoise_row_max_failure_le {n d : ℕ} [NeZero n] (hd : 0 < d)
    {U : Frame n d} (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ)
    (hlog : Real.log n ≤ (d : ℝ)) :
    (stdGaussian (FrameVector n d)).real {g | ∃ i,
      600 * ((d : ℝ)/n) ≤ rowNormSq
        (frameOfVector (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g)) i} ≤ 1/100 := by
  have hdR : (0:ℝ) < d := Nat.cast_pos.mpr hd
  have hnR : (0:ℝ) < n := Nat.cast_pos.mpr (NeZero.pos n)
  have h := gaussian_maximum_row_tail (normalizedTangentNoiseFactor U ρ)
    (600 * ((d:ℝ)/n)) (6 * ((d:ℝ)/n)) (by positivity)
    (integral_maximum_normalizedTangentNoiseRow_energy_le_six hU hρ hlog)
  have he : (6 * ((d:ℝ)/n)) / (600 * ((d:ℝ)/n)) = 1/100 := by
    field_simp
    ring
  rwa [he] at h

theorem retainedTangent_row_max_failure_le {n d : ℕ} [NeZero n] (hd : 0 < d)
    {U : Frame n d} (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ)
    (hnear : ∀ i, rowNormSq U i ≤ 2 * (d : ℝ)/n)
    (hlog : Real.log n ≤ (d : ℝ)) :
    (stdGaussian (FrameVector n d)).real {g | ∃ i,
      2000 * ((d : ℝ)/n) ≤ rowNormSq
        (frameOfVector (Matrix.toEuclideanLin (retainedTangentFactor U ρ) g)) i} ≤ 1/100 := by
  have hdR : (0:ℝ) < d := Nat.cast_pos.mpr hd
  have hnR : (0:ℝ) < n := Nat.cast_pos.mpr (NeZero.pos n)
  have h := gaussian_maximum_row_tail (retainedTangentFactor U ρ)
    (2000 * ((d:ℝ)/n)) (20 * ((d:ℝ)/n)) (by positivity)
    (integral_maximum_retainedTangentRow_energy_le_twenty hU hρ hnear hlog)
  have he : (20 * ((d:ℝ)/n)) / (2000 * ((d:ℝ)/n)) = 1/100 := by
    field_simp
    ring
  rwa [he] at h

end
end Paulsen.Smooth
