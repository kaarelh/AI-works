import PhysicalShortResidualResources

noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory ConditionalAnalytic
open scoped BigOperators RealInnerProductSpace ENNReal
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup

lemma resource_constant {C R : ℝ} (hC : 0≤C) (hR : 2≤R) :
    C≤R^(⌈C*(1+1/Real.log 2)⌉₊) := by
  have hl : 0≤Real.log R := Real.log_nonneg (by linarith)
  have h1 : C≤Real.exp C := by linarith [Real.add_one_le_exp C]
  have h2 : Real.exp C≤Real.exp (C*(1+Real.log R)) := Real.exp_le_exp.mpr
    (by nlinarith [mul_nonneg hC hl])
  exact h1.trans (h2.trans (exp_log_envelope_pow hC hR))

def criticalPrimitiveConstant (B : ℝ) : ℝ :=
  (6+2*criticalAnchorCoefficient B)+criticalAnchorCoefficient B+(257+B)+criticalFloorCoefficient B+1

def criticalPrimitiveExponent (B : ℝ) (q : ℕ) : ℕ :=
  ⌈criticalPrimitiveConstant B*(1+1/Real.log 2)⌉₊+
    criticalAnchorExponent B+criticalPrecisionExponent B+q+5

lemma criticalAnchorCoefficient_nonneg {B : ℝ} (hB : 0≤B) : 0≤criticalAnchorCoefficient B := by
  unfold criticalAnchorCoefficient
  positivity
lemma criticalFloorCoefficient_nonneg (B : ℝ) : 0≤criticalFloorCoefficient B := by
  unfold criticalFloorCoefficient criticalReadoutCoefficient
  positivity

namespace FiniteCanonicalDynamics
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ → CanonicalProgramState d}

/-- A single power of R dominates every genuine primitive resource needed by
all residual evaluators. The exponent depends only on the near-baseline
constant and the requested tolerance exponent. -/
theorem critical_primitive_resources (M : FiniteCanonicalDynamics P S states)
    (hd : 1≤d) (hH : 1≤H) {ε B R τ : ℝ} (hε : 0≤ε) (hB : 0≤B) (hR : 2≤R)
    (hdR : (d:ℝ)≤R) (hHR : (H:ℝ)≤R)
    (hgap : (H:ℝ)*ε≤B*(1+Real.log R)^2) (hnear : P.action≤scalarBaseline.toReal+ε)
    (hdim : ∀j≤H,(states j).dimension≤d+1+j*(S.card+1))
    (hcard : (S.card:ℝ)≤(H:ℝ)/(2*physicalAbsolutePrecision P (canonicalSignPrecision P))+
      1024*‖P.readout‖^2) (q : ℕ) (hτ : τ⁻¹≤R^q) :
    M.PrimitiveResources (R^(criticalPrimitiveExponent B q)) τ := by
  have hC := criticalAnchorCoefficient_nonneg hB
  have hF := criticalFloorCoefficient_nonneg B
  have hCC : 0≤criticalPrimitiveConstant B := by unfold criticalPrimitiveConstant;positivity
  have hcoef := resource_constant hCC hR
  have hcard0 := critical_anchor_card_polynomial P hd hH hε hB hR hHR hgap hnear S hcard
  have hdim0 := M.ambient_dimension_polynomial hdim hB hR hdR hHR hcard0
  have hsum0 := critical_layer_cost_sum_polynomial P hH hε hB hR hgap hnear
  have hamp0 := critical_exp_budget_polynomial P hd hH hε hB hR hHR hgap hnear
  have hfloor0 := (critical_rounding_polynomial_bound P hd hH hε hB hR hHR hgap hnear).2
  let C := ⌈criticalPrimitiveConstant B*(1+1/Real.log 2)⌉₊
  have ha : criticalAnchorCoefficient B≤R^C :=
    (show criticalAnchorCoefficient B≤criticalPrimitiveConstant B by unfold criticalPrimitiveConstant;linarith).trans hcoef
  have hb : 6+2*criticalAnchorCoefficient B≤R^C :=
    (show 6+2*criticalAnchorCoefficient B≤criticalPrimitiveConstant B by unfold criticalPrimitiveConstant;linarith).trans hcoef
  have hc : 257+B≤R^C :=
    (show 257+B≤criticalPrimitiveConstant B by unfold criticalPrimitiveConstant;linarith).trans hcoef
  have hf : criticalFloorCoefficient B≤R^C :=
    (show criticalFloorCoefficient B≤criticalPrimitiveConstant B by unfold criticalPrimitiveConstant;linarith).trans hcoef
  have hR0 : 0≤R := by linarith
  have hmono (a : ℕ) (ha : a≤criticalPrimitiveExponent B q) : R^a≤R^(criticalPrimitiveExponent B q) :=
    resource_pow_mono hR ha
  refine ⟨?_,?_,?_,?_,?_,?_,?_⟩
  · exact hR.trans (by simpa only [pow_one] using hmono 1 (by unfold criticalPrimitiveExponent;omega))
  · rw [canonicalAmbientDimension_eq_finrank]
    exact hdim0.trans ((resource_mul hR hb (le_refl (R^(criticalAnchorExponent B+2)))
      (pow_nonneg hR0 _)).trans (hmono _ (by unfold criticalPrimitiveExponent C;omega)))
  · exact hcard0.trans ((resource_mul hR ha (le_refl (R^(criticalAnchorExponent B)))
      (pow_nonneg hR0 _)).trans (hmono _ (by unfold criticalPrimitiveExponent C;omega)))
  · exact hsum0.trans ((resource_mul hR hc (le_refl (R^2)) (sq_nonneg R)).trans
      (hmono _ (by unfold criticalPrimitiveExponent C;omega)))
  · exact hamp0.trans (hmono _ (by unfold criticalPrimitiveExponent;omega))
  · exact hfloor0.trans ((resource_mul hR hf (le_refl (R^2)) (sq_nonneg R)).trans
      (hmono _ (by unfold criticalPrimitiveExponent C;omega)))
  · exact hτ.trans (hmono _ (by unfold criticalPrimitiveExponent;omega))

#print axioms critical_primitive_resources
end FiniteCanonicalDynamics
end ConditionalNonpolynomial.Analytic.PhysicalShort
