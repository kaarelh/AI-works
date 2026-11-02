import NeuralGeneralization.RobustCouplingAllWidths
import NeuralGeneralization.PointwiseRobustSupport

/-! The common finite compressor under pointwise stability. Its score-coupling
failure is charged to actual posterior instability at the queried input. -/
noncomputable section
open MeasureTheory ProbabilityTheory Set InformationTheory
open scoped ENNReal
namespace NeuralGeneralization.ConcreteModel
open RobustCompressionInduction

lemma rounded_path_pointwise_close {d N m M r B R : ℕ}
    (hmM : m ≤ M) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (w : Weights d N r) (v : Weights d m r) (x : Cube d) (h : HiddenPath N r)
    {c radius : ℝ} (hw : stableAt φ c w x)
    (hr0 : 0 ≤ radius) (hr1 : radius ≤ 1/6) (hr : radius ≤ robustRadius c w)
    (hB : 0 < B) (hR : 0 < R) (hv : boundedWeights B v)
    (hround : 1/(R:ℝ) ≤ radius/8)
    (hcost : reconstructionPathCost φ w v x h ≤ (radius/2)^2) :
    |clippedScore (robustGridOutput d M r B R φ (padAndRoundCode hmM B R v) x)-
      clippedScore (networkOutput φ w x)| ≤ 1/12 := by
  let η := pathDisturbance φ w x h (networkOutput φ v x)
  have hnoise : noiseBudgetSq η ≤ (radius/2)^2 := by
    rw [pathDisturbance_budget_eq_hiddenPathCost]
    exact hcost
  apply pointwise_score_close_of_noisy_compression φ c w x η _ radius hw hr0 hr1 hr hnoise
  rw [pathDisturbance_output,abs_sub_comm]
  exact (padAndRoundCode_output_close hmM φ hφ hB hR v hv x).trans hround

lemma roundedFieldCoupling_pointwise_failure_le {Ω : Type*} [MeasurableSpace Ω]
    {d N m M r B R : ℕ}
    (Q : Measure (Weights d N r)) (Γ : Measure (Weights d m r))
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (original : Ω → Weights d N r) (compact : Ω → Weights d m r)
    (ho : Measurable original) (hcpt : Measurable compact)
    (hleft : μ.map original = Q) (hright : μ.map compact = Γ)
    (hmM : m ≤ M) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (x : Cube d) (path : Ω → HiddenPath N r)
    {c radius α : ℝ} (hc : 0 < c) (hr0 : 0 ≤ radius) (hr1 : radius ≤ 1/6)
    (hB : 0 < B) (hR : 0 < R) (hround : 1/(R:ℝ) ≤ radius/8)
    (hrad : ∀ᵐ ω ∂μ,radius ≤ robustRadius c (original ω))
    (hbound : ∀ᵐ ω ∂μ,boundedWeights B (compact ω))
    (hfail : μ.real {ω | (radius/2)^2 < reconstructionPathCost φ (original ω) (compact ω) x (path ω)} ≤ α) :
    (roundedFieldCoupling Q Γ μ original compact ho hcpt hleft hright hmM B R).joint.real
      (RobustStatistics.scoreFailure (fun w => networkOutput φ w x)
        (fun q => robustGridOutput d M r B R φ q x)) ≤
      α+Q.real {w | ¬ stableAt φ c w x} := by
  let bad : Set (Weights d N r) := {w | ¬ stableAt φ c w x}
  have hbad : MeasurableSet bad := (isClosed_stableAt (admissibleActivation_continuous hφ) hc x).measurableSet.compl
  have hmap : Measurable (fun ω => (original ω,padAndRoundCode hmM B R (compact ω))) :=
    ho.prodMk ((measurable_padAndRoundCode hmM B R).comp hcpt)
  have hs := RobustStatistics.measurable_scoreFailure
    (fun w : Weights d N r => networkOutput φ w x)
    (fun q : RobustOutputCode d M r B R => robustGridOutput d M r B R φ q x)
    (continuous_networkOutput (admissibleActivation_continuous hφ) x).measurable (measurable_of_countable _)
  change (μ.map (fun ω => (original ω,padAndRoundCode hmM B R (compact ω)))).real _ ≤ _
  rw [map_measureReal_apply hmap hs]
  have hsub : ∀ᵐ ω ∂μ,
      (original ω,padAndRoundCode hmM B R (compact ω)) ∈
        RobustStatistics.scoreFailure (fun w => networkOutput φ w x)
          (fun q => robustGridOutput d M r B R φ q x) →
      ω ∈ {ω | (radius/2)^2 < reconstructionPathCost φ (original ω) (compact ω) x (path ω)} ∪
        original ⁻¹' bad := by
    filter_upwards [hrad,hbound] with ω hr hv
    intro hh
    by_cases hw : stableAt φ c (original ω) x
    · left
      by_contra hcost
      have hclose := rounded_path_pointwise_close hmM φ hφ (original ω) (compact ω) x
        (path ω) hw hr0 hr1 hr hB hR hv hround (le_of_not_gt hcost)
      exact (not_lt_of_ge hclose) hh
    · exact Or.inr hw
  have hprob := ENNReal.toReal_mono (measure_ne_top μ _) (measure_mono_ae hsub)
  have he : μ.real (original ⁻¹' bad) = Q.real bad := by
    rw [← hleft,map_measureReal_apply ho hbad]
  exact hprob.trans ((measureReal_union_le _ _).trans (by linarith [hfail,he]))

/-- A common finite candidate law, with an explicit instability charge. -/
theorem RawPathCompression.pointwise_finite_grid {d N m M r B R : ℕ}
    {Q : Measure (Weights d N r)} {Γ : Measure (Weights d m r)}
    (hmM : m ≤ M) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    {c radius failure : ℝ} (hc : 0 < c) (hr0 : 0 ≤ radius) (hr1 : radius ≤ 1/6)
    (hB : 0 < B) (hR : 0 < R) (hround : 1/(R:ℝ) ≤ radius/8)
    (hrad : ∀ᵐ w ∂Q,radius ≤ robustRadius c w)
    (hraw : RawPathCompression φ Q Γ B radius failure) :
    ∃ π : ∀ x : Cube d,RobustStatistics.ProbabilityCoupling Q
      (Γ.map (padAndRoundCode hmM B R)),
      ∀ x,(π x).joint.real
        (RobustStatistics.scoreFailure (fun w => networkOutput φ w x)
          (fun q => robustGridOutput d M r B R φ q x)) ≤ failure+Q.real {w | ¬ stableAt φ c w x} := by
  choose ρ hρ using hraw.comparison
  refine ⟨fun x => (ρ x).rounded hmM B R,?_⟩
  intro x
  apply roundedFieldCoupling_pointwise_failure_le Q Γ (ρ x).joint Prod.fst (fun p => p.2.1)
    measurable_fst (measurable_fst.comp measurable_snd) (ρ x).original (ρ x).compact
    hmM φ hφ x (fun p => p.2.2) hc hr0 hr1 hB hR hround
  · exact ae_of_ae_map (μ := (ρ x).joint) (f := Prod.fst)
      (p := fun w => radius ≤ robustRadius c w) measurable_fst.aemeasurable (by rwa [(ρ x).original])
  · have hm : Measurable (fun p : RawPathState d N m r => p.2.1) := measurable_fst.comp measurable_snd
    exact ae_of_ae_map hm.aemeasurable (by rw [(ρ x).compact]; exact hraw.bounded)
  · exact hρ x

namespace RobustCompressionInput

theorem pointwise_finite_grid_of_large_width_raw (p : RobustCompressionInput)
    {N : ℕ} (hd : 0 < p.dimension) (hN : 0 < N)
    (hA : 0 < p.inverseFailure) (hR : 6 ≤ p.inverseRadius)
    {σ t c : ℝ} (hc : 0 < c) (ht : 0 < t) (ht1 : t^2 ≤ 1) (hscale : t^2 = N*σ^2)
    (Q : Measure (Weights p.dimension N (p.depth-2))) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (smallPrior p.dimension N (p.depth-2) σ) ≤ ENNReal.ofReal (N*(p.energy:ℝ)/t^2))
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (hrad : ∀ᵐ w ∂Q,1/(p.inverseRadius:ℝ) ≤ robustRadius c w)
    (hlarge : p.widthBound < N →
      ∃ Γ : Measure (Weights p.dimension p.bankSize (p.depth-2)),
        IsProbabilityMeasure Γ ∧ RawPathCompression φ Q Γ p.weightBound
          (1/(p.inverseRadius:ℝ)) (1/(p.inverseFailure:ℝ))) :
    ∃ Γ : Measure (RobustOutputCode p.dimension p.widthBound (p.depth-2) p.weightBound p.inverseOutputError),
      IsProbabilityMeasure Γ ∧
      ∃ π : ∀ x : Cube p.dimension,RobustStatistics.ProbabilityCoupling Q Γ,
        ∀ x,(π x).joint.real
          (RobustStatistics.scoreFailure (fun w => networkOutput φ w x)
            (fun q => robustGridOutput p.dimension p.widthBound (p.depth-2)
              p.weightBound p.inverseOutputError φ q x)) ≤
          1/(p.inverseFailure:ℝ)+Q.real {w | ¬ stableAt φ c w x} := by
  by_cases hNM : N ≤ p.widthBound
  · let Γ := Q.map (padAndRoundCode (d := p.dimension) (r := p.depth-2) hNM p.weightBound p.inverseOutputError)
    haveI : IsProbabilityMeasure Γ := Measure.isProbabilityMeasure_map
      (measurable_padAndRoundCode hNM p.weightBound p.inverseOutputError).aemeasurable
    refine ⟨Γ,inferInstance,fun _ => smallWidthGridCoupling Q hNM p.weightBound p.inverseOutputError,?_⟩
    intro x
    exact (small_width_grid_score_coupling p (α := 1/(p.inverseFailure:ℝ)) hd hN hNM hA (by omega) ht ht1 hscale
      (by simp only [one_div]; exact le_rfl) Q hKL φ hφ x).trans (by linarith [measureReal_nonneg (μ := Q) (s := {w | ¬ stableAt φ c w x})])
  · obtain ⟨Γ,hΓ,hraw⟩ := hlarge (Nat.lt_of_not_ge hNM)
    letI : IsProbabilityMeasure Γ := hΓ
    have hmM : p.bankSize ≤ p.widthBound := by dsimp [widthBound]; omega
    let Γgrid := Γ.map (padAndRoundCode (d := p.dimension) (r := p.depth-2) hmM p.weightBound p.inverseOutputError)
    haveI : IsProbabilityMeasure Γgrid := Measure.isProbabilityMeasure_map
      (measurable_padAndRoundCode hmM p.weightBound p.inverseOutputError).aemeasurable
    refine ⟨Γgrid,inferInstance,?_⟩
    have hRp : (0:ℝ) < p.inverseRadius := by exact_mod_cast (show 0 < p.inverseRadius by omega)
    apply hraw.pointwise_finite_grid hmM φ hφ hc (by positivity : 0 ≤ 1/(p.inverseRadius:ℝ))
      (one_div_le_one_div_of_le (by norm_num : (0:ℝ) < 6) (by exact_mod_cast hR))
      p.weightBound_pos (by dsimp [inverseOutputError]; omega) _ hrad
    simp only [inverseOutputError,Nat.cast_mul,Nat.cast_ofNat]
    field_simp
    norm_num

end RobustCompressionInput
end NeuralGeneralization.ConcreteModel
