import NeuralGeneralization.OnlineLowerGeometryWalsh

/-!
# Shared concrete interface for a physical Walsh code

The data are actual physical supports and an actual Boolean syndrome map.
The two proof fields are injectivity and the character identity; neither
an atomic norm estimate nor an online conclusion is a field.  A rail
construction must build this object explicitly.

Uniform fiber weights and the conditional-average formula are derived
below from the existing Walsh orthogonality theorem.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

structure WalshCodeMap (d m : ℕ) where
  support : Finset (Fin m) → Finset (Fin d)
  syndrome : ClippingCube d → ClippingCube m
  support_injective : Function.Injective support
  character : ∀ S x, walshCharacter (support S) x =
    walshCharacter (support ∅) x * walshCharacter S (syndrome x)

namespace WalshCodeMap

variable {d m : ℕ} (C : WalshCodeMap d m)

def base (x : ClippingCube d) : ℝ := walshCharacter (C.support ∅) x

def logicalProjection (F : ClippingCube d → ℝ) (z : ClippingCube m) : ℝ :=
  walshExpansion (fun S => walshCoefficients F (C.support S)) z

def project (F : ClippingCube d → ℝ) (x : ClippingCube d) : ℝ :=
  C.base x * C.logicalProjection F (C.syndrome x)

def fiberWeight (z : ClippingCube m) (x : ClippingCube d) : ℝ :=
  if C.syndrome x = z then
    (Fintype.card (ClippingCube m) : ℝ) / Fintype.card (ClippingCube d) else 0

theorem base_sq (x : ClippingCube d) : C.base x ^ 2 = 1 :=
  walshCharacter_sq _ _

theorem abs_base (x : ClippingCube d) : |C.base x| = 1 := by
  have hsq := C.base_sq x
  have ha := abs_nonneg (C.base x)
  have habs := sq_abs (C.base x)
  nlinarith

theorem fiberWeight_nonneg (z : ClippingCube m) (x : ClippingCube d) :
    0 ≤ C.fiberWeight z x := by
  unfold fiberWeight
  split_ifs
  · exact div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)
  · exact le_rfl

theorem project_expansion (F : ClippingCube d → ℝ) (x : ClippingCube d) :
    C.project F x = ∑ S, walshCoefficients F (C.support S) *
      walshCharacter (C.support S) x := by
  unfold project logicalProjection walshExpansion
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro S _
  rw [C.character S x]
  unfold base
  ring

/-- This is an exact conditional mean over the physical fiber, proved
from finite character orthogonality. -/
theorem logicalProjection_fiber (F : ClippingCube d → ℝ) (z : ClippingCube m) :
    C.logicalProjection F z = ∑ x, C.fiberWeight z x * (C.base x * F x) := by
  unfold logicalProjection walshExpansion walshCoefficients uniformCubeMean
  simp_rw [div_mul_eq_mul_div, Finset.sum_mul]
  rw [← Finset.sum_div, Finset.sum_comm]
  have hinner (x : ClippingCube d) :
      (∑ S : Finset (Fin m),
        F x * walshCharacter (C.support S) x * walshCharacter S z) =
          (C.base x * F x) *
            ∑ S : Finset (Fin m), walshCharacter S (C.syndrome x) * walshCharacter S z := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro S _
    rw [C.character S x]
    unfold base
    ring
  simp_rw [hinner, walshCharacter_dual_orthogonal]
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro x _
  by_cases hx : C.syndrome x = z
  · simp only [if_pos hx, fiberWeight]
    ring
  · simp [hx, fiberWeight]

theorem logicalProjection_base (z : ClippingCube m) : C.logicalProjection C.base z = 1 := by
  have hcoeff (S : Finset (Fin m)) :
      walshCoefficients C.base (C.support S) = if S = ∅ then 1 else 0 := by
    unfold base
    rw [walshCoefficients_character]
    have heq : C.support ∅ = C.support S ↔ S = ∅ := by
      constructor
      · intro h
        exact (C.support_injective h).symm
      · intro h
        rw [h]
    simp only [heq]
  unfold logicalProjection walshExpansion
  simp only [hcoeff, ite_mul, one_mul, zero_mul]
  simp [walshCharacter]

/-- Every logical fiber has its correct normalized mass.  In particular
the syndrome is uniform; no uniformity assumption is added to the code. -/
theorem fiberWeight_sum_one (z : ClippingCube m) : ∑ x, C.fiberWeight z x = 1 := by
  have h := C.logicalProjection_fiber C.base z
  rw [C.logicalProjection_base] at h
  simp only [← pow_two, C.base_sq, mul_one] at h
  exact h.symm

theorem logicalProjection_abs_le (F : ClippingCube d → ℝ) (B : ℝ)
    (hF : ∀ x, |F x| ≤ B) (z : ClippingCube m) :
    |C.logicalProjection F z| ≤ B := by
  rw [C.logicalProjection_fiber]
  calc
    |∑ x, C.fiberWeight z x * (C.base x * F x)| ≤
        ∑ x, |C.fiberWeight z x * (C.base x * F x)| :=
      Finset.abs_sum_le_sum_abs _ _
    _ = ∑ x, C.fiberWeight z x * |F x| := by
      apply Finset.sum_congr rfl
      intro x _
      rw [abs_mul, abs_mul, abs_of_nonneg (C.fiberWeight_nonneg z x), C.abs_base, one_mul]
    _ ≤ ∑ x, C.fiberWeight z x * B := by
      exact Finset.sum_le_sum fun x _ =>
        mul_le_mul_of_nonneg_left (hF x) (C.fiberWeight_nonneg z x)
    _ = B := by rw [← Finset.sum_mul, C.fiberWeight_sum_one, one_mul]

theorem project_abs_le (F : ClippingCube d → ℝ) (B : ℝ)
    (hF : ∀ x, |F x| ≤ B) (x : ClippingCube d) : |C.project F x| ≤ B := by
  rw [project, abs_mul, C.abs_base, one_mul]
  exact C.logicalProjection_abs_le F B hF _

end WalshCodeMap

end NeuralGeneralization.OnlineLowerGeometry
