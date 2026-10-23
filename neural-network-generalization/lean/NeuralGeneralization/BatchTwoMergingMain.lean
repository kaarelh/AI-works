import NeuralGeneralization.BatchTwoMergingTeacher
import NeuralGeneralization.BatchTwoMergingExceptionalPosterior
import NeuralGeneralization.BatchTwoMergingStatistics

/-! # Actual all-width, all-scale ReLU learning under population-merging support

Every approximation and target-mass lemma used here is proved for the concrete
finite Gaussian network. The common sample event is independent of learner
width, prior scale, and the optional all-input margin convention.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel
variable {d C r : ℕ}

def mainReadoutBound (d C r : ℕ) (ε : ℝ) : ℝ :=
  8+4*(mergingTargetCost d C r-Real.log (ε/4))
def mainPopulationBound (d C r : ℕ) (ε : ℝ) : ℕ := ⌈1+16*mainReadoutBound d C r ε⌉₊
def mainEnergyBound (d C r : ℕ) (ε : ℝ) : ℝ :=
  4*(mergingTargetCost d C r+partitionEntropyBudget d r (mainPopulationBound d C r ε)-Real.log (ε/4))
abbrev MainGridCode (d C r : ℕ) (ε : ℝ) :=
  NetworkGridCode d (mainPopulationBound d C r ε) r
    (gridResolution d (mainPopulationBound d C r ε) r (1+Real.sqrt (mainEnergyBound d C r ε)))
def mainGridFunction (d C r : ℕ) (ε : ℝ) (c : MainGridCode d C r ε) (x : Cube d) : ℝ :=
  networkOutput relu (gridWeights d (mainPopulationBound d C r ε) r
    (gridResolution d (mainPopulationBound d C r ε) r (1+Real.sqrt (mainEnergyBound d C r ε)))
    (1+Real.sqrt (mainEnergyBound d C r ε)) c) x

theorem mainReadoutBound_ge_eight {ε : ℝ} (hε : 0<ε) (hε1 : ε≤1) :
    8≤mainReadoutBound d C r ε := by
  have hlog : Real.log (ε/4)≤0 := Real.log_nonpos (by positivity) (by linarith)
  have hD := mergingTargetCost_nonneg d C r
  unfold mainReadoutBound
  linarith

theorem mainPopulationBound_pos {ε : ℝ} (hε : 0<ε) (hε1 : ε≤1) :
    0<mainPopulationBound d C r ε := by
  have hB := mainReadoutBound_ge_eight (d:=d) (C:=C) (r:=r) hε hε1
  apply Nat.ceil_pos.mpr
  linarith

/-- Explicit finite-class bound, simultaneously over every permitted learner.
The subsequent polynomial bookkeeping can upper-bound the displayed grid
entropy without changing this actual-posterior statement. -/
theorem all_width_all_scale_relu_learning (hd : 0<d) (hC : 0<C)
    (B : LayeredNorCircuit d C r) (D : Measure (Cube d)) [IsProbabilityMeasure D]
    {ε δ : ℝ} (hε : 0<ε) (hε1 : ε≤1) (hδ : 0<δ)
    (n : ℕ) (hn : 0<n)
    (hbudget : 2*(Real.log (Fintype.card (MainGridCode d C r ε):ℝ)+Real.log (1/δ))≤
      (n:ℝ)*(ε/2)) :
    ∃A : Set (Fin n→Cube d), MeasurableSet A ∧
      1-δ≤(CompressionSampling.iidSamples D n).real A ∧
      ∀sample∈A,∀N,C≤N→∀σ,0<σ→(N:ℝ)*σ^2≤1→∀globalMargin : Bool,
        0<(smallPrior d N r σ).real (posteriorEvent relu globalMargin B.computes sample) ∧
        RobustConfidence.gibbsMarginRisk D
          (posterior (N:=N) (r:=r) relu globalMargin σ B.computes sample)
          (fun x=>labelReal (B.computes x)) (fun w x=>networkOutput relu w x) (1/4)≤ε := by
  classical
  letI : Nonempty (MainGridCode d C r ε) := ⟨fun _=>⟨0,by simp⟩⟩
  let g := mainGridFunction d C r ε
  let loss := comparisonLoss B.computes g
  let A := BatchTwoRelativeStatistics.generalizationEvent D loss n (ε/2)
  have hprob : 1-δ≤(CompressionSampling.iidSamples D n).real A := by
    apply BatchTwoRelativeStatistics.finite_class_good_probability_log D loss
      (fun _=>measurable_of_finite _) (comparisonLoss_bounds B.computes g) n hn hδ
      (le_refl _) hbudget
  refine ⟨A,BatchTwoRelativeStatistics.measurable_generalizationEvent D loss
    (fun _=>measurable_of_finite _) n (ε/2),hprob,?_⟩
  intro sample hsample N hCN σ hσ hscale globalMargin
  have hN : 0<N := hC.trans_le hCN
  have hmass := merging_target_mass_all_widths hd hC hCN B hσ hscale
  have hpos := posterior_event_pos relu globalMargin σ B.computes sample hmass
  refine ⟨hpos,?_⟩
  have hE0 : (smallPrior d N r σ) (posteriorEvent relu globalMargin B.computes sample)≠0 := by
    intro he
    simp only [Measure.real,he,ENNReal.toReal_zero] at hpos
    exact (lt_irrefl 0) hpos
  let P := posterior (N:=N) (r:=r) relu globalMargin σ B.computes sample
  letI : IsProbabilityMeasure P := cond_isProbabilityMeasure hE0
  let B0 := mainReadoutBound d C r ε
  let Q0 := mainPopulationBound d C r ε
  let J0 := mainEnergyBound d C r ε
  have hQ : 0<Q0 := mainPopulationBound_pos hε hε1
  have hβ : 0<ε/4 := by positivity
  have hβ1 : ε/4≤1 := by linarith
  have htail1 : P.real {w | B0<readoutEnergy w}≤ε/4 := by
    apply posterior_readout_tail hd hN continuous_relu globalMargin hσ hscale B.computes sample
      hβ hβ1 (mainReadoutBound_ge_eight hε hε1) _ hmass
    dsimp [B0,mainReadoutBound]
    linarith
  have htail2 : P.real (exceptionalPartitions (Q:=Q0) J0)≤ε/4 := by
    apply posterior_exceptionalPartitions_tail hd hN hQ continuous_relu globalMargin hσ hscale
      B.computes sample hβ hβ1 _ hmass
    exact le_refl _
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
  have hrisk := finite_cover_posterior_risk D P B.computes g sample (by positivity : 0≤ε/2)
    hsample (fun w x=>networkOutput relu w x)
    (fun x=>(continuous_networkOutput continuous_relu x).measurable) E hE htail hgood
  exact hrisk.trans (by linarith)

end NeuralGeneralization.BatchTwoMerging
