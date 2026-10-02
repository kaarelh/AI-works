import Paulsen.Definitions
import Paulsen.Projection
import Mathlib.Analysis.InnerProductSpace.PiL2

/-!
# Complementary Parseval frames

An orthonormal-column matrix extends to an orthogonal square matrix. The
remaining columns form the Naimark complement, with exactly n-d columns.
-/

namespace Paulsen

open Matrix
open scoped BigOperators

/-- Every real Parseval frame admits a complementary Parseval frame of the
expected dimension, including zero-dimensional complements. -/
theorem IsParseval.exists_complement {n d : ℕ} (U : Frame n d)
    (hU : IsParseval U) (hdn : d ≤ n) :
    ∃ V : Frame n (n - d), IsParseval V ∧
      U * U.transpose + V * V.transpose = 1 ∧ U.transpose * V = 0 := by
  classical
  let u : Fin d → EuclideanSpace ℝ (Fin n) :=
    fun j => WithLp.toLp 2 (fun i => U i j)
  have hu : Orthonormal ℝ u := by
    rw [orthonormal_iff_ite]
    intro i j
    have hij := congrArg (fun M : Matrix (Fin d) (Fin d) ℝ => M i j) hU
    simpa only [u, PiLp.inner_apply, Real.inner_apply,
      Matrix.mul_apply, Matrix.transpose_apply, Matrix.one_apply, mul_comm] using hij
  let v : (Fin d ⊕ Fin (n - d)) → EuclideanSpace ℝ (Fin n) :=
    Sum.elim u (fun _ => 0)
  let s : Set (Fin d ⊕ Fin (n - d)) := Set.range Sum.inl
  have hv : Orthonormal ℝ (s.restrict v) := by
    rw [orthonormal_iff_ite]
    intro i j
    obtain ⟨i', hi⟩ := i.property
    obtain ⟨j', hj⟩ := j.property
    have hinner := orthonormal_iff_ite.mp hu i' j'
    have hi' : i = ⟨Sum.inl i', ⟨i', rfl⟩⟩ := Subtype.ext hi.symm
    have hj' : j = ⟨Sum.inl j', ⟨j', rfl⟩⟩ := Subtype.ext hj.symm
    subst i j
    simpa [s, v, Set.restrict] using hinner
  have hcard : Module.finrank ℝ (EuclideanSpace ℝ (Fin n)) =
      Fintype.card (Fin d ⊕ Fin (n - d)) := by
    simp only [finrank_euclideanSpace_fin, Fintype.card_sum, Fintype.card_fin]
    omega
  obtain ⟨b, hb⟩ := hv.exists_orthonormalBasis_extension_of_card_eq hcard
  have hbU : ∀ j : Fin d, b (Sum.inl j) = u j := by
    intro j
    exact hb (Sum.inl j) ⟨j, rfl⟩
  let Q : Matrix (Fin n) (Fin d ⊕ Fin (n - d)) ℝ := Matrix.of (fun i j => b j i)
  have hQtQ : Q.transpose * Q = 1 := by
    ext i j
    have hi := b.inner_eq_ite i j
    simpa only [Q, Matrix.mul_apply, Matrix.transpose_apply, Matrix.of_apply,
      PiLp.inner_apply, Real.inner_apply, Matrix.one_apply, mul_comm] using hi
  have hQQt : Q * Q.transpose = 1 := by
    have hc : Fintype.card (Fin n) = Fintype.card (Fin d ⊕ Fin (n - d)) := by
      simp only [Fintype.card_sum, Fintype.card_fin]
      omega
    exact (Matrix.mul_eq_one_comm_of_equiv
      (A := Q) (B := Q.transpose) (Fintype.equivOfCardEq hc)).mpr hQtQ
  let V : Frame n (n - d) := Matrix.of (fun i j => Q i (Sum.inr j))
  have hQU : ∀ i j, Q i (Sum.inl j) = U i j := by
    intro i j
    change b (Sum.inl j) i = U i j
    rw [hbU]
  refine ⟨V, ?_, ?_, ?_⟩
  · ext i j
    have hi := congrArg (fun M : Matrix (Fin d ⊕ Fin (n - d)) (Fin d ⊕ Fin (n - d)) ℝ =>
      M (Sum.inr i) (Sum.inr j)) hQtQ
    simpa only [V, Matrix.mul_apply, Matrix.transpose_apply, Matrix.of_apply,
      Matrix.one_apply, Sum.inr.injEq] using hi
  · ext i j
    have hi := congrArg (fun M : Matrix (Fin n) (Fin n) ℝ => M i j) hQQt
    simpa only [V, Matrix.mul_apply, Matrix.transpose_apply, Matrix.of_apply,
      Matrix.add_apply, Fintype.sum_sum_type, hQU] using hi
  · ext i j
    have hi := congrArg (fun M : Matrix (Fin d ⊕ Fin (n - d)) (Fin d ⊕ Fin (n - d)) ℝ =>
      M (Sum.inl i) (Sum.inr j)) hQtQ
    simpa only [V, Matrix.mul_apply, Matrix.transpose_apply, Matrix.of_apply,
      Matrix.one_apply, Sum.inl_ne_inr, if_false, Matrix.zero_apply, hQU] using hi

/-- Complementary projections have row energies summing to one. -/
theorem complement_rowNormSq {n d k : ℕ} (U : Frame n d) (V : Frame n k)
    (hcomplete : U * U.transpose + V * V.transpose = 1) (i : Fin n) :
    rowNormSq V i = 1 - rowNormSq U i := by
  have hi := congrArg (fun M : Matrix (Fin n) (Fin n) ℝ => M i i) hcomplete
  simp only [Matrix.add_apply, Matrix.mul_apply, Matrix.transpose_apply,
    Matrix.one_apply, if_true] at hi
  have hs : rowNormSq U i + rowNormSq V i = 1 := by
    simpa only [rowNormSq, pow_two] using hi
  linarith

/-- Passing to the complementary rank preserves every absolute row-energy error. -/
theorem complement_rowNormSq_abs_error {n d : ℕ} (hdn : d ≤ n)
    (U : Frame n d) (V : Frame n (n - d))
    (hcomplete : U * U.transpose + V * V.transpose = 1) (i : Fin n) :
    |rowNormSq V i - ((n - d : ℕ) : ℝ) / (n : ℝ)| =
      |rowNormSq U i - (d : ℝ) / (n : ℝ)| := by
  have hn : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr
    (Nat.ne_of_gt (lt_of_le_of_lt (Nat.zero_le i.val) i.isLt))
  have ht : ((n - d : ℕ) : ℝ) / (n : ℝ) = 1 - (d : ℝ) / (n : ℝ) := by
    rw [Nat.cast_sub hdn]
    field_simp
  rw [complement_rowNormSq U V hcomplete, ht]
  have hneg : 1 - rowNormSq U i - (1 - (d : ℝ) / (n : ℝ)) =
      -(rowNormSq U i - (d : ℝ) / (n : ℝ)) := by ring
  rw [hneg, abs_neg]

theorem IsEqualNorm.complement {n d : ℕ} {U : Frame n d}
    (hU : IsEqualNorm U) (hdn : d ≤ n) (V : Frame n (n - d))
    (hcomplete : U * U.transpose + V * V.transpose = 1) :
    IsEqualNorm V := by
  intro i
  have hi := complement_rowNormSq_abs_error hdn U V hcomplete i
  rw [hU i, sub_self, abs_zero] at hi
  exact sub_eq_zero.mp (abs_eq_zero.mp hi)

/-- The relative error changes by the ratio of the two complementary ranks. -/
theorem IsNearlyEqualNorm.complement {n d : ℕ} {U : Frame n d} {ε : ℝ}
    (hU : IsNearlyEqualNorm ε U) (hdn : d < n) (V : Frame n (n - d))
    (hcomplete : U * U.transpose + V * V.transpose = 1) :
    IsNearlyEqualNorm (ε * (d : ℝ) / ((n - d : ℕ) : ℝ)) V := by
  have hn : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.ne_of_gt (lt_of_le_of_lt (Nat.zero_le d) hdn))
  have hk : ((n - d : ℕ) : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.ne_of_gt (Nat.sub_pos_of_lt hdn))
  intro i
  have hi := hU.abs_error i
  rw [← complement_rowNormSq_abs_error (le_of_lt hdn) U V hcomplete i] at hi
  have hs : (ε * (d : ℝ) / ((n - d : ℕ) : ℝ)) *
      (((n - d : ℕ) : ℝ) / (n : ℝ)) = ε * ((d : ℝ) / (n : ℝ)) := by
    field_simp
  rw [← hs] at hi
  obtain ⟨hl, hu⟩ := abs_le.mp hi
  constructor <;> nlinarith

end Paulsen
