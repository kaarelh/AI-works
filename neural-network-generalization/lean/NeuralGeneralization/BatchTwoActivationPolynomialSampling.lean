import NeuralGeneralization.BatchTwoActivationPolynomialError

/-! Polynomial finite sampling widths and source-coordinate bounds. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoActivation

theorem exp_neg_four_lt_quarter : Real.exp (-4:ℝ)<1/4 := by
  rw [Real.exp_neg]
  have hh := Real.add_one_le_exp (4:ℝ)
  have hp := Real.exp_pos (4:ℝ)
  simpa only [one_div] using
    (one_div_lt_one_div_of_lt (by norm_num : (0:ℝ)<4) (by linarith : (4:ℝ)<Real.exp 4))

theorem finite_covariance_union_small {m x R : ℝ} (hm : 0<m) (hx : 128≤x)
    (hlog : Real.log (2*m)≤x) (hR : 4*x≤R) :
    2*m^2*Real.exp (-R)<1/4 := by
  have hpow : 2*m^2≤Real.exp (2*x) := by
    have he : Real.exp (2*Real.log (2*m))=(2*m)^2 := by
      rw [two_mul,Real.exp_add,Real.exp_log (by positivity)]
      ring
    have hh := Real.exp_le_exp.mpr (show 2*Real.log (2*m)≤2*x by linarith)
    rw [he] at hh
    nlinarith [sq_nonneg m]
  calc
    _ ≤ Real.exp (2*x)*Real.exp (-R) := mul_le_mul_of_nonneg_right hpow (Real.exp_nonneg _)
    _ = Real.exp (2*x-R) := by rw [←Real.exp_add]; ring_nf
    _ ≤ Real.exp (-4:ℝ) := Real.exp_le_exp.mpr (by linarith)
    _ < _ := exp_neg_four_lt_quarter

theorem atom_sampling_rate_polynomial {x ℓ M A n : ℝ} (hx : 128≤x)
    (hℓ0 : 0<ℓ) (hM0 : 0<M) (hA0 : 0<A)
    (hℓ : ℓ≤x) (hM : M≤x) (hA : A≤x) (hn : x^20≤n) :
    4*x≤n*(((1/x^2)/A)/(ℓ*Real.sqrt M)^2)^2/2 := by
  have hx0 : 0<x := by linarith
  have hx1 : 1≤x := by linarith
  have hden : x^2*A*ℓ^2*M≤x^6 := by
    calc
      _ ≤ x^2*x*x^2*x := by gcongr
      _ = _ := by ring
  have hrat : 1/x^6≤((1/x^2)/A)/(ℓ*Real.sqrt M)^2 := by
    have he : ((1/x^2)/A)/(ℓ*Real.sqrt M)^2=1/(x^2*A*ℓ^2*M) := by
      rw [mul_pow,Real.sq_sqrt hM0.le]
      field_simp
    rw [he]
    exact one_div_le_one_div_of_le (by positivity) hden
  have hs : (1/x^6)^2≤(((1/x^2)/A)/(ℓ*Real.sqrt M)^2)^2 :=
    pow_le_pow_left₀ (by positivity) hrat 2
  have hm := mul_le_mul hn hs (by positivity : 0≤(1/x^6)^2) (by linarith [pow_pos hx0 20])
  have he : x^20*(1/x^6)^2=x^8 := by field_simp <;> ring
  rw [he] at hm
  have hx8 : x^3≤x^8 := pow_le_pow_right₀ hx1 (by omega)
  have hx3 : 8*x≤x^3 := by nlinarith
  linarith

theorem bulk_sampling_rate_polynomial {x ℓ n : ℝ} (hx : 128≤x)
    (hℓ0 : 0<ℓ) (hℓ : ℓ≤x) (hn : x^48≤n) :
    4*x≤n*((1/x^2)/(4*ℓ*x^8)^2)^2/2 := by
  have hx0 : 0<x := by linarith
  have hx1 : 1≤x := by linarith
  have hden : 16*ℓ^2*x^18≤16*x^20 := by
    calc
      _ ≤ 16*x^2*x^18 := by gcongr
      _ = _ := by ring
  have hrat : 1/(16*x^20)≤(1/x^2)/(4*ℓ*x^8)^2 := by
    have he : (1/x^2)/(4*ℓ*x^8)^2=1/(16*ℓ^2*x^18) := by field_simp <;> ring
    rw [he]
    exact one_div_le_one_div_of_le (by positivity) hden
  have hs : (1/(16*x^20))^2≤((1/x^2)/(4*ℓ*x^8)^2)^2 :=
    pow_le_pow_left₀ (by positivity) hrat 2
  have hm := mul_le_mul hn hs (by positivity : 0≤(1/(16*x^20))^2) (by linarith [pow_pos hx0 48])
  have he : x^48*(1/(16*x^20))^2=x^8/256 := by field_simp <;> ring
  rw [he] at hm
  have hx8 : x^3≤x^8 := pow_le_pow_right₀ hx1 (by omega)
  have hx2 : 2048≤x^2 := by nlinarith
  have hx3 : 2048*x≤x^3 := by nlinarith
  linarith

theorem gaussian_source_union_small {G n r R : ℝ} (hG : 0≤G) (hn : 0≤n) (hr : 0≤r)
    (hR : 4*G+4*n*(r+1)+4≤R) :
    2*n*r*Real.exp (2*G-R^2/2)<1/4 := by
  let z := 2*n*(r+1)
  have hz : 0≤z := by dsimp [z]; positivity
  have hR4 : 4≤R := by nlinarith
  have hs : 2*G-R^2/2≤-z-4 := by dsimp [z]; nlinarith
  have hp : 2*n*r≤z := by dsimp [z]; nlinarith
  have hexp : z*Real.exp (-z)≤1 := by
    have he : z≤Real.exp z := by linarith [Real.add_one_le_exp z]
    have hh := mul_le_mul_of_nonneg_right he (Real.exp_nonneg (-z))
    simpa only [←Real.exp_add,add_neg_cancel,Real.exp_zero] using hh
  calc
    _ ≤ z*Real.exp (-z-4) := mul_le_mul hp (Real.exp_le_exp.mpr hs) (Real.exp_nonneg _) hz
    _ = (z*Real.exp (-z))*Real.exp (-4:ℝ) := by rw [show -z-4=(-z)+(-4) by ring,Real.exp_add]; ring
    _ ≤ 1*Real.exp (-4:ℝ) := mul_le_mul_of_nonneg_right hexp (Real.exp_nonneg _)
    _ < _ := by simpa only [one_mul] using exp_neg_four_lt_quarter

end NeuralGeneralization.BatchTwoActivation
