import NeuralGeneralization.RobustPredictionComparison

/-! The exact two-margin transport levels and the unchanged ramp loss. -/
noncomputable section
open MeasureTheory
namespace NeuralGeneralization.TwoMarginTransport
open ConcreteModel RobustStatistics

lemma clippedScore_neg (z : ℝ) : clippedScore (-z) = -clippedScore z := by
  simp only [clippedScore,max_def,min_def]
  split_ifs <;> linarith

lemma signed_clippedScore (b : Bool) (z : ℝ) :
    clippedScore (labelReal b*z) = labelReal b*clippedScore z := by
  cases b
  · simpa only [labelReal_false,neg_one_mul] using clippedScore_neg z
  · simp

lemma le_clippedScore_iff {a z : ℝ} (ha : -(1/2:ℝ) < a) (ha1 : a ≤ 1/2) :
    a ≤ clippedScore z ↔ a ≤ z := by
  simp only [clippedScore,le_max_iff,le_min_iff,not_le_of_gt ha,ha1,false_or,true_and]

lemma clippedScore_le_iff {a z : ℝ} (ha : -(1/2:ℝ) ≤ a) (ha1 : a < 1/2) :
    clippedScore z ≤ a ↔ z ≤ a := by
  simp only [clippedScore,max_le_iff,min_le_iff,ha,not_le_of_gt ha1,false_or,true_and]

/-- Raw-output margins after successful compression. -/
def good (z a : ℝ) : Prop := ∀ b : Bool,
  ((1/2:ℝ) < labelReal b*z → 5/12 ≤ labelReal b*a) ∧
  (labelReal b*z ≤ (1/4:ℝ) → labelReal b*a ≤ 1/3)

lemma measurable_good : MeasurableSet {p : ℝ × ℝ | good p.1 p.2} := by
  have heq : {p : ℝ × ℝ | good p.1 p.2} = ⋂ b : Bool,
      ({p | labelReal b*p.1 ≤ (1/2:ℝ)} ∪ {p | (5/12:ℝ) ≤ labelReal b*p.2}) ∩
      ({p | (1/4:ℝ) < labelReal b*p.1} ∪ {p | labelReal b*p.2 ≤ (1/3:ℝ)}) := by
    ext p
    simp only [good,Set.mem_iInter,Set.mem_inter_iff,Set.mem_union,Set.mem_setOf_eq,
      imp_iff_not_or,not_lt,not_le]
  rw [heq]
  exact MeasurableSet.iInter fun b =>
    ((measurableSet_le (measurable_fst.const_mul _) measurable_const).union
      (measurableSet_le measurable_const (measurable_snd.const_mul _))).inter
    ((measurableSet_lt measurable_const (measurable_fst.const_mul _)).union
      (measurableSet_le (measurable_snd.const_mul _) measurable_const))

def rule : PredictionComparison (1/2) (1/4) where
  good := good
  measurable_good := measurable_good
  loss b a := marginRamp (labelReal b*clippedScore a)
  measurable_loss b := measurable_marginRamp.comp (measurable_clippedScore.const_mul _)
  loss_bounds b a := marginRamp_bounds _
  training b z a hz hg := by
    apply marginRamp_eq_zero
    rw [← signed_clippedScore]
    exact (le_clippedScore_iff (by norm_num : -(1/2:ℝ)<5/12) (by norm_num)).mpr ((hg b).1 hz)
  test b z a hz hg := by
    apply marginRamp_eq_one
    rw [← signed_clippedScore]
    exact (clippedScore_le_iff (by norm_num : -(1/2:ℝ)≤1/3) (by norm_num)).mpr ((hg b).2 hz)

lemma good_of_score_close {z a : ℝ} (hclose : |clippedScore a-clippedScore z| ≤ 1/12) : good z a := by
  intro b
  have habs : |labelReal b*clippedScore a-labelReal b*clippedScore z| ≤ 1/12 := by
    simpa only [← mul_sub,abs_mul,abs_labelReal,one_mul] using hclose
  have hh := abs_le.mp habs
  constructor
  · intro hz
    have hclip : labelReal b*clippedScore z = 1/2 := by
      rw [← signed_clippedScore]
      unfold clippedScore
      rw [min_eq_left hz.le,max_eq_right (by norm_num)]
    rw [← le_clippedScore_iff (by norm_num : -(1/2:ℝ)<5/12) (by norm_num),signed_clippedScore]
    linarith
  · intro hz
    have hclip := signed_clippedScore_le_quarter b z hz
    rw [← clippedScore_le_iff (by norm_num : -(1/2:ℝ)≤1/3) (by norm_num),signed_clippedScore]
    linarith

lemma good_of_raw_close {z a : ℝ} (hclose : |a-z| ≤ 1/12) : good z a :=
  good_of_score_close ((clippedScore_lipschitz a z).trans hclose)

/-- The manuscript's exact rounding calculation: 7/16-1/48=5/12 and
5/16+1/48=1/3. -/
theorem good_of_transport_and_rounding {z z' a : ℝ}
    (htransport : ∀ b : Bool,
      ((1/2:ℝ) ≤ labelReal b*z → 7/16 ≤ labelReal b*z') ∧
      (labelReal b*z ≤ (1/4:ℝ) → labelReal b*z' ≤ 5/16))
    (hround : |a-z'| ≤ 1/48) : good z a := by
  intro b
  have habs : |labelReal b*a-labelReal b*z'| ≤ 1/48 := by
    simpa only [← mul_sub,abs_mul,abs_labelReal,one_mul] using hround
  have hh := abs_le.mp habs
  constructor
  · intro hz
    linarith [(htransport b).1 hz.le]
  · intro hz
    linarith [(htransport b).2 hz]

end NeuralGeneralization.TwoMarginTransport
