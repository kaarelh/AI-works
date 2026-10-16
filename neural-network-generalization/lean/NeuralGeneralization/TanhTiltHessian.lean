import NeuralGeneralization.ExponentialHessian

/-! Actual tanh tilt derivatives, with bounds preserving the pointwise exponential weight. -/
noncomputable section
namespace NeuralGeneralization.TanhDifferential
open scoped BigOperators
variable {I : Type*} [Fintype I] [DecidableEq I]

theorem tanh_expGradient_bound (Γ : I → I → ℝ) {g : ℝ}
    (hΓ : couplingMass Γ ≤ g) (z : I → ℝ) (i : I) :
    |expGradient (potentialValue Real.tanh Γ)
      (potentialGradient Real.tanh tanhFirst Γ) z i| ≤ Real.exp g * (2 * g) := by
  obtain ⟨hV, hV₁, hV₂⟩ := tanhPotential_bounds Γ g hΓ z
  have hg : 0 ≤ g := (abs_nonneg _).trans hV
  calc
    _ ≤ ∑ j, |expGradient (potentialValue Real.tanh Γ)
        (potentialGradient Real.tanh tanhFirst Γ) z j| :=
      Finset.single_le_sum (fun j hj => abs_nonneg _) (Finset.mem_univ i)
    _ = Real.exp (potentialValue Real.tanh Γ z) *
        ∑ j, |potentialGradient Real.tanh tanhFirst Γ z j| := expGradient_l1_eq _ _ _
    _ ≤ Real.exp g * (2 * g) := mul_le_mul
      (Real.exp_le_exp.mpr ((le_abs_self _).trans hV)) hV₁
      (Finset.sum_nonneg (fun _ _ => abs_nonneg _)) (Real.exp_pos _).le

theorem tanh_expHessian_l1_bound (Γ : I → I → ℝ) {g : ℝ}
    (hΓ : couplingMass Γ ≤ g) (z : I → ℝ) :
    (∑ i, ∑ j, |expHessian (potentialValue Real.tanh Γ)
      (potentialGradient Real.tanh tanhFirst Γ)
      (potentialHessian Real.tanh tanhFirst tanhSecond Γ) z i j|) ≤
        Real.exp (potentialValue Real.tanh Γ z) * (6 * g + 4 * g ^ 2) := by
  obtain ⟨hV, hV₁, hV₂⟩ := tanhPotential_bounds Γ g hΓ z
  have hg : 0 ≤ g := (abs_nonneg _).trans hV
  apply (expHessian_l1_le _ _ _ z).trans
  apply mul_le_mul_of_nonneg_left _ (Real.exp_pos _).le
  have hs : 0 ≤ ∑ i, |potentialGradient Real.tanh tanhFirst Γ z i| :=
    Finset.sum_nonneg (fun _ _ => abs_nonneg _)
  have hsq := mul_le_mul hV₁ hV₁ hs (by positivity : 0 ≤ 2 * g)
  nlinarith

theorem tanh_weightedGradient_bound (p q : I) (Γ : I → I → ℝ) {g : ℝ}
    (hΓ : couplingMass Γ ≤ g) (z : I → ℝ) (i : I) :
    |weightedGradient (pairValue Real.tanh p q) (pairGradient Real.tanh tanhFirst p q)
      (potentialValue Real.tanh Γ) (potentialGradient Real.tanh tanhFirst Γ) z i| ≤
        Real.exp g * (2 + 2 * g) := by
  obtain ⟨hF, hF₁, hF₂⟩ := tanhPair_bounds p q z
  obtain ⟨hV, hV₁, hV₂⟩ := tanhPotential_bounds Γ g hΓ z
  have hg : 0 ≤ g := (abs_nonneg _).trans hV
  have hprod := mul_le_mul hF hV₁
    (Finset.sum_nonneg (fun _ _ => abs_nonneg _)) (by norm_num : (0 : ℝ) ≤ 1)
  calc
    _ ≤ ∑ j, |weightedGradient (pairValue Real.tanh p q)
        (pairGradient Real.tanh tanhFirst p q) (potentialValue Real.tanh Γ)
        (potentialGradient Real.tanh tanhFirst Γ) z j| :=
      Finset.single_le_sum (fun j hj => abs_nonneg _) (Finset.mem_univ i)
    _ ≤ _ := weightedGradient_l1_le _ _ _ _ z
    _ ≤ Real.exp g * (2 + 2 * g) := by
      apply mul_le_mul (Real.exp_le_exp.mpr ((le_abs_self _).trans hV))
        (by nlinarith) _ (Real.exp_pos _).le
      positivity

set_option maxHeartbeats 800000 in
theorem tanh_weightedHessian_l1_bound (p q : I) (Γ : I → I → ℝ) {g : ℝ}
    (hΓ : couplingMass Γ ≤ g) (z : I → ℝ) :
    (∑ i, ∑ j, |weightedHessian (pairValue Real.tanh p q)
      (pairGradient Real.tanh tanhFirst p q) (pairHessian Real.tanh tanhFirst tanhSecond p q)
      (potentialValue Real.tanh Γ) (potentialGradient Real.tanh tanhFirst Γ)
      (potentialHessian Real.tanh tanhFirst tanhSecond Γ) z i j|) ≤
        Real.exp (potentialValue Real.tanh Γ z) * (6 + 14 * g + 4 * g ^ 2) := by
  obtain ⟨hF, hF₁, hF₂⟩ := tanhPair_bounds p q z
  obtain ⟨hV, hV₁, hV₂⟩ := tanhPotential_bounds Γ g hΓ z
  have hg : 0 ≤ g := (abs_nonneg _).trans hV
  have hs : 0 ≤ ∑ i, |potentialGradient Real.tanh tanhFirst Γ z i| :=
    Finset.sum_nonneg (fun _ _ => abs_nonneg _)
  have hsq := mul_le_mul hV₁ hV₁ hs (by positivity : 0 ≤ 2 * g)
  have hcross := mul_le_mul hF₁ hV₁ hs (by norm_num : (0 : ℝ) ≤ 2)
  have hinner : (∑ i, ∑ j, |potentialHessian Real.tanh tanhFirst tanhSecond Γ z i j|) +
      (∑ i, |potentialGradient Real.tanh tanhFirst Γ z i|) ^ 2 ≤ 6 * g + 4 * g ^ 2 := by
    nlinarith
  have hprod := mul_le_mul hF hinner (by positivity) (by norm_num : (0 : ℝ) ≤ 1)
  apply (weightedHessian_l1_le _ _ _ _ _ _ z).trans
  apply mul_le_mul_of_nonneg_left _ (Real.exp_pos _).le
  nlinarith

@[fun_prop] theorem continuous_tanh_expHessian (Γ : I → I → ℝ) (i j : I) :
    Continuous (fun z => expHessian (potentialValue Real.tanh Γ)
      (potentialGradient Real.tanh tanhFirst Γ)
      (potentialHessian Real.tanh tanhFirst tanhSecond Γ) z i j) := by
  apply continuous_expHessian <;> fun_prop

@[fun_prop] theorem continuous_tanh_weightedHessian (p q : I) (Γ : I → I → ℝ) (i j : I) :
    Continuous (fun z => weightedHessian (pairValue Real.tanh p q)
      (pairGradient Real.tanh tanhFirst p q) (pairHessian Real.tanh tanhFirst tanhSecond p q)
      (potentialValue Real.tanh Γ) (potentialGradient Real.tanh tanhFirst Γ)
      (potentialHessian Real.tanh tanhFirst tanhSecond Γ) z i j) := by
  apply continuous_weightedHessian <;> fun_prop

end NeuralGeneralization.TanhDifferential
