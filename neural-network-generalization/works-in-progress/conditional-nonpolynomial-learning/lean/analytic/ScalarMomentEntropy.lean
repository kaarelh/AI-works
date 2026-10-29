import GaussianCovarianceEntropy

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal NNReal

namespace ConditionalNonpolynomial.Analytic

theorem scalar_gaussian_second_moment_integrable
    (Q : Measure ℝ) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (gaussianReal 0 1) ≠ ∞) : Integrable (fun z : ℝ => z^2) Q := by
  have he : Integrable (fun z : ℝ => Real.exp (z^2/4)) (gaussianReal 0 1) := by
    apply Integrable.of_integral_ne_zero
    have h := NeuralGeneralization.GaussianTail.integral_exp_mul_sq_gaussianReal 1 (1/4)
      (by norm_num)
    simp only [NNReal.coe_one, mul_one] at h
    have heq : (fun z : ℝ => Real.exp (z^2/4)) = fun z : ℝ => Real.exp ((1/4)*z^2) := by
      funext z; congr 1; ring
    rw [heq, h]
    positivity
  have hi := NeuralGeneralization.RobustEntropyMoments.integrable_of_exp_integrable_finite_kl
    Q (gaussianReal 0 1) hKL (fun z : ℝ => z^2/4) (by fun_prop)
    (fun z => by positivity) he
  convert hi.const_mul 4 using 1
  funext z
  ring

theorem scalar_gaussian_second_moment_pos
    (Q : Measure ℝ) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (gaussianReal 0 1) ≠ ∞) : 0 < ∫ z : ℝ, z^2 ∂Q := by
  letI : NullSingletonClass (gaussianReal 0 1) := nullSingletonClass_gaussianReal (μ := 0) (by norm_num)
  have hn : 0 ≤ ∫ z : ℝ, z^2 ∂Q := integral_nonneg (fun z => sq_nonneg _)
  rcases hn.eq_or_lt with hz | hp
  · have hzero := (integral_eq_zero_iff_of_nonneg (fun z : ℝ => sq_nonneg z)
      (scalar_gaussian_second_moment_integrable Q hKL)).mp hz.symm
    have hne : ∀ᵐ z : ℝ ∂Q, z ≠ 0 :=
      (klDiv_ne_top_iff.mp hKL).1 (by simp)
    obtain ⟨z, hz, hne⟩ := (hzero.and hne).exists
    exact False.elim (hne (sq_eq_zero_iff.mp hz))
  · exact hp

theorem scalar_gaussian_second_moment_entropy
    (Q : Measure ℝ) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (gaussianReal 0 1) ≠ ∞) :
    ((∫ z : ℝ, z^2 ∂Q) - 1 - Real.log (∫ z : ℝ, z^2 ∂Q))/2 ≤
      (klDiv Q (gaussianReal 0 1)).toReal := by
  let M := ∫ z : ℝ, z^2 ∂Q
  let c := (1-M⁻¹)/2
  have hM : 0 < M := scalar_gaussian_second_moment_pos Q hKL
  have hi := scalar_gaussian_second_moment_integrable Q hKL
  have hd : 0 < 1 - 2*c*(1:ℝ≥0) := by
    change 0 < 1 - 2*c*1
    dsimp [c]
    have := inv_pos.mpr hM
    linarith
  have he := NeuralGeneralization.GaussianTail.integrable_exp_centered_square_gaussianReal 1 c hd
  simp only [NNReal.coe_one] at he
  have hMGF : (∫ z : ℝ, Real.exp (c*(z^2-1)) ∂gaussianReal 0 1) =
      Real.exp (-c + Real.log M / 2) := by
    have h := NeuralGeneralization.GaussianTail.mgf_centered_square_gaussianReal 1 c hd
    simp only [mgf, NNReal.coe_one, mul_one] at h
    rw [h]
    have hid : 1 - 2*c = M⁻¹ := by dsimp [c]; ring
    rw [hid]
    have hp : 0 < Real.exp (-c) / Real.sqrt M⁻¹ :=
      div_pos (Real.exp_pos _) (Real.sqrt_pos.mpr (inv_pos.mpr hM))
    rw [← Real.exp_log hp, Real.log_div (Real.exp_ne_zero _)
      (Real.sqrt_pos.mpr (inv_pos.mpr hM)).ne', Real.log_exp,
      Real.log_sqrt (inv_nonneg.mpr hM.le), Real.log_inv]
    congr 1
    ring
  have h := integral_le_kl_add_log_mgf Q (gaussianReal 0 1) hKL
    (fun z : ℝ => c*(z^2-1)) ((hi.sub (integrable_const 1)).const_mul _) he
    (-c+Real.log M/2) hMGF.le
  rw [integral_const_mul, integral_sub hi (integrable_const 1)] at h
  simp only [integral_const, probReal_univ, one_smul] at h
  have hid : c*(M-1)+c-Real.log M/2 = (M-1-Real.log M)/2 := by
    dsimp [c]
    field_simp [ne_of_gt hM]
    ring
  change (M-1-Real.log M)/2 ≤ _
  change c*(M-1) ≤ _ at h
  linarith

theorem scalar_gaussian_polar_deviation
    (Q : Measure ℝ) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (gaussianReal 0 1) ≠ ∞) :
    (Real.sqrt (∫ z : ℝ, z^2 ∂Q)-1)^2 ≤
      2 * (klDiv Q (gaussianReal 0 1)).toReal := by
  have h1 := scalar_gaussian_second_moment_entropy Q hKL
  have h2 := sqrt_deviation_sq_le_gaussian_cost (∫ z : ℝ, z^2 ∂Q)
    (scalar_gaussian_second_moment_pos Q hKL)
  linarith

#print axioms scalar_gaussian_polar_deviation
end ConditionalNonpolynomial.Analytic
