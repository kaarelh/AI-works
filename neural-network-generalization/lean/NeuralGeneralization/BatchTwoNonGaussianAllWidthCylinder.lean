import NeuralGeneralization.BatchTwoNonGaussianCoordinateCube
import NeuralGeneralization.CylinderConstants

/-! A closed target-cylinder bound at every admissible learner width. Large
clone groups use the proved Lindeberg small ball; small groups use coordinate
boxes whose parameter count is controlled by the polynomial group threshold. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1600000
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
open ConcreteModel CompressionSampling

def cloneGroupThreshold (ν : CoordinateLaw) (ρ : ℝ) : ℝ :=
  4*(smallBallTilt ρ)^2+
    (replacementConstant ν standardGaussian*lindebergPolynomial (smallBallTilt ρ))^2+1

def smallWidthThreshold (ν : CoordinateLaw) (C : ℕ) (ρ : ℝ) : ℝ :=
  (C : ℝ)*(cloneGroupThreshold ν ρ+1)

def allWidthNoiseCost (ν : CoordinateLaw) (d C r : ℕ) (K : ℝ) : ℝ :=
  let b := cylinderNoiseBound ν d r C K
  let ρ := cylinderRadius d r K C (2*(b+C+1))
  networkCylinderCost ν d C r ρ+
    smallWidthCylinderCost ν d r (smallWidthThreshold ν C ρ) ρ

theorem cylinderRadius_le_half (d r : ℕ) {K G B : ℝ} (hK : 0 ≤ K) (hG : 0 ≤ G) :
    cylinderRadius d r K G B ≤ 1/2 := by
  have hA : 0 ≤ cylinderAmplification K G B := by unfold cylinderAmplification; positivity
  have hD : 0 ≤ cylinderInputFactor d := by unfold cylinderInputFactor; positivity
  have hden : 2 ≤ 2*(2*K*cylinderInputFactor d*(cylinderAmplification K G B)^r+2) := by
    have : 0 ≤ 2*K*cylinderInputFactor d*(cylinderAmplification K G B)^r := by positivity
    linarith
  simpa only [cylinderRadius,one_div] using
    one_div_le_one_div_of_le (by norm_num : (0 : ℝ) < 2) hden

theorem smallWidthThreshold_nonneg (ν : CoordinateLaw) (C : ℕ) (ρ : ℝ) :
    0 ≤ smallWidthThreshold ν C ρ := by
  unfold smallWidthThreshold cloneGroupThreshold
  positivity

theorem smallWidthCylinderCost_nonneg (ν : CoordinateLaw) (d r : ℕ) {T ρ : ℝ}
    (hT : 0 ≤ T) (hρ : 0 < ρ) : 0 ≤ smallWidthCylinderCost ν d r T ρ := by
  have ha := coordinateBallConstant_pos ν
  unfold smallWidthCylinderCost
  positivity

theorem allWidthNoiseCost_nonneg (ν : CoordinateLaw) (d C r : ℕ) {K : ℝ} (hK : 0 ≤ K) :
    0 ≤ allWidthNoiseCost ν d C r K := by
  apply add_nonneg
  · exact networkCylinderCost_nonneg ν d C r
      (cylinderRadius_pos d r hK (Nat.cast_nonneg C))
      (cylinderRadius_le_one d r hK (Nat.cast_nonneg C))
  · exact smallWidthCylinderCost_nonneg ν d r (smallWidthThreshold_nonneg ν C _)
      (cylinderRadius_pos d r hK (Nat.cast_nonneg C))

theorem noiseCylinder_allWidth_exp_lower (ν : CoordinateLaw) {C k p N : ℕ} (d r : ℕ)
    (hC : 0 < C) (hk : 0 < k) (hp : p < C) (hsplit : C*k+p=N)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) {K : ℝ} (hK : 0 ≤ K) :
    let b := cylinderNoiseBound ν d r C K
    let ρ := cylinderRadius d r K C (2*(b+C+1))
    Real.exp (-(N : ℝ)*allWidthNoiseCost ν d C r K) ≤
      (rawPrior ν d N r).real (noiseCylinder d e ρ b r) := by
  let b := cylinderNoiseBound ν d r C K
  let ρ := cylinderRadius d r K C (2*(b+C+1))
  have hN : 0 < N := by nlinarith [Nat.mul_pos hC hk]
  have hkN : k ≤ N := by nlinarith
  have hρ : 0 < ρ := cylinderRadius_pos d r hK (Nat.cast_nonneg C)
  have hρhalf : ρ ≤ 1/2 := cylinderRadius_le_half d r hK (Nat.cast_nonneg C)
  have hρ1 : ρ ≤ 1 := by linarith
  have hb : 1 ≤ b := by
    have hv := subGaussianVariance_pos ν
    have hD := cylinderTailCoefficient_pos d r C hK
    dsimp [b,cylinderNoiseBound]
    nlinarith [mul_nonneg hv.le hD.le]
  have hlarge : Real.exp (-(N : ℝ)*allWidthNoiseCost ν d C r K) ≤
      Real.exp (-(N : ℝ)*networkCylinderCost ν d C r ρ) := by
    apply Real.exp_le_exp.mpr
    have hs := smallWidthCylinderCost_nonneg ν d r (smallWidthThreshold_nonneg ν C ρ) hρ
    dsimp [allWidthNoiseCost]
    change -(N : ℝ)*(networkCylinderCost ν d C r ρ+_) ≤ _
    nlinarith [mul_nonneg (Nat.cast_nonneg N : (0 : ℝ) ≤ N) hs]
  have hsmall : Real.exp (-(N : ℝ)*allWidthNoiseCost ν d C r K) ≤
      Real.exp (-(N : ℝ)*smallWidthCylinderCost ν d r (smallWidthThreshold ν C ρ) ρ) := by
    apply Real.exp_le_exp.mpr
    have hn := networkCylinderCost_nonneg ν d C r hρ hρ1
    dsimp [allWidthNoiseCost]
    change -(N : ℝ)*(networkCylinderCost ν d C r ρ+_) ≤ _
    nlinarith [mul_nonneg (Nat.cast_nonneg N : (0 : ℝ) ≤ N) hn]
  by_cases hsize : 4*(smallBallTilt ρ)^2 ≤ (k : ℝ)
  · by_cases herr : (replacementConstant ν standardGaussian*lindebergPolynomial (smallBallTilt ρ))^2 ≤ (k : ℝ)
    · exact hlarge.trans (noiseCylinder_exp_lower ν d r hN hk e hρ hρhalf (by linarith) hsize herr
        (matrixCylinder_tail_budget ν C hN hρ (cylinderNoiseBound_budget ν d r C hK)))
    · have hkle : (k : ℝ) ≤ cloneGroupThreshold ν ρ := by
        unfold cloneGroupThreshold
        nlinarith [sq_nonneg (smallBallTilt ρ),lt_of_not_ge herr]
      have hNT : (N : ℝ) ≤ smallWidthThreshold ν C ρ := by
        have hsR : (C : ℝ)*k+p=N := by exact_mod_cast hsplit
        have hpR : (p : ℝ) ≤ C := by exact_mod_cast hp.le
        unfold smallWidthThreshold
        nlinarith [mul_le_mul_of_nonneg_left hkle (Nat.cast_nonneg C : (0 : ℝ) ≤ C)]
      exact hsmall.trans (noiseCylinder_smallWidth_exp_lower ν d r hN hk hkN e hρ hρ1 hb hNT)
  · have hkle : (k : ℝ) ≤ cloneGroupThreshold ν ρ := by
      unfold cloneGroupThreshold
      nlinarith [sq_nonneg (replacementConstant ν standardGaussian*lindebergPolynomial (smallBallTilt ρ)),lt_of_not_ge hsize]
    have hNT : (N : ℝ) ≤ smallWidthThreshold ν C ρ := by
      have hsR : (C : ℝ)*k+p=N := by exact_mod_cast hsplit
      have hpR : (p : ℝ) ≤ C := by exact_mod_cast hp.le
      unfold smallWidthThreshold
      nlinarith [mul_le_mul_of_nonneg_left hkle (Nat.cast_nonneg C : (0 : ℝ) ≤ C)]
    exact hsmall.trans (noiseCylinder_smallWidth_exp_lower ν d r hN hk hkN e hρ hρ1 hb hNT)

end NeuralGeneralization.BatchTwoNonGaussian
