import NeuralGeneralization.GeneralMarginComparison

/-! Two-level transport across arbitrary training/test margins, including the
paper's exact residual-gap calculation for an arbitrary rounding error. -/
noncomputable section
open MeasureTheory
namespace NeuralGeneralization.GeneralTwoMargin
open ConcreteModel RobustStatistics

def gap (m u θ : ℝ) : ℝ := m-u-2*θ

structure Parameters (m u θ : ℝ) : Prop where
  train_pos : 0 < m
  test_nonneg : 0 ≤ u
  tolerance_nonneg : 0 ≤ θ
  gap_pos : 0 < gap m u θ

/-- Successful comparison after rounding by e, with the literal four levels. -/
def good (m u θ e z a : ℝ) : Prop := ∀ b : Bool,
  (m < labelReal b*z → m-θ-e ≤ labelReal b*a) ∧
  (labelReal b*z ≤ u → labelReal b*a ≤ u+θ+e)

lemma measurable_good (m u θ e : ℝ) : MeasurableSet {p : ℝ × ℝ | good m u θ e p.1 p.2} := by
  have heq : {p : ℝ × ℝ | good m u θ e p.1 p.2} = ⋂ b : Bool,
      ({p | labelReal b*p.1 ≤ m} ∪ {p | m-θ-e ≤ labelReal b*p.2}) ∩
      ({p | u < labelReal b*p.1} ∪ {p | labelReal b*p.2 ≤ u+θ+e}) := by
    ext p
    simp only [good,Set.mem_iInter,Set.mem_inter_iff,Set.mem_union,Set.mem_setOf_eq,
      imp_iff_not_or,not_lt,not_le]
  rw [heq]
  exact MeasurableSet.iInter fun b =>
    ((measurableSet_le (measurable_fst.const_mul _) measurable_const).union
      (measurableSet_le measurable_const (measurable_snd.const_mul _))).inter
    ((measurableSet_lt measurable_const (measurable_fst.const_mul _)).union
      (measurableSet_le (measurable_snd.const_mul _) measurable_const))

/-- Any positive residual gap m-u-2θ-2e permits the asserted bounded ramp. -/
def ruleForError (m u θ e : ℝ) (hgap : 0 < m-u-2*θ-2*e) : PredictionComparison m u where
  good := good m u θ e
  measurable_good := measurable_good m u θ e
  loss b a := separatedRamp (u+θ+e) (m-θ-e) (labelReal b*a)
  measurable_loss b := (continuous_separatedRamp _ _).measurable.comp (measurable_id.const_mul _)
  loss_bounds b a := separatedRamp_bounds _ _ _
  training b z a hz hg := separatedRamp_eq_zero (by linarith) ((hg b).1 hz)
  test b z a hz hg := separatedRamp_eq_one (by linarith) ((hg b).2 hz)

/-- Exact arbitrary-rounding-error transfer, independent of the later choice
of finite-grid resolution. -/
theorem good_of_transport_and_rounding {m u θ e z z' a : ℝ}
    (htransport : ∀ b : Bool,
      (m ≤ labelReal b*z → m-θ ≤ labelReal b*z') ∧
      (labelReal b*z ≤ u → labelReal b*z' ≤ u+θ))
    (hround : |a-z'| ≤ e) : good m u θ e z a := by
  intro b
  have hh := abs_le.mp (show |labelReal b*a-labelReal b*z'| ≤ e by
    simpa only [← mul_sub,abs_mul,abs_labelReal,one_mul] using hround)
  constructor
  · intro hz
    linarith [(htransport b).1 hz.le]
  · intro hz
    linarith [(htransport b).2 hz]

namespace Parameters
variable {m u θ : ℝ} (h : Parameters m u θ)
include h

lemma test_lt_train : u < m := by
  have hg := h.gap_pos
  have ht := h.tolerance_nonneg
  dsimp [gap] at hg
  linarith

lemma ramp_gap : 0 < m-u-2*θ-2*(gap m u θ/3) := by
  have hg := h.gap_pos
  dsimp [gap] at *
  linarith

def rule : PredictionComparison m u := ruleForError m u θ (gap m u θ/3) h.ramp_gap

lemma good_of_raw_close {z a : ℝ} (hclose : |a-z| ≤ gap m u θ/3) : h.rule.good z a := by
  intro b
  have hh := abs_le.mp (show |labelReal b*a-labelReal b*z| ≤ gap m u θ/3 by
    simpa only [← mul_sub,abs_mul,abs_labelReal,one_mul] using hclose)
  have ht := h.tolerance_nonneg
  constructor <;> intro hz <;> linarith

lemma good_of_noisy_comparison {z z' a radius : ℝ}
    (htransport : ∀ b : Bool,
      (m ≤ labelReal b*z → m-θ ≤ labelReal b*z') ∧
      (labelReal b*z ≤ u → labelReal b*z' ≤ u+θ))
    (hround : |a-z'| ≤ radius/8) (hr : radius ≤ 2*gap m u θ/3) : h.rule.good z a := by
  apply good_of_transport_and_rounding htransport
  have hg := h.gap_pos
  linarith

end Parameters
end NeuralGeneralization.GeneralTwoMargin
