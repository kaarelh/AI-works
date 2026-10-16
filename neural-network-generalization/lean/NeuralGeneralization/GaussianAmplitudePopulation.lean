import NeuralGeneralization.AuxiliaryNeuralGram

/-! # Averaging the finite Gaussian amplitude bound over auxiliary samples

The auxiliary sample is genuinely independent of the conditioned field.
The event conditioning the field may still depend on every cube input.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.GaussianAmplitude
open CompressionSampling GaussianFieldTilt
variable {d m : ℕ}

/-- Averaging a selected-count bound on a high-probability auxiliary event
produces a population-fraction bound. -/
theorem population_fraction_le_of_selected_count
    (μ : Measure (ClippingCube d → ℝ)) [IsProbabilityMeasure μ]
    (b B : ℝ) (hB : 0 ≤ B) (hm : 0 < m)
    (Good : Set (Fin m → ClippingCube d))
    (hcount : ∀ s ∈ Good, (∫ z, smallMeanCount b (z ∘ s) ∂μ) ≤ B) :
    (∫ z, uniformCubeMean (fun x => if |z x| ≤ b then (1:ℝ) else 0) ∂μ) ≤
      B/(m:ℝ)+(iidSamples (uniformCubeMeasure d) m).real Goodᶜ := by
  classical
  let ν := iidSamples (uniformCubeMeasure d) m
  let F := fun s : Fin m → ClippingCube d => ∫ z, smallMeanCount b (z ∘ s) ∂μ
  have hmeas : Measurable (fun p : (ClippingCube d → ℝ) × (Fin m → ClippingCube d) => p.1 ∘ p.2) := by
    apply measurable_from_prod_countable_left
    intro s
    fun_prop
  have hint := integrable_smallMeanCount (μ.prod ν) _ hmeas b
  have hswap := integral_integral_swap (f:=fun z s => smallMeanCount b (z ∘ s)) hint
  change (∫ z, ∫ s, smallMeanCount b (z ∘ s) ∂ν ∂μ) = ∫ s, F s ∂ν at hswap
  have havg : (m:ℝ)*(∫ z, uniformCubeMean (fun x => if |z x| ≤ b then (1:ℝ) else 0) ∂μ) =
      ∫ s, F s ∂ν := by
    simpa only [ν, uniformCubeSample_smallMeanCount, integral_const_mul] using hswap
  have hpoint (s : Fin m → ClippingCube d) :
      F s ≤ B+Goodᶜ.indicator (fun _ => (m:ℝ)) s := by
    by_cases hs : s ∈ Good
    · simpa [hs] using hcount s hs
    · have hf : F s ≤ m := by
        calc
          _ ≤ ∫ _z, (m:ℝ) ∂μ := integral_mono
            (integrable_smallMeanCount μ _ (by fun_prop) b) (integrable_const _)
            (fun z => by simpa using smallMeanCount_le_card b (z ∘ s))
          _ = _ := by simp
      simpa [hs] using hf.trans (le_add_of_nonneg_left hB)
  have hbound : (∫ s, F s ∂ν) ≤ B+(m:ℝ)*ν.real Goodᶜ := by
    calc
      _ ≤ ∫ s, B+Goodᶜ.indicator (fun _ => (m:ℝ)) s ∂ν :=
        integral_mono Integrable.of_finite Integrable.of_finite hpoint
      _ = _ := by
        rw [integral_add (integrable_const _) Integrable.of_finite, integral_const,
          integral_indicator_const _ (Set.toFinite _).measurableSet]
        simp [mul_comm]
  have hmR : (0:ℝ) < m := Nat.cast_pos.mpr hm
  apply (mul_le_mul_iff_right₀ hmR).mp
  rw [havg]
  convert! hbound using 1
  dsimp [ν]
  field_simp

/-- The actual all-depth neural covariance and actual IID auxiliary Gram
bound give this finite population-amplitude inequality. -/
theorem neural_population_amplitude (d k r m : ℕ) (hr : r ≤ d) (hm : 0 < m)
    (a t : ℝ) (ht : 0 ≤ t)
    (ha : Real.sqrt (walshSpectralTail (arcsineProfile d (k+1)) r/2)/2 ≤ a)
    (E : Set (ClippingCube d → ℝ)) (hE : MeasurableSet E)
    (hEpos : fieldLaw (fun x S => WalshGaussianLaw.features
      (walshCoefficients (arcsineProfile d (k+1))) S x) E ≠ 0)
    (hmargin : ∀ z ∈ E, ∀ x, a < |z x|) :
    let A := fun x S => WalshGaussianLaw.features (walshCoefficients (arcsineProfile d (k+1))) S x
    let sigma := Real.sqrt (walshSpectralTail (arcsineProfile d (k+1)) r/2)
    let D := Real.log (1/(fieldLaw A).real E)
    (∫ z, uniformCubeMean (fun x => if |z x| ≤ (a+sigma*t)/2 then (1:ℝ) else 0)
      ∂cond (fieldLaw A) E) ≤
      (D/smallBall t+(4*sigma^2/(a+sigma*t)^2)*(2*(m:ℝ)+4*D))/(m:ℝ)+
        4*(m:ℝ)^2/(d.choose r:ℝ) := by
  classical
  dsimp only
  let A := fun x S => WalshGaussianLaw.features (walshCoefficients (arcsineProfile d (k+1))) S x
  let sigma := Real.sqrt (walshSpectralTail (arcsineProfile d (k+1)) r/2)
  let D := Real.log (1/(fieldLaw A).real E)
  let B := D/smallBall t+(4*sigma^2/(a+sigma*t)^2)*(2*(m:ℝ)+4*D)
  let Good := {s : Fin m → ClippingCube d | ∀ b : Fin m → ℝ,
    |finiteQuadratic (fun i j => arcsineTailCovariance d (k+1) r (s i) (s j)) b-
      walshSpectralTail (arcsineProfile d (k+1)) r*(∑ i, b i^2)| ≤
      ((1:ℝ)/2)*walshSpectralTail (arcsineProfile d (k+1)) r*(∑ i, b i^2)}
  letI : IsProbabilityMeasure (cond (fieldLaw A) E) := cond_isProbabilityMeasure hEpos
  have hsig : 0 < sigma := Real.sqrt_pos.mpr (half_pos (arcsineSpectralTail_pos d k r hr))
  have hD : 0 ≤ D := by
    apply Real.log_nonneg
    have hp : 0 < (fieldLaw A).real E := ENNReal.toReal_pos hEpos (measure_ne_top _ _)
    exact (le_div_iff₀ hp).mpr (by simp)
  have hB : 0 ≤ B := by
    dsimp [B]
    exact add_nonneg (div_nonneg hD (smallBall_pos ht).le)
      (mul_nonneg (div_nonneg (by positivity) (sq_nonneg _)) (by positivity))
  have hcount (s : Fin m → ClippingCube d) (hs : s ∈ Good) :
      (∫ z, smallMeanCount ((a+sigma*t)/2) (z ∘ s) ∂cond (fieldLaw A) E) ≤ B := by
    have hh := finite_gaussian_amplitude A s a sigma t hsig ht ha
      (arcsineFeatureGram_floor_of_tail_event d k r m hr s hs) E hE hEpos
      (fun z hz i => hmargin z hz (s i))
    simpa only [Fintype.card_fin] using hh
  have hpop := population_fraction_le_of_selected_count (cond (fieldLaw A) E)
    ((a+sigma*t)/2) B hB hm Good hcount
  have hgood := arcsineTailGram_quadratic_probability d k r m hr ((1:ℝ)/2) (by norm_num)
  rw [← uniformCubeSample_measure_eq_probability] at hgood
  have hbad : (iidSamples (uniformCubeMeasure d) m).real Goodᶜ ≤ 4*(m:ℝ)^2/(d.choose r:ℝ) := by
    rw [probReal_compl_eq_one_sub (Set.toFinite Good).measurableSet]
    change 1-(m:ℝ)^2/(((1:ℝ)/2)^2*(d.choose r:ℝ)) ≤
      (iidSamples (uniformCubeMeasure d) m).real Good at hgood
    have heq : (m:ℝ)^2/(((1:ℝ)/2)^2*(d.choose r:ℝ)) = 4*(m:ℝ)^2/(d.choose r:ℝ) := by ring
    rw [heq] at hgood
    linarith only [hgood]
  exact hpop.trans (add_le_add le_rfl hbad)

end NeuralGeneralization.GaussianAmplitude
