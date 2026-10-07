import Paulsen.ResolventNoiseBounds
import Paulsen.Linear.DriftAlgebra

namespace Paulsen.Resolvent
open Matrix MeasureTheory ProbabilityTheory Paulsen.Linear
open scoped BigOperators
noncomputable section

def normalResidualDiagonal {n d : ℕ} (U : Frame n d) (ρ : ℝ) (i : Fin n) : ℝ :=
  (1/(n:ℝ))*∑ j ∈ highNormalizedModes U 0,
    residualWeight ρ (normalizedFisherEigenvalue U j)*
      horizontalQuadraticDiagonal U (normalizedNormalFrame U j) i

theorem residual_inverse_sqrt_sum_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i,0<rowNormSq U i) {ρ : ℝ} (hρ : 0<ρ) :
    (∑ j ∈ highNormalizedModes U 0,
      residualWeight ρ (normalizedFisherEigenvalue U j)/Real.sqrt (normalizedFisherEigenvalue U j))≤
        (d:ℝ)/(2*Real.sqrt ρ) := by
  calc
    _ ≤ ∑ j ∈ highNormalizedModes U 0, (1-normalizedFisherEigenvalue U j)/(2*Real.sqrt ρ) :=
      Finset.sum_le_sum (fun j hj=>residualWeight_div_sqrt_le hρ
        (normalizedFisherEigenvalue_nonneg U j) (normalizedFisherEigenvalue_le_one hU hp j))
    _ ≤ ∑ j, (1-normalizedFisherEigenvalue U j)/(2*Real.sqrt ρ) :=
      Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
        (fun j _ _=>div_nonneg (sub_nonneg.mpr (normalizedFisherEigenvalue_le_one hU hp j)) (by positivity))
    _ = _ := by rw [←Finset.sum_div,normalizedFisher_deficit_sum hU hp]

def driftMean {n d : ℕ} (U : Frame n d) (ρ : ℝ) : Frame n d :=
  (1 / (n : ℝ)) • ∑ j ∈ highNormalizedModes U 0,
    (residualWeight ρ (normalizedFisherEigenvalue U j) /
      normalizedFisherEigenvalue U j) • driftGamma U (normalizedNormalPotential U j)

/-- The resolvent drift is the original rational-filter drift scaled by `α`. -/
theorem driftMean_eq_baseWeight_smul {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    driftMean U ρ = baseWeight ρ • Linear.driftMean U ρ := by
  simp only [driftMean, Linear.driftMean, residualWeight, Finset.smul_sum, smul_smul]
  apply Finset.sum_congr rfl
  intro j hj
  congr 1
  ring

theorem driftMean_horizontal {n d : ℕ} {U : Frame n d} (hU : IsParseval U) (ρ : ℝ) :
    U.transpose * driftMean U ρ = 0 := by
  unfold driftMean
  rw [Matrix.mul_smul, Matrix.mul_sum]
  simp [Matrix.mul_smul, driftGamma_horizontal hU]

/-- `𝒜 m_* = b_*`. -/
theorem driftMean_diagonal {n d : ℕ} {U : Frame n d} (hU : IsParseval U) (ρ : ℝ)
    (i : Fin n) :
    (driftMean U ρ * U.transpose) i i = normalResidualDiagonal U ρ i := by
  unfold driftMean normalResidualDiagonal
  rw [Matrix.smul_mul, Matrix.sum_mul, Matrix.smul_apply, Matrix.sum_apply, smul_eq_mul]
  congr 1
  apply Finset.sum_congr rfl
  intro j hj
  have hμ : 0 < normalizedFisherEigenvalue U j := (Finset.mem_filter.mp hj).2
  rw [Matrix.smul_mul, Matrix.smul_apply, smul_eq_mul, normalizedNormalFrame_eq,
    horizontalQuadraticDiagonal_smul, horizontalQuadraticDiagonal_ambientNormal hU,
    inv_pow, Real.sq_sqrt hμ.le]
  field_simp

/-- `‖m_*‖_F ≤ a / √(p ρ)` when all leverages are at least `p`. -/
theorem driftMean_norm_le {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    {p ρ : ℝ} (hp : 0 < p) (hrows : ∀ i, p ≤ rowNormSq U i) (hρ : 0 < ρ) :
    ‖normalFrobVector (driftMean U ρ)‖ ≤
      ((d : ℝ) / n) / (Real.sqrt p * Real.sqrt ρ) := by
  have hpi : ∀ i, 0 < rowNormSq U i := fun i => hp.trans_le (hrows i)
  have hsp : 0 < Real.sqrt p := Real.sqrt_pos.mpr hp
  have hsρ : 0 < Real.sqrt ρ := Real.sqrt_pos.mpr hρ
  unfold driftMean
  rw [normalFrobVector_smul', norm_smul, normalFrobVector_sum']
  have hterm : ∀ j ∈ highNormalizedModes U 0,
      ‖normalFrobVector ((residualWeight ρ (normalizedFisherEigenvalue U j) /
        normalizedFisherEigenvalue U j) • driftGamma U (normalizedNormalPotential U j))‖ ≤
      (2 * (Real.sqrt p)⁻¹) * (residualWeight ρ (normalizedFisherEigenvalue U j) /
        Real.sqrt (normalizedFisherEigenvalue U j)) := by
    intro j hj
    have hμ : 0 < normalizedFisherEigenvalue U j := (Finset.mem_filter.mp hj).2
    have hw := residualWeight_nonneg hρ.le (normalizedFisherEigenvalue_nonneg U j)
      (normalizedFisherEigenvalue_le_one hU hpi j)
    rw [normalFrobVector_smul', norm_smul, Real.norm_eq_abs,
      abs_of_nonneg (div_nonneg hw hμ.le)]
    have hg := driftGamma_norm_le hU (normalizedNormalPotential U j)
      (inv_nonneg.mpr (Real.sqrt_nonneg p))
      (fun i => normalizedNormalPotential_abs_le U j i hp (hrows i))
    rw [normalizedNormalPotential_image_norm] at hg
    have hsμ : 0 < Real.sqrt (normalizedFisherEigenvalue U j) := Real.sqrt_pos.mpr hμ
    calc _ ≤ (residualWeight ρ (normalizedFisherEigenvalue U j) /
          normalizedFisherEigenvalue U j) *
          (2 * (Real.sqrt p)⁻¹ * Real.sqrt (normalizedFisherEigenvalue U j)) :=
          mul_le_mul_of_nonneg_left hg (div_nonneg hw hμ.le)
      _ = _ := by
          have key : residualWeight ρ (normalizedFisherEigenvalue U j) /
              normalizedFisherEigenvalue U j * Real.sqrt (normalizedFisherEigenvalue U j) =
              residualWeight ρ (normalizedFisherEigenvalue U j) /
              Real.sqrt (normalizedFisherEigenvalue U j) := by
            rw [div_mul_eq_mul_div, div_eq_div_iff hμ.ne' hsμ.ne', mul_assoc,
              Real.mul_self_sqrt hμ.le]
          rw [← key]; ring
  calc _ ≤ ‖(1 / (n : ℝ))‖ * ∑ j ∈ highNormalizedModes U 0,
        (2 * (Real.sqrt p)⁻¹) * (residualWeight ρ (normalizedFisherEigenvalue U j) /
          Real.sqrt (normalizedFisherEigenvalue U j)) := by
        gcongr
        exact (norm_sum_le _ _).trans (Finset.sum_le_sum hterm)
    _ = (1 / (n : ℝ)) * (2 * (Real.sqrt p)⁻¹) * ∑ j ∈ highNormalizedModes U 0,
        (residualWeight ρ (normalizedFisherEigenvalue U j) /
          Real.sqrt (normalizedFisherEigenvalue U j)) := by
        rw [← Finset.mul_sum, Real.norm_eq_abs, abs_of_nonneg (by positivity)]; ring
    _ ≤ (1 / (n : ℝ)) * (2 * (Real.sqrt p)⁻¹) * ((d : ℝ) / (2 * Real.sqrt ρ)) := by
        gcongr
        exact residual_inverse_sqrt_sum_le hU hpi hρ
    _ = _ := by field_simp

theorem driftMean_norm_sq_le {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    (hn : 0 < n) (hd : 0 < d)
    (hrows : ∀ i, ((d : ℝ) / n) / 2 ≤ rowNormSq U i) {ρ : ℝ} (hρ : 0 < ρ) :
    ‖normalFrobVector (driftMean U ρ)‖ ^ 2 ≤ 2 * ((d : ℝ) / n) / ρ := by
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hd
  have ha : 0 < (d : ℝ) / n := by positivity
  have hp : 0 < ((d : ℝ) / n) / 2 := by positivity
  have h := driftMean_norm_le hU hp hrows hρ
  have h2 := pow_le_pow_left₀ (norm_nonneg _) h 2
  refine h2.trans (le_of_eq ?_)
  rw [div_pow, mul_pow, Real.sq_sqrt hp.le, Real.sq_sqrt hρ.le]
  field_simp


end
end Paulsen.Resolvent
