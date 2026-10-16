import NeuralGeneralization.SubcriticalSmallSample
import NeuralGeneralization.SubcriticalPositiveLargeSample
import NeuralGeneralization.SubcriticalNegativeLargeSample
import NeuralGeneralization.SubcriticalZeroLargeSample

/-! # The actual exponential sample lower bound for every subcritical exponent

The three large-sample regimes and the uniform small-sample theorem share one
positive exponential rate and one dimension threshold. Width tends to infinity
with dimension, sample size and exponent fixed, exactly as in the main statement.
-/
noncomputable section
open Filter
namespace NeuralGeneralization.MainProofs
open ConcreteModel MainStatements SmallSampleCutoff SubcriticalNeuralEndpoints

/-- All fixed exponents below one, including zero and negative exponents,
have the stated exponential full-parity sample lower bound under the actual
strict global-margin posterior and strict two-thirds confidence rule. -/
theorem subcriticalExponential : SubcriticalExponentialLowerBound := by
  intro k a ha
  obtain ⟨cp,hcp,hpositive⟩ :=
    SubcriticalPositiveLargeSample.eventually_positive_large_sample_lower_bound k a ha
  obtain ⟨cn,hcn,hnegative⟩ :=
    SubcriticalNegativeLargeSample.eventually_negative_large_sample_lower_bound k a
  obtain ⟨cz,hcz,hzero⟩ :=
    SubcriticalZeroLargeSample.eventually_zero_large_sample_lower_bound k a ha
  let c := min cp (min cn cz)
  have hc : 0<c := lt_min hcp (lt_min hcn hcz)
  have hcP : c≤cp := min_le_left _ _
  have hcN : c≤cn := (min_le_right _ _).trans (min_le_left _ _)
  have hcZ : c≤cz := (min_le_right _ _).trans (min_le_right _ _)
  have hevent : ∀ᶠ d : ℕ in atTop, ∀ n : ℕ, (n:ℝ)≤Real.exp (c*(d:ℝ)) →
      ∀ γ : ℝ, γ<1 →
      (3/4:ℝ)≤sampleProbability (uniformLaw d) n (fun s =>
        (1/16:ℝ)≤Filter.liminf (parityFailure d k n a γ s) atTop) := by
    filter_upwards [SubcriticalSmallSample.eventually_small_sample_lower_bound k a ha,
      hpositive,hnegative,hzero] with d hsmall hpos hneg hzer n hn γ hγ
    by_cases hsize : (n:ℝ)≤Real.exp (logDimension d^3)
    · exact hsmall n hsize γ hγ
    have hmin := (lt_of_not_ge hsize).le
    have hmax (b : ℝ) (hcb : c≤b) : (n:ℝ)≤Real.exp (b*(d:ℝ)) :=
      hn.trans (Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_right hcb (Nat.cast_nonneg _)))
    rcases lt_trichotomy γ 0 with hγn | hγz | hγp
    · exact hneg n hmin (hmax cn hcN) γ hγn
    · subst γ
      exact hzer n hmin (hmax cz hcZ)
    · exact hpos n hmin (hmax cp hcP) γ hγp hγ
  obtain ⟨d₀,hd₀⟩ := eventually_atTop.mp hevent
  refine ⟨c,hc,d₀,?_⟩
  intro d hd hd1 n hn γ hγ
  exact ⟨subcritical_denominators_eventually_pos hd1 k hγ ha (parity d),
    hd₀ d hd n hn γ hγ⟩

end NeuralGeneralization.MainProofs
