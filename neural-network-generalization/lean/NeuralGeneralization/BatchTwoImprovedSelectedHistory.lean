import NeuralGeneralization.BatchTwoImprovedSelectedRun
import NeuralGeneralization.RobustCompressionInductionAlignment
import NeuralGeneralization.RobustCouplingActualCost

/-! # Retaining the original network throughout the actual selected run

This induction glues each actual layer comparison to the preceding full
history. It charges disturbance only while the canonical state remains live.
The state invariant is separate from pointwise histories, so all test inputs
share exactly the same recursively constructed terminal coefficient law.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal
namespace NeuralGeneralization.BatchTwoImprovedInduction
open ConcreteModel RobustEntropy RobustStatistics RobustCompressionInduction
variable {d N m q R : ℕ}
local notation "QI" => Fin (Fintype.card (Cube d))
local notation "Msg" => QueryMessage QI q

theorem SharpSelectedRun.exists_terminal_history [NeZero N]
    [hFin : MeasurableSpace (Finset QI)] [hFinS : MeasurableSingletonClass (Finset QI)]
    [hMsg : MeasurableSpace Msg] [hMsgS : MeasurableSingletonClass Msg]
    {φ : ℝ → ℝ} {hφ : Continuous φ} {hq : 0 < q} {t BH BG δ η σ : ℝ}
    (hσ : σ≠0) (x : Cube d) (Q : Measure (Weights d N R))
    (Good : ∀ s k, CanonicalStateLaw d N m s k → Prop)
    (localBudget : ℝ≥0∞)
    (step : ∀ s k (Γ : CanonicalStateLaw d N m s (k+1))
      (S : ActualPrefixSelection Γ φ hφ q t δ η),
      s+(k+1)≤R → Good s (k+1) Γ →
      ∃ C : ProbabilityCoupling Γ.law (sharpSelectedNext (q:=q) hφ hq t BH BG δ η Γ S).law,
        Good (s+1) k (sharpSelectedNext (q:=q) hφ hq t BH BG δ η Γ S) ∧
        (∀ᵐ z ∂C.joint,z.2.2=(splitFuture N k z.1.2).2) ∧
        (∀ᵐ z ∂C.joint,z.2.1.1=true → z.1.1.1=true) ∧
        (∫⁻ z,liveLocalCost σ φ x z ∂C.joint)≤ localBudget)
    {s k : ℕ} {Γ : CanonicalStateLaw d N m s k}
    (P : SharpSelectedRun (d:=d) (N:=N) (m:=m) (q:=q) hφ hq t BH BG δ η s k Γ)
    (hs : s+k≤R) (hg : Good s k Γ)
    (H : CanonicalHistoryComparison Q Γ.law
      (Prod.fst : OriginalHistory d N R s → Weights d N R))
    (halign : ∀ᵐ z ∂H.joint,HistoryAligned hs σ φ x z.1 z.2)
    (initialBudget : ℝ≥0∞)
    (hcost : (∫⁻ z,liveOriginalCost (by omega : s≤R) φ x z ∂H.joint)≤ initialBudget) :
    Good P.terminal.1 0 P.terminal.2 ∧
    ∃ H' : CanonicalHistoryComparison Q P.terminal.2.law
        (Prod.fst : OriginalHistory d N R P.terminal.1 → Weights d N R),
      (∀ᵐ z ∂H'.joint,HistoryAligned (by have ht:=P.terminal_stage; omega : P.terminal.1+0≤R)
        σ φ x z.1 z.2) ∧
      (∫⁻ z,liveOriginalCost (by have ht:=P.terminal_stage; omega : P.terminal.1≤R)
        φ x z ∂H'.joint)≤ initialBudget+k • localBudget := by
  induction P generalizing initialBudget with
  | nil s Γ =>
    refine ⟨hg,H,halign,?_⟩
    convert hcost using 1 <;> simp only [SharpSelectedRun.terminal,zero_nsmul,add_zero]
    rfl
  | @cons s k Γ S tail ih =>
    obtain ⟨C,hg',hfuture,hlive,hlocal⟩ := step s k Γ S hs hg
    let H' := advanceHistory H C (appendOriginalHistory φ x)
      (measurable_appendOriginalHistory hφ x) measurable_fst measurable_fst
      (appendOriginalHistory_original φ x)
    have ha' : ∀ᵐ z ∂H'.joint,
        HistoryAligned (by omega : (s+1)+k≤R) σ φ x z.1 z.2 :=
      advanceHistory_ae_aligned hs σ hφ x H C halign hfuture
    have hc' : (∫⁻ z,liveOriginalCost (by omega : s+1≤R) φ x z ∂H'.joint)≤
        initialBudget+localBudget :=
      advanceOriginalHistory_cost_le hs hσ hφ x H C halign hlive hcost hlocal
    obtain ⟨hg'',H'',ha'',hc''⟩ := ih (by omega) hg' H' ha'
      (initialBudget+localBudget) hc'
    refine ⟨hg'',H'',ha'',hc''.trans_eq ?_⟩
    rw [add_nsmul,one_nsmul]
    ac_rfl

end NeuralGeneralization.BatchTwoImprovedInduction
