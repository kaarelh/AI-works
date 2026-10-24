import NeuralGeneralization.BatchTwoActivationVariableWidth

/-!
# A concrete input-layer exponential moment

The elementary coordinate union bound here is intentionally slightly looser
than the dimension-free bounded-difference estimate in the manuscript. Its
dimension dependence is polynomial and therefore suffices for the exact
existential-polynomial learning statement.
-/

noncomputable section
open scoped BigOperators RealInnerProductSpace

namespace NeuralGeneralization.BatchTwoActivation
open SquaredSampling

variable {J : Type*} [Fintype J] [Nonempty J]

theorem norm_le_sqrt_card_mul_envelope (v : EuclideanSpace ℝ J) {B : ℝ}
    (hv : ∀ j, |v j| ≤ B) :
    ‖v‖ ≤ Real.sqrt (Fintype.card J) * envelope (fun j => v j) := by
  have he := envelope_nonneg (fun j => v j) hv
  have hsum : (∑ j, (v j)^2) ≤ (Fintype.card J : ℝ) * (envelope (fun j => v j))^2 := by
    calc
      _ ≤ ∑ _j : J, (envelope (fun j => v j))^2 := by
        apply Finset.sum_le_sum
        intro j _
        simpa only [sq_abs] using pow_le_pow_left₀ (abs_nonneg (v j))
          (le_envelope (fun j => v j) hv j) 2
      _ = _ := by simp
  rw [EuclideanSpace.norm_eq]
  simp only [Real.norm_eq_abs, sq_abs]
  calc
    _ ≤ Real.sqrt ((Fintype.card J : ℝ) * (envelope (fun j => v j))^2) := Real.sqrt_le_sqrt hsum
    _ = _ := by rw [Real.sqrt_mul (Nat.cast_nonneg _), Real.sqrt_sq he]

/-- Exact finite sign-law MGF bound for the Euclidean input sum. -/
theorem input_vector_sign_mgf (n : ℕ) (x : Fin n → EuclideanSpace ℝ J)
    (hx : ∀ i j, |x i j| ≤ 1) (a : ℝ) (ha : 0 ≤ a) :
    finiteMean (fun ε : Fin n → Bool =>
      Real.exp (a * ‖∑ i, cubeCoordinateSign (ε i) • x i‖)) ≤
      2 * (Fintype.card J : ℝ) * Real.exp (a^2 * (Fintype.card J : ℝ) * n / 2) := by
  let T : (Fin n → Bool) → J → ℝ := fun ε j =>
    ∑ i, cubeCoordinateSign (ε i) * x i j
  have hT (ε : Fin n → Bool) (j : J) : |T ε j| ≤ (n : ℝ) := by
    simpa only [mul_one] using signed_sum_abs_le (fun i => x i j) (fun i => hx i j) ε
  have hcoord (ε : Fin n → Bool) (j : J) :
      (∑ i, cubeCoordinateSign (ε i) • x i) j = T ε j := by
    simp only [WithLp.ofLp_sum, Finset.sum_apply, WithLp.ofLp_smul,
      Pi.smul_apply, smul_eq_mul, T]
  let b : ℝ := a * Real.sqrt (Fintype.card J)
  have hpoint (ε : Fin n → Bool) :
      Real.exp (a * ‖∑ i, cubeCoordinateSign (ε i) • x i‖) ≤
        ∑ j, (Real.exp (b * T ε j) + Real.exp (-b * T ε j)) := by
    have hn := norm_le_sqrt_card_mul_envelope (∑ i, cubeCoordinateSign (ε i) • x i)
      (fun j => by simpa only [hcoord] using hT ε j)
    simp only [hcoord] at hn
    have h := Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_left hn ha)
    have heq : a * (Real.sqrt (Fintype.card J) * envelope (T ε)) = b * envelope (T ε) := by
      dsimp [b]; ring
    rw [heq] at h
    exact h.trans (exp_envelope_le_sum (T ε) b)
  have hmax := finiteMean_mono hpoint
  rw [finiteMean_sum] at hmax
  have hvariance (j : J) : (∑ i, (x i j)^2) ≤ (n : ℝ) := by
    calc
      _ ≤ ∑ _i : Fin n, (1 : ℝ) := by
        apply Finset.sum_le_sum
        intro i _
        have h := pow_le_pow_left₀ (abs_nonneg (x i j)) (hx i j) 2
        simpa only [sq_abs, one_pow] using h
      _ = _ := by simp
  have hterm (j : J) :
      finiteMean (fun ε : Fin n → Bool => Real.exp (b*T ε j) + Real.exp (-b*T ε j)) ≤
        2 * Real.exp (a^2 * (Fintype.card J : ℝ) * n / 2) := by
    rw [finiteMean_add]
    have hp := finite_rademacher_mgf_le n (fun i => x i j) b
    have hm := finite_rademacher_mgf_le n (fun i => x i j) (-b)
    simp only [neg_sq] at hm
    have hb : b^2 = a^2 * (Fintype.card J : ℝ) := by
      dsimp [b]
      rw [mul_pow, Real.sq_sqrt (Nat.cast_nonneg _)]
    have hu : Real.exp (b^2 * (∑ i, (x i j)^2) / 2) ≤
        Real.exp (a^2 * (Fintype.card J : ℝ) * n / 2) := by
      apply Real.exp_le_exp.mpr
      rw [← hb]
      exact div_le_div_of_nonneg_right
        (mul_le_mul_of_nonneg_left (hvariance j) (sq_nonneg b)) (by norm_num)
    change finiteMean (fun ε => Real.exp (b*T ε j)) ≤ _ at hp
    change finiteMean (fun ε => Real.exp (-b*T ε j)) ≤ _ at hm
    linarith [hp.trans hu, hm.trans hu]
  have hs := Finset.sum_le_sum (fun j (_ : j ∈ Finset.univ) => hterm j)
  apply (hmax.trans hs).trans_eq
  simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  ring

end NeuralGeneralization.BatchTwoActivation
