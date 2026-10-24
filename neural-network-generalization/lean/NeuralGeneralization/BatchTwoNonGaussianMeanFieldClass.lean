import NeuralGeneralization.BatchTwoNonGaussianMeanFieldExtraction
import NeuralGeneralization.BatchTwoNonGaussianMixedTransport
import NeuralGeneralization.MeanFieldFunctionClass

/-! Counted finite representatives for actual good non-Gaussian mean-field
networks, with explicit polynomial width and coefficient bounds. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian.NonGaussianMeanField
open ConcreteModel MeanFieldBudgets MeanFieldCoefficientSequence GaussianAngularPrice

def compressedWidth (d r K : ℕ) : ℕ :=
  TowerCompression.compressedWidth d r K (maxTiltBudget r (2*K))

def compressedBound (ν : CoordinateLaw) (d r K : ℕ) : ℕ :=
  mixedCompressedBound ν d r K (maxTiltBudget r (2*K))

def functions (ν : CoordinateLaw) (d r K : ℕ) : Finset (BooleanFunction d) := by
  classical
  exact Finset.univ.filter fun f => ∃ w : Weights d (compressedWidth d r K) r,
    w ∈ marginEvent Real.tanh (1/2) f ∧ boundedWeights (compressedBound ν d r K) w

@[simp] theorem mem_functions (ν : CoordinateLaw) {d r K : ℕ} (f : BooleanFunction d) :
    f ∈ functions ν d r K ↔ ∃ w : Weights d (compressedWidth d r K) r,
      w ∈ marginEvent Real.tanh (1/2) f ∧ boundedWeights (compressedBound ν d r K) w := by
  classical
  simp [functions]

def capacity (ν : CoordinateLaw) (d r K : ℕ) : ℕ :=
  parameterCapacityExponent d (compressedWidth d r K) r (compressedBound ν d r K)

theorem functions_card_le_exp (ν : CoordinateLaw) (d r K : ℕ) :
    ((functions ν d r K).card : ℝ) ≤ Real.exp (capacity ν d r K : ℝ) :=
  representedClass_card_le_exp (functions ν d r K) (compressedWidth d r K) r
    (compressedBound ν d r K) Real.tanh tanh_admissible (fun f hf => (mem_functions ν f).mp hf)

theorem precision_growth (r : ℕ) :
    PolynomialGrowth2 (fun d K => TowerCompression.precision r K (maxTiltBudget r (2*K))) := by
  have hG := (maxTiltBudget_polynomialGrowth r).compositionRight
    ((PolynomialGrowth2.const 2).mul PolynomialGrowth2.right)
  unfold TowerCompression.precision
  exact ((((PolynomialGrowth2.const 32).mul PolynomialGrowth2.right).mul
    (PolynomialGrowth2.const (r+1))).mul
      (((PolynomialGrowth2.const 8).mul (((PolynomialGrowth2.const 1).add hG).pow 2)).pow r))

theorem compressedWidth_growth (r : ℕ) : PolynomialGrowth2 (fun d K => compressedWidth d r K) := by
  unfold compressedWidth TowerCompression.compressedWidth TowerSamplingBudget.width
  exact ((PolynomialGrowth2.const 32).mul ((precision_growth r).pow 2)).mul
    (PolynomialGrowth2.left.add (PolynomialGrowth2.const 1))

theorem compressedBound_growth (ν : CoordinateLaw) (r : ℕ) :
    PolynomialGrowth2 (fun d K => compressedBound ν d r K) := by
  have hG := (maxTiltBudget_polynomialGrowth r).compositionRight
    ((PolynomialGrowth2.const 2).mul PolynomialGrowth2.right)
  have hN := compressedWidth_growth r
  change PolynomialGrowth2 (fun d K => lawFactor ν * (32*(maxTiltBudget r (2*K)+
    lawFactor ν*compressedWidth d r K*(d+compressedWidth d r K+1)+1))+4*K)
  exact ((PolynomialGrowth2.const (lawFactor ν)).mul ((PolynomialGrowth2.const 32).mul
    ((hG.add (((PolynomialGrowth2.const (lawFactor ν)).mul hN).mul
      ((PolynomialGrowth2.left.add hN).add (PolynomialGrowth2.const 1)))).add (PolynomialGrowth2.const 1)))).add
        ((PolynomialGrowth2.const 4).mul PolynomialGrowth2.right)

theorem capacity_growth (ν : CoordinateLaw) (r : ℕ) :
    PolynomialGrowth2 (fun d K => capacity ν d r K) := by
  have hN := compressedWidth_growth r
  have hB := compressedBound_growth ν r
  have hdim : PolynomialGrowth2 (fun d K =>
      compressedWidth d r K*(d+1)+r*(compressedWidth d r K*compressedWidth d r K)+compressedWidth d r K) :=
    ((hN.mul (PolynomialGrowth2.left.add (PolynomialGrowth2.const 1))).add
      ((PolynomialGrowth2.const r).mul (hN.mul hN))).add hN
  have hmesh : PolynomialGrowth2 (fun d K =>
      (d+1)*(compressedWidth d r K*(compressedBound ν d r K+1)+1)^(r+1)) :=
    (PolynomialGrowth2.left.add (PolynomialGrowth2.const 1)).mul
      (((hN.mul (hB.add (PolynomialGrowth2.const 1))).add (PolynomialGrowth2.const 1)).pow (r+1))
  simpa only [capacity,parameterCapacityExponent_eq] using
    hdim.mul (((PolynomialGrowth2.const 2).mul (hB.mul hmesh)).add (PolynomialGrowth2.const 1))

theorem good_network_mem_functions (ν : CoordinateLaw) {d N r K : ℕ}
    (hd : 0 < d) (hN : 0 < N) (hK : 0 < K) (z : Weights d N r) (f : BooleanFunction d)
    (hmargin : weights z ∈ marginEvent Real.tanh (1/2) f)
    (henergy : (N : ℝ)*(∑ i, weights z (.inr (.inr i))^2) ≤ (K : ℝ))
    (hsize : ∀ s, 1 ≤ s → s ≤ r → 4*(layerBudget r (2*K) (s+1) : ℝ)^2 ≤ (N : ℝ))
    (herr : ∀ s, 1 ≤ s → s ≤ r → replacementConstant ν standardGaussian*
      lindebergPolynomial (layerBudget r (2*K) (s+1) : ℝ)/Real.sqrt N ≤ (K : ℝ))
    (hgood : GoodHidden ν d N r (fun s => (layerBudget r (2*K) (s+1) : ℝ)) (K : ℝ) z) :
    f ∈ functions ν d r K := by
  obtain ⟨Γ,hΓ,hbase,hcert⟩ := exists_covariance_certificates ν hN
    (fun s => (layerBudget r (2*K) (s+1) : ℝ)) (K : ℝ) (Nat.cast_nonneg K) r z
    (fun s hs => by exact_mod_cast layerBudget_pos r (show 0 < 2*K by omega) (s+1)) hsize herr hgood
  apply (mem_functions ν f).mpr
  apply exists_compressed_of_mixed_certificates ν hd hN hK (weights z) f (coefficient (weights z)) Γ
    hmargin henergy (gram_coefficient_final hN (weights z)) hΓ hbase hcert

end NeuralGeneralization.BatchTwoNonGaussian.NonGaussianMeanField
