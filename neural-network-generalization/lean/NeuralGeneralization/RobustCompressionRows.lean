import NeuralGeneralization.RobustCompressionCovariance
import NeuralGeneralization.RobustGaussianGeometryCovariance

/-!
# Actual finite coefficient rows in entropy reconstruction

The active coefficients and Gaussian residual coefficients below act on the
selected original hidden activations. Their evaluation identity is exact, so
the compressed object is an ordinary neural-network row rather than an abstract
Gaussian process predictor.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators RealInnerProductSpace

namespace NeuralGeneralization.RobustCompressionRows
open RobustCompressionClipping

variable {N m q : ℕ}

/-- Active feature vector of the finitely sampled sources. -/
def sampledActive (c : Fin N → EuclideanSpace ℝ (Fin q))
    (I : Fin m → Fin N) (h : Fin N → ℝ) (a : ℝ) : EuclideanSpace ℝ (Fin q) :=
  (Real.sqrt (1 + a))⁻¹ • finiteAverage (fun j => h (I j) • c (I j))

/-- A literal finite neural-network row. The caller may clip the residual
coordinates before passing them here. -/
def reconstructedRow (H : EuclideanSpace ℝ (Fin q))
    (c : Fin N → EuclideanSpace ℝ (Fin q)) (I : Fin m → Fin N)
    (a t : ℝ) (ξ : Fin m → ℝ) (j : Fin m) : ℝ :=
  ⟪H, c (I j)⟫ / ((m : ℝ) * Real.sqrt (1 + a)) +
    t * ξ j / Real.sqrt (m : ℝ)

/-- The finite row has exactly the intended active mean and residual linear
Gaussian evaluation. -/
theorem reconstructedRow_evaluation (H : EuclideanSpace ℝ (Fin q))
    (c : Fin N → EuclideanSpace ℝ (Fin q)) (I : Fin m → Fin N)
    (h : Fin N → ℝ) (a t : ℝ) (ξ : Fin m → ℝ) :
    (∑ j, reconstructedRow H c I a t ξ j * h (I j)) =
      ⟪H, sampledActive c I h a⟫ +
        t / Real.sqrt (m : ℝ) * ∑ j, ξ j * h (I j) := by
  unfold reconstructedRow sampledActive finiteAverage
  simp only [add_mul, Finset.sum_add_distrib, real_inner_smul_right, inner_sum]
  simp only [div_eq_mul_inv, mul_inv_rev]
  simp only [Finset.mul_sum, Finset.sum_mul]
  congr 1 <;> apply Finset.sum_congr rfl <;> intro j hj <;> ring

/-- Every candidate row coefficient is bounded before any later adaptive
source choice. No union bound over the virtual target width is involved. -/
theorem reconstructedRow_bound (H : EuclideanSpace ℝ (Fin q))
    (c : Fin N → EuclideanSpace ℝ (Fin q)) (I : Fin m → Fin N)
    {a t BH T BG : ℝ} (ha : 0 ≤ a) (ht : |t| ≤ 1)
    (hH : ‖H‖ ≤ BH) (hc : ∀ i, ‖c i‖ ≤ T)
    (hBG : 0 ≤ BG) (ξ : Fin m → ℝ) (hξ : ∀ j, |ξ j| ≤ BG)
    (j : Fin m) :
    |reconstructedRow H c I a t ξ j| ≤ BH * T / (m : ℝ) + BG / Real.sqrt (m : ℝ) := by
  have hBH : 0 ≤ BH := (norm_nonneg H).trans hH
  have hT : 0 ≤ T := (norm_nonneg (c (I j))).trans (hc (I j))
  have hs : 1 ≤ Real.sqrt (1 + a) := by
    apply (Real.le_sqrt (by norm_num) (by positivity)).mpr
    nlinarith
  have hinner : |⟪H, c (I j)⟫| ≤ BH * T :=
    (abs_real_inner_le_norm _ _).trans (mul_le_mul hH (hc _) (norm_nonneg _) hBH)
  unfold reconstructedRow
  calc
    |⟪H, c (I j)⟫ / ((m : ℝ) * Real.sqrt (1 + a)) +
        t * ξ j / Real.sqrt (m : ℝ)| ≤
      |⟪H, c (I j)⟫ / ((m : ℝ) * Real.sqrt (1 + a))| +
        |t * ξ j / Real.sqrt (m : ℝ)| := abs_add_le _ _
    _ ≤ BH * T / (m : ℝ) + BG / Real.sqrt (m : ℝ) := by
      apply add_le_add
      · rw [abs_div, abs_of_nonneg (by positivity : 0 ≤ (m : ℝ) * Real.sqrt (1 + a))]
        calc
          _ ≤ (BH * T) / ((m : ℝ) * Real.sqrt (1 + a)) :=
            div_le_div_of_nonneg_right hinner (by positivity)
          _ ≤ (BH * T) / (m : ℝ) := by
            by_cases hm : m = 0
            · simp [hm]
            · apply div_le_div_of_nonneg_left (mul_nonneg hBH hT) (by positivity)
              nlinarith [Nat.cast_nonneg (α := ℝ) m]
      · rw [abs_div, abs_mul, abs_of_nonneg (Real.sqrt_nonneg _)]
        apply div_le_div_of_nonneg_right _ (Real.sqrt_nonneg _)
        calc |t| * |ξ j| ≤ 1 * BG := mul_le_mul ht (hξ j) (abs_nonneg _) (by norm_num)
             _ = _ := one_mul _

end NeuralGeneralization.RobustCompressionRows
