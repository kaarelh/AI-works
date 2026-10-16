import NeuralGeneralization.MeanFieldCertificateExtraction
import NeuralGeneralization.MeanFieldFunctionClass
import NeuralGeneralization.MeanFieldHiddenTail
import NeuralGeneralization.MeanFieldReadoutTail

/-!
# Aggregate function mass from the actual mean-field good event

The full deterministic certificate extraction and tilted-tower compression
place every good global-margin draw in the counted finite class. Disjoint
sign events then convert this into an aggregate parameter-mass inequality.
-/

noncomputable section
open scoped BigOperators
open MeasureTheory
namespace NeuralGeneralization.MeanFieldAggregate
open ConcreteModel MeanFieldBudgets MeanFieldGoodEvent

/-- This is an actual event of the original network weights, using the
proved layer-specific backward budgets and the original linear readout. -/
def goodWeights (d N r K : ℕ) : Set (Weights d N r) :=
  {w | GoodHidden d N r (fun s => (layerBudget r K (s+1) : ℝ)) (K : ℝ) w ∧
    (N : ℝ)*(∑ i, w (.inr (.inr i))^2) ≤ (K : ℝ)}

theorem excluded_mass_le_bad_event {d N r K : ℕ}
    (hd : 0 < d) (hN : 0 < N) (hK : 0 < K)
    (μ : Measure (Weights d N r)) [IsFiniteMeasure μ] :
    (∑ f ∈ Finset.univ \ MeanFieldFunctionClass.functions d r K,
      functionMass Real.tanh (1/2) μ f) ≤ μ.real (goodWeights d N r K)ᶜ := by
  apply MeanFieldFunctionClass.complement_mass_le μ (goodWeights d N r K)
  intro f w hmargin hgood
  exact (MeanFieldFunctionClass.mem_functions f).mp
    (MeanFieldCertificateExtraction.good_network_mem_functions hd hN hK w f hmargin hgood.2 hgood.1)

/-- The complete actual-prior aggregate mass bound, with every probability,
compression and counting ingredient discharged. -/
theorem aggregate_tail (r d : ℕ) (hd : 1 ≤ d) (K : ℕ) (hK : 8 ≤ K)
    (N : ℕ) (hNT : empiricalWidthThreshold d r K ≤ N) :
    (∑ f ∈ Finset.univ \ MeanFieldFunctionClass.functions d r K,
      functionMass Real.tanh (1/2) (powerPrior d N r 1) f) ≤
      ((r : ℝ)+2)*Real.exp (-(N : ℝ)*(K : ℝ)/8) := by
  have hN : 0 < N := by
    have hh : 0 < empiricalWidthThreshold d r K := by
      unfold empiricalWidthThreshold
      omega
    omega
  have hK0 : 0 < K := by omega
  have hKR : (8 : ℝ) ≤ K := by exact_mod_cast hK
  let G : ℕ → ℝ := fun s => (layerBudget r K (s+1) : ℝ)
  have hhidden := MeanFieldHiddenTail.goodHidden_compl_tail (r := r)
    (s := sparseCount r K) (by omega : 0 < d) hN (sparseCount_pos r K) G (K : ℝ)
    (by linarith)
    (fun j hj => by dsimp [G]; exact_mod_cast layerBudget_pos r hK0 (j+1))
    (fun j hj => layerBudget_sq_le_twice_sparseCount r K (show 1 ≤ j+1 by omega))
    (empiricalWidthThreshold_entropy (by omega) hNT)
  have hread := MeanFieldReadoutTail.readout_bad_tail (d := d) (r := r) (by omega) hN (K : ℝ) hKR
  have hset : (goodWeights d N r K)ᶜ =
      {w | ¬GoodHidden d N r G (K : ℝ) w} ∪
      {w | (K : ℝ) < (N : ℝ)*(∑ i, w (.inr (.inr i))^2)} := by
    ext w
    simp only [goodWeights, Set.mem_compl_iff, Set.mem_setOf_eq, Set.mem_union, not_and_or, not_le]
    rfl
  apply (excluded_mass_le_bad_event (by omega) hN hK0 (powerPrior d N r 1)).trans
  rw [hset]
  apply (measureReal_union_le _ _).trans
  calc
    _ ≤ ((r : ℝ)+1)*Real.exp (-(N : ℝ)*(K : ℝ)/8)+
        Real.exp (-(N : ℝ)*(K : ℝ)/8) := add_le_add hhidden hread
    _ = _ := by ring

end NeuralGeneralization.MeanFieldAggregate
