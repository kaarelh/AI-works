import NeuralGeneralization.OnlineLowerPhysicalTeacher
import Mathlib.Data.Fintype.Sigma
import Mathlib.Data.Fintype.EquivFin
import Mathlib.Algebra.BigOperators.Fin

noncomputable section
open scoped BigOperators symmDiff
namespace NeuralGeneralization.OnlineLowerRelu

local instance : Std.Commutative Bool.xor := ⟨Bool.xor_comm⟩
local instance : Std.Associative Bool.xor := ⟨Bool.xor_assoc⟩

/-- Each physical input coordinate belongs to exactly one side of one rail pair. -/
abbrev RailCoord {p : ℕ} (size : Fin p → Bool → ℕ) :=
  (i : Fin p) × (b : Bool) × Fin (size i b)

def railDimension {p : ℕ} (size : Fin p → Bool → ℕ) : ℕ :=
  Fintype.card (RailCoord size)

def railIndex {p : ℕ} (size : Fin p → Bool → ℕ) :
    RailCoord size ≃ Fin (railDimension size) := Fintype.equivFin _

theorem railDimension_eq {p : ℕ} (size : Fin p → Bool → ℕ) :
    railDimension size = ∑ i, (size i false + size i true) := by
  simp [railDimension,RailCoord,Fintype.card_sigma,Fintype.sum_bool,add_comm]

def physicalRail {p : ℕ} (size : Fin p → Bool → ℕ) (i : Fin p) (b : Bool) :
    Finset (Fin (railDimension size)) :=
  Finset.univ.filter (fun j => ((railIndex size).symm j).1 = i ∧
    ((railIndex size).symm j).2.1 = b)

@[simp] theorem mem_physicalRail {p : ℕ} (size : Fin p → Bool → ℕ)
    (i : Fin p) (b : Bool) (j : Fin (railDimension size)) :
    j ∈ physicalRail size i b ↔
      ((railIndex size).symm j).1=i ∧ ((railIndex size).symm j).2.1=b := by
  simp [physicalRail]

def physicalBase {p : ℕ} (size : Fin p → Bool → ℕ) :
    Finset (Fin (railDimension size)) :=
  Finset.univ.filter (fun j => ((railIndex size).symm j).2.1=false)

def physicalColumn {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (j : Fin (railDimension size)) : Finset (Fin m) :=
  column (((railIndex size).symm j).1)

/-- The selected side is the parity of the logical columns containing the
currently selected logical coordinates. -/
def railOrientation {p m : ℕ} (column : Fin p → Finset (Fin m))
    (s : Finset (Fin m)) (i : Fin p) : Bool :=
  s.fold Bool.xor false (fun k => decide (k ∈ column i))

@[simp] theorem railOrientation_empty {p m : ℕ} (column : Fin p → Finset (Fin m))
    (i : Fin p) : railOrientation column ∅ i=false := by simp [railOrientation]

theorem railOrientation_insert {p m : ℕ} (column : Fin p → Finset (Fin m))
    (s : Finset (Fin m)) (k : Fin m) (hk : k∉s) (i : Fin p) :
    railOrientation column (insert k s) i =
      Bool.xor (decide (k∈column i)) (railOrientation column s i) := by
  simp [railOrientation,hk]

/-- The abstract symmetric-difference support is literally a transversal of
physical rails; no support-shape premise is introduced. -/
theorem physical_generatedSupport_mem {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (s : Finset (Fin m))
    (j : Fin (railDimension size)) :
    j ∈ generatedSupport (physicalBase size)
      (coordinateGenerator (physicalColumn size column)) s ↔
    ((railIndex size).symm j).2.1 =
      railOrientation column s (((railIndex size).symm j).1) := by
  classical
  induction s using Finset.induction_on with
  | empty => simp [physicalBase]
  | @insert k s hk ih =>
      rw [generatedSupport_insert _ _ _ _ hk,Finset.mem_symmDiff,
        mem_coordinateGenerator,ih,railOrientation_insert _ _ _ hk]
      unfold physicalColumn
      cases hside : ((railIndex size).symm j).2.1 <;>
        cases horient : railOrientation column s (((railIndex size).symm j).1) <;>
        by_cases hmem : k∈column (((railIndex size).symm j).1) <;>
        simp [hside,horient,hmem]


def railInclusion {p : ℕ} (size : Fin p → Bool → ℕ) (i : Fin p) (b : Bool) :
    Fin (size i b) ↪ Fin (railDimension size) where
  toFun k := railIndex size ⟨i,b,k⟩
  inj' := by
    intro k l h
    have hh := (railIndex size).injective h
    simpa only [Sigma.mk.inj_iff,heq_eq_eq,true_and] using hh

theorem physicalRail_eq_map {p : ℕ} (size : Fin p → Bool → ℕ) (i : Fin p) (b : Bool) :
    physicalRail size i b = Finset.univ.map (railInclusion size i b) := by
  classical
  ext j
  rw [mem_physicalRail]
  simp only [Finset.mem_map,Finset.mem_univ,true_and]
  constructor
  · intro h
    generalize he : (railIndex size).symm j = a at h
    rcases a with ⟨i',b',k⟩
    simp only [Sigma.fst,Sigma.snd] at h
    rcases h with ⟨rfl,rfl⟩
    refine ⟨k,?_⟩
    apply (railIndex size).symm.injective
    simp [railInclusion,he]
  · rintro ⟨k,rfl⟩
    change ((railIndex size).symm ((railIndex size) ⟨i,b,k⟩)).1=i ∧
      ((railIndex size).symm ((railIndex size) ⟨i,b,k⟩)).2.1=b
    rw [Equiv.symm_apply_apply]
    exact ⟨rfl,rfl⟩

@[simp] theorem physicalRail_card {p : ℕ} (size : Fin p → Bool → ℕ)
    (i : Fin p) (b : Bool) : (physicalRail size i b).card = size i b := by
  rw [physicalRail_eq_map]
  simp

theorem physicalRail_disjoint {p : ℕ} (size : Fin p → Bool → ℕ)
    {i j : Fin p} {a b : Bool} (h : i≠j ∨ a≠b) :
    Disjoint (physicalRail size i a) (physicalRail size j b) := by
  rw [Finset.disjoint_left]
  intro k hk hl
  rw [mem_physicalRail] at hk hl
  rcases h with h | h
  · exact h (hk.1.symm.trans hl.1)
  · exact h (hk.2.symm.trans hl.2)

theorem physical_generatedSupport_eq {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (s : Finset (Fin m)) :
    generatedSupport (physicalBase size) (coordinateGenerator (physicalColumn size column)) s =
      Finset.univ.biUnion (fun i => physicalRail size i (railOrientation column s i)) := by
  classical
  ext j
  rw [physical_generatedSupport_mem]
  simp only [Finset.mem_biUnion,Finset.mem_univ,true_and,mem_physicalRail]
  constructor
  · intro h
    exact ⟨((railIndex size).symm j).1,rfl,h⟩
  · rintro ⟨i,hi,hb⟩
    simpa [hi] using hb

theorem physical_generatedSupport_card {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (s : Finset (Fin m)) :
    (generatedSupport (physicalBase size) (coordinateGenerator (physicalColumn size column)) s).card =
      ∑ i,size i (railOrientation column s i) := by
  classical
  rw [physical_generatedSupport_eq,Finset.card_biUnion]
  · simp
  · intro i hi j hj hij
    exact physicalRail_disjoint size (Or.inl hij)

theorem physical_generatedSupport_even {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (s : Finset (Fin m))
    (heven : ∀ i b,Even (size i b)) :
    Even (generatedSupport (physicalBase size)
      (coordinateGenerator (physicalColumn size column)) s).card := by
  rw [physical_generatedSupport_card]
  exact Finset.even_sum _ (fun i _ => heven i _)


def physicalPair {p : ℕ} (size : Fin p → Bool → ℕ) (i : Fin p) :
    Finset (Fin (railDimension size)) := physicalRail size i false ∪ physicalRail size i true

@[simp] theorem mem_physicalPair {p : ℕ} (size : Fin p → Bool → ℕ)
    (i : Fin p) (j : Fin (railDimension size)) :
    j∈physicalPair size i ↔ ((railIndex size).symm j).1=i := by
  simp only [physicalPair,Finset.mem_union,mem_physicalRail]
  cases ((railIndex size).symm j).2.1 <;> simp

theorem physical_toggle_mem {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (s : Finset (Fin m))
    (j : Fin (railDimension size)) :
    j∈physicalBase size ∆ generatedSupport (physicalBase size)
      (coordinateGenerator (physicalColumn size column)) s ↔
    railOrientation column s (((railIndex size).symm j).1)=true := by
  rw [Finset.mem_symmDiff,physical_generatedSupport_mem]
  simp only [physicalBase,Finset.mem_filter,Finset.mem_univ,true_and]
  cases ((railIndex size).symm j).2.1 <;>
    cases railOrientation column s (((railIndex size).symm j).1) <;> simp

theorem physical_toggle_pair {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (s : Finset (Fin m)) (i : Fin p) :
    (physicalBase size ∆ generatedSupport (physicalBase size)
      (coordinateGenerator (physicalColumn size column)) s) ∩ physicalPair size i =
    if railOrientation column s i then physicalPair size i else ∅ := by
  classical
  ext j
  rw [Finset.mem_inter,physical_toggle_mem,mem_physicalPair]
  by_cases hi : ((railIndex size).symm j).1=i
  · simp [hi]
    cases railOrientation column s i <;> simp [mem_physicalPair,hi]
  · simp [hi]
    cases railOrientation column s i <;> simp [mem_physicalPair,hi]

theorem subset_generatedSupport_side {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (s : Finset (Fin m))
    (S : Finset (Fin (railDimension size)))
    (hS : S⊆generatedSupport (physicalBase size)
      (coordinateGenerator (physicalColumn size column)) s)
    (i : Fin p) : S∩physicalPair size i ⊆ physicalRail size i (railOrientation column s i) := by
  intro j hj
  rw [Finset.mem_inter,mem_physicalPair] at hj
  have h := hS hj.1
  rw [physical_generatedSupport_mem] at h
  exact (mem_physicalRail _ _ _ _).mpr ⟨hj.2,by simpa [hj.2] using h⟩

/-- Two subsets, each lying on one side of a pair, cannot cover the full
pair by symmetric difference if one of them is a proper subset of its side. -/
theorem defective_pair_not_covered {p : ℕ} (size : Fin p → Bool → ℕ)
    (i : Fin p) (a b : Bool) (S T : Finset (Fin (railDimension size)))
    (hS : S∩physicalPair size i ⊆ physicalRail size i a)
    (hT : T∩physicalPair size i ⊆ physicalRail size i b)
    (hdef : ¬physicalRail size i a ⊆ S)
    (hpos : 0<size i (!a)) :
    ¬physicalPair size i ⊆ S∆T := by
  classical
  intro hcover
  by_cases hab : a=b
  · subst b
    let k := railInclusion size i (!a) ⟨0,hpos⟩
    have hk : k∈physicalRail size i (!a) := by rw [physicalRail_eq_map]; simp [k]
    have hpair : k∈physicalPair size i := (mem_physicalPair _ _ _).mpr
      ((mem_physicalRail _ _ _ _).mp hk).1
    have hnot (U : Finset (Fin (railDimension size)))
        (hU : U∩physicalPair size i ⊆ physicalRail size i a) : k∉U := by
      intro hku
      have hh := (mem_physicalRail _ _ _ _).mp (hU (Finset.mem_inter.mpr ⟨hku,hpair⟩))
      have hh' := (mem_physicalRail _ _ _ _).mp hk
      cases a <;> simp_all
    have hh := hcover hpair
    simp only [Finset.mem_symmDiff,hnot S hS,hnot T hT] at hh
    tauto
  · obtain ⟨k,hk,hks⟩ := Finset.not_subset.mp hdef
    have hpair : k∈physicalPair size i := (mem_physicalPair _ _ _).mpr
      ((mem_physicalRail _ _ _ _).mp hk).1
    have hh := hcover hpair
    rw [Finset.mem_symmDiff] at hh
    have hkt : k∈T := by tauto
    have ha := (mem_physicalRail _ _ _ _).mp hk
    have hb := (mem_physicalRail _ _ _ _).mp (hT (Finset.mem_inter.mpr ⟨hkt,hpair⟩))
    exact hab (ha.2.symm.trans hb.2)


def logicalColumnPoint {p m : ℕ} (column : Fin p → Finset (Fin m))
    (i : Fin p) : ClippingCube m := fun k => decide (k∉column i)

theorem character_orientation {p m : ℕ} (column : Fin p → Finset (Fin m))
    (s : Finset (Fin m)) (i : Fin p) :
    walshCharacter s (logicalColumnPoint column i) =
      if railOrientation column s i then (-1:ℝ) else 1 := by
  classical
  induction s using Finset.induction_on with
  | empty => simp [walshCharacter]
  | @insert k s hk ih =>
    rw [show walshCharacter (insert k s) (logicalColumnPoint column i) =
      cubeCoordinateSign (logicalColumnPoint column i k) * walshCharacter s (logicalColumnPoint column i)
      by simp [walshCharacter,hk],ih,railOrientation_insert _ _ _ hk]
    by_cases h:k∈column i <;> cases railOrientation column s i <;>
      norm_num [logicalColumnPoint,cubeCoordinateSign,h]

theorem character_ne_one_iff_orientation {p m : ℕ}
    (column : Fin p → Finset (Fin m)) (s : Finset (Fin m)) (i : Fin p) :
    walshCharacter s (logicalColumnPoint column i) ≠ 1 ↔ railOrientation column s i=true := by
  rw [character_orientation]
  cases railOrientation column s i <;> norm_num

end NeuralGeneralization.OnlineLowerRelu
