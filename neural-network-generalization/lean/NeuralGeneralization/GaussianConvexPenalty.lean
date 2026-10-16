import NeuralGeneralization.PrekopaLeindlerProduct

/-! Explicit positive continuous approximations to affine halfspace
intersections, including their actual joint logarithmic concavity. -/
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.GaussianConvexPenalty
open PrekopaLeindlerInterval GaussianCoordinateIntegration

theorem positivePart_square_convex {t : ℝ} (ht : t ∈ Icc 0 1) (u v : ℝ) :
    (max 0 (mix t u v))^2 ≤ (1-t)*(max 0 u)^2+t*(max 0 v)^2 := by
  have hα : 0 ≤ 1-t := sub_nonneg.mpr ht.2
  have hM : 0 ≤ mix t (max 0 u) (max 0 v) :=
    add_nonneg (mul_nonneg hα (le_max_left _ _)) (mul_nonneg ht.1 (le_max_left _ _))
  have hU : mix t u v ≤ mix t (max 0 u) (max 0 v) :=
    add_le_add (mul_le_mul_of_nonneg_left (le_max_right _ _) hα)
      (mul_le_mul_of_nonneg_left (le_max_right _ _) ht.1)
  have hmax := max_le hM hU
  have hsq := mul_nonneg (mul_nonneg ht.1 hα) (sq_nonneg (max 0 u-max 0 v))
  have hsqle := sq_le_sq₀ (le_max_left 0 (mix t u v)) hM |>.2 hmax
  dsimp only [mix] at hsqle ⊢
  nlinarith

variable {I J : Type*} [Fintype I] [Fintype J]

def residual (A : J → I → ℝ) (a b : J → ℝ) (t : ℝ) (z : I → ℝ) (j : J) : ℝ :=
  (∑ i, A j i * z i) - a j*t - b j

def penalty (A : J → I → ℝ) (a b : J → ℝ) (t : ℝ) (z : I → ℝ) : ℝ :=
  ∑ j, (max 0 (residual A a b t z j))^2

def approximation (A : J → I → ℝ) (a b : J → ℝ) (n : ℕ) (t : ℝ) (z : I → ℝ) : ℝ :=
  Real.exp (-(n : ℝ) * penalty A a b t z)

theorem penalty_nonneg (A : J → I → ℝ) (a b : J → ℝ) (t : ℝ) (z : I → ℝ) :
    0 ≤ penalty A a b t z := Finset.sum_nonneg fun _ _ => sq_nonneg _

theorem residual_mix (A : J → I → ℝ) (a b : J → ℝ) (s t θ : ℝ) (x y : I → ℝ) (j : J) :
    residual A a b (mix θ s t) (mixVec θ x y) j =
      mix θ (residual A a b s x j) (residual A a b t y j) := by
  simp only [residual, mixVec, mix, mul_add, Finset.sum_add_distrib]
  rw [show (∑ i, A j i * ((1-θ)*x i)) = (1-θ)*(∑ i, A j i*x i) by
    rw [Finset.mul_sum]; apply Finset.sum_congr rfl; intro i _; ring]
  rw [show (∑ i, A j i * (θ*y i)) = θ*(∑ i, A j i*y i) by
    rw [Finset.mul_sum]; apply Finset.sum_congr rfl; intro i _; ring]
  ring

theorem penalty_convex (A : J → I → ℝ) (a b : J → ℝ) (s t : ℝ)
    {θ : ℝ} (hθ : θ ∈ Icc 0 1) (x y : I → ℝ) :
    penalty A a b (mix θ s t) (mixVec θ x y) ≤
      (1-θ)*penalty A a b s x+θ*penalty A a b t y := by
  unfold penalty
  simp_rw [residual_mix]
  rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
  exact Finset.sum_le_sum fun j _ => positivePart_square_convex hθ _ _

theorem continuous_approximation (A : J → I → ℝ) (a b : J → ℝ) (n : ℕ) (t : ℝ) :
    Continuous (approximation A a b n t) := by
  unfold approximation penalty residual
  fun_prop

theorem approximation_pos (A : J → I → ℝ) (a b : J → ℝ) (n : ℕ) (t : ℝ) (z : I → ℝ) :
    0 < approximation A a b n t z := Real.exp_pos _

theorem approximation_le_one (A : J → I → ℝ) (a b : J → ℝ) (n : ℕ) (t : ℝ) (z : I → ℝ) :
    approximation A a b n t z ≤ 1 :=
  Real.exp_le_one_iff.mpr (mul_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr (Nat.cast_nonneg _))
    (penalty_nonneg A a b t z))

theorem approximation_logConcave (A : J → I → ℝ) (a b : J → ℝ) (n : ℕ) (s t : ℝ)
    {θ : ℝ} (hθ : θ ∈ Icc 0 1) (x y : I → ℝ) :
    approximation A a b n s x ^ (1-θ) * approximation A a b n t y ^ θ ≤
      approximation A a b n (mix θ s t) (mixVec θ x y) := by
  unfold approximation
  rw [← Real.exp_mul, ← Real.exp_mul, ← Real.exp_add]
  apply Real.exp_le_exp.mpr
  have h := mul_le_mul_of_nonneg_left (penalty_convex A a b s t hθ x y)
    (Nat.cast_nonneg n : (0 : ℝ) ≤ n)
  nlinarith

theorem integral_approximation_logConcave (A : J → I → ℝ) (a b : J → ℝ) (n : ℕ) (s t : ℝ)
    {θ : ℝ} (hθ : θ ∈ Icc 0 1) :
    (∫ x, approximation A a b n s x ∂law I) ^ (1-θ) *
      (∫ x, approximation A a b n t x ∂law I) ^ θ ≤
      ∫ x, approximation A a b n (mix θ s t) x ∂law I :=
  PrekopaLeindlerProduct.prekopa_leindler_product
    (continuous_approximation A a b n s) (continuous_approximation A a b n t)
    (continuous_approximation A a b n (mix θ s t))
    (approximation_pos A a b n s) (approximation_pos A a b n t)
    (approximation_pos A a b n (mix θ s t))
    (approximation_le_one A a b n s) (approximation_le_one A a b n t)
    (approximation_le_one A a b n (mix θ s t)) hθ
    (approximation_logConcave A a b n s t hθ)

end NeuralGeneralization.GaussianConvexPenalty
end
