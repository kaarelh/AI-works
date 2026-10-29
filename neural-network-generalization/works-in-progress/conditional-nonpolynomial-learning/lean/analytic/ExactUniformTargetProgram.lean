import UniformPreparationReplay
import ScalarChannelOccupation

noncomputable section
set_option maxHeartbeats 2200000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal BigOperators
namespace ConditionalNonpolynomial.Analytic

def uniformTargetSlack (v : ℝ) (H : ℕ) : ℝ :=
  1024*targetProgramConstant^2*(targetLogBudget v H)^2/(H:ℝ)

def uniformTargetCriticalBudget (v : ℝ) (H : ℕ) : ℝ := scalarBaseline.toReal+uniformTargetSlack v H

def uniformTargetSqrtBudget (v : ℝ) (H : ℕ) : ℝ :=
  Real.sqrt (526337*(H:ℝ)*uniformTargetSlack v H+526336)+
    ((Nat.log2 (H+1)+1:ℕ):ℝ)*dyadicBlockConstant 526336

def uniformTargetPhysicalBudget (t v : ℝ) (H : ℕ) : ℝ :=
  (H:ℝ)*subcriticalCostBaseline (t^2).toNNReal+uniformTargetCriticalBudget v H+
    ((t^2)⁻¹-1)/2*(2*Real.sqrt 2*uniformTargetSqrtBudget v H+2*uniformTargetCriticalBudget v H)

/-- An actual program at every 0<t≤1, retaining the coefficient-one critical
baseline. Its controls, scores, entropy, and moment recursions are all genuine;
the critical comparator is used only to bound the same scalar entropy charges. -/
theorem exists_exact_uniform_target_program {v r r0 t : ℝ}
    (hv : 0<v) (hr : 0≤r) (hq : v+r≤1)
    (ht : 0<t) (ht1 : t≤1) (hr0 : 0≤r0) (hr0le : r0≤r) (H : ℕ)
    (hH : 256*targetProgramConstant*targetLogBudget v H≤(H:ℝ)) :
    ∃ (P : TaggedScalarPath t v r0) (C : ScalarChannelPath v r),
      P.length=H ∧ C.length=H ∧
      (∀j<H,P.control j=(C.control j).prod scoreSignLaw) ∧
      P.bound≤1/Real.sqrt (cooledSeedFloor v H/2)+1 ∧
      C.cost≤uniformTargetCriticalBudget v H ∧
      C.hiddenCost+1/(8*P.terminal.1)≤uniformTargetCriticalBudget v H ∧
      (∑j∈Finset.range H,Real.sqrt (klDiv (C.control j) (gaussianReal 0 1)).toReal)≤
        uniformTargetSqrtBudget v H ∧
      P.cost≤t^2*uniformTargetPhysicalBudget t v H ∧ P.terminal.1≤1 := by
  obtain ⟨q,nominal,prep,hqpos,hqsmall,hinc,hLen,hV,hR0,hR,hsmall,hFloor,hG,hBudget⟩ :=
    exists_exact_gaussian_preparation hv hr hq H hH
  have hnomH : nominal.length≤H := by omega
  have hδ := targetResidual_bounds hqpos hqsmall hnomH
  have hβ : 0<cooledSeedFloor v H/2 := by positivity [cooledSeedFloor_pos hv H]
  have hFloor' : prep.SignalFloor (cooledSeedFloor v H/2) := by
    intro j hj
    have hh := hFloor j hj
    have hhpos := cooledSeedFloor_pos hv H
    linarith
  have hβq : cooledSeedFloor v H/2≤q/2 := by
    have hh := hFloor prep.length le_rfl
    rw [prep.state_terminal,hV] at hh
    linarith
  obtain ⟨P,C,hPLen,hCLen,hControl,hB,hCCost,hRead,hUpper⟩ :=
    exists_uniform_preparation_replay prep nominal hG hV hR hinc ht ht1 hr0 hr0le
      hδ.1.le hδ.2.1 hsmall hβ hFloor' hβq hBudget
  have hpH : P.length=H := hPLen.trans hLen
  have hcH : C.length=H := hCLen.trans hpH
  have hc : C.cost≤uniformTargetCriticalBudget v H := hCCost
  have hsqrt := C.sqrt_entropy_bound hq
    (show 0≤uniformTargetSlack v H by unfold uniformTargetSlack; positivity) hc
  rw [hcH] at hsqrt
  have hcontrol' : ∀j<H,P.control j=(C.control j).prod scoreSignLaw := by
    intro j hj
    exact hControl j (by omega)
  have hsum : C.hiddenCost=∑j∈Finset.range H,(klDiv (C.control j) (gaussianReal 0 1)).toReal := by
    rw [C.hiddenCost_eq_sum,hcH]
  have haction := tagged_reused_physical_action ht ht1 P C.control H hpH hcontrol'
    (fun j _=>C.control_probability j) (fun j _=>C.control_finiteKL j)
    (K:=uniformTargetCriticalBudget v H) (S:=uniformTargetSqrtBudget v H)
    (by rw [←hsum]; exact hRead) hsqrt
  exact ⟨P,C,hpH,hcH,hcontrol',hB,hc,hRead,hsqrt,haction,
    hUpper.trans (nominal.state_le_one (hqsmall.trans (by norm_num)) _)⟩

#print axioms exists_exact_uniform_target_program
end ConditionalNonpolynomial.Analytic
