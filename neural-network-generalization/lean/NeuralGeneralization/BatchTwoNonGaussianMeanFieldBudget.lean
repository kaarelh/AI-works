import NeuralGeneralization.BatchTwoNonGaussianMeanFieldClass
import NeuralGeneralization.BatchTwoNonGaussianMeanFieldHiddenTail
import NeuralGeneralization.BatchTwoNonGaussianMeanFieldLaw

/-! Polynomial width budgets discharge the actual relative-Lindeberg and
covariance-test conditions at the mean-field endpoint. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
namespace NeuralGeneralization.BatchTwoNonGaussian.NonGaussianMeanField
open ConcreteModel MeanFieldBudgets

def replacementFactor (ν : CoordinateLaw) : ℕ := ⌈|replacementConstant ν standardGaussian|⌉₊+1

def tiltPolynomial (G : ℕ) : ℕ := 24*G+36*G^2+8*G^3

def widthThreshold (ν : CoordinateLaw) (d r K : ℕ) : ℕ :=
  let G := maxTiltBudget r (2*K)
  8*d*(G^2+1)+4*G^2+(replacementFactor ν*tiltPolynomial G)^2+1

def tailScale (ν : CoordinateLaw) : ℕ := ⌈max 1 (subGaussianVariance ν)⌉₊

theorem tailScale_ge_one (ν : CoordinateLaw) : (1 : ℝ) ≤ tailScale ν :=
  (le_max_left _ _).trans (Nat.le_ceil _)

theorem tailScale_ge_variance (ν : CoordinateLaw) : subGaussianVariance ν ≤ tailScale ν :=
  (le_max_right _ _).trans (Nat.le_ceil _)

theorem widthThreshold_pos (ν : CoordinateLaw) (d r K : ℕ) : 0 < widthThreshold ν d r K := by
  dsimp only [widthThreshold]
  omega

theorem widthThreshold_growth (ν : CoordinateLaw) (r : ℕ) :
    PolynomialGrowth2 (fun d K => widthThreshold ν d r K) := by
  have hG := (maxTiltBudget_polynomialGrowth r).compositionRight
    ((PolynomialGrowth2.const 2).mul PolynomialGrowth2.right)
  have hP : PolynomialGrowth2 (fun d K => tiltPolynomial (maxTiltBudget r (2*K))) :=
    (((PolynomialGrowth2.const 24).mul hG).add ((PolynomialGrowth2.const 36).mul (hG.pow 2))).add
      ((PolynomialGrowth2.const 8).mul (hG.pow 3))
  unfold widthThreshold
  exact (((((PolynomialGrowth2.const 8).mul PolynomialGrowth2.left).mul
    ((hG.pow 2).add (PolynomialGrowth2.const 1))).add ((PolynomialGrowth2.const 4).mul (hG.pow 2))).add
      (((PolynomialGrowth2.const (replacementFactor ν)).mul hP).pow 2)).add (PolynomialGrowth2.const 1)

theorem widthThreshold_budget (ν : CoordinateLaw) {d r K N : ℕ}
    (hK : 0 < K) (hNT : widthThreshold ν d r K ≤ N) :
    (∀ s, 1 ≤ s → s ≤ r → 4*(layerBudget r (2*K) (s+1) : ℝ)^2 ≤ (N : ℝ)) ∧
    (∀ s, 1 ≤ s → s ≤ r → replacementConstant ν standardGaussian*
      lindebergPolynomial (layerBudget r (2*K) (s+1) : ℝ)/Real.sqrt N ≤ (K : ℝ)) := by
  let G := maxTiltBudget r (2*K)
  let P := replacementFactor ν*tiltPolynomial G
  have hN : 0 < N := (widthThreshold_pos ν d r K).trans_le hNT
  have hNR : (0 : ℝ) < N := Nat.cast_pos.mpr hN
  have hGs : 4*(G : ℝ)^2 ≤ N := by
    have : 4*G^2 ≤ N := by dsimp [G] at *; dsimp only [widthThreshold] at hNT; omega
    exact_mod_cast this
  have hPs : (P : ℝ)^2 ≤ N := by
    have : P^2 ≤ N := by dsimp [P,G] at *; dsimp only [widthThreshold] at hNT; omega
    exact_mod_cast this
  have hPsqrt : (P : ℝ) ≤ Real.sqrt N := by nlinarith [Real.sq_sqrt hNR.le,Real.sqrt_nonneg (N : ℝ),Nat.cast_nonneg P (α := ℝ)]
  have hrep : replacementConstant ν standardGaussian ≤ (replacementFactor ν : ℝ) := by
    have h := Nat.le_ceil |replacementConstant ν standardGaussian|
    have hle := (le_abs_self (replacementConstant ν standardGaussian)).trans h
    simp only [replacementFactor,Nat.cast_add,Nat.cast_one]
    linarith
  have hbudget (s : ℕ) : (layerBudget r (2*K) (s+1) : ℝ) ≤ G := by
    exact_mod_cast layerBudget_le_max r (2*K) (show 1 ≤ s+1 by omega)
  constructor
  · intro s _ _
    have hsq := pow_le_pow_left₀ (Nat.cast_nonneg (layerBudget r (2*K) (s+1))) (hbudget s) 2
    nlinarith
  · intro s _ _
    have hpoly : lindebergPolynomial (layerBudget r (2*K) (s+1) : ℝ) ≤ (tiltPolynomial G : ℝ) := by
      unfold lindebergPolynomial tiltPolynomial
      push_cast
      gcongr <;> exact_mod_cast hbudget s
    have hpoly0 : 0 ≤ lindebergPolynomial (layerBudget r (2*K) (s+1) : ℝ) := by
      unfold lindebergPolynomial
      positivity
    have hcoef : replacementConstant ν standardGaussian*
        lindebergPolynomial (layerBudget r (2*K) (s+1) : ℝ) ≤ (P : ℝ) := by
      exact (mul_le_mul hrep hpoly hpoly0 (Nat.cast_nonneg (replacementFactor ν))).trans_eq (by simp [P])
    have hfrac : replacementConstant ν standardGaussian*
        lindebergPolynomial (layerBudget r (2*K) (s+1) : ℝ)/Real.sqrt N ≤ 1 :=
      (div_le_one (Real.sqrt_pos.mpr hNR)).mpr (hcoef.trans hPsqrt)
    exact hfrac.trans (by exact_mod_cast hK)

theorem widthThreshold_entropy (ν : CoordinateLaw) {d r K N : ℕ}
    (hK : 4 ≤ K) (hNT : widthThreshold ν d r K ≤ N) :
    4*(d : ℝ)*(sparseCount r (2*K) : ℝ) ≤ (N : ℝ)*((K : ℝ)-1)/2 := by
  have hn : 8*d*sparseCount r (2*K)+1 ≤ N := by
    unfold sparseCount
    dsimp only [widthThreshold] at hNT
    omega
  have hnR : 8*(d : ℝ)*(sparseCount r (2*K) : ℝ)+1 ≤ N := by exact_mod_cast hn
  have hKR : (4 : ℝ) ≤ K := by exact_mod_cast hK
  nlinarith [mul_nonneg (Nat.cast_nonneg N : (0 : ℝ) ≤ N) (show 0 ≤ (K : ℝ)-4 by linarith)]

end NeuralGeneralization.BatchTwoNonGaussian.NonGaussianMeanField
