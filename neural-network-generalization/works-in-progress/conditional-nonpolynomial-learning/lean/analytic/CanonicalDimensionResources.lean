import CanonicalEvaluationRanges

noncomputable section
set_option maxHeartbeats 3000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

def criticalFloorCoefficient (B : ℝ) := 64*(1+criticalReadoutCoefficient B)
def criticalAnchorExponent (B : ℝ) := 4*(criticalPrecisionExponent B+3)+2
def criticalAnchorCoefficient (B : ℝ) :=
  (257+B)*(8*criticalFloorCoefficient B)^4+1024*(criticalReadoutCoefficient B)^2

lemma critical_exp_budget_polynomial {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) (hd : 1≤d) (hH : 1≤H)
    {ε B R : ℝ} (hε : 0≤ε) (hB : 0≤B) (hR : 2≤R) (hHR : (H:ℝ)≤R)
    (hgap : (H:ℝ)*ε≤B*(1+Real.log R)^2) (hnear : P.action≤scalarBaseline.toReal+ε) :
    Real.exp (canonicalEntropySum P)≤R^(criticalPrecisionExponent B) := by
  obtain ⟨he,hΛ⟩ := critical_normal_form_log_budgets P hd hH hε hB hR hHR hgap hnear
  have hΛpos := canonicalNonlinearBudget_nonneg P (canonicalSignPrecision P)
  apply (Real.exp_le_exp.mpr (show canonicalEntropySum P≤
    (2*criticalEntropyCoefficient B+criticalNonlinearCoefficient B)*(1+Real.log R) by nlinarith)).trans
  exact exp_log_envelope_pow (by positivity [criticalEntropyCoefficient_nonneg B,criticalNonlinearCoefficient_nonneg B]) hR

lemma critical_anchor_precision_polynomial {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) (hd : 1≤d) (hH : 1≤H)
    {ε B R : ℝ} (hε : 0≤ε) (hB : 0≤B) (hR : 2≤R) (hHR : (H:ℝ)≤R)
    (hgap : (H:ℝ)*ε≤B*(1+Real.log R)^2) (hnear : P.action≤scalarBaseline.toReal+ε) :
    (canonicalPrecision P (canonicalSignPrecision P))⁻¹≤
      (8*criticalFloorCoefficient B)^4*R^(4*(criticalPrecisionExponent B+3)) := by
  have hR0 : 0≤R := by linarith
  have hexp := critical_exp_budget_polynomial P hd hH hε hB hR hHR hgap hnear
  have hη := (critical_rounding_polynomial_bound P hd hH hε hB hR hHR hgap hnear).2
  have hH1 : (H:ℝ)+1≤2*R := by linarith
  have hηpos := canonicalSignPrecision_pos P
  have hbound : 4*((H:ℝ)+1)*Real.exp (canonicalEntropySum P)*(canonicalSignPrecision P)⁻¹≤
      8*criticalFloorCoefficient B*R^(criticalPrecisionExponent B+3) := by
    have h1 := mul_le_mul (mul_le_mul_of_nonneg_left hH1 (by norm_num : (0:ℝ)≤4)) hexp
      (Real.exp_nonneg _) (by positivity)
    have h2 := mul_le_mul h1 hη (inv_nonneg.mpr hηpos.le) (by positivity)
    apply h2.trans_eq
    simp only [criticalFloorCoefficient,pow_add]
    ring
  rw [canonicalPrecision,← inv_pow,inv_div,div_eq_mul_inv]
  have hp := pow_le_pow_left₀ (by positivity : 0≤4*((H:ℝ)+1)*Real.exp (canonicalEntropySum P)*
    (canonicalSignPrecision P)⁻¹) hbound 4
  apply hp.trans_eq
  rw [mul_pow,← pow_mul]
  congr 1
  congr 1
  omega

lemma critical_layer_cost_sum_polynomial {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) (hH : 1≤H)
    {ε B R : ℝ} (hε : 0≤ε) (hB : 0≤B) (hR : 2≤R)
    (hgap : (H:ℝ)*ε≤B*(1+Real.log R)^2) (hnear : P.action≤scalarBaseline.toReal+ε) :
    (∑j:Fin H,criticalLayerCost P j)≤(257+B)*R^2 := by
  have ha := critical_action_eq P
  have hb := scalarBaseline_le
  have hs : (∑j∈Finset.range H,criticalLayerCost P j)≤257+ε := by nlinarith [sq_nonneg ‖P.readout‖]
  have hH1 : (1:ℝ)≤H := by exact_mod_cast hH
  have he : ε≤B*(1+Real.log R)^2 := by nlinarith [hgap]
  have hl : 1+Real.log R≤R := by linarith [Real.log_le_sub_one_of_pos (show 0<R by linarith)]
  have hl0 : 0≤1+Real.log R := by linarith [Real.log_nonneg (show 1≤R by linarith)]
  have hsq := mul_le_mul_of_nonneg_left (pow_le_pow_left₀ hl0 hl 2) hB
  rw [Fin.sum_univ_eq_sum_range (fun j => criticalLayerCost P j) H]
  nlinarith

theorem critical_anchor_card_polynomial {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) (hd : 1≤d) (hH : 1≤H)
    {ε B R : ℝ} (hε : 0≤ε) (hB : 0≤B) (hR : 2≤R) (hHR : (H:ℝ)≤R)
    (hgap : (H:ℝ)*ε≤B*(1+Real.log R)^2) (hnear : P.action≤scalarBaseline.toReal+ε)
    (S : Finset (Cube d))
    (hcard : (S.card:ℝ)≤(∑j:Fin H,criticalLayerCost P j/canonicalPrecision P (canonicalSignPrecision P))+
        1024*‖P.readout‖^2) :
    (S.card:ℝ)≤criticalAnchorCoefficient B*R^(criticalAnchorExponent B) := by
  have hR0 : 0≤R := by linarith
  have hC : 0≤criticalReadoutCoefficient B := Real.sqrt_nonneg _
  have hsum := critical_layer_cost_sum_polynomial P hH hε hB hR hgap hnear
  have hprec := critical_anchor_precision_polynomial P hd hH hε hB hR hHR hgap hnear
  have hpos := canonicalPrecision_pos P (canonicalSignPrecision_pos P)
  have hr0 := critical_readout_polynomial_envelope P hH hε hB hR hgap hnear
  have hr : ‖P.readout‖≤criticalReadoutCoefficient B*R := by
    have hh := critical_readout_log_envelope P hH hε hB hR hgap hnear
    have hl : 1+Real.log R≤R := by linarith [Real.log_le_sub_one_of_pos (show 0<R by linarith)]
    exact hh.trans (mul_le_mul_of_nonneg_left hl hC)
  have hrs := pow_le_pow_left₀ (norm_nonneg _) hr 2
  have hp : R^2≤R^(criticalAnchorExponent B) := by
    apply pow_le_pow_right₀ (by linarith : 1≤R)
    unfold criticalAnchorExponent
    omega
  rw [← Finset.sum_div,div_eq_mul_inv] at hcard
  have hprod := mul_le_mul hsum hprec (inv_nonneg.mpr hpos.le) (by positivity)
  have hprod' : (∑j:Fin H,criticalLayerCost P j)*(canonicalPrecision P (canonicalSignPrecision P))⁻¹≤
      (257+B)*(8*criticalFloorCoefficient B)^4*R^(criticalAnchorExponent B) := by
    apply hprod.trans_eq
    simp only [criticalAnchorExponent,pow_add]
    ring
  have hrr : 1024*‖P.readout‖^2≤1024*(criticalReadoutCoefficient B)^2*R^(criticalAnchorExponent B) := by
    rw [mul_pow] at hrs
    have h1 := mul_le_mul_of_nonneg_left hrs (by norm_num : (0:ℝ)≤1024)
    have h2 := mul_le_mul_of_nonneg_left hp (by positivity : 0≤1024*(criticalReadoutCoefficient B)^2)
    nlinarith
  unfold criticalAnchorCoefficient
  nlinarith

namespace FiniteCanonicalDynamics
variable {d H : ℕ} {f : BooleanFunction d} {P : ControlledMarginPath d H 1 f}
variable {S : Finset (Cube d)} {states : ℕ → CanonicalProgramState d}

theorem ambient_dimension_polynomial (M : FiniteCanonicalDynamics P S states)
    (hdim : ∀j≤H,(states j).dimension≤d+1+j*(S.card+1))
    {B R : ℝ} (hB : 0≤B) (hR : 2≤R) (hdR : (d:ℝ)≤R) (hHR : (H:ℝ)≤R)
    (hcard : (S.card:ℝ)≤criticalAnchorCoefficient B*R^(criticalAnchorExponent B)) :
    (Module.finrank ℝ (CanonicalAmbient states H):ℝ)≤
      (6+2*criticalAnchorCoefficient B)*R^(criticalAnchorExponent B+2) := by
  have hR0 : 0≤R := by linarith
  have hC : 0≤criticalAnchorCoefficient B := by
    unfold criticalAnchorCoefficient
    positivity
  have hb : (Module.finrank ℝ (CanonicalAmbient states H):ℝ)≤
      ((H:ℝ)+1)*((d:ℝ)+1+(H:ℝ)*((S.card:ℝ)+1)) := by
    exact_mod_cast M.ambient_dimension_le hdim
  have hH1 : (H:ℝ)+1≤2*R := by linarith
  have hd1 : (d:ℝ)+1≤2*R := by linarith
  have hmul := mul_le_mul hHR (add_le_add hcard le_rfl)
    (by positivity : 0≤(S.card:ℝ)+1) hR0
  have hinside := add_le_add hd1 hmul
  have hall := mul_le_mul hH1 hinside
    (by positivity : 0≤(d:ℝ)+1+(H:ℝ)*((S.card:ℝ)+1)) (by positivity)
  apply hb.trans (hall.trans ?_)
  have hp : R^2≤R^(criticalAnchorExponent B+2) :=
    pow_le_pow_right₀ (by linarith) (by omega)
  have hid : 2*R*(2*R+R*(criticalAnchorCoefficient B*R^(criticalAnchorExponent B)+1))=
      6*R^2+2*criticalAnchorCoefficient B*R^(criticalAnchorExponent B+2) := by
    rw [pow_add]
    ring
  rw [hid]
  nlinarith
end FiniteCanonicalDynamics

#print axioms critical_anchor_card_polynomial
#print axioms FiniteCanonicalDynamics.ambient_dimension_polynomial
end ConditionalNonpolynomial.Analytic
