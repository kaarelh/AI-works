import GaussianDenseCertificate
import BoundedTiltKL

/-! A finite controlled covariance path extracted from the aggregate dense
cost. The row laws are actual exponential tilts, and the budget is their
Mathlib relative entropy. This is the approximate path before covariance
repair; no recursion or repair theorem is assumed here. -/
noncomputable section
set_option linter.unusedSectionVars false
open MeasureTheory InformationTheory
open scoped BigOperators ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.BoundedDual NeuralGeneralization.BoundedTilt
open NeuralGeneralization.ActualBoundedDual

variable {Ω ι κ : Type*} [MeasurableSpace Ω]
variable [Fintype ι] [DecidableEq ι] [Nonempty ι] [Fintype κ]

lemma denseCost_nonneg (μ : Measure Ω) [IsProbabilityMeasure μ]
    (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) {G : ℝ} (hG : 0 < G)
    {M N : ℕ} (hM : 0 < M) (hN : 0 < N)
    (q : ι → ℝ) (hq : ∀ i, |q i| ≤ 1) :
    0 ≤ denseCost μ T G M N q := by
  obtain ⟨star,_,hent,_⟩ := exists_tilt_of_denseCost μ T hT hbound hG hM hN q hq
  exact (actual_entropy_nonneg μ T hT hbound star).trans hent

/-- A checked extraction of all controlled row laws at once. The premise is
an aggregate finite-grid statistic, whose actual Gaussian exponential moment
is established layerwise in `GaussianDenseCertificate`. -/
theorem exists_controlled_path_of_cost
    (μ : κ → Measure Ω) [∀ j, IsProbabilityMeasure (μ j)]
    (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1)
    (q : κ → ι → ℝ) (hq : ∀ j i, |q j i| ≤ 1)
    {G B : ℝ} (hG : 0 < G) {M N : ℕ} (hM : 0 < M) (hN : 0 < N)
    (hcost : (∑ j, denseCost (μ j) T G M N (q j)) ≤ B) :
    ∃ star : κ → ι → ℝ,
      (∀ j, entryL1 (star j) ≤ G) ∧
      (∀ j, IsProbabilityMeasure ((μ j).tilted (potential T (star j)))) ∧
      (∀ j, klDiv ((μ j).tilted (potential T (star j))) (μ j) ≠ ∞) ∧
      (∑ j, (klDiv ((μ j).tilted (potential T (star j))) (μ j)).toReal) ≤ B ∧
      ∀ j, maxAbs (q j-mean (μ j) T (star j)) ≤ B/G := by
  classical
  have hex j := exists_tilt_of_denseCost (μ j) T hT hbound hG hM hN (q j) (hq j)
  choose star hstar hent herr using hex
  have heq j : (klDiv ((μ j).tilted (potential T (star j))) (μ j)).toReal =
      entropy (μ j) T (star j) := by
    rw [boundedTilt_klDiv_eq (μ j) _ (measurable_potential T hT (star j))
      (potential_bound T hbound (star j))]
    change (ENNReal.ofReal (entropy (μ j) T (star j))).toReal = _
    exact ENNReal.toReal_ofReal (actual_entropy_nonneg (μ j) T hT hbound (star j))
  refine ⟨star,hstar,?_,?_,?_,?_⟩
  · intro j
    exact tilted_probability (μ j) _ (measurable_potential T hT (star j))
      (potential_bound T hbound (star j))
  · intro j
    exact boundedTilt_klDiv_ne_top (μ j) _ (measurable_potential T hT (star j))
      (potential_bound T hbound (star j))
  · simp_rw [heq]
    exact (Finset.sum_le_sum (fun j _ => hent j)).trans hcost
  · intro j
    have hsingle : denseCost (μ j) T G M N (q j) ≤ B := by
      apply le_trans _ hcost
      exact Finset.single_le_sum (fun k _ =>
        denseCost_nonneg (μ k) T hT hbound hG hM hN (q k) (hq k)) (Finset.mem_univ j)
    exact (herr j).trans (div_le_div_of_nonneg_right hsingle hG.le)

#print axioms exists_controlled_path_of_cost
end ConditionalNonpolynomial.Analytic
