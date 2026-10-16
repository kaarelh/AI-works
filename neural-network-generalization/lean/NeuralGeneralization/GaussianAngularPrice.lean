import NeuralGeneralization.GaussianAngularDerivative
import NeuralGeneralization.GaussianLinearStein

/-! # Price's formula for angular interpolation, including singular endpoints

The covariance derivative identity is derived from actual finite independent
Gaussian integration by parts and dominated differentiation. No nonsingularity
of either endpoint field is assumed.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.GaussianAngularPrice
open FiniteDifferential GaussianAngularFields GaussianAngularDerivative GaussianLinearStein
variable {I J K R : Type*} [Fintype I] [Fintype J] [Fintype K] [Fintype R]

def gram (A : I → J → ℝ) (i k : I) : ℝ := ∑ j, A i j * A k j

omit [Fintype I] [Fintype R] in
lemma angular_covariance_contraction (A : I → J → ℝ) (B : I → K → ℝ)
    (θ : ℝ) (i k : I) :
    (∑ r, velocityMatrix A B θ i r * angleMatrix A B θ k r) =
      Real.sin θ * Real.cos θ * (gram B i k - gram A i k) := by
  simp only [Fintype.sum_sum_type, velocityMatrix, angleMatrix, Sum.elim_inl, Sum.elim_inr]
  have hA : (∑ j, (-Real.sin θ * A i j) * (Real.cos θ * A k j)) =
      -(Real.sin θ * Real.cos θ) * gram A i k := by
    simp only [gram, Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j hj
    ring
  have hB : (∑ j, (Real.cos θ * B i j) * (Real.sin θ * B k j)) =
      (Real.sin θ * Real.cos θ) * gram B i k := by
    simp only [gram, Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j hj
    ring
  rw [hA, hB]
  ring

omit [Fintype J] [Fintype K] in
/-- Actual Gaussian integration of a linear velocity against a gradient. -/
theorem integral_gradient_linear (C D : I → R → ℝ)
    (grad : (I → ℝ) → I → ℝ) (hess : (I → ℝ) → I → I → ℝ)
    (hDiff : ∀ x i, HasFDerivAt (fun y => grad y i) (gradientLinear (hess x i)) x)
    (hHessMeas : ∀ i k, Measurable (fun x => hess x i k))
    (B1 B2 : ℝ) (hGradBound : ∀ x i, |grad x i| ≤ B1)
    (hHessBound : ∀ x i k, |hess x i k| ≤ B2) :
    (∫ z, gradientLinear (grad (fieldLinear C z)) (fieldLinear D z) ∂standardLaw R) =
      ∑ i, ∑ k, (∑ r, D i r * C k r) *
        ∫ z, hess (fieldLinear C z) i k ∂standardLaw R := by
  classical
  have hGcont (i : I) : Continuous (fun x => grad x i) :=
    continuous_iff_continuousAt.mpr (fun x => (hDiff x i).continuousAt)
  have hint (i : I) (r : R) :
      Integrable (fun z => z r * grad (fieldLinear C z) i) (standardLaw R) :=
    GaussianProductStein.integrable_coord_mul_of_bounded (fun _ : R => (1 : ℝ≥0)) r _
      ((hGcont i).measurable.comp (fieldLinear C).continuous.measurable) B1
      (fun z => hGradBound _ i)
  have heq (z : R → ℝ) :
      gradientLinear (grad (fieldLinear C z)) (fieldLinear D z) =
        ∑ i, ∑ r, D i r * (z r * grad (fieldLinear C z) i) := by
    simp only [gradientLinear_apply, fieldLinear_apply, Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i hi
    apply Finset.sum_congr rfl
    intro r hr
    ring
  simp_rw [heq]
  rw [integral_finsetSum Finset.univ (fun i _ =>
    integrable_finsetSum Finset.univ (fun r _ => (hint i r).const_mul (D i r)))]
  apply Finset.sum_congr rfl
  intro i hi
  rw [integral_finsetSum Finset.univ (fun r _ => (hint i r).const_mul (D i r))]
  simp_rw [integral_const_mul, integral_coord_gradient C grad hess hDiff hHessMeas
    B1 B2 hGradBound hHessBound, Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro k hk
  rw [Finset.sum_mul]
  apply Finset.sum_congr rfl
  intro r hr
  ring

omit [Fintype R] in
/-- Price's identity on the entire angular path, with both endpoint covariances
allowed to be singular. All derivative and integrability conditions concern
ordinary bounded first and second derivatives of the test function. -/
theorem hasDerivAt_integral_angular (A : I → J → ℝ) (B : I → K → ℝ)
    (H : (I → ℝ) → ℝ) (grad : (I → ℝ) → I → ℝ)
    (hess : (I → ℝ) → I → I → ℝ)
    (hH : ∀ x, HasFDerivAt H (gradientLinear (grad x)) x)
    (hDiff : ∀ x i, HasFDerivAt (fun y => grad y i) (gradientLinear (hess x i)) x)
    (hHessMeas : ∀ i k, Measurable (fun x => hess x i k))
    (B0 B1 B2 : ℝ) (hB1 : 0 ≤ B1) (hBound : ∀ x, |H x| ≤ B0)
    (hGradBound : ∀ x i, |grad x i| ≤ B1)
    (hHessBound : ∀ x i k, |hess x i k| ≤ B2) (θ : ℝ) :
    HasDerivAt (fun t => ∫ z, H (angularField A B t z) ∂standardLaw (J ⊕ K))
      (Real.sin θ * Real.cos θ * ∑ i, ∑ k,
        (gram B i k - gram A i k) *
          ∫ z, hess (angularField A B θ z) i k ∂standardLaw (J ⊕ K)) θ := by
  have hgradmeas (i : I) : Measurable (fun x => grad x i) :=
    (continuous_iff_continuousAt.mpr (fun x => (hDiff x i).continuousAt)).measurable
  have h := hasDerivAt_integral_angular_raw A B H grad hH hgradmeas B0 B1 hB1 hBound hGradBound θ
  have hid : (∫ z, angularDirectional A B grad θ z ∂standardLaw (J ⊕ K)) =
      Real.sin θ * Real.cos θ * ∑ i, ∑ k,
        (gram B i k - gram A i k) *
          ∫ z, hess (angularField A B θ z) i k ∂standardLaw (J ⊕ K) := by
    change (∫ z, gradientLinear (grad (fieldLinear (angleMatrix A B θ) z))
      (fieldLinear (velocityMatrix A B θ) z) ∂standardLaw (J ⊕ K)) = _
    rw [integral_gradient_linear (angleMatrix A B θ) (velocityMatrix A B θ)
      grad hess hDiff hHessMeas B1 B2 hGradBound hHessBound]
    simp_rw [angular_covariance_contraction, Finset.mul_sum, mul_assoc]
    rfl
  exact hid ▸ h

end NeuralGeneralization.GaussianAngularPrice
end
