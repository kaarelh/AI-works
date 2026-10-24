import NeuralGeneralization.BatchTwoNonGaussianLindebergJet
import Mathlib.Analysis.Calculus.MeanValue

/-! The relative third-derivative bound for the actual quadratic tanh tilt.
Its loss is polynomial in the tilt budget, not exponential in that budget. -/

noncomputable section
namespace NeuralGeneralization.BatchTwoNonGaussian
open TanhDifferential

def lindebergPolynomial (G : ℝ) : ℝ := 24 * G + 36 * G ^ 2 + 8 * G ^ 3

def exponentialFirst (f f' : ℝ → ℝ) (t : ℝ) : ℝ := Real.exp (f t) * f' t
def exponentialSecond (f f' f'' : ℝ → ℝ) (t : ℝ) : ℝ :=
  Real.exp (f t) * (f'' t + f' t ^ 2)
def exponentialThird (f f' f'' f''' : ℝ → ℝ) (t : ℝ) : ℝ :=
  Real.exp (f t) * (f''' t + 3 * f' t * f'' t + f' t ^ 3)

theorem hasDerivAt_expFirst {f f' f'' : ℝ → ℝ}
    (hf : ∀ t, HasDerivAt f (f' t) t) (hf' : ∀ t, HasDerivAt f' (f'' t) t) (t : ℝ) :
    HasDerivAt (exponentialFirst f f') (exponentialSecond f f' f'' t) t := by
  have h := (hf t).exp.mul (hf' t)
  convert! h using 1 <;> (try dsimp [exponentialFirst, exponentialSecond]) <;> ring

theorem hasDerivAt_expSecond {f f' f'' f''' : ℝ → ℝ}
    (hf : ∀ t, HasDerivAt f (f' t) t) (hf' : ∀ t, HasDerivAt f' (f'' t) t)
    (hf'' : ∀ t, HasDerivAt f'' (f''' t) t) (t : ℝ) :
    HasDerivAt (exponentialSecond f f' f'') (exponentialThird f f' f'' f''' t) t := by
  have h := (hf t).exp.mul ((hf'' t).add ((hf' t).pow 2))
  convert! h using 1 <;> (try dsimp [exponentialSecond, exponentialThird]) <;> ring

theorem exponentialThird_bound {f f' f'' f''' : ℝ → ℝ} (t G b : ℝ)
    (hG : 0 ≤ G) (hb : 0 ≤ b)
    (h1 : |f' t| ≤ 2 * G * b) (h2 : |f'' t| ≤ 6 * G * b ^ 2)
    (h3 : |f''' t| ≤ 24 * G * b ^ 3) :
    |exponentialThird f f' f'' f''' t| ≤
      lindebergPolynomial G * b ^ 3 * Real.exp (f t) := by
  have hpoly : |f''' t + 3 * f' t * f'' t + f' t ^ 3| ≤ lindebergPolynomial G * b ^ 3 := by
    calc
      _ ≤ |f''' t| + |3 * f' t * f'' t| + |f' t ^ 3| :=
        (abs_add_le _ _).trans (add_le_add (abs_add_le _ _) le_rfl)
      _ ≤ 24 * G * b ^ 3 + 3 * (2 * G * b) * (6 * G * b ^ 2) + (2 * G * b) ^ 3 := by
        simp only [abs_mul, abs_pow, abs_of_nonneg (by norm_num : (0 : ℝ) ≤ 3)]
        gcongr
      _ = _ := by unfold lindebergPolynomial; ring
  unfold exponentialThird
  rw [abs_mul, abs_of_pos (Real.exp_pos _)]
  exact (mul_le_mul_of_nonneg_left hpoly (Real.exp_nonneg _)).trans_eq (mul_comm _ _)

section FiniteField
variable {I : Type*} [Fintype I]

theorem hasDerivAt_expPotential_second (Γ : I → I → ℝ) (z a : I → ℝ) (t : ℝ) :
    HasDerivAt
      (exponentialSecond (potentialLine Γ z a) (potentialLineFirst Γ z a) (potentialLineSecond Γ z a))
      (exponentialThird (potentialLine Γ z a) (potentialLineFirst Γ z a)
        (potentialLineSecond Γ z a) (potentialLineThird Γ z a) t) t :=
  hasDerivAt_expSecond (hasDerivAt_potentialLine Γ z a)
    (hasDerivAt_potentialLineFirst Γ z a) (hasDerivAt_potentialLineSecond Γ z a) t

/-- Exact dimension-independent `P(G)` bound in the paper's Lindeberg proof. -/
theorem expPotential_third_bound (Γ : I → I → ℝ) (z a : I → ℝ) (t G b : ℝ)
    (hG : 0 ≤ G) (hΓ : couplingMass Γ ≤ G) (hb : 0 ≤ b) (ha : ∀ i, |a i| ≤ b) :
    |exponentialThird (potentialLine Γ z a) (potentialLineFirst Γ z a)
      (potentialLineSecond Γ z a) (potentialLineThird Γ z a) t| ≤
      lindebergPolynomial G * b ^ 3 * Real.exp (potentialLine Γ z a t) := by
  obtain ⟨h1, h2, h3⟩ := potentialLine_bounds Γ z a t G b hΓ hb ha
  exact exponentialThird_bound t G b hG hb h1 h2 h3

end FiniteField
end NeuralGeneralization.BatchTwoNonGaussian
