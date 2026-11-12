import NeuralGeneralization.BatchTwoOnlineBalancedPosteriorCover
import NeuralGeneralization.BatchTwoMergingStatistics

/-! Uniform finite-sample learning for the actual balanced-population tanh prior. -/
noncomputable section
set_option autoImplicit false
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoOnlineBalanced
open ConcreteModel BatchTwoMerging BatchTwoOnlineTanhMerging

theorem all_width_all_scale_balanced_tanh_learning {d C r : ℕ} (hd : 0<d) (hC : 0<C)
    (B : LayeredBooleanCircuit d C r) (D : Measure (Cube d)) [IsProbabilityMeasure D]
    {c0 ε δ : ℝ} (hc0 : 0<c0) (hε : 0<ε) (hε1 : ε≤1) (hδ : 0<δ)
    (n : ℕ) (hn : 0<n)
    (hbudget : 2*(Real.log (Fintype.card (BalancedMainGridCode d C r c0 ε):ℝ)+Real.log (1/δ))≤
      (n:ℝ)*(ε/2)) :
    ∃A : Set (Fin n→Cube d), MeasurableSet A ∧
      1-δ≤(CompressionSampling.iidSamples D n).real A ∧
      ∀sample∈A,∀N,C≤N→∀σ,0<σ→(N:ℝ)*σ^2≤1→∀noiseMargin globalMargin : Bool,
        0<(smallPrior d N r σ).real (balancedPosteriorEvent noiseMargin globalMargin c0 B.computes sample) ∧
        RobustConfidence.gibbsMarginRisk D
          (balancedPosterior (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes sample)
          (fun x=>labelReal (B.computes x)) (fun w x=>networkOutput Real.tanh w x) (1/4)≤ε := by
  classical
  letI : Nonempty (BalancedMainGridCode d C r c0 ε) := ⟨fun _=>⟨0,by simp⟩⟩
  let g := balancedMainGridFunction d C r c0 ε
  let loss := comparisonLoss B.computes g
  let A := BatchTwoRelativeStatistics.generalizationEvent D loss n (ε/2)
  have hprob : 1-δ≤(CompressionSampling.iidSamples D n).real A := by
    apply BatchTwoRelativeStatistics.finite_class_good_probability_log D loss
      (fun _=>measurable_of_finite _) (comparisonLoss_bounds B.computes g) n hn hδ
      (le_refl _) hbudget
  refine ⟨A,BatchTwoRelativeStatistics.measurable_generalizationEvent D loss
    (fun _=>measurable_of_finite _) n (ε/2),hprob,?_⟩
  intro sample hsample N hCN σ hσ hscale noiseMargin globalMargin
  refine ⟨balanced_posterior_event_pos hd hC hCN B hc0 hσ hscale noiseMargin globalMargin sample,?_⟩
  obtain ⟨hP,E,hE,htail,hgood⟩ := balanced_merging_posterior_cover hd hC B hCN hc0 hσ hscale hε hε1
    noiseMargin globalMargin sample hn
  letI := hP
  have hrisk := finite_cover_posterior_risk D
    (balancedPosterior (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes sample)
    B.computes g sample (by positivity : 0≤ε/2) hsample
    (fun w x=>networkOutput Real.tanh w x)
    (fun x=>(continuous_networkOutput tanh_continuous x).measurable) E hE htail hgood
  exact hrisk.trans (by linarith)

end NeuralGeneralization.BatchTwoOnlineBalanced
