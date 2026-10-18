import NeuralGeneralization.RobustCompressionInductionLayer
import NeuralGeneralization.RobustCompressionSelectedLocalCost
import NeuralGeneralization.RobustCompressionInductionInvariantStep
import NeuralGeneralization.RobustCompressionInductionSelectedHistory

/-! # Complete actual selected-law and original-history construction

Starting with the literal Gaussian-relative entropy bound, this file constructs
the common terminal canonical law and every aligned original-network history.
All layer comparisons and their success-weighted errors are instantiated from
the actual conditional laws; no compressor or coupling premise is retained.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustEntropy RobustStatistics RobustCompressionSelectedBank
set_option maxHeartbeats 700000

variable (p : RobustCompressionInput) {N : ℕ} [NeZero N]
  [hFin : MeasurableSpace (Finset (Fin (Fintype.card (Cube p.dimension))))]
  [hFinS : MeasurableSingletonClass (Finset (Fin (Fintype.card (Cube p.dimension))))]
  [hMsg : MeasurableSpace (QueryMessage (Fin (Fintype.card (Cube p.dimension))) p.activeRank)]
  [hMsgS : MeasurableSingletonClass (QueryMessage (Fin (Fintype.card (Cube p.dimension))) p.activeRank)]
  [hMsgB : StandardBorelSpace (QueryMessage (Fin (Fintype.card (Cube p.dimension))) p.activeRank)]

theorem resourceLayerComparison_cost {s k : ℕ} {σ : ℝ} (hσ : 0<σ)
    (hscale : (N : ℝ)*σ^2≤1) (hE : 0<p.inverseLayerError)
    (Γ : CanonicalStateLaw p.dimension N p.bankSize s (k+1))
    (S : ActualPrefixSelection Γ Real.tanh tanh_lipschitzWith.continuous p.activeRank
      (σ*Real.sqrt (N : ℝ)) (p.inverseSelectionError : ℝ)⁻¹ (p.inverseLayerFailure : ℝ)⁻¹)
    (hentropy : futureEntropy Γ.law (futurePrior N (k+1)) ≤
      ENNReal.ofReal (2*N*p.energy/(σ*Real.sqrt (N : ℝ))^2))
    (x : Cube p.dimension) :
    (∫⁻ z,liveLocalCost σ Real.tanh x z
      ∂(resourceLayerComparison p (σ*Real.sqrt (N : ℝ)) Γ S x).joint) ≤
      ENNReal.ofReal (10/(p.inverseLayerError : ℝ)) := by
  have hn : (0 : ℝ)<N := Nat.cast_pos.mpr (NeZero.pos N)
  have ht : 0<σ*Real.sqrt (N : ℝ) := by positivity
  have ht1 : (σ*Real.sqrt (N : ℝ))^2≤1 := by
    rw [physicalScale_sq]
    nlinarith [hscale]
  have he : σ*Real.sqrt (N : ℝ)/Real.sqrt (N : ℝ)=σ :=
    mul_div_cancel_right₀ σ (Real.sqrt_pos.mpr hn).ne'
  have h := selectedLayerJoint_liveLocalCost_le p Γ.law hE ht ht1 S hentropy
    ((Fintype.equivFin (Cube p.dimension)) x)
  simpa only [resourceLayerComparison,Equiv.symm_apply_apply,he] using h

/-- The terminal law and original histories are constructed from the original
posterior, uniformly in its width and Gaussian scale. -/
theorem exists_actual_terminal_histories {r : ℕ}
    (hd : 0<p.dimension) (hdepth : r+2≤p.depth)
    (hK : 0<p.energy) (hA : 0<p.inverseFailure) (hR : 0<p.inverseRadius)
    (hN : p.widthBound≤N) {σ : ℝ} (hσ : 0<σ) (hscale : (N : ℝ)*σ^2≤1)
    (Q : Measure (Weights p.dimension N r)) [IsProbabilityMeasure Q]
    (hQ : InformationTheory.klDiv Q (smallPrior p.dimension N r σ) ≤
      ENNReal.ofReal ((p.energy : ℝ)/σ^2)) :
    ∃ Γ : CanonicalStateLaw p.dimension N p.bankSize r 0,
      ResourceInvariant p σ r 0 Γ ∧
      ∀ x : Cube p.dimension, ∃ H : CanonicalHistoryComparison Q Γ.law
          (Prod.fst : OriginalHistory p.dimension N r r → Weights p.dimension N r),
        (∀ᵐ z ∂H.joint,HistoryAligned (by omega : r+0≤r) σ Real.tanh x z.1 z.2) ∧
        (∫⁻ z,liveOriginalCost (m:=p.bankSize) (k:=0) le_rfl Real.tanh x z ∂H.joint) ≤
          ENNReal.ofReal (1/(p.inverseLayerError : ℝ))+
            r • ENNReal.ofReal (10/(p.inverseLayerError : ℝ)) := by
  have hL : 0<p.depth := by omega
  have hE := p.inverseLayerError_pos hL hA hR
  have hH := p.inverseLayerFailure_pos hL hA
  have hn : 0<N := NeZero.pos N
  obtain ⟨run⟩ := exists_resource_selectedRun p hd hdepth hK hA hR hN hσ hscale
    tanh_lipschitzWith.continuous Q hQ
  let initial := initialCanonicalLaw p.bankSize σ (Real.sqrt p.firstSquaredBound) Q
  have hinitial : ResourceInvariant p σ 0 r initial := initial_resourceInvariant p hd hn hσ Q hQ
  have hall : ∀ hs : run.terminal.1 ≤ r, ∀ x : Cube p.dimension,
      ResourceInvariant p σ run.terminal.1 0 run.terminal.2 ∧
      ∃ H : CanonicalHistoryComparison Q run.terminal.2.law
          (Prod.fst : OriginalHistory p.dimension N r run.terminal.1 → Weights p.dimension N r),
        (∀ᵐ z ∂H.joint,HistoryAligned (by omega : run.terminal.1+0≤r)
          σ Real.tanh x z.1 z.2) ∧
        (∫⁻ z,liveOriginalCost hs
          Real.tanh x z ∂H.joint) ≤ ENNReal.ofReal (1/(p.inverseLayerError : ℝ))+
            r • ENNReal.ofReal (10/(p.inverseLayerError : ℝ)) := by
    intro hs x
    refine run.exists_terminal_history hσ.ne' x Q (ResourceInvariant p σ)
      (ENNReal.ofReal (10/(p.inverseLayerError : ℝ))) ?_ (by omega) hinitial
      (initialHistory p.bankSize σ (Real.sqrt p.firstSquaredBound)
        tanh_lipschitzWith.continuous x Q)
      (initialHistory_ae_aligned hd hn hσ _ tanh_lipschitzWith.continuous x Q)
      (ENNReal.ofReal (1/(p.inverseLayerError : ℝ))) ?_
    · intro s k Γ S hs hΓ
      refine ⟨resourceLayerComparison p (σ*Real.sqrt (N : ℝ)) Γ S x,?_,
        resourceLayerComparison_future p _ Γ S x,resourceLayerComparison_alive p _ Γ S x,?_⟩
      · exact selectedNext_resourceInvariant p hσ hscale hE hH tanh_lipschitzWith.continuous
          (fun z => (Real.abs_tanh_lt_one z).le) Γ S hΓ
      · exact resourceLayerComparison_cost p hσ hscale hE Γ S
          (ResourceInvariant.entropy_cap p hσ hscale hN hK (by omega) Γ hΓ) x
    · simpa only [one_div] using initialHistory_resource_cost p hd hn hE hσ hscale Q hQ
        tanh_lipschitzWith.continuous (fun z => (Real.abs_tanh_lt_one z).le) x
  have hstage := run.terminal_stage
  cases ht : run.terminal with
  | mk sf Γ =>
    rw [ht] at hall hstage
    simp only [Nat.zero_add] at hstage
    clear ht
    subst sf
    exact ⟨Γ,(hall le_rfl (fun _ => false)).1,fun x => (hall le_rfl x).2⟩

end NeuralGeneralization.RobustCompressionInduction
