import NeuralGeneralization.BatchTwoOnlineBalancedTarget
import NeuralGeneralization.BatchTwoOnlineTanhPosterior
import NeuralGeneralization.BatchTwoOnlineBalancedCover
import NeuralGeneralization.BatchTwoOnlineTanhSignedTail
import NeuralGeneralization.BatchTwoOnlineTanhCover
import NeuralGeneralization.BatchTwoMergingExceptionalPosterior

/-! Literal balanced-tanh posterior, with optional robustness and all-input margin conditioning. -/
noncomputable section
set_option autoImplicit false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineBalanced
open ConcreteModel BatchTwoMerging BatchTwoOnlineTanhMerging
variable {d N r n : ℕ}

def balancedRestrictedSupport (noiseMargin globalMargin : Bool) (c : ℝ) : Set (Weights d N r) :=
  (balancedMergingSupport∩if noiseMargin then robustEvent Real.tanh c else Set.univ)∩
    if globalMargin then globalMarginEvent Real.tanh (1/2) else Set.univ

def balancedPosteriorEvent (noiseMargin globalMargin : Bool) (c : ℝ)
    (f : BooleanFunction d) (sample : Fin n→Cube d) : Set (Weights d N r) :=
  balancedRestrictedSupport noiseMargin globalMargin c∩RobustPosterior.trainingMarginEvent Real.tanh f sample

def balancedPosterior (noiseMargin globalMargin : Bool) (c σ : ℝ)
    (f : BooleanFunction d) (sample : Fin n→Cube d) : Measure (Weights d N r) :=
  cond (smallPrior d N r σ) (balancedPosteriorEvent noiseMargin globalMargin c f sample)

theorem measurable_balancedRestrictedSupport (noiseMargin globalMargin : Bool) {c : ℝ} (hc : 0<c) :
    MeasurableSet (balancedRestrictedSupport (d:=d) (N:=N) (r:=r) noiseMargin globalMargin c) := by
  apply MeasurableSet.inter
  · apply (isClosed_balancedMergingSupport d N r).measurableSet.inter
    cases noiseMargin
    · exact MeasurableSet.univ
    · exact measurableSet_robustEvent tanh_continuous hc
  · cases globalMargin
    · exact MeasurableSet.univ
    · rw [globalMarginEvent_eq_iUnion]
      exact (isOpen_iUnion fun f=>isOpen_marginEvent tanh_continuous (1/2) f).measurableSet

theorem measurable_balancedPosteriorEvent (noiseMargin globalMargin : Bool) {c : ℝ} (hc : 0<c)
    (f : BooleanFunction d) (sample : Fin n→Cube d) :
    MeasurableSet (balancedPosteriorEvent (N:=N) (r:=r) noiseMargin globalMargin c f sample) :=
  (measurable_balancedRestrictedSupport noiseMargin globalMargin hc).inter
    (RobustPosterior.measurable_trainingMarginEvent tanh_continuous f sample)

theorem balancedPosterior_eq_two_stage (noiseMargin globalMargin : Bool) {c : ℝ} (hc : 0<c)
    (σ : ℝ) (f : BooleanFunction d) (sample : Fin n→Cube d) :
    balancedPosterior (N:=N) (r:=r) noiseMargin globalMargin c σ f sample=
      cond (cond (smallPrior d N r σ) (balancedRestrictedSupport noiseMargin globalMargin c))
        (RobustPosterior.trainingMarginEvent Real.tanh f sample) :=
  (cond_cond_eq_cond_inter (measurable_balancedRestrictedSupport noiseMargin globalMargin hc)
    (RobustPosterior.measurable_trainingMarginEvent tanh_continuous f sample) _).symm

theorem balanced_target_subset_posteriorEvent (noiseMargin globalMargin : Bool) (c : ℝ)
    (f : BooleanFunction d) (sample : Fin n→Cube d) :
    (balancedMergingSupport∩robustEvent Real.tanh c)∩marginEvent Real.tanh (1/2) f⊆
      balancedPosteriorEvent (N:=N) (r:=r) noiseMargin globalMargin c f sample := by
  intro w hw
  refine ⟨⟨⟨hw.1.1,?_⟩,?_⟩,fun i=>hw.2 (sample i)⟩
  · cases noiseMargin
    · trivial
    · exact hw.1.2
  · cases globalMargin
    · trivial
    · exact marginEvent_subset_global Real.tanh (1/2) f hw.2

theorem balanced_posterior_event_mass {C : ℕ} (hd : 0<d) (hC : 0<C) (hCN : C≤N)
    (B : LayeredBooleanCircuit d C r) {c σ : ℝ} (hc : 0<c) (hσ : 0<σ)
    (hscale : (N:ℝ)*σ^2≤1) (noiseMargin globalMargin : Bool) (sample : Fin n→Cube d) :
    Real.exp (-balancedTargetCost d C r c/σ^2)≤
      (smallPrior d N r σ).real (balancedPosteriorEvent noiseMargin globalMargin c B.computes sample) :=
  (balanced_target_mass_all_widths hd hC hCN B hc hσ hscale).trans
    (measureReal_mono (balanced_target_subset_posteriorEvent noiseMargin globalMargin c B.computes sample))

theorem balanced_posterior_event_pos {C : ℕ} (hd : 0<d) (hC : 0<C) (hCN : C≤N)
    (B : LayeredBooleanCircuit d C r) {c σ : ℝ} (hc : 0<c) (hσ : 0<σ)
    (hscale : (N:ℝ)*σ^2≤1) (noiseMargin globalMargin : Bool) (sample : Fin n→Cube d) :
    0<(smallPrior d N r σ).real (balancedPosteriorEvent noiseMargin globalMargin c B.computes sample) :=
  (Real.exp_pos _).trans_le (balanced_posterior_event_mass hd hC hCN B hc hσ hscale noiseMargin globalMargin sample)

theorem balanced_posterior_probability {C : ℕ} (hd : 0<d) (hC : 0<C) (hCN : C≤N)
    (B : LayeredBooleanCircuit d C r) {c σ : ℝ} (hc : 0<c) (hσ : 0<σ)
    (hscale : (N:ℝ)*σ^2≤1) (noiseMargin globalMargin : Bool) (sample : Fin n→Cube d) :
    IsProbabilityMeasure (balancedPosterior (N:=N) (r:=r) noiseMargin globalMargin c σ B.computes sample) := by
  apply cond_isProbabilityMeasure
  have hp := balanced_posterior_event_pos hd hC hCN B hc hσ hscale noiseMargin globalMargin sample
  intro he
  simp only [Measure.real,he,ENNReal.toReal_zero] at hp
  exact (lt_irrefl 0) hp

theorem balanced_posterior_readout_tail {C : ℕ} (hd : 0<d) (hC : 0<C) (hCN : C≤N)
    (B : LayeredBooleanCircuit d C r) {c σ : ℝ} (hc : 0<c) (hσ : 0<σ)
    (hscale : (N:ℝ)*σ^2≤1) (noiseMargin globalMargin : Bool) (sample : Fin n→Cube d)
    {U β : ℝ} (hβ : 0<β) (hβ1 : β≤1) (hU : 8≤U)
    (hbudget : 4*(balancedTargetCost d C r c-Real.log β)≤U) :
    (balancedPosterior (N:=N) (r:=r) noiseMargin globalMargin c σ B.computes sample).real
      {w | U<readoutEnergy w}≤β := by
  have hN : 0<N := hC.trans_le hCN
  have hN1 : (1:ℝ)≤N := by exact_mod_cast hN
  have hs1 : σ^2≤1 := (le_mul_of_one_le_left (sq_nonneg σ) hN1).trans hscale
  exact RobustPosterior.conditional_tail_of_exponential_bounds
    (smallPrior d N r σ) (balancedPosteriorEvent noiseMargin globalMargin c B.computes sample)
    {w | U<readoutEnergy w} (measurable_balancedPosteriorEvent noiseMargin globalMargin hc B.computes sample)
    (sq_pos_of_pos hσ) hs1 hβ hβ1
    (balanced_posterior_event_mass hd hC hCN B hc hσ hscale noiseMargin globalMargin sample)
    (RobustPosterior.smallPrior_readout_tail hd hN hσ (B:=U) (by nlinarith [hscale])) hbudget

theorem balanced_posterior_exceptional_tail {C Q : ℕ} (hd : 0<d) (hC : 0<C) (hCN : C≤N) (hQ : 0<Q)
    (B : LayeredBooleanCircuit d C r) {c σ : ℝ} (hc : 0<c) (hσ : 0<σ)
    (hscale : (N:ℝ)*σ^2≤1) (noiseMargin globalMargin : Bool) (sample : Fin n→Cube d)
    {J β : ℝ} (hβ : 0<β) (hβ1 : β≤1)
    (hbudget : 4*(balancedTargetCost d C r c+signedPartitionEntropyBudget d r Q-Real.log β)≤J) :
    (balancedPosterior (N:=N) (r:=r) noiseMargin globalMargin c σ B.computes sample).real
      (signedExceptionalPartitions (Q:=Q) J)≤β := by
  have hN : 0<N := hC.trans_le hCN
  have hN1 : (1:ℝ)≤N := by exact_mod_cast hN
  have hs1 : σ^2≤1 := (le_mul_of_one_le_left (sq_nonneg σ) hN1).trans hscale
  apply RobustPosterior.conditional_tail_of_exponential_bounds
    (smallPrior d N r σ) (balancedPosteriorEvent noiseMargin globalMargin c B.computes sample)
    (signedExceptionalPartitions (Q:=Q) J) (measurable_balancedPosteriorEvent noiseMargin globalMargin hc B.computes sample)
    (sq_pos_of_pos hσ) hs1 hβ hβ1
    (balanced_posterior_event_mass hd hC hCN B hc hσ hscale noiseMargin globalMargin sample)
    (smallPrior_signedExceptional_scaled_tail hd hN hQ hσ hscale J)
  linarith

theorem balanced_posteriorEvent_grid_cover (hd : 0<d) (hN : 0<N) (hn : 0<n)
    (noiseMargin globalMargin : Bool) (c : ℝ) (f : BooleanFunction d) (sample : Fin n→Cube d)
    (w : Weights d N r) (hw : w∈balancedPosteriorEvent noiseMargin globalMargin c f sample) {U J : ℝ}
    (hU : readoutEnergy w≤U) (hJ : w∉signedExceptionalPartitions (Q:=⌈1+16*U⌉₊) J) :
    ∃a : TanhGridCode d ⌈1+16*U⌉₊ r (tanhGridResolution d ⌈1+16*U⌉₊ r (1+Real.sqrt J)),∀x,
      |clippedScore (networkOutput Real.tanh w x)-clippedScore (BatchTwoOnlineTanhMerging.perspectiveOutput
        (tanhGridWeights d ⌈1+16*U⌉₊ r (tanhGridResolution d ⌈1+16*U⌉₊ r (1+Real.sqrt J)) (1+Real.sqrt J) a)
        (tanhGridMasses d ⌈1+16*U⌉₊ r (tanhGridResolution d ⌈1+16*U⌉₊ r (1+Real.sqrt J)) a) x)|≤3/32 := by
  obtain ⟨p,hp⟩ := Set.mem_iUnion.mp hw.1.1.1
  have hq : ∀j,populationCount (p.val j)≤⌈1+16*U⌉₊ := by
    intro j
    have hh := balanced_population_count_le p w hp j
    have hh' : (populationCount (p.val j):ℝ)≤(⌈1+16*U⌉₊:ℝ) :=
      (hh.trans (by linarith)).trans (Nat.le_ceil _)
    exact_mod_cast hh'
  have heq : flipHiddenSigns (fun (_:Fin (r+1)) (_:Fin N)=>true) w=w := by
    funext i
    rcases i with ij | (sij | j) <;> simp [flipHiddenSigns,weightSign,signAt,labelReal]
  have he := signed_compressedEnergy_le_of_not_exceptional w hJ p.val (fun _ _=>true) hq
  rw [heq] at he
  exact balanced_partition_grid_cover hd hN p.val hq w hp.2 he

end NeuralGeneralization.BatchTwoOnlineBalanced
