import NeuralGeneralization.RobustCompressionClipping
import Mathlib.Algebra.Order.BigOperators.Ring.Finset

/-!
# Deterministic covariance estimates for finite source reconstruction

These estimates turn the actual finite-bank sampling event into quadratic-form
control and turn first-moment errors into scalar Gaussian variance errors.
-/
noncomputable section
open scoped BigOperators RealInnerProductSpace

namespace NeuralGeneralization.RobustCompressionCovariance

/-- An entrywise matrix error is controlled in Euclidean quadratic form with
one factor of the active dimension. -/
theorem quadratic_error_of_entrywise {q : ℕ} (A B : Fin q → Fin q → ℝ)
    {e : ℝ} (he : 0 ≤ e) (hAB : ∀ i j, |A i j - B i j| ≤ e)
    (v : Fin q → ℝ) :
    |∑ i, ∑ j, v i * (A i j - B i j) * v j| ≤
      (q : ℝ) * e * ∑ i, v i ^ 2 := by
  have hc : (∑ i, |v i|) ^ 2 ≤ (q : ℝ) * ∑ i, v i ^ 2 := by
    have h := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
      (fun i : Fin q => |v i|) (fun _ => (1 : ℝ))
    simpa [sq_abs, mul_comm] using h
  calc
    |∑ i, ∑ j, v i * (A i j - B i j) * v j| ≤
        ∑ i, |∑ j, v i * (A i j - B i j) * v j| :=
      Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i, ∑ j, |v i * (A i j - B i j) * v j| := by
      exact Finset.sum_le_sum (fun i _ => Finset.abs_sum_le_sum_abs _ _)
    _ ≤ ∑ i, ∑ j, e * |v i| * |v j| := by
      apply Finset.sum_le_sum
      intro i hi
      apply Finset.sum_le_sum
      intro j hj
      rw [abs_mul, abs_mul]
      calc
        |v i| * |A i j - B i j| * |v j| ≤ |v i| * e * |v j| := by
          gcongr
          exact hAB i j
        _ = _ := by ring
    _ = e * (∑ i, |v i|) ^ 2 := by
      simp_rw [← Finset.mul_sum]
      rw [← Finset.sum_mul, ← Finset.mul_sum]
      ring
    _ ≤ e * ((q : ℝ) * ∑ i, v i ^ 2) := mul_le_mul_of_nonneg_left hc he
    _ = _ := by ring

/-- Adding a small entrywise perturbation to a contraction preserves a
quantified quadratic upper bound. -/
theorem gram_upper_of_entrywise {q : ℕ} (G G₀ : Fin q → Fin q → ℝ)
    {a : ℝ} (ha : 0 ≤ a)
    (hG : ∀ i j, |G i j - G₀ i j| ≤ a / ((q : ℝ) + 1))
    (hG₀ : ∀ v : Fin q → ℝ, ∑ i, ∑ j, v i * G₀ i j * v j ≤ ∑ i, v i ^ 2)
    (v : Fin q → ℝ) :
    ∑ i, ∑ j, v i * G i j * v j ≤ (1 + a) * ∑ i, v i ^ 2 := by
  have he := quadratic_error_of_entrywise G G₀ (by positivity) hG v
  have hq : (q : ℝ) * (a / ((q : ℝ) + 1)) ≤ a := by
    have hqp : 0 < (q : ℝ) + 1 := by positivity
    rw [← mul_div_assoc]
    apply (div_le_iff₀ hqp).mpr
    nlinarith
  have hsum : 0 ≤ ∑ i, v i ^ 2 := Finset.sum_nonneg (fun i _ => sq_nonneg _)
  have hb := mul_le_mul_of_nonneg_right hq hsum
  have hid : (∑ i, ∑ j, v i * G i j * v j) -
      (∑ i, ∑ j, v i * G₀ i j * v j) =
      ∑ i, ∑ j, v i * (G i j - G₀ i j) * v j := by
    simp_rw [mul_sub, sub_mul, Finset.sum_sub_distrib]
  have hle := le_abs_self (∑ i, ∑ j, v i * (G i j - G₀ i j) * v j)
  rw [← hid] at hle he
  nlinarith [hG₀ v]

section Inner
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

theorem inner_error_le {u u' v v' : E} {e : ℝ}
    (hu : ‖u - u'‖ ≤ e) (hv : ‖v - v'‖ ≤ e)
    (hu' : ‖u'‖ ≤ 1) (hv₀ : ‖v‖ ≤ 1) :
    |⟪u, v⟫ - ⟪u', v'⟫| ≤ 2 * e := by
  have h1 := abs_real_inner_le_norm (u - u') v
  have h2 := abs_real_inner_le_norm u' (v - v')
  have h3 := abs_add_le ⟪u - u', v⟫ ⟪u', v - v'⟫
  have he : 0 ≤ e := (norm_nonneg (u - u')).trans hu
  have hb1 : ‖u - u'‖ * ‖v‖ ≤ e := by
    calc _ ≤ e * 1 := mul_le_mul hu hv₀ (norm_nonneg _) he
         _ = _ := mul_one _
  have hb2 : ‖u'‖ * ‖v - v'‖ ≤ e := by
    calc _ ≤ 1 * e := mul_le_mul hu' hv (norm_nonneg _) (by norm_num)
         _ = _ := one_mul _
  have hid : ⟪u, v⟫ - ⟪u', v'⟫ = ⟪u - u', v⟫ + ⟪u', v - v'⟫ := by
    simp [inner_sub_left, inner_sub_right]
  rw [hid]
  linarith

/-- Removing an approximately reconstructed active component changes the
residual covariance by at most the covariance error plus twice the active
feature error. -/
theorem residual_covariance_error {u u' v v' : E} {K K' a e : ℝ}
    (hK : |K - K'| ≤ a) (hu : ‖u - u'‖ ≤ e) (hv : ‖v - v'‖ ≤ e)
    (hu' : ‖u'‖ ≤ 1) (hv₀ : ‖v‖ ≤ 1) :
    |(K - ⟪u, v⟫) - (K' - ⟪u', v'⟫)| ≤ a + 2 * e := by
  have hi := inner_error_le hu hv hu' hv₀
  have hid : (K - ⟪u, v⟫) - (K' - ⟪u', v'⟫) =
      (K - K') - (⟪u, v⟫ - ⟪u', v'⟫) := by ring
  rw [hid]
  exact (abs_sub _ _).trans (add_le_add hK hi)

/-- A finite source family with a bounded second-moment quadratic form has
uniformly bounded feature means against every scalar activation in [-1,1]. -/
theorem feature_mean_norm_sq_le {N : ℕ} [NeZero N]
    (c : Fin N → E) (h : Fin N → ℝ) (hh : ∀ i, |h i| ≤ 1)
    {A : ℝ} (hA : 0 ≤ A)
    (hquad : ∀ v : E, (∑ i, ⟪c i, v⟫ ^ 2) / (N : ℝ) ≤ A * ‖v‖ ^ 2) :
    ‖RobustCompressionClipping.finiteAverage (fun i => h i • c i)‖ ^ 2 ≤ A := by
  let v := RobustCompressionClipping.finiteAverage (fun i => h i • c i)
  have hN : (0 : ℝ) < N := by exact_mod_cast NeZero.pos N
  have hv : ‖v‖ ^ 2 = (∑ i, h i * ⟪c i, v⟫) / (N : ℝ) := by
    rw [← real_inner_self_eq_norm_sq]
    conv_lhs => lhs; unfold v RobustCompressionClipping.finiteAverage
    simp only [real_inner_smul_left, sum_inner]
    ring
  have hc := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ h (fun i => ⟪c i, v⟫)
  have hs : (∑ i, h i ^ 2) ≤ (N : ℝ) := by
    calc
      (∑ i, h i ^ 2) ≤ ∑ _i : Fin N, (1 : ℝ) := by
        apply Finset.sum_le_sum
        intro i hi
        nlinarith [hh i, abs_nonneg (h i), sq_abs (h i)]
      _ = _ := by simp
  have hq := hquad v
  have hq' : (∑ i, ⟪c i, v⟫ ^ 2) ≤ (N : ℝ) * A * ‖v‖ ^ 2 := by
    have hb := (div_le_iff₀ hN).mp hq
    nlinarith
  have hi0 : 0 ≤ ∑ i, ⟪c i, v⟫ ^ 2 := Finset.sum_nonneg (fun i _ => sq_nonneg _)
  have hs' := mul_le_mul_of_nonneg_right hs hi0
  have hq'' := mul_le_mul_of_nonneg_left hq' hN.le
  have hid : (∑ i, h i * ⟪c i, v⟫) = (N : ℝ) * ‖v‖ ^ 2 := by
    have hb := (eq_div_iff hN.ne').mp hv
    nlinarith
  rw [hid] at hc
  change ‖v‖ ^ 2 ≤ A
  by_contra hn
  have hn' : A < ‖v‖ ^ 2 := lt_of_not_ge hn
  have hvpos : 0 < ‖v‖ ^ 2 := hA.trans_lt hn'
  have hp : 0 < (N : ℝ) ^ 2 * ‖v‖ ^ 2 * (‖v‖ ^ 2 - A) := by positivity
  nlinarith

end Inner
end NeuralGeneralization.RobustCompressionCovariance
