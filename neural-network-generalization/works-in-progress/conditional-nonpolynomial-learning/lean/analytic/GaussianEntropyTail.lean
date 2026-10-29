import ScalarMomentEntropy
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic

lemma gaussian_tail_square_measurable (R : ℝ) :
    Measurable (fun z : ℝ => if R < |z| then z^2 else 0) := by
  exact Measurable.ite (measurableSet_lt measurable_const measurable_id.abs)
    (measurable_id.pow_const 2) measurable_const

lemma gaussian_tail_square_integrable (Q : Measure ℝ) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (gaussianReal 0 1)≠∞) (R : ℝ) :
    Integrable (fun z : ℝ => if R < |z| then z^2 else 0) Q := by
  apply (scalar_gaussian_second_moment_integrable Q hKL).mono'
    (gaussian_tail_square_measurable R).aestronglyMeasurable
  filter_upwards [] with z
  split_ifs
  · simp only [Real.norm_eq_abs,abs_sq,le_refl]
  · simpa only [norm_zero] using sq_nonneg z

lemma gaussian_three_eighths_square_mgf :
    (∫z : ℝ, Real.exp ((3/8:ℝ)*z^2) ∂gaussianReal 0 1)=2 := by
  have h := NeuralGeneralization.GaussianTail.integral_exp_mul_sq_gaussianReal 1 (3/8)
    (by norm_num)
  norm_num at h
  have hs : Real.sqrt (4:ℝ)=2 := by
    nlinarith [Real.sq_sqrt (show (0:ℝ)≤4 by norm_num),Real.sqrt_nonneg (4:ℝ)]
  simpa only [hs] using h

/-- Entropy controls the tail second moment, with a Gaussian-decaying
reference term. This is a genuine measure inequality, not an assumed
transport or regularity hypothesis. -/
theorem gaussian_tail_second_moment_le (Q : Measure ℝ) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (gaussianReal 0 1)≠∞) {R : ℝ} (hR : 0≤R) :
    (∫z : ℝ, (if R < |z| then z^2 else 0) ∂Q)≤
      4*(klDiv Q (gaussianReal 0 1)).toReal+8*Real.exp (-(R^2)/8) := by
  let f : ℝ→ℝ := fun z => if R < |z| then z^2 else 0
  let a := Real.exp (-(R^2)/8)
  have hf : Measurable f := gaussian_tail_square_measurable R
  have hfi : Integrable f Q := gaussian_tail_square_integrable Q hKL R
  have he3 : Integrable (fun z : ℝ => Real.exp ((3/8:ℝ)*z^2)) (gaussianReal 0 1) :=
    Integrable.of_integral_ne_zero (by rw [gaussian_three_eighths_square_mgf]; norm_num)
  have hbound (z : ℝ) : Real.exp (f z/4)≤1+a*Real.exp ((3/8:ℝ)*z^2) := by
    by_cases hz : R < |z|
    · have hs : R^2≤z^2 := by nlinarith [sq_abs z,sq_nonneg (|z|-R)]
      have hh : z^2/4≤-(R^2)/8+(3/8:ℝ)*z^2 := by nlinarith
      have he := Real.exp_le_exp.mpr hh
      rw [Real.exp_add] at he
      dsimp [f]
      rw [if_pos hz]
      dsimp [a]
      linarith
    · simp only [f,if_neg hz,zero_div,Real.exp_zero]
      have ha : 0≤a*Real.exp ((3/8:ℝ)*z^2) := by dsimp [a]; positivity
      linarith
  have hei : Integrable (fun z : ℝ => Real.exp (f z/4)) (gaussianReal 0 1) := by
    apply ((integrable_const 1).add (he3.const_mul a)).mono'
      ((Real.measurable_exp.comp (hf.div_const 4)).aestronglyMeasurable)
    filter_upwards [] with z
    change ‖Real.exp (f z/4)‖≤1+a*Real.exp ((3/8:ℝ)*z^2)
    rw [Real.norm_eq_abs,abs_of_pos (Real.exp_pos _)]
    exact hbound z
  have hmgf : (∫z : ℝ,Real.exp (f z/4) ∂gaussianReal 0 1)≤Real.exp (2*a) := by
    have hh := integral_mono hei ((integrable_const 1).add (he3.const_mul a)) hbound
    simp only [Pi.add_apply] at hh
    rw [integral_add (integrable_const 1) (he3.const_mul a),integral_const_mul,
      gaussian_three_eighths_square_mgf] at hh
    simp only [integral_const,probReal_univ,one_smul] at hh
    exact hh.trans (by linarith [Real.add_one_le_exp (2*a)])
  have h := integral_le_kl_add_log_mgf Q (gaussianReal 0 1) hKL
    (fun z => f z/4) (hfi.div_const 4) hei (2*a) hmgf
  rw [integral_div] at h
  change (∫z,f z ∂Q)≤_
  dsimp [a] at h
  linarith

#print axioms gaussian_tail_second_moment_le
end ConditionalNonpolynomial.Analytic
