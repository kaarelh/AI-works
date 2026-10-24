import NeuralGeneralization.BatchTwoContinuousFiniteQueryCompression
import NeuralGeneralization.BatchTwoContinuousFiniteInputTail

/-! Mean-field accuracy budgets with distinct covariance tilt and probability
rate resources. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteQuery
open ConcreteModel BatchTwoNonGaussian MeanFieldBudgets

def inputMesh (ν : CoordinateLaw) (r K R : ℕ) : ℕ :=
  12*R*K*(FiniteInput.operatorBound ν K)^r

def queryBits (ν : CoordinateLaw) (d r K R : ℕ) : ℕ :=
  d+d*(2*inputMesh ν r K R+1)+1

def widthThreshold (ν : CoordinateLaw) (d r K R : ℕ) : ℕ :=
  NonGaussianMeanField.widthThreshold ν (queryBits ν d r K R) r (regressionResource K R)

theorem inputMesh_pos (ν : CoordinateLaw) (r : ℕ) {K R : ℕ} (hK : 0<K) (hR : 0<R) :
    0 < inputMesh ν r K R := by
  have hq : 0<NonGaussianMeanField.tailScale ν := by
    exact_mod_cast NonGaussianMeanField.tailScale_ge_one ν
  unfold inputMesh FiniteInput.operatorBound
  positivity

theorem queryBits_pos (ν : CoordinateLaw) (d r K R : ℕ) : 0<queryBits ν d r K R := by
  unfold queryBits
  omega

theorem widthThreshold_budget (ν : CoordinateLaw) {q r J N K : ℕ}
    (hK : 0<K) (hJ : 0<J) (hNT : NonGaussianMeanField.widthThreshold ν q r J≤N) :
    (∀ s,1≤s → s≤r → 4*(layerBudget r (2*J) (s+1) : ℝ)^2≤(N : ℝ)) ∧
    (∀ s,1≤s → s≤r → replacementConstant ν standardGaussian*
      lindebergPolynomial (layerBudget r (2*J) (s+1) : ℝ)/Real.sqrt N≤(K : ℝ)) := by
  have hbase := NonGaussianMeanField.widthThreshold_budget ν hJ hNT
  refine ⟨hbase.1,?_⟩
  let G := maxTiltBudget r (2*J)
  let P := NonGaussianMeanField.replacementFactor ν*NonGaussianMeanField.tiltPolynomial G
  have hN : 0<N := (NonGaussianMeanField.widthThreshold_pos ν q r J).trans_le hNT
  have hNR : (0 : ℝ)<N := by exact_mod_cast hN
  have hPs : (P : ℝ)^2≤N := by
    have hh : P^2≤N := by dsimp[P,G] at *; dsimp only [NonGaussianMeanField.widthThreshold] at hNT; omega
    exact_mod_cast hh
  have hPsqrt : (P : ℝ)≤Real.sqrt N := by
    nlinarith [Real.sq_sqrt hNR.le,Real.sqrt_nonneg (N : ℝ),Nat.cast_nonneg P (α := ℝ)]
  have hrep : replacementConstant ν standardGaussian≤(NonGaussianMeanField.replacementFactor ν : ℝ) := by
    have hh := (le_abs_self (replacementConstant ν standardGaussian)).trans (Nat.le_ceil _)
    simp only [NonGaussianMeanField.replacementFactor,Nat.cast_add,Nat.cast_one]
    linarith
  intro s hs hsr
  have hGs : (layerBudget r (2*J) (s+1) : ℝ)≤G := by
    exact_mod_cast layerBudget_le_max r (2*J) (show 1≤s+1 by omega)
  have hpoly : lindebergPolynomial (layerBudget r (2*J) (s+1) : ℝ)≤
      (NonGaussianMeanField.tiltPolynomial G : ℝ) := by
    unfold lindebergPolynomial NonGaussianMeanField.tiltPolynomial
    push_cast
    gcongr <;> exact_mod_cast hGs
  have hpoly0 : 0≤lindebergPolynomial (layerBudget r (2*J) (s+1) : ℝ) := by
    unfold lindebergPolynomial
    positivity
  have hcoef : replacementConstant ν standardGaussian*lindebergPolynomial (layerBudget r (2*J) (s+1) : ℝ)≤(P : ℝ) := by
    exact (mul_le_mul hrep hpoly hpoly0 (Nat.cast_nonneg _)).trans_eq (by simp[P])
  exact ((div_le_one (Real.sqrt_pos.mpr hNR)).mpr (hcoef.trans hPsqrt)).trans (by exact_mod_cast hK)

theorem widthThreshold_entropy (ν : CoordinateLaw) {q r J N K : ℕ}
    (hK : 4≤K) (hNT : NonGaussianMeanField.widthThreshold ν q r J≤N) :
    4*(q : ℝ)*(sparseCount r (2*J) : ℝ)≤(N : ℝ)*((K : ℝ)-1)/2 := by
  have hn : 8*q*sparseCount r (2*J)+1≤N := by
    unfold sparseCount
    dsimp only [NonGaussianMeanField.widthThreshold] at hNT
    omega
  have hnR : 8*(q : ℝ)*(sparseCount r (2*J) : ℝ)+1≤N := by exact_mod_cast hn
  have hKR : (4 : ℝ)≤K := by exact_mod_cast hK
  nlinarith [mul_nonneg (Nat.cast_nonneg N : (0 : ℝ)≤N) (show 0≤(K : ℝ)-4 by linarith)]

end NeuralGeneralization.BatchTwoContinuous.FiniteQuery
