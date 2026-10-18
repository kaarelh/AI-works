import NeuralGeneralization.RobustCompressionGrid
import Mathlib.MeasureTheory.Function.Floor

/-!
# A measurable canonical finite-grid rounder

Clamped integer floor makes the rounder defined and measurable on the entire
parameter space. On bounded weights it has the already specified uniform
output error. Thus its finite-code law is an actual measurable pushforward.
-/

noncomputable section
open MeasureTheory
open scoped BigOperators

namespace NeuralGeneralization.ConcreteModel

open ParameterGrid

def roundUnitGrid (T : ℕ) (x : ℝ) : GridInt T :=
  ⟨max (-(T : ℤ)) (min (T : ℤ) ⌊(T : ℝ) * x⌋), by
    apply Finset.mem_Icc.mpr
    constructor
    · exact le_max_left _ _
    · apply max_le
      · omega
      · exact min_le_left _ _⟩

theorem measurable_roundUnitGrid (T : ℕ) : Measurable (roundUnitGrid T) := by
  apply Measurable.subtype_mk
  exact measurable_const.max
    (measurable_const.min ((measurable_const.mul measurable_id).floor))

theorem roundUnitGrid_close (T : ℕ) (hT : 0 < T)
    (x : ℝ) (hx : |x| ≤ 1) :
    |x - ((roundUnitGrid T x).val : ℝ) / T| ≤ 1 / (T : ℝ) := by
  have hTR : (0 : ℝ) < T := Nat.cast_pos.mpr hT
  obtain ⟨hlx, hux⟩ := abs_le.mp hx
  have hlo : -(T : ℤ) ≤ ⌊(T : ℝ) * x⌋ := by
    apply Int.le_floor.mpr
    push_cast
    nlinarith
  have hhi : ⌊(T : ℝ) * x⌋ ≤ (T : ℤ) := by
    have hh := Int.floor_mono (mul_le_mul_of_nonneg_left hux hTR.le)
    simpa using hh
  simp only [roundUnitGrid, min_eq_right hhi, max_eq_right hlo]
  have hl := Int.floor_le ((T : ℝ) * x)
  have hu := Int.lt_floor_add_one ((T : ℝ) * x)
  rw [abs_le]
  constructor
  · have hz : 0 ≤ x - (⌊(T : ℝ) * x⌋ : ℝ) / T := by
      apply sub_nonneg.mpr
      apply (div_le_iff₀ hTR).mpr
      nlinarith
    linarith [one_div_nonneg.mpr hTR.le]
  · apply (le_div_iff₀ hTR).mpr
    have heq : (x - (⌊(T : ℝ) * x⌋ : ℝ) / T) * T =
        (T : ℝ) * x - ⌊(T : ℝ) * x⌋ := by field_simp
    rw [heq]
    linarith

def roundRobustCode (d M r B R : ℕ) (w : Weights d M r) :
    RobustOutputCode d M r B R :=
  fun i => roundUnitGrid (robustOutputMesh d M r B R) (w i / (B : ℝ))

theorem measurable_roundRobustCode (d M r B R : ℕ) :
    Measurable (roundRobustCode d M r B R) := by
  apply measurable_pi_lambda
  intro i
  exact (measurable_roundUnitGrid _).comp ((measurable_pi_apply i).div_const _)

theorem roundRobustCode_weights_close {d M r B R : ℕ}
    (hB : 0 < B) (hR : 0 < R)
    (w : Weights d M r) (hw : boundedWeights B w) (i : WeightIndex d M r) :
    |w i - robustGridWeights (roundRobustCode d M r B R w) i| ≤
      (B : ℝ) / robustOutputMesh d M r B R := by
  have hBR : (0 : ℝ) < B := Nat.cast_pos.mpr hB
  have hx : |w i / (B : ℝ)| ≤ 1 := by
    rw [abs_div, abs_of_pos hBR]
    exact (div_le_one hBR).mpr (hw i)
  have hq := roundUnitGrid_close (robustOutputMesh d M r B R)
    (robustOutputMesh_pos d M r hB hR) (w i / (B : ℝ)) hx
  have hh := mul_le_mul_of_nonneg_left hq hBR.le
  have hid : w i - robustGridWeights (roundRobustCode d M r B R w) i =
      (B : ℝ) * (w i / B -
        ((roundUnitGrid (robustOutputMesh d M r B R) (w i / B)).val : ℝ) /
          robustOutputMesh d M r B R) := by
    unfold robustGridWeights roundRobustCode decode
    field_simp
  rw [hid, abs_mul, abs_of_pos hBR]
  simpa only [mul_one_div] using hh

/-- Pathwise approximation by the measurable canonical code. -/
theorem roundRobustCode_output_close {d M r B R : ℕ}
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (hB : 0 < B) (hR : 0 < R)
    (w : Weights d M r) (hw : boundedWeights B w) (x : Cube d) :
    |networkOutput φ w x -
      robustGridOutput d M r B R φ (roundRobustCode d M r B R w) x| ≤
        1 / (R : ℝ) := by
  have hBR : (0 : ℝ) < B := Nat.cast_pos.mpr hB
  have hRR : (0 : ℝ) < R := Nat.cast_pos.mpr hR
  have hPR : (0 : ℝ) < parameterMesh d M r B :=
    Nat.cast_pos.mpr (parameterMesh_pos d M r B)
  have herr := networkOutput_parameter_stability φ hφ w
    (robustGridWeights (roundRobustCode d M r B R w)) B
    ((B : ℝ) / robustOutputMesh d M r B R) (Nat.cast_nonneg B) (by positivity)
    (robustGridWeights_bounded hB hR _) (roundRobustCode_weights_close hB hR w hw) x
  apply herr.trans
  calc
    (B : ℝ) / robustOutputMesh d M r B R *
      nextSensitivity M B (hiddenSensitivity d M B r) ≤
        (B : ℝ) / robustOutputMesh d M r B R * (parameterMesh d M r B : ℝ) :=
      mul_le_mul_of_nonneg_left (sensitivity_le_parameterMesh d M r B) (by positivity)
    _ = 1 / (R : ℝ) := by
      simp only [robustOutputMesh, Nat.cast_mul]
      field_simp

end NeuralGeneralization.ConcreteModel
