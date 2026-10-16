import NeuralGeneralization.MatrixSamplingGeometry
import NeuralGeneralization.ElementaryTailGram

/-! Exact quadratic-form consequences of the sampled Euclidean norm. -/
noncomputable section
namespace NeuralGeneralization.RandomRestriction
open scoped BigOperators Matrix.Norms.L2Operator
open SquaredSampling Classical

variable {m n : ℕ}

lemma action_square_le_operatorSquare (A : Matrix (Fin m) (Fin n) ℝ) (u : Fin n → ℝ) :
    (∑ i,linearEvaluation (A i) u^2) ≤ operatorSquare A*(∑ j,u j^2) := by
  let x : EuclideanSpace ℝ (Fin n) := WithLp.toLp 2 u
  have h := (matrixCLM A).le_opNorm x
  rw [matrixCLM_norm] at h
  have hs := (sq_le_sq₀ (norm_nonneg _) (mul_nonneg (norm_nonneg A) (norm_nonneg x))).mpr h
  rw [quadratic_eq_norm]
  simpa only [operatorSquare,operatorNorm,mul_pow,EuclideanSpace.real_norm_sq_eq] using hs

lemma finiteQuadratic_sq_le_operatorSquare (A : Matrix (Fin n) (Fin n) ℝ) (u : Fin n → ℝ) :
    finiteQuadratic A u^2 ≤ operatorSquare A*(∑ i,u i^2)^2 := by
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ u (fun i => linearEvaluation (A i) u)
  have he : (∑ i,u i*linearEvaluation (A i) u)=finiteQuadratic A u := by
    unfold linearEvaluation finiteQuadratic
    simp_rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro j _
    ring
  rw [he] at hcs
  have hb := mul_le_mul_of_nonneg_left (action_square_le_operatorSquare A u)
    (show (0:ℝ) ≤ ∑ i,u i^2 from Finset.sum_nonneg (fun _ _ => sq_nonneg _))
  exact hcs.trans (by convert hb using 1; ring)

/-- Small actual Euclidean operator norm controls every quadratic form. -/
lemma finiteQuadratic_abs_le_of_operatorSquare (A : Matrix (Fin n) (Fin n) ℝ)
    (t : ℝ) (ht : 0 ≤ t) (hA : operatorSquare A ≤ t^2) (u : Fin n → ℝ) :
    |finiteQuadratic A u| ≤ t*(∑ i,u i^2) := by
  have h := (finiteQuadratic_sq_le_operatorSquare A u).trans
    (mul_le_mul_of_nonneg_right hA (sq_nonneg _))
  apply (sq_le_sq₀ (abs_nonneg _) (mul_nonneg ht (Finset.sum_nonneg (fun _ _ => sq_nonneg _)))).mp
  simpa only [sq_abs,mul_pow] using h

/-- A near/far masked sample agrees exactly with the off-diagonal full
sample whenever every distinct sampled pair is retained. -/
lemma sampled_mask_eq_offDiagonal (A : Matrix (Fin m) (Fin m) ℝ)
    (keep : Fin m → Fin m → Prop) [DecidableRel keep] (s : Fin n → Fin m)
    (hdiag : ∀ x,¬keep x x) (hfar : ∀ i j,i≠j → keep (s i) (s j)) :
    sampledMatrix (fun x y => if keep x y then A x y else 0) s=
      offDiagonal (sampledMatrix A s) := by
  ext i j
  by_cases hij : i=j
  · subst j
    simp [sampledMatrix,offDiagonal,hdiag]
  · simp [sampledMatrix,offDiagonal,hij,hfar i j hij]

/-- The paper's all-vector Gram perturbation bound follows from the actual
sampled far-matrix norm, with all input collisions treated by `hfar`. -/
theorem sampled_quadratic_close_of_far_norm (A : Matrix (Fin m) (Fin m) ℝ)
    (keep : Fin m → Fin m → Prop) [DecidableRel keep] (s : Fin n → Fin m)
    (tau t : ℝ) (ht : 0 ≤ t) (hA : ∀ x,A x x=tau)
    (hdiag : ∀ x,¬keep x x) (hfar : ∀ i j,i≠j → keep (s i) (s j))
    (hop : operatorSquare (sampledMatrix (fun x y => if keep x y then A x y else 0) s) ≤ t^2)
    (u : Fin n → ℝ) :
    |finiteQuadratic (sampledMatrix A s) u-tau*(∑ i,u i^2)| ≤ t*(∑ i,u i^2) := by
  rw [sampled_mask_eq_offDiagonal A keep s hdiag hfar] at hop
  rw [finiteQuadratic_offDiagonal_decomposition (sampledMatrix A s) tau
    (fun i => hA (s i)) u,add_sub_cancel_left]
  exact finiteQuadratic_abs_le_of_operatorSquare _ t ht hop u

end NeuralGeneralization.RandomRestriction
