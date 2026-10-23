import NeuralGeneralization.BatchTwoMergingSurvivalMain

/-! The finite-cover budgets displayed in the manuscript. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel

def sharpReadoutBound (D ε:ℝ):ℝ := max 8 (8*(D+Real.log (4/ε)))
def sharpPopulationBound (D ε:ℝ):ℕ := ⌈1+16*sharpReadoutBound D ε⌉₊
def sharpEnergyBound (d r:ℕ) (D ε:ℝ):ℝ :=
  4*(D+Real.log (4/ε)+partitionEntropyBudget d r (sharpPopulationBound D ε))
def sharpGridMesh (r:ℕ) (A:ℝ):ℝ := 1/(32*((r:ℝ)+2)*A^(r+2))
def sharpReluEntropy (d r:ℕ) (D ε:ℝ):ℝ :=
  let Q:=sharpPopulationBound D ε
  let R:=1+Real.sqrt (sharpEnergyBound d r D ε)
  let A:=gridAmplification d Q R
  ((Q:ℝ)*(d+2)+r*(Q:ℝ)^2)*Real.log (3+4*R/sharpGridMesh r A)
def sharpGeluEntropy (d r:ℕ) (D ε:ℝ):ℝ :=
  let Q:=sharpPopulationBound D ε
  let R:=1+Real.sqrt (sharpEnergyBound d r D ε)
  let A:=geluGridAmplification d Q R
  ((Q:ℝ)*(d+2)+r*(Q:ℝ)^2+(r+1)*Q)*Real.log (3+4*R/sharpGridMesh r A)
abbrev SharpReluGridCode (d r:ℕ) (D ε:ℝ) :=
  NetworkGridCode d (sharpPopulationBound D ε) r
    (gridResolution d (sharpPopulationBound D ε) r (1+Real.sqrt (sharpEnergyBound d r D ε)))
abbrev SharpGeluGridCode (d r:ℕ) (D ε:ℝ) :=
  GeluGridCode d (sharpPopulationBound D ε) r
    (geluGridResolution d (sharpPopulationBound D ε) r (1+Real.sqrt (sharpEnergyBound d r D ε)))
def sharpReluGridFunction (d r:ℕ) (D ε:ℝ) (c:SharpReluGridCode d r D ε) (x:Cube d):ℝ :=
  networkOutput relu (gridWeights d (sharpPopulationBound D ε) r
    (gridResolution d (sharpPopulationBound D ε) r (1+Real.sqrt (sharpEnergyBound d r D ε)))
    (1+Real.sqrt (sharpEnergyBound d r D ε)) c) x
def sharpGeluGridFunction (d r:ℕ) (D ε:ℝ) (c:SharpGeluGridCode d r D ε) (x:Cube d):ℝ :=
  perspectiveOutput (geluGridWeights d (sharpPopulationBound D ε) r
    (geluGridResolution d (sharpPopulationBound D ε) r (1+Real.sqrt (sharpEnergyBound d r D ε)))
    (1+Real.sqrt (sharpEnergyBound d r D ε)) c)
    (geluGridMasses d (sharpPopulationBound D ε) r
      (geluGridResolution d (sharpPopulationBound D ε) r (1+Real.sqrt (sharpEnergyBound d r D ε))) c) x

theorem sharpReadoutBound_ge_eight (D ε:ℝ):8≤sharpReadoutBound D ε := le_max_left _ _
theorem sharpPopulationBound_pos (D ε:ℝ):0<sharpPopulationBound D ε := by
  apply Nat.ceil_pos.mpr
  have h:=sharpReadoutBound_ge_eight D ε
  linarith

theorem log_four_div {ε:ℝ} (hε:0<ε):Real.log (4/ε)= -Real.log (ε/4) := by
  rw [show 4/ε=(ε/4)⁻¹ by field_simp,Real.log_inv]

theorem sharpReadoutBound_budget {D ε:ℝ} (hD:0≤D) (hε:0<ε) (hε1:ε≤1):
    4*(D-Real.log (ε/4))≤sharpReadoutBound D ε := by
  have hh:=le_max_right (8:ℝ) (8*(D+Real.log (4/ε)))
  have hlog:Real.log (ε/4)≤0 := Real.log_nonpos (by positivity) (by linarith)
  rw [log_four_div hε] at hh
  unfold sharpReadoutBound
  rw [log_four_div hε]
  linarith

theorem gridResolution_log_le (d Q r:ℕ) {R:ℝ} (hR:1≤R):
    Real.log (2*(gridResolution d Q r R:ℝ)+1)≤
      Real.log (3+4*R/sharpGridMesh r (gridAmplification d Q R)) := by
  let A:=gridAmplification d Q R
  have hA:1≤A := (gridAmplification_bounds d Q hR).1
  have hden:0<32*((r:ℝ)+2)*A^(r+2) := by positivity
  have ht:(gridResolution d Q r R:ℝ)≤32*R*((r:ℝ)+2)*A^(r+2)+1 := by
    exact (Nat.ceil_lt_add_one (by positivity)).le
  apply Real.log_le_log (by positivity)
  change 2*(gridResolution d Q r R:ℝ)+1≤3+4*R/(1/(32*((r:ℝ)+2)*A^(r+2)))
  simp only [div_div_eq_mul_div,div_one]
  have hp:0≤R*((r:ℝ)+2)*A^(r+2) := by positivity
  nlinarith

theorem geluGridResolution_log_le (d Q r:ℕ) {R:ℝ} (hR:1≤R):
    Real.log (2*(geluGridResolution d Q r R:ℝ)+1)≤
      Real.log (3+4*R/sharpGridMesh r (geluGridAmplification d Q R)) := by
  let A:=geluGridAmplification d Q R
  have hA:1≤A := (geluGridAmplification_bounds d Q hR).1
  have hden:0<32*((r:ℝ)+2)*A^(r+2) := by positivity
  have ht:(geluGridResolution d Q r R:ℝ)≤64*R*((r:ℝ)+2)*A^(r+2)+1 := by
    exact (Nat.ceil_lt_add_one (by positivity)).le
  apply Real.log_le_log (by positivity)
  change 2*(geluGridResolution d Q r R:ℝ)+1≤3+4*R/(1/(32*((r:ℝ)+2)*A^(r+2)))
  simp only [div_div_eq_mul_div,div_one]
  nlinarith

theorem sharpReluGrid_entropy (d r:ℕ) (D ε:ℝ):
    Real.log (Fintype.card (SharpReluGridCode d r D ε):ℝ)≤sharpReluEntropy d r D ε := by
  rw [networkGridCode_card]
  push_cast
  rw [Real.log_pow]
  push_cast
  unfold sharpReluEntropy
  apply mul_le_mul_of_nonneg_left (gridResolution_log_le _ _ _ (by linarith [Real.sqrt_nonneg (sharpEnergyBound d r D ε)]))
  positivity

theorem sharpGeluGrid_entropy (d r:ℕ) (D ε:ℝ):
    Real.log (Fintype.card (SharpGeluGridCode d r D ε):ℝ)≤sharpGeluEntropy d r D ε := by
  rw [geluGridCode_card]
  push_cast
  rw [Real.log_pow]
  push_cast
  unfold sharpGeluEntropy
  apply mul_le_mul_of_nonneg_left (geluGridResolution_log_le _ _ _ (by linarith [Real.sqrt_nonneg (sharpEnergyBound d r D ε)]))
  positivity

end NeuralGeneralization.BatchTwoMerging
