import NeuralGeneralization.BatchTwoOnlineRawPosteriorControl
import NeuralGeneralization.BatchTwoMergingGeluPolynomialMain

/-! The actual merging-restricted posterior has a fixed grid comparison class
and a uniformly small exceptional mass at every nonempty history. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineRaw
open ConcreteModel BatchTwoMerging

 theorem gelu_merging_posterior_cover {d C r N n : ℕ} (hd : 0<d) (hC : 0<C)
    (B : LayeredNorCircuit d C r) (hCN : 2*C ≤ N) {σ ε : ℝ}
    (hσ : 0<σ) (hscale : (N : ℝ)*σ^2≤1) (hε : 0<ε) (hε1 : ε≤1)
    (globalMargin : Bool) (sample : Fin n→Cube d) (hn : 0<n) :
    let P := BatchTwoMerging.posterior (N:=N) (r:=r) gelu globalMargin σ B.computes sample
    IsProbabilityMeasure P ∧ ∃ E : Set (Weights d N r), MeasurableSet E ∧ P.real E≤ε/2 ∧
      ∀ᵐ w ∂P, (∀i,(1/2 : ℝ)<labelReal (B.computes (sample i))*networkOutput gelu w (sample i)) ∧
        (w∉E→∃c : GeluMainGridCode d C r ε,∀x,
          |clippedScore (networkOutput gelu w x)-clippedScore (geluMainGridFunction d C r ε c x)|≤3/32) := by
  classical
  dsimp only
  have hN : 0<N := (Nat.mul_pos (by omega : 0<2) hC).trans_le hCN
  have hmass := gelu_merging_target_mass_all_widths hd hC hCN B hσ hscale
  have hpos := posterior_event_pos gelu globalMargin σ B.computes sample hmass
  have hE0 : (smallPrior d N r σ) (posteriorEvent gelu globalMargin B.computes sample)≠0 := by
    intro he
    simp only [Measure.real,he,ENNReal.toReal_zero] at hpos
    exact (lt_irrefl 0) hpos
  let P := BatchTwoMerging.posterior (N:=N) (r:=r) gelu globalMargin σ B.computes sample
  letI : IsProbabilityMeasure P := cond_isProbabilityMeasure hE0
  let B0 := geluMainReadoutBound d C r ε
  let Q0 := geluMainPopulationBound d C r ε
  let J0 := geluMainEnergyBound d C r ε
  have hQ : 0<Q0 := geluMainPopulationBound_pos hε hε1
  have hβ : 0<ε/4 := by positivity
  have hβ1 : ε/4≤1 := by linarith
  have htail1 : P.real {w | B0<readoutEnergy w}≤ε/4 := by
    apply posterior_readout_tail hd hN gelu_lipschitz.continuous globalMargin hσ hscale B.computes sample
      hβ hβ1 (geluMainReadoutBound_ge_eight hε hε1) _ hmass
    dsimp [B0,geluMainReadoutBound]
    linarith
  have htail2 : P.real (exceptionalPartitions (Q:=Q0) J0)≤ε/4 := by
    apply posterior_exceptionalPartitions_tail hd hN hQ gelu_lipschitz.continuous globalMargin hσ hscale
      B.computes sample hβ hβ1 _ hmass
    exact le_refl _
  let E : Set (Weights d N r) := {w | B0<readoutEnergy w} ∪ exceptionalPartitions (Q:=Q0) J0
  have hE : MeasurableSet E := (measurableSet_lt measurable_const continuous_readoutEnergy.measurable).union
    (measurable_exceptionalPartitions J0)
  have htail : P.real E≤ε/2 := (measureReal_union_le _ _).trans (by linarith)
  refine ⟨inferInstance,E,hE,htail,?_⟩
  filter_upwards [ae_cond_mem (μ:=smallPrior d N r σ)
    (measurable_posteriorEvent gelu_lipschitz.continuous globalMargin B.computes sample)] with w hw
  refine ⟨hw.2,?_⟩
  intro he
  have hb : readoutEnergy w≤B0 := le_of_not_gt (fun h=>he (Or.inl h))
  have hj : w∉exceptionalPartitions (Q:=Q0) J0 := fun h=>he (Or.inr h)
  exact gelu_posteriorEvent_grid_cover hd hN hn globalMargin B.computes sample w hw hb hj

end NeuralGeneralization.BatchTwoOnlineRaw
