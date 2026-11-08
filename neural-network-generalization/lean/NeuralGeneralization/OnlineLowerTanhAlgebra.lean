import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.GCongr

/-!
# Algebraic core of the tanh support Jensen estimate

The first theorem is quantitative square-root concavity in a form that only
mentions nonnegative roots and their defining polynomial equations.
-/

namespace NeuralGeneralization.OnlineLowerTanh

/-- Quantitative midpoint concavity with all square roots replaced by their
nonnegative polynomial characterizations. -/
theorem midpoint_gap_mul_of_sq (x t a b s : ℝ)
    (hx : 0 ≤ x) (ha0 : 0 ≤ a) (hb0 : 0 ≤ b) (hs0 : 0 ≤ s)
    (ha : a ^ 2 = x + t) (hb : b ^ 2 = x - t) (hs : s ^ 2 = x) :
    t ^ 2 ≤ 8 * x * s * (s - (a + b) / 2) := by
  let y := (a + b) / 2
  have hy0 : 0 ≤ y := by dsimp [y]; linarith
  have hab0 : 0 ≤ a * b := mul_nonneg ha0 hb0
  have habsq : (a * b) ^ 2 = x ^ 2 - t ^ 2 := by
    rw [mul_pow, ha, hb]
    ring
  have hab : a * b ≤ x := (sq_le_sq₀ hab0 hx).mp (by nlinarith [sq_nonneg t])
  have hy : y ^ 2 = (x + a * b) / 2 := by dsimp [y]; nlinarith
  have hys : y ≤ s := (sq_le_sq₀ hy0 hs0).mp (by nlinarith)
  have hgap : 0 ≤ s - y := sub_nonneg.mpr hys
  have hid : t ^ 2 = 2 * (s - y) * (s + y) * (x + a * b) := by
    calc
      t ^ 2 = x ^ 2 - (a * b) ^ 2 := by linarith [habsq]
      _ = (x - a * b) * (x + a * b) := by ring
      _ = 2 * (s ^ 2 - y ^ 2) * (x + a * b) := by rw [hs, hy]; ring
      _ = _ := by ring
  have hsum : 0 ≤ s + y := add_nonneg hs0 hy0
  have hxab : 0 ≤ x + a * b := add_nonneg hx hab0
  have hbound : 2 * (s - y) * (s + y) * (x + a * b) ≤
      2 * (s - y) * (2 * s) * (2 * x) := by
    gcongr <;> linarith
  calc
    t ^ 2 = 2 * (s - y) * (s + y) * (x + a * b) := hid
    _ ≤ 2 * (s - y) * (2 * s) * (2 * x) := hbound
    _ = 8 * x * s * (s - (a + b) / 2) := by dsimp [y]; ring

end NeuralGeneralization.OnlineLowerTanh
