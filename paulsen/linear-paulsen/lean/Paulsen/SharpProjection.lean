import Paulsen.ProjectionFactor
import Paulsen.ComplementReduction

/-! The projection form of the linear Paulsen estimate, derived from the frame statement. -/
namespace Paulsen
open Matrix
open scoped BigOperators
noncomputable section

/-- Uniform projection correction in absolute diagonal error. This includes
ranks zero and n, zero error, and errors of arbitrary size. -/
def SharpProjectionBound : Prop :=
  ∃ C : ℝ, 0 < C ∧ ∀ (n d : ℕ), 0 < n →
    ∀ (P : Frame n n), P.transpose = P → P * P = P → P.rank = d →
    ∀ β : ℝ, 0 ≤ β → (∀ i, |P i i - (d : ℝ) / n| ≤ β) →
    ∃ Q : Frame n n, Q.transpose = Q ∧ Q * Q = Q ∧ Q.rank = d ∧
      (∀ i, Q i i = (d : ℝ) / n) ∧ sqDistance P Q ≤ C * (n : ℝ) * β

/-- The isometry-represented projection estimate, with a universal constant
and no restriction on absolute diagonal error. -/
theorem projection_frame_bound_of_sharpPaulsenBound (H : SharpPaulsenBound) :
    ∃ C : ℝ, 0 < C ∧ ∀ (n d : ℕ), 0 < n → d ≤ n →
      ∀ (U : Frame n d), IsParseval U → ∀ β : ℝ, 0 ≤ β →
      (∀ i, |rowNormSq U i - (d : ℝ) / n| ≤ β) →
      ∃ W : Frame n d, IsEqualNormParseval W ∧
        sqDistance (frameProjection U) (frameProjection W) ≤ C * (n : ℝ) * β := by
  obtain ⟨C, hC, H⟩ := H
  refine ⟨2 * C + 2, by positivity, ?_⟩
  intro n d hn hdn U hU β hβ herr
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  by_cases hβzero : β = 0
  · subst β
    refine ⟨U, ⟨hU, ?_⟩, by simp⟩
    intro i
    exact sub_eq_zero.mp (abs_eq_zero.mp (le_antisymm (herr i) (abs_nonneg _)))
  by_cases hd : 0 < d
  · have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hd
    have hβpos : 0 < β := lt_of_le_of_ne hβ (Ne.symm hβzero)
    by_cases hsmall : β * (n : ℝ) / d < 1
    · let ε := β * (n : ℝ) / d
      have hε : 0 < ε := div_pos (mul_pos hβpos hnR) hdR
      have hcancel : ε * ((d : ℝ) / n) = β := by
        dsimp [ε]
        field_simp
      have hnear : IsNearlyEqualNormParseval ε U := by
        refine ⟨hU.isNearlyParseval hε.le, ?_⟩
        intro i
        have hi := abs_le.mp (herr i)
        constructor <;> nlinarith [hcancel]
      obtain ⟨W, hW, hdist⟩ := H n d hd hdn ε U hε hsmall hnear
      refine ⟨W, hW, ?_⟩
      calc
        _ ≤ 2 * sqDistance U W := projection_sqDistance_le_twice U W hU hW.1
        _ ≤ 2 * (C * ε * (d : ℝ)) := mul_le_mul_of_nonneg_left hdist (by norm_num)
        _ = 2 * C * (n : ℝ) * β := by dsimp [ε]; field_simp
        _ ≤ (2 * C + 2) * (n : ℝ) * β := by
          nlinarith only [mul_nonneg (Nat.cast_nonneg n) hβ]
    · obtain ⟨W, hW⟩ := exists_equalNormParseval hn hdn
      refine ⟨W, hW, ?_⟩
      have hdβ : (d : ℝ) ≤ β * (n : ℝ) := by
        have hh := (le_div_iff₀ hdR).mp (le_of_not_gt hsmall)
        simpa using hh
      have hb : 0 ≤ (n : ℝ) * β := by positivity
      calc
        _ ≤ 2 * (d : ℝ) := parseval_projection_sqDistance_le_twice_rank U W hU hW.1
        _ ≤ 2 * ((n : ℝ) * β) := by nlinarith only [hdβ]
        _ ≤ (2 * C + 2) * (n : ℝ) * β := by nlinarith only [mul_nonneg hC.le hb]
  · have hd0 : d = 0 := by omega
    subst d
    refine ⟨U, ⟨hU, ?_⟩, ?_⟩
    · intro i
      simp [rowNormSq]
    · rw [sqDistance_self]
      positivity

/-- The frame theorem implies the full projection theorem for raw symmetric
idempotent matrices, using an orthonormal basis of the projection's range. -/
theorem sharpProjectionBound_of_sharpPaulsenBound (H : SharpPaulsenBound) :
    SharpProjectionBound := by
  obtain ⟨C, hC, HC⟩ := projection_frame_bound_of_sharpPaulsenBound H
  refine ⟨C, hC, ?_⟩
  intro n d hn P hsymm hidem hrank β hβ herr
  obtain ⟨U, hU, hUP⟩ := exists_parseval_of_symmetric_idempotent P hsymm hidem
  subst d
  have hdn : P.rank ≤ n := Matrix.rank_le_height P
  obtain ⟨W, hW, hdist⟩ := HC n P.rank hn hdn U hU β hβ (by
    intro i
    rw [← frameProjection_diagonal, hUP]
    exact herr i)
  refine ⟨frameProjection W, frameProjection_transpose W, hW.1.frameProjection_idempotent,
    hW.1.frameProjection_rank, hW.2.projection_diagonal, ?_⟩
  simpa only [hUP] using hdist

end
end Paulsen
