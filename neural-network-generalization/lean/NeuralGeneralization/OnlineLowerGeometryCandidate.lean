import NeuralGeneralization.OnlineLowerGeometryFamily
import NeuralGeneralization.OnlineLowerCostCandidate

/-! # The actual distinct-cost candidates belong to the actual calibration coset -/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerRelu.Family
open OnlineLowerGeometry OnlineLower OnlineLower.FamilyCost

theorem free_coordinates_image (k : ℕ) :
    Finset.univ \ fixedCoordinates k =
      Finset.univ.image (fun j : Fin k => logicalIndex k (.inr (familyFreeVertex k j))) := by
  ext i
  constructor
  · intro hi
    have hnotfixed := (Finset.mem_sdiff.mp hi).2
    obtain ⟨raw, rfl⟩ := (logicalIndex k).surjective i
    cases raw with
    | inl j => exact False.elim (hnotfixed (prefix_mem_fixedCoordinates k j))
    | inr j =>
      have hj : ¬(j.val % 2 = 1 ∨ j.val = 2 * k) := by
        intro h
        exact hnotfixed ((path_mem_fixedCoordinates k j).mpr h)
      have hjlt := j.isLt
      change j.val < 2 * k + 1 at hjlt
      let a : Fin k := ⟨j.val / 2, by omega⟩
      have heq : familyFreeVertex k a = j := by
        apply Fin.ext
        dsimp [familyFreeVertex, a]
        omega
      exact Finset.mem_image.mpr ⟨a, Finset.mem_univ _, by rw [heq]⟩
  · intro hi
    obtain ⟨j, _, rfl⟩ := Finset.mem_image.mp hi
    apply Finset.mem_sdiff.mpr
    refine ⟨Finset.mem_univ _, ?_⟩
    rw [path_mem_fixedCoordinates]
    have hj := j.isLt
    dsimp [familyFreeVertex]
    omega

theorem familyFree_logical_injective (k : ℕ) :
    Function.Injective (fun j : Fin k => logicalIndex k (.inr (familyFreeVertex k j))) := by
  intro i j h
  have hpath := Sum.inr.inj ((logicalIndex k).injective h)
  have hval := congrArg Fin.val hpath
  apply Fin.ext
  dsimp [familyFreeVertex] at hval
  omega

theorem free_character_eq_product (k : ℕ) (z : ClippingCube (logicalDim k)) :
    walshCharacter (Finset.univ \ fixedCoordinates k) z =
      ∏ j : Fin k, cubeCoordinateSign (z (logicalIndex k (.inr (familyFreeVertex k j)))) := by
  rw [walshCharacter, free_coordinates_image, Finset.prod_image]
  intro i _ j _ h
  exact familyFree_logical_injective k h

theorem referencePoint_free_character_pow (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool) :
    walshCharacter (Finset.univ \ fixedCoordinates k) (referencePoint k endpoint) =
      (-1 : ℝ) ^ k * digitSign endpoint := by
  rw [referencePoint_free_character k hk, neg_one_pow_eq_pow_mod_two]
  by_cases he : k % 2 = 0
  · cases endpoint <;> norm_num [he, cubeCoordinateSign, digitSign]
  · have ho : k % 2 = 1 := by omega
    cases endpoint <;> norm_num [he, ho, cubeCoordinateSign, digitSign]

theorem candidatePoint_agrees_fixed (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool)
    (digits : Fin (k - 1) → Bool) :
    ∀ i ∈ fixedCoordinates k,
      candidatePoint k hk endpoint digits i = referencePoint k endpoint i := by
  intro i hi
  obtain ⟨raw, rfl⟩ := (logicalIndex k).surjective i
  cases raw with
  | inl j => simp
  | inr j =>
    have hj := (path_mem_fixedCoordinates k j).mp hi
    by_cases hterminal : j.val = 2 * k
    · have hjEq : j = ⟨2 * k, by unfold pathDim; omega⟩ := Fin.ext hterminal
      rw [hjEq, candidatePoint_terminal]
      simp [referencePoint]
    · have hodd : j.val % 2 = 1 := hj.resolve_right hterminal
      have hjlt := j.isLt
      change j.val < 2 * k + 1 at hjlt
      let a : Fin k := ⟨j.val / 2, by omega⟩
      have heq : familyFixedVertex k a = j := by
        apply Fin.ext
        dsimp [familyFixedVertex, a]
        omega
      have hc := candidatePoint_fixed k hk endpoint digits a
      rw [heq] at hc
      rw [hc]
      simp [referencePoint, hterminal, hodd]

/-- The indexed candidates used in the strict scalar-cost ordering are
members of the concrete affine calibration set, with both Boolean
conventions and the `k`-dependent free parity accounted for. -/
theorem candidatePoint_mem_calibrationCoset (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool)
    (digits : Fin (k - 1) → Bool) :
    candidatePoint k hk endpoint digits ∈
      calibrationCoset (fixedCoordinates k) (referencePoint k endpoint) := by
  apply (mem_calibrationCoset_iff _ _ _).mpr
  refine ⟨candidatePoint_agrees_fixed k hk endpoint digits, ?_⟩
  rw [free_character_eq_product, candidatePoint_free_product,
    referencePoint_free_character_pow k hk]

end NeuralGeneralization.OnlineLowerRelu.Family
