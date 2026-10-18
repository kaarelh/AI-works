import NeuralGeneralization.RobustCompressionInductionSelectedRunBounds
import NeuralGeneralization.RobustCompressionEntropyBudget
import NeuralGeneralization.RobustCompressionInductionInitialHistory

/-! # Actual selected canonical run from the original Gaussian posterior

The only entropy hypothesis here concerns the original law and the literal
Gaussian prior. Each selected conditional law is constructed by the preceding
canonical transition, with its finite message paid by the explicit width cutoff.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustEntropy

/-- Bundle the literal first-clipped-state pushforward as a probability law. -/
def initialCanonicalLaw {d N r : ℕ} (m : ℕ) (σ B : ℝ)
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q] :
    CanonicalStateLaw d N m 0 r :=
  ⟨initialLaw m σ B Q,inferInstance⟩

theorem physicalScale_sq {N : ℕ} (σ : ℝ) :
    (σ*Real.sqrt (N : ℝ))^2=σ^2*N := by
  rw [mul_pow,Real.sq_sqrt (Nat.cast_nonneg N)]

theorem normalized_entropy_scale {N : ℕ} (hN : 0<N) {σ : ℝ} (hσ : 0<σ) (K : ℝ) :
    (N : ℝ)*K/(σ*Real.sqrt (N : ℝ))^2=K/σ^2 := by
  rw [physicalScale_sq]
  have hn : (N : ℝ) ≠ 0 := by positivity
  field_simp

/-- A genuine complete run, with actual per-stage selections, exists at every
width beyond the explicit polynomial resource cutoff. -/
theorem exists_resource_selectedRun (p : RobustCompressionInput) {N r : ℕ}
    [NeZero N]
    [hFin : MeasurableSpace (Finset (Fin (Fintype.card (Cube p.dimension))))]
    [hFinS : MeasurableSingletonClass (Finset (Fin (Fintype.card (Cube p.dimension))))]
    [hMsg : MeasurableSpace (QueryMessage (Fin (Fintype.card (Cube p.dimension))) p.activeRank)]
    [hMsgS : MeasurableSingletonClass (QueryMessage (Fin (Fintype.card (Cube p.dimension))) p.activeRank)]
    [hMsgB : StandardBorelSpace (QueryMessage (Fin (Fintype.card (Cube p.dimension))) p.activeRank)]
    (hd : 0 < p.dimension) (hdepth : r+2 ≤ p.depth)
    (hK : 0 < p.energy) (hA : 0 < p.inverseFailure) (hR : 0 < p.inverseRadius)
    (hN : p.widthBound ≤ N) {σ : ℝ} (hσ : 0 < σ) (hscale : (N : ℝ)*σ^2 ≤ 1)
    {φ : ℝ → ℝ} (hφ : Continuous φ)
    (Q : Measure (Weights p.dimension N r)) [IsProbabilityMeasure Q]
    (hQ : InformationTheory.klDiv Q (smallPrior p.dimension N r σ) ≤
      ENNReal.ofReal ((p.energy : ℝ)/σ^2)) :
    Nonempty (SelectedRun (q:=p.activeRank) hφ
      ((p.inverseKernelPrecision : ℝ)⁻¹) (σ*Real.sqrt (N : ℝ))
      p.sourceClip (Real.sqrt p.activeSquaredBound) (Real.sqrt p.gaussianSquaredBound)
      ((p.inverseSelectionError : ℝ)⁻¹) ((p.inverseLayerFailure : ℝ)⁻¹)
      0 r (initialCanonicalLaw p.bankSize σ (Real.sqrt p.firstSquaredBound) Q)) := by
  have hn : 0<N := lt_of_lt_of_le p.widthBound_pos hN
  have hL : 0<p.depth := by omega
  have he := p.inverseLayerError_pos hL hA hR
  have hh := p.inverseLayerFailure_pos hL hA
  have hdelta : 0<p.inverseSelectionError := by
    unfold RobustCompressionInput.inverseSelectionError
    positivity
  have hq : 0<p.activeRank := by
    unfold RobustCompressionInput.activeRank
    omega
  have ht : 0<σ*Real.sqrt (N : ℝ) := by positivity
  have ht1 : (σ*Real.sqrt (N : ℝ))^2≤1 := by
    rw [physicalScale_sq]
    nlinarith [hscale]
  apply exists_selectedRun hφ _ _ _ _ _ _ _ (p.energy : ℝ) hq hn ht
    (by positivity) (by positivity) (p.active_rank_constructor_budget hh hdelta)
    (ENNReal.ofReal ((p.energy : ℝ)/σ^2)) 0 r
  · simpa only [zero_nsmul,add_zero,initialCanonicalLaw] using
      (initialLaw_futureEntropy_le hd hn hσ (Real.sqrt p.firstSquaredBound) Q).trans hQ
  · intro j hj
    have hz := p.initial_and_messages_budget
      (Fin (Fintype.card (Cube p.dimension)))
      (by simp [Cube]) hN hK (by omega : j≤p.depth) ht ht1
    rw [normalized_entropy_scale hn hσ] at hz
    exact hz

end NeuralGeneralization.RobustCompressionInduction
