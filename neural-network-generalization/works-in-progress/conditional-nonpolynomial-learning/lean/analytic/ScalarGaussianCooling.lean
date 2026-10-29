import ScalarGaussianPreparation

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.BatchTwoContinuousDepthCritical

theorem exists_cooled_gaussian_prepared_prefix {v r p δ : ℝ}
    (hv : 0 < v) (hr : 0 ≤ r) (hq : v+r ≤ 1)
    (hp0 : 0 < p) (hp : p ≤ 1/256)
    (Hcool Hhold Hgrow Hpur : ℕ)
    (hcooling : 1 ≤ p*(1+coolingConstant*(Hcool : ℝ)))
    (hgrowth : Real.log (p/cooledSeedFloor v Hcool) ≤ (Hgrow : ℝ)*p)
    (hpurification : Real.exp (-purificationRate*p*(Hpur : ℝ))*p ≤ δ) :
    ∃ P : ScalarChannelPath v r,
      P.length=Hcool+Hhold+Hgrow+Hpur ∧
      P.terminal.1=p ∧ 0 ≤ P.terminal.2 ∧ P.terminal.2 ≤ δ ∧
      P.hiddenCost ≤ 256*((Hhold : ℝ)+Hgrow+Hpur)*p^2 ∧
      P.SignalFloor (cooledSeedFloor v Hcool) ∧ P.GaussianControls := by
  obtain ⟨cool,hcoolLen,hcoolCost,hcoolGaussian,hcoolState⟩ :=
    exists_freeCooling_gaussian_path hv hr hq Hcool
  let vc := (freeCoolingState v r Hcool).1
  let rc := (freeCoolingState v r Hcool).2
  have hnon := freeCoolingState_nonneg hv.le hr Hcool
  have hfloor := freeCoolingState_uniform_floor hv.le hr hq (le_refl Hcool)
  have hfpos := cooledSeedFloor_pos hv Hcool
  have hvc : 0 < vc := hfpos.trans_le hfloor
  have hsum := freeCoolingState_small hv.le hr hq hp0 Hcool hcooling
  have hvcp : vc ≤ p := by linarith
  have hrcp : rc ≤ p := by linarith
  have hterminal : cool.terminal=(vc,rc) :=
    cool.terminal_of_state hcoolLen (hcoolState Hcool le_rfl)
  have hgrowth' : Real.log (p/vc) ≤ (Hgrow : ℝ)*p := by
    apply (Real.log_le_log (div_pos hp0 hvc) ?_).trans hgrowth
    exact div_le_div_of_nonneg_left hp0.le hfpos hfloor
  obtain ⟨tail,htailLen,htailV,htailR0,htailR,htailCost,htailFloor,htailGaussian⟩ :=
    exists_gaussian_prepared_prefix hvc hvcp hnon.2 hrcp hp Hhold Hgrow Hpur hgrowth' hpurification
  have hcoolFloor : cool.SignalFloor (cooledSeedFloor v Hcool) := by
    intro j hj
    rw [hcoolLen] at hj
    rw [hcoolState j hj]
    exact freeCoolingState_uniform_floor hv.le hr hq hj
  have htailFloor' : tail.SignalFloor (cooledSeedFloor v Hcool) := by
    intro j hj
    exact hfloor.trans (htailFloor j hj)
  obtain ⟨P,hPLen,hPTerminal,hPHidden,hPFloor,hPGaussian⟩ :=
    cool.exists_append_gaussian tail hterminal hcoolFloor htailFloor' hcoolGaussian htailGaussian
  refine ⟨P,?_,?_,?_,?_,?_,hPFloor,hPGaussian⟩
  · omega
  · rw [hPTerminal]; exact htailV
  · rw [hPTerminal]; exact htailR0
  · rw [hPTerminal]; exact htailR
  · rw [hPHidden,hcoolCost,zero_add]
    exact htailCost

#print axioms exists_cooled_gaussian_prepared_prefix
end ConditionalNonpolynomial.Analytic
