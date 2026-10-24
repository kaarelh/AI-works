import NeuralGeneralization.BatchTwoNonGaussianTargetMass
import NeuralGeneralization.AllWidthCylinderCost

/-! Polynomial arithmetic envelopes for the explicitly constructed cylinder.
The constants depend only on the fixed depth and scalar law. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1600000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
open ConcreteModel

def RealPolynomialGrowth2 (f : ℕ → ℕ → ℝ) : Prop :=
  ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ, ∀ d C, |f d C| ≤ A*(1+(d : ℝ)+C)^m

namespace RealPolynomialGrowth2

theorem const (k : ℝ) : RealPolynomialGrowth2 (fun _ _ => k) := by
  refine ⟨|k|+1,by positivity,0,?_⟩
  intro d C
  simp

theorem left : RealPolynomialGrowth2 (fun d _ => (d : ℝ)) := by
  refine ⟨1,by norm_num,1,?_⟩
  intro d C
  rw [abs_of_nonneg (Nat.cast_nonneg d),pow_one,one_mul]
  linarith [Nat.cast_nonneg C (α := ℝ)]

theorem right : RealPolynomialGrowth2 (fun _ C => (C : ℝ)) := by
  refine ⟨1,by norm_num,1,?_⟩
  intro d C
  rw [abs_of_nonneg (Nat.cast_nonneg C),pow_one,one_mul]
  linarith [Nat.cast_nonneg d (α := ℝ)]

theorem add {f g : ℕ → ℕ → ℝ} (hf : RealPolynomialGrowth2 f) (hg : RealPolynomialGrowth2 g) :
    RealPolynomialGrowth2 (fun d C => f d C+g d C) := by
  obtain ⟨A,hA,m,hF⟩ := hf
  obtain ⟨B,hB,n,hG⟩ := hg
  refine ⟨A+B,add_pos hA hB,m+n,?_⟩
  intro d C
  have hx : (1 : ℝ) ≤ 1+d+C := by linarith [Nat.cast_nonneg d (α := ℝ),Nat.cast_nonneg C (α := ℝ)]
  have hm := pow_le_pow_right₀ hx (Nat.le_add_right m n)
  have hn := pow_le_pow_right₀ hx (Nat.le_add_left n m)
  calc
    _ ≤ |f d C|+|g d C| := abs_add_le _ _
    _ ≤ A*(1+(d : ℝ)+C)^m+B*(1+(d : ℝ)+C)^n := add_le_add (hF d C) (hG d C)
    _ ≤ A*(1+(d : ℝ)+C)^(m+n)+B*(1+(d : ℝ)+C)^(m+n) :=
      add_le_add (mul_le_mul_of_nonneg_left hm hA.le) (mul_le_mul_of_nonneg_left hn hB.le)
    _ = _ := by ring

theorem mul {f g : ℕ → ℕ → ℝ} (hf : RealPolynomialGrowth2 f) (hg : RealPolynomialGrowth2 g) :
    RealPolynomialGrowth2 (fun d C => f d C*g d C) := by
  obtain ⟨A,hA,m,hF⟩ := hf
  obtain ⟨B,hB,n,hG⟩ := hg
  refine ⟨A*B,mul_pos hA hB,m+n,?_⟩
  intro d C
  rw [abs_mul]
  calc
    _ ≤ (A*(1+(d : ℝ)+C)^m)*(B*(1+(d : ℝ)+C)^n) :=
      mul_le_mul (hF d C) (hG d C) (abs_nonneg _) (by positivity)
    _ = _ := by rw [pow_add]; ring

theorem pow {f : ℕ → ℕ → ℝ} (hf : RealPolynomialGrowth2 f) (n : ℕ) :
    RealPolynomialGrowth2 (fun d C => f d C^n) := by
  obtain ⟨A,hA,m,hF⟩ := hf
  refine ⟨A^n,pow_pos hA _,m*n,?_⟩
  intro d C
  rw [abs_pow]
  calc
    _ ≤ (A*(1+(d : ℝ)+C)^m)^n := pow_le_pow_left₀ (abs_nonneg _) (hF d C) _
    _ = _ := by rw [mul_pow,←pow_mul]

end RealPolynomialGrowth2

def targetRadiusInverse (ν : CoordinateLaw) (d C r : ℕ) : ℝ :=
  let K := cylinderTeacherCost d r C
  let b := cylinderNoiseBound ν d r C K
  2*(2*K*cylinderInputFactor d*(cylinderAmplification K C (2*(b+C+1)))^r+2)

def targetGroupWidthBound (ν : CoordinateLaw) (d C r : ℕ) : ℝ :=
  let R := targetRadiusInverse ν d C r
  let t := 4096*R^4
  (C : ℝ)*(4*t^2+(replacementConstant ν standardGaussian*lindebergPolynomial t)^2+2)

def targetMassPolynomial (ν : CoordinateLaw) (d C r : ℕ) : ℝ :=
  let R := targetRadiusInverse ν d C r
  let T := targetGroupWidthBound ν d C r
  ν.upperCurvature/2*cylinderTeacherCost d r C+
    ((d : ℝ)+2)*(coordinateBallConstant ν)⁻¹*R+
    (r : ℝ)*(1024*C*R^2+2)+
    ((d : ℝ)+2+(r : ℝ)*T)*(T+1)*(coordinateBallConstant ν)⁻¹*R

theorem targetRadiusInverse_positive (ν : CoordinateLaw) (d C r : ℕ) :
    0 < targetRadiusInverse ν d C r := by
  have hK := cylinderTeacherCost_nonneg d r C
  unfold targetRadiusInverse cylinderAmplification cylinderInputFactor
  positivity

theorem targetRadiusInverse_eq (ν : CoordinateLaw) (d C r : ℕ) :
    targetRadiusInverse ν d C r =
      (cylinderRadius d r (cylinderTeacherCost d r C) C
        (2*(cylinderNoiseBound ν d r C (cylinderTeacherCost d r C)+C+1)))⁻¹ := by
  simp only [targetRadiusInverse,cylinderRadius,inv_inv]

theorem targetGroupWidthBound_eq (ν : CoordinateLaw) (d C r : ℕ) :
    targetGroupWidthBound ν d C r =
      smallWidthThreshold ν C (cylinderRadius d r (cylinderTeacherCost d r C) C
        (2*(cylinderNoiseBound ν d r C (cylinderTeacherCost d r C)+C+1))) := by
  unfold targetGroupWidthBound smallWidthThreshold cloneGroupThreshold smallBallTilt
  rw [targetRadiusInverse_eq]
  simp only [inv_pow,div_eq_mul_inv]
  ring

theorem targetMassCost_le_polynomial (ν : CoordinateLaw) (d C r : ℕ) :
    targetMassCost ν d C r ≤ targetMassPolynomial ν d C r := by
  let ρ := cylinderRadius d r (cylinderTeacherCost d r C) C
    (2*(cylinderNoiseBound ν d r C (cylinderTeacherCost d r C)+C+1))
  have hρ : 0 < ρ := cylinderRadius_pos d r (cylinderTeacherCost_nonneg d r C) (Nat.cast_nonneg C)
  have ha := coordinateBallConstant_pos ν
  have hscalar : scalarCylinderCost ν ρ ≤ (coordinateBallConstant ν)⁻¹*ρ⁻¹ := by
    have hl := Real.log_le_sub_one_of_pos (one_div_pos.mpr (mul_pos ha hρ))
    unfold scalarCylinderCost
    rw [one_div,mul_inv_rev] at hl ⊢
    nlinarith
  have hmatrix : matrixCylinderCost C ρ ≤ 1024*(C : ℝ)*(ρ⁻¹)^2+2 := by
    have hl := Real.log_le_sub_one_of_pos (div_pos (by norm_num : (0 : ℝ) < 1024) (sq_pos_of_pos hρ))
    have h2 := Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ) < 2)
    have hm := mul_le_mul_of_nonneg_left hl (Nat.cast_nonneg C : (0 : ℝ) ≤ C)
    unfold matrixCylinderCost
    rw [div_eq_mul_inv,←inv_pow] at hm ⊢
    nlinarith [Nat.cast_nonneg C (α := ℝ)]
  have h1 := mul_le_mul_of_nonneg_left hscalar (show (0 : ℝ) ≤ d+2 by positivity)
  have h2 := mul_le_mul_of_nonneg_left hmatrix (Nat.cast_nonneg r : (0 : ℝ) ≤ r)
  unfold targetMassCost allWidthNoiseCost networkCylinderCost targetMassPolynomial smallWidthCylinderCost
  rw [targetRadiusInverse_eq,targetGroupWidthBound_eq]
  change ν.upperCurvature/2*cylinderTeacherCost d r C+
      (((d : ℝ)+2)*scalarCylinderCost ν ρ+(r : ℝ)*matrixCylinderCost C ρ+
        ((d : ℝ)+2+(r : ℝ)*smallWidthThreshold ν C ρ)*(smallWidthThreshold ν C ρ+1)/(coordinateBallConstant ν*ρ)) ≤ _
  change _ ≤ ν.upperCurvature/2*cylinderTeacherCost d r C+
    ((d : ℝ)+2)*(coordinateBallConstant ν)⁻¹*ρ⁻¹+
    (r : ℝ)*(1024*C*(ρ⁻¹)^2+2)+
    ((d : ℝ)+2+(r : ℝ)*smallWidthThreshold ν C ρ)*(smallWidthThreshold ν C ρ+1)*(coordinateBallConstant ν)⁻¹*ρ⁻¹
  ring_nf at h1 h2 ⊢
  linarith

theorem teacherCost_growth (r : ℕ) :
    RealPolynomialGrowth2 (fun d C => cylinderTeacherCost d r C) := by
  refine ⟨cylinderTeacherCoefficient r,cylinderTeacherCoefficient_pos r,4,?_⟩
  intro d C
  rw [abs_of_nonneg (cylinderTeacherCost_nonneg d r C)]
  exact cylinderTeacherCost_le_polynomial d r C

theorem inverseRadiusFactor_growth (r : ℕ) :
    RealPolynomialGrowth2 (fun d C => inverseRadiusFactor d r C (cylinderTeacherCost d r C)) := by
  have hK := teacherCost_growth r
  unfold inverseRadiusFactor cylinderInputFactor
  repeat' first
    | assumption
    | exact RealPolynomialGrowth2.left
    | exact RealPolynomialGrowth2.right
    | apply RealPolynomialGrowth2.const
    | apply RealPolynomialGrowth2.add
    | apply RealPolynomialGrowth2.mul
    | apply RealPolynomialGrowth2.pow

theorem cylinderNoiseBound_growth (ν : CoordinateLaw) (r : ℕ) :
    RealPolynomialGrowth2 (fun d C => cylinderNoiseBound ν d r C (cylinderTeacherCost d r C)) := by
  have hA := inverseRadiusFactor_growth r
  unfold cylinderNoiseBound cylinderTailCoefficient
  repeat' first
    | assumption
    | exact RealPolynomialGrowth2.left
    | exact RealPolynomialGrowth2.right
    | apply RealPolynomialGrowth2.const
    | apply RealPolynomialGrowth2.add
    | apply RealPolynomialGrowth2.mul
    | apply RealPolynomialGrowth2.pow

theorem targetRadiusInverse_growth (ν : CoordinateLaw) (r : ℕ) :
    RealPolynomialGrowth2 (fun d C => targetRadiusInverse ν d C r) := by
  have hK := teacherCost_growth r
  have hb := cylinderNoiseBound_growth ν r
  unfold targetRadiusInverse cylinderInputFactor cylinderAmplification
  repeat' first
    | assumption
    | exact RealPolynomialGrowth2.left
    | exact RealPolynomialGrowth2.right
    | apply RealPolynomialGrowth2.const
    | apply RealPolynomialGrowth2.add
    | apply RealPolynomialGrowth2.mul
    | apply RealPolynomialGrowth2.pow

theorem targetGroupWidthBound_growth (ν : CoordinateLaw) (r : ℕ) :
    RealPolynomialGrowth2 (fun d C => targetGroupWidthBound ν d C r) := by
  have hR := targetRadiusInverse_growth ν r
  unfold targetGroupWidthBound lindebergPolynomial
  repeat' first
    | assumption
    | exact RealPolynomialGrowth2.left
    | exact RealPolynomialGrowth2.right
    | apply RealPolynomialGrowth2.const
    | apply RealPolynomialGrowth2.add
    | apply RealPolynomialGrowth2.mul
    | apply RealPolynomialGrowth2.pow

theorem targetMassPolynomial_growth (ν : CoordinateLaw) (r : ℕ) :
    RealPolynomialGrowth2 (fun d C => targetMassPolynomial ν d C r) := by
  have hK := teacherCost_growth r
  have hR := targetRadiusInverse_growth ν r
  have hT := targetGroupWidthBound_growth ν r
  unfold targetMassPolynomial
  repeat' first
    | assumption
    | exact RealPolynomialGrowth2.left
    | exact RealPolynomialGrowth2.right
    | apply RealPolynomialGrowth2.const
    | apply RealPolynomialGrowth2.add
    | apply RealPolynomialGrowth2.mul
    | apply RealPolynomialGrowth2.pow

theorem targetMassCost_polynomial_envelope (ν : CoordinateLaw) (r : ℕ) :
    ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ, ∀ d C,
      targetMassCost ν d C r ≤ A*(1+(d : ℝ)+C)^m := by
  obtain ⟨A,hA,m,hbound⟩ := targetMassPolynomial_growth ν r
  exact ⟨A,hA,m,fun d C => (targetMassCost_le_polynomial ν d C r).trans
    ((le_abs_self _).trans (hbound d C))⟩

end NeuralGeneralization.BatchTwoNonGaussian
