import NeuralGeneralization.BatchTwoContinuousClassificationSupport

/-! Full-measure-support form of the manuscript classification corollary.
The learner receives the original binary labels. No condition is imposed on
labels at null inputs, and no global margin is imposed on the prior. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Filter
namespace NeuralGeneralization.BatchTwoContinuous.Classification
open ConcreteModel CompressionSampling BatchTwoNonGaussian

theorem finite_scale_classification_ae :
    ∀ r : ℕ, ∀ ν : CoordinateLaw, ∀ γ : ℝ, 1≤γ →
    ∃ A : ℝ, 0<A ∧ ∃ m : ℕ,
    ∀ d C : ℕ, 1≤d → 1≤C → ∀ B margin : ℝ, 1≤B → 0<margin →
    ∀ teacher : Weights d C r, boundedWeights B teacher →
    ∀ X : Set (RealInput d), admissibleDomain X →
    ∀ label : RealInput d→Bool,
    ∀ N : ℕ, C≤N → ∀ D : Measure (RealInput d), IsProbabilityMeasure D → D Xᶜ=0 →
    (∀ᵐ x ∂D,margin≤labelReal (label x)*output Real.tanh teacher x) →
    ∀ ε δ : ℝ, 0<ε → ε<1 → 0<δ → δ<1 → ∀ n : ℕ,
    (6/ε)*(regressionEnvelope A m d C (weightBound B margin) 4 (Real.log 2)
      (Real.log (1/ε))+Real.log (6/(ε*δ)))≤(n:ℝ) →
    1-δ≤(iidSamples D n).real {s |
      let Q := posterior Real.tanh (powerPrior ν d N r γ) label s
      confidenceFailure Real.tanh D Q label≤ε} := by
  intro r ν γ hγ
  obtain ⟨A,hA,m,hlearn⟩ := finite_scale_classification r ν γ hγ
  refine ⟨A,hA,m,?_⟩
  intro d C hd hC B margin hB hm teacher hw X hX label N hCN D hD hDX hmargin ε δ hε hε1 hδ hδ1 n hn
  letI := hD
  obtain ⟨hDS,hle⟩ := ae_margin_support teacher X D hDX label hm hmargin
  have hs : ∀ᵐ x ∂D,x∈marginSupport teacher X margin := by rw [ae_iff]; exact hDS
  have hS := marginSupport_admissible teacher X hX margin hs.exists
  apply success_probability_transfer Real.tanh (powerPrior ν d N r γ) D hle
  apply hlearn d C hd hC B margin hB hm teacher hw (marginSupport teacher X margin) hS
    (teacherLabel teacher) (measurable_teacherLabel teacher) _ N hCN D hD hDS ε δ hε hε1 hδ hδ1 n hn
  intro x hx
  rw [teacherLabel_mul_output]
  exact hx.2

#print axioms finite_scale_classification_ae

theorem strong_prior_classification_ae :
    ∀ r : ℕ, ∀ ν : CoordinateLaw,
    ∃ A : ℝ, 0<A ∧ ∃ m : ℕ,
    ∀ d C : ℕ, 1≤d → 1≤C → ∀ B margin : ℝ, 1≤B → 0<margin →
    ∀ teacher : Weights d C r, boundedWeights B teacher →
    ∀ X : Set (RealInput d), admissibleDomain X →
    ∀ label : RealInput d→Bool,
    ∀ N : ℕ, C≤N → ∀ ε : ℝ, 0<ε → ε<1 →
    ∃ σ₀ : ℝ, 0<σ₀ ∧ ∀ σ : ℝ, 0<σ → σ<σ₀ →
    ∀ D : Measure (RealInput d), IsProbabilityMeasure D → D Xᶜ=0 →
    (∀ᵐ x ∂D,margin≤labelReal (label x)*output Real.tanh teacher x) →
    ∀ δ : ℝ, 0<δ → δ<1 → ∀ n : ℕ,
    (6/ε)*(regressionEnvelope A m d C (weightBound B margin) 4 0 0+Real.log (1/δ))≤(n:ℝ) →
    1-δ≤(iidSamples D n).real {s |
      let Q := posterior Real.tanh (smallPrior ν d N r σ) label s
      confidenceFailure Real.tanh D Q label≤ε} := by
  intro r ν
  obtain ⟨A,hA,m,hlearn⟩ := strong_prior_classification r ν
  refine ⟨A,hA,m,?_⟩
  intro d C hd hC B margin hB hm teacher hw X hX label N hCN ε hε hε1
  by_cases hne : (marginSupport teacher X margin).Nonempty
  · have hS := marginSupport_admissible teacher X hX margin hne
    obtain ⟨σ₀,hσ₀,hs⟩ := hlearn d C hd hC B margin hB hm teacher hw
      (marginSupport teacher X margin) hS (teacherLabel teacher) (measurable_teacherLabel teacher)
      (fun x hx => by rw [teacherLabel_mul_output]; exact hx.2) N hCN ε hε hε1
    refine ⟨σ₀,hσ₀,?_⟩
    intro σ hσ hσlt D hD hDX hmargin δ hδ hδ1 n hn
    letI := hD
    obtain ⟨hDS,hle⟩ := ae_margin_support teacher X D hDX label hm hmargin
    apply success_probability_transfer Real.tanh (smallPrior ν d N r σ) D hle
    exact hs σ hσ hσlt D hD hDS δ hδ hδ1 n hn
  · refine ⟨1,by norm_num,?_⟩
    intro σ hσ hσlt D hD hDX hmargin δ hδ hδ1 n hn
    letI := hD
    have hDS := (ae_margin_support teacher X D hDX label hm hmargin).1
    have hs : ∀ᵐ x ∂D,x∈marginSupport teacher X margin := by rw [ae_iff]; exact hDS
    exact (hne hs.exists).elim

#print axioms strong_prior_classification_ae

end NeuralGeneralization.BatchTwoContinuous.Classification
