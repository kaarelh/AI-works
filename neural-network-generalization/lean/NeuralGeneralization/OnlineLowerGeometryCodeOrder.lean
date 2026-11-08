import NeuralGeneralization.OnlineLowerGeometryCode
import NeuralGeneralization.OnlineLowerGeometryOrderModel

/-! # Concrete physical fibers and cost-sorted finite online orders -/

noncomputable section
open scoped Classical

namespace NeuralGeneralization.OnlineLowerGeometry

theorem exists_injective_cost_order {X : Type*} [Fintype X]
    (cost : X → ℝ) (hinj : Function.Injective cost) :
    ∃ e : Fin (Fintype.card X) ≃ X, StrictMono (fun i => cost (e i)) := by
  letI : LinearOrder X := LinearOrder.lift' cost hinj
  let e : Fin (Fintype.card X) ≃o X := monoEquivOfFin X rfl
  exact ⟨e.toEquiv, fun _ _ hij => e.strictMono hij⟩

namespace WalshCodeMap
variable {d m : ℕ} (C : WalshCodeMap d m)

theorem syndrome_surjective : Function.Surjective C.syndrome := by
  intro z
  by_contra h
  have hnone (x : ClippingCube d) : C.syndrome x ≠ z := fun hx => h ⟨x, hx⟩
  have hsum := C.fiberWeight_sum_one z
  simp only [fiberWeight, if_neg (hnone _), Finset.sum_const_zero] at hsum
  norm_num at hsum

def sectionPoint (z : ClippingCube m) : ClippingCube d :=
  Classical.choose (C.syndrome_surjective z)

@[simp] theorem syndrome_sectionPoint (z : ClippingCube m) :
    C.syndrome (C.sectionPoint z) = z := Classical.choose_spec (C.syndrome_surjective z)

def codeFiber {T : ℕ} (point : Fin T → ClippingCube m) (x : ClippingCube d) : Option (Fin T) :=
  if h : ∃ i, point i = C.syndrome x then some (Classical.choose h) else none

theorem codeFiber_eq_some_iff {T : ℕ} (point : Fin T → ClippingCube m)
    (hinj : Function.Injective point) (x : ClippingCube d) (i : Fin T) :
    C.codeFiber point x = some i ↔ C.syndrome x = point i := by
  unfold codeFiber
  split_ifs with h
  · have hchoose := Classical.choose_spec h
    constructor
    · intro hi
      have hEq := Option.some.inj hi
      rw [hEq] at hchoose
      exact hchoose.symm
    · intro hi
      congr 1
      exact hinj (hchoose.trans hi)
  · constructor
    · intro hi
      contradiction
    · intro hi
      exact False.elim (h ⟨i, hi.symm⟩)

theorem codeFiber_eq_none_iff {T : ℕ} (point : Fin T → ClippingCube m)
    (x : ClippingCube d) :
    C.codeFiber point x = none ↔ ∀ i, C.syndrome x ≠ point i := by
  unfold codeFiber
  split_ifs with h
  · simp only [reduceCtorEq, false_iff]
    intro hnone
    exact hnone (Classical.choose h) (Classical.choose_spec h).symm
  · constructor
    · intro _ i hi
      exact h ⟨i, hi.symm⟩
    · intro _
      rfl

theorem codeFiber_sectionPoint {T : ℕ} (point : Fin T → ClippingCube m)
    (hinj : Function.Injective point) (i : Fin T) :
    C.codeFiber point (C.sectionPoint (point i)) = some i :=
  (C.codeFiber_eq_some_iff point hinj _ i).mpr (C.syndrome_sectionPoint _)

/-- Complete physical permutation with the exact whole-fiber history.
All noncandidate fibers are part of the calibration prefix. -/
theorem exists_code_fiber_inputOrder {T : ℕ} (point : Fin T → ClippingCube m)
    (hinj : Function.Injective point) :
    ∃ π : OnlineLower.InputOrder d, ∀ i x,
      (∃ a : Fin (π.symm (C.sectionPoint (point i))).val,
        OnlineLower.observedPrefix π (π.symm (C.sectionPoint (point i))) a = x) ↔
      (∀ j, C.syndrome x ≠ point j) ∨ ∃ j : Fin T, j < i ∧ C.syndrome x = point j := by
  obtain ⟨π, hπ⟩ := OnlineLower.exists_fiber_inputOrder (C.codeFiber point)
    (fun i => C.sectionPoint (point i)) (C.codeFiber_sectionPoint point hinj)
  refine ⟨π, ?_⟩
  intro i x
  rw [hπ, C.codeFiber_eq_none_iff]
  simp_rw [C.codeFiber_eq_some_iff point hinj]

end WalshCodeMap
end NeuralGeneralization.OnlineLowerGeometry
