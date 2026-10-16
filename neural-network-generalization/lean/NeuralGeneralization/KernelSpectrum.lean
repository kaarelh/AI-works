import NeuralGeneralization.KernelEnergy
import Mathlib.Algebra.BigOperators.Fin

/-!
# Exact finite spectral ingredients for biased dot-product kernels

This module defines the actual biased normalized dot product and proves
its Walsh diagonalization after any scalar transformation. Powers are
represented by explicit finite tensor features, giving nonnegative
spectral coefficients without an assumed positivity conclusion.
It does not establish the arcsine coefficient asymptotics or tail rates.
-/

noncomputable section

namespace NeuralGeneralization

open scoped BigOperators

variable {d : ℕ}

def cubeProduct (x y : ClippingCube d) (i : Fin d) : Bool := x i == y i

theorem cubeCoordinateSign_product (x y : ClippingCube d) (i : Fin d) :
    cubeCoordinateSign (cubeProduct x y i) =
      cubeCoordinateSign (x i) * cubeCoordinateSign (y i) := by
  cases hx : x i <;> cases hy : y i <;> simp [cubeProduct, hx, hy, cubeCoordinateSign]

theorem walshCharacter_product (S : Finset (Fin d)) (x y : ClippingCube d) :
    walshCharacter S (cubeProduct x y) = walshCharacter S x * walshCharacter S y := by
  simp only [walshCharacter, cubeCoordinateSign_product, Finset.prod_mul_distrib]

/-- Normalization includes the distinguished bias coordinate. -/
def biasedDot (x y : ClippingCube d) : ℝ :=
  (1 + ∑ i, cubeCoordinateSign (x i) * cubeCoordinateSign (y i)) / (d + 1 : ℝ)

def biasedProfile (F : ℝ → ℝ) (x : ClippingCube d) : ℝ :=
  F ((1 + ∑ i, cubeCoordinateSign (x i)) / (d + 1 : ℝ))

theorem biasedProfile_product (F : ℝ → ℝ) (x y : ClippingCube d) :
    biasedProfile F (cubeProduct x y) = F (biasedDot x y) := by
  simp only [biasedProfile, biasedDot, cubeCoordinateSign_product]

/-- Exact spectral representation of the actual biased dot-product
kernel, for an arbitrary scalar function (no analyticity needed). -/
theorem biasedDot_kernel_walsh (F : ℝ → ℝ) (x y : ClippingCube d) :
    F (biasedDot x y) = walshKernel (walshCoefficients (biasedProfile F)) x y := by
  rw [← biasedProfile_product F x y, ← walshExpansion_coefficients (biasedProfile F) (cubeProduct x y)]
  unfold walshExpansion walshKernel featureKernel
  simp_rw [walshCharacter_product]
  apply Finset.sum_congr rfl
  intro S hS
  ring

/-- Matrix eigenvalue is `M * w(S)`; population eigenvalue is `w(S)`. -/
theorem walshKernel_character_eigenvalue (w : Finset (Fin d) → ℝ)
    (S : Finset (Fin d)) (x : ClippingCube d) :
    (∑ y : ClippingCube d, walshKernel w x y * walshCharacter S y) =
      (Fintype.card (ClippingCube d) : ℝ) * w S * walshCharacter S x := by
  simp_rw [walshKernel_eq_expansion]
  rw [walshExpansion_pairing]
  ring

theorem walshKernel_character_quadratic (w : Finset (Fin d) → ℝ)
    (S : Finset (Fin d)) :
    finiteQuadratic (walshKernel w) (walshCharacter S) =
      (Fintype.card (ClippingCube d) : ℝ) ^ 2 * w S := by
  unfold finiteQuadratic
  have hinner (x : ClippingCube d) :
      (∑ y, walshCharacter S x * walshKernel w x y * walshCharacter S y) =
        walshCharacter S x * (∑ y, walshKernel w x y * walshCharacter S y) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro y hy
    ring
  simp_rw [hinner, walshKernel_character_eigenvalue]
  calc
    (∑ x : ClippingCube d, walshCharacter S x *
        ((Fintype.card (ClippingCube d) : ℝ) * w S * walshCharacter S x)) =
      ∑ _x : ClippingCube d, (Fintype.card (ClippingCube d) : ℝ) * w S := by
      apply Finset.sum_congr rfl
      intro x hx
      calc
        _ = ((Fintype.card (ClippingCube d) : ℝ) * w S) * walshCharacter S x ^ 2 := by ring
        _ = _ := by rw [walshCharacter_sq, mul_one]
    _ = _ := by simp; ring

/-- A finite tensor feature for a power of the biased dot product. -/
def biasedCoordinate (x : ClippingCube d) : Option (Fin d) → ℝ
  | none => 1
  | some i => cubeCoordinateSign (x i)

def biasedTensorFeature (m : ℕ) (p : Fin m → Option (Fin d))
    (x : ClippingCube d) : ℝ := ∏ t, biasedCoordinate x (p t)

/-- Exact tensor-feature expansion, including the bias coordinate. -/
theorem biasedDot_power_featureKernel (m : ℕ) (x y : ClippingCube d) :
    biasedDot x y ^ m = featureKernel (biasedTensorFeature m)
      (fun _ => 1 / (d + 1 : ℝ) ^ m) x y := by
  have hsum : 1 + ∑ i, cubeCoordinateSign (x i) * cubeCoordinateSign (y i) =
      ∑ i : Option (Fin d), biasedCoordinate x i * biasedCoordinate y i := by
    rw [Fintype.sum_option]
    simp only [biasedCoordinate, one_mul]
  unfold biasedDot
  rw [hsum, div_pow, Fintype.sum_pow, Finset.sum_div]
  unfold featureKernel biasedTensorFeature
  apply Finset.sum_congr rfl
  intro p hp
  rw [Finset.prod_mul_distrib]
  ring

/-- Positivity is derived from explicit tensor features for every power. -/
theorem biasedDot_power_positiveSemidefinite (m : ℕ) (b : ClippingCube d → ℝ) :
    0 ≤ finiteQuadratic (fun x y : ClippingCube d => biasedDot x y ^ m) b := by
  simp_rw [biasedDot_power_featureKernel]
  exact featureKernel_positiveSemidefinite (biasedTensorFeature m) _
    (fun _ => by positivity) id b

/-- Exact power-kernel spectral coefficient as a sum of squares. This is
also a finite occupancy formula: each inner sum is the Fourier transform
of one coordinate-selection path. -/
theorem biasedDot_power_coefficient_formula (m : ℕ) (S : Finset (Fin d)) :
    (Fintype.card (ClippingCube d) : ℝ) ^ 2 *
        walshCoefficients (biasedProfile (fun t => t ^ m)) S =
      ∑ p : Fin m → Option (Fin d), (1 / (d + 1 : ℝ) ^ m) *
        (∑ x : ClippingCube d, walshCharacter S x * biasedTensorFeature m p x) ^ 2 := by
  rw [← walshKernel_character_quadratic]
  have hkernel : walshKernel (walshCoefficients (biasedProfile (fun t => t ^ m))) =
      fun x y : ClippingCube d => featureKernel (biasedTensorFeature m)
        (fun _ => 1 / (d + 1 : ℝ) ^ m) x y := by
    funext x y
    rw [← biasedDot_kernel_walsh, biasedDot_power_featureKernel]
  rw [hkernel]
  exact featureKernel_quadratic (biasedTensorFeature m) _ id (walshCharacter S)

theorem biasedDot_power_coefficient_nonneg (m : ℕ) (S : Finset (Fin d)) :
    0 ≤ walshCoefficients (biasedProfile (fun t => t ^ m)) S := by
  have h := biasedDot_power_positiveSemidefinite m (walshCharacter S)
  have hkernel : (fun x y : ClippingCube d => biasedDot x y ^ m) =
      walshKernel (walshCoefficients (biasedProfile (fun t => t ^ m))) := by
    funext x y
    exact biasedDot_kernel_walsh _ x y
  rw [hkernel, walshKernel_character_quadratic] at h
  have hM : 0 < (Fintype.card (ClippingCube d) : ℝ) ^ 2 :=
    sq_pos_of_pos (Nat.cast_pos.mpr Fintype.card_pos)
  apply (mul_le_mul_iff_left₀ hM).mp
  simpa only [zero_mul, mul_comm] using h

/-- The path selecting coordinates in `S` and bias coordinates elsewhere
is exactly the Walsh character `S`. -/
theorem biasedTensorFeature_selected (S : Finset (Fin d)) (x : ClippingCube d) :
    biasedTensorFeature d (fun i => if i ∈ S then some i else none) x =
      walshCharacter S x := by
  classical
  unfold biasedTensorFeature
  have hterm (i : Fin d) :
      biasedCoordinate x (if i ∈ S then some i else none) =
        if i ∈ S then cubeCoordinateSign (x i) else 1 := by
    by_cases hi : i ∈ S <;> simp [hi, biasedCoordinate]
  simp_rw [hterm]
  exact Fintype.prod_ite_mem S _

/-- Every degree occurs with positive weight in the `d`th biased power.
The bound follows by retaining one explicit coordinate-selection path;
it is not the paper's much sharper arcsine tail estimate. -/
theorem biasedDot_dimension_power_coefficient_lower (S : Finset (Fin d)) :
    1 / (d + 1 : ℝ) ^ d ≤
      walshCoefficients (biasedProfile (fun t => t ^ d)) S := by
  classical
  let p : Fin d → Option (Fin d) := fun i => if i ∈ S then some i else none
  have hpath : (∑ x : ClippingCube d, walshCharacter S x * biasedTensorFeature d p x) =
      (Fintype.card (ClippingCube d) : ℝ) := by
    simp only [p, biasedTensorFeature_selected, ← pow_two, walshCharacter_sq,
      Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_one]
  have hle := Finset.single_le_sum
    (s := (Finset.univ : Finset (Fin d → Option (Fin d))))
    (f := fun q => (1 / (d + 1 : ℝ) ^ d) *
      (∑ x : ClippingCube d, walshCharacter S x * biasedTensorFeature d q x) ^ 2)
    (fun q hq => by positivity) (Finset.mem_univ p)
  rw [hpath, ← biasedDot_power_coefficient_formula] at hle
  have hM : 0 < (Fintype.card (ClippingCube d) : ℝ) ^ 2 :=
    sq_pos_of_pos (Nat.cast_pos.mpr Fintype.card_pos)
  apply (mul_le_mul_iff_left₀ hM).mp
  simpa only [mul_comm] using hle

/-- Additional factors select the bias coordinate and hence equal one. -/
def paddedSelectedPath (S : Finset (Fin d)) :
    (n : ℕ) → Fin (d + n) → Option (Fin d)
  | 0 => fun i => if i ∈ S then some i else none
  | n + 1 => Fin.cons none (paddedSelectedPath S n)

theorem biasedTensorFeature_paddedSelected (S : Finset (Fin d)) (n : ℕ)
    (x : ClippingCube d) :
    biasedTensorFeature (d + n) (paddedSelectedPath S n) x = walshCharacter S x := by
  induction n with
  | zero => exact biasedTensorFeature_selected S x
  | succ n ih =>
    change (∏ t : Fin ((d + n) + 1),
      biasedCoordinate x (Fin.cons (α := fun _ => Option (Fin d)) none (paddedSelectedPath S n) t)) = walshCharacter S x
    rw [Fin.prod_univ_succ]
    simpa only [Fin.cons_zero, Fin.cons_succ, biasedCoordinate, biasedTensorFeature,
      one_mul] using ih

/-- All Walsh eigenvalues of every biased dot-product power of order at
least `d` are positive, with an explicit lower bound. -/
theorem biasedDot_power_coefficient_lower (S : Finset (Fin d)) (n : ℕ) :
    1 / (d + 1 : ℝ) ^ (d + n) ≤
      walshCoefficients (biasedProfile (fun t => t ^ (d + n))) S := by
  classical
  have hpath : (∑ x : ClippingCube d,
      walshCharacter S x * biasedTensorFeature (d + n) (paddedSelectedPath S n) x) =
      (Fintype.card (ClippingCube d) : ℝ) := by
    simp only [biasedTensorFeature_paddedSelected, ← pow_two, walshCharacter_sq,
      Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_one]
  have hle := Finset.single_le_sum
    (s := (Finset.univ : Finset (Fin (d + n) → Option (Fin d))))
    (f := fun q => (1 / (d + 1 : ℝ) ^ (d + n)) *
      (∑ x : ClippingCube d, walshCharacter S x * biasedTensorFeature (d + n) q x) ^ 2)
    (fun q hq => by positivity) (Finset.mem_univ (paddedSelectedPath S n))
  rw [hpath, ← biasedDot_power_coefficient_formula] at hle
  have hM : 0 < (Fintype.card (ClippingCube d) : ℝ) ^ 2 :=
    sq_pos_of_pos (Nat.cast_pos.mpr Fintype.card_pos)
  apply (mul_le_mul_iff_left₀ hM).mp
  simpa only [mul_comm] using hle

theorem walshCoefficients_finite_sum {ι : Type*} (A : Finset ι)
    (c : ι → ℝ) (P : ι → ClippingCube d → ℝ) (S : Finset (Fin d)) :
    walshCoefficients (fun x => ∑ i ∈ A, c i * P i x) S =
      ∑ i ∈ A, c i * walshCoefficients (P i) S := by
  unfold walshCoefficients uniformCubeMean
  simp_rw [Finset.sum_mul]
  rw [Finset.sum_comm, Finset.sum_div]
  apply Finset.sum_congr rfl
  intro i hi
  rw [← mul_div_assoc, Finset.mul_sum]
  apply congrArg (fun t => t / (Fintype.card (ClippingCube d) : ℝ))
  apply Finset.sum_congr rfl
  intro x hx
  ring

theorem biasedDot_polynomial_coefficient_nonneg (A : Finset ℕ) (c : ℕ → ℝ)
    (hc : ∀ m ∈ A, 0 ≤ c m) (S : Finset (Fin d)) :
    0 ≤ walshCoefficients (biasedProfile (fun t => ∑ m ∈ A, c m * t ^ m)) S := by
  change 0 ≤ walshCoefficients (fun x => ∑ m ∈ A,
    c m * biasedProfile (fun t => t ^ m) x) S
  rw [walshCoefficients_finite_sum]
  exact Finset.sum_nonneg (fun m hm =>
    mul_nonneg (hc m hm) (biasedDot_power_coefficient_nonneg m S))

/-- A nonnegative polynomial with one positive coefficient of order at
least `d` gives a strictly positive definite biased kernel. Here the
conclusion is the explicit lower bound for every Walsh eigenvalue. -/
theorem biasedDot_polynomial_coefficient_lower (A : Finset ℕ) (c : ℕ → ℝ)
    (hc : ∀ m ∈ A, 0 ≤ c m) (S : Finset (Fin d)) (n : ℕ) (hm : d + n ∈ A) :
    c (d + n) / (d + 1 : ℝ) ^ (d + n) ≤
      walshCoefficients (biasedProfile (fun t => ∑ m ∈ A, c m * t ^ m)) S := by
  change c (d + n) / (d + 1 : ℝ) ^ (d + n) ≤
    walshCoefficients (fun x => ∑ m ∈ A, c m * biasedProfile (fun t => t ^ m) x) S
  rw [walshCoefficients_finite_sum]
  have hlower := mul_le_mul_of_nonneg_left (biasedDot_power_coefficient_lower S n)
    (hc (d + n) hm)
  have hsingle := Finset.single_le_sum (s := A)
    (f := fun m => c m * walshCoefficients (biasedProfile (fun t => t ^ m)) S)
    (fun m hm => mul_nonneg (hc m hm) (biasedDot_power_coefficient_nonneg m S)) hm
  have hlower' : c (d + n) / (d + 1 : ℝ) ^ (d + n) ≤
      c (d + n) * walshCoefficients (biasedProfile (fun t => t ^ (d + n))) S := by
    simpa only [mul_one_div] using hlower
  exact hlower'.trans hsingle

end NeuralGeneralization
