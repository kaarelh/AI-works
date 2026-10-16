import NeuralGeneralization.GaussianZeroModelBridge
import NeuralGeneralization.SmallSampleParity

/-! # Fixed-margin posterior hardness throughout the small-sample range

The finite ABFR obstruction is integrated under the actual conditioned
Gaussian field. Conditional tail energy, rather than a posterior-mean
classifier, supplies the approximation bound.
-/
noncomputable section
open Filter MeasureTheory ProbabilityTheory
open scoped BigOperators Topology
namespace NeuralGeneralization.GaussianZeroSmallSample
open GaussianBandEnergy GaussianMarginHeadBound GaussianMarginConfidence GaussianFieldTilt

lemma uniformParityError_le_drawRisk {d : ℕ} (z : ClippingCube d → ℝ) :
    uniformParityError z ≤ drawRisk z := by
  apply ConfidenceClipping.mean_mono
  intro x
  by_cases hz : 0 < fullParity x*z x
  · have he : binarySign (z x)=fullParity x := by
      rcases fullParity_sign x with hf | hf <;> rw [hf] at hz ⊢
      · simp [binarySign, (by linarith : 0 ≤ z x)]
      · simp [binarySign, (by linarith : ¬ 0 ≤ z x)]
    simp [hz, he]
  · simp only [if_neg hz]
    split_ifs <;> norm_num

/-- Integrating the exact finite threshold-degree obstruction gives a lower
bound on posterior draw risk under a strict global margin. -/
theorem risk_lower_of_ABFR {d u t : ℕ}
    (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S)
    (H : Finset (Finset (Fin d))) (hdegree : ∀ S ∈ H, S.card ≤ u) (hut : u+2*t<d)
    (ell b : ℝ) (hell : 0 < ell) (hb : 0 < b)
    (hmax : ∀ S ∈ Finset.univ\H, w S ≤ ell)
    (E : Set (ClippingCube d → ℝ)) (hE : MeasurableSet E)
    (hEpos : fieldLaw (WalshGaussianEnergy.matrix w) E ≠ 0)
    (hmargin : ∀ z ∈ E, ∀ x, b ≤ |z x|) :
    (Fintype.card (DegreeIndices d t):ℝ)/Fintype.card (ClippingCube d)-
      (2*(∑ S ∈ Finset.univ\H, w S)+4*ell*Real.log (1/(fieldLaw (WalshGaussianEnergy.matrix w)).real E))/b^2 ≤
      ∫ z, drawRisk z ∂cond (fieldLaw (WalshGaussianEnergy.matrix w)) E := by
  classical
  let μ := cond (fieldLaw (WalshGaussianEnergy.matrix w)) E
  letI : IsProbabilityMeasure μ := cond_isProbabilityMeasure hEpos
  let T := Finset.univ\H
  let A : ℝ := (Fintype.card (DegreeIndices d t):ℝ)/Fintype.card (ClippingCube d)
  have hi := integrable_bandEnergy_cond w hw T E hE hEpos
  have hpoint : ∀ᵐ z ∂μ, A-bandEnergy T z/b^2 ≤ drawRisk z := by
    apply ae_cond_of_forall_mem hE
    intro z hz
    let c := maskCoefficients H (walshCoefficients z)
    have hc : ∀ S, c S ≠ 0 → S.card ≤ u := by
      intro S hS
      by_cases hSH : S ∈ H
      · exact hdegree S hSH
      · exact False.elim (hS (by simp [c, maskCoefficients, hSH]))
    have hh := parity_error_lower_of_ABFR_approximation c hc hut z b hb (hmargin z hz)
    have he : uniformCubeMean (fun x => (z x-walshExpansion c x)^2)=bandEnergy T z := by
      change uniformCubeMean (fun x => (z x-walshProjection H z x)^2)=bandEnergy T z
      simp only [projection_residual, bandEnergy, T]
    rw [he] at hh
    exact hh.trans (uniformParityError_le_drawRisk z)
  have hh := integral_mono_ae ((integrable_const A).sub (hi.div_const _)) (integrable_drawRisk μ) hpoint
  simp only [Pi.sub_apply] at hh
  rw [integral_sub (f:=fun _ => A) (g:=fun z => bandEnergy T z/b^2)
    (integrable_const A) (hi.div_const _), integral_const, integral_div] at hh
  simp only [probReal_univ, smul_eq_mul, one_mul] at hh
  have htail := conditional_bandEnergy_le w hw T ell hell hmax E hE hEpos
  have hdv := div_le_div_of_nonneg_right htail (sq_nonneg b)
  dsimp only [μ, A, T] at hh hdv ⊢
  linarith

/-- A polynomial log-conditioning cost suffices throughout the actual
small-sample range, with every Gaussian and cutoff estimate discharged. -/
theorem eventually_confidence_failure (k : ℕ) (C : ℝ) (hC : 0 ≤ C) (m : ℕ)
    (b : ℝ) (hb : 0 < b) :
    ∀ᶠ d : ℕ in atTop, ∀ n : ℝ, 0 ≤ n → n ≤ Real.exp (SmallSampleCutoff.logDimension d^3) →
      ∀ E : Set (ClippingCube d → ℝ), MeasurableSet E →
      fieldLaw (WalshGaussianEnergy.matrix (walshCoefficients (arcsineProfile d (k+1)))) E ≠ 0 →
      (∀ z ∈ E, ∀ x, b ≤ |z x|) →
      Real.log (1/(fieldLaw (WalshGaussianEnergy.matrix (walshCoefficients (arcsineProfile d (k+1))))).real E)
        ≤ C*((d:ℝ)+1)^m*(1+n) →
      (1:ℝ)/16 ≤ ConfidenceClipping.failure
        (confidence (cond (fieldLaw (WalshGaussianEnergy.matrix
          (walshCoefficients (arcsineProfile d (k+1))))) E)) (13/20) := by
  classical
  have hlim : Tendsto (fun d : ℕ => 2*C/((d:ℝ)+1)) atTop (𝓝 0) :=
    tendsto_const_nhds.div_atTop (tendsto_atTop_add_const_right _ 1 tendsto_natCast_atTop_atTop)
  filter_upwards [SmallSampleCutoff.eventually_ABFR_lower (1/32) (by norm_num),
    SmallSampleCutoff.eventually_small_sample_ratio C hC m,
    (SmallSampleCutoff.spectral_tail_tendsto (k+1)).eventually
      (eventually_le_nhds (show (0:ℝ)<b^2/192 by positivity)),
    hlim.eventually (eventually_le_nhds (show (0:ℝ)<1 by norm_num))]
    with d hAB hratio htrace hratio1 n hn hnmax E hE hEpos hmargin hcost
  let w := walshCoefficients (arcsineProfile d (k+1))
  let H := SmallSampleCutoff.lowBand d
  let τ := walshSpectralTail (arcsineProfile d (k+1)) (SmallSampleCutoff.cutoff d)
  let ell := τ/(d.choose (SmallSampleCutoff.cutoff d):ℝ)
  have htau : 0 < τ := arcsineSpectralTail_pos d k _ hAB.1.le
  have hden : 0 < (d.choose (SmallSampleCutoff.cutoff d):ℝ) := by exact_mod_cast Nat.choose_pos hAB.1.le
  have hell : 0 < ell := div_pos htau hden
  have hdegree : ∀ S ∈ H, S.card ≤ SmallSampleCutoff.cutoff d := by
    intro S hS
    exact (Finset.mem_filter.mp hS).2.le
  have hmax : ∀ S ∈ Finset.univ\H, w S ≤ ell := by
    intro S hS
    have hcard : SmallSampleCutoff.cutoff d ≤ S.card := by simpa [H, SmallSampleCutoff.lowBand] using hS
    exact (le_div_iff₀ hden).mpr (by simpa only [mul_comm] using
      arcsineProfile_coefficient_binomial_le_tail (k+1) (SmallSampleCutoff.cutoff d) S hcard)
  have hsum : (∑ S ∈ Finset.univ\H, w S)=τ := by
    congr 1
    ext S
    simp [H, SmallSampleCutoff.lowBand, not_lt]
  have hbound : ell*Real.log (1/(fieldLaw (WalshGaussianEnergy.matrix w)).real E) ≤ τ := by
    calc
      _ ≤ ell*(C*((d:ℝ)+1)^m*(1+n)) := mul_le_mul_of_nonneg_left hcost hell.le
      _ = (C*((d:ℝ)+1)^m*(1+n)/(d.choose (SmallSampleCutoff.cutoff d):ℝ))*τ := by dsimp [ell]; ring
      _ ≤ (2*C/((d:ℝ)+1))*τ := mul_le_mul_of_nonneg_right (hratio n hn hnmax) htau.le
      _ ≤ 1*τ := mul_le_mul_of_nonneg_right hratio1 htau.le
      _ = _ := one_mul _
  have hh := risk_lower_of_ABFR w (fun S => (iterated_arcsine_coefficient_pos d k S).le)
    H hdegree (by omega : SmallSampleCutoff.cutoff d+2*((d-SmallSampleCutoff.cutoff d-1)/2)<d)
    ell b hell hb hmax E hE hEpos hmargin
  rw [hsum] at hh
  have htail : (2*τ+4*ell*Real.log (1/(fieldLaw (WalshGaussianEnergy.matrix w)).real E))/b^2 ≤ 1/32 := by
    apply (div_le_iff₀ (sq_pos_of_pos hb)).mpr
    change τ ≤ b^2/192 at htrace
    nlinarith [hbound]
  letI := cond_isProbabilityMeasure hEpos
  have hr := risk_le_failure (cond (fieldLaw (WalshGaussianEnergy.matrix w)) E)
  have hCDF := hAB.2
  nlinarith only [hh, htail, hCDF, hr]

end NeuralGeneralization.GaussianZeroSmallSample
