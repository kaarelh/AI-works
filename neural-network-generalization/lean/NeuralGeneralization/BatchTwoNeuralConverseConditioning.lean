import NeuralGeneralization.BatchTwoNeuralConversePriorLimit

/-! Equality between parameter conditioning and the finite sign-function posterior. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open Classical Set MeasureTheory ProbabilityTheory
open ConcreteModel
variable {d N r : ℕ}

theorem isOpen_signTraining (f : BooleanFunction d) (A : Finset (Cube d)) :
    IsOpen (signTraining (N := N) (r := r) f A) := by
  unfold signTraining
  simp only [setOf_forall]
  apply isOpen_iInter_of_finite
  intro x
  by_cases hx : x∈A
  · simp only [hx,iInter_true]
    exact isOpen_lt continuous_const ((continuous_networkOutput tanh_continuous x).const_mul _)
  · simp [hx]

theorem fits_of_training_margin {f g : BooleanFunction d} {A : Finset (Cube d)}
    {w : Weights d N r} (hw : w ∈ marginEvent Real.tanh (1/2) g)
    (ht : w ∈ signTraining f A) : Fits g f A := by
  intro x hx
  have hg := hw x
  have hf := ht x hx
  cases hgx : g x <;> cases hfx : f x <;> simp_all [labelReal] <;> linarith

theorem training_of_fits_margin {f g : BooleanFunction d} {A : Finset (Cube d)}
    {w : Weights d N r} (hw : w ∈ marginEvent Real.tanh (1/2) g)
    (hf : Fits g f A) : w ∈ signTraining f A := by
  intro x hx
  have h := hw x
  rw [hf x hx] at h
  linarith

def trainingCell (Λ U : ℝ) (f : BooleanFunction d) (A : Finset (Cube d))
    (g : BooleanFunction d) : Set (Weights d N r) :=
  if Fits g f A then functionSupport Λ U g else ∅

theorem trainingCell_open (Λ U : ℝ) (f : BooleanFunction d) (A : Finset (Cube d))
    (g : BooleanFunction d) : IsOpen (trainingCell (N := N) (r := r) Λ U f A g) := by
  unfold trainingCell
  split_ifs
  · exact isOpen_functionSupport Λ U g
  · exact isOpen_empty

theorem trainingCell_disjoint (Λ U : ℝ) (f : BooleanFunction d) (A : Finset (Cube d))
    (g h : BooleanFunction d) (hgh : g≠h) :
    Disjoint (trainingCell (N := N) (r := r) Λ U f A g) (trainingCell Λ U f A h) := by
  unfold trainingCell
  split_ifs <;> try simp only [disjoint_empty,empty_disjoint]
  exact (marginEvents_disjoint Real.tanh (by norm_num : (0 : ℝ)≤1/2) hgh).mono inter_subset_right inter_subset_right

theorem trainingCell_union (Λ U : ℝ) (f : BooleanFunction d) (A : Finset (Cube d)) :
    (⋃ g,trainingCell (N := N) (r := r) Λ U f A g)=gainSupport Λ U ∩ signTraining f A := by
  ext w
  simp only [mem_iUnion,mem_inter_iff]
  constructor
  · rintro ⟨g,hg⟩
    by_cases hfit : Fits g f A
    · have hw : w ∈ functionSupport Λ U g := by simpa [trainingCell,hfit] using hg
      exact ⟨hw.1,training_of_fits_margin hw.2 hfit⟩
    · simp [trainingCell,hfit] at hg
  · rintro ⟨hw,ht⟩
    have habs : w ∈ globalMarginEvent Real.tanh (1/2) := fun x => (hw.1 x).1
    rw [globalMarginEvent_eq_iUnion] at habs
    obtain ⟨g,hg⟩ := mem_iUnion.mp habs
    have hf := fits_of_training_margin hg ht
    refine ⟨g,?_⟩
    simpa only [trainingCell,if_pos hf] using (show w ∈ functionSupport Λ U g from ⟨hw,hg⟩)

theorem training_function_inter (Λ U : ℝ) (f g : BooleanFunction d) (A : Finset (Cube d)) :
    (gainSupport Λ U ∩ signTraining (N := N) (r := r) f A) ∩ functionSupport Λ U g=
      trainingCell Λ U f A g := by
  by_cases hfit : Fits g f A
  · simp only [trainingCell,if_pos hfit]
    apply inter_eq_right.mpr
    intro w hw
    exact ⟨hw.1,training_of_fits_margin hw.2 hfit⟩
  · simp only [trainingCell,if_neg hfit]
    apply eq_empty_iff_forall_notMem.mpr
    rintro w ⟨ht,hw⟩
    exact hfit (fits_of_training_margin hw.2 ht.2)

theorem functionPosterior_eq_parameter_posterior (σ Λ U : ℝ)
    (f g : BooleanFunction d) (A : Finset (Cube d)) :
    functionPosterior N r σ Λ U f A g=
      (posterior (N := N) (r := r) σ Λ U f A).real (functionSupport Λ U g) := by
  have hsum : (∑ h : BooleanFunction d, (smallPrior d N r σ).real (trainingCell Λ U f A h))=
      (smallPrior d N r σ).real (gainSupport Λ U ∩ signTraining (N := N) (r := r) f A) := by
    rw [←trainingCell_union Λ U f A]
    unfold Measure.real
    rw [measure_iUnion (trainingCell_disjoint Λ U f A)
      (fun g => (trainingCell_open Λ U f A g).measurableSet),tsum_fintype,
      ENNReal.toReal_sum (fun g _ => measure_ne_top _ _)]
  have hcell (g : BooleanFunction d) : (smallPrior d N r σ).real (trainingCell Λ U f A g)=
      if Fits g f A then restrictedFunctionMass N r σ Λ U g else 0 := by
    by_cases hg : Fits g f A <;> simp [trainingCell,hg,restrictedFunctionMass]
  simp_rw [hcell] at hsum
  unfold functionPosterior NeuralGeneralization.posterior NeuralGeneralization.normalizer
  rw [hsum]
  unfold posterior restrictedPrior
  rw [cond_cond_eq_cond_inter (isOpen_gainSupport Λ U).measurableSet (isOpen_signTraining f A).measurableSet]
  unfold Measure.real
  rw [cond_apply' (isOpen_functionSupport Λ U g).measurableSet,training_function_inter]
  rw [ENNReal.toReal_mul,ENNReal.toReal_inv]
  change _ = ((smallPrior d N r σ).real (gainSupport Λ U ∩ signTraining f A))⁻¹*
    (smallPrior d N r σ).real (trainingCell Λ U f A g)
  rw [hcell]
  simp only [Measure.real]
  ring

end
end NeuralGeneralization.BatchTwoNeuralConverse
