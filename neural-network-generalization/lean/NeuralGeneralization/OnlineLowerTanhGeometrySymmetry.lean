import NeuralGeneralization.OnlineLowerTanhGeometryFourier
import NeuralGeneralization.OnlineLowerGeometryPhysicalVariance

/-! # Quantitative anti-invariance forced by observed negative fibers -/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

theorem uniformCubeMean_add {m : ℕ} (f g : ClippingCube m → ℝ) :
    uniformCubeMean (fun z => f z + g z) = uniformCubeMean f + uniformCubeMean g := by
  simp only [uniformCubeMean, Finset.sum_add_distrib, add_div]

theorem restricted_mean_translation {m : ℕ} (u : ClippingCube m)
    (O : Set (ClippingCube m)) (f : ClippingCube m → ℝ)
    (hinv : ∀ z, cubeTranslation u z ∈ O ↔ z ∈ O) :
    uniformCubeMean (fun z => if z ∈ O then f (cubeTranslation u z) else 0) =
      uniformCubeMean (fun z => if z ∈ O then f z else 0) := by
  have h := (cubeTranslation u).sum_comp (fun z => if z ∈ O then f z else 0)
  simp only [hinv] at h
  unfold uniformCubeMean
  rw [h]

/-- Averaging over a translation-invariant observed region of density at
least one half pins the constant coefficient near `-1/2`. -/
theorem rectangle_constant_coefficient_bound {m : ℕ} (u : ClippingCube m)
    (g : ClippingCube m → ℝ) (O : Set (ClippingCube m)) (ε s : ℝ)
    (hs : 0 ≤ s) (hinv : ∀ z, cubeTranslation u z ∈ O ↔ z ∈ O)
    (hdensity : (1 : ℝ) / 2 ≤ uniformCubeMean (fun z => if z ∈ O then 1 else 0))
    (hrem : ∀ z, |invariantRemainder u g z| ≤ ε)
    (hobserved : uniformCubeMean (fun z => if z ∈ O then |g z + 1 / 2| else 0) ≤ s) :
    |walshCoefficients g ∅ + 1 / 2| ≤ ε + 2 * s := by
  let ρ : ℝ := uniformCubeMean (fun z => if z ∈ O then 1 else 0)
  have hpoint (z : ClippingCube m) : |walshCoefficients g ∅ + 1 / 2| ≤
      (|g z + 1 / 2| + |g (cubeTranslation u z) + 1 / 2|) / 2 + ε := by
    have hsym := invariantRemainder_symmetry u g z
    obtain ⟨hrlo, hrhi⟩ := abs_le.mp (hrem z)
    apply abs_le.mpr
    constructor <;> nlinarith [le_abs_self (g z + 1 / 2), neg_le_abs (g z + 1 / 2),
      le_abs_self (g (cubeTranslation u z) + 1 / 2),
      neg_le_abs (g (cubeTranslation u z) + 1 / 2)]
  have hweighted (z : ClippingCube m) :
      |walshCoefficients g ∅ + 1 / 2| * (if z ∈ O then 1 else 0) ≤
        (1 / 2 : ℝ) * (if z ∈ O then |g z + 1 / 2| else 0) +
        (1 / 2 : ℝ) * (if z ∈ O then |g (cubeTranslation u z) + 1 / 2| else 0) +
        ε * (if z ∈ O then 1 else 0) := by
    by_cases hz : z ∈ O
    · simp only [if_pos hz, mul_one]
      nlinarith only [hpoint z]
    · simp only [if_neg hz, mul_zero, add_zero, le_refl]
  have hmean := uniformCubeMean_mono _ _ hweighted
  rw [uniformCubeMean_add, uniformCubeMean_add, uniformCubeMean_mul,
    uniformCubeMean_mul, uniformCubeMean_mul, uniformCubeMean_mul] at hmean
  rw [restricted_mean_translation u O (fun z => |g z + 1 / 2|) hinv] at hmean
  change |walshCoefficients g ∅ + 1 / 2| * ρ ≤
    (1 / 2 : ℝ) * _ + (1 / 2 : ℝ) * _ + ε * ρ at hmean
  have hρ : (1 : ℝ) / 2 ≤ ρ := hdensity
  by_cases hsmall : |walshCoefficients g ∅ + 1 / 2| ≤ ε
  · linarith
  · have hprod := mul_nonneg (by linarith : 0 ≤ ρ - 1 / 2)
      (by linarith : 0 ≤ |walshCoefficients g ∅ + 1 / 2| - ε)
    nlinarith

/-- The complete score is close to anti-invariant about `-1/2`. -/
theorem rectangle_anti_invariance_bound {m : ℕ} (u : ClippingCube m)
    (g : ClippingCube m → ℝ) (O : Set (ClippingCube m)) (ε s : ℝ)
    (hs : 0 ≤ s) (hinv : ∀ z, cubeTranslation u z ∈ O ↔ z ∈ O)
    (hdensity : (1 : ℝ) / 2 ≤ uniformCubeMean (fun z => if z ∈ O then 1 else 0))
    (hrem : ∀ z, |invariantRemainder u g z| ≤ ε)
    (hobserved : uniformCubeMean (fun z => if z ∈ O then |g z + 1 / 2| else 0) ≤ s)
    (z : ClippingCube m) :
    |g z + g (cubeTranslation u z) + 1| ≤ 4 * (ε + s) := by
  have hconstant := rectangle_constant_coefficient_bound u g O ε s hs hinv hdensity hrem hobserved
  have hsym := invariantRemainder_symmetry u g z
  have heq : g z + g (cubeTranslation u z) + 1 =
      2 * ((walshCoefficients g ∅ + 1 / 2) + invariantRemainder u g z) := by linarith
  rw [heq, abs_mul]
  rw [abs_of_pos (by norm_num : (0 : ℝ) < 2)]
  have htriangle := abs_add_le (walshCoefficients g ∅ + 1 / 2) (invariantRemainder u g z)
  nlinarith [hrem z]

end NeuralGeneralization.OnlineLowerGeometry
