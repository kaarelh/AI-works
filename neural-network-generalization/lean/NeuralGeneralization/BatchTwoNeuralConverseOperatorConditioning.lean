import NeuralGeneralization.BatchTwoNeuralConverseOperatorPriorLimit
import NeuralGeneralization.BatchTwoNeuralConverseConditioning

/-! Equality between parameter conditioning and the finite sign-function posterior. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open Classical Set MeasureTheory ProbabilityTheory
open ConcreteModel
variable {d N r : ℕ}

def operator_trainingCell (U : ℝ) (f : BooleanFunction d) (A : Finset (Cube d))
    (g : BooleanFunction d) : Set (Weights d N r) :=
  if Fits g f A then operatorFunctionSupport U g else ∅

theorem operator_trainingCell_open (U : ℝ) (f : BooleanFunction d) (A : Finset (Cube d))
    (g : BooleanFunction d) : IsOpen (operator_trainingCell (N := N) (r := r) U f A g) := by
  unfold operator_trainingCell
  split_ifs
  · exact isOpen_operatorFunctionSupport U g
  · exact isOpen_empty

theorem operator_trainingCell_disjoint (U : ℝ) (f : BooleanFunction d) (A : Finset (Cube d))
    (g h : BooleanFunction d) (hgh : g≠h) :
    Disjoint (operator_trainingCell (N := N) (r := r) U f A g) (operator_trainingCell U f A h) := by
  unfold operator_trainingCell
  split_ifs <;> try simp only [disjoint_empty,empty_disjoint]
  exact (marginEvents_disjoint Real.tanh (by norm_num : (0 : ℝ)≤1/2) hgh).mono inter_subset_right inter_subset_right

theorem operator_trainingCell_union (U : ℝ) (f : BooleanFunction d) (A : Finset (Cube d)) :
    (⋃ g,operator_trainingCell (N := N) (r := r) U f A g)=operatorSupport U ∩ signTraining f A := by
  ext w
  simp only [mem_iUnion,mem_inter_iff]
  constructor
  · rintro ⟨g,hg⟩
    by_cases hfit : Fits g f A
    · have hw : w ∈ operatorFunctionSupport U g := by simpa [operator_trainingCell,hfit] using hg
      exact ⟨hw.1,training_of_fits_margin hw.2 hfit⟩
    · simp [operator_trainingCell,hfit] at hg
  · rintro ⟨hw,ht⟩
    have habs : w ∈ globalMarginEvent Real.tanh (1/2) := fun x => (hw.1 x).1
    rw [globalMarginEvent_eq_iUnion] at habs
    obtain ⟨g,hg⟩ := mem_iUnion.mp habs
    have hf := fits_of_training_margin hg ht
    refine ⟨g,?_⟩
    simpa only [operator_trainingCell,if_pos hf] using (show w ∈ operatorFunctionSupport U g from ⟨hw,hg⟩)

theorem operator_training_function_inter (U : ℝ) (f g : BooleanFunction d) (A : Finset (Cube d)) :
    (operatorSupport U ∩ signTraining (N := N) (r := r) f A) ∩ operatorFunctionSupport U g=
      operator_trainingCell U f A g := by
  by_cases hfit : Fits g f A
  · simp only [operator_trainingCell,if_pos hfit]
    apply inter_eq_right.mpr
    intro w hw
    exact ⟨hw.1,training_of_fits_margin hw.2 hfit⟩
  · simp only [operator_trainingCell,if_neg hfit]
    apply eq_empty_iff_forall_notMem.mpr
    rintro w ⟨ht,hw⟩
    exact hfit (fits_of_training_margin hw.2 ht.2)

theorem operator_functionPosterior_eq_parameter_posterior (σ U : ℝ)
    (f g : BooleanFunction d) (A : Finset (Cube d)) :
    operator_functionPosterior N r σ U f A g=
      (operatorPosterior (N := N) (r := r) σ U f A).real (operatorFunctionSupport U g) := by
  have hsum : (∑ h : BooleanFunction d, (smallPrior d N r σ).real (operator_trainingCell U f A h))=
      (smallPrior d N r σ).real (operatorSupport U ∩ signTraining (N := N) (r := r) f A) := by
    rw [←operator_trainingCell_union U f A]
    unfold Measure.real
    rw [measure_iUnion (operator_trainingCell_disjoint U f A)
      (fun g => (operator_trainingCell_open U f A g).measurableSet),tsum_fintype,
      ENNReal.toReal_sum (fun g _ => measure_ne_top _ _)]
  have hcell (g : BooleanFunction d) : (smallPrior d N r σ).real (operator_trainingCell U f A g)=
      if Fits g f A then operator_restrictedFunctionMass N r σ U g else 0 := by
    by_cases hg : Fits g f A <;> simp [operator_trainingCell,hg,operator_restrictedFunctionMass]
  simp_rw [hcell] at hsum
  unfold operator_functionPosterior NeuralGeneralization.posterior NeuralGeneralization.normalizer
  rw [hsum]
  unfold operatorPosterior operatorPrior
  rw [cond_cond_eq_cond_inter (isOpen_operatorSupport U).measurableSet (isOpen_signTraining f A).measurableSet]
  unfold Measure.real
  rw [cond_apply' (isOpen_operatorFunctionSupport U g).measurableSet,operator_training_function_inter]
  rw [ENNReal.toReal_mul,ENNReal.toReal_inv]
  change _ = ((smallPrior d N r σ).real (operatorSupport U ∩ signTraining f A))⁻¹*
    (smallPrior d N r σ).real (operator_trainingCell U f A g)
  rw [hcell]
  simp only [Measure.real]
  ring

end
end NeuralGeneralization.BatchTwoNeuralConverse
