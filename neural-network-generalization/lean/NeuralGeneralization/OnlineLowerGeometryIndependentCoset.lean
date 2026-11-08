import NeuralGeneralization.OnlineLowerGeometryCoset

/-!
# Affine calibration sets independent under physical code columns

The subgroup is constructed as the simultaneous kernel of specified
Walsh parity constraints. A column detected by any constraint cannot
connect two points of its translated coset.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

def parityKernel {m : ℕ} (constraints : Finset (Finset (Fin m))) : CubeSubgroup m where
  carrier := Finset.univ.filter (fun x => ∀ S ∈ constraints, walshCharacter S x = 1)
  one_mem := by simp [walshCharacter_one]
  mul_mem := by
    intro x hx y hy
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx hy ⊢
    intro S hS
    rw [walshCharacter_translation, hx S hS, hy S hS, one_mul]

theorem parityKernel_detected {m : ℕ} (constraints : Finset (Finset (Fin m)))
    (a : ClippingCube m) (hdetect : ∃ S ∈ constraints, walshCharacter S a ≠ 1) :
    a ∉ (parityKernel constraints).carrier := by
  obtain ⟨S, hS, ha⟩ := hdetect
  intro h
  exact ha ((Finset.mem_filter.mp h).2 S hS)

theorem CubeSubgroup.coset_independent {m : ℕ} (H : CubeSubgroup m)
    (v a : ClippingCube m) (ha : a ∉ H.carrier) (x : ClippingCube m)
    (hx : cubeTranslation v x ∈ H.carrier) :
    cubeTranslation v (cubeTranslation a x) ∉ H.carrier := by
  intro hy
  have h := H.mul_mem (cubeTranslation v x) hx
    (cubeTranslation v (cubeTranslation a x)) hy
  have heq : cubeTranslation (cubeTranslation v x)
      (cubeTranslation v (cubeTranslation a x)) = a := by
    funext i
    cases hv : v i <;> cases ha : a i <;> cases hx : x i <;>
      simp [cubeTranslation, hv, ha, hx]
  rw [heq] at h
  exact ha h

/-- Concrete parity constraints give the independence hypothesis used
by physical observability for every detected column. -/
theorem parity_coset_independent {m : ℕ} (constraints : Finset (Finset (Fin m)))
    (v a : ClippingCube m) (hdetect : ∃ S ∈ constraints, walshCharacter S a ≠ 1) :
    ∀ x, cubeTranslation v x ∈ (parityKernel constraints).carrier →
      cubeTranslation v (cubeTranslation a x) ∉ (parityKernel constraints).carrier :=
  (parityKernel constraints).coset_independent v a
    (parityKernel_detected constraints a hdetect)

end NeuralGeneralization.OnlineLowerGeometry
