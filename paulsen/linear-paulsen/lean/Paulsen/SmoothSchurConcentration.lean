import Paulsen.SmoothNoiseBounds
import Paulsen.GaussianSchurConcentration
import Paulsen.SmoothTangentFactor

/-!
# Squared-entry concentration for the actual retained tangent seed
-/

namespace Paulsen.Smooth
open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory Matrix.Norms.Elementwise
noncomputable section

local instance {n : ℕ} : ContinuousENorm (Matrix (Fin n) (Fin n) ℝ) :=
  inferInstanceAs (ContinuousENorm (Fin n → Fin n → ℝ))

theorem retainedTangentFactor_symmetric {n d : ℕ} (U : Frame n d) (ρ : ℝ)
    (s : Fin n × Fin d) (i j : Fin n) :
    retainedTangentFactor U ρ (i,j) s = retainedTangentFactor U ρ (j,i) s := by
  simp only [retainedTangentFactor, Matrix.mul_apply, tangentLiftMatrix, Matrix.of_apply]
  apply Finset.sum_congr rfl
  intro p _
  ring

/-- The retained tangent Gaussian has an explicit squared-entry fluctuation bound. -/
theorem retainedTangentSchurSquare_expected_norm_le {n d : ℕ} [NeZero n]
    {U : Frame n d} (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ)
    (hnear : ∀ i, rowNormSq U i ≤ 2 * (d : ℝ) / n) :
    (∫ g, ‖matrixEuclideanOperator
      (gaussianSchurSquare (retainedTangentFactor U ρ) g -
        ∫ h, gaussianSchurSquare (retainedTangentFactor U ρ) h ∂stdGaussian (FrameVector n d))‖
      ∂stdGaussian (FrameVector n d)) ≤
      4 * Real.sqrt (2 * Real.exp 1 * (2 / (n : ℝ)) * (Real.log (n : ℝ) + 2) *
        (12 * (d : ℝ) / n + 8 * Real.log n / n)) := by
  have hn : (0 : ℝ) < n := Nat.cast_pos.mpr (Nat.pos_of_ne_zero (NeZero.ne n))
  have h := gaussianSchurSquare_expected_operator_norm_le (retainedTangentFactor U ρ)
    (retainedTangentFactor_symmetric U ρ) (by positivity : (0 : ℝ) < 2 / n)
    (retainedTangentFactor_operator_norm_sq_le hU hρ)
    (fun i => retainedTangentRowFactor_sq_sum_le hU hρ i (hnear i))
  have he : 2 * (6 * (d : ℝ) / n) + 4 * (2 / (n : ℝ)) * Real.log n =
      12 * (d : ℝ) / n + 8 * Real.log n / n := by ring
  simpa only [he] using h

/-- In the moderate regime the fluctuation scale is √(d log n)/n. -/
theorem retainedTangentSchurSquare_expected_norm_le_moderate {n d : ℕ} [NeZero n]
    {U : Frame n d} (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ)
    (hnear : ∀ i, rowNormSq U i ≤ 2 * (d : ℝ) / n)
    (hlog : Real.log n ≤ (d : ℝ)) :
    (∫ g, ‖matrixEuclideanOperator
      (gaussianSchurSquare (retainedTangentFactor U ρ) g -
        ∫ h, gaussianSchurSquare (retainedTangentFactor U ρ) h ∂stdGaussian (FrameVector n d))‖
      ∂stdGaussian (FrameVector n d)) ≤
      4 * Real.sqrt (80 * Real.exp 1 * (d : ℝ) * (Real.log n + 2)) / n := by
  have hn : (0 : ℝ) < n := Nat.cast_pos.mpr (Nat.pos_of_ne_zero (NeZero.ne n))
  have hlog0 : 0 ≤ Real.log (n : ℝ) := Real.log_nonneg
    (Nat.one_le_cast.mpr (Nat.pos_of_ne_zero (NeZero.ne n)))
  have hmean : 12 * (d : ℝ) / n + 8 * Real.log n / n ≤ 20 * (d : ℝ) / n := by
    calc
      _ ≤ 12 * (d : ℝ) / n + 8 * (d : ℝ) / n := by gcongr
      _ = _ := by ring
  calc
    _ ≤ 4 * Real.sqrt (2 * Real.exp 1 * (2 / (n : ℝ)) * (Real.log (n : ℝ) + 2) *
        (12 * (d : ℝ) / n + 8 * Real.log n / n)) :=
      retainedTangentSchurSquare_expected_norm_le hU hρ hnear
    _ ≤ 4 * Real.sqrt (2 * Real.exp 1 * (2 / (n : ℝ)) * (Real.log (n : ℝ) + 2) *
        (20 * (d : ℝ) / n)) := by gcongr
    _ = _ := by
      rw [show 2 * Real.exp 1 * (2 / (n : ℝ)) * (Real.log (n : ℝ) + 2) *
        (20 * (d : ℝ) / n) = (80 * Real.exp 1 * (d : ℝ) * (Real.log n + 2)) / (n : ℝ) ^ 2 by ring]
      rw [Real.sqrt_div (by positivity), Real.sqrt_sq hn.le]
      ring

/-- A failure bound for the actual retained Schur square, centered at its actual mean. -/
theorem retainedTangentSchurSquare_operator_tail {n d : ℕ} [NeZero n]
    {U : Frame n d} (hU : IsParseval U) {ρ t : ℝ} (hρ : 0 ≤ ρ) (ht : 0 < t)
    (hnear : ∀ i, rowNormSq U i ≤ 2 * (d : ℝ) / n)
    (hlog : Real.log n ≤ (d : ℝ)) :
    (stdGaussian (FrameVector n d)).real {g | t ≤ ‖matrixEuclideanOperator
      (gaussianSchurSquare (retainedTangentFactor U ρ) g -
        ∫ h, gaussianSchurSquare (retainedTangentFactor U ρ) h ∂stdGaussian (FrameVector n d))‖} ≤
      (4 * Real.sqrt (80 * Real.exp 1 * (d : ℝ) * (Real.log n + 2)) / n) / t := by
  have hi := (matrixEuclideanOperator.integrable_comp
    ((integrable_gaussianSchurSquare (retainedTangentFactor U ρ)).sub (integrable_const
      (∫ h, gaussianSchurSquare (retainedTangentFactor U ρ) h ∂stdGaussian (FrameVector n d))))).norm
  have hm := mul_meas_ge_le_integral_of_nonneg
    (ae_of_all _ fun g => norm_nonneg (matrixEuclideanOperator
      (gaussianSchurSquare (retainedTangentFactor U ρ) g -
        ∫ h, gaussianSchurSquare (retainedTangentFactor U ρ) h ∂stdGaussian (FrameVector n d)))) hi t
  apply (le_div_iff₀ ht).2
  rw [mul_comm]
  exact hm.trans (retainedTangentSchurSquare_expected_norm_le_moderate hU hρ hnear hlog)

end
end Paulsen.Smooth
