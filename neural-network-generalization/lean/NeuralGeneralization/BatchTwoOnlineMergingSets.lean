import NeuralGeneralization.BatchTwoOnlineMergingMain
import NeuralGeneralization.BatchTwoOnlineRawFirstAppearance

/-! The merging posterior depends on the set of previous examples, and
its tested-margin error probability vanishes at repeated examples. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineRaw
open ConcreteModel BatchTwoMerging BatchTwoOnline
variable {d N r : ℕ}

def mergingSetEvent (globalMargin : Bool) (f : BooleanFunction d) (S : Finset (Fin (cubeSize d))) :
    Set (Weights d N r) := restrictedSupport relu globalMargin ∩
      {w | ∀x∈S,(1/2:ℝ)<labelReal (f (cubeEnumeration d x))*networkOutput relu w (cubeEnumeration d x)}

def mergingSetRisk (globalMargin : Bool) (σ : ℝ) (f : BooleanFunction d)
    (S : Finset (Fin (cubeSize d))) (x : Fin (cubeSize d)) : ℝ :=
  (cond (smallPrior d N r σ) (mergingSetEvent globalMargin f S)).real
    {w | labelReal (f (cubeEnumeration d x))*networkOutput relu w (cubeEnumeration d x)≤1/4}

theorem measurable_mergingSetEvent (globalMargin : Bool) (f : BooleanFunction d) (S : Finset (Fin (cubeSize d))) :
    MeasurableSet (mergingSetEvent (N:=N) (r:=r) globalMargin f S) := by
  apply (measurable_restrictedSupport continuous_relu globalMargin).inter
  simp only [Set.setOf_forall]
  apply MeasurableSet.iInter
  intro x
  apply MeasurableSet.iInter
  intro _
  exact measurableSet_lt measurable_const
    ((continuous_networkOutput continuous_relu (cubeEnumeration d x)).measurable.const_mul _)

theorem mergingSetRisk_nonneg (globalMargin : Bool) (σ : ℝ) (f : BooleanFunction d)
    (S : Finset (Fin (cubeSize d))) (x : Fin (cubeSize d)) :
    0≤mergingSetRisk (N:=N) (r:=r) globalMargin σ f S x := measureReal_nonneg

theorem mergingSetRisk_repeated (globalMargin : Bool) (σ : ℝ) (f : BooleanFunction d)
    (S : Finset (Fin (cubeSize d))) (x : Fin (cubeSize d)) (hx : x∈S) :
    mergingSetRisk (N:=N) (r:=r) globalMargin σ f S x=0 := by
  have hae:=ae_cond_mem (μ:=smallPrior d N r σ) (measurable_mergingSetEvent globalMargin f S)
  have hz : (cond (smallPrior d N r σ) (mergingSetEvent globalMargin f S))
      {w | labelReal (f (cubeEnumeration d x))*networkOutput relu w (cubeEnumeration d x)≤1/4}=0 := by
    apply measure_mono_null _ (ae_iff.mp hae)
    intro w hw he
    have hh:=he.2 x hx
    change labelReal (f (cubeEnumeration d x))*networkOutput relu w (cubeEnumeration d x)≤1/4 at hw
    exact (by linarith : False)
  exact by simp only [mergingSetRisk,Measure.real,hz,ENNReal.toReal_zero]

theorem mergingSetEvent_prefix (globalMargin : Bool) (f : BooleanFunction d)
    (i : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) :
    mergingSetEvent (N:=N) (r:=r) globalMargin f (permutationSeen π i)=
      posteriorEvent relu globalMargin f (prefixSample i π) := by
  ext w
  simp only [mergingSetEvent,posteriorEvent,Set.mem_inter_iff,Set.mem_setOf_eq,
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

theorem mergingSetRisk_permutation (globalMargin : Bool) (σ : ℝ) (f : BooleanFunction d)
    (i : Fin (cubeSize d)) (π : Equiv.Perm (Fin (cubeSize d))) :
    mergingSetRisk (N:=N) (r:=r) globalMargin σ f (permutationSeen π i) (π i)=
      mergingRoundRisk (N:=N) (r:=r) globalMargin σ f i π := by
  simp only [mergingSetRisk,mergingSetEvent_prefix,mergingRoundRisk,mergingPrefixPosterior,BatchTwoMerging.posterior]

theorem setPermutationRisk_merging (globalMargin : Bool) (σ : ℝ) (f : BooleanFunction d) :
    setPermutationRisk (mergingSetRisk (N:=N) (r:=r) globalMargin σ f)=
      mergingPermutationRisk (N:=N) (r:=r) globalMargin σ f := by
  funext π
  simp only [setPermutationRisk,mergingPermutationRisk,mergingSetRisk_permutation]

/-- Literal prefix conditioning, with repeated observations retained, agrees
with the set-based risk used by the infinite-stream theorem. -/
theorem mergingSetRisk_sample {n : ℕ} (globalMargin : Bool) (σ : ℝ) (f : BooleanFunction d)
    (s : Fin n→Fin (cubeSize d)) (i : Fin n) :
    mergingSetRisk (N:=N) (r:=r) globalMargin σ f (seenSet s i) (s i)=
      (BatchTwoMerging.posterior (N:=N) (r:=r) relu globalMargin σ f
        (fun j : Fin i.val=>cubeEnumeration d (s ⟨j.val,lt_trans j.isLt i.isLt⟩))).real
      {w | labelReal (f (cubeEnumeration d (s i)))*networkOutput relu w (cubeEnumeration d (s i))≤1/4} := by
  have he:mergingSetEvent (N:=N) (r:=r) globalMargin f (seenSet s i)=
      posteriorEvent relu globalMargin f
        (fun j : Fin i.val=>cubeEnumeration d (s ⟨j.val,lt_trans j.isLt i.isLt⟩)) := by
    ext w
    simp only [mergingSetEvent,posteriorEvent,Set.mem_inter_iff,Set.mem_setOf_eq,
      RobustPosterior.trainingMarginEvent]
    apply and_congr_right
    intro _
    constructor
    · intro h j
      exact h _ ((mem_seenSet s i _).mpr ⟨⟨j.val,lt_trans j.isLt i.isLt⟩,j.isLt,rfl⟩)
    · intro h x hx
      obtain ⟨j,hj,rfl⟩:=(mem_seenSet s i x).mp hx
      exact h ⟨j.val,hj⟩
  simp only [mergingSetRisk,he,BatchTwoMerging.posterior]

end NeuralGeneralization.BatchTwoOnlineRaw
