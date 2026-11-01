import NeuralGeneralization.SubcriticalNegativeLargeSample
import NeuralGeneralization.GaussianSmallSample

/-! The paper's separate negative-exponent theorem, retaining its sharper
3/8 confidence-failure fraction for every sample count, including zero. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open Filter
open scoped Topology
namespace NeuralGeneralization.SubcriticalNegativeLargeSample
open ConcreteModel SmallSampleCutoff SubcriticalNeuralEndpoints

/-- At the buffered confidence threshold 13/20, the actual Gaussian sign
posterior has failure fraction at least 3/8 with probability at least 3/4
throughout one exponential sample interval. -/
theorem gaussian_sign_posterior_exponential :
    ∀ k : ℕ, ∃ c : ℝ, 0<c ∧ ∃ d₀ : ℕ, ∀ d : ℕ, d₀≤d → ∀ n : ℕ,
      (n:ℝ)≤Real.exp (c*(d:ℝ)) →
      (3/4:ℝ)≤sampleProbability (uniformLaw d) n
        (fun s => (3/8:ℝ)≤gaussianFailure d k n s) := by
  intro k
  obtain ⟨c,hc,hl⟩ := eventually_gaussian_large_sample_lower_bound k
  have he : ∀ᶠ d : ℕ in atTop, ∀ n : ℕ, (n:ℝ)≤Real.exp (c*(d:ℝ)) →
      (3/4:ℝ)≤sampleProbability (uniformLaw d) n
        (fun s => (3/8:ℝ)≤gaussianFailure d k n s) := by
    filter_upwards [hl,GaussianSmallSample.eventually_neural_function_posterior_failure
      (1/8) (by norm_num)] with d hlarge hsmall n hn
    by_cases hs : (n:ℝ)≤Real.exp (logDimension d^3)
    · have hpoint (s : Fin n→Cube d) : (3/8:ℝ)≤gaussianFailure d k n s := by
        simpa only [show (1/2:ℝ)-1/8=3/8 by norm_num,gaussianFailure] using hsmall n hs k s
      have hmono := sampleProbability_mono (uniformLaw d) n
        (E := fun _ => True) (F := fun s => (3/8:ℝ)≤gaussianFailure d k n s)
        (fun s _ => hpoint s)
      rw [sampleProbability_true] at hmono
      linarith
    · exact hlarge n (le_of_not_ge hs) hn
  obtain ⟨d₀,hd₀⟩ := eventually_atTop.mp he
  exact ⟨c,hc,d₀,hd₀⟩

/-- The finite-width strict-2/3 prediction convention inherits the same
3/8 lower bound for every negative exponent. Constants and dimension
thresholds are chosen before the exponent, margin, and sample count. -/
theorem negative_gamma_exponential_sharp (k : ℕ) :
    ∃ c : ℝ, 0<c ∧ ∃ d₀ : ℕ, ∀ d : ℕ, d₀≤d → 1≤d → ∀ n : ℕ,
      (n:ℝ)≤Real.exp (c*(d:ℝ)) → ∀ γ : ℝ, γ<0 → ∀ a : ℝ,
      (3/4:ℝ)≤sampleProbability (uniformLaw d) n (fun s =>
        (3/8:ℝ)≤Filter.liminf (MainStatements.parityFailure d k n a γ s) atTop) := by
  obtain ⟨c,hc,d₀,hd₀⟩ := gaussian_sign_posterior_exponential k
  refine ⟨c,hc,d₀,?_⟩
  intro d hd hd1 n hn γ hγ a
  apply (hd₀ d hd n hn).trans
  apply sampleProbability_mono
  intro s hs
  have ht := NetworkGaussianFunctionLimit.gamma_negative_confidence_liminf
    (by omega) k hγ a (parity d) s (uniformLaw d) (13/20) (by norm_num)
  rw [uniform_bufferedFailure_eq] at ht
  exact hs.trans ht

#print axioms gaussian_sign_posterior_exponential
#print axioms negative_gamma_exponential_sharp
end NeuralGeneralization.SubcriticalNegativeLargeSample
