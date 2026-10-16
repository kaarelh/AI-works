import NeuralGeneralization.GaussianZeroBudgets
import NeuralGeneralization.GaussianSampleBandConditional
import NeuralGeneralization.GaussianAmplitudePopulation

/-! # The fixed-margin Gaussian endpoint

This theorem uses the actual posterior sign probability. Every conditional
Gaussian energy and amplitude estimate is proved. The hypotheses left for
the sample-size argument are the two empirical events and explicit scalar
spectral, conditioning-cost and cutoff inequalities.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.GaussianZeroDeterministic
open GaussianBandEnergy GaussianMarginHeadBound GaussianMarginConfidence GaussianFieldTilt
  GaussianSampleBand GaussianZeroBudgets
variable {d u : ℕ} {J : Type*} [Fintype J] [Nonempty J]

/-- Actual posterior confidence failure from empirical coercivity, a
sampled covariance bound, and scalar posterior moment budgets. -/
theorem confidence_failure_lower (hd : 0 < d)
    (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S)
    (s : J → ClippingCube d) (H U : Finset (Finset (Fin d)))
    (hdegree : ∀ S ∈ U, S.card ≤ u)
    (hcoercivity : ∀ c : Finset (Fin d) → ℝ, (∀ S, c S ≠ 0 → S ∈ H) →
      (1/4:ℝ)*uniformCubeMean (fun x => walshExpansion c x^2) ≤
        (∑ j, (max 0 (-(fullParity (s j)*walshExpansion c (s j))))^2)/Fintype.card J)
    (G ellH ellU b : ℝ) (hG : 0 < G) (hellH : 0 < ellH) (hellU : 0 < ellU) (hb : 0 < b)
    (hmaxH : ∀ S ∈ Finset.univ\H, w S ≤ ellH)
    (hmaxU : ∀ S ∈ Finset.univ\U, w S ≤ ellU)
    (hGram : ∀ a : J → ℝ, finiteQuadratic (fun i j => walshTailKernel (Finset.univ\H) w (s i) (s j)) a
      ≤ G*∑ j, a j^2)
    (E : Set (ClippingCube d → ℝ)) (hE : MeasurableSet E)
    (hEpos : fieldLaw (WalshGaussianEnergy.matrix w) E ≠ 0)
    (htrain : ∀ z ∈ E, ∀ j, 0 ≤ fullParity (s j)*z (s j))
    (hhead : (u:ℝ)^2*(10*(∑ S ∈ Finset.univ\H, w S)+
      (16*G/(Fintype.card J:ℝ)+4*ellH)*Real.log (1/(fieldLaw (WalshGaussianEnergy.matrix w)).real E))
        ≤ (b*(d:ℝ))^2/256)
    (htail : 2*(∑ S ∈ Finset.univ\U, w S)+
      4*ellU*Real.log (1/(fieldLaw (WalshGaussianEnergy.matrix w)).real E) ≤ b^2/256)
    (hamp : (∫ z, amplitudeFraction b z ∂cond (fieldLaw (WalshGaussianEnergy.matrix w)) E) ≤ 1/32) :
    (1:ℝ)/16 ≤ ConfidenceClipping.failure
      (confidence (cond (fieldLaw (WalshGaussianEnergy.matrix w)) E)) (13/20) := by
  apply failure_lower_of_sample_energy hd w hw s H U hdegree hcoercivity ellH ellU b
    (2*(Fintype.card J:ℝ)*(∑ S ∈ Finset.univ\H, w S)+
      4*G*Real.log (1/(fieldLaw (WalshGaussianEnergy.matrix w)).real E))
    hellH hellU hb hmaxH hmaxU E hE hEpos htrain
    (integrable_sampleBandEnergy_cond w (Finset.univ\H) s E hE hEpos)
    (conditional_sampleBandEnergy_le w hw (Finset.univ\H) s G hG hGram E hE hEpos) _ htail hamp
  have hn : (Fintype.card J:ℝ) ≠ 0 := by exact_mod_cast Fintype.card_ne_zero
  convert hhead using 1 <;> field_simp <;> ring

/-- All Gaussian population amplitude hypotheses are discharged for the
actual neural covariance. The remaining inequalities contain only finite
sample matrices, actual spectrum, and the event's scalar log probability. -/
theorem neural_confidence_failure_lower (hd : 0 < d) (k v m : ℕ) (hv : v ≤ d) (hm : 0 < m)
    (s : J → ClippingCube d) (H U : Finset (Finset (Fin d)))
    (hdegree : ∀ S ∈ U, S.card ≤ u)
    (hcoercivity : ∀ c : Finset (Fin d) → ℝ, (∀ S, c S ≠ 0 → S ∈ H) →
      (1/4:ℝ)*uniformCubeMean (fun x => walshExpansion c x^2) ≤
        (∑ j, (max 0 (-(fullParity (s j)*walshExpansion c (s j))))^2)/Fintype.card J)
    (G ellH ellU a t : ℝ) (hG : 0 < G) (hellH : 0 < ellH) (hellU : 0 < ellU) (ht : 0 ≤ t)
    (ha : Real.sqrt (walshSpectralTail (arcsineProfile d (k+1)) v/2)/2 ≤ a)
    (hmaxH : ∀ S ∈ Finset.univ\H, walshCoefficients (arcsineProfile d (k+1)) S ≤ ellH)
    (hmaxU : ∀ S ∈ Finset.univ\U, walshCoefficients (arcsineProfile d (k+1)) S ≤ ellU)
    (hGram : ∀ q : J → ℝ, finiteQuadratic (fun i j => walshTailKernel (Finset.univ\H)
      (walshCoefficients (arcsineProfile d (k+1))) (s i) (s j)) q ≤ G*∑ j, q j^2)
    (E : Set (ClippingCube d → ℝ)) (hE : MeasurableSet E)
    (hEpos : fieldLaw (WalshGaussianEnergy.matrix (walshCoefficients (arcsineProfile d (k+1)))) E ≠ 0)
    (htrain : ∀ z ∈ E, ∀ j, 0 ≤ fullParity (s j)*z (s j))
    (hmargin : ∀ z ∈ E, ∀ x, a < |z x|) :
    let w := walshCoefficients (arcsineProfile d (k+1))
    let sigma := Real.sqrt (walshSpectralTail (arcsineProfile d (k+1)) v/2)
    let b := (a+sigma*t)/2
    let D := Real.log (1/(fieldLaw (WalshGaussianEnergy.matrix w)).real E)
    (u:ℝ)^2*(10*(∑ S ∈ Finset.univ\H, w S)+(16*G/(Fintype.card J:ℝ)+4*ellH)*D)
      ≤ (b*(d:ℝ))^2/256 →
    2*(∑ S ∈ Finset.univ\U, w S)+4*ellU*D ≤ b^2/256 →
    (D/GaussianAmplitude.smallBall t+(4*sigma^2/(a+sigma*t)^2)*(2*(m:ℝ)+4*D))/(m:ℝ)+
      4*(m:ℝ)^2/(d.choose v:ℝ) ≤ 1/32 →
    (1:ℝ)/16 ≤ ConfidenceClipping.failure
      (confidence (cond (fieldLaw (WalshGaussianEnergy.matrix w)) E)) (13/20) := by
  dsimp only
  intro hhead htail hamp
  have hsig : 0 < Real.sqrt (walshSpectralTail (arcsineProfile d (k+1)) v/2) :=
    Real.sqrt_pos.mpr (half_pos (arcsineSpectralTail_pos d k v hv))
  have hb : 0 < (a+Real.sqrt (walshSpectralTail (arcsineProfile d (k+1)) v/2)*t)/2 := by
    have := mul_nonneg hsig.le ht
    linarith
  apply confidence_failure_lower hd _ (fun S => (iterated_arcsine_coefficient_pos d k S).le)
    s H U hdegree hcoercivity G ellH ellU _ hG hellH hellU hb hmaxH hmaxU hGram E hE hEpos
    htrain hhead htail
  exact (GaussianAmplitude.neural_population_amplitude d k v m hv hm a t ht ha E hE hEpos hmargin).trans hamp

end NeuralGeneralization.GaussianZeroDeterministic
