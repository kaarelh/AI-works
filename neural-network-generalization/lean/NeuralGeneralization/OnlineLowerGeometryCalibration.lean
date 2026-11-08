import NeuralGeneralization.OnlineLowerGeometryCode
import NeuralGeneralization.OnlineLowerGeometryRounding

/-!
# Physical margins and conditional variance on an actual Walsh code

These results use the physical cube and the concrete code map.  In
particular the conditional laws are the derived uniform fiber weights.
No variance estimate or calibration implication is a structure field.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry
namespace WalshCodeMap

variable {d m : ℕ} (C : WalshCodeMap d m)

theorem fiberWeight_eq_zero {z : ClippingCube m} {x : ClippingCube d}
    (hx : C.syndrome x ≠ z) : C.fiberWeight z x = 0 := by
  simp [fiberWeight, hx]

theorem fiberWeight_sum (x : ClippingCube d) :
    (∑ z, C.fiberWeight z x) =
      (Fintype.card (ClippingCube m) : ℝ) / Fintype.card (ClippingCube d) := by
  simp [fiberWeight, eq_comm]

/-- Averaging the conditional laws recovers the physical cube law. -/
theorem mean_fiber_mean (F : ClippingCube d → ℝ) :
    uniformCubeMean (fun z => ∑ x, C.fiberWeight z x * F x) = uniformCubeMean F := by
  have hM : (Fintype.card (ClippingCube m) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  unfold uniformCubeMean
  rw [Finset.sum_comm]
  simp_rw [← Finset.sum_mul, C.fiberWeight_sum]
  rw [← Finset.mul_sum]
  field_simp

theorem fiber_mean_pullback (G : ClippingCube m → ℝ) (z : ClippingCube m) :
    (∑ x, C.fiberWeight z x * G (C.syndrome x)) = G z := by
  calc
    _ = ∑ x, C.fiberWeight z x * G z := by
      apply Finset.sum_congr rfl
      intro x _
      by_cases hx : C.syndrome x = z
      · rw [hx]
      · simp [C.fiberWeight_eq_zero hx]
    _ = G z := by rw [← Finset.sum_mul, C.fiberWeight_sum_one, one_mul]

theorem mean_pullback (G : ClippingCube m → ℝ) :
    uniformCubeMean (fun x => G (C.syndrome x)) = uniformCubeMean G := by
  rw [← C.mean_fiber_mean]
  simp_rw [C.fiber_mean_pullback]

theorem signed_projection_mean (F : ClippingCube d → ℝ) (t : ℝ)
    (z : ClippingCube m) :
    (∑ x, C.fiberWeight z x * (t * (C.base x * F x))) =
      t * C.logicalProjection F z := by
  rw [C.logicalProjection_fiber, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro x _
  ring

/-- Known labels on a whole physical fiber impose the corresponding
closed margin on its actual code projection. -/
theorem logical_margin_of_fiber_margin (F : ClippingCube d → ℝ)
    (t a : ℝ) (z : ClippingCube m)
    (hF : ∀ x, C.syndrome x = z → a ≤ t * (C.base x * F x)) :
    a ≤ t * C.logicalProjection F z := by
  have hpoint (x : ClippingCube d) :
      C.fiberWeight z x * a ≤ C.fiberWeight z x * (t * (C.base x * F x)) := by
    by_cases hx : C.syndrome x = z
    · exact mul_le_mul_of_nonneg_left (hF x hx) (C.fiberWeight_nonneg z x)
    · simp [C.fiberWeight_eq_zero hx]
  have h := Finset.sum_le_sum fun x (_ : x ∈ Finset.univ) => hpoint x
  simpa only [← Finset.sum_mul, C.fiberWeight_sum_one, one_mul,
    C.signed_projection_mean] using h

theorem residual_square_on_fiber (F : ClippingCube d → ℝ)
    (z : ClippingCube m) (x : ClippingCube d) (hx : C.syndrome x = z) :
    (C.base x * F x - C.logicalProjection F z) ^ 2 =
      (F x - C.project F x) ^ 2 := by
  rw [project, hx]
  ring_nf
  rw [C.base_sq]
  ring

theorem signed_residual_on_fiber (F : ClippingCube d → ℝ) (t : ℝ)
    (z : ClippingCube m) (x : ClippingCube d) (hx : C.syndrome x = z) :
    t * (C.base x * F x) - t * C.logicalProjection F z =
      (t * C.base x) * (F x - C.project F x) := by
  rw [project, hx]
  ring_nf
  rw [C.base_sq]
  ring

/-- Physical absolute residual on an observed fiber is bounded by twice
its actual conditional mean margin excess. -/
theorem observed_fiber_absolute_residual (F : ClippingCube d → ℝ)
    (t a : ℝ) (z : ClippingCube m) (ht : |t| = 1)
    (hF : ∀ x, C.syndrome x = z → a ≤ t * (C.base x * F x)) :
    (∑ x, C.fiberWeight z x * |F x - C.project F x|) ≤
      2 * (t * C.logicalProjection F z - a) := by
  let y : ClippingCube d → ℝ := fun x =>
    if C.syndrome x = z then t * (C.base x * F x) else a
  have hy (x : ClippingCube d) : a ≤ y x := by
    dsimp [y]
    split_ifs with hx
    · exact hF x hx
    · exact le_rfl
  have hmean : (∑ x, C.fiberWeight z x * y x) =
      t * C.logicalProjection F z := by
    rw [← C.signed_projection_mean F t z]
    apply Finset.sum_congr rfl
    intro x _
    by_cases hx : C.syndrome x = z
    · simp [y, hx]
    · simp [C.fiberWeight_eq_zero hx]
  have h := mean_absolute_deviation_of_lower (C.fiberWeight z) y a
    (t * C.logicalProjection F z) (C.fiberWeight_nonneg z)
    (C.fiberWeight_sum_one z) hmean hy
  have heq : (∑ x, C.fiberWeight z x * |y x - t * C.logicalProjection F z|) =
      ∑ x, C.fiberWeight z x * |F x - C.project F x| := by
    apply Finset.sum_congr rfl
    intro x _
    by_cases hx : C.syndrome x = z
    · simp only [y, if_pos hx]
      rw [C.signed_residual_on_fiber F t z x hx, abs_mul, abs_mul,
        ht, C.abs_base, one_mul]
      simp only [one_mul]
    · simp [C.fiberWeight_eq_zero hx]
  rwa [heq] at h

/-- Combining the exact conditional mean with the projection contraction
gives the observed squared-residual estimate used in physical calibration. -/
theorem observed_fiber_squared_residual (F : ClippingCube d → ℝ)
    (t a B : ℝ) (z : ClippingCube m) (ht : |t| = 1) (hB : 0 ≤ B)
    (hcap : ∀ x, |F x| ≤ B)
    (hF : ∀ x, C.syndrome x = z → a ≤ t * (C.base x * F x)) :
    (∑ x, C.fiberWeight z x * (F x - C.project F x) ^ 2) ≤
      4 * B * (t * C.logicalProjection F z - a) := by
  have hres (x : ClippingCube d) : |F x - C.project F x| ≤ 2 * B := by
    calc
      _ ≤ |F x| + |C.project F x| := abs_sub _ _
      _ ≤ B + B := add_le_add (hcap x) (C.project_abs_le F B hcap x)
      _ = 2 * B := by ring
  have hsquare := bounded_square_le_absolute (C.fiberWeight z)
    (fun x => F x - C.project F x) (2 * B) (C.fiberWeight_nonneg z) hres
  have habs := C.observed_fiber_absolute_residual F t a z ht hF
  have hmul := mul_le_mul_of_nonneg_left habs (by linarith : 0 ≤ 2 * B)
  nlinarith

/-- A nonintegral logical value costs physical variance, even though the
physical score can have either margin sign on this unrevealed fiber. -/
theorem fractional_penalty_le_fiber_variance (F : ClippingCube d → ℝ)
    (hF : ∀ x, (1 : ℝ) / 2 ≤ |F x|) (z : ClippingCube m) :
    fractionalPenalty (C.logicalProjection F z + 1 / 2) ≤
      ∑ x, C.fiberWeight z x * (F x - C.project F x) ^ 2 := by
  have hmean : (∑ x, C.fiberWeight z x * (C.base x * F x)) =
      (C.logicalProjection F z + 1 / 2) - 1 / 2 := by
    rw [← C.logicalProjection_fiber]
    ring
  have hmargin (x : ClippingCube d) : (1 : ℝ) / 2 ≤ |C.base x * F x| := by
    rw [abs_mul, C.abs_base, one_mul]
    exact hF x
  have hvar := fractional_variance_bound (C.fiberWeight z)
    (fun x => C.base x * F x) (C.logicalProjection F z + 1 / 2)
    (C.fiberWeight_nonneg z) (C.fiberWeight_sum_one z) hmean hmargin
  have heq : (∑ x, C.fiberWeight z x *
      (C.base x * F x - ((C.logicalProjection F z + 1 / 2) - 1 / 2)) ^ 2) =
      ∑ x, C.fiberWeight z x * (F x - C.project F x) ^ 2 := by
    apply Finset.sum_congr rfl
    intro x _
    have hsub : (C.logicalProjection F z + 1 / 2) - 1 / 2 =
        C.logicalProjection F z := by ring
    rw [hsub]
    by_cases hx : C.syndrome x = z
    · rw [C.residual_square_on_fiber F z x hx]
    · simp [C.fiberWeight_eq_zero hx]
  rw [heq] at hvar
  unfold fractionalPenalty
  split_ifs
  · exact hvar
  · exact Finset.sum_nonneg fun x _ =>
      mul_nonneg (C.fiberWeight_nonneg z x) (sq_nonneg _)

/-- The sum of fractional defects is bounded by the physical squared
residual with its exact logical-cube normalization. -/
theorem fractional_penalty_sum_le_variance (F : ClippingCube d → ℝ)
    (hF : ∀ x, (1 : ℝ) / 2 ≤ |F x|) :
    (∑ z, fractionalPenalty (C.logicalProjection F z + 1 / 2)) ≤
      Fintype.card (ClippingCube m) *
        uniformCubeMean (fun x => (F x - C.project F x) ^ 2) := by
  have h := Finset.sum_le_sum fun z (_ : z ∈ Finset.univ) =>
    C.fractional_penalty_le_fiber_variance F hF z
  have heq := C.mean_fiber_mean (fun x => (F x - C.project F x) ^ 2)
  have hM : (Fintype.card (ClippingCube m) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  unfold uniformCubeMean at heq
  have hsum : (∑ z, ∑ x, C.fiberWeight z x * (F x - C.project F x) ^ 2) =
      Fintype.card (ClippingCube m) *
        uniformCubeMean (fun x => (F x - C.project F x) ^ 2) := by
    unfold uniformCubeMean
    exact (div_eq_iff hM).mp heq |>.trans (mul_comm _ _)
  rwa [hsum] at h

end WalshCodeMap
end NeuralGeneralization.OnlineLowerGeometry
