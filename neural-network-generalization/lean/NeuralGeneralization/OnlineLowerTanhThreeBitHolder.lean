import NeuralGeneralization.OnlineLowerTanhThreeBitAlgebra

/-! A cubed Holder bound for the actual three-bit correlation. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open scoped BigOperators
open Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma three_tanh_nonneg {a:ℝ} (ha:0≤a) : 0≤Real.tanh a := by
  simpa only [Real.tanh_zero] using tanh_monotone ha

lemma three_tanh_pos {a:ℝ} (ha:0<a) : 0<Real.tanh a := by
  have hm:StrictMono Real.tanh := strictMono_of_hasDerivAt_pos
    ConcreteModel.hasDerivAt_tanh (fun x=>by positivity)
  simpa only [Real.tanh_zero] using hm ha

lemma threeBitQ_nonneg {a:ℝ} (ha:0≤a) : 0≤threeBitQ a := by
  have ht:=three_tanh_nonneg ha
  unfold threeBitQ
  positivity

lemma threeBitQ_pos {a:ℝ} (ha:0<a) : 0<threeBitQ a := by
  have ht:=three_tanh_pos ha
  unfold threeBitQ
  positivity

lemma parityCorrelation_three_balanced (a:ℝ) :
    parityCorrelation ![a,a,a] 0 = -threeBitQ a := by
  rw [parityCorrelation_three]
  rw [show a+a-a=a by ring,show a-a+a=a by ring,show a-a-a = -a by ring,
    Real.tanh_neg,tanh_triple_formula a a a]
  unfold threeBitQ
  have hd:1+3*Real.tanh a^2≠0 := by positivity
  have hd':1+Real.tanh a*Real.tanh a+Real.tanh a*Real.tanh a+Real.tanh a*Real.tanh a≠0 := by nlinarith [sq_nonneg (Real.tanh a)]
  field_simp
  <;> ring

lemma threeBit_holder_cube (a b c:ℝ) (ha:0≤a) (hb:0≤b) (hc:0≤c) :
    |parityCorrelation ![a,b,c] 0|^3≤threeBitQ a*threeBitQ b*threeBitQ c := by
  let x:=Real.tanh a
  let y:=Real.tanh b
  let z:=Real.tanh c
  have hx:0≤x:=three_tanh_nonneg ha
  have hy:0≤y:=three_tanh_nonneg hb
  have hz:0≤z:=three_tanh_nonneg hc
  have hx1:0<1-x^2:=sub_pos.mpr (Real.tanh_sq_lt_one a)
  have hy1:0<1-y^2:=sub_pos.mpr (Real.tanh_sq_lt_one b)
  have hz1:0<1-z^2:=sub_pos.mpr (Real.tanh_sq_lt_one c)
  have hP:0<threeBitDen x y z:=threeBitDen_tanh_pos a b c
  have hD:0<1+x^2+y^2+z^2:=by positivity
  have he:|parityCorrelation ![a,b,c] 0|=
      2*x*y*z*(1-x^2)*(1-y^2)*(1-z^2)/threeBitDen x y z := by
    rw [parityCorrelation_three_rational]
    change |(-2*x*y*z*(1-x^2)*(1-y^2)*(1-z^2))/threeBitDen x y z|=_
    have hn:0≤2*x*y*z*(1-x^2)*(1-y^2)*(1-z^2):=by positivity
    rw [abs_of_nonpos (by apply div_nonpos_of_nonpos_of_nonneg <;> nlinarith)]
    ring
  have hfirst:|parityCorrelation ![a,b,c] 0|≤2*x*y*z/(1+x^2+y^2+z^2) := by
    rw [he]
    apply (div_le_div_iff₀ hP hD).mpr
    have hh:=mul_le_mul_of_nonneg_left (threeBitDen_lower x y z)
      (show 0≤2*x*y*z by positivity)
    nlinarith only [hh]
  have hden:(1+3*x^2)*(1+3*y^2)*(1+3*z^2)≤(1+x^2+y^2+z^2)^3 := by
    have hh:=cubic_amgm_three (show 0≤1+3*x^2 by positivity)
      (show 0≤1+3*y^2 by positivity) (show 0≤1+3*z^2 by positivity)
    nlinarith only [hh]
  have hrewrite:threeBitQ a*threeBitQ b*threeBitQ c=
      (2*x*y*z)^3/((1+3*x^2)*(1+3*y^2)*(1+3*z^2)) := by
    dsimp [threeBitQ,x,y,z]
    field_simp
    <;> ring
  calc
    |parityCorrelation ![a,b,c] 0|^3≤(2*x*y*z/(1+x^2+y^2+z^2))^3 :=
      pow_le_pow_left₀ (abs_nonneg _) hfirst 3
    _ = (2*x*y*z)^3/(1+x^2+y^2+z^2)^3 := div_pow _ _ _
    _ ≤ (2*x*y*z)^3/((1+3*x^2)*(1+3*y^2)*(1+3*z^2)) :=
      div_le_div_of_nonneg_left (by positivity) (by positivity) hden
    _ = threeBitQ a*threeBitQ b*threeBitQ c := hrewrite.symm

/-- Any scalar balanced-gain bound controls all three incoming weights. -/
lemma threeBit_of_scalar_bound (M a b c:ℝ) (hM:0≤M)
    (ha:0≤a) (hb:0≤b) (hc:0≤c)
    (hqa:threeBitQ a≤M*a) (hqb:threeBitQ b≤M*b) (hqc:threeBitQ c≤M*c) :
    |parityCorrelation ![a,b,c] 0|≤M*(a+b+c)/3 := by
  have h1:=threeBit_holder_cube a b c ha hb hc
  have h2:threeBitQ a*threeBitQ b*threeBitQ c≤M^3*(a*b*c) := by
    calc
      _ ≤ (M*a)*(M*b)*(M*c) := mul_le_mul
        (mul_le_mul hqa hqb (threeBitQ_nonneg hb) (mul_nonneg hM ha)) hqc
        (threeBitQ_nonneg hc) (by positivity)
      _ = _ := by ring
  have h3:=mul_le_mul_of_nonneg_left (cubic_amgm_three ha hb hc) (pow_nonneg hM 3)
  apply le_of_pow_le_pow_left₀ (by norm_num : (3:ℕ)≠0) (by positivity)
  nlinarith only [h1,h2,h3]

end NeuralGeneralization.OnlineLowerTanh
