import NeuralGeneralization.BatchTwoCircuitConversePosterior
import Mathlib.Analysis.Convex.SpecificFunctions.Basic

/-!
# The exact lower-bound form of the geometric circuit-prior converse
-/

namespace NeuralGeneralization.BatchTwoCircuitConverse

noncomputable section
open Classical

/-- Concavity of log and positivity of the constant term imply the monotonicity
of u/A_d(u), without differentiating the reciprocal expression. -/
theorem predictiveCost_cross_mono (d : ℕ) {x y : ℝ} (hx : 0 ≤ x) (hxy : x ≤ y) :
    x * predictiveCost d y ≤ y * predictiveCost d x := by
  have hy : 0 ≤ y := hx.trans hxy
  by_cases hy0 : y = 0
  · have hx0 : x = 0 := by linarith
    simp [hx0, hy0]
  have hyp : 0 < y := lt_of_le_of_ne hy (Ne.symm hy0)
  let R : ℝ := ((3*d+3 : ℕ):ℝ)
  let B : ℝ := ((4*d+6 : ℕ):ℝ)
  let r := Real.log 2
  have hr : 0 < r := Real.log_pos (by norm_num)
  have hB : 1 ≤ B := by
    dsimp [B]
    push_cast
    have hd : (0:ℝ) ≤ d := Nat.cast_nonneg d
    linarith
  have ht : 0 ≤ x/y := div_nonneg hx hy
  have ht1 : x/y ≤ 1 := (div_le_one hyp).mpr hxy
  have hc := strictConcaveOn_log_Ioi.concaveOn.2
    (show 0 < y/r+B by positivity) (show 0 < B by linarith)
    ht (sub_nonneg.mpr ht1) (show x/y+(1-x/y)=1 by ring)
  simp only [smul_eq_mul] at hc
  have he : x/y*(y/r+B)+(1-x/y)*B = x/r+B := by field_simp; ring
  rw [he] at hc
  have hlogB : 0 ≤ Real.log B := Real.log_nonneg hB
  have hprod := mul_nonneg (sub_nonneg.mpr ht1) hlogB
  have hlog : x/y*Real.log (y/r+B) ≤ Real.log (x/r+B) := by linarith
  have hm := mul_le_mul_of_nonneg_left hlog hy
  have hcancel : y*(x/y*Real.log (y/r+B)) = x*Real.log (y/r+B) := by
    field_simp
  rw [hcancel] at hm
  have ha : 0 ≤ Real.log (4/3:ℝ)+R*r := by
    apply add_nonneg (Real.log_nonneg (by norm_num))
    exact mul_nonneg (by dsimp [R]; positivity) hr.le
  have hconst := mul_le_mul_of_nonneg_right hxy ha
  have hlogmul := mul_le_mul_of_nonneg_left hm (show 0 ≤ 2*R by dsimp [R]; positivity)
  dsimp [R, B, r] at *
  unfold predictiveCost
  nlinarith

/-- Exact first inequality of the geometric Bayesian converse, given its
already-proved pathwise loss bound. -/
theorem complexity_lower_of_loss_bound {d : ℕ} (f : Input d → Bool)
    (A : Finset (Input d)) {m : ℝ}
    (hloss : versionLoss f A ≤ 2*predictiveCost d (versionLoss f A)*m) :
    ((complexity f A : ℝ)*Real.log 2) /
      (2*predictiveCost d ((complexity f A : ℝ)*Real.log 2)) ≤ m := by
  let x := (complexity f A : ℝ)*Real.log 2
  let y := versionLoss f A
  have hx : 0 ≤ x := by dsimp [x]; positivity
  have hy : 0 ≤ y := versionLoss_nonneg f A
  have hxy : x ≤ y := complexity_le_versionLoss f A
  have hc := predictiveCost_cross_mono d hx hxy
  have hAx : 0 < predictiveCost d x := lt_of_lt_of_le (by norm_num) (predictiveCost_ge_one d hx)
  have hAy : 0 < predictiveCost d y := lt_of_lt_of_le (by norm_num) (predictiveCost_ge_one d hy)
  have hratio : x/(2*predictiveCost d x) ≤ y/(2*predictiveCost d y) := by
    apply (div_le_div_iff₀ (by positivity) (by positivity)).mpr
    nlinarith
  have hm : y/(2*predictiveCost d y) ≤ m := by
    apply (div_le_iff₀ (by positivity)).mpr
    simpa only [mul_comm] using hloss
  exact hratio.trans hm

/-- Exact lower-bound form, for the actual finite-function posterior induced by
the specified countable NAND-description prior. -/
theorem geometric_posterior_mistake_lower {d : ℕ} (f : Input d → Bool)
    (query : ℕ → Input d) (n : ℕ) :
    ((complexity f (history query n) : ℝ)*Real.log 2) /
      (2*predictiveCost d ((complexity f (history query n) : ℝ)*Real.log 2)) ≤
    BatchTwoOnline.cumulativeError (functionWeight d) (fun g x => g x = f x) query n := by
  rw [← predictionMistakes_eq_cumulativeError]
  exact complexity_lower_of_loss_bound f _ (geometric_pathwise_loss f query n)

end
end NeuralGeneralization.BatchTwoCircuitConverse
