import NeuralGeneralization.BatchTwoShallowTeacher
import NeuralGeneralization.BatchTwoShallowRobust
import NeuralGeneralization.FunctionPriorFacts

/-! Positive target mass with the literal logarithmic cost in the shallow
paper, for every width at least the teacher width and every Nσ² ≤ 1. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoShallow
open ConcreteModel

def targetRadius {d C : ℕ} (s : ℝ) (w : Weights d C 0) : ℝ :=
  1/(4*(1+s*readoutL1 w*((d : ℝ)+1)/Real.sqrt d))

def targetCost {d C : ℕ} (s : ℝ) (w : Weights d C 0) : ℝ :=
  teacherCenterCost s w+((d : ℝ)+2)*
    Real.log (Real.exp 1*Real.sqrt (2*Real.pi)/(2*targetRadius s w))

theorem targetRadius_bounds {d C : ℕ} {s : ℝ} (hs : 0 ≤ s) (w : Weights d C 0) :
    0 < targetRadius s w ∧ targetRadius s w ≤ 1/4 := by
  have hL : 0 ≤ readoutL1 w := Finset.sum_nonneg fun _ _ => abs_nonneg _
  have ha : 0 ≤ s*readoutL1 w*((d : ℝ)+1)/Real.sqrt d := by positivity
  constructor
  · unfold targetRadius; positivity
  · unfold targetRadius
    apply one_div_le_one_div_of_le (by norm_num : (0 : ℝ)<4)
    linarith

theorem targetRadius_identity {d C : ℕ} {s : ℝ} (hs : 0 ≤ s) (w : Weights d C 0) :
    targetRadius s w+s*readoutL1 w*((d : ℝ)+1)*targetRadius s w/Real.sqrt d=1/4 := by
  have hL : 0 ≤ readoutL1 w := Finset.sum_nonneg fun _ _ => abs_nonneg _
  have ha : 0 ≤ s*readoutL1 w*((d : ℝ)+1)/Real.sqrt d := by positivity
  have hd : 1+s*readoutL1 w*((d : ℝ)+1)/Real.sqrt d ≠ 0 := by linarith
  unfold targetRadius
  field_simp
  <;> ring

theorem targetCost_eq {d C : ℕ} {s : ℝ} (hs : 0 ≤ s) (w : Weights d C 0) :
    targetCost s w=teacherCenterCost s w+((d : ℝ)+2)*
      (1-Real.log (2*targetRadius s w/Real.sqrt (2*Real.pi))) := by
  have hr := (targetRadius_bounds hs w).1
  unfold targetCost
  rw [Real.log_div (by positivity) (by positivity),
    Real.log_mul (by positivity) (by positivity), Real.log_exp,
    Real.log_div (by positivity) (by positivity)]
  ring

theorem targetCost_gt_one {d C : ℕ} {s : ℝ} (hs : 0 ≤ s) (w : Weights d C 0) :
    1 < targetCost s w := by
  have hK : 0 ≤ teacherCenterCost s w := by
    unfold teacherCenterCost teacherInputCost maxRowEnergy firstEnergySum rowEnergy readoutEnergySum
    positivity
  have hr := targetRadius_bounds hs w
  have hr0 := hr.1
  have hsqrt : (1 : ℝ) ≤ Real.sqrt (2*Real.pi) := by
    apply (Real.le_sqrt (by norm_num) (by positivity)).mpr
    nlinarith [Real.pi_gt_three]
  have hratio : 2*targetRadius s w/Real.sqrt (2*Real.pi) ≤ 1 :=
    (div_le_one (by positivity)).mpr (by linarith [hr.2])
  have hl := Real.log_nonpos (by positivity : 0 ≤ 2*targetRadius s w/Real.sqrt (2*Real.pi)) hratio
  rw [targetCost_eq hs]
  have hdim : (2 : ℝ) ≤ d+2 := by have := (Nat.cast_nonneg d : (0 : ℝ) ≤ d); linarith
  nlinarith

def priorSupport (d N : ℕ) (c : ℝ) (robust global : Bool) : Set (Weights d N 0) :=
  (if robust then robustEvent Real.tanh c else Set.univ) ∩
    (if global then globalMarginEvent Real.tanh (1/2) else Set.univ)

def targetScale (c : ℝ) (robust : Bool) : ℝ := if robust then 2*c+3 else 3

theorem measurable_priorSupport (d N : ℕ) {c : ℝ} (hc : 0 < c) (robust global : Bool) :
    MeasurableSet (priorSupport d N c robust global) := by
  unfold priorSupport
  apply MeasurableSet.inter
  · cases robust <;> simp only [Bool.false_eq_true, ite_false, ite_true]
    · exact MeasurableSet.univ
    · exact measurableSet_robustEvent tanh_continuous hc
  · cases global <;> simp only [Bool.false_eq_true, ite_false, ite_true]
    · exact MeasurableSet.univ
    · rw [globalMarginEvent_eq_iUnion Real.tanh (1/2)]
      exact MeasurableSet.iUnion (fun f => (isOpen_marginEvent tanh_continuous (1/2) f).measurableSet)

theorem shallow_target_mass {d C N : ℕ} (hd : 0 < d) (hC : 0 < C) (hCN : C ≤ N)
    (w : Weights d C 0) (f : BooleanFunction d) (hw : w ∈ marginEvent Real.tanh (1/2) f)
    {c σ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N : ℝ)*σ^2 ≤ 1)
    (robust global : Bool) :
    Real.exp (-targetCost (targetScale c robust) w/σ^2) ≤
      (smallPrior d N 0 σ).real
        (priorSupport d N c robust global ∩ marginEvent Real.tanh (1/2) f) := by
  have hN : 0 < N := hC.trans_le hCN
  let s := targetScale c robust
  have hs : 3 ≤ s := by dsimp [s,targetScale]; cases robust <;> simp <;> linarith
  have hs0 : 0 ≤ s := by linarith
  obtain ⟨v,hout,hL,hK⟩ := exists_teacher_clone hC hCN hs0 w
  have hr := targetRadius_bounds hs0 w
  have hm := coordinateCylinder_mass hd hN v hr.1 hr.2 hσ hscale hK
  rw [← targetCost_eq hs0] at hm
  apply hm.trans (measureReal_mono ?_)
  intro u hu
  have herr (x : Cube d) : |networkOutput Real.tanh u x-s*networkOutput Real.tanh w x| ≤ 1/4 := by
    have he := coordinateCylinder_output_stability hd hN u v hr.1.le hσ.le hscale hu x
    rw [hout x, hL, targetRadius_identity hs0] at he
    exact he
  have hmargin (x : Cube d) : s/2-1/4 < labelReal (f x)*networkOutput Real.tanh u x := by
    have he : |labelReal (f x)*(networkOutput Real.tanh u x-s*networkOutput Real.tanh w x)| ≤ 1/4 := by
      simpa only [abs_mul, abs_labelReal, one_mul] using herr x
    have hdif := (abs_le.mp he).1
    have ht := mul_lt_mul_of_pos_left (hw x) (show 0 < s by linarith)
    nlinarith
  have huMargin : u ∈ marginEvent Real.tanh (1/2) f := by
    intro x
    linarith [hmargin x]
  refine ⟨⟨?_, ?_⟩, huMargin⟩
  · cases robust with
    | false => trivial
    | true =>
      apply shallow_robust_of_margin hN Real.tanh u f hc.le
      intro x
      have hs' : s=2*c+3 := rfl
      rw [hs'] at hmargin
      linarith [hmargin x]
  · cases global with
    | false => trivial
    | true => exact marginEvent_subset_global Real.tanh (1/2) f huMargin

end NeuralGeneralization.BatchTwoShallow
