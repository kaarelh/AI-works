import NeuralGeneralization.OnlineLowerGeometryIndependentCoset
import NeuralGeneralization.OnlineLowerGeometryRailDefect

/-!
# Concrete affine calibration constraints for loop-and-path codes

Fixed coordinates are constrained individually; the remaining coordinates
have one parity constraint. Every singleton loop is detected, and every
edge meeting a fixed coordinate is detected. This is the explicit
calibration-set geometry of the prefix/path construction.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry
open OnlineLowerRelu

def calibrationConstraints {m : ℕ} (fixed : Finset (Fin m)) : Finset (Finset (Fin m)) :=
  fixed.image (fun j => {j}) ∪ {Finset.univ \ fixed}

def calibrationCoset {m : ℕ} (fixed : Finset (Fin m)) (v : ClippingCube m) :
    Set (ClippingCube m) :=
  {z | cubeTranslation v z ∈ (parityKernel (calibrationConstraints fixed)).carrier}

theorem fixed_constraint_mem {m : ℕ} (fixed : Finset (Fin m))
    (j : Fin m) (hj : j ∈ fixed) : {j} ∈ calibrationConstraints fixed :=
  Finset.mem_union_left _ (Finset.mem_image.mpr ⟨j, hj, rfl⟩)

theorem free_constraint_mem {m : ℕ} (fixed : Finset (Fin m)) :
    Finset.univ \ fixed ∈ calibrationConstraints fixed :=
  Finset.mem_union_right _ (Finset.mem_singleton_self _)

theorem column_detected_by_fixed_coordinate {p m : ℕ} (column : Fin p → Finset (Fin m))
    (fixed : Finset (Fin m)) (i : Fin p) (j : Fin m)
    (hj : j ∈ fixed) (hji : j ∈ column i) :
    ∃ S ∈ calibrationConstraints fixed,
      walshCharacter S (logicalColumnPoint column i) ≠ 1 := by
  refine ⟨{j}, fixed_constraint_mem fixed j hj, ?_⟩
  norm_num [walshCharacter, logicalColumnPoint, cubeCoordinateSign, hji]

theorem free_character_on_singleton_column {p m : ℕ} (column : Fin p → Finset (Fin m))
    (fixed : Finset (Fin m)) (i : Fin p) (j : Fin m)
    (hj : j ∉ fixed) (hcol : column i = {j}) :
    walshCharacter (Finset.univ \ fixed) (logicalColumnPoint column i) = -1 := by
  unfold walshCharacter
  rw [Finset.prod_eq_single j]
  · simp [logicalColumnPoint, hcol, cubeCoordinateSign]
  · intro k _ hkj
    simp [logicalColumnPoint, hcol, cubeCoordinateSign, hkj]
  · intro hnot
    exact False.elim (hnot (Finset.mem_sdiff.mpr ⟨Finset.mem_univ _, hj⟩))

/-- The loop-and-path column condition is enough to detect every column
by one of the literal affine calibration constraints. -/
theorem calibrationConstraints_detect_columns {p m : ℕ}
    (column : Fin p → Finset (Fin m)) (fixed : Finset (Fin m))
    (hcolumns : ∀ i, (∃ j ∈ fixed, j ∈ column i) ∨ ∃ j, column i = {j}) (i : Fin p) :
    ∃ S ∈ calibrationConstraints fixed,
      walshCharacter S (logicalColumnPoint column i) ≠ 1 := by
  rcases hcolumns i with ⟨j, hj, hji⟩ | ⟨j, hj⟩
  · exact column_detected_by_fixed_coordinate column fixed i j hj hji
  · by_cases hfixed : j ∈ fixed
    · exact column_detected_by_fixed_coordinate column fixed i j hfixed (by simp [hj])
    · refine ⟨Finset.univ \ fixed, free_constraint_mem fixed, ?_⟩
      rw [free_character_on_singleton_column column fixed i j hfixed hj]
      norm_num

theorem calibrationCoset_independent {p m : ℕ} (column : Fin p → Finset (Fin m))
    (fixed : Finset (Fin m)) (v : ClippingCube m)
    (hcolumns : ∀ i, (∃ j ∈ fixed, j ∈ column i) ∨ ∃ j, column i = {j}) :
    ∀ i z, z ∈ calibrationCoset fixed v →
      cubeTranslation (logicalColumnPoint column i) z ∉ calibrationCoset fixed v := by
  intro i
  exact parity_coset_independent (calibrationConstraints fixed) v
    (logicalColumnPoint column i) (calibrationConstraints_detect_columns column fixed hcolumns i)

/-- Literal membership in the affine calibration coset is exactly
agreement on the fixed coordinates and on the remaining parity. -/
theorem mem_calibrationCoset_iff {m : ℕ} (fixed : Finset (Fin m))
    (v z : ClippingCube m) :
    z ∈ calibrationCoset fixed v ↔
      (∀ j ∈ fixed, z j = v j) ∧
      walshCharacter (Finset.univ \ fixed) z = walshCharacter (Finset.univ \ fixed) v := by
  constructor
  · intro hz
    have hconstraints := (Finset.mem_filter.mp hz).2
    constructor
    · intro j hj
      have h := hconstraints {j} (fixed_constraint_mem fixed j hj)
      rw [walshCharacter_translation] at h
      simp only [walshCharacter, Finset.prod_singleton] at h
      cases hv : v j <;> cases hz : z j <;> simp_all [cubeCoordinateSign]
      all_goals norm_num at h
    · have h := hconstraints (Finset.univ \ fixed) (free_constraint_mem fixed)
      rw [walshCharacter_translation] at h
      nlinarith [walshCharacter_sq (Finset.univ \ fixed) v,
        walshCharacter_sq (Finset.univ \ fixed) z,
        sq_nonneg (walshCharacter (Finset.univ \ fixed) z -
          walshCharacter (Finset.univ \ fixed) v)]
  · rintro ⟨hfixed, hfree⟩
    apply Finset.mem_filter.mpr
    refine ⟨Finset.mem_univ _, ?_⟩
    intro S hS
    rcases Finset.mem_union.mp hS with h | h
    · obtain ⟨j, hj, rfl⟩ := Finset.mem_image.mp h
      rw [walshCharacter_translation]
      simp only [walshCharacter, Finset.prod_singleton, hfixed j hj]
      simpa only [pow_two] using cubeCoordinateSign_sq (v j)
    · have hS' : S = Finset.univ \ fixed := Finset.mem_singleton.mp h
      rw [hS', walshCharacter_translation, hfree, ← pow_two]
      exact walshCharacter_sq _ _

/-- Actual physical observability for this explicitly constructed
calibration coset. Independence is proved, not a premise. -/
theorem actual_calibrationCoset_observability {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (hsize : ∀ i b, 0 < size i b)
    (C : WalshCodeMap (railDimension size) m)
    (hsupport : ∀ s, C.support s = generatedSupport (physicalBase size)
      (coordinateGenerator (physicalColumn size column)) s)
    (fixed : Finset (Fin m)) (v : ClippingCube m)
    (hcolumns : ∀ i, (∃ j ∈ fixed, j ∈ column i) ∨ ∃ j, column i = {j})
    (F : ClippingCube (railDimension size) → ℝ) :
    uniformCubeMean (fun x =>
      (fourierProject (railDownwardSupports size column) F x - C.project F x) ^ 2) ≤
      2 * uniformCubeMean (fun x => if C.syndrome x ∉ calibrationCoset fixed v then
        (fourierProject (railDownwardSupports size column) F x - C.project F x) ^ 2 else 0) :=
  actual_rail_observability size column hsize C hsupport F (calibrationCoset fixed v)
    (calibrationCoset_independent column fixed v hcolumns)

end NeuralGeneralization.OnlineLowerGeometry
