import NeuralGeneralization.OnlineLowerTanhFiniteParityGain
import NeuralGeneralization.OnlineLowerTanhConditioningMixture

/-! Finite-degree signed bias curvature, valid at every gain at least one. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open Set
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel OnlineLowerRelu TanhDifferential

theorem signedRidge_hamming (r : ℕ) (h : ℝ → ℝ) :
    (-1:ℝ)^r * ridgeParity h (fun _:Fin (2*r+1)=>1) 0 = (-1 : ℝ)^r / 2^(2*r+1) *
      ∑ j ∈ Finset.range (2*r+2), (-1 : ℝ)^j * ((2*r+1).choose j : ℝ) *
        h ((2*r+1 : ℕ)-2*j) := by
  have he : ridgeParity h (fun _:Fin (2*r+1)=>1) 0 =
      (Fintype.card (Cube (2*r+1)):ℝ)⁻¹ * ∑ x:Cube (2*r+1),paritySign x*h (spinSum x) := by
    simp [ridgeParity,cubeMean,incomingLinear_constant]
  rw [he, ← Equiv.sum_comp (negativeSetEquiv (2*r+1)).symm]
  have hsign (S : Finset (Fin (2*r+1))) :
      paritySign ((negativeSetEquiv (2*r+1)).symm S) = (-1 : ℝ)^S.card := by
    exact negativeSet_full_parity (2*r+1) S
  have hsum (S : Finset (Fin (2*r+1))) :
      spinSum ((negativeSetEquiv (2*r+1)).symm S) = (2*r+1 : ℕ)-2*S.card := by
    exact negativeSet_sum_signs (2*r+1) S
  simp_rw [hsign, hsum]
  rw [subset_parity_sum_eq_alternatingBinomial (2*r+1)
    (fun j => h ((2*r+1 : ℕ)-2*j))]
  simp only [alternatingBinomial, Cube, Fintype.card_fun, Fintype.card_bool,
    Fintype.card_fin, Nat.cast_pow, Nat.cast_ofNat]
  rw [show 2*r+1+1=2*r+2 by omega]
  ring

/-- Central-binomial Hamming representation, with only positive arguments. -/
theorem signedRidge_centered (r : ℕ) (h:ℝ→ℝ) (hodd:∀x,h (-x) = -h x) :
    (-1:ℝ)^r * ridgeParity h (fun _:Fin (2*r+1)=>1) 0 = (1 : ℝ)/4^r *
      ∑ j ∈ Finset.range (r+1), (-1 : ℝ)^j * ((2*r+1).choose (r-j) : ℝ) *
        h (2*j+1) := by
  rw [signedRidge_hamming]
  have hh := odd_hamming_half r h hodd
  rw [hh, ← Finset.sum_range_reflect
    (fun j => (-1 : ℝ)^j * ((2*r+1).choose j : ℝ)*h ((2*r+1 : ℕ)-2*j)) (r+1)]
  have hscale : (-1 : ℝ)^r / 2^(2*r+1)*2 = (-1 : ℝ)^r / 4^r := by
    rw [pow_add, pow_mul]
    norm_num
    ring
  rw [← mul_assoc, hscale, div_mul_eq_mul_div, div_mul_eq_mul_div, one_mul]
  congr 1
  rw [Finset.mul_sum]
  have hterm (j : ℕ) (hj : j ∈ Finset.range (r+1)) :
      (-1 : ℝ)^r * ((-1 : ℝ)^(r+1-1-j)*((2*r+1).choose (r+1-1-j) : ℝ)*
        h ((2*r+1 : ℕ)-2*(r+1-1-j : ℕ))) =
      (-1 : ℝ)^j*((2*r+1).choose (r-j) : ℝ)*h (2*j+1) := by
    have hj' : j ≤ r := Nat.lt_succ_iff.mp (Finset.mem_range.mp hj)
    simp only [Nat.add_sub_cancel]
    have ha : ((2*r+1 : ℕ) : ℝ)-2*(r-j : ℕ) = 2*j+1 := by
      rw [Nat.cast_sub hj']
      push_cast
      ring
    rw [ha]
    rw [← mul_assoc, ← mul_assoc, neg_one_pow_center r j hj']
  exact Finset.sum_congr rfl hterm


def negativeTanhCurvature (t:ℝ) : ℝ := -tanhSecond t

lemma negativeTanhCurvature_pos {t:ℝ} (ht:1≤t) : 0<negativeTanhCurvature t := by
  have htanh:0<Real.tanh t:=lt_trans (by norm_num) (tanh_one_gt_three_quarters.trans_le (scalar_tanh_monotone ht))
  have hf:0<tanhFirst t:=sub_pos.mpr (Real.tanh_sq_lt_one t)
  unfold negativeTanhCurvature tanhSecond
  nlinarith [mul_pos htanh hf]

lemma hasDerivAt_negativeTanhCurvature (t:ℝ) :
    HasDerivAt negativeTanhCurvature (2*tanhFirst t*(1-3*Real.tanh t^2)) t := by
  have h:=((hasDerivAt_tanh_first t).mul (hasDerivAt_tanhFirst t)).const_mul 2
  convert h using 1 <;> (try rfl)
  · funext x;simp only [negativeTanhCurvature,tanhSecond,Pi.mul_apply];ring
  · simp only [tanhSecond,tanhFirst];ring

lemma negativeTanhCurvature_strictAnti : StrictAntiOn negativeTanhCurvature (Ici (1:ℝ)) := by
  apply strictAntiOn_of_deriv_neg (convex_Ici 1)
    (fun t _=>(hasDerivAt_negativeTanhCurvature t).continuousAt.continuousWithinAt)
  intro t ht
  have ht':1≤t:=(interior_subset ht)
  rw [(hasDerivAt_negativeTanhCurvature t).deriv]
  have htan:3/4<Real.tanh t:=tanh_one_gt_three_quarters.trans_le (scalar_tanh_monotone ht')
  have hf:0<tanhFirst t:=sub_pos.mpr (Real.tanh_sq_lt_one t)
  have hneg:1-3*Real.tanh t^2<0:=by nlinarith
  exact mul_neg_of_pos_of_neg (by positivity) hneg

/-- The paper's `D_n(a)` is the actual second external-bias derivative. -/
def balancedBiasCurvature (r:ℕ) (a:ℝ) : ℝ :=
  (-1:ℝ)^r * parityBiasSecond (fun _:Fin (2*r+1)=>a) 0

lemma balancedBiasCurvature_centered (r:ℕ) (a:ℝ) :
    balancedBiasCurvature r a= -(1:ℝ)/4^r *
      ∑j∈Finset.range (r+1),(-1:ℝ)^j*((2*r+1).choose (r-j):ℝ)*
        negativeTanhCurvature (a*(2*j+1)) := by
  have hodd:∀x:ℝ,tanhSecond (a*(-x)) = -tanhSecond (a*x):=by
    intro x
    simp [tanhSecond,tanhFirst,Real.tanh_neg,mul_neg]
  have hh:=signedRidge_centered r (fun x=>tanhSecond (a*x)) hodd
  have he:ridgeParity (fun x=>tanhSecond (a*x)) (fun _:Fin (2*r+1)=>1) 0=
      parityBiasSecond (fun _:Fin (2*r+1)=>a) 0:=by
    simp [ridgeParity,cubeMean,parityBiasSecond,incomingLinear_constant]
  rw [he] at hh
  unfold balancedBiasCurvature
  rw [hh]
  simp only [negativeTanhCurvature,mul_neg,Finset.sum_neg_distrib]
  ring

/-- Strict restoring bias curvature at every odd degree, with no asymptotic
threshold and no assumed curvature premise. -/
theorem balancedBiasCurvature_neg (r:ℕ) (a:ℝ) (ha:1≤a) : balancedBiasCurvature r a<0 := by
  let f:ℕ→ℝ:=fun j=>((2*r+1).choose (r-j):ℝ)*negativeTanhCurvature (a*(2*j+1))
  have harg (j:ℕ):1≤a*(2*j+1):=by have hj:0≤(j:ℝ):=Nat.cast_nonneg j;nlinarith
  have hc (j:ℕ):0<((2*r+1).choose (r-j):ℝ):=Nat.cast_pos.mpr (Nat.choose_pos (by omega))
  have hp (j:ℕ):0<negativeTanhCurvature (a*(2*j+1)):=negativeTanhCurvature_pos (harg j)
  have hdec (j:ℕ):negativeTanhCurvature (a*(2*(j+1:ℕ)+1))<negativeTanhCurvature (a*(2*j+1)):=by
    apply negativeTanhCurvature_strictAnti (harg j) (harg (j+1))
    push_cast
    nlinarith
  have hf (j:ℕ):0<f j:=mul_pos (hc j) (hp j)
  have hm (j:ℕ):f (j+1)≤f j:=mul_le_mul
    (by exact_mod_cast centered_choose_antitone r j) (hdec j).le (hp (j+1)).le (hc j).le
  have h01:f 1<f 0:=by
    have hchoose:((2*r+1).choose (r-1):ℝ)≤((2*r+1).choose (r-0):ℝ):=by
      exact_mod_cast centered_choose_antitone r 0
    calc
      f 1≤((2*r+1).choose (r-0):ℝ)*negativeTanhCurvature (a*(2*(1:ℕ)+1)):=
        mul_le_mul_of_nonneg_right hchoose (hp 1).le
      _<f 0:=by simpa [f] using mul_lt_mul_of_pos_left (hdec 0) (hc 0)
  have hsum:=alternating_strictly_positive (r+1) (by omega) f hf hm h01
  rw [balancedBiasCurvature_centered]
  apply mul_neg_of_neg_of_pos (div_neg_of_neg_of_pos (by norm_num) (by positivity))
  simpa only [f,mul_assoc] using hsum

end NeuralGeneralization.OnlineLowerTanh
