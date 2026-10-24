import NeuralGeneralization.BatchTwoMergingSharpTarget
import NeuralGeneralization.BatchTwoMergingSharpLearning
import NeuralGeneralization.PowerPriorScaling

/-! Exact main theorems of the ReLU/GELU polynomial-depth manuscript.

All displayed constants are those of the paper, with r=L−2. The target-mass,
Gaussian bulk, actual support, finite comparison class and statistical steps
are proved for the concrete posterior, without learning or covering premises.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel

private theorem sharpReluEntropy_nonneg (d r:ℕ) (D ε:ℝ):0≤sharpReluEntropy d r D ε := by
  letI:Nonempty (SharpReluGridCode d r D ε):=⟨fun _=>⟨0,by simp⟩⟩
  exact (Real.log_nonneg (show (1:ℝ)≤Fintype.card (SharpReluGridCode d r D ε) by
    exact_mod_cast (Fintype.card_pos : 0<Fintype.card (SharpReluGridCode d r D ε)))).trans
      (sharpReluGrid_entropy d r D ε)
private theorem sharpGeluEntropy_nonneg (d r:ℕ) (D ε:ℝ):0≤sharpGeluEntropy d r D ε := by
  letI:Nonempty (SharpGeluGridCode d r D ε):=⟨fun _=>⟨0,by simp⟩⟩
  exact (Real.log_nonneg (show (1:ℝ)≤Fintype.card (SharpGeluGridCode d r D ε) by
    exact_mod_cast (Fintype.card_pos : 0<Fintype.card (SharpGeluGridCode d r D ε)))).trans
      (sharpGeluGrid_entropy d r D ε)

/-- Theorem 1, with its literal displayed sample budget, simultaneously over
all widths, mean-field-or-stronger scales, and both margin conventions. -/
theorem manuscript_relu_learning {d C r n:ℕ} (hd:0<d) (hC:0<C)
    (B:LayeredNorCircuit d C r) (D:Measure (Cube d)) [IsProbabilityMeasure D]
    {ε δ:ℝ} (hε:0<ε) (hε1:ε<1) (hδ:0<δ) (hδ1:δ<1)
    (hn:2/ε*(sharpReluEntropy d r (sharpReluTargetCost d C r) ε+Real.log (1/δ))≤(n:ℝ)):
    ∃A:Set (Fin n→Cube d),MeasurableSet A ∧
      1-δ≤(CompressionSampling.iidSamples D n).real A ∧
      ∀sample∈A,∀N,C≤N→∀σ,0<σ→(N:ℝ)*σ^2≤1→∀globalMargin:Bool,
        0<(smallPrior d N r σ).real (posteriorEvent relu globalMargin B.computes sample) ∧
        RobustConfidence.gibbsMarginRisk D
          (posterior (N:=N) (r:=r) relu globalMargin σ B.computes sample)
          (fun x=>labelReal (B.computes x)) (fun w x=>networkOutput relu w x) (1/4)≤ε := by
  have hlog:0<Real.log (1/δ) := Real.log_pos ((one_lt_div hδ).mpr hδ1)
  have he:=sharpReluEntropy_nonneg d r (sharpReluTargetCost d C r) ε
  have hp:0<2/ε*(sharpReluEntropy d r (sharpReluTargetCost d C r) ε+Real.log (1/δ)) := by positivity
  have hn0:0<n := by exact_mod_cast (hp.trans_le hn)
  apply sharp_relu_learning_of_target_mass hd hC B D (sharpReluTargetCost d C r)
    (sharpReluTargetCost_nonneg d r hC)
    (fun N hCN σ hσ hscale=>sharp_relu_target_mass_all_widths hd hC hCN B hσ hscale)
    hε hε1.le hδ n hn0
  have hh:=mul_le_mul_of_nonneg_right hn (show 0≤ε/2 by positivity)
  have hc:(2/ε*(sharpReluEntropy d r (sharpReluTargetCost d C r) ε+Real.log (1/δ)))*(ε/2)=
      sharpReluEntropy d r (sharpReluTargetCost d C r) ε+Real.log (1/δ) := by field_simp
  rwa [hc] at hh

/-- The GELU main theorem, including its counted factor-two compiler overhead. -/
theorem manuscript_gelu_learning {d C r n:ℕ} (hd:0<d) (hC:0<C)
    (B:LayeredNorCircuit d C r) (D:Measure (Cube d)) [IsProbabilityMeasure D]
    {ε δ:ℝ} (hε:0<ε) (hε1:ε<1) (hδ:0<δ) (hδ1:δ<1)
    (hn:2/ε*(sharpGeluEntropy d r (sharpGeluTargetCost d (2*C) r) ε+Real.log (1/δ))≤(n:ℝ)):
    ∃A:Set (Fin n→Cube d),MeasurableSet A ∧
      1-δ≤(CompressionSampling.iidSamples D n).real A ∧
      ∀sample∈A,∀N,2*C≤N→∀σ,0<σ→(N:ℝ)*σ^2≤1→∀globalMargin:Bool,
        0<(smallPrior d N r σ).real (posteriorEvent gelu globalMargin B.computes sample) ∧
        RobustConfidence.gibbsMarginRisk D
          (posterior (N:=N) (r:=r) gelu globalMargin σ B.computes sample)
          (fun x=>labelReal (B.computes x)) (fun w x=>networkOutput gelu w x) (1/4)≤ε := by
  have hlog:0<Real.log (1/δ) := Real.log_pos ((one_lt_div hδ).mpr hδ1)
  have he:=sharpGeluEntropy_nonneg d r (sharpGeluTargetCost d (2*C) r) ε
  have hp:0<2/ε*(sharpGeluEntropy d r (sharpGeluTargetCost d (2*C) r) ε+Real.log (1/δ)) := by positivity
  have hn0:0<n := by exact_mod_cast (hp.trans_le hn)
  apply sharp_gelu_learning_of_target_mass hd hC B D (sharpGeluTargetCost d (2*C) r)
    (sharpGeluTargetCost_nonneg d r (Nat.mul_pos (by omega) hC))
    (fun N hCN σ hσ hscale=>sharp_gelu_target_mass_all_widths hd hC hCN B hσ hscale)
    hε hε1.le hδ n hn0
  have hh:=mul_le_mul_of_nonneg_right hn (show 0≤ε/2 by positivity)
  have hc:(2/ε*(sharpGeluEntropy d r (sharpGeluTargetCost d (2*C) r) ε+Real.log (1/δ)))*(ε/2)=
      sharpGeluEntropy d r (sharpGeluTargetCost d (2*C) r) ε+Real.log (1/δ) := by field_simp
  rwa [hc] at hh

end NeuralGeneralization.BatchTwoMerging
