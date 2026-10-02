import Mathlib.MeasureTheory.Covering.BesicovitchVectorSpace
import Mathlib.Analysis.InnerProductSpace.Dual

/-!
# Finite nets for Gaussian operator estimates

A maximal separated set and the finite-dimensional volume packing bound give
a half-net of the unit ball with at most `5^dim` points. Two such nets test the
operator norm through finitely many bilinear functionals.
-/

namespace Paulsen
open Set Metric
noncomputable section

variable {E F : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
  [NormedAddCommGroup F] [NormedSpace ℝ F]

theorem exists_half_unit_ball_net [FiniteDimensional ℝ E] :
    ∃ s : Finset E, s.card ≤ 5 ^ Module.finrank ℝ E ∧
      (∀ x ∈ s, ‖x‖ ≤ 1) ∧
      ∀ x : E, ‖x‖ ≤ 1 → ∃ y ∈ s, ‖x - y‖ < 1 / 2 := by
  classical
  let good : Finset E → Prop := fun s =>
    (∀ x ∈ s, ‖x‖ ≤ 2) ∧ ∀ x ∈ s, ∀ y ∈ s, x ≠ y → 1 ≤ ‖x - y‖
  let cards : Set ℕ := {k | ∃ s : Finset E, good s ∧ s.card = k}
  have hne : cards.Nonempty := ⟨0, ∅, by simp [good], rfl⟩
  have hb : BddAbove cards := ⟨5 ^ Module.finrank ℝ E, by
    rintro k ⟨s, hs, rfl⟩
    exact Besicovitch.card_le_of_separated s hs.1 hs.2⟩
  obtain ⟨k, hk, hmax⟩ := hb.exists_isGreatest_of_nonempty hne
  obtain ⟨s, hs, hcard⟩ := hk
  have hcover (x : E) (hx : ‖x‖ ≤ 2) : ∃ y ∈ s, ‖x - y‖ < 1 := by
    by_contra! h
    have hxs : x ∉ s := by
      intro hx'
      have hbad := h x hx'
      norm_num at hbad
    have hgood : good (insert x s) := by
      constructor
      · intro y hy
        rcases Finset.mem_insert.mp hy with rfl | hy'
        · exact hx
        · exact hs.1 y hy'
      · intro y hy z hz hyz
        rcases Finset.mem_insert.mp hy with rfl | hy'
        · rcases Finset.mem_insert.mp hz with rfl | hz
          · exact False.elim (hyz rfl)
          · exact h z hz
        · rcases Finset.mem_insert.mp hz with rfl | hz
          · simpa only [norm_sub_rev] using h y hy'
          · exact hs.2 y hy' z hz hyz
    have hlarge := hmax ⟨insert x s, hgood, rfl⟩
    rw [Finset.card_insert_of_notMem hxs, hcard] at hlarge
    omega
  refine ⟨s.image (fun x => (1 / 2 : ℝ) • x),
    (Finset.card_image_le).trans (Besicovitch.card_le_of_separated s hs.1 hs.2), ?_, ?_⟩
  · intro x hx
    obtain ⟨y, hy, rfl⟩ := Finset.mem_image.mp hx
    rw [norm_smul, Real.norm_eq_abs]
    norm_num
    linarith [hs.1 y hy]
  · intro x hx
    have hx2 : ‖(2 : ℝ) • x‖ ≤ 2 := by
      rw [norm_smul, Real.norm_eq_abs]
      norm_num
      linarith
    obtain ⟨y, hy, hdist⟩ := hcover (2 • x) hx2
    refine ⟨(1 / 2 : ℝ) • y, Finset.mem_image.mpr ⟨y, hy, rfl⟩, ?_⟩
    have heq : x - (1 / 2 : ℝ) • y = (1 / 2 : ℝ) • ((2 : ℝ) • x - y) := by
      simp [smul_sub, smul_smul]
    rw [heq, norm_smul, Real.norm_eq_abs]
    norm_num
    linarith

theorem operator_norm_le_twice_of_half_net (L : E →L[ℝ] F)
    (s : Finset E)
    (hcover : ∀ x : E, ‖x‖ ≤ 1 → ∃ y ∈ s, ‖x - y‖ < 1 / 2)
    (u : ℝ) (hu : 0 ≤ u) (hbound : ∀ x ∈ s, ‖L x‖ ≤ u) :
    ‖L‖ ≤ 2 * u := by
  have hnorm : ‖L‖ ≤ u + ‖L‖ / 2 := by
    apply ContinuousLinearMap.opNorm_le_of_unit_norm (by positivity)
    intro x hx
    obtain ⟨y, hy, hxy⟩ := hcover x hx.le
    calc
      ‖L x‖ = ‖L y + L (x - y)‖ := by rw [map_sub]; congr 1; abel
      _ ≤ ‖L y‖ + ‖L (x-y)‖ := norm_add_le _ _
      _ ≤ u + ‖L‖ * ‖x-y‖ := add_le_add (hbound y hy) (L.le_opNorm _)
      _ ≤ u + ‖L‖ / 2 := by
        have h := mul_le_mul_of_nonneg_left hxy.le (norm_nonneg L)
        linarith
  linarith

theorem operator_norm_le_four_of_half_nets {G : Type*} [NormedAddCommGroup G] [InnerProductSpace ℝ G]
    (L : E →L[ℝ] G) (s : Finset E) (t : Finset G)
    (hs : ∀ x : E, ‖x‖ ≤ 1 → ∃ y ∈ s, ‖x - y‖ < 1 / 2)
    (ht : ∀ x : G, ‖x‖ ≤ 1 → ∃ y ∈ t, ‖x - y‖ < 1 / 2)
    (u : ℝ) (hu : 0 ≤ u)
    (hbound : ∀ x ∈ s, ∀ y ∈ t, |inner ℝ y (L x)| ≤ u) :
    ‖L‖ ≤ 4 * u := by
  have hb (x : E) (hx : x ∈ s) : ‖L x‖ ≤ 2 * u := by
    have h := operator_norm_le_twice_of_half_net (innerSL ℝ (L x)) t ht u hu
      (fun y hy => by simpa only [innerSL_apply_apply, Real.norm_eq_abs, real_inner_comm] using hbound x hx y hy)
    simpa only [innerSL_apply_norm] using h
  have h := operator_norm_le_twice_of_half_net L s hs (2*u) (by positivity) hb
  linarith

end
end Paulsen
