import NeuralGeneralization.OnlineLowerGeometryProjection
import NeuralGeneralization.OnlineLowerGeometryAlgebra

/-!
# Physical observability from conditional Fourier support

This module connects the factor-two finite mass inequality to actual
conditional physical energy.  Its spectral premise is the vanishing
condition to be proved by the first-defective-rail combinatorics; it is
not assumed as part of an unconditional online theorem.
-/

noncomputable section
open scoped BigOperators Classical symmDiff

namespace NeuralGeneralization.OnlineLowerGeometry

/-- A purely finite support exclusion kills a product Fourier mode. -/
theorem projected_product_coefficient_zero {d : ℕ}
    (A B : Finset (Finset (Fin d))) (F G : ClippingCube d → ℝ)
    (Q : Finset (Fin d))
    (hexclude : ∀ S ∈ A, ∀ T ∈ B, S ∆ T ≠ Q) :
    walshCoefficients (fun x => fourierProject A F x * fourierProject B G x) Q = 0 := by
  rw [walshCoefficients_product]
  simp_rw [fourierProject_coefficient]
  apply Finset.sum_eq_zero
  intro S _
  by_cases hS : S ∈ A
  · have hT : Q ∆ S ∉ B := by
      intro hmem
      apply hexclude S hS (Q ∆ S) hmem
      rw [symmDiff_comm Q S]
      exact (supportTranslation S).left_inv Q
    simp [hS, hT]
  · simp [hS]

namespace WalshCodeMap

variable {d m : ℕ} (C : WalshCodeMap d m)

def fiberMean (F : ClippingCube d → ℝ) (z : ClippingCube m) : ℝ :=
  ∑ x, C.fiberWeight z x * F x

theorem fiberMean_sum {κ : Type*} [Fintype κ]
    (F : κ → ClippingCube d → ℝ) (z : ClippingCube m) :
    C.fiberMean (fun x => ∑ i, F i x) z = ∑ i, C.fiberMean (F i) z := by
  unfold fiberMean
  simp_rw [Finset.mul_sum]
  rw [Finset.sum_comm]

theorem fiberMean_sum_squared {κ : Type*} [Fintype κ]
    (F : κ → ClippingCube d → ℝ)
    (hcross : ∀ i j, i ≠ j → ∀ z, C.fiberMean (fun x => F i x * F j x) z = 0)
    (z : ClippingCube m) :
    C.fiberMean (fun x => (∑ i, F i x) ^ 2) z =
      ∑ i, C.fiberMean (fun x => (F i x) ^ 2) z := by
  have hexp : (fun x => (∑ i, F i x) ^ 2) =
      (fun x => ∑ i, ∑ j, F i x * F j x) := by
    funext x
    rw [pow_two, Finset.sum_mul]
    simp_rw [Finset.mul_sum]
  rw [hexp, C.fiberMean_sum]
  apply Finset.sum_congr rfl
  intro i _
  rw [C.fiberMean_sum, Finset.sum_eq_single i]
  · congr 1
    funext x
    ring
  · intro j _ hji
    exact hcross i j (Ne.symm hji) z
  · simp

theorem physical_sum_squared {κ : Type*} [Fintype κ]
    (F : κ → ClippingCube d → ℝ)
    (hcross : ∀ i j, i ≠ j → ∀ z, C.fiberMean (fun x => F i x * F j x) z = 0) :
    uniformCubeMean (fun x => (∑ i, F i x) ^ 2) =
      ∑ i, uniformCubeMean (fun x => (F i x) ^ 2) := by
  rw [← C.mean_fiber_mean]
  change uniformCubeMean (fun z => C.fiberMean (fun x => (∑ i, F i x) ^ 2) z) = _
  simp_rw [C.fiberMean_sum_squared F hcross]
  unfold uniformCubeMean
  rw [Finset.sum_comm, Finset.sum_div]
  apply Finset.sum_congr rfl
  intro i _
  exact C.mean_fiber_mean _

theorem fiberMean_eq_logicalProjection (F : ClippingCube d → ℝ)
    (z : ClippingCube m) :
    C.fiberMean F z = C.logicalProjection (fun x => C.base x * F x) z := by
  rw [C.logicalProjection_fiber]
  unfold fiberMean
  apply Finset.sum_congr rfl
  intro x _
  have h : C.base x * (C.base x * F x) = F x := by
    rw [← mul_assoc, ← pow_two, C.base_sq, one_mul]
  rw [h]

theorem fiberMean_nonneg (F : ClippingCube d → ℝ) (hF : ∀ x, 0 ≤ F x)
    (z : ClippingCube m) : 0 ≤ C.fiberMean F z :=
  Finset.sum_nonneg fun x _ => mul_nonneg (C.fiberWeight_nonneg z x) (hF x)

theorem fiberMean_restrict (F : ClippingCube d → ℝ) (J : Set (ClippingCube m))
    (z : ClippingCube m) :
    C.fiberMean (fun x => if C.syndrome x ∉ J then F x else 0) z =
      if z ∉ J then C.fiberMean F z else 0 := by
  unfold fiberMean
  by_cases hz : z ∉ J
  · rw [if_pos hz]
    apply Finset.sum_congr rfl
    intro x _
    by_cases hx : C.syndrome x = z
    · simp [hx, hz]
    · simp [C.fiberWeight_eq_zero hx]
  · rw [if_neg hz]
    apply Finset.sum_eq_zero
    intro x _
    by_cases hx : C.syndrome x = z
    · simp [hx, hz]
    · simp [C.fiberWeight_eq_zero hx]

theorem physical_restricted_sum_squared {κ : Type*} [Fintype κ]
    (F : κ → ClippingCube d → ℝ) (J : Set (ClippingCube m))
    (hcross : ∀ i j, i ≠ j → ∀ z, C.fiberMean (fun x => F i x * F j x) z = 0) :
    uniformCubeMean (fun x => if C.syndrome x ∉ J then (∑ i, F i x) ^ 2 else 0) =
      ∑ i, uniformCubeMean (fun x => if C.syndrome x ∉ J then (F i x) ^ 2 else 0) := by
  rw [← C.mean_fiber_mean]
  change uniformCubeMean (fun z => C.fiberMean (fun x =>
    if C.syndrome x ∉ J then (∑ i, F i x) ^ 2 else 0) z) = _
  simp_rw [C.fiberMean_restrict, C.fiberMean_sum_squared F hcross]
  have hsplit (z : ClippingCube m) :
      (if z ∉ J then ∑ i, C.fiberMean (fun x => (F i x) ^ 2) z else 0) =
        ∑ i, if z ∉ J then C.fiberMean (fun x => (F i x) ^ 2) z else 0 := by
    split_ifs <;> simp
  simp_rw [hsplit]
  unfold uniformCubeMean
  rw [Finset.sum_comm, Finset.sum_div]
  apply Finset.sum_congr rfl
  intro i _
  change uniformCubeMean (fun z => if z ∉ J then
    C.fiberMean (fun x => (F i x) ^ 2) z else 0) = _
  simp_rw [← C.fiberMean_restrict]
  exact C.mean_fiber_mean _

/-- Missing conditional Fourier modes give invariance under the actual
logical cube translation. -/
theorem fiberMean_translation (F : ClippingCube d → ℝ) (a : ClippingCube m)
    (hzero : ∀ S, walshCharacter S a ≠ 1 →
      walshCoefficients (fun x => C.base x * F x) (C.support S) = 0)
    (z : ClippingCube m) :
    C.fiberMean F (cubeTranslation a z) = C.fiberMean F z := by
  simp only [C.fiberMean_eq_logicalProjection, logicalProjection, walshExpansion,
    walshCharacter_translation]
  apply Finset.sum_congr rfl
  intro S _
  by_cases hS : walshCharacter S a = 1
  · rw [hS, one_mul]
  · rw [hzero S hS]
    ring

/-- A concrete physical second moment is observable off an independent
logical set whenever its conditional spectrum has the required support. -/
theorem physical_observability_from_conditional_spectrum
    (A : ClippingCube d → ℝ) (a : ClippingCube m) (J : Set (ClippingCube m))
    (hind : ∀ z, z ∈ J → cubeTranslation a z ∉ J)
    (hzero : ∀ S, walshCharacter S a ≠ 1 →
      walshCoefficients (fun x => C.base x * (A x) ^ 2) (C.support S) = 0) :
    uniformCubeMean (fun x => (A x) ^ 2) ≤
      2 * uniformCubeMean (fun x => if C.syndrome x ∉ J then (A x) ^ 2 else 0) := by
  have h := cube_translation_observability a J
    (C.fiberMean (fun x => (A x) ^ 2))
    (C.fiberMean_nonneg _ (fun x => sq_nonneg (A x)))
    (C.fiberMean_translation _ a hzero) hind
  have hleft : uniformCubeMean (C.fiberMean (fun x => (A x) ^ 2)) =
      uniformCubeMean (fun x => (A x) ^ 2) := C.mean_fiber_mean _
  have hright : uniformCubeMean (fun z =>
      if z ∉ J then C.fiberMean (fun x => (A x) ^ 2) z else 0) =
      uniformCubeMean (fun x => if C.syndrome x ∉ J then (A x) ^ 2 else 0) := by
    simp_rw [← C.fiberMean_restrict]
    exact C.mean_fiber_mean _
  rwa [hleft, hright] at h

/-- The conditional cross term vanishes if no pair of component Fourier
supports differs by one of the actual code toggles. -/
theorem conditional_projected_product_zero
    (A B : Finset (Finset (Fin d))) (F G : ClippingCube d → ℝ)
    (hexclude : ∀ U : Finset (Fin m), ∀ S ∈ A, ∀ T ∈ B,
      S ∆ T ≠ C.support ∅ ∆ C.support U) (z : ClippingCube m) :
    C.fiberMean (fun x => fourierProject A F x * fourierProject B G x) z = 0 := by
  rw [C.fiberMean_eq_logicalProjection]
  unfold logicalProjection walshExpansion
  apply Finset.sum_eq_zero
  intro U _
  have heq : (fun x => C.base x * (fourierProject A F x * fourierProject B G x)) =
      (fun x => (fourierProject A F x * fourierProject B G x) *
        walshCharacter (C.support ∅) x) := by
    funext x
    unfold base
    ring
  rw [heq]
  dsimp only
  rw [walshCoefficients_mul_character,
    projected_product_coefficient_zero A B F G _ (hexclude U), zero_mul]

/-- For a same-defect component, excluding the shifted product modes
proves physical observability directly from actual Fourier supports. -/
theorem projected_physical_observability
    (A : Finset (Finset (Fin d))) (F : ClippingCube d → ℝ)
    (a : ClippingCube m) (J : Set (ClippingCube m))
    (hind : ∀ z, z ∈ J → cubeTranslation a z ∉ J)
    (hexclude : ∀ U : Finset (Fin m), walshCharacter U a ≠ 1 →
      ∀ S ∈ A, ∀ T ∈ A, S ∆ T ≠ C.support ∅ ∆ C.support U) :
    uniformCubeMean (fun x => (fourierProject A F x) ^ 2) ≤
      2 * uniformCubeMean (fun x =>
        if C.syndrome x ∉ J then (fourierProject A F x) ^ 2 else 0) := by
  apply C.physical_observability_from_conditional_spectrum _ a J hind
  intro U hU
  have heq : (fun x => C.base x * (fourierProject A F x) ^ 2) =
      (fun x => (fourierProject A F x * fourierProject A F x) *
        walshCharacter (C.support ∅) x) := by
    funext x
    unfold base
    ring
  rw [heq, walshCoefficients_mul_character]
  exact projected_product_coefficient_zero A A F F _ (hexclude U hU)

end WalshCodeMap
end NeuralGeneralization.OnlineLowerGeometry
