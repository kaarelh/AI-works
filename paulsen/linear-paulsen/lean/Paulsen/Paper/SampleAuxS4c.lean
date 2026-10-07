import Paulsen.Paper.SampleAuxS4b

/-!
# Helpers for `ModerateSample`: the principal block of `𝓛(Y) - E𝓛(Y)` (S4, second half)

* entries of `𝓛(M)` for symmetric `M`: `𝓛(M)_bb = ∑_{j≠b} M_bj²`, `𝓛(M)_bc = -M_bc²`;
* the variance of a Gaussian norm square `‖Dg‖²` is at most `2‖D‖²E‖Dg‖²`
  (`lem:gauss`(a) variance identity with `tr(A²) ≤ ‖A‖ tr A`).
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

theorem edgeVec_apply {n : ℕ} (i j b : Fin n) :
    edgeVec i j b = (if b = i then 1 else 0) - (if b = j then 1 else 0) := by
  simp [edgeVec, Pi.single_apply]

/-- Diagonal entries of `𝓛(M)` for symmetric `M`. -/
theorem sqLaplacian_diag {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ) (hM : M.transpose = M)
    (b : Fin n) : sqLaplacian M b b = ∑ j, if j = b then 0 else M b j ^ 2 := by
  have hsym : ∀ i j, M i j = M j i := fun i j => by
    have := congrFun (congrFun hM j) i; simpa using this
  have hpt : ∀ i j, (if i < j then M i j ^ 2 * (edgeVec i j b * edgeVec i j b) else 0) =
      (if i = b ∧ b < j then M b j ^ 2 else 0) + (if j = b ∧ i < b then M i b ^ 2 else 0) := by
    intro i j
    rw [edgeVec_apply]
    by_cases hij : i < j
    · by_cases hib : b = i
      · subst hib
        have hjb : ¬ j = b := fun h => by subst h; exact lt_irrefl _ hij
        simp [hij, hjb, Ne.symm hjb]
      · by_cases hjb : b = j
        · subst hjb
          simp [hij, hib, Ne.symm hib]
        · simp [hij, hib, hjb, Ne.symm hib, Ne.symm hjb]
    · have h1 : ¬ (i = b ∧ b < j) := fun h => hij (h.1 ▸ h.2)
      have h2 : ¬ (j = b ∧ i < b) := fun h => hij (h.1 ▸ h.2)
      simp [hij, h1, h2]
  have hL : sqLaplacian M b b = ∑ i, ∑ j,
      if i < j then M i j ^ 2 * (edgeVec i j b * edgeVec i j b) else 0 := by
    simp only [sqLaplacian, Matrix.sum_apply]
    apply Finset.sum_congr rfl; intro i _
    apply Finset.sum_congr rfl; intro j _
    split_ifs <;> simp [Matrix.vecMulVec_apply]
  rw [hL]
  simp_rw [hpt, Finset.sum_add_distrib]
  have e1 : ∑ i, ∑ j, (if i = b ∧ b < j then M b j ^ 2 else 0) =
      ∑ j, if b < j then M b j ^ 2 else 0 := by
    rw [Finset.sum_eq_single b]
    · apply Finset.sum_congr rfl; intro j _; simp
    · intro i _ hi; apply Finset.sum_eq_zero; intro j _; simp [hi]
    · simp
  have e2 : ∑ i, ∑ j, (if j = b ∧ i < b then M i b ^ 2 else 0) =
      ∑ j, if j < b then M b j ^ 2 else 0 := by
    apply Finset.sum_congr rfl; intro i _
    rw [Finset.sum_eq_single b]
    · simp [hsym i b]
    · intro j _ hj; simp [hj]
    · simp
  rw [e1, e2, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl; intro j _
  rcases lt_trichotomy j b with h | h | h
  · simp [h, not_lt.mpr h.le, h.ne]
  · subst h; simp
  · simp [h, not_lt.mpr h.le, h.ne']

/-- Off-diagonal entries of `𝓛(M)` for symmetric `M`. -/
theorem sqLaplacian_offdiag {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ) (hM : M.transpose = M)
    {b c : Fin n} (hbc : b ≠ c) : sqLaplacian M b c = -(M b c ^ 2) := by
  have hsym : ∀ i j, M i j = M j i := fun i j => by
    have := congrFun (congrFun hM j) i; simpa using this
  have hL : sqLaplacian M b c = ∑ i, ∑ j,
      if i < j then M i j ^ 2 * (edgeVec i j b * edgeVec i j c) else 0 := by
    simp only [sqLaplacian, Matrix.sum_apply]
    apply Finset.sum_congr rfl; intro i _
    apply Finset.sum_congr rfl; intro j _
    split_ifs <;> simp [Matrix.vecMulVec_apply]
  have hpt : ∀ i j, (if i < j then M i j ^ 2 * (edgeVec i j b * edgeVec i j c) else 0) =
      -((if i = b ∧ j = c ∧ b < c then M b c ^ 2 else 0) +
        (if i = c ∧ j = b ∧ c < b then M b c ^ 2 else 0)) := by
    intro i j
    rw [edgeVec_apply, edgeVec_apply]
    by_cases hij : i < j
    · have hne : i ≠ j := ne_of_lt hij
      by_cases hib : i = b
      · subst hib
        by_cases hjc : j = c
        · subst hjc; simp [hij, hne, Ne.symm hne]
        · simp [hij, hjc, hbc, Ne.symm hbc, Ne.symm hjc, hne, Ne.symm hne]
      · by_cases hic : i = c
        · subst hic
          by_cases hjb : j = b
          · subst hjb; simp [hij, hne, Ne.symm hne, hsym i j]
          · simp [hij, hjb, hib, Ne.symm hib, Ne.symm hjb, hne, Ne.symm hne]
        · by_cases hjb : j = b
          · subst hjb
            have hcj : c ≠ j := Ne.symm hbc
            simp [hij, hib, hic, Ne.symm hib, Ne.symm hic, hcj]
          · simp [hij, hib, hic, Ne.symm hib, Ne.symm hic, hjb, Ne.symm hjb]
    · have h1 : ¬ (i = b ∧ j = c ∧ b < c) := fun h => hij (h.1 ▸ h.2.1 ▸ h.2.2)
      have h2 : ¬ (i = c ∧ j = b ∧ c < b) := fun h => hij (h.1 ▸ h.2.1 ▸ h.2.2)
      simp [hij, h1, h2]
  have e1 : ∑ i, ∑ j, (if i = b ∧ j = c ∧ b < c then M b c ^ 2 else 0) =
      if b < c then M b c ^ 2 else 0 := by
    rw [Finset.sum_eq_single b]
    · rw [Finset.sum_eq_single c]
      · simp
      · intro j _ hj; simp [hj]
      · simp
    · intro i _ hi; apply Finset.sum_eq_zero; intro j _; simp [hi]
    · simp
  have e2 : ∑ i, ∑ j, (if i = c ∧ j = b ∧ c < b then M b c ^ 2 else 0) =
      if c < b then M b c ^ 2 else 0 := by
    rw [Finset.sum_eq_single c]
    · rw [Finset.sum_eq_single b]
      · simp
      · intro j _ hj; simp [hj]
      · simp
    · intro i _ hi; apply Finset.sum_eq_zero; intro j _; simp [hi]
    · simp
  rw [hL]
  simp_rw [hpt]
  simp only [Finset.sum_neg_distrib, Finset.sum_add_distrib]
  rw [e1, e2]
  rcases lt_or_gt_of_ne hbc with h | h
  · simp [h, not_lt.mpr h.le]
  · simp [h, not_lt.mpr h.le]

variable {ι κ : Type*} [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ]
set_option linter.unusedSectionVars false

/-- Variance of a Gaussian norm square: `Var ‖Dg‖² ≤ 2‖D‖² E‖Dg‖²`. -/
theorem centered_norm_sq_var_le (D : Matrix ι κ ℝ) {v : ℝ} (hv : opNorm D ^ 2 ≤ v) :
    ∫ g, (‖Matrix.toEuclideanLin D g‖ ^ 2 -
        ∫ g', ‖Matrix.toEuclideanLin D g'‖ ^ 2 ∂stdGaussian (EuclideanSpace ℝ κ)) ^ 2
        ∂stdGaussian (EuclideanSpace ℝ κ) ≤
      2 * v * ∫ g, ‖Matrix.toEuclideanLin D g‖ ^ 2 ∂stdGaussian (EuclideanSpace ℝ κ) := by
  have hpsd : (D.transpose * D).PosSemidef := by
    simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using
      Matrix.posSemidef_conjTranspose_mul_self D
  have hop : opNorm (D.transpose * D) ≤ v := by
    calc opNorm (D.transpose * D) ≤ opNorm D.transpose * opNorm D :=
          euclidean_operator_norm_mul_le _ _
      _ = opNorm D ^ 2 := by unfold opNorm; rw [euclidean_operator_norm_transpose, pow_two]
      _ ≤ v := hv
  have hmean : ∫ g', ‖Matrix.toEuclideanLin D g'‖ ^ 2 ∂stdGaussian (EuclideanSpace ℝ κ) =
      (D.transpose * D).trace := by
    simp_rw [norm_sq_gaussianImage_eq_quadratic]
    exact integral_euclideanQuadratic_stdGaussian _ hpsd.isHermitian
  rw [hmean]
  simp_rw [norm_sq_gaussianImage_eq_quadratic]
  -- the variance identity of `lem:gauss`(a)
  have hvar := (lem_gauss_a (D.transpose * D) hpsd.isHermitian 0).1
  rw [variance_eq_integral (by unfold euclideanQuadratic; fun_prop),
    integral_euclideanQuadratic_stdGaussian _ hpsd.isHermitian] at hvar
  rw [hvar]
  have hfrob : frobSq (D.transpose * D) ≤ v * (D.transpose * D).trace := by
    unfold frobSq
    rw [← eigenvalues_sq_sum_eq_entry_sq_sum _ hpsd.isHermitian]
    have htrace := hpsd.isHermitian.trace_eq_sum_eigenvalues
    simp only [RCLike.ofReal_real_eq_id, id_eq] at htrace
    rw [htrace, Finset.mul_sum]
    apply Finset.sum_le_sum
    intro i _
    have hi := (le_abs_self (hpsd.isHermitian.eigenvalues i)).trans
      ((abs_eigenvalue_le_euclidean_operator_norm _ hpsd.isHermitian i).trans hop)
    have hp := hpsd.eigenvalues_nonneg i
    nlinarith
  linarith

theorem integrable_centered_norm_sq_sq (D : Matrix ι κ ℝ) (c : ℝ) :
    Integrable (fun g => (‖Matrix.toEuclideanLin D g‖ ^ 2 - c) ^ 2)
      (stdGaussian (EuclideanSpace ℝ κ)) :=
  ((memLp_norm_sq_gaussianImage D).sub (memLp_const c)).integrable_sq

end

end Paulsen.Paper
