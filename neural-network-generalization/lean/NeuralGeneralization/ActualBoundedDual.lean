import NeuralGeneralization.BoundedObservables
import NeuralGeneralization.BoundedTiltDeriv

/-! # Existence of a bounded dual lift for actual bounded observables
The optimizer, its first-order condition, and its entropy/error identity
are proved for the actual exponential family; none is a certificate premise.
-/
noncomputable section
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.ActualBoundedDual
open BoundedDual BoundedTilt
variable {Ω ι : Type*} [MeasurableSpace Ω] [Fintype ι] [DecidableEq ι] [Nonempty ι]
variable (μ : Measure Ω) [IsProbabilityMeasure μ]

omit [DecidableEq ι] [Nonempty ι] in
lemma hasDerivAt_objective_line (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) (q star dir : ι → ℝ) :
    HasDerivAt (fun t : ℝ => objective μ T q (star + t • dir))
      (pairing (q - mean μ T star) dir) 0 := by
  letI : IsProbabilityMeasure (μ.tilted (potential T star)) :=
    tilted_probability μ _ (measurable_potential T hT star) (potential_bound T hbound star)
  have hlog : HasDerivAt
      (fun t : ℝ => Real.log (partition μ (potential T (star + t • dir))))
      (pairing dir (mean μ T star)) 0 := by
    have h := hasDerivAt_log_partition_line μ (potential T star) (potential T dir)
      (measurable_potential T hT star) (measurable_potential T hT dir)
      (potential_bound T hbound star) (potential_bound T hbound dir)
    rw [integral_potential _ T hT hbound dir] at h
    change HasDerivAt _
      (pairing dir (fun i => ∫ x, T i x ∂(μ.tilted (potential T star)))) 0
    simpa only [potential_line] using h
  have hlinear : (fun t : ℝ => pairing (star + t • dir) q) =
      fun t => pairing star q + t * pairing dir q := by
    funext t
    simp only [pairing, Pi.add_apply, Pi.smul_apply, smul_eq_mul, add_mul,
      Finset.sum_add_distrib, Finset.mul_sum, mul_assoc]
  have hlin : HasDerivAt (fun t : ℝ => pairing (star + t • dir) q) (pairing dir q) 0 := by
    rw [hlinear]
    simpa using ((hasDerivAt_id (0 : ℝ)).mul_const (pairing dir q)).const_add (pairing star q)
  have h := hlin.sub hlog
  rw [pairing_comm dir q, pairing_comm dir (mean μ T star), ← pairing_sub_left] at h
  exact h

/-- A genuine bounded exponential tilt realizes the exact entropy/error
decomposition at a maximizer of the bounded dual objective. -/
theorem exists_bounded_dual_lift
    (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) (q : ι → ℝ) {G : ℝ} (hG : 0 ≤ G) :
    ∃ star : ι → ℝ, entryL1 star ≤ G ∧
      IsMaxOn (objective μ T q) {v : ι → ℝ | entryL1 v ≤ G} star ∧
      0 ≤ entropy μ T star ∧
      objective μ T q star = entropy μ T star + G * maxAbs (q - mean μ T star) := by
  have hne : ({v : ι → ℝ | entryL1 v ≤ G} : Set (ι → ℝ)).Nonempty := by
    refine ⟨0, ?_⟩
    change entryL1 (0 : ι → ℝ) ≤ G
    simpa only [entryL1, Pi.zero_apply, abs_zero, Finset.sum_const_zero] using hG
  obtain ⟨star, hstar, hmax⟩ := (isCompact_entryL1_ball hG).exists_isMaxOn hne
    (continuousOn_objective_ball μ T hT hbound q G)
  have hfirst : ∀ v : ι → ℝ, entryL1 v ≤ G →
      pairing (q - mean μ T star) (v - star) ≤ 0 := by
    intro v hv
    exact first_order_of_segment_derivative (objective μ T q) star v hstar hv hmax
      (hasDerivAt_objective_line μ T hT hbound q star (v - star))
  refine ⟨star, hstar, hmax, actual_entropy_nonneg μ T hT hbound star, ?_⟩
  exact exact_entropy_error_decomposition q (mean μ T star) star hG hstar hfirst
    (actual_entropy_identity μ T hT hbound star)

/-- If the objective on the bounded parameter ball is at most K, the constructed
tilt simultaneously has entropy at most K and coordinate error at most K/G.
The upper-bound premise is exactly the bounded variational rate condition,
not an assumed tilt or optimizer. -/
theorem exists_bounded_dual_lift_of_rate_bound
    (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) (q : ι → ℝ) {G K : ℝ} (hG : 0 < G)
    (hrate : ∀ v : ι → ℝ, entryL1 v ≤ G → objective μ T q v ≤ K) :
    ∃ star : ι → ℝ, entryL1 star ≤ G ∧ entropy μ T star ≤ K ∧
      maxAbs (q - mean μ T star) ≤ K / G := by
  obtain ⟨star, hstar, _, hnonneg, hid⟩ := exists_bounded_dual_lift μ T hT hbound q hG.le
  have herror_nonneg : 0 ≤ G * maxAbs (q - mean μ T star) :=
    mul_nonneg hG.le (maxAbs_nonneg _)
  have hK := hrate star hstar
  refine ⟨star, hstar, by linarith, ?_⟩
  apply (le_div_iff₀ hG).2
  nlinarith

end NeuralGeneralization.ActualBoundedDual

end
