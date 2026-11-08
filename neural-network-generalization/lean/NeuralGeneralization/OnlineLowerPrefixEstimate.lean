import NeuralGeneralization.OnlineLowerBernsteinCost

noncomputable section
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerBernstein

theorem integrable_pow_laplace (p : ℕ) {z : ℝ} (hz : 0 < z) :
    IntegrableOn (fun t : ℝ => Real.exp (-z*t)*t^p) (Ioi 0) := by
  have hi := (integrableOn_Ioi_comp_mul_left_iff
    (fun t : ℝ => Real.exp (-t)*t^((p : ℝ)+1-1)) 0 hz).mpr
      (by simpa only [mul_zero] using
        Real.GammaIntegral_convergent (by positivity : (0 : ℝ)<(p : ℝ)+1))
  have hc := hi.const_mul ((z^p)⁻¹)
  apply hc.congr
  filter_upwards [] with t
  rw [add_sub_cancel_right, Real.rpow_natCast, mul_pow]
  have hn : z^p ≠ 0 := pow_ne_zero _ hz.ne'
  simp only [neg_mul]
  field_simp


theorem integral_pow_laplace (p : ℕ) {z : ℝ} (hz : 0 < z) :
    (∫ t in Ioi (0 : ℝ), Real.exp (-z*t)*t^p) = (p.factorial : ℝ)/z^(p+1) := by
  have hi := integral_rpow_mul_exp_neg_mul_rpow (p := (1 : ℝ))
    (q := (p : ℝ)) (b := z) (by norm_num) (by have := Nat.cast_nonneg (α := ℝ) p; linarith) hz
  norm_num only [Real.rpow_one, one_div, one_mul, div_one, mul_one] at hi
  rw [show (fun t : ℝ => Real.exp (-z*t)*t^p) =
    (fun t : ℝ => t^(p : ℝ)*Real.exp (-z*t)) by
      funext t; rw [Real.rpow_natCast]; ring, hi]
  rw [Real.Gamma_nat_eq_factorial, Real.rpow_neg hz.le,
    show (p : ℝ)+1=((p+1 : ℕ) : ℝ) by simp, Real.rpow_natCast]
  ring

/-- A uniform prefix estimate with the actual positive Bernstein density. -/
theorem density_integral_prefix_bound (p : ℕ) {n : ℝ} (hn : 1 < n)
    (f : ℝ → ℝ)
    (hi : IntegrableOn (fun t => Real.exp (-n*t)*reluCostDensity t*f t) (Ioi 0))
    (hf : ∀ t, 0 < t → |f t| ≤ (2*t)^p) :
    |∫ t in Ioi (0 : ℝ), Real.exp (-n*t)*reluCostDensity t*f t| ≤
      8*reluCostSlope*2^p*(p.factorial : ℝ)/(n-1)^(p+1) := by
  have hz : 0 < n-1 := by linarith
  have hg := (integrable_pow_laplace p hz).const_mul (8*reluCostSlope*2^p)
  have hmajor : ∀ t, 0 < t →
      |Real.exp (-n*t)*reluCostDensity t*f t| ≤
        (8*reluCostSlope*2^p)*(Real.exp (-(n-1)*t)*t^p) := by
    intro t ht
    rw [abs_mul, abs_mul, abs_of_pos (Real.exp_pos _), abs_of_pos (reluCostDensity_pos _)]
    calc
      _ ≤ Real.exp (-n*t)*(8*reluCostSlope*Real.exp t)*(2*t)^p := by
        apply mul_le_mul
        · exact mul_le_mul_of_nonneg_left (reluCostDensity_bound ht.le) (Real.exp_pos _).le
        · exact hf t ht
        · exact abs_nonneg _
        · exact mul_nonneg (mul_nonneg (by norm_num) reluCostSlope_pos.le) (Real.exp_pos _).le |> fun h => mul_nonneg (Real.exp_pos _).le h
      _ = _ := by
        rw [mul_pow]
        have he : Real.exp (-n*t)*Real.exp t = Real.exp (-(n-1)*t) := by
          rw [← Real.exp_add]; congr 1; ring
        calc
          _ = (8*reluCostSlope*2^p)*(Real.exp (-n*t)*Real.exp t)*t^p := by ring
          _ = _ := by rw [he]; ring
  calc
    _ ≤ ∫ t in Ioi (0 : ℝ), |Real.exp (-n*t)*reluCostDensity t*f t| := abs_integral_le_integral_abs
    _ ≤ ∫ t in Ioi (0 : ℝ), (8*reluCostSlope*2^p)*(Real.exp (-(n-1)*t)*t^p) := by
      apply integral_mono_ae hi.norm hg
      filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
      exact hmajor t ht
    _ = _ := by rw [integral_const_mul, integral_pow_laplace p hz]; ring

end NeuralGeneralization.OnlineLowerBernstein
