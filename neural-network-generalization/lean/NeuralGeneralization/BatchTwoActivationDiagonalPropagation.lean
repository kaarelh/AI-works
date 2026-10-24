import NeuralGeneralization.BatchTwoActivationBooleanBudgets

/-! Polynomial diagonal envelopes are propagated by the actual Gaussian
projection-good event, so later conditional tails use validated budgets. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel FiniteDifferential

theorem activationDiagonal_step_le {b d K s : ℕ} (hb : 1≤b) (hK : 1≤K)
    {ℓ : ℝ} (hℓ0 : 0≤ℓ) (hℓ : ℓ≤b) :
    let M := (activationDiagonalBudget b d K s:ℝ)
    2*ℓ^2*(gaussianBulkThreshold (Cube d) M)^2+
      2*ℓ^2*M*(8*(4*(K:ℝ)+Real.log 3))≤activationDiagonalBudget b d K (s+1) := by
  let M := (activationDiagonalBudget b d K s:ℝ)
  have hM : 0≤M := Nat.cast_nonneg _
  have hbR : (0:ℝ)≤b := Nat.cast_nonneg _
  have hdR : (0:ℝ)≤d := Nat.cast_nonneg _
  have hKR : (1:ℝ)≤K := by exact_mod_cast hK
  have hℓ2 := pow_le_pow_left₀ hℓ0 hℓ 2
  have hA0 : 0≤8*(4*(K:ℝ)+Real.log 3) := by positivity
  have hA : 8*(4*(K:ℝ)+Real.log 3)≤56*(K:ℝ) := by
    have hlog : Real.log 3≤2 := by linarith [Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<3)]
    linarith
  have hlog0 : 0≤Real.log (4*((Fintype.card (Cube d):ℝ)+1)) := Real.log_nonneg (by
    have := Nat.cast_nonneg (Fintype.card (Cube d)) (α:=ℝ)
    linarith)
  have hsq : (gaussianBulkThreshold (Cube d) M)^2=
      2*M*Real.log (4*((Fintype.card (Cube d):ℝ)+1)) := Real.sq_sqrt (by positivity)
  have hs : (gaussianBulkThreshold (Cube d) M)^2≤2*M*((d:ℝ)+4) := by
    rw [hsq]
    exact mul_le_mul_of_nonneg_left (cube_log_bulk d) (by positivity)
  have ht1 : 2*ℓ^2*(gaussianBulkThreshold (Cube d) M)^2≤2*(b:ℝ)^2*(2*M*((d:ℝ)+4)) := by
    exact mul_le_mul (mul_le_mul_of_nonneg_left hℓ2 (by norm_num)) hs (sq_nonneg _) (by positivity)
  have ht2 : 2*ℓ^2*M*(8*(4*(K:ℝ)+Real.log 3))≤2*(b:ℝ)^2*M*(56*(K:ℝ)) := by
    exact mul_le_mul (mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left hℓ2 (by norm_num)) hM)
      hA hA0 (by positivity)
  have hcoef : 4*((d:ℝ)+4)+112*(K:ℝ)≤128*((d:ℝ)+(K:ℝ)+4) := by linarith
  have hm := mul_le_mul_of_nonneg_left hcoef (show 0≤(b:ℝ)^2*M by positivity)
  have hnext : (activationDiagonalBudget b d K (s+1):ℝ)=
      M*(128*(b:ℝ)^2*((d:ℝ)+(K:ℝ)+4)) := by
    dsimp [M,activationDiagonalBudget]
    push_cast
    rw [pow_succ]
    ring
  change 2*ℓ^2*(gaussianBulkThreshold (Cube d) M)^2+
    2*ℓ^2*M*(8*(4*(K:ℝ)+Real.log 3))≤_
  rw [hnext]
  nlinarith

theorem polynomial_good_layer_diagonal {b d K s N n : ℕ} (hb : 1≤b) (hK : 1≤K)
    (c : Cube d → Fin n → ℝ) (x : Fin N → Fin n → ℝ) (k : ℕ)
    {φ : ℝ → ℝ} {ℓ : ℝ} (hφ : zeroLipschitzActivation ℓ φ)
    (hℓ0 : 0≤ℓ) (hℓ : ℓ≤b) (hN : 0<N)
    (hvar : ∀i,(∑j,(c i j)^2)≤(activationDiagonalBudget b d K s:ℝ))
    (hgood : x∉polynomialLayerBad c φ k N (activationDiagonalBudget b d K s) (4*(K:ℝ)))
    (i : Cube d) :
    (∑j,(φ (fieldLinear c (x j) i))^2)/(N:ℝ)≤activationDiagonalBudget b d K (s+1) := by
  have hM : (0:ℝ)<activationDiagonalBudget b d K s := Nat.cast_pos.mpr (activationDiagonalBudget_pos hb)
  have henergy : ∑j,‖gaussianResidualSource c (activationDiagonalBudget b d K s) (x j)‖^2≤
      (N:ℝ)*(8*(4*(K:ℝ)+Real.log 3)) := by
    have hn : x∉residualBadRows c N (activationDiagonalBudget b d K s) (4*(K:ℝ)) :=
      fun hx => hgood (Or.inl hx)
    have ht : ∑j,‖gaussianResidualSource c (activationDiagonalBudget b d K s) (x j)‖^2<
        8*(N:ℝ)*(4*(K:ℝ)+Real.log 3) := lt_of_not_ge hn
    nlinarith
  exact (gaussian_layer_diagonal c x hφ hℓ0 hM hvar hN henergy i).trans
    (activationDiagonal_step_le hb hK hℓ0 hℓ)

end NeuralGeneralization.BatchTwoActivation
