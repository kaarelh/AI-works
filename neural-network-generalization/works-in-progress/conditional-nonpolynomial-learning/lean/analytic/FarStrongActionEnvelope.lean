import FarStrongPrefixRadius
import DenominatorBudgetArithmetic
import CriticalPrimitiveResources
import ThresholdResourceConversion
import PhysicalCompressionPrecision

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup

 def farStrongExcessCoefficient (B:ℝ) : ℝ := 1028+9*B
 def farStrongReadoutCoefficient (B:ℝ) : ℝ := 4*B+522
 def farStrongGainExponent (B:ℝ) : ℕ := ⌈farStrongExcessCoefficient B*(1+1/Real.log 2)⌉₊
 def farStrongReadoutExponent (B:ℝ) : ℕ := ⌈farStrongReadoutCoefficient B*(1+1/Real.log 2)⌉₊+1

lemma farStrong_baseline_eq {t:ℝ} (ht:0<t) :
    twoBallEntropyBaseline ((t^2)⁻¹-1)=subcriticalCostBaseline (t^2).toNNReal := by
  unfold twoBallEntropyBaseline subcriticalCostBaseline
  rw [Real.coe_toNNReal _ (sq_nonneg t)]
  simp only [sub_add_cancel,Real.log_inv]
  ring

lemma physical_sharp_product_eq {d H:ℕ} {t:ℝ} {f:BooleanFunction d}
    (P:ControlledMarginPath d H t f) (j:ℕ) :
    sharpFiniteProduct t (physicalLayerCost P) j=physicalGainProduct P j := by
  apply Finset.prod_congr rfl
  intro k hk
  change t*Real.sqrt (gaussianEntropyGain (physicalLayerCost P k))=
    Real.sqrt (physicalVariance P:ℝ)*Real.sqrt (gaussianEntropyGain (physicalLayerCost P k))
  rw [physicalVariance_coe,Real.sqrt_sq_eq_abs,abs_of_pos P.scale_positive]

lemma farStrong_action_split {d H:ℕ} {t:ℝ} {f:BooleanFunction d}
    (P:ControlledMarginPath d H t f) :
    P.action=(∑j∈Finset.range H,physicalLayerCost P j)+‖P.readout‖^2/(2*t^2) := by
  rw [ControlledMarginPath.action]
  change (∑j:Fin H,physicalLayerCost P j)+_= _
  rw [Fin.sum_univ_eq_sum_range]

lemma farStrong_action_bounds {d H:ℕ} {t R B:ℝ} {f:BooleanFunction d}
    (P:ControlledMarginPath d H t f) (hH:1≤H) (hB:0≤B) (hR:2≤R)
    (hHR:(H:ℝ)+1≤R) (hlogH:Real.log R≤2*(H:ℝ))
    (ha:1/4≤(t^2)⁻¹-1) (hnear:P.action≤denominatorBudget B t R H) :
    ((∑j∈Finset.range H,physicalLayerCost P j)-(H:ℝ)*subcriticalCostBaseline (t^2).toNNReal)/((t^2)⁻¹-1)≤
      farStrongExcessCoefficient B*(1+Real.log R) ∧
    ‖P.readout‖≤farStrongReadoutCoefficient B*R := by
  have ht:=P.scale_positive
  have ht1:=P.scale_le_one
  have hH0:(0:ℝ)<H := by exact_mod_cast (show 0<H by omega)
  have ha0:0<(t^2)⁻¹-1 := by linarith
  have hlog:0≤Real.log R := Real.log_nonneg (by linarith)
  have hsqH:(Real.log R)^2/(H:ℝ)≤2*Real.log R := by
    apply (div_le_iff₀ hH0).mpr
    nlinarith [mul_le_mul_of_nonneg_left hlogH hlog]
  have hread0:0≤‖P.readout‖^2/(2*t^2) := by positivity
  have hsum:((∑j∈Finset.range H,physicalLayerCost P j)-(H:ℝ)*subcriticalCostBaseline (t^2).toNNReal)≤
      scalarBaseline.toReal+B*(((t^2)⁻¹-1)*Real.log R+(Real.log R)^2/(H:ℝ)) := by
    rw [farStrong_action_split P] at hnear
    unfold denominatorBudget at hnear
    linarith
  have hsmall:scalarBaseline.toReal+B*(((t^2)⁻¹-1)*Real.log R+(Real.log R)^2/(H:ℝ))≤
      ((t^2)⁻¹-1)*(1028+9*B*Real.log R) := by
    have h8:2*Real.log R≤8*((t^2)⁻¹-1)*Real.log R := by nlinarith
    have hb:=mul_le_mul_of_nonneg_left (hsqH.trans h8) hB
    have hv:=scalarBaseline_le
    nlinarith [mul_le_mul_of_nonneg_right ha (by norm_num : (0:ℝ)≤1028)]
  have hex:((∑j∈Finset.range H,physicalLayerCost P j)-(H:ℝ)*subcriticalCostBaseline (t^2).toNNReal)/((t^2)⁻¹-1)≤
      farStrongExcessCoefficient B*(1+Real.log R) := by
    apply (div_le_iff₀ ha0).mpr
    have hb:1028+9*B*Real.log R≤farStrongExcessCoefficient B*(1+Real.log R) := by
      unfold farStrongExcessCoefficient
      nlinarith
    exact (hsum.trans hsmall).trans (by simpa only [mul_comm] using mul_le_mul_of_nonneg_left hb ha0.le)
  have hn:=denominatorBudget_normalized hB ht ht1 hH hR hHR
  have hnorm:t^2*P.action≤(2*B+260)*R^2 := by
    have hh:=mul_le_mul_of_nonneg_left hnear (sq_nonneg t)
    have hp:0≤2/(t^2*(H:ℝ)) := by positivity
    nlinarith
  have hcost:‖P.readout‖^2≤2*(t^2*P.action) := by
    have hs:0≤∑j∈Finset.range H,physicalLayerCost P j :=
      Finset.sum_nonneg (fun _ _=>ENNReal.toReal_nonneg)
    rw [farStrong_action_split P]
    field_simp
    nlinarith [mul_nonneg (sq_nonneg t) hs]
  have hcoef:0≤farStrongReadoutCoefficient B := by unfold farStrongReadoutCoefficient;linarith
  have hcoefsq:4*B+520≤(farStrongReadoutCoefficient B)^2 := by
    unfold farStrongReadoutCoefficient
    nlinarith [sq_nonneg B]
  have hsq:=mul_le_mul_of_nonneg_right hcoefsq (sq_nonneg R)
  have hp:0≤farStrongReadoutCoefficient B*R := mul_nonneg hcoef (by linarith)
  exact ⟨hex,by nlinarith [norm_nonneg P.readout]⟩

lemma farStrong_gain_bound {d H:ℕ} {t R B:ℝ} {f:BooleanFunction d}
    (P:ControlledMarginPath d H t f) (hH:1≤H) (hB:0≤B) (hR:2≤R)
    (hHR:(H:ℝ)+1≤R) (hlogH:Real.log R≤2*(H:ℝ))
    (ha:1/4≤(t^2)⁻¹-1) (hnear:P.action≤denominatorBudget B t R H) :
    physicalGainProduct P H≤R^(farStrongGainExponent B) ∧
      ‖P.readout‖≤R^(farStrongReadoutExponent B) := by
  have hb:=farStrong_action_bounds P hH hB hR hHR hlogH ha hnear
  let a:ℝ:=(t^2)⁻¹-1
  have ha0:0<a := by dsimp [a];linarith
  have hta:t^2*(a+1)=1 := by dsimp [a];rw [sub_add_cancel,mul_inv_cancel₀ (sq_pos_of_pos P.scale_positive).ne']
  have hg:Real.log (physicalGainProduct P H)≤
      ((∑j∈Finset.range H,physicalLayerCost P j)-(H:ℝ)*subcriticalCostBaseline (t^2).toNNReal)/a := by
    rw [←physical_sharp_product_eq P H]
    unfold sharpFiniteProduct
    rw [Real.log_prod (fun j hj=>(sharpFiniteGain_pos P.scale_positive (physicalLayerCost P) j).ne')]
    have hh:=Finset.sum_le_sum (s:=Finset.range H) (fun j hj=>
      sharp_physical_gain_tangent ha0 P.scale_positive ENNReal.toReal_nonneg hta (D:=physicalLayerCost P j))
    simp only [←Finset.sum_div,Finset.sum_sub_distrib,Finset.sum_const,Finset.card_range,nsmul_eq_mul] at hh
    rw [farStrong_baseline_eq P.scale_positive] at hh
    exact hh
  have hC:0≤farStrongExcessCoefficient B := by unfold farStrongExcessCoefficient;linarith
  have hc:0≤farStrongReadoutCoefficient B := by unfold farStrongReadoutCoefficient;linarith
  refine ⟨?_,?_⟩
  · rw [←Real.exp_log (physicalGainProduct_pos P H)]
    exact (Real.exp_le_exp.mpr (hg.trans hb.1)).trans (exp_log_envelope_pow hC hR)
  · have hh:=resource_mul hR (resource_constant hc hR) (a:=⌈farStrongReadoutCoefficient B*(1+1/Real.log 2)⌉₊)
      (b:=1) (by simp : R≤R^1) (by linarith : 0≤R)
    exact hb.2.trans hh

#print axioms farStrong_action_bounds
#print axioms farStrong_gain_bound
end ConditionalNonpolynomial.Analytic
