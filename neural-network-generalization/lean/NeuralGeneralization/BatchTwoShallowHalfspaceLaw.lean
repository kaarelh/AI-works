import NeuralGeneralization.BatchTwoShallowRidgeMixture
import NeuralGeneralization.RobustStatistics
import Mathlib.MeasureTheory.Integral.Bochner.SumMeasure

/-! Literal finite halfspace distributions representing the tanh ridges. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoShallow
open ConcreteModel BatchTwoImprovedQuantile

def Halfspace (d : ℕ) := {A : Finset (Cube d) // A ∈ halfspacePatterns (inputVector (d := d))}
deriving Fintype

instance (d : ℕ) : MeasurableSpace (Halfspace d) := ⊤
instance (d : ℕ) : MeasurableSingletonClass (Halfspace d) := ⟨fun _ => trivial⟩

def halfspaceValue {d : ℕ} (h : Halfspace d) (x : Cube d) : ℝ :=
  if x ∈ h.val then 1 else -1

theorem empty_halfspace (d : ℕ) :
    (∅ : Finset (Cube d)) ∈ halfspacePatterns (inputVector (d := d)) := by
  classical
  apply Finset.mem_filter.mpr
  refine ⟨Finset.mem_univ _, fun _ => 0, ?_⟩
  intro x
  simp [dot]

def zeroHalfspace (d : ℕ) : Halfspace d := ⟨∅, empty_halfspace d⟩
instance (d : ℕ) : Nonempty (Halfspace d) := ⟨zeroHalfspace d⟩

def ridgeHalfspace {d : ℕ} (b : Fin (d+1) → ℝ) (u : ℝ) : Halfspace d :=
  if hu : u ∈ Ioo 0 1 then
    ⟨patternSet (ridgePattern b u), ridgePattern_is_halfspace b hu⟩
  else zeroHalfspace d

theorem ridgeHalfspace_value {d : ℕ} (b : Fin (d+1) → ℝ) {u : ℝ}
    (hu : u ∈ Ioo 0 1) (x : Cube d) :
    halfspaceValue (ridgeHalfspace b u) x = labelReal (ridgePattern b u x) := by
  classical
  simp only [ridgeHalfspace, dif_pos hu, halfspaceValue, patternSet,
    Finset.mem_filter, Finset.mem_univ, true_and]
  cases ridgePattern b u x <;> simp [labelReal]

theorem measurable_ridgeHalfspace {d : ℕ} (b : Fin (d+1) → ℝ) :
    Measurable (ridgeHalfspace b) := by
  classical
  apply measurable_to_countable'
  intro h
  have he : ridgeHalfspace b ⁻¹' {h} =
      (Ioo 0 1 ∩ {u | patternSet (ridgePattern b u) = h.val}) ∪
        ((Ioo 0 1)ᶜ ∩ {u : ℝ | zeroHalfspace d = h}) := by
    ext u
    by_cases hu : u ∈ Ioo 0 1
    · simp only [mem_preimage, mem_singleton_iff, ridgeHalfspace, dif_pos hu,
        mem_union, mem_inter_iff, hu, true_and, mem_setOf_eq, mem_compl_iff,
        not_true_eq_false, false_and, or_false]
      exact ⟨fun he => congrArg Subtype.val he, fun he => Subtype.ext he⟩
    · simp [ridgeHalfspace, hu]
  rw [he]
  apply MeasurableSet.union
  · apply measurableSet_Ioo.inter
    have hp : Measurable (fun u => patternSet (ridgePattern b u)) :=
      (measurable_of_finite patternSet).comp (measurable_ridgePattern b)
    exact measurableSet_eq_fun hp measurable_const
  · exact measurableSet_Ioo.compl.inter (by by_cases h : zeroHalfspace d = h <;> simp [h])

def ridgeLaw {d : ℕ} (b : Fin (d+1) → ℝ) : Measure (Halfspace d) :=
  uniformSeed.map (ridgeHalfspace b)

instance {d : ℕ} (b : Fin (d+1) → ℝ) : IsProbabilityMeasure (ridgeLaw b) :=
  Measure.isProbabilityMeasure_map (measurable_ridgeHalfspace b).aemeasurable

theorem ridgeLaw_mean {d : ℕ} (b : Fin (d+1) → ℝ) (x : Cube d) :
    (∫ h, halfspaceValue h x ∂ridgeLaw b) = Real.tanh (dot b (inputVector x)) := by
  rw [ridgeLaw, integral_map (measurable_ridgeHalfspace b).aemeasurable
    (measurable_of_finite (fun h : Halfspace d => halfspaceValue h x)).aestronglyMeasurable]
  rw [← ridgePattern_mean b x]
  apply integral_congr_ae
  filter_upwards [ae_restrict_mem measurableSet_Ioo] with u hu
  exact ridgeHalfspace_value b hu x

theorem ridgeLaw_sum {d : ℕ} (b : Fin (d+1) → ℝ) :
    (∑ h : Halfspace d, (ridgeLaw b).real {h}) = 1 := by
  rw [sum_measureReal_singleton]
  simp

theorem ridgeLaw_mean_finite {d : ℕ} (b : Fin (d+1) → ℝ) (x : Cube d) :
    (∑ h : Halfspace d, (ridgeLaw b).real {h} * halfspaceValue h x) =
      Real.tanh (dot b (inputVector x)) := by
  rw [← ridgeLaw_mean b x, integral_fintype (RobustStatistics.integrable_finite_domain _ _)]
  simp only [smul_eq_mul]

theorem halfspace_card_bound (d : ℕ) :
    Fintype.card (Halfspace d) ≤ (2 ^ d + 1) ^ (d+1) := by
  change Fintype.card {A : Finset (Cube d) // A ∈ halfspacePatterns inputVector} ≤ _
  simpa [Cube] using halfspace_card_le (inputVector (d := d))

end NeuralGeneralization.BatchTwoShallow
