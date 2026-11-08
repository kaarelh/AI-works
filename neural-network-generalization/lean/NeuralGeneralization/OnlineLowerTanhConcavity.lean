import NeuralGeneralization.OnlineLowerTanhCurvature
import NeuralGeneralization.TanhSaturation

/-! Strict concavity of the actual balanced coefficient for gains at least one. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

theorem exp_neg_two_le_seventh (a : ℝ) (ha : 1 ≤ a) : Real.exp (-2*a) ≤ 1/7 := by
  have ht := Real.sum_le_exp_of_nonneg (by norm_num : (0 : ℝ) ≤ 2) 6
  norm_num [Finset.sum_range_succ] at ht
  have hm : Real.exp 2 ≤ Real.exp (2*a) := Real.exp_le_exp.mpr (by linarith)
  rw [show -2*a=-(2*a) by ring,Real.exp_neg]
  have hi := inv_anti₀ (by norm_num : (0 : ℝ) < 7) (show 7 ≤ Real.exp (2*a) by linarith)
  simpa only [one_div] using hi

theorem logisticCurvatureY_lower (j : ℕ) (y : ℝ) (hy : 0 ≤ y) (hy1 : y ≤ 1/7) :
    (147/256 : ℝ)*(2*(2*j+1))^2*logisticPower j y ≤ logisticCurvatureY j y := by
  have hp := logisticPower_nonneg j hy
  have hp1 : logisticPower j y ≤ 1/7 := by
    calc
      logisticPower j y = y*(y^2)^j := by unfold logisticPower; rw [pow_add,pow_mul]; ring
      _ ≤ y*1 := mul_le_mul_of_nonneg_left (pow_le_one₀ (by positivity) (by nlinarith) : (y^2)^j ≤ 1) hy
      _ ≤ _ := by simpa only [mul_one] using hy1
  have hd : (1+logisticPower j y)^3 ≤ (8/7 : ℝ)^3 :=
    pow_le_pow_left₀ (by positivity) (by linarith) 3
  have hb : 0 ≤ (2*(2*(j : ℝ)+1))^2 := sq_nonneg _
  unfold logisticCurvatureY
  apply (le_div_iff₀ (by positivity : 0 < (1+logisticPower j y)^3)).mpr
  have hden := mul_le_mul_of_nonneg_left hd ((mul_nonneg hb hp))
  have hnum := mul_le_mul_of_nonneg_left (show (6/7 : ℝ) ≤ 1-logisticPower j y by linarith) (mul_nonneg hb hp)
  nlinarith only [hden,hnum]

theorem logisticCurvatureY_pos (j : ℕ) (y : ℝ) (hy : 0 < y) (hy1 : y ≤ 1/7) :
    0 < logisticCurvatureY j y := by
  have h := logisticCurvatureY_lower j y hy.le hy1
  have hp : 0 < (147/256 : ℝ)*(2*(2*j+1))^2*logisticPower j y := by unfold logisticPower; positivity
  exact lt_of_lt_of_le hp h

theorem logisticCurvatureY_succ_lt (j : ℕ) (y : ℝ) (hy : 0 < y) (hy1 : y ≤ 1/7) :
    logisticCurvatureY (j+1) y < logisticCurvatureY j y := by
  have hj : (0 : ℝ) ≤ j := Nat.cast_nonneg j
  have hp : 0 < logisticPower j y := by unfold logisticPower; positivity
  have hnext := logisticCurvatureY_abs_le (j+1) hy.le (by linarith)
  have hlow := logisticCurvatureY_lower j y hy.le hy1
  have hc : (2*(2*(j+1 : ℕ)+1 : ℝ))^2 ≤ 9*(2*(2*j+1 : ℝ))^2 := by push_cast; nlinarith
  have hpow : logisticPower (j+1) y = logisticPower j y*y^2 := by
    unfold logisticPower
    rw [show 2*(j+1)+1=(2*j+1)+2 by omega,pow_add]
  have hy2 : y^2 ≤ (1/49 : ℝ) := by nlinarith
  have hupper : logisticCurvatureY (j+1) y ≤ (9/49 : ℝ)*(2*(2*j+1))^2*logisticPower j y := by
    calc
      logisticCurvatureY (j+1) y ≤ (2*(2*(j+1 : ℕ)+1 : ℝ))^2*logisticPower (j+1) y :=
        (le_abs_self _).trans hnext
      _ = (2*(2*(j+1 : ℕ)+1 : ℝ))^2*(logisticPower j y*y^2) := by rw [hpow]
      _ ≤ (9*(2*(2*j+1 : ℝ))^2)*(logisticPower j y*(1/49)) :=
        mul_le_mul hc (mul_le_mul_of_nonneg_left hy2 hp.le) (by positivity) (by positivity)
      _ = _ := by ring
  have hscale : 0 < (2*(2*(j : ℝ)+1))^2*logisticPower j y := by positivity
  nlinarith only [hupper,hlow,hscale]

theorem logisticSecond_pos (j : ℕ) (a : ℝ) (ha : 1 ≤ a) : 0 < logisticSecond j a :=
  logisticCurvatureY_pos j _ (Real.exp_pos _) (exp_neg_two_le_seventh a ha)

theorem logisticSecond_succ_lt (j : ℕ) (a : ℝ) (ha : 1 ≤ a) :
    logisticSecond (j+1) a < logisticSecond j a :=
  logisticCurvatureY_succ_lt j _ (Real.exp_pos _) (exp_neg_two_le_seventh a ha)

theorem tanh_eq_one_sub_two_logistic (j : ℕ) (a : ℝ) :
    Real.tanh (a*(2*j+1)) = 1-2*logisticTail j a := by
  rw [TanhSaturation.tanh_exp_formula,logisticTail_eq_inverse]
  rw [show 2*(a*(2*(j : ℝ)+1))=2*a*(2*j+1) by ring,add_comm (Real.exp _)]
  ring

theorem balancedParity_logistic (r : ℕ) (a : ℝ) :
    balancedParity r a = oddParityKappa r - (2 : ℝ)/4^r*
      ∑ j ∈ Finset.range (r+1), (-1 : ℝ)^j*((2*r+1).choose (r-j) : ℝ)*logisticTail j a := by
  rw [balancedParity_centered]
  simp_rw [tanh_eq_one_sub_two_logistic,mul_sub,mul_one]
  rw [Finset.sum_sub_distrib]
  have he : (∑ j ∈ Finset.range (r+1), (-1 : ℝ)^j*((2*r+1).choose (r-j) : ℝ)*(2*logisticTail j a)) =
      2*∑ j ∈ Finset.range (r+1), (-1 : ℝ)^j*((2*r+1).choose (r-j) : ℝ)*logisticTail j a := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j hj
    ring
  rw [he,centered_choose_alternating]
  unfold oddParityKappa
  ring


def balancedTailFirst (r : ℕ) (a : ℝ) : ℝ := -(2 : ℝ)/4^r*
  ∑ j ∈ Finset.range (r+1), (-1 : ℝ)^j*((2*r+1).choose (r-j) : ℝ)*logisticFirst j a

def balancedTailSecond (r : ℕ) (a : ℝ) : ℝ := -(2 : ℝ)/4^r*
  ∑ j ∈ Finset.range (r+1), (-1 : ℝ)^j*((2*r+1).choose (r-j) : ℝ)*logisticSecond j a

theorem hasDerivAt_balancedParity_tail (r : ℕ) (a : ℝ) :
    HasDerivAt (balancedParity r) (balancedTailFirst r a) a := by
  have h := ((HasDerivAt.sum (u := Finset.range (r+1)) (fun j hj =>
    (hasDerivAt_logisticTail j a).const_mul ((-1 : ℝ)^j*((2*r+1).choose (r-j) : ℝ)))).const_mul
      ((2 : ℝ)/4^r)).const_sub (oddParityKappa r)
  convert h using 1 <;> try rfl
  · funext x
    simpa only [Finset.sum_apply] using balancedParity_logistic r x
  · unfold balancedTailFirst
    ring

theorem balancedParityFirst_eq_tail (r : ℕ) (a : ℝ) :
    balancedParityFirst r a=balancedTailFirst r a :=
  (hasDerivAt_balancedParity r a).unique (hasDerivAt_balancedParity_tail r a)

theorem hasDerivAt_balancedTailFirst (r : ℕ) (a : ℝ) :
    HasDerivAt (balancedTailFirst r) (balancedTailSecond r a) a := by
  have h := (HasDerivAt.sum (u := Finset.range (r+1)) (fun j hj =>
    (hasDerivAt_logisticFirst j a).const_mul ((-1 : ℝ)^j*((2*r+1).choose (r-j) : ℝ)))).const_mul
      (-(2 : ℝ)/4^r)
  convert h using 1 <;> try rfl
  funext x
  simp only [balancedTailFirst,Finset.sum_apply]

theorem balancedParitySecond_eq_tail (r : ℕ) (a : ℝ) :
    balancedParitySecond r a=balancedTailSecond r a := by
  have h := hasDerivAt_balancedParityFirst r a
  have he : balancedParityFirst r=balancedTailFirst r := funext (balancedParityFirst_eq_tail r)
  rw [he] at h
  exact h.unique (hasDerivAt_balancedTailFirst r a)

theorem alternating_strictly_positive (N : ℕ) (hN : 0 < N) (f : ℕ → ℝ)
    (hf : ∀ j, 0 < f j) (hm : ∀ j, f (j+1) ≤ f j) (h01 : f 1 < f 0) :
    0 < ∑ j ∈ Finset.range N, (-1 : ℝ)^j*f j := by
  cases N with
  | zero => omega
  | succ N =>
      cases N with
      | zero => simpa using hf 0
      | succ N =>
          have ht := (alternating_nonnegative_antitone N (fun j => f (j+2))
            (fun j => (hf (j+2)).le) (fun j => hm (j+2))).1
          rw [show N+1+1=2+N by omega,Finset.sum_range_add]
          norm_num [Finset.sum_range_succ,pow_add,pow_two]
          convert (add_pos_of_pos_of_nonneg (sub_pos.mpr h01) ht) using 1 <;> try rfl
          simp only [Nat.add_comm,sub_eq_add_neg]

theorem balancedParitySecond_neg (r : ℕ) (a : ℝ) (ha : 1 ≤ a) :
    balancedParitySecond r a < 0 := by
  let f : ℕ → ℝ := fun j => ((2*r+1).choose (r-j) : ℝ)*logisticSecond j a
  have hc (j : ℕ) : 0 < ((2*r+1).choose (r-j) : ℝ) := by
    exact Nat.cast_pos.mpr (Nat.choose_pos (by omega))
  have hf (j : ℕ) : 0 < f j := mul_pos (hc j) (logisticSecond_pos j a ha)
  have hm (j : ℕ) : f (j+1) ≤ f j := by
    exact mul_le_mul (by exact_mod_cast centered_choose_antitone r j)
      (logisticSecond_succ_lt j a ha).le (logisticSecond_pos (j+1) a ha).le (hc j).le
  have h01 : f 1 < f 0 := by
    calc
      f 1 ≤ ((2*r+1).choose (r-0) : ℝ)*logisticSecond 1 a :=
        mul_le_mul_of_nonneg_right (by exact_mod_cast centered_choose_antitone r 0) (logisticSecond_pos 1 a ha).le
      _ < f 0 := mul_lt_mul_of_pos_left (logisticSecond_succ_lt 0 a ha) (hc 0)
  have hsum := alternating_strictly_positive (r+1) (by omega) f hf hm h01
  rw [balancedParitySecond_eq_tail]
  unfold balancedTailSecond
  apply mul_neg_of_neg_of_pos (div_neg_of_neg_of_pos (by norm_num) (by positivity))
  simpa only [f,mul_assoc] using hsum

end NeuralGeneralization.OnlineLowerTanh
