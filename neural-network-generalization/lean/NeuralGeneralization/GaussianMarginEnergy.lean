import NeuralGeneralization.GaussianMarginLaw
import NeuralGeneralization.KernelEnergy

/-! Exact conversion of standard Gaussian coordinate energy into the
weighted feature-energy convention used in the kernel estimates. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.GaussianMarginEnergy
open GaussianRate GaussianMarginGeometry GaussianMarginLaw
variable {I X : Type*} [Fintype I]

def weightedFeatures (φ : I → X → ℝ) (w : I → ℝ) : I → X → ℝ :=
  fun i x => Real.sqrt (w i) * φ i x

theorem margin_scale_coefficients (φ : I → X → ℝ) (w : I → ℝ)
    (s : X → ℝ) (a : ℝ) (z : I → ℝ) :
    z ∈ linearMargin (signedCoefficients (weightedFeatures φ w) s) a ↔
      (fun i => z i * Real.sqrt (w i)) ∈ linearMargin (signedCoefficients φ s) a := by
  apply forall_congr'
  intro x
  have he : (∑ i, signedCoefficients (weightedFeatures φ w) s x i * z i) =
      ∑ i, signedCoefficients φ s x i * (z i * Real.sqrt (w i)) := by
    apply Finset.sum_congr rfl
    intro i hi
    simp only [signedCoefficients, weightedFeatures]
    ring
  exact he ▸ Iff.rfl

theorem scaled_energy (w : I → ℝ) (hw : ∀ i, 0 < w i) (z : I → ℝ) :
    featureEnergy w (fun i => z i * Real.sqrt (w i)) = squareSum z := by
  unfold featureEnergy squareSum
  apply Finset.sum_congr rfl
  intro i hi
  rw [mul_pow, Real.sq_sqrt (hw i).le, mul_div_cancel_right₀ _ (hw i).ne']

theorem unscaled_energy (w : I → ℝ) (hw : ∀ i, 0 < w i) (c : I → ℝ) :
    squareSum (fun i => c i / Real.sqrt (w i)) = featureEnergy w c := by
  unfold featureEnergy squareSum
  apply Finset.sum_congr rfl
  intro i hi
  rw [div_pow, Real.sq_sqrt (hw i).le]

/-- Equality of entire feasible energy sets, including all strict boundary
conventions. This is stronger than equality of their infima. -/
theorem feasible_energy_image_eq (φ : I → X → ℝ) (w : I → ℝ) (hw : ∀ i, 0 < w i)
    (s : X → ℝ) (a : ℝ) :
    squareSum '' linearMargin (signedCoefficients (weightedFeatures φ w) s) a =
      featureEnergy w '' linearMargin (signedCoefficients φ s) a := by
  ext E
  constructor
  · rintro ⟨z, hz, rfl⟩
    exact ⟨fun i => z i * Real.sqrt (w i), (margin_scale_coefficients φ w s a z).mp hz,
      scaled_energy w hw z⟩
  · rintro ⟨c, hc, rfl⟩
    refine ⟨fun i => c i / Real.sqrt (w i), ?_, unscaled_energy w hw c⟩
    apply (margin_scale_coefficients φ w s a _).mpr
    have he : (fun i => (c i / Real.sqrt (w i)) * Real.sqrt (w i)) = c := by
      funext i
      exact div_mul_cancel₀ _ (Real.sqrt_pos.mpr (hw i)).ne'
    rwa [he]

theorem squareInf_weighted_margin (φ : I → X → ℝ) (w : I → ℝ) (hw : ∀ i, 0 < w i)
    (s : X → ℝ) (a : ℝ) :
    squareInf (linearMargin (signedCoefficients (weightedFeatures φ w) s) a) =
      sInf (featureEnergy w '' linearMargin (signedCoefficients φ s) a) := by
  unfold squareInf
  rw [feasible_energy_image_eq φ w hw s a]

end NeuralGeneralization.GaussianMarginEnergy
