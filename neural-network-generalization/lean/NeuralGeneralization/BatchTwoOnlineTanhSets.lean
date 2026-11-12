import NeuralGeneralization.BatchTwoOnlineTanhMain
import NeuralGeneralization.BatchTwoOnlineRawFirstAppearance

/-! The merging posterior depends on the set of previous examples, and
its tested-margin error probability vanishes at repeated examples. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineTanhMerging
open ConcreteModel BatchTwoMerging BatchTwoOnline BatchTwoOnlineRaw
variable {d N r : ℕ}

def tanhMergingSetEvent (noiseMargin globalMargin : Bool) (c0 : ℝ) (f : BooleanFunction d) (S : Finset (Fin (cubeSize d))) :
    Set (Weights d N r) := tanhRestrictedSupport noiseMargin globalMargin c0 ∩
      {w | ∀x∈S,(1/2:ℝ)<labelReal (f (cubeEnumeration d x))*networkOutput Real.tanh w (cubeEnumeration d x)}

def tanhMergingSetRisk (noiseMargin globalMargin : Bool) (c0 : ℝ) (σ : ℝ) (f : BooleanFunction d)
    (S : Finset (Fin (cubeSize d))) (x : Fin (cubeSize d)) : ℝ :=
  (cond (smallPrior d N r σ) (tanhMergingSetEvent noiseMargin globalMargin c0 f S)).real
    {w | labelReal (f (cubeEnumeration d x))*networkOutput Real.tanh w (cubeEnumeration d x)≤1/4}

theorem tanh_measurable_mergingSetEvent (noiseMargin globalMargin : Bool) {c0 : ℝ} (hc0 : 0<c0) (f : BooleanFunction d) (S : Finset (Fin (cubeSize d))) :
    MeasurableSet (tanhMergingSetEvent (N:=N) (r:=r) noiseMargin globalMargin c0 f S) := by
  apply (measurable_tanhRestrictedSupport noiseMargin globalMargin hc0).inter
  simp only [Set.setOf_forall]
  apply MeasurableSet.iInter
  intro x
  apply MeasurableSet.iInter
  intro _
  exact measurableSet_lt measurable_const
    ((continuous_networkOutput tanh_continuous (cubeEnumeration d x)).measurable.const_mul _)

theorem tanh_mergingSetRisk_nonneg (noiseMargin globalMargin : Bool) (c0 : ℝ) (σ : ℝ) (f : BooleanFunction d)
    (S : Finset (Fin (cubeSize d))) (x : Fin (cubeSize d)) :
    0≤tanhMergingSetRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ f S x := measureReal_nonneg

theorem tanh_mergingSetRisk_repeated (noiseMargin globalMargin : Bool) {c0 : ℝ} (hc0 : 0<c0) (σ : ℝ) (f : BooleanFunction d)
    (S : Finset (Fin (cubeSize d))) (x : Fin (cubeSize d)) (hx : x∈S) :
    tanhMergingSetRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ f S x=0 := by
  have hae:=ae_cond_mem (μ:=smallPrior d N r σ) (tanh_measurable_mergingSetEvent noiseMargin globalMargin hc0 f S)
  have hz : (cond (smallPrior d N r σ) (tanhMergingSetEvent noiseMargin globalMargin c0 f S))
      {w | labelReal (f (cubeEnumeration d x))*networkOutput Real.tanh w (cubeEnumeration d x)≤1/4}=0 := by
    apply measure_mono_null _ (ae_iff.mp hae)
    intro w hw he
    have hh:=he.2 x hx
    change labelReal (f (cubeEnumeration d x))*networkOutput Real.tanh w (cubeEnumeration d x)≤1/4 at hw
    exact (by linarith : False)
  exact by simp only [tanhMergingSetRisk,Measure.real,hz,ENNReal.toReal_zero]

theorem tanh_mergingSetEvent_prefix (noiseMargin globalMargin : Bool) (c0 : ℝ) (f : BooleanFunction d)
    (i : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) :
    tanhMergingSetEvent (N:=N) (r:=r) noiseMargin globalMargin c0 f (permutationSeen π i)=
      tanhPosteriorEvent noiseMargin globalMargin c0 f (prefixSample i π) := by
  ext w
  simp only [tanhMergingSetEvent,tanhPosteriorEvent,Set.mem_inter_iff,Set.mem_setOf_eq,
    RobustPosterior.trainingMarginEvent]
  apply and_congr_right
  intro _
  constructor
  · intro h j
    exact h (π ⟨j.val,lt_trans j.isLt i.isLt⟩)
      ((mem_permutationSeen π i _).mpr (by simpa using j.isLt))
  · intro h x hx
    have hi:=(mem_permutationSeen π i x).mp hx
    have hh:=h ⟨(π.symm x).val,hi⟩
    simpa only [prefixSample,Fin.eta,π.apply_symm_apply] using hh

theorem tanh_mergingSetRisk_permutation (noiseMargin globalMargin : Bool) (c0 : ℝ) (σ : ℝ) (f : BooleanFunction d)
    (i : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) :
    tanhMergingSetRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ f (permutationSeen π i) (π i)=
      tanhMergingRoundRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ f i π := by
  simp only [tanhMergingSetRisk,tanh_mergingSetEvent_prefix,tanhMergingRoundRisk,tanhMergingPrefixPosterior,tanhPosterior]

theorem tanh_setPermutationRisk_merging (noiseMargin globalMargin : Bool) (c0 : ℝ) (σ : ℝ) (f : BooleanFunction d) :
    setPermutationRisk (tanhMergingSetRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ f)=
      tanhMergingPermutationRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ f := by
  funext π
  simp only [setPermutationRisk,tanhMergingPermutationRisk,tanh_mergingSetRisk_permutation]

/-- Literal prefix conditioning, with repeated observations retained, agrees
with the set-based risk used by the infinite-stream theorem. -/
theorem tanh_mergingSetRisk_sample {n : ℕ} (noiseMargin globalMargin : Bool) (c0 : ℝ) (σ : ℝ) (f : BooleanFunction d)
    (s : Fin n→Fin (cubeSize d)) (i : Fin n) :
    tanhMergingSetRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ f (seenSet s i) (s i)=
      (tanhPosterior (N:=N) (r:=r) noiseMargin globalMargin c0 σ f
        (fun j : Fin i.val=>cubeEnumeration d (s ⟨j.val,lt_trans j.isLt i.isLt⟩))).real
      {w | labelReal (f (cubeEnumeration d (s i)))*networkOutput Real.tanh w (cubeEnumeration d (s i))≤1/4} := by
  have he:tanhMergingSetEvent (N:=N) (r:=r) noiseMargin globalMargin c0 f (seenSet s i)=
      tanhPosteriorEvent noiseMargin globalMargin c0 f
        (fun j : Fin i.val=>cubeEnumeration d (s ⟨j.val,lt_trans j.isLt i.isLt⟩)) := by
    ext w
    simp only [tanhMergingSetEvent,tanhPosteriorEvent,Set.mem_inter_iff,Set.mem_setOf_eq,
      RobustPosterior.trainingMarginEvent]
    apply and_congr_right
    intro _
    constructor
    · intro h j
      exact h _ ((mem_seenSet s i _).mpr ⟨⟨j.val,lt_trans j.isLt i.isLt⟩,j.isLt,rfl⟩)
    · intro h x hx
      obtain ⟨j,hj,rfl⟩:=(mem_seenSet s i x).mp hx
      exact h ⟨j.val,hj⟩
  simp only [tanhMergingSetRisk,he,tanhPosterior]

end NeuralGeneralization.BatchTwoOnlineTanhMerging
