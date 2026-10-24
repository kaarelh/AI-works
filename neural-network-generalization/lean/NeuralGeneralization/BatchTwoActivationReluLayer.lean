import NeuralGeneralization.BatchTwoActivationPeeling
import NeuralGeneralization.BatchTwoActivationStatements

/-!
# Exact ReLU row normalization and layer contraction

These lemmas connect exponential row peeling to ordinary ReLU layers.
The row directions and lengths are constructed from the actual weights.
-/

noncomputable section
open scoped BigOperators RealInnerProductSpace

namespace NeuralGeneralization.BatchTwoActivation
open SquaredSampling

variable {U E J : Type*} [Nonempty U] [Fintype J] [Nonempty J]
  [NormedAddCommGroup E] [InnerProductSpace ℝ E]

def unitDirection (w : E) : E := ‖w‖⁻¹ • w

theorem norm_unitDirection_le (w : E) : ‖unitDirection w‖ ≤ 1 := by
  rw [unitDirection, norm_smul, Real.norm_eq_abs,
    abs_of_nonneg (inv_nonneg.mpr (norm_nonneg w))]
  by_cases hw : ‖w‖ = 0
  · simp [hw]
  · rw [inv_mul_cancel₀ hw]

theorem norm_smul_unitDirection (w : E) : ‖w‖ • unitDirection w = w := by
  by_cases hw : w = 0
  · simp [hw, unitDirection]
  · rw [unitDirection, smul_smul, mul_inv_cancel₀ (norm_ne_zero_iff.mpr hw), one_smul]

theorem relu_mul_nonneg {a : ℝ} (ha : 0 ≤ a) (x : ℝ) : relu (a*x) = a*relu x := by
  by_cases hx : 0 ≤ x
  · simp only [relu, max_eq_right hx, max_eq_right (mul_nonneg ha hx)]
  · have hx0 : x ≤ 0 := le_of_lt (lt_of_not_ge hx)
    simp only [relu, max_eq_left hx0, max_eq_left (mul_nonpos_of_nonneg_of_nonpos ha hx0), mul_zero]

theorem relu_inner_normalized (w h : E) :
    relu ⟪w,h⟫ = ‖w‖ * relu ⟪unitDirection w,h⟫ := by
  rw [← relu_mul_nonneg (norm_nonneg w), ← real_inner_smul_left,
    norm_smul_unitDirection]

def rowLayer (φ : ℝ → ℝ) (w : U → J → E) (h : U → Fin n → E) :
    U → Fin n → EuclideanSpace ℝ J :=
  fun p i => WithLp.toLp 2 (fun j => φ ⟪w p j, h p i⟫)

theorem relu_rowLayer_eq_normalized (w : U → J → E) (h : U → Fin n → E) :
    rowLayer relu w h =
      normalizedRowLayer relu (fun p j => ‖w p j‖) (fun p j => unitDirection (w p j)) h := by
  funext p i
  apply PiLp.ext
  intro j
  exact relu_inner_normalized (w p j) (h p i)

theorem rowLayer_relu_norm_le (w : J → E) (h : E)
    (hw : (∑ j, ‖w j‖^2) ≤ 1) :
    ‖(WithLp.toLp 2 (fun j => relu ⟪w j,h⟫) : EuclideanSpace ℝ J)‖ ≤ ‖h‖ := by
  have hsq : ‖(WithLp.toLp 2 (fun j => relu ⟪w j,h⟫) : EuclideanSpace ℝ J)‖^2 ≤ ‖h‖^2 := by
    rw [EuclideanSpace.real_norm_sq_eq]
    simp only [PiLp.toLp_apply]
    calc
      _ ≤ ∑ j, ‖w j‖^2 * ‖h‖^2 := by
        apply Finset.sum_le_sum
        intro j _
        have hab := (activation_abs_le relu_zeroLipschitz ⟪w j,h⟫)
        simp only [one_mul] at hab
        have hinner := abs_real_inner_le_norm (w j) h
        have hboth := hab.trans hinner
        have hp := pow_le_pow_left₀ (abs_nonneg (relu ⟪w j,h⟫)) hboth 2
        simpa only [sq_abs, mul_pow] using hp
      _ = (∑ j, ‖w j‖^2) * ‖h‖^2 := by rw [Finset.sum_mul]
      _ ≤ 1 * ‖h‖^2 := mul_le_mul_of_nonneg_right hw (sq_nonneg _)
      _ = _ := one_mul _
  nlinarith [norm_nonneg h,
    norm_nonneg (WithLp.toLp 2 (fun j => relu ⟪w j,h⟫) : EuclideanSpace ℝ J)]

/-- The actual layer moment inequality. Its only matrix assumption is the
Frobenius bound, and its constant is independent of both adjacent widths. -/
theorem relu_rowLayer_exp_peeling {n : ℕ} (w : U → J → E) (h : U → Fin n → E)
    (hw : ∀ p, (∑ j, ‖w p j‖^2) ≤ 1) {R : ℝ}
    (hh : ∀ p i, ‖h p i‖ ≤ R) (a : ℝ) (ha : 0 ≤ a) :
    finiteMean (fun ε : Fin n → Bool => Real.exp (a * vectorProcess (rowLayer relu w h) ε)) ≤
      2 * finiteMean (fun ε : Fin n → Bool => Real.exp (a * vectorProcess h ε)) := by
  rw [relu_rowLayer_eq_normalized]
  apply normalizedRowLayer_exp_peeling relu relu_zeroLipschitz.1
    (fun x y => by simpa only [one_mul] using relu_zeroLipschitz.2 x y)
    (fun p j => ‖w p j‖) (fun p j => unitDirection (w p j)) h hw
    (fun p j => norm_unitDirection_le (w p j)) hh a ha

end NeuralGeneralization.BatchTwoActivation
