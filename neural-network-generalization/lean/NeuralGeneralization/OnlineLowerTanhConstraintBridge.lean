import NeuralGeneralization.OnlineLowerTanhGeometryClosed
import NeuralGeneralization.OnlineLowerTanhVarianceBudget
import NeuralGeneralization.OnlineLowerNetworkActivation
import NeuralGeneralization.Activation

/-! # Actual tanh outputs satisfy the closed rectangle constraints -/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLower
open ConcreteModel OnlineLowerRelu OnlineLowerTanh OnlineLowerGeometry

theorem actual_tanh_mem_rectangle_constraints {p m N:ℕ}
    (size:Fin p → Bool → ℕ) (column:Fin p → Finset (Fin m))
    (hsize:∀i b,0<size i b) (heven:∀i b,Even (size i b)) (hN:0<N)
    (C:WalshCodeMap (carrierDimension size) m)
    (hsupport:∀s,C.support s=carrierSupport size column s)
    (weight:Finset (Fin m) → ℝ) (H:CubeSubgroup m) (v u:ClippingCube m)
    (live:ClippingCube m → Prop) (hw:RectangleCostConditions weight u)
    (hu:u∉H.carrier) (hv:v∉(H.adjoinPoint u).carrier)
    (hE:2≤((H.adjoinPoint u).differenceAnnihilator v).card)
    (hind:∀i z,z∉rectangleObserved H v u → cubeTranslation (logicalColumnPoint column i) z∈rectangleObserved H v u)
    (net:Weights (carrierDimension size) N 0) (K Bcap:ℝ)
    (hK:0≤K) (hBcap:0≤Bcap)
    (hmargin:∀x,(1:ℝ)/2≤|networkOutput Real.tanh net x|)
    (hcal:∀x,cubeTranslation v (C.syndrome x)∉H.carrier →
      (1:ℝ)/2≤(if C.syndrome x=cubeOne m then 1 else -1)*(C.base x*networkOutput Real.tanh net x))
    (hremoved:∀z,¬live z → reluLiveMass H v (C.logicalProjection (networkOutput Real.tanh net)) z≤0)
    (hcap:weightedSquaredNorm net≤(2*Real.sqrt (carrierDimension size:ℝ))*Bcap)
    (hcost:weightedWalshCost weight (C.logicalProjection (networkOutput Real.tanh net))≤networkVariationBudget net)
    (hdownward:uniformCubeMean (fun x=>(networkOutput Real.tanh net x-
      fourierProject (carrierOddDownwardSupports size column) (networkOutput Real.tanh net) x)^2)≤
      K*networkVariationBudget net*(networkVariationBudget net-
        weightedWalshCost weight (C.logicalProjection (networkOutput Real.tanh net)))) :
    (weightedSquaredNorm net,networkOutput Real.tanh net)∈
      C.rectangleScoreConstraints weight H v u live (2*Real.sqrt (carrierDimension size:ℝ))
        (16*((2*Real.sqrt (carrierDimension size:ℝ))*Bcap)/rectangleCommonA weight u+5*K*Bcap) := by
  have hd:0<carrierDimension size:=by unfold carrierDimension; omega
  let scale:ℝ:=2*Real.sqrt (carrierDimension size:ℝ)
  have hscale:0<scale:=mul_pos (by norm_num) (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hd))
  have hB:0≤networkVariationBudget net:=div_nonneg (weightedSquaredNorm_nonneg net) hscale.le
  have hbudget:networkVariationBudget net≤Bcap:=by
    apply (div_le_iff₀ hscale).mpr
    simpa only [mul_comm] using hcap
  have hL:0≤scale*Bcap:=mul_nonneg hscale.le hBcap
  have hφ:∀t,|Real.tanh t|≤|t|:=fun t=>by
    simpa only [Real.tanh_zero,sub_zero] using tanh_admissible.2 t 0
  have hscore:∀x,|networkOutput Real.tanh net x|≤scale*Bcap:=fun x=>
    (networkOutput_abs_le_weightedSquaredNorm hd hN Real.tanh hφ net x).trans hcap
  have hvariance:=rectangle_variance_budget_of_downward_deficit size column hsize heven C hsupport
    weight H v u hw hu hv hE hind (networkOutput Real.tanh net) (networkVariationBudget net)
    (scale*Bcap) K Bcap hB hL hK hscore hcal hcost hbudget hdownward
  exact ⟨hmargin,hcal,hcost,hremoved,hvariance⟩

end NeuralGeneralization.OnlineLower
