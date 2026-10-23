import NeuralGeneralization.BatchTwoMergingSharpBudgets

/-! An internal assembly lemma. The public manuscript endpoints discharge the
actual Gaussian target-mass premise by the compiler-cylinder construction. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel
variable {d C r : ℕ}

theorem sharp_relu_learning_of_target_mass (hd : 0<d) (hC : 0<C)
    (B : LayeredNorCircuit d C r) (D : Measure (Cube d)) [IsProbabilityMeasure D]
    (T:ℝ) (hT:0≤T)
    (htarget:∀N,C≤N→∀σ,0<σ→(N:ℝ)*σ^2≤1→
      Real.exp (-T/σ^2)≤(smallPrior d N r σ).real
        (mergingSupport relu ∩marginEvent relu (1/2) B.computes))
    {ε δ : ℝ} (hε : 0<ε) (hε1 : ε≤1) (hδ : 0<δ)
    (n : ℕ) (hn : 0<n)
    (hbudget : (sharpReluEntropy d r T ε+Real.log (1/δ))≤
      (n:ℝ)*(ε/2)) :
    ∃A : Set (Fin n→Cube d), MeasurableSet A ∧
      1-δ≤(CompressionSampling.iidSamples D n).real A ∧
      ∀sample∈A,∀N,C≤N→∀σ,0<σ→(N:ℝ)*σ^2≤1→∀globalMargin : Bool,
        0<(smallPrior d N r σ).real (posteriorEvent relu globalMargin B.computes sample) ∧
        RobustConfidence.gibbsMarginRisk D
          (posterior (N:=N) (r:=r) relu globalMargin σ B.computes sample)
          (fun x=>labelReal (B.computes x)) (fun w x=>networkOutput relu w x) (1/4)≤ε := by
  classical
  letI : Nonempty (SharpReluGridCode d r T ε) := ⟨fun _=>⟨0,by simp⟩⟩
  let g := sharpReluGridFunction d r T ε
  let A := (BatchTwoSurvivalStatistics.badSamples D (comparisonBadSet B.computes g) n (ε/2))ᶜ
  have hprob : 1-δ≤(CompressionSampling.iidSamples D n).real A := by
    apply BatchTwoSurvivalStatistics.goodSamples_probability_log (E:=Real.log (Fintype.card (SharpReluGridCode d r T ε):ℝ)) D
      (comparisonBadSet B.computes g) (fun c=>(Set.toFinite _).measurableSet) n hδ _ (by linarith [sharpReluGrid_entropy d r T ε])
    rw [Real.exp_log (by exact_mod_cast (Fintype.card_pos : 0<Fintype.card (SharpReluGridCode d r T ε)))]
  refine ⟨A,(BatchTwoSurvivalStatistics.measurable_badSamples D
    (comparisonBadSet B.computes g) (fun c=>(Set.toFinite _).measurableSet) n (ε/2)).compl,hprob,?_⟩
  intro sample hsample N hCN σ hσ hscale globalMargin
  have hN : 0<N := hC.trans_le hCN
  have hmass := htarget N hCN σ hσ hscale
  have hpos := posterior_event_pos relu globalMargin σ B.computes sample hmass
  refine ⟨hpos,?_⟩
  have hE0 : (smallPrior d N r σ) (posteriorEvent relu globalMargin B.computes sample)≠0 := by
    intro he
    simp only [Measure.real,he,ENNReal.toReal_zero] at hpos
    exact (lt_irrefl 0) hpos
  let P := posterior (N:=N) (r:=r) relu globalMargin σ B.computes sample
  letI : IsProbabilityMeasure P := cond_isProbabilityMeasure hE0
  let B0 := sharpReadoutBound T ε
  let Q0 := sharpPopulationBound T ε
  let J0 := sharpEnergyBound d r T ε
  have hQ : 0<Q0 := sharpPopulationBound_pos T ε
  have hβ : 0<ε/4 := by positivity
  have hβ1 : ε/4≤1 := by linarith
  have htail1 : P.real {w | B0<readoutEnergy w}≤ε/4 := by
    apply posterior_readout_tail hd hN continuous_relu globalMargin hσ hscale B.computes sample
      hβ hβ1 (sharpReadoutBound_ge_eight T ε) _ hmass
    exact sharpReadoutBound_budget hT hε hε1
  have htail2 : P.real (exceptionalPartitions (Q:=Q0) J0)≤ε/4 := by
    apply posterior_exceptionalPartitions_tail hd hN hQ continuous_relu globalMargin hσ hscale
      B.computes sample hβ hβ1 _ hmass
    dsimp [J0,Q0,sharpEnergyBound]
    rw [log_four_div hε]
    nlinarith
  let E : Set (Weights d N r) := {w | B0<readoutEnergy w} ∪ exceptionalPartitions (Q:=Q0) J0
  have hE : MeasurableSet E := (measurableSet_lt measurable_const continuous_readoutEnergy.measurable).union
    (measurable_exceptionalPartitions J0)
  have htail : P.real E≤ε/2 :=
    (measureReal_union_le _ _).trans (by linarith)
  have hgood : ∀ᵐw ∂P,(∀i,(1/2:ℝ)<labelReal (B.computes (sample i))*networkOutput relu w (sample i)) ∧
      (w∉E→∃c,∀x,|clippedScore (networkOutput relu w x)-clippedScore (g c x)|≤3/32) := by
    filter_upwards [ae_cond_mem (μ:=smallPrior d N r σ)
      (measurable_posteriorEvent continuous_relu globalMargin B.computes sample)] with w hw
    refine ⟨hw.2,?_⟩
    intro he
    have hb : readoutEnergy w≤B0 := le_of_not_gt (fun h=>he (Or.inl h))
    have hj : w∉exceptionalPartitions (Q:=Q0) J0 := fun h=>he (Or.inr h)
    exact posteriorEvent_grid_cover hd hN hn globalMargin B.computes sample w hw hb hj
  have hrisk := survival_finite_cover_posterior_risk D P B.computes g sample (by positivity : 0≤ε/2)
    hsample (fun w x=>networkOutput relu w x)
    (fun x=>(continuous_networkOutput continuous_relu x).measurable) E hE htail hgood
  exact hrisk.trans (by linarith)


theorem sharp_gelu_learning_of_target_mass (hd : 0<d) (hC : 0<C)
    (B : LayeredNorCircuit d C r) (D : Measure (Cube d)) [IsProbabilityMeasure D]
    (T:ℝ) (hT:0≤T)
    (htarget:∀N,2*C≤N→∀σ,0<σ→(N:ℝ)*σ^2≤1→
      Real.exp (-T/σ^2)≤(smallPrior d N r σ).real
        (mergingSupport gelu ∩marginEvent gelu (1/2) B.computes))
    {ε δ : ℝ} (hε : 0<ε) (hε1 : ε≤1) (hδ : 0<δ)
    (n : ℕ) (hn : 0<n)
    (hbudget : (sharpGeluEntropy d r T ε+Real.log (1/δ))≤
      (n:ℝ)*(ε/2)) :
    ∃A : Set (Fin n→Cube d), MeasurableSet A ∧
      1-δ≤(CompressionSampling.iidSamples D n).real A ∧
      ∀sample∈A,∀N,2*C≤N→∀σ,0<σ→(N:ℝ)*σ^2≤1→∀globalMargin : Bool,
        0<(smallPrior d N r σ).real (posteriorEvent gelu globalMargin B.computes sample) ∧
        RobustConfidence.gibbsMarginRisk D
          (posterior (N:=N) (r:=r) gelu globalMargin σ B.computes sample)
          (fun x=>labelReal (B.computes x)) (fun w x=>networkOutput gelu w x) (1/4)≤ε := by
  classical
  letI : Nonempty (SharpGeluGridCode d r T ε) := ⟨fun _=>⟨0,by simp⟩⟩
  let g := sharpGeluGridFunction d r T ε
  let A := (BatchTwoSurvivalStatistics.badSamples D (comparisonBadSet B.computes g) n (ε/2))ᶜ
  have hprob : 1-δ≤(CompressionSampling.iidSamples D n).real A := by
    apply BatchTwoSurvivalStatistics.goodSamples_probability_log (E:=Real.log (Fintype.card (SharpGeluGridCode d r T ε):ℝ)) D
      (comparisonBadSet B.computes g) (fun c=>(Set.toFinite _).measurableSet) n hδ _ (by linarith [sharpGeluGrid_entropy d r T ε])
    rw [Real.exp_log (by exact_mod_cast (Fintype.card_pos : 0<Fintype.card (SharpGeluGridCode d r T ε)))]
  refine ⟨A,(BatchTwoSurvivalStatistics.measurable_badSamples D
    (comparisonBadSet B.computes g) (fun c=>(Set.toFinite _).measurableSet) n (ε/2)).compl,hprob,?_⟩
  intro sample hsample N hCN σ hσ hscale globalMargin
  have hN : 0<N := (Nat.mul_pos (by omega : 0<2) hC).trans_le hCN
  have hmass := htarget N hCN σ hσ hscale
  have hpos := posterior_event_pos gelu globalMargin σ B.computes sample hmass
  refine ⟨hpos,?_⟩
  have hE0 : (smallPrior d N r σ) (posteriorEvent gelu globalMargin B.computes sample)≠0 := by
    intro he
    simp only [Measure.real,he,ENNReal.toReal_zero] at hpos
    exact (lt_irrefl 0) hpos
  let P := posterior (N:=N) (r:=r) gelu globalMargin σ B.computes sample
  letI : IsProbabilityMeasure P := cond_isProbabilityMeasure hE0
  let B0 := sharpReadoutBound T ε
  let Q0 := sharpPopulationBound T ε
  let J0 := sharpEnergyBound d r T ε
  have hQ : 0<Q0 := sharpPopulationBound_pos T ε
  have hβ : 0<ε/4 := by positivity
  have hβ1 : ε/4≤1 := by linarith
  have htail1 : P.real {w | B0<readoutEnergy w}≤ε/4 := by
    apply posterior_readout_tail hd hN gelu_lipschitz.continuous globalMargin hσ hscale B.computes sample
      hβ hβ1 (sharpReadoutBound_ge_eight T ε) _ hmass
    exact sharpReadoutBound_budget hT hε hε1
  have htail2 : P.real (exceptionalPartitions (Q:=Q0) J0)≤ε/4 := by
    apply posterior_exceptionalPartitions_tail hd hN hQ gelu_lipschitz.continuous globalMargin hσ hscale
      B.computes sample hβ hβ1 _ hmass
    dsimp [J0,Q0,sharpEnergyBound]
    rw [log_four_div hε]
    nlinarith
  let E : Set (Weights d N r) := {w | B0<readoutEnergy w} ∪ exceptionalPartitions (Q:=Q0) J0
  have hE : MeasurableSet E := (measurableSet_lt measurable_const continuous_readoutEnergy.measurable).union
    (measurable_exceptionalPartitions J0)
  have htail : P.real E≤ε/2 :=
    (measureReal_union_le _ _).trans (by linarith)
  have hgood : ∀ᵐw ∂P,(∀i,(1/2:ℝ)<labelReal (B.computes (sample i))*networkOutput gelu w (sample i)) ∧
      (w∉E→∃c,∀x,|clippedScore (networkOutput gelu w x)-clippedScore (g c x)|≤3/32) := by
    filter_upwards [ae_cond_mem (μ:=smallPrior d N r σ)
      (measurable_posteriorEvent gelu_lipschitz.continuous globalMargin B.computes sample)] with w hw
    refine ⟨hw.2,?_⟩
    intro he
    have hb : readoutEnergy w≤B0 := le_of_not_gt (fun h=>he (Or.inl h))
    have hj : w∉exceptionalPartitions (Q:=Q0) J0 := fun h=>he (Or.inr h)
    exact gelu_posteriorEvent_grid_cover hd hN hn globalMargin B.computes sample w hw hb hj
  have hrisk := survival_finite_cover_posterior_risk D P B.computes g sample (by positivity : 0≤ε/2)
    hsample (fun w x=>networkOutput gelu w x)
    (fun x=>(continuous_networkOutput gelu_lipschitz.continuous x).measurable) E hE htail hgood
  exact hrisk.trans (by linarith)


end NeuralGeneralization.BatchTwoMerging
