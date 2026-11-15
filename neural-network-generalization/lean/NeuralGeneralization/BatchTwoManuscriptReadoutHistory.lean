import NeuralGeneralization.BatchTwoManuscriptReadoutJoint

/-! # Actual terminal sampling joined to the full original hidden path -/
noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Set
open scoped ENNReal BigOperators
namespace NeuralGeneralization.BatchTwoManuscriptReadout
open ConcreteModel RobustStatistics RobustCompression RobustCompressionInduction

variable {d N m r : ℕ}

/-- The actual final readout comparison retains the complete original path. -/
def historyJoint [NeZero N] {Q : Measure (Weights d N r)}
    {Γ : Measure (TerminalState d N m r)} [IsProbabilityMeasure Γ]
    (P : CanonicalHistoryComparison Q Γ (Prod.fst : OriginalHistory d N r r → Weights d N r))
    (t K : ℝ) : Measure (TerminalHistorySpace d N m r) :=
  glue P.joint (coupling (NeZero.pos N) Γ t K).joint

instance historyJoint_probability [NeZero N] {Q : Measure (Weights d N r)}
    {Γ : Measure (TerminalState d N m r)} [IsProbabilityMeasure Γ]
    (P : CanonicalHistoryComparison Q Γ (Prod.fst : OriginalHistory d N r r → Weights d N r))
    (t K : ℝ) : IsProbabilityMeasure (historyJoint P t K) := by
  unfold historyJoint
  infer_instance

theorem historyJoint_old [NeZero N] {Q : Measure (Weights d N r)}
    {Γ : Measure (TerminalState d N m r)} [IsProbabilityMeasure Γ]
    (P : CanonicalHistoryComparison Q Γ (Prod.fst : OriginalHistory d N r r → Weights d N r))
    (t K : ℝ) : (historyJoint P t K).map Prod.fst=P.joint :=
  glue_old _ _

theorem historyJoint_new [NeZero N] {Q : Measure (Weights d N r)}
    {Γ : Measure (TerminalState d N m r)} [IsProbabilityMeasure Γ]
    (P : CanonicalHistoryComparison Q Γ (Prod.fst : OriginalHistory d N r r → Weights d N r))
    (t K : ℝ) : (historyJoint P t K).map (fun z => (z.1.2,z.2))=
      (coupling (NeZero.pos N) Γ t K).joint :=
  glue_new _ _ (P.state_marginal.trans (coupling (NeZero.pos N) Γ t K).left.symm)

def historyRawCoupling [NeZero N] {Q : Measure (Weights d N r)}
    {Γ : Measure (TerminalState d N m r)} [IsProbabilityMeasure Γ]
    (P : CanonicalHistoryComparison Q Γ (Prod.fst : OriginalHistory d N r r → Weights d N r))
    (t K : ℝ) : RawPathCoupling Q (candidateLaw (NeZero.pos N) Γ t K) := by
  apply RawPathCoupling.ofFields Q (candidateLaw (NeZero.pos N) Γ t K) (historyJoint P t K)
    (fun z => z.1.1.1) (fun z => z.2) (fun z => z.1.1.2)
    (by fun_prop) measurable_snd (by fun_prop)
  · have he := congrArg (fun μ => μ.map (fun z : OriginalHistory d N r r × TerminalState d N m r => z.1.1))
      (historyJoint_old P t K)
    rw [Measure.map_map (by fun_prop) measurable_fst] at he
    exact he.trans P.original_marginal
  · have he := congrArg (fun μ => μ.map Prod.snd) (historyJoint_new P t K)
    rw [Measure.map_map measurable_snd (by fun_prop)] at he
    exact he.trans (coupling (NeZero.pos N) Γ t K).right


/-- Final readout sampling and projection retain every stored hidden state. -/
theorem historyRawCoupling_valid [NeZero N]
    {Q : Measure (Weights d N r)} {Γ : Measure (TerminalState d N m r)} [IsProbabilityMeasure Γ]
    (P : CanonicalHistoryComparison Q Γ (Prod.fst : OriginalHistory d N r r → Weights d N r))
    (t K : ℝ) (hvalid : ∀ᵐ z ∂P.joint,validHiddenPath z.1.2) :
    ∀ᵐ z ∂(historyRawCoupling P t K).joint,validHiddenPath z.2.2 := by
  change ∀ᵐ z ∂(historyJoint P t K).map
    (fun z => (z.1.1.1,z.2,z.1.1.2)),validHiddenPath z.2.2
  apply (ae_map_iff (by fun_prop)
    ((measurableSet_validHiddenPath N r).preimage (by fun_prop))).mpr
  change ∀ᵐ z ∂historyJoint P t K,validHiddenPath z.1.1.2
  apply ae_of_ae_map (μ := historyJoint P t K) (f := Prod.fst)
    (p := fun z : OriginalHistory d N r r × TerminalState d N m r => validHiddenPath z.1.2) measurable_fst.aemeasurable
  rwa [historyJoint_old]

/-- Live readout discrepancy is covered by actual terminal energy abort and
actual all-input sampling failure. Alignment is needed only almost everywhere. -/
theorem history_readout_failure_le [NeZero N] {σ : ℝ} (hσ : 0 < σ)
    {φ : ℝ → ℝ} (hφ : Continuous φ) (x : Cube d)
    {Q : Measure (Weights d N r)} {Γ : Measure (TerminalState d N m r)} [IsProbabilityMeasure Γ]
    (P : CanonicalHistoryComparison Q Γ (Prod.fst : OriginalHistory d N r r → Weights d N r))
    {K η radius energyFailure sampleFailure : ℝ}
    (halign : ∀ᵐ z ∂P.joint,HistoryAligned (by omega : r+0 ≤ r) σ φ x z.1 z.2)
    (hthreshold : η ≤ radius/8)
    (henergy : Γ.real {p | K < terminalEnergy (σ*Real.sqrt (N : ℝ)) p.2} ≤ energyFailure)
    (hsample : (coupling (NeZero.pos N) Γ (σ*Real.sqrt (N : ℝ)) K).joint.real
      (outputFailure φ (σ*Real.sqrt (N : ℝ)) K η) ≤ sampleFailure) :
    (historyJoint P (σ*Real.sqrt (N : ℝ)) K).real
      ({z | z.1.2.1.1=true} ∩ {z | radius/8 < |networkOutput φ z.2 x -
        ∑ i,z.1.1.1 (Sum.inr (Sum.inr i))*z.1.1.2 (Fin.last r) i|}) ≤
      energyFailure+sampleFailure := by
  let t := σ*Real.sqrt (N : ℝ)
  let μ := historyJoint P t K
  let R := coupling (NeZero.pos N) Γ t K
  let badEnergy : Set (TerminalState d N m r × Weights d m r) :=
    {z | K < terminalEnergy t z.1.2}
  let badSample := outputFailure (d:=d) (N:=N) (m:=m) (s:=r) φ t K η
  have ha : ∀ᵐ z ∂μ,HistoryAligned (by omega : r+0 ≤ r) σ φ x z.1.1 z.1.2 := by
    apply ae_of_ae_map (μ:=μ) (f:=Prod.fst)
      (p:=fun z => HistoryAligned (by omega : r+0 ≤ r) σ φ x z.1 z.2)
      measurable_fst.aemeasurable
    rwa [historyJoint_old]
  have hsub : ∀ᵐ z : TerminalHistorySpace d N m r ∂μ,
      z ∈ ({z | z.1.2.1.1=true} ∩ {z | radius/8 < |networkOutput φ z.2 x -
        ∑ i,z.1.1.1 (Sum.inr (Sum.inr i))*z.1.1.2 (Fin.last r) i|}) →
      z ∈ (fun z => (z.1.2,z.2)) ⁻¹' (badEnergy ∪ badSample) := by
    filter_upwards [ha] with z hz hbad
    by_cases he : terminalEnergy t z.1.2.2 ≤ K
    · exact Or.inr ⟨he, x, by
        rw [terminalOriginalOutput_aligned hσ (NeZero.pos N) φ x z.1.1 z.1.2 hz]
        exact hthreshold.trans hbad.2.le⟩
    · exact Or.inl (lt_of_not_ge he)
  have hmeasure := measure_mono_ae (μ:=μ)
    (s:=({z : TerminalHistorySpace d N m r | z.1.2.1.1=true} ∩ {z : TerminalHistorySpace d N m r | radius/8 < |networkOutput φ z.2 x -
      ∑ i,z.1.1.1 (Sum.inr (Sum.inr i))*z.1.1.2 (Fin.last r) i|}))
    (t:=(fun z : TerminalHistorySpace d N m r => (z.1.2,z.2)) ⁻¹' (badEnergy ∪ badSample)) hsub
  have hle := ENNReal.toReal_mono (measure_ne_top μ _) hmeasure
  have hbadE : MeasurableSet badEnergy :=
    measurableSet_lt measurable_const ((measurable_terminalEnergy t).comp (by fun_prop))
  have hbadS : MeasurableSet badSample := measurableSet_outputFailure hφ t K η
  change μ.real _ ≤ μ.real _ at hle
  have hmap : Measurable (fun z : TerminalHistorySpace d N m r => (z.1.2,z.2)) := by fun_prop
  rw [← map_measureReal_apply hmap (hbadE.union hbadS), historyJoint_new] at hle
  apply hle.trans ((measureReal_union_le badEnergy badSample).trans ?_)
  have he : R.joint.real badEnergy=Γ.real {p | K < terminalEnergy t p.2} := by
    have hs : MeasurableSet {p : TerminalState d N m r | K < terminalEnergy t p.2} :=
      measurableSet_lt measurable_const ((measurable_terminalEnergy t).comp measurable_snd)
    have hh := map_measureReal_apply (μ:=R.joint) measurable_fst hs
    rw [R.left] at hh
    exact hh.symm
  exact add_le_add (he ▸ henergy) hsample



/-- The actual terminal sampler and stopped hidden-path estimate imply the
raw reconstruction-cost tail required by the finite-grid theorem. -/
theorem historyRawCoupling_cost_le [NeZero N] {σ : ℝ} (hσ : 0 < σ)
    {φ : ℝ → ℝ} (hφ : Continuous φ) (x : Cube d)
    {Q : Measure (Weights d N r)} {Γ : Measure (TerminalState d N m r)} [IsProbabilityMeasure Γ]
    (P : CanonicalHistoryComparison Q Γ (Prod.fst : OriginalHistory d N r r → Weights d N r))
    {K η radius E abort energyFailure sampleFailure : ℝ}
    (hr : 0 < radius) (hE : 0 ≤ E)
    (halign : ∀ᵐ z ∂P.joint,HistoryAligned (by omega : r+0 ≤ r) σ φ x z.1 z.2)
    (hcost : (∫⁻ z,liveOriginalCost (m:=m) (k:=0) le_rfl φ x z ∂P.joint) ≤ ENNReal.ofReal E)
    (habort : P.joint.real {z | z.2.1.1 ≠ true} ≤ abort)
    (hthreshold : η ≤ radius/8)
    (henergy : Γ.real {p | K < terminalEnergy (σ*Real.sqrt (N : ℝ)) p.2} ≤ energyFailure)
    (hsample : (coupling (NeZero.pos N) Γ (σ*Real.sqrt (N : ℝ)) K).joint.real
      (outputFailure φ (σ*Real.sqrt (N : ℝ)) K η) ≤ sampleFailure) :
    (historyRawCoupling P (σ*Real.sqrt (N : ℝ)) K).joint.real
      {z | (radius/2)^2 < reconstructionPathCost φ z.1 z.2.1 x z.2.2} ≤
        abort + 8*E/radius^2 + (energyFailure+sampleFailure) := by
  let t := σ*Real.sqrt (N : ℝ)
  let μ := historyJoint P t K
  let good : Set (TerminalHistorySpace d N m r) := {z | z.1.2.1.1=true}
  let cost : TerminalHistorySpace d N m r → ℝ :=
    good.indicator (fun z => hiddenPathCost φ z.1.1.1 x z.1.1.2)
  have hg : MeasurableSet good := measurableSet_eq_fun (by fun_prop) measurable_const
  have hmc : Measurable cost := by
    apply Measurable.indicator _ hg
    have hh := (measurable_originalPathCost (d:=d) (N:=N) (r:=r) le_rfl hφ x).comp
      (measurable_fst.comp measurable_fst : Measurable (fun z : TerminalHistorySpace d N m r => z.1.1))
    simpa only [originalPathCost_full,Function.comp_def] using hh
  have hnonneg (z : TerminalHistorySpace d N m r) : 0 ≤ cost z :=
    indicator_nonneg (fun z _ => hiddenPathCost_nonneg φ z.1.1.1 x z.1.1.2) z
  have hident (z : TerminalHistorySpace d N m r) :
      ENNReal.ofReal (cost z)=liveOriginalCost (m:=m) (k:=0) le_rfl φ x z.1 := by
    by_cases hz : z∈good
    · rw [show cost z=hiddenPathCost φ z.1.1.1 x z.1.1.2 from indicator_of_mem hz _]
      unfold liveOriginalCost
      have hh : z.1.2.1.1=true := hz
      rw [if_pos hh,originalPathCost_full]
    · rw [show cost z=0 from indicator_of_notMem hz _]
      unfold liveOriginalCost
      have hh : z.1.2.1.1≠true := hz
      rw [if_neg hh,ENNReal.ofReal_zero]
  have hlin : (∫⁻ z,ENNReal.ofReal (cost z) ∂μ) ≤ ENNReal.ofReal E := by
    simp_rw [hident]
    exact (lintegral_glue_old P.joint (coupling (NeZero.pos N) Γ t K).joint
      (liveOriginalCost le_rfl φ x) (measurable_liveOriginalCost le_rfl hφ x)).le.trans hcost
  have hi : Integrable cost μ := ⟨hmc.aestronglyMeasurable,
    (hasFiniteIntegral_iff_ofReal (Filter.Eventually.of_forall hnonneg)).mpr
      (hlin.trans_lt ENNReal.ofReal_lt_top)⟩
  have hm : (∫ z,cost z ∂μ) ≤ E := by
    rw [← ofReal_integral_eq_lintegral_ofReal hi (Filter.Eventually.of_forall hnonneg)] at hlin
    have hh := ENNReal.toReal_mono ENNReal.ofReal_ne_top hlin
    rwa [ENNReal.toReal_ofReal (integral_nonneg hnonneg),ENNReal.toReal_ofReal hE] at hh
  have habort' : μ.real goodᶜ ≤ abort := by
    have hs : MeasurableSet {z : OriginalHistory d N r r × TerminalState d N m r |
        z.2.1.1 ≠ true} := (measurableSet_eq_fun (by fun_prop) measurable_const).compl
    have hh := map_measureReal_apply (μ:=μ) measurable_fst hs
    rw [historyJoint_old] at hh
    exact hh.symm.trans_le habort
  have hread := history_readout_failure_le hσ hφ x P halign hthreshold henergy hsample
  have hout := reconstructionPathCost_tail_le_stopped μ
    (fun z => z.1.1.1) (fun z => z.2) (fun z => z.1.1.2) φ x good hr hi hm habort' hread
  change ((historyJoint P t K).map
    (fun z => (z.1.1.1,z.2,z.1.1.2))).real _ ≤ _
  rw [map_measureReal_apply (by fun_prop)
    (measurableSet_lt measurable_const (measurable_reconstructionPathCost φ hφ x))]
  exact hout



/-- A common actual terminal law plus the proved final history invariants
suffices for raw compression. This theorem constructs the raw couplings; it
does not assume a raw-compression or score-coupling premise. -/
theorem rawPathCompression_of_histories [NeZero N] (hm : 0 < m)
    {σ : ℝ} (hσ : 0 < σ) {φ : ℝ → ℝ} (hφ : Continuous φ)
    (Q : Measure (Weights d N r))
    (Γ : Measure (TerminalState d N m r)) [IsProbabilityMeasure Γ]
    {K W η radius E abort energyFailure sampleFailure failure : ℝ}
    (hW : 0 ≤ W) (hBW : Real.sqrt K/(m:ℝ) ≤ W) (hr : 0 < radius) (hE : 0 ≤ E)
    (hbounded : ∀ᵐ p ∂Γ,activePrefixBounded W p.1)
    (hhistory : ∀ x : Cube d, ∃ P : CanonicalHistoryComparison Q Γ
        (Prod.fst : OriginalHistory d N r r → Weights d N r),
      (∀ᵐ z ∂P.joint,HistoryAligned (by omega : r+0 ≤ r) σ φ x z.1 z.2) ∧
      (∀ᵐ z ∂P.joint,validHiddenPath z.1.2) ∧
      (∫⁻ z,liveOriginalCost (m:=m) (k:=0) le_rfl φ x z ∂P.joint) ≤ ENNReal.ofReal E ∧
      P.joint.real {z | z.2.1.1 ≠ true} ≤ abort)
    (hthreshold : η ≤ radius/8)
    (henergy : Γ.real {p | K < terminalEnergy (σ*Real.sqrt (N : ℝ)) p.2} ≤ energyFailure)
    (hsample : (coupling (NeZero.pos N) Γ (σ*Real.sqrt (N : ℝ)) K).joint.real
      (outputFailure φ (σ*Real.sqrt (N : ℝ)) K η) ≤ sampleFailure)
    (hfailure : abort+8*E/radius^2+(energyFailure+sampleFailure) ≤ failure) :
    RawPathCompression φ Q (candidateLaw (NeZero.pos N) Γ (σ*Real.sqrt (N : ℝ)) K)
      W radius failure := by
  constructor
  · exact candidateLaw_bounded (NeZero.pos N) Γ hW hBW hbounded
  · intro x
    obtain ⟨P,ha,hv,hc,hab⟩ := hhistory x
    exact ⟨historyRawCoupling P (σ*Real.sqrt (N : ℝ)) K,
      historyRawCoupling_valid P _ K hv,
      (historyRawCoupling_cost_le hσ hφ x P hr hE ha hc hab hthreshold henergy hsample).trans hfailure⟩

end NeuralGeneralization.BatchTwoManuscriptReadout
