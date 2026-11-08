import NeuralGeneralization.OnlineLowerGeometryRailDefect
import NeuralGeneralization.OnlineLowerCarrierRails

/-! # Odd downward observability for the literal shared-carrier code

The carrier-free complete transversals have even degree and are excluded.
Every remaining noncode support has an actual defective rail pair. The
conditional covariance argument is the same literal finite Fourier
argument as for ReLU, with no analytic or neuron hypothesis.
-/

noncomputable section
open scoped BigOperators Classical symmDiff

namespace NeuralGeneralization.OnlineLowerGeometry
open OnlineLowerRelu OnlineLowerTanh

def carrierTail {d : ℕ} (S : Finset (Fin (d + 1))) : Finset (Fin d) :=
  Finset.univ.filter (fun j => j.succ ∈ S)

@[simp] theorem mem_carrierTail {d : ℕ} (S : Finset (Fin (d + 1))) (j : Fin d) :
    j ∈ carrierTail S ↔ j.succ ∈ S := by simp [carrierTail]

@[simp] theorem carrierTail_symmDiff {d : ℕ} (S T : Finset (Fin (d + 1))) :
    carrierTail (S ∆ T) = carrierTail S ∆ carrierTail T := by
  ext j
  simp [Finset.mem_symmDiff]

@[simp] theorem carrierTail_support {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (s : Finset (Fin m)) :
    carrierTail (carrierSupport size column s) = generatedSupport (physicalBase size)
      (coordinateGenerator (physicalColumn size column)) s := by
  ext j
  simp

theorem carrierTail_map_eq {d : ℕ} (S : Finset (Fin (d + 1)))
    (hzero : (0 : Fin (d + 1)) ∉ S) : (carrierTail S).map (shiftPhysical d) = S := by
  ext j
  refine Fin.cases ?_ (fun j => ?_) j
  · simp [shiftPhysical, hzero]
  · simp [shiftPhysical]

theorem carrierTail_insert_map_eq {d : ℕ} (S : Finset (Fin (d + 1)))
    (hzero : (0 : Fin (d + 1)) ∈ S) : insert 0 ((carrierTail S).map (shiftPhysical d)) = S := by
  ext j
  refine Fin.cases ?_ (fun j => ?_) j
  · simp [hzero]
  · simp [shiftPhysical]

theorem carrier_downward_iff {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (S : Finset (Fin (carrierDimension size))) :
    (∃ s, S ⊆ carrierSupport size column s) ↔ railDownward size column (carrierTail S) := by
  constructor
  · rintro ⟨s, hs⟩
    refine ⟨s, ?_⟩
    intro j hj
    exact (succ_mem_carrierSupport size column s j).mp (hs ((mem_carrierTail S j).mp hj))
  · rintro ⟨s, hs⟩
    refine ⟨s, ?_⟩
    intro j
    refine Fin.cases ?_ (fun j => ?_) j
    · intro _
      exact zero_mem_carrierSupport size column s
    · intro hj
      exact (succ_mem_carrierSupport size column s j).mpr (hs ((mem_carrierTail S j).mpr hj))

def carrierOddDownwardSupports {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) : Finset (Finset (Fin (carrierDimension size))) :=
  Finset.univ.filter (fun S => Odd S.card ∧ ∃ s, S ⊆ carrierSupport size column s)

def carrierCodeSupports {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) : Finset (Finset (Fin (carrierDimension size))) :=
  Finset.univ.image (carrierSupport size column)

def carrierDefectClass {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (i : Fin p) :
    Finset (Finset (Fin (carrierDimension size))) :=
  Finset.univ.filter (fun S => Odd S.card ∧ carrierTail S ∈ railDefectClass size column i)

@[simp] theorem mem_carrierDefectClass {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (i : Fin p)
    (S : Finset (Fin (carrierDimension size))) :
    S ∈ carrierDefectClass size column i ↔
      Odd S.card ∧ carrierTail S ∈ railDefectClass size column i := by
  simp [carrierDefectClass]

lemma carrierSupport_odd {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (heven : ∀ i b, Even (size i b))
    (s : Finset (Fin m)) : Odd (carrierSupport size column s).card := by
  rw [carrierSupport_eq, Finset.card_insert_of_notMem (by simp [shiftPhysical]), Finset.card_map]
  exact (physical_generatedSupport_even size column s heven).add_one

/-- Oddness removes precisely the carrier-free complete transversals. -/
theorem odd_carrier_code_iff_tail_code {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (heven : ∀ i b, Even (size i b))
    (S : Finset (Fin (carrierDimension size))) (hodd : Odd S.card) :
    S ∈ carrierCodeSupports size column ↔ carrierTail S ∈ railCodeSupports size column := by
  constructor
  · rintro hS
    obtain ⟨s, _, rfl⟩ := Finset.mem_image.mp hS
    rw [carrierTail_support]
    exact Finset.mem_image.mpr ⟨s, Finset.mem_univ _, rfl⟩
  · intro hS
    obtain ⟨s, _, hs⟩ := Finset.mem_image.mp hS
    have hzero : (0 : Fin (carrierDimension size)) ∈ S := by
      by_contra hz
      have heq := carrierTail_map_eq S hz
      have he : Even S.card := by
        rw [← heq, Finset.card_map, ← hs]
        exact physical_generatedSupport_even size column s heven
      exact (Nat.not_odd_iff_even.mpr he) hodd
    apply Finset.mem_image.mpr
    refine ⟨s, Finset.mem_univ _, ?_⟩
    rw [carrierSupport_eq, hs]
    exact carrierTail_insert_map_eq S hzero

/-- The carrier projection has exactly the same first-defect partition,
restricted to odd physical supports. -/
theorem carrierDefect_mask_sum {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (hsize : ∀ i b, 0 < size i b)
    (heven : ∀ i b, Even (size i b))
    (S : Finset (Fin (carrierDimension size))) (a : ℝ) :
    (∑ i, if S ∈ carrierDefectClass size column i then a else 0) =
      (if S ∈ carrierOddDownwardSupports size column then a else 0) -
      (if S ∈ carrierCodeSupports size column then a else 0) := by
  by_cases hodd : Odd S.card
  · have hdown : S ∈ carrierOddDownwardSupports size column ↔
        carrierTail S ∈ railDownwardSupports size column := by
      simp only [carrierOddDownwardSupports, railDownwardSupports, Finset.mem_filter,
        Finset.mem_univ, true_and, hodd, true_and, carrier_downward_iff]
    simp only [mem_carrierDefectClass, hodd, true_and, hdown,
      odd_carrier_code_iff_tail_code size column heven S hodd]
    exact railDefect_mask_sum size column hsize (carrierTail S) a
  · have hncode : S ∉ carrierCodeSupports size column := by
      intro hS
      obtain ⟨s, _, rfl⟩ := Finset.mem_image.mp hS
      exact hodd (carrierSupport_odd size column heven s)
    simp [carrierOddDownwardSupports, hodd, hncode]

lemma carrier_defective_toggle_exclusion {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (hsize : ∀ i b, 0 < size i b)
    (i : Fin p) (S T : Finset (Fin (carrierDimension size)))
    (hS : S ∈ carrierDefectClass size column i)
    (hT : T ∈ carrierDefectClass size column i)
    (s : Finset (Fin m)) (horient : railOrientation column s i = true) :
    S ∆ T ≠ carrierSupport size column ∅ ∆ carrierSupport size column s := by
  intro heq
  have hh := congrArg carrierTail heq
  simp only [carrierTail_symmDiff, carrierTail_support, generatedSupport_empty] at hh
  obtain ⟨hSd, hSi, _⟩ := (mem_railDefectClass size column i _).mp
    ((mem_carrierDefectClass size column i S).mp hS).2
  obtain ⟨hTd, _, _⟩ := (mem_railDefectClass size column i _).mp
    ((mem_carrierDefectClass size column i T).mp hT).2
  exact defective_toggle_exclusion size column hsize i _ _ hSd hTd hSi s horient hh

lemma carrier_different_defect_exclusion {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (hsize : ∀ i b, 0 < size i b)
    (i j : Fin p) (hij : i ≠ j) (S T : Finset (Fin (carrierDimension size)))
    (hS : S ∈ carrierDefectClass size column i)
    (hT : T ∈ carrierDefectClass size column j) (s : Finset (Fin m)) :
    S ∆ T ≠ carrierSupport size column ∅ ∆ carrierSupport size column s := by
  intro heq
  have hh := congrArg carrierTail heq
  simp only [carrierTail_symmDiff, carrierTail_support, generatedSupport_empty] at hh
  exact different_defect_classes_exclude size column hsize i j hij _ _
    ((mem_carrierDefectClass size column i S).mp hS).2
    ((mem_carrierDefectClass size column j T).mp hT).2 s hh

theorem carrierDefect_projection_sum {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (hsize : ∀ i b, 0 < size i b)
    (heven : ∀ i b, Even (size i b))
    (F : ClippingCube (carrierDimension size) → ℝ) (x : ClippingCube (carrierDimension size)) :
    (∑ i, fourierProject (carrierDefectClass size column i) F x) =
      fourierProject (carrierOddDownwardSupports size column) F x -
        fourierProject (carrierCodeSupports size column) F x := by
  unfold fourierProject walshExpansion
  rw [Finset.sum_comm, ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro S _
  rw [← Finset.sum_mul, carrierDefect_mask_sum size column hsize heven]
  ring

theorem actual_carrier_component_observability {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (hsize : ∀ i b, 0 < size i b)
    (C : WalshCodeMap (carrierDimension size) m)
    (hsupport : ∀ s, C.support s = carrierSupport size column s)
    (i : Fin p) (F : ClippingCube (carrierDimension size) → ℝ)
    (J : Set (ClippingCube m))
    (hind : ∀ z, z ∈ J → cubeTranslation (logicalColumnPoint column i) z ∉ J) :
    uniformCubeMean (fun x => (fourierProject (carrierDefectClass size column i) F x) ^ 2) ≤
      2 * uniformCubeMean (fun x => if C.syndrome x ∉ J then
        (fourierProject (carrierDefectClass size column i) F x) ^ 2 else 0) := by
  apply C.projected_physical_observability _ F (logicalColumnPoint column i) J hind
  intro U hU S hS T hT
  rw [hsupport, hsupport]
  exact carrier_defective_toggle_exclusion size column hsize i S T hS hT U
    ((character_ne_one_iff_orientation column U i).mp hU)

theorem actual_carrier_cross_conditional_zero {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (hsize : ∀ i b, 0 < size i b)
    (C : WalshCodeMap (carrierDimension size) m)
    (hsupport : ∀ s, C.support s = carrierSupport size column s)
    (i j : Fin p) (hij : i ≠ j) (F : ClippingCube (carrierDimension size) → ℝ)
    (z : ClippingCube m) :
    C.fiberMean (fun x => fourierProject (carrierDefectClass size column i) F x *
      fourierProject (carrierDefectClass size column j) F x) z = 0 := by
  apply C.conditional_projected_product_zero
  intro U S hS T hT
  rw [hsupport, hsupport]
  exact carrier_different_defect_exclusion size column hsize i j hij S T hS hT U

/-- Full factor-two observability of the actual odd downward/code residual.
The exclusion of even carrier-free complete transversals is proved above,
rather than assumed as a spectral premise. -/
theorem actual_carrier_odd_observability {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (hsize : ∀ i b, 0 < size i b)
    (heven : ∀ i b, Even (size i b))
    (C : WalshCodeMap (carrierDimension size) m)
    (hsupport : ∀ s, C.support s = carrierSupport size column s)
    (F : ClippingCube (carrierDimension size) → ℝ) (J : Set (ClippingCube m))
    (hind : ∀ i z, z ∈ J → cubeTranslation (logicalColumnPoint column i) z ∉ J) :
    uniformCubeMean (fun x =>
      (fourierProject (carrierOddDownwardSupports size column) F x - C.project F x) ^ 2) ≤
      2 * uniformCubeMean (fun x => if C.syndrome x ∉ J then
        (fourierProject (carrierOddDownwardSupports size column) F x - C.project F x) ^ 2 else 0) := by
  let A := fun i => fourierProject (carrierDefectClass size column i) F
  have hcross : ∀ i j, i ≠ j → ∀ z,
      C.fiberMean (fun x => A i x * A j x) z = 0 := by
    intro i j hij z
    exact actual_carrier_cross_conditional_zero size column hsize C hsupport i j hij F z
  have hcodes : C.supports = carrierCodeSupports size column := by
    unfold WalshCodeMap.supports carrierCodeSupports
    congr 1
    funext s
    exact hsupport s
  have hsum (x : ClippingCube (carrierDimension size)) :
      (∑ i, A i x) = fourierProject (carrierOddDownwardSupports size column) F x - C.project F x := by
    rw [C.project_eq_fourierProject, hcodes]
    exact carrierDefect_projection_sum size column hsize heven F x
  have hbound := Finset.sum_le_sum fun i (_ : i ∈ Finset.univ) =>
    actual_carrier_component_observability size column hsize C hsupport i F J (hind i)
  have hleft := C.physical_sum_squared A hcross
  have hright := C.physical_restricted_sum_squared A J hcross
  simp_rw [hsum] at hleft hright
  rw [hleft, hright, Finset.mul_sum]
  exact hbound

end NeuralGeneralization.OnlineLowerGeometry
