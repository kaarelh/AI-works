import NeuralGeneralization.BatchTwoOnlineTanhPosterior
import NeuralGeneralization.BatchTwoOnlineRawPosteriorControl

/-! One width-independent comparison class controls the literal signed-tanh posterior. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineTanhMerging
open ConcreteModel BatchTwoMerging
variable {d C r : ℕ}

def tanhMainReadoutBound (d C r : ℕ) (c0 ε : ℝ) : ℝ :=
  8+4*(tanhMergeTargetCost d C r c0-Real.log (ε/4))
def tanhMainPopulationBound (d C r : ℕ) (c0 ε : ℝ) : ℕ := ⌈1+16*tanhMainReadoutBound d C r c0 ε⌉₊
def tanhMainEnergyBound (d C r : ℕ) (c0 ε : ℝ) : ℝ :=
  4*(tanhMergeTargetCost d C r c0+signedPartitionEntropyBudget d r (tanhMainPopulationBound d C r c0 ε)-Real.log (ε/4))
abbrev TanhMainGridCode (d C r : ℕ) (c0 ε : ℝ) :=
  TanhGridCode d (tanhMainPopulationBound d C r c0 ε) r
    (tanhGridResolution d (tanhMainPopulationBound d C r c0 ε) r (1+Real.sqrt (tanhMainEnergyBound d C r c0 ε)))
def tanhMainGridFunction (d C r : ℕ) (c0 ε : ℝ) (c : TanhMainGridCode d C r c0 ε) (x : Cube d) : ℝ :=
  perspectiveOutput
    (tanhGridWeights d (tanhMainPopulationBound d C r c0 ε) r
      (tanhGridResolution d (tanhMainPopulationBound d C r c0 ε) r (1+Real.sqrt (tanhMainEnergyBound d C r c0 ε)))
      (1+Real.sqrt (tanhMainEnergyBound d C r c0 ε)) c)
    (tanhGridMasses d (tanhMainPopulationBound d C r c0 ε) r
      (tanhGridResolution d (tanhMainPopulationBound d C r c0 ε) r (1+Real.sqrt (tanhMainEnergyBound d C r c0 ε))) c) x

theorem tanhMainReadoutBound_ge_eight (hC : 0<C) (c0 : ℝ) {ε : ℝ} (hε : 0<ε) (hε1 : ε≤1) :
    8≤tanhMainReadoutBound d C r c0 ε := by
  have hlog : Real.log (ε/4)≤0 := Real.log_nonpos (by positivity) (by linarith)
  have hD := tanhMergeTargetCost_nonneg d r hC c0
  unfold tanhMainReadoutBound
  linarith

theorem tanhMainPopulationBound_pos (hC : 0<C) (c0 : ℝ) {ε : ℝ} (hε : 0<ε) (hε1 : ε≤1) :
    0<tanhMainPopulationBound d C r c0 ε := by
  have hB := tanhMainReadoutBound_ge_eight (d:=d) (C:=C) (r:=r) hC c0 hε hε1
  apply Nat.ceil_pos.mpr
  linarith

 theorem tanh_merging_posterior_cover {d C r N n : ℕ} (hd : 0<d) (hC : 0<C)
    (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N) {c0 σ ε : ℝ} (hc0 : 0<c0)
    (hσ : 0<σ) (hscale : (N : ℝ)*σ^2≤1) (hε : 0<ε) (hε1 : ε≤1)
    (noiseMargin globalMargin : Bool) (sample : Fin n→Cube d) (hn : 0<n) :
    let P := tanhPosterior (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes sample
    IsProbabilityMeasure P ∧ ∃ E : Set (Weights d N r), MeasurableSet E ∧ P.real E≤ε/2 ∧
      ∀ᵐ w ∂P, (∀i,(1/2 : ℝ)<labelReal (B.computes (sample i))*networkOutput Real.tanh w (sample i)) ∧
        (w∉E→∃c : TanhMainGridCode d C r c0 ε,∀x,
          |clippedScore (networkOutput Real.tanh w x)-clippedScore (tanhMainGridFunction d C r c0 ε c x)|≤3/32) := by
  classical
  dsimp only
  have hN : 0<N := hC.trans_le hCN
  let P := tanhPosterior (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes sample
  letI : IsProbabilityMeasure P := tanh_posterior_probability hd hC hCN B hc0 hσ hscale noiseMargin globalMargin sample
  let B0 := tanhMainReadoutBound d C r c0 ε
  let Q0 := tanhMainPopulationBound d C r c0 ε
  let J0 := tanhMainEnergyBound d C r c0 ε
  have hQ : 0<Q0 := tanhMainPopulationBound_pos hC c0 hε hε1
  have hβ : 0<ε/4 := by positivity
  have hβ1 : ε/4≤1 := by linarith
  have htail1 : P.real {w | B0<readoutEnergy w}≤ε/4 := by
    apply tanh_posterior_readout_tail hd hC hCN B hc0 hσ hscale noiseMargin globalMargin sample
      hβ hβ1 (tanhMainReadoutBound_ge_eight hC c0 hε hε1) _
    dsimp [B0,tanhMainReadoutBound]
    linarith
  have htail2 : P.real (signedExceptionalPartitions (Q:=Q0) J0)≤ε/4 := by
    apply tanh_posterior_exceptional_tail hd hC hCN hQ B hc0 hσ hscale noiseMargin globalMargin sample hβ hβ1 _
    exact le_refl _
  let E : Set (Weights d N r) := {w | B0<readoutEnergy w} ∪ signedExceptionalPartitions (Q:=Q0) J0
  have hE : MeasurableSet E := (measurableSet_lt measurable_const continuous_readoutEnergy.measurable).union
    (measurable_signedExceptionalPartitions J0)
  have htail : P.real E≤ε/2 := (measureReal_union_le _ _).trans (by linarith)
  refine ⟨inferInstance,E,hE,htail,?_⟩
  filter_upwards [ae_cond_mem (μ:=smallPrior d N r σ)
    (measurable_tanhPosteriorEvent noiseMargin globalMargin hc0 B.computes sample)] with w hw
  refine ⟨hw.2,?_⟩
  intro he
  have hb : readoutEnergy w≤B0 := le_of_not_gt (fun h=>he (Or.inl h))
  have hj : w∉signedExceptionalPartitions (Q:=Q0) J0 := fun h=>he (Or.inr h)
  exact tanh_posteriorEvent_grid_cover hd hN hn noiseMargin globalMargin c0 B.computes sample w hw hb hj


end NeuralGeneralization.BatchTwoOnlineTanhMerging
