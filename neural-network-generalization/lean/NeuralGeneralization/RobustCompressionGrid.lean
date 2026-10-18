import NeuralGeneralization.FiniteParameterGrid
import NeuralGeneralization.ParameterCounting
import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-!
# Actual finite output grids for bounded neural networks

This discretizes real-valued outputs, with no margin assumption. Although
the inverse mesh grows exponentially with depth, its logarithm has an
explicit polynomial bound in depth, width, weight bound, and inverse error.
The finite class is the actual decoded parameter grid, not an assumed cover.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.ConcreteModel

open ParameterGrid

/-- Integer inverse mesh for absolute output error 1 / R. -/
def robustOutputMesh (d M r B R : ℕ) : ℕ :=
  B * R * parameterMesh d M r B

theorem robustOutputMesh_pos (d M r : ℕ) {B R : ℕ}
    (hB : 0 < B) (hR : 0 < R) :
    0 < robustOutputMesh d M r B R := by
  unfold robustOutputMesh
  exact Nat.mul_pos (Nat.mul_pos hB hR) (parameterMesh_pos d M r B)

/-- Codes for a concrete finite class of actual depth-r+2 networks. -/
abbrev RobustOutputCode (d M r B R : ℕ) :=
  WeightIndex d M r → GridInt (robustOutputMesh d M r B R)

def robustGridWeights {d M r B R : ℕ}
    (q : RobustOutputCode d M r B R) : Weights d M r :=
  fun i => (B : ℝ) * decode (robustOutputMesh d M r B R) q i

def robustGridOutput (d M r B R : ℕ) (φ : ℝ → ℝ)
    (q : RobustOutputCode d M r B R) : Cube d → ℝ :=
  networkOutput φ (robustGridWeights q)

theorem robustGridWeights_bounded {d M r B R : ℕ}
    (hB : 0 < B) (hR : 0 < R) (q : RobustOutputCode d M r B R) :
    boundedWeights B (robustGridWeights q) := by
  intro i
  unfold robustGridWeights
  rw [abs_mul, abs_of_nonneg (Nat.cast_nonneg B)]
  simpa using mul_le_mul_of_nonneg_left
    (decode_abs_le_one _ (robustOutputMesh_pos d M r hB hR) q i)
    (Nat.cast_nonneg (α := ℝ) B)

/-- Uniform output approximation by an explicitly finite parameter class. -/
theorem exists_robustGridOutput {d M r B R : ℕ}
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (hB : 0 < B) (hR : 0 < R)
    (w : Weights d M r) (hw : boundedWeights B w) :
    ∃ q : RobustOutputCode d M r B R, ∀ x : Cube d,
      |networkOutput φ w x - robustGridOutput d M r B R φ q x| ≤
        1 / (R : ℝ) := by
  have hBR : (0 : ℝ) < B := Nat.cast_pos.mpr hB
  have hRR : (0 : ℝ) < R := Nat.cast_pos.mpr hR
  have hTR : (0 : ℝ) < robustOutputMesh d M r B R :=
    Nat.cast_pos.mpr (robustOutputMesh_pos d M r hB hR)
  have hPR : (0 : ℝ) < parameterMesh d M r B :=
    Nat.cast_pos.mpr (parameterMesh_pos d M r B)
  obtain ⟨q, hq⟩ := exists_close_grid
    (robustOutputMesh d M r B R) (robustOutputMesh_pos d M r hB hR)
    (fun i => w i / (B : ℝ)) (fun i => by
      rw [abs_div, abs_of_pos hBR]
      exact (div_le_one hBR).mpr (hw i))
  refine ⟨q, ?_⟩
  have hclose (i : WeightIndex d M r) :
      |w i - robustGridWeights q i| ≤
        (B : ℝ) / robustOutputMesh d M r B R := by
    have hh := mul_le_mul_of_nonneg_left (hq i) hBR.le
    have hid : w i - robustGridWeights q i =
        (B : ℝ) * (w i / B - decode (robustOutputMesh d M r B R) q i) := by
      unfold robustGridWeights
      field_simp
    rw [hid, abs_mul, abs_of_pos hBR]
    simpa only [mul_one_div] using hh
  intro x
  have herr := networkOutput_parameter_stability φ hφ w (robustGridWeights q)
    B ((B : ℝ) / robustOutputMesh d M r B R)
    (Nat.cast_nonneg B) (by positivity)
    (robustGridWeights_bounded hB hR q) hclose x
  apply herr.trans
  calc
    (B : ℝ) / robustOutputMesh d M r B R *
        nextSensitivity M B (hiddenSensitivity d M B r)
        ≤ (B : ℝ) / robustOutputMesh d M r B R *
          (parameterMesh d M r B : ℝ) :=
      mul_le_mul_of_nonneg_left (sensitivity_le_parameterMesh d M r B)
        (by positivity)
    _ = 1 / (R : ℝ) := by
      simp only [robustOutputMesh, Nat.cast_mul]
      field_simp

/-- Number of actual parameter coordinates in the concrete architecture. -/
def robustParameterCount (d M r : ℕ) : ℕ :=
  M * (d + 1) + r * M * M + M

theorem robustWeightIndex_card (d M r : ℕ) :
    Fintype.card (WeightIndex d M r) = robustParameterCount d M r := by
  simp [WeightIndex, robustParameterCount, Nat.mul_assoc, Nat.add_assoc]

theorem robustOutputCode_card (d M r B R : ℕ) :
    Fintype.card (RobustOutputCode d M r B R) =
      (2 * robustOutputMesh d M r B R + 1) ^ robustParameterCount d M r := by
  rw [Fintype.card_fun, gridInt_card, robustWeightIndex_card]

/-- Polynomial entropy budget, including variable depth. -/
def robustGridEntropyBudget (d M r B R : ℕ) : ℕ :=
  robustParameterCount d M r *
    (4 + B + R + d + (r + 1) * (M * (B + 1) + 1))

theorem robustOutputMesh_log_le (d M r : ℕ) {B R : ℕ}
    (hB : 0 < B) (hR : 0 < R) :
    Real.log (2 * (robustOutputMesh d M r B R : ℝ) + 1) ≤
      (4 + B + R + d + (r + 1) * (M * (B + 1) + 1) : ℕ) := by
  have hBR : (0 : ℝ) < B := Nat.cast_pos.mpr hB
  have hRR : (0 : ℝ) < R := Nat.cast_pos.mpr hR
  have hT : 0 < robustOutputMesh d M r B R :=
    robustOutputMesh_pos d M r hB hR
  have hTR : (0 : ℝ) < robustOutputMesh d M r B R := Nat.cast_pos.mpr hT
  have hTone : (1 : ℝ) ≤ robustOutputMesh d M r B R := by exact_mod_cast hT
  have hd : (0 : ℝ) < (d : ℝ) + 1 := by positivity
  have hb : (0 : ℝ) < (M : ℝ) * (B + 1) + 1 := by positivity
  have hlog : Real.log (robustOutputMesh d M r B R : ℝ) =
      Real.log (B : ℝ) + Real.log (R : ℝ) +
        Real.log ((d : ℝ) + 1) +
        (r + 1 : ℕ) * Real.log ((M : ℝ) * (B + 1) + 1) := by
    simp only [robustOutputMesh, parameterMesh, Nat.cast_mul, Nat.cast_add,
      Nat.cast_one, Nat.cast_pow]
    rw [Real.log_mul (by positivity) (by positivity),
      Real.log_mul hBR.ne' hRR.ne',
      Real.log_mul hd.ne' (pow_ne_zero _ hb.ne'), Real.log_pow]
    push_cast
    ring
  have h3 : Real.log (3 : ℝ) ≤ 3 := (Real.log_le_sub_one_of_pos (by norm_num)).trans (by norm_num)
  have hlogB : Real.log (B : ℝ) ≤ B := (Real.log_le_sub_one_of_pos hBR).trans (by linarith)
  have hlogR : Real.log (R : ℝ) ≤ R := (Real.log_le_sub_one_of_pos hRR).trans (by linarith)
  have hlogd : Real.log ((d : ℝ) + 1) ≤ d + 1 :=
    (Real.log_le_sub_one_of_pos hd).trans (by linarith)
  have hlogbase : Real.log ((M : ℝ) * (B + 1) + 1) ≤ (M : ℝ) * (B + 1) + 1 :=
    (Real.log_le_sub_one_of_pos hb).trans (by linarith)
  calc
    _ ≤ Real.log (3 * (robustOutputMesh d M r B R : ℝ)) := by
      apply Real.log_le_log (by positivity)
      linarith
    _ = Real.log 3 + Real.log (robustOutputMesh d M r B R : ℝ) :=
      Real.log_mul (by norm_num) hTR.ne'
    _ ≤ 3 + ((B : ℝ) + R + (d + 1) +
        (r + 1 : ℕ) * ((M : ℝ) * (B + 1) + 1)) := by
      rw [hlog]
      have hh := mul_le_mul_of_nonneg_left hlogbase
        (Nat.cast_nonneg (α := ℝ) (r + 1))
      linarith
    _ = _ := by push_cast; ring

/-- Logarithmic cardinality is polynomial jointly in all grid resources. -/
theorem robustOutputCode_log_card_le (d M r : ℕ) {B R : ℕ}
    (hB : 0 < B) (hR : 0 < R) :
    Real.log (Fintype.card (RobustOutputCode d M r B R) : ℝ) ≤
      (robustGridEntropyBudget d M r B R : ℝ) := by
  rw [robustOutputCode_card]
  push_cast
  rw [Real.log_pow]
  have hh := mul_le_mul_of_nonneg_left (robustOutputMesh_log_le d M r hB hR)
    (Nat.cast_nonneg (α := ℝ) (robustParameterCount d M r))
  simpa only [robustGridEntropyBudget, Nat.cast_mul] using hh

end NeuralGeneralization.ConcreteModel
