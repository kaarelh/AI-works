import NeuralGeneralization.BatchTwoOnlineBalancedGroups
import NeuralGeneralization.BatchTwoOnlineTanhSignedSupport

/-! The literal common-count balanced-population support used in the online theorem. -/
noncomputable section
set_option autoImplicit false
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoOnlineBalanced
open ConcreteModel BatchTwoMerging

abbrev BalancedPartitions (N r : ℕ) :=
  {p : LayerPartitions N r // (∀s,IsBalancedPartition (p s)) ∧
    ∀s,populationCount (p s)=populationCount (p 0)}

def balancedPartitionSupport {d N r : ℕ} (p : BalancedPartitions N r) : Set (Weights d N r) :=
  {w | (populationCount (p.val 0):ℝ)≤1+readoutEnergy w ∧
    ∀x,|clippedScore (networkOutput Real.tanh w x)-
      clippedScore (networkOutput Real.tanh (mergedWeights p.val w) x)|≤(1/16:ℝ)}

def balancedMergingSupport {d N r : ℕ} : Set (Weights d N r) :=
  ⋃p : BalancedPartitions N r,balancedPartitionSupport p

theorem isClosed_balancedPartitionSupport {d N r : ℕ} (p : BalancedPartitions N r) :
    IsClosed (balancedPartitionSupport (d:=d) p) := by
  unfold balancedPartitionSupport
  simp only [Set.setOf_and,Set.setOf_forall]
  apply IsClosed.inter
  · exact isClosed_le continuous_const (continuous_const.add continuous_readoutEnergy)
  · apply isClosed_iInter
    intro x
    apply isClosed_le _ continuous_const
    apply Continuous.abs
    exact (continuous_clippedScore.comp (continuous_networkOutput tanh_continuous x)).sub
      (continuous_clippedScore.comp
        ((continuous_networkOutput tanh_continuous x).comp (continuous_mergedWeights p.val)))

theorem isClosed_balancedMergingSupport (d N r : ℕ) :
    IsClosed (balancedMergingSupport (d:=d) (N:=N) (r:=r)) :=
  isClosed_iUnion_of_finite (fun p=>isClosed_balancedPartitionSupport p)

theorem mem_balancedMergingSupport_iff_manuscript {d N r : ℕ} (hN : 0<N) (w : Weights d N r) :
    w∈balancedMergingSupport ↔
      ∃q : ℕ,1≤q ∧ q≤N ∧ ∃p : LayerPartitions N r,
        (∀s,populationCount (p s)=q ∧ IsBalancedPartition (p s)) ∧
        (q:ℝ)≤1+readoutEnergy w ∧
        ∀x,|clippedScore (networkOutput Real.tanh w x)-
          clippedScore (networkOutput Real.tanh (mergedWeights p w) x)|≤(1/16:ℝ) := by
  constructor
  · intro hw
    obtain ⟨p,hp⟩ := Set.mem_iUnion.mp hw
    exact ⟨populationCount (p.val 0),populationCount_pos hN _,populationCount_le _,p.val,
      fun s=>⟨p.property.2 s,p.property.1 s⟩,hp⟩
  · rintro ⟨q,_,_,p,hp,hq,hclose⟩
    let pp : BalancedPartitions N r := ⟨p,fun s=>(hp s).2,fun s=>(hp s).1.trans (hp 0).1.symm⟩
    apply Set.mem_iUnion.mpr
    refine ⟨pp,?_,⟩
    change (populationCount (p 0):ℝ)≤1+readoutEnergy w ∧ _
    rw [(hp 0).1]
    exact ⟨hq,hclose⟩

def balancedTeacherPartitions {C N r : ℕ} (hC : 0<C) (hCN : C≤N) : BalancedPartitions N r :=
  ⟨fun _=>layoutPartition (balancedLayout hC) (balancedGroupSize_pos hC hCN),
    fun _=>isBalanced_layoutPartition hC hCN,fun _=>rfl⟩

theorem balanced_population_count_le {d N r : ℕ} (p : BalancedPartitions N r) (w : Weights d N r)
    (hw : w∈balancedPartitionSupport p) (s : Fin (r+1)) :
    (populationCount (p.val s):ℝ)≤1+16*readoutEnergy w := by
  rw [p.property.2 s]
  have he := readoutEnergy_nonneg w
  exact hw.1.trans (by linarith)

end NeuralGeneralization.BatchTwoOnlineBalanced
