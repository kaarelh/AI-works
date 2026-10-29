import CanonicalPolynomialResources

noncomputable section
set_option maxHeartbeats 3000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

lemma canonicalRadius_le_three {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) (hd : 1≤d) (j : ℕ) (hj : j≤H) :
    canonicalRadius P (canonicalSignPrecision P) j≤3 := by
  have hh := P.feature_norm_le_two hd j hj (featureMaximizer (P.feature j))
  have hnorm : 0≤‖P.feature j (featureMaximizer (P.feature j))‖ := norm_nonneg _
  unfold canonicalRadius maxFeatureVariance
  rw [Real.sqrt_sq hnorm]
  linarith [canonicalSignPrecision_le_one P]

namespace FiniteCanonicalDynamics
variable {d H : ℕ} {f : BooleanFunction d} {P : ControlledMarginPath d H 1 f}
variable {S : Finset (Cube d)} {states : ℕ → CanonicalProgramState d}

theorem residualRange_le_gain (M : FiniteCanonicalDynamics P S states) (hd : 1≤d) (j : ℕ) :
    M.residualRange (canonicalSignPrecision P) j≤2*M.nonlinearGain (canonicalSignPrecision P) j := by
  unfold residualRange nonlinearGain
  split_ifs with hj
  · have hr := canonicalRadius_le_three P hd j (Nat.le_of_lt hj)
    have hp : 0≤(canonicalRadius P (canonicalSignPrecision P) j)^2+
        Real.sqrt (criticalLayerCost P j) := by positivity
    nlinarith
  · simp

theorem residualRange_sum_le (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (j : ℕ) (hj : j≤H) :
    (∑i∈Finset.range j,M.residualRange (canonicalSignPrecision P) i)≤
      2*canonicalNonlinearBudget P (canonicalSignPrecision P) := by
  have hh := Finset.sum_le_sum (fun i (_:i∈Finset.range j) => M.residualRange_le_gain hd i)
  rw [← Finset.mul_sum] at hh
  apply hh.trans
  rw [← M.nonlinear_sum (canonicalSignPrecision P)]
  apply mul_le_mul_of_nonneg_left _ (by norm_num)
  exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.range_mono hj)
    (fun i _ _ => M.nonlinearGain_nonneg _ i)

theorem volterra_uniform_range (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (hquery : ∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x (canonicalSignPrecision P))
    (x : Cube d) (v : ℕ → CanonicalAmbient states H) (j : ℕ) (hj : j≤H) :
    ‖volterra (M.affineBase x) M.propagator (M.normResidual (canonicalSignPrecision P)) v j‖≤
      3+2*canonicalNonlinearBudget P (canonicalSignPrecision P) := by
  have h := volterra_range_bound (M.affineBase x) M.propagator
    (M.normResidual (canonicalSignPrecision P)) (M.residualRange (canonicalSignPrecision P))
    (fun j i _ => M.propagator_norm_le j i) (M.normResidual_range (canonicalSignPrecision_pos P)) v j
  have hb := M.affineBase_norm_le hd (canonicalSignPrecision_pos P).le hquery x j
  have hs := M.residualRange_sum_le hd j hj
  linarith [canonicalSignPrecision_le_one P]

theorem inexact_uniform_range (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (hquery : ∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x (canonicalSignPrecision P))
    (x : Cube d) (v : ℕ → CanonicalAmbient states H) (j : ℕ) (hj : j≤H)
    (z : CanonicalAmbient states H) {δ : ℝ}
    (hz : ‖z-volterra (M.affineBase x) M.propagator (M.normResidual (canonicalSignPrecision P)) v j‖≤δ) :
    ‖z‖≤δ+3+2*canonicalNonlinearBudget P (canonicalSignPrecision P) := by
  have ht := norm_three z
    (volterra (M.affineBase x) M.propagator (M.normResidual (canonicalSignPrecision P)) v j) 0
  simp only [sub_zero] at ht
  linarith [M.volterra_uniform_range hd hquery x v j hj]

/-- Every actual normalized scaling coefficient is at least one and has a
single polynomial upper bound on the complete finite time interval. -/
theorem scale_uniform_polynomial (M : FiniteCanonicalDynamics P S states) (hd : 1≤d) (hH : 1≤H)
    {ε B R : ℝ} (hε : 0≤ε) (hB : 0≤B) (hR : 2≤R) (hHR : (H:ℝ)≤R)
    (hgap : (H:ℝ)*ε≤B*(1+Real.log R)^2) (hnear : P.action≤scalarBaseline.toReal+ε)
    (j : ℕ) (hj : j≤H) :
    1≤normalizingScale M.linearGain j ∧
    normalizingScale M.linearGain j≤R^(criticalPrecisionExponent B) := by
  constructor
  · exact normalizingScale_one_le M.linearGain M.linearGain_one_le j
  · apply (normalizingScale_mono M.linearGain M.linearGain_one_le hj).trans
    apply M.scale_le_exp.trans
    obtain ⟨he,hΛ⟩ := critical_normal_form_log_budgets P hd hH hε hB hR hHR hgap hnear
    have hΛpos := canonicalNonlinearBudget_nonneg P (canonicalSignPrecision P)
    apply (Real.exp_le_exp.mpr (show canonicalEntropySum P≤
      (2*criticalEntropyCoefficient B+criticalNonlinearCoefficient B)*(1+Real.log R) by nlinarith)).trans
    exact exp_log_envelope_pow (by positivity [criticalEntropyCoefficient_nonneg B,criticalNonlinearCoefficient_nonneg B]) hR

end FiniteCanonicalDynamics
#print axioms FiniteCanonicalDynamics.volterra_uniform_range
#print axioms FiniteCanonicalDynamics.scale_uniform_polynomial
end ConditionalNonpolynomial.Analytic
