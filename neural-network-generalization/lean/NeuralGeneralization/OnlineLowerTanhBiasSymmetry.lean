import NeuralGeneralization.OnlineLowerTanhBiasIntegral

/-! # Exact bias reflection and odd-degree stationarity -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel

/-- Reflection of the literal finite-cube tanh coefficient, at every degree. -/
theorem parityCorrelation_bias_reflection {n : ℕ} (u : Fin n → ℝ) (b : ℝ) :
    parityCorrelation u (-b) = -((-1 : ℝ)^n)*parityCorrelation u b := by
  have hpoint (x : Cube n) :
      paritySign (negateInputs n x)*Real.tanh (-b+incomingLinear u (negateInputs n x)) =
        -((-1 : ℝ)^n)*(paritySign x*Real.tanh (b+incomingLinear u x)) := by
    rw [paritySign_negate, incomingLinear_negate]
    rw [show -b + -incomingLinear u x = -(b+incomingLinear u x) by ring, Real.tanh_neg]
    ring
  have hsum := (negateInputs n).sum_comp
    (fun x => paritySign x*Real.tanh (-b+incomingLinear u x))
  simp_rw [hpoint] at hsum
  unfold parityCorrelation
  rw [← hsum, ← Finset.mul_sum]
  ring

theorem abs_parityCorrelation_bias_neg {n : ℕ} (u : Fin n → ℝ) (b : ℝ) :
    |parityCorrelation u (-b)| = |parityCorrelation u b| := by
  rw [parityCorrelation_bias_reflection]
  simp only [abs_mul, abs_neg, abs_pow, abs_one, one_pow, one_mul]

/-- Odd selected degree has exactly zero first bias derivative at the origin. -/
theorem parityBiasFirst_zero_of_odd {n : ℕ} (hn : Odd n) (u : Fin n → ℝ) :
    parityBiasFirst u 0 = 0 := by
  have hd := hasDerivAt_parityCorrelation u 0
  have hdneg := hasDerivAt_parityCorrelation u (-(0 : ℝ))
  have hc := hdneg.comp (0 : ℝ) (hasDerivAt_id (0 : ℝ)).neg
  simp only [neg_zero] at hc
  have he : (fun x : ℝ => parityCorrelation u (-x)) = parityCorrelation u :=
    funext (parityCorrelation_bias_neg hn u)
  change HasDerivAt (fun x : ℝ => parityCorrelation u (-x))
    (parityBiasFirst u 0 * -1) 0 at hc
  rw [he] at hc
  have hh := hd.unique hc
  linarith

end NeuralGeneralization.OnlineLowerTanh
