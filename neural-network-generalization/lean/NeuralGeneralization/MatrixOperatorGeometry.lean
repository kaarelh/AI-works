import NeuralGeneralization.GaussianCovarianceFactor
import NeuralGeneralization.SquaredResponseScaling

/-! Exact Euclidean operator geometry for finite random restrictions. -/
noncomputable section
namespace NeuralGeneralization.RandomRestriction
open scoped BigOperators Matrix.Norms.L2Operator
open SquaredSampling
open Classical

variable {m D : ℕ}

def operatorNorm (A : Matrix (Fin m) (Fin D) ℝ) : ℝ := ‖A‖
def operatorSquare (A : Matrix (Fin m) (Fin D) ℝ) : ℝ := operatorNorm A ^ 2

def matrixCLM (A : Matrix (Fin m) (Fin D) ℝ) :
    EuclideanSpace ℝ (Fin D) →L[ℝ] EuclideanSpace ℝ (Fin m) :=
  (Matrix.toEuclideanLin ≪≫ₗ LinearMap.toContinuousLinearMap) A

lemma matrixCLM_norm (A : Matrix (Fin m) (Fin D) ℝ) :
    ‖matrixCLM A‖ = operatorNorm A := (Matrix.l2_opNorm_def A).symm

lemma quadratic_eq_norm (A : Matrix (Fin m) (Fin D) ℝ) (u : Fin D → ℝ) :
    (∑ i, linearEvaluation (A i) u ^ 2) = ‖matrixCLM A (WithLp.toLp 2 u)‖ ^ 2 := by
  rw [EuclideanSpace.real_norm_sq_eq]
  rfl

lemma unit_quadratic_le (A : Matrix (Fin m) (Fin D) ℝ) (u : Fin D → ℝ)
    (hu : (∑ j, u j^2) ≤ 1) :
    (∑ i, linearEvaluation (A i) u ^ 2) ≤ operatorSquare A := by
  let x : EuclideanSpace ℝ (Fin D) := WithLp.toLp 2 u
  have hx : ‖x‖ ≤ 1 := by
    have hh : ‖x‖^2 ≤ 1 := by simpa only [EuclideanSpace.real_norm_sq_eq] using hu
    nlinarith only [hh, norm_nonneg x]
  have h := (matrixCLM A).le_opNorm x
  rw [matrixCLM_norm] at h
  have hn : 0 ≤ operatorNorm A := norm_nonneg A
  have hh : ‖matrixCLM A x‖ ≤ operatorNorm A := by nlinarith only [h, mul_le_mul_of_nonneg_left hx hn]
  rw [quadratic_eq_norm]
  exact sq_le_sq₀ (norm_nonneg _) hn |>.2 hh

lemma exists_unit_maximizer (A : Matrix (Fin m) (Fin D) ℝ) :
    ∃ u : Fin D → ℝ, (∑ j, u j^2) ≤ 1 ∧
      (∑ i, linearEvaluation (A i) u ^ 2) = operatorSquare A := by
  let f := matrixCLM A
  obtain ⟨x, hx, hmax⟩ := (isCompact_closedBall (0 : EuclideanSpace ℝ (Fin D)) 1).exists_isMaxOn (by exact ⟨0, by simp⟩) (f.continuous.norm.continuousOn)
  have hx' : ‖x‖ ≤ 1 := by simpa using hx
  have hnorm : ‖f‖ = ‖f x‖ := by
    apply le_antisymm
    · apply ContinuousLinearMap.opNorm_le_of_unit_norm (norm_nonneg _)
      intro y hy
      exact hmax (by simpa using hy.le)
    · exact (f.le_opNorm x).trans (mul_le_of_le_one_right (norm_nonneg _) hx')
  refine ⟨x.ofLp, ?_, ?_⟩
  · rw [← EuclideanSpace.real_norm_sq_eq]
    nlinarith only [hx', norm_nonneg x]
  · rw [quadratic_eq_norm]
    change ‖f x‖^2 = operatorNorm A^2
    rw [← hnorm, matrixCLM_norm]

lemma operatorNorm_transpose (A : Matrix (Fin m) (Fin D) ℝ) :
    operatorNorm A.transpose = operatorNorm A := by
  have he : A.conjTranspose = A.transpose := by ext i j; simp
  exact he ▸ Matrix.l2_opNorm_conjTranspose A

lemma operatorSquare_transpose (A : Matrix (Fin m) (Fin D) ℝ) :
    operatorSquare A.transpose = operatorSquare A := by
  simp only [operatorSquare, operatorNorm_transpose]

def rowMask (b : Fin m → Bool) (A : Matrix (Fin m) (Fin D) ℝ) :
    Matrix (Fin m) (Fin D) ℝ := fun i j => if b i then A i j else 0

def colMask (b : Fin D → Bool) (A : Matrix (Fin m) (Fin D) ℝ) :
    Matrix (Fin m) (Fin D) ℝ := fun i j => if b j then A i j else 0

lemma rowMask_eq_diagonal (b : Fin m → Bool) (A : Matrix (Fin m) (Fin D) ℝ) :
    rowMask b A = Matrix.diagonal (fun i => if b i then (1:ℝ) else 0) * A := by
  ext i j
  simp only [Matrix.diagonal_mul, rowMask]
  split <;> simp_all

lemma mask_diagonal_norm_le (b : Fin m → Bool) :
    ‖Matrix.diagonal (fun i => if b i then (1:ℝ) else 0)‖ ≤ 1 := by
  rw [Matrix.l2_opNorm_diagonal]
  apply (pi_norm_le_iff_of_nonneg (by norm_num : (0:ℝ) ≤ 1)).mpr
  intro i
  split <;> norm_num

lemma operatorNorm_rowMask_le (b : Fin m → Bool) (A : Matrix (Fin m) (Fin D) ℝ) :
    operatorNorm (rowMask b A) ≤ operatorNorm A := by
  change ‖rowMask b A‖ ≤ ‖A‖
  rw [rowMask_eq_diagonal]
  exact (Matrix.l2_opNorm_mul _ _).trans (mul_le_of_le_one_left (norm_nonneg _) (mask_diagonal_norm_le b))

lemma colMask_transpose (b : Fin D → Bool) (A : Matrix (Fin m) (Fin D) ℝ) :
    (colMask b A).transpose = rowMask b A.transpose := rfl

lemma operatorNorm_colMask_le (b : Fin D → Bool) (A : Matrix (Fin m) (Fin D) ℝ) :
    operatorNorm (colMask b A) ≤ operatorNorm A := by
  rw [← operatorNorm_transpose, colMask_transpose]
  exact (operatorNorm_rowMask_le b A.transpose).trans_eq (operatorNorm_transpose A)

lemma finite_unit_witnesses {T : Type*} [Fintype T]
    (A : T → Matrix (Fin m) (Fin D) ℝ) :
    ∃ p : Option T → Fin D → ℝ, p none = 0 ∧
      (∀ u, (∑ j, p u j^2) ≤ 1) ∧
      ∀ t, empiricalSquareEnvelope (A t) p = operatorSquare (A t) := by
  choose u hu he using fun t => exists_unit_maximizer (A t)
  let p : Option T → Fin D → ℝ := fun t => t.elim 0 u
  refine ⟨p, rfl, ?_, ?_⟩
  · intro t
    cases t with
    | none => simp [p]
    | some t => exact hu t
  · intro t
    apply le_antisymm
    · apply envelope_le
      intro v
      rw [abs_of_nonneg (Finset.sum_nonneg (fun i _ => sq_nonneg _))]
      apply unit_quadratic_le
      cases v with
      | none => simp [p]
      | some v => exact hu v
    · have hh := le_envelope_finite (fun v => ∑ i, linearEvaluation (A t i) (p v)^2) (some t)
      rw [abs_of_nonneg (Finset.sum_nonneg (fun i _ => sq_nonneg _))] at hh
      simpa only [p, Option.elim_some, he, empiricalSquareEnvelope, id_eq] using hh

lemma operatorSquare_rowMask_le (b : Fin m → Bool) (A : Matrix (Fin m) (Fin D) ℝ) :
    operatorSquare (rowMask b A) ≤ operatorSquare A := by
  apply (sq_le_sq₀ (norm_nonneg _) (norm_nonneg _)).mpr
  exact operatorNorm_rowMask_le b A

lemma operatorSquare_colMask_le (b : Fin D → Bool) (A : Matrix (Fin m) (Fin D) ℝ) :
    operatorSquare (colMask b A) ≤ operatorSquare A := by
  apply (sq_le_sq₀ (norm_nonneg _) (norm_nonneg _)).mpr
  exact operatorNorm_colMask_le b A

end NeuralGeneralization.RandomRestriction
