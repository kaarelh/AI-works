import NeuralGeneralization.KernelEnergy
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.NormNum

/-! A concrete Boolean-cube memorizer with small normalized Walsh variation.

The Fourier transform here is the repository's actual cube transform, whose
characters and inversion formula are proved in `KernelEnergy`. No abstract
Fourier basis, interpolation oracle, or target-mass premise is assumed.
-/

noncomputable section
open scoped BigOperators
open NeuralGeneralization

namespace ConditionalNonpolynomial.Analytic

variable {d : ℕ}

def pointIndicator (a x : ClippingCube d) : ℝ := if x = a then 1 else 0

def pointExceptionFunction (A : Finset (ClippingCube d)) (x : ClippingCube d) : ℝ :=
  if x ∈ A then -1 else 1

def walshVariation (f : ClippingCube d → ℝ) : ℝ :=
  ∑ S : Finset (Fin d), |walshCoefficients f S|

theorem pointExceptionFunction_boolean (A : Finset (ClippingCube d))
    (x : ClippingCube d) : pointExceptionFunction A x = -1 ∨
      pointExceptionFunction A x = 1 := by
  classical
  by_cases hx : x ∈ A <;> simp [pointExceptionFunction, hx]

theorem pointExceptionFunction_expansion (A : Finset (ClippingCube d))
    (x : ClippingCube d) :
    pointExceptionFunction A x = 1 - 2 * ∑ a ∈ A, pointIndicator a x := by
  classical
  by_cases hx : x ∈ A
  · norm_num [pointExceptionFunction, pointIndicator, hx]
  · simp [pointExceptionFunction, pointIndicator, hx]

theorem walshCoefficients_add_actual (f g : ClippingCube d → ℝ)
    (S : Finset (Fin d)) :
    walshCoefficients (fun x => f x + g x) S =
      walshCoefficients f S + walshCoefficients g S := by
  simp [walshCoefficients, uniformCubeMean, add_mul, Finset.sum_add_distrib, add_div]

theorem walshCoefficients_sub_actual (f g : ClippingCube d → ℝ)
    (S : Finset (Fin d)) :
    walshCoefficients (fun x => f x - g x) S =
      walshCoefficients f S - walshCoefficients g S := by
  simp [walshCoefficients, uniformCubeMean, sub_mul, Finset.sum_sub_distrib, sub_div]

theorem walshCoefficients_smul_actual (c : ℝ) (f : ClippingCube d → ℝ)
    (S : Finset (Fin d)) :
    walshCoefficients (fun x => c * f x) S = c * walshCoefficients f S := by
  simp only [walshCoefficients, uniformCubeMean, mul_assoc, ← Finset.mul_sum]
  ring

theorem walshCoefficients_sum_actual {ι : Type*} (A : Finset ι)
    (f : ι → ClippingCube d → ℝ) (S : Finset (Fin d)) :
    walshCoefficients (fun x => ∑ i ∈ A, f i x) S =
      ∑ i ∈ A, walshCoefficients (f i) S := by
  classical
  simp only [walshCoefficients, uniformCubeMean, Finset.sum_mul]
  rw [Finset.sum_comm, Finset.sum_div]

theorem walshVariation_nonneg (f : ClippingCube d → ℝ) : 0 ≤ walshVariation f :=
  Finset.sum_nonneg (fun _ _ => abs_nonneg _)

theorem walshVariation_sub_le (f g : ClippingCube d → ℝ) :
    walshVariation (fun x => f x - g x) ≤ walshVariation f + walshVariation g := by
  unfold walshVariation
  simp_rw [walshCoefficients_sub_actual]
  rw [← Finset.sum_add_distrib]
  exact Finset.sum_le_sum (fun _ _ => abs_sub _ _)

theorem walshVariation_smul (c : ℝ) (f : ClippingCube d → ℝ) :
    walshVariation (fun x => c * f x) = |c| * walshVariation f := by
  simp only [walshVariation, walshCoefficients_smul_actual, abs_mul, Finset.mul_sum]

theorem walshVariation_sum_le {ι : Type*} (A : Finset ι)
    (f : ι → ClippingCube d → ℝ) :
    walshVariation (fun x => ∑ i ∈ A, f i x) ≤ ∑ i ∈ A, walshVariation (f i) := by
  classical
  unfold walshVariation
  simp_rw [walshCoefficients_sum_actual]
  calc
    (∑ S : Finset (Fin d), |∑ i ∈ A, walshCoefficients (f i) S|) ≤
        ∑ S : Finset (Fin d), ∑ i ∈ A, |walshCoefficients (f i) S| :=
      Finset.sum_le_sum (fun _ _ => Finset.abs_sum_le_sum_abs _ _)
    _ = _ := Finset.sum_comm

theorem walshCharacter_abs_one (S : Finset (Fin d)) (x : ClippingCube d) :
    |walshCharacter S x| = 1 := by
  have h := walshCharacter_sq S x
  rcases (sq_eq_one_iff.mp h) with h | h <;> simp [h]

theorem walshCoefficients_pointIndicator (a : ClippingCube d) (S : Finset (Fin d)) :
    walshCoefficients (pointIndicator a) S =
      walshCharacter S a / (Fintype.card (ClippingCube d) : ℝ) := by
  classical
  simp [walshCoefficients, uniformCubeMean, pointIndicator, ite_mul]

theorem walshVariation_pointIndicator (a : ClippingCube d) :
    walshVariation (pointIndicator a) = 1 := by
  have hcard : (Fintype.card (ClippingCube d) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  have hsame : Fintype.card (Finset (Fin d)) = Fintype.card (ClippingCube d) := by
    simp [ClippingCube, Fintype.card_pi]
  simp only [walshVariation, walshCoefficients_pointIndicator, abs_div,
    walshCharacter_abs_one, abs_of_nonneg (Nat.cast_nonneg (Fintype.card (ClippingCube d)) :
      (0 : ℝ) ≤ _), Finset.sum_const,
    Finset.card_univ, nsmul_eq_mul, hsame]
  field_simp

theorem walshCoefficients_one (S : Finset (Fin d)) :
    walshCoefficients (fun _ : ClippingCube d => (1 : ℝ)) S =
      if S = ∅ then 1 else 0 := by
  classical
  have h := walshCharacter_orthogonal S ∅
  simp only [walshCharacter, Finset.prod_empty, mul_one] at h
  simp only [walshCoefficients, uniformCubeMean, one_mul]
  change (∑ x : ClippingCube d, ∏ i ∈ S, cubeCoordinateSign (x i)) /
    (Fintype.card (ClippingCube d) : ℝ) = _
  rw [h]
  split_ifs <;> simp

theorem walshVariation_one :
    walshVariation (fun _ : ClippingCube d => (1 : ℝ)) = 1 := by
  classical
  simp [walshVariation, walshCoefficients_one, apply_ite abs]

/-- Explicit 1+2|A| bound for the exact Boolean point-exception function. -/
theorem pointExceptionFunction_walshVariation (A : Finset (ClippingCube d)) :
    walshVariation (pointExceptionFunction A) ≤ 1 + 2 * (A.card : ℝ) := by
  have hfun : pointExceptionFunction A =
      fun x => 1 - 2 * ∑ a ∈ A, pointIndicator a x := by
    funext x
    exact pointExceptionFunction_expansion A x
  rw [hfun]
  have htri := walshVariation_sub_le (fun _ : ClippingCube d => (1 : ℝ))
    (fun x => 2 * ∑ a ∈ A, pointIndicator a x)
  rw [walshVariation_one, walshVariation_smul] at htri
  have hsum := walshVariation_sum_le A (fun a => pointIndicator a)
  simp only [walshVariation_pointIndicator, Finset.sum_const, nsmul_eq_mul, mul_one] at hsum
  norm_num at htri
  linarith

def negativeSamplePoints {n : ℕ} (sample : Fin n → ClippingCube d)
    (f : ClippingCube d → Bool) : Finset (ClippingCube d) :=
  (Finset.univ.filter (fun i => f (sample i) = false)).image sample

theorem negativeSamplePoints_card {n : ℕ} (sample : Fin n → ClippingCube d)
    (f : ClippingCube d → Bool) : (negativeSamplePoints sample f).card ≤ n := by
  classical
  exact (Finset.card_image_le).trans ((Finset.card_filter_le _ _).trans_eq (by simp))

theorem pointExceptionFunction_fits_sample {n : ℕ} (sample : Fin n → ClippingCube d)
    (f : ClippingCube d → Bool) (i : Fin n) :
    pointExceptionFunction (negativeSamplePoints sample f) (sample i) =
      cubeCoordinateSign (f (sample i)) := by
  classical
  cases hf : f (sample i) with
  | false =>
    have hi : sample i ∈ negativeSamplePoints sample f := by
      apply Finset.mem_image.mpr
      exact ⟨i, Finset.mem_filter.mpr ⟨Finset.mem_univ _, hf⟩, rfl⟩
    simp [pointExceptionFunction, hi, cubeCoordinateSign]
  | true =>
    have hi : sample i ∉ negativeSamplePoints sample f := by
      intro h
      obtain ⟨j, hj, hji⟩ := Finset.mem_image.mp h
      have hjf := (Finset.mem_filter.mp hj).2
      rw [hji, hf] at hjf
      cases hjf
    simp [pointExceptionFunction, hi, cubeCoordinateSign]

/-- The exact negative-example memorizer has normalized Walsh l1 at most 1+2n.
Repeated training inputs are allowed. -/
theorem sampleMemorizer_walshVariation {n : ℕ} (sample : Fin n → ClippingCube d)
    (f : ClippingCube d → Bool) :
    walshVariation (pointExceptionFunction (negativeSamplePoints sample f)) ≤
      1 + 2 * (n : ℝ) := by
  have hcard : ((negativeSamplePoints sample f).card : ℝ) ≤ n :=
    Nat.cast_le.mpr (negativeSamplePoints_card sample f)
  exact (pointExceptionFunction_walshVariation _).trans (by linarith)

end ConditionalNonpolynomial.Analytic

#print axioms ConditionalNonpolynomial.Analytic.pointExceptionFunction_walshVariation
#print axioms ConditionalNonpolynomial.Analytic.pointExceptionFunction_fits_sample
#print axioms ConditionalNonpolynomial.Analytic.sampleMemorizer_walshVariation
