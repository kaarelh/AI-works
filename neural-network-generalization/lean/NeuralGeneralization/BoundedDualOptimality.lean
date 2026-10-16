import NeuralGeneralization.BoundedDual
import Mathlib.Analysis.Calculus.LocalExtr.Basic
import Mathlib.Analysis.Convex.Topology
import Mathlib.Analysis.Normed.Group.Constructions
import Mathlib.Analysis.Normed.Group.Real
import Mathlib.Topology.Algebra.Monoid
import Mathlib.Topology.MetricSpace.ProperSpace
import Mathlib.Topology.Order.Compact

/-!
# Compact optimization on the bounded-dual parameter ball

These theorems construct a maximizer on the finite ℓ¹ ball and derive its
first-order support identity from genuine differentiability. The analytic
construction and differentiation of the Gaussian log-MGF are separate
obligations; this file does not assert them.
-/

namespace NeuralGeneralization.BoundedDual

open scoped BigOperators

variable {ι : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]

omit [DecidableEq ι] [Nonempty ι] in
lemma continuous_entryL1 : Continuous (entryL1 : (ι → ℝ) → ℝ) := by
  exact continuous_finsetSum _ (fun i _ => (continuous_apply i).abs)

omit [DecidableEq ι] [Nonempty ι] in
lemma convex_entryL1_ball (G : ℝ) : Convex ℝ {v : ι → ℝ | entryL1 v ≤ G} := by
  intro x hx y hy a b ha hb hab
  change entryL1 x ≤ G at hx
  change entryL1 y ≤ G at hy
  change (∑ i, |a * x i + b * y i|) ≤ G
  calc
    (∑ i, |a * x i + b * y i|) ≤ ∑ i, (a * |x i| + b * |y i|) := by
      apply Finset.sum_le_sum
      intro i hi
      calc
        |a * x i + b * y i| ≤ |a * x i| + |b * y i| := abs_add_le _ _
        _ = a * |x i| + b * |y i| := by
          rw [abs_mul, abs_mul, abs_of_nonneg ha, abs_of_nonneg hb]
    _ = a * entryL1 x + b * entryL1 y := by
      rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum]
      rfl
    _ ≤ a * G + b * G := add_le_add
      (mul_le_mul_of_nonneg_left hx ha) (mul_le_mul_of_nonneg_left hy hb)
    _ = G := by rw [← add_mul, hab, one_mul]

omit [DecidableEq ι] [Nonempty ι] in
lemma isCompact_entryL1_ball {G : ℝ} (hG : 0 ≤ G) :
    IsCompact {v : ι → ℝ | entryL1 v ≤ G} := by
  have hclosed : IsClosed {v : ι → ℝ | entryL1 v ≤ G} :=
    isClosed_le continuous_entryL1 continuous_const
  apply (isCompact_closedBall (0 : ι → ℝ) G).of_isClosed_subset hclosed
  intro v hv
  have hnorm : ‖v‖ ≤ G := by
    apply (pi_norm_le_iff_of_nonneg hG).2
    intro i
    rw [Real.norm_eq_abs]
    exact (Finset.single_le_sum (fun j _ => abs_nonneg (v j))
      (Finset.mem_univ i)).trans hv
  simpa only [Metric.mem_closedBall, dist_zero_right] using hnorm

omit [DecidableEq ι] [Nonempty ι] in
/-- Actual maximizer existence, with no assumed optimizer witness. -/
theorem exists_maximizer_entryL1_ball (F : (ι → ℝ) → ℝ)
    (hF : Continuous F) {G : ℝ} (hG : 0 ≤ G) :
    ∃ star : ι → ℝ, entryL1 star ≤ G ∧
      IsMaxOn F {v : ι → ℝ | entryL1 v ≤ G} star := by
  have hne : ({v : ι → ℝ | entryL1 v ≤ G} : Set (ι → ℝ)).Nonempty := by
    refine ⟨0, ?_⟩
    change entryL1 (0 : ι → ℝ) ≤ G
    simpa only [entryL1, Pi.zero_apply, abs_zero, Finset.sum_const_zero] using hG
  exact (isCompact_entryL1_ball hG).exists_isMaxOn hne hF.continuousOn

omit [DecidableEq ι] [Nonempty ι] in
/-- A differentiable maximum on the convex ball gives the exact first-order
inequality, including maxima on the boundary. -/
theorem first_order_of_maximizer
    (F : (ι → ℝ) → ℝ) (D : (ι → ℝ) →L[ℝ] ℝ) (star : ι → ℝ) {G : ℝ}
    (hstar : entryL1 star ≤ G)
    (hmax : IsMaxOn F {v : ι → ℝ | entryL1 v ≤ G} star)
    (hD : HasFDerivAt F D star) :
    ∀ v : ι → ℝ, entryL1 v ≤ G → D (v - star) ≤ 0 := by
  intro v hv
  exact hmax.localize.hasFDerivWithinAt_nonpos hD.hasFDerivWithinAt
    (sub_mem_posTangentConeAt_of_segment_subset
      ((convex_entryL1_ball G).segment_subset hstar hv))

omit [DecidableEq ι] [Nonempty ι] in
/-- It is enough to differentiate the one-dimensional segment toward each
competitor. This permits the log-partition application to use the ordinary
moment-generating-function derivative. -/
theorem first_order_of_segment_derivative
    (F : (ι → ℝ) → ℝ) (star v : ι → ℝ) {G slope : ℝ}
    (hstar : entryL1 star ≤ G) (hv : entryL1 v ≤ G)
    (hmax : IsMaxOn F {w : ι → ℝ | entryL1 w ≤ G} star)
    (hderiv : HasDerivAt (fun t : ℝ => F (star + t • (v - star))) slope 0) :
    slope ≤ 0 := by
  have hline : IsMaxOn (fun t : ℝ => F (star + t • (v - star)))
      (Set.Icc 0 1) 0 := by
    intro t ht
    have hcomb := (convex_entryL1_ball G) hstar hv
      (sub_nonneg.mpr ht.2) ht.1 (by ring : (1 - t) + t = 1)
    have heq : (1 - t) • star + t • v = star + t • (v - star) := by
      ext i
      simp only [Pi.add_apply, Pi.smul_apply, Pi.sub_apply, smul_eq_mul]
      ring
    rw [heq] at hcomb
    simpa only [Set.mem_setOf_eq, zero_smul, add_zero] using hmax hcomb
  have htangent : (1 : ℝ) ∈ posTangentConeAt (Set.Icc 0 1) (0 : ℝ) := by
    have h := sub_mem_posTangentConeAt_of_segment_subset
      (show segment ℝ (0 : ℝ) 1 ⊆ Set.Icc 0 1 by
        rw [segment_eq_Icc (by norm_num : (0 : ℝ) ≤ 1)])
    simpa only [sub_zero] using h
  have h := hline.localize.hasFDerivWithinAt_nonpos
    hderiv.hasFDerivAt.hasFDerivWithinAt htangent
  simpa using h

/-- A continuous differentiable objective attains a maximum whose gradient
satisfies the ℓ¹/ℓ∞ support identity. -/
theorem exists_maximizer_with_support
    (F : (ι → ℝ) → ℝ) (gradient : (ι → ℝ) → (ι → ℝ))
    (D : (ι → ℝ) → ((ι → ℝ) →L[ℝ] ℝ))
    (hF : Continuous F)
    (hD : ∀ star, HasFDerivAt F (D star) star)
    (hgradient : ∀ star v, D star v = pairing (gradient star) v)
    {G : ℝ} (hG : 0 ≤ G) :
    ∃ star : ι → ℝ, entryL1 star ≤ G ∧
      IsMaxOn F {v : ι → ℝ | entryL1 v ≤ G} star ∧
      pairing (gradient star) star = G * maxAbs (gradient star) := by
  obtain ⟨star, hstar, hmax⟩ := exists_maximizer_entryL1_ball F hF hG
  refine ⟨star, hstar, hmax, support_eq_of_first_order (gradient star) star hG hstar ?_⟩
  intro v hv
  have h := first_order_of_maximizer F (D star) star hstar hmax (hD star) v hv
  simpa only [hgradient] using h

end NeuralGeneralization.BoundedDual
