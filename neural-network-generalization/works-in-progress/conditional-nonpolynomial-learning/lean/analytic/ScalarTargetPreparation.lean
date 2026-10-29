import ScalarChannelPhases
import ScalarChannelAppend
import ScalarChannelFloor
import StableScalarChannelPath

/-! A concrete target-component path, with an arbitrary prescribed holding
time, exact geometric growth, purification, and a lifted scalar continuation. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped NNReal ENNReal BigOperators
namespace ConditionalNonpolynomial.Analytic

theorem exists_prepared_scalar_channel_path {p v r δ : ℝ}
    (hv : 0 < v) (hvp : v ≤ p) (hr : 0 ≤ r) (hrp : r ≤ p)
    (hp : p ≤ 1/256) (hδ : 0 ≤ δ) (hδ1 : δ < 1)
    (Hhold Hgrow Hpur : ℕ) (nominal : ScalarPath p) (hinc : nominal.Increasing)
    (hgrowth : Real.log (p/v) ≤ (Hgrow : ℝ)*p)
    (hpurification : Real.exp (-purificationRate*p*(Hpur : ℝ))*p ≤ δ)
    (hsmall : 4*(nominal.length : ℝ)*δ ≤ 1) :
    ∃ P : ScalarChannelPath v r,
      P.length=Hhold+Hgrow+Hpur+nominal.length ∧
      P.cost ≤ 256*((Hhold : ℝ)+Hgrow+Hpur)*p^2+
        (1+4*(nominal.length : ℝ)*δ)*nominal.cost ∧ P.SignalFloor (v/2) := by
  have hp0 : 0 < p := hv.trans_le hvp
  have hq : v+r ≤ 1/128 := by linarith
  obtain ⟨hold,hholdLen,hholdCost,hholdState⟩ := exists_holding_path hv hr hq Hhold
  let rh := holdingResidual v r Hhold
  have hrh := holdingResidual_bounds hv.le hr hq Hhold
  have hholdTerminal : hold.terminal=(v,rh) := hold.terminal_of_state hholdLen
    (hholdState Hhold le_rfl)
  obtain ⟨grow,hgrowLen,hgrowCost,hgrowState⟩ :=
    exists_growth_path hv hvp hrh.1 (hrh.2.trans hrp) hp Hgrow
  let rg := growthResidual p v rh Hgrow
  have hrg := growthResidual_bounds hv.le hvp hrh.1 (hrh.2.trans hrp) hp Hgrow
  have hrgp : rg ≤ p := hrg.2.trans (hrh.2.trans hrp)
  have hreach := growthSchedule_reaches hv hvp (show p ≤ 1 by linarith) Hgrow hgrowth
  have hgrowTerminal : grow.terminal=(p,rg) := by
    have hh := grow.terminal_of_state hgrowLen (hgrowState Hgrow le_rfl)
    simpa only [hreach] using hh
  have hqpur : p+rg ≤ 1/128 := by linarith
  obtain ⟨pur,hpurLen,hpurCost,hpurState⟩ := exists_holding_path hp0 hrg.1 hqpur Hpur
  let rp := holdingResidual p rg Hpur
  have hrp0 := (holdingResidual_bounds hp0.le hrg.1 hqpur Hpur).1
  have hrpδ : rp ≤ δ := by
    have hdec := holdingResidual_exp_bound hp0.le hrg.1 hrgp hqpur Hpur
    have hm := mul_le_mul_of_nonneg_left hrgp
      (Real.exp_pos (-purificationRate*p*(Hpur : ℝ))).le
    exact hdec.trans (hm.trans hpurification)
  have hpurTerminal : pur.terminal=(p,rp) := pur.terminal_of_state hpurLen (hpurState Hpur le_rfl)
  have hsmall' : 4*(nominal.length : ℝ)*rp ≤ 1 := by
    have hm := mul_le_mul_of_nonneg_left hrpδ (by positivity : 0 ≤ 4*(nominal.length : ℝ))
    exact hm.trans hsmall
  obtain ⟨finish,hfinishLen,hfinishCost,hfinishState⟩ :=
    stable_scalar_channel_path_relative_cost nominal hrp0 (hrpδ.trans_lt hδ1) hsmall'
  have hfinishCost' : finish.cost ≤ (1+4*(nominal.length : ℝ)*δ)*nominal.cost := by
    apply hfinishCost.trans
    apply mul_le_mul_of_nonneg_right _ nominal.cost_nonneg
    have hm := mul_le_mul_of_nonneg_left hrpδ (by positivity : 0 ≤ 4*(nominal.length : ℝ))
    linarith
  have hholdFloor : hold.SignalFloor (v/2) := by
    intro j hj
    rw [hholdLen] at hj
    rw [hholdState j hj]
    dsimp only
    linarith
  have hgrowFloor : grow.SignalFloor (v/2) := by
    intro j hj
    rw [hgrowLen] at hj
    rw [hgrowState j hj]
    exact (show v/2 ≤ v by linarith).trans (growthSchedule_bounds hv.le hvp j).1
  have hpurFloor : pur.SignalFloor (v/2) := by
    intro j hj
    rw [hpurLen] at hj
    rw [hpurState j hj]
    dsimp only
    linarith
  have hfinishFloor : finish.SignalFloor (v/2) := by
    intro j hj
    rw [hfinishLen] at hj
    have hstate := hfinishState j hj
    have hqfloor := nominal.state_floor hinc j
    have hbern := one_add_mul_le_pow (show (-2:ℝ) ≤ -rp by linarith) (2*j)
    have hjcast : (j:ℝ) ≤ nominal.length := by exact_mod_cast hj
    have hmulj := mul_le_mul_of_nonneg_right hjcast hrp0
    have hhalf : (1/2:ℝ) ≤ (1-rp)^(2*j) := by
      simp only [Nat.cast_mul,Nat.cast_ofNat] at hbern
      have he : 1+(-rp)=1-rp := by ring
      rw [he] at hbern
      nlinarith
    have hproduct := mul_le_mul hhalf hqfloor hp0.le
      (pow_nonneg (show 0 ≤ 1-rp by linarith) _)
    have hh := hproduct.trans hstate.2.1
    nlinarith
  obtain ⟨pf,hpfLen,hpfTerminal,hpfHidden,hpfCost,hpfFloor⟩ :=
    pur.exists_append_floor finish hpurTerminal hpurFloor hfinishFloor
  obtain ⟨gpf,hgpfLen,hgpfTerminal,hgpfHidden,hgpfCost,hgpfFloor⟩ :=
    grow.exists_append_floor pf hgrowTerminal hgrowFloor hpfFloor
  obtain ⟨P,hPLen,hPTerminal,hPHidden,hPCost,hPFloor⟩ :=
    hold.exists_append_floor gpf hholdTerminal hholdFloor hgpfFloor
  refine ⟨P,?_,?_,hPFloor⟩
  · omega
  · have hholdSq := pow_le_pow_left₀ (add_nonneg hv.le hr)
      (show v+r ≤ 2*p by linarith) 2
    have hholdMul := mul_le_mul_of_nonneg_left hholdSq (by positivity : 0 ≤ 64*(Hhold : ℝ))
    have hholdCost' : hold.hiddenCost ≤ 256*(Hhold : ℝ)*p^2 := by nlinarith
    have hpurSq := pow_le_pow_left₀ (add_nonneg hp0.le hrg.1)
      (show p+rg ≤ 2*p by linarith) 2
    have hpurMul := mul_le_mul_of_nonneg_left hpurSq (by positivity : 0 ≤ 64*(Hpur : ℝ))
    have hpurCost' : pur.hiddenCost ≤ 256*(Hpur : ℝ)*p^2 := by nlinarith
    rw [hPCost,hgpfCost,hpfCost]
    nlinarith only [hholdCost',hgrowCost,hpurCost',hfinishCost']

#print axioms exists_prepared_scalar_channel_path
end ConditionalNonpolynomial.Analytic
