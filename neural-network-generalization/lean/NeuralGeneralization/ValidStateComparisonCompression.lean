import NeuralGeneralization.RobustComparisonCompression
import NeuralGeneralization.PointwiseRobustCompression
import NeuralGeneralization.RobustCompressionLargeWidthProof

/-! The actual Gaussian compressor transferred to comparisons that require
valid hidden states. The activation-box hypothesis is proved for the selected
histories and terminal sampler, and is retained through finite-grid rounding. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
namespace NeuralGeneralization.ConcreteModel
open RobustStatistics RobustCompressionInduction RobustMainProofs

lemma roundedFieldCoupling_valid_comparison_failure_le {Ω : Type*} [MeasurableSpace Ω]
    {d N m M r B R : ℕ} {train test : ℝ} (rule : PredictionComparison train test)
    (Q : Measure (Weights d N r)) (Γ : Measure (Weights d m r))
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (original : Ω → Weights d N r) (compact : Ω → Weights d m r)
    (ho : Measurable original) (hcpt : Measurable compact)
    (hleft : μ.map original = Q) (hright : μ.map compact = Γ)
    (hmM : m ≤ M) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (x : Cube d) (path : Ω → HiddenPath N r)
    (P : Weights d N r → Cube d → Prop) (hP : MeasurableSet {w | P w x})
    {c radius α : ℝ}
    (hrad : ∀ᵐ ω ∂μ,radius ≤ robustRadius c (original ω))
    (hbound : ∀ᵐ ω ∂μ,boundedWeights B (compact ω))
    (hvalid : ∀ᵐ ω ∂μ,validHiddenPath (path ω))
    (hpath : ∀ w v h,validHiddenPath h → P w x → radius ≤ robustRadius c w → boundedWeights B v →
      reconstructionPathCost φ w v x h ≤ (radius/2)^2 →
      rule.good (networkOutput φ w x)
        (robustGridOutput d M r B R φ (padAndRoundCode hmM B R v) x))
    (hfail : μ.real {ω | (radius/2)^2 < reconstructionPathCost φ (original ω) (compact ω) x (path ω)} ≤ α) :
    (roundedFieldCoupling Q Γ μ original compact ho hcpt hleft hright hmM B R).joint.real
      (rule.failure (fun w => networkOutput φ w x) (fun q => robustGridOutput d M r B R φ q x)) ≤
      α+Q.real {w | ¬ P w x} := by
  let bad : Set (Weights d N r) := {w | ¬ P w x}
  have hbad : MeasurableSet bad := hP.compl
  have hmap : Measurable (fun ω => (original ω,padAndRoundCode hmM B R (compact ω))) :=
    ho.prodMk ((measurable_padAndRoundCode hmM B R).comp hcpt)
  have hs := rule.measurable_failure
    (fun w : Weights d N r => networkOutput φ w x)
    (fun q : RobustOutputCode d M r B R => robustGridOutput d M r B R φ q x)
    (continuous_networkOutput (admissibleActivation_continuous hφ) x).measurable (measurable_of_countable _)
  change (μ.map (fun ω => (original ω,padAndRoundCode hmM B R (compact ω)))).real _ ≤ _
  rw [map_measureReal_apply hmap hs]
  have hsub : ∀ᵐ ω ∂μ,
      (original ω,padAndRoundCode hmM B R (compact ω)) ∈ rule.failure
        (fun w => networkOutput φ w x) (fun q => robustGridOutput d M r B R φ q x) →
      ω ∈ {ω | (radius/2)^2 < reconstructionPathCost φ (original ω) (compact ω) x (path ω)} ∪
        original ⁻¹' bad := by
    filter_upwards [hrad,hbound,hvalid] with ω hr hv hhvalid
    intro hh
    by_cases hw : P (original ω) x
    · left
      by_contra hcost
      exact hh (hpath (original ω) (compact ω) (path ω) hhvalid hw hr hv (le_of_not_gt hcost))
    · exact Or.inr hw
  have hprob := ENNReal.toReal_mono (measure_ne_top μ _) (measure_mono_ae hsub)
  have he : μ.real (original ⁻¹' bad) = Q.real bad := by
    rw [← hleft,map_measureReal_apply ho hbad]
  exact hprob.trans ((measureReal_union_le _ _).trans (by linarith [hfail,he]))

/-- The concrete large-width raw construction and the small-width grid branch
produce one common finite candidate law for the supplied comparison rule. -/
theorem pointwise_valid_comparison_compression (p : RobustCompressionInput)
    {N : ℕ} (hd : 0 < p.dimension) (hN : 0 < N) (hL : 2 ≤ p.depth)
    (hK : 1 ≤ p.energy) (hA : 0 < p.inverseFailure) (hR : 6 ≤ p.inverseRadius)
    {σ t c train test : ℝ} (hσ : 0 < σ) (ht : 0 < t) (ht1 : t^2 ≤ 1) (hscale : t^2 = N*σ^2)
    (Q : Measure (Weights p.dimension N (p.depth-2))) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (smallPrior p.dimension N (p.depth-2) σ) ≤ ENNReal.ofReal (N*(p.energy:ℝ)/t^2))
    (rule : PredictionComparison train test)
    (P : Weights p.dimension N (p.depth-2) → Cube p.dimension → Prop)
    (hP : ∀ x,MeasurableSet {w | P w x})
    (hrad : ∀ᵐ w ∂Q,1/(p.inverseRadius:ℝ) ≤ robustRadius c w)
    (hsmall : ∀ (w : Weights p.dimension N (p.depth-2)) (x : Cube p.dimension) (a : ℝ),|a-networkOutput Real.tanh w x| ≤ 1/(p.inverseOutputError:ℝ) →
      rule.good (networkOutput Real.tanh w x) a)
    (hpath : ∀ (hmM : p.bankSize ≤ p.widthBound) w v x h,
      validHiddenPath h → P w x → 1/(p.inverseRadius:ℝ) ≤ robustRadius c w → boundedWeights p.weightBound v →
      reconstructionPathCost Real.tanh w v x h ≤ ((1/(p.inverseRadius:ℝ))/2)^2 →
      rule.good (networkOutput Real.tanh w x)
        (robustGridOutput p.dimension p.widthBound (p.depth-2) p.weightBound p.inverseOutputError
          Real.tanh (padAndRoundCode hmM p.weightBound p.inverseOutputError v) x)) :
    ∃ Γ : Measure (RobustOutputCode p.dimension p.widthBound (p.depth-2) p.weightBound p.inverseOutputError),
      IsProbabilityMeasure Γ ∧ ∃ π : ∀ x : Cube p.dimension,ProbabilityCoupling Q Γ,
        ∀ x,(π x).joint.real (rule.failure (fun w => networkOutput Real.tanh w x)
          (fun q => robustGridOutput p.dimension p.widthBound (p.depth-2)
            p.weightBound p.inverseOutputError Real.tanh q x)) ≤
          1/(p.inverseFailure:ℝ)+Q.real {w | ¬ P w x} := by
  by_cases hNM : N ≤ p.widthBound
  · let Γ := Q.map (padAndRoundCode (d := p.dimension) (r := p.depth-2) hNM p.weightBound p.inverseOutputError)
    haveI : IsProbabilityMeasure Γ := Measure.isProbabilityMeasure_map
      (measurable_padAndRoundCode hNM p.weightBound p.inverseOutputError).aemeasurable
    refine ⟨Γ,inferInstance,fun _ => smallWidthGridCoupling Q hNM p.weightBound p.inverseOutputError,?_⟩
    intro x
    have hf := p.small_width_grid_coupling hd hN hNM hA (by omega) ht ht1 hscale
      (α := 1/(p.inverseFailure:ℝ)) (by simp only [one_div]; exact le_rfl) Q hKL Real.tanh tanh_admissible
    have hh : (smallWidthGridCoupling Q hNM p.weightBound p.inverseOutputError).joint.real
        (rule.failure (fun w => networkOutput Real.tanh w x)
          (fun q => robustGridOutput p.dimension p.widthBound (p.depth-2)
            p.weightBound p.inverseOutputError Real.tanh q x)) ≤ 1/(p.inverseFailure:ℝ) := by
      apply (measureReal_mono (μ := (smallWidthGridCoupling Q hNM p.weightBound p.inverseOutputError).joint) ?_).trans hf
      intro q hq
      refine ⟨x,?_⟩
      by_contra hclose
      apply hq
      exact hsmall q.1 x _ (by simpa only [abs_sub_comm] using le_of_not_gt hclose)
    exact hh.trans (by linarith [measureReal_nonneg (μ := Q) (s := {w | ¬ P w x})])
  · obtain ⟨Γ,hΓ,hraw⟩ := largeWidthRawCompression p hd hL hK hA hR N (Nat.lt_of_not_ge hNM)
      σ t hσ ht ht1 hscale Q inferInstance hKL
    letI : IsProbabilityMeasure Γ := hΓ
    have hmM : p.bankSize ≤ p.widthBound := by dsimp [RobustCompressionInput.widthBound]; omega
    let Γgrid := Γ.map (padAndRoundCode (d := p.dimension) (r := p.depth-2) hmM p.weightBound p.inverseOutputError)
    haveI : IsProbabilityMeasure Γgrid := Measure.isProbabilityMeasure_map
      (measurable_padAndRoundCode hmM p.weightBound p.inverseOutputError).aemeasurable
    choose ρ hvalid hρ using hraw.validComparison
    refine ⟨Γgrid,inferInstance,fun x => (ρ x).rounded hmM p.weightBound p.inverseOutputError,?_⟩
    intro x
    apply roundedFieldCoupling_valid_comparison_failure_le rule Q Γ (ρ x).joint Prod.fst (fun q => q.2.1)
      measurable_fst (measurable_fst.comp measurable_snd) (ρ x).original (ρ x).compact
      hmM Real.tanh tanh_admissible x (fun q => q.2.2) P (hP x)
    · exact ae_of_ae_map (μ := (ρ x).joint) (f := Prod.fst)
        (p := fun w => 1/(p.inverseRadius:ℝ) ≤ robustRadius c w) measurable_fst.aemeasurable (by rwa [(ρ x).original])
    · have hm : Measurable (fun q : RawPathState p.dimension N p.bankSize (p.depth-2) => q.2.1) :=
        measurable_fst.comp measurable_snd
      exact ae_of_ae_map hm.aemeasurable (by rw [(ρ x).compact]; exact hraw.bounded)
    · exact hvalid x
    · exact fun w v h => hpath hmM w v x h
    · exact hρ x

end NeuralGeneralization.ConcreteModel
