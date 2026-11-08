import NeuralGeneralization.OnlineLowerCostBernsteinFinite
import NeuralGeneralization.OnlineLowerGeometryWalsh
import Mathlib.Analysis.SpecialFunctions.ExpDeriv

/-!+# Bernstein Fourier costs of actual Boolean code columns

The degree function has one increment for each negative column character.
The constant and linear terms vanish at every nonzero syndrome which is
not itself a column. This supplies the exact hypotheses of the finite
Bernstein exchange, with no separation or Fourier-sign assumption.
-/

noncomputable section
open MeasureTheory
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower

def columnDegree {m : ℕ} {ι : Type*} [Fintype ι]
    (n₀ : ℝ) (column : ι → Finset (Fin m)) (increment : ι → ℝ)
    (s : ClippingCube m) : ℝ :=
  n₀ + ∑ j, increment j / 2 * (1 - walshCharacter (column j) s)

theorem character_sum_zero {m : ℕ} (v : Finset (Fin m)) (hv : v ≠ ∅) :
    (∑ s : ClippingCube m, walshCharacter v s) = 0 := by
  have h := walshCharacter_orthogonal v ∅
  simpa [walshCharacter, hv] using h

theorem columnDegree_character_sum_zero {m : ℕ} {ι : Type*} [Fintype ι]
    (n₀ : ℝ) (column : ι → Finset (Fin m)) (increment : ι → ℝ)
    (v : Finset (Fin m)) (hv : v ≠ ∅) (hcolumn : ∀ j, v ≠ column j) :
    (∑ s : ClippingCube m, walshCharacter v s * columnDegree n₀ column increment s) = 0 := by
  classical
  unfold columnDegree
  simp_rw [mul_add, Finset.mul_sum]
  rw [Finset.sum_add_distrib, ← Finset.sum_mul, character_sum_zero v hv, zero_mul,
    zero_add, Finset.sum_comm]
  apply Finset.sum_eq_zero
  intro j _
  have horth := walshCharacter_orthogonal v (column j)
  rw [if_neg (hcolumn j)] at horth
  calc
    (∑ s : ClippingCube m, walshCharacter v s *
        (increment j / 2 * (1 - walshCharacter (column j) s))) =
      increment j / 2 * ((∑ s : ClippingCube m, walshCharacter v s) -
        ∑ s : ClippingCube m, walshCharacter v s * walshCharacter (column j) s) := by
      rw [← Finset.sum_sub_distrib, Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro s _
      ring
    _ = 0 := by rw [character_sum_zero v hv, horth]; ring

theorem columnCost_bernstein {α ι : Type*} [MeasurableSpace α] [Fintype ι]
    {m : ℕ} (μ : Measure α) (n₀ : ℝ) (column : ι → Finset (Fin m))
    (increment : ι → ℝ) (cost : ℝ → ℝ) (A B : ℝ)
    (laplaceTerm : ClippingCube m → α → ℝ)
    (hint : ∀ s, Integrable (laplaceTerm s) μ)
    (hcost : ∀ s, cost (columnDegree n₀ column increment s) =
      A * columnDegree n₀ column increment s + B - ∫ t, laplaceTerm s t ∂μ)
    (v : Finset (Fin m)) (hv : v ≠ ∅) (hcolumn : ∀ j, v ≠ column j) :
    walshCoefficients (fun s => cost (columnDegree n₀ column increment s)) v =
      -(∫ t, (∑ s : ClippingCube m, walshCharacter v s * laplaceTerm s t) /
        Fintype.card (ClippingCube m) ∂μ) := by
  have h := finite_bernstein_fourier_normalized μ (columnDegree n₀ column increment)
    (walshCharacter v) cost A B (1 / Fintype.card (ClippingCube m)) laplaceTerm hint hcost
    (character_sum_zero v hv)
    (columnDegree_character_sum_zero n₀ column increment v hv hcolumn)
  simpa only [walshCoefficients, uniformCubeMean, mul_comm, one_div, ← div_eq_inv_mul]
    using h

def columnLaplaceAlpha (δ t : ℝ) : ℝ := (1 + Real.exp (-δ * t)) / 2
def columnLaplaceFugacity (δ t : ℝ) : ℝ :=
  (1 - Real.exp (-δ * t)) / (1 + Real.exp (-δ * t))

theorem columnLaplaceAlpha_pos (δ t : ℝ) : 0 < columnLaplaceAlpha δ t := by
  unfold columnLaplaceAlpha
  positivity

theorem binary_laplace_factor (δ t c : ℝ) (hc : c ^ 2 = 1) :
    Real.exp (-(δ / 2 * (1 - c)) * t) =
      columnLaplaceAlpha δ t * (1 + columnLaplaceFugacity δ t * c) := by
  have he : 1 + Real.exp (-δ * t) ≠ 0 := by positivity
  have hs : c = 1 ∨ c = -1 := by
    have h : (c - 1) * (c + 1) = 0 := by nlinarith
    rcases mul_eq_zero.mp h with h | h
    · exact Or.inl (by linarith)
    · exact Or.inr (by linarith)
  rcases hs with rfl | rfl
  · simp only [sub_self, mul_zero, neg_zero, zero_mul, Real.exp_zero, mul_one]
    unfold columnLaplaceAlpha columnLaplaceFugacity
    field_simp
    ring
  · rw [show -(δ / 2 * (1 - (-1 : ℝ))) * t = -δ * t by ring]
    unfold columnLaplaceAlpha columnLaplaceFugacity
    field_simp
    ring

/-- Exact exponential Fourier product for arbitrary finite columns. -/
theorem exp_columnDegree {m : ℕ} {ι : Type*} [Fintype ι]
    (n₀ t : ℝ) (column : ι → Finset (Fin m)) (increment : ι → ℝ)
    (s : ClippingCube m) :
    Real.exp (-columnDegree n₀ column increment s * t) =
      (Real.exp (-n₀ * t) * ∏ j, columnLaplaceAlpha (increment j) t) *
        ∏ j, (1 + columnLaplaceFugacity (increment j) t * walshCharacter (column j) s) := by
  classical
  have hexp : -columnDegree n₀ column increment s * t =
      -n₀ * t + ∑ j, -(increment j / 2 * (1 - walshCharacter (column j) s)) * t := by
    unfold columnDegree
    rw [← Finset.sum_mul, Finset.sum_neg_distrib]
    ring
  rw [hexp, Real.exp_add, Real.exp_sum]
  simp_rw [binary_laplace_factor _ _ _ (walshCharacter_sq _ _)]
  rw [Finset.prod_mul_distrib]
  ring

end NeuralGeneralization.OnlineLower
