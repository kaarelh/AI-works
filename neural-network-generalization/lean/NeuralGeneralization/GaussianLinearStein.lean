import NeuralGeneralization.GaussianAngularFields

/-! # Actual Stein identity for gradients of finite linear Gaussian fields -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.GaussianLinearStein
open FiniteDifferential GaussianAngularFields GaussianProductStein
variable {I R : Type*} [Fintype I] [Fintype R] [DecidableEq R]

/-- A raw coordinate times a field gradient equals the corresponding Hessian
contraction. The identity is proved under the actual independent Gaussian law. -/
theorem integral_coord_gradient (C : I → R → ℝ)
    (grad : (I → ℝ) → I → ℝ) (hess : (I → ℝ) → I → I → ℝ)
    (hDiff : ∀ x i, HasFDerivAt (fun y => grad y i) (gradientLinear (hess x i)) x)
    (hHessMeas : ∀ i k, Measurable (fun x => hess x i k))
    (B1 B2 : ℝ) (hGradBound : ∀ x i, |grad x i| ≤ B1)
    (hHessBound : ∀ x i k, |hess x i k| ≤ B2) (i : I) (r : R) :
    (∫ z, z r * grad (fieldLinear C z) i ∂standardLaw R) =
      ∑ k, C k r * ∫ z, hess (fieldLinear C z) i k ∂standardLaw R := by
  have hGcont : Continuous (fun x => grad x i) :=
    continuous_iff_continuousAt.mpr (fun x => (hDiff x i).continuousAt)
  let F : (R → ℝ) → ℝ := fun z => grad (fieldLinear C z) i
  let D : (R → ℝ) → ℝ := fun z => ∑ k, hess (fieldLinear C z) i k * C k r
  have hFmeas : Measurable F := hGcont.measurable.comp (fieldLinear C).continuous.measurable
  have hDmeas : Measurable D :=
    Finset.measurable_fun_sum Finset.univ (fun k _ =>
      ((hHessMeas i k).comp (fieldLinear C).continuous.measurable).mul_const (C k r))
  have hpartial (z : R → ℝ) :
      HasDerivAt (fun t => F (Function.update z r t)) (D z) (z r) := by
    have h := (hDiff (fieldLinear C (Function.update z r (z r))) i).comp_hasDerivAt
      (z r) (hasDerivAt_field_update C z r (z r))
    simpa only [F, D, Function.comp_def, Function.update_eq_self, gradientLinear_apply] using h
  have hDB (z : R → ℝ) : |D z| ≤ B2 * ∑ k, |C k r| := by
    calc
      |D z| ≤ ∑ k, |hess (fieldLinear C z) i k * C k r| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ k, B2 * |C k r| := by
        apply Finset.sum_le_sum
        intro k hk
        rw [abs_mul]
        exact mul_le_mul_of_nonneg_right (hHessBound _ i k) (abs_nonneg _)
      _ = B2 * ∑ k, |C k r| := (Finset.mul_sum _ _ _).symm
  have hStein : (∫ z, z r * F z ∂standardLaw R) =
      ∫ z, D z ∂standardLaw R := gaussian_integral_coord_mul_eq_integral_partial_standard r F D
    hFmeas hDmeas hpartial B1 (B2 * ∑ k, |C k r|)
    (fun z => hGradBound _ i) hDB
  have hint (k : I) : Integrable (fun z : R → ℝ => hess (fieldLinear C z) i k)
      (standardLaw R) :=
    integrable_of_bounded (fun _ : R => (1 : ℝ≥0)) _
      ((hHessMeas i k).comp (fieldLinear C).continuous.measurable) B2
      (fun z => hHessBound _ i k)
  change (∫ z, z r * F z ∂standardLaw R) = _
  rw [hStein]
  change (∫ z, ∑ k, hess (fieldLinear C z) i k * C k r ∂standardLaw R) = _
  rw [integral_finsetSum Finset.univ (fun k _ => (hint k).mul_const (C k r))]
  simp only [mul_comm, integral_const_mul]

end NeuralGeneralization.GaussianLinearStein
end
