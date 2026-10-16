import NeuralGeneralization.LearningBudget

/-! # Quantitative conversion of prior tails to posterior tail ratios -/

namespace NeuralGeneralization

/-- At speed at least one, a rate gap of `log(1/τ)` makes the raw tail-to-target
mass ratio at most `τ`. Positivity of the denominator is derived from the
actual positive exponential lower bound. -/
theorem exponential_tail_ratio_le
    (tail mass B K speed τ : ℝ)
    (htail : tail ≤ Real.exp (-K * speed))
    (hmass : Real.exp (-B * speed) ≤ mass)
    (hspeed : 1 ≤ speed) (hτ : 0 < τ) (hτ1 : τ ≤ 1)
    (hgap : B + Real.log (1 / τ) ≤ K) :
    tail / mass ≤ τ := by
  have hmasspos : 0 < mass := (Real.exp_pos _).trans_le hmass
  have hlog : 0 ≤ Real.log (1 / τ) :=
    Real.log_nonneg ((one_le_div hτ).mpr hτ1)
  have hrate : Real.log (1 / τ) ≤ (K - B) * speed := by
    have hKB : 0 ≤ K - B := by linarith
    have hmono := mul_le_mul_of_nonneg_left hspeed hKB
    linarith
  have hneg : -K * speed ≤ -Real.log (1 / τ) + -B * speed := by linarith
  have hexp : Real.exp (-K * speed) ≤ τ * Real.exp (-B * speed) := by
    calc
      _ ≤ Real.exp (-Real.log (1 / τ) + -B * speed) := Real.exp_le_exp.mpr hneg
      _ = τ * Real.exp (-B * speed) := by
        rw [Real.exp_add, Real.exp_neg, Real.exp_log (one_div_pos.mpr hτ)]
        simp
  apply (div_le_iff₀ hmasspos).mpr
  exact htail.trans (hexp.trans (mul_le_mul_of_nonneg_left hmass hτ.le))

/-- The same actual tail comparison with a fixed union-bound prefactor. The
factor is paid in the rate gap, so no width-dependent logarithm is introduced. -/
theorem exponential_tail_ratio_prefactor_le
    (tail mass prefactor B K speed τ : ℝ)
    (htail : tail ≤ prefactor * Real.exp (-K * speed))
    (hmass : Real.exp (-B * speed) ≤ mass)
    (hprefactor : 1 ≤ prefactor) (hspeed : 1 ≤ speed)
    (hτ : 0 < τ) (hτ1 : τ ≤ 1)
    (hgap : B + Real.log (prefactor / τ) ≤ K) :
    tail / mass ≤ τ := by
  have hmasspos : 0 < mass := (Real.exp_pos _).trans_le hmass
  have hp : 0 < prefactor := zero_lt_one.trans_le hprefactor
  have hlog : 0 ≤ Real.log (prefactor / τ) :=
    Real.log_nonneg ((one_le_div hτ).mpr (hτ1.trans hprefactor))
  have hrate : Real.log (prefactor / τ) ≤ (K - B) * speed := by
    have hKB : 0 ≤ K - B := by linarith
    have hmono := mul_le_mul_of_nonneg_left hspeed hKB
    linarith
  have hneg : -K * speed ≤ -Real.log (prefactor / τ) + -B * speed := by
    linarith
  have hexp : prefactor * Real.exp (-K * speed) ≤ τ * Real.exp (-B * speed) := by
    calc
      _ ≤ prefactor * Real.exp (-Real.log (prefactor / τ) + -B * speed) :=
        mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr hneg) hp.le
      _ = τ * Real.exp (-B * speed) := by
        rw [Real.exp_add, Real.exp_neg, Real.exp_log (div_pos hp hτ)]
        field_simp
  apply (div_le_iff₀ hmasspos).mpr
  exact htail.trans (hexp.trans (mul_le_mul_of_nonneg_left hmass hτ.le))

end NeuralGeneralization
