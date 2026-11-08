import NeuralGeneralization.OnlineLowerTanhGeometryPhysical

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerGeometry
open OnlineLowerRelu OnlineLowerTanh

theorem rectangle_variance_budget_of_downward_deficit {p m:ℕ}
    (size:Fin p→Bool→ℕ) (column:Fin p→Finset (Fin m))
    (hsize:∀i b,0<size i b) (heven:∀i b,Even (size i b))
    (C:WalshCodeMap (carrierDimension size) m)
    (hsupport:∀s,C.support s=carrierSupport size column s)
    (w:Finset (Fin m)→ℝ) (H:CubeSubgroup m) (v u:ClippingCube m)
    (hw:RectangleCostConditions w u) (hu:u∉H.carrier) (hv:v∉(H.adjoinPoint u).carrier)
    (hE:2≤((H.adjoinPoint u).differenceAnnihilator v).card)
    (hind:∀i z,z∉rectangleObserved H v u → cubeTranslation (logicalColumnPoint column i) z∈rectangleObserved H v u)
    (F:ClippingCube (carrierDimension size)→ℝ) (B L K Bcap:ℝ)
    (hB:0≤B) (hL:0≤L) (hK:0≤K) (hcap:∀x,|F x|≤L)
    (hcal:∀x,cubeTranslation v (C.syndrome x)∉H.carrier →
      (1:ℝ)/2≤(if C.syndrome x=cubeOne m then 1 else -1)*(C.base x*F x))
    (hcost:weightedWalshCost w (C.logicalProjection F)≤B) (hbudget:B≤Bcap)
    (hdownward:uniformCubeMean (fun x=>(F x-fourierProject (carrierOddDownwardSupports size column) F x)^2)≤
      K*B*(B-weightedWalshCost w (C.logicalProjection F))) :
    uniformCubeMean (fun x=>(F x-C.project F x)^2)≤
      (16*L/rectangleCommonA w u+5*K*Bcap)*
        (rectangleLogicalDeficit w H v u (C.logicalProjection F) B+
          rectangleLogicalSlack w H v u (C.logicalProjection F)) := by
  let D:=rectangleLogicalDeficit w H v u (C.logicalProjection F) B
  let S:=rectangleLogicalSlack w H v u (C.logicalProjection F)
  let mass:=weightedWalshCost w (C.logicalProjection F)
  have hdual:=walsh_dual_bound w (C.logicalProjection F) (rectangleLogicalDual w H v u) (fun s=>by
    rw [rectangleLogicalDual,walshCoefficients_expansion]
    exact hw.coefficients_feasible (H.adjoinPoint u) v (H.point_mem_adjoinPoint u) hE s)
  have hgap:B-mass≤D:=by
    dsimp [D,rectangleLogicalDeficit,fourierDualDeficit,mass]
    exact sub_le_sub_left hdual B
  have hD:0≤D:=hw.logical_deficit_nonneg H v hE _ B hcost
  have hvH:v∉H.carrier:=fun hh=>hv (H.subset_adjoinPoint u hh)
  obtain ⟨hanchor,hnegative⟩:=C.relu_projection_calibration_margins H v hvH F hcal
  have hS:0≤S:=hw.logical_slack_nonneg H v hu hv (by omega) _ hanchor hnegative
  have hdown:uniformCubeMean (fun x=>(F x-fourierProject (carrierOddDownwardSupports size column) F x)^2)≤K*Bcap*D:=by
    calc
      _ ≤ K*B*(B-mass):=hdownward
      _ ≤ K*B*D:=mul_le_mul_of_nonneg_left hgap (mul_nonneg hK hB)
      _ ≤ _:=by have hh:=mul_le_mul_of_nonneg_left hbudget (mul_nonneg hK hD); nlinarith
  have hvar:=actual_carrier_rectangle_variance size column hsize heven C hsupport w H v u hw hu hv
    (by omega) hind F L hL hcap hcal
  have ha:=hw.parameter_bounds.2.2.1
  have hBcap:0≤Bcap:=hB.trans hbudget
  have hc1:0≤(16*L/rectangleCommonA w u)*D:=by positivity
  have hc2:0≤(5*K*Bcap)*S:=by positivity
  change uniformCubeMean (fun x=>(F x-C.project F x)^2)≤
    (16*L/rectangleCommonA w u+5*K*Bcap)*(D+S)
  change uniformCubeMean (fun x=>(F x-C.project F x)^2)≤
    (16*L/rectangleCommonA w u)*S+5*uniformCubeMean (fun x=>
      (F x-fourierProject (carrierOddDownwardSupports size column) F x)^2) at hvar
  nlinarith

end NeuralGeneralization.OnlineLowerGeometry
