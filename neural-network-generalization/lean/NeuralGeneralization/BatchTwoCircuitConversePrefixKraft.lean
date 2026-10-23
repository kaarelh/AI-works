import NeuralGeneralization.BatchTwoCircuitConversePrefixLanguage

/-!
# A direct Kraft bound for the explicit exception language

The bound is proved by counting legal NAND addresses and exception chains, rather
than postulating a prefix-code inequality.
-/

namespace NeuralGeneralization.BatchTwoCircuitConverse.Prefix

open scoped ENNReal BigOperators
noncomputable section
open Classical

@[simp] theorem card_patch (d : ℕ) : Fintype.card (Patch d) = 2^(d+1) := by
  simp [Patch, Input, Fintype.card_prod, Fintype.card_fun, pow_succ]

theorem base_kraft_level_le (d n : ℕ) :
    (Fintype.card (Gates d n) : ℝ≥0∞) * (2⁻¹ : ℝ≥0∞)^(baseLength d n) ≤
      (2⁻¹ : ℝ≥0∞)^(n+2) := by
  have hc : (Fintype.card (Gates d n) : ℝ≥0∞) ≤ 2^(2*addressBits d n) := by
    exact_mod_cast card_gates_le_address_space d n
  have hl : (2⁻¹ : ℝ≥0∞)^(baseLength d n) ≤
      (2⁻¹ : ℝ≥0∞)^(n+2+2*addressBits d n) :=
    pow_le_pow_of_le_one zero_le (by norm_num) (baseLength_ge d n)
  calc
    (Fintype.card (Gates d n) : ℝ≥0∞) * (2⁻¹ : ℝ≥0∞)^(baseLength d n) ≤
      (2 : ℝ≥0∞)^(2*addressBits d n) * (2⁻¹ : ℝ≥0∞)^(n+2+2*addressBits d n) :=
      mul_le_mul' hc hl
    _ = (2⁻¹ : ℝ≥0∞)^(n+2) := by
      rw [pow_add]
      rw [show (2:ℝ≥0∞)^(2*addressBits d n) *
          ((2⁻¹:ℝ≥0∞)^(n+2) * (2⁻¹:ℝ≥0∞)^(2*addressBits d n)) =
          ((2:ℝ≥0∞)^(2*addressBits d n) * (2⁻¹:ℝ≥0∞)^(2*addressBits d n)) *
            (2⁻¹:ℝ≥0∞)^(n+2) by ac_rfl]
      rw [← ENNReal.inv_pow, ENNReal.mul_inv_cancel (by positivity) (by finiteness), one_mul]

theorem base_kraft_le (d : ℕ) :
    (∑' c : Circuit d, (2⁻¹ : ℝ≥0∞)^(baseLength d c.size)) ≤ (2⁻¹ : ℝ≥0∞) := by
  rw [← (Circuit.equivSigma d).symm.tsum_eq]
  change (∑' c : (n:ℕ) × Gates d n, (2⁻¹ : ℝ≥0∞)^(baseLength d c.1)) ≤ _
  rw [ENNReal.tsum_sigma (fun n (_ : Gates d n) => (2⁻¹ : ℝ≥0∞)^(baseLength d n))]
  simp only [tsum_fintype, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  calc
    (∑' n : ℕ, (Fintype.card (Gates d n) : ℝ≥0∞) * (2⁻¹ : ℝ≥0∞)^(baseLength d n)) ≤
        ∑' n : ℕ, (2⁻¹ : ℝ≥0∞)^(n+2) := ENNReal.tsum_le_tsum (base_kraft_level_le d)
    _ = (2⁻¹ : ℝ≥0∞) := by
      simp_rw [show ∀ n:ℕ, n+2 = (n+1)+1 by omega]
      simp only [pow_add (2⁻¹ : ℝ≥0∞) (_+1) 1, pow_one]
      rw [ENNReal.tsum_mul_right, ENNReal.tsum_geometric_add_one,
        ENNReal.one_sub_inv_two, inv_inv,
        ENNReal.inv_mul_cancel (by norm_num) (by norm_num), one_mul]

theorem program_kraft_decomposition (d : ℕ) (a : ℝ≥0∞) :
    (∑' p : Program d, a^p.length) =
      (∑' n:ℕ, ((Fintype.card (Patch d) : ℝ≥0∞)^n * a^(n*(d+2)))) *
      (∑' c : Circuit d, a^(baseLength d c.size)) := by
  change (∑' p : (n:ℕ) × (Fin n → Patch d) × Circuit d,
    a^(baseLength d p.2.2.size + p.1*(d+2))) = _
  rw [ENNReal.tsum_sigma (fun n (p : (Fin n → Patch d) × Circuit d) =>
    a^(baseLength d p.2.size + n*(d+2)))]
  have hlevel : ∀ n, (∑' p : (Fin n → Patch d) × Circuit d,
      a^(baseLength d p.2.size + n*(d+2))) =
      ((Fintype.card (Patch d) : ℝ≥0∞)^n * a^(n*(d+2))) *
      (∑' c : Circuit d, a^(baseLength d c.size)) := by
    intro n
    rw [ENNReal.tsum_prod (f := fun (_ : Fin n → Patch d) (c : Circuit d) =>
      a^(baseLength d c.size + n*(d+2)))]
    simp only [tsum_fintype]
    simp_rw [pow_add]
    rw [show (fun (_ : Fin n → Patch d) =>
      ∑' c : Circuit d, a^(baseLength d c.size) * a^(n*(d+2))) =
      fun _ => (∑' c : Circuit d, a^(baseLength d c.size)) * a^(n*(d+2)) by
        funext p; exact ENNReal.tsum_mul_right]
    simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul,
      Fintype.card_fun, Fintype.card_fin, Nat.cast_pow]
    ac_rfl
  simp_rw [hlevel]
  exact ENNReal.tsum_mul_right

theorem exception_kraft_factor (d n : ℕ) :
    (Fintype.card (Patch d) : ℝ≥0∞)^n * (2⁻¹ : ℝ≥0∞)^(n*(d+2)) =
      (2⁻¹ : ℝ≥0∞)^n := by
  rw [card_patch, Nat.cast_pow, Nat.cast_ofNat, Nat.mul_comm n (d+2), pow_mul, ← mul_pow]
  congr 1
  rw [show d+2 = (d+1)+1 by omega, pow_add (2⁻¹ : ℝ≥0∞) (d+1) 1, pow_one]
  rw [← mul_assoc, ← ENNReal.inv_pow,
    ENNReal.mul_inv_cancel (by positivity) (by finiteness), one_mul]

/-- Kraft's inequality for the paper's precise program syntax and bit lengths. -/
theorem program_kraft_le_one (d : ℕ) :
    (∑' p : Program d, (2⁻¹ : ℝ≥0∞)^p.length) ≤ 1 := by
  rw [program_kraft_decomposition]
  simp_rw [exception_kraft_factor]
  rw [ENNReal.tsum_geometric_two]
  calc
    2 * (∑' c : Circuit d, (2⁻¹ : ℝ≥0∞)^(baseLength d c.size)) ≤
        2 * (2⁻¹ : ℝ≥0∞) := mul_le_mul_right (base_kraft_le d) _
    _ = 1 := ENNReal.mul_inv_cancel (by norm_num) (by norm_num)

end
end NeuralGeneralization.BatchTwoCircuitConverse.Prefix
