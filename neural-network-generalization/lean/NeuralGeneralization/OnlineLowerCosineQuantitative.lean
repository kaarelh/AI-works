import NeuralGeneralization.OnlineLowerTanhResidualSaddle
import Mathlib.Analysis.SpecialFunctions.Gaussian.GaussianIntegral

/-! A global quantitative Gaussian approximation for the actual pure cosine saddle. -/
noncomputable section
open scoped BigOperators Topology
open Set MeasureTheory
namespace NeuralGeneralization.OnlineLowerTanh

lemma exp_sub_le_linear (u v:ℝ) (hvu:v≤u) :
    Real.exp u-Real.exp v≤(u-v)*Real.exp u := by
  have h:=Real.add_one_le_exp (v-u)
  have hh:=mul_le_mul_of_nonneg_right h (Real.exp_pos u).le
  rw [Real.exp_sub] at hh
  have he:Real.exp v/Real.exp u*Real.exp u=Real.exp v :=
    div_mul_cancel₀ _ (Real.exp_ne_zero _)
  rw [he] at hh
  nlinarith

lemma abs_exp_sub_exp_le (u v U:ℝ) (hu:u≤U) (hv:v≤U) :
    |Real.exp u-Real.exp v|≤|u-v| *Real.exp U := by
  rcases le_total v u with h|h
  · rw [abs_of_nonneg (sub_nonneg.mpr (Real.exp_le_exp.mpr h)),abs_of_nonneg (sub_nonneg.mpr h)]
    exact (exp_sub_le_linear u v h).trans
      (mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr hu) (sub_nonneg.mpr h))
  · rw [abs_sub_comm (Real.exp u),abs_sub_comm u]
    rw [abs_of_nonneg (sub_nonneg.mpr (Real.exp_le_exp.mpr h)),abs_of_nonneg (sub_nonneg.mpr h)]
    exact (exp_sub_le_linear v u h).trans
      (mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr hv) (sub_nonneg.mpr h))

lemma cosine_gaussian_local_error (n:ℕ) (x:ℝ) (hx:|x|≤1/2) :
    |Real.cos x^n-Real.exp (-(n:ℝ)*x^2/2)|≤
      (n:ℝ)*x^4*Real.exp (-(n:ℝ)*x^2/8) := by
  have hx2:x^2≤1/4 := by nlinarith [sq_abs x,abs_nonneg x]
  have hc:0<Real.cos x := by linarith [Real.one_sub_sq_div_two_le_cos (x:=x)]
  have hl:=log_cosine_quartic_error hx
  have hlog:Real.log (Real.cos x)≤-x^2/4 := by
    have h4:x^4≤x^2/4 := by nlinarith [mul_le_mul_of_nonneg_left hx2 (sq_nonneg x)]
    have hh:Real.log (Real.cos x)+x^2/2≤x^4 := (le_abs_self _).trans hl
    linarith
  have hn:0≤(n:ℝ) := Nat.cast_nonneg _
  have hu:(n:ℝ)*Real.log (Real.cos x)≤-(n:ℝ)*x^2/4 := by
    nlinarith [mul_le_mul_of_nonneg_left hlog hn]
  have hv:-(n:ℝ)*x^2/2≤-(n:ℝ)*x^2/4 := by nlinarith [mul_nonneg hn (sq_nonneg x)]
  have hh:=abs_exp_sub_exp_le _ _ _ hu hv
  have he:Real.exp ((n:ℝ)*Real.log (Real.cos x))=Real.cos x^n := by
    rw [Real.exp_nat_mul,Real.exp_log hc]
  rw [he] at hh
  have hd : |(n:ℝ)*Real.log (Real.cos x)-(-(n:ℝ)*x^2/2)|≤(n:ℝ)*x^4 := by
    rw [show (n:ℝ)*Real.log (Real.cos x)-(-(n:ℝ)*x^2/2)=
      (n:ℝ)*(Real.log (Real.cos x)+x^2/2) by ring,abs_mul,abs_of_nonneg hn]
    exact mul_le_mul_of_nonneg_left hl hn
  exact hh.trans (mul_le_mul hd (Real.exp_le_exp.mpr (by nlinarith [mul_nonneg hn (sq_nonneg x)]))
    (Real.exp_pos _).le (by positivity))

def truncatedCosinePower (n:ℕ) (x:ℝ) : ℝ :=
  if |x|≤Real.pi/2 then Real.cos x^n else 0

lemma truncatedCosinePower_nonneg (n:ℕ) (x:ℝ) : 0≤truncatedCosinePower n x := by
  unfold truncatedCosinePower
  split_ifs with hx
  · exact pow_nonneg (Real.cos_nonneg_of_neg_pi_div_two_le_of_le (by linarith [(abs_le.mp hx).1])
      (abs_le.mp hx).2) _
  · rfl

lemma truncatedCosinePower_bound (n:ℕ) (x:ℝ) :
    truncatedCosinePower n x≤Real.exp (-(n:ℝ)*x^2/8) := by
  unfold truncatedCosinePower
  split_ifs with hx
  · have hc:0≤Real.cos x := Real.cos_nonneg_of_neg_pi_div_two_le_of_le
      (by linarith [(abs_le.mp hx).1]) (abs_le.mp hx).2
    have h:=cos_le_exp_square (x:=x) (hx.trans (by linarith [Real.pi_pos]))
    have hp:=pow_le_pow_left₀ hc h n
    rw [←Real.exp_nat_mul] at hp
    apply hp.trans (Real.exp_le_exp.mpr ?_)
    have hpi:0<Real.pi^2 := sq_pos_of_pos Real.pi_pos
    have hpi2:Real.pi^2≤16 := by nlinarith [Real.pi_lt_four,Real.pi_pos]
    have he:(1/8:ℝ)≤2/Real.pi^2 := (le_div_iff₀ hpi).mpr (by linarith)
    have hh:=mul_le_mul_of_nonneg_right he (mul_nonneg (Nat.cast_nonneg (α:=ℝ) n) (sq_nonneg x))
    nlinarith
  · exact (Real.exp_pos _).le

/-- A polynomially weighted Gaussian dominates the error on the entire real
line, including outside the finite saddle cell. -/
theorem truncatedCosinePower_error (n:ℕ) (x:ℝ) :
    |truncatedCosinePower n x-Real.exp (-(n:ℝ)*x^2/2)|≤
      ((n:ℝ)*x^4+8*x^2)*Real.exp (-(n:ℝ)*x^2/8) := by
  by_cases hx:|x|≤1/2
  · have hp:|x|≤Real.pi/2 := hx.trans (by linarith [Real.pi_gt_three])
    rw [truncatedCosinePower,if_pos hp]
    exact (cosine_gaussian_local_error n x hx).trans
      (mul_le_mul_of_nonneg_right (by nlinarith [sq_nonneg x]) (Real.exp_pos _).le)
  · have hx2:(1/4:ℝ)≤x^2 := by
      have h:1/2 < |x| := lt_of_not_ge hx
      nlinarith [sq_abs x,abs_nonneg x]
    have hb:=truncatedCosinePower_bound n x
    have hg:Real.exp (-(n:ℝ)*x^2/2)≤Real.exp (-(n:ℝ)*x^2/8) :=
      Real.exp_le_exp.mpr (by nlinarith [mul_nonneg (Nat.cast_nonneg (α:=ℝ) n) (sq_nonneg x)])
    calc
      _ ≤ truncatedCosinePower n x+Real.exp (-(n:ℝ)*x^2/2) := by
        exact (abs_sub _ _).trans_eq (by rw [abs_of_nonneg (truncatedCosinePower_nonneg n x),Real.abs_exp])
      _ ≤ 2*Real.exp (-(n:ℝ)*x^2/8) := by linarith
      _ ≤ _ := mul_le_mul_of_nonneg_right (by nlinarith [mul_nonneg (Nat.cast_nonneg (α:=ℝ) n) (show 0≤x^4 by positivity)])
        (Real.exp_pos _).le

lemma scaled_cosine_error (n:ℕ) (hn:0<n) (y:ℝ) :
    |truncatedCosinePower n (y/Real.sqrt n)-Real.exp (-y^2/2)|≤
      ((y^4+8*y^2)*Real.exp (-y^2/8))/(n:ℝ) := by
  have hn':0<(n:ℝ) := Nat.cast_pos.mpr hn
  have hs:0<Real.sqrt (n:ℝ) := Real.sqrt_pos.mpr hn'
  have hs2:Real.sqrt (n:ℝ)^2=(n:ℝ) := Real.sq_sqrt hn'.le
  have he2:(n:ℝ)*(y/Real.sqrt (n:ℝ))^2=y^2 := by
    rw [div_pow,hs2]; field_simp
  have he4:(n:ℝ)*(y/Real.sqrt (n:ℝ))^4=y^4/(n:ℝ) := by
    rw [div_pow,show Real.sqrt (n:ℝ)^4=(n:ℝ)^2 by nlinarith [sq_nonneg (Real.sqrt (n:ℝ)^2-(n:ℝ))]]
    field_simp
  have he22:(y/Real.sqrt (n:ℝ))^2=y^2/(n:ℝ) := by rw [div_pow,hs2]
  have h:=truncatedCosinePower_error n (y/Real.sqrt (n:ℝ))
  rw [show -(n:ℝ)*(y/Real.sqrt (n:ℝ))^2 = -y^2 by nlinarith [he2],he4,he22] at h
  convert h using 1 <;> ring

lemma integrable_natPower_gaussian (p:ℕ) (b:ℝ) (hb:0<b) :
    Integrable (fun y:ℝ=>y^p*Real.exp (-b*y^2)) := by
  have hp:(-1:ℝ)<(p:ℝ) := by have h:=Nat.cast_nonneg (α:=ℝ) p; linarith
  simpa only [Real.rpow_natCast] using integrable_rpow_mul_exp_neg_mul_sq hb hp

def cosineErrorMajorant (y:ℝ) : ℝ := (y^4+8*y^2)*Real.exp (-y^2/8)

lemma cosineErrorMajorant_nonneg (y:ℝ) : 0≤cosineErrorMajorant y := by
  unfold cosineErrorMajorant
  positivity

lemma cosineErrorMajorant_integrable : Integrable cosineErrorMajorant := by
  have h4:=integrable_natPower_gaussian 4 (1/8) (by norm_num)
  have h2:=integrable_natPower_gaussian 2 (1/8) (by norm_num)
  convert! h4.add (h2.const_mul 8) using 1
  funext y
  change (y^4+8*y^2)*Real.exp (-y^2/8)=
    y^4*Real.exp (-(1/8:ℝ)*y^2)+8*(y^2*Real.exp (-(1/8:ℝ)*y^2))
  rw [show -y^2/8=-(1/8:ℝ)*y^2 by ring]
  ring

@[fun_prop] lemma measurable_truncatedCosinePower (n:ℕ) :
    Measurable (truncatedCosinePower n) := by
  unfold truncatedCosinePower
  apply Measurable.ite
  · exact measurableSet_le (show Measurable (fun x:ℝ=>|x|) by fun_prop) measurable_const
  · fun_prop
  · fun_prop

lemma scaled_cosine_error_integrable (n:ℕ) (hn:0<n) :
    Integrable (fun y:ℝ=>|truncatedCosinePower n (y/Real.sqrt n)-Real.exp (-y^2/2)|) := by
  apply (cosineErrorMajorant_integrable.div_const (n:ℝ)).mono'
  · fun_prop
  · filter_upwards [] with y
    rw [Real.norm_eq_abs,abs_abs]
    exact scaled_cosine_error n hn y

/-- Explicit O(1/n) L¹ error, uniform over every oscillatory bias multiplier
of absolute value at most one. -/
theorem scaled_cosine_L1_error (n:ℕ) (hn:0<n) :
    (∫y:ℝ,|truncatedCosinePower n (y/Real.sqrt n)-Real.exp (-y^2/2)|)≤
      (∫y:ℝ,cosineErrorMajorant y)/(n:ℝ) := by
  rw [←integral_div]
  exact integral_mono (scaled_cosine_error_integrable n hn)
    (cosineErrorMajorant_integrable.div_const _) (fun y=>scaled_cosine_error n hn y)

end NeuralGeneralization.OnlineLowerTanh
