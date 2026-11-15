import NeuralGeneralization.BatchTwoManuscriptCircuitLearning
import NeuralGeneralization.BatchTwoManuscriptGlobalLearning
import NeuralGeneralization.BatchTwoManuscriptTargetMain

/-! Complete circuit learning at the paper's literal D_* and literal J, with
no target-mass or cost-comparison premise. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoManuscriptLearning
open ConcreteModel RobustPosterior RobustStatistics BatchTwoManuscriptTarget

def literalCircuitInput (d C L : ℕ) (c ε : ℝ) (hd : 0<d) (hL : 2≤L)
    (hC : 0<C) (hc : 0<c) (hε : 0<ε) (hε1 : ε≤1) : Input where
  dimension := d
  depth := L
  targetCost := BatchTwoManuscriptTarget.targetCost d C (L-2) c
  calibration := c
  accuracy := ε
  dimension_pos := hd
  depth_ge_two := hL
  targetCost_ge_one := targetCost_ge_one d (L-2) hC c
  calibration_pos := hc
  accuracy_pos := hε
  accuracy_le_one := hε1

theorem circuit_learning_literal_Dstar_J {d C L : ℕ} {c ε δ : ℝ}
    (hd : 0<d) (hL : 2≤L) (hC : 0<C) (hc : 0<c) (hε : 0<ε) (hε1 : ε≤1)
    (B : LayeredBooleanCircuit d C (L-2)) (hδ : 0<δ)
    (D : Measure (Cube d)) [IsProbabilityMeasure D] (n : ℕ) (hn : 0<n)
    (hbudget : 16*(entropy (literalCircuitInput d C L c ε hd hL hC hc hε hε1)+Real.log (1/δ))≤(n:ℝ)*ε) :
    ∃E : Set (Fin n→Cube d),MeasurableSet E ∧
      1-δ≤(CompressionSampling.iidSamples D n).real E ∧
      ∀sample∈E,∀N : ℕ,C≤N→∀t : ℝ,0<t→t≤1→
        0<(smallPrior d N (L-2) (t/Real.sqrt (N:ℝ))).real
          (robustPosteriorEvent Real.tanh c B.computes sample) ∧
        RobustConfidence.gibbsMarginRisk D
          (robustPosterior (N:=N) (r:=L-2) Real.tanh c (t/Real.sqrt (N:ℝ)) B.computes sample)
          (fun x=>labelReal (B.computes x)) (networkOutput Real.tanh) (1/4)≤ε := by
  apply all_width_all_scale_learning_of_target_mass
    (literalCircuitInput d C L c ε hd hL hC hc hε hε1) hC B.computes _ D hδ n hn hbudget
  intro N hCN t ht ht1
  have hN := hC.trans_le hCN
  have hNR : (0:ℝ)<N := Nat.cast_pos.mpr hN
  have hs : 0<t/Real.sqrt (N:ℝ) := by positivity
  have hscale : (N:ℝ)*(t/Real.sqrt (N:ℝ))^2≤1 := by
    rw [div_pow,Real.sq_sqrt hNR.le]
    have he : (N:ℝ)*(t^2/(N:ℝ))=t^2 := by field_simp
    rw [he]
    nlinarith
  exact literal_target_mass_all_widths hd hC hCN B hc hs hscale

theorem global_circuit_learning_literal_Dstar_J {d C L : ℕ} {c ε δ : ℝ}
    (hd : 0<d) (hL : 2≤L) (hC : 0<C) (hc : 0<c) (hε : 0<ε) (hε1 : ε≤1)
    (B : LayeredBooleanCircuit d C (L-2)) (hδ : 0<δ)
    (D : Measure (Cube d)) [IsProbabilityMeasure D] (n : ℕ) (hn : 0<n)
    (hbudget : 16*(entropy (literalCircuitInput d C L c ε hd hL hC hc hε hε1)+Real.log (1/δ))≤(n:ℝ)*ε) :
    ∃E : Set (Fin n→Cube d),MeasurableSet E ∧
      1-δ≤(CompressionSampling.iidSamples D n).real E ∧
      ∀sample∈E,∀N : ℕ,C≤N→∀t : ℝ,0<t→t≤1→
        0<(smallPrior d N (L-2) (t/Real.sqrt (N:ℝ))).real
          (BatchTwoImprovedGlobalPosterior.robustPosteriorEvent Real.tanh c B.computes sample) ∧
        RobustConfidence.gibbsMarginRisk D
          (BatchTwoImprovedGlobalPosterior.robustPosterior (N:=N) (r:=L-2) Real.tanh c (t/Real.sqrt (N:ℝ)) B.computes sample)
          (fun x=>labelReal (B.computes x)) (networkOutput Real.tanh) (1/4)≤ε := by
  apply BatchTwoManuscriptGlobalLearning.all_width_all_scale_learning_of_target_mass
    (literalCircuitInput d C L c ε hd hL hC hc hε hε1) hC B.computes _ D hδ n hn hbudget
  intro N hCN t ht ht1
  have hN := hC.trans_le hCN
  have hNR : (0:ℝ)<N := Nat.cast_pos.mpr hN
  have hs : 0<t/Real.sqrt (N:ℝ) := by positivity
  have hscale : (N:ℝ)*(t/Real.sqrt (N:ℝ))^2≤1 := by
    rw [div_pow,Real.sq_sqrt hNR.le]
    have he : (N:ℝ)*(t^2/(N:ℝ))=t^2 := by field_simp
    rw [he]
    nlinarith
  exact literal_target_mass_all_widths hd hC hCN B hc hs hscale

end NeuralGeneralization.BatchTwoManuscriptLearning
