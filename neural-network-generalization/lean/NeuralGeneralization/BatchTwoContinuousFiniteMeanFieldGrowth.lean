import NeuralGeneralization.BatchTwoContinuousFiniteMeanFieldCover

/-! Explicit arithmetic of the real-query mean-field cover preserves polynomial
sample resources at every fixed depth. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoContinuous.FiniteMeanField
open ConcreteModel BatchTwoNonGaussian MeanFieldBudgets

theorem polynomial_compose_both {f g h : ℕ → ℕ → ℕ}
    (hf : PolynomialGrowth2 f) (hg : PolynomialGrowth2 g) (hh : PolynomialGrowth2 h) :
    PolynomialGrowth2 (fun d S => f (g d S) (h d S)) := by
  obtain ⟨A,m,hA,hbound⟩ := hf
  apply ((PolynomialGrowth2.const A).mul
    (((PolynomialGrowth2.const 1).add hg).add hh |>.pow m)).mono
  intro d S
  exact hbound _ _

theorem queryBits_growth (ν : CoordinateLaw) (r : ℕ) {K R : ℕ → ℕ → ℕ}
    (hK : PolynomialGrowth2 K) (hR : PolynomialGrowth2 R) :
    PolynomialGrowth2 (fun d S => FiniteQuery.queryBits ν d r (K d S) (R d S)) := by
  have hb := (PolynomialGrowth2.const (32*NonGaussianMeanField.tailScale ν)).mul
    (hK.add (PolynomialGrowth2.const 1))
  have ht : PolynomialGrowth2 (fun d S => FiniteQuery.inputMesh ν r (K d S) (R d S)) := by
    unfold FiniteQuery.inputMesh FiniteInput.operatorBound
    exact (((PolynomialGrowth2.const 12).mul hR).mul hK).mul (hb.pow r)
  unfold FiniteQuery.queryBits
  exact ((PolynomialGrowth2.left.add (PolynomialGrowth2.left.mul
    (((PolynomialGrowth2.const 2).mul ht).add (PolynomialGrowth2.const 1)))).add (PolynomialGrowth2.const 1))

theorem regressionResource_growth {K R : ℕ → ℕ → ℕ}
    (hK : PolynomialGrowth2 K) (hR : PolynomialGrowth2 R) :
    PolynomialGrowth2 (fun d S => FiniteQuery.regressionResource (K d S) (R d S)) := by
  unfold FiniteQuery.regressionResource
  exact ((PolynomialGrowth2.const 12).mul hK).mul (hR.pow 2)

theorem widthThreshold_growth (ν : CoordinateLaw) (r : ℕ) {K R : ℕ → ℕ → ℕ}
    (hK : PolynomialGrowth2 K) (hR : PolynomialGrowth2 R) :
    PolynomialGrowth2 (fun d S => FiniteQuery.widthThreshold ν d r (K d S) (R d S)) := by
  unfold FiniteQuery.widthThreshold
  exact polynomial_compose_both (NonGaussianMeanField.widthThreshold_growth ν r)
    (queryBits_growth ν r hK hR) (regressionResource_growth hK hR)

theorem compressedWidth_growth (ν : CoordinateLaw) (r : ℕ) {K R : ℕ → ℕ → ℕ}
    (hK : PolynomialGrowth2 K) (hR : PolynomialGrowth2 R) :
    PolynomialGrowth2 (fun d S => FiniteQuery.compressedWidth d
      (FiniteQuery.queryBits ν d r (K d S) (R d S)) r (K d S) (R d S)) := by
  have hh := polynomial_compose_both (NonGaussianMeanField.compressedWidth_growth r)
    (PolynomialGrowth2.left.add (queryBits_growth ν r hK hR)) (regressionResource_growth hK hR)
  simpa only [FiniteQuery.compressedWidth, NonGaussianMeanField.compressedWidth] using hh

theorem compressedBound_growth (ν : CoordinateLaw) (r : ℕ) {K R : ℕ → ℕ → ℕ}
    (hK : PolynomialGrowth2 K) (hR : PolynomialGrowth2 R) :
    PolynomialGrowth2 (fun d S => FiniteQuery.compressedBound ν d
      (FiniteQuery.queryBits ν d r (K d S) (R d S)) r (K d S) (R d S)) := by
  have hh := polynomial_compose_both (NonGaussianMeanField.compressedBound_growth ν r)
    (PolynomialGrowth2.left.add (queryBits_growth ν r hK hR)) (regressionResource_growth hK hR)
  simpa only [FiniteQuery.compressedBound, NonGaussianMeanField.compressedBound] using hh

theorem capacity_growth (ν : CoordinateLaw) (r : ℕ) {K R : ℕ → ℕ → ℕ}
    (hK : PolynomialGrowth2 K) (hR : PolynomialGrowth2 R) :
    PolynomialGrowth2 (fun d S => capacity ν d r (K d S) (R d S)) := by
  have hM := compressedWidth_growth ν r hK hR
  have hB := compressedBound_growth ν r hK hR
  have hP : PolynomialGrowth2 (fun d S => robustParameterCount d
      (FiniteQuery.compressedWidth d (FiniteQuery.queryBits ν d r (K d S) (R d S)) r (K d S) (R d S)) r) := by
    unfold robustParameterCount
    exact ((hM.mul (PolynomialGrowth2.left.add (PolynomialGrowth2.const 1))).add
      (((PolynomialGrowth2.const r).mul hM).mul hM)).add hM
  have hm : PolynomialGrowth2 (fun d S => realOutputMesh d
      (FiniteQuery.compressedWidth d (FiniteQuery.queryBits ν d r (K d S) (R d S)) r (K d S) (R d S)) r
      (FiniteQuery.compressedBound ν d (FiniteQuery.queryBits ν d r (K d S) (R d S)) r (K d S) (R d S)) (6*R d S)) := by
    unfold realOutputMesh parameterMesh
    exact (((hB.mul ((PolynomialGrowth2.const 6).mul hR)).mul
      (PolynomialGrowth2.left.add (PolynomialGrowth2.const 1))).mul
      ((PolynomialGrowth2.left.add (PolynomialGrowth2.const 1)).mul
        ((hM.mul (((PolynomialGrowth2.left.add (PolynomialGrowth2.const 1)).mul hB).add (PolynomialGrowth2.const 1))).add
          (PolynomialGrowth2.const 1) |>.pow (r+1))))
  exact hP.mul (((PolynomialGrowth2.const 2).mul hm).add (PolynomialGrowth2.const 1))

end NeuralGeneralization.BatchTwoContinuous.FiniteMeanField
