import NeuralGeneralization.NetworkEnergy
import NeuralGeneralization.NormCompression
import NeuralGeneralization.StrongPriorParameters

/-! # Polynomial capacity of the actual low-energy network class -/

noncomputable section

namespace NeuralGeneralization
open ConcreteModel CompressionSampling

/-- The actual low-energy class has concrete compressed representatives.
The witness is chosen above the energy infimum, with one unit of slack. -/
theorem lowEnergyFunctions_compressed {d C N r : ℕ}
    (hd : 1 ≤ d) {φ : ℝ → ℝ} (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hc : realizesAtComplexity (r := r) φ f C)
    (hCN : C ≤ N) :
    ∀ g ∈ lowEnergyFunctions (N := N) (r := r) φ f,
      ∃ w : Weights d (strongCompressionWidth d r C) r,
        w ∈ marginEvent φ (1 / 2) g ∧ boundedWeights (strongCompressionWidth d r C) w := by
  intro g hg
  obtain ⟨hne, henergy⟩ := (mem_lowEnergyFunctions φ f g).mp hg
  have htarget := networkEnergy_le_complexity_polynomial φ f hc hCN
  have hbound := henergy.trans htarget
  have hinf : sInf (weightedSquaredNorm '' marginEvent (N := N) (r := r) φ (1 / 2) g) <
      (strongEnergyBudget d r C : ℝ) := by
    unfold networkEnergy at hbound
    unfold strongEnergyBudget
    push_cast
    linarith
  obtain ⟨q, ⟨w, hw, rfl⟩, hq⟩ :=
    exists_lt_of_csInf_lt (hne.image weightedSquaredNorm) hinf
  have hN : 0 < N := lt_of_lt_of_le (Nat.succ_le_iff.mp hc.1) hCN
  have hK : 1 ≤ strongEnergyBudget d r C := by unfold strongEnergyBudget; omega
  obtain ⟨v, hv, hbound, _⟩ := norm_compression hd hN hK φ hφ g w hq.le hw
  exact ⟨v, hv, hbound⟩


/-- The low-energy class itself has polynomial logarithmic cardinality,
independently of the source network width. -/
theorem lowEnergyFunctions_card_le_exp {d C N r : ℕ}
    (hd : 1 ≤ d) {φ : ℝ → ℝ} (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hc : realizesAtComplexity (r := r) φ f C)
    (hCN : C ≤ N) :
    ((lowEnergyFunctions (N := N) (r := r) φ f).card : ℝ) ≤
      Real.exp (strongCapacity d r C : ℝ) := by
  exact representedClass_card_le_exp (lowEnergyFunctions (N := N) (r := r) φ f)
    (strongCompressionWidth d r C) r (strongCompressionWidth d r C) φ hφ
    (lowEnergyFunctions_compressed hd hφ f hc hCN)


end NeuralGeneralization
