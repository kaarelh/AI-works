import Paulsen.RowNormalization
import Paulsen.Energy

/-!
# Reduction from general frames to equal-row frames

This proves that a uniform all-density equal-row bound implies the full
target statement. The all-density equal-row bound is an explicit hypothesis;
this file does not establish it.
-/

namespace Paulsen

theorem equalRowBound_zero (n d : ℕ) (C : ℝ) : EqualRowBound n d 0 C := by
  intro X hX hXp
  have hexact : IsEqualNormParseval X := ⟨(isNearlyParseval_zero_iff X).mp hXp, hX⟩
  simpa using hexact.hasCorrection

/-- A uniform equal-row correction theorem is enough for the unrestricted
Paulsen bound. No polar decomposition is needed for this direction. -/
theorem sharpPaulsenBound_of_equalRowBounds (C : ℝ) (hC : 0 < C)
    (H : ∀ n d : ℕ, 0 < d → d ≤ n → ∀ η : ℝ, 0 ≤ η → EqualRowBound n d η C) :
    SharpPaulsenBound := by
  refine ⟨14 + 8 * C, by positivity, ?_⟩
  intro n d hd hdn ε U hε hεone hU
  have hn : 0 < n := lt_of_lt_of_le hd hdn
  have hdR : 0 ≤ (d : ℝ) := Nat.cast_nonneg _
  by_cases hsmall : ε ≤ 1 / 2
  · have h := correction_of_equalRowBound hd hn U hε.le hsmall hU
      (H n d hd hdn (4 * ε) (by positivity))
    apply h.mono
    nlinarith [mul_nonneg hε.le hdR]
  · have hpos := hU.2.rowNormSq_pos hd hn hεone
    have heq := normalizeRows_equalNorm U hpos
    obtain ⟨W, hW, _⟩ := H n d hd hdn (d : ℝ) hdR (normalizeRows U) heq
      (heq.isNearlyParseval_rank hd hn)
    refine ⟨W, hW, ?_⟩
    have he := hU.2.total_rowNormSq_le hn
    have hdist := sqDistance_le_twice_energy U W
    rw [hW.1.total_rowNormSq] at hdist
    have hlarge : 1 / 2 < ε := lt_of_not_ge hsmall
    have hcost : sqDistance U W ≤ 6 * (d : ℝ) := by
      nlinarith [mul_nonneg (show 0 ≤ 1 - ε by linarith) hdR]
    have h12 : 6 * (d : ℝ) ≤ 12 * ε * (d : ℝ) := by
      nlinarith [mul_nonneg (show 0 ≤ 2 * ε - 1 by linarith) hdR]
    apply hcost.trans (h12.trans _)
    have hcoeff : 12 ≤ 14 + 8 * C := by linarith
    exact mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_right hcoeff hε.le) hdR

end Paulsen
