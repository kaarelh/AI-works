import NeuralGeneralization.RobustCompressionInductionResourceInitial

/-! # Entropy, bounded support, and abort invariant of the canonical law -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustEntropy

def ResourceInvariant (p : RobustCompressionInput) {N : ℕ} (σ : ℝ) (s k : ℕ)
    (Γ : CanonicalStateLaw p.dimension N p.bankSize s k) : Prop :=
  futureEntropy Γ.law (futurePrior N k) ≤ ENNReal.ofReal ((p.energy : ℝ)/σ^2)+
    s • ENNReal.ofReal (Real.log (Fintype.card
      (QueryMessage (Fin (Fintype.card (Cube p.dimension))) p.activeRank))) ∧
  (∀ᵐ z ∂Γ.law,activePrefixBounded (p.largeWeightBound : ℝ) z.1) ∧
  Γ.law.real {z | z.1.1≠true} ≤ 2*(s : ℝ)/(p.inverseLayerFailure : ℝ)

theorem initial_resourceInvariant (p : RobustCompressionInput) {N r : ℕ}
    (hd : 0<p.dimension) (hN : 0<N) {σ : ℝ} (hσ : 0<σ)
    (Q : Measure (Weights p.dimension N r)) [IsProbabilityMeasure Q]
    (hQ : InformationTheory.klDiv Q (smallPrior p.dimension N r σ) ≤
      ENNReal.ofReal ((p.energy : ℝ)/σ^2)) :
    ResourceInvariant p σ 0 r
      (initialCanonicalLaw p.bankSize σ (Real.sqrt p.firstSquaredBound) Q) := by
  constructor
  · simpa only [zero_nsmul,add_zero,initialCanonicalLaw] using
      (initialLaw_futureEntropy_le hd hN hσ (Real.sqrt p.firstSquaredBound) Q).trans hQ
  constructor
  · exact initialCanonicalLaw_bounded hd σ _ _ (Real.sqrt_nonneg _)
      p.first_le_largeWeightBound Q
  · simp only [Measure.real,initialCanonicalLaw_abort,ENNReal.toReal_zero,
      Nat.cast_zero,mul_zero,zero_div,le_refl]

theorem ResourceInvariant.entropy_cap (p : RobustCompressionInput) {N s k : ℕ}
    {σ : ℝ} (hσ : 0<σ) (hscale : (N : ℝ)*σ^2≤1)
    (hN : p.widthBound≤N) (hK : 0<p.energy) (hs : s≤p.depth)
    (Γ : CanonicalStateLaw p.dimension N p.bankSize s k)
    (h : ResourceInvariant p σ s k Γ) :
    futureEntropy Γ.law (futurePrior N k) ≤
      ENNReal.ofReal (2*(N : ℝ)*p.energy/(σ*Real.sqrt (N : ℝ))^2) := by
  have hn : 0<N := lt_of_lt_of_le p.widthBound_pos hN
  have ht : 0<σ*Real.sqrt (N : ℝ) := by positivity
  have ht1 : (σ*Real.sqrt (N : ℝ))^2≤1 := by
    rw [physicalScale_sq]
    nlinarith [hscale]
  have hb := p.initial_and_messages_budget
    (Fin (Fintype.card (Cube p.dimension))) (by simp [Cube]) hN hK hs ht ht1
  rw [normalized_entropy_scale hn hσ] at hb
  exact h.1.trans hb

end NeuralGeneralization.RobustCompressionInduction
