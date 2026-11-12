import NeuralGeneralization.BatchTwoMergingGeluPerspective
import NeuralGeneralization.TanhScalarJet
import NeuralGeneralization.BatchTwoNonGaussianSmallBallKernel

/-! Exact scale-normalized tanh coordinates for the remaining online merging supports. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoOnlineTanhMerging
open ConcreteModel TanhDifferential

def tanhPerspective (a u : ℝ) : ℝ := a*Real.tanh (u/a)

@[simp] theorem tanhPerspective_zero_scale (u : ℝ) : tanhPerspective 0 u=0 := by simp [tanhPerspective]
@[simp] theorem tanhPerspective_zero (a : ℝ) : tanhPerspective a 0=0 := by simp [tanhPerspective]

theorem tanhPerspective_abs_le_scale {a : ℝ} (ha : 0≤a) (u : ℝ) : |tanhPerspective a u|≤a := by
  rw [tanhPerspective,abs_mul,abs_of_nonneg ha]
  exact mul_le_of_le_one_right ha (Real.abs_tanh_lt_one _).le

theorem tanhPerspective_abs_le {a : ℝ} (ha : 0≤a) (u : ℝ) : |tanhPerspective a u|≤|u| := by
  by_cases h : a=0
  · simp [h]
  have hap : 0<a := lt_of_le_of_ne ha (Ne.symm h)
  have hh := mul_le_mul_of_nonneg_left (BatchTwoNonGaussian.abs_tanh_le_abs (u/a)) ha
  rw [abs_div,abs_of_pos hap] at hh
  rw [tanhPerspective,abs_mul,abs_of_nonneg ha]
  exact hh.trans_eq (by field_simp)

theorem tanhPerspective_input_lipschitz {a : ℝ} (ha : 0≤a) (u v : ℝ) :
    |tanhPerspective a u-tanhPerspective a v|≤|u-v| := by
  by_cases h : a=0
  · simp [h]
  have hap : 0<a := lt_of_le_of_ne ha (Ne.symm h)
  have hh := mul_le_mul_of_nonneg_left (tanh_admissible.2 (u/a) (v/a)) ha
  rw [←sub_div,abs_div,abs_of_pos hap] at hh
  rw [tanhPerspective,tanhPerspective,←mul_sub,abs_mul,abs_of_nonneg ha]
  exact hh.trans_eq (by field_simp)

def tanhScaleDerivative (y : ℝ) : ℝ := Real.tanh y-y*tanhFirst y

theorem hasDerivAt_tanhScaleDerivative (y : ℝ) :
    HasDerivAt tanhScaleDerivative (2*y*Real.tanh y*tanhFirst y) y := by
  convert! (hasDerivAt_tanh_first y).sub ((hasDerivAt_id y).mul (hasDerivAt_tanhFirst y)) using 1 <;>
    simp [tanhScaleDerivative,tanhSecond] <;> ring

theorem tanhScaleDerivative_nonneg {y : ℝ} (hy : 0≤y) : 0≤tanhScaleDerivative y := by
  have hm : MonotoneOn tanhScaleDerivative (Ici 0) := monotoneOn_of_deriv_nonneg (convex_Ici 0)
    (fun t _=>(hasDerivAt_tanhScaleDerivative t).continuousAt.continuousWithinAt)
    (fun t _=>(hasDerivAt_tanhScaleDerivative t).differentiableAt.differentiableWithinAt)
    (fun t ht=>by
      rw [(hasDerivAt_tanhScaleDerivative t).deriv]
      have ht0 : 0≤t := interior_subset ht
      have htt : 0≤Real.tanh t := by simpa only [Real.tanh_zero] using BatchTwoNonGaussian.tanh_monotone ht0
      exact mul_nonneg (mul_nonneg (mul_nonneg (by norm_num) ht0) htt) (tanhFirst_nonneg t))
  have hh := hm (show (0:ℝ)∈Ici 0 by simp) hy hy
  simpa only [tanhScaleDerivative,Real.tanh_zero,zero_mul,sub_zero] using hh

theorem tanhScaleDerivative_abs_le (y : ℝ) : |tanhScaleDerivative y|≤1 := by
  have hb (t : ℝ) (ht : 0≤t) : |tanhScaleDerivative t|≤1 := by
    rw [abs_of_nonneg (tanhScaleDerivative_nonneg ht)]
    unfold tanhScaleDerivative
    have hm := mul_nonneg ht (tanhFirst_nonneg t)
    have hh := (le_abs_self (Real.tanh t)).trans (Real.abs_tanh_lt_one t).le
    linarith
  rcases le_total 0 y with h | h
  · exact hb y h
  · have hh := hb (-y) (neg_nonneg.mpr h)
    have he : tanhScaleDerivative (-y)= -tanhScaleDerivative y := by
      simp only [tanhScaleDerivative,tanhFirst,Real.tanh_neg,neg_sq]
      ring
    simpa only [he,abs_neg] using hh

theorem hasDerivAt_tanhPerspective_scale {a : ℝ} (ha : a≠0) (u : ℝ) :
    HasDerivAt (fun b=>tanhPerspective b u) (tanhScaleDerivative (u/a)) a := by
  have hi : HasDerivAt (fun b:ℝ=>u/b) (-u/a^2) a := by
    convert (hasDerivAt_const a u).div (hasDerivAt_id' a) ha using 1 <;> first | rfl | simp
  have hh := (hasDerivAt_id' a).mul ((hasDerivAt_tanh_first (u/a)).comp a hi)
  convert hh using 1 <;> try rfl
  simp only [tanhScaleDerivative,Function.comp_apply]
  field_simp
  <;> ring

theorem tanhPerspective_scale_lipschitz_pos {a b : ℝ} (ha : 0<a) (hb : 0<b) (u : ℝ) :
    |tanhPerspective a u-tanhPerspective b u|≤|a-b| := by
  have hd (t : ℝ) (ht : t∈Ioi (0:ℝ)) : DifferentiableAt ℝ (fun t=>tanhPerspective t u) t :=
    (hasDerivAt_tanhPerspective_scale ht.ne' u).differentiableAt
  have hbound (t : ℝ) (ht : t∈Ioi (0:ℝ)) : ‖deriv (fun t=>tanhPerspective t u) t‖≤(1:ℝ) := by
    rw [(hasDerivAt_tanhPerspective_scale ht.ne' u).deriv,Real.norm_eq_abs]
    exact tanhScaleDerivative_abs_le _
  have hh := (convex_Ioi (0:ℝ)).norm_image_sub_le_of_norm_deriv_le hd hbound hb ha
  simpa only [Real.norm_eq_abs,one_mul] using hh

/-- Includes the zero-mass limit, so vanishing normalized populations need
no separate limiting assumption in the finite cover. -/
theorem tanhPerspective_scale_lipschitz {a b : ℝ} (ha : 0≤a) (hb : 0≤b) (u : ℝ) :
    |tanhPerspective a u-tanhPerspective b u|≤|a-b| := by
  by_cases ha0 : a=0
  · subst a
    simpa only [tanhPerspective_zero_scale,zero_sub,abs_neg,abs_of_nonneg hb] using tanhPerspective_abs_le_scale hb u
  by_cases hb0 : b=0
  · subst b
    simpa only [tanhPerspective_zero_scale,sub_zero,abs_of_nonneg ha] using tanhPerspective_abs_le_scale ha u
  exact tanhPerspective_scale_lipschitz_pos (lt_of_le_of_ne ha (Ne.symm ha0)) (lt_of_le_of_ne hb (Ne.symm hb0)) u

theorem tanhPerspective_joint_lipschitz {a b : ℝ} (ha : 0≤a) (hb : 0≤b) (u v : ℝ) :
    |tanhPerspective a u-tanhPerspective b v|≤|u-v|+|a-b| := by
  have ht := abs_sub_le (tanhPerspective a u) (tanhPerspective a v) (tanhPerspective b v)
  linarith [tanhPerspective_input_lipschitz ha u v,tanhPerspective_scale_lipschitz ha hb v]

theorem tanhPerspective_joint_lipschitz_two {a b : ℝ} (ha : 0<a) (hb : 0<b) (u v : ℝ) :
    |tanhPerspective a u-tanhPerspective b v|≤2*|u-v|+|a-b| := by
  have hh := tanhPerspective_joint_lipschitz ha.le hb.le u v
  linarith [abs_nonneg (u-v)]

end NeuralGeneralization.BatchTwoOnlineTanhMerging
