import NeuralGeneralization.BatchTwoImprovedLearningParameters
import NeuralGeneralization.BatchTwoImprovedLearningStatistics
import NeuralGeneralization.BatchTwoImprovedAllWidths

/-! Actual original-support NN Bayes learning, at every width above the teacher
and every mean-field-or-stronger scale. All analytic premises are discharged. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
namespace NeuralGeneralization.BatchTwoImprovedLearning
open ConcreteModel RobustPosterior RobustConfidence RobustStatistics
variable {d C N r n:ℕ}
set_option maxHeartbeats 600000
set_option backward.isDefEq.respectTransparency false

theorem retained_score_compression (hd:0<d) (hC:0<C) (hCN:C≤N)
    (B:LayeredBooleanCircuit d C r) {c ε t:ℝ} (hc:0<c) (hε:0<ε) (hε1:ε≤1)
    (ht:0<t) (ht1:t≤1) (sample:Fin n→Cube d):
    ∃Γ:Measure (CandidateCode d C r c ε),IsProbabilityMeasure Γ ∧
      ∃π:∀x:Cube d,ProbabilityCoupling
        (retainedPosterior (N:=N) (r:=r) Real.tanh c (t/Real.sqrt N)
          (readoutBound d C r c ε) B.computes sample) Γ,
        ∀x,(π x).joint.real (scoreFailure (fun w=>networkOutput Real.tanh w x)
          (fun q=>candidate d C r c ε q x))≤ε/100 := by
  have hN:0<N:=hC.trans_le hCN
  have hNr:(0:ℝ)<N:=Nat.cast_pos.mpr hN
  have hσ:0<t/Real.sqrt (N:ℝ):=by positivity
  have hscale:(N:ℝ)*(t/Real.sqrt (N:ℝ))^2≤1:=by
    rw [div_pow,Real.sq_sqrt hNr.le]
    have he:(N:ℝ)*(t^2/(N:ℝ))=t^2:=by field_simp
    rw [he]
    nlinarith
  have hσ1:(t/Real.sqrt (N:ℝ))^2≤1:=by
    have hN1:(1:ℝ)≤N:=by exact_mod_cast hN
    nlinarith [sq_nonneg (t/Real.sqrt (N:ℝ))]
  have hm:=improved_target_mass_all_widths hd hC hCN B hc hσ hscale
  have hβ:0<ε/100:=by positivity
  have hβhalf:ε/100≤(1/2:ℝ):=by linarith
  have hcap:=readoutBound_ge_eight (d:=d) (r:=r) hC c hε hε1
  have hcapbudget:4*(improvedTargetCost d C r c-Real.log (ε/100))≤readoutBound d C r c ε:=by
    unfold readoutBound
    linarith
  have htail:=robustPosterior_readout_tail tanh_continuous hd hN hc hσ hscale hβ
    (by linarith) hcap hcapbudget B.computes sample hm
  let Q:=retainedPosterior (N:=N) (r:=r) Real.tanh c (t/Real.sqrt N)
    (readoutBound d C r c ε) B.computes sample
  letI:IsProbabilityMeasure Q:=retainedPosterior_isProbability tanh_continuous hc hσ hσ1
    hβhalf B.computes sample hm htail
  let p:=parameters d C r c ε
  have hKL:klDiv Q (smallPrior d N r (t/Real.sqrt N))≤ENNReal.ofReal ((p.energy:ℝ)/(t/Real.sqrt N)^2):=by
    apply (retainedPosterior_klDiv_bound tanh_continuous hc hσ hσ1 hβhalf B.computes sample hm htail).trans
    apply ENNReal.ofReal_le_ofReal
    exact div_le_div_of_nonneg_right (parameters_energy hC c ε).2 (sq_nonneg _)
  have hrob:∀ᵐw ∂Q,w∈robustEvent Real.tanh c :=
    (retained_supported tanh_continuous hc (t/Real.sqrt N) (readoutBound d C r c ε) B.computes sample).mono
      (fun w hw=>hw.1)
  have hrad:∀ᵐw ∂Q,1/((p.inverseRadius:ℝ)+1)≤robustRadius c w :=by
    filter_upwards [retained_supported tanh_continuous hc (t/Real.sqrt N)
      (readoutBound d C r c ε) B.computes sample] with w hw
    exact (parameters_radius hC hc hε hε1).2.2.trans (calibrated_radius_lower hc w hw.2)
  have hraw:=BatchTwoImprovedInduction.all_width_score_compression p hd
    (parameters_energy hC c ε).1 (parameters_inverseRadius_ge_six d C r c ε) hN ht ht1 Q hKL hrob hrad
  change ∃Γ:Measure (CandidateCode d C r c ε),IsProbabilityMeasure Γ ∧
    ∃π:∀x:Cube d,ProbabilityCoupling Q Γ,
      ∀x,(π x).joint.real (scoreFailure (fun w=>networkOutput Real.tanh w x)
        (fun q=>candidate d C r c ε q x))≤1/((p.inverseFailure:ℝ)+1) at hraw
  obtain ⟨Γ,hΓ,π,hfail⟩:=hraw
  exact ⟨Γ,hΓ,π,fun x=>(hfail x).trans (parameters_failure d C r c hε)⟩

theorem all_width_all_scale_learning (hd:0<d) (hC:0<C)
    (B:LayeredBooleanCircuit d C r) {c ε δ:ℝ} (hc:0<c) (hε:0<ε) (hε1:ε≤1) (hδ:0<δ)
    (D:Measure (Cube d)) [IsProbabilityMeasure D]
    (n:ℕ) (hn:0<n)
    (hbudget:200*(entropy d C r c ε+Real.log (1/δ))≤(n:ℝ)*ε):
    ∃E:Set (Fin n→Cube d),MeasurableSet E ∧
      1-δ≤(CompressionSampling.iidSamples D n).real E ∧
      ∀sample∈E,∀N,C≤N→∀t,0<t→t≤1→
        0<(smallPrior d N r (t/Real.sqrt N)).real
          (robustPosteriorEvent Real.tanh c B.computes sample) ∧
        gibbsMarginRisk D
          (robustPosterior (N:=N) (r:=r) Real.tanh c (t/Real.sqrt N) B.computes sample)
          (fun x=>labelReal (B.computes x)) (networkOutput Real.tanh) (1/4)≤ε/3 ∧
        D.real {x|correctConfidence
          (robustPosterior (N:=N) (r:=r) Real.tanh c (t/Real.sqrt N) B.computes sample)
          (fun x=>labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) x≤(2/3:ℝ)}≤ε := by
  classical
  letI:Nonempty (CandidateCode d C r c ε):=⟨fun _=>⟨0,by apply Finset.mem_Icc.mpr;constructor <;> omega⟩⟩
  let loss:=candidateLoss B.computes (candidate d C r c ε)
  let E:=BatchTwoRelativeStatistics.generalizationEvent D loss n (ε/100)
  have hmeas:MeasurableSet E:=BatchTwoRelativeStatistics.measurable_generalizationEvent D loss
    (fun _=>measurable_of_finite _) n (ε/100)
  have hprob:1-δ≤(CompressionSampling.iidSamples D n).real E :=
    BatchTwoRelativeStatistics.finite_class_good_probability_log D loss
      (fun _=>measurable_of_finite _) (candidateLoss_bounds B.computes (candidate d C r c ε))
      n hn hδ (candidate_entropy d C r c ε) (by nlinarith)
  refine ⟨E,hmeas,hprob,?_⟩
  intro sample hs N hCN t ht ht1
  have hN:0<N:=hC.trans_le hCN
  have hNr:(0:ℝ)<N:=Nat.cast_pos.mpr hN
  have hσ:0<t/Real.sqrt (N:ℝ):=by positivity
  have hscale:(N:ℝ)*(t/Real.sqrt (N:ℝ))^2≤1:=by
    rw [div_pow,Real.sq_sqrt hNr.le]
    have he:(N:ℝ)*(t^2/(N:ℝ))=t^2:=by field_simp
    rw [he]
    nlinarith
  have hσ1:(t/Real.sqrt (N:ℝ))^2≤1:=by
    have hN1:(1:ℝ)≤N:=by exact_mod_cast hN
    nlinarith [sq_nonneg (t/Real.sqrt (N:ℝ))]
  have hm:=improved_target_mass_all_widths hd hC hCN B hc hσ hscale
  have hβ:0<ε/100:=by positivity
  have hβhalf:ε/100≤(1/2:ℝ):=by linarith
  have hcap:=readoutBound_ge_eight (d:=d) (r:=r) hC c hε hε1
  have hcapbudget:4*(improvedTargetCost d C r c-Real.log (ε/100))≤readoutBound d C r c ε:=by
    unfold readoutBound
    linarith
  have htail:=robustPosterior_readout_tail tanh_continuous hd hN hc hσ hscale hβ
    (by linarith) hcap hcapbudget B.computes sample hm
  let Q:=robustPosterior (N:=N) (r:=r) Real.tanh c (t/Real.sqrt N) B.computes sample
  let Q':=retainedPosterior (N:=N) (r:=r) Real.tanh c (t/Real.sqrt N)
    (readoutBound d C r c ε) B.computes sample
  letI:IsProbabilityMeasure Q:=robustPosterior_isProbability Real.tanh c (t/Real.sqrt N) B.computes sample hm
  letI:IsProbabilityMeasure Q':=retainedPosterior_isProbability tanh_continuous hc hσ hσ1
    hβhalf B.computes sample hm htail
  obtain ⟨Γ,hΓ,π,hfail⟩:=retained_score_compression hd hC hCN B hc hε hε1 ht ht1 sample
  letI:IsProbabilityMeasure Γ:=hΓ
  have hrisk:gibbsMarginRisk D Q (fun x=>labelReal (B.computes x)) (networkOutput Real.tanh) (1/4)≤
      ε/100+3*(ε/100)+ε/100 := by
    apply posterior_margin_risk_on_relative_event D B.computes (candidate d C r c ε) hn sample hs Q Q' Γ
      (networkOutput Real.tanh) (fun x=>(continuous_networkOutput tanh_continuous x).measurable) π hfail
    · intro i
      exact retained_training_null tanh_continuous hc (t/Real.sqrt N) (readoutBound d C r c ε) B.computes sample i
    · intro x
      exact robustPosterior_restore tanh_continuous hc (by linarith : ε/100<1) B.computes sample hm htail _
  have hrisk':gibbsMarginRisk D Q (fun x=>labelReal (B.computes x)) (networkOutput Real.tanh) (1/4)≤ε/3 :=
    hrisk.trans (by linarith)
  refine ⟨(Real.exp_pos _).trans_le (posterior_event_mass_lower Real.tanh c (t/Real.sqrt N) B.computes sample hm),hrisk',?_⟩
  have hconf:=two_thirds_confidence_bound D Q (fun x=>labelReal (B.computes x))
    (networkOutput Real.tanh) (fun x=>(continuous_networkOutput tanh_continuous x).measurable) (1/4) hrisk'
  simpa only [mul_div_cancel₀ _ (by norm_num : (3:ℝ)≠0)] using hconf

end NeuralGeneralization.BatchTwoImprovedLearning
