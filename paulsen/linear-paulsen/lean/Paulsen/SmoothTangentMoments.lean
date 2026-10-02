import Paulsen.SmoothNoiseBounds
import Paulsen.SmoothTangentFactor
import Paulsen.GaussianMaximumEnergy

/-!
# Maximum row energy of the actual moderate tangent Gaussian

The abstract Gaussian maximum-energy estimate is instantiated with the actual
retained horizontal tangent factor. No covariance or row-energy bound is assumed.
-/

namespace Paulsen.Smooth
open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory
noncomputable section

/-- Actual expected maximum tangent row energy, including the logarithmic term. -/
theorem integral_maximum_retainedTangentRow_energy_le {n d : ℕ} [NeZero n]
    {U : Frame n d} (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ)
    (hnear : ∀ i, rowNormSq U i ≤ 2 * (d : ℝ) / n) :
    (∫ g, finiteMaximum
      (fun i g => rowNormSq (frameOfVector (Matrix.toEuclideanLin (retainedTangentFactor U ρ) g)) i) g
      ∂stdGaussian (FrameVector n d)) ≤
        12 * ((d : ℝ) / n) + 8 * Real.log n / n := by
  have hn : (0 : ℝ) < n := Nat.cast_pos.mpr (Nat.pos_of_ne_zero (NeZero.ne n))
  have h := integral_maximum_gaussianRow_energy_le (retainedTangentFactor U ρ)
    (2 / (n : ℝ)) (6 * (d : ℝ) / n) (by positivity)
    (retainedTangentFactor_operator_norm_sq_le hU hρ)
    (fun i => retainedTangentRowFactor_sq_sum_le hU hρ i (hnear i))
  have he : 2 * (6 * (d : ℝ) / n) + 4 * (2 / (n : ℝ)) * Real.log n =
      12 * ((d : ℝ) / n) + 8 * Real.log n / n := by ring
  simpa only [he] using h

/-- In the moderate dimension regime, the maximum row energy stays at leverage scale. -/
theorem integral_maximum_retainedTangentRow_energy_le_twenty {n d : ℕ} [NeZero n]
    {U : Frame n d} (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ)
    (hnear : ∀ i, rowNormSq U i ≤ 2 * (d : ℝ) / n)
    (hlog : Real.log n ≤ (d : ℝ)) :
    (∫ g, finiteMaximum
      (fun i g => rowNormSq (frameOfVector (Matrix.toEuclideanLin (retainedTangentFactor U ρ) g)) i) g
      ∂stdGaussian (FrameVector n d)) ≤ 20 * ((d : ℝ) / n) := by
  calc
    _ ≤ 12 * ((d : ℝ) / n) + 8 * Real.log n / n :=
      integral_maximum_retainedTangentRow_energy_le hU hρ hnear
    _ ≤ 12 * ((d : ℝ) / n) + 8 * (d : ℝ) / n := by
      gcongr
    _ = _ := by ring

/-- Maximum row energy of the underlying retained horizontal noise. -/
theorem integral_maximum_normalizedTangentNoiseRow_energy_le {n d : ℕ} [NeZero n]
    {U : Frame n d} (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ) :
    (∫ g, finiteMaximum
      (fun i g => rowNormSq
        (frameOfVector (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g)) i) g
      ∂stdGaussian (FrameVector n d)) ≤
        2 * ((d : ℝ) / n) + 4 * Real.log n / n := by
  have hn : (0 : ℝ) < n := Nat.cast_pos.mpr (Nat.pos_of_ne_zero (NeZero.ne n))
  have he (i : Fin n) : (∑ a, ∑ p, (normalizedTangentNoiseFactor U ρ (i,a) p) ^ 2) ≤
      (d : ℝ) / n := by
    simpa only [tangentNoiseRowCovariance, Matrix.trace, Matrix.diag_apply,
      Matrix.submatrix_apply, Matrix.mul_apply, Matrix.transpose_apply, ← sq] using
      tangentNoiseRowCovariance_trace_le hU hρ i
  have h := integral_maximum_gaussianRow_energy_le (normalizedTangentNoiseFactor U ρ)
    (1 / (n : ℝ)) ((d : ℝ) / n) (by positivity)
    (normalizedTangentNoiseFactor_operator_norm_sq_le hU hρ) he
  convert h using 1 <;> ring

/-- The horizontal noise maximum also stays at the leverage scale. -/
theorem integral_maximum_normalizedTangentNoiseRow_energy_le_six {n d : ℕ} [NeZero n]
    {U : Frame n d} (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ)
    (hlog : Real.log n ≤ (d : ℝ)) :
    (∫ g, finiteMaximum
      (fun i g => rowNormSq
        (frameOfVector (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g)) i) g
      ∂stdGaussian (FrameVector n d)) ≤ 6 * ((d : ℝ) / n) := by
  calc
    _ ≤ 2 * ((d : ℝ) / n) + 4 * Real.log n / n :=
      integral_maximum_normalizedTangentNoiseRow_energy_le hU hρ
    _ ≤ 2 * ((d : ℝ) / n) + 4 * (d : ℝ) / n := by gcongr
    _ = _ := by ring

end
end Paulsen.Smooth
