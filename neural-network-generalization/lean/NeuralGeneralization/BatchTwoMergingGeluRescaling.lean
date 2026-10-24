import NeuralGeneralization.BatchTwoMergingMergedCylinder
import NeuralGeneralization.BatchTwoMergingGeluAnalytic

/-! An exact change of units reduces GELU's Lipschitz constant two to the
already checked one-Lipschitz cylinder estimate. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel

def halfGelu (x : ℝ) : ℝ := gelu x/2

def doubledOutgoing {d N r : ℕ} (w : Weights d N r) : Weights d N r
  | Sum.inl ij=>w (Sum.inl ij)
  | Sum.inr ij=>2*w (Sum.inr ij)

theorem halfGelu_lipschitzZero : LipschitzZero halfGelu := by
  refine ⟨by simp [halfGelu],fun a b=>?_⟩
  have h := gelu_lipschitz.dist_le_mul a b
  simp only [Real.dist_eq,NNReal.coe_ofNat] at h
  unfold halfGelu
  rw [←sub_div,abs_div]
  norm_num
  linarith

theorem halfGelu_firstHidden {d N r : ℕ} (w : Weights d N r) (x : Cube d) :
    firstHidden halfGelu (doubledOutgoing w) x = fun i=>firstHidden gelu w x i/2 := by
  rfl

theorem halfGelu_hiddenStep {d N r : ℕ} (w : Weights d N r) (h : Fin N→ℝ) (s : Fin r) :
    hiddenStep halfGelu (doubledOutgoing w) (fun i=>h i/2) s =
      fun i=>hiddenStep gelu w h s i/2 := by
  funext i
  unfold hiddenStep halfGelu
  congr 2
  apply Finset.sum_congr rfl
  intro j _
  simp only [doubledOutgoing]
  ring

theorem halfGelu_hiddenFold {d N r : ℕ} (w : Weights d N r)
    (x : Cube d) (ss : List (Fin r)) :
    ss.foldl (hiddenStep halfGelu (doubledOutgoing w))
      (firstHidden halfGelu (doubledOutgoing w) x) =
      fun i=>ss.foldl (hiddenStep gelu w) (firstHidden gelu w x) i/2 := by
  induction ss using List.reverseRecOn with
  | nil => exact halfGelu_firstHidden w x
  | append_singleton ss s ih =>
    simp only [List.foldl_append,List.foldl_cons,List.foldl_nil]
    rw [ih,halfGelu_hiddenStep]

theorem halfGelu_networkOutput {d N r : ℕ} (w : Weights d N r) (x : Cube d) :
    networkOutput halfGelu (doubledOutgoing w) x = networkOutput gelu w x := by
  unfold networkOutput finalHidden
  rw [halfGelu_hiddenFold]
  apply Finset.sum_congr rfl
  intro i _
  simp only [doubledOutgoing]
  ring

theorem doubledOutgoing_energy {d N r : ℕ} (w : Weights d N r) :
    weightedSquaredNorm (doubledOutgoing w)≤4*weightedSquaredNorm w := by
  unfold weightedSquaredNorm
  have h2 (z : ℝ) : (2*z)^2=4*z^2 := by ring
  simp only [doubledOutgoing,h2,←Finset.mul_sum]
  have hfirst : 0≤(d:ℝ)/N*∑i,∑j,w (Sum.inl (i,j))^2 := by positivity
  nlinarith

theorem doubledOutgoing_merged {d N r : ℕ} (p : LayerPartitions N r) (w : Weights d N r) :
    doubledOutgoing (mergedWeights p w)=mergedWeights p (doubledOutgoing w) := by
  funext q
  rcases q with ⟨i,j⟩ | ⟨s,i,j⟩ | i
  · rfl
  · simp only [doubledOutgoing,mergedWeights]
    simp_rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro a _
    apply Finset.sum_congr rfl
    intro b _
    ring
  · simp only [doubledOutgoing,mergedWeights]
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro a _
    ring

end NeuralGeneralization.BatchTwoMerging
