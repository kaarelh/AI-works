import Paulsen.Correction
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Positivity

/-!
# Equalizing the row norms

This is a deterministic reduction for the original nearly equal-norm input.
The correction estimate proved here is linear in the row error, which is
sufficient for the sharp Paulsen target.
-/

namespace Paulsen

noncomputable def rowNormalizationScale {n d : ℕ} (U : Frame n d) (i : Fin n) : ℝ :=
  Real.sqrt (((d : ℝ) / (n : ℝ)) / rowNormSq U i)

noncomputable def normalizeRows {n d : ℕ} (U : Frame n d) : Frame n d :=
  fun i j => rowNormalizationScale U i * U i j

theorem rowNormalizationScale_nonneg {n d : ℕ} (U : Frame n d) (i : Fin n) :
    0 ≤ rowNormalizationScale U i := Real.sqrt_nonneg _

theorem rowNormalizationScale_sq {n d : ℕ} (U : Frame n d) (i : Fin n) :
    rowNormalizationScale U i ^ 2 = ((d : ℝ) / (n : ℝ)) / rowNormSq U i := by
  exact Real.sq_sqrt (div_nonneg
    (div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)) (rowNormSq_nonneg U i))

theorem IsNearlyEqualNorm.rowNormSq_pos {n d : ℕ} {ε : ℝ} {U : Frame n d}
    (hU : IsNearlyEqualNorm ε U) (hd : 0 < d) (hn : 0 < n) (hε : ε < 1)
    (i : Fin n) : 0 < rowNormSq U i := by
  have ha : 0 < (d : ℝ) / (n : ℝ) := by positivity
  exact (mul_pos (by linarith) ha).trans_le (hU i).1

theorem normalizeRows_equalNorm {n d : ℕ} (U : Frame n d)
    (hU : ∀ i, 0 < rowNormSq U i) : IsEqualNorm (normalizeRows U) := by
  intro i
  unfold rowNormSq normalizeRows
  simp only [mul_pow, ← Finset.mul_sum]
  change rowNormalizationScale U i ^ 2 * rowNormSq U i = _
  rw [rowNormalizationScale_sq, div_mul_cancel₀ _ (ne_of_gt (hU i))]

theorem nonnegative_radial_cost (q s : ℝ) (hq : 0 ≤ q) (hs : 0 ≤ s) :
    (1 - s) ^ 2 * q ≤ |q - s ^ 2 * q| := by
  by_cases h : s ≤ 1
  · have hp : 0 ≤ q * s * (1 - s) := mul_nonneg (mul_nonneg hq hs) (by linarith)
    have hb := le_abs_self (q - s ^ 2 * q)
    nlinarith
  · have hp : 0 ≤ q * (s - 1) := mul_nonneg hq (by linarith)
    have hb := neg_le_abs (q - s ^ 2 * q)
    nlinarith

theorem normalizeRows_row_cost {n d : ℕ} (U : Frame n d) (i : Fin n)
    (hU : 0 < rowNormSq U i) :
    (∑ j, (U i j - normalizeRows U i j) ^ 2) ≤
      |rowNormSq U i - (d : ℝ) / (n : ℝ)| := by
  have hsq : rowNormalizationScale U i ^ 2 * rowNormSq U i =
      (d : ℝ) / (n : ℝ) := by
    rw [rowNormalizationScale_sq, div_mul_cancel₀ _ (ne_of_gt hU)]
  calc
    (∑ j, (U i j - normalizeRows U i j) ^ 2) =
        (1 - rowNormalizationScale U i) ^ 2 * rowNormSq U i := by
      unfold normalizeRows rowNormSq
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro j _
      ring
    _ ≤ |rowNormSq U i - rowNormalizationScale U i ^ 2 * rowNormSq U i| :=
      nonnegative_radial_cost _ _ hU.le (rowNormalizationScale_nonneg U i)
    _ = _ := by rw [hsq]

theorem normalizeRows_distance {n d : ℕ} {ε : ℝ} (U : Frame n d)
    (hn : 0 < n) (hU : IsNearlyEqualNorm ε U)
    (hpos : ∀ i, 0 < rowNormSq U i) :
    sqDistance U (normalizeRows U) ≤ ε * (d : ℝ) := by
  have hnR : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.ne_of_gt hn)
  calc
    sqDistance U (normalizeRows U) ≤ ∑ _i : Fin n, ε * ((d : ℝ) / (n : ℝ)) := by
      apply Finset.sum_le_sum
      intro i _
      exact (normalizeRows_row_cost U i (hpos i)).trans (hU.abs_error i)
    _ = ε * (d : ℝ) := by
      simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
      field_simp

theorem normalizeRows_energy {n d : ℕ} (U : Frame n d) (x : Fin d → ℝ) :
    frameEnergy (normalizeRows U) x =
      ∑ i, rowNormalizationScale U i ^ 2 * (∑ j, U i j * x j) ^ 2 := by
  unfold frameEnergy normalizeRows
  apply Finset.sum_congr rfl
  intro i _
  simp only [mul_assoc, ← Finset.mul_sum, mul_pow]

theorem normalizeRows_energy_comparison {n d : ℕ} {ε : ℝ} (U : Frame n d)
    (hU : IsNearlyEqualNorm ε U) (hpos : ∀ i, 0 < rowNormSq U i)
    (x : Fin d → ℝ) :
    (1 - ε) * frameEnergy (normalizeRows U) x ≤ frameEnergy U x ∧
      frameEnergy U x ≤ (1 + ε) * frameEnergy (normalizeRows U) x := by
  have hscale (i : Fin n) :
      (1 - ε) * rowNormalizationScale U i ^ 2 ≤ 1 ∧
      1 ≤ (1 + ε) * rowNormalizationScale U i ^ 2 := by
    rw [rowNormalizationScale_sq]
    constructor
    · rw [← mul_div_assoc, div_le_one (hpos i)]
      exact (hU i).1
    · rw [← mul_div_assoc, le_div_iff₀ (hpos i), one_mul]
      exact (hU i).2
  rw [normalizeRows_energy]
  unfold frameEnergy
  simp only [Finset.mul_sum, ← mul_assoc]
  constructor
  · apply Finset.sum_le_sum
    intro i _
    simpa using mul_le_mul_of_nonneg_right (hscale i).1
      (sq_nonneg (∑ j, U i j * x j))
  · apply Finset.sum_le_sum
    intro i _
    simpa using mul_le_mul_of_nonneg_right (hscale i).2
      (sq_nonneg (∑ j, U i j * x j))

theorem normalizeRows_nearlyParseval {n d : ℕ} {ε : ℝ} (U : Frame n d)
    (hU : IsNearlyEqualNormParseval ε U)
    (hpos : ∀ i, 0 < rowNormSq U i) (hε : 0 ≤ ε) (hεhalf : ε ≤ 1 / 2) :
    IsNearlyParseval (4 * ε) (normalizeRows U) := by
  intro x
  obtain ⟨hFl, hFu⟩ := hU.1 x
  obtain ⟨hEl, hEu⟩ := normalizeRows_energy_comparison U hU.2 hpos x
  have hV := vectorNormSq_nonneg x
  constructor
  · by_cases h : vectorNormSq x ≤ frameEnergy (normalizeRows U) x
    · nlinarith [mul_nonneg hε hV]
    · have hm := mul_nonneg hε (sub_nonneg.mpr (le_of_not_ge h))
      nlinarith [mul_nonneg hε hV]
  · by_cases h : frameEnergy (normalizeRows U) x ≤ vectorNormSq x
    · nlinarith [mul_nonneg hε hV]
    · have hm := mul_nonneg (sub_nonneg.mpr hεhalf)
        (sub_nonneg.mpr (le_of_not_ge h))
      nlinarith

/-- Equalizing the rows costs at most εd and increases the spectral error
by at most a factor of four in the small-error range. -/
theorem exists_equal_row_normalization {n d : ℕ} (hd : 0 < d) (hn : 0 < n)
    {ε : ℝ} (U : Frame n d) (hε : 0 ≤ ε) (hεhalf : ε ≤ 1 / 2)
    (hU : IsNearlyEqualNormParseval ε U) :
    ∃ X : Frame n d, IsEqualNorm X ∧ IsNearlyParseval (4 * ε) X ∧
      sqDistance U X ≤ ε * (d : ℝ) := by
  have hpos := hU.2.rowNormSq_pos hd hn (show ε < 1 by linarith)
  exact ⟨normalizeRows U, normalizeRows_equalNorm U hpos,
    normalizeRows_nearlyParseval U hU hpos hε hεhalf,
    normalizeRows_distance U hn hU.2 hpos⟩

/-- Transfer a supplied equal-row correction through the explicit normalization.
This theorem assumes the correction bound and does not prove it. -/
theorem correction_of_equalRowBound {n d : ℕ} (hd : 0 < d) (hn : 0 < n)
    {ε C : ℝ} (U : Frame n d) (hε : 0 ≤ ε) (hεhalf : ε ≤ 1 / 2)
    (hU : IsNearlyEqualNormParseval ε U) (H : EqualRowBound n d (4 * ε) C) :
    HasCorrection U ((2 + 8 * C) * ε * (d : ℝ)) := by
  obtain ⟨X, hX, hXp, hcost⟩ := exists_equal_row_normalization hd hn U hε hεhalf hU
  have hc := (H X hX hXp).transfer hcost
  convert hc using 1; ring

end Paulsen
