import NeuralGeneralization.BatchTwoImprovedHistoryActual
import NeuralGeneralization.BatchTwoImprovedRunBounds
import NeuralGeneralization.BatchTwoImprovedRunAbort
import NeuralGeneralization.RobustCompressionInductionResourceInitial

/-! The actual sharp terminal history, starting from the literal Gaussian
relative-entropy bound. All remaining premises are explicit scalar budgets. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal
namespace NeuralGeneralization.BatchTwoImprovedInduction
open ConcreteModel RobustEntropy RobustStatistics RobustCompressionInduction
open BatchTwoImprovedWeightedSampling SquaredSampling
variable {d N m q r : ℕ} [NeZero N]
  [hFin : MeasurableSpace (Finset (Fin (Fintype.card (Cube d))))]
  [hFinS : MeasurableSingletonClass (Finset (Fin (Fintype.card (Cube d))))]
  [hMsg : MeasurableSpace (QueryMessage (Fin (Fintype.card (Cube d))) q)]
  [hMsgS : MeasurableSingletonClass (QueryMessage (Fin (Fintype.card (Cube d))) q)]
  [hMsgB : StandardBorelSpace (QueryMessage (Fin (Fintype.card (Cube d))) q)]
local notation "Msg" => QueryMessage (Fin (Fintype.card (Cube d))) q
set_option maxHeartbeats 600000

theorem exists_sharp_actual_terminal_histories
    (hd : 0<d) (hm : 0<m) (hq : 0<q)
    {K t B₀ BH BG W δ η : ℝ}
    (hK : 0≤K) (ht : 0<t) (ht1 : t≤1)
    (hB₀ : 0<B₀) (hBH : 0<BH) (hBG : 0<BG) (hδ : 0<δ)
    (hη : 0<η) (hη1 : η≤1) (hB₀W : B₀≤W)
    (hW : 2*BH*((q:ℝ)+1)+2*BG≤W)
    (hrank : 2*K≤η*δ^3*q)
    (hgram : 256*(268435456:ℝ)^2*(2*q)*restrictionLog m q≤η^2*m)
    (hcap : ∀ j≤r, ENNReal.ofReal (K/(t/Real.sqrt (N:ℝ))^2)+
      j • ENNReal.ofReal (Real.log (Fintype.card Msg))≤ENNReal.ofReal (2*N*K/t^2))
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q]
    (hQ : InformationTheory.klDiv Q (smallPrior d N r (t/Real.sqrt (N:ℝ)))≤
      ENNReal.ofReal (K/(t/Real.sqrt (N:ℝ))^2)) :
    ∃ Γ : CanonicalStateLaw d N m r 0,
      (∀ᵐ z ∂Γ.law,activePrefixBounded W z.1) ∧
      Γ.law {z | z.1.1=false}≤r • (2*ENNReal.ofReal η) ∧
      futureEntropy Γ.law (futurePrior N 0)≤
        ENNReal.ofReal (K/(t/Real.sqrt (N:ℝ))^2)+
          r • ENNReal.ofReal (Real.log (Fintype.card Msg)) ∧
      ∀ x : Cube d, ∃ H : CanonicalHistoryComparison Q Γ.law
          (Prod.fst : OriginalHistory d N r r → Weights d N r),
        (∀ᵐ z ∂H.joint,HistoryAligned (by omega : r+0≤r)
          (t/Real.sqrt (N:ℝ)) Real.tanh x z.1 z.2) ∧
        (∫⁻ z,liveOriginalCost (m:=m) (k:=0) le_rfl Real.tanh x z ∂H.joint)≤
          ENNReal.ofReal (4*(4*K+2*((d:ℝ)+1))/B₀^2)+
            r • ENNReal.ofReal (sharpLayerError K δ BH BG q m) := by
  have hn : 0<N := Nat.pos_of_neZero N
  have hnR : (0:ℝ)<N := Nat.cast_pos.mpr hn
  let σ := t/Real.sqrt (N:ℝ)
  have hσ : 0<σ := by dsimp [σ]; positivity
  have hscale : (N:ℝ)*σ^2≤1 := by
    have hroot := Real.sq_sqrt hnR.le
    have he : (N:ℝ)*σ^2=t^2 := by dsimp [σ]; field_simp; nlinarith
    rw [he]; nlinarith
  let initial := initialCanonicalLaw m σ B₀ Q
  have hi : futureEntropy initial.law (futurePrior N r)≤ENNReal.ofReal (K/σ^2) :=
    (initialLaw_futureEntropy_le hd hn hσ B₀ Q).trans hQ
  obtain ⟨run⟩ := exists_sharpSelectedRun tanh_lipschitzWith.continuous
    t BH BG δ η K hq hn ht hδ hη.le hrank (ENNReal.ofReal (K/σ^2)) 0 r initial
    (by simpa using hi) (by simpa using hcap)
  have hb := run.terminal_bounded hm (by rwa [abs_of_pos ht]) hBH.le hBG.le
    (hB₀.le.trans hB₀W) hW (initialCanonicalLaw_bounded hd σ B₀ W hB₀.le hB₀W Q)
  have hia : initial.law {z | z.1.1=false}=0 := by
    have he : {z : (ActivePrefix d N m 0) × FutureWeights N r | z.1.1=false}=
        {z | z.1.1≠true} := by ext z; cases z.1.1 <;> simp
    rw [he]
    exact initialCanonicalLaw_abort σ B₀ Q
  have ha := run.terminal_abort hm hη hη1 hgram
  rw [hia,zero_add] at ha
  have he := run.terminal_entropy.trans (add_le_add hi le_rfl)
  have hall : ∀ hs : run.terminal.1≤r, ∀ x : Cube d,
      ∃ H : CanonicalHistoryComparison Q run.terminal.2.law
          (Prod.fst : OriginalHistory d N r run.terminal.1 → Weights d N r),
        (∀ᵐ z ∂H.joint,HistoryAligned (by omega : run.terminal.1+0≤r)
          σ Real.tanh x z.1 z.2) ∧
        (∫⁻ z,liveOriginalCost hs Real.tanh x z ∂H.joint)≤
          ENNReal.ofReal (4*(4*K+2*((d:ℝ)+1))/B₀^2)+
            r • ENNReal.ofReal (sharpLayerError K δ BH BG q m) := by
    intro hs x
    exact run.exists_actual_terminal_history hm hK ht ht1 hBH hBG hδ.le x Q
      (ENNReal.ofReal (K/σ^2)) hcap (by omega) (by simpa using hi)
      (initialHistory m σ B₀ tanh_lipschitzWith.continuous x Q)
      (initialHistory_ae_aligned hd hn hσ B₀ tanh_lipschitzWith.continuous x Q) _
      (initialHistory_live_cost_le hd hn hσ hK hscale Q hQ
        tanh_lipschitzWith.continuous (fun z => (Real.abs_tanh_lt_one z).le) B₀ hB₀ x)
  have hstage := run.terminal_stage
  cases hterm : run.terminal with
  | mk sf Γ =>
    rw [hterm] at hall hstage hb ha he
    simp only [Nat.zero_add] at hstage
    clear hterm
    subst sf
    exact ⟨Γ,hb,ha,he,fun x => hall le_rfl x⟩
end NeuralGeneralization.BatchTwoImprovedInduction
