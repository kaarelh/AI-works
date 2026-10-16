import NeuralGeneralization.WeightedFiniteChaining

/-! Explicit entropy budgets for finite doubly exponential chaining trees. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.GrowthPath

def chainingWeight (h : ℕ) : ℝ := 8 * 2 ^ h

theorem chainingWeight_pos (h : ℕ) : 0 < chainingWeight h := by
  unfold chainingWeight
  positivity

theorem chainingWeight_sq (h : ℕ) : chainingWeight h ^ 2 = 64 * 4 ^ h := by
  unfold chainingWeight
  rw [mul_pow, ← pow_mul, Nat.mul_comm h 2, pow_mul]
  norm_num

theorem entropy_term_le {C p : ℝ} (hp : 0 < p)
    (hC : C ≤ Real.exp (p ^ 2 / 4)) :
    C * (2 * Real.exp (-(p ^ 2) / 2) / p ^ 2) ≤ 2 / p ^ 2 := by
  have ht : 0 ≤ 2 * Real.exp (-(p ^ 2) / 2) / p ^ 2 := by positivity
  calc
    _ ≤ Real.exp (p ^ 2 / 4) * (2 * Real.exp (-(p ^ 2) / 2) / p ^ 2) :=
      mul_le_mul_of_nonneg_right hC ht
    _ = 2 * Real.exp (-(p ^ 2) / 4) / p ^ 2 := by
      rw [show p ^ 2 / 4 = p ^ 2 / 4 from rfl]
      have he := Real.exp_add (p ^ 2 / 4) (-(p ^ 2) / 2)
      have hexp : Real.exp (p ^ 2 / 4) * Real.exp (-(p ^ 2) / 2) =
          Real.exp (-(p ^ 2) / 4) := by
        rw [← he]
        congr 1
        ring
      calc
        _ = 2 * (Real.exp (p ^ 2 / 4) * Real.exp (-(p ^ 2) / 2)) / p ^ 2 := by ring
        _ = _ := by rw [hexp]
    _ ≤ 2 / p ^ 2 := by
      apply div_le_div_of_nonneg_right _ (sq_nonneg p)
      have he : Real.exp (-(p ^ 2) / 4) ≤ 1 := Real.exp_le_one_iff.mpr (by nlinarith [sq_nonneg p])
      linarith

theorem entropy_reciprocal (h : ℕ) :
    2 / chainingWeight h ^ 2 = (1 : ℝ) / 32 * (1 / 4) ^ h := by
  rw [chainingWeight_sq, div_pow]
  simp only [one_pow]
  field_simp
  <;> ring

theorem geometric_quarter_sum_le (L : ℕ) :
    (∑ h ∈ Finset.range L, ((1 : ℝ) / 4) ^ h) ≤ 4 / 3 := by
  have hh := geom_sum_mul_neg ((1 : ℝ) / 4) L
  have hp : 0 ≤ ((1 : ℝ) / 4) ^ L := by positivity
  nlinarith

/-- The complete entropy correction is at most 1/24, uniformly in the
number of levels. No infinite summation or asymptotic notation is used. -/
theorem chaining_entropy_budget (C : ℕ → ℝ) (L : ℕ)
    (hC : ∀ h < L, C h ≤ Real.exp (16 * (4 : ℝ) ^ h)) :
    (∑ h ∈ Finset.range L,
      C h * (2 * Real.exp (-(chainingWeight h ^ 2) / 2) / chainingWeight h ^ 2)) ≤ 1 / 24 := by
  calc
    _ ≤ ∑ h ∈ Finset.range L, 2 / chainingWeight h ^ 2 := by
      apply Finset.sum_le_sum
      intro h hh
      apply entropy_term_le (chainingWeight_pos h)
      simpa only [chainingWeight_sq, mul_div_assoc, show (64 : ℝ) / 4 = 16 by norm_num,
        show ∀ x : ℝ, 64 * x / 4 = 16 * x by intro x; ring] using hC h (Finset.mem_range.mp hh)
    _ = (1 : ℝ) / 32 * ∑ h ∈ Finset.range L, (1 / 4) ^ h := by
      simp_rw [entropy_reciprocal]
      rw [Finset.mul_sum]
    _ ≤ 1 / 24 := by
      have hh := geometric_quarter_sum_le L
      linarith

/-- An elementary conversion of a power-of-two cardinality bound into
the exponential bound used by the Rademacher maximal inequality. -/
theorem two_pow_le_exp (n : ℕ) : (2 : ℝ) ^ n ≤ Real.exp n := by
  have htwo : (2 : ℝ) ≤ Real.exp 1 := by linarith [Real.add_one_le_exp (1 : ℝ)]
  have hp := pow_le_pow_left₀ (by norm_num : (0 : ℝ) ≤ 2) htwo n
  simpa only [← Real.exp_nat_mul, mul_one] using hp

end NeuralGeneralization.GrowthPath
