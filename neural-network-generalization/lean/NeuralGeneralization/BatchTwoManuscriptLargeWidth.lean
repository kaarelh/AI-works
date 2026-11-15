import NeuralGeneralization.BatchTwoManuscriptReadoutHistory
import NeuralGeneralization.BatchTwoManuscriptResourceHistory

/-! Actual ordinary-network raw compression at the literal manuscript
resources, for every width above its displayed cutoff. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace NeuralGeneralization.BatchTwoManuscriptResources
open ConcreteModel RobustEntropy RobustCompressionInduction BatchTwoManuscriptReadout

theorem total_failure_allocation (p : Input) :
    2*(p.depth-2:ℕ)*localFailure p+8*(20*(p.depth:ℝ)*localError p)/(p.radius/2)^2+
      (2*localFailure p+localFailure p)≤p.failure := by
  have hd := depth_pos p
  have hr := p.radius_pos
  have hα := p.failure_pos
  have hL : (2:ℝ)≤p.depth := by exact_mod_cast p.depth_ge_two
  unfold localFailure localError
  rw [Nat.cast_sub p.depth_ge_two]
  field_simp
  nlinarith

theorem exists_large_width_raw_compression (p : Input) {N : ℕ} (hN : widthBound p≤N)
    {φ : ℝ→ℝ} (hφ : LipschitzWith 1 φ) (hφb : ∀z,|φ z|≤1)
    {t : ℝ} (ht : 0<t) (ht1 : t≤1)
    (Q : Measure (Weights p.dimension N (p.depth-2))) [IsProbabilityMeasure Q]
    (hQ : klDiv Q (smallPrior p.dimension N (p.depth-2) (t/Real.sqrt (N:ℝ)))≤
      ENNReal.ofReal ((N:ℝ)*p.energy/t^2)) :
    ∃ν : Measure (Weights p.dimension (bankSize p) (p.depth-2)),
      IsProbabilityMeasure ν ∧ RawPathCompression φ Q ν (weightBound p) (p.radius/2) p.failure := by
  have hn := (widthBound_pos p).trans_le hN
  letI : NeZero N := ⟨hn.ne'⟩
  obtain ⟨Γ,hb,ha,hhistory⟩ := exists_literal_resource_histories p hN hφ hφb ht ht1 Q hQ
  let σ := t/Real.sqrt (N:ℝ)
  have hσ : 0<σ := div_pos ht (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hn))
  have htσ : σ*Real.sqrt (N:ℝ)=t := div_mul_cancel₀ t (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hn)).ne'
  have habort : Γ.law.real {z | z.1.1≠true}≤2*(p.depth-2:ℕ)*localFailure p := by
    have hs : {z : TerminalState p.dimension N (bankSize p) (p.depth-2) | z.1.1≠true}=
        {z | z.1.1=false} := by ext z; cases z.1.1 <;> simp
    rw [hs,measureReal_def]
    have hf : (p.depth-2) • (2*ENNReal.ofReal (localFailure p))≠⊤ := by
      rw [nsmul_eq_mul]
      exact ENNReal.mul_ne_top (by simp) (ENNReal.mul_ne_top (by norm_num) ENNReal.ofReal_ne_top)
    have hh := ENNReal.toReal_mono hf ha
    simpa only [ENNReal.toReal_nsmul,ENNReal.toReal_mul,ENNReal.toReal_ofReal (localFailure_pos p).le,
      ENNReal.toReal_ofNat,ENNReal.toReal_natCast,
      nsmul_eq_mul,mul_assoc,mul_left_comm,mul_comm] using hh
  have henergy : Γ.law.real {z | readoutEnergy p<terminalEnergy t z.2}≤2*localFailure p := by
    obtain ⟨H,hal,_,_⟩ := hhistory (fun _=>false)
    have he := terminalEnergy_abort_eq_original hσ φ (fun _=>false) H hal (readoutEnergy p)
    rw [htσ] at he
    rw [he]
    exact original_readout_abort p hn ht ht1 Q hQ
  have hc : ∀x : Cube p.dimension,∃ H : CanonicalHistoryComparison Q Γ.law
      (Prod.fst : OriginalHistory p.dimension N (p.depth-2) (p.depth-2)→Weights p.dimension N (p.depth-2)),
      (∀ᵐ z ∂H.joint,HistoryAligned (by omega : p.depth-2+0≤p.depth-2) σ φ x z.1 z.2) ∧
      (∀ᵐ z ∂H.joint,validHiddenPath z.1.2) ∧
      (∫⁻ z,liveOriginalCost (m:=bankSize p) (k:=0) le_rfl φ x z ∂H.joint)≤
        ENNReal.ofReal (20*(p.depth:ℝ)*localError p) ∧
      H.joint.real {z | z.2.1.1≠true}≤2*(p.depth-2:ℕ)*localFailure p := by
    intro x
    obtain ⟨H,hal,hv,hc⟩ := hhistory x
    refine ⟨H,hal,hv,hc,?_⟩
    have hs : MeasurableSet {z : TerminalState p.dimension N (bankSize p) (p.depth-2) | z.1.1≠true} :=
      (measurableSet_eq_fun (by fun_prop) measurable_const).compl
    have hm := map_measureReal_apply (μ:=H.joint) measurable_snd hs
    rw [H.state_marginal] at hm
    exact hm.symm.trans_le habort
  refine ⟨candidateLaw hn Γ.law t (readoutEnergy p),inferInstance,?_⟩
  rw [←htσ]
  apply rawPathCompression_of_histories (bankSize_pos p) hσ hφ.continuous Q Γ.law
    (K:=readoutEnergy p) (W:=weightBound p) (η:=p.radius/16)
    (E:=20*(p.depth:ℝ)*localError p) (abort:=2*(p.depth-2:ℕ)*localFailure p)
    (energyFailure:=2*localFailure p) (sampleFailure:=localFailure p)
    (show 0≤weightBound p from (by unfold weightBound; positivity)) (readout_weight_allocation p)
    (by have := p.radius_pos; positivity) (by have := localError_pos p; positivity) hb hc (by have := p.radius_pos; linarith)
  · simpa only [htσ] using henergy
  · exact coupling_literal_tail p hn Γ.law hφ.continuous hφb _
  · exact total_failure_allocation p

end NeuralGeneralization.BatchTwoManuscriptResources
