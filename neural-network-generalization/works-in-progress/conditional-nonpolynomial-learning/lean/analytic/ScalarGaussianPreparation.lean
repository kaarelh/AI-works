import ScalarGaussianPhases
import ScalarTargetCooling

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
namespace ConditionalNonpolynomial.Analytic

theorem exists_gaussian_prepared_prefix {p v r δ : ℝ}
    (hv : 0 < v) (hvp : v ≤ p) (hr : 0 ≤ r) (hrp : r ≤ p)
    (hp : p ≤ 1/256)
    (Hhold Hgrow Hpur : ℕ)
    (hgrowth : Real.log (p/v) ≤ (Hgrow : ℝ)*p)
    (hpurification : Real.exp (-purificationRate*p*(Hpur : ℝ))*p ≤ δ) :
    ∃ P : ScalarChannelPath v r,
      P.length=Hhold+Hgrow+Hpur ∧
      P.terminal.1=p ∧ 0 ≤ P.terminal.2 ∧ P.terminal.2 ≤ δ ∧
      P.hiddenCost ≤ 256*((Hhold : ℝ)+Hgrow+Hpur)*p^2 ∧
      P.SignalFloor v ∧ P.GaussianControls := by
  have hp0 : 0 < p := hv.trans_le hvp
  have hq : v+r ≤ 1/128 := by linarith
  obtain ⟨hold,hholdLen,hholdCost,hholdGaussian,hholdState⟩ := exists_holding_gaussian_path hv hr hq Hhold
  let rh := holdingResidual v r Hhold
  have hrh := holdingResidual_bounds hv.le hr hq Hhold
  have hholdTerminal : hold.terminal=(v,rh) := hold.terminal_of_state hholdLen
    (hholdState Hhold le_rfl)
  obtain ⟨grow,hgrowLen,hgrowCost,hgrowGaussian,hgrowState⟩ :=
    exists_growth_gaussian_path hv hvp hrh.1 (hrh.2.trans hrp) hp Hgrow
  let rg := growthResidual p v rh Hgrow
  have hrg := growthResidual_bounds hv.le hvp hrh.1 (hrh.2.trans hrp) hp Hgrow
  have hrgp : rg ≤ p := hrg.2.trans (hrh.2.trans hrp)
  have hreach := growthSchedule_reaches hv hvp (show p ≤ 1 by linarith) Hgrow hgrowth
  have hgrowTerminal : grow.terminal=(p,rg) := by
    have hh := grow.terminal_of_state hgrowLen (hgrowState Hgrow le_rfl)
    simpa only [hreach] using hh
  have hqpur : p+rg ≤ 1/128 := by linarith
  obtain ⟨pur,hpurLen,hpurCost,hpurGaussian,hpurState⟩ := exists_holding_gaussian_path hp0 hrg.1 hqpur Hpur
  let rp := holdingResidual p rg Hpur
  have hrp0 := (holdingResidual_bounds hp0.le hrg.1 hqpur Hpur).1
  have hrpδ : rp ≤ δ := by
    have hdec := holdingResidual_exp_bound hp0.le hrg.1 hrgp hqpur Hpur
    have hm := mul_le_mul_of_nonneg_left hrgp
      (Real.exp_pos (-purificationRate*p*(Hpur : ℝ))).le
    exact hdec.trans (hm.trans hpurification)
  have hpurTerminal : pur.terminal=(p,rp) := pur.terminal_of_state hpurLen (hpurState Hpur le_rfl)
  have hholdFloor : hold.SignalFloor v := by
    intro j hj
    rw [hholdLen] at hj
    rw [hholdState j hj]
  have hgrowFloor : grow.SignalFloor v := by
    intro j hj
    rw [hgrowLen] at hj
    rw [hgrowState j hj]
    exact (growthSchedule_bounds hv.le hvp j).1
  have hpurFloor : pur.SignalFloor v := by
    intro j hj
    rw [hpurLen] at hj
    rw [hpurState j hj]
    exact hvp
  obtain ⟨gp,hgpLen,hgpTerminal,hgpHidden,hgpFloor,hgpGaussian⟩ :=
    grow.exists_append_gaussian pur hgrowTerminal hgrowFloor hpurFloor hgrowGaussian hpurGaussian
  obtain ⟨P,hPLen,hPTerminal,hPHidden,hPFloor,hPGaussian⟩ :=
    hold.exists_append_gaussian gp hholdTerminal hholdFloor hgpFloor hholdGaussian hgpGaussian
  have hPT : P.terminal=(p,rp) := hPTerminal.trans (hgpTerminal.trans hpurTerminal)
  refine ⟨P,?_,?_,?_,?_,?_,hPFloor,hPGaussian⟩
  · omega
  · rw [hPT]
  · rw [hPT]; exact hrp0
  · rw [hPT]; exact hrpδ
  · have hholdSq := pow_le_pow_left₀ (add_nonneg hv.le hr)
      (show v+r ≤ 2*p by linarith) 2
    have hholdMul := mul_le_mul_of_nonneg_left hholdSq (by positivity : 0 ≤ 64*(Hhold : ℝ))
    have hholdCost' : hold.hiddenCost ≤ 256*(Hhold : ℝ)*p^2 := by nlinarith
    have hpurSq := pow_le_pow_left₀ (add_nonneg hp0.le hrg.1)
      (show p+rg ≤ 2*p by linarith) 2
    have hpurMul := mul_le_mul_of_nonneg_left hpurSq (by positivity : 0 ≤ 64*(Hpur : ℝ))
    have hpurCost' : pur.hiddenCost ≤ 256*(Hpur : ℝ)*p^2 := by nlinarith
    rw [hPHidden,hgpHidden]
    nlinarith only [hholdCost',hgrowCost,hpurCost']

#print axioms exists_gaussian_prepared_prefix
end ConditionalNonpolynomial.Analytic
