import NeuralGeneralization.BatchTwoCircuitConverseCutoff

/-!
# Pathwise reverse log-loss bound for geometric circuit induction
-/

namespace NeuralGeneralization.BatchTwoCircuitConverse

open scoped BigOperators
noncomputable section
open Classical

variable {d : ℕ}

theorem predictiveCost_mono {d : ℕ} {u v : ℝ} (hu : 0 ≤ u) (huv : u ≤ v) :
    predictiveCost d u ≤ predictiveCost d v := by
  have hl2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have ha : 0 < u / Real.log 2 + ((4*d+6 : ℕ) : ℝ) := by positivity
  have hq := div_le_div_of_nonneg_right huv hl2.le
  have hb := Real.log_le_log ha
    (show u / Real.log 2 + ((4*d+6 : ℕ) : ℝ) ≤
      v / Real.log 2 + ((4*d+6 : ℕ) : ℝ) by linarith)
  unfold predictiveCost
  have hm := mul_le_mul_of_nonneg_left hb (by positivity : (0:ℝ) ≤ 2*((3*d+3 : ℕ):ℝ))
  linarith

theorem predictiveCost_ge_one (d : ℕ) {u : ℝ} (hu : 0 ≤ u) : 1 ≤ predictiveCost d u := by
  have hl2 : (1/2 : ℝ) ≤ Real.log 2 := by
    have h := Real.one_sub_inv_le_log_of_pos (by norm_num : (0:ℝ)<2)
    norm_num at h
    linarith
  have hl2pos : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have ha : 1 ≤ u / Real.log 2 + ((4*d+6 : ℕ) : ℝ) := by
    have := div_nonneg hu hl2pos.le
    push_cast
    have hd : (0:ℝ) ≤ d := Nat.cast_nonneg d
    linarith
  have hlog := Real.log_nonneg ha
  have hfrac : 0 ≤ Real.log (4/3 : ℝ) := Real.log_nonneg (by norm_num)
  have hR : (3 : ℝ) ≤ ((3*d+3 : ℕ) : ℝ) := by push_cast; have := Nat.cast_nonneg (α := ℝ) d; linarith
  have hm := mul_nonneg (by positivity : (0:ℝ) ≤ 2*((3*d+3 : ℕ) : ℝ)) hlog
  unfold predictiveCost
  nlinarith

/-- An elementary scalar reverse-logloss inequality sufficient for the exact
constant 2 A_d(L) in the manuscript. -/
theorem neg_log_le_twice_cost_error {p a : ℝ} (hp : 0 < p) (hp1 : p ≤ 1)
    (ha : 1 ≤ a) (hlog : -Real.log p ≤ a) :
    -Real.log p ≤ 2*a*(1-p) := by
  by_cases hh : (1/2 : ℝ) ≤ p
  · have hi := Real.one_sub_inv_le_log_of_pos hp
    have he : p⁻¹ - 1 = (1-p)/p := by field_simp
    have hdiv : (1-p)/p ≤ 2*(1-p) := by
      apply (div_le_iff₀ hp).mpr
      nlinarith [mul_nonneg (sub_nonneg.mpr hp1) (show 0 ≤ 2*p-1 by linarith)]
    have hneg : -Real.log p ≤ (1-p)/p := by rw [← he]; linarith
    have hscale : 2*(1-p) ≤ 2*a*(1-p) := by
      nlinarith [mul_nonneg (show 0 ≤ a-1 by linarith) (sub_nonneg.mpr hp1)]
    exact hneg.trans (hdiv.trans hscale)
  · have hamul := mul_nonneg (show 0 ≤ a by linarith) (show 0 ≤ 1-2*p by linarith)
    nlinarith

@[simp] theorem versionMass_empty (f : Input d → Bool) : versionMass f ∅ = 1 := by
  unfold versionMass descriptionMass
  have he : (fun c : Circuit d => if c.Fits f ∅ then circuitMass c else 0) = circuitMass := by
    funext c
    simp [Circuit.Fits]
  rw [he, tsum_circuitMass, ENNReal.toReal_one]

@[simp] theorem versionLoss_empty (f : Input d → Bool) : versionLoss f ∅ = 0 := by
  simp [versionLoss]

theorem versionLoss_mono (f : Input d → Bool) {A B : Finset (Input d)} (hAB : A ⊆ B) :
    versionLoss f A ≤ versionLoss f B :=
  neg_le_neg (Real.log_le_log (versionMass_pos f B) (versionMass_antitone f hAB))

theorem versionLoss_insert (f : Input d → Bool) (A : Finset (Input d)) (x : Input d) :
    versionLoss f (insert x A) - versionLoss f A = -Real.log (correctProbability f A x) := by
  unfold versionLoss correctProbability
  rw [Real.log_div (versionMass_pos f (insert x A)).ne' (versionMass_pos f A).ne']
  ring

/-- The expected posterior-sampling mistake count for a deterministic query path.
Its equality to the actual finite-function posterior is proved below. -/
def predictionMistakes (f : Input d → Bool) (query : ℕ → Input d) (n : ℕ) : ℝ :=
  ∑ i ∈ Finset.range n, (1 - correctProbability f (history query i) (query i))

theorem predictionMistakes_nonneg (f : Input d → Bool) (query : ℕ → Input d) (n : ℕ) :
    0 ≤ predictionMistakes f query n := by
  unfold predictionMistakes
  apply Finset.sum_nonneg
  intro i hi
  exact sub_nonneg.mpr (correctProbability_le_one _ _ _)

theorem versionLoss_eq_sum_log (f : Input d → Bool) (query : ℕ → Input d) (n : ℕ) :
    versionLoss f (history query n) =
      ∑ i ∈ Finset.range n, -Real.log (correctProbability f (history query i) (query i)) := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [history_succ, Finset.sum_range_succ]
    have hs := versionLoss_insert f (history query n) (query n)
    rw [ih] at hs
    linarith

/-- Exact pathwise reverse-logloss inequality from the paper, now with the prior,
repair construction, cutoff, and all label-probability estimates discharged. -/
theorem geometric_pathwise_loss (f : Input d → Bool) (query : ℕ → Input d) (n : ℕ) :
    versionLoss f (history query n) ≤
      2 * predictiveCost d (versionLoss f (history query n)) * predictionMistakes f query n := by
  rw [versionLoss_eq_sum_log f query n]
  have hbound : ∀ i ∈ Finset.range n,
      -Real.log (correctProbability f (history query i) (query i)) ≤
      2 * predictiveCost d (versionLoss f (history query n)) *
        (1 - correctProbability f (history query i) (query i)) := by
    intro i hi
    have hsub : history query i ⊆ history query n := by
      exact Finset.image_subset_image (Finset.range_mono (Nat.le_of_lt (Finset.mem_range.mp hi)))
    have hloss := versionLoss_mono f hsub
    have hcost := predictiveCost_mono (d := d) (versionLoss_nonneg f _) hloss
    exact neg_log_le_twice_cost_error (correctProbability_pos _ _ _)
      (correctProbability_le_one _ _ _) (predictiveCost_ge_one d (versionLoss_nonneg f _))
      ((neg_log_correctProbability_le _ _ _).trans hcost)
  have hs := Finset.sum_le_sum hbound
  rw [← Finset.mul_sum] at hs
  simpa only [predictionMistakes, ← versionLoss_eq_sum_log f query n] using hs

end
end NeuralGeneralization.BatchTwoCircuitConverse
