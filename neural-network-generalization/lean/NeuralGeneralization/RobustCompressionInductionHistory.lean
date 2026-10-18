import NeuralGeneralization.RobustCompressionInductionCost

/-! # Canonical-state comparison with complete original history

At each depth the canonical compression state has a fixed law independent
of the test input. A pointwise comparison additionally retains the original
network and its virtual hidden path. This construction joins an actual next
layer comparison to that entire history, then stores its updated path.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal
namespace NeuralGeneralization.RobustCompressionInduction
open RobustStatistics RobustCompression

variable {W U V S T : Type*} [MeasurableSpace W] [MeasurableSpace U]
  [MeasurableSpace V] [MeasurableSpace S] [MeasurableSpace T]

/-- A comparison retaining additional original history. Only the specified
original projection and canonical-state marginal are constrained. -/
structure CanonicalHistoryComparison (Q : Measure W) (Γ : Measure S)
    (original : U → W) where
  joint : Measure (U × S)
  probability : IsProbabilityMeasure joint
  original_marginal : joint.map (fun z => original z.1) = Q
  state_marginal : joint.map Prod.snd = Γ

attribute [instance] CanonicalHistoryComparison.probability

variable [StandardBorelSpace T] [Nonempty T]

/-- Carry an input-dependent complete history through an input-independent
canonical layer law. The entire previous comparison is preserved before the
explicit history update, and the new canonical marginal is exact. -/
def advanceHistory {Q : Measure W} {Γ : Measure S} {Γ' : Measure T}
    {original : U → W} {original' : V → W}
    (P : CanonicalHistoryComparison Q Γ original)
    (R : ProbabilityCoupling Γ Γ')
    (update : U → S → T → V)
    (hupdate : Measurable (fun z : (U × S) × T => update z.1.1 z.1.2 z.2))
    (horiginal : Measurable original) (horiginal' : Measurable original')
    (hpreserve : ∀ u s t, original' (update u s t) = original u) :
    CanonicalHistoryComparison Q Γ' original' where
  joint := (glue P.joint R.joint).map
    (fun z => (update z.1.1 z.1.2 z.2,z.2))
  probability := Measure.isProbabilityMeasure_map (hupdate.prodMk measurable_snd).aemeasurable
  original_marginal := by
    have ho' : Measurable (fun z : V × T => original' z.1) := horiginal'.comp measurable_fst
    have hm : Measurable (fun z : (U × S) × T => (update z.1.1 z.1.2 z.2,z.2)) :=
      hupdate.prodMk measurable_snd
    rw [Measure.map_map ho' hm]
    simp only [Function.comp_def,hpreserve]
    have he := congrArg (fun μ : Measure (U × S) => μ.map (fun z => original z.1))
      (glue_old P.joint R.joint)
    have ho : Measurable (fun z : U × S => original z.1) := horiginal.comp measurable_fst
    change ((glue P.joint R.joint).map Prod.fst).map (fun z => original z.1) =
      P.joint.map (fun z => original z.1) at he
    rw [Measure.map_map ho measurable_fst] at he
    exact he.trans P.original_marginal
  state_marginal := by
    rw [Measure.map_map measurable_snd (hupdate.prodMk measurable_snd)]
    have hshared : P.joint.snd = R.joint.fst :=
      P.state_marginal.trans R.left.symm
    have he := congrArg (fun μ : Measure (S × T) => μ.map Prod.snd)
      (glue_new P.joint R.joint hshared)
    have hm : Measurable (fun z : (U × S) × T => (z.1.2,z.2)) := by fun_prop
    rw [Measure.map_map measurable_snd hm] at he
    exact he.trans R.right

/-- Any measurable accumulated cost satisfying the exact deterministic
one-layer identity retains an additive expectation bound. -/
theorem advanceHistory_cost_le {Q : Measure W} {Γ : Measure S} {Γ' : Measure T}
    {original : U → W} {original' : V → W}
    (P : CanonicalHistoryComparison Q Γ original)
    (R : ProbabilityCoupling Γ Γ')
    (update : U → S → T → V)
    (hupdate : Measurable (fun z : (U × S) × T => update z.1.1 z.1.2 z.2))
    (horiginal : Measurable original) (horiginal' : Measurable original')
    (hpreserve : ∀ u s t, original' (update u s t) = original u)
    (oldCost : U × S → ℝ≥0∞) (localCost : S × T → ℝ≥0∞)
    (newCost : V × T → ℝ≥0∞)
    (hOld : Measurable oldCost) (hLocal : Measurable localCost) (hNew : Measurable newCost)
    (hcost : ∀ u s t, newCost (update u s t,t) ≤ oldCost (u,s)+localCost (s,t))
    {a b : ℝ≥0∞}
    (hOldBound : (∫⁻ z, oldCost z ∂P.joint) ≤ a)
    (hLocalBound : (∫⁻ z, localCost z ∂R.joint) ≤ b) :
    (∫⁻ z, newCost z ∂(advanceHistory P R update hupdate horiginal horiginal' hpreserve).joint)
      ≤ a+b := by
  change (∫⁻ z, newCost z ∂(glue P.joint R.joint).map
    (fun z => (update z.1.1 z.1.2 z.2,z.2))) ≤ _
  rw [lintegral_map hNew (hupdate.prodMk measurable_snd)]
  apply le_trans (lintegral_mono (fun z : (U × S) × T => hcost z.1.1 z.1.2 z.2))
  apply lintegral_glue_cost_le P.joint R.joint
    (P.state_marginal.trans R.left.symm) oldCost localCost hOld hLocal hOldBound hLocalBound

/-- Forgetting the accumulated history produces the exact coupling type used
by the final statistical theorem. -/
def CanonicalHistoryComparison.toCoupling {Q : Measure W} {Γ : Measure S}
    {original : U → W} (P : CanonicalHistoryComparison Q Γ original)
    (ho : Measurable original) : ProbabilityCoupling Q Γ where
  joint := P.joint.map (fun z => (original z.1,z.2))
  probability := Measure.isProbabilityMeasure_map
    ((ho.comp measurable_fst).prodMk measurable_snd).aemeasurable
  left := by
    have hm : Measurable (fun z : U × S => (original z.1,z.2)) :=
      (ho.comp measurable_fst).prodMk measurable_snd
    rw [Measure.map_map measurable_fst hm]
    exact P.original_marginal
  right := by
    have hm : Measurable (fun z : U × S => (original z.1,z.2)) :=
      (ho.comp measurable_fst).prodMk measurable_snd
    rw [Measure.map_map measurable_snd hm]
    exact P.state_marginal

end NeuralGeneralization.RobustCompressionInduction
