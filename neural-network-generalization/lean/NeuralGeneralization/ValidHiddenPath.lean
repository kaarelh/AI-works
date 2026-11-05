import NeuralGeneralization.RobustCompressionInductionPath
import NeuralGeneralization.FunctionPrior
import Mathlib.Topology.Order.Compact

/-! The literal closed activation-state box for a complete hidden path. -/
noncomputable section
namespace NeuralGeneralization.ConcreteModel
open RobustCompressionInduction

def validHiddenPath {N r : ℕ} (h : HiddenPath N r) : Prop := ∀ s i,|h s i| ≤ 1

lemma validHiddenPath_iff_box {N r : ℕ} (h : HiddenPath N r) :
    validHiddenPath h ↔ h ∈ Set.Icc (fun _ _ => -(1:ℝ)) (fun _ _ => (1:ℝ)) := by
  simp only [validHiddenPath,Set.mem_Icc,Pi.le_def,abs_le,forall_and]

lemma isCompact_validHiddenPath (N r : ℕ) :
    IsCompact {h : HiddenPath N r | validHiddenPath h} := by
  simp_rw [validHiddenPath_iff_box]
  exact isCompact_Icc

lemma isClosed_validHiddenPath (N r : ℕ) :
    IsClosed {h : HiddenPath N r | validHiddenPath h} := (isCompact_validHiddenPath N r).isClosed

lemma measurableSet_validHiddenPath (N r : ℕ) :
    MeasurableSet {h : HiddenPath N r | validHiddenPath h} := (isClosed_validHiddenPath N r).measurableSet

lemma validHiddenPath_append {N r : ℕ} {h : HiddenPath N r} {v : Fin N → ℝ}
    (hh : validHiddenPath h) (hv : ∀ i,|v i| ≤ 1) : validHiddenPath (appendPath h v) := by
  intro s i
  induction s using Fin.lastCases with
  | last => simpa using hv i
  | cast s => simpa using hh s i

end NeuralGeneralization.ConcreteModel
