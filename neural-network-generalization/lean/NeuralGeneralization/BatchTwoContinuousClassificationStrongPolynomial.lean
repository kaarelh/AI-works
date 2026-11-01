import NeuralGeneralization.BatchTwoContinuousStrongBudget
import NeuralGeneralization.BatchTwoContinuousClassificationStrong

/-! The literal strong-prior main theorem from the continuous-domain paper. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel

theorem Classification.strong_polynomial :
  ∀ r : ℕ, ∀ ν : BatchTwoNonGaussian.CoordinateLaw,
    ∃ A : ℝ, 0<A ∧ ∃ m : ℕ,
    ∀ d C : ℕ, 1≤d → 1≤C → ∀ B : ℝ, 1≤B →
    ∀ w : Weights d C r, boundedWeights B w →
    ∀ X : Set (RealInput d), admissibleDomain X →
    ∀ N : ℕ, C≤N → ∀ ρ τ ε : ℝ, 0<ρ → ρ<τ → 0<ε → ε<1 →
    ∀ label : RealInput d→Bool, Measurable label →
    (∀ x∈X,1/2+ρ≤labelReal (label x)*output Real.tanh w x) → τ≤ρ+1/2 →
    ∃ σ₀ : ℝ, 0<σ₀ ∧ ∀ σ : ℝ, 0<σ → σ<σ₀ →
    ∀ D : Measure (RealInput d), IsProbabilityMeasure D → D Xᶜ=0 →
    ∀ δ : ℝ, 0<δ → δ<1 → ∀ n : ℕ,
      (6/ε)*(regressionEnvelope A m d C B (inverseGap ρ τ) 0 0+Real.log (1/δ))≤(n:ℝ) →
      1-δ≤(CompressionSampling.iidSamples D n).real {s |
        let Q := Classification.posterior Real.tanh (BatchTwoNonGaussian.smallPrior ν d N r σ) label s
        Classification.risk Real.tanh D Q label≤ε/3 ∧
        Classification.confidenceFailure Real.tanh D Q label≤ε} := by
  intro r ν
  obtain ⟨k,hk⟩ := exists_nat_gt (ν.upperCurvature/ν.lowerCurvature)
  have hcurv : ν.upperCurvature ≤ ν.lowerCurvature*(k : ℝ) := by
    have h := (div_lt_iff₀ ν.lowerCurvature_pos).mp hk
    linarith
  obtain ⟨A,hA,m,hpoly⟩ := strongRegression_polynomial r k
  refine ⟨A,hA,m,?_⟩
  intro d C hd hC B hB w hw X hX N hCN ρ τ ε hρ hρτ hε _hε1 label hl hmargin hsep
  let K := strongRegressionEnergy k d C r B
  let R := regressionAccuracyWidth (inverseGap ρ τ)
  have hK : 1 ≤ K := strongRegressionEnergy_pos _ _ _ _ _
  have hR : 1 ≤ R := regressionAccuracyWidth_pos _
  have hgap := regressionAccuracyWidth_gap hρτ
  have hKgap := strongRegressionEnergy_gap ν (d := d) (C := C) (r := r) hcurv (by linarith : 0 ≤ B)
  obtain ⟨σ₀,hσ₀,hlearn⟩ := Classification.strong_explicit ν hd hC hCN hK hR w (by linarith : 0 ≤ B)
    hw X hX.1 hX.2.1 hX.2.2 label hl hmargin hρ hε (by linarith) hKgap
  refine ⟨σ₀,hσ₀,?_⟩
  intro σ hσ hσlt D hD hDX δ hδ _hδ1 n hsize
  apply hlearn σ hσ hσlt D hD hDX δ hδ n
  apply le_trans _ hsize
  exact mul_le_mul_of_nonneg_left
    (add_le_add (hpoly d C B (inverseGap ρ τ) hB (inverseGap_ge_one hρτ)) le_rfl) (by positivity)

#print axioms Classification.strong_polynomial

end NeuralGeneralization.BatchTwoContinuous
