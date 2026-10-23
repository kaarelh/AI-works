import NeuralGeneralization.BatchTwoImprovedLayerBudget
import NeuralGeneralization.BatchTwoImprovedSelectedHistory
import NeuralGeneralization.BatchTwoImprovedCanonicalAbort

/-! Closing the depthwise history construction with the actual sharp layer
coupling and cost, rather than an assumed layer-comparison oracle. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal
namespace NeuralGeneralization.BatchTwoImprovedInduction
open ConcreteModel RobustEntropy RobustStatistics RobustCompressionInduction
open BatchTwoImprovedCanonicalLayer
variable {d N m q R : ℕ} [NeZero N]
  [hFin : MeasurableSpace (Finset (Fin (Fintype.card (Cube d))))]
  [hFinS : MeasurableSingletonClass (Finset (Fin (Fintype.card (Cube d))))]
  [hMsg : MeasurableSpace (QueryMessage (Fin (Fintype.card (Cube d))) q)]
  [hMsgS : MeasurableSingletonClass (QueryMessage (Fin (Fintype.card (Cube d))) q)]
  [hMsgB : StandardBorelSpace (QueryMessage (Fin (Fintype.card (Cube d))) q)]
local notation "Msg" => QueryMessage (Fin (Fintype.card (Cube d))) q

theorem SharpSelectedRun.exists_actual_terminal_history
    {hq : 0<q} {K t BH BG δ η : ℝ} (hm : 0<m) (hK : 0 ≤ K)
    (ht : 0<t) (ht1 : t ≤ 1) (hBH : 0<BH) (hBG : 0<BG) (hδ : 0 ≤ δ)
    (x : Cube d) (Q : Measure (Weights d N R))
    (base : ℝ≥0∞)
    (hcap : ∀ j ≤ R,base+j • ENNReal.ofReal (Real.log (Fintype.card Msg)) ≤ ENNReal.ofReal (2*N*K/t^2))
    {s k : ℕ} {Γ : CanonicalStateLaw d N m s k}
    (P : SharpSelectedRun (d:=d) (N:=N) (m:=m) (q:=q) tanh_lipschitzWith.continuous
      hq t BH BG δ η s k Γ) (hs : s+k ≤ R)
    (hΓ : futureEntropy Γ.law (futurePrior N k) ≤ base+s • ENNReal.ofReal (Real.log (Fintype.card Msg)))
    (H : CanonicalHistoryComparison Q Γ.law (Prod.fst : OriginalHistory d N R s → Weights d N R))
    (halign : ∀ᵐ z ∂H.joint,HistoryAligned hs (t/Real.sqrt (N:ℝ)) Real.tanh x z.1 z.2)
    (initialBudget : ℝ≥0∞)
    (hcost : (∫⁻ z,liveOriginalCost (by omega : s ≤ R) Real.tanh x z ∂H.joint) ≤ initialBudget) :
    ∃ H' : CanonicalHistoryComparison Q P.terminal.2.law
        (Prod.fst : OriginalHistory d N R P.terminal.1 → Weights d N R),
      (∀ᵐ z ∂H'.joint,HistoryAligned (by have he:=P.terminal_stage; omega : P.terminal.1+0 ≤ R)
        (t/Real.sqrt (N:ℝ)) Real.tanh x z.1 z.2) ∧
      (∫⁻ z,liveOriginalCost (by have he:=P.terminal_stage; omega : P.terminal.1 ≤ R)
        Real.tanh x z ∂H'.joint) ≤ initialBudget+k • ENNReal.ofReal (sharpLayerError K δ BH BG q m) := by
  let Good := fun s k (Γ : CanonicalStateLaw d N m s k) =>
    futureEntropy Γ.law (futurePrior N k) ≤ base+s • ENNReal.ofReal (Real.log (Fintype.card Msg))
  have hn : (0:ℝ) < N := Nat.cast_pos.mpr (Nat.pos_of_neZero N)
  have hσ : t/Real.sqrt (N:ℝ)≠0 := ne_of_gt (by positivity : 0 < t/Real.sqrt (N:ℝ))
  have step : ∀ s k (Γ : CanonicalStateLaw d N m s (k+1))
      (S : ActualPrefixSelection Γ Real.tanh tanh_lipschitzWith.continuous q t δ η),
      s+(k+1) ≤ R → Good s (k+1) Γ →
      ∃ C : ProbabilityCoupling Γ.law
        (sharpSelectedNext tanh_lipschitzWith.continuous hq t BH BG δ η Γ S).law,
        Good (s+1) k (sharpSelectedNext tanh_lipschitzWith.continuous hq t BH BG δ η Γ S) ∧
        (∀ᵐ z ∂C.joint,z.2.2=(splitFuture N k z.1.2).2) ∧
        (∀ᵐ z ∂C.joint,z.2.1.1=true → z.1.1.1=true) ∧
        (∫⁻ z,liveLocalCost (t/Real.sqrt (N:ℝ)) Real.tanh x z ∂C.joint) ≤ 
          ENNReal.ofReal (sharpLayerError K δ BH BG q m) := by
    intro s k Γ S hs hg
    refine ⟨sharpComparison tanh_lipschitzWith.continuous hq t BH BG δ η Γ S x,?_,
      sharpComparison_future tanh_lipschitzWith.continuous hq t BH BG δ η Γ S x,
      sharpComparison_alive tanh_lipschitzWith.continuous hq t BH BG δ η Γ S x,
      sharpComparison_cost hq hm hK ht ht1 hBH hBG hδ Γ S
        (hg.trans (hcap s (by omega))) x⟩
    have he := sharp_selectedStep_futureEntropy hq Γ.law (indexedPrefixQueries Real.tanh)
      (measurable_indexedPrefixQueries tanh_lipschitzWith.continuous) S.queries S.measurable_queries t BH BG
    refine he.trans ?_
    calc
      _  ≤  (base+s • ENNReal.ofReal (Real.log (Fintype.card Msg)))+
          ENNReal.ofReal (Real.log (Fintype.card Msg)) := add_le_add hg le_rfl
      _ = _ := by rw [add_nsmul,one_nsmul]; ac_rfl
  obtain ⟨_,H',ha,hc⟩ := SharpSelectedRun.exists_terminal_history hσ x Q Good
    (ENNReal.ofReal (sharpLayerError K δ BH BG q m)) step P hs hΓ H halign initialBudget hcost
  exact ⟨H',ha,hc⟩
end NeuralGeneralization.BatchTwoImprovedInduction
