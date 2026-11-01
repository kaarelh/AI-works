import NeuralGeneralization.BatchTwoContinuousClassificationStrongPolynomial
import NeuralGeneralization.BatchTwoContinuousClassificationAbovePolynomial
import NeuralGeneralization.BatchTwoContinuousClassificationFiniteMeanFieldPolynomial

/-! Classification corollary with its original binary-margin likelihood, all
learner widths N≥C, and a polynomial in B and the inverse teacher margin.
The teacher need only have a margin on the data support X. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoContinuous.Classification
open ConcreteModel CompressionSampling BatchTwoNonGaussian

def weightBound (B margin : ℝ) : ℝ := B*(1+3/(2*margin))

theorem rescaled_teacher {d C r : ℕ} (w : Weights d C r) {B margin : ℝ}
    (hB : 1≤B) (hm : 0<margin) (hw : boundedWeights B w)
    (X : Set (RealInput d)) (label : RealInput d→Bool)
    (hmargin : ∀ x∈X,margin≤labelReal (label x)*output Real.tanh w x) :
    1≤weightBound B margin ∧
    boundedWeights (weightBound B margin) (rescaleReadout (3/(2*margin)) w) ∧
    ∀ x∈X,(1:ℝ)≤labelReal (label x)*output Real.tanh (rescaleReadout (3/(2*margin)) w) x := by
  have hc : 0<3/(2*margin) := by positivity
  have hBb : B≤weightBound B margin := by unfold weightBound; nlinarith
  refine ⟨hB.trans hBb,?_,?_⟩
  · intro i
    rcases i with ij | (sij | j)
    · exact (hw _).trans hBb
    · exact (hw _).trans hBb
    · change |(3/(2*margin))*w (.inr (.inr j))|≤weightBound B margin
      rw [abs_mul,abs_of_pos hc]
      have hb := mul_le_mul_of_nonneg_left (hw (.inr (.inr j))) hc.le
      unfold weightBound
      nlinarith
  · intro x hx
    rw [output_rescaleReadout]
    have h := mul_le_mul_of_nonneg_left (hmargin x hx) hc.le
    have he : (3/(2*margin))*margin=(3/2:ℝ) := by field_simp
    rw [he] at h
    nlinarith

/-- Every fixed gamma≥1, including the critical exponent. The displayed
budget is polynomial in d,C,B,1/margin and the accuracy resources. -/
theorem finite_scale_classification :
    ∀ r : ℕ, ∀ ν : CoordinateLaw, ∀ γ : ℝ, 1≤γ →
    ∃ A : ℝ, 0<A ∧ ∃ m : ℕ,
    ∀ d C : ℕ, 1≤d → 1≤C → ∀ B margin : ℝ, 1≤B → 0<margin →
    ∀ teacher : Weights d C r, boundedWeights B teacher →
    ∀ X : Set (RealInput d), admissibleDomain X →
    ∀ label : RealInput d→Bool, Measurable label →
    (∀ x∈X,margin≤labelReal (label x)*output Real.tanh teacher x) →
    ∀ N : ℕ, C≤N → ∀ D : Measure (RealInput d), IsProbabilityMeasure D → D Xᶜ=0 →
    ∀ ε δ : ℝ, 0<ε → ε<1 → 0<δ → δ<1 → ∀ n : ℕ,
    (6/ε)*(regressionEnvelope A m d C (weightBound B margin) 4 (Real.log 2)
      (Real.log (1/ε))+Real.log (6/(ε*δ)))≤(n:ℝ) →
    1-δ≤(iidSamples D n).real {s |
      let Q := posterior Real.tanh (powerPrior ν d N r γ) label s
      risk Real.tanh D Q label≤ε/3 ∧ confidenceFailure Real.tanh D Q label≤ε} := by
  intro r ν γ hγ
  have hp : ∃ A : ℝ, 0<A ∧ ∃ m : ℕ,
      ∀ d C : ℕ, 1≤d → 1≤C → ∀ B : ℝ, 1≤B →
      ∀ teacher : Weights d C r, boundedWeights B teacher →
      ∀ X : Set (RealInput d), admissibleDomain X →
      ∀ N : ℕ, C≤N → ∀ D : Measure (RealInput d), IsProbabilityMeasure D → D Xᶜ=0 →
      ∀ ρ τ ε δ : ℝ, 0<ρ → ρ<τ → 0<ε → ε<1 → 0<δ → δ<1 →
      ∀ label : RealInput d→Bool, Measurable label →
      (∀ x∈X,1/2+ρ≤labelReal (label x)*output Real.tanh teacher x) → τ≤ρ+1/2 →
      ∀ n : ℕ,
      (6/ε)*(regressionEnvelope A m d C B (inverseGap ρ τ) (logInverseTolerance ρ)
        (Real.log (1/ε))+Real.log (6/(ε*δ)))≤(n:ℝ) →
      1-δ≤(iidSamples D n).real {s |
        let Q := posterior Real.tanh (powerPrior ν d N r γ) label s
        risk Real.tanh D Q label≤ε/3 ∧ confidenceFailure Real.tanh D Q label≤ε} := by
    rcases hγ.eq_or_lt with he | hgt
    · subst γ
      exact FiniteMeanField.classification_polynomial r ν
    · exact Above.classification_polynomial r ν γ hgt
  obtain ⟨A,hA,m,hlearn⟩ := hp
  refine ⟨A,hA,m,?_⟩
  intro d C hd hC B margin hB hm teacher hw X hX label hl hmargin N hCN D hD hDX ε δ hε hε1 hδ hδ1 n hn
  obtain ⟨hB',hw',hm'⟩ := rescaled_teacher teacher hB hm hw X label hmargin
  apply hlearn d C hd hC (weightBound B margin) hB' (rescaleReadout (3/(2*margin)) teacher)
    hw' X hX N hCN D hD hDX (1/2) (3/4) ε δ (by norm_num) (by norm_num)
    hε hε1 hδ hδ1 label hl (by convert hm' using 1 <;> norm_num) (by norm_num) n
  convert hn using 1 <;> norm_num [inverseGap,logInverseTolerance]

/-- Strong-prior classification. The scale threshold is chosen before the
input law, sample size and confidence parameter, at each fixed width N≥C. -/
theorem strong_prior_classification :
    ∀ r : ℕ, ∀ ν : CoordinateLaw,
    ∃ A : ℝ, 0<A ∧ ∃ m : ℕ,
    ∀ d C : ℕ, 1≤d → 1≤C → ∀ B margin : ℝ, 1≤B → 0<margin →
    ∀ teacher : Weights d C r, boundedWeights B teacher →
    ∀ X : Set (RealInput d), admissibleDomain X →
    ∀ label : RealInput d→Bool, Measurable label →
    (∀ x∈X,margin≤labelReal (label x)*output Real.tanh teacher x) →
    ∀ N : ℕ, C≤N → ∀ ε : ℝ, 0<ε → ε<1 →
    ∃ σ₀ : ℝ, 0<σ₀ ∧ ∀ σ : ℝ, 0<σ → σ<σ₀ →
    ∀ D : Measure (RealInput d), IsProbabilityMeasure D → D Xᶜ=0 →
    ∀ δ : ℝ, 0<δ → δ<1 → ∀ n : ℕ,
    (6/ε)*(regressionEnvelope A m d C (weightBound B margin) 4 0 0+Real.log (1/δ))≤(n:ℝ) →
    1-δ≤(iidSamples D n).real {s |
      let Q := posterior Real.tanh (smallPrior ν d N r σ) label s
      risk Real.tanh D Q label≤ε/3 ∧ confidenceFailure Real.tanh D Q label≤ε} := by
  intro r ν
  obtain ⟨A,hA,m,hlearn⟩ := strong_polynomial r ν
  refine ⟨A,hA,m,?_⟩
  intro d C hd hC B margin hB hm teacher hw X hX label hl hmargin N hCN ε hε hε1
  obtain ⟨hB',hw',hm'⟩ := rescaled_teacher teacher hB hm hw X label hmargin
  obtain ⟨σ₀,hσ₀,hs⟩ := hlearn d C hd hC (weightBound B margin) hB'
    (rescaleReadout (3/(2*margin)) teacher) hw' X hX N hCN (1/2) (3/4) ε
    (by norm_num) (by norm_num) hε hε1 label hl (by convert hm' using 1 <;> norm_num) (by norm_num)
  refine ⟨σ₀,hσ₀,?_⟩
  intro σ hσ hσlt D hD hDX δ hδ hδ1 n hn
  apply hs σ hσ hσlt D hD hDX δ hδ hδ1 n
  convert hn using 1 <;> norm_num [inverseGap]

#print axioms finite_scale_classification
#print axioms strong_prior_classification
end NeuralGeneralization.BatchTwoContinuous.Classification
