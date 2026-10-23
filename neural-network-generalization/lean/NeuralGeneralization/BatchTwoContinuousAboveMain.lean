import NeuralGeneralization.BatchTwoContinuousAboveExplicit

/-! The literal γ>1 part of the continuous-domain finite-scale main theorem. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoContinuous.Above
open ConcreteModel CompressionSampling BatchTwoNonGaussian

theorem aboveMeanField :
    ∀ r : ℕ, ∀ ν : CoordinateLaw, ∀ γ : ℝ, 1<γ →
    ∃ A : ℝ, 0<A ∧ ∃ m : ℕ,
    ∀ d C : ℕ, 1≤d → 1≤C → ∀ B : ℝ, 1≤B →
    ∀ teacher : Weights d C r, boundedWeights B teacher →
    ∀ X : Set (RealInput d), admissibleDomain X →
    ∀ N : ℕ, C≤N → ∀ D : Measure (RealInput d), IsProbabilityMeasure D → D Xᶜ=0 →
    ∀ ρ τ ε δ : ℝ, 0<ρ → ρ<τ → 0<ε → ε<1 → 0<δ → δ<1 →
    ∀ n : ℕ,
      (6/ε)*(regressionEnvelope A m d C B (inverseGap ρ τ)
        (logInverseTolerance ρ) (Real.log (1/ε))+Real.log (6/(ε*δ)))≤(n : ℝ) →
      1-δ≤(iidSamples D n).real {s |
        let Q := posterior Real.tanh (powerPrior ν d N r γ) (output Real.tanh teacher) ρ s
        risk Real.tanh D Q (output Real.tanh teacher) τ≤ε/3 ∧
        confidenceFailure Real.tanh D Q (output Real.tanh teacher) τ≤ε} := by
  intro r ν γ hγ
  obtain ⟨N₀,hlearn⟩ := learning ν γ hγ
  obtain ⟨A₀,hA₀,p,hcost⟩ := FiniteTarget.targetCost_polynomial_envelope ν r
  obtain ⟨mγ,hmγ⟩ := exists_truncation_polynomial_degree γ hγ
  let a := ⌈A₀⌉₊
  obtain ⟨A,hA,m,hpoly⟩ := (sampleBudget_growth ν a p r N₀ mγ).shifted_ceil_real_envelope
  refine ⟨A,hA,m,?_⟩
  intro d C hd hC B hB teacher hteacher X hX N hCN D hD hDX ρ τ ε δ hρ hgap hε hε1 hδ _ n hn
  let u := inverseGap ρ τ
  let v := logInverseTolerance ρ
  let t := Real.log (1/ε)
  let z := B+u+v+t
  let S := C+⌈z⌉₊
  have hu : 1≤u := inverseGap_ge_one hgap
  have hv : 0≤v := by
    exact Real.log_nonneg ((one_le_div (lt_min zero_lt_one hρ)).mpr (min_le_left _ _))
  have ht : 0≤t := Real.log_nonneg ((one_le_div hε).mpr hε1.le)
  have hz : 0≤z := by dsimp [z]; linarith
  have hS : (C : ℝ)+z≤(S : ℝ) := by
    dsimp only [S]
    push_cast
    linarith [Nat.le_ceil z]
  have hus : u≤(S : ℝ) := by dsimp only [z] at hS; linarith [Nat.cast_nonneg C (α:=ℝ)]
  have hts : t≤(S : ℝ) := by dsimp only [z] at hS; linarith [Nat.cast_nonneg C (α:=ℝ)]
  have hcost' : FiniteTarget.targetCost ν d C r B ρ≤(targetBudget a p d S : ℝ) := by
    have hc := hcost d C B ρ (by linarith) hρ
    have hbase : 1+(d : ℝ)+(C : ℝ)+B+v≤1+(d : ℝ)+(S : ℝ) := by
      dsimp only [z] at hS
      linarith
    have hp := pow_le_pow_left₀ (by positivity : 0≤1+(d : ℝ)+(C : ℝ)+B+v) hbase p
    have hh := mul_le_mul (Nat.le_ceil A₀) hp (by positivity) (Nat.cast_nonneg a)
    unfold targetBudget
    push_cast
    exact hc.trans hh
  apply hlearn r a p mγ d C S hmγ hd hC B ρ τ ε δ (by linarith) hρ hgap hε hε1 hδ
    hus hts hcost' teacher hteacher X hX N hCN D hD hDX n
  apply le_trans _ hn
  apply mul_le_mul_of_nonneg_left _ (by positivity : 0≤6/ε)
  apply add_le_add _ le_rfl
  have hh := hpoly d C z hz
  have he : A*(1+(d : ℝ)+(C : ℝ)+z)^m=
      regressionEnvelope A m d C B u v t := by
    unfold regressionEnvelope
    dsimp only [z]
    congr 2
    ring
  rwa [he] at hh

#print axioms aboveMeanField
end NeuralGeneralization.BatchTwoContinuous.Above
