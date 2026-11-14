import Mathlib.Analysis.SpecialFunctions.Trigonometric.Chebyshev.Basic
import Mathlib.Tactic

/-! The exact finite polynomial used in the restoring-curvature certificate. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

def restoringMu : ℝ := 7499 / 10000

def restoringAmplitude (q : ℝ) : ℝ := (1 + 2 * q + 2 * q ^ 4) ^ 4

def restoringRatioPolynomial (q : ℝ) (j : ℕ) : ℝ :=
  if j = 0 then 1 else
    (1 - q) * ∑ ell ∈ Finset.range 15,
      if j + (2 * j + 1) * ell < 15 then q ^ (j + (2 * j + 1) * ell) else 0

def restoringPolynomial (q x : ℝ) : ℝ :=
  restoringAmplitude q * restoringMu / 2 *
      (∑ j ∈ Finset.range 6, (-1 : ℝ) ^ j * restoringRatioPolynomial q j) +
    ∑ j ∈ Finset.range 6,
      (-1 : ℝ) ^ j * (((2 * j + 1 : ℕ) : ℝ) ^ 2 -
        restoringAmplitude q * (1 - restoringMu / 2)) *
        restoringRatioPolynomial q j * (Polynomial.Chebyshev.T ℝ (2 * j + 1)).eval x

end NeuralGeneralization.OnlineLowerTanh
