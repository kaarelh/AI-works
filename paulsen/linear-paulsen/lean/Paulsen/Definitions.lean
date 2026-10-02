import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Real finite frames and the sharp Paulsen statement

SharpPaulsenBound below specifies the target proposition.
Its proof is Paulsen.sharpPaulsenBound in Paulsen.SharpBound.
Frames are matrices whose rows are the frame vectors.
-/

open scoped BigOperators

namespace Paulsen

abbrev Frame (n d : ℕ) := Matrix (Fin n) (Fin d) ℝ

def rowNormSq {n d : ℕ} (U : Frame n d) (i : Fin n) : ℝ :=
  ∑ j, U i j ^ 2

def vectorNormSq {d : ℕ} (x : Fin d → ℝ) : ℝ :=
  ∑ j, x j ^ 2

def frameEnergy {n d : ℕ} (U : Frame n d) (x : Fin d → ℝ) : ℝ :=
  ∑ i, (∑ j, U i j * x j) ^ 2

def sqDistance {n d : ℕ} (U V : Frame n d) : ℝ :=
  ∑ i, ∑ j, (U i j - V i j) ^ 2

def IsParseval {n d : ℕ} (U : Frame n d) : Prop :=
  U.transpose * U = 1

def IsEqualNorm {n d : ℕ} (U : Frame n d) : Prop :=
  ∀ i, rowNormSq U i = (d : ℝ) / (n : ℝ)

def IsEqualNormParseval {n d : ℕ} (U : Frame n d) : Prop :=
  IsParseval U ∧ IsEqualNorm U

/-- The usual operator inequalities, expressed as quadratic-form inequalities. -/
def IsNearlyParseval {n d : ℕ} (ε : ℝ) (U : Frame n d) : Prop :=
  ∀ x : Fin d → ℝ,
    (1 - ε) * vectorNormSq x ≤ frameEnergy U x ∧
      frameEnergy U x ≤ (1 + ε) * vectorNormSq x

def IsNearlyEqualNorm {n d : ℕ} (ε : ℝ) (U : Frame n d) : Prop :=
  ∀ i, (1 - ε) * ((d : ℝ) / (n : ℝ)) ≤ rowNormSq U i ∧
    rowNormSq U i ≤ (1 + ε) * ((d : ℝ) / (n : ℝ))

def IsNearlyEqualNormParseval {n d : ℕ} (ε : ℝ) (U : Frame n d) : Prop :=
  IsNearlyParseval ε U ∧ IsNearlyEqualNorm ε U

/-- The unrestricted real Paulsen bound, with one constant for all dimensions and errors.
This definition is proved in Paulsen.SharpBound. -/
def SharpPaulsenBound : Prop :=
  ∃ C : ℝ, 0 < C ∧
    ∀ (n d : ℕ), 0 < d → d ≤ n →
    ∀ (ε : ℝ) (U : Frame n d), 0 < ε → ε < 1 →
      IsNearlyEqualNormParseval ε U →
      ∃ W : Frame n d, IsEqualNormParseval W ∧
        sqDistance U W ≤ C * ε * (d : ℝ)

theorem rowNormSq_nonneg {n d : ℕ} (U : Frame n d) (i : Fin n) :
    0 ≤ rowNormSq U i := by
  exact Finset.sum_nonneg fun _ _ ↦ sq_nonneg _

theorem vectorNormSq_nonneg {d : ℕ} (x : Fin d → ℝ) :
    0 ≤ vectorNormSq x := by
  exact Finset.sum_nonneg fun _ _ ↦ sq_nonneg _

theorem sqDistance_nonneg {n d : ℕ} (U V : Frame n d) :
    0 ≤ sqDistance U V := by
  exact Finset.sum_nonneg fun _ _ ↦ Finset.sum_nonneg fun _ _ ↦ sq_nonneg _

@[simp] theorem sqDistance_self {n d : ℕ} (U : Frame n d) :
    sqDistance U U = 0 := by
  simp [sqDistance]

theorem sqDistance_symm {n d : ℕ} (U V : Frame n d) :
    sqDistance U V = sqDistance V U := by
  simp only [sqDistance]
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem sqDistance_triangle {n d : ℕ} (U V W : Frame n d) :
    sqDistance U W ≤ 2 * sqDistance U V + 2 * sqDistance V W := by
  unfold sqDistance
  simp only [Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_le_sum
  intro i _
  apply Finset.sum_le_sum
  intro j _
  nlinarith [sq_nonneg (U i j - 2 * V i j + W i j)]

theorem isParseval_iff_gram {n d : ℕ} (U : Frame n d) :
    IsParseval U ↔
      ∀ j k : Fin d, (∑ i, U i j * U i k) = if j = k then 1 else 0 := by
  constructor
  · intro h j k
    have h' := congrArg (fun A : Matrix (Fin d) (Fin d) ℝ ↦ A j k) h
    simpa only [Matrix.mul_apply, Matrix.transpose_apply, Matrix.one_apply] using h'
  · intro h
    apply Matrix.ext
    intro j k
    simpa only [Matrix.mul_apply, Matrix.transpose_apply, Matrix.one_apply] using h j k

theorem frameEnergy_eq_sum_gram {n d : ℕ} (U : Frame n d) (x : Fin d → ℝ) :
    frameEnergy U x =
      ∑ j, ∑ k, (∑ i, U i j * U i k) * x j * x k := by
  unfold frameEnergy
  calc
    ∑ i, (∑ j, U i j * x j) ^ 2 =
        ∑ i, ∑ j, ∑ k, U i j * U i k * x j * x k := by
      apply Finset.sum_congr rfl
      intro i _
      simp only [pow_two, Finset.sum_mul, Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro j _
      apply Finset.sum_congr rfl
      intro k _
      ring
    _ = ∑ j, ∑ k, ∑ i, U i j * U i k * x j * x k := by
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl
      intro j _
      rw [Finset.sum_comm]
    _ = _ := by simp only [Finset.sum_mul]

theorem IsParseval.frameEnergy_eq {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (x : Fin d → ℝ) :
    frameEnergy U x = vectorNormSq x := by
  rw [frameEnergy_eq_sum_gram]
  simp_rw [(isParseval_iff_gram U).mp hU]
  simp [vectorNormSq, pow_two]

theorem IsParseval.isNearlyParseval {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ε : ℝ} (hε : 0 ≤ ε) :
    IsNearlyParseval ε U := by
  intro x
  rw [hU.frameEnergy_eq]
  have hx := vectorNormSq_nonneg x
  constructor <;> nlinarith

theorem IsEqualNorm.isNearlyEqualNorm {n d : ℕ} {U : Frame n d}
    (hU : IsEqualNorm U) {ε : ℝ} (hε : 0 ≤ ε) :
    IsNearlyEqualNorm ε U := by
  intro i
  rw [hU i]
  have ha : 0 ≤ (d : ℝ) / (n : ℝ) := div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)
  constructor <;> nlinarith

theorem IsParseval.total_rowNormSq {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) :
    (∑ i, rowNormSq U i) = (d : ℝ) := by
  unfold rowNormSq
  rw [Finset.sum_comm]
  calc
    ∑ j, ∑ i, U i j ^ 2 = ∑ _j : Fin d, (1 : ℝ) := by
      apply Finset.sum_congr rfl
      intro j _
      simpa [pow_two] using (isParseval_iff_gram U).mp hU j j
    _ = _ := by simp

theorem sqDistance_le_twice_energy {n d : ℕ} (U V : Frame n d) :
    sqDistance U V ≤ 2 * (∑ i, rowNormSq U i) + 2 * (∑ i, rowNormSq V i) := by
  unfold sqDistance rowNormSq
  simp only [Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_le_sum
  intro i _
  apply Finset.sum_le_sum
  intro j _
  nlinarith [sq_nonneg (U i j + V i j)]

theorem sqDistance_le_four_rank {n d : ℕ} {U V : Frame n d}
    (hU : IsParseval U) (hV : IsParseval V) :
    sqDistance U V ≤ 4 * (d : ℝ) := by
  have h := sqDistance_le_twice_energy U V
  rw [hU.total_rowNormSq, hV.total_rowNormSq] at h
  linarith

theorem IsNearlyEqualNorm.abs_error {n d : ℕ} {U : Frame n d} {ε : ℝ}
    (hU : IsNearlyEqualNorm ε U) (i : Fin n) :
    |rowNormSq U i - (d : ℝ) / (n : ℝ)| ≤ ε * ((d : ℝ) / (n : ℝ)) := by
  obtain ⟨hl, hu⟩ := hU i
  apply abs_le.mpr
  constructor <;> linarith

theorem exact_input_has_zero_cost {n d : ℕ} {U : Frame n d}
    (hU : IsEqualNormParseval U) :
    ∃ W : Frame n d, IsEqualNormParseval W ∧ sqDistance U W = 0 := by
  exact ⟨U, hU, sqDistance_self U⟩

end Paulsen
