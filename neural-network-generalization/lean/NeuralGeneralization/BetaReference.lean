import NeuralGeneralization.GammaRatioBounds
import Mathlib.Analysis.SpecialFunctions.Gamma.Beta
import Mathlib.Data.Nat.Choose.Basic

/-! Exact real beta-integral normalization for spectral level masses. -/
noncomputable section
namespace NeuralGeneralization
open MeasureTheory Set
open scoped BigOperators

/-- Real beta integral, deduced from the proved complex beta/Gamma identity. -/
theorem real_beta_integral {a b : ℝ} (ha : 0 < a) (hb : 0 < b) :
    (∫ p : ℝ in Ioo 0 1,p^(a-1)*(1-p)^(b-1)) =
      Real.Gamma a*Real.Gamma b/Real.Gamma (a+b) := by
  apply Complex.ofReal_injective
  rw [← integral_complex_ofReal]
  calc
    _ = ∫ p : ℝ in Ioo 0 1,(p : ℂ)^((a : ℂ)-1)*(1-(p : ℂ))^((b : ℂ)-1) := by
      apply setIntegral_congr_fun measurableSet_Ioo
      intro p hp
      dsimp only
      rw [Complex.ofReal_mul]
      rw [show (a : ℂ)-1=((a-1 : ℝ) : ℂ) by push_cast; rfl,
        show (b : ℂ)-1=((b-1 : ℝ) : ℂ) by push_cast; rfl,
        show (1 : ℂ)-(p : ℂ)=((1-p : ℝ) : ℂ) by push_cast; rfl,
        Complex.ofReal_cpow hp.1.le,Complex.ofReal_cpow (show 0 ≤ 1-p by linarith [hp.2])]
    _ = Complex.betaIntegral (a : ℂ) (b : ℂ) := by
      rw [Complex.betaIntegral,intervalIntegral.integral_of_le (by norm_num : (0 : ℝ) ≤ 1),
        integral_Ioc_eq_integral_Ioo]
    _ = _ := by
      rw [Complex.betaIntegral_eq_Gamma_mul_div _ _ (by simpa) (by simpa),
        ← Complex.ofReal_add,Complex.Gamma_ofReal,Complex.Gamma_ofReal,Complex.Gamma_ofReal]
      push_cast
      rfl

/-- Exact combined multiplicity times beta integral, in Gamma-ratio form. -/
theorem binomial_beta_reference_identity {D j : ℕ} (hj : 1 ≤ j) (hjD : j ≤ D)
    {β : ℝ} (hβ1 : β < 1) :
    (D.choose j : ℝ)*(∫ p : ℝ in Ioo 0 1,
      p^((j : ℝ)-β-1)*(1-p)^((D-j : ℕ) : ℝ)) =
      (Real.Gamma ((j : ℝ)-β)/(j.factorial : ℝ))*
        ((D.factorial : ℝ)/Real.Gamma ((D : ℝ)+1-β)) := by
  have hjR : (1 : ℝ) ≤ j := by exact_mod_cast hj
  have ha : (0 : ℝ) < j-β := by linarith
  have hb : (0 : ℝ) < (D-j : ℕ)+1 := by positivity
  have he : (fun p : ℝ => p^((j : ℝ)-β-1)*(1-p)^((D-j : ℕ) : ℝ)) =
      fun p : ℝ => p^((j : ℝ)-β-1)*(1-p)^(((D-j : ℕ) : ℝ)+1-1) := by
    funext p
    rw [add_sub_cancel_right]
  rw [he,real_beta_integral ha hb,Real.Gamma_nat_eq_factorial]
  have hcast : ((D-j : ℕ) : ℝ)=(D : ℝ)-j := Nat.cast_sub hjD
  rw [hcast,show (j : ℝ)-β+(D-j+1)=D+1-β by ring]
  have hfac : (D.choose j : ℝ)*(j.factorial : ℝ)*((D-j).factorial : ℝ) = D.factorial := by
    exact_mod_cast Nat.choose_mul_factorial_mul_factorial hjD
  have hjfac : (j.factorial : ℝ) ≠ 0 := by positivity
  have hΓ : Real.Gamma ((D : ℝ)+1-β) ≠ 0 := by
    apply ne_of_gt (Real.Gamma_pos_of_pos _)
    have hD : (j : ℝ) ≤ D := by exact_mod_cast hjD
    linarith
  field_simp
  nlinarith only [hfac]

/-- Sharp complete-beta level bounds, uniform in dimension and degree.
The constants are explicit for every fractional exponent in `(0,1)`. -/
theorem binomial_beta_reference_bounds {D j : ℕ} (hj : 1 ≤ j) (hjD : j ≤ D)
    {β : ℝ} (hβ0 : 0 < β) (hβ1 : β < 1) :
    (1-β)*((D : ℝ)+1)^β ≤
      (j : ℝ)^(1+β)*(D.choose j : ℝ)*(∫ p : ℝ in Ioo 0 1,
        p^((j : ℝ)-β-1)*(1-p)^((D-j : ℕ) : ℝ)) ∧
    (j : ℝ)^(1+β)*(D.choose j : ℝ)*(∫ p : ℝ in Ioo 0 1,
        p^((j : ℝ)-β-1)*(1-p)^((D-j : ℕ) : ℝ)) ≤
      ((D : ℝ)+1)^β/(1-β) := by
  let p : ℝ := (j : ℝ)^(1+β)*(Real.Gamma ((j : ℝ)-β)/(j.factorial : ℝ))
  let q : ℝ := ((D : ℝ)+1)^(1+β)*
    (Real.Gamma ((D : ℝ)+1-β)/((D+1).factorial : ℝ))
  have hp : 1 ≤ p ∧ p ≤ 1/(1-β) := gamma_coefficient_power_bounds hj hβ0 hβ1
  have hq : 1 ≤ q ∧ q ≤ 1/(1-β) := by
    simpa only [Nat.cast_add,Nat.cast_one] using
      gamma_coefficient_power_bounds (show 1 ≤ D+1 by omega) hβ0 hβ1
  have hp0 : 0 ≤ p := by linarith [hp.1]
  have hq0 : 0 < q := by linarith [hq.1]
  have hβ : 0 < 1-β := by linarith
  have hlo : 1-β ≤ p/q := by
    apply (le_div_iff₀ hq0).mpr
    have hh := (le_div_iff₀ hβ).mp hq.2
    nlinarith only [hh,hp.1]
  have hup : p/q ≤ 1/(1-β) := (div_le_self hp0 hq.1).trans hp.2
  have hD0 : 0 < (D : ℝ)+1 := by positivity
  have hΓ : Real.Gamma ((D : ℝ)+1-β) ≠ 0 := by
    apply ne_of_gt (Real.Gamma_pos_of_pos _)
    have hD1 : (1 : ℝ) ≤ D := by exact_mod_cast (hj.trans hjD)
    linarith
  have hpow0 : ((D : ℝ)+1)^β ≠ 0 := ne_of_gt (Real.rpow_pos_of_pos hD0 _)
  have hid : (j : ℝ)^(1+β)*
      ((D.choose j : ℝ)*(∫ t : ℝ in Ioo 0 1,
        t^((j : ℝ)-β-1)*(1-t)^((D-j : ℕ) : ℝ))) = ((D : ℝ)+1)^β*(p/q) := by
    rw [binomial_beta_reference_identity hj hjD hβ1]
    dsimp [p,q]
    rw [Real.rpow_add hD0,Real.rpow_one,Nat.factorial_succ,Nat.cast_mul,
      Nat.cast_add,Nat.cast_one]
    field_simp
  have hpow : 0 ≤ ((D : ℝ)+1)^β := Real.rpow_nonneg hD0.le _
  constructor
  · have hh := mul_le_mul_of_nonneg_left hlo hpow
    rw [← hid] at hh
    simpa only [mul_assoc,mul_comm,mul_left_comm] using hh
  · have hh := mul_le_mul_of_nonneg_left hup hpow
    rw [← hid] at hh
    simpa only [mul_one_div,mul_assoc] using hh

end NeuralGeneralization
