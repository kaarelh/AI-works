import NeuralGeneralization.OnlineLowerTanhGeometryFamily
import NeuralGeneralization.OnlineLowerTanhGeometryTarget
import NeuralGeneralization.OnlineLowerGeometryCandidate
import NeuralGeneralization.OnlineLowerPhysicalTeacher

/-! # The actual full-cube rectangle protocol for the tanh rail family

The finite digit order is chosen before any learner width or Gaussian
scale. Cost injectivity only selects this finite order; the literal
physical permutation and all its history identities are proved here.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerTanh.Family
open OnlineLowerGeometry OnlineLower ConcreteModel

abbrev CandidateDigits (k : ℕ) := Fin (k - 1) → Bool
abbrev candidateCount (k : ℕ) := Fintype.card (CandidateDigits k)
abbrev CandidateOrder (k : ℕ) := Fin (candidateCount k) ≃ CandidateDigits k

@[simp] lemma candidateCount_eq (k : ℕ) : candidateCount k = 2^(k-1) := by
  simp [candidateCount, CandidateDigits]

def candidatePoint (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool) (digits : CandidateDigits k) :
    ClippingCube (logicalDim k) :=
  extendPoint k (OnlineLower.FamilyCost.candidatePoint k hk endpoint digits) false

lemma candidatePoint_injective (k : ℕ) (hk : 3 ≤ k) (endpoint : Bool) :
    Function.Injective (candidatePoint k (by omega) endpoint) := by
  intro a b hab
  have hh := congrArg (oldPoint k) hab
  simp only [candidatePoint, extendPoint, oldPoint_joinPoint] at hh
  exact OnlineLower.FamilyCost.candidatePoint_injective k hk endpoint hh

lemma candidatePoint_mem (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool) (digits : CandidateDigits k) :
    cubeTranslation (referencePoint k endpoint) (candidatePoint k hk endpoint digits) ∈
      (calibrationSubgroup k).carrier := by
  rw [mem_liveCoset]
  simp only [candidatePoint, extendPoint, oldPoint_joinPoint, distinguishedPoint_joinPoint]
  exact ⟨OnlineLowerRelu.Family.candidatePoint_mem_calibrationCoset k hk endpoint digits, trivial, trivial⟩

def orderedCandidate (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool) (order : CandidateOrder k)
    (i : Fin (candidateCount k)) : ClippingCube (logicalDim k) :=
  candidatePoint k hk endpoint (order i)

lemma orderedCandidate_injective (k : ℕ) (hk : 3 ≤ k) (endpoint : Bool) (order : CandidateOrder k) :
    Function.Injective (orderedCandidate k (by omega) endpoint order) :=
  (candidatePoint_injective k hk endpoint).comp order.injective

lemma orderedCandidate_mem (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool) (order : CandidateOrder k)
    (i : Fin (candidateCount k)) :
    cubeTranslation (referencePoint k endpoint) (orderedCandidate k hk endpoint order i) ∈
      (calibrationSubgroup k).carrier := candidatePoint_mem k hk endpoint _

lemma orderedCandidate_ne_anchor (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool) (order : CandidateOrder k)
    (i : Fin (candidateCount k)) : orderedCandidate k hk endpoint order i ≠ cubeOne (logicalDim k) :=
  ((calibrationSubgroup k).coset_mem_not_anchor_or_shift (shiftPoint k) (referencePoint k endpoint)
    _ (referencePoint_not_enlargedSubgroup k endpoint) (orderedCandidate_mem k hk endpoint order i)).1

lemma orderedCandidate_ne_shift (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool) (order : CandidateOrder k)
    (i : Fin (candidateCount k)) : orderedCandidate k hk endpoint order i ≠ shiftPoint k :=
  ((calibrationSubgroup k).coset_mem_not_anchor_or_shift (shiftPoint k) (referencePoint k endpoint)
    _ (referencePoint_not_enlargedSubgroup k endpoint) (orderedCandidate_mem k hk endpoint order i)).2

/-- Sorting is performed on the actual finite effective cost values. -/
theorem exists_rectangle_cost_order (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool)
    (w : Finset (Fin (logicalDim k)) → ℝ)
    (hinj : Function.Injective (fun digits => rectangleEffectiveCost w (shiftPoint k)
      (candidatePoint k hk endpoint digits))) :
    ∃ order : CandidateOrder k,
      StrictMono (fun i => rectangleEffectiveCost w (shiftPoint k)
        (orderedCandidate k hk endpoint order i)) :=
  exists_injective_cost_order _ hinj

def liveAt (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool) (order : CandidateOrder k)
    (i : Fin (candidateCount k)) (z : ClippingCube (logicalDim k)) : Prop :=
  ∃ j : Fin (candidateCount k), i ≤ j ∧ z = orderedCandidate k hk endpoint order j

lemma liveAt_self (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool) (order : CandidateOrder k)
    (i : Fin (candidateCount k)) : liveAt k hk endpoint order i (orderedCandidate k hk endpoint order i) :=
  ⟨i, le_rfl, rfl⟩

lemma liveAt_mem (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool) (order : CandidateOrder k)
    (i : Fin (candidateCount k)) (z : ClippingCube (logicalDim k)) (hz : liveAt k hk endpoint order i z) :
    cubeTranslation (referencePoint k endpoint) z ∈ (calibrationSubgroup k).carrier := by
  obtain ⟨j, _, rfl⟩ := hz
  exact orderedCandidate_mem k hk endpoint order j

lemma liveAt_strict_cost (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool) (order : CandidateOrder k)
    (w : Finset (Fin (logicalDim k)) → ℝ)
    (horder : StrictMono (fun i => rectangleEffectiveCost w (shiftPoint k)
      (orderedCandidate k hk endpoint order i)))
    (i : Fin (candidateCount k)) (z : ClippingCube (logicalDim k))
    (hz : liveAt k hk endpoint order i z) (hne : orderedCandidate k hk endpoint order i ≠ z) :
    rectangleEffectiveCost w (shiftPoint k) (orderedCandidate k hk endpoint order i) <
      rectangleEffectiveCost w (shiftPoint k) z := by
  obtain ⟨j, hij, rfl⟩ := hz
  exact horder (lt_of_le_of_ne hij (fun hh => hne (congrArg _ hh)))

lemma target_label (R H k : ℕ) (hR : 0 < R) (hH : 0 < H) (x : Cube (dimension R H k)) :
    labelReal (target R H k x) = (physicalCode R H k hR hH).base x *
      (if (physicalCode R H k hR hH).syndrome x = cubeOne (logicalDim k) then 1 else -1) := by
  rw [target, physicalParityTarget_label]
  simp only [WalshCodeMap.base, physicalCode_support, carrierSupport, OnlineLowerRelu.generatedSupport_empty]
  rfl

section Protocol
variable (R H k : ℕ) (hR : 0 < R) (hH : 0 < H) (hk : 3 ≤ k)
    (endpoint : Bool) (order : CandidateOrder k)

include hk

def firstInput (i : Fin (candidateCount k)) : Cube (dimension R H k) :=
  (physicalCode R H k hR hH).sectionPoint (orderedCandidate k (by omega) endpoint order i)

def candidateFiber : Cube (dimension R H k) → Option (Fin (candidateCount k)) :=
  (physicalCode R H k hR hH).codeFiber (orderedCandidate k (by omega) endpoint order)

lemma candidateFiber_firstInput (i : Fin (candidateCount k)) :
    candidateFiber R H k hR hH hk endpoint order (firstInput R H k hR hH hk endpoint order i) = some i :=
  (physicalCode R H k hR hH).codeFiber_sectionPoint _
    (orderedCandidate_injective k hk endpoint order) i

def rectanglePhysicalScore (i : Fin (candidateCount k)) (x : Cube (dimension R H k)) : ℝ :=
  (physicalCode R H k hR hH).base x * rectangleScore (shiftPoint k)
    (orderedCandidate k (by omega) endpoint order i) ((physicalCode R H k hR hH).syndrome x)

def rectangleClassifier (i : Fin (candidateCount k)) : BooleanFunction (dimension R H k) :=
  fiberFlip (target R H k) (candidateFiber R H k hR hH hk endpoint order) i

lemma rectanglePhysicalScore_margin (i : Fin (candidateCount k)) (x : Cube (dimension R H k)) :
    (1 : ℝ) / 2 ≤ labelReal (rectangleClassifier R H k hR hH hk endpoint order i x) *
      rectanglePhysicalScore R H k hR hH hk endpoint order i x :=
  (physicalCode R H k hR hH).physical_rectangle_fiberFlip_margin _
    (orderedCandidate_injective k hk endpoint order) (shiftPoint k)
    (fun hh => shiftPoint_not_subgroup k (hh ▸ (calibrationSubgroup k).one_mem))
    (orderedCandidate_ne_anchor k (by omega) endpoint order)
    (orderedCandidate_ne_shift k (by omega) endpoint order) (target R H k)
    (target_label R H k hR hH) i x

lemma rectanglePhysicalScore_wrong_at_first (i : Fin (candidateCount k)) :
    labelReal (target R H k (firstInput R H k hR hH hk endpoint order i)) *
      rectanglePhysicalScore R H k hR hH hk endpoint order i
        (firstInput R H k hR hH hk endpoint order i) = -(1 : ℝ) / 2 :=
  (physicalCode R H k hR hH).physical_rectangle_wrong_at_section _ (shiftPoint k)
    (fun hh => shiftPoint_not_subgroup k (hh ▸ (calibrationSubgroup k).one_mem))
    (orderedCandidate_ne_anchor k (by omega) endpoint order)
    (orderedCandidate_ne_shift k (by omega) endpoint order) (target R H k)
    (target_label R H k hR hH) i

def HistoryAt (π : InputOrder (dimension R H k)) (i : Fin (candidateCount k)) : Prop :=
  ∀ x, (∃ a : Fin (π.symm (firstInput R H k hR hH hk endpoint order i)).val,
    observedPrefix π (π.symm (firstInput R H k hR hH hk endpoint order i)) a = x) ↔
      (∀ j, (physicalCode R H k hR hH).syndrome x ≠ orderedCandidate k (by omega) endpoint order j) ∨
        ∃ j : Fin (candidateCount k), j < i ∧
          (physicalCode R H k hR hH).syndrome x = orderedCandidate k (by omega) endpoint order j

/-- A complete nonrepeating cube permutation with exactly the intended
whole-fiber prefixes and exponentially many designated wrong first hits. -/
theorem exists_concrete_rectangle_protocol :
    ∃ π : InputOrder (dimension R H k),
    ∃ J : Finset (Fin (Fintype.card (Cube (dimension R H k)))),
      J = designatedRounds (firstInput R H k hR hH hk endpoint order) π ∧
      J.card = 2^(k-1) ∧ ∀ i : Fin (candidateCount k),
        π.symm (firstInput R H k hR hH hk endpoint order i) ∈ J ∧
        HistoryAt R H k hR hH hk endpoint order π i ∧
        (∀ j : Fin (candidateCount k),
          (∀ a : Fin (π.symm (firstInput R H k hR hH hk endpoint order i)).val,
            rectangleClassifier R H k hR hH hk endpoint order j
              (observedPrefix π (π.symm (firstInput R H k hR hH hk endpoint order i)) a) =
            target R H k (observedPrefix π (π.symm (firstInput R H k hR hH hk endpoint order i)) a)) ↔ i ≤ j) ∧
        labelReal (target R H k (π (π.symm (firstInput R H k hR hH hk endpoint order i)))) *
          rectanglePhysicalScore R H k hR hH hk endpoint order i
            (π (π.symm (firstInput R H k hR hH hk endpoint order i))) = -(1 : ℝ) / 2 := by
  let C := physicalCode R H k hR hH
  let point := orderedCandidate k (by omega) endpoint order
  let fiber := candidateFiber R H k hR hH hk endpoint order
  let first := firstInput R H k hR hH hk endpoint order
  have hfirst := candidateFiber_firstInput R H k hR hH hk endpoint order
  obtain ⟨π, hπ⟩ := exists_live_fiber_order fiber first hfirst
  refine ⟨π, designatedRounds first π, rfl, ?_, ?_⟩
  · rw [designatedRounds_card fiber first hfirst, candidateCount_eq]
  · intro i
    refine ⟨Finset.mem_image.mpr ⟨i, Finset.mem_univ _, rfl⟩, ?_, ?_, ?_⟩
    · intro x
      rw [observedPrefix_range_iff, hπ]
      change (C.codeFiber point x = none ∨ ∃ j, j < i ∧ C.codeFiber point x = some j) ↔ _
      rw [C.codeFiber_eq_none_iff]
      simp_rw [C.codeFiber_eq_some_iff point (orderedCandidate_injective k hk endpoint order)]
      rfl
    · intro j
      exact observedPrefix_fits_fiberFlip_iff (target R H k) fiber first hfirst π hπ i j
    · rw [π.apply_symm_apply]
      exact rectanglePhysicalScore_wrong_at_first R H k hR hH hk endpoint order i

end Protocol
/-- Every nonlive logical fiber has already been observed in its entirety. -/
theorem history_covers_nonlive (R H k : ℕ) (hR : 0 < R) (hH : 0 < H) (hk : 3 ≤ k) (endpoint : Bool) (order : CandidateOrder k)
    (π : InputOrder (dimension R H k)) (i : Fin (candidateCount k))
    (hHistory : HistoryAt R H k hR hH hk endpoint order π i)
    (z : ClippingCube (logicalDim k)) (hz : ¬ liveAt k (by omega) endpoint order i z)
    (x : Cube (dimension R H k)) (hx : (physicalCode R H k hR hH).syndrome x = z) :
    ∃ a : Fin (π.symm (firstInput R H k hR hH hk endpoint order i)).val,
      observedPrefix π (π.symm (firstInput R H k hR hH hk endpoint order i)) a = x := by
  apply (hHistory x).mpr
  by_cases hhit : ∃ j, z = orderedCandidate k (by omega) endpoint order j
  · obtain ⟨j, hj⟩ := hhit
    refine Or.inr ⟨j, ?_, hx.trans hj⟩
    exact lt_of_not_ge (fun hij => hz ⟨j, hij, hj⟩)
  · exact Or.inl (fun j hj => hhit ⟨j, hx.symm.trans hj⟩)

/-- Observed half margins imply every physical calibration inequality. -/
theorem history_calibration_margins (R H k : ℕ) (hR : 0 < R) (hH : 0 < H) (hk : 3 ≤ k) (endpoint : Bool) (order : CandidateOrder k)
    (π : InputOrder (dimension R H k)) (i : Fin (candidateCount k))
    (hHistory : HistoryAt R H k hR hH hk endpoint order π i)
    (F : Cube (dimension R H k) → ℝ)
    (hknown : ∀ a : Fin (π.symm (firstInput R H k hR hH hk endpoint order i)).val,
      (1 : ℝ) / 2 ≤ labelReal (target R H k
        (observedPrefix π (π.symm (firstInput R H k hR hH hk endpoint order i)) a)) *
        F (observedPrefix π (π.symm (firstInput R H k hR hH hk endpoint order i)) a)) :
    ∀ x, cubeTranslation (referencePoint k endpoint) ((physicalCode R H k hR hH).syndrome x) ∉
        (calibrationSubgroup k).carrier →
      (1 : ℝ) / 2 ≤ (if (physicalCode R H k hR hH).syndrome x = cubeOne (logicalDim k)
        then 1 else -1) * ((physicalCode R H k hR hH).base x * F x) := by
  intro x hx
  have hn : ¬ liveAt k (by omega) endpoint order i ((physicalCode R H k hR hH).syndrome x) := by
    intro hl
    exact hx (liveAt_mem k (by omega) endpoint order i _ hl)
  obtain ⟨a, ha⟩ := history_covers_nonlive R H k hR hH hk endpoint order π i hHistory _ hn x rfl
  have h := hknown a
  rw [ha, target_label R H k hR hH] at h
  nlinarith only [h]

/-- Revealed fibers force nonpositive live mass, by averaging their
actual target margins under the uniform physical fiber law. -/
theorem history_removed_live_mass (R H k : ℕ) (hR : 0 < R) (hH : 0 < H) (hk : 3 ≤ k) (endpoint : Bool) (order : CandidateOrder k)
    (π : InputOrder (dimension R H k)) (i : Fin (candidateCount k))
    (hHistory : HistoryAt R H k hR hH hk endpoint order π i)
    (F : Cube (dimension R H k) → ℝ)
    (hknown : ∀ a : Fin (π.symm (firstInput R H k hR hH hk endpoint order i)).val,
      (1 : ℝ) / 2 ≤ labelReal (target R H k
        (observedPrefix π (π.symm (firstInput R H k hR hH hk endpoint order i)) a)) *
        F (observedPrefix π (π.symm (firstInput R H k hR hH hk endpoint order i)) a)) :
    ∀ z, ¬ liveAt k (by omega) endpoint order i z →
      reluLiveMass (calibrationSubgroup k) (referencePoint k endpoint)
        ((physicalCode R H k hR hH).logicalProjection F) z ≤ 0 := by
  intro z hz
  by_cases hU : cubeTranslation (referencePoint k endpoint) z ∈ (calibrationSubgroup k).carrier
  · have hzone : z ≠ cubeOne (logicalDim k) := by
      intro he
      rw [he] at hU
      exact cubeOne_not_in_coset (calibrationSubgroup k) (referencePoint k endpoint)
        (referencePoint_not_subgroup k endpoint) hU
    have havg := (physicalCode R H k hR hH).logical_margin_of_fiber_margin
      F (-1) (1 / 2) z (by
        intro x hx
        obtain ⟨a, ha⟩ := history_covers_nonlive R H k hR hH hk endpoint order π i hHistory z hz x hx
        have h := hknown a
        rw [ha, target_label R H k hR hH, hx, if_neg hzone] at h
        nlinarith only [h])
    simp only [reluLiveMass, if_pos hU]
    linarith
  · simp only [reluLiveMass, if_neg hU]
    exact le_rfl

/-- Exact designated-round membership, including the converse used by the
actual posterior theorem's universal quantifier over mistake rounds. -/
theorem designated_round_mem_iff (R H k : ℕ) (hR : 0 < R) (hH : 0 < H) (hk : 3 ≤ k) (endpoint : Bool) (order : CandidateOrder k)
    (π : InputOrder (dimension R H k))
    (j : Fin (Fintype.card (Cube (dimension R H k)))) :
    j ∈ designatedRounds (firstInput R H k hR hH hk endpoint order) π ↔
      ∃ i : Fin (candidateCount k), j = π.symm (firstInput R H k hR hH hk endpoint order i) := by
  simp only [designatedRounds, Finset.mem_image, Finset.mem_univ, true_and]
  exact exists_congr fun i => eq_comm


end NeuralGeneralization.OnlineLowerTanh.Family
