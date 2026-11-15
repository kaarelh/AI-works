import NeuralGeneralization.BatchTwoManuscriptReadoutKernel
import NeuralGeneralization.BatchTwoManuscriptReadoutAllocation
import NeuralGeneralization.RobustCompressionTerminalCoupling

/-! The common final-network law and its integrated all-input readout tail.
The original terminal state may have arbitrary prefix/readout dependence. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoManuscriptReadout
open ConcreteModel RobustCompressionInduction RobustStatistics
variable {d N m s : ℕ}

def candidateLaw (hN : 0<N) (Q : Measure (TerminalState d N m s)) (t K : ℝ) :
    Measure (Weights d m s) := (Q ⊗ₘ terminalKernel hN t K).snd

instance candidateLaw_probability (hN : 0<N) (Q : Measure (TerminalState d N m s))
    [IsProbabilityMeasure Q] (t K : ℝ) : IsProbabilityMeasure (candidateLaw hN Q t K) := by
  unfold candidateLaw
  infer_instance

def coupling (hN : 0<N) (Q : Measure (TerminalState d N m s)) [IsProbabilityMeasure Q]
    (t K : ℝ) : ProbabilityCoupling Q (candidateLaw hN Q t K) where
  joint := Q ⊗ₘ terminalKernel hN t K
  probability := inferInstance
  left := Measure.fst_compProd Q _
  right := rfl

def outputFailure (φ : ℝ→ℝ) (t K radius : ℝ) : Set (TerminalState d N m s×Weights d m s) :=
  {z | terminalEnergy t z.1.2≤K ∧ ∃x : Cube d,
    radius≤|networkOutput φ z.2 x-terminalOriginalOutput φ t z.1 x|}

theorem measurableSet_outputFailure {φ : ℝ→ℝ} (hφ : Continuous φ) (t K radius : ℝ) :
    MeasurableSet (outputFailure (d:=d) (N:=N) (m:=m) (s:=s) φ t K radius) := by
  have hs (x : Cube d) : MeasurableSet {z : TerminalState d N m s×Weights d m s |
      radius≤|networkOutput φ z.2 x-terminalOriginalOutput φ t z.1 x|} :=
    measurableSet_le measurable_const (((continuous_networkOutput hφ x).measurable.comp measurable_snd).sub
      ((measurable_terminalOriginalOutput hφ t x).comp measurable_fst)).abs
  unfold outputFailure
  have he : {z : TerminalState d N m s×Weights d m s |
      terminalEnergy t z.1.2≤K ∧ ∃x : Cube d,radius≤|networkOutput φ z.2 x-terminalOriginalOutput φ t z.1 x|}=
      {z | terminalEnergy t z.1.2≤K} ∩ ⋃x : Cube d,
        {z | radius≤|networkOutput φ z.2 x-terminalOriginalOutput φ t z.1 x|} := by ext z; simp
  rw [he]
  exact (measurableSet_le ((measurable_terminalEnergy t).comp (by fun_prop)) measurable_const).inter
    (MeasurableSet.iUnion hs)

theorem coupling_sampling_tail (hN : 0<N) (hm : 0<m)
    (Q : Measure (TerminalState d N m s)) [IsProbabilityMeasure Q]
    {φ : ℝ→ℝ} (hφ : Continuous φ) (hb : ∀z,|φ z|≤1)
    {t K radius : ℝ} (hK : 0<K) (hr : 0≤radius) :
    (coupling hN Q t K).joint.real (outputFailure φ t K radius)≤
      (2:ℝ)^d*(2*Real.exp (-(m:ℝ)*radius^2/(2*K))) := by
  let δ := (2:ℝ)^d*(2*Real.exp (-(m:ℝ)*radius^2/(2*K)))
  have hslice (p : TerminalState d N m s) :
      terminalKernel hN t K p (Prod.mk p ⁻¹' outputFailure φ t K radius)≤ENNReal.ofReal δ := by
    have hd : Measurable (draw t K p) := by
      simpa only [Function.comp_def] using
        (measurable_draw (d:=d) (N:=N) (m:=m) (s:=s) t K).comp (measurable_prodMk_left (x:=p))
    have hs : MeasurableSet (Prod.mk p ⁻¹' outputFailure φ t K radius) :=
      (measurableSet_outputFailure hφ t K radius).preimage measurable_prodMk_left
    rw [terminalKernel_apply,Measure.map_apply hd hs]
    by_cases he : terminalEnergy t p.2≤K
    · have ht := draw_sampling_tail hN hm φ hb hK hr p he
      have hc := ENNReal.ofReal_le_ofReal ht
      rw [measureReal_def,ENNReal.ofReal_toReal (measure_ne_top _ _),stateIndicesKernel_apply] at hc
      simpa only [outputFailure,Set.preimage_setOf_eq,he,true_and,terminalOriginalOutput,δ] using hc
    · have hz : (draw t K p) ⁻¹' (Prod.mk p ⁻¹' outputFailure φ t K radius)=∅ := by
        ext I
        simp [outputFailure,he]
      rw [hz,measure_empty]
      exact zero_le
  have hg : (Q ⊗ₘ terminalKernel hN t K) (outputFailure φ t K radius)≤ENNReal.ofReal δ := by
    rw [Measure.compProd_apply (measurableSet_outputFailure hφ t K radius)]
    exact (lintegral_mono hslice).trans_eq (by simp)
  have ht := ENNReal.toReal_mono ENNReal.ofReal_ne_top hg
  rw [ENNReal.toReal_ofReal (by dsimp [δ]; positivity)] at ht
  exact ht

theorem candidateLaw_bounded (hN : 0<N) (Q : Measure (TerminalState d N m s))
    [IsProbabilityMeasure Q] {t K B : ℝ} (hB : 0≤B) (hb : Real.sqrt K/(m:ℝ)≤B)
    (hQ : ∀ᵐp ∂Q,activePrefixBounded B p.1) :
    ∀ᵐw ∂candidateLaw hN Q t K,boundedWeights B w := by
  have hs : MeasurableSet {w : Weights d m s | boundedWeights B w} := by
    change MeasurableSet {w : Weights d m s | ∀i,|w i|≤B}
    rw [Set.setOf_forall]
    exact MeasurableSet.iInter (fun i=>measurableSet_le (measurable_pi_apply i).abs measurable_const)
  change ∀ᵐw ∂(Q ⊗ₘ terminalKernel hN t K).map Prod.snd,boundedWeights B w
  apply (ae_map_iff measurable_snd.aemeasurable hs).mpr
  apply (Measure.ae_compProd_iff (hs.preimage measurable_snd)).mpr
  filter_upwards [hQ] with p hp
  rw [terminalKernel_apply]
  apply (ae_map_iff ((measurable_draw (d:=d) (N:=N) (m:=m) (s:=s) t K).comp (measurable_prodMk_left (x:=p))).aemeasurable hs).mpr
  exact Filter.Eventually.of_forall (fun I=>draw_bounded hN hB hb p hp I)

theorem coupling_literal_tail (p : BatchTwoManuscriptResources.Input) {N s : ℕ} (hN : 0<N)
    (Q : Measure (TerminalState p.dimension N (BatchTwoManuscriptResources.bankSize p) s))
    [IsProbabilityMeasure Q] {φ : ℝ→ℝ} (hφ : Continuous φ) (hb : ∀z,|φ z|≤1) (t : ℝ) :
    (coupling hN Q t (BatchTwoManuscriptResources.readoutEnergy p)).joint.real
      (outputFailure φ t (BatchTwoManuscriptResources.readoutEnergy p) (p.radius/16))≤
      BatchTwoManuscriptResources.localFailure p :=
  (coupling_sampling_tail hN (BatchTwoManuscriptResources.bankSize_pos p) Q hφ hb
    (BatchTwoManuscriptResources.readoutEnergy_pos p) (by have := p.radius_pos; positivity)).trans
      (BatchTwoManuscriptResources.readout_sampling_allocation p)

end NeuralGeneralization.BatchTwoManuscriptReadout
