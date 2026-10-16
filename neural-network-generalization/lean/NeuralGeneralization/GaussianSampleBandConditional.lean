import NeuralGeneralization.GaussianSampleBand
import NeuralGeneralization.GaussianConditionalMatrixEnergy

/-! # Actual posterior energy on sampled Fourier bands

The matrix estimate is applied on the original Gaussian coordinates, then
transported through the full field map. Conditioning may depend on every
coordinate, including the sampled tail itself.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.GaussianSampleBand
open GaussianBandEnergy GaussianMarginHeadBound FiniteDifferential GaussianAngularPrice
  GaussianFieldTilt GaussianAngularFields
variable {d : ℕ} {J : Type*} [Fintype J]

lemma integrable_sampleBandEnergy_cond
    (w : Finset (Fin d) → ℝ) (H : Finset (Finset (Fin d)))
    (s : J → ClippingCube d) (E : Set (ClippingCube d → ℝ)) (hE : MeasurableSet E)
    (hEpos : fieldLaw (WalshGaussianEnergy.matrix w) E ≠ 0) :
    Integrable (sampleBandEnergy H s) (cond (fieldLaw (WalshGaussianEnergy.matrix w)) E) := by
  let F := fieldLinear (WalshGaussianEnergy.matrix w)
  have hF : Measurable F := F.continuous.measurable
  have hmass : standardLaw (Finset (Fin d)) (F ⁻¹' E)=fieldLaw (WalshGaussianEnergy.matrix w) E :=
    (Measure.map_apply hF hE).symm
  have hp : standardLaw (Finset (Fin d)) (F ⁻¹' E) ≠ 0 := by rwa [hmass]
  have hi := integrable_cond_gaussian_matrix_energy (sampleMatrix w H s) (F ⁻¹' E) hp
  have hc := GaussianConditionalSubspace.map_cond_preimage
    (standardLaw (Finset (Fin d))) F hF E hE
  change (cond (standardLaw (Finset (Fin d))) (F ⁻¹' E)).map F =
    cond (fieldLaw (WalshGaussianEnergy.matrix w)) E at hc
  rw [← hc]
  apply (integrable_map_measure (measurable_sampleBandEnergy H s).aestronglyMeasurable hF.aemeasurable).mpr
  simpa only [Function.comp_def, F, sampleBandEnergy_field] using hi

/-- Trace and sampled-kernel operator norm control the actual conditional
sampled energy. The event is arbitrary and may involve the global margin. -/
theorem conditional_sampleBandEnergy_le
    (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S)
    (H : Finset (Finset (Fin d))) (s : J → ClippingCube d)
    (g : ℝ) (hg : 0 < g)
    (hGram : ∀ a : J → ℝ, finiteQuadratic (fun i j => walshTailKernel H w (s i) (s j)) a
      ≤ g*∑ j, a j^2)
    (E : Set (ClippingCube d → ℝ)) (hE : MeasurableSet E)
    (hEpos : fieldLaw (WalshGaussianEnergy.matrix w) E ≠ 0) :
    (∫ z, sampleBandEnergy H s z ∂cond (fieldLaw (WalshGaussianEnergy.matrix w)) E) ≤
      2*(Fintype.card J:ℝ)*(∑ S ∈ H, w S)+
        4*g*Real.log (1/(fieldLaw (WalshGaussianEnergy.matrix w)).real E) := by
  classical
  let F := fieldLinear (WalshGaussianEnergy.matrix w)
  have hF : Measurable F := F.continuous.measurable
  have hmass : standardLaw (Finset (Fin d)) (F ⁻¹' E)=fieldLaw (WalshGaussianEnergy.matrix w) E :=
    (Measure.map_apply hF hE).symm
  have hp : standardLaw (Finset (Fin d)) (F ⁻¹' E) ≠ 0 := by rwa [hmass]
  have hG : ∀ a : J → ℝ, finiteQuadratic (gram (sampleMatrix w H s)) a ≤ g*∑ j, a j^2 := by
    simpa only [show gram (sampleMatrix w H s) = (fun i j => walshTailKernel H w (s i) (s j))
      from funext (fun i => funext (sampleMatrix_gram w hw H s i))] using hGram
  have hh := conditional_gaussian_matrix_energy (sampleMatrix w H s) g hg hG (F ⁻¹' E) hp
  have hc := GaussianConditionalSubspace.map_cond_preimage
    (standardLaw (Finset (Fin d))) F hF E hE
  change (cond (standardLaw (Finset (Fin d))) (F ⁻¹' E)).map F =
    cond (fieldLaw (WalshGaussianEnergy.matrix w)) E at hc
  rw [← hc, integral_map hF.aemeasurable (measurable_sampleBandEnergy H s).aestronglyMeasurable]
  simp_rw [show ∀ z, sampleBandEnergy H s (F z)=∑ j, fieldLinear (sampleMatrix w H s) z j^2
    from sampleBandEnergy_field w H s]
  have hr : (standardLaw (Finset (Fin d))).real (F ⁻¹' E)=
      (fieldLaw (WalshGaussianEnergy.matrix w)).real E := congrArg ENNReal.toReal hmass
  rw [sampleMatrix_trace w hw H s, hr] at hh
  convert hh using 1 <;> ring

end NeuralGeneralization.GaussianSampleBand
