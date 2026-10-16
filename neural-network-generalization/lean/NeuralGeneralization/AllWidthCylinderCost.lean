import NeuralGeneralization.CylinderConstants
import NeuralGeneralization.PowerPriorScaling
import Mathlib.Tactic.GCongr

/-!
# Polynomial cost of the Gaussian cylinder at every admissible width

The constants below depend only on the fixed depth.  The polynomial exponent
is explicit, and the bound includes the mean-field endpoint `γ = 1`.
-/

noncomputable section
namespace NeuralGeneralization.ConcreteModel

def cylinderTeacherCoefficient (r : ℕ) : ℝ := 18 * ((r : ℝ) + 2)

def cylinderAmplificationCoefficient (r : ℕ) : ℝ :=
  3 * cylinderTeacherCoefficient r + 3 * (cylinderFreeBound r) ^ 2 + 4

def cylinderInverseRadiusCoefficient (r : ℕ) : ℝ :=
  8 * cylinderTeacherCoefficient r * (cylinderAmplificationCoefficient r) ^ r + 4

def cylinderCoordinateCoefficient (r : ℕ) : ℝ :=
  1 + (Real.sqrt (2 * Real.pi) / 2) * cylinderInverseRadiusCoefficient r

def cylinderPolynomialCoefficient (r : ℕ) : ℝ :=
  cylinderTeacherCoefficient r + ((r : ℝ) + 3) * cylinderCoordinateCoefficient r + 1

def cylinderPolynomialDegree (r : ℕ) : ℕ := 4 * r + 7

theorem cylinderTeacherCoefficient_pos (r : ℕ) : 0 < cylinderTeacherCoefficient r := by
  unfold cylinderTeacherCoefficient
  positivity

theorem cylinderAmplificationCoefficient_pos (r : ℕ) :
    0 < cylinderAmplificationCoefficient r := by
  unfold cylinderAmplificationCoefficient
  have := cylinderTeacherCoefficient_pos r
  positivity

theorem cylinderInverseRadiusCoefficient_pos (r : ℕ) :
    0 < cylinderInverseRadiusCoefficient r := by
  unfold cylinderInverseRadiusCoefficient
  have := cylinderTeacherCoefficient_pos r
  have := cylinderAmplificationCoefficient_pos r
  positivity

theorem cylinderCoordinateCoefficient_pos (r : ℕ) :
    0 < cylinderCoordinateCoefficient r := by
  unfold cylinderCoordinateCoefficient
  have := cylinderInverseRadiusCoefficient_pos r
  positivity

theorem cylinderPolynomialCoefficient_pos (r : ℕ) :
    0 < cylinderPolynomialCoefficient r := by
  unfold cylinderPolynomialCoefficient
  have := cylinderTeacherCoefficient_pos r
  have := cylinderCoordinateCoefficient_pos r
  positivity

theorem cylinderTeacherCost_le_polynomial (d r C : ℕ) :
    cylinderTeacherCost d r C ≤
      cylinderTeacherCoefficient r * (1 + (d : ℝ) + C) ^ 4 := by
  let x : ℝ := 1 + d + C
  have hd : (d : ℝ) ≤ x := by dsimp [x]; linarith [Nat.cast_nonneg C (α := ℝ)]
  have hd1 : (d : ℝ) + 1 ≤ x := by dsimp [x]; linarith [Nat.cast_nonneg C (α := ℝ)]
  have hC : (C : ℝ) ≤ x := by dsimp [x]; linarith [Nat.cast_nonneg d (α := ℝ)]
  have hterm : (d : ℝ) * (d + 1) * C ^ 2 ≤ x ^ 4 := by
    calc
      _ ≤ x * x * x ^ 2 := by gcongr
      _ = _ := by ring
  have hC4 : (C : ℝ) ^ 4 ≤ x ^ 4 := by gcongr
  change _ ≤ cylinderTeacherCoefficient r * x ^ 4
  unfold cylinderTeacherCost cylinderTeacherCoefficient
  nlinarith [mul_le_mul_of_nonneg_left hC4 (show 0 ≤ (r : ℝ) + 1 by positivity)]

theorem cylinderInputFactor_le_polynomial (d C : ℕ) :
    cylinderInputFactor d ≤ 2 * (1 + (d : ℝ) + C) ^ 2 := by
  have hd : (d : ℝ) + 1 ≤ 1 + d + C := by linarith [Nat.cast_nonneg C (α := ℝ)]
  have hx : (1 : ℝ) ≤ 1 + d + C := by
    linarith [Nat.cast_nonneg d (α := ℝ), Nat.cast_nonneg C (α := ℝ)]
  have hh : ((d : ℝ) + 1) ^ 2 ≤ (1 + d + C) ^ 2 := by gcongr
  have hp := one_le_pow₀ hx (n := 2)
  unfold cylinderInputFactor
  linarith

theorem cylinderAmplification_le_polynomial (d r C : ℕ) :
    cylinderAmplification (cylinderTeacherCost d r C) ((C : ℝ) + 1)
      (cylinderFreeBound r) ≤
      cylinderAmplificationCoefficient r * (1 + (d : ℝ) + C) ^ 4 := by
  let x : ℝ := 1 + d + C
  have hx : 1 ≤ x := by
    dsimp [x]
    linarith [Nat.cast_nonneg d (α := ℝ), Nat.cast_nonneg C (α := ℝ)]
  have hC : (C : ℝ) + 1 ≤ x := by dsimp [x]; linarith [Nat.cast_nonneg d (α := ℝ)]
  have hx4 : 1 ≤ x ^ 4 := one_le_pow₀ hx
  have hx14 : x ≤ x ^ 4 := by simpa using (pow_le_pow_right₀ hx (by omega : 1 ≤ 4))
  have hK := cylinderTeacherCost_le_polynomial d r C
  change cylinderTeacherCost d r C ≤ cylinderTeacherCoefficient r * x ^ 4 at hK
  have hB := mul_le_mul_of_nonneg_left hx4 (sq_nonneg (cylinderFreeBound r))
  unfold cylinderAmplification cylinderAmplificationCoefficient
  change 3 * (cylinderTeacherCost d r C + cylinderFreeBound r ^ 2) + 3 * (C + 1) + 1 ≤
    (3 * cylinderTeacherCoefficient r + 3 * cylinderFreeBound r ^ 2 + 4) * x ^ 4
  nlinarith [hC.trans hx14]

theorem cylinderUniversalRadius_inv_le_polynomial (d r C : ℕ) :
    (cylinderUniversalRadius d r C)⁻¹ ≤
      cylinderInverseRadiusCoefficient r * (1 + (d : ℝ) + C) ^ (4 * r + 6) := by
  let x : ℝ := 1 + d + C
  have hx : 1 ≤ x := by
    dsimp [x]
    linarith [Nat.cast_nonneg d (α := ℝ), Nat.cast_nonneg C (α := ℝ)]
  have hx0 : 0 ≤ x := zero_le_one.trans hx
  have hK := cylinderTeacherCost_le_polynomial d r C
  have hD := cylinderInputFactor_le_polynomial d C
  have hA := cylinderAmplification_le_polynomial d r C
  have hK0 := cylinderTeacherCost_nonneg d r C
  have hc0 := (cylinderTeacherCoefficient_pos r).le
  have hD0 : 0 ≤ cylinderInputFactor d := by unfold cylinderInputFactor; positivity
  have hA0 : 0 ≤ cylinderAmplification (cylinderTeacherCost d r C) ((C : ℝ) + 1)
      (cylinderFreeBound r) := by unfold cylinderAmplification; positivity
  have hprod : cylinderTeacherCost d r C * cylinderInputFactor d *
      (cylinderAmplification (cylinderTeacherCost d r C) ((C : ℝ) + 1)
        (cylinderFreeBound r)) ^ r ≤
      (cylinderTeacherCoefficient r * x ^ 4) * (2 * x ^ 2) *
        (cylinderAmplificationCoefficient r * x ^ 4) ^ r := by
    gcongr
  have hshape : (cylinderTeacherCoefficient r * x ^ 4) * (2 * x ^ 2) *
      (cylinderAmplificationCoefficient r * x ^ 4) ^ r =
      2 * cylinderTeacherCoefficient r * (cylinderAmplificationCoefficient r) ^ r *
        x ^ (4 * r + 6) := by
    rw [mul_pow, ← pow_mul]
    rw [pow_add]
    ring
  rw [hshape] at hprod
  have hp : 1 ≤ x ^ (4 * r + 6) := one_le_pow₀ hx
  unfold cylinderUniversalRadius cylinderRadius
  rw [inv_inv]
  change 2 * (2 * cylinderTeacherCost d r C * cylinderInputFactor d *
    (cylinderAmplification (cylinderTeacherCost d r C) ((C : ℝ) + 1)
      (cylinderFreeBound r)) ^ r + 2) ≤ cylinderInverseRadiusCoefficient r * x ^ (4 * r + 6)
  unfold cylinderInverseRadiusCoefficient
  nlinarith

theorem cylinderCoordinateCost_le_polynomial (d r C : ℕ) :
    cylinderCoordinateCost (cylinderUniversalRadius d r C) ≤
      cylinderCoordinateCoefficient r * (1 + (d : ℝ) + C) ^ (4 * r + 6) := by
  let ρ := cylinderUniversalRadius d r C
  let x : ℝ := 1 + d + C
  have hρ : 0 < ρ := cylinderUniversalRadius_pos d r C
  have hρ1 : ρ ≤ 1 := cylinderUniversalRadius_le_one d r C
  have hρ2 : ρ ^ 2 ≤ 1 := by nlinarith
  have hx : 1 ≤ x := by
    dsimp [x]
    linarith [Nat.cast_nonneg d (α := ℝ), Nat.cast_nonneg C (α := ℝ)]
  have hp : 1 ≤ x ^ (4 * r + 6) := one_le_pow₀ hx
  have hinv := cylinderUniversalRadius_inv_le_polynomial d r C
  change ρ⁻¹ ≤ cylinderInverseRadiusCoefficient r * x ^ (4 * r + 6) at hinv
  have hscaled := mul_le_mul_of_nonneg_left hinv
    (show 0 ≤ Real.sqrt (2 * Real.pi) / 2 by positivity)
  change ρ ^ 2 + Real.sqrt (2 * Real.pi) / (2 * ρ) ≤
    cylinderCoordinateCoefficient r * x ^ (4 * r + 6)
  rw [show Real.sqrt (2 * Real.pi) / (2 * ρ) =
    (Real.sqrt (2 * Real.pi) / 2) * ρ⁻¹ by ring]
  unfold cylinderCoordinateCoefficient
  nlinarith

theorem cylinder_totalCost_le_polynomial (d r C : ℕ) :
    cylinderTeacherCost d r C +
      ((d : ℝ) + 2 + r * ((C : ℝ) + 1)) *
        cylinderCoordinateCost (cylinderUniversalRadius d r C) + 1 ≤
      cylinderPolynomialCoefficient r * (1 + (d : ℝ) + C) ^ cylinderPolynomialDegree r := by
  let x : ℝ := 1 + d + C
  have hx : 1 ≤ x := by
    dsimp [x]
    linarith [Nat.cast_nonneg d (α := ℝ), Nat.cast_nonneg C (α := ℝ)]
  have hK := cylinderTeacherCost_le_polynomial d r C
  have hQ := cylinderCoordinateCost_le_polynomial d r C
  have hK0 := (cylinderTeacherCoefficient_pos r).le
  have hQ0 := (cylinderCoordinateCoefficient_pos r).le
  have hq0 := cylinderCoordinateCost_nonneg (cylinderUniversalRadius_pos d r C).le
  have hcount : (d : ℝ) + 2 + r * ((C : ℝ) + 1) ≤ ((r : ℝ) + 3) * x := by
    dsimp [x]
    nlinarith [Nat.cast_nonneg d (α := ℝ), Nat.cast_nonneg C (α := ℝ), Nat.cast_nonneg r (α := ℝ),
      mul_nonneg (Nat.cast_nonneg r : (0 : ℝ) ≤ r) (Nat.cast_nonneg d (α := ℝ))]
  have hpow : x ^ 4 ≤ x ^ (4 * r + 7) := pow_le_pow_right₀ hx (by omega)
  have hp : 1 ≤ x ^ (4 * r + 7) := one_le_pow₀ hx
  have hK' : cylinderTeacherCost d r C ≤ cylinderTeacherCoefficient r * x ^ (4 * r + 7) :=
    hK.trans (mul_le_mul_of_nonneg_left hpow hK0)
  have hQ' : ((d : ℝ) + 2 + r * ((C : ℝ) + 1)) *
      cylinderCoordinateCost (cylinderUniversalRadius d r C) ≤
      ((r : ℝ) + 3) * cylinderCoordinateCoefficient r * x ^ (4 * r + 7) := by
    calc
      _ ≤ (((r : ℝ) + 3) * x) * (cylinderCoordinateCoefficient r * x ^ (4 * r + 6)) := by
        gcongr
      _ = _ := by rw [show 4 * r + 7 = (4 * r + 6) + 1 by omega, pow_succ]; ring
  change _ ≤ cylinderPolynomialCoefficient r * x ^ (4 * r + 7)
  unfold cylinderPolynomialCoefficient
  nlinarith

theorem cylinder_powerCost_le_polynomial {N : ℕ} (hN : 0 < N)
    (d r C : ℕ) {γ : ℝ} (hγ : 1 ≤ γ) :
    cylinderTeacherCost d r C / powerStandardDeviation N γ ^ 2 +
      (N : ℝ) * ((d : ℝ) + 2 + r * ((C : ℝ) + 1)) *
        cylinderCoordinateCost (cylinderUniversalRadius d r C) + 1 ≤
      cylinderPolynomialCoefficient r * (1 + (d : ℝ) + C) ^ cylinderPolynomialDegree r *
        (N : ℝ) ^ γ := by
  have hwidth := width_le_power hN hγ
  have hone := one_le_width_power hN hγ
  have hq : 0 ≤ ((d : ℝ) + 2 + r * ((C : ℝ) + 1)) *
      cylinderCoordinateCost (cylinderUniversalRadius d r C) := by
    have := cylinderCoordinateCost_nonneg (cylinderUniversalRadius_pos d r C).le
    positivity
  have hh := mul_le_mul_of_nonneg_right (cylinder_totalCost_le_polynomial d r C)
    (Real.rpow_nonneg (Nat.cast_nonneg N) γ)
  have hw := mul_le_mul_of_nonneg_right hwidth hq
  have hscale : cylinderTeacherCost d r C / powerStandardDeviation N γ ^ 2 =
      cylinderTeacherCost d r C * (N : ℝ) ^ γ := by
    rw [div_eq_mul_one_div, powerStandardDeviation_inv_sq hN]
  rw [hscale]
  nlinarith

/-- The explicit polynomial comparison used directly with the actual cylinder
mass theorem. It holds at every positive width and for all `γ ≥ 1`. -/
theorem cylinder_polynomial_exp_le {N : ℕ} (hN : 0 < N)
    (d r C : ℕ) {γ : ℝ} (hγ : 1 ≤ γ) :
    Real.exp (-(cylinderPolynomialCoefficient r *
      (1 + (d : ℝ) + C) ^ cylinderPolynomialDegree r * (N : ℝ) ^ γ)) ≤
    Real.exp (-cylinderTeacherCost d r C / powerStandardDeviation N γ ^ 2 -
      (N : ℝ) * ((d : ℝ) + 2 + r * ((C : ℝ) + 1)) *
        cylinderCoordinateCost (cylinderUniversalRadius d r C) - 1) := by
  apply Real.exp_le_exp.mpr
  have := cylinder_powerCost_le_polynomial hN d r C hγ
  simp only [neg_div]
  linarith

end NeuralGeneralization.ConcreteModel
