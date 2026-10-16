import NeuralGeneralization.FiniteSymmetrization
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Series

/-!
# Actual subgaussian increments of the squared one-sided process

The MGF is computed under the literal uniform sign cube. The increment
metric is compared with the symmetric rank-one metric in Lee's argument.
This file does not assume or establish the remaining chaining bound.
-/

noncomputable section
namespace NeuralGeneralization.SquaredSampling
open scoped BigOperators

/-- Exact factorization of the Rademacher moment generating function. -/
theorem finite_rademacher_mgf_eq (n : ℕ) (a : Fin n → ℝ) (t : ℝ) :
    finiteMean (fun ε : Fin n → Bool =>
      Real.exp (t * ∑ i, cubeCoordinateSign (ε i) * a i)) =
        ∏ i, Real.cosh (t * a i) := by
  have hpoint (ε : Fin n → Bool) :
      Real.exp (t * ∑ i, cubeCoordinateSign (ε i) * a i) =
        ∏ i, Real.exp (t * cubeCoordinateSign (ε i) * a i) := by
    rw [Finset.mul_sum, Real.exp_sum]
    apply Finset.prod_congr rfl
    intro i _
    congr 1
    ring
  simp_rw [hpoint]
  rw [finiteMean_pi_prod (fun i : Fin n => fun b : Bool => Real.exp (t * cubeCoordinateSign b * a i))]
  apply Finset.prod_congr rfl
  intro i _
  simp [finiteMean, cubeCoordinateSign, Real.cosh_eq, neg_mul]


/-- The actual Rademacher MGF has the exact variance-proxy constant `1/2`. -/
theorem finite_rademacher_mgf_le (n : ℕ) (a : Fin n → ℝ) (t : ℝ) :
    finiteMean (fun ε : Fin n → Bool =>
      Real.exp (t * ∑ i, cubeCoordinateSign (ε i) * a i)) ≤
        Real.exp (t ^ 2 * (∑ i, a i ^ 2) / 2) := by
  rw [finite_rademacher_mgf_eq]
  calc
    _ ≤ ∏ i, Real.exp ((t * a i) ^ 2 / 2) := by
      apply Finset.prod_le_prod
      · intro i _; exact (Real.cosh_pos _).le
      · intro i _; exact Real.cosh_le_exp_half_sq _
    _ = _ := by
      rw [← Real.exp_sum]
      congr 1
      simp only [mul_pow, Finset.sum_div, Finset.mul_sum]

/-- Squaring a Lipschitz response gives the symmetric rank-one increment
bound. The right hand side involves ordinary symmetric absolute values. -/
theorem squared_lipschitz_increment (ψ : ℝ → ℝ) (hzero : ψ 0 = 0)
    (hLip : ∀ x y, |ψ x - ψ y| ≤ |x - y|) (x y : ℝ) :
    (ψ x ^ 2 - ψ y ^ 2) ^ 2 ≤ 2 * (x - y) ^ 2 * (x ^ 2 + y ^ 2) := by
  have hx : |ψ x| ≤ |x| := by simpa only [hzero, sub_zero] using hLip x 0
  have hy : |ψ y| ≤ |y| := by simpa only [hzero, sub_zero] using hLip y 0
  have hsum : |ψ x + ψ y| ≤ |x| + |y| :=
    (abs_add_le _ _).trans (add_le_add hx hy)
  have hdiff := hLip x y
  have hsquare : (ψ x ^ 2 - ψ y ^ 2) ^ 2 =
      |ψ x - ψ y| ^ 2 * |ψ x + ψ y| ^ 2 := by
    rw [sq_abs, sq_abs]
    ring
  rw [hsquare]
  have h₁ := pow_le_pow_left₀ (abs_nonneg _) hdiff 2
  have h₂ := pow_le_pow_left₀ (abs_nonneg _) hsum 2
  have hprod := mul_le_mul h₁ h₂ (sq_nonneg _) (sq_nonneg _)
  have hnorm : (|x| + |y|) ^ 2 ≤ 2 * (x ^ 2 + y ^ 2) := by
    nlinarith [sq_nonneg (|x| - |y|), sq_abs x, sq_abs y]
  have hlast := mul_le_mul_of_nonneg_left hnorm (sq_nonneg (x-y))
  simp only [sq_abs] at hprod
  calc
    _ ≤ (x - y) ^ 2 * (|x| + |y|) ^ 2 := by simpa only [sq_abs] using hprod
    _ ≤ _ := by nlinarith only [hlast]

/-- The actual negative-part response is 1-Lipschitz. -/
theorem negativePart_lipschitz (x y : ℝ) :
    |max 0 (-x) - max 0 (-y)| ≤ |x - y| := by
  have h := abs_max_sub_max_le_max (0 : ℝ) (-x) 0 (-y)
  simpa only [sub_self, abs_zero, neg_sub_neg, abs_sub_comm, max_eq_right (abs_nonneg (x-y))] using h

def linearEvaluation {D : ℕ} (a u : Fin D → ℝ) : ℝ := ∑ j, a j * u j

/-- Lee's symmetric rank-one squared quasimetric, written explicitly. -/
def rankOneMetricSquared {m D : ℕ} (a : Fin m → Fin D → ℝ)
    (u v : Fin D → ℝ) : ℝ :=
  ∑ i, (linearEvaluation (a i) u - linearEvaluation (a i) v) ^ 2 *
    (linearEvaluation (a i) u ^ 2 + linearEvaluation (a i) v ^ 2)

/-- The actual squared one-sided Rademacher process. -/
def squaredOneSidedProcess {m D : ℕ} (a : Fin m → Fin D → ℝ)
    (ε : Fin m → Bool) (u : Fin D → ℝ) : ℝ :=
  ∑ i, cubeCoordinateSign (ε i) * (max 0 (-linearEvaluation (a i) u)) ^ 2

theorem squaredOneSided_increment_energy {m D : ℕ} (a : Fin m → Fin D → ℝ)
    (u v : Fin D → ℝ) :
    (∑ i, ((max 0 (-linearEvaluation (a i) u)) ^ 2 -
        (max 0 (-linearEvaluation (a i) v)) ^ 2) ^ 2) ≤
      2 * rankOneMetricSquared a u v := by
  rw [rankOneMetricSquared, Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  have h := squared_lipschitz_increment (fun x => max 0 (-x)) (by norm_num)
    negativePart_lipschitz (linearEvaluation (a i) u) (linearEvaluation (a i) v)
  nlinarith only [h]

/-- Actual exponential-moment increment control, with no inserted
subgaussian-process assumption. This is the probabilistic input to the
remaining generic-chaining estimate. -/
theorem squaredOneSided_increment_mgf {m D : ℕ} (a : Fin m → Fin D → ℝ)
    (u v : Fin D → ℝ) (t : ℝ) :
    finiteMean (fun ε : Fin m → Bool =>
      Real.exp (t * (squaredOneSidedProcess a ε u - squaredOneSidedProcess a ε v))) ≤
      Real.exp (t ^ 2 * rankOneMetricSquared a u v) := by
  have heq (ε : Fin m → Bool) :
      squaredOneSidedProcess a ε u - squaredOneSidedProcess a ε v =
      ∑ i, cubeCoordinateSign (ε i) *
        ((max 0 (-linearEvaluation (a i) u)) ^ 2 -
         (max 0 (-linearEvaluation (a i) v)) ^ 2) := by
    unfold squaredOneSidedProcess
    rw [← Finset.sum_sub_distrib]
    apply Finset.sum_congr rfl
    intro i _
    ring
  simp_rw [heq]
  apply (finite_rademacher_mgf_le m _ t).trans
  apply Real.exp_le_exp.mpr
  have h := mul_le_mul_of_nonneg_left (squaredOneSided_increment_energy a u v) (sq_nonneg t)
  nlinarith only [h]

end NeuralGeneralization.SquaredSampling
