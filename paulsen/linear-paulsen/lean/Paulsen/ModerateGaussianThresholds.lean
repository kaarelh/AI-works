import Paulsen.ModerateGaussianEvents
import Paulsen.GaussianGraphExpansion

/-! Scalar probability budgets for simultaneous retained Gaussian sampling. -/
namespace Paulsen
open Matrix MeasureTheory ProbabilityTheory Set
open scoped BigOperators ProbabilityTheory Matrix.Norms.Elementwise
noncomputable section

/-- An exponent with an additive margin of 200 pays for a union over all rows. -/
theorem gaussian_row_union_failure_budget {n : ℕ} (hn : 0 < n) {b : ℝ}
    (hb : Real.log n + 200 ≤ b) :
    2 * (n : ℝ) * Real.exp (-b) ≤ 1 / 100 := by
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  calc
    _ ≤ 2 * n * Real.exp (-(Real.log n + 200)) := by gcongr
    _ = 2 * Real.exp (-200) := by
      rw [neg_add, Real.exp_add, Real.exp_neg (Real.log n), Real.exp_log hnR]
      field_simp
    _ ≤ 1 / 100 := by
      rw [Real.exp_neg, ← div_eq_mul_inv]
      apply (div_le_iff₀ (Real.exp_pos _)).mpr
      linarith [Real.add_one_le_exp (200 : ℝ)]

theorem normalizedTangentNoise_diagonal_max_failure_le {n d : ℕ}
    (hn : 0 < n) (hd : 0 < d) {U : Frame n d} (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) (hnear : ∀ i, rowNormSq U i ≤ 2 * (d : ℝ) / n)
    {ρ u : ℝ} (hρ : 0 < ρ) (hu : 0 ≤ u)
    (hlarge : Real.log n + 200 ≤ (n : ℝ) ^ 2 * u ^ 2 / (4 * ρ * d)) :
    (stdGaussian (FrameVector n d)).real {g | ∃ i,
      u ≤ |(frameOfVector (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g) * U.transpose) i i|} ≤
        1 / 100 := by
  have h := normalizedTangentNoise_diagonal_max_tail hn hd hU hp hnear hρ hu
  have hb := gaussian_row_union_failure_budget hn hlarge
  apply h.trans
  simpa only [neg_div, neg_mul] using hb

theorem normalizedTangentNoise_quadratic_max_failure_le {n d : ℕ}
    (hn : 0 < n) (hd : 0 < d) {U : Frame n d} (hU : IsParseval U)
    (hnear : ∀ i, rowNormSq U i ≤ 2 * (d : ℝ) / n)
    {ρ u : ℝ} (hρ : 0 ≤ ρ) (hu : 0 ≤ u)
    (hlarge : Real.log n + 200 ≤
      min ((n : ℝ) ^ 2 * u ^ 2 / (96 * d)) ((n : ℝ) * u / 16)) :
    (stdGaussian (FrameVector n d)).real {g | ∃ i,
      u ≤ |horizontalQuadraticDiagonal U
        (frameOfVector (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g)) i -
          ∫ h, horizontalQuadraticDiagonal U
            (frameOfVector (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) h)) i
              ∂stdGaussian (FrameVector n d)|} ≤ 1 / 100 :=
  (normalizedTangentNoise_quadratic_max_abs_tail hU hn hd hnear hρ hu).trans
    (gaussian_row_union_failure_budget hn hlarge)

/-- The normalized first-order threshold has an exponent independent of the step size. -/
theorem moderate_diagonal_scaled_exponent {n d : ℕ} (hn : 0 < n) (hd : 0 < d)
    {D t ζ : ℝ} (hD : 0 < D) (ht : 0 < t) :
    (n : ℝ) ^ 2 * (ζ * ((d : ℝ) / n) * t) ^ 2 / (4 * (D ^ 2 * t ^ 2) * d) =
      ζ ^ 2 * d / (4 * D ^ 2) := by
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hd
  field_simp

/-- Both scalar fluctuation budgets follow from a single logarithmic dimension bound. -/
theorem moderate_scaled_exponent_budgets {n d : ℕ} [NeZero n]
    (hd : 0 < d) {D t ζ : ℝ} (hD : 0 < D) (ht : 0 < t)
    (hζ : 0 < ζ) (hζ1 : ζ ≤ 1)
    (hlarge : 100 * (D ^ 2 + 1) * (Real.log n + 200) ≤ ζ ^ 2 * d) :
    Real.log n + 200 ≤ (n : ℝ) ^ 2 * (ζ * ((d : ℝ) / n) * t) ^ 2 /
      (4 * (D ^ 2 * t ^ 2) * d) ∧
    Real.log n + 200 ≤ min
      ((n : ℝ) ^ 2 * (ζ * ((d : ℝ) / n)) ^ 2 / (96 * d))
      ((n : ℝ) * (ζ * ((d : ℝ) / n)) / 16) := by
  have hn : 0 < n := NeZero.pos n
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hd
  have hL : 0 ≤ Real.log n := Real.log_nonneg (by exact_mod_cast hn)
  have hD2 : 0 ≤ D ^ 2 := sq_nonneg _
  have hζsq : ζ ^ 2 ≤ ζ := by nlinarith
  have hζd := mul_le_mul_of_nonneg_right hζsq hdR.le
  rw [moderate_diagonal_scaled_exponent hn hd hD ht]
  constructor
  · apply (le_div_iff₀ (by positivity : 0 < 4 * D ^ 2)).mpr
    nlinarith [mul_nonneg hD2 (show 0 ≤ Real.log n + 200 by positivity)]
  · have he1 : (n : ℝ) ^ 2 * (ζ * ((d : ℝ) / n)) ^ 2 / (96 * d) = ζ ^ 2 * d / 96 := by
      field_simp
    have he2 : (n : ℝ) * (ζ * ((d : ℝ) / n)) / 16 = ζ * d / 16 := by
      field_simp
    rw [he1, he2]
    apply le_min <;> nlinarith [mul_nonneg hD2 (show 0 ≤ Real.log n + 200 by positivity)]

/-- A margin below 128 makes the operator event stable under a small perturbation. -/
theorem normalizedTangentNoise_operator_margin_failure_le {n d : ℕ}
    (hn : 0 < n) (hdn : d ≤ n) {U : Frame n d} (hU : IsParseval U)
    {ρ : ℝ} (hρ : 0 ≤ ρ) :
    (stdGaussian (FrameVector n d)).real {g | 124 <
      ‖(Matrix.toEuclideanLin (frameOfVector (Matrix.toEuclideanLin
        (normalizedTangentNoiseFactor U ρ) g))).toContinuousLinearMap‖} ≤ 1 / 100 := by
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  have hn1 : (1 : ℝ) ≤ n := by exact_mod_cast hn
  have hdnR : (d : ℝ) ≤ n := by exact_mod_cast hdn
  have ht := gaussian_matrix_operator_net_tail (normalizedTangentNoiseFactor U ρ)
    (1 / (n : ℝ)) 31 (by positivity) (by norm_num)
    (normalizedTangentNoiseFactor_operator_norm_sq_le hU hρ)
  norm_num only [show (4 : ℝ) * 31 = 124 by norm_num] at ht
  have h5 : (5 : ℝ) ≤ Real.exp 5 := by linarith [Real.add_one_le_exp (5 : ℝ)]
  have hpow := pow_le_pow_left₀ (by norm_num : (0 : ℝ) ≤ 5) h5 (n + d)
  rw [← Real.exp_nat_mul] at hpow
  have he : -(961 : ℝ) / (2 * (1 / (n : ℝ))) = -(961 / 2) * n := by field_simp
  rw [he] at ht
  apply ht.trans
  calc
    2 * (5 : ℝ) ^ (n + d) * Real.exp (-(961 / 2) * n) ≤
        2 * Real.exp ((n + d : ℕ) * 5) * Real.exp (-(961 / 2) * n) := by gcongr
    _ = 2 * Real.exp (5 * ((n : ℝ) + d) - (961 / 2) * n) := by
      rw [mul_assoc, ← Real.exp_add]
      push_cast
      congr 2
      ring
    _ ≤ 2 * Real.exp (-470 * n) := by gcongr; linarith
    _ ≤ 2 * Real.exp (-470) := by gcongr; linarith
    _ ≤ 1 / 100 := by
      rw [Real.exp_neg, ← div_eq_mul_inv]
      apply (div_le_iff₀ (Real.exp_pos _)).mpr
      linarith [Real.add_one_le_exp (470 : ℝ)]

end
end Paulsen
