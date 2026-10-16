import NeuralGeneralization.KernelPoissonOdd
import Mathlib.Analysis.SpecialFunctions.Gamma.Basic

/-! The exact Gamma integral for one term of the actual coordinate-walk
Poisson series. This records the normalization needed for spectral estimates. -/

noncomputable section
namespace NeuralGeneralization
open MeasureTheory Set
open scoped BigOperators

/-- Gamma-integrating an actual path-count Poisson term yields the
Gamma-ratio walk weight, with the correct `(d+1)^β` factor. -/
theorem biased_path_poisson_gamma_integral (d m : ℕ) (β : ℝ)
    (hm : β < (m : ℝ)) (S : Finset (Fin d)) :
    (∫ u : ℝ in Ioi 0,
      u^(-1-β)*Real.exp (-((d : ℝ)+1)*u)*
        (u^m/(m.factorial : ℝ))*(biasedPathCount m S : ℝ)) =
      ((d : ℝ)+1)^β * (Real.Gamma ((m : ℝ)-β)/(m.factorial : ℝ)) *
        ((biasedPathCount m S : ℝ)/((d : ℝ)+1)^m) := by
  have hD : 0 < (d : ℝ)+1 := by positivity
  have hpoint (u : ℝ) (hu : u ∈ Ioi 0) :
      u^(-1-β)*Real.exp (-((d : ℝ)+1)*u)*(u^m/(m.factorial : ℝ))*
        (biasedPathCount m S : ℝ) =
      ((biasedPathCount m S : ℝ)/(m.factorial : ℝ))*
        (u^((m : ℝ)-β-1)*Real.exp (-(((d : ℝ)+1)*u))) := by
    have hp : u^(-1-β)*u^m = u^((m : ℝ)-β-1) := by
      rw [← Real.rpow_natCast,← Real.rpow_add hu]
      congr 1
      ring
    rw [show -((d : ℝ)+1)*u = -(((d : ℝ)+1)*u) by ring]
    calc
      _ = ((biasedPathCount m S : ℝ)/(m.factorial : ℝ))*
          ((u^(-1-β)*u^m)*Real.exp (-(((d : ℝ)+1)*u))) := by ring
      _ = _ := by rw [hp]
  rw [setIntegral_congr_fun measurableSet_Ioi hpoint,integral_const_mul,
    Real.integral_rpow_mul_exp_neg_mul_Ioi (sub_pos.mpr hm) hD]
  have hp : (1/((d : ℝ)+1))^((m : ℝ)-β) =
      ((d : ℝ)+1)^β/((d : ℝ)+1)^m := by
    rw [one_div,Real.inv_rpow hD.le,Real.rpow_sub hD,Real.rpow_natCast]
    rw [inv_div]
  rw [hp]
  ring

end NeuralGeneralization
