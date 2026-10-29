import GaussianConditionalVariance

/-! Symmetry and contraction of the actual Gaussian-smoothed tanh mean. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Set
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization NeuralGeneralization.BatchTwoContinuousDepthCritical

theorem shiftedMean_odd (r a : ℝ) : shiftedMean r (-a) = -shiftedMean r a := by
  have hmp : MeasurePreserving (MeasurableEquiv.neg ℝ)
      (gaussianReal 0 1) (gaussianReal 0 1) := by
    refine ⟨by fun_prop, ?_⟩
    simpa only [MeasurableEquiv.neg_apply, neg_zero] using
      (gaussianReal_map_neg (μ := (0 : ℝ)) (v := (1 : NNReal)))
  have hp := hmp.integral_comp' (fun z : ℝ => Real.tanh (-a+Real.sqrt r*z))
  have he (z : ℝ) : Real.tanh (-a+Real.sqrt r*(-z)) =
      -Real.tanh (a+Real.sqrt r*z) := by
    rw [mul_neg,←neg_add,Real.tanh_neg]
  simpa only [MeasurableEquiv.neg_apply,he,integral_neg,shiftedMean] using hp.symm

theorem shiftedMean_zero (r : ℝ) : shiftedMean r 0 = 0 := by
  have hh := shiftedMean_odd r 0
  simp only [neg_zero] at hh
  linarith

theorem shiftedMean_lipschitz (r a b : ℝ) :
    |shiftedMean r a-shiftedMean r b| ≤ |a-b| := by
  have hi := (shifted_tanh_integrable r a).sub (shifted_tanh_integrable r b)
  have hp (z : ℝ) : ‖Real.tanh (a+Real.sqrt r*z)-Real.tanh (b+Real.sqrt r*z)‖ ≤ |a-b| := by
    rw [Real.norm_eq_abs]
    simpa only [add_sub_add_right_eq_sub] using
      ConcreteModel.tanh_admissible.2 (a+Real.sqrt r*z) (b+Real.sqrt r*z)
  have hh := norm_integral_le_of_norm_le_const (μ := gaussianReal 0 1)
    (Filter.Eventually.of_forall hp)
  rw [integral_sub (shifted_tanh_integrable r a) (shifted_tanh_integrable r b)] at hh
  simpa only [shiftedMean,Real.norm_eq_abs,probReal_univ,one_mul,mul_one] using hh

theorem shiftedMean_abs_le_abs (r a : ℝ) : |shiftedMean r a| ≤ |a| := by
  simpa only [shiftedMean_zero,sub_zero] using shiftedMean_lipschitz r a 0

theorem shiftedMean_monotone (r : ℝ) : Monotone (shiftedMean r) := by
  intro a b hab
  exact integral_mono (shifted_tanh_integrable r a) (shifted_tanh_integrable r b)
    (fun z => BatchTwoNonGaussian.tanh_monotone (by linarith))

theorem shiftedMean_nonneg {a : ℝ} (ha : 0 ≤ a) (r : ℝ) : 0 ≤ shiftedMean r a := by
  simpa only [shiftedMean_zero] using shiftedMean_monotone r ha

#print axioms shiftedMean_abs_le_abs
end ConditionalNonpolynomial.Analytic
