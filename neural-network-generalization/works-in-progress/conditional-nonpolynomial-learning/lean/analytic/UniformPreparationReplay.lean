import UniformGaussianPathReplay
import UniformStablePathReplay
import ScalarPreparationComparison
import TaggedPhysicalAction

noncomputable section
set_option maxHeartbeats 2200000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal BigOperators
namespace ConditionalNonpolynomial.Analytic

theorem preparation_comparison_hiddenCost {v r q : ℝ}
    (prep C : ScalarChannelPath v r) (nominal : ScalarPath q)
    (hlen : C.length=prep.length+nominal.length)
    (hpre : ∀j<prep.length,C.control j=prep.control j)
    (htail : ∀j<nominal.length,C.control (prep.length+j)=nominal.control j) :
    C.hiddenCost=prep.hiddenCost+∑j∈Finset.range nominal.length,nominal.charge j := by
  rw [C.hiddenCost_eq_sum,hlen,Finset.sum_range_add,prep.hiddenCost_eq_sum]
  congr 1
  · apply Finset.sum_congr rfl
    intro j hj
    rw [hpre j (Finset.mem_range.mp hj)]
  · apply Finset.sum_congr rfl
    intro j hj
    rw [htail j (Finset.mem_range.mp hj)]
    rfl

/-- A critical comparator and a uniformly scaled actual program with exactly
the same scalar controls. Both critical action bounds preserve their original
coefficient; no division of the critical baseline by t² occurs here. -/
theorem exists_uniform_preparation_replay {v r r0 t q δ β K : ℝ}
    (prep : ScalarChannelPath v r) (nominal : ScalarPath q)
    (hG : prep.GaussianControls) (hprepV : prep.terminal.1=q)
    (hprepR : prep.terminal.2≤δ) (hinc : nominal.Increasing)
    (ht : 0<t) (ht1 : t≤1) (hr0 : 0≤r0) (hr0le : r0≤r)
    (hδ : 0≤δ) (hδ1 : δ<1) (hsmall : 4*(nominal.length:ℝ)*δ≤1)
    (hβ : 0<β) (hfloor : prep.SignalFloor β) (hβq : β≤q/2)
    (hK : prep.hiddenCost+(1+4*(nominal.length:ℝ)*δ)*nominal.cost≤K) :
    ∃(P : TaggedScalarPath t v r0) (C : ScalarChannelPath v r),
      P.length=prep.length+nominal.length ∧ C.length=P.length ∧
      (∀j<P.length,P.control j=(C.control j).prod scoreSignLaw) ∧
      P.bound≤1/Real.sqrt β+1 ∧ C.cost≤K ∧
      C.hiddenCost+1/(8*P.terminal.1)≤K ∧ P.terminal.1≤nominal.state nominal.length := by
  obtain ⟨pp,hpLen,hpState,hpControl,hpB,hpV,hpR0,hpR⟩ :=
    exists_uniform_gaussian_replay prep hG ht ht1 hr0 hr0le hβ hfloor
  have hppV : pp.terminal.1=q := hpV.trans hprepV
  have hppR : pp.terminal.2≤δ := hpR.trans hprepR
  have hsmallP : 4*(nominal.length:ℝ)*pp.terminal.2≤1 :=
    (mul_le_mul_of_nonneg_left hppR (by positivity)).trans hsmall
  obtain ⟨tail,htLen,htState,htControl,htB,htRead⟩ :=
    exists_uniform_stable_replay nominal hinc ht ht1 hpR0 (hppR.trans_lt hδ1) hsmallP
  have hterminal : pp.terminal=(q,pp.terminal.2) := by
    exact Prod.ext hppV rfl
  obtain ⟨P,hLen,hTerm,hBound,hHidden,hCost,hPre,hTail,hPreState,hTailState⟩ :=
    pp.exists_append tail hterminal
  have hPrepR0 := (prep.state_pos prep.length).2
  rw [prep.state_terminal] at hPrepR0
  have hsmallC : 4*(nominal.length:ℝ)*prep.terminal.2≤1 :=
    (mul_le_mul_of_nonneg_left hprepR (by positivity)).trans hsmall
  obtain ⟨C,hCLen,hCpre,hCtail,hCcost⟩ := prep.exists_stable_continuation nominal hprepV
    hPrepR0 (hprepR.trans_lt hδ1) hsmallC
  have hPLen : P.length=prep.length+nominal.length := by omega
  have hCCost : C.cost≤K := by
    have hh := mul_le_mul_of_nonneg_right (show 1+4*(nominal.length:ℝ)*prep.terminal.2≤
      1+4*(nominal.length:ℝ)*δ from by
        have hh := mul_le_mul_of_nonneg_left hprepR (by positivity : 0≤4*(nominal.length:ℝ))
        linarith) nominal.cost_nonneg
    linarith
  have hB : P.bound≤1/Real.sqrt β+1 := by
    rw [hBound]
    apply max_le hpB
    have hh := one_div_le_one_div_of_le (Real.sqrt_pos.mpr hβ) (Real.sqrt_le_sqrt hβq)
    linarith
  have hcontrols : ∀j<P.length,P.control j=(C.control j).prod scoreSignLaw := by
    intro j hj
    by_cases hpre : j<prep.length
    · rw [hPre j (by omega),hpControl j hpre,hCpre j hpre]
    · have hjtail : j-prep.length<nominal.length := by omega
      have hjEq : j=prep.length+(j-prep.length) := by omega
      rw [hpLen] at hTail
      rw [hjEq,hTail,htControl _ hjtail,hCtail _ hjtail]
  have hupper : P.terminal.1≤nominal.state nominal.length := by
    have hh := (uniformLiftedScalarState_bounds nominal ht.le ht1 hpR0
      (hppR.trans_lt hδ1) nominal.length le_rfl).2.1
    rw [hTerm,←tail.state_terminal,htLen,htState nominal.length le_rfl]
    exact hh
  refine ⟨P,C,hPLen,hCLen.trans hPLen.symm,hcontrols,hB,hCCost,?_,hupper⟩
  have hhidden := preparation_comparison_hiddenCost prep C nominal hCLen hCpre hCtail
  have htailCharge : 0≤∑j∈Finset.range nominal.length,nominal.charge j :=
    Finset.sum_nonneg fun _ _=>ENNReal.toReal_nonneg
  have hnomPos := nominal.state_pos nominal.length
  have hR0 : 0≤1/(8*nominal.state nominal.length) := by positivity
  have hreadScaled : (1+4*(nominal.length:ℝ)*pp.terminal.2)/(8*nominal.state nominal.length)≤
      (1+4*(nominal.length:ℝ)*δ)/(8*nominal.state nominal.length) := by
    apply div_le_div_of_nonneg_right _ (by positivity)
    have hh := mul_le_mul_of_nonneg_left hppR (by positivity : 0≤4*(nominal.length:ℝ))
    linarith
  have hread : 1/(8*P.terminal.1)≤(1+4*(nominal.length:ℝ)*δ)/(8*nominal.state nominal.length) := by
    rw [hTerm]
    exact htRead.trans hreadScaled
  have hnom := nominal.cost_eq_sum
  have hextra : 0≤4*(nominal.length:ℝ)*δ*(∑j∈Finset.range nominal.length,nominal.charge j) := by positivity
  rw [hhidden]
  have heq : (1+4*(nominal.length:ℝ)*δ)/(8*nominal.state nominal.length)=
      (1+4*(nominal.length:ℝ)*δ)*(1/(8*nominal.state nominal.length)) := by ring
  rw [heq] at hread
  rw [hnom] at hK
  nlinarith only [hread,hK,hextra]

#print axioms exists_uniform_preparation_replay
end ConditionalNonpolynomial.Analytic
