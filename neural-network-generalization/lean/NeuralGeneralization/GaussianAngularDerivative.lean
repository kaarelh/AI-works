import NeuralGeneralization.GaussianAngularFields

/-! # Dominated differentiation of actual angular Gaussian expectations -/
noncomputable section
open MeasureTheory ProbabilityTheory Filter
open scoped BigOperators NNReal Topology
namespace NeuralGeneralization.GaussianAngularDerivative
open FiniteDifferential GaussianAngularFields
variable {I J K : Type*} [Fintype I] [Fintype J] [Fintype K]

def angularDirectional (A : I → J → ℝ) (B : I → K → ℝ)
    (grad : (I → ℝ) → I → ℝ) (θ : ℝ) (z : J ⊕ K → ℝ) : ℝ :=
  gradientLinear (grad (angularField A B θ z)) (angularVelocity A B θ z)

lemma measurable_angularDirectional (A : I → J → ℝ) (B : I → K → ℝ)
    (grad : (I → ℝ) → I → ℝ) (hgrad : ∀ i, Measurable (fun x => grad x i)) (θ : ℝ) :
    Measurable (angularDirectional A B grad θ) := by
  unfold angularDirectional
  simp_rw [gradientLinear_apply]
  apply Finset.measurable_fun_sum Finset.univ
  intro i hi
  exact ((hgrad i).comp (continuous_angularField A B θ).measurable).mul
    ((continuous_apply i).comp (fieldLinear (velocityMatrix A B θ)).continuous).measurable

lemma angularDirectional_bound (A : I → J → ℝ) (B : I → K → ℝ)
    (grad : (I → ℝ) → I → ℝ) {C : ℝ} (hC : 0 ≤ C)
    (hgrad : ∀ x i, |grad x i| ≤ C) (θ : ℝ) (z : J ⊕ K → ℝ) :
    |angularDirectional A B grad θ z| ≤ C * ∑ i, (|leftField A z i| + |rightField B z i|) := by
  rw [angularDirectional, gradientLinear_apply, Finset.mul_sum]
  calc
    _ ≤ ∑ i, |grad (angularField A B θ z) i * angularVelocity A B θ z i| :=
      Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i, C * (|leftField A z i| + |rightField B z i|) := by
      apply Finset.sum_le_sum
      intro i hi
      rw [abs_mul]
      exact mul_le_mul (hgrad _ i) (velocity_abs_le A B θ z i) (abs_nonneg _) hC

lemma hasDerivAt_angular_test (A : I → J → ℝ) (B : I → K → ℝ)
    (H : (I → ℝ) → ℝ) (grad : (I → ℝ) → I → ℝ)
    (hH : ∀ x, HasFDerivAt H (gradientLinear (grad x)) x)
    (θ : ℝ) (z : J ⊕ K → ℝ) :
    HasDerivAt (fun t => H (angularField A B t z)) (angularDirectional A B grad θ z) θ := by
  have h := (hH (angularField A B θ z)).comp_hasDerivAt θ (hasDerivAt_angularField A B θ z)
  simpa only [Function.comp_def, angularDirectional] using h

/-- Differentiation is justified by a global integrable Gaussian-coordinate
bound; no Gaussian differentiation formula is assumed. -/
theorem hasDerivAt_integral_angular_raw (A : I → J → ℝ) (B : I → K → ℝ)
    (H : (I → ℝ) → ℝ) (grad : (I → ℝ) → I → ℝ)
    (hH : ∀ x, HasFDerivAt H (gradientLinear (grad x)) x)
    (hgradmeas : ∀ i, Measurable (fun x => grad x i))
    (C0 C1 : ℝ) (hC1 : 0 ≤ C1) (hbound : ∀ x, |H x| ≤ C0)
    (hgradbound : ∀ x i, |grad x i| ≤ C1) (θ : ℝ) :
    HasDerivAt (fun t => ∫ z, H (angularField A B t z) ∂standardLaw (J ⊕ K))
      (∫ z, angularDirectional A B grad θ z ∂standardLaw (J ⊕ K)) θ := by
  have hHcont : Continuous H := continuous_iff_continuousAt.mpr (fun x => (hH x).continuousAt)
  have hmeas : ∀ᶠ t : ℝ in 𝓝 θ,
      AEStronglyMeasurable (fun z => H (angularField A B t z)) (standardLaw (J ⊕ K)) :=
    Filter.Eventually.of_forall (fun t =>
      (hHcont.measurable.comp (continuous_angularField A B t).measurable).aestronglyMeasurable)
  have hint : Integrable (fun z => H (angularField A B θ z)) (standardLaw (J ⊕ K)) :=
    GaussianProductStein.integrable_of_bounded (fun _ : J ⊕ K => (1 : ℝ≥0)) _
      (hHcont.measurable.comp (continuous_angularField A B θ).measurable) C0
      (fun z => hbound _)
  apply (hasDerivAt_integral_of_dominated_loc_of_deriv_le
    (μ := standardLaw (J ⊕ K)) (s := Set.univ)
    (F := fun t z => H (angularField A B t z))
    (F' := angularDirectional A B grad)
    (bound := fun z => C1 * ∑ i, (|leftField A z i| + |rightField B z i|))
    (Filter.univ_mem) hmeas hint
    (measurable_angularDirectional A B grad hgradmeas θ).aestronglyMeasurable
    (ae_of_all _ (fun z t _ => by
      simpa only [Real.norm_eq_abs] using angularDirectional_bound A B grad hC1 hgradbound t z))
    (integrable_velocity_bound A B C1)
    (ae_of_all _ (fun z t _ => hasDerivAt_angular_test A B H grad hH t z))).2

end NeuralGeneralization.GaussianAngularDerivative
end
