import NeuralGeneralization.OnlineLowerTanhHamming
import NeuralGeneralization.OnlineLowerReluCostVariation

/-! Concrete nonasymptotic bounds for the actual balanced optimum. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLowerRelu

theorem oddParityKappa_eq_twice_relu (r : ℕ) : oddParityKappa r = 2*evenReluKappa r := by
  unfold oddParityKappa evenReluKappa
  rw [pow_add, pow_mul]
  norm_num
  ring

theorem oddParityKappa_lower_square (r : ℕ) :
    1 ≤ (4*(r : ℝ)+1)*oddParityKappa r^2 := by
  have h := evenReluKappa_lower_square r
  rw [oddParityKappa_eq_twice_relu]
  nlinarith

theorem oddParityKappa_mul_sqrt_lower (r : ℕ) :
    (1 : ℝ)/2 ≤ oddParityKappa r*Real.sqrt (2*r+1 : ℕ) := by
  have hk := oddParityKappa_pos r
  have hl := oddParityKappa_lower_square r
  have hs := Real.sq_sqrt (show (0 : ℝ) ≤ (2*r+1 : ℕ) by positivity)
  have hmul := congrArg (fun x : ℝ => oddParityKappa r^2*x) hs
  have hn : 0 ≤ oddParityKappa r*Real.sqrt (2*r+1 : ℕ) := by positivity
  push_cast at hs hmul hn ⊢
  nlinarith [sq_nonneg (oddParityKappa r*Real.sqrt (2*r+1 : ℕ)-1/2)]

theorem balancedParity_gain_lower (r : ℕ) :
    balancedGain r * (oddParityKappa r/2) < balancedParity r (balancedGain r) := by
  have hmax : balancedParity r 1 ≤ balancedParity r (balancedGain r)/balancedGain r := by
    have h := balancedGain_max r (by norm_num : (1 : ℝ) ∈ Set.Icc 1 2)
    change balancedRatio r 1 ≤ balancedRatio r (balancedGain r) at h
    simpa only [balancedRatio, div_one] using h
  have hq := balancedParity_one_lower r
  have ha := balancedGain_pos r
  have hh := (le_div_iff₀ ha).mp hmax
  nlinarith

theorem balancedParity_gain_pos (r : ℕ) : 0 < balancedParity r (balancedGain r) := by
  exact lt_trans (mul_pos (balancedGain_pos r) (half_pos (oddParityKappa_pos r)))
    (balancedParity_gain_lower r)

theorem balancedCost_pos (r : ℕ) : 0 < balancedCost r := by
  unfold balancedCost
  exact div_pos (mul_pos (balancedGain_pos r) (Real.sqrt_pos.mpr (by positivity)))
    (balancedParity_gain_pos r)

theorem balancedCost_le_four_degree (r : ℕ) :
    balancedCost r ≤ 4*(2*r+1 : ℕ) := by
  have hq := balancedParity_gain_lower r
  have hk := oddParityKappa_pos r
  have ha := balancedGain_pos r
  have hl := oddParityKappa_mul_sqrt_lower r
  have hs := Real.sq_sqrt (show (0 : ℝ) ≤ (2*r+1 : ℕ) by positivity)
  have hroot : Real.sqrt (2*r+1 : ℕ) ≤ 2*(2*r+1 : ℕ)*oddParityKappa r := by
    have h := mul_le_mul_of_nonneg_right hl (Real.sqrt_nonneg (2*r+1 : ℕ))
    nlinarith
  unfold balancedCost
  apply (div_le_iff₀ (balancedParity_gain_pos r)).mpr
  have h := mul_le_mul_of_nonneg_right hq.le
    (show (0 : ℝ) ≤ 4*(2*r+1 : ℕ) by positivity)
  nlinarith [mul_le_mul_of_nonneg_left hroot ha.le]

/-- Uniform mass lower bound used by the orbit synthesis and localization. -/
theorem balancedGain_mass_lower (r : ℕ) :
    (1 : ℝ)/4 ≤ balancedGain r*Real.sqrt (2*r+1 : ℕ)*
      balancedParity r (balancedGain r) := by
  have hq := balancedParity_gain_lower r
  have ha := (balancedGain_mem r).1
  have hk := oddParityKappa_pos r
  have hl := oddParityKappa_mul_sqrt_lower r
  have hs := Real.sqrt_nonneg (2*r+1 : ℕ)
  have hqa : oddParityKappa r/2 ≤ balancedParity r (balancedGain r) := by nlinarith
  have h := mul_le_mul_of_nonneg_left hqa hs
  have hp := balancedParity_gain_pos r
  nlinarith [mul_nonneg hs hp.le]

end NeuralGeneralization.OnlineLowerTanh
