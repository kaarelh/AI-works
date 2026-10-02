import Paulsen.Paper.ToolboxAuxScaled
import Mathlib.Analysis.MeanInequalities

/-!
# Helper for `Paulsen.Paper.Toolbox`: convexity of the scaling potential (`lem:potential`).

By Cauchy–Binet (`diagonalScalingPartition_eq_det`), `det(UᵀD_s²U) = ∑_f μ_f e^{2∑_j s_{f j}}`
with `μ_f ≥ 0`, so `F` is (half) a log-sum-exp of linear functions; convexity follows from the
weighted AM–GM inequality (Hölder).
-/

namespace Paulsen.Paper.ToolboxAux

open Matrix Paulsen
open scoped BigOperators

noncomputable section

/-- Convexity of `s ↦ log ∑_f c_f exp(φ_f(s))` for `c ≥ 0` and linear `φ_f`. -/
theorem logsumexp_convex {E κ : Type*} [AddCommGroup E] [Module ℝ E] [Fintype κ]
    (c : κ → ℝ) (hc : ∀ f, 0 ≤ c f) (φ : κ → E → ℝ)
    (hφ : ∀ f (x y : E) (a b : ℝ), φ f (a • x + b • y) = a * φ f x + b * φ f y)
    (hpos : ∀ s, 0 < ∑ f, c f * Real.exp (φ f s)) :
    ConvexOn ℝ Set.univ (fun s => Real.log (∑ f, c f * Real.exp (φ f s))) := by
  refine ⟨convex_univ, ?_⟩
  intro x _ y _ a b ha hb hab
  have hZx := hpos x
  have hZy := hpos y
  set Zx := ∑ f, c f * Real.exp (φ f x) with hZxdef
  set Zy := ∑ f, c f * Real.exp (φ f y) with hZydef
  have hterm : ∀ f, c f * Real.exp (φ f (a • x + b • y)) =
      (Zx ^ a * Zy ^ b) * ((c f * Real.exp (φ f x) / Zx) ^ a *
        (c f * Real.exp (φ f y) / Zy) ^ b) := by
    intro f
    have hc0 := hc f
    have h1 : (c f * Real.exp (φ f x) / Zx) ^ a = c f ^ a * Real.exp (φ f x * a) / Zx ^ a := by
      rw [Real.div_rpow (by positivity) hZx.le, Real.mul_rpow hc0 (Real.exp_pos _).le,
        ← Real.exp_mul]
    have h2 : (c f * Real.exp (φ f y) / Zy) ^ b = c f ^ b * Real.exp (φ f y * b) / Zy ^ b := by
      rw [Real.div_rpow (by positivity) hZy.le, Real.mul_rpow hc0 (Real.exp_pos _).le,
        ← Real.exp_mul]
    rw [h1, h2]
    have hca : c f ^ a * c f ^ b = c f := by
      rw [← Real.rpow_add' hc0 (by rw [hab]; norm_num), hab, Real.rpow_one]
    have hxa : 0 < Zx ^ a := Real.rpow_pos_of_pos hZx a
    have hyb : 0 < Zy ^ b := Real.rpow_pos_of_pos hZy b
    rw [hφ]
    calc c f * Real.exp (a * φ f x + b * φ f y)
        = (c f ^ a * c f ^ b) * (Real.exp (φ f x * a) * Real.exp (φ f y * b)) := by
          rw [hca, ← Real.exp_add]; ring_nf
      _ = (Zx ^ a * Zy ^ b) * (c f ^ a * Real.exp (φ f x * a) / Zx ^ a *
            (c f ^ b * Real.exp (φ f y * b) / Zy ^ b)) := by
          field_simp
  have hamgm : ∀ f, (c f * Real.exp (φ f x) / Zx) ^ a * (c f * Real.exp (φ f y) / Zy) ^ b ≤
      a * (c f * Real.exp (φ f x) / Zx) + b * (c f * Real.exp (φ f y) / Zy) := fun f =>
    Real.geom_mean_le_arith_mean2_weighted ha hb
      (div_nonneg (mul_nonneg (hc f) (Real.exp_pos _).le) hZx.le)
      (div_nonneg (mul_nonneg (hc f) (Real.exp_pos _).le) hZy.le) hab
  have hprod : 0 < Zx ^ a * Zy ^ b :=
    mul_pos (Real.rpow_pos_of_pos hZx a) (Real.rpow_pos_of_pos hZy b)
  have key : ∑ f, c f * Real.exp (φ f (a • x + b • y)) ≤ Zx ^ a * Zy ^ b := by
    calc ∑ f, c f * Real.exp (φ f (a • x + b • y))
        = ∑ f, (Zx ^ a * Zy ^ b) * ((c f * Real.exp (φ f x) / Zx) ^ a *
            (c f * Real.exp (φ f y) / Zy) ^ b) := Finset.sum_congr rfl (fun f _ => hterm f)
      _ ≤ ∑ f, (Zx ^ a * Zy ^ b) * (a * (c f * Real.exp (φ f x) / Zx) +
            b * (c f * Real.exp (φ f y) / Zy)) :=
          Finset.sum_le_sum (fun f _ => mul_le_mul_of_nonneg_left (hamgm f) hprod.le)
      _ = (Zx ^ a * Zy ^ b) * (a * ((∑ f, c f * Real.exp (φ f x)) / Zx) +
            b * ((∑ f, c f * Real.exp (φ f y)) / Zy)) := by
          rw [← Finset.mul_sum, Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum,
            Finset.sum_div, Finset.sum_div]
      _ = Zx ^ a * Zy ^ b := by
          rw [← hZxdef, ← hZydef, div_self hZx.ne', div_self hZy.ne', mul_one, mul_one, hab,
            mul_one]
  calc Real.log (∑ f, c f * Real.exp (φ f (a • x + b • y)))
      ≤ Real.log (Zx ^ a * Zy ^ b) := Real.log_le_log (hpos _) key
    _ = a * Real.log Zx + b * Real.log Zy := by
        rw [Real.log_mul (Real.rpow_pos_of_pos hZx a).ne' (Real.rpow_pos_of_pos hZy b).ne',
          Real.log_rpow hZx, Real.log_rpow hZy]
    _ = a • Real.log Zx + b • Real.log Zy := by simp only [smul_eq_mul]

/-- `lem:potential`, convexity: `F(s) = ½ log det(Uᵀ D_s² U)` is convex. -/
theorem potential_convex {n d : ℕ} (U : Frame n d) (hU : IsParseval U) :
    ConvexOn ℝ Set.univ (fun s : Fin n → ℝ =>
      (1 / 2) * Real.log (U.transpose * Matrix.diagonal (fun i => Real.exp (2 * s i)) * U).det) := by
  rw [← potential_eq]
  have hconv := logsumexp_convex (fun f : Fin d ↪ Fin n => embeddingMinorWeight U f)
    (fun f => embeddingMinorWeight_nonneg U f) (fun f (s : Fin n → ℝ) => 2 * ∑ j, s (f j))
    (by
      intro f x y a b
      simp only [Pi.add_apply, Pi.smul_apply, smul_eq_mul, Finset.sum_add_distrib,
        ← Finset.mul_sum]
      ring)
    (fun s => diagonalScalingPartition_pos hU s)
  have h := hconv.smul (show (0 : ℝ) ≤ 1 / 2 by norm_num)
  exact h

end

end Paulsen.Paper.ToolboxAux
