import NeuralGeneralization.BatchTwoContinuousLearning
import NeuralGeneralization.Activation

/-! Actual strong-prior regression with an explicit width-independent cover
budget. The prior threshold precedes the input law, confidence and sample size. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel CompressionSampling

theorem strong_regression_explicit (ν : BatchTwoNonGaussian.CoordinateLaw)
    {d C N r K R : ℕ} (hd : 1 ≤ d) (hC : 1 ≤ C) (hCN : C ≤ N)
    (hK : 1 ≤ K) (hR : 1 ≤ R) (w : Weights d C r) {B ρ τ ε : ℝ}
    (hB : 0 ≤ B) (hw : boundedWeights B w) (X : Set (RealInput d))
    (hX : X.Nonempty) (hcompact : IsCompact X) (hball : ∀ x ∈ X, ∑ i, x i^2 ≤ 1)
    (hρ : 0 < ρ) (hε : 0 < ε)
    (hgap : ρ+2*(1/(3*(R : ℝ))) ≤ τ)
    (hKgap : ν.upperCurvature*teacherEnergyBound d C r B < ν.lowerCurvature*(K : ℝ)/2) :
    ∃ σ₀ : ℝ, 0 < σ₀ ∧ ∀ σ : ℝ, 0 < σ → σ < σ₀ →
    ∀ D : Measure (RealInput d), IsProbabilityMeasure D → D Xᶜ=0 →
    ∀ δ : ℝ, 0 < δ → ∀ n : ℕ,
      (6/ε)*((coverEntropy d r K R : ℝ)+Real.log (1/δ)) ≤ (n : ℝ) →
      1-δ ≤ (iidSamples D n).real {s |
        let Q := posterior Real.tanh (BatchTwoNonGaussian.smallPrior ν d N r σ) (output Real.tanh w) ρ s
        risk Real.tanh D Q (output Real.tanh w) τ ≤ ε/3 ∧
        confidenceFailure Real.tanh D Q (output Real.tanh w) τ ≤ ε} := by
  have hd' : 0 < d := by omega
  have hC' : 0 < C := by omega
  have hN : 0 < N := hC'.trans_le hCN
  have hpos := nonGaussian_tube_eventually_pos ν hd' hC' hCN tanh_continuous w hB hw X hcompact hρ
  have ht := nonGaussian_tube_tail_ratio ν hd' hC' hCN tanh_continuous w hB hw X hcompact hρ hKgap
  have hsmall := (tendsto_order.mp ht).2 (ε/6) (by linarith)
  have he : ∀ᶠ σ in 𝓝[>] (0 : ℝ),
      0 < (BatchTwoNonGaussian.smallPrior ν d N r σ).real (uniformTube Real.tanh (output Real.tanh w) X ρ) ∧
      (BatchTwoNonGaussian.smallPrior ν d N r σ).real {v | (K : ℝ) < weightedSquaredNorm v}/
        (BatchTwoNonGaussian.smallPrior ν d N r σ).real (uniformTube Real.tanh (output Real.tanh w) X ρ) ≤ ε/6 := by
    filter_upwards [hpos,hsmall] with σ hp hs
    exact ⟨hp,hs.le⟩
  obtain ⟨σ₀,hσ₀,hsub⟩ := mem_nhdsGT_iff_exists_Ioo_subset.mp he
  refine ⟨σ₀,hσ₀,?_⟩
  intro σ hσ hσlt D hD hDX δ hδ n hsize
  letI := hD
  have hb := hsub ⟨hσ,hσlt⟩
  have hbudget : (coverEntropy d r K R : ℝ)+Real.log (1/δ) ≤ (n : ℝ)*(ε/6) := by
    have hm := mul_le_mul_of_nonneg_right hsize (show 0 ≤ ε/6 by positivity)
    have heq : (6/ε)*((coverEntropy d r K R : ℝ)+Real.log (1/δ))*(ε/6)=
      (coverEntropy d r K R : ℝ)+Real.log (1/δ) := by field_simp
    rwa [heq] at hm
  have h := regression_learning_of_tail hd hN hK hR (BatchTwoNonGaussian.smallPrior ν d N r σ)
    Real.tanh tanh_admissible tanh_continuous (output Real.tanh w) (continuous_output_input tanh_continuous w)
    X hX hcompact hball (u := ε/6) (β := ε/6) (by positivity) hgap hb.1 hb.2 D hDX hδ n hbudget
  have heq : ε/6+ε/6=ε/3 := by ring
  have heq' : 3*(ε/3)=ε := by ring
  simpa only [heq,heq'] using h

end NeuralGeneralization.BatchTwoContinuous
