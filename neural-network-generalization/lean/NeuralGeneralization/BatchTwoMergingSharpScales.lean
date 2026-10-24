import NeuralGeneralization.BatchTwoMergingSharpMain

/-! Literal prior scalings and both stages of normalization. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel

theorem prior_and_training_normalizers_pos {d N r n:ℕ} {φ:ℝ→ℝ}
    (hφ:Continuous φ) (globalMargin:Bool) (σ:ℝ) (f:BooleanFunction d)
    (sample:Fin n→Cube d)
    (hpos:0<(smallPrior d N r σ).real (posteriorEvent φ globalMargin f sample)):
    0<(smallPrior d N r σ).real (restrictedSupport φ globalMargin) ∧
    0<(cond (smallPrior d N r σ) (restrictedSupport φ globalMargin)).real
      (RobustPosterior.trainingMarginEvent φ f sample) := by
  have hp:0<(smallPrior d N r σ).real (restrictedSupport φ globalMargin) :=
    hpos.trans_le (measureReal_mono Set.inter_subset_left (measure_ne_top _ _))
  refine ⟨hp,?_⟩
  rw [RobustPosterior.cond_real_eq_ratio _ _ _ (measurable_restrictedSupport hφ globalMargin)]
  exact div_pos hpos hp

/-- Both prior normalization and subsequent training normalization are positive
for every sample, independently of the sample-complexity assumption. -/
theorem manuscript_relu_normalizers_positive {d C N r n:ℕ} (hd:0<d) (hC:0<C)
    (B:LayeredNorCircuit d C r) (hCN:C≤N) {σ:ℝ} (hσ:0<σ)
    (hscale:(N:ℝ)*σ^2≤1) (globalMargin:Bool) (sample:Fin n→Cube d):
    0<(smallPrior d N r σ).real (restrictedSupport relu globalMargin) ∧
    0<(cond (smallPrior d N r σ) (restrictedSupport relu globalMargin)).real
      (RobustPosterior.trainingMarginEvent relu B.computes sample) ∧
    0<(smallPrior d N r σ).real (posteriorEvent relu globalMargin B.computes sample) := by
  have hp:=posterior_event_pos relu globalMargin σ B.computes sample
    (sharp_relu_target_mass_all_widths hd hC hCN B hσ hscale)
  have hh:=prior_and_training_normalizers_pos continuous_relu globalMargin σ B.computes sample hp
  exact ⟨hh.1,hh.2,hp⟩

/-- Both prior normalization and subsequent training normalization are positive
for every sample, independently of the sample-complexity assumption. -/
theorem manuscript_gelu_normalizers_positive {d C N r n:ℕ} (hd:0<d) (hC:0<C)
    (B:LayeredNorCircuit d C r) (hCN:2*C≤N) {σ:ℝ} (hσ:0<σ)
    (hscale:(N:ℝ)*σ^2≤1) (globalMargin:Bool) (sample:Fin n→Cube d):
    0<(smallPrior d N r σ).real (restrictedSupport gelu globalMargin) ∧
    0<(cond (smallPrior d N r σ) (restrictedSupport gelu globalMargin)).real
      (RobustPosterior.trainingMarginEvent gelu B.computes sample) ∧
    0<(smallPrior d N r σ).real (posteriorEvent gelu globalMargin B.computes sample) := by
  have hp:=posterior_event_pos gelu globalMargin σ B.computes sample
    (sharp_gelu_target_mass_all_widths hd hC hCN B hσ hscale)
  have hh:=prior_and_training_normalizers_pos gelu_lipschitz.continuous globalMargin σ B.computes sample hp
  exact ⟨hh.1,hh.2,hp⟩

theorem manuscript_relu_learning_power {d C r n : ℕ} (hd : 0<d) (hC : 0<C)
    (B : LayeredNorCircuit d C r) (D : Measure (Cube d)) [IsProbabilityMeasure D]
    {ε δ : ℝ} (hε : 0<ε) (hε1 : ε<1) (hδ : 0<δ) (hδ1 : δ<1)
    (hn : 2/ε*(sharpReluEntropy d r (sharpReluTargetCost d C r) ε+Real.log (1/δ))≤(n:ℝ)) :
    ∃A : Set (Fin n→Cube d), MeasurableSet A ∧
      1-δ≤(CompressionSampling.iidSamples D n).real A ∧
      ∀sample∈A,∀N,C≤N→∀γ:ℝ,1≤γ→∀globalMargin : Bool,
        0<(powerPrior d N r γ).real (posteriorEvent relu globalMargin B.computes sample) ∧
        RobustConfidence.gibbsMarginRisk D
          (posterior (N:=N) (r:=r) relu globalMargin (powerStandardDeviation N γ)
            B.computes sample)
          (fun x=>labelReal (B.computes x)) (fun w x=>networkOutput relu w x) (1/4)≤ε := by
  obtain ⟨A,hA,hprob,hgood⟩ := manuscript_relu_learning hd hC B D hε hε1 hδ hδ1 hn
  refine ⟨A,hA,hprob,?_⟩
  intro sample hsample N hCN γ hγ globalMargin
  have hN : 0<N := hC.trans_le hCN
  have hh := hgood sample hsample N hCN (powerStandardDeviation N γ)
    (powerStandardDeviation_pos hN γ) (width_mul_powerStandardDeviation_sq_le_one hN hγ)
    globalMargin
  simpa only [powerPrior_eq_smallPrior_standardDeviation hN γ] using hh

/-- The paper's literal t/√N standard deviation, simultaneously for 0<t≤1. -/
theorem manuscript_relu_learning_meanfield {d C r n : ℕ} (hd : 0<d) (hC : 0<C)
    (B : LayeredNorCircuit d C r) (D : Measure (Cube d)) [IsProbabilityMeasure D]
    {ε δ : ℝ} (hε : 0<ε) (hε1 : ε<1) (hδ : 0<δ) (hδ1 : δ<1)
    (hn : 2/ε*(sharpReluEntropy d r (sharpReluTargetCost d C r) ε+Real.log (1/δ))≤(n:ℝ)) :
    ∃A : Set (Fin n→Cube d), MeasurableSet A ∧
      1-δ≤(CompressionSampling.iidSamples D n).real A ∧
      ∀sample∈A,∀N,C≤N→∀t:ℝ,0<t→t≤1→∀globalMargin : Bool,
        0<(smallPrior d N r (t/Real.sqrt (N:ℝ))).real
          (posteriorEvent relu globalMargin B.computes sample) ∧
        RobustConfidence.gibbsMarginRisk D
          (posterior (N:=N) (r:=r) relu globalMargin (t/Real.sqrt (N:ℝ)) B.computes sample)
          (fun x=>labelReal (B.computes x)) (fun w x=>networkOutput relu w x) (1/4)≤ε := by
  obtain ⟨A,hA,hprob,hgood⟩ := manuscript_relu_learning hd hC B D hε hε1 hδ hδ1 hn
  refine ⟨A,hA,hprob,?_⟩
  intro sample hsample N hCN t ht ht1 globalMargin
  have hN : 0<N := hC.trans_le hCN
  have hNr : (0:ℝ)<N := by exact_mod_cast hN
  have hs : 0<Real.sqrt (N:ℝ) := Real.sqrt_pos.mpr hNr
  apply hgood sample hsample N hCN (t/Real.sqrt (N:ℝ)) (div_pos ht hs) _ globalMargin
  rw [div_pow,Real.sq_sqrt hNr.le,mul_div_cancel₀ _ hNr.ne']
  nlinarith


theorem manuscript_gelu_learning_power {d C r n : ℕ} (hd : 0<d) (hC : 0<C)
    (B : LayeredNorCircuit d C r) (D : Measure (Cube d)) [IsProbabilityMeasure D]
    {ε δ : ℝ} (hε : 0<ε) (hε1 : ε<1) (hδ : 0<δ) (hδ1 : δ<1)
    (hn : 2/ε*(sharpGeluEntropy d r (sharpGeluTargetCost d (2*C) r) ε+Real.log (1/δ))≤(n:ℝ)) :
    ∃A : Set (Fin n→Cube d), MeasurableSet A ∧
      1-δ≤(CompressionSampling.iidSamples D n).real A ∧
      ∀sample∈A,∀N,2*C≤N→∀γ:ℝ,1≤γ→∀globalMargin : Bool,
        0<(powerPrior d N r γ).real (posteriorEvent gelu globalMargin B.computes sample) ∧
        RobustConfidence.gibbsMarginRisk D
          (posterior (N:=N) (r:=r) gelu globalMargin (powerStandardDeviation N γ)
            B.computes sample)
          (fun x=>labelReal (B.computes x)) (fun w x=>networkOutput gelu w x) (1/4)≤ε := by
  obtain ⟨A,hA,hprob,hgood⟩ := manuscript_gelu_learning hd hC B D hε hε1 hδ hδ1 hn
  refine ⟨A,hA,hprob,?_⟩
  intro sample hsample N hCN γ hγ globalMargin
  have hN : 0<N := (Nat.mul_pos (by omega : 0<2) hC).trans_le hCN
  have hh := hgood sample hsample N hCN (powerStandardDeviation N γ)
    (powerStandardDeviation_pos hN γ) (width_mul_powerStandardDeviation_sq_le_one hN hγ)
    globalMargin
  simpa only [powerPrior_eq_smallPrior_standardDeviation hN γ] using hh

/-- The paper's literal t/√N standard deviation, simultaneously for 0<t≤1. -/
theorem manuscript_gelu_learning_meanfield {d C r n : ℕ} (hd : 0<d) (hC : 0<C)
    (B : LayeredNorCircuit d C r) (D : Measure (Cube d)) [IsProbabilityMeasure D]
    {ε δ : ℝ} (hε : 0<ε) (hε1 : ε<1) (hδ : 0<δ) (hδ1 : δ<1)
    (hn : 2/ε*(sharpGeluEntropy d r (sharpGeluTargetCost d (2*C) r) ε+Real.log (1/δ))≤(n:ℝ)) :
    ∃A : Set (Fin n→Cube d), MeasurableSet A ∧
      1-δ≤(CompressionSampling.iidSamples D n).real A ∧
      ∀sample∈A,∀N,2*C≤N→∀t:ℝ,0<t→t≤1→∀globalMargin : Bool,
        0<(smallPrior d N r (t/Real.sqrt (N:ℝ))).real
          (posteriorEvent gelu globalMargin B.computes sample) ∧
        RobustConfidence.gibbsMarginRisk D
          (posterior (N:=N) (r:=r) gelu globalMargin (t/Real.sqrt (N:ℝ)) B.computes sample)
          (fun x=>labelReal (B.computes x)) (fun w x=>networkOutput gelu w x) (1/4)≤ε := by
  obtain ⟨A,hA,hprob,hgood⟩ := manuscript_gelu_learning hd hC B D hε hε1 hδ hδ1 hn
  refine ⟨A,hA,hprob,?_⟩
  intro sample hsample N hCN t ht ht1 globalMargin
  have hN : 0<N := (Nat.mul_pos (by omega : 0<2) hC).trans_le hCN
  have hNr : (0:ℝ)<N := by exact_mod_cast hN
  have hs : 0<Real.sqrt (N:ℝ) := Real.sqrt_pos.mpr hNr
  apply hgood sample hsample N hCN (t/Real.sqrt (N:ℝ)) (div_pos ht hs) _ globalMargin
  rw [div_pow,Real.sq_sqrt hNr.le,mul_div_cancel₀ _ hNr.ne']
  nlinarith

end NeuralGeneralization.BatchTwoMerging
