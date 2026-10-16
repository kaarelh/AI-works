import NeuralGeneralization.CylinderStability
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic

/-! # Shared explicit constants for the all-width Gaussian cylinder -/

noncomputable section
namespace NeuralGeneralization.ConcreteModel

def cylinderTeacherCost (d r C : ℕ) : ℝ :=
  18 * ((d : ℝ) * (d + 1) * C ^ 2 + (r + 1) * C ^ 4)

def cylinderFreeBound (r : ℕ) : ℝ := 16 * ((r : ℝ) + 1)

def cylinderUniversalRadius (d r C : ℕ) : ℝ :=
  cylinderRadius d r (cylinderTeacherCost d r C) ((C : ℝ) + 1)
    (cylinderFreeBound r)

def cylinderCoordinateCost (ρ : ℝ) : ℝ :=
  ρ ^ 2 + Real.sqrt (2 * Real.pi) / (2 * ρ)

theorem cylinderTeacherCost_nonneg (d r C : ℕ) : 0 ≤ cylinderTeacherCost d r C := by
  unfold cylinderTeacherCost
  positivity

theorem cylinderFreeBound_pos (r : ℕ) : 0 < cylinderFreeBound r := by
  unfold cylinderFreeBound
  positivity

theorem cylinderUniversalRadius_pos (d r C : ℕ) : 0 < cylinderUniversalRadius d r C :=
  cylinderRadius_pos d r (cylinderTeacherCost_nonneg d r C) (by positivity)

theorem cylinderUniversalRadius_le_one (d r C : ℕ) : cylinderUniversalRadius d r C ≤ 1 :=
  cylinderRadius_le_one d r (cylinderTeacherCost_nonneg d r C) (by positivity)

theorem cylinderCoordinateCost_nonneg {ρ : ℝ} (hρ : 0 ≤ ρ) :
    0 ≤ cylinderCoordinateCost ρ := by
  unfold cylinderCoordinateCost
  positivity

end NeuralGeneralization.ConcreteModel
