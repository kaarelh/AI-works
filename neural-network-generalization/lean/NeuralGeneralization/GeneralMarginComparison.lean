import NeuralGeneralization.MonotoneScoreTransform

/-! Arbitrary training/test margins and their bounded-loss comparison. -/
noncomputable section
namespace NeuralGeneralization.GeneralMargin
open ConcreteModel RobustStatistics

structure Admissible (m u : ℝ) (F : ℝ → ℝ) : Prop where
  train_pos : 0 < m
  test_nonneg : 0 ≤ u
  test_lt_train : u < m
  odd : ∀ z,F (-z) = -F z
  monotone : Monotone F
  lipschitz : ∀ a z,|F a-F z| ≤ |a-z|
  saturated : ∀ z,m ≤ z → F z = F m
  gap_pos : 0 < F m-F u

def gap (m u : ℝ) (F : ℝ → ℝ) : ℝ := F m-F u

namespace Admissible
variable {m u : ℝ} {F : ℝ → ℝ} (hF : Admissible m u F)
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

lemma gap_le_margin : gap m u F ≤ m-u := by
  have hh := (le_abs_self (F m-F u)).trans (hF.lipschitz m u)
  rw [abs_of_nonneg (sub_nonneg.mpr hF.test_lt_train.le)] at hh
  exact hh

lemma ramp_gap : F u+gap m u F/3 < F m-gap m u F/3 := by
  have hh := hF.gap_pos
  dsimp [gap]
  linarith

def rule : PredictionComparison m u where
  good z a := |F a-F z| ≤ gap m u F/3
  measurable_good := measurableSet_le
    (((hF.continuous.measurable.comp measurable_snd).sub
      (hF.continuous.measurable.comp measurable_fst)).abs) measurable_const
  loss b a := separatedRamp (F u+gap m u F/3) (F m-gap m u F/3) (labelReal b*F a)
  measurable_loss b := (continuous_separatedRamp _ _).measurable.comp (hF.continuous.measurable.const_mul _)
  loss_bounds b a := separatedRamp_bounds _ _ _
  training b z a hz hg := by
    apply separatedRamp_eq_zero hF.ramp_gap
    have hs : |labelReal b*F a-labelReal b*F z| ≤ gap m u F/3 := by
      simpa only [← mul_sub,abs_mul,abs_labelReal,one_mul] using hg
    have heq : labelReal b*F z = F m := by
      rw [← hF.signed]
      exact hF.saturated _ hz.le
    linarith [(abs_le.mp hs).1]
  test b z a hz hg := by
    apply separatedRamp_eq_one hF.ramp_gap
    have hs : |labelReal b*F a-labelReal b*F z| ≤ gap m u F/3 := by
      simpa only [← mul_sub,abs_mul,abs_labelReal,one_mul] using hg
    have hle : labelReal b*F z ≤ F u := by
      rw [← hF.signed]
      exact hF.monotone hz
    linarith [(abs_le.mp hs).2]

lemma good_of_raw_close {z a : ℝ} (hh : |a-z| ≤ gap m u F/3) : hF.rule.good z a :=
  (hF.lipschitz a z).trans hh

lemma good_of_noisy_comparison {z z' a radius : ℝ}
    (hstable : |F z'-F z| ≤ gap m u F/4) (hround : |a-z'| ≤ radius/8)
    (hr : radius ≤ 2*gap m u F/3) : hF.rule.good z a := by
  have htriangle := abs_sub_le (F a) (F z') (F z)
  have happrox := (hF.lipschitz a z').trans hround
  change |F a-F z| ≤ gap m u F/3
  linarith

end Admissible

def clip (m z : ℝ) : ℝ := max (-m) (min m z)

lemma clip_of_between {m z : ℝ} (hl : -m ≤ z) (hu : z ≤ m) : clip m z = z := by
  simp [clip,min_eq_right hu,max_eq_right hl]

lemma clip_of_le {m z : ℝ} (hm : 0 ≤ m) (hz : z ≤ -m) : clip m z = -m := by
  rw [clip,min_eq_right (by linarith),max_eq_left hz]

lemma clip_of_ge {m z : ℝ} (hm : 0 ≤ m) (hz : m ≤ z) : clip m z = m := by
  rw [clip,min_eq_left hz,max_eq_right (by linarith)]

lemma clip_neg {m : ℝ} (hm : 0 ≤ m) (z : ℝ) : clip m (-z) = -clip m z := by
  by_cases hl : z ≤ -m
  · rw [clip_of_le hm hl,clip_of_ge hm (by linarith)]
    ring
  by_cases hu : m ≤ z
  · rw [clip_of_ge hm hu,clip_of_le hm (by linarith)]
  · rw [clip_of_between (by linarith) (by linarith),clip_of_between (by linarith) (by linarith)]

lemma clip_lipschitz (m a z : ℝ) : |clip m a-clip m z| ≤ |a-z| := by
  have h : LipschitzWith 1 (clip m) := (LipschitzWith.id.const_min m).const_max (-m)
  simpa only [Real.dist_eq,NNReal.coe_one,one_mul] using h.dist_le_mul a z

lemma clip_admissible {m u : ℝ} (hm : 0 < m) (hu : 0 ≤ u) (hum : u < m) :
    Admissible m u (clip m) where
  train_pos := hm
  test_nonneg := hu
  test_lt_train := hum
  odd := clip_neg hm.le
  monotone := fun _ _ h => max_le_max_left _ (min_le_min_left _ h)
  lipschitz := clip_lipschitz m
  saturated z hz := by rw [clip_of_ge hm.le hz,clip_of_ge hm.le le_rfl]
  gap_pos := by
    rw [clip_of_ge hm.le le_rfl,clip_of_between (by linarith) hum.le]
    linarith

lemma clip_gap {m u : ℝ} (hm : 0 < m) (hu : 0 ≤ u) (hum : u < m) :
    gap m u (clip m) = m-u := by
  rw [gap,clip_of_ge hm.le le_rfl,clip_of_between (by linarith) hum.le]

end NeuralGeneralization.GeneralMargin
