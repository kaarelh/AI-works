import NeuralGeneralization.BatchTwoOnlineBalancedPolynomial
import NeuralGeneralization.BatchTwoOnlineBalancedSampledIID

/-! The explicit polynomial budget controls actual sampled mistakes and the entire IID stream. -/
noncomputable section
set_option autoImplicit false
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal
attribute [local instance] Classical.propDecidable
namespace NeuralGeneralization.BatchTwoOnlineBalanced
open ConcreteModel BatchTwoMerging BatchTwoOnlineTanhMerging BatchTwoOnline BatchTwoOnlineRaw SquaredSampling
variable {d C N r : ℕ}

theorem balanced_polynomial_expectation_threshold (hd : 0<d) (hC : 0<C) {c0 : ℝ} (hc0 : 0<c0) :
    2+2*(balancedMergingOnlineEntropy d C r c0+1)*(1+(d:ℝ))≤
      2+2*(balancedMergingOnlineCapacity d C r c0+1)*(1+(d:ℝ)) := by
  have hh := mul_le_mul_of_nonneg_right (balanced_online_entropy_le (r:=r) hd hC hc0)
    (show 0≤2*(1+(d:ℝ)) by positivity)
  linarith

theorem balanced_polynomial_confidence_threshold (hd : 0<d) (hC : 0<C) {c0 : ℝ} (hc0 : 0<c0) (δ : ℝ) :
    (Real.exp 1-1)*(2+2*(balancedMergingOnlineEntropy d C r c0+
      Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1))+Real.log (2/δ)≤
    (Real.exp 1-1)*(2+2*(balancedMergingOnlineCapacity d C r c0+
      Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1))+Real.log (2/δ) := by
  have he : 0≤Real.exp 1-1 := by linarith [Real.add_one_le_exp (1:ℝ)]
  have hh := mul_le_mul_of_nonneg_right (balanced_online_entropy_le (r:=r) hd hC hc0)
    (show 0≤(Real.exp 1-1)*2*harmonicSum (cubeSize d-1) by positivity [harmonicSum_nonneg (cubeSize d-1)])
  linarith

theorem balanced_merging_iid_expected_polynomial (hd : 0<d) (hC : 0<C)
    (B : LayeredBooleanCircuit d C r) (hCN : C≤N) {c0 σ : ℝ} (hc0 : 0<c0)
    (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) (noiseMargin globalMargin : Bool) :
    (∫⁻s,streamTotal (balancedMergingSetRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes) s
      ∂iidQueryLaw (Fin (cubeSize d)))≤
      ENNReal.ofReal (2+2*(balancedMergingOnlineCapacity d C r c0+1)*(1+(d:ℝ))) :=
  (balanced_merging_iid_expected hd hC B hCN hc0 hσ hscale noiseMargin globalMargin).trans
    (ENNReal.ofReal_le_ofReal (balanced_polynomial_expectation_threshold hd hC hc0))

theorem balanced_merging_iid_sampled_expected_polynomial (hd : 0<d) (hC : 0<C)
    (B : LayeredBooleanCircuit d C r) (hCN : C≤N) {c0 σ : ℝ} (hc0 : 0<c0)
    (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) (noiseMargin globalMargin : Bool) :
    (∫⁻query,∫⁻draw,actualStreamTotal (balancedMergingTestError (N:=N) (r:=r) B.computes) query draw
      ∂setDrawLaw (balancedMergingSetPosterior noiseMargin globalMargin c0 σ B.computes) query
      ∂iidQueryLaw (Fin (cubeSize d)))≤
      ENNReal.ofReal (2+2*(balancedMergingOnlineCapacity d C r c0+1)*(1+(d:ℝ))) :=
  (balanced_merging_iid_sampled_expected hd hC B hCN hc0 hσ hscale noiseMargin globalMargin).trans
    (ENNReal.ofReal_le_ofReal (balanced_polynomial_expectation_threshold hd hC hc0))

theorem balanced_merging_online_sampled_tail_polynomial (hd : 0<d) (hC : 0<C)
    (B : LayeredBooleanCircuit d C r) (hCN : C≤N) {c0 σ δ : ℝ} (hc0 : 0<c0)
    (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) (noiseMargin globalMargin : Bool)
    (hδ : 0<δ) (hδ1 : δ<1) :
    finiteMean (fun π=>(Measure.pi (fun i=>
      balancedMergingPrefixPosterior (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes i π)).real
      {draw | (Real.exp 1-1)*(2+2*(balancedMergingOnlineCapacity d C r c0+
        Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1))+Real.log (2/δ)<
        actualErrorCount (fun w j=>labelReal (B.computes (cubeEnumeration d j))*
          networkOutput Real.tanh w (cubeEnumeration d j)≤1/4) π draw})≤δ := by
  apply le_trans (finiteMean_mono ?_) (balanced_merging_online_sampled_tail hd hC B hCN hc0 hσ hscale
    noiseMargin globalMargin hδ hδ1)
  intro π
  letI : ∀i,IsProbabilityMeasure
      (balancedMergingPrefixPosterior (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes i π) :=
    fun i=>balanced_mergingPrefix_probability hd hC B hCN hc0 hσ hscale noiseMargin globalMargin i π
  apply measureReal_mono _ (measure_ne_top _ _)
  intro draw hdraw
  exact lt_of_le_of_lt (balanced_polynomial_confidence_threshold hd hC hc0 δ) hdraw

theorem balanced_merging_iid_sampled_tail_polynomial (hd : 0<d) (hC : 0<C)
    (B : LayeredBooleanCircuit d C r) (hCN : C≤N) {c0 σ δ : ℝ} (hc0 : 0<c0)
    (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) (noiseMargin globalMargin : Bool)
    (hδ : 0<δ) (hδ1 : δ<1) :
    (∫⁻query,setDrawLaw (balancedMergingSetPosterior (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes) query
      {draw | ENNReal.ofReal ((Real.exp 1-1)*(2+2*(balancedMergingOnlineCapacity d C r c0+
        Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1))+Real.log (2/δ))<
        actualStreamTotal (balancedMergingTestError B.computes) query draw} ∂iidQueryLaw (Fin (cubeSize d)))≤
      ENNReal.ofReal δ := by
  apply le_trans (lintegral_mono ?_) (balanced_merging_iid_sampled_tail hd hC B hCN hc0 hσ hscale
    noiseMargin globalMargin hδ hδ1)
  intro query
  apply measure_mono
  intro draw hdraw
  exact lt_of_le_of_lt (ENNReal.ofReal_le_ofReal (balanced_polynomial_confidence_threshold hd hC hc0 δ)) hdraw

theorem all_width_all_scale_balanced_tanh_polynomial_learning (hd : 0<d) (hC : 0<C)
    (B : LayeredBooleanCircuit d C r) (D : Measure (Cube d)) [IsProbabilityMeasure D]
    {c0 ε δ : ℝ} (hc0 : 0<c0) (hε : 0<ε) (hε1 : ε≤1) (hδ : 0<δ)
    (n : ℕ) (hn : 0<n)
    (hbudget : 2*(balancedPolynomialEntropy d C r c0 ε+Real.log (1/δ))≤(n:ℝ)*(ε/2)) :
    ∃A : Set (Fin n→Cube d), MeasurableSet A ∧ 1-δ≤(CompressionSampling.iidSamples D n).real A ∧
      ∀sample∈A,∀N,C≤N→∀σ,0<σ→(N:ℝ)*σ^2≤1→∀noiseMargin globalMargin : Bool,
        0<(smallPrior d N r σ).real (balancedPosteriorEvent noiseMargin globalMargin c0 B.computes sample) ∧
        RobustConfidence.gibbsMarginRisk D
          (balancedPosterior (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes sample)
          (fun x=>labelReal (B.computes x)) (fun w x=>networkOutput Real.tanh w x) (1/4)≤ε := by
  apply all_width_all_scale_balanced_tanh_learning hd hC B D hc0 hε hε1 hδ n hn
  have hh := balanced_grid_entropy_polynomial (d:=d) (r:=r) hC hc0 hε hε1
  linarith

end NeuralGeneralization.BatchTwoOnlineBalanced
