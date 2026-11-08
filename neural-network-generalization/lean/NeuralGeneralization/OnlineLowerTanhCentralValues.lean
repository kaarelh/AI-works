import NeuralGeneralization.OnlineLowerTanhBiasCandidates
import NeuralGeneralization.OnlineLowerTanhBiasPeakLoss

/-! # Exact central values and their uniform normalized positive lower bound -/
noncomputable section
open scoped BigOperators Topology Classical
namespace NeuralGeneralization.OnlineLowerTanh

lemma odd_central_abs_eq_balancedParity (r : ℕ) {a : ℝ} (ha : 1 ≤ a) :
    |parityCorrelation (fun _ : Fin (2*r+1) => a) 0| = balancedParity r a := by
  have hp := balancedParity_pos_of_one_le r a ha
  calc
    _ = |balancedParity r a| := by
      simp only [balancedParity, abs_mul, abs_pow, abs_neg, abs_one, one_pow, one_mul]
    _ = _ := abs_of_pos hp

lemma even_central_signed_eq_balancedParity (r : ℕ) (a : ℝ) :
    (-1 : ℝ)^r*parityCorrelation (fun _ : Fin (2*r) => a) a = balancedParity r a := by
  have hh := signed_even_bulk_peak_exact r 0 a
  have hm : balancedPolynomialMoment r a (1 : Polynomial ℝ)=balancedParity r a := by
    have hs : (1 : Polynomial ℝ).support = {0} := by
      simpa using (Polynomial.support_C (show (1 : ℝ) ≠ 0 by norm_num))
    simp only [balancedPolynomialMoment, hs, Finset.sum_singleton,
      Polynomial.coeff_one_zero, one_mul, Nat.add_zero]
  simpa only [Nat.add_zero, Nat.cast_zero, mul_zero, zero_add, one_mul,
    evenBiasPeakPolynomial_zero, hm] using hh

lemma even_central_abs_eq_balancedParity (r : ℕ) {a : ℝ} (ha : 1 ≤ a) :
    |parityCorrelation (fun _ : Fin (2*r) => a) a| = balancedParity r a := by
  have hh := congrArg abs (even_central_signed_eq_balancedParity r a)
  simpa only [abs_mul, abs_pow, abs_neg, abs_one, one_pow, one_mul,
    abs_of_pos (balancedParity_pos_of_one_le r a ha)] using hh

/-- The actual central candidates have a uniformly positive normalized
coefficient for all sufficiently large degrees and all gains in `[1,2]`. -/
theorem equalBulk_central_normalized_lower :
    ∃ α : ℝ, 0 < α ∧ ∃ N₀ : ℕ, 0 < N₀ ∧ ∀ n : ℕ, N₀ ≤ n →
      ∀ a : ℝ, 1 ≤ a → a ≤ 2 →
      α ≤ Real.sqrt (n : ℝ)*
        |parityCorrelation (fun _ : Fin n => a) (bulkCentralBias n a)| := by
  let α := Real.sqrt (2/Real.pi)/4
  have hα : 0 < α := by dsimp [α]; positivity [gaussianLeadingScale_pos]
  obtain ⟨N₁, hN₁, herr⟩ := balanced_global_error_uniform
  obtain ⟨N₂, hN₂⟩ := exists_nat_gt ((3*balancedGlobalConstant+1)/α)
  refine ⟨α, hα, max N₁ N₂, lt_of_lt_of_le hN₁ (le_max_left _ _), ?_⟩
  intro n hn a ha ha2
  have hn1 := le_trans (le_max_left N₁ N₂) hn
  have hn2 := le_trans (le_max_right N₁ N₂) hn
  have hn0 : 0 < n := lt_of_lt_of_le hN₁ hn1
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn0
  have hnn : (N₂ : ℝ) ≤ n := by exact_mod_cast hn2
  have hsmall : (3*balancedGlobalConstant+1)/(n : ℝ) ≤ α := by
    apply (div_le_iff₀ hnR).mpr
    have hh := (div_lt_iff₀ hα).mp (lt_of_lt_of_le hN₂ hnn)
    linarith
  have hb := balanced_central_lower hn0 ha ha2 balancedGlobalConstant_pos.le (herr n hn1 a ha ha2)
  have hA := (bulkAmplitude_bounds a ha).1
  dsimp [α] at *
  linarith

/-- The same positive lower bound applies to the odd reference coefficient
used by either parity of bulk degree. -/
theorem equalBulk_reference_normalized_lower :
    ∃ α : ℝ, 0 < α ∧ ∃ N₀ : ℕ, 0 < N₀ ∧ ∀ r : ℕ, N₀ ≤ 2*r →
      ∀ a : ℝ, 1 ≤ a → a ≤ 2 →
      α ≤ Real.sqrt ((2*r : ℕ) : ℝ)*balancedParity r a ∧
      α ≤ Real.sqrt ((2*r+1 : ℕ) : ℝ)*balancedParity r a := by
  obtain ⟨α, hα, N₀, hN₀, hlo⟩ := equalBulk_central_normalized_lower
  refine ⟨α, hα, N₀, hN₀, ?_⟩
  intro r hr a ha ha2
  have he := hlo (2*r) hr a ha ha2
  have ho := hlo (2*r+1) (by omega) a ha ha2
  have hbe : bulkCentralBias (2*r) a = a := by simp [bulkCentralBias]
  have hbo : bulkCentralBias (2*r+1) a = 0 := by simp [bulkCentralBias]
  rw [hbe, even_central_abs_eq_balancedParity r ha] at he
  rw [hbo, odd_central_abs_eq_balancedParity r ha] at ho
  exact ⟨he, ho⟩

end NeuralGeneralization.OnlineLowerTanh
