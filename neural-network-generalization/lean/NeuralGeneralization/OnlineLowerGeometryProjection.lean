import NeuralGeneralization.OnlineLowerGeometryCalibration

/-!
# Orthogonal physical Fourier projections

The support projection and its orthogonal residual split are constructed
from the actual finite Walsh transform.  The downward support set will
be supplied by the rail construction.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

theorem walshCoefficients_sub {d : ℕ} (F G : ClippingCube d → ℝ)
    (S : Finset (Fin d)) :
    walshCoefficients (fun x => F x - G x) S =
      walshCoefficients F S - walshCoefficients G S := by
  simp only [walshCoefficients, uniformCubeMean, sub_mul, Finset.sum_sub_distrib, sub_div]

def fourierProject {d : ℕ} (A : Finset (Finset (Fin d)))
    (F : ClippingCube d → ℝ) : ClippingCube d → ℝ :=
  walshExpansion (fun S => if S ∈ A then walshCoefficients F S else 0)

theorem fourierProject_coefficient {d : ℕ} (A : Finset (Finset (Fin d)))
    (F : ClippingCube d → ℝ) (S : Finset (Fin d)) :
    walshCoefficients (fourierProject A F) S =
      if S ∈ A then walshCoefficients F S else 0 :=
  walshCoefficients_expansion _ _

theorem fourierProject_residual_orthogonal {d : ℕ}
    (A B : Finset (Finset (Fin d))) (hAB : A ⊆ B) (F : ClippingCube d → ℝ) :
    uniformCubeMean (fun x =>
      (fourierProject B F x - fourierProject A F x) *
        (F x - fourierProject B F x)) = 0 := by
  rw [walsh_inner_identity]
  apply Finset.sum_eq_zero
  intro S _
  simp only [walshCoefficients_sub, fourierProject_coefficient]
  by_cases hB : S ∈ B
  · simp [hB]
  · have hA : S ∉ A := fun h => hB (hAB h)
    simp [hB, hA]

/-- Pythagoras for the physical downward-space/code-space split. -/
theorem fourierProject_residual_pythagoras {d : ℕ}
    (A B : Finset (Finset (Fin d))) (hAB : A ⊆ B) (F : ClippingCube d → ℝ) :
    uniformCubeMean (fun x => (F x - fourierProject A F x) ^ 2) =
      uniformCubeMean (fun x => (fourierProject B F x - fourierProject A F x) ^ 2) +
      uniformCubeMean (fun x => (F x - fourierProject B F x) ^ 2) := by
  have horth := fourierProject_residual_orthogonal A B hAB F
  have hpoint (x : ClippingCube d) :
      (F x - fourierProject A F x) ^ 2 =
        (fourierProject B F x - fourierProject A F x) ^ 2 +
        (F x - fourierProject B F x) ^ 2 +
        2 * ((fourierProject B F x - fourierProject A F x) *
          (F x - fourierProject B F x)) := by ring
  unfold uniformCubeMean at horth ⊢
  simp_rw [hpoint]
  rw [Finset.sum_add_distrib, Finset.sum_add_distrib, ← Finset.mul_sum]
  rw [add_div, add_div, mul_div_assoc, horth]
  ring

namespace WalshCodeMap

variable {d m : ℕ} (C : WalshCodeMap d m)

def supports : Finset (Finset (Fin d)) := Finset.univ.image C.support

theorem project_eq_fourierProject (F : ClippingCube d → ℝ) :
    C.project F = fourierProject C.supports F := by
  funext x
  rw [C.project_expansion]
  unfold fourierProject walshExpansion
  simp only [ite_mul, zero_mul, Fintype.sum_ite_mem]
  rw [supports, Finset.sum_image]
  intro S _ T _ h
  exact C.support_injective h

theorem code_residual_pythagoras (B : Finset (Finset (Fin d)))
    (hB : C.supports ⊆ B) (F : ClippingCube d → ℝ) :
    uniformCubeMean (fun x => (F x - C.project F x) ^ 2) =
      uniformCubeMean (fun x => (fourierProject B F x - C.project F x) ^ 2) +
      uniformCubeMean (fun x => (F x - fourierProject B F x) ^ 2) := by
  rw [C.project_eq_fourierProject]
  exact fourierProject_residual_pythagoras C.supports B hB F

/-- A logical dual is paired with a physical score through the genuine
conditional code projection, with no independent logical score variable. -/
theorem physical_logical_pairing (F : ClippingCube d → ℝ)
    (dual : ClippingCube m → ℝ) :
    uniformCubeMean (fun x => C.base x * dual (C.syndrome x) * F x) =
      uniformCubeMean (fun z => dual z * C.logicalProjection F z) := by
  rw [← C.mean_fiber_mean]
  congr 1
  funext z
  rw [C.logicalProjection_fiber, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro x _
  by_cases hx : C.syndrome x = z
  · rw [hx]
    ring
  · simp [C.fiberWeight_eq_zero hx]

end WalshCodeMap
end NeuralGeneralization.OnlineLowerGeometry
