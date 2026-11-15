import NeuralGeneralization.BatchTwoManuscriptScore
import NeuralGeneralization.RobustPosterior

/-! Literal substitutions beta, B_v, K, r and alpha in the explicit budget. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
namespace NeuralGeneralization.BatchTwoManuscriptLearning
open ConcreteModel

structure Input where
  dimension : ℕ
  depth : ℕ
  targetCost : ℝ
  calibration : ℝ
  accuracy : ℝ
  dimension_pos : 0<dimension
  depth_ge_two : 2≤depth
  targetCost_ge_one : 1≤targetCost
  calibration_pos : 0<calibration
  accuracy_pos : 0<accuracy
  accuracy_le_one : accuracy≤1

def discardedMass (p : Input) : ℝ := p.accuracy/4
def posteriorReadoutBound (p : Input) : ℝ := max 8 (8*(p.targetCost+Real.log (1/discardedMass p)))
def compressionRadius (p : Input) : ℝ := min (1/6) (p.calibration/Real.sqrt (1+((p.depth:ℝ)-1)*posteriorReadoutBound p))

theorem discardedMass_pos (p : Input) : 0<discardedMass p := by unfold discardedMass; exact div_pos p.accuracy_pos (by norm_num)
theorem discardedMass_le_quarter (p : Input) : discardedMass p≤1/4 := by unfold discardedMass; linarith [p.accuracy_le_one]
theorem posteriorReadoutBound_ge_eight (p : Input) : 8≤posteriorReadoutBound p := le_max_left _ _
theorem compressionRadius_pos (p : Input) : 0<compressionRadius p := by
  unfold compressionRadius
  apply lt_min (by norm_num)
  apply div_pos p.calibration_pos
  apply Real.sqrt_pos.mpr
  have hL : (2:ℝ)≤p.depth := by exact_mod_cast p.depth_ge_two
  have hB := posteriorReadoutBound_ge_eight p
  nlinarith

def compressionInput (p : Input) : BatchTwoManuscriptResources.Input where
  dimension := p.dimension
  depth := p.depth
  energy := p.targetCost+1
  radius := compressionRadius p
  failure := p.accuracy/12
  dimension_pos := p.dimension_pos
  depth_ge_two := p.depth_ge_two
  energy_ge_one := by linarith [p.targetCost_ge_one]
  radius_pos := compressionRadius_pos p
  radius_le_one := (min_le_left _ _).trans (by norm_num)
  failure_pos := div_pos p.accuracy_pos (by norm_num)
  failure_le_eighth := by linarith [p.accuracy_le_one]

abbrev CandidateCode (p : Input) := BatchTwoManuscriptResources.GridCode (compressionInput p)
def candidate (p : Input) (φ : ℝ→ℝ) : CandidateCode p→Cube p.dimension→ℝ :=
  BatchTwoManuscriptResources.gridOutput (compressionInput p) φ
def entropy (p : Input) : ℝ := BatchTwoManuscriptResources.gridEntropy (compressionInput p)

theorem candidate_entropy (p : Input) : Real.log (Fintype.card (CandidateCode p):ℝ)≤entropy p :=
  BatchTwoManuscriptResources.gridCode_log_card_le (compressionInput p)

theorem posteriorReadoutBound_allocation (p : Input) :
    4*(p.targetCost-Real.log (discardedMass p))≤posteriorReadoutBound p := by
  have hβ := discardedMass_pos p
  have hβ1 : discardedMass p≤1 := (discardedMass_le_quarter p).trans (by norm_num)
  have hl : 0≤Real.log (1/discardedMass p) := Real.log_nonneg ((one_le_div hβ).mpr hβ1)
  have hb : 8*(p.targetCost+Real.log (1/discardedMass p))≤posteriorReadoutBound p := le_max_right _ _
  rw [one_div,Real.log_inv] at hl hb
  linarith [p.targetCost_ge_one]

theorem compression_radius_le_robust (p : Input) {N : ℕ}
    (w : Weights p.dimension N (p.depth-2)) (hw : readoutEnergy w≤posteriorReadoutBound p) :
    (compressionInput p).radius≤robustRadius p.calibration w := by
  have hh := RobustPosterior.calibrated_radius_lower p.calibration_pos w hw
  have he : ((p.depth-2:ℕ):ℝ)+1=(p.depth:ℝ)-1 := by rw [Nat.cast_sub p.depth_ge_two]; norm_num; ring
  rw [he] at hh
  exact (min_le_right _ _).trans hh

end NeuralGeneralization.BatchTwoManuscriptLearning
