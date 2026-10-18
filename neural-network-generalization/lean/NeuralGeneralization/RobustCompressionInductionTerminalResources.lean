import NeuralGeneralization.RobustCouplingTerminalPath
import NeuralGeneralization.RobustCompressionTerminalResourceAllocations
import NeuralGeneralization.RobustCompressionInductionResources

/-! # Literal terminal resources give actual raw-path compression

This closes the terminal construction from the actual common state law and
its aligned histories. The final candidate is the explicit readout-sampling
law. No raw-path or score-coupling premise is assumed.
-/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal BigOperators
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustEntropy RobustCompressionCanonicalLayer
set_option maxHeartbeats 400000

/-- The declared readout cutoff pays for the doubled terminal entropy budget. -/
theorem terminal_energy_resource_bound (p : RobustCompressionInput) {N r : ℕ} [NeZero N]
    (Γ : Measure (TerminalState p.dimension N p.bankSize r)) [IsProbabilityMeasure Γ]
    {t : ℝ} (ht : 0 < t) (ht1 : t^2 ≤ 1) (hη : 0 < p.inverseLayerFailure)
    (hKL : futureEntropy Γ (futurePrior N 0) ≤
      ENNReal.ofReal (2*N*(p.energy : ℝ)/t^2)) :
    Γ.real {z | (p.readoutMoment : ℝ) < terminalEnergy t z.2} ≤
      2/(p.inverseLayerFailure : ℝ) := by
  have hK : (0 : ℝ) < p.readoutMoment := by
    unfold RobustCompressionInput.readoutMoment
    positivity
  have hKL' : futureEntropy Γ (futurePrior N 0) ≤
      ENNReal.ofReal (N*(2*(p.energy : ℝ))/t^2) := by
    simpa only [mul_assoc,mul_left_comm,mul_comm] using hKL
  have h := terminal_energy_abort_of_entropy (NeZero.pos N) Γ ht ht1
    (by positivity : 0 ≤ 2*(p.energy : ℝ)) hK hKL'
  apply h.trans
  have hηr : (0 : ℝ) < p.inverseLayerFailure := by exact_mod_cast hη
  apply (div_le_div_iff₀ hK hηr).mpr
  simp only [RobustCompressionInput.readoutMoment,Nat.cast_mul,Nat.cast_add,Nat.cast_ofNat]
  nlinarith [show (0 : ℝ) ≤ p.energy from Nat.cast_nonneg p.energy]

/-- The accumulated first/layer cost fits the declared whole-depth budget. -/
theorem terminal_history_cost_allocation (p : RobustCompressionInput) {r : ℕ}
    (hdepth : r+2 ≤ p.depth) (hE : 0 < p.inverseLayerError) :
    ENNReal.ofReal (1/(p.inverseLayerError : ℝ)) +
      r • ENNReal.ofReal (10/(p.inverseLayerError : ℝ)) ≤
      ENNReal.ofReal (10*(p.depth : ℝ)/p.inverseLayerError) := by
  rw [← ENNReal.ofReal_nsmul,← ENNReal.ofReal_add (by positivity) (by positivity)]
  apply ENNReal.ofReal_le_ofReal
  rw [nsmul_eq_mul]
  have hr : (r : ℝ)+2 ≤ p.depth := by exact_mod_cast hdepth
  have he : (0 : ℝ) < p.inverseLayerError := by exact_mod_cast hE
  have heq : 1/(p.inverseLayerError : ℝ) + r*(10/(p.inverseLayerError : ℝ)) =
      (1+10*r)/(p.inverseLayerError : ℝ) := by ring
  rw [heq]
  apply (div_le_div_iff_of_pos_right he).mpr
  nlinarith

/-- Final actual compression from the supplied terminal state and histories.
The entropy and history assumptions are exactly the invariants of the
selected canonical run, and the resulting candidate law is explicit. -/
theorem rawPathCompression_of_resource_terminal_histories
    (p : RobustCompressionInput) {N r : ℕ} [NeZero N]
    (hdepth : r+2 ≤ p.depth) (hA : 0 < p.inverseFailure) (hR : 0 < p.inverseRadius)
    {σ : ℝ} (hσ : 0 < σ) (hscale : (N : ℝ)*σ^2 ≤ 1)
    {φ : ℝ → ℝ} (hφ : Continuous φ) (hφbound : ∀ z, |φ z| ≤ 1)
    (Q : Measure (Weights p.dimension N r))
    (Γ : Measure (TerminalState p.dimension N p.bankSize r)) [IsProbabilityMeasure Γ]
    (hKL : futureEntropy Γ (futurePrior N 0) ≤
      ENNReal.ofReal (2*N*(p.energy : ℝ)/(σ*Real.sqrt (N : ℝ))^2))
    (hbounded : ∀ᵐ z ∂Γ,activePrefixBounded (p.largeWeightBound : ℝ) z.1)
    (hhistory : ∀ x : Cube p.dimension, ∃ P : CanonicalHistoryComparison Q Γ
        (Prod.fst : OriginalHistory p.dimension N r r → Weights p.dimension N r),
      (∀ᵐ z ∂P.joint,HistoryAligned (by omega : r+0 ≤ r) σ φ x z.1 z.2) ∧
      (∫⁻ z,liveOriginalCost (m:=p.bankSize) (k:=0) le_rfl φ x z ∂P.joint) ≤
        ENNReal.ofReal (1/(p.inverseLayerError : ℝ)) +
          r • ENNReal.ofReal (10/(p.inverseLayerError : ℝ)))
    (habort : Γ.real {z | z.1.1 ≠ true} ≤ 2*(r : ℝ)/p.inverseLayerFailure) :
    RawPathCompression φ Q
      (terminalCandidateLaw Γ (σ*Real.sqrt (N : ℝ)) p.readoutClip p.readoutMoment)
      p.weightBound (1/(p.inverseRadius : ℝ)) (1/(p.inverseFailure : ℝ)) := by
  have hL : 0 < p.depth := by omega
  have hη := p.inverseLayerFailure_pos hL hA
  have hE := p.inverseLayerError_pos hL hA hR
  have hηr : (0 : ℝ) < p.inverseLayerFailure := by exact_mod_cast hη
  have hEr : (0 : ℝ) < p.inverseLayerError := by exact_mod_cast hE
  have hRr : (0 : ℝ) < p.inverseRadius := by exact_mod_cast hR
  have hNr : (0 : ℝ) < N := Nat.cast_pos.mpr (NeZero.pos N)
  have ht : 0 < σ*Real.sqrt (N : ℝ) := by positivity
  have ht1 : (σ*Real.sqrt (N : ℝ))^2 ≤ 1 := by
    rw [physicalScale_sq]
    nlinarith [hscale]
  have hBW : (p.readoutClip : ℝ) ≤ p.weightBound := by
    exact_mod_cast (show p.readoutClip ≤ p.weightBound by
      unfold RobustCompressionInput.weightBound RobustCompressionInput.largeWeightBound
      omega)
  have hlarge : (p.largeWeightBound : ℝ) ≤ p.weightBound := by
    exact_mod_cast (show p.largeWeightBound ≤ p.weightBound by
      unfold RobustCompressionInput.weightBound
      omega)
  have hb : ∀ᵐ z ∂Γ,activePrefixBounded (p.weightBound : ℝ) z.1 :=
    hbounded.mono (fun z hz => activePrefixBounded_mono hlarge z.1 hz)
  have henergy := terminal_energy_resource_bound p Γ ht ht1 hη hKL
  have hsample := terminalCoupling_resource_tail p Γ hφ hφbound
    (σ*Real.sqrt (N : ℝ)) hη hR
  have hhist : ∀ x : Cube p.dimension, ∃ P : CanonicalHistoryComparison Q Γ
        (Prod.fst : OriginalHistory p.dimension N r r → Weights p.dimension N r),
      (∀ᵐ z ∂P.joint,HistoryAligned (by omega : r+0 ≤ r) σ φ x z.1 z.2) ∧
      (∫⁻ z,liveOriginalCost (m:=p.bankSize) (k:=0) le_rfl φ x z ∂P.joint) ≤
        ENNReal.ofReal (10*(p.depth : ℝ)/p.inverseLayerError) ∧
      P.joint.real {z | z.2.1.1 ≠ true} ≤ 2*(p.depth : ℝ)/p.inverseLayerFailure := by
    intro x
    obtain ⟨P,ha,hc⟩ := hhistory x
    refine ⟨P,ha,hc.trans (terminal_history_cost_allocation p hdepth hE),?_⟩
    have hs : MeasurableSet {z : TerminalState p.dimension N p.bankSize r | z.1.1 ≠ true} :=
      (measurableSet_eq_fun (by fun_prop) measurable_const).compl
    have hm := map_measureReal_apply (μ:=P.joint) measurable_snd hs
    rw [P.state_marginal] at hm
    have hr : (r : ℝ) ≤ p.depth := by exact_mod_cast (show r ≤ p.depth by omega)
    exact hm.symm.trans_le (habort.trans
      (div_le_div_of_nonneg_right (by linarith) hηr.le))
  apply rawPathCompression_of_terminal_histories p.bankSize_pos hσ hφ Q Γ
    (B:=p.readoutClip) (K:=p.readoutMoment) (W:=p.weightBound)
    (η:=1/(16*(p.inverseRadius : ℝ)))
    (E:=10*(p.depth : ℝ)/p.inverseLayerError)
    (abort:=2*(p.depth : ℝ)/p.inverseLayerFailure)
    (energyFailure:=2/(p.inverseLayerFailure : ℝ))
    (sampleFailure:=(p.inverseLayerFailure : ℝ)⁻¹)
    (by positivity) (by positivity) hBW (by positivity) (by positivity) hb hhist
  · simpa only [one_div] using p.terminal_readout_error_allocation hL hA hR
      (radius := (p.inverseRadius : ℝ)⁻¹) le_rfl
  · exact henergy
  · exact hsample
  · have hf := p.terminal_failure_allocation hL hA hR
      (radius := (p.inverseRadius : ℝ)⁻¹) le_rfl
    convert hf using 1 <;> ring

end NeuralGeneralization.RobustCompressionInduction
