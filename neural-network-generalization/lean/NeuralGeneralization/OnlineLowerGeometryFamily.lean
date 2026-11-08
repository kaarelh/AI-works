import NeuralGeneralization.OnlineLowerGeometryCalibrationSet
import NeuralGeneralization.OnlineLowerReluFamily
import NeuralGeneralization.OnlineLowerReluRailGeometry

/-!
# Explicit calibration geometry for the fixed-rail ReLU family

The logical dimension is `6*k+4`. All prefix coordinates and the odd
zero-based path vertices, together with the terminal vertex, are fixed; the other path
vertices obey one parity constraint. The literal column enumeration
from `OnlineLowerReluFamily` satisfies the detection condition.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerRelu.Family
open OnlineLowerGeometry

def fixedCoordinates (k : ℕ) : Finset (Fin (logicalDim k)) :=
  Finset.univ.filter (fun j => match (logicalIndex k).symm j with
    | .inl _ => True
    | .inr j => j.val % 2 = 1 ∨ j.val = 2 * k)

@[simp] theorem prefix_mem_fixedCoordinates (k : ℕ) (i : Fin (prefixDim k)) :
    logicalIndex k (.inl i) ∈ fixedCoordinates k := by
  simp [fixedCoordinates]

@[simp] theorem path_mem_fixedCoordinates (k : ℕ) (j : Fin (pathDim k)) :
    logicalIndex k (.inr j) ∈ fixedCoordinates k ↔ j.val % 2 = 1 ∨ j.val = 2 * k := by
  simp [fixedCoordinates]

theorem concrete_column_detection_condition (k : ℕ) :
    ∀ i, (∃ j ∈ fixedCoordinates k, j ∈ column k i) ∨ ∃ j, column k i = {j} := by
  intro i
  obtain ⟨raw, rfl⟩ := (pairIndex k).surjective i
  rcases raw with j | j | e
  · exact Or.inr ⟨logicalIndex k (.inl j), column_prefix k j⟩
  · exact Or.inr ⟨logicalIndex k (.inr j), column_loop k j⟩
  · apply Or.inl
    by_cases he : e.val % 2 = 1
    · refine ⟨logicalIndex k (.inr e.castSucc), ?_, ?_⟩
      · exact (path_mem_fixedCoordinates k e.castSucc).mpr (Or.inl he)
      · simp
    · refine ⟨logicalIndex k (.inr e.succ), ?_, ?_⟩
      · apply (path_mem_fixedCoordinates k e.succ).mpr
        exact Or.inl (by change (e.val + 1) % 2 = 1; omega)
      · simp

theorem concrete_calibration_independent (k : ℕ) (v : ClippingCube (logicalDim k)) :
    ∀ i z, z ∈ calibrationCoset (fixedCoordinates k) v →
      cubeTranslation (logicalColumnPoint (column k) i) z ∉
        calibrationCoset (fixedCoordinates k) v :=
  calibrationCoset_independent (column k) (fixedCoordinates k) v
    (concrete_column_detection_condition k)

def referencePoint (k : ℕ) (endpoint : Bool) : ClippingCube (logicalDim k) :=
  fun j => match (logicalIndex k).symm j with
    | .inl _ => false
    | .inr j => if j.val = 2 * k then true
      else if j.val % 2 = 1 then false
      else if j.val = 0 then (if k % 2 = 0 then endpoint else !endpoint) else true

@[simp] theorem referencePoint_prefix (k : ℕ) (endpoint : Bool) (i : Fin (prefixDim k)) :
    referencePoint k endpoint (logicalIndex k (.inl i)) = false := by
  simp [referencePoint]

def calibrationSubgroup (k : ℕ) : CubeSubgroup (logicalDim k) :=
  parityKernel (calibrationConstraints (fixedCoordinates k))

theorem referencePoint_not_subgroup (k : ℕ) (endpoint : Bool) :
    referencePoint k endpoint ∉ (calibrationSubgroup k).carrier := by
  let i : Fin (prefixDim k) := ⟨0, by unfold prefixDim; omega⟩
  apply parityKernel_detected
  refine ⟨{logicalIndex k (.inl i)}, fixed_constraint_mem _ _ (prefix_mem_fixedCoordinates k i), ?_⟩
  norm_num [walshCharacter, cubeCoordinateSign]

theorem prefix_singleton_mem_differenceAnnihilator (k : ℕ) (endpoint : Bool)
    (i : Fin (prefixDim k)) :
    {logicalIndex k (.inl i)} ∈
      (calibrationSubgroup k).differenceAnnihilator (referencePoint k endpoint) := by
  apply Finset.mem_filter.mpr
  constructor
  · apply Finset.mem_filter.mpr
    refine ⟨Finset.mem_univ _, ?_⟩
    intro z hz
    exact (Finset.mem_filter.mp hz).2 _
      (fixed_constraint_mem _ _ (prefix_mem_fixedCoordinates k i))
  · norm_num [walshCharacter, cubeCoordinateSign]

theorem concrete_differenceAnnihilator_card (k : ℕ) (endpoint : Bool) :
    2 ≤ ((calibrationSubgroup k).differenceAnnihilator (referencePoint k endpoint)).card := by
  let i0 : Fin (prefixDim k) := ⟨0, by unfold prefixDim; omega⟩
  let i1 : Fin (prefixDim k) := ⟨1, by unfold prefixDim; omega⟩
  have hne : ({logicalIndex k (.inl i0)} : Finset (Fin (logicalDim k))) ≠
      {logicalIndex k (.inl i1)} := by
    intro h
    have hi := (logicalIndex k).injective (Finset.singleton_inj.mp h)
    have hv : i0 = i1 := Sum.inl.inj hi
    have := congrArg Fin.val hv
    norm_num [i0, i1] at this
  have hsub : ({ {logicalIndex k (.inl i0)}, {logicalIndex k (.inl i1)} } :
      Finset (Finset (Fin (logicalDim k)))) ⊆
      (calibrationSubgroup k).differenceAnnihilator (referencePoint k endpoint) := by
    intro S hS
    rcases Finset.mem_insert.mp hS with h | h
    · rw [h]
      exact prefix_singleton_mem_differenceAnnihilator k endpoint i0
    · rw [Finset.mem_singleton.mp h]
      exact prefix_singleton_mem_differenceAnnihilator k endpoint i1
  have h := Finset.card_le_card hsub
  simpa [hne] using h

theorem calibration_prefix_bits (k : ℕ) (endpoint : Bool)
    (z : ClippingCube (logicalDim k))
    (hz : z ∈ calibrationCoset (fixedCoordinates k) (referencePoint k endpoint))
    (i : Fin (prefixDim k)) : z (logicalIndex k (.inl i)) = false := by
  have hfixed := ((mem_calibrationCoset_iff _ _ _).mp hz).1
  exact (hfixed _ (prefix_mem_fixedCoordinates k i)).trans (referencePoint_prefix k endpoint i)

theorem calibration_fixed_path_bits (k : ℕ) (endpoint : Bool)
    (z : ClippingCube (logicalDim k))
    (hz : z ∈ calibrationCoset (fixedCoordinates k) (referencePoint k endpoint))
    (j : Fin (pathDim k)) (hj : j.val % 2 = 1) (hterminal : j.val ≠ 2 * k) :
    z (logicalIndex k (.inr j)) = false := by
  have hfixed := ((mem_calibrationCoset_iff _ _ _).mp hz).1
  rw [hfixed _ ((path_mem_fixedCoordinates k j).mpr (Or.inl hj))]
  simp [referencePoint, hj, hterminal]

theorem calibration_terminal_bit (k : ℕ) (endpoint : Bool)
    (z : ClippingCube (logicalDim k))
    (hz : z ∈ calibrationCoset (fixedCoordinates k) (referencePoint k endpoint)) :
    z (logicalIndex k (.inr ⟨2 * k, by unfold pathDim; omega⟩)) = true := by
  let j : Fin (pathDim k) := ⟨2 * k, by unfold pathDim; omega⟩
  have hj : j.val = 2 * k := rfl
  have hfixed := ((mem_calibrationCoset_iff _ _ _).mp hz).1
  change z (logicalIndex k (.inr j)) = true
  rw [hfixed _ ((path_mem_fixedCoordinates k j).mpr (Or.inr hj))]
  simp [referencePoint, j]

/-- The parity constant includes the fixed-parity block convention: for
endpoint `false` it is negative when `k` is even and positive when `k`
is odd. This is the parity of the actual candidate family. -/
theorem referencePoint_free_character (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool) :
    walshCharacter (Finset.univ \ fixedCoordinates k) (referencePoint k endpoint) =
      cubeCoordinateSign (if k % 2 = 0 then endpoint else !endpoint) := by
  let j1 : Fin (pathDim k) := ⟨0, by unfold pathDim; omega⟩
  have hnotterminal : (0 : ℕ) ≠ 2 * k := by omega
  unfold walshCharacter
  rw [Finset.prod_eq_single (logicalIndex k (.inr j1))]
  · simp [referencePoint, j1, hnotterminal]
  · intro i hi hne
    have hnotfixed : i ∉ fixedCoordinates k := (Finset.mem_sdiff.mp hi).2
    obtain ⟨raw, rfl⟩ := (logicalIndex k).surjective i
    cases raw with
    | inl j => exact False.elim (hnotfixed (prefix_mem_fixedCoordinates k j))
    | inr j =>
      have hodd : j.val % 2 ≠ 1 := by
        intro h
        exact hnotfixed ((path_mem_fixedCoordinates k j).mpr (Or.inl h))
      have hterminal : j.val ≠ 2 * k := by
        intro h
        exact hnotfixed ((path_mem_fixedCoordinates k j).mpr (Or.inr h))
      have hfirst : j.val ≠ 0 := by
        intro h
        have hj : j = j1 := Fin.ext h
        exact hne (by rw [hj])
      simp [referencePoint, hodd, hterminal, hfirst, cubeCoordinateSign]
  · intro hnot
    apply False.elim
    apply hnot
    apply Finset.mem_sdiff.mpr
    refine ⟨Finset.mem_univ _, ?_⟩
    simp [j1, hnotterminal]

/-- The actual Walsh code map of the explicitly enumerated physical
prefix/path rail system. All character and uniform-fiber facts follow
from this construction. -/
def physicalCode (R k : ℕ) (hR : 0 < R) :
    WalshCodeMap (railDimension (size R k)) (logicalDim k) :=
  coordinateWalshCode (physicalBase (size R k))
    (physicalColumn (size R k) (column k)) (privateCoord R k hR)
    (physicalColumn_privateCoord R k hR)

@[simp] theorem physicalCode_support (R k : ℕ) (hR : 0 < R)
    (s : Finset (Fin (logicalDim k))) :
    (physicalCode R k hR).support s = generatedSupport (physicalBase (size R k))
      (coordinateGenerator (physicalColumn (size R k) (column k))) s := rfl

theorem family_size_pos (R k : ℕ) (hR : 0 < R) : ∀ i b, 0 < size R k i b := by
  intro i b
  cases b <;> simp only [size_false, size_true] <;> omega

/-- Fully instantiated physical observability for the explicit ReLU
family; no abstract code or independence certificate is a premise. -/
theorem concrete_physical_observability (R k : ℕ) (hR : 0 < R) (endpoint : Bool)
    (F : ClippingCube (railDimension (size R k)) → ℝ) :
    uniformCubeMean (fun x =>
      (fourierProject (railDownwardSupports (size R k) (column k)) F x -
        (physicalCode R k hR).project F x) ^ 2) ≤
      2 * uniformCubeMean (fun x =>
        if (physicalCode R k hR).syndrome x ∉
            calibrationCoset (fixedCoordinates k) (referencePoint k endpoint) then
          (fourierProject (railDownwardSupports (size R k) (column k)) F x -
            (physicalCode R k hR).project F x) ^ 2 else 0) :=
  actual_calibrationCoset_observability (size R k) (column k) (family_size_pos R k hR)
    (physicalCode R k hR) (physicalCode_support R k hR)
    (fixedCoordinates k) (referencePoint k endpoint) (concrete_column_detection_condition k) F

end NeuralGeneralization.OnlineLowerRelu.Family
