import NeuralGeneralization.RobustCouplingStoppedPath
import NeuralGeneralization.RobustCompressionInductionHistory

/-! # Live-cost and abort accumulation through actual history gluing -/
noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped ENNReal
namespace NeuralGeneralization.RobustCompressionInduction
open RobustStatistics

variable {W U V S T : Type*} [MeasurableSpace W] [MeasurableSpace U]
  [MeasurableSpace V] [MeasurableSpace S] [MeasurableSpace T]
  [StandardBorelSpace T] [Nonempty T]

theorem advanceHistory_success_cost_le {Q : Measure W} {Γ : Measure S} {Γ' : Measure T}
    {original : U → W} {original' : V → W}
    (P : CanonicalHistoryComparison Q Γ original) (R : ProbabilityCoupling Γ Γ')
    (update : U → S → T → V)
    (hupdate : Measurable (fun z : (U × S) × T => update z.1.1 z.1.2 z.2))
    (horiginal : Measurable original) (horiginal' : Measurable original')
    (hpreserve : ∀ u s t, original' (update u s t) = original u)
    (oldGood : Set (U × S)) (localGood : Set (S × T)) (newGood : Set (V × T))
    (hOldGood : MeasurableSet oldGood) (hLocalGood : MeasurableSet localGood)
    (hNewGood : MeasurableSet newGood)
    (oldCost : U × S → ℝ≥0∞) (localCost : S × T → ℝ≥0∞) (newCost : V × T → ℝ≥0∞)
    (hOld : Measurable oldCost) (hLocal : Measurable localCost) (hNew : Measurable newCost)
    (hlive : ∀ u s t, (update u s t,t) ∈ newGood → (u,s) ∈ oldGood ∧ (s,t) ∈ localGood)
    (hcost : ∀ u s t, (update u s t,t) ∈ newGood →
      newCost (update u s t,t) ≤ oldCost (u,s)+localCost (s,t))
    {a b : ℝ≥0∞}
    (hOldBound : (∫⁻ z, oldGood.indicator oldCost z ∂P.joint) ≤ a)
    (hLocalBound : (∫⁻ z, localGood.indicator localCost z ∂R.joint) ≤ b) :
    (∫⁻ z, newGood.indicator newCost z
      ∂(advanceHistory P R update hupdate horiginal horiginal' hpreserve).joint) ≤ a+b := by
  apply advanceHistory_cost_le P R update hupdate horiginal horiginal' hpreserve
    (oldGood.indicator oldCost) (localGood.indicator localCost) (newGood.indicator newCost)
    (hOld.indicator hOldGood) (hLocal.indicator hLocalGood) (hNew.indicator hNewGood)
    _ hOldBound hLocalBound
  intro u s t
  by_cases hg : (update u s t,t) ∈ newGood
  · rw [indicator_of_mem hg, indicator_of_mem (hlive u s t hg).1,
      indicator_of_mem (hlive u s t hg).2]
    exact hcost u s t hg
  · rw [indicator_of_notMem hg]
    exact zero_le

/-- An absorbing failure flag contributes only its probability. It does not
enter the success-weighted squared-error recurrence above. -/
theorem advanceHistory_abort_le {Q : Measure W} {Γ : Measure S} {Γ' : Measure T}
    {original : U → W} {original' : V → W}
    (P : CanonicalHistoryComparison Q Γ original) (R : ProbabilityCoupling Γ Γ')
    (update : U → S → T → V)
    (hupdate : Measurable (fun z : (U × S) × T => update z.1.1 z.1.2 z.2))
    (horiginal : Measurable original) (horiginal' : Measurable original')
    (hpreserve : ∀ u s t, original' (update u s t) = original u)
    (oldBad : Set (U × S)) (localBad : Set (S × T)) (newBad : Set (V × T))
    (hOldBad : MeasurableSet oldBad) (hLocalBad : MeasurableSet localBad)
    (hNewBad : MeasurableSet newBad)
    (hbad : ∀ u s t, (update u s t,t) ∈ newBad → (u,s) ∈ oldBad ∨ (s,t) ∈ localBad)
    {a b : ℝ≥0∞} (hOldBound : P.joint oldBad ≤ a) (hLocalBound : R.joint localBad ≤ b) :
    (advanceHistory P R update hupdate horiginal horiginal' hpreserve).joint newBad ≤ a+b := by
  have h := advanceHistory_cost_le P R update hupdate horiginal horiginal' hpreserve
    (oldBad.indicator (fun _ => (1 : ℝ≥0∞)))
    (localBad.indicator (fun _ => (1 : ℝ≥0∞)))
    (newBad.indicator (fun _ => (1 : ℝ≥0∞)))
    (measurable_const.indicator hOldBad) (measurable_const.indicator hLocalBad)
    (measurable_const.indicator hNewBad) (a := a) (b := b)
    (by
      intro u s t
      by_cases hn : (update u s t,t) ∈ newBad
      · rw [indicator_of_mem hn]
        rcases hbad u s t hn with ho | hl
        · rw [indicator_of_mem ho]
          exact le_add_right le_rfl
        · rw [indicator_of_mem hl]
          exact le_add_left le_rfl
      · rw [indicator_of_notMem hn]
        exact zero_le)
    (by simpa only [lintegral_indicator_const hOldBad, one_mul] using hOldBound)
    (by simpa only [lintegral_indicator_const hLocalBad, one_mul] using hLocalBound)
  simpa only [lintegral_indicator_const hNewBad, one_mul] using h



/-- An almost-everywhere recurrence is sufficient: the invariant identifying
original weights and canonical future is itself a support property. -/
theorem advanceHistory_cost_le_ae {Q : Measure W} {Γ : Measure S} {Γ' : Measure T}
    {original : U → W} {original' : V → W}
    (P : CanonicalHistoryComparison Q Γ original) (R : ProbabilityCoupling Γ Γ')
    (update : U → S → T → V)
    (hupdate : Measurable (fun z : (U × S) × T => update z.1.1 z.1.2 z.2))
    (horiginal : Measurable original) (horiginal' : Measurable original')
    (hpreserve : ∀ u s t, original' (update u s t) = original u)
    (oldCost : U × S → ℝ≥0∞) (localCost : S × T → ℝ≥0∞)
    (newCost : V × T → ℝ≥0∞)
    (hOld : Measurable oldCost) (hLocal : Measurable localCost) (hNew : Measurable newCost)
    (hcost : ∀ᵐ z ∂RobustCompression.glue P.joint R.joint,
      newCost (update z.1.1 z.1.2 z.2,z.2) ≤ oldCost z.1+localCost (z.1.2,z.2))
    {a b : ℝ≥0∞}
    (hOldBound : (∫⁻ z, oldCost z ∂P.joint) ≤ a)
    (hLocalBound : (∫⁻ z, localCost z ∂R.joint) ≤ b) :
    (∫⁻ z, newCost z ∂(advanceHistory P R update hupdate horiginal horiginal' hpreserve).joint)
      ≤ a+b := by
  change (∫⁻ z, newCost z ∂(RobustCompression.glue P.joint R.joint).map
    (fun z => (update z.1.1 z.1.2 z.2,z.2))) ≤ _
  rw [lintegral_map hNew (hupdate.prodMk measurable_snd)]
  apply le_trans (lintegral_mono_ae hcost)
  exact lintegral_glue_cost_le P.joint R.joint
    (P.state_marginal.trans R.left.symm) oldCost localCost hOld hLocal hOldBound hLocalBound

/-- Pull back old and one-step support invariants along the two exact gluing
marginals, then integrate a recurrence valid on their intersection. -/
theorem advanceHistory_cost_le_on_support {Q : Measure W} {Γ : Measure S} {Γ' : Measure T}
    {original : U → W} {original' : V → W}
    (P : CanonicalHistoryComparison Q Γ original) (R : ProbabilityCoupling Γ Γ')
    (update : U → S → T → V)
    (hupdate : Measurable (fun z : (U × S) × T => update z.1.1 z.1.2 z.2))
    (horiginal : Measurable original) (horiginal' : Measurable original')
    (hpreserve : ∀ u s t, original' (update u s t) = original u)
    (oldCost : U × S → ℝ≥0∞) (localCost : S × T → ℝ≥0∞)
    (newCost : V × T → ℝ≥0∞)
    (hOld : Measurable oldCost) (hLocal : Measurable localCost) (hNew : Measurable newCost)
    (oldInvariant : U × S → Prop) (localInvariant : S × T → Prop)
    (hOldInv : ∀ᵐ z ∂P.joint, oldInvariant z)
    (hLocalInv : ∀ᵐ z ∂R.joint, localInvariant z)
    (hcost : ∀ u s t, oldInvariant (u,s) → localInvariant (s,t) →
      newCost (update u s t,t) ≤ oldCost (u,s)+localCost (s,t))
    {a b : ℝ≥0∞}
    (hOldBound : (∫⁻ z, oldCost z ∂P.joint) ≤ a)
    (hLocalBound : (∫⁻ z, localCost z ∂R.joint) ≤ b) :
    (∫⁻ z, newCost z ∂(advanceHistory P R update hupdate horiginal horiginal' hpreserve).joint)
      ≤ a+b := by
  apply advanceHistory_cost_le_ae P R update hupdate horiginal horiginal' hpreserve
    oldCost localCost newCost hOld hLocal hNew _ hOldBound hLocalBound
  have ho : ∀ᵐ z ∂RobustCompression.glue P.joint R.joint, oldInvariant z.1 := by
    apply ae_of_ae_map (f:=Prod.fst) measurable_fst.aemeasurable
    change ∀ᵐ y ∂(RobustCompression.glue P.joint R.joint).fst, oldInvariant y
    rwa [RobustCompression.glue_old]
  have hl : ∀ᵐ z ∂RobustCompression.glue P.joint R.joint, localInvariant (z.1.2,z.2) := by
    have hm : Measurable (fun z : (U × S) × T => (z.1.2,z.2)) := by fun_prop
    apply ae_of_ae_map (f:=fun z : (U × S) × T => (z.1.2,z.2)) hm.aemeasurable
    rwa [RobustCompression.glue_new P.joint R.joint (P.state_marginal.trans R.left.symm)]
  filter_upwards [ho,hl] with z hz hz'
  exact hcost z.1.1 z.1.2 z.2 hz hz'

end NeuralGeneralization.RobustCompressionInduction
