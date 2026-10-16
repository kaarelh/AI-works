import NeuralGeneralization.KernelPowerSeries

/-!
# Spectral positivity under nonnegative scalar power series

This module works directly with the finite cube kernel. Tensor features prove
that every natural power preserves nonnegative Walsh coefficients. Passing
through the scalar series then preserves each existing coefficient at least by
the linear coefficient. This avoids assuming a composed scalar power series.
-/

noncomputable section

namespace NeuralGeneralization

open Filter
open scoped BigOperators Topology

variable {d : ℕ}

/-- The tensor feature associated with a sequence of Walsh characters. -/
def walshTensorFeature (m : ℕ) (p : Fin m → Finset (Fin d))
    (x : ClippingCube d) : ℝ := ∏ i, walshCharacter (p i) x

def walshTensorWeight (w : Finset (Fin d) → ℝ) (m : ℕ)
    (p : Fin m → Finset (Fin d)) : ℝ := ∏ i, w (p i)

/-- Exact tensor expansion; no square roots of coefficients are needed. -/
theorem walshKernel_power_featureKernel (w : Finset (Fin d) → ℝ)
    (m : ℕ) (x y : ClippingCube d) :
    walshKernel w x y ^ m =
      featureKernel (walshTensorFeature m) (walshTensorWeight w m) x y := by
  unfold walshKernel featureKernel
  rw [Fintype.sum_pow]
  apply Finset.sum_congr rfl
  intro p _
  simp only [walshTensorFeature, walshTensorWeight, Finset.prod_mul_distrib]

theorem walshKernel_power_positiveSemidefinite
    (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S) (m : ℕ)
    (b : ClippingCube d → ℝ) :
    0 ≤ finiteQuadratic (fun x y => walshKernel w x y ^ m) b := by
  simp_rw [walshKernel_power_featureKernel]
  exact featureKernel_positiveSemidefinite (walshTensorFeature m)
    (walshTensorWeight w m)
    (fun p => Finset.prod_nonneg fun i _ => hw (p i)) id b

/-- Walsh reconstruction of the translation-invariant kernel of any profile. -/
theorem profile_product_walshKernel (P : ClippingCube d → ℝ)
    (x y : ClippingCube d) :
    P (cubeProduct x y) = walshKernel (walshCoefficients P) x y := by
  rw [← walshExpansion_coefficients P (cubeProduct x y)]
  unfold walshExpansion walshKernel featureKernel
  simp_rw [walshCharacter_product]
  apply Finset.sum_congr rfl
  intro S _
  ring

/-- Natural powers preserve nonnegative spectral coefficients. -/
theorem profile_power_coefficient_nonneg (P : ClippingCube d → ℝ)
    (hP : ∀ S, 0 ≤ walshCoefficients P S) (m : ℕ) (S : Finset (Fin d)) :
    0 ≤ walshCoefficients (fun x => P x ^ m) S := by
  have h := walshKernel_power_positiveSemidefinite (walshCoefficients P) hP m
    (walshCharacter S)
  have hkernel : (fun x y => walshKernel (walshCoefficients P) x y ^ m) =
      walshKernel (walshCoefficients (fun x => P x ^ m)) := by
    funext x y
    rw [← profile_product_walshKernel, ← profile_product_walshKernel]
  rw [hkernel, walshKernel_character_quadratic] at h
  have hM : 0 < (Fintype.card (ClippingCube d) : ℝ) ^ 2 :=
    sq_pos_of_pos (Nat.cast_pos.mpr Fintype.card_pos)
  apply (mul_le_mul_iff_left₀ hM).mp
  simpa only [zero_mul, mul_comm] using h

/-- Any selected term of a nonnegative scalar series supplies a lower bound
for every resulting spectral coefficient. This includes higher odd terms in
the first arcsine layer. -/
theorem profile_series_coefficient_term_lower
    (P Q : ClippingCube d → ℝ) (c : ℕ → ℝ) (e : ℕ → ℕ)
    (hP : ∀ S, 0 ≤ walshCoefficients P S) (hc : ∀ n, 0 ≤ c n)
    (hseries : ∀ x, Tendsto (fun N => ∑ n ∈ Finset.range N, c n * P x ^ e n)
      atTop (𝓝 (Q x))) (j : ℕ) (S : Finset (Fin d)) :
    c j * walshCoefficients (fun x => P x ^ e j) S ≤ walshCoefficients Q S := by
  have hlim := walshCoefficients_tendsto
    (fun N x => ∑ n ∈ Finset.range N, c n * P x ^ e n) Q hseries S
  apply ge_of_tendsto hlim
  apply (eventually_ge_atTop (j + 1)).mono
  intro N hN
  rw [walshCoefficients_finite_sum]
  exact Finset.single_le_sum (s := Finset.range N)
    (f := fun n => c n * walshCoefficients (fun x => P x ^ e n) S)
    (fun n _ => mul_nonneg (hc n) (profile_power_coefficient_nonneg P hP (e n) S))
    (Finset.mem_range.mpr (show j < N from hN))

/-- Each coefficient after scalar composition is at least its old value times
the scalar series' linear coefficient. Only series convergence on the actual
finite profile range is assumed. -/
theorem profile_series_coefficient_lower
    (P Q : ClippingCube d → ℝ) (c : ℕ → ℝ) (e : ℕ → ℕ)
    (hP : ∀ S, 0 ≤ walshCoefficients P S) (hc : ∀ n, 0 ≤ c n)
    (he : e 0 = 1)
    (hseries : ∀ x, Tendsto (fun N => ∑ n ∈ Finset.range N, c n * P x ^ e n)
      atTop (𝓝 (Q x))) (S : Finset (Fin d)) :
    c 0 * walshCoefficients P S ≤ walshCoefficients Q S := by
  have hlim := walshCoefficients_tendsto
    (fun N x => ∑ n ∈ Finset.range N, c n * P x ^ e n) Q hseries S
  apply ge_of_tendsto hlim
  apply (eventually_ge_atTop 1).mono
  intro N hN
  rw [walshCoefficients_finite_sum]
  have hsingle := Finset.single_le_sum (s := Finset.range N)
    (f := fun n => c n * walshCoefficients (fun x => P x ^ e n) S)
    (fun n _ => mul_nonneg (hc n) (profile_power_coefficient_nonneg P hP (e n) S))
    (Finset.mem_range.mpr (show 0 < N from hN))
  simpa only [he, pow_one] using hsingle

/-- Nonnegative spectra are preserved by the same composition. -/
theorem profile_series_coefficient_nonneg
    (P Q : ClippingCube d → ℝ) (c : ℕ → ℝ) (e : ℕ → ℕ)
    (hP : ∀ S, 0 ≤ walshCoefficients P S) (hc : ∀ n, 0 ≤ c n)
    (he : e 0 = 1)
    (hseries : ∀ x, Tendsto (fun N => ∑ n ∈ Finset.range N, c n * P x ^ e n)
      atTop (𝓝 (Q x))) (S : Finset (Fin d)) :
    0 ≤ walshCoefficients Q S :=
  (mul_nonneg (hc 0) (hP S)).trans
    (profile_series_coefficient_lower P Q c e hP hc he hseries S)

/-- Iterating the scalar map retains the first layer's positive spectrum with
an explicit geometric lower factor. The profile sequence can be the actual
neural depth recurrence. -/
theorem iterated_profile_coefficient_lower
    (P : ℕ → ClippingCube d → ℝ) (c : ℕ → ℝ) (e : ℕ → ℕ)
    (hP : ∀ S, 0 ≤ walshCoefficients (P 0) S) (hc : ∀ n, 0 ≤ c n)
    (he : e 0 = 1)
    (hseries : ∀ k x, Tendsto
      (fun N => ∑ n ∈ Finset.range N, c n * P k x ^ e n)
      atTop (𝓝 (P (k + 1) x))) (k : ℕ) (S : Finset (Fin d)) :
    c 0 ^ k * walshCoefficients (P 0) S ≤ walshCoefficients (P k) S := by
  have hnonneg : ∀ k S, 0 ≤ walshCoefficients (P k) S := by
    intro k
    induction k with
    | zero => exact hP
    | succ k ih => exact fun S =>
        profile_series_coefficient_nonneg (P k) (P (k + 1)) c e ih hc he (hseries k) S
  induction k with
  | zero => simp
  | succ k ih =>
    calc
      c 0 ^ (k + 1) * walshCoefficients (P 0) S =
          c 0 * (c 0 ^ k * walshCoefficients (P 0) S) := by ring
      _ ≤ c 0 * walshCoefficients (P k) S := mul_le_mul_of_nonneg_left ih (hc 0)
      _ ≤ walshCoefficients (P (k + 1)) S :=
        profile_series_coefficient_lower (P k) (P (k + 1)) c e (hnonneg k) hc he (hseries k) S

end NeuralGeneralization
