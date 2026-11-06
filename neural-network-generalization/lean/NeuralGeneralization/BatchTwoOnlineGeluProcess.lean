import NeuralGeneralization.BatchTwoOnlineGeluCover
import NeuralGeneralization.BatchTwoOnlineRemainingLaw
import NeuralGeneralization.BatchTwoOnlineMergingProcess

/-! The literal merging-restricted posterior is an adapted raw-posterior
process, controlled by one grid fixed before the random permutation. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineRaw
open ConcreteModel BatchTwoMerging BatchTwoOnline

variable {d C r N : ℕ}

def geluMergingPrefixPosterior (globalMargin : Bool) (σ : ℝ) (f : BooleanFunction d)
    (i : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) : Measure (Weights d N r) :=
  BatchTwoMerging.posterior gelu globalMargin σ f (prefixSample i π)

def geluMergingRoundRisk (globalMargin : Bool) (σ : ℝ) (f : BooleanFunction d)
    (i : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) : ℝ :=
  (geluMergingPrefixPosterior (N:=N) (r:=r) globalMargin σ f i π).real
    {w | labelReal (f (cubeEnumeration d (π i)))*networkOutput gelu w (cubeEnumeration d (π i))≤1/4}

theorem gelu_mergingPrefix_probability (hd : 0<d) (hC : 0<C) (B : LayeredNorCircuit d C r)
    (hCN : 2*C ≤ N) {σ : ℝ} (hσ : 0<σ) (hscale : (N : ℝ)*σ^2≤1)
    (globalMargin : Bool) (i : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) :
    IsProbabilityMeasure (geluMergingPrefixPosterior (N:=N) (r:=r) globalMargin σ B.computes i π) := by
  have hp := posterior_event_pos gelu globalMargin σ B.computes (prefixSample i π)
    (gelu_merging_target_mass_all_widths hd hC hCN B hσ hscale)
  apply cond_isProbabilityMeasure
  intro he
  simp only [Measure.real,he,ENNReal.toReal_zero] at hp
  exact (lt_irrefl 0) hp

theorem gelu_mergingRound_adapted (globalMargin : Bool) (σ : ℝ) (f : BooleanFunction d)
    (i k j : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) (hik : i.val<k.val) (hkj : k.val≤j.val) :
    geluMergingRoundRisk (N:=N) (r:=r) globalMargin σ f i (π*Equiv.swap k j)=
      geluMergingRoundRisk (N:=N) (r:=r) globalMargin σ f i π := by
  have hi : Equiv.swap k j i=i := by
    apply Equiv.swap_apply_of_ne_of_ne <;> intro he <;> subst i <;> omega
  simp only [geluMergingRoundRisk,geluMergingPrefixPosterior,prefixSample_swap i k j π hik.le hkj,
    Equiv.Perm.mul_apply,hi]

theorem gelu_remainingAverage_mergingRound (globalMargin : Bool) (σ : ℝ) (f : BooleanFunction d)
    (i : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) :
    remainingAverage (geluMergingRoundRisk (N:=N) (r:=r) globalMargin σ f i) i π=
      RobustConfidence.gibbsMarginRisk (remainingLaw i)
        (geluMergingPrefixPosterior (N:=N) (r:=r) globalMargin σ f i π)
        (fun j => labelReal (f (cubeEnumeration d (π j))))
        (fun w j => networkOutput gelu w (cubeEnumeration d (π j))) (1/4) := by
  unfold RobustConfidence.gibbsMarginRisk
  rw [remainingLaw_integral]
  unfold remainingAverage
  congr 1
  apply Finset.sum_congr rfl
  intro j _
  by_cases hj : i.val≤j.val
  · simp only [if_pos hj,geluMergingRoundRisk,geluMergingPrefixPosterior,
      prefixSample_swap i i j π le_rfl hj,Equiv.Perm.mul_apply,Equiv.swap_apply_left]
  · simp [hj]

def geluMergingGridGood (ε : ℝ) (f : BooleanFunction d) (c : GeluMainGridCode d C r ε)
    (j : Fin (cubeSize d)) : Prop :=
  11/32<labelReal (f (cubeEnumeration d j))*clippedScore (geluMainGridFunction d C r ε c (cubeEnumeration d j))

theorem gelu_mergingRound_control (hd : 0<d) (hC : 0<C) (B : LayeredNorCircuit d C r)
    (hCN : 2*C ≤ N) {σ ε : ℝ} (hσ : 0<σ) (hscale : (N : ℝ)*σ^2≤1)
    (hε : 0<ε) (hε1 : ε≤1) (globalMargin : Bool)
    (i : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) (hi : 0 < i.val)
    (u : ℝ) (hu : 0≤u)
    (hs : ∀c, prefixKeep (geluMergingGridGood (C:=C) (r:=r) ε B.computes) π i.val c →
      domainError (geluMergingGridGood (C:=C) (r:=r) ε B.computes) c≤u) :
    remainingAverage (geluMergingRoundRisk (N:=N) (r:=r) globalMargin σ B.computes i) i π≤
      (cubeSize d : ℝ)/(cubeSize d-i.val : ℕ)*u+ε/2 := by
  classical
  haveI := gelu_mergingPrefix_probability hd hC B hCN hσ hscale globalMargin i π
  rw [gelu_remainingAverage_mergingRound]
  obtain ⟨_,E,hE,htail,hcover⟩ := gelu_merging_posterior_cover hd hC B hCN hσ hscale hε hε1
    globalMargin (prefixSample i π) hi
  refine posterior_risk_of_consistent_cover (remainingLaw i)
    (geluMergingPrefixPosterior (N:=N) (r:=r) globalMargin σ B.computes i π)
    (fun j=>B.computes (cubeEnumeration d (π j)))
    (fun c j=>geluMainGridFunction d C r ε c (cubeEnumeration d (π j)))
    (fun j : Fin i.val=>⟨j.val,lt_trans j.isLt i.isLt⟩)
    (by positivity) ?_ (fun w j => networkOutput gelu w (cubeEnumeration d (π j)))
    (fun j => (continuous_networkOutput gelu_lipschitz.continuous (cubeEnumeration d (π j))).measurable)
    E hE htail ?_
  · intro c hc
    have hk : prefixKeep (geluMergingGridGood (C:=C) (r:=r) ε B.computes) π i.val c := by
      intro j hj
      have hh := hc ⟨j.val,hj⟩
      simp only [comparisonLoss] at hh
      unfold geluMergingGridGood
      split_ifs at hh with h
      · norm_num at hh
      · exact lt_of_not_ge h
    have he := remainingLaw_comparison_integral i π (fun j=>B.computes (cubeEnumeration d j))
      (fun c j=>geluMainGridFunction d C r ε c (cubeEnumeration d j)) c
    simp only [Function.comp_def] at he
    rw [he]
    change remainingLoss (geluMergingGridGood (C:=C) (r:=r) ε B.computes) π i.val c ≤ _
    rw [remainingLoss_eq _ π i.val i.isLt c hk]
    exact mul_le_mul_of_nonneg_left (hs c hk) (by positivity)
  · filter_upwards [hcover] with w hw
    refine ⟨hw.1,?_⟩
    intro he
    obtain ⟨c,hc⟩ := hw.2 he
    exact ⟨c,fun j=>hc (cubeEnumeration d (π j))⟩

/-- No posterior-class surrogate appears here: `risk` is the literal
probability of a tested-margin error under the conditioned neural measure. -/
def geluMergingCoverProcess (hd : 0<d) (hC : 0<C) (B : LayeredNorCircuit d C r)
    (hCN : 2*C ≤ N) {σ ε : ℝ} (hσ : 0<σ) (hscale : (N : ℝ)*σ^2≤1)
    (hε : 0<ε) (hε1 : ε≤1) (globalMargin : Bool) :
    CoverProcess Finset.univ (geluMergingGridGood (C:=C) (r:=r) ε B.computes) (ε/2) where
  risk := geluMergingRoundRisk (N:=N) (r:=r) globalMargin σ B.computes
  range := by
    intro i π
    haveI := gelu_mergingPrefix_probability hd hC B hCN hσ hscale globalMargin i π
    exact ⟨measureReal_nonneg, (measureReal_mono (Set.subset_univ _)).trans_eq probReal_univ⟩
  adapted := gelu_mergingRound_adapted globalMargin σ B.computes
  control := by
    intro i π hi u hu hs
    exact gelu_mergingRound_control hd hC B hCN hσ hscale hε hε1 globalMargin i π hi u hu
      (fun c=>hs c (Finset.mem_univ c))

end NeuralGeneralization.BatchTwoOnlineRaw
