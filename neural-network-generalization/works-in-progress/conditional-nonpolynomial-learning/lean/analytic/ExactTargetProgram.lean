import ScalarTargetCooling
import ScalarShortPath
import TargetProgramResidual

noncomputable section
set_option maxHeartbeats 3000000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.BatchTwoContinuousDepthCritical

def targetCoolingLogConstant : ℝ := 2/(coolingConstant*derivativeFloor)
def targetTailLengthConstant : ℝ := 3*scalarBandLengthConstant 526336
def targetProgramConstant : ℝ := targetAllocationConstant coolingConstant purificationRate
  targetCoolingLogConstant targetTailLengthConstant

theorem targetCoolingLogConstant_pos : 0<targetCoolingLogConstant :=
  div_pos (by norm_num) (mul_pos coolingConstant_pos derivativeFloor_pos)

theorem targetTailLengthConstant_pos : 0<targetTailLengthConstant :=
  mul_pos (by norm_num) (scalarBandLengthConstant_pos (by norm_num))

theorem targetProgramConstant_ge : 16≤targetProgramConstant := by
  have hc : 0<1/coolingConstant := div_pos (by norm_num) coolingConstant_pos
  have hp : 0<3/purificationRate := div_pos (by norm_num) purificationRate_pos
  unfold targetProgramConstant targetAllocationConstant
  linarith [targetCoolingLogConstant_pos,targetTailLengthConstant_pos]

/-- Actual exact-depth scalar control program, with universal quantitative
near-baseline cost and a lower bound on every tracked signal component. -/
theorem exists_exact_nearbaseline_channel {v r : ℝ} (hv : 0<v) (hr : 0≤r)
    (hq : v+r≤1) (H : ℕ)
    (hH : 256*targetProgramConstant*targetLogBudget v H≤(H:ℝ)) :
    ∃ P : ScalarChannelPath v r, P.length=H ∧
      P.cost≤scalarBaseline.toReal+
        1024*targetProgramConstant^2*(targetLogBudget v H)^2/(H:ℝ) ∧
      P.SignalFloor (cooledSeedFloor v H/2) := by
  let T := targetLogBudget v H
  let A := targetProgramConstant
  let K := targetCoolingLogConstant
  let B := targetTailLengthConstant
  let p := targetScale coolingConstant purificationRate K B T H
  let δ := targetResidual p H
  have hv1 : v≤1 := by linarith
  have hT : 1≤T := targetLogBudget_ge_one hv hv1 H
  have hA : 16≤A := targetProgramConstant_ge
  have hK : 0≤K := targetCoolingLogConstant_pos.le
  have hB : 0≤B := targetTailLengthConstant_pos.le
  have hp := targetScale_bounds coolingConstant_pos purificationRate_pos hK hB hT hH
  have hH0 : 0<(H:ℝ) := lt_of_lt_of_le (by positivity) hH
  have hpH : p*(H:ℝ)=A*T := by dsimp [p,targetScale,A,targetProgramConstant,K,B,T]; field_simp
  have hHp : 1≤(H:ℝ)*p := by nlinarith
  obtain ⟨nominal,hinc,hnomCost,hnomLength⟩ := exists_short_nearOptimal_scalarPath hp.1
    (hp.2.trans (by norm_num))
  let Hcool := targetCoolingLength coolingConstant p
  let Hgrow := targetGrowthLength K T p
  let Hpur := targetPurificationLength purificationRate T p
  have hbudget := targetLengths_budget coolingConstant_pos purificationRate_pos hK hB hT hH hnomLength
  have hsum : Hcool+Hgrow+Hpur+nominal.length≤H := by
    have hreal : ((Hcool+Hgrow+Hpur+nominal.length:ℕ):ℝ)≤(H:ℝ) := by
      apply hbudget.trans
      have hzero : 0≤(H:ℝ) := Nat.cast_nonneg _
      linarith
    exact_mod_cast hreal
  have hcoolH : Hcool≤H := by omega
  have hnomH : nominal.length≤H := by omega
  let Hhold := H-(Hcool+Hgrow+Hpur+nominal.length)
  have hlength : Hcool+Hhold+Hgrow+Hpur+nominal.length=H := by dsimp [Hhold]; omega
  have hδbounds := targetResidual_bounds hp.1 hp.2 hnomH
  have hrequirements := targetLengths_requirements coolingConstant_pos purificationRate_pos hp.1 (K:=K) (T:=T)
  have hcooling : 1≤p*(1+coolingConstant*(Hcool:ℝ)) := by
    have hh := (div_le_iff₀ (mul_pos coolingConstant_pos hp.1)).mp hrequirements.1
    change 1≤(Hcool:ℝ)*(coolingConstant*p) at hh
    nlinarith
  have hfloor : v*Real.exp (-K*(1+Real.log ((H:ℝ)+1)))≤cooledSeedFloor v Hcool := by
    have he : v*Real.exp (-K*(1+Real.log ((H:ℝ)+1)))=cooledSeedFloor v H := by
      unfold cooledSeedFloor
      congr 1
      dsimp [K,targetCoolingLogConstant]
      ring
    rw [he]
    exact cooledSeedFloor_antitone hv.le hcoolH
  have hgrowth := (targetLogBudget_cooled_ratio H hv hv1 hp.1 (hp.2.trans (by norm_num)) hK hfloor).trans
    hrequirements.2.1
  have hlogT : Real.log ((H:ℝ)+1)≤T := by
    have hlogv := Real.log_nonneg ((le_div_iff₀ hv).mpr (show 1*v≤1 by linarith))
    dsimp [T,targetLogBudget]
    linarith
  have hpurification := target_purification_residual H purificationRate_pos hp.1 hlogT
  have hsmall : 4*(nominal.length:ℝ)*δ≤1 := hδbounds.2.2.trans (hp.2.trans (by norm_num))
  obtain ⟨P,hPLen,hPCost,hPFloor⟩ := exists_cooled_prepared_scalar_channel_path hv hr hq hp.1 hp.2
    hδbounds.1.le hδbounds.2.1 Hcool Hhold Hgrow Hpur nominal hinc hcooling hgrowth hpurification hsmall
  refine ⟨P,hPLen.trans hlength,?_,?_⟩
  · have hnom : nominal.cost≤scalarBaseline.toReal+p := by
      have hh := scalarValue_le_baseline hp.1
      change nominal.cost<scalarValue p+p at hnomCost
      linarith
    have hphase : (Hhold:ℝ)+Hgrow+Hpur≤(H:ℝ) := by
      have hnat : Hhold+Hgrow+Hpur≤H := by omega
      exact_mod_cast hnat
    have hh := targetProgram_cost_bound hp.1 hp.2 hHp hnomH scalarBaseline_pos.le scalarBaseline_le hnom hphase
    apply (hPCost.trans hh).trans_eq
    congr 1
    dsimp [p,targetScale,A,targetProgramConstant,K,B,T]
    field_simp
  · intro j hj
    exact (div_le_div_of_nonneg_right (cooledSeedFloor_antitone hv.le hcoolH) (by norm_num)).trans (hPFloor j hj)

#print axioms exists_exact_nearbaseline_channel
end ConditionalNonpolynomial.Analytic
