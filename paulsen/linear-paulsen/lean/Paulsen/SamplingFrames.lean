import Paulsen.Sampling
import Paulsen.Definitions
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Algebra.Order.Chebyshev

/-!
# Sampling equal-row frame covariance matrices

Matrices are embedded into Euclidean space so that the norm is explicitly
the Frobenius norm, rather than the operator norm or a supremum norm.
-/

namespace Paulsen

open scoped BigOperators

theorem sum_centered_norm_sq {ι E : Type*} [Fintype ι]
    [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (v : ι → E) (hn : (Fintype.card ι : ℝ) ≠ 0) :
    (∑ i, ‖v i - (Fintype.card ι : ℝ)⁻¹ • ∑ j, v j‖ ^ 2) =
      (∑ i, ‖v i‖ ^ 2) - (Fintype.card ι : ℝ) *
        ‖(Fintype.card ι : ℝ)⁻¹ • ∑ j, v j‖ ^ 2 := by
  let m : E := (Fintype.card ι : ℝ)⁻¹ • ∑ j, v j
  have hs : (∑ i, v i) = (Fintype.card ι : ℝ) • m := by
    dsimp [m]
    rw [smul_smul, mul_inv_cancel₀ hn, one_smul]
  change (∑ i, ‖v i - m‖ ^ 2) = (∑ i, ‖v i‖ ^ 2) - _ * ‖m‖ ^ 2
  simp only [norm_sub_sq_real, Finset.sum_add_distrib, Finset.sum_sub_distrib,
    ← Finset.mul_sum, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  rw [← sum_inner, hs, real_inner_smul_left, real_inner_self_eq_norm_sq]
  ring

theorem sum_centered_norm_sq_le {ι E : Type*} [Fintype ι]
    [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (v : ι → E) (hn : (Fintype.card ι : ℝ) ≠ 0) :
    (∑ i, ‖v i - (Fintype.card ι : ℝ)⁻¹ • ∑ j, v j‖ ^ 2) ≤ ∑ i, ‖v i‖ ^ 2 := by
  rw [sum_centered_norm_sq v hn]
  exact sub_le_self _ (mul_nonneg (Nat.cast_nonneg _) (sq_nonneg _))

noncomputable def rowOuterVector {n d : ℕ} (U : Frame n d) (i : Fin n) :
    EuclideanSpace ℝ (Fin d × Fin d) :=
  WithLp.toLp 2 (fun p => U i p.1 * U i p.2)

theorem rowOuterVector_norm_sq {n d : ℕ} (U : Frame n d) (i : Fin n) :
    ‖rowOuterVector U i‖ ^ 2 = rowNormSq U i ^ 2 := by
  rw [EuclideanSpace.real_norm_sq_eq]
  simp only [rowOuterVector, PiLp.toLp_apply, Fintype.sum_prod_type, mul_pow]
  simp only [rowNormSq, pow_two, Finset.sum_mul, Finset.mul_sum]
  rw [Finset.sum_comm]

theorem sum_rowOuterVector_apply {n d : ℕ} (U : Frame n d) (j k : Fin d) :
    (∑ i, rowOuterVector U i) (j, k) = (U.transpose * U) j k := by
  simp [rowOuterVector, Matrix.mul_apply]

/-- A sampled Gram matrix, after rescaling by n/q, minus the original Gram matrix. -/
noncomputable def sampledGramError {n d : ℕ} (U : Frame n d) (q : ℕ)
    (s : Finset (Fin n)) : EuclideanSpace ℝ (Fin d × Fin d) :=
  ((n : ℝ) / q) • (∑ i ∈ s, rowOuterVector U i) - ∑ i, rowOuterVector U i

theorem sampledGramError_apply {n d : ℕ} (U : Frame n d) (q : ℕ)
    (s : Finset (Fin n)) (j k : Fin d) :
    sampledGramError U q s (j, k) =
      ((n : ℝ) / q) * (∑ i ∈ s, U i j * U i k) - (U.transpose * U) j k := by
  simp [sampledGramError, rowOuterVector, Matrix.mul_apply]

/-- Exact covariance variance for a uniformly chosen block, in Frobenius norm. -/
theorem uniform_sampledGram_variance {n d : ℕ} (U : Frame n d)
    (q : ℕ) (hq : 2 ≤ q) (hqn : q ≤ n) :
    (∑ s ∈ (Finset.univ : Finset (Fin n)).powersetCard q,
      ((n.choose q : ℝ))⁻¹ * ‖sampledGramError U q s‖ ^ 2) =
      ((n : ℝ) * ((n : ℝ) - q) / ((q : ℝ) * ((n : ℝ) - 1))) *
        ∑ i, ‖rowOuterVector U i - (n : ℝ)⁻¹ • ∑ j, rowOuterVector U j‖ ^ 2 := by
  simpa [sampledGramError] using uniform_subset_sum_variance
    (rowOuterVector U) q hq (by simpa using hqn)

/-- The estimate used by the blocking argument: covariance variance ≤ d²/q. -/
theorem uniform_sampledGram_variance_le {n d : ℕ} (U : Frame n d)
    (hU : IsEqualNorm U) (q : ℕ) (hq : 2 ≤ q) (hqn : q ≤ n) :
    (∑ s ∈ (Finset.univ : Finset (Fin n)).powersetCard q,
      ((n.choose q : ℝ))⁻¹ * ‖sampledGramError U q s‖ ^ 2) ≤ (d : ℝ) ^ 2 / q := by
  have hn : 0 < n := lt_of_lt_of_le (by omega : 0 < q) hqn
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hqR : (0 : ℝ) < q := by exact_mod_cast (by omega : 0 < q)
  have hqnR : (q : ℝ) ≤ n := by exact_mod_cast hqn
  have hq1 : (1 : ℝ) ≤ q := by exact_mod_cast (by omega : 1 ≤ q)
  have hn1 : (0 : ℝ) < (n : ℝ) - 1 := by
    have h2 : (2 : ℝ) ≤ n := by exact_mod_cast (hq.trans hqn)
    linarith
  have hcenter := sum_centered_norm_sq_le (rowOuterVector U)
    (show (Fintype.card (Fin n) : ℝ) ≠ 0 by simpa using hnR.ne')
  simp only [Fintype.card_fin] at hcenter
  have hsum : (∑ i, ‖rowOuterVector U i‖ ^ 2) = (d : ℝ) ^ 2 / n := by
    simp_rw [rowOuterVector_norm_sq]
    have heq : ∀ i, rowNormSq U i = (d : ℝ) / n := hU
    simp_rw [heq]
    simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    field_simp
  rw [hsum] at hcenter
  rw [uniform_sampledGram_variance U q hq hqn]
  have hfactor : 0 ≤ (n : ℝ) * ((n : ℝ) - q) / ((q : ℝ) * ((n : ℝ) - 1)) :=
    div_nonneg (mul_nonneg hnR.le (sub_nonneg.mpr hqnR)) (mul_nonneg hqR.le hn1.le)
  apply (mul_le_mul_of_nonneg_left hcenter hfactor).trans
  have hcancel : ((n : ℝ) * ((n : ℝ) - q) / ((q : ℝ) * ((n : ℝ) - 1))) *
      ((d : ℝ) ^ 2 / n) = ((n : ℝ) - q) / ((n : ℝ) - 1) * ((d : ℝ) ^ 2 / q) := by
    field_simp
  rw [hcancel]
  have hratio : ((n : ℝ) - q) / ((n : ℝ) - 1) ≤ 1 := by
    apply (div_le_one hn1).mpr
    linarith
  simpa using mul_le_mul_of_nonneg_right hratio
    (div_nonneg (sq_nonneg (d : ℝ)) hqR.le)

/-- Cauchy--Schwarz for a uniform average, expressed without a probability space. -/
theorem uniform_mean_sq_le_mean_sq {ι : Type*} (s : Finset ι) (f : ι → ℝ)
    (hs : s.Nonempty) :
    ((s.card : ℝ)⁻¹ * (∑ i ∈ s, f i)) ^ 2 ≤
      (s.card : ℝ)⁻¹ * (∑ i ∈ s, f i ^ 2) := by
  have hc : (0 : ℝ) < s.card := Nat.cast_pos.mpr hs.card_pos
  have h := sq_sum_le_card_mul_sum_sq (s := s) (f := f)
  have hm := mul_le_mul_of_nonneg_left h (sq_nonneg ((s.card : ℝ)⁻¹))
  calc
    ((s.card : ℝ)⁻¹ * ∑ i ∈ s, f i) ^ 2 =
        ((s.card : ℝ)⁻¹) ^ 2 * (∑ i ∈ s, f i) ^ 2 := mul_pow _ _ _
    _ ≤ ((s.card : ℝ)⁻¹) ^ 2 * ((s.card : ℝ) * ∑ i ∈ s, f i ^ 2) := hm
    _ = _ := by field_simp

/-- The expected Frobenius error of the rescaled block is at most d/√q. -/
theorem uniform_sampledGram_mean_norm_le {n d : ℕ} (U : Frame n d)
    (hU : IsEqualNorm U) (q : ℕ) (hq : 2 ≤ q) (hqn : q ≤ n) :
    (∑ s ∈ (Finset.univ : Finset (Fin n)).powersetCard q,
      ((n.choose q : ℝ))⁻¹ * ‖sampledGramError U q s‖) ≤
      (d : ℝ) / Real.sqrt q := by
  let samples := (Finset.univ : Finset (Fin n)).powersetCard q
  have hcard : samples.card = n.choose q := by simp [samples]
  have hnonempty : samples.Nonempty := Finset.card_pos.mp (by rw [hcard]; exact Nat.choose_pos hqn)
  have hmean := uniform_mean_sq_le_mean_sq samples (fun s => ‖sampledGramError U q s‖) hnonempty
  rw [hcard] at hmean
  have hvar := uniform_sampledGram_variance_le U hU q hq hqn
  change (∑ s ∈ samples, (n.choose q : ℝ)⁻¹ * ‖sampledGramError U q s‖ ^ 2) ≤ _ at hvar
  rw [← Finset.mul_sum] at hvar
  have hqR : (0 : ℝ) < q := by exact_mod_cast (by omega : 0 < q)
  have hsqrt : 0 < Real.sqrt (q : ℝ) := Real.sqrt_pos.mpr hqR
  rw [← Finset.mul_sum]
  apply (sq_le_sq₀ (by positivity) (by positivity)).mp
  calc
    ((n.choose q : ℝ)⁻¹ * ∑ s ∈ samples, ‖sampledGramError U q s‖) ^ 2 ≤
        (d : ℝ) ^ 2 / q := hmean.trans hvar
    _ = ((d : ℝ) / Real.sqrt q) ^ 2 := by rw [div_pow, Real.sq_sqrt hqR.le]

end Paulsen
