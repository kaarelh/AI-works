import NeuralGeneralization.BatchTwoImprovedNoisyAllWidths
import NeuralGeneralization.BatchTwoImprovedResourceGrowth
import NeuralGeneralization.BatchTwoImprovedGridBudget

/-! A universal polynomial bound for the finite pre-stability output class. -/
noncomputable section
open MeasureTheory
namespace NeuralGeneralization.BatchTwoImprovedInduction
open ConcreteModel BatchTwoImprovedResources

/-- The same finite class works for every admissible activation, learner width,
and Gaussian scale. Its logarithmic size is polynomial in all five resources. -/
theorem noisy_grid_entropy_polynomial :
    ∃ A : ℝ, 0 < A ∧ ∀ p : RobustCompressionInput,
      Real.log (Fintype.card (RobustOutputCode p.dimension (widthBound p) (p.depth-2)
        (weightBound p) (8*(p.inverseRadius+1))) : ℝ) ≤ A*((p.size:ℝ)+1)^45 := by
  obtain ⟨a, ha, hwidth⟩ := widthBound_global_growth (by norm_num : (0:ℝ)<1)
    (by norm_num : (0:ℝ)<1) (by norm_num : (0:ℝ)<1)
  obtain ⟨b, hb, hweight⟩ := weightBound_global_growth (by norm_num : (0:ℝ)<1)
    (by norm_num : (0:ℝ)<1) (by norm_num : (0:ℝ)<1)
  let a' := max 1 a
  let b' := max 1 b
  let A := improvedGridBudgetCoefficient a' b' 16
  have hA : 0 < A := by
    dsimp [A, improvedGridBudgetCoefficient, a', b']
    positivity
  refine ⟨A, hA, ?_⟩
  intro p
  let S : ℝ := (p.size:ℝ)+1
  have hp1 : 1 ≤ p.size := by unfold RobustCompressionInput.size; omega
  have hS : 2 ≤ S := by dsimp [S]; exact_mod_cast (show 2 ≤ p.size+1 by omega)
  have hd : (p.dimension:ℝ) ≤ S := by
    dsimp [S]
    exact_mod_cast (show p.dimension ≤ p.size+1 by unfold RobustCompressionInput.size; omega)
  have hl : (p.depth:ℝ) ≤ S := by
    dsimp [S]
    exact_mod_cast (show p.depth ≤ p.size+1 by unfold RobustCompressionInput.size; omega)
  have hk : (p.energy:ℝ) ≤ S := by
    dsimp [S]
    exact_mod_cast (show p.energy ≤ p.size+1 by unfold RobustCompressionInput.size; omega)
  have hr : (p.inverseRadius:ℝ) ≤ S := by
    dsimp [S]
    exact_mod_cast (show p.inverseRadius ≤ p.size+1 by unfold RobustCompressionInput.size; omega)
  have hf : (p.inverseFailure:ℝ) ≤ S := by
    dsimp [S]
    exact_mod_cast (show p.inverseFailure ≤ p.size+1 by unfold RobustCompressionInput.size; omega)
  have hS3 : S ≤ S^3 := by simpa using pow_le_pow_right₀ (by linarith : 1 ≤ S) (by omega : 1 ≤ 3)
  have hp : ResourceHypotheses 1 1 1 p S :=
    ⟨hS, hd, hl, by simpa using hk.trans hS3, by simpa using hr.trans hS3, by simpa using hf⟩
  have hW : (widthBound p:ℝ) ≤ a'*S^21 :=
    (hwidth p S hp).trans (mul_le_mul_of_nonneg_right (le_max_right 1 a) (by positivity))
  have hB : (weightBound p:ℝ) ≤ b'*S^24 :=
    (hweight p S hp).trans (mul_le_mul_of_nonneg_right (le_max_right 1 b) (by positivity))
  have hR : (8*(p.inverseRadius+1):ℕ) ≤ (16:ℝ)*S^3 := by
    push_cast
    nlinarith
  have hdepth : ((p.depth-2:ℕ):ℝ) ≤ S :=
    (Nat.cast_le.mpr (Nat.sub_le p.depth 2)).trans hl
  have he := improvedGridEntropy_resource_budget (le_max_left 1 a) (le_max_left 1 b)
    (by norm_num : (1:ℝ)≤16) (by linarith : 1 ≤ S) hd hdepth hW hB hR
    (weightBound_pos p) (by omega : 0 < 8*(p.inverseRadius+1))
  have hlog : 1+Real.log S ≤ S := by
    linarith [Real.log_le_sub_one_of_pos (by linarith : 0 < S)]
  have hc := robustOutputCode_log_card_sharp p.dimension (widthBound p) (p.depth-2)
    (weightBound_pos p) (by omega : 0 < 8*(p.inverseRadius+1))
  apply hc.trans (he.trans ?_)
  change A*S^44*(1+Real.log S) ≤ A*S^45
  calc
    _ ≤ A*S^44*S := mul_le_mul_of_nonneg_left hlog (by positivity)
    _ = _ := by ring

end NeuralGeneralization.BatchTwoImprovedInduction
