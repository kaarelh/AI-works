import NeuralGeneralization.BatchTwoNonGaussianLindebergExponential
import Mathlib.Analysis.Calculus.Taylor
import Mathlib.Analysis.SpecialFunctions.Trigonometric.DerivHyp

/-! Taylor's order-three remainder for the actual relative Lindeberg observable. -/

noncomputable section
open Set
namespace NeuralGeneralization.BatchTwoNonGaussian

theorem quadratic_taylor_remainder {f f₁ f₂ f₃ : ℝ → ℝ}
    (hsmooth : ContDiff ℝ 3 f)
    (h₁ : ∀ t, HasDerivAt f (f₁ t) t)
    (h₂ : ∀ t, HasDerivAt f₁ (f₂ t) t)
    (h₃ : ∀ t, HasDerivAt f₂ (f₃ t) t)
    (t B : ℝ) (hB : 0 ≤ B) (hbound : ∀ s ∈ uIcc 0 t, |f₃ s| ≤ B) :
    |f t - f 0 - t * f₁ 0 - t ^ 2 * f₂ 0 / 2| ≤ B * |t| ^ 3 / 6 := by
  by_cases ht : t = 0
  · subst t
    simp
  have hne : (0 : ℝ) ≠ t := Ne.symm ht
  have hd1 : deriv f = f₁ := funext fun s => (h₁ s).deriv
  have hd2 : deriv f₁ = f₂ := funext fun s => (h₂ s).deriv
  have hd3 : deriv f₂ = f₃ := funext fun s => (h₃ s).deriv
  have hi1 : iteratedDeriv 1 f = f₁ := by rw [iteratedDeriv_one, hd1]
  have hi2 : iteratedDeriv 2 f = f₂ := by rw [show 2 = 1 + 1 from rfl, iteratedDeriv_succ, hi1, hd2]
  have hi3 : iteratedDeriv 3 f = f₃ := by rw [show 3 = 2 + 1 from rfl, iteratedDeriv_succ, hi2, hd3]
  have hU : UniqueDiffOn ℝ (uIcc 0 t) := uniqueDiffOn_uIcc hne
  have hw1 : iteratedDerivWithin 1 f (uIcc 0 t) 0 = f₁ 0 := by
    rw [iteratedDerivWithin_eq_iteratedDeriv hU
      ((hsmooth.of_le (by norm_num : (1 : WithTop ℕ∞) ≤ 3)).contDiffAt) (left_mem_uIcc), hi1]
  have hw2 : iteratedDerivWithin 2 f (uIcc 0 t) 0 = f₂ 0 := by
    rw [iteratedDerivWithin_eq_iteratedDeriv hU
      ((hsmooth.of_le (by norm_num : (2 : WithTop ℕ∞) ≤ 3)).contDiffAt) (left_mem_uIcc), hi2]
  have htaylor : taylorWithinEval f 2 (uIcc 0 t) 0 t = f 0 + t * f₁ 0 + t ^ 2 * f₂ 0 / 2 := by
    rw [taylorWithinEval_succ f 1, taylorWithinEval_succ f 0, taylor_within_zero_eval]
    rw [hw1, hw2]
    norm_num
    ring
  obtain ⟨s, hs, heq⟩ := taylor_mean_remainder_lagrange_iteratedDeriv (n := 2) hne
    (by convert hsmooth.contDiffOn using 1 <;> norm_num)
  rw [hi3, htaylor] at heq
  have hres : f t - f 0 - t * f₁ 0 - t ^ 2 * f₂ 0 / 2 = f₃ s * t ^ 3 / 6 := by
    norm_num at heq
    linarith
  rw [hres, abs_div, abs_mul, abs_pow]
  norm_num
  exact div_le_div_of_nonneg_right
    (mul_le_mul_of_nonneg_right (hbound s ⟨hs.1.le, hs.2.le⟩) (pow_nonneg (abs_nonneg t) 3))
    (by norm_num)

@[fun_prop] theorem contDiff_tanh_all {n : WithTop ℕ∞} : ContDiff ℝ n Real.tanh := by
  have heq : Real.tanh = fun x => Real.sinh x / Real.cosh x :=
    funext Real.tanh_eq_sinh_div_cosh
  rw [heq]
  exact Real.contDiff_sinh.div Real.contDiff_cosh (fun x => (Real.cosh_pos x).ne')

section FiniteField
variable {I : Type*} [Fintype I]

@[fun_prop] theorem contDiff_potentialLine (Γ : I → I → ℝ) (z a : I → ℝ) {n : WithTop ℕ∞} :
    ContDiff ℝ n (potentialLine Γ z a) := by
  unfold potentialLine pairLine lineTanh
  fun_prop

def expPotential (Γ : I → I → ℝ) (z a : I → ℝ) (t : ℝ) : ℝ :=
  Real.exp (potentialLine Γ z a t)

theorem hasDerivAt_expPotential (Γ : I → I → ℝ) (z a : I → ℝ) (t : ℝ) :
    HasDerivAt (expPotential Γ z a)
      (exponentialFirst (potentialLine Γ z a) (potentialLineFirst Γ z a) t) t := by
  simpa [expPotential, exponentialFirst] using!
    (hasDerivAt_potentialLine Γ z a t).exp

@[fun_prop] theorem contDiff_expPotential (Γ : I → I → ℝ) (z a : I → ℝ) {n : WithTop ℕ∞} :
    ContDiff ℝ n (expPotential Γ z a) := by
  unfold expPotential
  fun_prop

theorem potentialLine_lipschitz (Γ : I → I → ℝ) (z a : I → ℝ) (t G b : ℝ)
    (hΓ : TanhDifferential.couplingMass Γ ≤ G) (hb : 0 ≤ b) (ha : ∀ i, |a i| ≤ b) :
    |potentialLine Γ z a t - potentialLine Γ z a 0| ≤ 2 * G * b * |t| := by
  have h := Convex.norm_image_sub_le_of_norm_deriv_le
    (f := potentialLine Γ z a) (s := Set.univ)
    (fun s _ => (hasDerivAt_potentialLine Γ z a s).differentiableAt)
    (fun s _ => by
      rw [(hasDerivAt_potentialLine Γ z a s).deriv, Real.norm_eq_abs]
      exact (potentialLine_bounds Γ z a s G b hΓ hb ha).1)
    convex_univ (mem_univ 0) (mem_univ t)
  simpa only [Real.norm_eq_abs, sub_zero] using h

theorem expPotential_relative_bounds (Γ : I → I → ℝ) (z a : I → ℝ) (t G b : ℝ)
    (hΓ : TanhDifferential.couplingMass Γ ≤ G) (hb : 0 ≤ b) (ha : ∀ i, |a i| ≤ b) :
    Real.exp (-(2 * G * b * |t|)) * expPotential Γ z a 0 ≤ expPotential Γ z a t ∧
      expPotential Γ z a t ≤ Real.exp (2 * G * b * |t|) * expPotential Γ z a 0 := by
  have h := abs_le.mp (potentialLine_lipschitz Γ z a t G b hΓ hb ha)
  unfold expPotential
  constructor
  · rw [← Real.exp_add]
    apply Real.exp_le_exp.mpr
    linarith
  · rw [← Real.exp_add]
    apply Real.exp_le_exp.mpr
    linarith

/-- The exact relative Taylor error: the reference value is `f(0)`, so later
normalization does not pay an exponential factor in the tilt budget. -/
theorem expPotential_relative_remainder (Γ : I → I → ℝ) (z a : I → ℝ) (t G b : ℝ)
    (hG : 0 ≤ G) (hΓ : TanhDifferential.couplingMass Γ ≤ G)
    (hb : 0 ≤ b) (ha : ∀ i, |a i| ≤ b) :
    |expPotential Γ z a t - expPotential Γ z a 0 -
        t * exponentialFirst (potentialLine Γ z a) (potentialLineFirst Γ z a) 0 -
        t ^ 2 * exponentialSecond (potentialLine Γ z a) (potentialLineFirst Γ z a)
          (potentialLineSecond Γ z a) 0 / 2| ≤
      lindebergPolynomial G * b ^ 3 / 6 * |t| ^ 3 *
        Real.exp (2 * G * b * |t|) * expPotential Γ z a 0 := by
  let B := lindebergPolynomial G * b ^ 3 *
    (Real.exp (2 * G * b * |t|) * expPotential Γ z a 0)
  have hP : 0 ≤ lindebergPolynomial G := by unfold lindebergPolynomial; positivity
  have hB : 0 ≤ B := by dsimp [B, expPotential]; positivity
  have hbound (s : ℝ) (hs : s ∈ uIcc 0 t) :
      |exponentialThird (potentialLine Γ z a) (potentialLineFirst Γ z a)
        (potentialLineSecond Γ z a) (potentialLineThird Γ z a) s| ≤ B := by
    have hsabs : |s| ≤ |t| := by simpa using abs_sub_left_of_mem_uIcc hs
    have hupper := (expPotential_relative_bounds Γ z a s G b hΓ hb ha).2
    have hexp : Real.exp (2 * G * b * |s|) ≤ Real.exp (2 * G * b * |t|) := by
      apply Real.exp_le_exp.mpr
      exact mul_le_mul_of_nonneg_left hsabs (by positivity)
    exact (expPotential_third_bound Γ z a s G b hG hΓ hb ha).trans
      (mul_le_mul_of_nonneg_left
        (hupper.trans (mul_le_mul_of_nonneg_right hexp (by unfold expPotential; positivity)))
        (mul_nonneg hP (pow_nonneg hb 3)))
  have h := quadratic_taylor_remainder (contDiff_expPotential Γ z a)
    (hasDerivAt_expPotential Γ z a)
    (hasDerivAt_expFirst (hasDerivAt_potentialLine Γ z a) (hasDerivAt_potentialLineFirst Γ z a))
    (hasDerivAt_expPotential_second Γ z a) t B hB hbound
  convert! h using 1 <;> dsimp [B] <;> ring

end FiniteField
end NeuralGeneralization.BatchTwoNonGaussian
