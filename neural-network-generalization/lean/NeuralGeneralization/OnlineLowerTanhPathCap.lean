import NeuralGeneralization.OnlineLowerTanhPathActualCost
import NeuralGeneralization.OnlineLowerTanhOptimizer

/-! # A polynomial cost cap for every literal candidate rectangle -/

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerGeometry

theorem rectangleWeightTransform_abs_le_uniform {m : ℕ}
    (w : Finset (Fin m) → ℝ) (B : ℝ) (hw : ∀s, |w s|≤B) (z : ClippingCube m) :
    |rectangleWeightTransform w z|≤B := by
  have hM : (0 : ℝ)<Fintype.card (ClippingCube m) := Nat.cast_pos.mpr Fintype.card_pos
  unfold rectangleWeightTransform walshExpansion
  rw [abs_div, abs_of_pos hM]
  apply (div_le_iff₀ hM).mpr
  calc
    |∑s, w s*walshCharacter s z| ≤ ∑s, |w s*walshCharacter s z| := Finset.abs_sum_le_sum_abs _ _
    _ = ∑s, |w s| := by simp only [abs_mul, OnlineLower.cost_abs_walshCharacter, mul_one]
    _ ≤ ∑_s : Finset (Fin m), B := Finset.sum_le_sum (fun s _ => hw s)
    _ = B*(Fintype.card (ClippingCube m) : ℝ) := by simp [ClippingCube, mul_comm]

theorem rectangle_totalCost_le_uniform {m : ℕ}
    (w : Finset (Fin m) → ℝ) (B : ℝ) (hw : ∀s, |w s|≤B) (u v : ClippingCube m) :
    rectangleBaselineCost w u + rectangleEffectiveCost w u v≤9*B/2 := by
  have h0 := (abs_le.mp (hw ∅)).2
  have ha := abs_le.mp (rectangleWeightTransform_abs_le_uniform w B hw (cubeOne m))
  have hu := abs_le.mp (rectangleWeightTransform_abs_le_uniform w B hw u)
  have hv := abs_le.mp (rectangleWeightTransform_abs_le_uniform w B hw v)
  have huv := abs_le.mp (rectangleWeightTransform_abs_le_uniform w B hw (cubeTranslation u v))
  unfold rectangleBaselineCost rectangleEffectiveCost
  rw [sub_div, sub_div]
  change w ∅/2 + (rectangleWeightTransform w (cubeOne m)-rectangleWeightTransform w u) +
    (rectangleWeightTransform w v-rectangleWeightTransform w (cubeTranslation u v))≤9*B/2
  linarith

end NeuralGeneralization.OnlineLowerGeometry

namespace NeuralGeneralization.OnlineLowerTanh

theorem balancedCost_ge_one (r : ℕ) : 1≤balancedCost r := by
  have hpar := parityCorrelation_abs_le_one (fun _ : Fin (2*r+1) => balancedGain r) 0
  rw [balancedParity_gain_abs] at hpar
  have hgain := (balancedGain_mem r).1
  have hsqrt : (1 : ℝ)≤Real.sqrt (2*r+1 : ℕ) := by
    have hs := Real.sq_sqrt (show (0 : ℝ)≤(2*r+1 : ℕ) by positivity)
    have hn : (1 : ℝ)≤(2*r+1 : ℕ) := by exact_mod_cast (show 1≤2*r+1 by omega)
    nlinarith [Real.sqrt_nonneg (2*r+1 : ℕ)]
  unfold balancedCost
  apply (le_div_iff₀ (balancedParity_gain_pos r)).mpr
  have hp := mul_le_mul hgain hsqrt (by norm_num : (0 : ℝ)≤1) (balancedGain_pos r).le
  linarith

end NeuralGeneralization.OnlineLowerTanh

namespace NeuralGeneralization.OnlineLowerTanh.Family
open OnlineLower OnlineLowerGeometry

theorem codeBalancedCost_le_four_dimension (R H k : ℕ) (hR : 0<R) (hH : 0<H)
    (hRe : Even R) (hHe : Even H) (s : Finset (Fin (logicalDim k))) :
    codeBalancedCost (physicalCode R H k hR hH) s≤4*(dimension R H k : ℝ) := by
  let n := (carrierSupport (size R H k) (column R H k) s).card
  have ho : Odd n := support_odd R H k hRe hHe s
  have he : 2*(n/2)+1=n := by have hm := Nat.odd_iff.mp ho; omega
  have hn : n≤dimension R H k := by
    simpa only [Fintype.card_fin] using
      (Finset.card_le_univ (carrierSupport (size R H k) (column R H k) s))
  have hb := balancedCost_le_four_degree (n/2)
  rw [he] at hb
  unfold codeBalancedCost
  rw [physicalCode_support]
  exact hb.trans (mul_le_mul_of_nonneg_left (by exact_mod_cast hn) (by norm_num))

/-- A strict cap with polynomial size, uniformly over all logical
rectangles and independent of their Fourier sign or ordering. -/
theorem rectangle_cost_lt_twenty_dimension (R H k : ℕ) (hR : 0<R) (hH : 0<H)
    (hRe : Even R) (hHe : Even H) (u v : ClippingCube (logicalDim k)) :
    rectangleBaselineCost (codeBalancedCost (physicalCode R H k hR hH)) u +
      rectangleEffectiveCost (codeBalancedCost (physicalCode R H k hR hH)) u v <
        20*(dimension R H k : ℝ) := by
  have hw (s : Finset (Fin (logicalDim k))) :
      |codeBalancedCost (physicalCode R H k hR hH) s|≤4*(dimension R H k : ℝ) := by
    rw [abs_of_pos (codeBalancedCost_pos _ _)]
    exact codeBalancedCost_le_four_dimension R H k hR hH hRe hHe s
  have hb := rectangle_totalCost_le_uniform _ _ hw u v
  have hd : (0 : ℝ)<dimension R H k := Nat.cast_pos.mpr (Nat.succ_pos _)
  linarith

theorem logicalCube_card_ge_sixtyfour (k : ℕ) :
    64≤Fintype.card (ClippingCube (logicalDim k)) := by
  have hh : (2 : ℕ)^6≤2^(logicalDim k) :=
    Nat.pow_le_pow_right (by norm_num) (by rw [logicalDim_eq]; omega)
  simpa [ClippingCube] using hh

theorem rectangleCommonA_ge_one (R H k : ℕ) (hR : 0<R) (hH : 0<H)
    (hc : RectangleCostConditions (codeBalancedCost (physicalCode R H k hR hH)) (shiftPoint k)) :
    1≤rectangleCommonA (codeBalancedCost (physicalCode R H k hR hH)) (shiftPoint k) := by
  have ha := hc.parameter_bounds.1
  have hw : 1≤codeBalancedCost (physicalCode R H k hR hH) ∅ := balancedCost_ge_one _
  linarith

end NeuralGeneralization.OnlineLowerTanh.Family
