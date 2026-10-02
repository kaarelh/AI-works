import Paulsen.IndependentTangentCore
import Mathlib.Probability.ProductMeasure

/-!
# Independent rows of the ambient standard Gaussian

Reshaping a standard Gaussian frame into its rows gives the product of the
standard row Gaussian laws. The row-tangent seed is exactly the normalized
independent tangent construction, with the original row norm restored.
-/

open MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory

namespace Paulsen
noncomputable section

/-- Reshape a vectorized frame into Euclidean row vectors. -/
def gaussianRows {n d : ℕ} (g : FrameVector n d) :
    Fin n → EuclideanSpace ℝ (Fin d) :=
  fun i => WithLp.toLp 2 (fun j => g (i, j))

theorem continuous_gaussianRows {n d : ℕ} :
    Continuous (@gaussianRows n d) := by
  unfold gaussianRows
  fun_prop

/-- Flattening or grouping independent scalar Gaussians does not change their
joint law. This bridges the independent-row and conditioned-frame samples. -/
theorem gaussianRows_measurePreserving {n d : ℕ} :
    MeasurePreserving (@gaussianRows n d) (stdGaussian (FrameVector n d))
      (Measure.pi fun _ : Fin n => stdGaussian (EuclideanSpace ℝ (Fin d))) := by
  refine ⟨continuous_gaussianRows.measurable, ?_⟩
  rw [← map_pi_eq_stdGaussian, Measure.map_map continuous_gaussianRows.measurable (by fun_prop)]
  have hcurry := Measure.infinitePi_map_curry
    (fun (_ : Fin n) (_ : Fin d) => gaussianReal 0 1)
  simp only [Measure.infinitePi_eq_pi] at hcurry
  have hrows := (measurePreserving_pi
    (fun _ : Fin n => Measure.pi fun _ : Fin d => gaussianReal 0 1)
    (fun _ : Fin n => stdGaussian (EuclideanSpace ℝ (Fin d)))
    (fun _ => ⟨by fun_prop, map_pi_eq_stdGaussian⟩)).map_eq
  rw [← hcurry, Measure.map_map (by fun_prop) (by fun_prop)] at hrows
  exact hrows

/-- Original row direction, divided by its prescribed length. -/
def frameRowDirection {n d : ℕ} (X : Frame n d) (a : ℝ) (i : Fin n) :
    EuclideanSpace ℝ (Fin d) :=
  WithLp.toLp 2 (fun j => X i j / Real.sqrt a)

theorem norm_frameRowDirection {n d : ℕ} (X : Frame n d) {a : ℝ}
    (ha : 0 < a) (hrows : ∀ i, rowNormSq X i = a) (i : Fin n) :
    ‖frameRowDirection X a i‖ = 1 := by
  have hs : ‖frameRowDirection X a i‖ ^ 2 = 1 := by
    rw [EuclideanSpace.real_norm_sq_eq]
    change (∑ j, (X i j / Real.sqrt a) ^ 2) = 1
    simp only [div_pow, Real.sq_sqrt ha.le, ← Finset.sum_div]
    change rowNormSq X i / a = 1
    rw [hrows i, div_self ha.ne']
  nlinarith [norm_nonneg (frameRowDirection X a i)]

/-- The independent tangent noise acts row by row after the Gaussian reshape. -/
theorem rowTangentNoiseFactor_row {n d : ℕ} (X : Frame n d) {a : ℝ}
    (ha : 0 < a) (hrows : ∀ i, rowNormSq X i = a)
    (g : FrameVector n d) (i : Fin n) (j : Fin d) :
    frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g) i j =
      (1 / Real.sqrt (n : ℝ)) *
        independentTangentProjection (frameRowDirection X a i) (gaussianRows g i) j := by
  rw [rowTangentNoiseFactor_apply, rowTangentProjection_apply X ha hrows,
    independentTangentProjection_apply _ (norm_frameRowDirection X ha hrows i)]
  simp only [frameOfVector, PiLp.smul_apply, smul_eq_mul,
    PiLp.sub_apply, PiLp.inner_apply, Real.inner_apply]
  change (1 / Real.sqrt (n : ℝ)) *
    (g (i,j) - (∑ k, X i k * g (i,k)) / a * X i j) =
      (1 / Real.sqrt (n : ℝ)) *
        (g (i,j) - (∑ k, (X i k / Real.sqrt a) * g (i,k)) * (X i j / Real.sqrt a))
  congr 2
  have hsqrt := Real.sq_sqrt ha.le
  simp only [div_mul_eq_mul_div, ← Finset.sum_div]
  rw [← mul_div_assoc, div_div, ← pow_two, hsqrt]

theorem rowTangentNoiseFactor_rowNormSq {n d : ℕ} (X : Frame n d) {a : ℝ}
    (ha : 0 < a) (hrows : ∀ i, rowNormSq X i = a)
    (g : FrameVector n d) (i : Fin n) :
    rowNormSq (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g)) i =
      ‖independentTangentProjection (frameRowDirection X a i) (gaussianRows g i)‖ ^ 2 /
        (n : ℝ) := by
  unfold rowNormSq
  simp_rw [rowTangentNoiseFactor_row X ha hrows, mul_pow, div_pow, one_pow,
    Real.sq_sqrt (Nat.cast_nonneg n)]
  rw [← Finset.mul_sum, EuclideanSpace.real_norm_sq_eq]
  ring

/-- The row-independent normalized seed and the vectorized construction agree
pointwise, not only in law. -/
theorem tangentSeed_rowTangent_eq {n d : ℕ} (X : Frame n d)
    (hn : 0 < n) (hd : 0 < d) (hX : IsEqualNorm X)
    (t : ℝ) (g : FrameVector n d) (i : Fin n) (j : Fin d) :
    tangentSeed X (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
      ((d : ℝ) / n) t i j =
      Real.sqrt ((d : ℝ) / n) *
        independentTangentDirection (frameRowDirection X ((d : ℝ) / n) i) t
          (gaussianRows g i) j := by
  have hn' : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  have hd' : (d : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hd.ne'
  have ha : 0 < (d : ℝ) / n := div_pos (Nat.cast_pos.mpr hd) (Nat.cast_pos.mpr hn)
  have hsn : Real.sqrt (n : ℝ) ≠ 0 := (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hn)).ne'
  have hsd : Real.sqrt (d : ℝ) ≠ 0 := (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hd)).ne'
  have hsa : Real.sqrt ((d : ℝ) / n) ≠ 0 := (Real.sqrt_pos.mpr ha).ne'
  have hratio : t ^ 2 * tangentRatio ((d : ℝ) / n)
      (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g)) i =
      (t / Real.sqrt d) ^ 2 *
        ‖independentTangentProjection (frameRowDirection X ((d : ℝ) / n) i)
          (gaussianRows g i)‖ ^ 2 := by
    rw [tangentRatio, rowTangentNoiseFactor_rowNormSq X ha hX,
      div_pow, Real.sq_sqrt (Nat.cast_nonneg d)]
    field_simp
  simp only [tangentSeed, Matrix.of_apply, hratio, independentTangentDirection,
    PiLp.smul_apply, PiLp.add_apply, smul_eq_mul]
  rw [rowTangentNoiseFactor_row X ha hX]
  change (X i j + t * (1 / Real.sqrt n * _)) / _ =
    Real.sqrt ((d : ℝ) / n) * (1 / _ * (X i j / Real.sqrt ((d : ℝ) / n) + _))
  rw [Real.sqrt_div (Nat.cast_nonneg d)]
  field_simp

end
end Paulsen
