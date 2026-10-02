import Paulsen.NormalResidualMean
import Paulsen.NormalizedTangentNoise

/-!
# Positive residual covariance loss in the tangent projection

The spectral residual is pushed through the actual tangent lift
`H ↦ HUᵀ+UHᵀ`. Horizontality makes its squared Frobenius norm exactly twice
that of H, so the total covariance loss is at most `2d/n`.
-/

namespace Paulsen
open Matrix
open scoped BigOperators
noncomputable section

/-- Matrix of the derivative of the frame projection, in ambient coordinates. -/
def tangentLiftMatrix {n d : ℕ} (U : Frame n d) :
    Matrix (Fin n × Fin n) (Fin n × Fin d) ℝ :=
  Matrix.of fun p q => (if p.1 = q.1 then U p.2 q.2 else 0) +
    (if p.2 = q.1 then U p.1 q.2 else 0)

theorem tangentLiftMatrix_mulVec {n d : ℕ} (U H : Frame n d) (i j : Fin n) :
    (tangentLiftMatrix U *ᵥ (fun p => H p.1 p.2)) (i,j) =
      (H * U.transpose + U * H.transpose) i j := by
  simp only [tangentLiftMatrix, Matrix.of_apply, Matrix.mulVec, dotProduct,
    Fintype.sum_prod_type, add_mul, Finset.sum_add_distrib,
    ite_mul, zero_mul, Finset.sum_ite_irrel, Finset.sum_const_zero]
  simp only [Finset.sum_ite_eq, Finset.mem_univ, if_true,
    Matrix.add_apply, Matrix.mul_apply, Matrix.transpose_apply]
  congr 1
  apply Finset.sum_congr rfl
  intro a _
  ring

theorem tangentLiftMatrix_apply {n d : ℕ} (U H : Frame n d) :
    Matrix.toEuclideanLin (tangentLiftMatrix U) (normalFrobVector H) =
      normalFrobVector (H * U.transpose + U * H.transpose) := by
  ext p
  exact tangentLiftMatrix_mulVec U H p.1 p.2

theorem normalFrobVector_add {n d : ℕ} (H K : Frame n d) :
    normalFrobVector (H + K) = normalFrobVector H + normalFrobVector K := by
  ext p
  rfl

theorem normalFrobVector_transpose_norm {n d : ℕ} (H : Frame n d) :
    ‖normalFrobVector H.transpose‖ = ‖normalFrobVector H‖ := by
  have he : ‖normalFrobVector H.transpose‖ ^ 2 = ‖normalFrobVector H‖ ^ 2 := by
    simp only [normalFrobVector, EuclideanSpace.real_norm_sq_eq, Fintype.sum_prod_type,
      Matrix.transpose_apply]
    exact Finset.sum_comm
  nlinarith [norm_nonneg (normalFrobVector H.transpose), norm_nonneg (normalFrobVector H)]

/-- Exact tangent Frobenius isometry on the horizontal space. -/
theorem horizontal_tangent_frobenius_sq {n d : ℕ} {U H : Frame n d}
    (hU : IsParseval U) (hH : U.transpose * H = 0) :
    ‖normalFrobVector (H * U.transpose + U * H.transpose)‖ ^ 2 =
      2 * ‖normalFrobVector H‖ ^ 2 := by
  have hHt : H.transpose * U = 0 := by
    simpa only [Matrix.transpose_mul, Matrix.transpose_transpose, Matrix.transpose_zero] using
      congrArg Matrix.transpose hH
  have hc : inner ℝ (normalFrobVector (H * U.transpose))
      (normalFrobVector (U * H.transpose)) = 0 := by
    rw [normalFrobVector_inner, Matrix.transpose_mul, Matrix.transpose_transpose]
    rw [show U * H.transpose * (U * H.transpose) = U * (H.transpose * U) * H.transpose by
      simp only [Matrix.mul_assoc]]
    rw [hHt, Matrix.mul_zero, Matrix.zero_mul, Matrix.trace_zero]
  have hn : ‖normalFrobVector (U * H.transpose)‖ = ‖normalFrobVector H‖ := by
    rw [← normalFrobVector_transpose_norm (U * H.transpose),
      Matrix.transpose_mul, Matrix.transpose_transpose]
    exact normalFrobVector_mul_parseval_transpose_norm hU H
  rw [normalFrobVector_add, norm_add_sq_real, hc, hn,
    normalFrobVector_mul_parseval_transpose_norm hU]
  ring

theorem normalizedNormalFrame_horizontal {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (j : Fin n) :
    U.transpose * normalizedNormalFrame U j = 0 := by
  rw [normalizedNormalFrame_eq, Matrix.mul_smul]
  simp only [ambientNormal, ← Matrix.mul_assoc,
    hU.transpose_mul_frameComplementProjection, Matrix.zero_mul, smul_zero]

def normalTangentFrame {n d : ℕ} (U : Frame n d) (j : Fin n) : Frame n n :=
  normalizedNormalFrame U j * U.transpose + U * (normalizedNormalFrame U j).transpose

theorem normalTangentFrame_sq_sum {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (j : Fin n) (hj : 0 < normalizedFisherEigenvalue U j) :
    (∑ i, ∑ k, (normalTangentFrame U j i k) ^ 2) = 2 := by
  have hn : ‖normalFrobVector (normalizedNormalFrame U j)‖ ^ 2 = 1 := by
    have he := normalizedNormalDirection_inner U j j hj hj
    rw [if_pos rfl, real_inner_self_eq_norm_sq] at he
    exact he
  have h := horizontal_tangent_frobenius_sq hU (normalizedNormalFrame_horizontal hU j)
  rw [hn, mul_one] at h
  simpa only [normalTangentFrame, normalFrobVector, EuclideanSpace.real_norm_sq_eq,
    Fintype.sum_prod_type] using h

/-- Actual tangent covariance removed by the positive spectral residual. -/
def positiveResidualTangentCovariance {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    Matrix (Fin n × Fin n) (Fin n × Fin n) ℝ :=
  (1 / (n : ℝ)) • (tangentLiftMatrix U * normalizedPositiveResidual U ρ *
    (tangentLiftMatrix U).transpose)

theorem positiveResidualTangentCovariance_posSemidef {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) (ρ : ℝ) :
    (positiveResidualTangentCovariance U ρ).PosSemidef := by
  unfold positiveResidualTangentCovariance
  have h := (normalizedPositiveResidual_posSemidef hU hp ρ).mul_mul_conjTranspose_same
    (tangentLiftMatrix U)
  simp only [Matrix.conjTranspose_eq_transpose_of_trivial] at h
  exact h.smul (by positivity)

theorem positiveResidualTangentCovariance_decomposition {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    positiveResidualTangentCovariance U ρ = (1 / (n : ℝ)) •
      ∑ j ∈ highNormalizedModes U ρ, (1 - normalizedFisherEigenvalue U j) •
        Matrix.vecMulVec (fun p => normalTangentFrame U j p.1 p.2)
          (fun p => normalTangentFrame U j p.1 p.2) := by
  unfold positiveResidualTangentCovariance normalizedPositiveResidual
  congr 1
  rw [Matrix.mul_sum, Matrix.sum_mul]
  apply Finset.sum_congr rfl
  intro j _
  rw [Matrix.mul_smul, Matrix.smul_mul, normalDirectionOuter, matrix_outer_conjugation]
  congr 2
  · funext p
    exact tangentLiftMatrix_mulVec U (normalizedNormalFrame U j) p.1 p.2
  · funext p
    exact tangentLiftMatrix_mulVec U (normalizedNormalFrame U j) p.1 p.2

/-- Individual entry variance lost to the positive residual. -/
def positiveResidualEntryLoss {n d : ℕ} (U : Frame n d) (ρ : ℝ) (i k : Fin n) : ℝ :=
  positiveResidualTangentCovariance U ρ (i,k) (i,k)

def positiveResidualRowLoss {n d : ℕ} (U : Frame n d) (ρ : ℝ) (i : Fin n) : ℝ :=
  ∑ k, positiveResidualEntryLoss U ρ i k

theorem positiveResidualEntryLoss_formula {n d : ℕ} (U : Frame n d) (ρ : ℝ) (i k : Fin n) :
    positiveResidualEntryLoss U ρ i k = (1 / (n : ℝ)) *
      ∑ j ∈ highNormalizedModes U ρ, (1 - normalizedFisherEigenvalue U j) *
        (normalTangentFrame U j i k) ^ 2 := by
  unfold positiveResidualEntryLoss
  rw [positiveResidualTangentCovariance_decomposition]
  simp only [Matrix.smul_apply, Matrix.sum_apply, Matrix.vecMulVec_apply, smul_eq_mul, pow_two]

theorem positiveResidualEntryLoss_nonneg {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) (ρ : ℝ) (i k : Fin n) :
    0 ≤ positiveResidualEntryLoss U ρ i k :=
  (positiveResidualTangentCovariance_posSemidef hU hp ρ).diag_nonneg

theorem positiveResidualRowLoss_nonneg {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) (ρ : ℝ) (i : Fin n) :
    0 ≤ positiveResidualRowLoss U ρ i :=
  Finset.sum_nonneg fun k _ => positiveResidualEntryLoss_nonneg hU hp ρ i k

/-- Exact total loss: each positive normal mode contributes twice its residual weight. -/
theorem positiveResidualRowLoss_sum {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ) :
    (∑ i, positiveResidualRowLoss U ρ i) =
      (2 / (n : ℝ)) * normalizedPositiveResidualMass U ρ := by
  simp only [positiveResidualRowLoss, positiveResidualEntryLoss_formula, ← Finset.mul_sum]
  rw [Finset.sum_comm]
  conv_lhs => arg 2; arg 2; ext k; rw [Finset.sum_comm]
  rw [Finset.sum_comm]
  simp only [← Finset.mul_sum]
  have hj (j : Fin n) (hj : j ∈ highNormalizedModes U ρ) :
      (∑ i, ∑ k, (normalTangentFrame U j i k) ^ 2) = 2 :=
    normalTangentFrame_sq_sum hU j (hρ.trans_lt (Finset.mem_filter.mp hj).2)
  simp_rw [Finset.sum_comm (f := fun k i => (normalTangentFrame U _ i k) ^ 2)]
  have he : (∑ j ∈ highNormalizedModes U ρ, (1 - normalizedFisherEigenvalue U j) *
      ∑ i, ∑ k, (normalTangentFrame U j i k) ^ 2) =
      ∑ j ∈ highNormalizedModes U ρ, (1 - normalizedFisherEigenvalue U j) * 2 := by
    apply Finset.sum_congr rfl
    intro j hj'
    rw [hj j hj']
  rw [he, ← Finset.sum_mul]
  change (1 / (n : ℝ)) * (normalizedPositiveResidualMass U ρ * 2) = _
  ring

/-- The total entry variance removed by the positive residual is at most `2d/n`. -/
theorem positiveResidualRowLoss_sum_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 ≤ ρ) :
    (∑ i, positiveResidualRowLoss U ρ i) ≤ 2 * (d : ℝ) / n := by
  rw [positiveResidualRowLoss_sum hU hρ]
  calc
    _ ≤ (2 / (n : ℝ)) * d := mul_le_mul_of_nonneg_left
      (normalizedPositiveResidualMass_le hU hp ρ) (by positivity)
    _ = _ := by ring

/-- Only a bounded number of rows can lose a prescribed amount of variance. -/
theorem positiveResidualRowLoss_large_card_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) {ρ t : ℝ}
    (hρ : 0 ≤ ρ) (ht : 0 < t) :
    ((Finset.univ.filter (fun i => t ≤ positiveResidualRowLoss U ρ i)).card : ℝ) ≤
      (2 * (d : ℝ) / n) / t := by
  apply (le_div_iff₀ ht).2
  calc
    _ = ∑ _i ∈ Finset.univ.filter (fun i => t ≤ positiveResidualRowLoss U ρ i), t := by simp
    _ ≤ ∑ i ∈ Finset.univ.filter (fun i => t ≤ positiveResidualRowLoss U ρ i),
        positiveResidualRowLoss U ρ i :=
      Finset.sum_le_sum fun i hi => (Finset.mem_filter.mp hi).2
    _ ≤ ∑ i, positiveResidualRowLoss U ρ i :=
      Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _)
        (fun i _ _ => positiveResidualRowLoss_nonneg hU hp ρ i)
    _ ≤ _ := positiveResidualRowLoss_sum_le hU hp hρ

/-- At a fixed fraction of the leverage scale d/n, the exceptional row count
is an absolute constant, independent of n and d. -/
theorem positiveResidualRowLoss_density_large_card_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) (hn : 0 < n) (hd : 0 < d)
    {ρ η : ℝ} (hρ : 0 ≤ ρ) (hη : 0 < η) :
    ((Finset.univ.filter (fun i => η * ((d : ℝ) / n) ≤ positiveResidualRowLoss U ρ i)).card : ℝ) ≤
      2 / η := by
  have hn' : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  have hd' : (0 : ℝ) < d := Nat.cast_pos.mpr hd
  have h := positiveResidualRowLoss_large_card_le hU hp hρ
    (mul_pos hη (div_pos hd' hn'))
  convert h using 1
  field_simp

/-- Within each remaining row, few entries can lose a prescribed variance. -/
theorem positiveResidualEntryLoss_large_card_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) (ρ : ℝ) (i : Fin n)
    {t : ℝ} (ht : 0 < t) :
    ((Finset.univ.filter (fun k => t ≤ positiveResidualEntryLoss U ρ i k)).card : ℝ) ≤
      positiveResidualRowLoss U ρ i / t := by
  apply (le_div_iff₀ ht).2
  calc
    _ = ∑ _k ∈ Finset.univ.filter (fun k => t ≤ positiveResidualEntryLoss U ρ i k), t := by simp
    _ ≤ ∑ k ∈ Finset.univ.filter (fun k => t ≤ positiveResidualEntryLoss U ρ i k),
        positiveResidualEntryLoss U ρ i k :=
      Finset.sum_le_sum fun k hk => (Finset.mem_filter.mp hk).2
    _ ≤ ∑ k, positiveResidualEntryLoss U ρ i k :=
      Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _)
        (fun k _ _ => positiveResidualEntryLoss_nonneg hU hp ρ i k)
    _ = _ := rfl

/-- An explicit Gaussian factor realizing the residual tangent covariance. -/
def positiveResidualTangentFactor {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    Matrix (Fin n × Fin n) (Fin n) ℝ :=
  Matrix.of fun p j => if j ∈ highNormalizedModes U ρ then
    Real.sqrt ((1 - normalizedFisherEigenvalue U j) / (n : ℝ)) *
      normalTangentFrame U j p.1 p.2 else 0

theorem positiveResidualTangentFactor_covariance {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) (ρ : ℝ) :
    positiveResidualTangentFactor U ρ * (positiveResidualTangentFactor U ρ).transpose =
      positiveResidualTangentCovariance U ρ := by
  rw [positiveResidualTangentCovariance_decomposition]
  ext p q
  simp only [Matrix.mul_apply, Matrix.transpose_apply, Matrix.smul_apply,
    Matrix.sum_apply, Matrix.vecMulVec_apply, smul_eq_mul, Finset.mul_sum]
  have ht (j : Fin n) : positiveResidualTangentFactor U ρ p j * positiveResidualTangentFactor U ρ q j =
      if j ∈ highNormalizedModes U ρ then
        (1 / (n : ℝ)) * ((1 - normalizedFisherEigenvalue U j) *
          (normalTangentFrame U j p.1 p.2 * normalTangentFrame U j q.1 q.2)) else 0 := by
    unfold positiveResidualTangentFactor
    simp only [Matrix.of_apply]
    split_ifs
    · have hs := Real.sq_sqrt (div_nonneg
        (sub_nonneg.mpr (normalizedFisherEigenvalue_le_one hU hp j)) (Nat.cast_nonneg n))
      calc
        _ = Real.sqrt ((1 - normalizedFisherEigenvalue U j) / (n : ℝ)) ^ 2 *
            (normalTangentFrame U j p.1 p.2 * normalTangentFrame U j q.1 q.2) := by ring
        _ = _ := by rw [hs]; ring
    · simp
  simp_rw [ht]
  rw [← Finset.sum_filter]
  simp

end
end Paulsen
