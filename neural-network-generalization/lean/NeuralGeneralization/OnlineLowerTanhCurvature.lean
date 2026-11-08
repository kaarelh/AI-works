import NeuralGeneralization.OnlineLowerTanhHamming
import Mathlib.Analysis.SpecificLimits.Normed
import Mathlib.Analysis.Calculus.Deriv.Pow

/-! Concrete scalar series used in the optimized tanh cost expansion. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

def logisticPower (j : ℕ) (y : ℝ) : ℝ := y^(2*j+1)
def logisticValue (j : ℕ) (y : ℝ) : ℝ := logisticPower j y/(1+logisticPower j y)
def logisticSlopeY (j : ℕ) (y : ℝ) : ℝ :=
  -2*(2*j+1)*logisticPower j y/(1+logisticPower j y)^2
def logisticCurvatureY (j : ℕ) (y : ℝ) : ℝ :=
  (2*(2*j+1))^2*logisticPower j y*(1-logisticPower j y)/(1+logisticPower j y)^3

def logisticTail (j : ℕ) (a : ℝ) : ℝ := logisticValue j (Real.exp (-2*a))
def logisticFirst (j : ℕ) (a : ℝ) : ℝ := logisticSlopeY j (Real.exp (-2*a))
def logisticSecond (j : ℕ) (a : ℝ) : ℝ := logisticCurvatureY j (Real.exp (-2*a))

def scalarF0Y (y : ℝ) : ℝ := 1-4*∑' j : ℕ, (-1 : ℝ)^j*logisticValue j y
def scalarF1Y (y : ℝ) : ℝ :=
  4*∑' j : ℕ, (-1 : ℝ)^j*(1+2*(j : ℝ)*(j+1))*logisticValue j y
def scalarF2Y (y : ℝ) : ℝ :=
  -4*∑' j : ℕ, (-1 : ℝ)^j*(1+4*(j : ℝ)*(j+1)+2*((j : ℝ)*(j+1))^2)*logisticValue j y
def scalarF0FirstY (y : ℝ) : ℝ := -4*∑' j : ℕ, (-1 : ℝ)^j*logisticSlopeY j y
def scalarF0SecondY (y : ℝ) : ℝ := -4*∑' j : ℕ, (-1 : ℝ)^j*logisticCurvatureY j y
def scalarF1FirstY (y : ℝ) : ℝ :=
  4*∑' j : ℕ, (-1 : ℝ)^j*(1+2*(j : ℝ)*(j+1))*logisticSlopeY j y

def scalarF0 (a : ℝ) := scalarF0Y (Real.exp (-2*a))
def scalarF1 (a : ℝ) := scalarF1Y (Real.exp (-2*a))
def scalarF2 (a : ℝ) := scalarF2Y (Real.exp (-2*a))
def scalarF0First (a : ℝ) := scalarF0FirstY (Real.exp (-2*a))
def scalarF0Second (a : ℝ) := scalarF0SecondY (Real.exp (-2*a))
def scalarF1First (a : ℝ) := scalarF1FirstY (Real.exp (-2*a))

def scalarStationary (a : ℝ) : ℝ := a*scalarF0First a-scalarF0 a

def normalizedOptimizedCurvature (a : ℝ) : ℝ :=
  a*(scalarF1 a+scalarF0 a/4)^2/(scalarF0 a)^3 -
  a*(scalarF2 a+scalarF1 a/4+scalarF0 a/32)/(scalarF0 a)^2 +
  (scalarF1 a-a*scalarF1First a)^2/(2*a*scalarF0Second a*(scalarF0 a)^2)

theorem logisticPower_exp (j : ℕ) (a : ℝ) :
    logisticPower j (Real.exp (-2*a)) = Real.exp (-2*a*(2*j+1)) := by
  simp only [logisticPower, ← Real.exp_nat_mul]
  congr 1
  push_cast
  ring

theorem logisticTail_exp (j : ℕ) (a : ℝ) :
    logisticTail j a = Real.exp (-2*a*(2*j+1))/(1+Real.exp (-2*a*(2*j+1))) := by
  simp only [logisticTail, logisticValue, logisticPower_exp]

theorem logisticTail_eq_inverse (j : ℕ) (a : ℝ) :
    logisticTail j a = 1/(1+Real.exp (2*a*(2*j+1))) := by
  rw [logisticTail_exp]
  have he : Real.exp (-2*a*(2*j+1)) = (Real.exp (2*a*(2*j+1)))⁻¹ := by
    rw [show -2*a*(2*j+1)=-(2*a*(2*j+1)) by ring, Real.exp_neg]
  rw [he]
  have hp := Real.exp_pos (2*a*(2*j+1))
  field_simp
  <;> ring

theorem logisticPower_nonneg (j : ℕ) {y : ℝ} (hy : 0 ≤ y) : 0 ≤ logisticPower j y :=
  pow_nonneg hy _

theorem logisticPower_le_one (j : ℕ) {y : ℝ} (hy : 0 ≤ y) (hy1 : y ≤ 1) :
    logisticPower j y ≤ 1 := by
  exact pow_le_one₀ hy hy1

theorem logisticValue_nonneg (j : ℕ) {y : ℝ} (hy : 0 ≤ y) : 0 ≤ logisticValue j y := by
  unfold logisticValue
  exact div_nonneg (logisticPower_nonneg j hy) (by linarith [logisticPower_nonneg j hy])

theorem logisticValue_le_power (j : ℕ) {y : ℝ} (hy : 0 ≤ y) :
    logisticValue j y ≤ logisticPower j y := by
  have hp := logisticPower_nonneg j hy
  unfold logisticValue
  apply (div_le_iff₀ (by linarith : 0 < 1+logisticPower j y)).mpr
  nlinarith

theorem logisticSlopeY_abs_le (j : ℕ) {y : ℝ} (hy : 0 ≤ y) :
    |logisticSlopeY j y| ≤ 2*(2*j+1)*logisticPower j y := by
  have hp := logisticPower_nonneg j hy
  have hb : 0 ≤ 2*(2*(j : ℝ)+1) := by positivity
  have hd : 1 ≤ (1+logisticPower j y)^2 := by nlinarith
  unfold logisticSlopeY
  rw [abs_div, abs_mul, abs_mul, abs_neg, abs_of_nonneg (by norm_num : (0 : ℝ) ≤ 2),
    abs_of_nonneg (by positivity : (0 : ℝ) ≤ 2*(j : ℝ)+1), abs_of_nonneg hp,
    abs_of_nonneg (sq_nonneg _)]
  apply (div_le_iff₀ (by positivity : 0 < (1+logisticPower j y)^2)).mpr
  nlinarith [mul_nonneg (mul_nonneg hb hp) (sub_nonneg.mpr hd)]

theorem logisticCurvatureY_abs_le (j : ℕ) {y : ℝ} (hy : 0 ≤ y) (hy1 : y ≤ 1) :
    |logisticCurvatureY j y| ≤ (2*(2*j+1))^2*logisticPower j y := by
  have hp := logisticPower_nonneg j hy
  have hp1 := logisticPower_le_one j hy hy1
  have hb : 0 ≤ (2*(2*(j : ℝ)+1))^2 := sq_nonneg _
  have hd : 1 ≤ (1+logisticPower j y)^3 := one_le_pow₀ (by linarith)
  unfold logisticCurvatureY
  rw [abs_div, abs_mul, abs_mul, abs_of_nonneg hb, abs_of_nonneg hp,
    abs_of_nonneg (sub_nonneg.mpr hp1), abs_of_nonneg (by positivity : 0 ≤ (1+logisticPower j y)^3)]
  apply (div_le_iff₀ (by positivity : 0 < (1+logisticPower j y)^3)).mpr
  nlinarith [mul_nonneg (mul_nonneg hb hp) (sub_nonneg.mpr hd),
    mul_nonneg (mul_nonneg hb hp) hp]


theorem hasDerivAt_logisticTail (j : ℕ) (a : ℝ) :
    HasDerivAt (logisticTail j) (logisticFirst j a) a := by
  let b : ℝ := 2*(2*j+1)
  have hp (a : ℝ) : HasDerivAt (fun x => Real.exp (-b*x)) (-b*Real.exp (-b*a)) a := by
    convert! ((hasDerivAt_id a).const_mul (-b)).exp using 1 <;> simp only [id_eq,mul_one] <;> ring
  have hd : (1+Real.exp (-b*a)) ≠ 0 := by positivity
  have hh := (hp a).div ((hp a).const_add 1) hd
  convert hh using 1 <;> try rfl
  · funext z
    rw [logisticTail_exp]
    simp only [b]
    congr 2 <;> ring
  · simp only [logisticFirst,logisticSlopeY,logisticPower_exp,b,Pi.div_apply,Pi.pow_apply]
    have he : -2*a*(2*(j : ℝ)+1) = -(2*(2*j+1))*a := by ring
    rw [he]
    field_simp
    ring

theorem hasDerivAt_logisticFirst (j : ℕ) (a : ℝ) :
    HasDerivAt (logisticFirst j) (logisticSecond j a) a := by
  let b : ℝ := 2*(2*j+1)
  have hp : HasDerivAt (fun x => Real.exp (-b*x)) (-b*Real.exp (-b*a)) a := by
    convert! ((hasDerivAt_id a).const_mul (-b)).exp using 1 <;> simp only [id_eq,mul_one] <;> ring
  have hd : (1+Real.exp (-b*a))^2 ≠ 0 := by positivity
  have hh := (hp.const_mul (-b)).div (((hp.const_add 1).pow 2)) hd
  convert hh using 1 <;> try rfl
  · funext z
    simp only [logisticFirst,logisticSlopeY,logisticPower_exp,b,Pi.div_apply,Pi.pow_apply]
    have he : -2*z*(2*(j : ℝ)+1) = -(2*(2*j+1))*z := by ring
    rw [he]
    ring
  · simp only [logisticSecond,logisticCurvatureY,logisticPower_exp,b,Pi.div_apply,Pi.pow_apply]
    have he : -2*a*(2*(j : ℝ)+1) = -(2*(2*j+1))*a := by ring
    rw [he]
    field_simp
    ring

end NeuralGeneralization.OnlineLowerTanh
