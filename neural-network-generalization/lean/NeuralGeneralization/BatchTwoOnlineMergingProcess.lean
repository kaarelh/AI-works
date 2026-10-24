import NeuralGeneralization.BatchTwoOnlineMergingCover
import NeuralGeneralization.BatchTwoOnlineRemainingLaw
import NeuralGeneralization.BatchTwoOnlineNetwork

/-! The literal merging-restricted posterior is an adapted raw-posterior
process, controlled by one grid fixed before the random permutation. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineRaw
open ConcreteModel BatchTwoMerging BatchTwoOnline

variable {d C r N : ℕ}

abbrev cubeSize (d : ℕ) := Fintype.card (Cube d)

def prefixSample (i : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) : Fin i.val → Cube d :=
  fun j => cubeEnumeration d (π ⟨j.val,lt_trans j.isLt i.isLt⟩)

def mergingPrefixPosterior (globalMargin : Bool) (σ : ℝ) (f : BooleanFunction d)
    (i : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) : Measure (Weights d N r) :=
  BatchTwoMerging.posterior relu globalMargin σ f (prefixSample i π)

def mergingRoundRisk (globalMargin : Bool) (σ : ℝ) (f : BooleanFunction d)
    (i : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) : ℝ :=
  (mergingPrefixPosterior (N:=N) (r:=r) globalMargin σ f i π).real
    {w | labelReal (f (cubeEnumeration d (π i)))*networkOutput relu w (cubeEnumeration d (π i))≤1/4}

theorem mergingPrefix_probability (hd : 0<d) (hC : 0<C) (B : LayeredNorCircuit d C r)
    (hCN : C≤N) {σ : ℝ} (hσ : 0<σ) (hscale : (N : ℝ)*σ^2≤1)
    (globalMargin : Bool) (i : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) :
    IsProbabilityMeasure (mergingPrefixPosterior (N:=N) (r:=r) globalMargin σ B.computes i π) := by
  have hp := posterior_event_pos relu globalMargin σ B.computes (prefixSample i π)
    (merging_target_mass_all_widths hd hC hCN B hσ hscale)
  apply cond_isProbabilityMeasure
  intro he
  simp only [Measure.real,he,ENNReal.toReal_zero] at hp
  exact (lt_irrefl 0) hp

theorem prefixSample_swap (i k j : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d)))
    (hik : i.val≤k.val) (hkj : k.val≤j.val) : prefixSample i (π*Equiv.swap k j)=prefixSample i π := by
  funext x
  have hx : Equiv.swap k j ⟨x.val,lt_trans x.isLt i.isLt⟩=⟨x.val,lt_trans x.isLt i.isLt⟩ := by
    apply Equiv.swap_apply_of_ne_of_ne <;> intro he <;> apply_fun Fin.val at he <;> simp only at he <;> omega
  simp only [prefixSample,Equiv.Perm.mul_apply,hx]

theorem mergingRound_adapted (globalMargin : Bool) (σ : ℝ) (f : BooleanFunction d)
    (i k j : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) (hik : i.val<k.val) (hkj : k.val≤j.val) :
    mergingRoundRisk (N:=N) (r:=r) globalMargin σ f i (π*Equiv.swap k j)=
      mergingRoundRisk (N:=N) (r:=r) globalMargin σ f i π := by
  have hi : Equiv.swap k j i=i := by
    apply Equiv.swap_apply_of_ne_of_ne <;> intro he <;> subst i <;> omega
  simp only [mergingRoundRisk,mergingPrefixPosterior,prefixSample_swap i k j π hik.le hkj,
    Equiv.Perm.mul_apply,hi]

theorem remainingAverage_mergingRound (globalMargin : Bool) (σ : ℝ) (f : BooleanFunction d)
    (i : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) :
    remainingAverage (mergingRoundRisk (N:=N) (r:=r) globalMargin σ f i) i π=
      RobustConfidence.gibbsMarginRisk (remainingLaw i)
        (mergingPrefixPosterior (N:=N) (r:=r) globalMargin σ f i π)
        (fun j => labelReal (f (cubeEnumeration d (π j))))
        (fun w j => networkOutput relu w (cubeEnumeration d (π j))) (1/4) := by
  unfold RobustConfidence.gibbsMarginRisk
  rw [remainingLaw_integral]
  unfold remainingAverage
  congr 1
  apply Finset.sum_congr rfl
  intro j _
  by_cases hj : i.val≤j.val
  · simp only [if_pos hj,mergingRoundRisk,mergingPrefixPosterior,
      prefixSample_swap i i j π le_rfl hj,Equiv.Perm.mul_apply,Equiv.swap_apply_left]
  · simp [hj]

def mergingGridGood (ε : ℝ) (f : BooleanFunction d) (c : MainGridCode d C r ε)
    (j : Fin (cubeSize d)) : Prop :=
  11/32<labelReal (f (cubeEnumeration d j))*clippedScore (mainGridFunction d C r ε c (cubeEnumeration d j))

theorem mergingRound_control (hd : 0<d) (hC : 0<C) (B : LayeredNorCircuit d C r)
    (hCN : C≤N) {σ ε : ℝ} (hσ : 0<σ) (hscale : (N : ℝ)*σ^2≤1)
    (hε : 0<ε) (hε1 : ε≤1) (globalMargin : Bool)
    (i : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) (hi : 0 < i.val)
    (u : ℝ) (hu : 0≤u)
    (hs : ∀c, prefixKeep (mergingGridGood (C:=C) (r:=r) ε B.computes) π i.val c →
      domainError (mergingGridGood (C:=C) (r:=r) ε B.computes) c≤u) :
    remainingAverage (mergingRoundRisk (N:=N) (r:=r) globalMargin σ B.computes i) i π≤
      (cubeSize d : ℝ)/(cubeSize d-i.val : ℕ)*u+ε/2 := by
  classical
  haveI := mergingPrefix_probability hd hC B hCN hσ hscale globalMargin i π
  rw [remainingAverage_mergingRound]
  obtain ⟨_,E,hE,htail,hcover⟩ := merging_posterior_cover hd hC B hCN hσ hscale hε hε1
    globalMargin (prefixSample i π) hi
  refine posterior_risk_of_consistent_cover (remainingLaw i)
    (mergingPrefixPosterior (N:=N) (r:=r) globalMargin σ B.computes i π)
    (fun j=>B.computes (cubeEnumeration d (π j)))
    (fun c j=>mainGridFunction d C r ε c (cubeEnumeration d (π j)))
    (fun j : Fin i.val=>⟨j.val,lt_trans j.isLt i.isLt⟩)
    (by positivity) ?_ (fun w j => networkOutput relu w (cubeEnumeration d (π j)))
    (fun j => (continuous_networkOutput continuous_relu (cubeEnumeration d (π j))).measurable)
    E hE htail ?_
  · intro c hc
    have hk : prefixKeep (mergingGridGood (C:=C) (r:=r) ε B.computes) π i.val c := by
      intro j hj
      have hh := hc ⟨j.val,hj⟩
      simp only [comparisonLoss] at hh
      unfold mergingGridGood
      split_ifs at hh with h
      · norm_num at hh
      · exact lt_of_not_ge h
    have he := remainingLaw_comparison_integral i π (fun j=>B.computes (cubeEnumeration d j))
      (fun c j=>mainGridFunction d C r ε c (cubeEnumeration d j)) c
    simp only [Function.comp_def] at he
    rw [he]
    change remainingLoss (mergingGridGood (C:=C) (r:=r) ε B.computes) π i.val c ≤ _
    rw [remainingLoss_eq _ π i.val i.isLt c hk]
    exact mul_le_mul_of_nonneg_left (hs c hk) (by positivity)
  · filter_upwards [hcover] with w hw
    refine ⟨hw.1,?_⟩
    intro he
    obtain ⟨c,hc⟩ := hw.2 he
    exact ⟨c,fun j=>hc (cubeEnumeration d (π j))⟩

/-- No posterior-class surrogate appears here: `risk` is the literal
probability of a tested-margin error under the conditioned neural measure. -/
def mergingCoverProcess (hd : 0<d) (hC : 0<C) (B : LayeredNorCircuit d C r)
    (hCN : C≤N) {σ ε : ℝ} (hσ : 0<σ) (hscale : (N : ℝ)*σ^2≤1)
    (hε : 0<ε) (hε1 : ε≤1) (globalMargin : Bool) :
    CoverProcess Finset.univ (mergingGridGood (C:=C) (r:=r) ε B.computes) (ε/2) where
  risk := mergingRoundRisk (N:=N) (r:=r) globalMargin σ B.computes
  range := by
    intro i π
    haveI := mergingPrefix_probability hd hC B hCN hσ hscale globalMargin i π
    exact ⟨measureReal_nonneg, (measureReal_mono (Set.subset_univ _)).trans_eq probReal_univ⟩
  adapted := mergingRound_adapted globalMargin σ B.computes
  control := by
    intro i π hi u hu hs
    exact mergingRound_control hd hC B hCN hσ hscale hε hε1 globalMargin i π hi u hu
      (fun c=>hs c (Finset.mem_univ c))

end NeuralGeneralization.BatchTwoOnlineRaw
