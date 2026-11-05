import NeuralGeneralization.ValidHiddenPath
import NeuralGeneralization.RobustCompressionInductionAlignment
import NeuralGeneralization.RobustCompressionTerminalReadout

/-! Every constructed virtual hidden state is in the activation box, and
this property survives the actual gluing of original-network histories. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustStatistics

lemma initialHistory_ae_valid {d N m r : ℕ} (σ B : ℝ) {φ : ℝ → ℝ}
    (hφ : Continuous φ) (hb : ∀ z,|φ z| ≤ 1) (x : Cube d)
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q] :
    ∀ᵐ z ∂(initialHistory m σ B hφ x Q).joint,validHiddenPath z.1.2 := by
  change ∀ᵐ z ∂Q.map (initialHistoryMap σ B φ x),validHiddenPath z.1.2
  apply (ae_map_iff (measurable_initialHistoryMap σ B hφ x).aemeasurable
    ((measurableSet_validHiddenPath N 0).preimage (by fun_prop))).mpr
  exact Filter.Eventually.of_forall fun w s i => hb _

lemma advanceHistory_ae_valid {d N m r s k : ℕ}
    {φ : ℝ → ℝ} (hφ : Continuous φ) (hb : ∀ z,|φ z| ≤ 1) (x : Cube d)
    {Q : Measure (Weights d N r)}
    {Γ : Measure (ActivePrefix d N m s × FutureWeights N (k+1))}
    {Γ' : Measure (ActivePrefix d N m (s+1) × FutureWeights N k)}
    (P : CanonicalHistoryComparison Q Γ
      (Prod.fst : OriginalHistory d N r s → Weights d N r))
    (R : ProbabilityCoupling Γ Γ')
    (hvalid : ∀ᵐ z ∂P.joint,validHiddenPath z.1.2) :
    ∀ᵐ z ∂(advanceHistory P R (appendOriginalHistory φ x)
      (measurable_appendOriginalHistory hφ x) measurable_fst measurable_fst
      (appendOriginalHistory_original φ x)).joint,validHiddenPath z.1.2 := by
  apply advanceHistory_ae P R (appendOriginalHistory φ x)
    (measurable_appendOriginalHistory hφ x) measurable_fst measurable_fst
    (appendOriginalHistory_original φ x)
    (fun z => validHiddenPath z.1.2) (fun _ => True) (fun z => validHiddenPath z.1.2)
    ((measurableSet_validHiddenPath N (s+1)).preimage (by fun_prop)) hvalid
    (Filter.Eventually.of_forall fun _ => True.intro)
  intro h old next hh _
  exact validHiddenPath_append hh (activeHidden_bounded φ hb next.1 x)

end NeuralGeneralization.RobustCompressionInduction
