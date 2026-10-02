import Paulsen.SmoothNormalCovariance
import Paulsen.NormalResidualVariance

namespace Paulsen.Smooth
open Matrix
open scoped BigOperators
noncomputable section

def normalizedPositiveResidual {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  modeSum U (residualWeight (max 0 ρ))

def normalizedPositiveResidualMass {n d : ℕ} (U : Frame n d) (ρ : ℝ) : ℝ :=
  ∑ j ∈ highNormalizedModes U 0, residualWeight (max 0 ρ) (normalizedFisherEigenvalue U j)

theorem normalizedPositiveResidual_posSemidef {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i,0<rowNormSq U i) (ρ : ℝ) :
    (normalizedPositiveResidual U ρ).PosSemidef := by
  unfold normalizedPositiveResidual modeSum
  apply Matrix.posSemidef_sum
  intro j hj
  exact (normalDirectionOuter_posSemidef U j).smul
    (residualWeight_nonneg (le_max_left 0 ρ) (normalizedFisherEigenvalue_nonneg U j)
      (normalizedFisherEigenvalue_le_one hU hp j))

theorem normalizedPositiveResidualMass_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i,0<rowNormSq U i) (ρ : ℝ) :
    normalizedPositiveResidualMass U ρ≤(d:ℝ) := by
  calc
    _ ≤ ∑ j ∈ highNormalizedModes U 0, (1-normalizedFisherEigenvalue U j) :=
      Finset.sum_le_sum (fun j hj=>residualWeight_le_deficit (le_max_left 0 ρ)
        (normalizedFisherEigenvalue_nonneg U j) (normalizedFisherEigenvalue_le_one hU hp j))
    _ ≤ ∑ j, (1-normalizedFisherEigenvalue U j) :=
      Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
        (fun j _ _=>sub_nonneg.mpr (normalizedFisherEigenvalue_le_one hU hp j))
    _ = _ := normalizedFisher_deficit_sum hU hp

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
      ∑ j ∈ highNormalizedModes U 0, (residualWeight (max 0 ρ) (normalizedFisherEigenvalue U j)) •
        Matrix.vecMulVec (fun p => normalTangentFrame U j p.1 p.2)
          (fun p => normalTangentFrame U j p.1 p.2) := by
  unfold positiveResidualTangentCovariance normalizedPositiveResidual modeSum
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
      ∑ j ∈ highNormalizedModes U 0, (residualWeight (max 0 ρ) (normalizedFisherEigenvalue U j)) *
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
  have hj (j : Fin n) (hj : j ∈ highNormalizedModes U 0) :
      (∑ i, ∑ k, (normalTangentFrame U j i k) ^ 2) = 2 :=
    normalTangentFrame_sq_sum hU j (Finset.mem_filter.mp hj).2
  simp_rw [Finset.sum_comm (f := fun k i => (normalTangentFrame U _ i k) ^ 2)]
  have he : (∑ j ∈ highNormalizedModes U 0, (residualWeight (max 0 ρ) (normalizedFisherEigenvalue U j)) *
      ∑ i, ∑ k, (normalTangentFrame U j i k) ^ 2) =
      ∑ j ∈ highNormalizedModes U 0, (residualWeight (max 0 ρ) (normalizedFisherEigenvalue U j)) * 2 := by
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
  Matrix.of fun p j => if j ∈ highNormalizedModes U 0 then
    Real.sqrt ((residualWeight (max 0 ρ) (normalizedFisherEigenvalue U j)) / (n : ℝ)) *
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
      if j ∈ highNormalizedModes U 0 then
        (1 / (n : ℝ)) * ((residualWeight (max 0 ρ) (normalizedFisherEigenvalue U j)) *
          (normalTangentFrame U j p.1 p.2 * normalTangentFrame U j q.1 q.2)) else 0 := by
    unfold positiveResidualTangentFactor
    simp only [Matrix.of_apply]
    split_ifs
    · have hs := Real.sq_sqrt (div_nonneg
        (residualWeight_nonneg (le_max_left 0 ρ) (normalizedFisherEigenvalue_nonneg U j)
          (normalizedFisherEigenvalue_le_one hU hp j)) (Nat.cast_nonneg n))
      calc
        _ = Real.sqrt ((residualWeight (max 0 ρ) (normalizedFisherEigenvalue U j)) / (n : ℝ)) ^ 2 *
            (normalTangentFrame U j p.1 p.2 * normalTangentFrame U j q.1 q.2) := by ring
        _ = _ := by rw [hs]; ring
    · simp
  simp_rw [ht]
  rw [← Finset.sum_filter]
  simp

end
end Paulsen.Smooth
