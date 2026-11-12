import NeuralGeneralization.BatchTwoOnlineTanhTarget
import NeuralGeneralization.BatchTwoOnlineTanhSignedTail
import NeuralGeneralization.BatchTwoOnlineTanhCover
import NeuralGeneralization.BatchTwoMergingExceptionalPosterior

/-! Literal signed-tanh posterior, with optional robustness and all-input margin conditioning. -/
noncomputable section
set_option autoImplicit false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineTanhMerging
open ConcreteModel BatchTwoMerging
variable {d N r n : ℕ}

def tanhRestrictedSupport (noiseMargin globalMargin : Bool) (c : ℝ) : Set (Weights d N r) :=
  (signedMergingSupport∩if noiseMargin then robustEvent Real.tanh c else Set.univ)∩
    if globalMargin then globalMarginEvent Real.tanh (1/2) else Set.univ

def tanhPosteriorEvent (noiseMargin globalMargin : Bool) (c : ℝ)
    (f : BooleanFunction d) (sample : Fin n→Cube d) : Set (Weights d N r) :=
  tanhRestrictedSupport noiseMargin globalMargin c∩RobustPosterior.trainingMarginEvent Real.tanh f sample

def tanhPosterior (noiseMargin globalMargin : Bool) (c σ : ℝ)
    (f : BooleanFunction d) (sample : Fin n→Cube d) : Measure (Weights d N r) :=
  cond (smallPrior d N r σ) (tanhPosteriorEvent noiseMargin globalMargin c f sample)

theorem measurable_tanhRestrictedSupport (noiseMargin globalMargin : Bool) {c : ℝ} (hc : 0<c) :
    MeasurableSet (tanhRestrictedSupport (d:=d) (N:=N) (r:=r) noiseMargin globalMargin c) := by
  apply MeasurableSet.inter
  · apply (isClosed_signedMergingSupport d N r).measurableSet.inter
    cases noiseMargin
    · exact MeasurableSet.univ
    · exact measurableSet_robustEvent tanh_continuous hc
  · cases globalMargin
    · exact MeasurableSet.univ
    · rw [globalMarginEvent_eq_iUnion]
      exact (isOpen_iUnion fun f=>isOpen_marginEvent tanh_continuous (1/2) f).measurableSet

theorem measurable_tanhPosteriorEvent (noiseMargin globalMargin : Bool) {c : ℝ} (hc : 0<c)
    (f : BooleanFunction d) (sample : Fin n→Cube d) :
    MeasurableSet (tanhPosteriorEvent (N:=N) (r:=r) noiseMargin globalMargin c f sample) :=
  (measurable_tanhRestrictedSupport noiseMargin globalMargin hc).inter
    (RobustPosterior.measurable_trainingMarginEvent tanh_continuous f sample)

theorem tanhPosterior_eq_two_stage (noiseMargin globalMargin : Bool) {c : ℝ} (hc : 0<c)
    (σ : ℝ) (f : BooleanFunction d) (sample : Fin n→Cube d) :
    tanhPosterior (N:=N) (r:=r) noiseMargin globalMargin c σ f sample=
      cond (cond (smallPrior d N r σ) (tanhRestrictedSupport noiseMargin globalMargin c))
        (RobustPosterior.trainingMarginEvent Real.tanh f sample) :=
  (cond_cond_eq_cond_inter (measurable_tanhRestrictedSupport noiseMargin globalMargin hc)
    (RobustPosterior.measurable_trainingMarginEvent tanh_continuous f sample) _).symm

theorem tanh_target_subset_posteriorEvent (noiseMargin globalMargin : Bool) (c : ℝ)
    (f : BooleanFunction d) (sample : Fin n→Cube d) :
    (signedMergingSupport∩robustEvent Real.tanh c)∩marginEvent Real.tanh (1/2) f⊆
      tanhPosteriorEvent (N:=N) (r:=r) noiseMargin globalMargin c f sample := by
  intro w hw
  refine ⟨⟨⟨hw.1.1,?_⟩,?_⟩,fun i=>hw.2 (sample i)⟩
  · cases noiseMargin
    · trivial
    · exact hw.1.2
  · cases globalMargin
    · trivial
    · exact marginEvent_subset_global Real.tanh (1/2) f hw.2

theorem tanh_posterior_event_mass {C : ℕ} (hd : 0<d) (hC : 0<C) (hCN : C≤N)
    (B : LayeredBooleanCircuit d C r) {c σ : ℝ} (hc : 0<c) (hσ : 0<σ)
    (hscale : (N:ℝ)*σ^2≤1) (noiseMargin globalMargin : Bool) (sample : Fin n→Cube d) :
    Real.exp (-tanhMergeTargetCost d C r c/σ^2)≤
      (smallPrior d N r σ).real (tanhPosteriorEvent noiseMargin globalMargin c B.computes sample) :=
  (tanh_merge_target_mass_all_widths hd hC hCN B hc hσ hscale).trans
    (measureReal_mono (tanh_target_subset_posteriorEvent noiseMargin globalMargin c B.computes sample))

theorem tanh_posterior_event_pos {C : ℕ} (hd : 0<d) (hC : 0<C) (hCN : C≤N)
    (B : LayeredBooleanCircuit d C r) {c σ : ℝ} (hc : 0<c) (hσ : 0<σ)
    (hscale : (N:ℝ)*σ^2≤1) (noiseMargin globalMargin : Bool) (sample : Fin n→Cube d) :
    0<(smallPrior d N r σ).real (tanhPosteriorEvent noiseMargin globalMargin c B.computes sample) :=
  (Real.exp_pos _).trans_le (tanh_posterior_event_mass hd hC hCN B hc hσ hscale noiseMargin globalMargin sample)

theorem tanh_posterior_probability {C : ℕ} (hd : 0<d) (hC : 0<C) (hCN : C≤N)
    (B : LayeredBooleanCircuit d C r) {c σ : ℝ} (hc : 0<c) (hσ : 0<σ)
    (hscale : (N:ℝ)*σ^2≤1) (noiseMargin globalMargin : Bool) (sample : Fin n→Cube d) :
    IsProbabilityMeasure (tanhPosterior (N:=N) (r:=r) noiseMargin globalMargin c σ B.computes sample) := by
  apply cond_isProbabilityMeasure
  have hp := tanh_posterior_event_pos hd hC hCN B hc hσ hscale noiseMargin globalMargin sample
  intro he
  simp only [Measure.real,he,ENNReal.toReal_zero] at hp
  exact (lt_irrefl 0) hp

def signedPartitionEntropyBudget (d r Q : ℕ) : ℝ :=
  ((r:ℝ)+1)*Real.log 2+partitionEntropyBudget d r Q

theorem signedPartitionEntropyBudget_nonneg (d r : ℕ) {Q : ℕ} (hQ : 0<Q) :
    0≤signedPartitionEntropyBudget d r Q := by
  have hh := partitionEntropyBudget_nonneg d r hQ
  have hl : 0≤Real.log 2 := Real.log_nonneg (by norm_num)
  unfold signedPartitionEntropyBudget
  positivity

theorem smallPrior_signedExceptional_scaled_tail {Q : ℕ}
    (hd : 0<d) (hN : 0<N) (hQ : 0<Q) {σ : ℝ} (hσ : 0<σ)
    (hscale : (N:ℝ)*σ^2≤1) (J : ℝ) :
    (smallPrior d N r σ).real (signedExceptionalPartitions (Q:=Q) J)≤
      Real.exp (-(J-4*signedPartitionEntropyBudget d r Q)/(4*σ^2)) := by
  apply (smallPrior_signedExceptional_tail hd hN hQ hσ J).trans
  apply Real.exp_le_exp.mpr
  have hs := sq_pos_of_pos hσ
  have hN1 : (1:ℝ)≤N := by exact_mod_cast hN
  have hlog : 0≤Real.log (Q:ℝ) := Real.log_nonneg (by exact_mod_cast hQ)
  have he := signedPartitionEntropyBudget_nonneg d r hQ
  have hcount : (((r+1)*(N+1):ℕ):ℝ)*Real.log (Q:ℝ)≤
      (N:ℝ)*(2*(r+1)*Real.log (Q:ℝ)) := by
    push_cast
    have hh := mul_nonneg (show 0≤(r+1:ℝ) by positivity) hlog
    nlinarith
  have hscaled : (N:ℝ)*signedPartitionEntropyBudget d r Q≤signedPartitionEntropyBudget d r Q/σ^2 := by
    apply (le_div_iff₀ hs).mpr
    have hh := mul_le_mul_of_nonneg_right hscale he
    nlinarith
  have hmid : (((r+1)*N:ℕ):ℝ)*Real.log 2+(((r+1)*(N+1):ℕ):ℝ)*Real.log (Q:ℝ)+
      (N:ℝ)/2*(d+2+r*Q:ℕ)*Real.log 2≤signedPartitionEntropyBudget d r Q/σ^2 := by
    apply le_trans _ hscaled
    unfold signedPartitionEntropyBudget partitionEntropyBudget
    push_cast at hcount ⊢
    nlinarith
  calc
    _ ≤ signedPartitionEntropyBudget d r Q/σ^2-J/(4*σ^2) := by linarith
    _ = _ := by ring

theorem tanh_posterior_readout_tail {C : ℕ} (hd : 0<d) (hC : 0<C) (hCN : C≤N)
    (B : LayeredBooleanCircuit d C r) {c σ : ℝ} (hc : 0<c) (hσ : 0<σ)
    (hscale : (N:ℝ)*σ^2≤1) (noiseMargin globalMargin : Bool) (sample : Fin n→Cube d)
    {U β : ℝ} (hβ : 0<β) (hβ1 : β≤1) (hU : 8≤U)
    (hbudget : 4*(tanhMergeTargetCost d C r c-Real.log β)≤U) :
    (tanhPosterior (N:=N) (r:=r) noiseMargin globalMargin c σ B.computes sample).real
      {w | U<readoutEnergy w}≤β := by
  have hN : 0<N := hC.trans_le hCN
  have hN1 : (1:ℝ)≤N := by exact_mod_cast hN
  have hs1 : σ^2≤1 := (le_mul_of_one_le_left (sq_nonneg σ) hN1).trans hscale
  exact RobustPosterior.conditional_tail_of_exponential_bounds
    (smallPrior d N r σ) (tanhPosteriorEvent noiseMargin globalMargin c B.computes sample)
    {w | U<readoutEnergy w} (measurable_tanhPosteriorEvent noiseMargin globalMargin hc B.computes sample)
    (sq_pos_of_pos hσ) hs1 hβ hβ1
    (tanh_posterior_event_mass hd hC hCN B hc hσ hscale noiseMargin globalMargin sample)
    (RobustPosterior.smallPrior_readout_tail hd hN hσ (B:=U) (by nlinarith [hscale])) hbudget

theorem tanh_posterior_exceptional_tail {C Q : ℕ} (hd : 0<d) (hC : 0<C) (hCN : C≤N) (hQ : 0<Q)
    (B : LayeredBooleanCircuit d C r) {c σ : ℝ} (hc : 0<c) (hσ : 0<σ)
    (hscale : (N:ℝ)*σ^2≤1) (noiseMargin globalMargin : Bool) (sample : Fin n→Cube d)
    {J β : ℝ} (hβ : 0<β) (hβ1 : β≤1)
    (hbudget : 4*(tanhMergeTargetCost d C r c+signedPartitionEntropyBudget d r Q-Real.log β)≤J) :
    (tanhPosterior (N:=N) (r:=r) noiseMargin globalMargin c σ B.computes sample).real
      (signedExceptionalPartitions (Q:=Q) J)≤β := by
  have hN : 0<N := hC.trans_le hCN
  have hN1 : (1:ℝ)≤N := by exact_mod_cast hN
  have hs1 : σ^2≤1 := (le_mul_of_one_le_left (sq_nonneg σ) hN1).trans hscale
  apply RobustPosterior.conditional_tail_of_exponential_bounds
    (smallPrior d N r σ) (tanhPosteriorEvent noiseMargin globalMargin c B.computes sample)
    (signedExceptionalPartitions (Q:=Q) J) (measurable_tanhPosteriorEvent noiseMargin globalMargin hc B.computes sample)
    (sq_pos_of_pos hσ) hs1 hβ hβ1
    (tanh_posterior_event_mass hd hC hCN B hc hσ hscale noiseMargin globalMargin sample)
    (smallPrior_signedExceptional_scaled_tail hd hN hQ hσ hscale J)
  linarith

theorem tanh_posteriorEvent_grid_cover (hd : 0<d) (hN : 0<N) (hn : 0<n)
    (noiseMargin globalMargin : Bool) (c : ℝ) (f : BooleanFunction d) (sample : Fin n→Cube d)
    (w : Weights d N r) (hw : w∈tanhPosteriorEvent noiseMargin globalMargin c f sample) {U J : ℝ}
    (hU : readoutEnergy w≤U) (hJ : w∉signedExceptionalPartitions (Q:=⌈1+16*U⌉₊) J) :
    ∃a : TanhGridCode d ⌈1+16*U⌉₊ r (tanhGridResolution d ⌈1+16*U⌉₊ r (1+Real.sqrt J)),∀x,
      |clippedScore (networkOutput Real.tanh w x)-clippedScore (perspectiveOutput
        (tanhGridWeights d ⌈1+16*U⌉₊ r (tanhGridResolution d ⌈1+16*U⌉₊ r (1+Real.sqrt J)) (1+Real.sqrt J) a)
        (tanhGridMasses d ⌈1+16*U⌉₊ r (tanhGridResolution d ⌈1+16*U⌉₊ r (1+Real.sqrt J)) a) x)|≤3/32 := by
  obtain ⟨s,hs⟩ := Set.mem_iUnion.mp hw.1.1.1
  obtain ⟨p,hp⟩ := Set.mem_iUnion.mp hs
  have hq : ∀j,populationCount (p j)≤⌈1+16*U⌉₊ := by
    intro j
    have hh := signed_population_count_le hN p s w hp (sample ⟨0,hn⟩) (f (sample ⟨0,hn⟩)) (hw.2 ⟨0,hn⟩) j
    have hh' : (populationCount (p j):ℝ)≤(⌈1+16*U⌉₊:ℝ) :=
      (hh.trans (by linarith)).trans (Nat.le_ceil _)
    exact_mod_cast hh'
  exact signed_partition_grid_cover hd hN p s hq w hp
    (signed_compressedEnergy_le_of_not_exceptional w hJ p s hq)

end NeuralGeneralization.BatchTwoOnlineTanhMerging
