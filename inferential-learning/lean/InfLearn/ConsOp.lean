import InfLearn.Prelude

/-!
# Consequence operators (Tarski closure operators) on an arbitrary sentence type

This file is the generic, language-independent layer of the shared foundation.

* `ConsOp S` : a bundled closure operator on `Set S` (extensive, monotone, idempotent).
  This is Tarski's notion of a *deductive system* (T6 Def. 1.1) and the closure-operator
  reading of a consequence relation (T2 §1, item 2).  It is *not* assumed finitary.
* `ConsOp.Finitary`, `ConsOp.Coherent`, `ConsOp.IsClosed`, `ConsOp.Fix`.
* `ConsOp.trivial S` : the trivial operator `X ↦ univ` (T2's `C_Fm`).
* `ConsOp.id S` : the identity operator `X ↦ X`.
* `ConsOp.ofSat sat` : the semantic operator `Th ∘ Mod` of a satisfaction relation
  `sat : M → S → Prop` (T6 Fact 1.2).
* `C ≤ D` : pointwise inclusion (`∀ X, C X ⊆ D X`); `ConsOp S` is a partial order.
  The paper's "`C ⊇ C₂`" is written `Cn2 ≤ C`.
* `ConsOp.toClosureOperator` / `ConsOp.ofClosureOperator` : conversion to and from
  Mathlib's `ClosureOperator (Set S)`, so Mathlib's lemmas are available when wanted.

A `ConsOp` is applied like a function: `C X : Set S` (via `CoeFun`; it unfolds to
`C.toFun X`).
-/

namespace InfLearn

universe u v

/-- A (Tarski) consequence operator, i.e. a closure operator on `Set S`:
extensive, monotone and idempotent.  No finitarity is assumed. -/
structure ConsOp (S : Type u) where
  /-- The underlying map `X ↦ C X`. -/
  toFun : Set S → Set S
  /-- Extensive (reflexivity): `X ⊆ C X`. -/
  extensive : ∀ X, X ⊆ toFun X
  /-- Monotone (weakening): `X ⊆ Y → C X ⊆ C Y`. -/
  monotone : ∀ ⦃X Y : Set S⦄, X ⊆ Y → toFun X ⊆ toFun Y
  /-- Idempotent (cut): `C (C X) = C X`. -/
  idempotent : ∀ X, toFun (toFun X) = toFun X

namespace ConsOp

variable {S : Type u}

instance : CoeFun (ConsOp S) (fun _ => Set S → Set S) := ⟨ConsOp.toFun⟩

/-- Smart constructor taking idempotence in the weaker form `C (C X) ⊆ C X`
(the reverse inclusion follows from extensivity). -/
def mk' (f : Set S → Set S) (ext : ∀ X, X ⊆ f X) (mono : ∀ ⦃X Y : Set S⦄, X ⊆ Y → f X ⊆ f Y)
    (idem : ∀ X, f (f X) ⊆ f X) : ConsOp S where
  toFun := f
  extensive := ext
  monotone := mono
  idempotent X := Set.Subset.antisymm (idem X) (ext (f X))

@[simp] theorem mk'_apply (f : Set S → Set S) (ext mono idem) (X : Set S) :
    (mk' f ext mono idem) X = f X := rfl

@[simp] theorem coe_mk (f : Set S → Set S) (ext mono idem) (X : Set S) :
    (ConsOp.mk f ext mono idem) X = f X := rfl

@[ext] theorem ext {C D : ConsOp S} (h : ∀ X, C X = D X) : C = D := by
  cases C; cases D
  congr
  funext X
  exact h X

variable (C D E : ConsOp S)

/-! ### Basic lemmas -/

theorem subset_apply (X : Set S) : X ⊆ C X := C.extensive X

theorem mem_apply_of_mem {X : Set S} {φ : S} (h : φ ∈ X) : φ ∈ C X := C.extensive X h

theorem mono {X Y : Set S} (h : X ⊆ Y) : C X ⊆ C Y := C.monotone h

theorem monotone' : Monotone C.toFun := fun _ _ h => C.monotone h

@[simp] theorem idem (X : Set S) : C (C X) = C X := C.idempotent X

/-- `Y ⊆ C X ↔ C Y ⊆ C X` (the characteristic property of closure operators). -/
theorem subset_apply_iff {X Y : Set S} : Y ⊆ C X ↔ C Y ⊆ C X :=
  ⟨fun h => (C.mono h).trans (C.idem X).subset, fun h => (C.subset_apply Y).trans h⟩

/-- Cut / transitivity: if everything in `Y` follows from `X`, whatever follows from `Y`
follows from `X`. -/
theorem apply_subset_of_subset {X Y : Set S} (h : Y ⊆ C X) : C Y ⊆ C X :=
  C.subset_apply_iff.1 h

theorem mem_trans {X Y : Set S} {φ : S} (hY : Y ⊆ C X) (hφ : φ ∈ C Y) : φ ∈ C X :=
  C.apply_subset_of_subset hY hφ

/-- Cut with one extra premise: `φ ∈ C X` and `ψ ∈ C (insert φ X)` give `ψ ∈ C X`. -/
theorem cut {X : Set S} {φ ψ : S} (hφ : φ ∈ C X) (hψ : ψ ∈ C (insert φ X)) : ψ ∈ C X := by
  refine C.mem_trans ?_ hψ
  intro x hx
  rcases hx with rfl | hx
  · exact hφ
  · exact C.mem_apply_of_mem hx

theorem apply_union_apply (X Y : Set S) : C (C X ∪ Y) = C (X ∪ Y) := by
  apply Set.Subset.antisymm
  · apply C.apply_subset_of_subset
    exact Set.union_subset (C.mono Set.subset_union_left)
      ((Set.subset_union_right).trans (C.subset_apply _))
  · exact C.mono (Set.union_subset_union_left _ (C.subset_apply X))

theorem apply_empty_subset (X : Set S) : C ∅ ⊆ C X := C.mono (Set.empty_subset X)

/-! ### Closed sets, fixed points, coherence, finitarity -/

/-- `T` is `C`-closed (a `C`-theory): `C T ⊆ T` (equivalently `C T = T`). -/
def IsClosed (T : Set S) : Prop := C T ⊆ T

theorem isClosed_iff_eq {T : Set S} : C.IsClosed T ↔ C T = T :=
  ⟨fun h => Set.Subset.antisymm h (C.subset_apply T), fun h => h.subset⟩

theorem isClosed_apply (X : Set S) : C.IsClosed (C X) := (C.idem X).subset

/-- The set of fixed points (closed sets / theories) of `C`. -/
def Fix : Set (Set S) := {T | C T = T}

theorem mem_Fix_iff {T : Set S} : T ∈ C.Fix ↔ C.IsClosed T := C.isClosed_iff_eq.symm

/-- Leastness: `C X` is contained in every closed superset of `X`. -/
theorem apply_subset_of_isClosed {X T : Set S} (hXT : X ⊆ T) (hT : C.IsClosed T) : C X ⊆ T :=
  (C.mono hXT).trans hT

/-- A closure operator is the intersection of its closed supersets. -/
theorem apply_eq_sInter (X : Set S) : C X = ⋂₀ {T | X ⊆ T ∧ C.IsClosed T} := by
  apply Set.Subset.antisymm
  · exact Set.subset_sInter fun T hT => C.apply_subset_of_isClosed hT.1 hT.2
  · exact Set.sInter_subset_of_mem ⟨C.subset_apply X, C.isClosed_apply X⟩

/-- `X` is `C`-coherent (non-trivial) if `C X ≠ univ` (T6 Def. 1.1; T2 §1 for languages
without `⊥`).  For languages with `⊥` see `InfLearn.Consistent`. -/
def Coherent (X : Set S) : Prop := C X ≠ Set.univ

/-- `C` is finitary: whatever follows from `X` follows from a finite subset of `X`. -/
def Finitary : Prop := ∀ (X : Set S) (φ : S), φ ∈ C X → ∃ X₀ : Finset S, ↑X₀ ⊆ X ∧ φ ∈ C ↑X₀

/-- Equivalent formulation of finitarity with `Set.Finite`. -/
theorem finitary_iff_set : C.Finitary ↔
    ∀ (X : Set S) (φ : S), φ ∈ C X → ∃ X₀ : Set S, X₀ ⊆ X ∧ X₀.Finite ∧ φ ∈ C X₀ := by
  constructor
  · intro h X φ hφ
    obtain ⟨X₀, h1, h2⟩ := h X φ hφ
    exact ⟨↑X₀, h1, X₀.finite_toSet, h2⟩
  · intro h X φ hφ
    obtain ⟨X₀, h1, h2, h3⟩ := h X φ hφ
    refine ⟨h2.toFinset, ?_, ?_⟩
    · simpa using h1
    · simpa using h3

/-! ### Order -/

/-- Pointwise order: `C ≤ D` iff `C X ⊆ D X` for every `X` (`D` is an extension of `C`). -/
instance : LE (ConsOp S) := ⟨fun C D => ∀ X, C X ⊆ D X⟩

theorem le_def {C D : ConsOp S} : C ≤ D ↔ ∀ X, C X ⊆ D X := Iff.rfl

instance : PartialOrder (ConsOp S) where
  le_refl _ _ := subset_rfl
  le_trans _ _ _ h₁ h₂ X := (h₁ X).trans (h₂ X)
  le_antisymm _ _ h₁ h₂ := ext fun X => Set.Subset.antisymm (h₁ X) (h₂ X)

/-! ### Examples -/

variable (S) in
/-- The trivial (inconsistent) operator `X ↦ univ` (T2's `C_Fm`). -/
def trivial : ConsOp S where
  toFun _ := Set.univ
  extensive _ := Set.subset_univ _
  monotone _ _ _ := subset_rfl
  idempotent _ := rfl

@[simp] theorem trivial_apply (X : Set S) : trivial S X = Set.univ := rfl

theorem le_trivial : C ≤ trivial S := fun _ => Set.subset_univ _

variable (S) in
/-- The identity operator `X ↦ X` (the least consequence operator). -/
protected def id : ConsOp S where
  toFun X := X
  extensive _ := subset_rfl
  monotone _ _ h := h
  idempotent _ := rfl

@[simp] theorem id_apply (X : Set S) : ConsOp.id S X = X := rfl

theorem id_le : ConsOp.id S ≤ C := fun X => C.subset_apply X

/-! ### Semantic operators `Th ∘ Mod` (T6 §1.1) -/

section Sat

variable {M : Type v} (sat : M → S → Prop)

/-- `Mod(Σ)`: the models satisfying every sentence of `Σ`. -/
def Mod (Γ : Set S) : Set M := {m | ∀ φ ∈ Γ, sat m φ}

/-- `Th(K)`: the sentences true in every model of `K`. -/
def Th (K : Set M) : Set S := {φ | ∀ m ∈ K, sat m φ}

/-- The Galois connection `K ⊆ Mod Σ ↔ Σ ⊆ Th K` (T6 Fact 1.2). -/
theorem subset_Mod_iff_subset_Th (Γ : Set S) (K : Set M) :
    K ⊆ Mod sat Γ ↔ Γ ⊆ Th sat K :=
  ⟨fun h _ hφ _ hm => h hm _ hφ, fun h _ hm _ hφ => h hφ _ hm⟩

/-- The semantic consequence operator `Th ∘ Mod` of a satisfaction relation. -/
def ofSat : ConsOp S where
  toFun X := Th sat (Mod sat X)
  extensive _ _ hφ _ hm := hm _ hφ
  monotone _ _ hXY _ hφ m hm := hφ m fun ψ hψ => hm ψ (hXY hψ)
  idempotent X := by
    apply Set.Subset.antisymm
    · intro φ hφ m hm
      exact hφ m fun ψ hψ => hψ m hm
    · intro φ hφ m hm
      exact hm φ hφ

theorem mem_ofSat {X : Set S} {φ : S} :
    φ ∈ ofSat sat X ↔ ∀ m, (∀ ψ ∈ X, sat m ψ) → sat m φ := Iff.rfl

end Sat

/-! ### Conversion to and from Mathlib's `ClosureOperator` -/

/-- View a `ConsOp S` as a Mathlib `ClosureOperator (Set S)`. -/
def toClosureOperator : ClosureOperator (Set S) where
  toFun := C
  monotone' _ _ h := C.monotone h
  le_closure' := C.extensive
  idempotent' := C.idempotent

@[simp] theorem toClosureOperator_apply (X : Set S) : C.toClosureOperator X = C X := rfl

/-- View a Mathlib `ClosureOperator (Set S)` as a `ConsOp S`. -/
def ofClosureOperator (c : ClosureOperator (Set S)) : ConsOp S where
  toFun := c
  extensive := c.le_closure
  monotone _ _ h := c.monotone h
  idempotent := c.idempotent

@[simp] theorem ofClosureOperator_apply (c : ClosureOperator (Set S)) (X : Set S) :
    ofClosureOperator c X = c X := rfl

end ConsOp

end InfLearn
