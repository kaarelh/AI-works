import NeuralGeneralization.RobustPredictionComparison
import NeuralGeneralization.MarginBandScore

/-! The manuscript's arbitrary monotone score transforms and their exact
bounded-loss comparison across the training/test margin gap. -/
noncomputable section
open MeasureTheory
namespace NeuralGeneralization.RobustStatistics

def separatedRamp (low high t : ℝ) : ℝ := max 0 (min 1 ((high-t)/(high-low)))

lemma separatedRamp_bounds (low high t : ℝ) :
    0 ≤ separatedRamp low high t ∧ separatedRamp low high t ≤ 1 :=
  ⟨le_max_left _ _,max_le (by norm_num) (min_le_left _ _)⟩

lemma continuous_separatedRamp (low high : ℝ) : Continuous (separatedRamp low high) := by
  unfold separatedRamp
  fun_prop

lemma separatedRamp_eq_zero {low high t : ℝ} (hgap : low < high) (ht : high ≤ t) :
    separatedRamp low high t = 0 := by
  have hh : (high-t)/(high-low) ≤ 0 := div_nonpos_of_nonpos_of_nonneg (by linarith) (by linarith)
  rw [separatedRamp,min_eq_right (by linarith),max_eq_left hh]

lemma separatedRamp_eq_one {low high t : ℝ} (hgap : low < high) (ht : t ≤ low) :
    separatedRamp low high t = 1 := by
  have hh : 1 ≤ (high-t)/(high-low) := (le_div_iff₀ (by linarith)).mpr (by linarith)
  rw [separatedRamp,min_eq_left hh,max_eq_right (by norm_num)]

end NeuralGeneralization.RobustStatistics
namespace NeuralGeneralization.ScoreTransform
open ConcreteModel RobustStatistics

structure Admissible (F : ℝ → ℝ) : Prop where
  odd : ∀ z,F (-z) = -F z
  monotone : Monotone F
  lipschitz : ∀ a z,|F a-F z| ≤ |a-z|
  saturated : ∀ z,(1/2:ℝ) ≤ z → F z = F (1/2)
  gap_pos : 0 < F (1/2)-F (1/4)

def gap (F : ℝ → ℝ) : ℝ := F (1/2)-F (1/4)

namespace Admissible
variable {F : ℝ → ℝ} (hF : Admissible F)
include hF

lemma continuous : Continuous F :=
  (LipschitzWith.mk_one (fun a z => by simpa only [Real.dist_eq] using hF.lipschitz a z)).continuous

lemma zero : F 0 = 0 := by
  have hh := hF.odd 0
  simp only [neg_zero] at hh
  linarith

lemma signed (b : Bool) (z : ℝ) : F (labelReal b*z) = labelReal b*F z := by
  cases b
  · simp only [labelReal_false,neg_one_mul,hF.odd]
  · simp only [labelReal_true,one_mul]

lemma nonneg {z : ℝ} (hz : 0 ≤ z) : 0 ≤ F z := by
  simpa only [hF.zero] using hF.monotone hz

lemma gap_le_quarter : gap F ≤ 1/4 := by
  have hh := (le_abs_self (F (1/2)-F (1/4))).trans (hF.lipschitz (1/2) (1/4))
  norm_num at hh
  dsimp [gap]
  linarith

lemma ramp_gap : F (1/4)+gap F/3 < F (1/2)-gap F/3 := by
  have hh := hF.gap_pos
  dsimp [gap]
  linarith

def rule : PredictionComparison (1/2) (1/4) where
  good z a := |F a-F z| ≤ gap F/3
  measurable_good := measurableSet_le
    (((hF.continuous.measurable.comp measurable_snd).sub
      (hF.continuous.measurable.comp measurable_fst)).abs) measurable_const
  loss b a := separatedRamp (F (1/4)+gap F/3) (F (1/2)-gap F/3) (labelReal b*F a)
  measurable_loss b := (continuous_separatedRamp _ _).measurable.comp (hF.continuous.measurable.const_mul _)
  loss_bounds b a := separatedRamp_bounds _ _ _
  training b z a hz hg := by
    apply separatedRamp_eq_zero hF.ramp_gap
    have hs : |labelReal b*F a-labelReal b*F z| ≤ gap F/3 := by
      simpa only [← mul_sub,abs_mul,abs_labelReal,one_mul] using hg
    have heq : labelReal b*F z = F (1/2) := by
      rw [← hF.signed]
      exact hF.saturated _ hz.le
    linarith [(abs_le.mp hs).1]
  test b z a hz hg := by
    apply separatedRamp_eq_one hF.ramp_gap
    have hs : |labelReal b*F a-labelReal b*F z| ≤ gap F/3 := by
      simpa only [← mul_sub,abs_mul,abs_labelReal,one_mul] using hg
    have hle : labelReal b*F z ≤ F (1/4) := by
      rw [← hF.signed]
      exact hF.monotone hz
    linarith [(abs_le.mp hs).2]

lemma good_of_raw_close {z a : ℝ} (hh : |a-z| ≤ gap F/3) : hF.rule.good z a :=
  (hF.lipschitz a z).trans hh

lemma good_of_noisy_comparison {z z' a radius : ℝ}
    (hstable : |F z'-F z| ≤ gap F/4) (hround : |a-z'| ≤ radius/8)
    (hr : radius ≤ 2*gap F/3) : hF.rule.good z a := by
  have htriangle := abs_sub_le (F a) (F z') (F z)
  have happrox := (hF.lipschitz a z').trans hround
  change |F a-F z| ≤ gap F/3
  linarith

end Admissible

/-- U has the full available 1/4 gap and exactly satisfies all hypotheses. -/
theorem marginBand_admissible : Admissible MarginBand.score where
  odd := MarginBand.score_neg
  monotone := MarginBand.score_monotone
  lipschitz := MarginBand.score_lipschitz
  saturated z hz := by rw [MarginBand.score_eq_quarter hz,MarginBand.score_eq_quarter le_rfl]
  gap_pos := by norm_num [MarginBand.score,Real.sign]

end NeuralGeneralization.ScoreTransform
