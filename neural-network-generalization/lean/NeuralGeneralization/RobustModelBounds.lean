import NeuralGeneralization.RobustModel

/-! # Consequences of the simultaneous noise budget -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ConcreteModel
variable {N r : ℕ}

theorem noiseBudgetSq_hidden (hN : 0 < N) (η : NetworkDisturbance N r)
    {τ : ℝ} (hη : noiseBudgetSq η ≤ τ^2) (s : Fin (r+1)) :
    (∑ i, (η.1 s i)^2) ≤ (N:ℝ)*τ^2 := by
  have hNR : (0:ℝ)<N := Nat.cast_pos.mpr hN
  have hall : (∑ t, ∑ i, (η.1 t i)^2) ≤ (N:ℝ)*τ^2 := by
    have hout := sq_nonneg η.2
    unfold noiseBudgetSq at hη
    have hh : (∑ t, ∑ i, (η.1 t i)^2)/(N:ℝ) ≤ τ^2 := by linarith
    have hh' := (div_le_iff₀ hNR).mp hh
    nlinarith
  apply (Finset.single_le_sum (fun t _ => Finset.sum_nonneg fun i _ => sq_nonneg _)
    (Finset.mem_univ s)).trans hall

theorem noiseBudgetSq_output (η : NetworkDisturbance N r)
    {τ : ℝ} (hτ : 0 ≤ τ) (hη : noiseBudgetSq η ≤ τ^2) : |η.2| ≤ τ := by
  have hs : 0 ≤ (∑ t, ∑ i, (η.1 t i)^2)/(N:ℝ) := by positivity
  unfold noiseBudgetSq at hη
  apply (sq_le_sq₀ (abs_nonneg _) hτ).mp
  rw [sq_abs]
  linarith

end NeuralGeneralization.ConcreteModel
