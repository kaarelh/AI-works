import GaussianSubcriticalReference
import IndependentControlEntropy
import ScalarVarianceSum

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic

theorem scalar_subcritical_reference_change
    (Q : Measure ℝ) [IsProbabilityMeasure Q] (v : ℝ≥0)
    (hv : v ≠ 0) (hvone : v ≤ 1) (hKL : klDiv Q (gaussianReal 0 v) ≠ ∞) :
    klDiv Q (gaussianReal 0 1) ≠ ∞ ∧
      (klDiv Q (gaussianReal 0 v)).toReal =
        (klDiv Q (gaussianReal 0 1)).toReal + Real.log (v:ℝ)/2 +
        ((v:ℝ)⁻¹-1)/2 * (∫ x : ℝ, x^2 ∂Q) := by
  let e := MeasurableEquiv.funUnique Unit ℝ
  let Q' := Q.map e.symm
  haveI : IsProbabilityMeasure Q' := Measure.isProbabilityMeasure_map e.symm.measurable.aemeasurable
  have hm (w : ℝ≥0) : (gaussianReal 0 w).map e.symm =
      Measure.pi fun _ : Unit => gaussianReal 0 w :=
    (MeasurePreserving.symm e (measurePreserving_funUnique (gaussianReal 0 w) Unit)).map_eq
  have hkl (w : ℝ≥0) : klDiv Q' (Measure.pi fun _ : Unit => gaussianReal 0 w) =
      klDiv Q (gaussianReal 0 w) := by
    rw [← hm]
    exact control_kl_measurableEquiv Q (gaussianReal 0 w) e.symm
  have hf : klDiv Q' (Measure.pi fun _ : Unit => gaussianReal 0 v) ≠ ∞ := by
    rwa [hkl]
  have h := subcritical_gaussian_reference_change Q' v hv hvone hf
  rw [hkl,hkl] at h
  have hmoment : (∫ x : Unit → ℝ, ∑ i,x i^2 ∂Q') = ∫ x : ℝ,x^2 ∂Q := by
    rw [show Q'=Q.map e.symm from rfl,integral_map_equiv]
    simp [e]
  simpa only [hmoment,Fintype.card_unit,Nat.cast_one,one_mul] using h

def subcriticalCostBaseline (v : ℝ≥0) : ℝ := ((v:ℝ)⁻¹-1+Real.log (v:ℝ))/2

theorem subcriticalCostBaseline_nonneg (v : ℝ≥0) (hv : v ≠ 0) :
    0 ≤ subcriticalCostBaseline v := by
  have hvp : 0 < (v:ℝ) := by exact_mod_cast (pos_iff_ne_zero.mpr hv)
  have h := Real.log_le_sub_one_of_pos (inv_pos.mpr hvp)
  rw [Real.log_inv] at h
  unfold subcriticalCostBaseline
  linarith

/-- The actual critical scalar entropy is dominated by the adjusted
subcritical charge, including when the maximizing query changes between
layers. The only state comparison is p≤qprev. -/
theorem adjusted_subcritical_scalar_cost
    (Q : Measure ℝ) [IsProbabilityMeasure Q] (v : ℝ≥0)
    (hv : v ≠ 0) (hvone : v ≤ 1) (hKL : klDiv Q (gaussianReal 0 v) ≠ ∞)
    {p qprev qnext : ℝ} (hp : 0 < p) (hpq : p ≤ qprev) (hqn : 0 < qnext)
    (hstep : qnext ≤ scalarTransition p Q) :
    (klDiv Q (gaussianReal 0 1)).toReal ≤
      (klDiv Q (gaussianReal 0 v)).toReal-subcriticalCostBaseline v-
        ((v:ℝ)⁻¹-1)/2*Real.log (qnext/qprev) := by
  obtain ⟨hfinite,heq⟩ := scalar_subcritical_reference_change Q v hv hvone hKL
  let M := ∫ x : ℝ,x^2 ∂Q
  have hM : 0 < M := scalar_gaussian_second_moment_pos Q hfinite
  have hi := scalar_gaussian_second_moment_integrable Q hfinite
  have htrans : scalarTransition p Q ≤ p*M := by
    calc
      _ ≤ ∫ x : ℝ,p*x^2 ∂Q := integral_mono (varianceTest_integrable Q p) (hi.const_mul p)
        (fun x => by
          have h := pow_le_pow_left₀ (abs_nonneg _) (NeuralGeneralization.BatchTwoNonGaussian.abs_tanh_le_abs
            (Real.sqrt p*x)) 2
          simpa only [varianceTest,sq_abs,mul_pow,Real.sq_sqrt hp.le] using h)
      _ = _ := integral_const_mul _ _
  have hqpos : 0 < qprev := hp.trans_le hpq
  have hratio : qnext/qprev ≤ M := by
    apply (div_le_iff₀ hqpos).mpr
    exact (hstep.trans htrans).trans (by nlinarith)
  have hlog := Real.log_le_sub_one_of_pos (div_pos hqn hqpos)
  have ha : 0 ≤ (v:ℝ)⁻¹-1 := by
    have hvp : 0 < (v:ℝ) := by exact_mod_cast (pos_iff_ne_zero.mpr hv)
    have hvr : (v:ℝ) ≤ 1 := by exact_mod_cast hvone
    have hh : 1 ≤ (v:ℝ)⁻¹ := (one_le_inv₀ hvp).mpr hvr
    linarith
  have hprod := mul_le_mul_of_nonneg_left (hlog.trans (sub_le_sub_right hratio 1)) (by linarith : 0 ≤ ((v:ℝ)⁻¹-1)/2)
  change _ = _ + _ + ((v:ℝ)⁻¹-1)/2*M at heq
  unfold subcriticalCostBaseline
  linarith

#print axioms adjusted_subcritical_scalar_cost

/-- The adjusted charge has all three scalar properties required for the
critical occupation argument: positivity, Bellman domination and drift. -/
theorem adjusted_subcritical_scalar_properties
    (Q : Measure ℝ) [IsProbabilityMeasure Q] (v : ℝ≥0)
    (hv : v ≠ 0) (hvone : v ≤ 1) (hKL : klDiv Q (gaussianReal 0 v) ≠ ∞)
    {p qprev qnext : ℝ} (hp : 0 < p) (hpq : p ≤ qprev) (hqn : 0 < qnext)
    (hqone : qprev ≤ 1) (hstep : qnext ≤ scalarTransition p Q) :
    let e := (klDiv Q (gaussianReal 0 v)).toReal-subcriticalCostBaseline v-
      ((v:ℝ)⁻¹-1)/2*Real.log (qnext/qprev)
    0 ≤ e ∧ scalarValue qprev ≤ e+scalarValue qnext ∧
      driftRate * (qnext-qprev+driftDissipation*qprev^2) ≤ e := by
  dsimp only
  have hcost := adjusted_subcritical_scalar_cost Q v hv hvone hKL hp hpq hqn hstep
  have hf := (scalar_subcritical_reference_change Q v hv hvone hKL).1
  have hq := hp.trans_le hpq
  have hb := scalarValue_controlled_step hq hqn hp.le hpq Q inferInstance hf hstep
  have hd := scalar_entropy_drift Q hf hq.le hqone
  have htrans := hstep.trans (scalarTransition_mono Q hp.le hpq)
  refine ⟨ENNReal.toReal_nonneg.trans hcost,by linarith,?_⟩
  have hmul := mul_le_mul_of_nonneg_left htrans driftRate_pos.le
  have hmult := (le_div_iff₀ driftRate_pos).mp
    (show scalarTransition qprev Q-qprev+driftDissipation*qprev^2 ≤
      (klDiv Q (gaussianReal 0 1)).toReal/driftRate from by
      change scalarTransition qprev Q-qprev ≤ _ at hd
      linarith)
  linarith

#print axioms adjusted_subcritical_scalar_properties
end ConditionalNonpolynomial.Analytic
