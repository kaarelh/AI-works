import NeuralGeneralization.GaussianFieldTilt
import NeuralGeneralization.GaussianReadout

/-! Equality of actual finite Gaussian field laws from covariance equality. -/
noncomputable section
open MeasureTheory ProbabilityTheory WithLp
open scoped BigOperators NNReal
namespace NeuralGeneralization.GaussianFieldCovariance
open FiniteDifferential GaussianAngularFields GaussianAngularPrice GaussianFieldTilt
variable {I J K : Type*} [Fintype I] [Fintype J] [Fintype K]

omit [Fintype K] in
theorem toLp_field_eq_readout (A : I → J → ℝ) :
    (toLp 2) ∘ fieldLinear A = GaussianReadout.readout (fun j i => A i j) := by
  funext z
  change toLp 2 (fieldLinear A z) = toLp 2 (fun i => ∑ j, z j * A i j)
  apply congrArg (toLp 2)
  funext i
  simp only [fieldLinear_apply, mul_comm]

theorem fieldLaw_eq_of_gram_eq (A : I → J → ℝ) (B : I → K → ℝ)
    (h : ∀ i k, gram A i k = gram B i k) : fieldLaw A = fieldLaw B := by
  apply (MeasurableEquiv.toLp 2 (I → ℝ)).map_measurableEquiv_injective
  unfold fieldLaw
  change ((standardLaw J).map (fieldLinear A)).map (toLp 2) =
    ((standardLaw K).map (fieldLinear B)).map (toLp 2)
  rw [Measure.map_map (WithLp.measurable_toLp 2 (I → ℝ)) (fieldLinear A).continuous.measurable,
    Measure.map_map (WithLp.measurable_toLp 2 (I → ℝ)) (fieldLinear B).continuous.measurable]
  rw [toLp_field_eq_readout A, toLp_field_eq_readout B]
  exact GaussianReadout.law_eq_of_gram_eq (fun j i => A i j) (fun k i => B i k) 1 1
    (by simpa only [NNReal.coe_one, one_mul, GaussianReadout.gram, gram] using h)

theorem map_field_eq_of_scaled_gram (H : I → J → ℝ) (v : ℝ≥0) (A : I → K → ℝ)
    (h : ∀ i k, (v : ℝ) * gram H i k = gram A i k) :
    (Measure.pi (fun _ : J => gaussianReal 0 v)).map (fieldLinear H) = fieldLaw A := by
  apply (MeasurableEquiv.toLp 2 (I → ℝ)).map_measurableEquiv_injective
  change (((Measure.pi (fun _ : J => gaussianReal 0 v)).map (fieldLinear H)).map (toLp 2)) =
    ((standardLaw K).map (fieldLinear A)).map (toLp 2)
  rw [Measure.map_map (WithLp.measurable_toLp 2 (I → ℝ)) (fieldLinear H).continuous.measurable,
    Measure.map_map (WithLp.measurable_toLp 2 (I → ℝ)) (fieldLinear A).continuous.measurable,
    toLp_field_eq_readout H, toLp_field_eq_readout A]
  exact GaussianReadout.law_eq_of_gram_eq (fun j i => H i j) (fun k i => A i k) v 1
    (by simpa only [NNReal.coe_one, one_mul, GaussianReadout.gram, gram] using h)

end NeuralGeneralization.GaussianFieldCovariance
end
