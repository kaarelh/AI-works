import Mathlib.MeasureTheory.Integral.Prod
import Mathlib.MeasureTheory.Measure.Real

/-! # Product-event bounds from uniform section estimates off an exception set -/
noncomputable section
open MeasureTheory
namespace NeuralGeneralization

theorem product_event_mass_le
    {α β : Type*} [MeasurableSpace α] [MeasurableSpace β]
    (μ : Measure α) (ν : Measure β) [IsProbabilityMeasure μ] [IsProbabilityMeasure ν]
    (A : Set α) (hA : MeasurableSet A) (E : Set (α × β)) (hE : MeasurableSet E)
    (b : ℝ) (hb : 0 ≤ b)
    (hsections : ∀ x ∉ A, ν.real {y | (x,y) ∈ E} ≤ b) :
    (μ.prod ν).real E ≤ μ.real A+b := by
  let F : α × β → ℝ := E.indicator (fun _ => 1)
  have hF : Integrable F (μ.prod ν) := (integrable_const (1:ℝ)).indicator hE
  have hsection (x : α) : (∫ y, F (x,y) ∂ν) = ν.real {y | (x,y) ∈ E} := by
    have hs : MeasurableSet {y : β | (x,y) ∈ E} := hE.preimage measurable_prodMk_left
    have hf : (fun y => F (x,y)) = {y | (x,y) ∈ E}.indicator (fun _ => (1:ℝ)) := by
      funext y
      simp [F, Set.indicator]
    rw [hf, integral_indicator_const _ hs]
    simp
  have hpoint (x : α) : (∫ y, F (x,y) ∂ν) ≤ A.indicator (fun _ => (1:ℝ)) x+b := by
    rw [hsection]
    by_cases hx : x ∈ A
    · rw [Set.indicator_of_mem hx]
      have hm : ν.real {y | (x,y) ∈ E} ≤ 1 := measureReal_le_one
      linarith
    · rw [Set.indicator_of_notMem hx, zero_add]
      exact hsections x hx
  have hr : Integrable (fun x => A.indicator (fun _ => (1:ℝ)) x+b) μ :=
    ((integrable_const (1:ℝ)).indicator hA).add (integrable_const b)
  have hi := integral_mono hF.integral_prod_left hr hpoint
  rw [← integral_prod F hF] at hi
  dsimp only [F] at hi
  rw [integral_indicator_const _ hE,
    integral_add ((integrable_const (1:ℝ)).indicator hA) (integrable_const b),
    integral_indicator_const _ hA, integral_const] at hi
  simpa using hi


/-- Uniform lower bounds on sections off an exceptional set give the matching
actual product-event lower bound. -/
theorem product_event_mass_ge
    {α β : Type*} [MeasurableSpace α] [MeasurableSpace β]
    (μ : Measure α) (ν : Measure β) [IsProbabilityMeasure μ] [IsProbabilityMeasure ν]
    (A : Set α) (hA : MeasurableSet A) (E : Set (α × β)) (hE : MeasurableSet E)
    (b : ℝ) (_hb : 0 ≤ b)
    (hsections : ∀ x ∉ A, b ≤ ν.real {y | (x,y) ∈ E}) :
    b*(1-μ.real A) ≤ (μ.prod ν).real E := by
  let F : α × β → ℝ := E.indicator (fun _ => 1)
  have hF : Integrable F (μ.prod ν) := (integrable_const (1:ℝ)).indicator hE
  have hsection (x : α) : (∫ y, F (x,y) ∂ν) = ν.real {y | (x,y) ∈ E} := by
    have hs : MeasurableSet {y : β | (x,y) ∈ E} := hE.preimage measurable_prodMk_left
    have hf : (fun y => F (x,y)) = {y | (x,y) ∈ E}.indicator (fun _ => (1:ℝ)) := by
      funext y
      simp [F, Set.indicator]
    rw [hf, integral_indicator_const _ hs]
    simp
  have hpoint (x : α) : Aᶜ.indicator (fun _ => b) x ≤ (∫ y, F (x,y) ∂ν) := by
    rw [hsection]
    by_cases hx : x ∈ A
    · rw [Set.indicator_of_notMem (by simpa only [Set.mem_compl_iff, not_not] using hx)]
      exact measureReal_nonneg
    · rw [Set.indicator_of_mem hx]
      exact hsections x hx
  have hi := integral_mono ((integrable_const b).indicator hA.compl)
    hF.integral_prod_left hpoint
  rw [← integral_prod F hF] at hi
  dsimp only [F] at hi
  rw [integral_indicator_const _ hE, integral_indicator_const _ hA.compl,
    probReal_compl_eq_one_sub hA] at hi
  simpa only [smul_eq_mul, mul_one, one_mul, mul_comm] using hi

end NeuralGeneralization
