import NeuralGeneralization.BatchTwoOnlineTanhSigns
import NeuralGeneralization.BatchTwoMergingPosterior

/-! The literal signed-population support in the online paper's naturality extension. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineTanhMerging
open ConcreteModel BatchTwoMerging

def signedPopulationProjection {N : ℕ} (p : PopulationPartition N) (s : Fin N→Bool)
    (i j : Fin N) : ℝ := labelReal (s i)*populationProjection p i j*labelReal (s j)

def signedMergedWeights {d N r : ℕ} (p : LayerPartitions N r) (s : HiddenSigns N r)
    (w : Weights d N r) : Weights d N r :=
  flipHiddenSigns s (mergedWeights p (flipHiddenSigns s w))

theorem signedMergedWeights_first {d N r : ℕ} (p : LayerPartitions N r) (s : HiddenSigns N r)
    (w : Weights d N r) (i : Fin N) (j : Fin (d+1)) :
    signedMergedWeights p s w (.inl (i,j))=
      ∑k,signedPopulationProjection (p 0) (s 0) i k*w (.inl (k,j)) := by
  simp only [signedMergedWeights,flipHiddenSigns,weightSign,mergedWeights,Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro k _
  unfold signedPopulationProjection signAt
  ring

theorem signedMergedWeights_internal {d N r : ℕ} (p : LayerPartitions N r) (s : HiddenSigns N r)
    (w : Weights d N r) (t : Fin r) (i j : Fin N) :
    signedMergedWeights p s w (.inr (.inl (t,i,j)))=
      ∑k,∑l,signedPopulationProjection (p t.succ) (s t.succ) i k*
        w (.inr (.inl (t,k,l)))*signedPopulationProjection (p t.castSucc) (s t.castSucc) l j := by
  simp only [signedMergedWeights,flipHiddenSigns,weightSign,mergedWeights,Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro k _
  apply Finset.sum_congr rfl
  intro l _
  unfold signedPopulationProjection signAt
  ring

theorem signedMergedWeights_readout {d N r : ℕ} (p : LayerPartitions N r) (s : HiddenSigns N r)
    (w : Weights d N r) (i : Fin N) :
    signedMergedWeights p s w (.inr (.inr i))=
      ∑j,signedPopulationProjection (p (Fin.last r)) (s (Fin.last r)) i j*w (.inr (.inr j)) := by
  simp only [signedMergedWeights,flipHiddenSigns,weightSign,mergedWeights,Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  unfold signedPopulationProjection signAt
  ring

def signedPartitionSupport {d N r : ℕ} (p : LayerPartitions N r) (s : HiddenSigns N r) :
    Set (Weights d N r) :=
  {w | (∀(j : Fin (r+1)) (x : Cube d),((populationCount (p j):ℝ)-1)*
      (networkOutput Real.tanh w x)^2≤4*readoutEnergy w) ∧
    ∀x,|clippedScore (networkOutput Real.tanh w x)-
      clippedScore (networkOutput Real.tanh (signedMergedWeights p s w) x)|≤(1/16:ℝ)}

theorem signedPartitionSupport_eq_preimage {d N r : ℕ} (p : LayerPartitions N r) (s : HiddenSigns N r) :
    signedPartitionSupport (d:=d) p s=flipHiddenSigns s ⁻¹' partitionSupport Real.tanh p := by
  ext w
  simp only [signedPartitionSupport,Set.mem_setOf_eq,Set.mem_preimage,partitionSupport,
    flipHiddenSigns_output,flipHiddenSigns_readoutEnergy,signedMergedWeights]

theorem isClosed_signedPartitionSupport {d N r : ℕ} (p : LayerPartitions N r) (s : HiddenSigns N r) :
    IsClosed (signedPartitionSupport (d:=d) p s) := by
  rw [signedPartitionSupport_eq_preimage]
  exact (isClosed_partitionSupport tanh_continuous p).preimage (continuous_flipHiddenSigns s)

def signedMergingSupport {d N r : ℕ} : Set (Weights d N r) :=
  ⋃s : HiddenSigns N r,⋃p : LayerPartitions N r,signedPartitionSupport p s

theorem isClosed_signedMergingSupport (d N r : ℕ) :
    IsClosed (signedMergingSupport (d:=d) (N:=N) (r:=r)) :=
  isClosed_iUnion_of_finite (fun s=>isClosed_iUnion_of_finite (fun p=>isClosed_signedPartitionSupport p s))

theorem mergingSupport_subset_signed {d N r : ℕ} :
    mergingSupport (d:=d) (N:=N) (r:=r) Real.tanh⊆signedMergingSupport := by
  intro w hw
  obtain ⟨p,hp⟩ := Set.mem_iUnion.mp hw
  apply Set.mem_iUnion.mpr
  refine ⟨fun _ _=>true,Set.mem_iUnion.mpr ⟨p,?_⟩⟩
  rw [signedPartitionSupport_eq_preimage]
  have he : flipHiddenSigns (fun (_:Fin (r+1)) (_:Fin N)=>true) w=w := by
    funext i
    rcases i with ij | (sij | j) <;> simp [flipHiddenSigns,weightSign,signAt,labelReal]
  simpa only [Set.mem_preimage,he] using hp

theorem signed_population_count_le {d N r : ℕ} (hN : 0<N)
    (p : LayerPartitions N r) (s : HiddenSigns N r) (w : Weights d N r)
    (hw : w∈signedPartitionSupport p s) (x : Cube d) (b : Bool)
    (hm : (1/2:ℝ)<labelReal b*networkOutput Real.tanh w x) (j : Fin (r+1)) :
    (populationCount (p j):ℝ)≤1+16*readoutEnergy w := by
  have hp : flipHiddenSigns s w∈partitionSupport Real.tanh p := by
    simpa only [signedPartitionSupport_eq_preimage,Set.mem_preimage] using hw
  have hh := populationCount_le_of_margin hN Real.tanh p (flipHiddenSigns s w) hp x b
    (by simpa only [flipHiddenSigns_output] using hm) j
  simpa only [flipHiddenSigns_readoutEnergy] using hh

theorem mem_signedPartitionSupport_iff_manuscript {d N r : ℕ} (hN : 0<N)
    (w : Weights d N r) (p : LayerPartitions N r) (s : HiddenSigns N r) :
    w∈signedPartitionSupport p s ↔
      (((largestPopulation p:ℝ)-1)*largestOutput Real.tanh w^2≤4*readoutEnergy w) ∧
      ∀x,|clippedScore (networkOutput Real.tanh w x)-
        clippedScore (networkOutput Real.tanh (signedMergedWeights p s w) x)|≤(1/16:ℝ) :=
  and_congr (population_budget_iff_maxima hN Real.tanh w p) Iff.rfl

end NeuralGeneralization.BatchTwoOnlineTanhMerging
