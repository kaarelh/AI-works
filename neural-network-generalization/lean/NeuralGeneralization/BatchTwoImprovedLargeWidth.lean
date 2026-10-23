import NeuralGeneralization.BatchTwoImprovedHistoryComplete
import NeuralGeneralization.BatchTwoImprovedResourceGram
import NeuralGeneralization.BatchTwoImprovedResourceFailure
import NeuralGeneralization.BatchTwoImprovedTerminalVarianceJoint

/-! Actual sharp large-width compression from the original Gaussian KL bound.
Every sampler, original marginal, and coefficient envelope is instantiated. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace NeuralGeneralization.BatchTwoImprovedInduction
open ConcreteModel RobustEntropy RobustStatistics RobustCompressionInduction
open BatchTwoImprovedResources BatchTwoImprovedTerminal
set_option maxHeartbeats 600000
set_option maxRecDepth 4000

theorem sharp_large_width_raw (p : RobustCompressionInput) {N r : ℕ}
    (hd : 0<p.dimension) (hr : r≤p.depth) (hK : 1≤p.energy)
    (hN : BatchTwoImprovedResources.widthBound p≤N)
    {t : ℝ} (ht : 0<t) (ht1 : t≤1)
    (Q : Measure (Weights p.dimension N r)) [IsProbabilityMeasure Q]
    (hQ : klDiv Q (smallPrior p.dimension N r (t/Real.sqrt (N:ℝ)))≤
      ENNReal.ofReal ((p.energy:ℝ)/(t/Real.sqrt (N:ℝ))^2)) :
    ∃ Γ : Measure (Weights p.dimension (bankSize p) r), IsProbabilityMeasure Γ ∧
      RawPathCompression Real.tanh Q Γ (weightBound p)
        (1/((p.inverseRadius:ℝ)+1)) (1/((p.inverseFailure:ℝ)+1)) := by
  have hn : 0<N := lt_of_lt_of_le (widthBound_pos p) hN
  letI : NeZero N := ⟨hn.ne'⟩
  letI : MeasurableSpace (QueryMessage (Fin (Fintype.card (Cube p.dimension))) (rank p)) := ⊤
  have hEr : (0:ℝ) < inverseError p := Nat.cast_pos.mpr (inverseError_pos p)
  have hHr : (0:ℝ) < BatchTwoImprovedResources.inverseFailure p := Nat.cast_pos.mpr (inverseFailure_pos p)
  have hHone : (1:ℝ)≤BatchTwoImprovedResources.inverseFailure p := by exact_mod_cast inverseFailure_pos p
  have hb0 : 0<Real.sqrt (firstSquared p:ℝ) := Real.sqrt_pos.mpr (Nat.cast_pos.mpr (firstSquared_pos p))
  have hbH : 0<Real.sqrt (activeSquared p:ℝ) := Real.sqrt_pos.mpr (Nat.cast_pos.mpr (activeSquared_pos p))
  have hbG : 0<Real.sqrt (gaussianSquared p:ℝ) := Real.sqrt_pos.mpr (Nat.cast_pos.mpr (gaussianSquared_pos p))
  obtain ⟨Γ,hb,ha,he,hhistory⟩ := exists_sharp_actual_terminal_histories hd
    (bankSize_pos p) (rank_pos p) (Nat.cast_nonneg p.energy) ht ht1 hb0 hbH hbG
    (selectionError_pos p) (inv_pos.mpr hHr) ((inv_le_one₀ hHr).mpr hHone)
    (first_weight_bound p) (reconstruction_weight_bound p) (rank_allocation p) (gram_allocation p)
    (fun j hj => entropy_cap p hn hN hK (hj.trans hr) ht ht1) Q hQ
  have ht2 : t^2≤1 := by nlinarith
  have hcap := entropy_cap p hn hN hK hr ht ht1
  have henergy := terminal_energy_abort_of_entropy hn Γ.law ht ht2
    (by positivity : 0≤2*(p.energy:ℝ))
    (Nat.cast_pos.mpr (readoutMoment_pos p))
    (by simpa only [mul_assoc,mul_left_comm,mul_comm] using he.trans hcap)
  have henergy' : Γ.law.real {z | (readoutMoment p:ℝ)<terminalEnergy t z.2}≤
      (BatchTwoImprovedResources.inverseFailure p:ℝ)⁻¹ := by
    refine henergy.trans ?_
    have hh : (4*(2*(p.energy:ℝ))+2)/(readoutMoment p:ℝ)=(8*(p.energy:ℝ)+2)/(readoutMoment p:ℝ) := by ring
    rw [hh]
    exact terminal_energy_allocation p
  let σ := t/Real.sqrt (N:ℝ)
  have hnR : (0:ℝ)<N := Nat.cast_pos.mpr hn
  have hσ : 0<σ := by dsimp [σ]; positivity
  have htσ : σ*Real.sqrt (N:ℝ)=t := by
    dsimp [σ]
    exact div_mul_cancel₀ t (Real.sqrt_pos.mpr hnR).ne'
  have habort : Γ.law.real {z | z.1.1≠true}≤2*(r:ℝ)/(BatchTwoImprovedResources.inverseFailure p:ℝ) := by
    have hs : {z : TerminalState p.dimension N (bankSize p) r | z.1.1≠true}=
        {z | z.1.1=false} := by ext z; cases z.1.1 <;> simp
    rw [hs,measureReal_def]
    have hfinite : r • (2*ENNReal.ofReal ((BatchTwoImprovedResources.inverseFailure p:ℝ)⁻¹))≠⊤ := by
      rw [nsmul_eq_mul]
      exact ENNReal.mul_ne_top (by simp) (ENNReal.mul_ne_top (by norm_num) ENNReal.ofReal_ne_top)
    have hh := ENNReal.toReal_mono hfinite ha
    simpa [ENNReal.toReal_nsmul,ENNReal.toReal_mul,ENNReal.toReal_ofReal (inv_pos.mpr hHr).le,
      nsmul_eq_mul,div_eq_mul_inv,mul_assoc,mul_left_comm,mul_comm] using hh
  have hc : ∀ x : Cube p.dimension,∃ H : CanonicalHistoryComparison Q Γ.law
      (Prod.fst : OriginalHistory p.dimension N r r → Weights p.dimension N r),
      (∀ᵐ z ∂H.joint,HistoryAligned (by omega : r+0≤r) σ Real.tanh x z.1 z.2) ∧
      (∫⁻ z,liveOriginalCost (m:=bankSize p) (k:=0) le_rfl Real.tanh x z ∂H.joint)≤
        ENNReal.ofReal ((1+14*(r:ℝ))/(inverseError p:ℝ)) ∧
      H.joint.real {z | z.2.1.1≠true}≤2*(r:ℝ)/(BatchTwoImprovedResources.inverseFailure p:ℝ) := by
    intro x
    obtain ⟨H,hal,hcost⟩ := hhistory x
    refine ⟨H,hal,?_,?_⟩
    · apply hcost.trans
      rw [first_cost_allocation]
      calc
        _ ≤ ENNReal.ofReal (1/(inverseError p:ℝ))+r • ENNReal.ofReal (14/(inverseError p:ℝ)) :=
          add_le_add le_rfl (nsmul_le_nsmul_right (ENNReal.ofReal_le_ofReal (layer_cost_allocation p)) r)
        _ = _ := by
          rw [←ENNReal.ofReal_nsmul,←ENNReal.ofReal_add (by positivity) (by positivity)]
          congr 1
          rw [nsmul_eq_mul]
          ring
    · have hs : MeasurableSet {z : TerminalState p.dimension N (bankSize p) r | z.1.1≠true} :=
        (measurableSet_eq_fun (by fun_prop) measurable_const).compl
      have hm := map_measureReal_apply (μ:=H.joint) measurable_snd hs
      rw [H.state_marginal] at hm
      exact hm.symm.trans_le habort
  refine ⟨terminalCandidateLaw Γ.law t (readoutClip p) (readoutMoment p),inferInstance,?_⟩
  rw [←htσ]
  apply pointwise_rawPathCompression_of_terminal_histories (bankSize_pos p) hσ
    tanh_lipschitzWith.continuous Q Γ.law (B:=readoutClip p) (K:=readoutMoment p)
    (W:=weightBound p) (η:=1/(16*((p.inverseRadius:ℝ)+1)))
    (E:=(1+14*(r:ℝ))/(inverseError p:ℝ))
    (abort:=2*(r:ℝ)/(BatchTwoImprovedResources.inverseFailure p:ℝ))
    (energyFailure:=(BatchTwoImprovedResources.inverseFailure p:ℝ)⁻¹)
    (sampleFailure:=(BatchTwoImprovedResources.inverseFailure p:ℝ)⁻¹)
    (Nat.cast_nonneg _) (Nat.cast_nonneg _) (by exact_mod_cast readout_weight_bound p)
    (by positivity) (by positivity) hb hc (terminal_threshold_allocation p).le
  · simpa only [htσ] using henergy'
  · intro x
    exact (pointwise_terminal_sampling_joint_tail (bankSize_pos p) Γ.law
      tanh_lipschitzWith.continuous (fun z => (Real.abs_tanh_lt_one z).le)
      (Nat.cast_pos.mpr (readoutClip_pos p)) (Nat.cast_nonneg _) (by positivity) x).trans
      (terminal_sampling_allocation p)
  · exact failure_allocation p hr
end NeuralGeneralization.BatchTwoImprovedInduction
