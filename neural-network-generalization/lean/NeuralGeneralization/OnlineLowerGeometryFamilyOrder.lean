import NeuralGeneralization.OnlineLowerGeometryCandidate
import NeuralGeneralization.OnlineLowerGeometryStarTarget
import NeuralGeneralization.OnlineLowerGeometryReluCalibration
import NeuralGeneralization.OnlineLowerFamilyCostGeometry

/-!
# The literal cost-sorted adversarial protocol for the ReLU family

The order enumerates the full physical Boolean cube and depends only on
the finite family parameters. It therefore precedes any choice of learner
width or Gaussian scale. Its target is the actual constructed parity-AND
teacher, and its comparators are the actual physical star scores.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerRelu.Family
open OnlineLowerGeometry OnlineLower OnlineLower.FamilyCost ConcreteModel

abbrev CandidateDigits (k : ℕ) := Fin (k - 1) → Bool
abbrev candidateCount (k : ℕ) := Fintype.card (CandidateDigits k)

@[simp] theorem candidateCount_eq (k : ℕ) : candidateCount k = 2 ^ (k - 1) := by
  simp [candidateCount, CandidateDigits]

def baseDegree (R k : ℕ) : ℝ := (pairDim k * R : ℕ)

theorem baseDegree_gt_one (R k : ℕ) (hR : 2 ≤ R) : 1 < baseDegree R k := by
  have hp : 4 ≤ pairDim k := by rw [pairDim_eq]; omega
  have hn : 1 < pairDim k * R := by nlinarith
  unfold baseDegree
  exact_mod_cast hn

def orderedDigits (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k) (endpoint : Bool) :
    Fin (candidateCount k) ≃ CandidateDigits k :=
  Classical.choose (exists_injective_cost_order
    (candidateCost k (by omega) (baseDegree R k) OnlineLowerBernstein.gammaCost endpoint)
    (candidateCost_injective k hk (baseDegree R k) (baseDegree_gt_one R k hR) endpoint))

theorem orderedDigits_cost_strictMono (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k) (endpoint : Bool) :
    StrictMono (fun i => candidateCost k (by omega) (baseDegree R k)
      OnlineLowerBernstein.gammaCost endpoint (orderedDigits R k hR hk endpoint i)) :=
  Classical.choose_spec (exists_injective_cost_order
    (candidateCost k (by omega) (baseDegree R k) OnlineLowerBernstein.gammaCost endpoint)
    (candidateCost_injective k hk (baseDegree R k) (baseDegree_gt_one R k hR) endpoint))

def orderedCandidate (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k) (endpoint : Bool)
    (i : Fin (candidateCount k)) : ClippingCube (logicalDim k) :=
  candidatePoint k (by omega) endpoint (orderedDigits R k hR hk endpoint i)

theorem orderedCandidate_injective (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k) (endpoint : Bool) :
    Function.Injective (orderedCandidate R k hR hk endpoint) :=
  (candidatePoint_injective k hk endpoint).comp (orderedDigits R k hR hk endpoint).injective

theorem orderedCandidate_mem (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k) (endpoint : Bool)
    (i : Fin (candidateCount k)) :
    orderedCandidate R k hR hk endpoint i ∈
      calibrationCoset (fixedCoordinates k) (referencePoint k endpoint) :=
  candidatePoint_mem_calibrationCoset k (by omega) endpoint _

theorem orderedCandidate_ne_anchor (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k) (endpoint : Bool)
    (i : Fin (candidateCount k)) : orderedCandidate R k hR hk endpoint i ≠ cubeOne (logicalDim k) := by
  have hmem := orderedCandidate_mem R k hR hk endpoint i
  intro h
  rw [h] at hmem
  exact cubeOne_not_in_coset (calibrationSubgroup k) (referencePoint k endpoint)
    (referencePoint_not_subgroup k endpoint) hmem


/-- The literal physical inverse-cost coefficients are strictly ordered. -/
theorem orderedCandidate_weightExpansion_strictMono (R k : ℕ) (hR : 2 ≤ R)
    (hk : 3 ≤ k) (endpoint : Bool) :
    StrictMono (fun i => walshExpansion (weight R k) (orderedCandidate R k hR hk endpoint i) /
      Fintype.card (ClippingCube (logicalDim k))) := by
  simpa only [orderedCandidate, ← candidateCost_eq_actualWeightExpansion, baseDegree] using
    orderedDigits_cost_strictMono R k hR hk endpoint

/-- The remaining candidate fibers immediately before the designated hit. -/
def liveAt (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k) (endpoint : Bool)
    (i : Fin (candidateCount k)) (z : ClippingCube (logicalDim k)) : Prop :=
  ∃ j : Fin (candidateCount k), i ≤ j ∧ z = orderedCandidate R k hR hk endpoint j

theorem liveAt_self (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k) (endpoint : Bool)
    (i : Fin (candidateCount k)) :
    liveAt R k hR hk endpoint i (orderedCandidate R k hR hk endpoint i) := ⟨i, le_rfl, rfl⟩

theorem liveAt_mem (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k) (endpoint : Bool)
    (i : Fin (candidateCount k)) (z : ClippingCube (logicalDim k))
    (hz : liveAt R k hR hk endpoint i z) :
    z ∈ calibrationCoset (fixedCoordinates k) (referencePoint k endpoint) := by
  obtain ⟨j, _, rfl⟩ := hz
  exact orderedCandidate_mem R k hR hk endpoint j

theorem liveAt_strict_weightExpansion (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k)
    (endpoint : Bool) (i : Fin (candidateCount k)) (z : ClippingCube (logicalDim k))
    (hz : liveAt R k hR hk endpoint i z)
    (hne : orderedCandidate R k hR hk endpoint i ≠ z) :
    walshExpansion (weight R k) (orderedCandidate R k hR hk endpoint i) /
        Fintype.card (ClippingCube (logicalDim k)) <
      walshExpansion (weight R k) z / Fintype.card (ClippingCube (logicalDim k)) := by
  obtain ⟨j, hij, rfl⟩ := hz
  apply orderedCandidate_weightExpansion_strictMono R k hR hk endpoint
  exact lt_of_le_of_ne hij (fun h => hne (congrArg _ h))

def target (R k : ℕ) : BooleanFunction (railDimension (size R k)) :=
  physicalParityTarget (physicalBase (size R k)) (physicalColumn (size R k) (column k))

theorem target_label (R k : ℕ) (hR : 0 < R) (x : Cube (railDimension (size R k))) :
    labelReal (target R k x) = (physicalCode R k hR).base x *
      (if (physicalCode R k hR).syndrome x = cubeOne (logicalDim k) then 1 else -1) := by
  rw [target, physicalParityTarget_label]
  simp only [WalshCodeMap.base, physicalCode_support, generatedSupport_empty]
  rfl

def firstInput (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k) (endpoint : Bool)
    (i : Fin (candidateCount k)) : Cube (railDimension (size R k)) :=
  (physicalCode R k (by omega)).sectionPoint (orderedCandidate R k hR hk endpoint i)

def candidateFiber (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k) (endpoint : Bool) :
    Cube (railDimension (size R k)) → Option (Fin (candidateCount k)) :=
  (physicalCode R k (by omega)).codeFiber (orderedCandidate R k hR hk endpoint)

theorem candidateFiber_firstInput (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k) (endpoint : Bool)
    (i : Fin (candidateCount k)) : candidateFiber R k hR hk endpoint (firstInput R k hR hk endpoint i) = some i :=
  (physicalCode R k (by omega)).codeFiber_sectionPoint _
    (orderedCandidate_injective R k hR hk endpoint) i

def starScore (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k) (endpoint : Bool)
    (i : Fin (candidateCount k)) (x : Cube (railDimension (size R k))) : ℝ :=
  (physicalCode R k (by omega)).base x * reluStar (orderedCandidate R k hR hk endpoint i)
    ((physicalCode R k (by omega)).syndrome x)

def starClassifier (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k) (endpoint : Bool)
    (i : Fin (candidateCount k)) : BooleanFunction (railDimension (size R k)) :=
  fiberFlip (target R k) (candidateFiber R k hR hk endpoint) i

theorem starScore_half_margin (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k) (endpoint : Bool)
    (i : Fin (candidateCount k)) (x : Cube (railDimension (size R k))) :
    labelReal (starClassifier R k hR hk endpoint i x) * starScore R k hR hk endpoint i x = (1 : ℝ) / 2 :=
  (physicalCode R k (by omega)).physical_star_fiberFlip_margin _
    (orderedCandidate_injective R k hR hk endpoint) (orderedCandidate_ne_anchor R k hR hk endpoint)
    (target R k) (target_label R k (by omega)) i x

theorem starScore_wrong_at_first (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k) (endpoint : Bool)
    (i : Fin (candidateCount k)) :
    labelReal (target R k (firstInput R k hR hk endpoint i)) *
      starScore R k hR hk endpoint i (firstInput R k hR hk endpoint i) = -(1 : ℝ) / 2 :=
  (physicalCode R k (by omega)).physical_star_wrong_at_section _
    (orderedCandidate_ne_anchor R k hR hk endpoint) (target R k) (target_label R k (by omega)) i

/-- A complete physical cube permutation with exponentially many
designated first hits, exact earlier whole fibers, and literal wrong
half-margin star scores. -/
theorem exists_concrete_family_protocol (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k) (endpoint : Bool) :
    ∃ π : InputOrder (railDimension (size R k)),
    ∃ J : Finset (Fin (Fintype.card (Cube (railDimension (size R k))))),
      J = designatedRounds (firstInput R k hR hk endpoint) π ∧
      J.card = 2 ^ (k - 1) ∧ ∀ i : Fin (candidateCount k),
        π.symm (firstInput R k hR hk endpoint i) ∈ J ∧
        (∀ x, (∃ a : Fin (π.symm (firstInput R k hR hk endpoint i)).val,
          observedPrefix π (π.symm (firstInput R k hR hk endpoint i)) a = x) ↔
          (∀ j, (physicalCode R k (by omega)).syndrome x ≠ orderedCandidate R k hR hk endpoint j) ∨
          ∃ j : Fin (candidateCount k), j < i ∧
            (physicalCode R k (by omega)).syndrome x = orderedCandidate R k hR hk endpoint j) ∧
        (∀ j : Fin (candidateCount k),
          (∀ a : Fin (π.symm (firstInput R k hR hk endpoint i)).val,
            starClassifier R k hR hk endpoint j
              (observedPrefix π (π.symm (firstInput R k hR hk endpoint i)) a) =
            target R k (observedPrefix π (π.symm (firstInput R k hR hk endpoint i)) a)) ↔ i ≤ j) ∧
        labelReal (target R k (π (π.symm (firstInput R k hR hk endpoint i)))) *
          starScore R k hR hk endpoint i (π (π.symm (firstInput R k hR hk endpoint i))) = -(1 : ℝ) / 2 := by
  let C := physicalCode R k (by omega)
  let point := orderedCandidate R k hR hk endpoint
  let fiber := candidateFiber R k hR hk endpoint
  let first := firstInput R k hR hk endpoint
  have hfirst := candidateFiber_firstInput R k hR hk endpoint
  obtain ⟨π, hπ⟩ := exists_live_fiber_order fiber first hfirst
  refine ⟨π, designatedRounds first π, rfl, ?_, ?_⟩
  · rw [designatedRounds_card fiber first hfirst, candidateCount_eq]
  · intro i
    refine ⟨Finset.mem_image.mpr ⟨i, Finset.mem_univ _, rfl⟩, ?_, ?_, ?_⟩
    · intro x
      rw [observedPrefix_range_iff, hπ]
      change (C.codeFiber point x = none ∨ ∃ j, j < i ∧ C.codeFiber point x = some j) ↔ _
      rw [C.codeFiber_eq_none_iff]
      simp_rw [C.codeFiber_eq_some_iff point (orderedCandidate_injective R k hR hk endpoint)]
      rfl
    · intro j
      exact observedPrefix_fits_fiberFlip_iff (target R k) fiber first hfirst π hπ i j
    · rw [π.apply_symm_apply]
      exact starScore_wrong_at_first R k hR hk endpoint i


/-- Exact description of the observed physical prefix at a designated hit. -/
def HistoryAt (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k) (endpoint : Bool)
    (π : InputOrder (railDimension (size R k))) (i : Fin (candidateCount k)) : Prop :=
  ∀ x, (∃ a : Fin (π.symm (firstInput R k hR hk endpoint i)).val,
    observedPrefix π (π.symm (firstInput R k hR hk endpoint i)) a = x) ↔
    (∀ j, (physicalCode R k (by omega)).syndrome x ≠ orderedCandidate R k hR hk endpoint j) ∨
      ∃ j : Fin (candidateCount k), j < i ∧
        (physicalCode R k (by omega)).syndrome x = orderedCandidate R k hR hk endpoint j

/-- Every nonlive logical fiber has already been observed in its entirety. -/
theorem history_covers_nonlive (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k) (endpoint : Bool)
    (π : InputOrder (railDimension (size R k))) (i : Fin (candidateCount k))
    (hHistory : HistoryAt R k hR hk endpoint π i)
    (z : ClippingCube (logicalDim k)) (hz : ¬ liveAt R k hR hk endpoint i z)
    (x : Cube (railDimension (size R k))) (hx : (physicalCode R k (by omega)).syndrome x = z) :
    ∃ a : Fin (π.symm (firstInput R k hR hk endpoint i)).val,
      observedPrefix π (π.symm (firstInput R k hR hk endpoint i)) a = x := by
  apply (hHistory x).mpr
  by_cases hhit : ∃ j, z = orderedCandidate R k hR hk endpoint j
  · obtain ⟨j, hj⟩ := hhit
    refine Or.inr ⟨j, ?_, hx.trans hj⟩
    exact lt_of_not_ge (fun hij => hz ⟨j, hij, hj⟩)
  · exact Or.inl (fun j hj => hhit ⟨j, hx.symm.trans hj⟩)

/-- Observed half margins imply every physical calibration inequality. -/
theorem history_calibration_margins (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k) (endpoint : Bool)
    (π : InputOrder (railDimension (size R k))) (i : Fin (candidateCount k))
    (hHistory : HistoryAt R k hR hk endpoint π i)
    (F : Cube (railDimension (size R k)) → ℝ)
    (hknown : ∀ a : Fin (π.symm (firstInput R k hR hk endpoint i)).val,
      (1 : ℝ) / 2 ≤ labelReal (target R k
        (observedPrefix π (π.symm (firstInput R k hR hk endpoint i)) a)) *
        F (observedPrefix π (π.symm (firstInput R k hR hk endpoint i)) a)) :
    ∀ x, cubeTranslation (referencePoint k endpoint) ((physicalCode R k (by omega)).syndrome x) ∉
        (calibrationSubgroup k).carrier →
      (1 : ℝ) / 2 ≤ (if (physicalCode R k (by omega)).syndrome x = cubeOne (logicalDim k)
        then 1 else -1) * ((physicalCode R k (by omega)).base x * F x) := by
  intro x hx
  have hn : ¬ liveAt R k hR hk endpoint i ((physicalCode R k (by omega)).syndrome x) := by
    intro hl
    exact hx (liveAt_mem R k hR hk endpoint i _ hl)
  obtain ⟨a, ha⟩ := history_covers_nonlive R k hR hk endpoint π i hHistory _ hn x rfl
  have h := hknown a
  rw [ha, target_label R k (by omega)] at h
  nlinarith only [h]

/-- Revealed fibers force nonpositive live mass, by averaging their
actual target margins under the uniform physical fiber law. -/
theorem history_removed_live_mass (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k) (endpoint : Bool)
    (π : InputOrder (railDimension (size R k))) (i : Fin (candidateCount k))
    (hHistory : HistoryAt R k hR hk endpoint π i)
    (F : Cube (railDimension (size R k)) → ℝ)
    (hknown : ∀ a : Fin (π.symm (firstInput R k hR hk endpoint i)).val,
      (1 : ℝ) / 2 ≤ labelReal (target R k
        (observedPrefix π (π.symm (firstInput R k hR hk endpoint i)) a)) *
        F (observedPrefix π (π.symm (firstInput R k hR hk endpoint i)) a)) :
    ∀ z, ¬ liveAt R k hR hk endpoint i z →
      reluLiveMass (calibrationSubgroup k) (referencePoint k endpoint)
        ((physicalCode R k (by omega)).logicalProjection F) z ≤ 0 := by
  intro z hz
  by_cases hU : cubeTranslation (referencePoint k endpoint) z ∈ (calibrationSubgroup k).carrier
  · have hzone : z ≠ cubeOne (logicalDim k) := by
      intro he
      rw [he] at hU
      exact cubeOne_not_in_coset (calibrationSubgroup k) (referencePoint k endpoint)
        (referencePoint_not_subgroup k endpoint) hU
    have havg := (physicalCode R k (by omega)).logical_margin_of_fiber_margin
      F (-1) (1 / 2) z (by
        intro x hx
        obtain ⟨a, ha⟩ := history_covers_nonlive R k hR hk endpoint π i hHistory z hz x hx
        have h := hknown a
        rw [ha, target_label R k (by omega), hx, if_neg hzone] at h
        nlinarith only [h])
    simp only [reluLiveMass, if_pos hU]
    linarith
  · simp only [reluLiveMass, if_neg hU]
    exact le_rfl

/-- Exact designated-round membership, including the converse used by the
actual posterior theorem's universal quantifier over mistake rounds. -/
theorem designated_round_mem_iff (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k) (endpoint : Bool)
    (π : InputOrder (railDimension (size R k)))
    (j : Fin (Fintype.card (Cube (railDimension (size R k))))) :
    j ∈ designatedRounds (firstInput R k hR hk endpoint) π ↔
      ∃ i : Fin (candidateCount k), j = π.symm (firstInput R k hR hk endpoint i) := by
  simp only [designatedRounds, Finset.mem_image, Finset.mem_univ, true_and]
  exact exists_congr fun i => eq_comm

end NeuralGeneralization.OnlineLowerRelu.Family
