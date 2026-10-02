import Paulsen.DenseCore
import Mathlib.Data.Matrix.Block

/-!
# Explicit Schur-complement lifting of bounded Poisson solutions

This file separates the finite algebraic lifting from the spectral or
diagonal-dominance estimates used to control the eliminated block.
-/

namespace Paulsen

open Matrix
open scoped BigOperators

variable {ι κ : Type*} [Fintype ι] [Fintype κ]

theorem BoundedPoissonSolvability.mono
    {w : ι → ι → ℝ} {K K' : ℝ}
    (hsolve : BoundedPoissonSolvability w K) (hK : K ≤ K') :
    BoundedPoissonSolvability w K' := by
  intro f hfmean hfbound
  obtain ⟨g, hg, hgbound⟩ := hsolve f hfmean hfbound
  exact ⟨g, hg, fun i => (hgbound i).trans hK⟩

theorem weightedLaplacian_const_mul (w : ι → ι → ℝ) (g : ι → ℝ) (c : ℝ) (i : ι) :
    weightedLaplacian w (fun j => c * g j) i = c * weightedLaplacian w g i := by
  unfold weightedLaplacian
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  ring

/-- Homogeneous form of bounded Poisson solvability. -/
theorem BoundedPoissonSolvability.solve_scaled
    {w : ι → ι → ℝ} {K c : ℝ} (hsolve : BoundedPoissonSolvability w K)
    (hc : 0 < c) (f : ι → ℝ) (hfmean : (∑ i, f i) = 0)
    (hfbound : ∀ i, |f i| ≤ c) :
    ∃ g : ι → ℝ, (∀ i, weightedLaplacian w g i = f i) ∧
      (∀ i, |g i| ≤ c * K) := by
  have hmean : (∑ i, f i / c) = 0 := by
    simp only [div_eq_mul_inv, ← Finset.sum_mul, hfmean, zero_mul]
  have hbound : ∀ i, |f i / c| ≤ 1 := by
    intro i
    rw [abs_div, abs_of_pos hc]
    exact (div_le_one hc).mpr (hfbound i)
  obtain ⟨g, hg, hgbound⟩ := hsolve (fun i => f i / c) hmean hbound
  refine ⟨fun i => c * g i, ?_, ?_⟩
  · intro i
    rw [weightedLaplacian_const_mul, hg i, mul_comm, div_mul_cancel₀ _ (ne_of_gt hc)]
  · intro i
    rw [abs_mul, abs_of_pos hc]
    exact mul_le_mul_of_nonneg_left (hgbound i) (le_of_lt hc)

omit [Fintype ι] in
/-- A finite absolute-row-sum bound controls matrix-vector multiplication. -/
theorem abs_mulVec_le_of_row_sum (M : Matrix ι κ ℝ) (x : κ → ℝ) (R B : ℝ)
    (hB : 0 ≤ B) (hrow : ∀ i, (∑ j, |M i j|) ≤ R)
    (hx : ∀ j, |x j| ≤ B) (i : ι) :
    |(M *ᵥ x) i| ≤ R * B := by
  change |∑ j, M i j * x j| ≤ R * B
  calc
    |∑ j, M i j * x j| ≤ ∑ j, |M i j * x j| := Finset.abs_sum_le_sum_abs _ _
    _ = ∑ j, |M i j| * |x j| := by simp only [abs_mul]
    _ ≤ ∑ j, |M i j| * B := by
      apply Finset.sum_le_sum
      intro j _
      exact mul_le_mul_of_nonneg_left (hx j) (abs_nonneg _)
    _ = (∑ j, |M i j|) * B := (Finset.sum_mul _ _ _).symm
    _ ≤ R * B := mul_le_mul_of_nonneg_right (hrow i) hB

theorem sum_mulVec_of_column_sum_one (M : Matrix ι κ ℝ)
    (hcols : ∀ j, (∑ i, M i j) = 1) (x : κ → ℝ) :
    (∑ i, (M *ᵥ x) i) = ∑ j, x j := by
  simp only [Matrix.mulVec, dotProduct]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro j _
  rw [← Finset.sum_mul, hcols j, one_mul]

theorem graphLaplacian_apply_eq_weighted [DecidableEq ι]
    (w : Matrix ι ι ℝ) (g : ι → ℝ) (i : ι) :
    (graphLaplacian w *ᵥ g) i = weightedLaplacian w g i := by
  simp only [graphLaplacian, Matrix.mulVec, dotProduct, Matrix.sub_apply,
    Matrix.diagonal_apply, sub_mul, Finset.sum_sub_distrib]
  simp only [ite_mul, zero_mul, Finset.sum_ite_eq, Finset.mem_univ, if_true]
  unfold weightedLaplacian
  simp_rw [mul_sub]
  rw [Finset.sum_sub_distrib, ← Finset.sum_mul]

variable [DecidableEq ι] [DecidableEq κ]

omit [DecidableEq ι] in
/-- Exact block elimination, keeping the forcing transfer explicit. -/
theorem schur_poisson_block_identity
    (A : Matrix ι ι ℝ) (B : Matrix ι κ ℝ)
    (C : Matrix κ ι ℝ) (D R : Matrix κ κ ℝ)
    (hDR : D * R = 1) (u : ι → ℝ) (f : κ → ℝ) :
    Matrix.fromBlocks A B C D *ᵥ
        Sum.elim u ((-(R * C)) *ᵥ u + R *ᵥ f) =
      Sum.elim ((A - B * R * C) *ᵥ u + (B * R) *ᵥ f) f := by
  rw [Matrix.fromBlocks_mulVec]
  simp only [Function.comp_def, Sum.elim_inl, Sum.elim_inr]
  congr 1
  · simp only [Matrix.mulVec_add, Matrix.mulVec_neg, Matrix.neg_mulVec,
      Matrix.mulVec_mulVec, Matrix.sub_mulVec, Matrix.mul_assoc]
    ext i
    simp only [Pi.add_apply, Pi.sub_apply, Pi.neg_apply]
    ring
  · simp only [Matrix.mulVec_add, Matrix.mulVec_neg, Matrix.neg_mulVec,
      Matrix.mulVec_mulVec, ← Matrix.mul_assoc, hDR, Matrix.one_mul, Matrix.one_mulVec]
    ext i
    simp

/-- A bounded Poisson solver on a Schur complement lifts to the original graph.

The assumptions keep every analytic input explicit: the forcing transfer has
column sums one and absolute row sums at most `a`; harmonic extension has
absolute row sums at most one; the killed inverse has absolute row sums at most
`b`.  No zero-mean normalization of the output solution is needed.
-/
theorem boundedPoisson_of_schur
    (w : Matrix (ι ⊕ κ) (ι ⊕ κ) ℝ) (wEff : Matrix ι ι ℝ)
    (A : Matrix ι ι ℝ) (B : Matrix ι κ ℝ)
    (C : Matrix κ ι ℝ) (D R : Matrix κ κ ℝ)
    (K a b : ℝ) (hK : 0 ≤ K) (ha : 0 ≤ a) (hb : 0 ≤ b)
    (hblocks : graphLaplacian w = Matrix.fromBlocks A B C D)
    (hDR : D * R = 1)
    (hEff : graphLaplacian wEff = A - B * R * C)
    (hsolve : BoundedPoissonSolvability wEff K)
    (htransferCols : ∀ j, (∑ i, (-(B * R)) i j) = 1)
    (htransferRows : ∀ i, (∑ j, |(-(B * R)) i j|) ≤ a)
    (hharmonicRows : ∀ i, (∑ j, |(-(R * C)) i j|) ≤ 1)
    (hinverseRows : ∀ i, (∑ j, |R i j|) ≤ b) :
    BoundedPoissonSolvability w ((1 + a) * K + b) := by
  intro f hfmean hfbound
  let fG : ι → ℝ := fun i => f (Sum.inl i)
  let fB : κ → ℝ := fun i => f (Sum.inr i)
  let fEff : ι → ℝ := fG + (-(B * R)) *ᵥ fB
  have hfEffMean : (∑ i, fEff i) = 0 := by
    dsimp only [fEff, Pi.add_apply]
    rw [Finset.sum_add_distrib,
      sum_mulVec_of_column_sum_one _ htransferCols]
    simpa only [Fintype.sum_sum_type, fG, fB] using hfmean
  have hfB : ∀ j, |fB j| ≤ 1 := fun j => hfbound (Sum.inr j)
  have hfEffBound : ∀ i, |fEff i| ≤ 1 + a := by
    intro i
    have ht := abs_mulVec_le_of_row_sum (-(B * R)) fB a 1 (by norm_num)
      htransferRows hfB i
    dsimp only [fEff, Pi.add_apply]
    calc
      |fG i + ((-(B * R)) *ᵥ fB) i| ≤ |fG i| + |((-(B * R)) *ᵥ fB) i| :=
        abs_add_le _ _
      _ ≤ 1 + a := by simpa only [mul_one] using add_le_add (hfbound (Sum.inl i)) ht
  obtain ⟨u, hu, hubound⟩ := hsolve.solve_scaled (by linarith : 0 < 1 + a)
    fEff hfEffMean hfEffBound
  have huMatrix : (A - B * R * C) *ᵥ u = fEff := by
    rw [← hEff]
    ext i
    exact (graphLaplacian_apply_eq_weighted wEff u i).trans (hu i)
  let v : κ → ℝ := (-(R * C)) *ᵥ u + R *ᵥ fB
  refine ⟨Sum.elim u v, ?_, ?_⟩
  · have heq : graphLaplacian w *ᵥ Sum.elim u v = f := by
      rw [hblocks]
      change Matrix.fromBlocks A B C D *ᵥ
          Sum.elim u ((-(R * C)) *ᵥ u + R *ᵥ fB) = f
      rw [schur_poisson_block_identity A B C D R hDR, huMatrix]
      ext i
      cases i with
      | inl i => simp [fEff, fG, Matrix.neg_mulVec]
      | inr i => rfl
    intro i
    rw [← graphLaplacian_apply_eq_weighted]
    exact congrFun heq i
  · intro i
    cases i with
    | inl i =>
        exact (hubound i).trans (le_add_of_nonneg_right hb)
    | inr i =>
        have hH := abs_mulVec_le_of_row_sum (-(R * C)) u 1 ((1 + a) * K)
          (mul_nonneg (by linarith) hK) hharmonicRows hubound i
        have hR := abs_mulVec_le_of_row_sum R fB b 1 (by norm_num) hinverseRows hfB i
        change |((-(R * C)) *ᵥ u) i + (R *ᵥ fB) i| ≤ (1 + a) * K + b
        calc
          _ ≤ |((-(R * C)) *ᵥ u) i| + |(R *ᵥ fB) i| := abs_add_le _ _
          _ ≤ (1 + a) * K + b := by simpa only [one_mul, mul_one] using add_le_add hH hR

end Paulsen
