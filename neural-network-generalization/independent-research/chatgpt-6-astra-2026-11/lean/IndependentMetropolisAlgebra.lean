import Mathlib

/-!
Exact deterministic identities used in the posterior correction papers.
No probability coupling, asymptotic density comparison, or sampler law
is claimed to be formalized by this file.
-/

namespace IndependentResearch

open scoped BigOperators

theorem metropolis_acceptance_balance (u v : ℝ) (hu : 0 < u) (hv : 0 < v) :
    u * min 1 (v / u) = v * min 1 (u / v) := by
  by_cases h : u ≤ v
  · rw [min_eq_left ((one_le_div hu).mpr h),
      min_eq_right ((div_le_one hv).mpr h)]
    field_simp
  · have h' : v ≤ u := le_of_not_ge h
    rw [min_eq_right ((div_le_one hu).mpr h'),
      min_eq_left ((one_le_div hv).mpr h')]
    field_simp

theorem positive_part_one_step_identity (l u : ℝ) :
    l * max (l - u) 0 - u * max (u - l) 0 =
      (max (l - u) 0) ^ 2 - u ^ 2 + l * u := by
  by_cases h : u ≤ l
  · rw [max_eq_left (sub_nonneg.mpr h), max_eq_right (sub_nonpos.mpr h)]
    ring
  · have h' : l ≤ u := le_of_not_ge h
    rw [max_eq_right (sub_nonpos.mpr h'), max_eq_left (sub_nonneg.mpr h')]
    ring

theorem centered_one_step_residual {ι : Type*} [Fintype ι]
    (q L : ι → ℝ) (l : ℝ) (hcenter : ∑ i, q i * L i = 0) :
    l * (∑ i, q i * max (l - L i) 0) -
      (∑ i, q i * L i * max (L i - l) 0) =
    (∑ i, q i * (max (l - L i) 0) ^ 2) - ∑ i, q i * (L i) ^ 2 := by
  have hp : ∀ i, l * (q i * max (l - L i) 0) -
      q i * L i * max (L i - l) 0 =
      q i * (max (l - L i) 0) ^ 2 - q i * (L i) ^ 2 + l * (q i * L i) := by
    intro i
    have h := congrArg (fun x : ℝ => q i * x) (positive_part_one_step_identity l (L i))
    nlinarith [h]
  rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
  simp_rw [hp]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, hcenter]
  ring

theorem positive_part_difference_square (u v : ℝ) :
    (max (u - v) 0) ^ 2 + (max (v - u) 0) ^ 2 = (u - v) ^ 2 := by
  by_cases h : v ≤ u
  · rw [max_eq_left (sub_nonneg.mpr h), max_eq_right (sub_nonpos.mpr h)]
    ring
  · have h' : u ≤ v := le_of_not_ge h
    rw [max_eq_right (sub_nonpos.mpr h'), max_eq_left (sub_nonneg.mpr h')]
    ring

theorem broadened_gaussian_identity (a r e : ℝ) (ha : 1 < a) :
    -(r - e) ^ 2 / 2 + r ^ 2 / (2 * a) =
      e ^ 2 / (2 * (a - 1)) - ((a - 1) * r - a * e) ^ 2 / (2 * a * (a - 1)) := by
  have ha0 : a ≠ 0 := ne_of_gt (lt_trans zero_lt_one ha)
  have ha1 : a - 1 ≠ 0 := ne_of_gt (sub_pos.mpr ha)
  field_simp
  ring

theorem broadened_gaussian_envelope (a r e : ℝ) (ha : 1 < a) :
    -(r - e) ^ 2 / 2 + r ^ 2 / (2 * a) ≤ e ^ 2 / (2 * (a - 1)) := by
  rw [broadened_gaussian_identity a r e ha]
  apply sub_le_self
  apply div_nonneg (sq_nonneg _)
  have : 0 < a := lt_trans zero_lt_one ha
  have : 0 < a - 1 := sub_pos.mpr ha
  positivity

theorem perturbation_negative_denominator_bound (ε l u : ℝ)
    (hl : l ≤ 0) (hu : 0 ≤ 1 + ε * u) (hden : 0 < 1 + ε * l) :
    (l - u) / (1 + ε * l) ≤ -u := by
  apply (div_le_iff₀ hden).mpr
  have h := mul_nonpos_of_nonpos_of_nonneg hl hu
  nlinarith [h]

theorem perturbation_positive_part_kernel_bound (ε l u : ℝ)
    (hε : 0 ≤ ε) (hl : 0 ≤ 1 + ε * l) (hu : 0 < 1 + ε * u) :
    max (u - l) 0 / (1 + ε * u) ≤ max u 0 + max (-l) 0 := by
  by_cases hul : u ≤ l
  · rw [max_eq_right (sub_nonpos.mpr hul), zero_div]
    positivity
  · have hlu : l ≤ u := le_of_lt (lt_of_not_ge hul)
    rw [max_eq_left (sub_nonneg.mpr hlu)]
    by_cases hu0 : 0 ≤ u
    · rw [max_eq_left hu0]
      apply (div_le_iff₀ hu).mpr
      have hm : -l ≤ max (-l) 0 := le_max_left _ _
      have hn : 0 ≤ u + max (-l) 0 := add_nonneg hu0 (le_max_right _ _)
      have hp : 0 ≤ (u + max (-l) 0) * (ε * u) :=
        mul_nonneg hn (mul_nonneg hε hu0)
      nlinarith [hp]
    · have hu0' : u ≤ 0 := le_of_not_ge hu0
      have hl0 : 0 ≤ -l := by linarith
      rw [max_eq_right hu0', max_eq_left hl0, zero_add]
      exact perturbation_negative_denominator_bound ε u l hu0' hl hu

end IndependentResearch
