import NeuralGeneralization.NeuralKernelSpectrum
import NeuralGeneralization.KernelWalk

/-!
# A direct first-layer spectral tail bound

The coefficient tail is controlled by a telescoping Wallis recurrence.
The power spectrum is supported at degrees at most the power. Together
these prove a uniform high-degree trace bound for the actual first
arcsine covariance, without a singularity-transfer theorem.
-/

noncomputable section

namespace NeuralGeneralization

open Filter
open scoped BigOperators Topology

/-- The positive arcsine coefficients are bounded by a telescoping
multiple of the derivative coefficients. -/
theorem arcsineCoefficient_le_difference (n : ℕ) :
    arcsineCoefficient n ≤
      2 * (arcsineDerivativeCoefficient n - arcsineDerivativeCoefficient (n + 1)) := by
  have hr := arcsineDerivativeCoefficient_recurrence n
  calc
    arcsineCoefficient n ≤ arcsineDerivativeCoefficient n / (n + 1 : ℝ) :=
      div_le_div_of_nonneg_left (arcsineDerivativeCoefficient_pos n).le
        (by positivity) (by nlinarith [Nat.cast_nonneg (α := ℝ) n])
    _ = 2 * (arcsineDerivativeCoefficient n - arcsineDerivativeCoefficient (n + 1)) := by
      apply (div_eq_iff (by positivity : (n + 1 : ℝ) ≠ 0)).mpr
      nlinarith only [hr]

/-- A finite tail estimate, uniform in its upper endpoint. -/
theorem arcsineCoefficient_tail_partial (r N : ℕ) :
    (∑ n ∈ Finset.range N, if r ≤ n then arcsineCoefficient n else 0) ≤
      2 * arcsineDerivativeCoefficient r := by
  have htel (N : ℕ) :
      (∑ n ∈ Finset.range N, if r ≤ n then arcsineCoefficient n else 0) ≤
        2 * (arcsineDerivativeCoefficient r - arcsineDerivativeCoefficient (max r N)) := by
    induction N with
    | zero => simp
    | succ N ih =>
      rw [Finset.sum_range_succ]
      by_cases h : r ≤ N
      · rw [if_pos h, max_eq_right (show r ≤ N + 1 by omega)]
        rw [max_eq_right h] at ih
        have hd := arcsineCoefficient_le_difference N
        linarith
      · rw [if_neg h, max_eq_left (show N + 1 ≤ r by omega), add_zero]
        rw [max_eq_left (show N ≤ r by omega)] at ih
        exact ih
  have h := htel N
  have hp := arcsineDerivativeCoefficient_pos (max r N)
  linarith

/-- The normalized link has the corresponding scalar coefficient tail. -/
theorem arcsineLinkCoefficient_tail_partial (r N : ℕ) :
    (∑ n ∈ Finset.range N, if r ≤ n then arcsineLinkCoefficient n else 0) ≤
      (4 / Real.pi) * arcsineDerivativeCoefficient r := by
  have hsum : (∑ n ∈ Finset.range N, if r ≤ n then arcsineLinkCoefficient n else 0) =
      (2 / Real.pi) * ∑ n ∈ Finset.range N, if r ≤ n then arcsineCoefficient n else 0 := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro n hn
    by_cases h : r ≤ n <;> simp [h, arcsineLinkCoefficient]
  rw [hsum]
  have h := mul_le_mul_of_nonneg_left (arcsineCoefficient_tail_partial r N)
    (div_pos (by norm_num : (0 : ℝ) < 2) Real.pi_pos).le
  calc
    _ ≤ (2 / Real.pi) * (2 * arcsineDerivativeCoefficient r) := h
    _ = _ := by ring

/-- Sum of normalized eigenvalues in Walsh degrees at least `r`. -/
def walshSpectralTail {d : ℕ} (P : ClippingCube d → ℝ) (r : ℕ) : ℝ :=
  ∑ S ∈ (Finset.univ.filter (fun S : Finset (Fin d) => r ≤ S.card)),
    walshCoefficients P S

theorem biasedDot_power_tail_le {d : ℕ} (r m : ℕ) :
    walshSpectralTail (biasedProfile (d := d) (fun t => t ^ m)) r ≤
      if r ≤ m then 1 else 0 := by
  classical
  unfold walshSpectralTail
  by_cases h : r ≤ m
  · rw [if_pos h]
    rw [← biasedDot_power_coefficient_sum (d := d) m]
    exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _)
      (fun S hS hnot => biasedDot_power_coefficient_nonneg m S)
  · rw [if_neg h]
    have hzero : (∑ S ∈ (Finset.univ.filter (fun S : Finset (Fin d) => r ≤ S.card)),
        walshCoefficients (biasedProfile (fun t => t ^ m)) S) = 0 := by
      apply Finset.sum_eq_zero
      intro S hS
      exact biasedDot_power_coefficient_zero m S (by
        have hcard := (Finset.mem_filter.mp hS).2
        omega)
    exact hzero.le

/-- The actual first arcsine layer has high-degree trace of order at most
`r^(-1/2)`, uniformly in the cube dimension. -/
theorem first_arcsine_spectral_tail (d r : ℕ) :
    walshSpectralTail (arcsineProfile d 1) (2 * r) ≤
      (4 / Real.pi) * arcsineDerivativeCoefficient r := by
  classical
  let A := Finset.univ.filter (fun S : Finset (Fin d) => 2 * r ≤ S.card)
  have hlim := tendsto_finsetSum A (fun S hS =>
    walshCoefficients_tendsto
      (fun N x => ∑ n ∈ Finset.range N,
        arcsineLinkCoefficient n * arcsineProfile d 0 x ^ (2 * n + 1))
      (arcsineProfile d 1) (arcsineProfile_series d 0) S)
  apply le_of_tendsto hlim
  apply Eventually.of_forall
  intro N
  have hexpand : (∑ S ∈ A, walshCoefficients
      (fun x => ∑ n ∈ Finset.range N,
        arcsineLinkCoefficient n * arcsineProfile d 0 x ^ (2 * n + 1)) S) =
      ∑ n ∈ Finset.range N, arcsineLinkCoefficient n *
        walshSpectralTail (biasedProfile (d := d) (fun t => t ^ (2 * n + 1))) (2 * r) := by
    simp_rw [walshCoefficients_finite_sum]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro n hn
    unfold walshSpectralTail
    rw [Finset.mul_sum]
    rfl
  rw [hexpand]
  calc
    _ ≤ ∑ n ∈ Finset.range N, if r ≤ n then arcsineLinkCoefficient n else 0 := by
      apply Finset.sum_le_sum
      intro n hn
      have h := mul_le_mul_of_nonneg_left
        (biasedDot_power_tail_le (d := d) (2 * r) (2 * n + 1))
        (arcsineLinkCoefficient_pos n).le
      have he : (2 * r ≤ 2 * n + 1) ↔ r ≤ n := by omega
      simpa only [he, mul_ite, mul_one, mul_zero] using h
    _ ≤ _ := arcsineLinkCoefficient_tail_partial r N

/-- A square-root-free explicit rate for the actual first-layer trace tail. -/
theorem first_arcsine_spectral_tail_square (d r : ℕ) :
    (3 * r + 1 : ℝ) * walshSpectralTail (arcsineProfile d 1) (2 * r) ^ 2 ≤
      (4 / Real.pi) ^ 2 := by
  classical
  have htail : 0 ≤ walshSpectralTail (arcsineProfile d 1) (2 * r) :=
    Finset.sum_nonneg (fun S hS => (first_arcsine_coefficient_pos d S).le)
  have hupper := first_arcsine_spectral_tail d r
  have hright : 0 ≤ (4 / Real.pi) * arcsineDerivativeCoefficient r := by
    exact mul_nonneg (div_pos (by norm_num) Real.pi_pos).le
      (arcsineDerivativeCoefficient_pos r).le
  have hsq := (sq_le_sq₀ htail hright).mpr hupper
  calc
    _ ≤ (3 * r + 1 : ℝ) * ((4 / Real.pi) * arcsineDerivativeCoefficient r) ^ 2 :=
      mul_le_mul_of_nonneg_left hsq (by positivity)
    _ = (4 / Real.pi) ^ 2 * ((3 * r + 1 : ℝ) * arcsineDerivativeCoefficient r ^ 2) := by ring
    _ ≤ (4 / Real.pi) ^ 2 * 1 :=
      mul_le_mul_of_nonneg_left (arcsineDerivativeCoefficient_square_upper r) (sq_nonneg _)
    _ = _ := mul_one _

end NeuralGeneralization
