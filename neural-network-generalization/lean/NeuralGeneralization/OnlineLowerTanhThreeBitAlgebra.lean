import NeuralGeneralization.OnlineLowerTanhOptimizer
import Mathlib.Analysis.SpecialFunctions.Artanh
import Mathlib.Analysis.MeanInequalities

/-! Exact algebra of the actual three-bit tanh parity coefficient. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1800000
open scoped BigOperators
open Set
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel

lemma tanh_add_formula (a b : ℝ) :
    Real.tanh (a+b)=(Real.tanh a+Real.tanh b)/(1+Real.tanh a*Real.tanh b) := by
  simp only [Real.tanh_eq_sinh_div_cosh,Real.sinh_add,Real.cosh_add]
  have ha:Real.cosh a≠0 := (Real.cosh_pos a).ne'
  have hb:Real.cosh b≠0 := (Real.cosh_pos b).ne'
  have hab:Real.cosh a*Real.cosh b+Real.sinh a*Real.sinh b≠0 := by
    rw [←Real.cosh_add]
    exact (Real.cosh_pos (a+b)).ne'
  field_simp

lemma tanh_triple_den_pos (a b c : ℝ) :
    0<1+Real.tanh a*Real.tanh b+Real.tanh a*Real.tanh c+Real.tanh b*Real.tanh c := by
  have he : 1+Real.tanh a*Real.tanh b+Real.tanh a*Real.tanh c+Real.tanh b*Real.tanh c =
      Real.cosh (a+b+c)/(Real.cosh a*Real.cosh b*Real.cosh c) := by
    simp only [Real.tanh_eq_sinh_div_cosh,Real.cosh_add,Real.sinh_add]
    field_simp
    <;> ring
  rw [he]
  positivity

lemma tanh_triple_formula (a b c : ℝ) :
    Real.tanh (a+b+c) =
      (Real.tanh a+Real.tanh b+Real.tanh c+Real.tanh a*Real.tanh b*Real.tanh c)/
      (1+Real.tanh a*Real.tanh b+Real.tanh a*Real.tanh c+Real.tanh b*Real.tanh c) := by
  simp only [Real.tanh_eq_sinh_div_cosh,Real.cosh_add,Real.sinh_add]
  field_simp
  <;> ring

lemma parityCorrelation_three (a b c : ℝ) :
    parityCorrelation ![a,b,c] 0 =
      (Real.tanh (a+b+c)-Real.tanh (a+b-c)-Real.tanh (a-b+c)+Real.tanh (a-b-c))/4 := by
  change parityCorrelation (Fin.cases a (Fin.cases b (Fin.cases c (fun i:Fin 0 => Fin.elim0 i)))) 0 = _
  simp only [parityCorrelation_prepend]
  simp [parityCorrelation,paritySign,incomingLinear,Cube,Finset.sum_empty,Real.tanh_neg]
  rw [show -a+b+c=-(a-b-c) by ring,show -a+b-c=-(a-b+c) by ring,
    show -a-b+c=-(a+b-c) by ring,show -a-b-c=-(a+b+c) by ring]
  simp only [Real.tanh_neg]
  ring

def threeBitDen (x y z : ℝ) : ℝ :=
  (1+x*y+x*z+y*z)*(1+x*y-x*z-y*z)*(1-x*y+x*z-y*z)*(1-x*y-x*z+y*z)

def threeBitQ (a : ℝ) : ℝ := 2*Real.tanh a^3/(1+3*Real.tanh a^2)

lemma threeBitDen_tanh_pos (a b c : ℝ) :
    0<threeBitDen (Real.tanh a) (Real.tanh b) (Real.tanh c) := by
  have h1:=tanh_triple_den_pos a b c
  have h2:=tanh_triple_den_pos a b (-c)
  have h3:=tanh_triple_den_pos a (-b) c
  have h4:=tanh_triple_den_pos (-a) b c
  simp only [Real.tanh_neg,mul_neg,neg_mul,sub_eq_add_neg] at h2 h3 h4 ⊢
  unfold threeBitDen
  simpa only [sub_eq_add_neg] using mul_pos (mul_pos (mul_pos h1 h2) h3) h4

lemma threeBitDen_identity (x y z : ℝ) :
    threeBitDen x y z-(1-x^2)*(1-y^2)*(1-z^2)*(1+x^2+y^2+z^2) =
      ((x^2-y^2)^2*(1-z^2)^2+(y^2-z^2)^2*(1-x^2)^2+(z^2-x^2)^2*(1-y^2)^2)/2 := by
  unfold threeBitDen
  ring

lemma parityCorrelation_three_rational (a b c : ℝ) :
    parityCorrelation ![a,b,c] 0 =
      -2*Real.tanh a*Real.tanh b*Real.tanh c*
        (1-Real.tanh a^2)*(1-Real.tanh b^2)*(1-Real.tanh c^2)/
          threeBitDen (Real.tanh a) (Real.tanh b) (Real.tanh c) := by
  have h1:1+Real.tanh a*Real.tanh b+Real.tanh a*Real.tanh c+Real.tanh b*Real.tanh c≠0 :=
    (tanh_triple_den_pos a b c).ne'
  have h2:1+Real.tanh a*Real.tanh b-Real.tanh a*Real.tanh c-Real.tanh b*Real.tanh c≠0 := by
    have h:=(tanh_triple_den_pos a b (-c)).ne'
    simpa only [Real.tanh_neg,mul_neg,sub_eq_add_neg] using h
  have h3:1-Real.tanh a*Real.tanh b+Real.tanh a*Real.tanh c-Real.tanh b*Real.tanh c≠0 := by
    have h:=(tanh_triple_den_pos a (-b) c).ne'
    simpa only [Real.tanh_neg,mul_neg,neg_mul,sub_eq_add_neg] using h
  have h4:1-Real.tanh a*Real.tanh b-Real.tanh a*Real.tanh c+Real.tanh b*Real.tanh c≠0 := by
    have h:=(tanh_triple_den_pos (-a) b c).ne'
    simpa only [Real.tanh_neg,mul_neg,neg_mul,sub_eq_add_neg] using h
  rw [parityCorrelation_three]
  rw [show a+b-c=a+b+(-c) by ring,show a-b+c=a+(-b)+c by ring,
    show a-b-c=a+(-b)+(-c) by ring]
  rw [tanh_triple_formula a b c,tanh_triple_formula a b (-c),
    tanh_triple_formula a (-b) c,tanh_triple_formula a (-b) (-c)]
  simp only [Real.tanh_neg,mul_neg,neg_mul,neg_neg]
  simp only [sub_eq_add_neg] at h1 h2 h3 h4
  have hP:threeBitDen (Real.tanh a) (Real.tanh b) (Real.tanh c)≠0 :=
    (threeBitDen_tanh_pos a b c).ne'
  field_simp [h1,h2,h3,h4,hP]
  unfold threeBitDen
  ring

lemma threeBitDen_lower (x y z : ℝ) :
    (1-x^2)*(1-y^2)*(1-z^2)*(1+x^2+y^2+z^2)≤threeBitDen x y z := by
  have h:=threeBitDen_identity x y z
  have h1:=mul_nonneg (sq_nonneg (x^2-y^2)) (sq_nonneg (1-z^2))
  have h2:=mul_nonneg (sq_nonneg (y^2-z^2)) (sq_nonneg (1-x^2))
  have h3:=mul_nonneg (sq_nonneg (z^2-x^2)) (sq_nonneg (1-y^2))
  linarith

lemma cubic_amgm_three {x y z : ℝ} (hx:0≤x) (hy:0≤y) (hz:0≤z) :
    27*x*y*z≤(x+y+z)^3 := by
  have h1:=mul_nonneg (show 0≤x+y+z by positivity) (sq_nonneg (x-y))
  have h2:=mul_nonneg (show 0≤x+y+z by positivity) (sq_nonneg (y-z))
  have h3:=mul_nonneg (show 0≤x+y+z by positivity) (sq_nonneg (z-x))
  have h4:=mul_nonneg hz (sq_nonneg (x-y))
  have h5:=mul_nonneg hx (sq_nonneg (y-z))
  have h6:=mul_nonneg hy (sq_nonneg (z-x))
  nlinarith only [h1,h2,h3,h4,h5,h6]

end NeuralGeneralization.OnlineLowerTanh
