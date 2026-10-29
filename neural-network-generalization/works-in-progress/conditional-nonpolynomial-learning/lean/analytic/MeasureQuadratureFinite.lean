import FiniteMaurey
import Mathlib.Analysis.Convex.Integral
import Mathlib.Analysis.Convex.Combination
import Mathlib.MeasureTheory.SpecificCodomains.Pi

/-! Empirical quadrature for finitely many bounded observables under an
arbitrary probability measure. The proof first approximates the Bochner mean
by a finite convex combination of genuine sample values, then applies the
already proved finite-distribution Maurey/concentration theorem. No empirical
approximation or concentration hypothesis is assumed. -/

noncomputable section
open MeasureTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open BooleanDepthResearch.FiniteProbability

/-- A common empirical sample approximates every member of a finite family of
bounded Hilbert-valued observables. Sample count depends logarithmically on the
number of observables, and not on the size of the underlying probability space. -/
theorem measure_finite_input_maurey
    {Ω K E : Type*} [MeasurableSpace Ω] [Fintype K] [Nonempty K]
    [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (v : K → Ω → E) (hvInt : ∀ k, Integrable (v k) μ)
    (J ε : ℝ) (hJ : 0 < J) (hε : 0 < ε)
    (hv : ∀ k x, ‖v k x‖ ≤ J) (m : ℕ) (hm : 0 < m)
    (hbudget : 256*J^2*(1+Real.log (Fintype.card K)) ≤ (m:ℝ)*ε^2) :
    ∃ s : Fin m → Ω, ∀ k,
      ‖(m:ℝ)⁻¹ • (∑ j, v k (s j)) - ∫ x, v k x ∂μ‖ < ε := by
  classical
  let F : Ω → K → E := fun x k => v k x
  have hFInt : Integrable F μ := integrable_pi_iff.mpr hvInt
  have hclosure : (∫ x, F x ∂μ) ∈ closure (convexHull ℝ (Set.range F)) := by
    apply (convex_convexHull ℝ (Set.range F)).closure.integral_mem isClosed_closure _ hFInt
    exact Filter.Eventually.of_forall (fun x => subset_closure (subset_convexHull ℝ _ (Set.mem_range_self x)))
  obtain ⟨z,hz,hclose⟩ := Metric.mem_closure_iff.mp hclosure (ε/2) (by positivity)
  obtain ⟨I,hI,p,w,hp0,hp,hw,hwz⟩ := mem_convexHull_iff_exists_fintype.mp hz
  letI : Fintype I := hI
  choose nodes hnodes using hw
  have hcoordinates (k : K) :
      ‖vectorAvg p (fun i => v k (nodes i)) - ∫ x, v k x ∂μ‖ < ε/2 := by
    have hnorm : ‖z - ∫ x, F x ∂μ‖ < ε/2 := by
      simpa only [dist_eq_norm, norm_sub_rev] using hclose
    have hcoord := (norm_le_pi_norm (z - ∫ x, F x ∂μ) k).trans_lt hnorm
    have hzcoord : z k = vectorAvg p (fun i => v k (nodes i)) := by
      rw [← hwz]
      simp only [Finset.sum_apply, Pi.smul_apply, vectorAvg]
      apply Finset.sum_congr rfl
      intro i hi
      rw [← hnodes i]
    simpa only [Pi.sub_apply, hzcoord, eval_integral (f:=F) hvInt k] using hcoord
  obtain ⟨s,hs⟩ := finite_input_maurey p hp0 hp
    (fun k i => v k (nodes i)) J (ε/2) hJ (by positivity)
    (fun k i => hv k (nodes i)) m hm (by nlinarith)
  refine ⟨fun j => nodes (s j), fun k => ?_⟩
  have hsum := norm_sub_le_norm_sub_add_norm_sub ((m:ℝ)⁻¹ • (∑ j, v k (nodes (s j))))
    (vectorAvg p (fun i => v k (nodes i))) (∫ x, v k x ∂μ)
  exact hsum.trans_lt (by linarith [hs k, hcoordinates k])

#print axioms measure_finite_input_maurey
end ConditionalNonpolynomial.Analytic
