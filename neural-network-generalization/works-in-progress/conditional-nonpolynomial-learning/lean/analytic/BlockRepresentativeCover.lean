import NetworkBallCover
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-! Actual representative selection for the nearcritical block cover.
The residual need only be Lipschitz on the actual query cluster. There is no
ambient-ball Lipschitz hypothesis and no assumed canonical normal form. -/

open scoped BigOperators

namespace ConditionalNonpolynomial.Analytic
open BooleanDepthResearch

variable {E F : Type*} [NormedAddCommGroup E] [NormedAddCommGroup F]

/-- Transfer a finite cover for the linear part into actual query
representatives for linear part plus a restricted Lipschitz residual. -/
theorem actual_representatives_of_linear_cover
    (S : Set E) (z : E) (r δ K : ℝ) (M : ℕ) (a n : E → F)
    (hS : S ⊆ Metric.closedBall z r) (hK : 0 ≤ K)
    (hc : FiniteBallCover (a '' S) M δ)
    (hn : ∀ x ∈ S, ∀ y ∈ S, dist (n x) (n y) ≤ K * dist x y) :
    ∃ Y : Finset E, (↑Y : Set E) ⊆ S ∧ Y.card ≤ M ∧
      ∀ x ∈ S, ∃ y ∈ Y, dist (a x + n x) (a y + n y) ≤ 2 * δ + 2 * K * r := by
  classical
  obtain ⟨C, hCM, hC⟩ := hc
  let P : F → Prop := fun c => ∃ x ∈ S, dist (a x) c ≤ δ
  let D := C.filter P
  let rep : F → E := fun c => if h : P c then Classical.choose h else 0
  have hs (c : F) (hc : c ∈ D) : rep c ∈ S ∧ dist (a (rep c)) c ≤ δ := by
    have hp : P c := (Finset.mem_filter.mp hc).2
    simpa only [rep, dif_pos hp] using Classical.choose_spec hp
  refine ⟨D.image rep, ?_, ?_, ?_⟩
  · intro y hy
    obtain ⟨c, hc, rfl⟩ := Finset.mem_image.mp hy
    exact (hs c hc).1
  · exact Finset.card_image_le.trans ((Finset.card_filter_le _ _).trans hCM)
  · intro x hx
    obtain ⟨c, hc, hxc⟩ := hC (a x) ⟨x, hx, rfl⟩
    have hcD : c ∈ D := Finset.mem_filter.mpr ⟨hc, x, hx, hxc⟩
    have hs' := hs c hcD
    refine ⟨rep c, Finset.mem_image_of_mem rep hcD, ?_⟩
    have hxy : dist x (rep c) ≤ 2 * r := by
      have hxz : dist x z ≤ r := hS hx
      have hyz : dist (rep c) z ≤ r := hS hs'.1
      have ht := dist_triangle x z (rep c)
      rw [dist_comm z (rep c)] at ht
      linarith
    have ha : dist (a x) (a (rep c)) ≤ 2 * δ := by
      have ht := dist_triangle (a x) c (a (rep c))
      rw [dist_comm c (a (rep c))] at ht
      linarith [hs'.2]
    have hn' := (hn x hx (rep c) hs'.1).trans (mul_le_mul_of_nonneg_left hxy hK)
    calc
      dist (a x + n x) (a (rep c) + n (rep c))
          ≤ dist (a x) (a (rep c)) + dist (n x) (n (rep c)) := dist_add_add_le _ _ _ _
      _ ≤ 2 * δ + 2 * K * r := by linarith

/-- The numerical radii used in the paper's good-block argument. -/
theorem actual_representatives_good_block
    (S : Set E) (z : E) (r B : ℝ) (M : ℕ) (a n : E → F)
    (hr : 0 ≤ r) (hB : 0 ≤ B)
    (hS : S ⊆ Metric.closedBall z r)
    (hc : FiniteBallCover (a '' S) M (B * r / 8))
    (hn : ∀ x ∈ S, ∀ y ∈ S, dist (n x) (n y) ≤ (B / 16) * dist x y) :
    ∃ Y : Finset E, (↑Y : Set E) ⊆ S ∧ Y.card ≤ M ∧
      ∀ x ∈ S, ∃ y ∈ Y, dist (a x + n x) (a y + n y) ≤ B * r / 2 := by
  obtain ⟨Y, hYS, hYM, hY⟩ := actual_representatives_of_linear_cover
    S z r (B * r / 8) (B / 16) M a n hS (by positivity) hc hn
  refine ⟨Y, hYS, hYM, ?_⟩
  intro x hx
  obtain ⟨y, hy, hxy⟩ := hY x hx
  refine ⟨y, hy, hxy.trans ?_⟩
  nlinarith [mul_nonneg hB hr]

#print axioms actual_representatives_of_linear_cover
#print axioms actual_representatives_good_block
end ConditionalNonpolynomial.Analytic
