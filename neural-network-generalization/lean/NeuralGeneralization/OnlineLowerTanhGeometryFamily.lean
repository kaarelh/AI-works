import NeuralGeneralization.OnlineLowerTanhGeometryPhysical
import NeuralGeneralization.OnlineLowerTanhFamily
import NeuralGeneralization.OnlineLowerGeometryFamily
import NeuralGeneralization.OnlineLowerTanhGeometryDensity

/-! # Literal appended-bit rectangle calibration for the tanh family -/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerTanh.Family
open OnlineLowerGeometry OnlineLowerRelu

abbrev OldDim (k : ℕ) := OnlineLowerRelu.Family.logicalDim k

def oldPoint (k : ℕ) (z : ClippingCube (logicalDim k)) : ClippingCube (OldDim k) :=
  fun j => z (oldLogical k j)

def distinguishedPoint (k : ℕ) (z : ClippingCube (logicalDim k)) : ClippingCube 2 :=
  fun j => z (logicalIndex k (.inr j))

def joinPoint (k : ℕ) (z : ClippingCube (OldDim k)) (b : ClippingCube 2) :
    ClippingCube (logicalDim k) :=
  fun j => match (logicalIndex k).symm j with | .inl i => z i | .inr i => b i

def extendPoint (k : ℕ) (z : ClippingCube (OldDim k)) (b : Bool) :
    ClippingCube (logicalDim k) := joinPoint k z (fun _ => b)

@[simp] theorem joinPoint_old (k : ℕ) (z : ClippingCube (OldDim k)) (b : ClippingCube 2)
    (i : Fin (OldDim k)) : joinPoint k z b (oldLogical k i) = z i := by
  simp [joinPoint, oldLogical]

@[simp] theorem joinPoint_distinguished (k : ℕ) (z : ClippingCube (OldDim k)) (b : ClippingCube 2)
    (i : Fin 2) : joinPoint k z b (logicalIndex k (.inr i)) = b i := by
  simp [joinPoint]

@[simp] theorem oldPoint_joinPoint (k : ℕ) (z : ClippingCube (OldDim k)) (b : ClippingCube 2) :
    oldPoint k (joinPoint k z b) = z := by ext j; simp [oldPoint]

@[simp] theorem distinguishedPoint_joinPoint (k : ℕ) (z : ClippingCube (OldDim k)) (b : ClippingCube 2) :
    distinguishedPoint k (joinPoint k z b) = b := by ext j; simp [distinguishedPoint]

@[simp] theorem joinPoint_parts (k : ℕ) (z : ClippingCube (logicalDim k)) :
    joinPoint k (oldPoint k z) (distinguishedPoint k z) = z := by
  ext j
  obtain ⟨j, rfl⟩ := (logicalIndex k).surjective j
  cases j <;> simp [oldPoint, distinguishedPoint, oldLogical, joinPoint]

@[simp] theorem oldPoint_one (k : ℕ) : oldPoint k (cubeOne (logicalDim k)) = cubeOne (OldDim k) := rfl
@[simp] theorem distinguishedPoint_one (k : ℕ) :
    distinguishedPoint k (cubeOne (logicalDim k)) = cubeOne 2 := rfl

@[simp] theorem oldPoint_translation (k : ℕ) (x y : ClippingCube (logicalDim k)) :
    oldPoint k (cubeTranslation x y) = cubeTranslation (oldPoint k x) (oldPoint k y) := rfl

@[simp] theorem distinguishedPoint_translation (k : ℕ) (x y : ClippingCube (logicalDim k)) :
    distinguishedPoint k (cubeTranslation x y) =
      cubeTranslation (distinguishedPoint k x) (distinguishedPoint k y) := rfl

def shiftPoint (k : ℕ) : ClippingCube (logicalDim k) :=
  extendPoint k (cubeOne (OldDim k)) false

def referencePoint (k : ℕ) (endpoint : Bool) : ClippingCube (logicalDim k) :=
  extendPoint k (OnlineLowerRelu.Family.referencePoint k endpoint) false

@[simp] theorem oldPoint_shift (k : ℕ) : oldPoint k (shiftPoint k) = cubeOne (OldDim k) := by
  simp [shiftPoint, extendPoint]

@[simp] theorem distinguishedPoint_shift (k : ℕ) (i : Fin 2) :
    distinguishedPoint k (shiftPoint k) i = false := by
  simp [shiftPoint, extendPoint]

@[simp] theorem oldPoint_reference (k : ℕ) (endpoint : Bool) :
    oldPoint k (referencePoint k endpoint) = OnlineLowerRelu.Family.referencePoint k endpoint := by
  simp [referencePoint, extendPoint]

@[simp] theorem distinguishedPoint_reference (k : ℕ) (endpoint : Bool) (i : Fin 2) :
    distinguishedPoint k (referencePoint k endpoint) i = false := by
  simp [referencePoint, extendPoint]

def calibrationSubgroup (k : ℕ) : CubeSubgroup (logicalDim k) where
  carrier := Finset.univ.filter (fun z => oldPoint k z ∈
    (OnlineLowerRelu.Family.calibrationSubgroup k).carrier ∧ distinguishedPoint k z = cubeOne 2)
  one_mem := by simp [OnlineLowerRelu.Family.calibrationSubgroup, parityKernel, walshCharacter_one]
  mul_mem := by
    intro x hx y hy
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx hy ⊢
    rw [oldPoint_translation, distinguishedPoint_translation, hx.2, hy.2, cubeTranslation_self]
    exact ⟨(OnlineLowerRelu.Family.calibrationSubgroup k).mul_mem _ hx.1 _ hy.1, rfl⟩

@[simp] theorem mem_calibrationSubgroup (k : ℕ) (z : ClippingCube (logicalDim k)) :
    z ∈ (calibrationSubgroup k).carrier ↔
      oldPoint k z ∈ (OnlineLowerRelu.Family.calibrationSubgroup k).carrier ∧
        distinguishedPoint k z = cubeOne 2 := by simp [calibrationSubgroup]

@[simp] theorem shiftPoint_not_subgroup (k : ℕ) : shiftPoint k ∉ (calibrationSubgroup k).carrier := by
  intro h
  have h0 := congrFun ((mem_calibrationSubgroup k _).mp h).2 0
  simp [cubeOne] at h0

lemma distinguishedPoint_eq_one_iff (k : ℕ) (z : ClippingCube (logicalDim k)) :
    distinguishedPoint k z = cubeOne 2 ↔
      distinguishedPoint k z 0 = true ∧ distinguishedPoint k z 1 = true := by
  constructor
  · intro h
    rw [h]
    exact ⟨rfl, rfl⟩
  · rintro ⟨h0, h1⟩
    ext i
    fin_cases i <;> assumption

lemma distinguished_shift_eq_one_iff (k : ℕ) (z : ClippingCube (logicalDim k)) :
    distinguishedPoint k (cubeTranslation (shiftPoint k) z) = cubeOne 2 ↔
      distinguishedPoint k z 0 = false ∧ distinguishedPoint k z 1 = false := by
  rw [distinguishedPoint_eq_one_iff]
  simp only [distinguishedPoint_translation]
  cases h0 : distinguishedPoint k z 0 <;> cases h1 : distinguishedPoint k z 1 <;>
    simp [cubeTranslation, h0, h1, distinguishedPoint_shift]

/-- The adjoined subgroup relaxes only the two distinguished bits: they
must be equal, while all old prefix/path constraints remain literal. -/
theorem mem_enlargedSubgroup (k : ℕ) (z : ClippingCube (logicalDim k)) :
    z ∈ ((calibrationSubgroup k).adjoinPoint (shiftPoint k)).carrier ↔
      oldPoint k z ∈ (OnlineLowerRelu.Family.calibrationSubgroup k).carrier ∧
        distinguishedPoint k z 0 = distinguishedPoint k z 1 := by
  rw [CubeSubgroup.mem_adjoinPoint, mem_calibrationSubgroup, mem_calibrationSubgroup,
    oldPoint_translation, oldPoint_shift, cubeTranslation_one,
    distinguishedPoint_eq_one_iff, distinguished_shift_eq_one_iff]
  cases h0 : distinguishedPoint k z 0 <;> cases h1 : distinguishedPoint k z 1 <;> simp [h0, h1]

theorem referencePoint_not_enlargedSubgroup (k : ℕ) (endpoint : Bool) :
    referencePoint k endpoint ∉ ((calibrationSubgroup k).adjoinPoint (shiftPoint k)).carrier := by
  intro h
  have hh := ((mem_enlargedSubgroup k _).mp h).1
  rw [oldPoint_reference] at hh
  exact OnlineLowerRelu.Family.referencePoint_not_subgroup k endpoint hh

/-- Live points are exactly the old calibrated coset with both new bits negative. -/
theorem mem_liveCoset (k : ℕ) (endpoint : Bool) (z : ClippingCube (logicalDim k)) :
    cubeTranslation (referencePoint k endpoint) z ∈ (calibrationSubgroup k).carrier ↔
      oldPoint k z ∈ calibrationCoset (OnlineLowerRelu.Family.fixedCoordinates k)
        (OnlineLowerRelu.Family.referencePoint k endpoint) ∧
      distinguishedPoint k z 0 = false ∧ distinguishedPoint k z 1 = false := by
  rw [mem_calibrationSubgroup, oldPoint_translation, oldPoint_reference,
    distinguishedPoint_eq_one_iff, distinguishedPoint_translation]
  change (_ ∧ ((cubeTranslation _ _) 0 = true ∧ (cubeTranslation _ _) 1 = true)) ↔ _
  cases h0 : distinguishedPoint k z 0 <;> cases h1 : distinguishedPoint k z 1 <;>
    simp [cubeTranslation, h0, h1, distinguishedPoint_reference,
      calibrationCoset, OnlineLowerRelu.Family.calibrationSubgroup]

/-- The enlarged live set contains both equal distinguished-bit choices. -/
theorem mem_enlargedCoset (k : ℕ) (endpoint : Bool) (z : ClippingCube (logicalDim k)) :
    cubeTranslation (referencePoint k endpoint) z ∈
      ((calibrationSubgroup k).adjoinPoint (shiftPoint k)).carrier ↔
      oldPoint k z ∈ calibrationCoset (OnlineLowerRelu.Family.fixedCoordinates k)
        (OnlineLowerRelu.Family.referencePoint k endpoint) ∧
      distinguishedPoint k z 0 = distinguishedPoint k z 1 := by
  rw [mem_enlargedSubgroup, oldPoint_translation, oldPoint_reference,
    distinguishedPoint_translation]
  cases h0 : distinguishedPoint k z 0 <;> cases h1 : distinguishedPoint k z 1 <;>
    simp [cubeTranslation, h0, h1, distinguishedPoint_reference,
      calibrationCoset, OnlineLowerRelu.Family.calibrationSubgroup]

def prefixIndex (k : ℕ) (i : Fin (OnlineLowerRelu.Family.prefixDim k)) : Fin (logicalDim k) :=
  oldLogical k (OnlineLowerRelu.Family.logicalIndex k (.inl i))

lemma prefixIndex_injective (k : ℕ) : Function.Injective (prefixIndex k) := by
  intro i j h
  exact Sum.inl.inj ((OnlineLowerRelu.Family.logicalIndex k).injective ((oldLogical k).injective h))

@[simp] theorem referencePoint_prefix (k : ℕ) (endpoint : Bool)
    (i : Fin (OnlineLowerRelu.Family.prefixDim k)) :
    referencePoint k endpoint (prefixIndex k i) = false := by
  simp [referencePoint, extendPoint, prefixIndex]

lemma prefix_singleton_mem_enlarged_difference (k : ℕ) (endpoint : Bool)
    (i : Fin (OnlineLowerRelu.Family.prefixDim k)) :
    {prefixIndex k i} ∈ ((calibrationSubgroup k).adjoinPoint (shiftPoint k)).differenceAnnihilator
      (referencePoint k endpoint) := by
  have hE := OnlineLowerRelu.Family.prefix_singleton_mem_differenceAnnihilator k endpoint i
  have hA := (Finset.mem_filter.mp (Finset.mem_filter.mp hE).1).2
  apply Finset.mem_filter.mpr
  constructor
  · apply Finset.mem_filter.mpr
    refine ⟨Finset.mem_univ _, ?_⟩
    intro z hz
    have hzold := ((mem_enlargedSubgroup k z).mp hz).1
    simpa only [walshCharacter, Finset.prod_singleton, oldPoint, prefixIndex] using hA _ hzold
  · norm_num [walshCharacter, cubeCoordinateSign]

theorem enlarged_difference_card (k : ℕ) (endpoint : Bool) :
    2 ≤ (((calibrationSubgroup k).adjoinPoint (shiftPoint k)).differenceAnnihilator
      (referencePoint k endpoint)).card := by
  let i0 : Fin (OnlineLowerRelu.Family.prefixDim k) := ⟨0, by unfold OnlineLowerRelu.Family.prefixDim; omega⟩
  let i1 : Fin (OnlineLowerRelu.Family.prefixDim k) := ⟨1, by unfold OnlineLowerRelu.Family.prefixDim; omega⟩
  have hne : ({prefixIndex k i0} : Finset (Fin (logicalDim k))) ≠ {prefixIndex k i1} := by
    intro he
    have hi := prefixIndex_injective k (Finset.singleton_inj.mp he)
    have hh := congrArg Fin.val hi
    norm_num [i0, i1] at hh
  have hsub : ({ {prefixIndex k i0}, {prefixIndex k i1} } : Finset (Finset (Fin (logicalDim k)))) ⊆
      ((calibrationSubgroup k).adjoinPoint (shiftPoint k)).differenceAnnihilator (referencePoint k endpoint) := by
    intro e he
    rcases Finset.mem_insert.mp he with he | he
    · rw [he]; exact prefix_singleton_mem_enlarged_difference k endpoint i0
    · rw [Finset.mem_singleton.mp he]; exact prefix_singleton_mem_enlarged_difference k endpoint i1
  have hh := Finset.card_le_card hsub
  simpa [hne] using hh

def distinguishedCharacter (k : ℕ) : Finset (Fin (logicalDim k)) := {logicalIndex k (.inr 0)}

theorem distinguishedCharacter_mem_difference (k : ℕ) (endpoint : Bool) :
    distinguishedCharacter k ∈ (calibrationSubgroup k).differenceAnnihilator (referencePoint k endpoint) := by
  apply Finset.mem_filter.mpr
  constructor
  · apply Finset.mem_filter.mpr
    refine ⟨Finset.mem_univ _, ?_⟩
    intro z hz
    have hh := congrFun ((mem_calibrationSubgroup k z).mp hz).2 0
    change z (logicalIndex k (.inr 0)) = true at hh
    simp [distinguishedCharacter, walshCharacter, cubeCoordinateSign, hh]
  · have hh := distinguishedPoint_reference k endpoint (0 : Fin 2)
    change referencePoint k endpoint (logicalIndex k (.inr 0)) = false at hh
    simp [distinguishedCharacter, walshCharacter, cubeCoordinateSign, hh]

@[simp] theorem distinguishedCharacter_shift (k : ℕ) :
    walshCharacter (distinguishedCharacter k) (shiftPoint k) = -1 := by
  have hh := distinguishedPoint_shift k (0 : Fin 2)
  change shiftPoint k (logicalIndex k (.inr 0)) = false at hh
  norm_num [distinguishedCharacter, walshCharacter, cubeCoordinateSign, hh]

@[simp] theorem oldPoint_column_old (R H k : ℕ) (i : Fin (OnlineLowerRelu.Family.pairDim k)) :
    oldPoint k (logicalColumnPoint (column R H k) (pairIndex R H k (.inl i))) =
      logicalColumnPoint (OnlineLowerRelu.Family.column k) i := by
  ext j
  simp [oldPoint, logicalColumnPoint]

@[simp] theorem distinguishedPoint_column_old (R H k : ℕ)
    (i : Fin (OnlineLowerRelu.Family.pairDim k)) :
    distinguishedPoint k (logicalColumnPoint (column R H k) (pairIndex R H k (.inl i))) = cubeOne 2 := by
  ext j
  simp [distinguishedPoint, logicalColumnPoint, oldLogical, cubeOne]

@[simp] theorem oldPoint_column_distinguished (R H k : ℕ) (b : Fin 2) (i : Fin (splitCount H R)) :
    oldPoint k (logicalColumnPoint (column R H k) (pairIndex R H k (.inr (b,i)))) = cubeOne (OldDim k) := by
  ext j
  simp [oldPoint, logicalColumnPoint, oldLogical, cubeOne]

@[simp] theorem distinguishedPoint_column_distinguished (R H k : ℕ)
    (b j : Fin 2) (i : Fin (splitCount H R)) :
    distinguishedPoint k (logicalColumnPoint (column R H k) (pairIndex R H k (.inr (b,i)))) j =
      if j = b then false else true := by
  simp [distinguishedPoint, logicalColumnPoint]

theorem enlarged_coset_prefix (k : ℕ) (endpoint : Bool) (z : ClippingCube (logicalDim k))
    (hz : cubeTranslation (referencePoint k endpoint) z ∈
      ((calibrationSubgroup k).adjoinPoint (shiftPoint k)).carrier)
    (i : Fin (OnlineLowerRelu.Family.prefixDim k)) : z (prefixIndex k i) = false := by
  have hOld := ((mem_enlargedCoset k endpoint z).mp hz).1
  exact OnlineLowerRelu.Family.calibration_prefix_bits k endpoint (oldPoint k z) hOld i

theorem concrete_negative_observed_density (k : ℕ) (endpoint : Bool) :
    (1 : ℝ) / 2 ≤ uniformCubeMean (fun z =>
      if z ∈ rectangleNegativeObserved (calibrationSubgroup k) (referencePoint k endpoint) (shiftPoint k)
        then 1 else 0) := by
  let i0 : Fin (OnlineLowerRelu.Family.prefixDim k) := ⟨0, by unfold OnlineLowerRelu.Family.prefixDim; omega⟩
  let i1 : Fin (OnlineLowerRelu.Family.prefixDim k) := ⟨1, by unfold OnlineLowerRelu.Family.prefixDim; omega⟩
  have hne : prefixIndex k i0 ≠ prefixIndex k i1 := by
    intro he
    have hh := congrArg Fin.val (prefixIndex_injective k he)
    norm_num [i0, i1] at hh
  apply rectangleNegativeObserved_density (calibrationSubgroup k) (referencePoint k endpoint)
    (shiftPoint k) (prefixIndex k i0) (prefixIndex k i1) hne
  · have hh : (2 : ℕ)^3 ≤ 2^(logicalDim k) :=
      Nat.pow_le_pow_right (by norm_num) (by rw [logicalDim_eq]; omega)
    simpa [ClippingCube] using hh
  · intro z hz
    exact ⟨enlarged_coset_prefix k endpoint z hz i0, enlarged_coset_prefix k endpoint z hz i1⟩

/-- No physical column alone can satisfy the whole negative prefix: it
contains at most two coordinates whereas the prefix has at least three. -/
theorem oldColumnPoint_not_calibrationCoset (k : ℕ) (endpoint : Bool)
    (i : Fin (OnlineLowerRelu.Family.pairDim k)) :
    logicalColumnPoint (OnlineLowerRelu.Family.column k) i ∉
      calibrationCoset (OnlineLowerRelu.Family.fixedCoordinates k)
        (OnlineLowerRelu.Family.referencePoint k endpoint) := by
  intro hz
  let f : Fin 3 → Fin (OldDim k) := fun j => OnlineLowerRelu.Family.logicalIndex k
    (.inl ⟨j.val, by have hj := j.isLt; unfold OnlineLowerRelu.Family.prefixDim; omega⟩)
  have hf : Function.Injective f := by
    intro a b hab
    have hh := Sum.inl.inj ((OnlineLowerRelu.Family.logicalIndex k).injective hab)
    exact Fin.ext (congrArg (fun j : Fin (OnlineLowerRelu.Family.prefixDim k) => j.val) hh)
  have hsub : Finset.univ.image f ⊆ OnlineLowerRelu.Family.column k i := by
    intro j hj
    obtain ⟨a, _, rfl⟩ := Finset.mem_image.mp hj
    have hh := OnlineLowerRelu.Family.calibration_prefix_bits k endpoint
      (logicalColumnPoint (OnlineLowerRelu.Family.column k) i) hz
      ⟨a.val, by have ha := a.isLt; unfold OnlineLowerRelu.Family.prefixDim; omega⟩
    change logicalColumnPoint (OnlineLowerRelu.Family.column k) i (f a) = false at hh
    by_contra hnot
    simp [logicalColumnPoint, hnot] at hh
  have hc := Finset.card_le_card hsub
  rw [Finset.card_image_of_injective _ hf] at hc
  have hc2 := OnlineLowerRelu.Family.column_card_le k i
  simp only [Finset.card_univ, Fintype.card_fin] at hc
  omega

lemma oldColumnPoint_ne_one (k : ℕ) (i : Fin (OnlineLowerRelu.Family.pairDim k)) :
    logicalColumnPoint (OnlineLowerRelu.Family.column k) i ≠ cubeOne (OldDim k) := by
  have hnot := parityKernel_detected (calibrationConstraints (OnlineLowerRelu.Family.fixedCoordinates k))
    (logicalColumnPoint (OnlineLowerRelu.Family.column k) i)
    (calibrationConstraints_detect_columns (OnlineLowerRelu.Family.column k)
      (OnlineLowerRelu.Family.fixedCoordinates k)
      (OnlineLowerRelu.Family.concrete_column_detection_condition k) i)
  intro he
  exact hnot (he ▸ (parityKernel (calibrationConstraints (OnlineLowerRelu.Family.fixedCoordinates k))).one_mem)

/-- The enlarged live coset together with the overshoot point is independent
under every actual old or repeated distinguished physical column. -/
theorem concrete_unobserved_independence (R H k : ℕ) (endpoint : Bool)
    (i : Fin (pairDim R H k)) (z : ClippingCube (logicalDim k))
    (hz : z ∉ rectangleObserved (calibrationSubgroup k) (referencePoint k endpoint) (shiftPoint k)) :
    cubeTranslation (logicalColumnPoint (column R H k) i) z ∈
      rectangleObserved (calibrationSubgroup k) (referencePoint k endpoint) (shiftPoint k) := by
  have hcases : cubeTranslation (referencePoint k endpoint) z ∈
      ((calibrationSubgroup k).adjoinPoint (shiftPoint k)).carrier ∨ z = shiftPoint k := by
    by_cases he : z = shiftPoint k
    · exact Or.inr he
    · exact Or.inl (by by_contra hh; exact hz ⟨hh, he⟩)
  obtain ⟨raw, rfl⟩ := (pairIndex R H k).surjective i
  cases raw with
  | inl i =>
    constructor
    · intro hmem
      have hnew := ((mem_enlargedCoset k endpoint _).mp hmem).1
      rw [oldPoint_translation, oldPoint_column_old] at hnew
      rcases hcases with hold | he
      · exact OnlineLowerRelu.Family.concrete_calibration_independent k
          (OnlineLowerRelu.Family.referencePoint k endpoint) i (oldPoint k z)
          ((mem_enlargedCoset k endpoint z).mp hold).1 hnew
      · subst z
        simp only [oldPoint_shift, cubeTranslation_comm _ (cubeOne _), cubeTranslation_one] at hnew
        exact oldColumnPoint_not_calibrationCoset k endpoint i hnew
    · intro he
      have hh := congrArg (oldPoint k) he
      rw [oldPoint_translation, oldPoint_column_old, oldPoint_shift] at hh
      have hold := (cubeTranslation_eq_one_iff _ _).mp hh
      rcases hcases with hmem | hez
      · have hcal := ((mem_enlargedCoset k endpoint z).mp hmem).1
        rw [hold] at hcal
        exact oldColumnPoint_not_calibrationCoset k endpoint i hcal
      · subst z
        rw [oldPoint_shift] at hold
        exact oldColumnPoint_ne_one k i hold.symm
  | inr bi =>
    obtain ⟨b, i⟩ := bi
    have hequal : distinguishedPoint k z 0 = distinguishedPoint k z 1 := by
      rcases hcases with hmem | he
      · exact ((mem_enlargedCoset k endpoint z).mp hmem).2
      · subst z; simp
    have hne : distinguishedPoint k (cubeTranslation
        (logicalColumnPoint (column R H k) (pairIndex R H k (.inr (b,i)))) z) 0 ≠
      distinguishedPoint k (cubeTranslation
        (logicalColumnPoint (column R H k) (pairIndex R H k (.inr (b,i)))) z) 1 := by
      rw [distinguishedPoint_translation]
      fin_cases b <;> cases h0 : distinguishedPoint k z 0 <;>
        cases h1 : distinguishedPoint k z 1 <;>
        simp_all [cubeTranslation, distinguishedPoint_column_distinguished]
    constructor
    · intro hmem
      exact hne ((mem_enlargedCoset k endpoint _).mp hmem).2
    · intro he
      have hh := congrArg (distinguishedPoint k) he
      apply hne
      rw [hh]
      simp

lemma referencePoint_not_subgroup (k : ℕ) (endpoint : Bool) :
    referencePoint k endpoint ∉ (calibrationSubgroup k).carrier := by
  intro h
  exact referencePoint_not_enlargedSubgroup k endpoint
    ((calibrationSubgroup k).subset_adjoinPoint (shiftPoint k) h)

/-- Completely instantiated factor-two observability for the actual
shared-carrier family and its actual rectangle calibration set. -/
theorem concrete_odd_observability (R H k : ℕ) (hR : 0 < R) (hH : 0 < H)
    (heR : Even R) (heH : Even H) (endpoint : Bool)
    (F : ClippingCube (dimension R H k) → ℝ) :
    uniformCubeMean (fun x =>
      (fourierProject (carrierOddDownwardSupports (size R H k) (column R H k)) F x -
        (physicalCode R H k hR hH).project F x)^2) ≤
      2 * uniformCubeMean (fun x =>
        if (physicalCode R H k hR hH).syndrome x ∈
          rectangleObserved (calibrationSubgroup k) (referencePoint k endpoint) (shiftPoint k) then
          (fourierProject (carrierOddDownwardSupports (size R H k) (column R H k)) F x -
            (physicalCode R H k hR hH).project F x)^2 else 0) := by
  have hh := actual_carrier_odd_observability (size R H k) (column R H k) (size_pos R H k hR)
    (size_even R H k heR heH) (physicalCode R H k hR hH) (physicalCode_support R H k hR hH)
    F (rectangleObserved (calibrationSubgroup k) (referencePoint k endpoint) (shiftPoint k))ᶜ
    (fun i z hz => by simpa only [Set.mem_compl_iff, not_not] using
      concrete_unobserved_independence R H k endpoint i z hz)
  simpa only [Set.mem_compl_iff, not_not] using hh

end NeuralGeneralization.OnlineLowerTanh.Family
