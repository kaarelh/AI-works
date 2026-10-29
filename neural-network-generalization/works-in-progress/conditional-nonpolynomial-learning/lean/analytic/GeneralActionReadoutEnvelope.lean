import FarStrongActionEnvelope

/-! The readout estimate holds throughout the physical scaling interval. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup

 def generalActionReadoutExponent (B : ℝ) : ℕ :=⌈(4*B+522)*(1+1/Real.log 2)⌉₊+1

 theorem general_action_readout_bound {d H : ℕ} {t R B : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hH : 1≤H) (hB : 0≤B) (hR : 2≤R)
    (hHR : (H:ℝ)+1≤R) (hnear : P.action≤denominatorBudget B t R H) :
    ‖P.readout‖≤(4*B+522)*R := by
  have ht:=P.scale_positive
  have ht1:=P.scale_le_one
  have hH0:(0:ℝ)<H:=by exact_mod_cast (show 0<H by omega)
  have hn:=denominatorBudget_normalized hB ht ht1 hH hR hHR
  have hnorm:t^2*P.action≤(2*B+260)*R^2:=by
    have hh:=mul_le_mul_of_nonneg_left hnear (sq_nonneg t)
    have hp:0≤2/(t^2*(H:ℝ)):=by positivity
    nlinarith
  have hcost:‖P.readout‖^2≤2*(t^2*P.action):=by
    have hs:0≤∑j∈Finset.range H,physicalLayerCost P j:=
      Finset.sum_nonneg (fun _ _=>ENNReal.toReal_nonneg)
    rw [farStrong_action_split P]
    field_simp
    nlinarith [mul_nonneg (sq_nonneg t) hs]
  have hcoef:0≤4*B+522:=by linarith
  have hcoefsq:4*B+520≤(4*B+522)^2:=by nlinarith [sq_nonneg B]
  have hsq:=mul_le_mul_of_nonneg_right hcoefsq (sq_nonneg R)
  have hp:0≤(4*B+522)*R:=mul_nonneg hcoef (by linarith)
  nlinarith [norm_nonneg P.readout]

 theorem general_action_readout_polynomial {d H : ℕ} {t R B : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hH : 1≤H) (hB : 0≤B) (hR : 2≤R)
    (hHR : (H:ℝ)+1≤R) (hnear : P.action≤denominatorBudget B t R H) :
    ‖P.readout‖≤R^(generalActionReadoutExponent B) := by
  have hc:0≤4*B+522:=by linarith
  have hh:=resource_mul hR (resource_constant hc hR)
    (a:=⌈(4*B+522)*(1+1/Real.log 2)⌉₊) (b:=1) (by simp : R≤R^1) (by linarith : 0≤R)
  exact (general_action_readout_bound P hH hB hR hHR hnear).trans hh

#print axioms general_action_readout_bound
#print axioms general_action_readout_polynomial
end ConditionalNonpolynomial.Analytic
