import NeuralGeneralization.BatchTwoShallowMixture
import NeuralGeneralization.FunctionPriorFacts
import Mathlib.MeasureTheory.Integral.Prod

/-! Measurability of the explicitly constructed halfspace weights. This is
needed when the sampling distribution is averaged over a neural posterior. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoShallow
open ConcreteModel BatchTwoImprovedQuantile

theorem measurable_ridgePattern_joint (d : ℕ) :
    Measurable (fun p : (Fin (d+1) → ℝ) × ℝ => ridgePattern p.1 p.2) := by
  apply measurable_pi_lambda
  intro x
  have he : (fun p : (Fin (d+1) → ℝ) × ℝ => ridgePattern p.1 p.2 x) =
      (fun p => if p.2 < (1 + Real.tanh (dot p.1 (inputVector x))) / 2 then true else false) := rfl
  rw [he]
  apply Measurable.ite
  · apply measurableSet_lt measurable_snd
    exact ((tanh_continuous.measurable.comp (show Measurable
      (fun p : (Fin (d+1) → ℝ) × ℝ => dot p.1 (inputVector x)) by unfold dot; fun_prop)).const_add 1).div_const 2
  · exact measurable_const
  · exact measurable_const

theorem measurable_ridgeHalfspace_joint (d : ℕ) :
    Measurable (fun p : (Fin (d+1) → ℝ) × ℝ => ridgeHalfspace p.1 p.2) := by
  classical
  apply measurable_to_countable'
  intro h
  have he : (fun p : (Fin (d+1) → ℝ) × ℝ => ridgeHalfspace p.1 p.2) ⁻¹' {h} =
      ({p | p.2 ∈ Ioo 0 1} ∩ {p | patternSet (ridgePattern p.1 p.2) = h.val}) ∪
        ({p | p.2 ∈ Ioo 0 1}ᶜ ∩ {p | zeroHalfspace d = h}) := by
    ext p
    by_cases hu : p.2 ∈ Ioo 0 1
    · simp only [mem_preimage, mem_singleton_iff, ridgeHalfspace,
        mem_union, mem_inter_iff, hu, true_and, mem_setOf_eq, mem_compl_iff,
        not_true_eq_false, false_and, or_false, dite_true]
      exact ⟨fun he => congrArg Subtype.val he, fun he => Subtype.ext he⟩
    · simp only [mem_preimage, mem_singleton_iff, ridgeHalfspace, dif_neg hu,
        mem_union, mem_inter_iff, mem_setOf_eq, hu, false_and, mem_compl_iff,
        not_false_eq_true, true_and, false_or, dite_false]
  rw [he]
  have hu : MeasurableSet {p : (Fin (d+1) → ℝ) × ℝ | p.2 ∈ Ioo 0 1} :=
    measurable_snd measurableSet_Ioo
  apply MeasurableSet.union
  · apply hu.inter
    have hp := (measurable_of_finite (patternSet (d := d))).comp (measurable_ridgePattern_joint d)
    exact measurableSet_eq_fun hp measurable_const
  · exact hu.compl.inter (by by_cases he : zeroHalfspace d = h <;> simp [he])

theorem measurable_ridgeWeight {d : ℕ} (h : Halfspace d) :
    Measurable (fun b : Fin (d+1) → ℝ => (ridgeLaw b).real {h}) := by
  have he : (fun b : Fin (d+1) → ℝ => (ridgeLaw b).real {h}) =
      (fun b => (uniformSeed {u | ridgeHalfspace b u = h}).toReal) := by
    funext b
    rw [ridgeLaw, Measure.real, Measure.map_apply (measurable_ridgeHalfspace b)
      (measurableSet_singleton h)]
    rfl
  rw [he]
  exact (measurable_measure_prodMk_left_finite
    (measurableSet_eq_fun (measurable_ridgeHalfspace_joint d) measurable_const)).ennreal_toReal

theorem measurable_signedRow {d N : ℕ} (a : SparseAtoms.Atom (Fin N)) :
    Measurable (fun b : Fin N → Fin (d+1) → ℝ => signedRow b a) := by
  cases a with
  | none => exact measurable_const
  | some p =>
    rcases p with ⟨i, s⟩
    cases s <;> simp only [signedRow, Bool.false_eq_true, ite_false, ite_true] <;> fun_prop

theorem measurable_mixtureWeight {d N : ℕ} (B : ℝ) (h : Halfspace d) :
    Measurable (fun p : (Fin N → Fin (d+1) → ℝ) × (Fin N → ℝ) =>
      mixtureWeight B p.1 p.2 h) := by
  unfold mixtureWeight
  apply Finset.measurable_sum
  intro a _
  apply Measurable.mul
  · cases a with
    | none =>
      simp only [SparseAtoms.weight, BoundedDual.entryL1]
      fun_prop
    | some p =>
      rcases p with ⟨i, s⟩
      cases s <;> simp only [SparseAtoms.weight, Bool.false_eq_true, ite_false, ite_true] <;> fun_prop
  · exact (measurable_ridgeWeight h).comp ((measurable_signedRow a).comp measurable_fst)

end NeuralGeneralization.BatchTwoShallow
