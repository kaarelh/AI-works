import NeuralGeneralization.BatchTwoManuscriptLearningMain
import NeuralGeneralization.BatchTwoImprovedTargetMain

/-! An unconditional circuit instantiation of the literal compression J.
This uses the already verified cylinder cost; it does not identify that cost
with the manuscript's distinct displayed target-cylinder constants. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoManuscriptLearning
open ConcreteModel RobustPosterior RobustStatistics

def verifiedCircuitInput (d C r : ℕ) (c ε : ℝ) (hd : 0<d) (hc : 0<c)
    (hε : 0<ε) (hε1 : ε≤1) : Input where
  dimension := d
  depth := r+2
  targetCost := max 1 (improvedTargetCost d C r c)
  calibration := c
  accuracy := ε
  dimension_pos := hd
  depth_ge_two := by omega
  targetCost_ge_one := le_max_left _ _
  calibration_pos := hc
  accuracy_pos := hε
  accuracy_le_one := hε1

theorem circuit_learning_with_literal_J (p : Input) {C : ℕ} (hC : 0<C)
    (B : LayeredBooleanCircuit p.dimension C (p.depth-2))
    (hcost : improvedTargetCost p.dimension C (p.depth-2) p.calibration≤p.targetCost)
    {δ : ℝ} (hδ : 0<δ) (D : Measure (Cube p.dimension)) [IsProbabilityMeasure D]
    (n : ℕ) (hn : 0<n) (hbudget : 16*(entropy p+Real.log (1/δ))≤(n:ℝ)*p.accuracy) :
    ∃E : Set (Fin n→Cube p.dimension),MeasurableSet E ∧
      1-δ≤(CompressionSampling.iidSamples D n).real E ∧
      ∀sample∈E,∀N : ℕ,C≤N→∀t : ℝ,0<t→t≤1→
        0<(smallPrior p.dimension N (p.depth-2) (t/Real.sqrt (N:ℝ))).real
          (robustPosteriorEvent Real.tanh p.calibration B.computes sample) ∧
        RobustConfidence.gibbsMarginRisk D
          (robustPosterior (N:=N) (r:=p.depth-2) Real.tanh p.calibration (t/Real.sqrt (N:ℝ)) B.computes sample)
          (fun x=>labelReal (B.computes x)) (networkOutput Real.tanh) (1/4)≤p.accuracy := by
  apply all_width_all_scale_learning_of_target_mass p hC B.computes _ D hδ n hn hbudget
  intro N hCN t ht ht1
  have hN := hC.trans_le hCN
  have hNR : (0:ℝ)<N := Nat.cast_pos.mpr hN
  have hs : 0<t/Real.sqrt (N:ℝ) := by positivity
  have hscale : (N:ℝ)*(t/Real.sqrt (N:ℝ))^2≤1 := by
    rw [div_pow,Real.sq_sqrt hNR.le]
    have he : (N:ℝ)*(t^2/(N:ℝ))=t^2 := by field_simp
    rw [he]
    nlinarith
  have hh := improved_target_mass_all_widths p.dimension_pos hC hCN B p.calibration_pos hs hscale
  apply (Real.exp_le_exp.mpr (div_le_div_of_nonneg_right (neg_le_neg hcost) (sq_nonneg _))).trans hh

end NeuralGeneralization.BatchTwoManuscriptLearning
