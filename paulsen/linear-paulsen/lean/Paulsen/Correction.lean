import Paulsen.Definitions

/-! Basic certified cost rules. No existence of a sharp correction is assumed here. -/

namespace Paulsen

def HasCorrection {n d : ℕ} (U : Frame n d) (cost : ℝ) : Prop :=
  ∃ W : Frame n d, IsEqualNormParseval W ∧ sqDistance U W ≤ cost

theorem HasCorrection.mono {n d : ℕ} {U : Frame n d} {a b : ℝ}
    (h : HasCorrection U a) (hab : a ≤ b) : HasCorrection U b := by
  obtain ⟨W, hW, hUW⟩ := h
  exact ⟨W, hW, hUW.trans hab⟩

theorem HasCorrection.transfer {n d : ℕ} {U V : Frame n d} {a b : ℝ}
    (h : HasCorrection V a) (hUV : sqDistance U V ≤ b) :
    HasCorrection U (2 * b + 2 * a) := by
  obtain ⟨W, hW, hVW⟩ := h
  refine ⟨W, hW, ?_⟩
  have ht := sqDistance_triangle U V W
  linarith

theorem IsEqualNormParseval.hasCorrection {n d : ℕ} {U : Frame n d}
    (h : IsEqualNormParseval U) : HasCorrection U 0 :=
  ⟨U, h, (sqDistance_self U).le⟩

theorem HasCorrection.cost_nonneg {n d : ℕ} {U : Frame n d} {cost : ℝ}
    (h : HasCorrection U cost) : 0 ≤ cost := by
  obtain ⟨W, _, hUW⟩ := h
  exact (sqDistance_nonneg U W).trans hUW

/-- The equal-row correction problem in quadratic-form language. -/
def EqualRowBound (n d : ℕ) (η C : ℝ) : Prop :=
  ∀ X : Frame n d, IsEqualNorm X → IsNearlyParseval η X →
    HasCorrection X (C * η * (d : ℝ))

theorem EqualRowBound.mono {n d : ℕ} {η C D : ℝ}
    (h : EqualRowBound n d η C) (hη : 0 ≤ η) (hCD : C ≤ D) :
    EqualRowBound n d η D := by
  intro X hX hηX
  apply (h X hX hηX).mono
  exact mul_le_mul_of_nonneg_right
    (mul_le_mul_of_nonneg_right hCD hη) (Nat.cast_nonneg d)

end Paulsen
