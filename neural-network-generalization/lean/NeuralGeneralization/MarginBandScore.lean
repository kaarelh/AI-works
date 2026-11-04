import NeuralGeneralization.TwoMarginSupport
import Mathlib.Data.Real.Sign

/-! The literal margin-band score from the manuscript, its contraction
through clipping, and its implication for two-margin transport. -/
noncomputable section
namespace NeuralGeneralization.MarginBand
open ConcreteModel RobustStatistics

def softThreshold (b z : ℝ) : ℝ := max 0 (z-b)-max 0 (-z-b)

lemma softThreshold_neg (b z : ℝ) : softThreshold b (-z) = -softThreshold b z := by
  simp only [softThreshold,neg_neg]
  ring

lemma softThreshold_lipschitz {b : ℝ} (hb : 0 ≤ b) (a z : ℝ) :
    |softThreshold b a-softThreshold b z| ≤ |a-z| := by
  simp only [softThreshold,max_def,abs_le]
  split_ifs <;> constructor <;> linarith [le_abs_self (a-z),neg_abs_le (a-z)]

lemma softThreshold_monotone {b : ℝ} (hb : 0 ≤ b) : Monotone (softThreshold b) := by
  intro a z haz
  simp only [softThreshold,max_def]
  split_ifs <;> linarith

lemma continuous_softThreshold (b : ℝ) : Continuous (softThreshold b) :=
  (continuous_const.max (continuous_id.sub continuous_const)).sub
    (continuous_const.max (continuous_id.neg.sub continuous_const))

/-- This is the paper's formula, including the sign at zero. -/
def score (z : ℝ) : ℝ := Real.sign z * min (1/4) (max 0 (|z|-1/4))

lemma score_neg (z : ℝ) : score (-z) = -score z := by
  simp only [score,Real.sign_neg,abs_neg,neg_mul]

lemma score_eq_softThreshold_nonneg {z : ℝ} (hz : 0 ≤ z) :
    score z = softThreshold (1/4) (clippedScore z) := by
  rcases hz.eq_or_lt with he | hp
  · subst z
    norm_num [score,softThreshold,clippedScore]
  · have hclip : 0 ≤ min (1/2:ℝ) z := le_min (by norm_num) hz
    rw [score,Real.sign_of_pos hp,abs_of_nonneg hz,one_mul,softThreshold,clippedScore,
      max_eq_right (show -(1/2:ℝ) ≤ min (1/2:ℝ) z by linarith),
      max_eq_left (show -(min (1/2:ℝ) z)-1/4 ≤ 0 by linarith),sub_zero]
    simp only [max_def,min_def]
    split_ifs <;> linarith

lemma score_eq_softThreshold (z : ℝ) : score z = softThreshold (1/4) (clippedScore z) := by
  rcases le_total 0 z with hp | hn
  · exact score_eq_softThreshold_nonneg hp
  · have hh := score_eq_softThreshold_nonneg (neg_nonneg.mpr hn)
    rw [score_neg,TwoMarginTransport.clippedScore_neg,softThreshold_neg] at hh
    linarith

lemma signed_score (b : Bool) (z : ℝ) : score (labelReal b*z) = labelReal b*score z := by
  cases b
  · simp only [labelReal_false,neg_one_mul,score_neg]
  · simp only [labelReal_true,one_mul]

lemma score_clipped_contraction (a z : ℝ) : |score a-score z| ≤ |clippedScore a-clippedScore z| := by
  rw [score_eq_softThreshold,score_eq_softThreshold]
  exact softThreshold_lipschitz (by norm_num) _ _

lemma score_lipschitz (a z : ℝ) : |score a-score z| ≤ |a-z| :=
  (score_clipped_contraction a z).trans (clippedScore_lipschitz a z)

lemma score_monotone : Monotone score := by
  intro a z haz
  rw [score_eq_softThreshold,score_eq_softThreshold]
  apply softThreshold_monotone (by norm_num)
  exact max_le_max_left _ (min_le_min_left _ haz)

lemma continuous_score : Continuous score := by
  have heq : score = fun z => softThreshold (1/4) (clippedScore z) := funext score_eq_softThreshold
  rw [heq]
  exact (continuous_softThreshold _).comp continuous_clippedScore

lemma score_eq_quarter {z : ℝ} (hz : (1/2:ℝ) ≤ z) : score z = 1/4 := by
  rw [score,Real.sign_of_pos (by linarith),abs_of_nonneg (by linarith),one_mul]
  rw [max_eq_right (by linarith),min_eq_left (by linarith)]

lemma score_eq_zero {z : ℝ} (hz : |z| ≤ (1/4:ℝ)) : score z = 0 := by
  rw [score,max_eq_left (by linarith),min_eq_right (by norm_num),mul_zero]

lemma le_score_iff {a z : ℝ} (ha : 0 < a) (ha1 : a ≤ 1/4) :
    a ≤ score z ↔ a+1/4 ≤ z := by
  rw [score_eq_softThreshold]
  simp only [softThreshold,clippedScore,max_def,min_def]
  split_ifs <;> constructor <;> intro h <;> linarith

lemma score_le_iff {a z : ℝ} (ha : 0 ≤ a) (ha1 : a < 1/4) :
    score z ≤ a ↔ z ≤ a+1/4 := by
  rw [score_eq_softThreshold]
  simp only [softThreshold,clippedScore,max_def,min_def]
  split_ifs <;> constructor <;> intro h <;> linarith

/-- Stability of U at tolerance 1/16 suffices for both literal transport
implications, for both signs and including boundary-triggered margins. -/
theorem transport_of_score_close {z z' : ℝ} (hh : |score z'-score z| ≤ 1/16) :
    ∀ b : Bool,
      ((1/2:ℝ) ≤ labelReal b*z → 7/16 ≤ labelReal b*z') ∧
      (labelReal b*z ≤ (1/4:ℝ) → labelReal b*z' ≤ 5/16) := by
  intro b
  have hs : |score (labelReal b*z')-score (labelReal b*z)| ≤ 1/16 := by
    simpa only [signed_score,← mul_sub,abs_mul,abs_labelReal,one_mul] using hh
  have hbounds := abs_le.mp hs
  constructor
  · intro hz
    have hclean := score_eq_quarter hz
    have hnoisy : (3/16:ℝ) ≤ score (labelReal b*z') := by linarith
    have he := (le_score_iff (by norm_num : (0:ℝ)<3/16) (by norm_num)).mp hnoisy
    norm_num at he
    exact he
  · intro hz
    have hclean : score (labelReal b*z) ≤ 0 :=
      (score_le_iff (by norm_num : (0:ℝ)≤0) (by norm_num)).mpr (by simpa using hz)
    have hnoisy : score (labelReal b*z') ≤ (1/16:ℝ) := by linarith
    have he := (score_le_iff (by norm_num : (0:ℝ)≤1/16) (by norm_num)).mp hnoisy
    norm_num at he
    exact he

/-- The paper's intermediate-score example satisfies transport but exceeds
U's allowed change by a factor of two. Its reverse violates transport. -/
theorem intermediate_example :
    (∀ b : Bool,
      ((1/2:ℝ) ≤ labelReal b*(3/8) → 7/16 ≤ labelReal b*(11/20)) ∧
      (labelReal b*(3/8) ≤ (1/4:ℝ) → labelReal b*(11/20) ≤ 5/16)) ∧
    |score (11/20)-score (3/8)| = (1/8:ℝ) ∧
    ¬ ((1/2:ℝ) ≤ labelReal true*(11/20) → 7/16 ≤ labelReal true*(3/8)) := by
  constructor
  · intro b; cases b <;> norm_num [labelReal]
  constructor
  · norm_num [score,Real.sign]
  · norm_num [labelReal]

lemma central_example : score (1/10) = 0 ∧ score (-1/10) = 0 ∧
    (1/16:ℝ) < |clippedScore (1/10)-clippedScore (-1/10)| := by
  norm_num [score,Real.sign,clippedScore]

end NeuralGeneralization.MarginBand
