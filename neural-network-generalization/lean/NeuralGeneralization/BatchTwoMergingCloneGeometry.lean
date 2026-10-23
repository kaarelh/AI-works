import NeuralGeneralization.BatchTwoMergingAveraging
import NeuralGeneralization.BatchTwoMergingEvaluation
import NeuralGeneralization.BatchTwoMergingCircuitNorm
import NeuralGeneralization.CloneSubspace

/-! # The exact cloning partition used by the target cylinder -/
noncomputable section
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel

variable {d C N r k p : ℕ}

def clonePartition (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) : PopulationPartition N :=
  partitionOfMap (cloneGroup e)

theorem clonePartition_count_le (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) :
    populationCount (clonePartition e) ≤ C+1 := by
  simpa [clonePartition] using populationCount_partitionOfMap_le (cloneGroup e)

theorem clonePartition_label_eq (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (i j : Fin N) :
    populationLabel (clonePartition e) i=populationLabel (clonePartition e) j ↔
      cloneGroup e i=cloneGroup e j := populationLabel_partitionOfMap_eq_iff _ _ _

theorem clone_first_constant (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (w : Weights d C r) (i j : Fin N) (hij : cloneGroup e i=cloneGroup e j)
    (b : Fin (d+1)) : clonedWeights e w (Sum.inl (i,b))=clonedWeights e w (Sum.inl (j,b)) := by
  cases hi : e.symm i <;> cases hj : e.symm j <;>
    simp_all [cloneGroup,clonedWeights]

theorem clone_internal_constant_left (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (w : Weights d C r) (s : Fin r) (i j l : Fin N) (hij : cloneGroup e i=cloneGroup e j) :
    clonedWeights e w (Sum.inr (Sum.inl (s,i,l)))=clonedWeights e w (Sum.inr (Sum.inl (s,j,l))) := by
  cases hi : e.symm i <;> cases hj : e.symm j <;> cases hl : e.symm l <;>
    simp_all [cloneGroup,clonedWeights]

theorem clone_internal_constant_right (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (w : Weights d C r) (s : Fin r) (i j l : Fin N) (hij : cloneGroup e i=cloneGroup e j) :
    clonedWeights e w (Sum.inr (Sum.inl (s,l,i)))=clonedWeights e w (Sum.inr (Sum.inl (s,l,j))) := by
  cases hi : e.symm i <;> cases hj : e.symm j <;> cases hl : e.symm l <;>
    simp_all [cloneGroup,clonedWeights]

theorem clone_readout_constant (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (w : Weights d C r) (i j : Fin N) (hij : cloneGroup e i=cloneGroup e j) :
    clonedWeights e w (Sum.inr (Sum.inr i))=clonedWeights e w (Sum.inr (Sum.inr j)) := by
  cases hi : e.symm i <;> cases hj : e.symm j <;>
    simp_all [cloneGroup,clonedWeights]

theorem projection_cloned_firstMatrix (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (w : Weights d C r) : Matrix.of (populationProjection (clonePartition e))*
      firstMatrix (clonedWeights e w)=firstMatrix (clonedWeights e w) := by
  ext i j
  exact congrFun (populationAverage_eq_of_fibre_constant (clonePartition e)
    (fun i => clonedWeights e w (Sum.inl (i,j)))
    (fun a b hab => clone_first_constant e w a b ((clonePartition_label_eq e a b).mp hab) j)) i

theorem projection_cloned_internalMatrix_left (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (w : Weights d C r) (s : Fin r) : Matrix.of (populationProjection (clonePartition e))*
      internalMatrix (clonedWeights e w) s=internalMatrix (clonedWeights e w) s := by
  ext i j
  exact congrFun (populationAverage_eq_of_fibre_constant (clonePartition e)
    (fun i => clonedWeights e w (Sum.inr (Sum.inl (s,i,j))))
    (fun a b hab => clone_internal_constant_left e w s a b j
      ((clonePartition_label_eq e a b).mp hab))) i

theorem projection_cloned_internalMatrix_right (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (w : Weights d C r) (s : Fin r) : internalMatrix (clonedWeights e w) s*
      Matrix.of (populationProjection (clonePartition e))=internalMatrix (clonedWeights e w) s := by
  ext i j
  have hh := congrFun (populationAverage_eq_of_fibre_constant (clonePartition e)
    (fun j => clonedWeights e w (Sum.inr (Sum.inl (s,i,j))))
    (fun a b hab => clone_internal_constant_right e w s a b i
      ((clonePartition_label_eq e a b).mp hab))) j
  simp only [Matrix.mul_apply,Matrix.of_apply,internalMatrix,populationAverage] at hh ⊢
  rw [← hh]
  apply Finset.sum_congr rfl
  intro l _
  rw [populationProjection_symm (clonePartition e) l j]
  ring

theorem projection_cloned_readout (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (w : Weights d C r) : populationAverage (clonePartition e) (readoutVector (clonedWeights e w))=
      readoutVector (clonedWeights e w) := by
  apply populationAverage_eq_of_fibre_constant
  intro i j hij
  exact clone_readout_constant e w i j ((clonePartition_label_eq e i j).mp hij)

theorem merging_fixes_clone (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (w : Weights d C r) : mergedWeights (fun _ : Fin (r+1) => clonePartition e) (clonedWeights e w)=
      clonedWeights e w := by
  funext i
  rcases i with ⟨i,j⟩ | ⟨s,i,j⟩ | i
  · exact congrFun (congrFun (projection_cloned_firstMatrix e w) i) j
  · have hm := merged_internalMatrix (fun _ : Fin (r+1) => clonePartition e) (clonedWeights e w) s
    rw [projection_cloned_internalMatrix_left,projection_cloned_internalMatrix_right] at hm
    exact congrFun (congrFun hm i) j
  · exact congrFun (projection_cloned_readout e w) i

theorem clone_projection_column_mem (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (j : Fin N) :
    (fun i => populationProjection (clonePartition e) i j) ∈ cloneSubspace e := by
  let a : Option (Fin C) → ℝ := fun g =>
    if g=cloneGroup e j then
      ((populationMembers (clonePartition e) (populationLabel (clonePartition e) j)).card : ℝ)⁻¹ else 0
  have he : (fun i => populationProjection (clonePartition e) i j)=fun i => a (cloneGroup e i) := by
    funext i
    rw [populationProjection_symm]
    simp only [populationProjection,clonePartition_label_eq,a]
    by_cases h : cloneGroup e i=cloneGroup e j
    · simp [h]
    · simp [h,Ne.symm h]
  rw [he]
  exact cloneGroup_function_mem e a

theorem cloned_compiler_hidden_bound (hk : 0 < k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (B : LayeredNorCircuit d C r) (a : ℝ)
    (x : Cube d) (ss : List (Fin r)) (i : Fin N) :
    |ss.foldl (hiddenStep relu (clonedWeights e (B.weights a)))
      (firstHidden relu (clonedWeights e (B.weights a)) x) i| ≤ 1 := by
  rw [firstHidden_cloned,hiddenFold_cloned hk]
  cases hi : e.symm i with
  | inl ai => simpa only [clonedHidden,hi] using B.hiddenFold_weights_abs_le_one a ss x ai.1
  | inr j => simp [clonedHidden,hi]

end NeuralGeneralization.BatchTwoMerging
