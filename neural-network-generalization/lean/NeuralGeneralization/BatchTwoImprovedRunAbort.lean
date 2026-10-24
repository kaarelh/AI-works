import NeuralGeneralization.BatchTwoImprovedSelectedRun
import NeuralGeneralization.BatchTwoImprovedCanonicalAbort

/-! A quantitative abort bound for the actual entire sharp run. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal
namespace NeuralGeneralization.BatchTwoImprovedInduction
open ConcreteModel RobustEntropy RobustCompressionInduction BatchTwoImprovedCanonicalLayer
open BatchTwoImprovedWeightedSampling SquaredSampling
variable {d N m q : ℕ}
local notation "QI" => Fin (Fintype.card (Cube d))
local notation "Msg" => QueryMessage QI q

theorem sharpSelectedNext_abort [NeZero N]
    [hFin : MeasurableSpace (Finset QI)] [hFinS : MeasurableSingletonClass (Finset QI)]
    [hMsg : MeasurableSpace Msg] [hMsgS : MeasurableSingletonClass Msg]
    {s r : ℕ} {φ : ℝ → ℝ} (hφ : Continuous φ) (hq : 0<q)
    {t BH BG δ η : ℝ} (hm : 0<m) (hη : 0<η) (hη1 : η≤1)
    (hbudget : 256*(268435456:ℝ)^2*(2*q)*restrictionLog m q≤η^2*m)
    (Γ : CanonicalStateLaw d N m s (r+1))
    (S : ActualPrefixSelection Γ φ hφ q t δ η) :
    (sharpSelectedNext hφ hq t BH BG δ η Γ S).law {z | z.1.1=false} ≤
      Γ.law {z | z.1.1=false}+2*ENNReal.ofReal η := by
  have ha := sharp_selectedStep_abort_le hq hm Γ.law (indexedPrefixQueries φ)
    (measurable_indexedPrefixQueries hφ) S.queries S.measurable_queries t BH BG hη hη1 hbudget
  have hs : (currentRowJoint (prefixCurrentLaw Γ.law)).fst
      {θ | abortQueryMessage q (S.queries θ)=none} ≤ ENNReal.ofReal η := by
    apply (ENNReal.toReal_le_toReal (measure_ne_top _ _) ENNReal.ofReal_ne_top).mp
    simpa only [Measure.real,ENNReal.toReal_ofReal hη.le] using S.abort_bound
  refine ha.trans ?_
  calc
    _ ≤ Γ.law {z | z.1.1=false}+ENNReal.ofReal η+ENNReal.ofReal η :=
      add_le_add (add_le_add le_rfl hs) le_rfl
    _ = _ := by rw [two_mul]; ac_rfl

theorem SharpSelectedRun.terminal_abort [NeZero N]
    [hFin : MeasurableSpace (Finset QI)] [hFinS : MeasurableSingletonClass (Finset QI)]
    [hMsg : MeasurableSpace Msg] [hMsgS : MeasurableSingletonClass Msg]
    {φ : ℝ → ℝ} {hφ : Continuous φ} {hq : 0<q} {t BH BG δ η : ℝ}
    {s r : ℕ} {Γ : CanonicalStateLaw d N m s r}
    (P : SharpSelectedRun (d:=d) (N:=N) (m:=m) (q:=q) hφ hq t BH BG δ η s r Γ)
    (hm : 0<m) (hη : 0<η) (hη1 : η≤1)
    (hbudget : 256*(268435456:ℝ)^2*(2*q)*restrictionLog m q≤η^2*m) :
    P.terminal.2.law {z | z.1.1=false} ≤
      Γ.law {z | z.1.1=false}+r • (2*ENNReal.ofReal η) := by
  induction P with
  | nil s Γ => simp only [terminal,zero_nsmul,add_zero]; exact le_rfl
  | @cons s r Γ S tail ih =>
    refine ih.trans ?_
    have hs := sharpSelectedNext_abort (BH:=BH) (BG:=BG) hφ hq hm hη hη1 hbudget Γ S
    calc
      _ ≤ (Γ.law {z | z.1.1=false}+2*ENNReal.ofReal η)+r • (2*ENNReal.ofReal η) :=
        add_le_add hs le_rfl
      _ = _ := by rw [add_nsmul,one_nsmul]; ac_rfl
end NeuralGeneralization.BatchTwoImprovedInduction
