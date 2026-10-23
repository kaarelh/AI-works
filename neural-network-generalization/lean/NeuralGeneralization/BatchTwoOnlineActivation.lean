import NeuralGeneralization.BatchTwoOnlineMain
import NeuralGeneralization.BatchTwoActivationStrongPrior

/-! Strong-prior cumulative learning for actual zero-at-zero Lipschitz
activations, including ReLU. This uses the proved all-width energy capacity;
the sharper product-norm constants from the ReLU discussion are not asserted. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Topology
open Classical MeasureTheory ProbabilityTheory Filter
namespace NeuralGeneralization.BatchTwoOnline
open ConcreteModel BatchTwoActivation

theorem lipschitz_strongPrior_online_bounds {d C N r : ℕ} {φ : ℝ → ℝ} {ℓ : ℝ}
    (hd : 1 ≤ d) (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0 < ℓ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r := r) φ f C) (hCN : C ≤ N) :
    ∃ σ₀ : ℝ, 0 < σ₀ ∧ ∀ σ : ℝ, 0 < σ → σ < σ₀ →
      NetworkOnlineBounds φ (1/2) (smallPrior d N r σ) f
        (activationLogCapacity d r ℓ (BatchTwoActivation.strongEnergyBudget d r C)) := by
  have hN : 0 < N := lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN
  have hcontinuous := zeroLipschitzActivation_continuous hφ hℓ.le
  have hlim := network_highEnergy_tail_ratio_tendsto_zero (by omega) hN hcontinuous f
    (margin_witness_at_larger_width φ f hf hCN)
  let β : ℝ := 1/Fintype.card (Cube d)
  let P := activationLogCapacity d r ℓ (BatchTwoActivation.strongEnergyBudget d r C)
  have hP : 0 ≤ P := by
    dsimp [P, activationLogCapacity, capacityPolynomial]
    positivity
  have hβ : 0 < β := by dsimp [β]; positivity
  have he := hlim.eventually (gt_mem_nhds hβ)
  obtain ⟨σ₀,hσ₀,hsub⟩ := mem_nhdsGT_iff_exists_Ioo_subset.mp he
  refine ⟨σ₀,hσ₀,?_⟩
  intro σ hσ hσlt
  have hmass := small_functionMass_pos (by omega) hcontinuous f hf hCN hσ
  have htail := hsub ⟨hσ,hσlt⟩
  change (∑ g∈Finset.univ \ lowEnergyFunctions (N := N) (r := r) φ f,
      functionMass φ (1/2) (smallPrior d N r σ) g)/functionMass φ (1/2) (smallPrior d N r σ) f < β at htail
  have hcount : ((lowEnergyFunctions (N := N) (r := r) φ f).card : ℝ) ≤ Real.exp P := by
    have hc := Finset.card_le_card (lowEnergyFunctions_subset_energyFunctions φ f hf hCN)
    have hcR : ((lowEnergyFunctions (N := N) (r := r) φ f).card : ℝ) ≤
        (energyFunctions d r φ (BatchTwoActivation.strongEnergyBudget d r C)).card := by exact_mod_cast hc
    exact hcR.trans (energyFunctions_card_le_exp hφ hℓ (strongEnergyBudget_ge_one d r C) hd)
  have hb := bounds_of_relevant_class Fintype.card_pos _
    (functionMass_nonneg φ (1/2) _)
    (fun g i => g (cubeEnumeration d i)=f (cubeEnumeration d i)) f (fun _ => rfl) hmass
    (lowEnergyFunctions (N := N) (r := r) φ f) P β hP hβ.le hcount htail.le
  exact network_online_of_randomOrder hd φ (1/2) _ f P hP hmass hb

end NeuralGeneralization.BatchTwoOnline
