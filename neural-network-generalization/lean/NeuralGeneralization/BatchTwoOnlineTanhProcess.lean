import NeuralGeneralization.BatchTwoOnlineTanhPosteriorCover
import NeuralGeneralization.BatchTwoOnlineRemainingLaw
import NeuralGeneralization.BatchTwoOnlineMergingProcess

/-! The literal merging-restricted posterior is an adapted raw-posterior
process, controlled by one grid fixed before the random permutation. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineTanhMerging
open ConcreteModel BatchTwoMerging BatchTwoOnline BatchTwoOnlineRaw

variable {d C r N : ℕ}

def tanhMergingPrefixPosterior (noiseMargin globalMargin : Bool) (c0 σ : ℝ) (f : BooleanFunction d)
    (i : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) : Measure (Weights d N r) :=
  tanhPosterior noiseMargin globalMargin c0 σ f (prefixSample i π)

def tanhMergingRoundRisk (noiseMargin globalMargin : Bool) (c0 σ : ℝ) (f : BooleanFunction d)
    (i : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) : ℝ :=
  (tanhMergingPrefixPosterior (N:=N) (r:=r) noiseMargin globalMargin c0 σ f i π).real
    {w | labelReal (f (cubeEnumeration d (π i)))*networkOutput Real.tanh w (cubeEnumeration d (π i))≤1/4}

theorem tanh_mergingPrefix_probability (hd : 0<d) (hC : 0<C) (B : LayeredBooleanCircuit d C r)
    (hCN : C ≤ N) {c0 σ : ℝ} (hc0 : 0<c0) (hσ : 0<σ) (hscale : (N : ℝ)*σ^2≤1)
    (noiseMargin globalMargin : Bool) (i : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) :
    IsProbabilityMeasure (tanhMergingPrefixPosterior (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes i π) := by
  exact tanh_posterior_probability hd hC hCN B hc0 hσ hscale noiseMargin globalMargin (prefixSample i π)

theorem tanh_mergingRound_adapted (noiseMargin globalMargin : Bool) (c0 σ : ℝ) (f : BooleanFunction d)
    (i k j : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) (hik : i.val<k.val) (hkj : k.val≤j.val) :
    tanhMergingRoundRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ f i (π*Equiv.swap k j)=
      tanhMergingRoundRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ f i π := by
  have hi : Equiv.swap k j i=i := by
    apply Equiv.swap_apply_of_ne_of_ne <;> intro he <;> subst i <;> omega
  simp only [tanhMergingRoundRisk,tanhMergingPrefixPosterior,prefixSample_swap i k j π hik.le hkj,
    Equiv.Perm.mul_apply,hi]

theorem tanh_remainingAverage_mergingRound (noiseMargin globalMargin : Bool) (c0 σ : ℝ) (f : BooleanFunction d)
    (i : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) :
    remainingAverage (tanhMergingRoundRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ f i) i π=
      RobustConfidence.gibbsMarginRisk (remainingLaw i)
        (tanhMergingPrefixPosterior (N:=N) (r:=r) noiseMargin globalMargin c0 σ f i π)
        (fun j => labelReal (f (cubeEnumeration d (π j))))
        (fun w j => networkOutput Real.tanh w (cubeEnumeration d (π j))) (1/4) := by
  unfold RobustConfidence.gibbsMarginRisk
  rw [remainingLaw_integral]
  unfold remainingAverage
  congr 1
  apply Finset.sum_congr rfl
  intro j _
  by_cases hj : i.val≤j.val
  · simp only [if_pos hj,tanhMergingRoundRisk,tanhMergingPrefixPosterior,
      prefixSample_swap i i j π le_rfl hj,Equiv.Perm.mul_apply,Equiv.swap_apply_left]
  · simp [hj]

def tanhMergingGridGood (c0 ε : ℝ) (f : BooleanFunction d) (c : TanhMainGridCode d C r c0 ε)
    (j : Fin (cubeSize d)) : Prop :=
  11/32<labelReal (f (cubeEnumeration d j))*clippedScore (tanhMainGridFunction d C r c0 ε c (cubeEnumeration d j))

theorem tanh_mergingRound_control (hd : 0<d) (hC : 0<C) (B : LayeredBooleanCircuit d C r)
    (hCN : C ≤ N) {c0 σ ε : ℝ} (hc0 : 0<c0) (hσ : 0<σ) (hscale : (N : ℝ)*σ^2≤1)
    (hε : 0<ε) (hε1 : ε≤1) (noiseMargin globalMargin : Bool)
    (i : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) (hi : 0 < i.val)
    (u : ℝ) (hu : 0≤u)
    (hs : ∀c, prefixKeep (tanhMergingGridGood (C:=C) (r:=r) c0 ε B.computes) π i.val c →
      domainError (tanhMergingGridGood (C:=C) (r:=r) c0 ε B.computes) c≤u) :
    remainingAverage (tanhMergingRoundRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes i) i π≤
      (cubeSize d : ℝ)/(cubeSize d-i.val : ℕ)*u+ε/2 := by
  classical
  haveI := tanh_mergingPrefix_probability hd hC B hCN hc0 hσ hscale noiseMargin globalMargin i π
  rw [tanh_remainingAverage_mergingRound]
  obtain ⟨_,E,hE,htail,hcover⟩ := tanh_merging_posterior_cover hd hC B hCN hc0 hσ hscale hε hε1
    noiseMargin globalMargin (prefixSample i π) hi
  refine posterior_risk_of_consistent_cover (remainingLaw i)
    (tanhMergingPrefixPosterior (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes i π)
    (fun j=>B.computes (cubeEnumeration d (π j)))
    (fun c j=>tanhMainGridFunction d C r c0 ε c (cubeEnumeration d (π j)))
    (fun j : Fin i.val=>⟨j.val,lt_trans j.isLt i.isLt⟩)
    (by positivity) ?_ (fun w j => networkOutput Real.tanh w (cubeEnumeration d (π j)))
    (fun j => (continuous_networkOutput tanh_continuous (cubeEnumeration d (π j))).measurable)
    E hE htail ?_
  · intro c hc
    have hk : prefixKeep (tanhMergingGridGood (C:=C) (r:=r) c0 ε B.computes) π i.val c := by
      intro j hj
      have hh := hc ⟨j.val,hj⟩
      simp only [comparisonLoss] at hh
      unfold tanhMergingGridGood
      split_ifs at hh with h
      · norm_num at hh
      · exact lt_of_not_ge h
    have he := remainingLaw_comparison_integral i π (fun j=>B.computes (cubeEnumeration d j))
      (fun c j=>tanhMainGridFunction d C r c0 ε c (cubeEnumeration d j)) c
    simp only [Function.comp_def] at he
    rw [he]
    change remainingLoss (tanhMergingGridGood (C:=C) (r:=r) c0 ε B.computes) π i.val c ≤ _
    rw [remainingLoss_eq _ π i.val i.isLt c hk]
    exact mul_le_mul_of_nonneg_left (hs c hk) (by positivity)
  · filter_upwards [hcover] with w hw
    refine ⟨hw.1,?_⟩
    intro he
    obtain ⟨c,hc⟩ := hw.2 he
    exact ⟨c,fun j=>hc (cubeEnumeration d (π j))⟩

/-- No posterior-class surrogate appears here: `risk` is the literal
probability of a tested-margin error under the conditioned neural measure. -/
def tanhMergingCoverProcess (hd : 0<d) (hC : 0<C) (B : LayeredBooleanCircuit d C r)
    (hCN : C ≤ N) {c0 σ ε : ℝ} (hc0 : 0<c0) (hσ : 0<σ) (hscale : (N : ℝ)*σ^2≤1)
    (hε : 0<ε) (hε1 : ε≤1) (noiseMargin globalMargin : Bool) :
    CoverProcess Finset.univ (tanhMergingGridGood (C:=C) (r:=r) c0 ε B.computes) (ε/2) where
  risk := tanhMergingRoundRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes
  range := by
    intro i π
    haveI := tanh_mergingPrefix_probability hd hC B hCN hc0 hσ hscale noiseMargin globalMargin i π
    exact ⟨measureReal_nonneg, (measureReal_mono (Set.subset_univ _)).trans_eq probReal_univ⟩
  adapted := tanh_mergingRound_adapted noiseMargin globalMargin c0 σ B.computes
  control := by
    intro i π hi u hu hs
    exact tanh_mergingRound_control hd hC B hCN hc0 hσ hscale hε hε1 noiseMargin globalMargin i π hi u hu
      (fun c=>hs c (Finset.mem_univ c))

end NeuralGeneralization.BatchTwoOnlineTanhMerging
