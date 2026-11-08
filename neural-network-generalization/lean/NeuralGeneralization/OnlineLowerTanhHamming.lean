import NeuralGeneralization.OnlineLowerTanhScalar
import NeuralGeneralization.OnlineLowerReluBalancedWalsh
import Mathlib.Algebra.BigOperators.Intervals
import Mathlib.Analysis.Calculus.MeanValue

/-! Exact Hamming-level formulas for the actual balanced tanh coefficient. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel OnlineLowerRelu

theorem balancedParity_hamming (r : ℕ) (a : ℝ) :
    balancedParity r a = (-1 : ℝ)^r / 2^(2*r+1) *
      ∑ j ∈ Finset.range (2*r+2), (-1 : ℝ)^j * ((2*r+1).choose j : ℝ) *
        Real.tanh (a*((2*r+1 : ℕ)-2*j)) := by
  rw [balancedParity_sum, ← Equiv.sum_comp (negativeSetEquiv (2*r+1)).symm]
  have hsign (S : Finset (Fin (2*r+1))) :
      paritySign ((negativeSetEquiv (2*r+1)).symm S) = (-1 : ℝ)^S.card := by
    exact negativeSet_full_parity (2*r+1) S
  have hsum (S : Finset (Fin (2*r+1))) :
      spinSum ((negativeSetEquiv (2*r+1)).symm S) = (2*r+1 : ℕ)-2*S.card := by
    exact negativeSet_sum_signs (2*r+1) S
  simp_rw [hsign, hsum]
  rw [subset_parity_sum_eq_alternatingBinomial (2*r+1)
    (fun j => Real.tanh (a*((2*r+1 : ℕ)-2*j)))]
  simp only [alternatingBinomial, Cube, Fintype.card_fun, Fintype.card_bool,
    Fintype.card_fin, Nat.cast_pow, Nat.cast_ofNat]
  rw [show 2*r+1+1=2*r+2 by omega]
  ring

theorem neg_one_pow_center (r j : ℕ) (hj : j ≤ r) :
    (-1 : ℝ)^r * (-1 : ℝ)^(r-j) = (-1 : ℝ)^j := by
  have he : r = (r-j)+j := by omega
  calc
    (-1 : ℝ)^r * (-1 : ℝ)^(r-j) =
      ((-1 : ℝ)^(r-j) * (-1 : ℝ)^(r-j)) * (-1 : ℝ)^j := by
        nth_rw 1 [he]
        rw [pow_add]
        ring
    _ = (-1 : ℝ)^j := by rw [← pow_add, ← two_mul, pow_mul]; norm_num

/-- Reflection of an odd Hamming grid duplicates its positive half. -/
theorem odd_hamming_half (r : ℕ) (h : ℝ → ℝ) (hodd : ∀ x, h (-x) = -h x) :
    (∑ j ∈ Finset.range (2*r+2), (-1 : ℝ)^j * ((2*r+1).choose j : ℝ) *
        h ((2*r+1 : ℕ)-2*j)) =
      2 * ∑ j ∈ Finset.range (r+1), (-1 : ℝ)^j * ((2*r+1).choose j : ℝ) *
        h ((2*r+1 : ℕ)-2*j) := by
  let f : ℕ → ℝ := fun j => (-1 : ℝ)^j*((2*r+1).choose j : ℝ)*h ((2*r+1 : ℕ)-2*j)
  change (∑ j ∈ Finset.range (2*r+2), f j) = 2*∑ j ∈ Finset.range (r+1), f j
  have hsym (j : ℕ) (hj : j ≤ 2*r+1) : f (2*r+1-j) = f j := by
    have hs : (-1 : ℝ)^(2*r+1-j) = -(-1 : ℝ)^j := by
      have hh := neg_one_pow_center (2*r+1) j hj
      have ho : (-1 : ℝ)^(2*r+1) = -1 := by rw [pow_add, pow_mul]; norm_num
      rw [ho] at hh
      linarith
    have hc := Nat.choose_symm hj
    have ha : ((2*r+1 : ℕ) : ℝ)-2*(2*r+1-j : ℕ) = -(((2*r+1 : ℕ) : ℝ)-2*j) := by
      rw [Nat.cast_sub hj]
      ring
    simp only [f, hs, hc, ha, hodd]
    ring
  rw [show 2*r+2=(r+1)+(r+1) by omega, Finset.sum_range_add]
  have htail : (∑ j ∈ Finset.range (r+1), f (r+1+j)) =
      ∑ j ∈ Finset.range (r+1), f j := by
    rw [← Finset.sum_range_reflect (fun j => f (r+1+j)) (r+1)]
    apply Finset.sum_congr rfl
    intro j hj
    have hj' := Finset.mem_range.mp hj
    rw [show r+1+(r+1-1-j)=2*r+1-j by omega]
    exact hsym j (by omega)
  rw [htail]
  ring

/-- Central-binomial Hamming representation, with only positive arguments. -/
theorem balancedParity_centered (r : ℕ) (a : ℝ) :
    balancedParity r a = (1 : ℝ)/4^r *
      ∑ j ∈ Finset.range (r+1), (-1 : ℝ)^j * ((2*r+1).choose (r-j) : ℝ) *
        Real.tanh (a*(2*j+1)) := by
  rw [balancedParity_hamming]
  have hh := odd_hamming_half r (fun x => Real.tanh (a*x))
    (fun x => by rw [mul_neg, Real.tanh_neg])
  rw [hh, ← Finset.sum_range_reflect
    (fun j => (-1 : ℝ)^j * ((2*r+1).choose j : ℝ)*Real.tanh (a*((2*r+1 : ℕ)-2*j))) (r+1)]
  have hscale : (-1 : ℝ)^r / 2^(2*r+1)*2 = (-1 : ℝ)^r / 4^r := by
    rw [pow_add, pow_mul]
    norm_num
    ring
  rw [← mul_assoc, hscale, div_mul_eq_mul_div, div_mul_eq_mul_div, one_mul]
  congr 1
  rw [Finset.mul_sum]
  have hterm (j : ℕ) (hj : j ∈ Finset.range (r+1)) :
      (-1 : ℝ)^r * ((-1 : ℝ)^(r+1-1-j)*((2*r+1).choose (r+1-1-j) : ℝ)*
        Real.tanh (a*((2*r+1 : ℕ)-2*(r+1-1-j : ℕ)))) =
      (-1 : ℝ)^j*((2*r+1).choose (r-j) : ℝ)*Real.tanh (a*(2*j+1)) := by
    have hj' : j ≤ r := Nat.lt_succ_iff.mp (Finset.mem_range.mp hj)
    simp only [Nat.add_sub_cancel]
    have ha : ((2*r+1 : ℕ) : ℝ)-2*(r-j : ℕ) = 2*j+1 := by
      rw [Nat.cast_sub hj']
      push_cast
      ring
    rw [ha]
    rw [← mul_assoc, ← mul_assoc, neg_one_pow_center r j hj']
  exact Finset.sum_congr rfl hterm

/-- Elementary alternating-sum bound, avoiding an infinite-series theorem. -/
theorem alternating_nonnegative_antitone (N : ℕ) (f : ℕ → ℝ)
    (hf : ∀ j, 0 ≤ f j) (hm : ∀ j, f (j+1) ≤ f j) :
    0 ≤ (∑ j ∈ Finset.range N, (-1 : ℝ)^j*f j) ∧
      (∑ j ∈ Finset.range N, (-1 : ℝ)^j*f j) ≤ f 0 := by
  induction N generalizing f with
  | zero => simp [hf 0]
  | succ N ih =>
      have hi := ih (fun j => f (j+1)) (fun j => hf (j+1)) (fun j => hm (j+1))
      rw [Finset.sum_range_succ']
      simp only [pow_succ, mul_neg_one, neg_mul, Finset.sum_neg_distrib, pow_zero, one_mul]
      constructor <;> linarith [hm 0]


theorem centered_choose_alternating (r : ℕ) :
    (∑ j ∈ Finset.range (r+1), (-1 : ℝ)^j*((2*r+1).choose (r-j) : ℝ)) =
      (Nat.centralBinom r : ℝ) := by
  have he : (∑ j ∈ Finset.range (r+1), (-1 : ℝ)^j*((2*r+1).choose (r-j) : ℝ)) =
      (-1 : ℝ)^r * ∑ j ∈ Finset.range (r+1), (-1 : ℝ)^(r-j)*((2*r+1).choose (r-j) : ℝ) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j hj
    rw [← mul_assoc, neg_one_pow_center r j (Nat.lt_succ_iff.mp (Finset.mem_range.mp hj))]
  rw [he]
  have href := Finset.sum_range_reflect
    (fun j => (-1 : ℝ)^j*((2*r+1).choose j : ℝ)) (r+1)
  simp only [Nat.add_sub_cancel] at href
  rw [href, alternating_binomial_prefix]
  unfold Nat.centralBinom
  have hp : (-1 : ℝ)^r * (-1 : ℝ)^r = 1 := by rw [← pow_add, ← two_mul, pow_mul]; norm_num
  rw [← mul_assoc, hp, one_mul]

theorem centered_choose_antitone (r j : ℕ) :
    (2*r+1).choose (r-(j+1)) ≤ (2*r+1).choose (r-j) := by
  by_cases hj : j < r
  · have ht : r-(j+1) < (2*r+1)/2 := by omega
    have h := Nat.choose_le_succ_of_lt_half_left ht
    rwa [show r-(j+1)+1=r-j by omega] at h
  · have hj' : r ≤ j := by omega
    simp [Nat.sub_eq_zero_of_le hj', Nat.sub_eq_zero_of_le (show r ≤ j+1 by omega)]

theorem centered_choose_le_twice (r : ℕ) :
    ((2*r+1).choose r : ℝ) ≤ 2*(Nat.centralBinom r : ℝ) := by
  cases r with
  | zero => norm_num [Nat.centralBinom]
  | succ r =>
      rw [show 2*(r+1)+1=(2*(r+1))+1 by omega, Nat.choose_succ_succ]
      have h := Nat.choose_le_middle r (2*(r+1))
      have hc : (2*(r+1))/2 = r+1 := by omega
      rw [hc] at h
      unfold Nat.centralBinom
      exact_mod_cast (show (2*(r+1)).choose r + (2*(r+1)).choose (r+1) ≤
        2*(2*(r+1)).choose (r+1) by omega)

theorem scalar_tanh_monotone : Monotone Real.tanh := by
  apply monotone_of_deriv_nonneg (fun x => (TanhDifferential.hasDerivAt_tanh_first x).differentiableAt)
  intro x
  rw [(TanhDifferential.hasDerivAt_tanh_first x).deriv]
  exact sub_nonneg.mpr (Real.tanh_sq_lt_one x).le

/-- A uniform elementary lower bound, derived from the actual finite coefficient. -/
theorem balancedParity_lower (r : ℕ) (a : ℝ) (ha : 0 ≤ a) :
    oddParityKappa r * (2*Real.tanh a-1) ≤ balancedParity r a := by
  let f : ℕ → ℝ := fun j => ((2*r+1).choose (r-j) : ℝ)*(1-Real.tanh (a*(2*j+1)))
  have hf (j : ℕ) : 0 ≤ f j := by
    exact mul_nonneg (Nat.cast_nonneg _) (sub_nonneg.mpr (Real.tanh_lt_one _).le)
  have hm (j : ℕ) : f (j+1) ≤ f j := by
    apply mul_le_mul
    · exact_mod_cast centered_choose_antitone r j
    · apply sub_le_sub_left
      apply scalar_tanh_monotone
      push_cast
      nlinarith
    · exact sub_nonneg.mpr (Real.tanh_lt_one _).le
    · exact Nat.cast_nonneg _
  have hsum := (alternating_nonnegative_antitone (r+1) f hf hm).2
  have hzero : f 0 ≤ 2*(Nat.centralBinom r : ℝ)*(1-Real.tanh a) := by
    simpa only [f, Nat.sub_zero, Nat.cast_zero, mul_zero, zero_add, mul_one] using
      mul_le_mul_of_nonneg_right (centered_choose_le_twice r)
        (sub_nonneg.mpr (Real.tanh_lt_one a).le)
  have hid : (∑ j ∈ Finset.range (r+1), (-1 : ℝ)^j*((2*r+1).choose (r-j) : ℝ)*
      Real.tanh (a*(2*j+1))) = (Nat.centralBinom r : ℝ) -
      ∑ j ∈ Finset.range (r+1), (-1 : ℝ)^j*f j := by
    rw [← centered_choose_alternating, ← Finset.sum_sub_distrib]
    apply Finset.sum_congr rfl
    intro j hj
    simp only [f]
    ring
  rw [balancedParity_centered, hid]
  unfold oddParityKappa
  have hpow : 0 < (4 : ℝ)^r := by positivity
  apply (le_of_sub_nonneg ?_)
  have hh : 0 ≤ (Nat.centralBinom r : ℝ) -
      (∑ j ∈ Finset.range (r+1), (-1 : ℝ)^j*f j) -
      (Nat.centralBinom r : ℝ)*(2*Real.tanh a-1) := by linarith
  have hd := div_nonneg hh hpow.le
  convert hd using 1 <;> try rfl
  ring

theorem tanh_one_gt_three_quarters : (3 : ℝ)/4 < Real.tanh 1 := by
  have hexp := Real.sum_le_exp_of_nonneg (by norm_num : (0 : ℝ) ≤ 1) 4
  norm_num [Finset.sum_range_succ] at hexp
  have he : 7 < Real.exp 1 ^ 2 := by nlinarith
  rw [Real.tanh_eq, Real.exp_neg]
  apply (lt_div_iff₀ (by positivity : 0 < Real.exp 1+(Real.exp 1)⁻¹)).mpr
  apply (mul_lt_mul_iff_of_pos_right (Real.exp_pos 1)).mp
  have hne : Real.exp 1 ≠ 0 := (Real.exp_pos 1).ne'
  simp only [add_mul, sub_mul, inv_mul_cancel₀ hne, mul_assoc]
  nlinarith

theorem balancedParity_one_lower (r : ℕ) : oddParityKappa r/2 < balancedParity r 1 := by
  have h := balancedParity_lower r 1 (by norm_num)
  have ht := tanh_one_gt_three_quarters
  have hk := oddParityKappa_pos r
  nlinarith

end NeuralGeneralization.OnlineLowerTanh
