import NeuralGeneralization.GaussianSmallSample
import NeuralGeneralization.PositiveSmallSample
import NeuralGeneralization.GaussianZeroSmallSampleCost
import NeuralGeneralization.NeuralComparatorProbability
import NeuralGeneralization.NeuralPolynomialInterpolant
import NeuralGeneralization.SubcriticalNeuralEndpoints
import NeuralGeneralization.Statements

/-! The complete small-sample neural theorem for every gamma below one.
All rate, Gaussian conditioning, spectral, interpolation, sampling and
strict-confidence arguments are discharged for the actual network prior. -/
noncomputable section
open Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.SubcriticalSmallSample
open ConcreteModel LocalizedCubeBump SmallSampleCutoff NetworkGaussianFunctionLimit
  SubcriticalNeuralEndpoints WalshMarginMinimizers

/-- For any fixed depth and positive global margin, one dimension threshold
works simultaneously for all real exponents below one and all sample sizes
up to exp(log(d+1)^3). The width tends to infinity first. -/
theorem eventually_small_sample_lower_bound (r : ℕ) (a : ℝ) (ha : 0 < a) :
    ∀ᶠ d : ℕ in atTop, ∀ n : ℕ, (n : ℝ) ≤ Real.exp (logDimension d^3) →
      ∀ γ : ℝ, γ < 1 →
      (3/4 : ℝ) ≤ sampleProbability (uniformLaw d) n (fun s =>
        (1/16 : ℝ) ≤ Filter.liminf (MainStatements.parityFailure d r n a γ s) atTop) := by
  classical
  filter_upwards [eventually_small_sample_neuralComparatorGood_probability r (1/4) (by norm_num),
    GaussianSmallSample.eventually_neural_function_posterior_failure (1/8) (by norm_num),
    GaussianZeroSmallSample.eventually_confidence_failure_of_comparator_event r a ha,
    PositiveSmallSample.eventually_confidence_liminf_of_polynomial_comparator
      (interpolantPolyConstant r a) (interpolantPolyConstant_nonneg r a) 3 a ha,
    eventually_ge_atTop 101]
    with d hgood hnegative hzero hpositive hd n hn γ hγ
  obtain ⟨hR, hsmall, hp⟩ := hgood n hn
  have hprob : (3/4 : ℝ) ≤ sampleProbability (uniformLaw d) n (neuralComparatorGood d r n) := by
    norm_num at hp
    exact hp
  apply hprob.trans
  apply sampleProbability_mono
  intro s hs
  rcases lt_trichotomy γ 0 with hneg | heq | hpos
  · have hg := hnegative n hn r s
    have ht := gamma_negative_confidence_liminf (by omega) r hneg a (parity d) s (uniformLaw d)
      (13/20) (by norm_num)
    rw [uniform_bufferedFailure_eq] at ht
    change (1/16 : ℝ) ≤ Filter.liminf (fun N => ConcreteModel.confidenceFailure (uniformLaw d) (parity d)
      (networkPosterior Real.tanh a (powerPrior d N r γ) (parity d) s)) atTop
    linarith
  · subst γ
    have hg := hzero n hn (d/10) hR hsmall s hs.1 hs.2
    have ht := gamma_zero_confidence_liminf (by omega) r a (parity d) s (uniformLaw d)
      (13/20) (by norm_num)
    rw [uniform_bufferedFailure_eq] at ht
    exact hg.trans ht
  · obtain ⟨P, hPglobal, hPtrain, hPenergy⟩ :=
      neural_polynomial_global_interpolant hd r (d/10) hR a ha s (parity d) hs.1 hsmall hs.2
    apply hpositive n hn r s _ γ hpos hγ
    refine ⟨walshCoefficients P, ?_, ?_⟩
    · constructor
      · intro x
        simpa only [walshExpansion_coefficients] using (hPglobal x).le
      · intro i
        simpa only [walshExpansion_coefficients] using (hPtrain i).le
    · convert hPenergy using 1 <;> ring

/-- An explicit existential dimension threshold version of the same actual
network result, convenient for the final exponential theorem assembly. -/
theorem small_sample_lower_bound (r : ℕ) (a : ℝ) (ha : 0 < a) :
    ∃ d₀ : ℕ, ∀ d : ℕ, d₀ ≤ d → ∀ n : ℕ,
      (n : ℝ) ≤ Real.exp (logDimension d^3) → ∀ γ : ℝ, γ < 1 →
      (3/4 : ℝ) ≤ sampleProbability (uniformLaw d) n (fun s =>
        (1/16 : ℝ) ≤ Filter.liminf (MainStatements.parityFailure d r n a γ s) atTop) :=
  eventually_atTop.mp (eventually_small_sample_lower_bound r a ha)

/-- The small-sample theorem with the same denominator and confidence
conclusions as the final exponential main statement. Its single dimension
threshold is independent of the sample size and of the subcritical exponent. -/
theorem small_sample_lower_bound_with_denominators (r : ℕ) (a : ℝ) (ha : 0 < a) :
    ∃ d₀ : ℕ, ∀ d : ℕ, d₀ ≤ d → 1 ≤ d → ∀ n : ℕ,
      (n : ℝ) ≤ Real.exp (logDimension d^3) → ∀ γ : ℝ, γ < 1 →
      (∀ᶠ N : ℕ in atTop, ∀ s : Fin n → Cube d,
        0 < posteriorDenominator Real.tanh a (powerPrior d N r γ) (parity d) s) ∧
      (3/4 : ℝ) ≤ sampleProbability (uniformLaw d) n (fun s =>
        (1/16 : ℝ) ≤ Filter.liminf (MainStatements.parityFailure d r n a γ s) atTop) := by
  obtain ⟨d₀, hd₀⟩ := small_sample_lower_bound r a ha
  refine ⟨d₀, fun d hd hd1 n hn γ hγ => ?_⟩
  exact ⟨subcritical_denominators_eventually_pos hd1 r hγ ha (parity d),
    hd₀ d hd n hn γ hγ⟩

end NeuralGeneralization.SubcriticalSmallSample
