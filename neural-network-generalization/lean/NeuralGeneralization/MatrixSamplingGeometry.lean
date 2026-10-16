import NeuralGeneralization.MatrixOperatorGeometry
import NeuralGeneralization.FiniteSubsetSampling

/-! Exact Euclidean compression and monotonicity for sampled matrices. -/
noncomputable section
namespace NeuralGeneralization.RandomRestriction
open scoped BigOperators Matrix.Norms.L2Operator
open SquaredSampling Classical
attribute [local instance] Classical.propDecidable

variable {m D n : ℕ}

lemma sum_injective_le (f : Fin m → ℝ) (hf : ∀ i,0 ≤ f i)
    (s : Fin n → Fin m) (hs : Function.Injective s) :
    (∑ i,f (s i)) ≤ ∑ j,f j := by
  calc
    _ = ∑ j ∈ Finset.univ.image s,f j := by
      rw [Finset.sum_image]
      exact fun _ _ _ _ h => hs h
    _ ≤ _ := Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) (fun j _ _ => hf j)

/-- Injectively selecting rows contracts the true Euclidean operator norm. -/
lemma operatorSquare_rowReindex_le (A : Matrix (Fin m) (Fin D) ℝ)
    (s : Fin n → Fin m) (hs : Function.Injective s) :
    operatorSquare (fun i j => A (s i) j) ≤ operatorSquare A := by
  obtain ⟨u,hu,he⟩ := exists_unit_maximizer (fun i j => A (s i) j)
  rw [← he]
  exact (sum_injective_le (fun i => linearEvaluation (A i) u^2)
    (fun _ => sq_nonneg _) s hs).trans (unit_quadratic_le A u hu)

lemma operatorSquare_colReindex_le (A : Matrix (Fin D) (Fin m) ℝ)
    (s : Fin n → Fin m) (hs : Function.Injective s) :
    operatorSquare (fun i j => A i (s j)) ≤ operatorSquare A := by
  rw [← operatorSquare_transpose (fun i j => A i (s j)), ← operatorSquare_transpose A]
  exact operatorSquare_rowReindex_le A.transpose s hs

def principalMask (S : Finset (Fin m)) (A : Matrix (Fin m) (Fin m) ℝ) :
    Matrix (Fin m) (Fin m) ℝ :=
  rowMask (fun i => decide (i∈S)) (colMask (fun j => decide (j∈S)) A)

lemma principalMask_nested (A : Matrix (Fin m) (Fin m) ℝ)
    {S T : Finset (Fin m)} (hST : S ⊆ T) :
    principalMask S (principalMask T A)=principalMask S A := by
  ext i j
  unfold principalMask rowMask colMask
  by_cases hi : i∈S
  · by_cases hj : j∈S
    · simp [hi,hj,hST hi,hST hj]
    · simp [hi,hj]
  · simp [hi]

lemma operatorSquare_principalMask_mono (A : Matrix (Fin m) (Fin m) ℝ)
    {S T : Finset (Fin m)} (hST : S ⊆ T) :
    operatorSquare (principalMask S A) ≤ operatorSquare (principalMask T A) := by
  rw [← principalMask_nested A hST]
  exact (operatorSquare_rowMask_le _ _).trans (operatorSquare_colMask_le _ _)

def sampledMatrix (A : Matrix (Fin m) (Fin m) ℝ) (s : Fin n → Fin m) :
    Matrix (Fin n) (Fin n) ℝ := fun i j => A (s i) (s j)

lemma sampledMatrix_principalMask (A : Matrix (Fin m) (Fin m) ℝ) (s : Fin n → Fin m) :
    sampledMatrix (principalMask (sampleRange s) A) s=sampledMatrix A s := by
  ext i j
  have hi : s i∈sampleRange s := by simp [sampleRange]
  have hj : s j∈sampleRange s := by simp [sampleRange]
  simp [sampledMatrix,principalMask,rowMask,colMask,hi,hj]

/-- An injective sample matrix is an actual compression of the ambient
principal matrix on its range; no spectral identity is assumed. -/
lemma operatorSquare_sampledMatrix_le (A : Matrix (Fin m) (Fin m) ℝ)
    (s : Fin n → Fin m) (hs : Function.Injective s) :
    operatorSquare (sampledMatrix A s) ≤ operatorSquare (principalMask (sampleRange s) A) := by
  rw [← sampledMatrix_principalMask A s]
  exact (operatorSquare_rowReindex_le
    (fun i j => principalMask (sampleRange s) A i (s j)) s hs).trans
    (operatorSquare_colReindex_le (principalMask (sampleRange s) A) s hs)

lemma principalMask_selectedSet {α : Type*} (choose : α → Bool) (ω : Fin m → α)
    (A : Matrix (Fin m) (Fin m) ℝ) :
    principalMask (selectedSet choose ω) A=
      rowMask (fun i => choose (ω i)) (colMask (fun j => choose (ω j)) A) := by
  ext i j
  simp [principalMask,selectedSet,rowMask,colMask]

end NeuralGeneralization.RandomRestriction
