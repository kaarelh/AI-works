import NeuralGeneralization.OnlineLowerCostIntegral
import Mathlib.Algebra.BigOperators.Ring.Finset

/-!+# Finite Fourier exchange for a Bernstein representation

This bridge keeps the cost function, actual degrees, Fourier signs and
exponential factors explicit. The analytic representation is an input;
cost separation is a conclusion after the path Fourier identity is used.
-/

noncomputable section
open MeasureTheory
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower

theorem finite_bernstein_fourier {α ι : Type*} [MeasurableSpace α] [Fintype ι]
    (μ : Measure α) (degree character : ι → ℝ) (cost : ℝ → ℝ)
    (A B : ℝ) (laplaceTerm : ι → α → ℝ)
    (hint : ∀ s, Integrable (laplaceTerm s) μ)
    (hcost : ∀ s, cost (degree s) = A * degree s + B - ∫ t, laplaceTerm s t ∂μ)
    (hconst : ∑ s, character s = 0)
    (hlinear : ∑ s, character s * degree s = 0) :
    (∑ s, character s * cost (degree s)) =
      -(∫ t, ∑ s, character s * laplaceTerm s t ∂μ) := by
  classical
  rw [integral_finsetSum _ (fun s _ => (hint s).const_mul (character s))]
  simp_rw [integral_const_mul]
  simp_rw [hcost, mul_sub, mul_add]
  rw [Finset.sum_sub_distrib, Finset.sum_add_distrib]
  have hA : (∑ s, character s * (A * degree s)) = 0 := by
    calc
      _ = A * ∑ s, character s * degree s := by rw [Finset.mul_sum]; congr 1; ext s; ring
      _ = 0 := by rw [hlinear, mul_zero]
  have hB : (∑ s, character s * B) = 0 := by rw [← Finset.sum_mul, hconst, zero_mul]
  rw [hA, hB]
  ring

theorem finite_bernstein_fourier_normalized {α ι : Type*}
    [MeasurableSpace α] [Fintype ι]
    (μ : Measure α) (degree character : ι → ℝ) (cost : ℝ → ℝ)
    (A B normalization : ℝ) (laplaceTerm : ι → α → ℝ)
    (hint : ∀ s, Integrable (laplaceTerm s) μ)
    (hcost : ∀ s, cost (degree s) = A * degree s + B - ∫ t, laplaceTerm s t ∂μ)
    (hconst : ∑ s, character s = 0)
    (hlinear : ∑ s, character s * degree s = 0) :
    normalization * (∑ s, character s * cost (degree s)) =
      -(∫ t, normalization * ∑ s, character s * laplaceTerm s t ∂μ) := by
  rw [integral_const_mul, finite_bernstein_fourier μ degree character cost A B
    laplaceTerm hint hcost hconst hlinear]
  ring

end NeuralGeneralization.OnlineLower
