import NeuralGeneralization.OnlineLowerReluFourier
import NeuralGeneralization.WalshLaplacian
import Mathlib.Analysis.Complex.Trigonometric

/-! # Exact Boolean cosine-product identity for affine ReLU coefficients -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

/-- The actual affine input of one physical neuron on the sign cube. -/
def cubeAffine {d : ℕ} (b : ℝ) (u : Fin d → ℝ) (x : ClippingCube d) : ℝ :=
  b + ∑ i, u i * cubeCoordinateSign (x i)

theorem complexSignStep (selected : Bool) (a : ℝ) :
    (∑ v : Bool, (if selected then (cubeCoordinateSign v : ℂ) else 1) *
      Complex.exp (((a * cubeCoordinateSign v : ℝ) : ℂ) * Complex.I)) =
      2 * (if selected then (Real.sin a : ℂ) * Complex.I else (Real.cos a : ℂ)) := by
  cases selected <;>
    simp [cubeCoordinateSign, Complex.exp_ofReal_mul_I] <;>
    ring

theorem cubeAffine_complex_exp {d : ℕ} (b : ℝ) (u : Fin d → ℝ)
    (x : ClippingCube d) :
    Complex.exp ((cubeAffine b u x : ℂ) * Complex.I) =
      Complex.exp ((b : ℂ) * Complex.I) *
        ∏ i, Complex.exp (((u i * cubeCoordinateSign (x i) : ℝ) : ℂ) * Complex.I) := by
  simp only [cubeAffine, Complex.ofReal_add, Complex.ofReal_sum, add_mul,
    Finset.sum_mul, Complex.exp_add, Complex.exp_sum]

theorem walshCharacter_complex_product {d : ℕ} (S : Finset (Fin d))
    (x : ClippingCube d) :
    (walshCharacter S x : ℂ) =
      ∏ i : Fin d, if i ∈ S then (cubeCoordinateSign (x i) : ℂ) else 1 := by
  classical
  simp [walshCharacter]

/-- Complex exponential factorization under the literal finite uniform cube. -/
theorem walsh_complex_exp_sum {d : ℕ} (S : Finset (Fin d))
    (b : ℝ) (u : Fin d → ℝ) :
    (∑ x : ClippingCube d, (walshCharacter S x : ℂ) *
      Complex.exp ((cubeAffine b u x : ℂ) * Complex.I)) =
      (2 : ℂ) ^ d * Complex.exp ((b : ℂ) * Complex.I) *
        ∏ i : Fin d, if i ∈ S then (Real.sin (u i) : ℂ) * Complex.I
          else (Real.cos (u i) : ℂ) := by
  classical
  let f : Fin d → Bool → ℂ := fun i v =>
    (if i ∈ S then (cubeCoordinateSign v : ℂ) else 1) *
      Complex.exp (((u i * cubeCoordinateSign v : ℝ) : ℂ) * Complex.I)
  have hpoint (x : ClippingCube d) :
      (walshCharacter S x : ℂ) * Complex.exp ((cubeAffine b u x : ℂ) * Complex.I) =
        Complex.exp ((b : ℂ) * Complex.I) * ∏ i, f i (x i) := by
    rw [cubeAffine_complex_exp, walshCharacter_complex_product, Finset.prod_mul_distrib]
    ring
  simp_rw [hpoint]
  rw [← Finset.mul_sum, ← Fintype.prod_sum]
  have hstep (i : Fin d) : (∑ v : Bool, f i v) =
      2 * (if i ∈ S then (Real.sin (u i) : ℂ) * Complex.I else (Real.cos (u i) : ℂ)) := by
    simpa [f] using complexSignStep (decide (i ∈ S)) (u i)
  simp_rw [hstep]
  rw [Finset.prod_mul_distrib]
  simp only [Finset.prod_const, Finset.card_univ, Fintype.card_fin]
  ring

/-- The real sine/cosine product attached to a physical Walsh support. -/
def trigProduct {d : ℕ} (S : Finset (Fin d)) (u : Fin d → ℝ) : ℝ :=
  ∏ i, if i ∈ S then Real.sin (u i) else Real.cos (u i)

theorem complex_trigProduct {d : ℕ} (S : Finset (Fin d)) (u : Fin d → ℝ) :
    (∏ i : Fin d, if i ∈ S then (Real.sin (u i) : ℂ) * Complex.I
      else (Real.cos (u i) : ℂ)) =
        Complex.I ^ S.card * (trigProduct S u : ℂ) := by
  classical
  have hp (i : Fin d) :
      (if i ∈ S then (Real.sin (u i) : ℂ) * Complex.I else (Real.cos (u i) : ℂ)) =
      (if i ∈ S then Complex.I else 1) *
        ((if i ∈ S then Real.sin (u i) else Real.cos (u i) : ℝ) : ℂ) := by
    by_cases hi : i ∈ S <;> simp [hi, mul_comm]
  simp_rw [hp]
  rw [Finset.prod_mul_distrib]
  simp [trigProduct]

/-- For an even support the complex phase is a fixed real sign. -/
theorem walsh_cosine_sum_even {d r : ℕ} (S : Finset (Fin d))
    (hcard : S.card = 2 * r) (b : ℝ) (u : Fin d → ℝ) :
    (∑ x : ClippingCube d, walshCharacter S x * Real.cos (cubeAffine b u x)) =
      (2 : ℝ) ^ d * (-1 : ℝ) ^ r * Real.cos b * trigProduct S u := by
  have h := congrArg Complex.re (walsh_complex_exp_sum S b u)
  rw [complex_trigProduct, hcard, pow_mul, Complex.I_sq] at h
  have htwo : (2 : ℂ) ^ d = (((2 : ℝ) ^ d : ℝ) : ℂ) := by simp
  have hneg : (-1 : ℂ) ^ r = (((-1 : ℝ) ^ r : ℝ) : ℂ) := by simp
  rw [htwo, hneg] at h
  have hsum (f : ClippingCube d → ℂ) :
      (∑ x, f x).re = ∑ x, (f x).re := map_sum Complex.reAddGroupHom f Finset.univ
  rw [hsum] at h
  simp only [Complex.mul_re, Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im,
    zero_mul, mul_zero, sub_zero, add_zero, Complex.exp_ofReal_mul_I_re] at h
  calc
    _ = (2 : ℝ) ^ d * Real.cos b * ((-1 : ℝ) ^ r * trigProduct S u) := h
    _ = _ := by ring

theorem cubeAffine_scale {d : ℕ} (t b : ℝ) (u : Fin d → ℝ)
    (x : ClippingCube d) :
    cubeAffine (t * b) (fun i => t * u i) x = t * cubeAffine b u x := by
  simp only [cubeAffine, mul_add, Finset.mul_sum]
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  ring

/-- Exact real Fourier product at every frequency, including zero. -/
theorem walsh_cosine_frequency_even {d r : ℕ} (S : Finset (Fin d))
    (hcard : S.card = 2 * r) (t b : ℝ) (u : Fin d → ℝ) :
    (∑ x : ClippingCube d, walshCharacter S x * Real.cos (t * cubeAffine b u x)) =
      (2 : ℝ) ^ d * (-1 : ℝ) ^ r * Real.cos (t * b) *
        trigProduct S (fun i => t * u i) := by
  simpa only [cubeAffine_scale] using
    walsh_cosine_sum_even S hcard (t * b) (fun i => t * u i)

end NeuralGeneralization.OnlineLowerRelu
