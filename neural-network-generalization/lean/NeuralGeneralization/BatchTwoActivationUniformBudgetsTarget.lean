import NeuralGeneralization.BatchTwoActivationTargetMass
import NeuralGeneralization.BatchTwoActivationEndpointClass

/-! Integer polynomial upper bounds for the target cylinder cost. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel BatchTwoMerging

def activationNatTeacherEnergy (d C r : ℕ) : ℕ := 18*(d*(d+1)*C^2+(r+1)*C^4)
def activationNatTeacherState (b d C r : ℕ) : ℕ := (d+1)*(1+b*C^2)^(r+1)
def activationNatAmplification (b d C r : ℕ) : ℕ :=
  4*b^2*(activationNatTeacherEnergy d C r+(16*(r+1))^2+(C+1))+
    4*b^2*(C+1)*(activationNatTeacherState b d C r)^2+1
def activationNatOutputFactor (b d C r : ℕ) : ℕ :=
  3*(activationNatTeacherEnergy d C r+1)*((b^2+1)*((d+1)^2+1))*
    (activationNatAmplification b d C r)^r+3*(activationNatTeacherState b d C r)^2

def activationNatTarget (b d C r : ℕ) : ℕ :=
  activationNatTeacherEnergy d C r+(d+2+r*(C+1))*(1+8*(activationNatOutputFactor b d C r+1))+1

theorem activationTargetPolynomial_le_natTarget {b d C r : ℕ} {ℓ : ℝ}
    (hℓ0 : 0≤ℓ) (hℓ : ℓ≤b) :
    activationTargetPolynomial d C r ℓ≤(activationNatTarget b d C r:ℝ) := by
  have hroot : Real.sqrt (2*Real.pi)≤4 := by
    have hs := Real.sq_sqrt (by positivity : 0≤2*Real.pi)
    nlinarith [Real.sqrt_nonneg (2*Real.pi),Real.pi_lt_four]
  have hE : activationTeacherEnergy d C r=(activationNatTeacherEnergy d C r:ℝ) := by
    simp [activationTeacherEnergy,activationNatTeacherEnergy]
  have hT : teacherStateBound d C r ℓ≤(activationNatTeacherState b d C r:ℝ) := by
    unfold teacherStateBound teacherGrowth activationNatTeacherState
    push_cast
    gcongr
  have hAmp : generalCylinderAmplification ℓ (teacherStateBound d C r ℓ)
      (activationTeacherEnergy d C r) (C+1) (16*((r:ℝ)+1))≤
        (activationNatAmplification b d C r:ℝ) := by
    unfold generalCylinderAmplification activationNatAmplification
    push_cast
    rw [hE]
    have ht0 := (teacherStateBound_ge_one d C r hℓ0)
    gcongr
  have hF : activationOutputFactor d C r ℓ≤(activationNatOutputFactor b d C r:ℝ) := by
    unfold activationOutputFactor generalCylinderOutputFactor generalCylinderInputFactor
      cylinderInputFactor activationNatOutputFactor
    push_cast
    rw [hE] at *
    have ht0 := teacherStateBound_ge_one d C r hℓ0
    have ha0 : 0≤generalCylinderAmplification ℓ (teacherStateBound d C r ℓ)
        (activationTeacherEnergy d C r) (C+1) (16*((r:ℝ)+1)) := by
      unfold generalCylinderAmplification activationTeacherEnergy
      positivity
    gcongr <;> unfold generalCylinderAmplification <;> positivity
  unfold activationTargetPolynomial activationNatTarget
  push_cast
  rw [hE]
  have hf0 := activationOutputFactor_nonneg d C r ℓ
  gcongr
  linarith

theorem activationNatTarget_mono_complexity (b d r : ℕ) :
    Monotone (fun C => activationNatTarget b d C r) := by
  intro C S hCS
  unfold activationNatTarget activationNatOutputFactor activationNatAmplification
    activationNatTeacherState activationNatTeacherEnergy
  repeat' first | exact le_rfl | exact hCS | apply Nat.add_le_add | apply Nat.mul_le_mul | apply Nat.pow_le_pow_left


theorem activationNatTeacherEnergy_polynomial (r : ℕ) :
    PolynomialGrowth2 (fun d C => activationNatTeacherEnergy d C r) := by
  unfold activationNatTeacherEnergy
  exact (PolynomialGrowth2.const 18).mul
    (((PolynomialGrowth2.left.mul (PolynomialGrowth2.left.add (PolynomialGrowth2.const 1))).mul
      (PolynomialGrowth2.right.pow 2)).add
        ((PolynomialGrowth2.const (r+1)).mul (PolynomialGrowth2.right.pow 4)))

theorem activationNatTeacherState_polynomial (b r : ℕ) :
    PolynomialGrowth2 (fun d C => activationNatTeacherState b d C r) := by
  unfold activationNatTeacherState
  exact (PolynomialGrowth2.left.add (PolynomialGrowth2.const 1)).mul
    (((PolynomialGrowth2.const 1).add ((PolynomialGrowth2.const b).mul (PolynomialGrowth2.right.pow 2))).pow (r+1))

theorem activationNatAmplification_polynomial (b r : ℕ) :
    PolynomialGrowth2 (fun d C => activationNatAmplification b d C r) := by
  unfold activationNatAmplification
  let E := activationNatTeacherEnergy_polynomial r
  let T := activationNatTeacherState_polynomial b r
  let C := PolynomialGrowth2.right.add (PolynomialGrowth2.const 1)
  exact (((PolynomialGrowth2.const (4*b^2)).mul
    ((E.add (PolynomialGrowth2.const ((16*(r+1))^2))).add C)).add
      (((PolynomialGrowth2.const (4*b^2)).mul C).mul (T.pow 2))).add (PolynomialGrowth2.const 1)

theorem activationNatOutputFactor_polynomial (b r : ℕ) :
    PolynomialGrowth2 (fun d C => activationNatOutputFactor b d C r) := by
  unfold activationNatOutputFactor
  let E := activationNatTeacherEnergy_polynomial r
  let T := activationNatTeacherState_polynomial b r
  let Q := activationNatAmplification_polynomial b r
  exact ((((PolynomialGrowth2.const 3).mul (E.add (PolynomialGrowth2.const 1))).mul
    ((PolynomialGrowth2.const (b^2+1)).mul
      (((PolynomialGrowth2.left.add (PolynomialGrowth2.const 1)).pow 2).add (PolynomialGrowth2.const 1)))).mul
        (Q.pow r)).add ((PolynomialGrowth2.const 3).mul (T.pow 2))


theorem activationNatTarget_polynomial (b r : ℕ) :
    PolynomialGrowth2 (fun d C => activationNatTarget b d C r) := by
  unfold activationNatTarget
  exact ((activationNatTeacherEnergy_polynomial r).add
    (((PolynomialGrowth2.left.add (PolynomialGrowth2.const 2)).add
      ((PolynomialGrowth2.const r).mul (PolynomialGrowth2.right.add (PolynomialGrowth2.const 1)))).mul
        ((PolynomialGrowth2.const 1).add ((PolynomialGrowth2.const 8).mul
          ((activationNatOutputFactor_polynomial b r).add (PolynomialGrowth2.const 1)))))).add
            (PolynomialGrowth2.const 1)

end NeuralGeneralization.BatchTwoActivation
