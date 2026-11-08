import Mathlib.MeasureTheory.Function.JacobianOneDim
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Analysis.SpecialFunctions.Log.Basic

noncomputable section
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerBernstein

private theorem expNeg_image : (fun t : ℝ => Real.exp (-t)) '' Ioi 0 = Ioo 0 1 := by
  ext x
  constructor
  · rintro ⟨t,ht,rfl⟩
    exact ⟨Real.exp_pos _,Real.exp_lt_one_iff.mpr (neg_neg_of_pos ht)⟩
  · intro hx
    refine ⟨-Real.log x,?_,?_⟩
    · exact neg_pos.mpr (Real.log_neg hx.1 hx.2)
    · simp [Real.exp_log hx.1]

private theorem expNeg_deriv (t : ℝ) :
    HasDerivWithinAt (fun t : ℝ => Real.exp (-t)) (-Real.exp (-t)) (Ioi 0) t := by
  simpa only [mul_neg, mul_one] using ((hasDerivAt_neg t).exp).hasDerivWithinAt

private theorem expNeg_inj : InjOn (fun t : ℝ => Real.exp (-t)) (Ioi 0) := by
  intro x hx y hy h
  exact neg_injective (Real.exp_injective h)

/-- The exponential substitution is established at the actual improper
Lebesgue integral, without unproved convergence assumptions. -/
theorem integral_expNeg_substitution (g : ℝ → ℝ) :
    (∫ x in Ioo (0:ℝ) 1,g x) =
      ∫ t in Ioi (0:ℝ),Real.exp (-t)*g (Real.exp (-t)) := by
  have h := integral_image_eq_integral_abs_deriv_smul measurableSet_Ioi
    (fun t _ => expNeg_deriv t) expNeg_inj g
  rw [expNeg_image] at h
  simpa [abs_neg,abs_of_pos (Real.exp_pos _)] using h

theorem integrable_expNeg_substitution (g : ℝ → ℝ) :
    IntegrableOn g (Ioo (0:ℝ) 1) ↔
      IntegrableOn (fun t => Real.exp (-t)*g (Real.exp (-t))) (Ioi (0:ℝ)) := by
  have h := integrableOn_image_iff_integrableOn_abs_deriv_smul measurableSet_Ioi
    (fun t _ => expNeg_deriv t) expNeg_inj g
  rw [expNeg_image] at h
  simpa [abs_neg,abs_of_pos (Real.exp_pos _)] using h

end NeuralGeneralization.OnlineLowerBernstein
