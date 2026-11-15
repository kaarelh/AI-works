import NeuralGeneralization.BatchTwoManuscriptLearningParameters
import NeuralGeneralization.BatchTwoImprovedLearningStatistics

/-! The explicit 16/epsilon J sample budget for the actual robust posterior.
The target-cost hypothesis is isolated for substitution of a proved cylinder. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
namespace NeuralGeneralization.BatchTwoManuscriptLearning
open ConcreteModel RobustPosterior RobustStatistics RobustConfidence

variable {N n : ℕ}

theorem retained_score_compression (p : Input) (hN : 0<N)
    (f : BooleanFunction p.dimension) (sample : Fin n→Cube p.dimension)
    {t : ℝ} (ht : 0<t) (ht1 : t≤1)
    (htarget : Real.exp (-p.targetCost/(t/Real.sqrt (N:ℝ))^2)≤
      (smallPrior p.dimension N (p.depth-2) (t/Real.sqrt (N:ℝ))).real
        (robustEvent Real.tanh p.calibration ∩ marginEvent Real.tanh (1/2) f)) :
    ∃Γ : Measure (CandidateCode p),IsProbabilityMeasure Γ ∧
      ∃π : ∀x : Cube p.dimension,ProbabilityCoupling
        (retainedPosterior (N:=N) (r:=p.depth-2) Real.tanh p.calibration (t/Real.sqrt (N:ℝ))
          (posteriorReadoutBound p) f sample) Γ,
        ∀x,(π x).joint.real (scoreFailure (fun w=>networkOutput Real.tanh w x)
          (fun q=>candidate p Real.tanh q x))≤p.accuracy/12 := by
  have hn : (0:ℝ)<N := Nat.cast_pos.mpr hN
  have hs : 0<t/Real.sqrt (N:ℝ) := by positivity
  have hscale : (N:ℝ)*(t/Real.sqrt (N:ℝ))^2≤1 := by
    rw [div_pow,Real.sq_sqrt hn.le]
    have he : (N:ℝ)*(t^2/(N:ℝ))=t^2 := by field_simp
    rw [he]
    nlinarith
  have hs1 : (t/Real.sqrt (N:ℝ))^2≤1 := by
    have hn1 : (1:ℝ)≤N := by exact_mod_cast hN
    nlinarith [sq_nonneg (t/Real.sqrt (N:ℝ))]
  have hβ := discardedMass_pos p
  have hβhalf : discardedMass p≤1/2 := (discardedMass_le_quarter p).trans (by norm_num)
  have htail := robustPosterior_readout_tail tanh_continuous p.dimension_pos hN p.calibration_pos hs hscale
    hβ (by linarith) (posteriorReadoutBound_ge_eight p) (posteriorReadoutBound_allocation p) f sample htarget
  let Q := retainedPosterior (N:=N) (r:=p.depth-2) Real.tanh p.calibration (t/Real.sqrt (N:ℝ)) (posteriorReadoutBound p) f sample
  letI : IsProbabilityMeasure Q := retainedPosterior_isProbability tanh_continuous p.calibration_pos hs hs1 hβhalf f sample htarget htail
  have hKL : klDiv Q (smallPrior p.dimension N (p.depth-2) (t/Real.sqrt (N:ℝ)))≤
      ENNReal.ofReal ((N:ℝ)*(compressionInput p).energy/t^2) := by
    have hh := retainedPosterior_klDiv_bound tanh_continuous p.calibration_pos hs hs1 hβhalf f sample htarget htail
    convert hh using 1
    congr 1
    change (N:ℝ)*(p.targetCost+1)/t^2=(p.targetCost+1)/(t/Real.sqrt (N:ℝ))^2
    rw [div_pow,Real.sq_sqrt hn.le]
    field_simp
  have hrob : ∀ᵐw ∂Q,w∈robustEvent Real.tanh p.calibration :=
    (retained_supported tanh_continuous p.calibration_pos (t/Real.sqrt (N:ℝ)) (posteriorReadoutBound p) f sample).mono (fun w hw=>hw.1)
  have hrad : ∀ᵐw ∂Q,(compressionInput p).radius≤robustRadius p.calibration w := by
    filter_upwards [retained_supported tanh_continuous p.calibration_pos (t/Real.sqrt (N:ℝ)) (posteriorReadoutBound p) f sample] with w hw
    exact compression_radius_le_robust p w hw.2
  exact BatchTwoManuscriptResources.all_width_score_compression (compressionInput p) hN tanh_admissible
    ht ht1 Q hKL (min_le_left _ _) hrob hrad

theorem all_width_all_scale_learning_of_target_mass (p : Input) {C : ℕ} (hC : 0<C)
    (f : BooleanFunction p.dimension)
    (htarget : ∀N : ℕ,C≤N→∀t : ℝ,0<t→t≤1→
      Real.exp (-p.targetCost/(t/Real.sqrt (N:ℝ))^2)≤
        (smallPrior p.dimension N (p.depth-2) (t/Real.sqrt (N:ℝ))).real
          (robustEvent Real.tanh p.calibration ∩ marginEvent Real.tanh (1/2) f))
    (D : Measure (Cube p.dimension)) [IsProbabilityMeasure D] {δ : ℝ} (hδ : 0<δ)
    (n : ℕ) (hn : 0<n) (hbudget : 16*(entropy p+Real.log (1/δ))≤(n:ℝ)*p.accuracy) :
    ∃E : Set (Fin n→Cube p.dimension),MeasurableSet E ∧
      1-δ≤(CompressionSampling.iidSamples D n).real E ∧
      ∀sample∈E,∀N : ℕ,C≤N→∀t : ℝ,0<t→t≤1→
        0<(smallPrior p.dimension N (p.depth-2) (t/Real.sqrt (N:ℝ))).real
          (robustPosteriorEvent Real.tanh p.calibration f sample) ∧
        gibbsMarginRisk D
          (robustPosterior (N:=N) (r:=p.depth-2) Real.tanh p.calibration (t/Real.sqrt (N:ℝ)) f sample)
          (fun x=>labelReal (f x)) (networkOutput Real.tanh) (1/4)≤p.accuracy := by
  classical
  letI : Nonempty (CandidateCode p) := ⟨fun _=>⟨0,by apply Finset.mem_Icc.mpr; constructor <;> omega⟩⟩
  let loss := candidateLoss f (candidate p Real.tanh)
  let E := BatchTwoRelativeStatistics.generalizationEvent D loss n (p.accuracy/2)
  have hmeas : MeasurableSet E := BatchTwoRelativeStatistics.measurable_generalizationEvent D loss
    (fun _=>measurable_of_finite _) n (p.accuracy/2)
  have hprob : 1-δ≤(CompressionSampling.iidSamples D n).real E :=
    BatchTwoRelativeStatistics.finite_class_good_probability_log D loss
      (fun _=>measurable_of_finite _) (candidateLoss_bounds f (candidate p Real.tanh)) n hn hδ (candidate_entropy p)
      (by have := p.accuracy_pos; have hn0 := Nat.cast_nonneg (α:=ℝ) n; nlinarith)
  refine ⟨E,hmeas,hprob,?_⟩
  intro sample hs N hCN t ht ht1
  have hN := hC.trans_le hCN
  have hNr : (0:ℝ)<N := Nat.cast_pos.mpr hN
  have hσ : 0<t/Real.sqrt (N:ℝ) := by positivity
  have hscale : (N:ℝ)*(t/Real.sqrt (N:ℝ))^2≤1 := by
    rw [div_pow,Real.sq_sqrt hNr.le]
    have he : (N:ℝ)*(t^2/(N:ℝ))=t^2 := by field_simp
    rw [he]
    nlinarith
  have hσ1 : (t/Real.sqrt (N:ℝ))^2≤1 := by
    have hn1 : (1:ℝ)≤N := by exact_mod_cast hN
    nlinarith [sq_nonneg (t/Real.sqrt (N:ℝ))]
  have hm := htarget N hCN t ht ht1
  have hβ := discardedMass_pos p
  have hβhalf : discardedMass p≤1/2 := (discardedMass_le_quarter p).trans (by norm_num)
  have htail := robustPosterior_readout_tail tanh_continuous p.dimension_pos hN p.calibration_pos hσ hscale
    hβ (by linarith) (posteriorReadoutBound_ge_eight p) (posteriorReadoutBound_allocation p) f sample hm
  let Q := robustPosterior (N:=N) (r:=p.depth-2) Real.tanh p.calibration (t/Real.sqrt (N:ℝ)) f sample
  let Q' := retainedPosterior (N:=N) (r:=p.depth-2) Real.tanh p.calibration (t/Real.sqrt (N:ℝ)) (posteriorReadoutBound p) f sample
  letI : IsProbabilityMeasure Q := robustPosterior_isProbability Real.tanh p.calibration (t/Real.sqrt (N:ℝ)) f sample hm
  letI : IsProbabilityMeasure Q' := retainedPosterior_isProbability tanh_continuous p.calibration_pos hσ hσ1 hβhalf f sample hm htail
  obtain ⟨Γ,hΓ,π,hfail⟩ := retained_score_compression p hN f sample ht ht1 hm
  letI : IsProbabilityMeasure Γ := hΓ
  have hrisk : gibbsMarginRisk D Q (fun x=>labelReal (f x)) (networkOutput Real.tanh) (1/4)≤
      discardedMass p+3*(p.accuracy/12)+p.accuracy/2 := by
    apply BatchTwoImprovedLearning.posterior_margin_risk_on_relative_event D f (candidate p Real.tanh) hn sample hs Q Q' Γ
      (networkOutput Real.tanh) (fun x=>(continuous_networkOutput tanh_continuous x).measurable) π hfail
    · intro i
      exact retained_training_null tanh_continuous p.calibration_pos (t/Real.sqrt (N:ℝ)) (posteriorReadoutBound p) f sample i
    · intro x
      exact robustPosterior_restore tanh_continuous p.calibration_pos (by linarith) f sample hm htail _
  refine ⟨(Real.exp_pos _).trans_le (posterior_event_mass_lower Real.tanh p.calibration (t/Real.sqrt (N:ℝ)) f sample hm),hrisk.trans ?_⟩
  unfold discardedMass
  linarith

end NeuralGeneralization.BatchTwoManuscriptLearning
