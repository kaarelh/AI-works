import ScalarTargetPreparation

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.BatchTwoContinuousDepthCritical

def cooledSeedFloor (v : ℝ) (H : ℕ) : ℝ :=
  v*Real.exp (-2*(1+Real.log ((H : ℝ)+1))/(coolingConstant*derivativeFloor))

theorem cooledSeedFloor_pos {v : ℝ} (hv : 0 < v) (H : ℕ) : 0 < cooledSeedFloor v H :=
  mul_pos hv (Real.exp_pos _)

theorem cooledSeedFloor_antitone {v : ℝ} (hv : 0 ≤ v) {H J : ℕ} (hHJ : H ≤ J) :
    cooledSeedFloor v J ≤ cooledSeedFloor v H := by
  have hlog := Real.log_le_log (by positivity : 0 < (H : ℝ)+1)
    (show (H : ℝ)+1 ≤ (J : ℝ)+1 by exact_mod_cast Nat.add_le_add_right hHJ 1)
  have hc := coolingConstant_pos
  have hd := derivativeFloor_pos
  have he : -2*(1+Real.log ((J : ℝ)+1))/(coolingConstant*derivativeFloor) ≤
      -2*(1+Real.log ((H : ℝ)+1))/(coolingConstant*derivativeFloor) :=
    div_le_div_of_nonneg_right (by linarith) (mul_nonneg hc.le hd.le)
  exact mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr he) hv

theorem freeCoolingState_uniform_floor {v r : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r)
    (hq : v+r ≤ 1) {H j : ℕ} (hj : j ≤ H) :
    cooledSeedFloor v H ≤ (freeCoolingState v r j).1 :=
  (cooledSeedFloor_antitone hv hj).trans (freeCoolingState_signal_exp_lower hv hr hq j)

theorem exists_cooled_prepared_scalar_channel_path {v r p δ : ℝ}
    (hv : 0 < v) (hr : 0 ≤ r) (hq : v+r ≤ 1)
    (hp0 : 0 < p) (hp : p ≤ 1/256) (hδ : 0 ≤ δ) (hδ1 : δ < 1)
    (Hcool Hhold Hgrow Hpur : ℕ) (nominal : ScalarPath p) (hinc : nominal.Increasing)
    (hcooling : 1 ≤ p*(1+coolingConstant*(Hcool : ℝ)))
    (hgrowth : Real.log (p/cooledSeedFloor v Hcool) ≤ (Hgrow : ℝ)*p)
    (hpurification : Real.exp (-purificationRate*p*(Hpur : ℝ))*p ≤ δ)
    (hsmall : 4*(nominal.length : ℝ)*δ ≤ 1) :
    ∃ P : ScalarChannelPath v r,
      P.length=Hcool+Hhold+Hgrow+Hpur+nominal.length ∧
      P.cost ≤ 256*((Hhold : ℝ)+Hgrow+Hpur)*p^2+
        (1+4*(nominal.length : ℝ)*δ)*nominal.cost ∧
      P.SignalFloor (cooledSeedFloor v Hcool/2) := by
  obtain ⟨cool,hcoolLen,hcoolCost,hcoolState⟩ := exists_freeCooling_path hv hr hq Hcool
  let vc := (freeCoolingState v r Hcool).1
  let rc := (freeCoolingState v r Hcool).2
  have hnon := freeCoolingState_nonneg hv.le hr Hcool
  have hfloor := freeCoolingState_uniform_floor hv.le hr hq (le_refl Hcool)
  have hfpos := cooledSeedFloor_pos hv Hcool
  have hvc : 0 < vc := hfpos.trans_le hfloor
  have hsum := freeCoolingState_small hv.le hr hq hp0 Hcool hcooling
  have hvcp : vc ≤ p := by linarith
  have hrcp : rc ≤ p := by linarith
  have hterminal : cool.terminal=(vc,rc) := by
    have hh := cool.terminal_of_state hcoolLen (hcoolState Hcool le_rfl)
    exact hh
  have hgrowth' : Real.log (p/vc) ≤ (Hgrow : ℝ)*p := by
    apply (Real.log_le_log (div_pos hp0 hvc) ?_).trans hgrowth
    exact div_le_div_of_nonneg_left hp0.le hfpos hfloor
  obtain ⟨tail,htailLen,htailCost,htailFloor⟩ := exists_prepared_scalar_channel_path
    hvc hvcp hnon.2 hrcp hp hδ hδ1 Hhold Hgrow Hpur nominal hinc hgrowth' hpurification hsmall
  have hcoolFloor : cool.SignalFloor (cooledSeedFloor v Hcool/2) := by
    intro j hj
    rw [hcoolLen] at hj
    rw [hcoolState j hj]
    exact (show cooledSeedFloor v Hcool/2 ≤ cooledSeedFloor v Hcool by linarith).trans
      (freeCoolingState_uniform_floor hv.le hr hq hj)
  have htailFloor' : tail.SignalFloor (cooledSeedFloor v Hcool/2) := by
    intro j hj
    exact (show cooledSeedFloor v Hcool/2 ≤ vc/2 by linarith).trans (htailFloor j hj)
  obtain ⟨P,hPLen,hPTerminal,hPHidden,hPCost,hPFloor⟩ :=
    cool.exists_append_floor tail hterminal hcoolFloor htailFloor'
  refine ⟨P,?_,?_,hPFloor⟩
  · omega
  · rw [hPCost,hcoolCost,zero_add]
    exact htailCost

#print axioms exists_cooled_prepared_scalar_channel_path
end ConditionalNonpolynomial.Analytic
