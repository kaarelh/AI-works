import NeuralGeneralization.RobustCompressionInductionHistory

/-! # Almost-everywhere invariants through canonical-history gluing -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.RobustCompressionInduction
open RobustStatistics RobustCompression
variable {W U V S T : Type*} [MeasurableSpace W] [MeasurableSpace U]
  [MeasurableSpace V] [MeasurableSpace S] [MeasurableSpace T]
  [StandardBorelSpace T] [Nonempty T]

/-- Both old-history support and one-step support survive gluing, so any
measurable deterministic consequence is a support invariant of the next
complete-history comparison. -/
theorem advanceHistory_ae {Q : Measure W} {Γ : Measure S} {Γ' : Measure T}
    {original : U → W} {original' : V → W}
    (P : CanonicalHistoryComparison Q Γ original)
    (R : ProbabilityCoupling Γ Γ')
    (update : U → S → T → V)
    (hupdate : Measurable (fun z : (U × S) × T => update z.1.1 z.1.2 z.2))
    (horiginal : Measurable original) (horiginal' : Measurable original')
    (hpreserve : ∀ u s t, original' (update u s t) = original u)
    (oldGood : U × S → Prop) (stepGood : S × T → Prop) (newGood : V × T → Prop)
    (hNew : MeasurableSet {z | newGood z})
    (hOld : ∀ᵐ z ∂P.joint,oldGood z) (hStep : ∀ᵐ z ∂R.joint,stepGood z)
    (himp : ∀ u s t,oldGood (u,s) → stepGood (s,t) → newGood (update u s t,t)) :
    ∀ᵐ z ∂(advanceHistory P R update hupdate horiginal horiginal' hpreserve).joint,newGood z := by
  change ∀ᵐ z ∂(glue P.joint R.joint).map
    (fun z => (update z.1.1 z.1.2 z.2,z.2)),newGood z
  apply (ae_map_iff (hupdate.prodMk measurable_snd).aemeasurable hNew).mpr
  have ho : ∀ᵐ z ∂(glue P.joint R.joint).map Prod.fst,oldGood z := by
    change ∀ᵐ z ∂(glue P.joint R.joint).fst,oldGood z
    rw [glue_old]
    exact hOld
  have hn : ∀ᵐ z ∂(glue P.joint R.joint).map
      (fun z : (U × S) × T => (z.1.2,z.2)),stepGood z := by
    rw [glue_new P.joint R.joint (P.state_marginal.trans R.left.symm)]
    exact hStep
  have hm : Measurable (fun z : (U × S) × T => (z.1.2,z.2)) := by fun_prop
  filter_upwards [ae_of_ae_map measurable_fst.aemeasurable ho,
    ae_of_ae_map hm.aemeasurable hn] with z hz hz'
  exact himp z.1.1 z.1.2 z.2 hz hz'

end NeuralGeneralization.RobustCompressionInduction
