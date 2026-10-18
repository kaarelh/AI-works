import Mathlib.MeasureTheory.Integral.Bochner.Set
import Mathlib.Probability.ProbabilityMassFunction.Integrals
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import NeuralGeneralization.RobustStatistics

/-! # Confidence guarantees for arbitrary posterior mixtures

The posterior below is a probability measure on the full parameter space.
No selection of a predictor and no concentration on one minimizer occurs.
-/

noncomputable section
open MeasureTheory

namespace NeuralGeneralization.RobustConfidence

variable {X W : Type*} [MeasurableSpace X] [MeasurableSpace W]

theorem low_confidence_probability_le (D : Measure X) [IsProbabilityMeasure D]
    (p : X → ℝ) (hp : Measurable p) (hupper : ∀ x, p x ≤ 1)
    {q : ℝ} (hq : q < 1) (hi : Integrable p D) :
    D.real {x | p x ≤ q} ≤ (∫ x, 1 - p x ∂D) / (1 - q) := by
  let E : Set X := {x | p x ≤ q}
  have hE : MeasurableSet E := measurableSet_le hp measurable_const
  have hpoint (x : X) : (1 - q) * E.indicator (fun _ => (1 : ℝ)) x ≤ 1 - p x := by
    by_cases hx : x ∈ E
    · simp only [Set.indicator_of_mem hx]
      have hh : p x ≤ q := hx
      linarith
    · simp only [Set.indicator_of_notMem hx, mul_zero]
      linarith [hupper x]
  have hind : Integrable (E.indicator (fun _ => (1 : ℝ))) D :=
    (integrable_const _).indicator hE
  have hh := integral_mono (hind.const_mul (1 - q)) ((integrable_const 1).sub hi) hpoint
  rw [integral_const_mul] at hh
  have he : (∫ x, E.indicator (fun _ => (1 : ℝ)) x ∂D) = D.real E := by
    exact integral_indicator_one hE
  rw [he] at hh
  exact (le_div_iff₀ (sub_pos.mpr hq)).mpr (by simpa [E, Pi.sub_apply, mul_comm] using hh)

def correctConfidence (Q : Measure W) (f : X → ℝ) (z : W → X → ℝ)
    (margin : ℝ) (x : X) : ℝ :=
  Q.real {w | margin < f x * z w x}

def gibbsMarginRisk (D : Measure X) (Q : Measure W)
    (f : X → ℝ) (z : W → X → ℝ) (margin : ℝ) : ℝ :=
  ∫ x, Q.real {w | f x * z w x ≤ margin} ∂D

/-- Equality with the literal expectation over a posterior draw followed by
an independent test input. The finite-input interchange is proved explicitly.
-/
theorem gibbsMarginRisk_eq_iterated_indicator [Fintype X] [MeasurableSingletonClass X]
    (D : Measure X) [IsProbabilityMeasure D] (Q : Measure W) [IsProbabilityMeasure Q]
    (f : X → ℝ) (z : W → X → ℝ) (hz : ∀ x, Measurable (fun w => z w x))
    (margin : ℝ) :
    gibbsMarginRisk D Q f z margin =
      ∫ w, ∫ x, (if f x * z w x ≤ margin then (1 : ℝ) else 0) ∂D ∂Q := by
  classical
  let E := fun x => {w | f x * z w x ≤ margin}
  have hE (x : X) : MeasurableSet (E x) :=
    measurableSet_le ((hz x).const_mul _) measurable_const
  have hi (x : X) : Integrable (fun w => if f x * z w x ≤ margin then (1 : ℝ) else 0) Q := by
    exact (integrable_const (1 : ℝ)).indicator (hE x)
  have he (x : X) : (∫ w, (if f x * z w x ≤ margin then (1 : ℝ) else 0) ∂Q) = Q.real (E x) := by
    exact integral_indicator_one (hE x)
  have hinner (w : W) : (∫ x, (if f x * z w x ≤ margin then (1 : ℝ) else 0) ∂D) =
      ∑ x, D.real {x} * (if f x * z w x ≤ margin then (1 : ℝ) else 0) := by
    rw [integral_fintype (RobustStatistics.integrable_finite_domain D _)]
    rfl
  simp_rw [hinner]
  rw [integral_finsetSum Finset.univ (fun x _ => (hi x).const_mul (D.real {x}))]
  simp_rw [integral_const_mul, he]
  unfold gibbsMarginRisk
  rw [integral_fintype (RobustStatistics.integrable_finite_domain D _)]
  rfl

omit [MeasurableSpace X] in
theorem margin_error_eq_one_sub_confidence (Q : Measure W) [IsProbabilityMeasure Q]
    (f : X → ℝ) (z : W → X → ℝ) (hz : ∀ x, Measurable (fun w => z w x))
    (margin : ℝ) (x : X) :
    Q.real {w | f x * z w x ≤ margin} = 1 - correctConfidence Q f z margin x := by
  have hE : MeasurableSet {w | margin < f x * z w x} :=
    measurableSet_lt measurable_const ((hz x).const_mul _)
  have heq : {w | f x * z w x ≤ margin} = {w | margin < f x * z w x}ᶜ := by
    ext w
    simp only [Set.mem_setOf_eq, Set.mem_compl_iff, not_lt]
  rw [heq, probReal_compl_eq_one_sub hE]
  rfl

omit [MeasurableSpace X] in
theorem correctConfidence_le_one (Q : Measure W) [IsProbabilityMeasure Q]
    (f : X → ℝ) (z : W → X → ℝ) (margin : ℝ) (x : X) :
    correctConfidence Q f z margin x ≤ 1 := by
  exact (measureReal_mono (Set.subset_univ _)).trans_eq probReal_univ

theorem margin_confidence_bound [Fintype X] [MeasurableSingletonClass X]
    (D : Measure X) [IsProbabilityMeasure D] (Q : Measure W) [IsProbabilityMeasure Q]
    (f : X → ℝ) (z : W → X → ℝ) (hz : ∀ x, Measurable (fun w => z w x))
    (margin : ℝ) {q ε : ℝ} (hq : q < 1)
    (hrisk : gibbsMarginRisk D Q f z margin ≤ ε) :
    D.real {x | correctConfidence Q f z margin x ≤ q} ≤ ε / (1 - q) := by
  have hbound := low_confidence_probability_le D (correctConfidence Q f z margin)
    (measurable_of_finite _) (correctConfidence_le_one Q f z margin) hq
    (Integrable.of_bound (measurable_of_finite _).aestronglyMeasurable 1
      (Filter.Eventually.of_forall (fun x => by
        rw [Real.norm_eq_abs, abs_of_nonneg (show 0 ≤ correctConfidence Q f z margin x from measureReal_nonneg)]
        exact correctConfidence_le_one Q f z margin x)))
  have heq : (∫ x, 1 - correctConfidence Q f z margin x ∂D) =
      gibbsMarginRisk D Q f z margin := by
    unfold gibbsMarginRisk
    apply integral_congr_ae
    exact Filter.Eventually.of_forall (fun x => (margin_error_eq_one_sub_confidence Q f z hz margin x).symm)
  rw [heq] at hbound
  exact hbound.trans (div_le_div_of_nonneg_right hrisk (sub_pos.mpr hq).le)

theorem sign_confidence_bound [Fintype X] [MeasurableSingletonClass X]
    (D : Measure X) [IsProbabilityMeasure D] (Q : Measure W) [IsProbabilityMeasure Q]
    (f : X → ℝ) (z : W → X → ℝ) (hz : ∀ x, Measurable (fun w => z w x))
    {margin q ε : ℝ} (hmargin : 0 ≤ margin) (hq : q < 1)
    (hrisk : gibbsMarginRisk D Q f z margin ≤ ε) :
    D.real {x | correctConfidence Q f z 0 x ≤ q} ≤ ε / (1 - q) := by
  apply le_trans (measureReal_mono ?_) (margin_confidence_bound D Q f z hz margin hq hrisk)
  intro x hx
  have hmono : correctConfidence Q f z margin x ≤ correctConfidence Q f z 0 x := by
    exact measureReal_mono (fun w hw => lt_of_le_of_lt hmargin hw)
  exact hmono.trans hx

theorem two_thirds_confidence_bound [Fintype X] [MeasurableSingletonClass X]
    (D : Measure X) [IsProbabilityMeasure D] (Q : Measure W) [IsProbabilityMeasure Q]
    (f : X → ℝ) (z : W → X → ℝ) (hz : ∀ x, Measurable (fun w => z w x))
    (margin : ℝ) {ε : ℝ} (hrisk : gibbsMarginRisk D Q f z margin ≤ ε) :
    D.real {x | correctConfidence Q f z margin x ≤ 2 / 3} ≤ 3 * ε := by
  have h := margin_confidence_bound D Q f z hz margin (q := 2 / 3) (by norm_num) hrisk
  norm_num [div_eq_mul_inv] at h ⊢
  simpa only [mul_comm] using h

theorem majority_confidence_bound [Fintype X] [MeasurableSingletonClass X]
    (D : Measure X) [IsProbabilityMeasure D] (Q : Measure W) [IsProbabilityMeasure Q]
    (f : X → ℝ) (z : W → X → ℝ) (hz : ∀ x, Measurable (fun w => z w x))
    (margin : ℝ) {ε : ℝ} (hrisk : gibbsMarginRisk D Q f z margin ≤ ε) :
    D.real {x | correctConfidence Q f z margin x ≤ 1 / 2} ≤ 2 * ε := by
  have h := margin_confidence_bound D Q f z hz margin (q := 1 / 2) (by norm_num) hrisk
  norm_num [div_eq_mul_inv] at h ⊢
  simpa only [mul_comm] using h

end NeuralGeneralization.RobustConfidence
