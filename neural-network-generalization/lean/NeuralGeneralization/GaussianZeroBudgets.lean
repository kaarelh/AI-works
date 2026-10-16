import NeuralGeneralization.GaussianMarginConfidence
import NeuralGeneralization.GaussianMarginHeadBound

/-! # Fixed-margin endpoint from spectral and sampled-energy budgets

The sampled-energy estimate is isolated here so that the independent matrix
quadratic theorem can provide it. All population moments and the posterior
confidence conversion are discharged against the actual conditioned field.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.GaussianZeroBudgets
open GaussianBandEnergy GaussianMarginHeadBound GaussianMarginConfidence GaussianFieldTilt
variable {d u : ℕ} {J : Type*} [Fintype J] [Nonempty J]

theorem projected_posterior_energy_le
    (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S)
    (s : J → ClippingCube d) (H U : Finset (Finset (Fin d)))
    (hcoercivity : ∀ c : Finset (Fin d) → ℝ, (∀ S, c S ≠ 0 → S ∈ H) →
      (1/4:ℝ)*uniformCubeMean (fun x => walshExpansion c x^2) ≤
        (∑ j, (max 0 (-(fullParity (s j)*walshExpansion c (s j))))^2)/Fintype.card J)
    (ell : ℝ) (hell : 0 < ell) (hmax : ∀ S ∈ Finset.univ\H, w S ≤ ell)
    (E : Set (ClippingCube d → ℝ)) (hE : MeasurableSet E)
    (hEpos : fieldLaw (WalshGaussianEnergy.matrix w) E ≠ 0)
    (htrain : ∀ z ∈ E, ∀ j, 0 ≤ fullParity (s j)*z (s j))
    (hi : Integrable (sampleBandEnergy (Finset.univ\H) s)
      (cond (fieldLaw (WalshGaussianEnergy.matrix w)) E))
    (B : ℝ) (hbound : (∫ z, sampleBandEnergy (Finset.univ\H) s z
      ∂cond (fieldLaw (WalshGaussianEnergy.matrix w)) E) ≤ B) :
    (∫ z, bandEnergy U z ∂cond (fieldLaw (WalshGaussianEnergy.matrix w)) E) ≤
      (4/(Fintype.card J:ℝ))*B+2*(∑ S ∈ Finset.univ\H, w S)+
        4*ell*Real.log (1/(fieldLaw (WalshGaussianEnergy.matrix w)).real E) := by
  have hh := conditional_headEnergy_le w hw s H hcoercivity E hE hEpos htrain hi B hbound
  have ht := conditional_bandEnergy_le w hw (Finset.univ\H) ell hell hmax E hE hEpos
  have hU := integral_mono (integrable_bandEnergy_cond w hw U E hE hEpos)
    ((integrable_bandEnergy_cond w hw H E hE hEpos).add
      (integrable_bandEnergy_cond w hw (Finset.univ\H) E hE hEpos))
    (fun z => bandEnergy_le_split H U z)
  simp only [Pi.add_apply] at hU
  rw [integral_add (integrable_bandEnergy_cond w hw H E hE hEpos)
    (integrable_bandEnergy_cond w hw (Finset.univ\H) E hE hEpos)] at hU
  linarith

/-- Quantitative fixed-margin endpoint with the empirical quadratic step
kept explicit and all population Gaussian steps proved. -/
theorem failure_lower_of_sample_energy
    (hd : 0 < d) (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S)
    (s : J → ClippingCube d) (H U : Finset (Finset (Fin d)))
    (hdegree : ∀ S ∈ U, S.card ≤ u)
    (hcoercivity : ∀ c : Finset (Fin d) → ℝ, (∀ S, c S ≠ 0 → S ∈ H) →
      (1/4:ℝ)*uniformCubeMean (fun x => walshExpansion c x^2) ≤
        (∑ j, (max 0 (-(fullParity (s j)*walshExpansion c (s j))))^2)/Fintype.card J)
    (ellH ellU b B : ℝ) (hellH : 0 < ellH) (hellU : 0 < ellU) (hb : 0 < b)
    (hmaxH : ∀ S ∈ Finset.univ\H, w S ≤ ellH)
    (hmaxU : ∀ S ∈ Finset.univ\U, w S ≤ ellU)
    (E : Set (ClippingCube d → ℝ)) (hE : MeasurableSet E)
    (hEpos : fieldLaw (WalshGaussianEnergy.matrix w) E ≠ 0)
    (htrain : ∀ z ∈ E, ∀ j, 0 ≤ fullParity (s j)*z (s j))
    (hi : Integrable (sampleBandEnergy (Finset.univ\H) s)
      (cond (fieldLaw (WalshGaussianEnergy.matrix w)) E))
    (hsample : (∫ z, sampleBandEnergy (Finset.univ\H) s z
      ∂cond (fieldLaw (WalshGaussianEnergy.matrix w)) E) ≤ B)
    (hhead : (u:ℝ)^2*((4/(Fintype.card J:ℝ))*B+2*(∑ S ∈ Finset.univ\H, w S)+
      4*ellH*Real.log (1/(fieldLaw (WalshGaussianEnergy.matrix w)).real E)) ≤ (b*(d:ℝ))^2/256)
    (htail : 2*(∑ S ∈ Finset.univ\U, w S)+
      4*ellU*Real.log (1/(fieldLaw (WalshGaussianEnergy.matrix w)).real E) ≤ b^2/256)
    (hamp : (∫ z, amplitudeFraction b z ∂cond (fieldLaw (WalshGaussianEnergy.matrix w)) E) ≤ 1/32) :
    (1:ℝ)/16 ≤ ConfidenceClipping.failure
      (confidence (cond (fieldLaw (WalshGaussianEnergy.matrix w)) E)) (13/20) := by
  classical
  let μ := cond (fieldLaw (WalshGaussianEnergy.matrix w)) E
  letI : IsProbabilityMeasure μ := cond_isProbabilityMeasure hEpos
  let c := fun z => maskCoefficients U (walshCoefficients z)
  have hdeg : ∀ z S, c z S ≠ 0 → S.card ≤ u := by
    intro z S hS
    by_cases hSU : S ∈ U
    · exact hdegree S hSU
    · exact False.elim (hS (by simp [c, maskCoefficients, hSU]))
  have hH := integrable_bandEnergy_cond w hw U E hE hEpos
  have hT := integrable_bandEnergy_cond w hw (Finset.univ\U) E hE hEpos
  have he (z : ClippingCube d → ℝ) : uniformCubeMean (fun x => (z x-walshExpansion (c z) x)^2) =
      bandEnergy (Finset.univ\U) z := by
    change uniformCubeMean (fun x => (z x-walshProjection U z x)^2) =
      uniformCubeMean (fun x => (walshProjection (Finset.univ\U) z x)^2)
    simp only [projection_residual]
  apply failure_lower_of_moment_budgets hd μ c hdeg b hb hH
  · simpa only [he] using hT
  · exact (mul_le_mul_of_nonneg_left
      (projected_posterior_energy_le w hw s H U hcoercivity ellH hellH hmaxH E hE hEpos htrain hi B hsample)
      (sq_nonneg (u:ℝ))).trans hhead
  · simpa only [he] using (conditional_bandEnergy_le w hw (Finset.univ\U) ellU hellU hmaxU E hE hEpos).trans htail
  · exact hamp

end NeuralGeneralization.GaussianZeroBudgets
