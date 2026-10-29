import PolynomialTargetProgram
import MemorizerBoolean

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization

def targetExcessConstant : ℝ := 692224*targetProgramConstant^2+4

theorem critical_seed_cost_absorbed {R H : ℝ} (hR : 2≤R) (hH : 0<H) :
    1/H+692224*targetProgramConstant^2*(Real.log R)^2/H≤
      targetExcessConstant*(Real.log R)^2/H := by
  have hl := logarithm_half_le hR
  have hnum : 1+692224*targetProgramConstant^2*(Real.log R)^2≤
      targetExcessConstant*(Real.log R)^2 := by unfold targetExcessConstant; nlinarith
  simpa only [add_div] using div_le_div_of_nonneg_right hnum hH.le

/-- A literal sample memorizer has an actual exact-depth scalar program with
polynomially bounded scores and only log-squared-over-depth excess action. -/
theorem exists_critical_memorizer_program {d n H : ℕ}
    (sample : Fin n→ClippingCube d) (f : ClippingCube d→Bool)
    (hd : 1≤d) (hH : 1≤H) {R : ℝ} (hR : 2≤R)
    (hdR : (d:ℝ)+1≤R) (hnR : (n:ℝ)≤R) (hHR : (H:ℝ)+1≤R)
    (hdepth : 6656*targetProgramConstant*Real.log R≤(H:ℝ)) :
    let g := pointExceptionFunction (negativeSamplePoints sample f)
    let D := seedEntropyBudget d (1/Real.sqrt d)
    let θ := rareCalibration D H
    let β := Real.exp (-targetSignalExponent*Real.log R)
    let B := Real.exp (targetSignalExponent*Real.log R)
    0<θ ∧ θ≤1 ∧ 0<β ∧ 1≤B ∧ 1/Real.sqrt θ≤B ∧ 1/Real.sqrt β≤B ∧
    ∃ P : ScalarChannelPath (rareSeedSignal g (1/Real.sqrt d) θ)
        (rareSeedResidual g (1/Real.sqrt d) θ),
      P.length=H ∧
      θ*D+P.cost≤scalarBaseline.toReal+targetExcessConstant*(Real.log R)^2/(H:ℝ) ∧
      P.SignalFloor β ∧ P.terminal.1≤1 := by
  let g := pointExceptionFunction (negativeSamplePoints sample f)
  let D := seedEntropyBudget d (1/Real.sqrt d)
  let θ := rareCalibration D H
  let v := rareSeedSignal g (1/Real.sqrt d) θ
  let r := rareSeedResidual g (1/Real.sqrt d) θ
  have hs := critical_memorizer_seed_state sample f hd hH hR hdR hnR hHR
  rcases hs with ⟨hθ,hθ1,hv,hr,hq,hvR,hT,hscore⟩
  obtain ⟨P,hlen,hcost,hfloor,hterminal,hPscore⟩ :=
    exists_polynomial_nearbaseline_channel hv hr hq hR hvR H hHR hdepth
  have hHreal : (1:ℝ)≤H := by exact_mod_cast hH
  have hHpos : (0:ℝ)<H := by linarith
  have hDpoly := critical_seed_entropy_polynomial hd hR hdR
  have hBseed := (calibrated_score_polynomial (seedEntropyBudget_nonneg d (1/Real.sqrt d))
    hHreal hR hDpoly (by linarith : (H:ℝ)≤R)).trans (thirteenth_power_le_targetBound hR)
  have hB : 1≤Real.exp (targetSignalExponent*Real.log R) := Real.one_le_exp_iff.mpr
    (mul_nonneg targetSignalExponent_pos.le (by linarith [logarithm_half_le hR]))
  refine ⟨hθ,hθ1,Real.exp_pos _,hB,hBseed,inverse_sqrt_polynomialFloor_le hR,
    P,hlen,?_,hfloor,hterminal⟩
  have hseed := (rareCalibration_bounds (seedEntropyBudget_nonneg d (1/Real.sqrt d)) hHreal).2.2
  have habs := critical_seed_cost_absorbed hR hHpos
  change θ*D≤1/(H:ℝ) at hseed
  linarith

#print axioms exists_critical_memorizer_program
end ConditionalNonpolynomial.Analytic
