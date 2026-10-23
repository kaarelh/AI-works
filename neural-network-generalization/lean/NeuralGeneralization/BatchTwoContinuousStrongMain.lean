import NeuralGeneralization.BatchTwoContinuousStrongBudget

/-! The literal strong-prior main theorem from the continuous-domain paper. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel

theorem strongPriorRegression : StrongPriorRegression := by
  intro r ν
  obtain ⟨k,hk⟩ := exists_nat_gt (ν.upperCurvature/ν.lowerCurvature)
  have hcurv : ν.upperCurvature ≤ ν.lowerCurvature*(k : ℝ) := by
    have h := (div_lt_iff₀ ν.lowerCurvature_pos).mp hk
    linarith
  obtain ⟨A,hA,m,hpoly⟩ := strongRegression_polynomial r k
  refine ⟨A,hA,m,?_⟩
  intro d C hd hC B hB w hw X hX N hCN ρ τ ε hρ hρτ hε _hε1
  let K := strongRegressionEnergy k d C r B
  let R := regressionAccuracyWidth (inverseGap ρ τ)
  have hK : 1 ≤ K := strongRegressionEnergy_pos _ _ _ _ _
  have hR : 1 ≤ R := regressionAccuracyWidth_pos _
  have hgap := regressionAccuracyWidth_gap hρτ
  have hKgap := strongRegressionEnergy_gap ν (d := d) (C := C) (r := r) hcurv (by linarith : 0 ≤ B)
  obtain ⟨σ₀,hσ₀,hlearn⟩ := strong_regression_explicit ν hd hC hCN hK hR w (by linarith : 0 ≤ B)
    hw X hX.1 hX.2.1 hX.2.2 hρ hε hgap hKgap
  refine ⟨σ₀,hσ₀,?_⟩
  intro σ hσ hσlt D hD hDX δ hδ _hδ1 n hsize
  apply hlearn σ hσ hσlt D hD hDX δ hδ n
  apply le_trans _ hsize
  exact mul_le_mul_of_nonneg_left
    (add_le_add (hpoly d C B (inverseGap ρ τ) hB (inverseGap_ge_one hρτ)) le_rfl) (by positivity)

#print axioms strongPriorRegression

end NeuralGeneralization.BatchTwoContinuous
