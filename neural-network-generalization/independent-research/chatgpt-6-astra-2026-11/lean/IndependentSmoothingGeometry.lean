import Mathlib

/-!
Exact finite Walsh coefficients used by the six-dimensional critical-covariance
correction. This file checks the integer ReLU sums and the stated spectral
constants; it does not formalize the critical-law covariance limit or the
analytic diagonalization argument in the manuscript.
-/
set_option maxRecDepth 100000
set_option maxHeartbeats 0

namespace IndependentResearch
open scoped BigOperators

abbrev SmoothingCube6 := Fin 64

def smoothingSign6 (x : SmoothingCube6) (i : Fin 6) : ℤ :=
  if x.val.testBit i.val then -1 else 1

def smoothingDegree6 (s : SmoothingCube6) : ℕ :=
  (Finset.univ.filter (fun i : Fin 6 => s.val.testBit i.val)).card

def smoothingCharacter6 (s x : SmoothingCube6) : ℤ :=
  ∏ i : Fin 6, if s.val.testBit i.val then smoothingSign6 x i else 1

def smoothingRelu6 (x : SmoothingCube6) : ℤ :=
  max 0 (∑ i : Fin 6, smoothingSign6 x i)

def smoothingCoefficientNumerator6 (j : ℕ) : ℤ :=
  if j = 0 then 60 else if j = 1 then 32 else if j = 2 then 12
  else if j = 4 then -4 else if j = 6 then 12 else 0

/-- Exact unnormalized Walsh coefficients of the actual six-bit ReLU sum. -/
theorem smoothing_relu_six_walsh_coefficients : ∀ s : SmoothingCube6,
    ∑ x : SmoothingCube6, smoothingCharacter6 s x * smoothingRelu6 x =
      smoothingCoefficientNumerator6 (smoothingDegree6 s) := by
  decide

/-- Exactly 38 Walsh characters have a nonzero displayed coefficient. -/
theorem smoothing_six_nonzero_character_count :
    (Finset.univ.filter (fun s : SmoothingCube6 =>
      smoothingCoefficientNumerator6 (smoothingDegree6 s) ≠ 0)).card = 38 := by
  decide

/-- Squaring the integer coefficient and dividing by the incoming dimension
produces the spectral constants stated for the sum of ray outer products. -/
theorem smoothing_six_spectral_constants :
    (60 : ℝ)^2 / 6 = 600 ∧
    (32 : ℝ)^2 / 6 = 512/3 ∧
    (12 : ℝ)^2 / 6 = 24 ∧
    (-4 : ℝ)^2 / 6 = 8/3 := by
  norm_num

end IndependentResearch
