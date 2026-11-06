import NeuralGeneralization.BatchTwoNeuralConverseOperatorClosure
import NeuralGeneralization.BatchTwoNeuralConverseConstant

/-! The exact singleton and constant witnesses satisfy strict spectral support. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open Classical ConcreteModel

theorem singleton_internal_frobenius_lt {d r : ℕ} (a : Cube d) (b : Fin (d+1) → ℝ)
    (t : ℝ) (hb : vectorL1 b ≤ 4) (s : Fin r) :
    (∑ i, ∑ j, (singletonWeights a b r t (Sum.inr (Sum.inl (s,i,j))))^2) < 1 := by
  have hN : (allocationWidth b : ℝ) ≠ 0 := by exact_mod_cast (allocationWidth_pos b).ne'
  by_cases hs : s.val=0
  · simp only [singletonWeights, hs, ↓reduceIte, Finset.sum_const,
      Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    have he : (∑ j : Fin (allocationWidth b),
        (b (allocationLabel b j)/(8*(featureCopies b (allocationLabel b j) : ℝ)))^2) =
        (∑ i : Fin (d+1), (b i)^2/(featureCopies b i : ℝ))/64 := by
      rw [← allocated_square_identity b, Finset.sum_div]
      apply Finset.sum_congr rfl
      intro j _
      ring
    rw [he]
    have h := allocated_energy_le_seventeen b hb
    linarith
  · simp only [singletonWeights, hs, ↓reduceIte, Finset.sum_const,
      Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    have he : (allocationWidth b : ℝ)*((allocationWidth b : ℝ)*
        (relayFactor (r+1)/(allocationWidth b : ℝ))^2) = (relayFactor (r+1))^2 := by
      field_simp
    rw [he]
    have h := relayFactor_bounds (Nat.succ_pos r)
    nlinarith


lemma operatorContractive_of_frobenius_lt {d N r : ℕ} (w : Weights d N r)
    (hW : ∀ s : Fin r, (∑ i, ∑ j, w (Sum.inr (Sum.inl (s,i,j)))^2) < 1) :
    operatorContractive w := by
  intro s
  have hh := matrixOperator_norm_sq_le_frobenius
    (fun ij : Fin N × Fin N => w (Sum.inr (Sum.inl (s,ij.1,ij.2))))
  have hs := hW s
  change ‖internalOperator w s‖^2 ≤ _ at hh
  nlinarith [norm_nonneg (internalOperator w s)]

theorem singleton_operatorContractive {d r : ℕ} (a : Cube d) (b : Fin (d+1) → ℝ)
    (t : ℝ) (hb : vectorL1 b ≤ 4) : operatorContractive (singletonWeights a b r t) :=
  operatorContractive_of_frobenius_lt _ (singleton_internal_frobenius_lt a b t hb)

/-- Exact same-depth singleton, with the original energy budget and genuinely
strict operator norms. There is no assumed spectral certificate. -/
theorem exists_singleton_operator_network {d : ℕ} (hd : 0 < d) (a : Cube d) (r : ℕ) (t : ℝ) :
    ∃ N : ℕ, 0 < N ∧ ∃ w : Weights d N r,
      (∀ x, networkOutput Real.tanh w x = if x=a then t else 0) ∧
      weightedSquaredNorm w ≤ singletonBaseBudget d (r+1)+singletonReadoutBudget (r+1)*t^2 ∧
      operatorContractive w := by
  obtain ⟨b,hb,hinterp⟩ := exists_exact_shell_indicator d hd
  have hi (x : Cube d) : (∑ j, b j*shellFeature (shellIndex a x) j) = if x=a then 1 else 0 := by
    rw [hinterp]
    simp only [shellIndex_eq_zero]
  exact ⟨allocationWidth b,allocationWidth_pos b,singletonWeights a b r t,
    singleton_output a b r t hi,singleton_energy_bound a b r t hb,
    singleton_operatorContractive a b t hb⟩

lemma constant_internal_frobenius_lt (d r : ℕ) (y : ℝ) (s : Fin r) :
    (∑ i, ∑ j, (constantWeights d r y (Sum.inr (Sum.inl (s,i,j))))^2) < 1 := by
  simp only [constantWeights,Finset.univ_unique,Fin.default_eq_zero,Finset.sum_singleton]
  have h := relayFactor_bounds (Nat.succ_pos r)
  nlinarith

theorem constant_operatorContractive (d r : ℕ) (y : ℝ) :
    operatorContractive (constantWeights d r y) :=
  operatorContractive_of_frobenius_lt _ (constant_internal_frobenius_lt d r y)

theorem constant_mem_operatorFunctionSupport (d r : ℕ) (y : Bool) {U : ℝ} (hU : 1 < U) :
    constantWeights d r (labelReal y) ∈ operatorFunctionSupport U (fun _ => y) := by
  refine ⟨⟨?_,constant_operatorContractive d r (labelReal y)⟩,?_⟩
  · intro x
    rw [constant_output]
    cases y <;> norm_num [labelReal] <;> exact hU
  · intro x
    rw [constant_output]
    cases y <;> norm_num [labelReal]

end
end NeuralGeneralization.BatchTwoNeuralConverse
