import NeuralGeneralization.BatchTwoImprovedLearningMain
import NeuralGeneralization.PowerPriorScaling

/-! Literal σ and γ conventions and positivity of both conditioning stages. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoImprovedLearning
open ConcreteModel RobustPosterior RobustConfidence
variable {d C N r n:ℕ}

theorem normalizers_positive (hd:0<d) (hC:0<C) (hCN:C≤N)
    (B:LayeredBooleanCircuit d C r) {c σ:ℝ} (hc:0<c) (hσ:0<σ)
    (hscale:(N:ℝ)*σ^2≤1) (sample:Fin n→Cube d):
    0<(smallPrior d N r σ).real (robustEvent Real.tanh c) ∧
    0<(cond (smallPrior d N r σ) (robustEvent Real.tanh c)).real
      (trainingMarginEvent Real.tanh B.computes sample) ∧
    0<(smallPrior d N r σ).real (robustPosteriorEvent Real.tanh c B.computes sample) := by
  have hm:=improved_target_mass_all_widths hd hC hCN B hc hσ hscale
  have hpos:0<(smallPrior d N r σ).real (robustPosteriorEvent Real.tanh c B.computes sample) :=
    (Real.exp_pos _).trans_le (posterior_event_mass_lower Real.tanh c σ B.computes sample hm)
  have hp:0<(smallPrior d N r σ).real (robustEvent Real.tanh c) :=
    hpos.trans_le (measureReal_mono Set.inter_subset_left (measure_ne_top _ _))
  refine ⟨hp,?_,hpos⟩
  rw [cond_real_eq_ratio _ _ _ (measurableSet_robustEvent tanh_continuous hc)]
  exact div_pos hpos hp

theorem learning_scaled_variance (hd:0<d) (hC:0<C)
    (B:LayeredBooleanCircuit d C r) {c ε δ:ℝ} (hc:0<c) (hε:0<ε) (hε1:ε≤1) (hδ:0<δ)
    (D:Measure (Cube d)) [IsProbabilityMeasure D]
    (n:ℕ) (hn:0<n)
    (hbudget:200*(entropy d C r c ε+Real.log (1/δ))≤(n:ℝ)*ε):
    ∃E:Set (Fin n→Cube d),MeasurableSet E ∧
      1-δ≤(CompressionSampling.iidSamples D n).real E ∧
      ∀sample∈E,∀N,C≤N→∀σ,0<σ→(N:ℝ)*σ^2≤1→
        0<(smallPrior d N r σ).real (robustPosteriorEvent Real.tanh c B.computes sample) ∧
        gibbsMarginRisk D (robustPosterior (N:=N) (r:=r) Real.tanh c σ B.computes sample)
          (fun x=>labelReal (B.computes x)) (networkOutput Real.tanh) (1/4)≤ε/3 ∧
        D.real {x|correctConfidence
          (robustPosterior (N:=N) (r:=r) Real.tanh c σ B.computes sample)
          (fun x=>labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) x≤(2/3:ℝ)}≤ε := by
  obtain ⟨E,hE,hprob,hgood⟩:=all_width_all_scale_learning hd hC B hc hε hε1 hδ D n hn hbudget
  refine ⟨E,hE,hprob,?_⟩
  intro sample hs N hCN σ hσ hscale
  have hN:0<N:=hC.trans_le hCN
  have hNr:(0:ℝ)<N:=Nat.cast_pos.mpr hN
  have hsN:0<Real.sqrt (N:ℝ):=Real.sqrt_pos.mpr hNr
  have ht:0<σ*Real.sqrt (N:ℝ):=by positivity
  have ht1:σ*Real.sqrt (N:ℝ)≤1:=by
    have he:(σ*Real.sqrt (N:ℝ))^2=σ^2*N:=by rw [mul_pow,Real.sq_sqrt hNr.le]
    nlinarith
  have he:σ*Real.sqrt (N:ℝ)/Real.sqrt (N:ℝ)=σ:=by field_simp
  have hh:=hgood sample hs N hCN (σ*Real.sqrt (N:ℝ)) ht ht1
  simpa only [he] using hh

theorem learning_power (hd:0<d) (hC:0<C)
    (B:LayeredBooleanCircuit d C r) {c ε δ:ℝ} (hc:0<c) (hε:0<ε) (hε1:ε≤1) (hδ:0<δ)
    (D:Measure (Cube d)) [IsProbabilityMeasure D]
    (n:ℕ) (hn:0<n)
    (hbudget:200*(entropy d C r c ε+Real.log (1/δ))≤(n:ℝ)*ε):
    ∃E:Set (Fin n→Cube d),MeasurableSet E ∧
      1-δ≤(CompressionSampling.iidSamples D n).real E ∧
      ∀sample∈E,∀N,C≤N→∀γ:ℝ,1≤γ→
        0<(powerPrior d N r γ).real (robustPosteriorEvent Real.tanh c B.computes sample) ∧
        gibbsMarginRisk D
          (robustPosterior (N:=N) (r:=r) Real.tanh c (powerStandardDeviation N γ) B.computes sample)
          (fun x=>labelReal (B.computes x)) (networkOutput Real.tanh) (1/4)≤ε/3 ∧
        D.real {x|correctConfidence
          (robustPosterior (N:=N) (r:=r) Real.tanh c (powerStandardDeviation N γ) B.computes sample)
          (fun x=>labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) x≤(2/3:ℝ)}≤ε := by
  obtain ⟨E,hE,hprob,hgood⟩:=learning_scaled_variance hd hC B hc hε hε1 hδ D n hn hbudget
  refine ⟨E,hE,hprob,?_⟩
  intro sample hs N hCN γ hγ
  have hN:0<N:=hC.trans_le hCN
  have hh:=hgood sample hs N hCN (powerStandardDeviation N γ)
    (powerStandardDeviation_pos hN γ) (width_mul_powerStandardDeviation_sq_le_one hN hγ)
  simpa only [powerPrior_eq_smallPrior_standardDeviation hN γ] using hh

end NeuralGeneralization.BatchTwoImprovedLearning
