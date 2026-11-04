import NeuralGeneralization.MonotoneScoreTransform
import NeuralGeneralization.MarginBandSupport

/-! Full-gap minimality in precisely the class of transforms stated in the
paper. This does not compare arbitrary prior conditions. -/
noncomputable section
namespace NeuralGeneralization.MarginBand

lemma softThreshold_eq_sign {b : ℝ} (hb : 0 ≤ b) (z : ℝ) :
    softThreshold b z = Real.sign z*max 0 (|z|-b) := by
  rcases lt_trichotomy z 0 with hn | hz | hp
  · rw [Real.sign_of_neg hn,abs_of_neg hn,softThreshold,max_eq_left (by linarith)]
    ring
  · subst z
    simp [softThreshold,max_eq_left (neg_nonpos.mpr hb)]
  · rw [Real.sign_of_pos hp,abs_of_pos hp,softThreshold,
      max_eq_left (show -z-b ≤ 0 by linarith),sub_zero,one_mul]

lemma softThreshold_of_nonneg {b z : ℝ} (hb : 0 ≤ b) (hz : 0 ≤ z) :
    softThreshold b z = max 0 (z-b) := by
  rw [softThreshold,max_eq_left (show -z-b ≤ 0 by linarith),sub_zero]

lemma score_linear {z : ℝ} (hz : (1/4:ℝ) ≤ z) (hz1 : z ≤ 1/2) : score z = z-1/4 := by
  rw [score,Real.sign_of_pos (by linarith),abs_of_nonneg (by linarith),one_mul,
    max_eq_right (by linarith),min_eq_right (by linarith)]

end NeuralGeneralization.MarginBand
namespace NeuralGeneralization.ScoreTransform.Admissible
open ConcreteModel MarginBand
variable {F : ℝ → ℝ} (hF : Admissible F)
include hF

lemma full_gap_linear (hfull : gap F = 1/4) {z : ℝ}
    (hz : (1/4:ℝ) ≤ z) (hz1 : z ≤ 1/2) : F z = F (1/4)+z-1/4 := by
  have hlo := hF.lipschitz z (1/4)
  have hhi := hF.lipschitz (1/2) z
  rw [abs_of_nonneg (by linarith : 0 ≤ z-1/4)] at hlo
  rw [abs_of_nonneg (by linarith : 0 ≤ (1/2:ℝ)-z)] at hhi
  dsimp [gap] at hfull
  linarith [(abs_le.mp hlo).2,(abs_le.mp hhi).2]

lemma full_gap_inner_bounds {z : ℝ} (hz : 0 ≤ z) (hz1 : z ≤ 1/4) :
    0 ≤ F z ∧ F z ≤ F (1/4) := ⟨hF.nonneg hz,hF.monotone hz1⟩

lemma full_gap_threshold_nonneg (hfull : gap F = 1/4) {z : ℝ} (hz : 0 ≤ z) :
    MarginBand.score z = softThreshold (F (1/4)) (F z) := by
  have hB : 0 ≤ F (1/4) := hF.nonneg (by norm_num)
  rw [softThreshold_of_nonneg hB (hF.nonneg hz)]
  by_cases hzq : z ≤ 1/4
  · rw [MarginBand.score_eq_zero (by rwa [abs_of_nonneg hz]),max_eq_left (by linarith [hF.monotone hzq])]
  · have hzq' : (1/4:ℝ) ≤ z := (lt_of_not_ge hzq).le
    by_cases hzh : z ≤ 1/2
    · rw [MarginBand.score_linear hzq' hzh,hF.full_gap_linear hfull hzq' hzh]
      rw [max_eq_right (by linarith)]
      ring
    · rw [MarginBand.score_eq_quarter (le_of_not_ge hzh),hF.saturated z (le_of_not_ge hzh)]
      have hh : F (1/2)-F (1/4) = (1/4:ℝ) := hfull
      rw [hh,max_eq_right (by norm_num)]

/-- The exact soft-threshold identity asserted in the manuscript. -/
theorem full_gap_threshold (hfull : gap F = 1/4) (z : ℝ) :
    MarginBand.score z = softThreshold (F (1/4)) (F z) := by
  rcases le_total 0 z with hz | hz
  · exact hF.full_gap_threshold_nonneg hfull hz
  · have hh := hF.full_gap_threshold_nonneg hfull (neg_nonneg.mpr hz)
    rw [MarginBand.score_neg,hF.odd,softThreshold_neg] at hh
    linarith

theorem full_gap_literal_identity (hfull : gap F = 1/4) (z : ℝ) :
    MarginBand.score z = Real.sign (F z)*max 0 (|F z|-F (1/4)) := by
  rw [hF.full_gap_threshold hfull,softThreshold_eq_sign (hF.nonneg (by norm_num))]

/-- Every full-gap admissible transformed-score stability condition implies
margin-band stability at the same radius and tolerance. -/
theorem full_gap_contraction (hfull : gap F = 1/4) (a z : ℝ) :
    |MarginBand.score a-MarginBand.score z| ≤ |F a-F z| := by
  rw [hF.full_gap_threshold hfull,hF.full_gap_threshold hfull]
  exact softThreshold_lipschitz (hF.nonneg (by norm_num)) _ _

end NeuralGeneralization.ScoreTransform.Admissible
