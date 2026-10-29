import ControlHistory
import Mathlib.MeasureTheory.Integral.Prod

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal
namespace ConditionalNonpolynomial.Analytic

/-- A good-history conditional success bound loses at most its stated failure
probability after averaging over the actual previous-history law. -/
theorem product_success_step {A B : Type*} [MeasurableSpace A] [MeasurableSpace B]
    (μ : Measure A) (ν : Measure B) [IsProbabilityMeasure μ] [IsProbabilityMeasure ν]
    (G : Set A) (E : Set (A×B)) (hG : MeasurableSet G) (hE : MeasurableSet E)
    {κ : ℝ} (hκ : 0≤κ) (hκ1 : κ≤1)
    (hgood : ∀a∈G,1-κ≤ν.real (Prod.mk a ⁻¹' E)) :
    μ.real G-κ≤(μ.prod ν).real E := by
  classical
  have hpoint : G.indicator (fun _=>ENNReal.ofReal (1-κ))≤fun a=>ν (Prod.mk a ⁻¹' E) := by
    intro a
    by_cases ha : a∈G
    · rw [Set.indicator_of_mem ha]
      have hh := ENNReal.ofReal_le_ofReal (hgood a ha)
      simpa only [Measure.real,ENNReal.ofReal_toReal (measure_ne_top _ _)] using hh
    · simp only [Set.indicator_of_notMem ha]
      exact bot_le
  have h := lintegral_mono (μ:=μ) hpoint
  rw [lintegral_indicator hG,lintegral_const,Measure.restrict_apply_univ,
    ←Measure.prod_apply hE] at h
  have hr := ENNReal.toReal_mono (measure_ne_top _ _) h
  simp only [ENNReal.toReal_mul,ENNReal.toReal_ofReal (sub_nonneg.mpr hκ1)] at hr
  have hp : μ.real G≤1 := measureReal_le_one
  change (1-κ)*μ.real G≤(μ.prod ν).real E at hr
  nlinarith

/-- Actual product-history induction, allowing each next-stage event to depend
on the whole past. Its statement is a probability theorem, not an independence
assumption about the resulting good events. -/
theorem controlHistory_success {H R : Type} [MeasurableSpace H] [MeasurableSpace R]
    (μ : Measure H) (ρ : ℕ→Measure R) [IsProbabilityMeasure μ]
    [∀n,IsProbabilityMeasure (ρ n)]
    (G : (n : ℕ)→Set (ControlHistory H R n))
    (hG : ∀n,MeasurableSet (G n)) (κ : ℕ→ℝ) (hκ : ∀n,0≤κ n)
    (hκ1 : ∀n,κ n≤1) {η : ℝ} (hinit : 1-η≤μ.real (G 0))
    (hstep : ∀n h,h∈G n→1-κ n≤(ρ n).real (Prod.mk h ⁻¹' G (n+1)))
    (n : ℕ) :
    1-η-(∑j : Fin n,κ j)≤(controlHistoryLaw μ ρ n).real (G n) := by
  induction n with
  | zero =>
      simp only [Fin.sum_univ_zero,sub_zero]
      exact hinit
  | succ n ih =>
      have hh := product_success_step (controlHistoryLaw μ ρ n) (ρ n) (G n) (G (n+1))
        (hG n) (hG (n+1)) (hκ n) (hκ1 n) (hstep n)
      change 1-η-(∑j : Fin (n+1),κ j)≤
        ((controlHistoryLaw μ ρ n).prod (ρ n)).real (G (n+1))
      rw [Fin.sum_univ_castSucc]
      simp only [Fin.val_castSucc,Fin.val_last]
      linarith

#print axioms product_success_step
#print axioms controlHistory_success
end ConditionalNonpolynomial.Analytic
