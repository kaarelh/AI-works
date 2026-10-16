import NeuralGeneralization.BetaTruncation

/-! Exact positive moment representation of the normalized arcsine
coefficients, for finite Hankel positivity arguments. -/
noncomputable section
namespace NeuralGeneralization
open MeasureTheory Set

lemma arcsineDerivativeCoefficient_gamma (n : ℕ) :
    Real.Gamma ((n : ℝ)+1/2) = Real.sqrt Real.pi*(n.factorial : ℝ)*
      arcsineDerivativeCoefficient n := by
  induction n with
  | zero =>
    norm_num [arcsineDerivativeCoefficient]
    convert Real.Gamma_one_half_eq using 1 <;> norm_num
  | succ n ih =>
    rw [Nat.cast_succ,show (n : ℝ)+1+1/2=(n+1/2)+1 by ring,
      Real.Gamma_add_one (by positivity : (n : ℝ)+1/2 ≠ 0),ih,
      Nat.factorial_succ,Nat.cast_mul,Nat.cast_succ]
    have hr := arcsineDerivativeCoefficient_recurrence n
    calc
      _ = Real.sqrt Real.pi*(n.factorial : ℝ)*(((n : ℝ)+1/2)*arcsineDerivativeCoefficient n) := by ring
      _ = Real.sqrt Real.pi*(n.factorial : ℝ)*(((n : ℝ)+1)*arcsineDerivativeCoefficient (n+1)) := by rw [← hr]
      _ = _ := by ring

lemma arcsineDerivativeCoefficient_beta (n : ℕ) :
    (∫ v : ℝ in Ioo 0 1,v^((n : ℝ)-1/2)*(1-v)^(-(1/2 : ℝ))) =
      Real.pi*arcsineDerivativeCoefficient n := by
  have ha : 0 < (n : ℝ)+1/2 := by positivity
  have hb : (0 : ℝ) < 1/2 := by norm_num
  have he : (fun v : ℝ => v^((n : ℝ)-1/2)*(1-v)^(-(1/2 : ℝ))) =
      fun v : ℝ => v^((n : ℝ)+1/2-1)*(1-v)^((1/2 : ℝ)-1) := by
    funext v
    congr 1 <;> congr 1 <;> ring
  rw [he,real_beta_integral ha hb,show (n : ℝ)+1/2+1/2=n+1 by ring,
    Real.Gamma_nat_eq_factorial,arcsineDerivativeCoefficient_gamma,Real.Gamma_one_half_eq]
  have hf : (n.factorial : ℝ) ≠ 0 := by positivity
  have hs : (Real.sqrt Real.pi)^2=Real.pi := Real.sq_sqrt Real.pi_pos.le
  field_simp
  rw [hs]
  ring

/-- Positive double-integral moments of the actual odd coefficient. -/
theorem arcsineLinkCoefficient_moment (n : ℕ) :
    arcsineLinkCoefficient n = (2/Real.pi^2)*
      (∫ u : ℝ in Ioo 0 1, ∫ v : ℝ in Ioo 0 1,
        ((u^2*v)^n)*(v*(1-v))^(-(1/2 : ℝ))) := by
  have hinner (u : ℝ) :
      (∫ v : ℝ in Ioo 0 1,((u^2*v)^n)*(v*(1-v))^(-(1/2 : ℝ))) =
        u^(2*n)*(Real.pi*arcsineDerivativeCoefficient n) := by
    have he : ∀ v ∈ Ioo (0 : ℝ) 1,
        ((u^2*v)^n)*(v*(1-v))^(-(1/2 : ℝ)) =
        u^(2*n)*(v^((n : ℝ)-1/2)*(1-v)^(-(1/2 : ℝ))) := by
      intro v hv
      rw [mul_pow,← pow_mul,Real.mul_rpow hv.1.le (by linarith [hv.2])]
      rw [← Real.rpow_natCast v n]
      rw [show u^(2*n)*v^(n : ℝ)*(v^(-(1/2 : ℝ))*(1-v)^(-(1/2 : ℝ))) =
        u^(2*n)*(v^(n : ℝ)*v^(-(1/2 : ℝ)))*(1-v)^(-(1/2 : ℝ)) by ring,
        ← Real.rpow_add hv.1]
      simp only [sub_eq_add_neg,mul_assoc]
    rw [setIntegral_congr_fun measurableSet_Ioo he,integral_const_mul,
      arcsineDerivativeCoefficient_beta]
  simp_rw [hinner]
  rw [integral_mul_const,← integral_Ioc_eq_integral_Ioo,
    ← intervalIntegral.integral_of_le (by norm_num : (0 : ℝ) ≤ 1),integral_pow]
  simp only [one_pow,zero_pow (by omega : 2*n+1 ≠ 0),sub_zero,Nat.cast_add,Nat.cast_mul,Nat.cast_ofNat,Nat.cast_one]
  unfold arcsineLinkCoefficient arcsineCoefficient
  field_simp
  <;> ring

end NeuralGeneralization
