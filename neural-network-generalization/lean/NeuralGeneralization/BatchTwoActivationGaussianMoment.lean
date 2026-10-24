import NeuralGeneralization.BatchTwoActivationGaussianConcentration
import Mathlib.MeasureTheory.Integral.Layercake
import Mathlib.Analysis.SpecialFunctions.ImproperIntegrals

/-!
# A dimension-free exponential moment for Gaussian projection distance

The complete concentration-to-moment step is proved using the layer-cake
formula. This supplies a finite, explicit MGF for sums over independent
Gaussian rows in the unbounded-activation bulk/tail decomposition.
-/

noncomputable section
open MeasureTheory ProbabilityTheory Set Filter
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoActivation

theorem gaussian_zeroSet_exp_square_moment {n : ℕ}
    (F : (Fin n→ℝ)→ℝ) (hF : Measurable F) (hLip : SquareLipschitz F)
    (A : Set (Fin n→ℝ)) (hA : MeasurableSet A)
    (hmass : (1/2:ℝ)≤(standardGaussian n).real A) (hzero : ∀x∈A, F x=0) :
    (∫⁻ x, ENNReal.ofReal (Real.exp ((F x)^2/8)) ∂standardGaussian n)≤3 := by
  let Y := fun x => (F x)^2/8
  have hY : Measurable Y := (hF.pow_const 2).div_const 8
  have hYpos : ∀x, 0≤Y x := by intro x; dsimp [Y]; positivity
  have hcake := lintegral_comp_eq_lintegral_meas_le_mul (f := Y) (g := Real.exp)
    (standardGaussian n) (Eventually.of_forall hYpos) hY.aemeasurable
    (fun t _ => Real.continuous_exp.intervalIntegrable 0 t)
    (Eventually.of_forall (fun t => (Real.exp_pos t).le))
  simp only [integral_exp, Real.exp_zero] at hcake
  have htail (t : ℝ) : standardGaussian n {x | t≤Y x}≤
      ENNReal.ofReal (2*Real.exp (-(8*t)/4)) := by
    have ht := gaussian_zeroSet_square_tail F hF hLip A hA hmass hzero (8*t)
    have he : {x | t≤Y x}={x | 8*t≤(F x)^2} := by
      ext x
      dsimp [Y]
      rw [le_div_iff₀ (by norm_num : (0:ℝ)<8)]
      constructor <;> intro h <;> nlinarith
    rw [he]
    have h := ENNReal.ofReal_le_ofReal ht
    simpa only [Measure.real, ENNReal.ofReal_toReal (measure_ne_top _ _)] using h
  have hpoint (t : ℝ) : standardGaussian n {x | t≤Y x}*ENNReal.ofReal (Real.exp t)≤
      ENNReal.ofReal (2*Real.exp (-t)) := by
    calc
      _ ≤ ENNReal.ofReal (2*Real.exp (-(8*t)/4))*ENNReal.ofReal (Real.exp t) :=
        mul_le_mul' (htail t) le_rfl
      _ = _ := by
        rw [← ENNReal.ofReal_mul (by positivity : 0≤2*Real.exp (-(8*t)/4))]
        congr 1
        rw [mul_assoc, ← Real.exp_add]
        congr 1
        ring
  have hintegral : (∫⁻ t in Ioi (0:ℝ), ENNReal.ofReal (2*Real.exp (-t)))=2 := by
    rw [← ofReal_integral_eq_lintegral_ofReal
      ((integrableOn_exp_neg_Ioi 0).const_mul 2) (Eventually.of_forall (fun t => by positivity)),
      integral_const_mul, integral_exp_neg_Ioi_zero]
    norm_num
  have hsub : (∫⁻ x, ENNReal.ofReal (Real.exp (Y x)-1) ∂standardGaussian n)≤2 := by
    rw [hcake]
    exact (lintegral_mono hpoint).trans_eq hintegral
  have hdecomp (x : Fin n→ℝ) : ENNReal.ofReal (Real.exp (Y x))=
      1+ENNReal.ofReal (Real.exp (Y x)-1) := by
    have he : 1≤Real.exp (Y x) := Real.one_le_exp_iff.mpr (hYpos x)
    rw [← ENNReal.ofReal_one, ← ENNReal.ofReal_add (by norm_num : (0:ℝ)≤1) (by linarith)]
    congr 1
    ring
  change (∫⁻ x, ENNReal.ofReal (Real.exp (Y x)) ∂standardGaussian n)≤3
  simp_rw [hdecomp]
  rw [lintegral_add_left measurable_const]
  simp only [lintegral_const, measure_univ, mul_one]
  calc
    _ ≤ 1+2 := add_le_add le_rfl hsub
    _ = _ := by norm_num

end NeuralGeneralization.BatchTwoActivation
