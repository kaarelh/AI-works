import NeuralGeneralization.BatchTwoContinuousDepthJitterLaw
import NeuralGeneralization.BatchTwoContinuousPairTailDecay

/-! The smaller target gap after smoothing still yields the same Gaussian
pair-tail exponent, because the original distance estimate had spare room. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel BatchTwoContinuous BatchTwoContinuous.PairMoments

/-- Correct prediction of both jittered labels requires a change of .48. -/
theorem jittered_incompatible_correct_outputs {a b u v : ℝ}
    (hgap : (49/50 : ℝ) ≤ |a-b|) (hchange : |u-v| < 12/25) :
    ¬(|u-a| ≤ (1/4 : ℝ) ∧ |v-b| ≤ (1/4 : ℝ)) := by
  rintro ⟨hu, hv⟩
  have h₁ := abs_sub_le a u b
  have h₂ := abs_sub_le u v b
  rw [abs_sub_comm a u] at h₁
  linarith

theorem jittered_scaled_distance_sq (H : ℕ) (z : SignStream × Jitter H) :
    (625/576 : ℝ)*inputDistanceSq (jitteredCoding H z)
      (jitteredCoding H (jitterFlip H z)) ≤ 9*(1/9 : ℝ)^H := by
  have hh := jittered_pair_distance H z
  have hs := pow_le_pow_left₀ (Real.sqrt_nonneg _) hh 2
  change (Real.sqrt (inputDistanceSq (jitteredCoding H z)
    (jitteredCoding H (jitterFlip H z))))^2 ≤ _ at hs
  rw [Real.sq_sqrt (inputDistanceSq_nonneg _ _)] at hs
  have he : ((13/5 : ℝ)*(1/3 : ℝ)^H)^2 = (169/25)*(1/9 : ℝ)^H := by
    rw [mul_pow, ←pow_mul, pow_mul']
    norm_num
  rw [he] at hs
  nlinarith [pow_nonneg (by norm_num : (0 : ℝ) ≤ 1/9) H]

theorem jittered_small_scale_pair_tail {N r : ℕ} (hN : 0 < N) (hr : 60 ≤ r+1)
    {σ : ℝ} (hσ : 0 < σ) (hscale : (N : ℝ)*σ^2 ≤ 1/16)
    (z : SignStream × Jitter (r+1)) :
    (smallPrior 2 N r σ).real {w | (12/25 : ℝ) ≤
      |output Real.tanh w (jitteredCoding (r+1) z)-
        output Real.tanh w (jitteredCoding (r+1) (jitterFlip (r+1) z))|} ≤
      Real.exp (-(11/10)*((r : ℝ)+1)/σ^2) := by
  let x := jitteredCoding (r+1) z
  let y := jitteredCoding (r+1) (jitterFlip (r+1) z)
  have ht := output_pair_tail (r := r) (by norm_num) hN hσ (by norm_num : (0 : ℝ)<12/25)
    x y (pairMomentOrder (σ^2)) (pairMomentOrder_pos (sq_pos_of_pos hσ))
  have hc := pair_moment_coefficient_bound hN hr (sq_pos_of_pos hσ) hscale
    (show 0 ≤ (625/576 : ℝ)*inputDistanceSq x y from by
      exact mul_nonneg (by norm_num) (inputDistanceSq_nonneg _ _))
    (jittered_scaled_distance_sq (r+1) z)
  have he : outputPairMomentBase 2 N r (pairMomentOrder (σ^2)) σ x y/(12/25 : ℝ)^2 =
      2*((625/576 : ℝ)*inputDistanceSq x y)*σ^2*(1+2*(pairMomentOrder (σ^2) : ℝ))*
        (σ^2*((N : ℝ)+2*(pairMomentOrder (σ^2) : ℝ)))^(r+1) := by
    unfold outputPairMomentBase
    norm_num
    ring
  rw [he] at ht
  exact ht.trans (by simpa only [Nat.cast_add,Nat.cast_one] using hc)

theorem jittered_meanfield_pair_tail {N r : ℕ} (hN : 0 < N) (hr : 12 ≤ r+1)
    {σ : ℝ} (hσ : 0 < σ) (hscale : (N : ℝ)*σ^2 = 1)
    (z : SignStream × Jitter (r+1)) :
    (smallPrior 2 N r σ).real {w | (12/25 : ℝ) ≤
      |output Real.tanh w (jitteredCoding (r+1) z)-
        output Real.tanh w (jitteredCoding (r+1) (jitterFlip (r+1) z))|} ≤
      Real.exp (-((r : ℝ)+1)*(N : ℝ)/2) := by
  let x := jitteredCoding (r+1) z
  let y := jitteredCoding (r+1) (jitterFlip (r+1) z)
  have ht := output_pair_tail (r := r) (by norm_num) hN hσ (by norm_num : (0 : ℝ)<12/25)
    x y N hN
  have hc := meanfield_pair_coefficient_bound hN hr (sq_pos_of_pos hσ) hscale
    (show 0 ≤ (625/576 : ℝ)*inputDistanceSq x y from by
      exact mul_nonneg (by norm_num) (inputDistanceSq_nonneg _ _))
    (jittered_scaled_distance_sq (r+1) z)
  have he : outputPairMomentBase 2 N r N σ x y/(12/25 : ℝ)^2 =
      2*((625/576 : ℝ)*inputDistanceSq x y)*σ^2*(1+2*(N : ℝ))*
        (σ^2*((N : ℝ)+2*(N : ℝ)))^(r+1) := by
    unfold outputPairMomentBase
    norm_num
    ring
  rw [he] at ht
  exact ht.trans (by simpa only [Nat.cast_add,Nat.cast_one] using hc)

end NeuralGeneralization.BatchTwoContinuousDepthLower
