import Mathlib

/-!
Finite observed-coordinate sparsification on an exposed unit-cost atom face.
The neural application supplies the atom set, its saturating dual functional,
and the normalized observed output. These identifications are hypotheses here.
The resulting witness uses at most the dimension of the observation space,
preserves every observed coordinate, and preserves total coefficient cost.
-/

namespace IndependentResearch
open scoped BigOperators

/-- An affine-independent family on a nonzero dual level is linearly independent. -/
theorem dual_face_linearIndependent {E ι : Type*}
    [AddCommGroup E] [Module ℝ E] (p : ι → E) (dual : E →ₗ[ℝ] ℝ)
    (hp : AffineIndependent ℝ p) (hdual : ∀ i, dual (p i) = 1) :
    LinearIndependent ℝ p := by
  rw [linearIndependent_iff']
  intro s w hsum
  have hw : ∑ i ∈ s, w i = 0 := by
    have hh := congrArg dual hsum
    simpa only [map_sum, map_smul, hdual, smul_eq_mul, mul_one, map_zero] using hh
  exact hp.eq_zero_of_sum_eq_zero hw hsum

/-- Caratheodory on a saturating dual face preserves an observed output and
its coefficient cost using no more atoms than observed-coordinate dimension. -/
theorem sparse_dual_face_calibration {E : Type*}
    [AddCommGroup E] [Module ℝ E] [FiniteDimensional ℝ E]
    (s : Set E) (dual : E →ₗ[ℝ] ℝ) (hdual : ∀ z ∈ s, dual z = 1)
    (x : E) (hx : x ∈ convexHull ℝ s) (cost : ℝ) (hc : 0 ≤ cost) :
    ∃ (t : Finset E) (c : E → ℝ),
      (↑t : Set E) ⊆ s ∧ t.card ≤ Module.finrank ℝ E ∧
      (∀ z ∈ t, 0 ≤ c z) ∧ (∑ z ∈ t, c z) = cost ∧
      (∑ z ∈ t, c z • z) = cost • x := by
  classical
  let t := Caratheodory.minCardFinsetOfMemConvexHull hx
  have ht : (↑t : Set E) ⊆ s := Caratheodory.minCardFinsetOfMemConvexHull_subseteq hx
  have hai : AffineIndependent ℝ ((↑) : t → E) :=
    Caratheodory.affineIndependent_minCardFinsetOfMemConvexHull hx
  have hli : LinearIndependent ℝ ((↑) : t → E) :=
    dual_face_linearIndependent _ dual hai (fun z => hdual z (ht z.property))
  have hcard : t.card ≤ Module.finrank ℝ E := hli.finset_card_le_finrank
  have hxt : x ∈ convexHull ℝ (↑t : Set E) :=
    Caratheodory.mem_minCardFinsetOfMemConvexHull hx
  obtain ⟨w, hw, hsum, hvalue⟩ := Finset.mem_convexHull'.mp hxt
  refine ⟨t, fun z => cost * w z, ht, hcard, ?_, ?_, ?_⟩
  · exact fun z hz => mul_nonneg hc (hw z hz)
  · rw [← Finset.mul_sum, hsum, mul_one]
  · simp_rw [mul_smul]
    rw [← Finset.smul_sum, hvalue]

end IndependentResearch
