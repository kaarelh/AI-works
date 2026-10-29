import PhysicalShortLogResources

noncomputable section
set_option maxHeartbeats 3000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel

lemma criticalFieldCoefficient_nonneg (B : ℝ) : 0≤criticalFieldCoefficient B := by
  unfold criticalFieldCoefficient dyadicBlockConstant
  have hh : 0<Real.log 2 := Real.log_pos (by norm_num)
  positivity
lemma criticalEntropyCoefficient_nonneg (B : ℝ) : 0≤criticalEntropyCoefficient B :=
  add_nonneg (Real.sqrt_nonneg _) (criticalFieldCoefficient_nonneg B)
lemma criticalVarianceCoefficient_nonneg (B : ℝ) : 0≤criticalVarianceCoefficient B := by
  unfold criticalVarianceCoefficient
  have hd := driftDissipation_pos
  have hv := varianceEntropyConstant_nonneg
  have hf := criticalFieldCoefficient_nonneg B
  have hl : 0≤Real.log 8 := Real.log_nonneg (by norm_num)
  positivity
lemma criticalNonlinearCoefficient_nonneg (B : ℝ) : 0≤criticalNonlinearCoefficient B := by
  unfold criticalNonlinearCoefficient
  have hv := criticalVarianceCoefficient_nonneg B
  have he := criticalEntropyCoefficient_nonneg B
  positivity

def criticalReadoutCoefficient (B : ℝ) := Real.sqrt (514+2*B)
def criticalIterationCoefficient (B : ℝ) :=
  (2*criticalNonlinearCoefficient B+2*criticalEntropyCoefficient B+
    Real.log 384+Real.log (1+criticalReadoutCoefficient B)+1)/Real.log 2+1

def criticalPrecisionExponent (B : ℝ) : ℕ :=
  ⌈(2*criticalEntropyCoefficient B+criticalNonlinearCoefficient B)*(1+1/Real.log 2)⌉₊

lemma exp_log_envelope_pow {C R : ℝ} (hC : 0≤C) (hR : 2≤R) :
    Real.exp (C*(1+Real.log R))≤R^(⌈C*(1+1/Real.log 2)⌉₊) := by
  have hl2 : 0<Real.log 2 := Real.log_pos (by norm_num)
  have hlR : Real.log 2≤Real.log R := Real.log_le_log (by norm_num) hR
  have hRpos : 0<R := by linarith
  have hh : 1≤(Real.log R)/Real.log 2 := (one_le_div hl2).mpr hlR
  have hprod := mul_le_mul_of_nonneg_left hh hC
  have hn := Nat.le_ceil (C*(1+1/Real.log 2))
  have hm := mul_le_mul_of_nonneg_right hn (by linarith : 0≤Real.log R)
  have hexp : C*(1+Real.log R)≤(⌈C*(1+1/Real.log 2)⌉₊:ℝ)*Real.log R := by
    simp only [div_eq_mul_inv,one_mul] at hprod hm ⊢
    nlinarith
  apply (Real.exp_le_exp.mpr hexp).trans_eq
  rw [Real.exp_nat_mul,Real.exp_log hRpos]

lemma critical_readout_log_envelope {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hH : 1≤H) {ε B R : ℝ}
    (hε : 0≤ε) (hB : 0≤B) (hR : 2≤R)
    (hgap : (H:ℝ)*ε≤B*(1+Real.log R)^2)
    (hnear : P.action≤scalarBaseline.toReal+ε) :
    ‖P.readout‖≤criticalReadoutCoefficient B*(1+Real.log R) := by
  have hs : 0≤∑j∈Finset.range H,physicalLayerCost P j := Finset.sum_nonneg
    (fun j _ => ENNReal.toReal_nonneg)
  have ha := physical_action_dominates_critical_readout P
  have hb := scalarBaseline_le
  have hnorm : ‖P.readout‖^2≤514+2*ε := by linarith
  have hr : ‖P.readout‖≤Real.sqrt (514+2*ε) :=
    (Real.le_sqrt (norm_nonneg _) (by positivity)).mpr hnorm
  have hHreal : (1:ℝ)≤H := by exact_mod_cast hH
  have he : 2*ε≤(2*B)*(1+Real.log R)^2 := by nlinarith [hgap]
  exact hr.trans (sqrt_log_envelope (by norm_num) (by positivity)
    (by linarith [Real.log_nonneg (show 1≤R by linarith)]) he)

lemma critical_readout_polynomial_envelope {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hH : 1≤H) {ε B R : ℝ}
    (hε : 0≤ε) (hB : 0≤B) (hR : 2≤R)
    (hgap : (H:ℝ)*ε≤B*(1+Real.log R)^2)
    (hnear : P.action≤scalarBaseline.toReal+ε) :
    1+‖P.readout‖≤(1+criticalReadoutCoefficient B)*R := by
  have hr := critical_readout_log_envelope P hH hε hB hR hgap hnear
  have hl := Real.log_le_sub_one_of_pos (show 0<R by linarith)
  have hc : 0≤criticalReadoutCoefficient B := Real.sqrt_nonneg _
  have hm := mul_le_mul_of_nonneg_left (show 1+Real.log R≤R by linarith) hc
  nlinarith

theorem critical_iteration_log_bound {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) (hH : 1≤H)
    {ε B R : ℝ} (hε : 0≤ε) (hB : 0≤B) (hR : 2≤R) (hHR : (H:ℝ)≤R)
    (hgap : (H:ℝ)*ε≤B*(1+Real.log R)^2) (hnear : P.action≤scalarBaseline.toReal+ε) :
    (canonicalSignIterations P:ℝ)≤criticalIterationCoefficient B*(1+Real.log R) := by
  obtain ⟨hE,hΛ⟩ := critical_normal_form_log_budgets P hd hH hε hB hR hHR hgap hnear
  have hepos : 0≤canonicalEntropySum P := Finset.sum_nonneg (fun _ _ => Real.sqrt_nonneg _)
  have hk := causalSignIterations_bound hepos (canonicalNonlinearBudget_nonneg P (canonicalSignPrecision P))
    (norm_nonneg P.readout)
  have hr := critical_readout_polynomial_envelope P hH hε hB hR hgap hnear
  have hC : 0≤criticalReadoutCoefficient B := Real.sqrt_nonneg _
  have hRpos : 0<R := by linarith
  have hlogR : 0≤Real.log R := Real.log_nonneg (by linarith)
  have hl2 : 0<Real.log 2 := Real.log_pos (by norm_num)
  have hlC : 0≤Real.log (1+criticalReadoutCoefficient B) := Real.log_nonneg (by linarith)
  have hl384 : 0≤Real.log 384 := Real.log_nonneg (by norm_num)
  have hlog := Real.log_le_log (by positivity : 0<1+‖P.readout‖) hr
  rw [Real.log_mul (by positivity : 1+criticalReadoutCoefficient B≠0) hRpos.ne'] at hlog
  have hlogtarget : Real.log (384*(1+‖P.readout‖))≤
      (Real.log 384+Real.log (1+criticalReadoutCoefficient B)+1)*(1+Real.log R) := by
    rw [Real.log_mul (by norm_num : (384:ℝ)≠0) (by positivity : 1+‖P.readout‖≠0)]
    nlinarith
  have hnum : 2*canonicalNonlinearBudget P (canonicalSignPrecision P)+canonicalEntropySum P+
      Real.log (384*(1+‖P.readout‖))≤
    (2*criticalNonlinearCoefficient B+2*criticalEntropyCoefficient B+
      Real.log 384+Real.log (1+criticalReadoutCoefficient B)+1)*(1+Real.log R) := by nlinarith
  have hdiv := div_le_div_of_nonneg_right hnum hl2.le
  unfold canonicalSignIterations criticalIterationCoefficient
  have hh := hk.trans (add_le_add hdiv le_rfl)
  apply hh.trans
  simp only [div_eq_mul_inv]
  nlinarith only [hlogR]

theorem critical_rounding_polynomial_bound {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) (hH : 1≤H)
    {ε B R : ℝ} (hε : 0≤ε) (hB : 0≤B) (hR : 2≤R) (hHR : (H:ℝ)≤R)
    (hgap : (H:ℝ)*ε≤B*(1+Real.log R)^2) (hnear : P.action≤scalarBaseline.toReal+ε) :
    (canonicalSignRounding P)⁻¹≤64*(1+criticalReadoutCoefficient B)*R^(criticalPrecisionExponent B+1) ∧
    (canonicalSignPrecision P)⁻¹≤64*(1+criticalReadoutCoefficient B)*R^2 := by
  obtain ⟨hE,hΛ⟩ := critical_normal_form_log_budgets P hd hH hε hB hR hHR hgap hnear
  have hr := critical_readout_polynomial_envelope P hH hε hB hR hgap hnear
  have hC : 0≤criticalReadoutCoefficient B := Real.sqrt_nonneg _
  have hR0 : 0≤R := by linarith
  have hexp : Real.exp (canonicalEntropySum P+canonicalNonlinearBudget P (canonicalSignPrecision P))≤
      R^(criticalPrecisionExponent B) := by
    apply (Real.exp_le_exp.mpr (show canonicalEntropySum P+
      canonicalNonlinearBudget P (canonicalSignPrecision P)≤
      (2*criticalEntropyCoefficient B+criticalNonlinearCoefficient B)*(1+Real.log R) by nlinarith)).trans
    exact exp_log_envelope_pow (by positivity [criticalEntropyCoefficient_nonneg B,criticalNonlinearCoefficient_nonneg B]) hR
  constructor
  · simp only [canonicalSignRounding,causalSignRounding,one_div,inv_inv]
    have hm := mul_le_mul (mul_le_mul_of_nonneg_left hr (by norm_num : (0:ℝ)≤64)) hexp
      (Real.exp_nonneg _) (by positivity)
    apply hm.trans_eq
    rw [pow_succ]
    ring
  · simp only [canonicalSignPrecision,one_div,inv_inv]
    have hH1 : (H:ℝ)+1≤2*R := by linarith
    have hm := mul_le_mul (mul_le_mul_of_nonneg_left hH1 (by norm_num : (0:ℝ)≤32)) hr
      (by positivity : 0≤1+‖P.readout‖) (by positivity)
    apply hm.trans_eq
    ring

#print axioms critical_iteration_log_bound
#print axioms critical_rounding_polynomial_bound
end ConditionalNonpolynomial.Analytic.PhysicalShort
