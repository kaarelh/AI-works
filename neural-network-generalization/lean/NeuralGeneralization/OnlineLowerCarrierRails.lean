import NeuralGeneralization.OnlineLowerReluRailGeometry
import NeuralGeneralization.OnlineLowerRailSystem

/-! # A shared physical carrier and even transversal rails

The carrier is an actual additional Boolean input coordinate. Its column is
empty, so every affine Walsh support contains it and has odd degree when
the rails have even sizes. All remaining coordinates are the existing
explicit disjoint rail system, shifted by `Fin.succ`.
-/

noncomputable section
open scoped BigOperators Classical symmDiff
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower OnlineLowerRelu OnlineLowerGeometry ConcreteModel

abbrev carrierDimension {p : ℕ} (size : Fin p → Bool → ℕ) : ℕ := railDimension size + 1

def shiftPhysical (d : ℕ) : Fin d ↪ Fin (d + 1) :=
  ⟨Fin.succ, Fin.succ_injective _⟩

def carrierBase {p : ℕ} (size : Fin p → Bool → ℕ) : Finset (Fin (carrierDimension size)) :=
  insert 0 ((physicalBase size).map (shiftPhysical _))

def carrierColumn {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) : Fin (carrierDimension size) → Finset (Fin m) :=
  Fin.cases ∅ (physicalColumn size column)

def carrierSupport {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (s : Finset (Fin m)) :
    Finset (Fin (carrierDimension size)) :=
  generatedSupport (carrierBase size) (coordinateGenerator (carrierColumn size column)) s

@[simp] theorem carrierColumn_zero {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) : carrierColumn size column 0 = ∅ := rfl

@[simp] theorem carrierColumn_succ {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (j : Fin (railDimension size)) :
    carrierColumn size column j.succ = physicalColumn size column j := rfl

@[simp] theorem zero_mem_carrierSupport {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (s : Finset (Fin m)) :
    (0 : Fin (carrierDimension size)) ∈ carrierSupport size column s := by
  induction s using Finset.induction_on with
  | empty => simp [carrierSupport, carrierBase]
  | @insert i s hi ih =>
    simp only [carrierSupport, generatedSupport_insert _ _ _ _ hi,
      Finset.mem_symmDiff, mem_coordinateGenerator, carrierColumn_zero, Finset.notMem_empty,
      false_and, not_false_eq_true, and_true, false_or]
    exact ih

@[simp] theorem succ_mem_carrierSupport {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (s : Finset (Fin m)) (j : Fin (railDimension size)) :
    j.succ ∈ carrierSupport size column s ↔ j ∈ generatedSupport (physicalBase size)
      (coordinateGenerator (physicalColumn size column)) s := by
  induction s using Finset.induction_on with
  | empty => simp [carrierSupport, carrierBase, shiftPhysical]
  | @insert i s hi ih =>
    unfold carrierSupport at *
    rw [generatedSupport_insert _ _ _ _ hi, generatedSupport_insert _ _ _ _ hi]
    simp only [Finset.mem_symmDiff, mem_coordinateGenerator, carrierColumn_succ, ih]

theorem carrierSupport_eq {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (s : Finset (Fin m)) :
    carrierSupport size column s = insert 0
      ((generatedSupport (physicalBase size) (coordinateGenerator (physicalColumn size column)) s).map
        (shiftPhysical _)) := by
  ext j
  refine Fin.cases ?_ (fun j => ?_) j
  · simp
  · simp [shiftPhysical]

@[simp] theorem carrierSupport_card {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (s : Finset (Fin m)) :
    (carrierSupport size column s).card = 1 + ∑ i, size i (railOrientation column s i) := by
  rw [carrierSupport_eq, Finset.card_insert_of_notMem]
  · rw [Finset.card_map, physical_generatedSupport_card]
    omega
  · simp [shiftPhysical]

def carrierPrivate {p m : ℕ} (size : Fin p → Bool → ℕ)
    (privatePair : Fin m → Fin p) (hsize : ∀ i b, 0 < size i b) :
    Fin m → Fin (carrierDimension size) :=
  fun i => (railIndex size ⟨privatePair i, false, ⟨0, hsize _ _⟩⟩).succ

@[simp] theorem carrierColumn_private {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (privatePair : Fin m → Fin p)
    (hsize : ∀ i b, 0 < size i b) (hprivate : ∀ i, column (privatePair i) = {i}) (i : Fin m) :
    carrierColumn size column (carrierPrivate size privatePair hsize i) = {i} := by
  simp [carrierPrivate, carrierColumn, physicalColumn, hprivate]

def carrierCode {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (privatePair : Fin m → Fin p)
    (hsize : ∀ i b, 0 < size i b) (hprivate : ∀ i, column (privatePair i) = {i}) :
    WalshCodeMap (carrierDimension size) m :=
  coordinateWalshCode (carrierBase size) (carrierColumn size column)
    (carrierPrivate size privatePair hsize) (carrierColumn_private size column privatePair hsize hprivate)

@[simp] theorem carrierCode_support {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (privatePair : Fin m → Fin p)
    (hsize : ∀ i b, 0 < size i b) (hprivate : ∀ i, column (privatePair i) = {i})
    (s : Finset (Fin m)) :
    (carrierCode size column privatePair hsize hprivate).support s = carrierSupport size column s := rfl



/-- Every independent rail orientation, before restricting to a column code. -/
def carrierTransversal {p : ℕ} (size : Fin p → Bool → ℕ) (b : Fin p → Bool) :
    Finset (Fin (carrierDimension size)) :=
  insert 0 ((Finset.univ.biUnion (fun i => physicalRail size i (b i))).map (shiftPhysical _))

@[simp] theorem zero_mem_carrierTransversal {p : ℕ} (size : Fin p → Bool → ℕ)
    (b : Fin p → Bool) : (0 : Fin (carrierDimension size)) ∈ carrierTransversal size b := by
  simp [carrierTransversal]

@[simp] theorem succ_mem_carrierTransversal {p : ℕ} (size : Fin p → Bool → ℕ)
    (b : Fin p → Bool) (j : Fin (railDimension size)) :
    j.succ ∈ carrierTransversal size b ↔
      ((railIndex size).symm j).2.1 = b (((railIndex size).symm j).1) := by
  simp only [carrierTransversal, Finset.mem_insert, Finset.mem_map, shiftPhysical,
    Function.Embedding.coeFn_mk, Fin.succ_ne_zero, false_or, Fin.succ_inj,
    exists_eq_right, Finset.mem_biUnion, Finset.mem_univ, true_and, mem_physicalRail]
  constructor
  · rintro ⟨i,hi,hb⟩
    simpa [hi] using hb
  · intro h
    exact ⟨((railIndex size).symm j).1,rfl,h⟩

theorem carrierSupport_eq_transversal {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (s : Finset (Fin m)) :
    carrierSupport size column s = carrierTransversal size (railOrientation column s) := by
  rw [carrierSupport_eq, physical_generatedSupport_eq]
  rfl

def changedRails {p : ℕ} (s t : Fin p → Bool) : Finset (Fin p) :=
  Finset.univ.filter (fun i => s i ≠ t i)

theorem carrierTransversal_difference {p : ℕ} (size : Fin p → Bool → ℕ)
    (s t : Fin p → Bool) :
    carrierTransversal size t \ carrierTransversal size s =
      (changedRails s t).biUnion (fun i => (physicalRail size i (t i)).map (shiftPhysical _)) := by
  ext j
  refine Fin.cases ?_ (fun j => ?_) j
  · simp [carrierTransversal, shiftPhysical]
  · simp only [Finset.mem_sdiff, succ_mem_carrierTransversal, Finset.mem_biUnion,
      changedRails, Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_map,
      shiftPhysical, Function.Embedding.coeFn_mk, Fin.succ_inj, exists_eq_right, mem_physicalRail]
    constructor
    · rintro ⟨ht,hs⟩
      refine ⟨((railIndex size).symm j).1, ?_, rfl, ht⟩
      intro he
      exact hs (ht.trans he.symm)
    · rintro ⟨i,hst,hi,ht⟩
      refine ⟨by simpa [hi] using ht, ?_⟩
      intro hs
      apply hst
      simpa [hi] using hs.symm.trans ht

theorem carrierTransversal_difference_card {p : ℕ} (size : Fin p → Bool → ℕ)
    (s t : Fin p → Bool) :
    (carrierTransversal size t \ carrierTransversal size s).card =
      ∑ i ∈ changedRails s t, size i (t i) := by
  rw [carrierTransversal_difference, Finset.card_biUnion]
  · simp
  · intro i hi j hj hij
    change Disjoint ((physicalRail size i (t i)).map (shiftPhysical _))
      ((physicalRail size j (t j)).map (shiftPhysical _))
    rw [Finset.disjoint_left]
    intro z hz hz'
    obtain ⟨a,ha,rfl⟩ := Finset.mem_map.mp hz
    obtain ⟨b,hb,he⟩ := Finset.mem_map.mp hz'
    have hab : b=a := (shiftPhysical _).injective he
    subst b
    exact (Finset.disjoint_left.mp (physicalRail_disjoint size (Or.inl hij))) ha hb

/-- Switching q rail choices creates at least qR new physical coordinates. -/
theorem carrierTransversal_difference_card_lower {p R : ℕ}
    (size : Fin p → Bool → ℕ) (hsize : ∀ i b, R ≤ size i b) (s t : Fin p → Bool) :
    (changedRails s t).card * R ≤
      (carrierTransversal size t \ carrierTransversal size s).card := by
  rw [carrierTransversal_difference_card]
  calc
    _ = ∑ _i ∈ changedRails s t, R := by simp
    _ ≤ _ := Finset.sum_le_sum (fun i _ => hsize i (t i))

end NeuralGeneralization.OnlineLowerTanh
