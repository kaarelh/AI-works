import Paulsen.ComplementReduction
import Paulsen.PolarNormalization
import Paulsen.GeneralReduction

/-!
# Partition-free global assembly

The linear Paulsen bound follows from three regimes for equal-norm frames with
`2d ≤ n`: bounded rank (Hamilton–Moitra), many rows `n ≥ B d²` with spectral
error at most an absolute constant, and moderate rows `n < B d²` (so that
`d ≥ A log 2n`). The two seed theorems enter through the interfaces
`ManyRowBound` and `ModerateParsevalBound`.
-/

namespace Paulsen.Linear

open Paulsen

/-- Many-row interface: equal-norm frames with `n ≥ B d²` and spectral error
`η ≤ c` are within `C η d` of an equal-norm Parseval frame. -/
def ManyRowBound (B c C : ℝ) : Prop :=
  ∀ (n d : ℕ), 0 < d → d ≤ n → B * (d : ℝ) ^ 2 ≤ (n : ℝ) →
    ∀ η : ℝ, 0 < η → η ≤ c → EqualRowBound n d η C

/-- Moderate-row interface, in Parseval form: frames with `2d ≤ n`,
`d ≥ A log 2n` and diagonal error `ε ≤ ε₀` are within `C ε d`. -/
def ModerateParsevalBound (A ε₀ C : ℝ) : Prop :=
  ∀ (n d : ℕ), 0 < d → 2 * d ≤ n → A * Real.log (2 * (n : ℝ)) ≤ (d : ℝ) →
    ∀ ε : ℝ, 0 < ε → ε ≤ ε₀ → ∀ U : Frame n d, IsParseval U →
      IsNearlyEqualNorm ε U → HasCorrection U (C * ε * (d : ℝ))

/-- Any equal-norm frame is within `4d` of an equal-norm Parseval frame. -/
theorem equalNorm_hasCorrection_trivial {n d : ℕ} (hd : 0 < d) (hdn : d ≤ n)
    (X : Frame n d) (hX : IsEqualNorm X) : HasCorrection X (4 * (d : ℝ)) := by
  have hn : 0 < n := lt_of_lt_of_le hd hdn
  obtain ⟨W, hW⟩ := exists_equalNormParseval hn hdn
  refine ⟨W, hW, ?_⟩
  have hdist := sqDistance_le_twice_energy X W
  have hsum : (∑ i, rowNormSq X i) = (d : ℝ) := by
    simp only [show ∀ i, rowNormSq X i = (d : ℝ) / n from hX, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    have : (n : ℝ) ≠ 0 := by exact_mod_cast hn.ne'
    field_simp
  rw [hsum, hW.1.total_rowNormSq] at hdist
  linarith

/-- For large `d`, `A log (2 B d²) ≤ d`. -/
theorem exists_log_threshold (A B : ℝ) (hA : 0 ≤ A) (hB : 0 < B) :
    ∃ D : ℕ, 0 < D ∧ ∀ d : ℕ, D ≤ d → A * Real.log (2 * B * (d : ℝ) ^ 2) ≤ (d : ℝ) := by
  set L := |Real.log (2 * B)|
  obtain ⟨D, hD⟩ := exists_nat_gt (64 * A ^ 2 + 2 * A * L + 1)
  refine ⟨D, by
    have : (0 : ℝ) < D := by nlinarith [abs_nonneg (Real.log (2 * B)), sq_nonneg A]
    exact_mod_cast this, ?_⟩
  intro d hd
  have hdR : (D : ℝ) ≤ d := by exact_mod_cast hd
  have hd1 : (1 : ℝ) ≤ d := by nlinarith [abs_nonneg (Real.log (2 * B)), sq_nonneg A]
  have hdpos : (0 : ℝ) < d := by linarith
  -- log d ≤ 2 √d
  have hsq : 0 < Real.sqrt d := Real.sqrt_pos.mpr hdpos
  have hlogsqrt : Real.log (Real.sqrt d) ≤ Real.sqrt d - 1 := Real.log_le_sub_one_of_pos hsq
  have hlogd : Real.log d = 2 * Real.log (Real.sqrt d) := by
    rw [← Real.log_rpow hsq, Real.rpow_two, Real.sq_sqrt hdpos.le]
    -- `Real.log_rpow` gives `log (√d ^ 2) = 2 * log √d`
  have hsplit : Real.log (2 * B * (d : ℝ) ^ 2) = Real.log (2 * B) + 2 * Real.log d := by
    rw [Real.log_mul (by positivity) (by positivity), Real.log_pow]; push_cast; ring
  have hsqd : Real.sqrt d * Real.sqrt d = d := Real.mul_self_sqrt hdpos.le
  -- √d ≥ 8A
  have h8 : 8 * A ≤ Real.sqrt d := by
    rw [show 8 * A = Real.sqrt ((8 * A) ^ 2) by rw [Real.sqrt_sq (by positivity)]]
    apply Real.sqrt_le_sqrt; nlinarith [abs_nonneg (Real.log (2 * B))]
  have hlogB : Real.log (2 * B) ≤ L := le_abs_self _
  rw [hsplit, hlogd]
  have hA4 : A * (4 * Real.sqrt d) ≤ d / 2 := by nlinarith
  have hAL : A * L ≤ d / 2 := by nlinarith [abs_nonneg (Real.log (2 * B)), sq_nonneg A]
  nlinarith [mul_le_mul_of_nonneg_left hlogsqrt hA, mul_le_mul_of_nonneg_left hlogB hA]

/-- Equal-row bound for every density `2d ≤ n` and every small spectral error. -/
theorem low_density_small_error {A B c ε₀ Cm Ch : ℝ} (hA : 0 ≤ A) (hB : 0 < B)
    (hc : 0 < c) (hε₀ : 0 < ε₀) (hCm : 0 ≤ Cm) (hCh : 0 ≤ Ch)
    (Hmany : ManyRowBound B c Ch) (Hmod : ModerateParsevalBound A ε₀ Cm) :
    ∃ C : ℝ, 0 < C ∧ ∀ (n d : ℕ), 0 < d → 2 * d ≤ n →
      ∀ η : ℝ, 0 < η → η ≤ 1 / 2 → EqualRowBound n d η C := by
  obtain ⟨D, hDpos, hD⟩ := exists_log_threshold A B hA hB
  let C : ℝ := (D : ℝ) + Ch + 4 / c + (2 + 4 * Cm) + 16 / ε₀
  have hC : 0 < C := by dsimp [C]; positivity
  refine ⟨C, hC, ?_⟩
  intro n d hd hdn η hη hηhalf X hX hXp
  have hdn' : d ≤ n := by omega
  have hdR : (0 : ℝ) < d := by exact_mod_cast hd
  have hηd : 0 ≤ η * (d : ℝ) := by positivity
  have htriv : ∀ K : ℝ, K ≤ C → 4 ≤ K * η → HasCorrection X (C * η * (d : ℝ)) := by
    intro K hK h4
    apply (equalNorm_hasCorrection_trivial hd hdn' X hX).mono
    have : 4 * (d : ℝ) ≤ K * η * d := by nlinarith
    have : K * η * (d : ℝ) ≤ C * η * d := by
      have := mul_le_mul_of_nonneg_right hK hηd; nlinarith
    linarith
  by_cases hdD : D ≤ d
  · by_cases hmany : B * (d : ℝ) ^ 2 ≤ (n : ℝ)
    · by_cases hηc : η ≤ c
      · apply (Hmany n d hd hdn' hmany η hη hηc X hX hXp).mono
        have : Ch ≤ C := by dsimp [C]; have : (0:ℝ) ≤ D := Nat.cast_nonneg _; nlinarith [div_pos (by norm_num : (0:ℝ) < 16) hε₀, div_pos (by norm_num : (0:ℝ) < 4) hc]
        nlinarith
      · push Not at hηc
        apply htriv (4 / c)
        · dsimp [C]; have : (0:ℝ) ≤ D := Nat.cast_nonneg _; nlinarith [div_pos (by norm_num : (0:ℝ) < 16) hε₀, div_pos (by norm_num : (0:ℝ) < 4) hc]
        · rw [div_mul_eq_mul_div, le_div_iff₀ hc]; nlinarith
    · push Not at hmany
      have hlog : A * Real.log (2 * (n : ℝ)) ≤ (d : ℝ) := by
        refine le_trans ?_ (hD d hdD)
        apply mul_le_mul_of_nonneg_left _ hA
        have hn : (0 : ℝ) < n := by exact_mod_cast (show 0 < n by omega)
        apply Real.log_le_log (by positivity)
        nlinarith
      by_cases hηε : η ≤ ε₀ / 4
      · obtain ⟨U, hU, hUn, hdist⟩ := exists_polar_normalization X η hη.le hηhalf hX hXp
        have hcorr := (Hmod n d hd hdn hlog (2 * η) (by positivity) (by linarith) U hU hUn).transfer hdist
        apply hcorr.mono
        have hq : η ^ 2 * (d : ℝ) ≤ η * d := by nlinarith
        have : 2 + 4 * Cm ≤ C := by
          dsimp [C]; have : (0:ℝ) ≤ D := Nat.cast_nonneg _
          nlinarith [div_pos (by norm_num : (0:ℝ) < 16) hε₀, div_pos (by norm_num : (0:ℝ) < 4) hc]
        nlinarith
      · push Not at hηε
        apply htriv (16 / ε₀)
        · dsimp [C]; have : (0:ℝ) ≤ D := Nat.cast_nonneg _; nlinarith [div_pos (by norm_num : (0:ℝ) < 4) hc]
        · rw [div_mul_eq_mul_div, le_div_iff₀ hε₀]; nlinarith
  · push Not at hdD
    apply (quadratic_equalRowBound n d hd hdn' η hη.le X hX hXp).mono
    have hdD' : (d : ℝ) ≤ D := by exact_mod_cast hdD.le
    have : (d : ℝ) ≤ C := by
      dsimp [C]; nlinarith [div_pos (by norm_num : (0:ℝ) < 16) hε₀, div_pos (by norm_num : (0:ℝ) < 4) hc]
    nlinarith

/-- Small-error equal-row bounds give low-density Parseval bounds for every
positive diagonal error. -/
theorem low_density_parseval_of_equalRow_small (C : ℝ) (hC : 0 ≤ C)
    (H : ∀ n d : ℕ, 0 < d → 2 * d ≤ n → ∀ η : ℝ,
      0 < η → η ≤ 1 / 2 → EqualRowBound n d η C) :
    ∀ n d : ℕ, 0 < d → 2 * d ≤ n → ∀ ε : ℝ, 0 < ε →
      ∀ U : Frame n d, IsParseval U → IsNearlyEqualNorm ε U →
        HasCorrection U ((32 + 8 * C) * ε * (d : ℝ)) := by
  intro n d hd hdn ε hε U hU hUn
  have hdn' : d ≤ n := by omega
  have hn : 0 < n := lt_of_lt_of_le hd hdn'
  have hdR : 0 ≤ (d : ℝ) := Nat.cast_nonneg d
  by_cases hsmall : ε ≤ 1 / 8
  · have hinput : IsNearlyEqualNormParseval ε U := ⟨hU.isNearlyParseval hε.le, hUn⟩
    have hbound := H n d hd hdn (4 * ε) (by positivity) (by linarith)
    apply (correction_of_equalRowBound hd hn U hε.le (by linarith) hinput hbound).mono
    exact mul_le_mul_of_nonneg_right
      (mul_le_mul_of_nonneg_right (by linarith : 2 + 8 * C ≤ 32 + 8 * C) hε.le) hdR
  · apply (parseval_hasCorrection_trivial hn hdn' U hU).mono
    have hlarge : 1 / 8 < ε := lt_of_not_ge hsmall
    have hbase : 2 * (d : ℝ) ≤ 32 * ε * (d : ℝ) := by
      nlinarith [mul_nonneg (show 0 ≤ 16 * ε - 2 by linarith) hdR]
    apply hbase.trans
    exact mul_le_mul_of_nonneg_right
      (mul_le_mul_of_nonneg_right (by linarith : (32 : ℝ) ≤ 32 + 8 * C) hε.le) hdR

/-- Polar normalisation transfers an all-density Parseval bound to all-density
equal-row bounds. -/
theorem all_density_equalRow_of_parseval (C : ℝ) (hC : 0 ≤ C)
    (H : ∀ n d : ℕ, 0 < d → d ≤ n → ∀ ε : ℝ, 0 < ε →
      ∀ U : Frame n d, IsParseval U → IsNearlyEqualNorm ε U →
        HasCorrection U (C * ε * (d : ℝ))) :
    ∀ n d : ℕ, 0 < d → d ≤ n → ∀ η : ℝ, 0 ≤ η →
      EqualRowBound n d η (8 + 4 * C) := by
  intro n d hd hdn η hη
  by_cases hzero : η = 0
  · subst η
    exact equalRowBound_zero n d _
  have hηpos : 0 < η := lt_of_le_of_ne hη (Ne.symm hzero)
  have hdR : 0 ≤ (d : ℝ) := Nat.cast_nonneg d
  intro X hX hXp
  by_cases hsmall : η ≤ 1 / 2
  · obtain ⟨U, hU, hUn, hdist⟩ := exists_polar_normalization X η hη hsmall hX hXp
    have hcorr := (H n d hd hdn (2 * η) (by positivity) U hU hUn).transfer hdist
    apply hcorr.mono
    have hquad : 2 * η ^ 2 ≤ η := by nlinarith
    have hcost : 2 * (η ^ 2 * (d : ℝ)) ≤ η * (d : ℝ) := by
      nlinarith [mul_le_mul_of_nonneg_right hquad hdR]
    have hηd : 0 ≤ η * (d : ℝ) := mul_nonneg hη hdR
    nlinarith
  · apply (equalNorm_hasCorrection_trivial hd hdn X hX).mono
    have hlarge : 1 / 2 < η := lt_of_not_ge hsmall
    have hbase : 4 * (d : ℝ) ≤ 8 * η * (d : ℝ) := by
      nlinarith [mul_nonneg (show 0 ≤ 2 * η - 1 by linarith) hdR]
    apply hbase.trans
    exact mul_le_mul_of_nonneg_right
      (mul_le_mul_of_nonneg_right (by linarith : (8 : ℝ) ≤ 8 + 4 * C) hη) hdR

/-- The linear Paulsen bound from the two seed theorems. -/
theorem sharpPaulsenBound_of_seeds {A B c ε₀ Cm Ch : ℝ} (hA : 0 ≤ A) (hB : 0 < B)
    (hc : 0 < c) (hε₀ : 0 < ε₀) (hCm : 0 ≤ Cm) (hCh : 0 ≤ Ch)
    (Hmany : ManyRowBound B c Ch) (Hmod : ModerateParsevalBound A ε₀ Cm) :
    SharpPaulsenBound := by
  obtain ⟨C, hC, hlow⟩ := low_density_small_error hA hB hc hε₀ hCm hCh Hmany Hmod
  have hlowParseval := low_density_parseval_of_equalRow_small C hC.le hlow
  have hCp : 0 ≤ 32 + 8 * C := by positivity
  have hallParseval := all_density_parseval_bound_of_low_density (32 + 8 * C) hCp
    (fun n d hd hdn ε hε _hεhalf U hU hUn => hlowParseval n d hd hdn ε hε U hU hUn)
  have hCa : 0 ≤ 2 * (32 + 8 * C) + 4 := by positivity
  have hallEqualRow := all_density_equalRow_of_parseval (2 * (32 + 8 * C) + 4) hCa
    hallParseval
  exact sharpPaulsenBound_of_equalRowBounds (8 + 4 * (2 * (32 + 8 * C) + 4))
    (by positivity) hallEqualRow

end Paulsen.Linear
