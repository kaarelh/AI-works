import WalshPointExceptions
import NeuralGeneralization.KernelSpectrum
import Mathlib.Analysis.SpecialFunctions.Trigonometric.DerivHyp

/-! Exact cube symmetrization, including its realization by actual bias-augmented
tanh neurons. The averaging is over the concrete Boolean cube. This module does
not assume an abstract character basis or postulate a parity-feature law.
-/

noncomputable section
open scoped BigOperators
open NeuralGeneralization

namespace ConditionalNonpolynomial.Analytic

variable {d : ℕ}

def cubeTranslation (x : ClippingCube d) : ClippingCube d ≃ ClippingCube d where
  toFun u := cubeProduct u x
  invFun u := cubeProduct u x
  left_inv u := by
    funext i
    cases hu : u i <;> cases hx : x i <;> simp [cubeProduct, hu, hx]
  right_inv u := by
    funext i
    cases hu : u i <;> cases hx : x i <;> simp [cubeProduct, hu, hx]

theorem cubeTranslation_apply (u x : ClippingCube d) :
    cubeTranslation x u = cubeProduct u x := rfl

def walshSymmetrizedFeature (S : Finset (Fin d)) (h : ClippingCube d → ℝ)
    (u x : ClippingCube d) : ℝ := walshCharacter S u * h (cubeProduct u x)

/-- Exact pure-parity mean under a uniform translation and parity sign. -/
theorem walshSymmetrizedFeature_mean (S : Finset (Fin d))
    (h : ClippingCube d → ℝ) (x : ClippingCube d) :
    uniformCubeMean (fun u => walshSymmetrizedFeature S h u x) =
      walshCoefficients h S * walshCharacter S x := by
  have hsum := (cubeTranslation x).sum_comp
    (fun v => walshCharacter S v * h v)
  have hrewrite (u : ClippingCube d) :
      walshSymmetrizedFeature S h u x =
        (walshCharacter S (cubeTranslation x u) * h (cubeTranslation x u)) *
          walshCharacter S x := by
    rw [cubeTranslation_apply, walshCharacter_product]
    have hsq := walshCharacter_sq S x
    unfold walshSymmetrizedFeature
    calc
      _ = (walshCharacter S u * h (cubeProduct u x)) * 1 := by ring
      _ = (walshCharacter S u * h (cubeProduct u x)) * walshCharacter S x ^ 2 := by
        rw [hsq]
      _ = _ := by ring
  simp_rw [hrewrite]
  simp only [walshCoefficients, uniformCubeMean]
  rw [← Finset.sum_mul, hsum]
  have hcomm : (∑ v : ClippingCube d, walshCharacter S v * h v) =
      ∑ v : ClippingCube d, h v * walshCharacter S v := by
    apply Finset.sum_congr rfl
    intro v _
    ring
  rw [hcomm]
  ring

/-- Symmetrization gives the same diagonal second moment at every cube input. -/
theorem walshSymmetrizedFeature_diagonal (S : Finset (Fin d))
    (h : ClippingCube d → ℝ) (x : ClippingCube d) :
    uniformCubeMean (fun u => walshSymmetrizedFeature S h u x ^ 2) =
      uniformCubeMean (fun u => h u ^ 2) := by
  have hsum := (cubeTranslation x).sum_comp (fun u => h u ^ 2)
  simp only [walshSymmetrizedFeature, mul_pow, walshCharacter_sq, one_mul,
    uniformCubeMean]
  exact congrArg (fun z : ℝ => z / (Fintype.card (ClippingCube d) : ℝ)) hsum

theorem walshCoefficients_lower_of_signed_margin (S : Finset (Fin d))
    (h : ClippingCube d → ℝ) (c : ℝ)
    (hc : ∀ x, c ≤ walshCharacter S x * h x) :
    c ≤ walshCoefficients h S := by
  have hM : 0 < (Fintype.card (ClippingCube d) : ℝ) :=
    Nat.cast_pos.mpr Fintype.card_pos
  apply (le_div_iff₀ hM).mpr
  have hs := Finset.sum_le_sum (s := (Finset.univ : Finset (ClippingCube d)))
    (fun x _ => hc x)
  simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul] at hs
  have hcomm : (∑ x : ClippingCube d, walshCharacter S x * h x) =
      ∑ x : ClippingCube d, h x * walshCharacter S x := by
    apply Finset.sum_congr rfl
    intro x _
    ring
  rw [hcomm] at hs
  simpa only [mul_comm] using hs

/-- Bias is the `none` coordinate; no extra bias parameters are introduced. -/
def tanhCubeFeature (w : Option (Fin d) → ℝ) (x : ClippingCube d) : ℝ :=
  Real.tanh (w none + ∑ i, w (some i) * cubeCoordinateSign (x i))

def symmetrizedTanhWeights (S : Finset (Fin d)) (u : ClippingCube d)
    (w : Option (Fin d) → ℝ) : Option (Fin d) → ℝ
  | none => walshCharacter S u * w none
  | some i => walshCharacter S u * cubeCoordinateSign (u i) * w (some i)

theorem tanh_mul_walshCharacter (S : Finset (Fin d)) (u : ClippingCube d) (z : ℝ) :
    Real.tanh (walshCharacter S u * z) = walshCharacter S u * Real.tanh z := by
  rcases sq_eq_one_iff.mp (walshCharacter_sq S u) with h | h <;>
    simp [h, Real.tanh_neg]

/-- Signed translations of an actual tanh neuron are actual tanh neurons of the
same augmented-input dimension. -/
theorem tanhCubeFeature_symmetrizedWeights (S : Finset (Fin d))
    (u x : ClippingCube d) (w : Option (Fin d) → ℝ) :
    tanhCubeFeature (symmetrizedTanhWeights S u w) x =
      walshSymmetrizedFeature S (tanhCubeFeature w) u x := by
  have harg : symmetrizedTanhWeights S u w none +
      (∑ i, symmetrizedTanhWeights S u w (some i) * cubeCoordinateSign (x i)) =
      walshCharacter S u * (w none +
        ∑ i, w (some i) * cubeCoordinateSign (cubeProduct u x i)) := by
    simp only [symmetrizedTanhWeights, cubeCoordinateSign_product, mul_add, Finset.mul_sum]
    congr 1
    apply Finset.sum_congr rfl
    intro i _
    ring
  unfold tanhCubeFeature
  rw [harg, tanh_mul_walshCharacter]
  rfl

theorem symmetrizedTanhWeights_sq (S : Finset (Fin d)) (u : ClippingCube d)
    (w : Option (Fin d) → ℝ) (i : Option (Fin d)) :
    symmetrizedTanhWeights S u w i ^ 2 = w i ^ 2 := by
  cases i <;> simp [symmetrizedTanhWeights, mul_pow, walshCharacter_sq, cubeCoordinateSign_sq]

/-- The explicit weight transform preserves squared norm, as required for its
Gaussian mean-shift entropy cost. Gaussian measure preservation is separate. -/
theorem symmetrizedTanhWeights_normSq (S : Finset (Fin d)) (u : ClippingCube d)
    (w : Option (Fin d) → ℝ) :
    (∑ i, symmetrizedTanhWeights S u w i ^ 2) = ∑ i, w i ^ 2 := by
  simp only [symmetrizedTanhWeights_sq]

theorem actualTanh_symmetrization_mean (S : Finset (Fin d))
    (w : Option (Fin d) → ℝ) (x : ClippingCube d) :
    uniformCubeMean (fun u => tanhCubeFeature (symmetrizedTanhWeights S u w) x) =
      walshCoefficients (tanhCubeFeature w) S * walshCharacter S x := by
  simp_rw [tanhCubeFeature_symmetrizedWeights]
  exact walshSymmetrizedFeature_mean S _ x

theorem actualTanh_symmetrization_constant_diagonal (S : Finset (Fin d))
    (w : Option (Fin d) → ℝ) (x : ClippingCube d) :
    uniformCubeMean (fun u => tanhCubeFeature (symmetrizedTanhWeights S u w) x ^ 2) =
      uniformCubeMean (fun u => tanhCubeFeature w u ^ 2) := by
  simp_rw [tanhCubeFeature_symmetrizedWeights]
  exact walshSymmetrizedFeature_diagonal S _ x

end ConditionalNonpolynomial.Analytic

#print axioms ConditionalNonpolynomial.Analytic.actualTanh_symmetrization_mean
#print axioms ConditionalNonpolynomial.Analytic.actualTanh_symmetrization_constant_diagonal
