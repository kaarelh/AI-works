import NeuralGeneralization.JacobianBlockProducts
import NeuralGeneralization.JacobianFiniteRadius

/-! The product-block matrix upper bound on the signed clean transport norm. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open WithLp
namespace NeuralGeneralization.JacobianCertificate
open ConcreteModel
variable {d N r : ℕ}

def blockNorms (X : Stack N r) : EuclideanSpace ℝ (Fin (r+1)) :=
  toLp 2 (fun s => ‖block X s‖)

lemma blockNorms_norm (X : Stack N r) : ‖blockNorms X‖ = ‖X‖ := by
  have hh : ‖blockNorms X‖^2 = ‖X‖^2 := by
    rw [EuclideanSpace.real_norm_sq_eq (blockNorms X),EuclideanSpace.real_norm_sq_eq X,
      Fintype.sum_prod_type]
    apply Finset.sum_congr rfl
    intro s _
    exact EuclideanSpace.real_norm_sq_eq (block X s)
  nlinarith [norm_nonneg (blockNorms X),norm_nonneg X]

def blockNormMatrix (C : Fin r → Fin N → Fin N → ℝ) : Fin (r+1) × Fin (r+1) → ℝ :=
  fun sj => ‖blockProduct C sj.2 sj.1‖

lemma blockNormMatrix_above (C : Fin r → Fin N → Fin N → ℝ)
    (s j : Fin (r+1)) (h : s < j) : blockNormMatrix C (s,j) = 0 := by
  simp [blockNormMatrix,blockProduct_above C j s h]

lemma blockNormMatrix_diagonal (hN : 0 < N) (C : Fin r → Fin N → Fin N → ℝ)
    (s : Fin (r+1)) : blockNormMatrix C (s,s) = 1 := by
  letI : NeZero N := ⟨Nat.ne_of_gt hN⟩
  simp [blockNormMatrix,blockProduct_diagonal]

lemma blockNormMatrix_below (C : Fin r → Fin N → Fin N → ℝ)
    (s : Fin r) (j : Fin (r+1)) (h : j < s.succ) :
    blockNormMatrix C (s.succ,j) = ‖layerOperator C s * blockProduct C j s.castSucc‖ := by
  rw [blockNormMatrix,blockProduct_below C j s h]

/-- Any entrywise upper bound for the true block norms gives a Euclidean
operator-norm bound, rather than a depth-dependent Frobenius substitute. -/
theorem transport_norm_le_matrix (C : Fin r → Fin N → Fin N → ℝ)
    (M : Fin (r+1) × Fin (r+1) → ℝ)
    (hM : ∀ s j, ‖blockProduct C j s‖ ≤ M (s,j)) :
    ‖transport C‖ ≤ ‖coordinateMatrixOperator M‖ := by
  apply ContinuousLinearMap.opNorm_le_bound _ (norm_nonneg _)
  intro X
  have hs (s : Fin (r+1)) :
      ‖block (transport C X) s‖ ≤ coordinateMatrixOperator M (blockNorms X) s := by
    rw [transport_block_decomposition]
    calc
      _ ≤ ∑ j, ‖blockProduct C j s (block X j)‖ := norm_sum_le _ _
      _ ≤ ∑ j, M (s,j)*‖block X j‖ := by
        apply Finset.sum_le_sum
        intro j _
        exact ((blockProduct C j s).le_opNorm _).trans
          (mul_le_mul_of_nonneg_right (hM s j) (norm_nonneg _))
      _ = _ := rfl
  have hnorm : ‖transport C X‖ ≤ ‖coordinateMatrixOperator M (blockNorms X)‖ := by
    rw [← blockNorms_norm (transport C X)]
    apply (sq_le_sq₀ (norm_nonneg _) (norm_nonneg _)).mp
    rw [EuclideanSpace.real_norm_sq_eq,EuclideanSpace.real_norm_sq_eq]
    apply Finset.sum_le_sum
    intro s _
    exact (sq_le_sq₀ (norm_nonneg _) ((norm_nonneg _).trans (hs s))).mpr (hs s)
  exact hnorm.trans (by simpa only [blockNorms_norm] using
    (coordinateMatrixOperator M).le_opNorm (blockNorms X))

/-- The literal k <= ||T||_op auxiliary bound from the paper. -/
theorem transport_norm_le_blockNormMatrix (C : Fin r → Fin N → Fin N → ℝ) :
    ‖transport C‖ ≤ ‖coordinateMatrixOperator (blockNormMatrix C)‖ :=
  transport_norm_le_matrix C _ (fun _ _ => le_rfl)

/-- Replacing each signed product norm by the product of its factor norms. -/
def factorProduct (C : Fin r → Fin N → Fin N → ℝ) (j : Fin (r+1)) : Fin (r+1) → ℝ :=
  Fin.induction (if j=0 then 1 else 0)
    (fun s prev => ‖layerOperator C s‖ * prev + if j=s.succ then 1 else 0)

@[simp] lemma factorProduct_zero (C : Fin r → Fin N → Fin N → ℝ) (j : Fin (r+1)) :
    factorProduct C j 0 = if j=0 then 1 else 0 := rfl
@[simp] lemma factorProduct_succ (C : Fin r → Fin N → Fin N → ℝ) (j : Fin (r+1)) (s : Fin r) :
    factorProduct C j s.succ = ‖layerOperator C s‖*factorProduct C j s.castSucc+
      if j=s.succ then 1 else 0 := rfl

lemma factorProduct_nonneg (C : Fin r → Fin N → Fin N → ℝ) (j s : Fin (r+1)) :
    0 ≤ factorProduct C j s := by
  induction s using Fin.induction with
  | zero => simp only [factorProduct_zero]; split <;> norm_num
  | succ s ih => rw [factorProduct_succ]; positivity

lemma factorProduct_above (C : Fin r → Fin N → Fin N → ℝ)
    (j s : Fin (r+1)) (hs : s < j) : factorProduct C j s = 0 := by
  induction s using Fin.induction with
  | zero => simp [show j ≠ 0 by intro h; subst j; exact (lt_irrefl _ hs)]
  | succ s ih =>
    rw [factorProduct_succ,ih (Fin.castSucc_lt_succ.trans hs)]
    simp [show j ≠ s.succ by intro h; subst j; exact (lt_irrefl _ hs)]

lemma factorProduct_diagonal (C : Fin r → Fin N → Fin N → ℝ) (j : Fin (r+1)) :
    factorProduct C j j = 1 := by
  induction j using Fin.cases with
  | zero => simp
  | succ s => rw [factorProduct_succ,factorProduct_above C s.succ s.castSucc Fin.castSucc_lt_succ]; simp

lemma factorProduct_below (C : Fin r → Fin N → Fin N → ℝ)
    (j : Fin (r+1)) (s : Fin r) (hj : j < s.succ) :
    factorProduct C j s.succ = ‖layerOperator C s‖*factorProduct C j s.castSucc := by
  simp [factorProduct_succ,show j ≠ s.succ from ne_of_lt hj]

lemma blockProduct_norm_le_factorProduct (C : Fin r → Fin N → Fin N → ℝ)
    (j s : Fin (r+1)) : ‖blockProduct C j s‖ ≤ factorProduct C j s := by
  have hid : ‖(1 : Block N →L[ℝ] Block N)‖ ≤ 1 := ContinuousLinearMap.norm_id_le
  induction s using Fin.induction with
  | zero => simp only [blockProduct_zero,factorProduct_zero]; split <;> simp_all
  | succ s ih =>
    rw [blockProduct_succ,factorProduct_succ]
    apply (norm_add_le _ _).trans
    apply add_le_add
    · exact (norm_mul_le _ _).trans (mul_le_mul_of_nonneg_left ih (norm_nonneg _))
    · split <;> simp_all

/-- The more conservative factor-norm product version is also valid. -/
theorem transport_norm_le_factorMatrix (C : Fin r → Fin N → Fin N → ℝ) :
    ‖transport C‖ ≤ ‖coordinateMatrixOperator (fun sj => factorProduct C sj.2 sj.1)‖ :=
  transport_norm_le_matrix C _ (fun s j => blockProduct_norm_le_factorProduct C j s)

/-- Instantiate the exact block-product norm bound with the actual clean
activation derivatives D_s W_s. -/
theorem jacobianNorm_le_blockNormMatrix (w : Weights d N r) (x : Cube d) :
    jacobianNorm w x ≤ ‖coordinateMatrixOperator (blockNormMatrix (cleanBlocks w x))‖ :=
  transport_norm_le_blockNormMatrix _

theorem jacobianNorm_le_factorMatrix (w : Weights d N r) (x : Cube d) :
    jacobianNorm w x ≤ ‖coordinateMatrixOperator (fun sj => factorProduct (cleanBlocks w x) sj.2 sj.1)‖ :=
  transport_norm_le_factorMatrix _

end NeuralGeneralization.JacobianCertificate
