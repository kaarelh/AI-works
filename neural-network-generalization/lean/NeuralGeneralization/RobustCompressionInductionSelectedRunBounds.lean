import NeuralGeneralization.RobustCompressionInductionSelectedRun
import NeuralGeneralization.RobustCompressionInductionSelectedBounds

/-! # Actual terminal coefficient bounds for the selected depth recursion -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustEntropy
variable {d N m q : ℕ}
local notation "QI" => Fin (Fintype.card (Cube d))
local notation "Msg" => QueryMessage QI q

theorem selectedNext_bounded [NeZero N]
    [hFin : MeasurableSpace (Finset QI)] [hFinS : MeasurableSingletonClass (Finset QI)]
    [hMsg : MeasurableSpace Msg] [hMsgS : MeasurableSingletonClass Msg]
    {s r : ℕ} {φ : ℝ → ℝ} (hφ : Continuous φ)
    {a t T BH BG δ η B : ℝ}
    (hm : 0 < m) (ha : 0 ≤ a) (ht : |t| ≤ 1)
    (hT : 0 ≤ T) (hBH : 0 ≤ BH) (hBG : 0 ≤ BG) (hB : 0 ≤ B)
    (hbound : BH*T+BG ≤ B)
    (Q : CanonicalStateLaw d N m s (r+1))
    (S : ActualPrefixSelection Q φ hφ q t δ η)
    (hQ : ∀ᵐ z ∂Q.law, activePrefixBounded B z.1) :
    ∀ᵐ z ∂(selectedNext (q:=q) hφ a t T BH BG δ η Q S).law,
      activePrefixBounded B z.1 := by
  exact selectedTransition_next_bounded hφ (indexedPrefixQueries φ)
    (measurable_indexedPrefixQueries hφ) hm ha ht hT hBH hBG hB hbound
    S.queries S.measurable_queries Q hQ

theorem SelectedRun.terminal_bounded [NeZero N]
    [hFin : MeasurableSpace (Finset QI)] [hFinS : MeasurableSingletonClass (Finset QI)]
    [hMsg : MeasurableSpace Msg] [hMsgS : MeasurableSingletonClass Msg]
    {φ : ℝ → ℝ} {hφ : Continuous φ} {a t T BH BG δ η B : ℝ}
    {s r : ℕ} {Q : CanonicalStateLaw d N m s r}
    (P : SelectedRun (d:=d) (N:=N) (m:=m) (q:=q) hφ a t T BH BG δ η s r Q)
    (hm : 0 < m) (ha : 0 ≤ a) (ht : |t| ≤ 1)
    (hT : 0 ≤ T) (hBH : 0 ≤ BH) (hBG : 0 ≤ BG) (hB : 0 ≤ B)
    (hbound : BH*T+BG ≤ B)
    (hQ : ∀ᵐ z ∂Q.law, activePrefixBounded B z.1) :
    ∀ᵐ z ∂P.terminal.2.law, activePrefixBounded B z.1 := by
  induction P with
  | nil s Q => exact hQ
  | @cons s r Q S tail ih =>
    exact ih (selectedNext_bounded hφ hm ha ht hT hBH hBG hB hbound Q S hQ)

end NeuralGeneralization.RobustCompressionInduction
