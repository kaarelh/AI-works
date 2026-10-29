import GaussianEntropyGain

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic

def adjustedLayerCost (D : ℝ) (v : ℝ≥0) (qprev qnext : ℝ) : ℝ :=
  D-subcriticalCostBaseline v-((v:ℝ)⁻¹-1)/2*Real.log (qnext/qprev)

def physicalLogGain (D : ℝ) (v : ℝ≥0) : ℝ :=
  Real.log (Real.sqrt (v:ℝ)*Real.sqrt (gaussianEntropyGain D))

/-- The two gain inequalities used in uniform last-exit estimates, with
their entropy-to-variance premise discharged for an actual scalar control.
D may be the full row KL charge dominating this query's marginal charge. -/
theorem actual_adjusted_gain
    (Q : Measure ℝ) [IsProbabilityMeasure Q] (v : ℝ≥0)
    (hv : v ≠ 0) (hvone : v ≤ 1) (hKL : klDiv Q (gaussianReal 0 v) ≠ ∞)
    {p qprev qnext D : ℝ} (hp : 0<p) (hpq : p≤qprev) (hqn : 0<qnext)
    (hstep : qnext≤scalarTransition p Q)
    (hD : (klDiv Q (gaussianReal 0 v)).toReal≤D) :
    0≤adjustedLayerCost D v qprev qnext ∧
      physicalLogGain D v≤2*Real.sqrt (adjustedLayerCost D v qprev qnext) ∧
      (0<(v:ℝ)⁻¹-1 → physicalLogGain D v≤
        Real.log (qnext/qprev)/2+adjustedLayerCost D v qprev qnext/((v:ℝ)⁻¹-1)) := by
  have hfinite := (scalar_subcritical_reference_change Q v hv hvone hKL).1
  have hc := adjusted_subcritical_scalar_cost Q v hv hvone hKL hp hpq hqn hstep
  have hcharge : (klDiv Q (gaussianReal 0 1)).toReal≤adjustedLayerCost D v qprev qnext := by
    unfold adjustedLayerCost
    linarith
  have he : 0≤adjustedLayerCost D v qprev qnext := ENNReal.toReal_nonneg.trans hcharge
  have ha : 0≤(v:ℝ)⁻¹-1 := by
    have hvp : 0<(v:ℝ) := by exact_mod_cast (pos_iff_ne_zero.mpr hv)
    have hvr : (v:ℝ)≤1 := by exact_mod_cast hvone
    have hh := (one_le_inv₀ hvp).mpr hvr
    linarith
  have hqpos : 0<qprev := hp.trans_le hpq
  have hu := scalar_transition_log_gain Q hfinite hp.le hpq hqpos hqn hstep
  have hroot := mul_le_mul_of_nonneg_left (Real.sqrt_le_sqrt hcharge) (by norm_num : (0:ℝ)≤3)
  have hu' : Real.log (qnext/qprev)≤3*Real.sqrt (adjustedLayerCost D v qprev qnext) := by
    rw [Real.log_div hqn.ne' hqpos.ne']
    exact hu.trans hroot
  have hnon : 0≤D := ENNReal.toReal_nonneg.trans hD
  have hid := gaussianEntropyGain_adjusted_identity hnon v hv
  change D-subcriticalCostBaseline v = ((v:ℝ)⁻¹-1)*physicalLogGain D v+
    (1+((v:ℝ)⁻¹-1))/2*(Real.exp (2*physicalLogGain D v)-1-2*physicalLogGain D v) at hid
  have hh := adjusted_gain_bounds ha he hu' (show ((v:ℝ)⁻¹-1)*physicalLogGain D v+
      (1+((v:ℝ)⁻¹-1))/2*(Real.exp (2*physicalLogGain D v)-1-2*physicalLogGain D v) =
      ((v:ℝ)⁻¹-1)*Real.log (qnext/qprev)/2+adjustedLayerCost D v qprev qnext from by
        rw [← hid]
        unfold adjustedLayerCost
        ring)
  exact ⟨he,hh⟩

#print axioms actual_adjusted_gain
end ConditionalNonpolynomial.Analytic
