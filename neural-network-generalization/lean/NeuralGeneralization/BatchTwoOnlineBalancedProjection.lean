import NeuralGeneralization.BatchTwoOnlineBalancedCompiler

/-! Saturated Boolean clones are fixed by genuine population averaging. -/
noncomputable section
set_option autoImplicit false
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoOnlineBalanced
open ConcreteModel BatchTwoMerging
variable {d C N r : ℕ} {k : Fin C→ℕ}

theorem grouped_first_constant (e : (Σb : Fin C,Fin (k b)) ≃ Fin N)
    (B : LayeredBooleanCircuit d C r) (A a : ℝ) (i j : Fin N) (hij : layoutGroup e i=layoutGroup e j)
    (b : Fin (d+1)) : groupedWeights B e A a (Sum.inl (i,b))=groupedWeights B e A a (Sum.inl (j,b)) := by
  simp only [groupedWeights,hij]

theorem grouped_internal_constant_left (e : (Σb : Fin C,Fin (k b)) ≃ Fin N)
    (B : LayeredBooleanCircuit d C r) (A a : ℝ) (s : Fin r) (i j l : Fin N) (hij : layoutGroup e i=layoutGroup e j) :
    groupedWeights B e A a (Sum.inr (Sum.inl (s,i,l)))=groupedWeights B e A a (Sum.inr (Sum.inl (s,j,l))) := by
  simp only [groupedWeights,hij]

theorem grouped_internal_constant_right (e : (Σb : Fin C,Fin (k b)) ≃ Fin N)
    (B : LayeredBooleanCircuit d C r) (A a : ℝ) (s : Fin r) (i j l : Fin N) (hij : layoutGroup e i=layoutGroup e j) :
    groupedWeights B e A a (Sum.inr (Sum.inl (s,l,i)))=groupedWeights B e A a (Sum.inr (Sum.inl (s,l,j))) := by
  simp only [groupedWeights,hij]

theorem grouped_readout_constant (e : (Σb : Fin C,Fin (k b)) ≃ Fin N)
    (B : LayeredBooleanCircuit d C r) (A a : ℝ) (i j : Fin N) (hij : layoutGroup e i=layoutGroup e j) :
    groupedWeights B e A a (Sum.inr (Sum.inr i))=groupedWeights B e A a (Sum.inr (Sum.inr j)) := by
  simp only [groupedWeights,hij]

theorem projection_grouped_firstMatrix (e : (Σb : Fin C,Fin (k b)) ≃ Fin N)
    (hk : ∀b,0<k b) (B : LayeredBooleanCircuit d C r) (A a : ℝ) : Matrix.of (populationProjection (layoutPartition e hk))*
      firstMatrix (groupedWeights B e A a)=firstMatrix (groupedWeights B e A a) := by
  ext i j
  exact congrFun (populationAverage_eq_of_fibre_constant (layoutPartition e hk)
    (fun i => groupedWeights B e A a (Sum.inl (i,j)))
    (fun ii jj hab => grouped_first_constant e B A a ii jj hab j)) i

theorem projection_grouped_internalMatrix_left (e : (Σb : Fin C,Fin (k b)) ≃ Fin N)
    (hk : ∀b,0<k b) (B : LayeredBooleanCircuit d C r) (A a : ℝ) (s : Fin r) : Matrix.of (populationProjection (layoutPartition e hk))*
      internalMatrix (groupedWeights B e A a) s=internalMatrix (groupedWeights B e A a) s := by
  ext i j
  exact congrFun (populationAverage_eq_of_fibre_constant (layoutPartition e hk)
    (fun i => groupedWeights B e A a (Sum.inr (Sum.inl (s,i,j))))
    (fun ii jj hab => grouped_internal_constant_left e B A a s ii jj j
      hab)) i

theorem projection_grouped_internalMatrix_right (e : (Σb : Fin C,Fin (k b)) ≃ Fin N)
    (hk : ∀b,0<k b) (B : LayeredBooleanCircuit d C r) (A a : ℝ) (s : Fin r) : internalMatrix (groupedWeights B e A a) s*
      Matrix.of (populationProjection (layoutPartition e hk))=internalMatrix (groupedWeights B e A a) s := by
  ext i j
  have hh := congrFun (populationAverage_eq_of_fibre_constant (layoutPartition e hk)
    (fun j => groupedWeights B e A a (Sum.inr (Sum.inl (s,i,j))))
    (fun ii jj hab => grouped_internal_constant_right e B A a s ii jj i
      hab)) j
  simp only [Matrix.mul_apply,Matrix.of_apply,internalMatrix,populationAverage] at hh ⊢
  rw [← hh]
  apply Finset.sum_congr rfl
  intro l _
  rw [populationProjection_symm (layoutPartition e hk) l j]
  ring

theorem projection_grouped_readout (e : (Σb : Fin C,Fin (k b)) ≃ Fin N)
    (hk : ∀b,0<k b) (B : LayeredBooleanCircuit d C r) (A a : ℝ) : populationAverage (layoutPartition e hk) (readoutVector (groupedWeights B e A a))=
      readoutVector (groupedWeights B e A a) := by
  apply populationAverage_eq_of_fibre_constant
  intro i j hij
  exact grouped_readout_constant e B A a i j hij

theorem merging_fixes_grouped (e : (Σb : Fin C,Fin (k b)) ≃ Fin N)
    (hk : ∀b,0<k b) (B : LayeredBooleanCircuit d C r) (A a : ℝ) : mergedWeights (fun _ : Fin (r+1) => layoutPartition e hk) (groupedWeights B e A a)=
      groupedWeights B e A a := by
  funext i
  rcases i with ⟨i,j⟩ | ⟨s,i,j⟩ | i
  · exact congrFun (congrFun (projection_grouped_firstMatrix e hk B A a) i) j
  · have hm := merged_internalMatrix (fun _ : Fin (r+1) => layoutPartition e hk) (groupedWeights B e A a) s
    rw [projection_grouped_internalMatrix_left,projection_grouped_internalMatrix_right] at hm
    exact congrFun (congrFun hm i) j
  · exact congrFun (projection_grouped_readout e hk B A a) i


theorem grouped_hidden_fixed (φ : ℝ→ℝ)
    (e : (Σb : Fin C,Fin (k b))≃Fin N) (hk : ∀b,0<k b) (B : LayeredBooleanCircuit d C r) (A a : ℝ)
    (x : Cube d) (ss : List (Fin r)) :
    populationAverage (layoutPartition e hk)
      (ss.foldl (hiddenStep φ (groupedWeights B e A a)) (firstHidden φ (groupedWeights B e A a) x))=
      ss.foldl (hiddenStep φ (groupedWeights B e A a)) (firstHidden φ (groupedWeights B e A a) x) := by
  apply populationAverage_eq_of_fibre_constant
  intro i j hij
  have hg : layoutGroup e i=layoutGroup e j := hij
  cases ss using List.reverseRecOn with
  | nil =>
    simp only [List.foldl_nil,firstHidden]
    congr 1
    apply Finset.sum_congr rfl
    intro b _
    rw [grouped_first_constant e B A a i j hg b]
  | append_singleton ss t _ =>
    simp only [List.foldl_append,List.foldl_cons,List.foldl_nil,hiddenStep]
    congr 1
    apply Finset.sum_congr rfl
    intro l _
    rw [grouped_internal_constant_left e B A a t i j l hg]

end NeuralGeneralization.BatchTwoOnlineBalanced
