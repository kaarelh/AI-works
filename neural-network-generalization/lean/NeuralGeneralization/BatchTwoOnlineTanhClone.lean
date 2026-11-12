import NeuralGeneralization.BatchTwoMergingCloneGeometry
import NeuralGeneralization.BatchTwoImprovedTargetGeometry
import NeuralGeneralization.BatchTwoImprovedTargetEnergy

/-! Saturated Boolean clones are fixed by genuine population averaging. -/
noncomputable section
set_option autoImplicit false
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoOnlineTanhMerging
open ConcreteModel BatchTwoMerging
variable {d C N r k p : ℕ}

theorem saturated_first_constant (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (B : LayeredBooleanCircuit d C r) (A a : ℝ) (i j : Fin N) (hij : cloneGroup e i=cloneGroup e j)
    (b : Fin (d+1)) : B.saturatedClone e A a (Sum.inl (i,b))=B.saturatedClone e A a (Sum.inl (j,b)) := by
  cases hi : e.symm i <;> cases hj : e.symm j <;>
    simp_all [cloneGroup,LayeredBooleanCircuit.saturatedClone,LayeredBooleanCircuit.cloneInputGate,LayeredBooleanCircuit.cloneInternalGate]

theorem saturated_internal_constant_left (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (B : LayeredBooleanCircuit d C r) (A a : ℝ) (s : Fin r) (i j l : Fin N) (hij : cloneGroup e i=cloneGroup e j) :
    B.saturatedClone e A a (Sum.inr (Sum.inl (s,i,l)))=B.saturatedClone e A a (Sum.inr (Sum.inl (s,j,l))) := by
  cases hi : e.symm i <;> cases hj : e.symm j <;> cases hl : e.symm l <;>
    simp_all [cloneGroup,LayeredBooleanCircuit.saturatedClone,LayeredBooleanCircuit.cloneInputGate,LayeredBooleanCircuit.cloneInternalGate]

theorem saturated_internal_constant_right (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (B : LayeredBooleanCircuit d C r) (A a : ℝ) (s : Fin r) (i j l : Fin N) (hij : cloneGroup e i=cloneGroup e j) :
    B.saturatedClone e A a (Sum.inr (Sum.inl (s,l,i)))=B.saturatedClone e A a (Sum.inr (Sum.inl (s,l,j))) := by
  cases hi : e.symm i <;> cases hj : e.symm j <;> cases hl : e.symm l <;>
    simp_all [cloneGroup,LayeredBooleanCircuit.saturatedClone,LayeredBooleanCircuit.cloneInputGate,LayeredBooleanCircuit.cloneInternalGate]

theorem saturated_readout_constant (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (B : LayeredBooleanCircuit d C r) (A a : ℝ) (i j : Fin N) (hij : cloneGroup e i=cloneGroup e j) :
    B.saturatedClone e A a (Sum.inr (Sum.inr i))=B.saturatedClone e A a (Sum.inr (Sum.inr j)) := by
  cases hi : e.symm i <;> cases hj : e.symm j <;>
    simp_all [cloneGroup,LayeredBooleanCircuit.saturatedClone,LayeredBooleanCircuit.cloneInputGate,LayeredBooleanCircuit.cloneInternalGate]

theorem projection_saturated_firstMatrix (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (B : LayeredBooleanCircuit d C r) (A a : ℝ) : Matrix.of (populationProjection (clonePartition e))*
      firstMatrix (B.saturatedClone e A a)=firstMatrix (B.saturatedClone e A a) := by
  ext i j
  exact congrFun (populationAverage_eq_of_fibre_constant (clonePartition e)
    (fun i => B.saturatedClone e A a (Sum.inl (i,j)))
    (fun ii jj hab => saturated_first_constant e B A a ii jj ((clonePartition_label_eq e ii jj).mp hab) j)) i

theorem projection_saturated_internalMatrix_left (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (B : LayeredBooleanCircuit d C r) (A a : ℝ) (s : Fin r) : Matrix.of (populationProjection (clonePartition e))*
      internalMatrix (B.saturatedClone e A a) s=internalMatrix (B.saturatedClone e A a) s := by
  ext i j
  exact congrFun (populationAverage_eq_of_fibre_constant (clonePartition e)
    (fun i => B.saturatedClone e A a (Sum.inr (Sum.inl (s,i,j))))
    (fun ii jj hab => saturated_internal_constant_left e B A a s ii jj j
      ((clonePartition_label_eq e ii jj).mp hab))) i

theorem projection_saturated_internalMatrix_right (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (B : LayeredBooleanCircuit d C r) (A a : ℝ) (s : Fin r) : internalMatrix (B.saturatedClone e A a) s*
      Matrix.of (populationProjection (clonePartition e))=internalMatrix (B.saturatedClone e A a) s := by
  ext i j
  have hh := congrFun (populationAverage_eq_of_fibre_constant (clonePartition e)
    (fun j => B.saturatedClone e A a (Sum.inr (Sum.inl (s,i,j))))
    (fun ii jj hab => saturated_internal_constant_right e B A a s ii jj i
      ((clonePartition_label_eq e ii jj).mp hab))) j
  simp only [Matrix.mul_apply,Matrix.of_apply,internalMatrix,populationAverage] at hh ⊢
  rw [← hh]
  apply Finset.sum_congr rfl
  intro l _
  rw [populationProjection_symm (clonePartition e) l j]
  ring

theorem projection_saturated_readout (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (B : LayeredBooleanCircuit d C r) (A a : ℝ) : populationAverage (clonePartition e) (readoutVector (B.saturatedClone e A a))=
      readoutVector (B.saturatedClone e A a) := by
  apply populationAverage_eq_of_fibre_constant
  intro i j hij
  exact saturated_readout_constant e B A a i j ((clonePartition_label_eq e i j).mp hij)

theorem merging_fixes_saturated (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (B : LayeredBooleanCircuit d C r) (A a : ℝ) : mergedWeights (fun _ : Fin (r+1) => clonePartition e) (B.saturatedClone e A a)=
      B.saturatedClone e A a := by
  funext i
  rcases i with ⟨i,j⟩ | ⟨s,i,j⟩ | i
  · exact congrFun (congrFun (projection_saturated_firstMatrix e B A a) i) j
  · have hm := merged_internalMatrix (fun _ : Fin (r+1) => clonePartition e) (B.saturatedClone e A a) s
    rw [projection_saturated_internalMatrix_left,projection_saturated_internalMatrix_right] at hm
    exact congrFun (congrFun hm i) j
  · exact congrFun (projection_saturated_readout e B A a) i


theorem saturated_hidden_fixed (φ : ℝ→ℝ)
    (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) (B : LayeredBooleanCircuit d C r) (A a : ℝ)
    (x : Cube d) (ss : List (Fin r)) :
    populationAverage (clonePartition e)
      (ss.foldl (hiddenStep φ (B.saturatedClone e A a)) (firstHidden φ (B.saturatedClone e A a) x))=
      ss.foldl (hiddenStep φ (B.saturatedClone e A a)) (firstHidden φ (B.saturatedClone e A a) x) := by
  apply populationAverage_eq_of_fibre_constant
  intro i j hij
  have hg := (clonePartition_label_eq e i j).mp hij
  cases ss using List.reverseRecOn with
  | nil =>
    simp only [List.foldl_nil,firstHidden]
    congr 1
    apply Finset.sum_congr rfl
    intro b _
    rw [saturated_first_constant e B A a i j hg b]
  | append_singleton ss t _ =>
    simp only [List.foldl_append,List.foldl_cons,List.foldl_nil,hiddenStep]
    congr 1
    apply Finset.sum_congr rfl
    intro l _
    rw [saturated_internal_constant_left e B A a t i j l hg]

theorem saturated_hidden_mem (φ : ℝ→ℝ)
    (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) (B : LayeredBooleanCircuit d C r) (A a : ℝ)
    (x : Cube d) (ss : List (Fin r)) :
    ss.foldl (hiddenStep φ (B.saturatedClone e A a)) (firstHidden φ (B.saturatedClone e A a) x)
      ∈cloneSubspace e := by
  let h := ss.foldl (hiddenStep φ (B.saturatedClone e A a)) (firstHidden φ (B.saturatedClone e A a) x)
  have he : h=∑j,h j • (fun i=>populationProjection (clonePartition e) i j) := by
    funext i
    have hf : populationAverage (clonePartition e) h=h := saturated_hidden_fixed φ e B A a x ss
    calc
      h i=populationAverage (clonePartition e) h i := congrFun hf.symm i
      _ = _ := by
        simp only [populationAverage,Finset.sum_apply,Pi.smul_apply,smul_eq_mul]
        apply Finset.sum_congr rfl
        intro j _
        ring
  change h∈cloneSubspace e
  rw [he]
  apply Submodule.sum_mem
  intro j _
  exact Submodule.smul_mem _ _ (clone_projection_column_mem e j)

theorem exists_adapted_saturated_merging (φ : ℝ→ℝ)
    (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) (B : LayeredBooleanCircuit d C r) (A a : ℝ) :
    ∃(b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N))) (J : Finset (Fin N)),
      J.card≤C+1 ∧
      (∀s i j,j∉J→basisCoordinates b (fun u=>B.saturatedClone e A a (.inr (.inl (s,i,u)))) j=0) ∧
      (∀(x:Cube d) (ss:List (Fin r)) j,j∉J→basisCoordinates b
        (ss.foldl (hiddenStep φ (B.saturatedClone e A a)) (firstHidden φ (B.saturatedClone e A a) x)) j=0) ∧
      (∀(bits:Fin C→Bool) j,j∉J→basisCoordinates b (saturatedCloneBits e B.constant bits) j=0) := by
  let S := cloneSubspace e
  let u : (Fin N→ℝ)≃ₗ[ℝ] EuclideanSpace ℝ (Fin N) := (WithLp.linearEquiv 2 ℝ (Fin N→ℝ)).symm
  let T : Submodule ℝ (EuclideanSpace ℝ (Fin N)) := S.map u.toLinearMap
  obtain ⟨b,J,hJ,hspan⟩ := AdaptedBasis.exists_adapted_orthonormalBasis N T
  have hcard : J.card≤C+1 := by
    rw [hJ]
    change Module.finrank ℝ (S.map u.toLinearMap)≤C+1
    rw [LinearEquiv.finrank_map_eq]
    exact cloneSubspace_finrank_le e
  have hsupport (z : Fin N→ℝ) (hz : z∈S) : ∀j,j∉J→basisCoordinates b z j=0 := by
    apply basisCoordinates_zero_of_mem_span b J z
    rw [←hspan]
    exact Submodule.mem_map.mpr ⟨z,hz,rfl⟩
  exact ⟨b,J,hcard,
    fun s i=>hsupport _ (B.saturatedClone_internalRow_mem e A a s i),
    fun x ss=>hsupport _ (saturated_hidden_mem φ e B A a x ss),
    fun bits=>hsupport _ (saturatedCloneBits_mem_subspace e B.constant bits)⟩

end NeuralGeneralization.BatchTwoOnlineTanhMerging
