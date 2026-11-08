import NeuralGeneralization.OnlineLowerGeometryObservability
import NeuralGeneralization.OnlineLowerRailSystem

/-!
# First-defective-pair geometry of the actual physical rail code

The downward sets, defective pairs, and support exclusions below are
defined using the physical coordinates and transversals constructed in
`OnlineLowerRailSystem`.  These are the combinatorial inputs to the
conditional Fourier observability theorem.
-/

noncomputable section
open scoped BigOperators Classical symmDiff

namespace NeuralGeneralization.OnlineLowerGeometry
open OnlineLowerRelu

def railDownward {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m))
    (S : Finset (Fin (railDimension size))) : Prop :=
  ∃ s, S ⊆ generatedSupport (physicalBase size)
    (coordinateGenerator (physicalColumn size column)) s

def railDefective {p : ℕ} (size : Fin p → Bool → ℕ)
    (S : Finset (Fin (railDimension size))) (i : Fin p) : Prop :=
  ∀ b, ¬ physicalRail size i b ⊆ S

def railDefectClass {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (i : Fin p) :
    Finset (Finset (Fin (railDimension size))) :=
  Finset.univ.filter (fun S => railDownward size column S ∧ railDefective size S i ∧
    ∀ j, j < i → ¬ railDefective size S j)

theorem mem_railDefectClass {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (i : Fin p)
    (S : Finset (Fin (railDimension size))) :
    S ∈ railDefectClass size column i ↔
      railDownward size column S ∧ railDefective size S i ∧
        ∀ j, j < i → ¬ railDefective size S j := by
  simp [railDefectClass]

theorem physicalRail_subset_pair {p : ℕ} (size : Fin p → Bool → ℕ)
    (i : Fin p) (b : Bool) : physicalRail size i b ⊆ physicalPair size i := by
  intro k hk
  exact (mem_physicalPair _ _ _).mpr ((mem_physicalRail _ _ _ _).mp hk).1

/-- A defective downward support cannot make a whole toggled pair by
symmetric difference with another downward support. -/
theorem defective_toggle_exclusion {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (hsize : ∀ i b, 0 < size i b)
    (i : Fin p) (S T : Finset (Fin (railDimension size)))
    (hS : railDownward size column S) (hT : railDownward size column T)
    (hdef : railDefective size S i) (s : Finset (Fin m))
    (horient : railOrientation column s i = true) :
    S ∆ T ≠ physicalBase size ∆ generatedSupport (physicalBase size)
      (coordinateGenerator (physicalColumn size column)) s := by
  obtain ⟨sS, hS⟩ := hS
  obtain ⟨sT, hT⟩ := hT
  have hnot := defective_pair_not_covered size i
    (railOrientation column sS i) (railOrientation column sT i) S T
    (subset_generatedSupport_side size column sS S hS i)
    (subset_generatedSupport_side size column sT T hT i)
    (hdef _) (hsize i _)
  intro heq
  apply hnot
  intro k hk
  rw [heq]
  have hpair := physical_toggle_pair size column s i
  rw [horient] at hpair
  have hmem : k ∈ (physicalBase size ∆ generatedSupport (physicalBase size)
      (coordinateGenerator (physicalColumn size column)) s) ∩ physicalPair size i := by
    rw [hpair]
    exact hk
  exact (Finset.mem_inter.mp hmem).1

/-- Across different first defects, one component is partial on a pair
where the other contains a whole side. Neither possible code toggle
(empty or full pair) can equal their symmetric difference. -/
theorem defective_full_toggle_exclusion {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (hsize : ∀ i b, 0 < size i b)
    (i : Fin p) (S T : Finset (Fin (railDimension size)))
    (hS : railDownward size column S) (hT : railDownward size column T)
    (hdef : railDefective size S i) (hfull : ¬ railDefective size T i)
    (s : Finset (Fin m)) :
    S ∆ T ≠ physicalBase size ∆ generatedSupport (physicalBase size)
      (coordinateGenerator (physicalColumn size column)) s := by
  by_cases ho : railOrientation column s i = true
  · exact defective_toggle_exclusion size column hsize i S T hS hT hdef s ho
  · intro heq
    have hof : railOrientation column s i = false := Bool.eq_false_of_not_eq_true ho
    obtain ⟨b, hb⟩ : ∃ b, physicalRail size i b ⊆ T := by
      by_contra h
      apply hfull
      intro b hb
      exact h ⟨b, hb⟩
    obtain ⟨k, hk, hks⟩ := Finset.not_subset.mp (hdef b)
    have hkt : k ∈ T := hb hk
    have hkpair : k ∈ physicalPair size i := physicalRail_subset_pair size i b hk
    have hkd : k ∈ S ∆ T := Finset.mem_symmDiff.mpr (Or.inr ⟨hkt, hks⟩)
    rw [heq] at hkd
    have hi := (mem_physicalPair _ _ _).mp hkpair
    rw [physical_toggle_mem, hi, hof] at hkd
    contradiction

theorem different_defect_classes_exclude {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (hsize : ∀ i b, 0 < size i b)
    (i j : Fin p) (hij : i ≠ j)
    (S T : Finset (Fin (railDimension size)))
    (hS : S ∈ railDefectClass size column i)
    (hT : T ∈ railDefectClass size column j) (s : Finset (Fin m)) :
    S ∆ T ≠ physicalBase size ∆ generatedSupport (physicalBase size)
      (coordinateGenerator (physicalColumn size column)) s := by
  obtain ⟨hSd, hSi, hSfirst⟩ := (mem_railDefectClass size column i S).mp hS
  obtain ⟨hTd, hTj, hTfirst⟩ := (mem_railDefectClass size column j T).mp hT
  rcases lt_or_gt_of_ne hij with hlt | hgt
  · exact defective_full_toggle_exclusion size column hsize i S T hSd hTd hSi
      (hTfirst i hlt) s
  · rw [symmDiff_comm S T]
    exact defective_full_toggle_exclusion size column hsize j T S hTd hSd hTj
      (hSfirst j hgt) s

theorem nondefective_contains_selected_side {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (hsize : ∀ i b, 0 < size i b)
    (S : Finset (Fin (railDimension size))) (s : Finset (Fin m))
    (hS : S ⊆ generatedSupport (physicalBase size)
      (coordinateGenerator (physicalColumn size column)) s)
    (i : Fin p) (hdef : ¬ railDefective size S i) :
    physicalRail size i (railOrientation column s i) ⊆ S := by
  obtain ⟨b, hb⟩ : ∃ b, physicalRail size i b ⊆ S := by
    by_contra h
    apply hdef
    intro b hb
    exact h ⟨b, hb⟩
  have hnonempty : (physicalRail size i b).Nonempty := by
    apply Finset.card_pos.mp
    rw [physicalRail_card]
    exact hsize i b
  obtain ⟨k, hk⟩ := hnonempty
  have hki := (mem_physicalRail size i b k).mp hk
  have hks := (physical_generatedSupport_mem size column s k).mp (hS (hb hk))
  have hbsel : b = railOrientation column s i := by
    exact hki.2.symm.trans (hks.trans (congrArg (railOrientation column s) hki.1))
  rwa [← hbsel]

theorem downward_noncode_has_defect {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (hsize : ∀ i b, 0 < size i b)
    (S : Finset (Fin (railDimension size))) (hS : railDownward size column S)
    (hnot : ∀ s, S ≠ generatedSupport (physicalBase size)
      (coordinateGenerator (physicalColumn size column)) s) :
    ∃ i, railDefective size S i := by
  by_contra hno
  obtain ⟨s, hs⟩ := hS
  apply hnot s
  apply Finset.Subset.antisymm hs
  intro k hk
  let i := ((railIndex size).symm k).1
  have hdef : ¬ railDefective size S i := fun h => hno ⟨i, h⟩
  have hfull := nondefective_contains_selected_side size column hsize S s hs i hdef
  apply hfull
  exact (mem_physicalRail size i _ k).mpr
    ⟨rfl, (physical_generatedSupport_mem size column s k).mp hk⟩

theorem downward_noncode_first_defect {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (hsize : ∀ i b, 0 < size i b)
    (S : Finset (Fin (railDimension size))) (hS : railDownward size column S)
    (hnot : ∀ s, S ≠ generatedSupport (physicalBase size)
      (coordinateGenerator (physicalColumn size column)) s) :
    ∃ i, S ∈ railDefectClass size column i := by
  obtain ⟨i0, hi0⟩ := downward_noncode_has_defect size column hsize S hS hnot
  let D : Finset (Fin p) := Finset.univ.filter (railDefective size S)
  have hD : D.Nonempty := ⟨i0, by simp [D, hi0]⟩
  refine ⟨D.min' hD, (mem_railDefectClass size column _ S).mpr ⟨hS, ?_, ?_⟩⟩
  · exact (Finset.mem_filter.mp (Finset.min'_mem D hD)).2
  · intro j hj hdef
    have hjD : j ∈ D := by simp [D, hdef]
    have hle := Finset.min'_le D j hjD
    exact (not_lt_of_ge hle) hj

theorem railDefectClass_unique {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (S : Finset (Fin (railDimension size)))
    (i j : Fin p) (hi : S ∈ railDefectClass size column i)
    (hj : S ∈ railDefectClass size column j) : i = j := by
  obtain ⟨_, hdi, hfi⟩ := (mem_railDefectClass size column i S).mp hi
  obtain ⟨_, hdj, hfj⟩ := (mem_railDefectClass size column j S).mp hj
  rcases lt_trichotomy i j with h | h | h
  · exact False.elim (hfj i h hdi)
  · exact h
  · exact False.elim (hfi j h hdj)

/-- The actual rail support exclusion supplies the conditional Fourier
premise of factor-two observability. -/
theorem actual_rail_component_observability {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (hsize : ∀ i b, 0 < size i b)
    (C : WalshCodeMap (railDimension size) m)
    (hsupport : ∀ s, C.support s = generatedSupport (physicalBase size)
      (coordinateGenerator (physicalColumn size column)) s)
    (i : Fin p) (F : ClippingCube (railDimension size) → ℝ)
    (J : Set (ClippingCube m))
    (hind : ∀ z, z ∈ J → cubeTranslation (logicalColumnPoint column i) z ∉ J) :
    uniformCubeMean (fun x => (fourierProject (railDefectClass size column i) F x) ^ 2) ≤
      2 * uniformCubeMean (fun x => if C.syndrome x ∉ J then
        (fourierProject (railDefectClass size column i) F x) ^ 2 else 0) := by
  apply C.projected_physical_observability _ F (logicalColumnPoint column i) J hind
  intro U hU S hS T hT
  obtain ⟨hSd, hdef, _⟩ := (mem_railDefectClass size column i S).mp hS
  obtain ⟨hTd, _, _⟩ := (mem_railDefectClass size column i T).mp hT
  rw [hsupport, hsupport, generatedSupport_empty]
  exact defective_toggle_exclusion size column hsize i S T hSd hTd hdef U
    ((character_ne_one_iff_orientation column U i).mp hU)

theorem actual_rail_cross_conditional_zero {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (hsize : ∀ i b, 0 < size i b)
    (C : WalshCodeMap (railDimension size) m)
    (hsupport : ∀ s, C.support s = generatedSupport (physicalBase size)
      (coordinateGenerator (physicalColumn size column)) s)
    (i j : Fin p) (hij : i ≠ j) (F : ClippingCube (railDimension size) → ℝ)
    (z : ClippingCube m) :
    C.fiberMean (fun x => fourierProject (railDefectClass size column i) F x *
      fourierProject (railDefectClass size column j) F x) z = 0 := by
  apply C.conditional_projected_product_zero
  intro U S hS T hT
  rw [hsupport, hsupport, generatedSupport_empty]
  exact different_defect_classes_exclude size column hsize i j hij S T hS hT U

def railDownwardSupports {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) : Finset (Finset (Fin (railDimension size))) :=
  Finset.univ.filter (railDownward size column)

def railCodeSupports {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) : Finset (Finset (Fin (railDimension size))) :=
  Finset.univ.image (generatedSupport (physicalBase size)
    (coordinateGenerator (physicalColumn size column)))

theorem selected_side_subset_support {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (s : Finset (Fin m)) (i : Fin p) :
    physicalRail size i (railOrientation column s i) ⊆
      generatedSupport (physicalBase size) (coordinateGenerator (physicalColumn size column)) s := by
  rw [physical_generatedSupport_eq]
  intro k hk
  exact Finset.mem_biUnion.mpr ⟨i, Finset.mem_univ i, hk⟩

theorem railDefectClass_not_code {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (i : Fin p)
    (S : Finset (Fin (railDimension size))) (hS : S ∈ railDefectClass size column i) :
    S ∉ railCodeSupports size column := by
  obtain ⟨_, hdef, _⟩ := (mem_railDefectClass size column i S).mp hS
  intro hcode
  obtain ⟨s, _, hs⟩ := Finset.mem_image.mp hcode
  apply hdef (railOrientation column s i)
  rw [← hs]
  exact selected_side_subset_support size column s i

theorem railCodeSupports_subset_downward {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) :
    railCodeSupports size column ⊆ railDownwardSupports size column := by
  intro S hS
  obtain ⟨s, _, rfl⟩ := Finset.mem_image.mp hS
  exact Finset.mem_filter.mpr ⟨Finset.mem_univ _, ⟨s, Finset.Subset.refl _⟩⟩

theorem railDefect_mask_sum {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (hsize : ∀ i b, 0 < size i b)
    (S : Finset (Fin (railDimension size))) (a : ℝ) :
    (∑ i, if S ∈ railDefectClass size column i then a else 0) =
      (if S ∈ railDownwardSupports size column then a else 0) -
      (if S ∈ railCodeSupports size column then a else 0) := by
  by_cases hD : S ∈ railDownwardSupports size column
  · by_cases hC : S ∈ railCodeSupports size column
    · have hnone (i : Fin p) : S ∉ railDefectClass size column i :=
        fun hi => railDefectClass_not_code size column i S hi hC
      simp [hD, hC, hnone]
    · have hdown : railDownward size column S := (Finset.mem_filter.mp hD).2
      have hnot (s : Finset (Fin m)) : S ≠ generatedSupport (physicalBase size)
          (coordinateGenerator (physicalColumn size column)) s := by
        intro hs
        apply hC
        exact Finset.mem_image.mpr ⟨s, Finset.mem_univ _, hs.symm⟩
      obtain ⟨i, hi⟩ := downward_noncode_first_defect size column hsize S hdown hnot
      rw [if_pos hD, if_neg hC, sub_zero, Finset.sum_eq_single i]
      · exact if_pos hi
      · intro j _ hji
        apply if_neg
        intro hj
        exact hji (railDefectClass_unique size column S j i hj hi)
      · simp
  · have hC : S ∉ railCodeSupports size column :=
      fun hc => hD (railCodeSupports_subset_downward size column hc)
    have hnone (i : Fin p) : S ∉ railDefectClass size column i := by
      intro hi
      apply hD
      exact Finset.mem_filter.mpr ⟨Finset.mem_univ _,
        ((mem_railDefectClass size column i S).mp hi).1⟩
    simp [hD, hC, hnone]

/-- The first-defect components sum exactly to the downward projection
minus the retained code projection. -/
theorem railDefect_projection_sum {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (hsize : ∀ i b, 0 < size i b)
    (F : ClippingCube (railDimension size) → ℝ) (x : ClippingCube (railDimension size)) :
    (∑ i, fourierProject (railDefectClass size column i) F x) =
      fourierProject (railDownwardSupports size column) F x -
        fourierProject (railCodeSupports size column) F x := by
  unfold fourierProject walshExpansion
  rw [Finset.sum_comm, ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro S _
  rw [← Finset.sum_mul, railDefect_mask_sum size column hsize]
  ring

/-- Full physical observability for the actual downward/code residual.
All first-defect and conditional-orthogonality premises have been proved
above from the literal physical rails. The remaining independence
condition concerns the chosen logical calibration set. -/
theorem actual_rail_observability {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (hsize : ∀ i b, 0 < size i b)
    (C : WalshCodeMap (railDimension size) m)
    (hsupport : ∀ s, C.support s = generatedSupport (physicalBase size)
      (coordinateGenerator (physicalColumn size column)) s)
    (F : ClippingCube (railDimension size) → ℝ) (J : Set (ClippingCube m))
    (hind : ∀ i z, z ∈ J → cubeTranslation (logicalColumnPoint column i) z ∉ J) :
    uniformCubeMean (fun x =>
      (fourierProject (railDownwardSupports size column) F x - C.project F x) ^ 2) ≤
      2 * uniformCubeMean (fun x => if C.syndrome x ∉ J then
        (fourierProject (railDownwardSupports size column) F x - C.project F x) ^ 2 else 0) := by
  let A := fun i => fourierProject (railDefectClass size column i) F
  have hcross : ∀ i j, i ≠ j → ∀ z,
      C.fiberMean (fun x => A i x * A j x) z = 0 := by
    intro i j hij z
    exact actual_rail_cross_conditional_zero size column hsize C hsupport i j hij F z
  have hcodes : C.supports = railCodeSupports size column := by
    unfold WalshCodeMap.supports railCodeSupports
    congr 1
    funext s
    exact hsupport s
  have hsum (x : ClippingCube (railDimension size)) :
      (∑ i, A i x) = fourierProject (railDownwardSupports size column) F x - C.project F x := by
    rw [C.project_eq_fourierProject, hcodes]
    exact railDefect_projection_sum size column hsize F x
  have hbound := Finset.sum_le_sum fun i (_ : i ∈ Finset.univ) =>
    actual_rail_component_observability size column hsize C hsupport i F J (hind i)
  have hleft := C.physical_sum_squared A hcross
  have hright := C.physical_restricted_sum_squared A J hcross
  simp_rw [hsum] at hleft hright
  rw [hleft, hright, Finset.mul_sum]
  exact hbound

end NeuralGeneralization.OnlineLowerGeometry
