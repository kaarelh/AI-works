import InfLearn.ConsOp

/-!
# Classical propositional logic: syntax, semantics, substitutions, `C₂`

Shared foundation for the propositional parts of T1–T7.

## Syntax
* `Formula` : atoms `var n` (`n : ℕ`, the paper's `p₀, p₁, …`), constants `bot`, `top`,
  and connectives `neg`, `and`, `or`, `imp`.
* `Formula.atoms`, `Formula.size`, `Formula.InFrag` (membership in a connective fragment,
  e.g. the `{∧,∨}` fragment of T2 Prop 3.2 or the pure `{→}` fragment).

## Semantics (Boolean valuations)
* `Valuation := ℕ → Bool`, `Formula.eval φ v : Bool`.
* `Satisfies v X`, `Satisfiable X`, `Tautology φ`, `Taut`, `Equiv2 φ ψ` (`≡₂`),
  `SemCons X φ` (`X ⊨ φ`, classical consequence).

## Substitutions
* `Subst := ℕ → Formula`, `Formula.subst s φ` (homomorphic extension), `Subst.comp`.
* Key lemma `Formula.eval_subst : (φ.subst s).eval v = φ.eval (fun n => (s n).eval v)`.
* `Subst.ofVal v` : the substitution `p ↦ top / bot` along `v` (T2 Thm 3.1's `σ_v`), with
  `eval_subst_ofVal : (φ.subst (Subst.ofVal v)).eval u = φ.eval v`.

## Consequence operators on formulas
* `Structural C` : `∀ s X, subst s '' C X ⊆ C (subst s '' X)` (T2 §1).
* `Consistent C X` : `bot ∉ C X` (T2's "coherent" in a language with `⊥`).
* `Cn2 : ConsOp Formula` : classical consequence `X ↦ {φ | SemCons X φ}` (T2's `𝐂₂`),
  with `Cn2_structural`, `Cn2_empty : Cn2 ∅ = Taut`, `Cn2_consistent_iff`, …
* `compactness`, `SemCons.exists_finset`, `Cn2_finitary` : propositional compactness.
* `ConsOp.trivial Formula` (T2's `C_Fm`) with `trivial_structural`.
-/

namespace InfLearn

/-- Propositional formulas over the atoms `p₀, p₁, …` (indexed by `ℕ`). -/
inductive Formula : Type
  /-- The atom `pₙ`. -/
  | var : ℕ → Formula
  /-- Falsum `⊥`. -/
  | bot : Formula
  /-- Verum `⊤`. -/
  | top : Formula
  /-- Negation `¬φ`. -/
  | neg : Formula → Formula
  /-- Conjunction `φ ∧ ψ`. -/
  | and : Formula → Formula → Formula
  /-- Disjunction `φ ∨ ψ`. -/
  | or : Formula → Formula → Formula
  /-- Implication `φ → ψ`. -/
  | imp : Formula → Formula → Formula
  deriving DecidableEq, Repr, Inhabited

/-- A Boolean valuation of the atoms. -/
abbrev Valuation := ℕ → Bool

/-- A substitution: an assignment of a formula to every atom. -/
abbrev Subst := ℕ → Formula

namespace Formula

/-- Bi-implication, as a derived connective. -/
def iff (φ ψ : Formula) : Formula := and (imp φ ψ) (imp ψ φ)

/-! ### Syntactic measures -/

/-- The set of atoms occurring in a formula. -/
def atoms : Formula → Finset ℕ
  | var n => {n}
  | bot => ∅
  | top => ∅
  | neg a => atoms a
  | and a b => atoms a ∪ atoms b
  | or a b => atoms a ∪ atoms b
  | imp a b => atoms a ∪ atoms b

/-- Number of symbol occurrences. -/
def size : Formula → ℕ
  | var _ => 1
  | bot => 1
  | top => 1
  | neg a => size a + 1
  | and a b => size a + size b + 1
  | or a b => size a + size b + 1
  | imp a b => size a + size b + 1

theorem size_pos (φ : Formula) : 0 < φ.size := by
  cases φ <;> simp [size]

/-! ### Semantics -/

/-- Boolean evaluation of a formula under a valuation. -/
def eval : Formula → Valuation → Bool
  | var n, v => v n
  | bot, _ => false
  | top, _ => true
  | neg a, v => !(eval a v)
  | and a b, v => eval a v && eval b v
  | or a b, v => eval a v || eval b v
  | imp a b, v => !(eval a v) || eval b v

@[simp] theorem eval_var (n : ℕ) (v : Valuation) : (var n).eval v = v n := rfl
@[simp] theorem eval_bot (v : Valuation) : bot.eval v = false := rfl
@[simp] theorem eval_top (v : Valuation) : top.eval v = true := rfl
@[simp] theorem eval_neg (a : Formula) (v : Valuation) : (neg a).eval v = !(a.eval v) := rfl
@[simp] theorem eval_and (a b : Formula) (v : Valuation) :
    (and a b).eval v = (a.eval v && b.eval v) := rfl
@[simp] theorem eval_or (a b : Formula) (v : Valuation) :
    (or a b).eval v = (a.eval v || b.eval v) := rfl
@[simp] theorem eval_imp (a b : Formula) (v : Valuation) :
    (imp a b).eval v = (!(a.eval v) || b.eval v) := rfl
@[simp] theorem eval_iff (a b : Formula) (v : Valuation) :
    (iff a b).eval v = (a.eval v == b.eval v) := by
  cases ha : a.eval v <;> cases hb : b.eval v <;> simp [iff, ha, hb]

/-- `Prop`-level characterisations of evaluation (often more convenient than `Bool`). -/
theorem eval_neg_eq_true {a : Formula} {v : Valuation} :
    (neg a).eval v = true ↔ a.eval v = false := by simp
theorem eval_and_eq_true {a b : Formula} {v : Valuation} :
    (and a b).eval v = true ↔ a.eval v = true ∧ b.eval v = true := by simp
theorem eval_or_eq_true {a b : Formula} {v : Valuation} :
    (or a b).eval v = true ↔ a.eval v = true ∨ b.eval v = true := by simp
theorem eval_imp_eq_true {a b : Formula} {v : Valuation} :
    (imp a b).eval v = true ↔ (a.eval v = true → b.eval v = true) := by
  simp only [eval_imp]
  cases a.eval v <;> cases b.eval v <;> simp

/-- Evaluation depends only on the atoms that occur. -/
theorem eval_congr {φ : Formula} {v w : Valuation} (h : ∀ n ∈ φ.atoms, v n = w n) :
    φ.eval v = φ.eval w := by
  induction φ with
  | var n => simpa [atoms] using h n (by simp [atoms])
  | bot => rfl
  | top => rfl
  | neg a iha => simp [iha (fun n hn => h n (by simpa [atoms] using hn))]
  | and a b iha ihb =>
    simp [iha (fun n hn => h n (by simp [atoms, hn])), ihb (fun n hn => h n (by simp [atoms, hn]))]
  | or a b iha ihb =>
    simp [iha (fun n hn => h n (by simp [atoms, hn])), ihb (fun n hn => h n (by simp [atoms, hn]))]
  | imp a b iha ihb =>
    simp [iha (fun n hn => h n (by simp [atoms, hn])), ihb (fun n hn => h n (by simp [atoms, hn]))]

/-! ### Substitution -/

/-- Simultaneous substitution `φ ↦ σφ` (the endomorphism of the formula algebra
determined by `s`). -/
def subst (s : Subst) : Formula → Formula
  | var n => s n
  | bot => bot
  | top => top
  | neg a => neg (subst s a)
  | and a b => and (subst s a) (subst s b)
  | or a b => or (subst s a) (subst s b)
  | imp a b => imp (subst s a) (subst s b)

@[simp] theorem subst_var (s : Subst) (n : ℕ) : (var n).subst s = s n := rfl
@[simp] theorem subst_bot (s : Subst) : bot.subst s = bot := rfl
@[simp] theorem subst_top (s : Subst) : top.subst s = top := rfl
@[simp] theorem subst_neg (s : Subst) (a : Formula) : (neg a).subst s = neg (a.subst s) := rfl
@[simp] theorem subst_and (s : Subst) (a b : Formula) :
    (and a b).subst s = and (a.subst s) (b.subst s) := rfl
@[simp] theorem subst_or (s : Subst) (a b : Formula) :
    (or a b).subst s = or (a.subst s) (b.subst s) := rfl
@[simp] theorem subst_imp (s : Subst) (a b : Formula) :
    (imp a b).subst s = imp (a.subst s) (b.subst s) := rfl
@[simp] theorem subst_iff (s : Subst) (a b : Formula) :
    (iff a b).subst s = iff (a.subst s) (b.subst s) := rfl

/-- The identity substitution `var` acts trivially. -/
@[simp] theorem subst_id (φ : Formula) : φ.subst var = φ := by
  induction φ <;> simp_all

/-- Composition of substitutions: `(φ.subst t).subst s = φ.subst (Subst.comp s t)`. -/
theorem subst_subst (s t : Subst) (φ : Formula) :
    (φ.subst t).subst s = φ.subst (fun n => (t n).subst s) := by
  induction φ <;> simp_all

/-- Substitution depends only on the atoms that occur. -/
theorem subst_congr {φ : Formula} {s t : Subst} (h : ∀ n ∈ φ.atoms, s n = t n) :
    φ.subst s = φ.subst t := by
  induction φ with
  | var n => simpa [atoms] using h n (by simp [atoms])
  | bot => rfl
  | top => rfl
  | neg a iha => simp [iha (fun n hn => h n (by simpa [atoms] using hn))]
  | and a b iha ihb =>
    simp [iha (fun n hn => h n (by simp [atoms, hn])), ihb (fun n hn => h n (by simp [atoms, hn]))]
  | or a b iha ihb =>
    simp [iha (fun n hn => h n (by simp [atoms, hn])), ihb (fun n hn => h n (by simp [atoms, hn]))]
  | imp a b iha ihb =>
    simp [iha (fun n hn => h n (by simp [atoms, hn])), ihb (fun n hn => h n (by simp [atoms, hn]))]

/-- **Key lemma.** Evaluating a substitution instance = evaluating the original formula
under the valuation `n ↦ eval (s n) v`. -/
@[simp] theorem eval_subst (s : Subst) (φ : Formula) (v : Valuation) :
    (φ.subst s).eval v = φ.eval (fun n => (s n).eval v) := by
  induction φ <;> simp_all

theorem atoms_subst (s : Subst) (φ : Formula) :
    (φ.subst s).atoms = φ.atoms.biUnion (fun n => (s n).atoms) := by
  induction φ with
  | var n => simp [atoms, subst]
  | bot => simp [atoms, subst]
  | top => simp [atoms, subst]
  | neg a iha => simpa [atoms, subst] using iha
  | and a b iha ihb => simp [atoms, subst, iha, ihb, Finset.union_biUnion]
  | or a b iha ihb => simp [atoms, subst, iha, ihb, Finset.union_biUnion]
  | imp a b iha ihb => simp [atoms, subst, iha, ihb, Finset.union_biUnion]

/-! ### Connective fragments -/

/-- Connective symbols (used to describe fragments such as `{∧,∨}` or `{→}`). -/
inductive Conn : Type
  | bot | top | neg | and | or | imp
  deriving DecidableEq, Repr

/-- `φ.InFrag L` : every connective/constant occurring in `φ` belongs to `L`
(atoms are always allowed). -/
def InFrag (L : Set Conn) : Formula → Prop
  | var _ => True
  | bot => Conn.bot ∈ L
  | top => Conn.top ∈ L
  | neg a => Conn.neg ∈ L ∧ InFrag L a
  | and a b => Conn.and ∈ L ∧ InFrag L a ∧ InFrag L b
  | or a b => Conn.or ∈ L ∧ InFrag L a ∧ InFrag L b
  | imp a b => Conn.imp ∈ L ∧ InFrag L a ∧ InFrag L b

/-- Substituting fragment formulas into a fragment formula stays in the fragment. -/
theorem InFrag.subst {L : Set Conn} {s : Subst} (hs : ∀ n, (s n).InFrag L) {φ : Formula}
    (hφ : φ.InFrag L) : (φ.subst s).InFrag L := by
  induction φ with
  | var n => exact hs n
  | bot => exact hφ
  | top => exact hφ
  | neg a iha => exact ⟨hφ.1, iha hφ.2⟩
  | and a b iha ihb => exact ⟨hφ.1, iha hφ.2.1, ihb hφ.2.2⟩
  | or a b iha ihb => exact ⟨hφ.1, iha hφ.2.1, ihb hφ.2.2⟩
  | imp a b iha ihb => exact ⟨hφ.1, iha hφ.2.1, ihb hφ.2.2⟩

end Formula

open Formula

/-! ### Substitutions -/

namespace Subst

/-- The identity substitution. -/
def id : Subst := Formula.var

/-- Composition: `comp s t` first applies `t`, then `s`. -/
def comp (s t : Subst) : Subst := fun n => (t n).subst s

@[simp] theorem subst_comp (s t : Subst) (φ : Formula) :
    φ.subst (comp s t) = (φ.subst t).subst s := (subst_subst s t φ).symm

@[simp] theorem subst_id' (φ : Formula) : φ.subst Subst.id = φ := Formula.subst_id φ

/-- The substitution `σ_v` of T2 Thm 3.1: atoms true under `v` go to `top`, the others to
`bot`.  Every instance `σ_v φ` is variable-free and has constant value `φ.eval v`. -/
def ofVal (v : Valuation) : Subst := fun n => if v n then top else bot

@[simp] theorem eval_ofVal (v u : Valuation) (n : ℕ) : ((ofVal v) n).eval u = v n := by
  unfold ofVal; cases v n <;> simp

end Subst

/-- `(σ_v φ)` evaluates, under every valuation `u`, to `φ.eval v`. -/
@[simp] theorem eval_subst_ofVal (v u : Valuation) (φ : Formula) :
    (φ.subst (Subst.ofVal v)).eval u = φ.eval v := by
  simp

/-! ### Semantic notions -/

/-- `v ⊨ X`: `v` makes every formula of `X` true. -/
def Satisfies (v : Valuation) (X : Set Formula) : Prop := ∀ ψ ∈ X, ψ.eval v = true

/-- `X` has a (Boolean) model. -/
def Satisfiable (X : Set Formula) : Prop := ∃ v, Satisfies v X

/-- `φ` is a (classical) tautology. -/
def Tautology (φ : Formula) : Prop := ∀ v : Valuation, φ.eval v = true

/-- The set of tautologies. -/
def Taut : Set Formula := {φ | Tautology φ}

/-- Classical (Boolean) equivalence `φ ≡₂ ψ`. -/
def Equiv2 (φ ψ : Formula) : Prop := ∀ v : Valuation, φ.eval v = ψ.eval v

/-- Classical semantic consequence `X ⊨ φ`: every valuation satisfying `X` satisfies `φ`. -/
def SemCons (X : Set Formula) (φ : Formula) : Prop :=
  ∀ v : Valuation, Satisfies v X → φ.eval v = true

@[simp] theorem mem_Taut {φ : Formula} : φ ∈ Taut ↔ Tautology φ := Iff.rfl

theorem satisfies_mono {v : Valuation} {X Y : Set Formula} (h : X ⊆ Y) (hY : Satisfies v Y) :
    Satisfies v X := fun ψ hψ => hY ψ (h hψ)

@[simp] theorem satisfies_empty (v : Valuation) : Satisfies v ∅ := fun _ h => h.elim

@[simp] theorem satisfies_insert {v : Valuation} {φ : Formula} {X : Set Formula} :
    Satisfies v (insert φ X) ↔ φ.eval v = true ∧ Satisfies v X := by
  constructor
  · intro h; exact ⟨h φ (Set.mem_insert _ _), fun ψ hψ => h ψ (Set.mem_insert_of_mem _ hψ)⟩
  · rintro ⟨h1, h2⟩ ψ hψ
    rcases hψ with rfl | hψ
    · exact h1
    · exact h2 ψ hψ

@[simp] theorem satisfies_singleton {v : Valuation} {φ : Formula} :
    Satisfies v {φ} ↔ φ.eval v = true := by
  constructor
  · intro h; exact h φ rfl
  · intro h ψ hψ; rw [Set.mem_singleton_iff.1 hψ]; exact h

/-- `v ⊨ σX` iff `(n ↦ eval (σ n) v) ⊨ X`. -/
theorem satisfies_image_subst {v : Valuation} {s : Subst} {X : Set Formula} :
    Satisfies v (Formula.subst s '' X) ↔ Satisfies (fun n => (s n).eval v) X := by
  constructor
  · intro h ψ hψ
    rw [← eval_subst]
    exact h _ ⟨ψ, hψ, rfl⟩
  · rintro h _ ⟨ψ, hψ, rfl⟩
    rw [eval_subst]
    exact h ψ hψ

theorem Equiv2.refl (φ : Formula) : Equiv2 φ φ := fun _ => rfl
theorem Equiv2.symm {φ ψ : Formula} (h : Equiv2 φ ψ) : Equiv2 ψ φ := fun v => (h v).symm
theorem Equiv2.trans {φ ψ χ : Formula} (h₁ : Equiv2 φ ψ) (h₂ : Equiv2 ψ χ) : Equiv2 φ χ :=
  fun v => (h₁ v).trans (h₂ v)

/-- Classical equivalence is preserved by substitution. -/
theorem Equiv2.subst {φ ψ : Formula} (h : Equiv2 φ ψ) (s : Subst) :
    Equiv2 (φ.subst s) (ψ.subst s) := fun v => by simp only [eval_subst]; exact h _

/-- Tautologies are closed under substitution. -/
theorem Tautology.subst {φ : Formula} (h : Tautology φ) (s : Subst) : Tautology (φ.subst s) :=
  fun v => by rw [eval_subst]; exact h _

/-! ### Semantic consequence -/

namespace SemCons

theorem of_mem {X : Set Formula} {φ : Formula} (h : φ ∈ X) : SemCons X φ :=
  fun _ hv => hv φ h

theorem mono {X Y : Set Formula} {φ : Formula} (hXY : X ⊆ Y) (h : SemCons X φ) :
    SemCons Y φ := fun v hv => h v (satisfies_mono hXY hv)

/-- Cut: if `X ⊨ ψ` for all `ψ ∈ Y` and `Y ⊨ φ` then `X ⊨ φ`. -/
theorem trans {X Y : Set Formula} {φ : Formula} (hY : ∀ ψ ∈ Y, SemCons X ψ)
    (h : SemCons Y φ) : SemCons X φ := fun v hv => h v fun ψ hψ => hY ψ hψ v hv

/-- Structurality of classical consequence: `X ⊨ φ` implies `σX ⊨ σφ`. -/
theorem subst {X : Set Formula} {φ : Formula} (h : SemCons X φ) (s : Subst) :
    SemCons (Formula.subst s '' X) (φ.subst s) := by
  intro v hv
  rw [eval_subst]
  exact h _ (satisfies_image_subst.1 hv)

theorem of_tautology {X : Set Formula} {φ : Formula} (h : Tautology φ) : SemCons X φ :=
  fun v _ => h v

theorem empty_iff {φ : Formula} : SemCons ∅ φ ↔ Tautology φ :=
  ⟨fun h v => h v (satisfies_empty v), fun h => of_tautology h⟩

/-- Ex falso: if `X ⊨ ⊥` then `X ⊨ φ` for every `φ`. -/
theorem of_bot {X : Set Formula} (h : SemCons X bot) (φ : Formula) : SemCons X φ := by
  intro v hv
  have := h v hv
  simp at this

theorem bot_iff_not_satisfiable {X : Set Formula} : SemCons X bot ↔ ¬ Satisfiable X := by
  constructor
  · rintro h ⟨v, hv⟩
    simpa using h v hv
  · intro h v hv
    exact absurd ⟨v, hv⟩ h

/-- Deduction theorem (semantic form). -/
theorem imp_iff {X : Set Formula} {φ ψ : Formula} :
    SemCons X (imp φ ψ) ↔ SemCons (insert φ X) ψ := by
  constructor
  · intro h v hv
    rw [satisfies_insert] at hv
    have := h v hv.2
    rw [eval_imp_eq_true] at this
    exact this hv.1
  · intro h v hv
    rw [eval_imp_eq_true]
    intro hφ
    exact h v (satisfies_insert.2 ⟨hφ, hv⟩)

/-- Invariance under classical equivalence of the conclusion. -/
theorem congr_right {X : Set Formula} {φ ψ : Formula} (he : Equiv2 φ ψ) (h : SemCons X φ) :
    SemCons X ψ := fun v hv => (he v) ▸ h v hv

end SemCons

/-- A formula follows from a finite set of premises iff the corresponding implication from
their conjunction is a tautology; we record the useful direction-free form for `insert`. -/
theorem semCons_singleton_iff {φ ψ : Formula} : SemCons {φ} ψ ↔ Tautology (imp φ ψ) := by
  rw [← SemCons.empty_iff, SemCons.imp_iff]
  simp

/-! ### Structural consequence operators -/

/-- A consequence operator on formulas is **structural** (substitution-invariant) if
`σ C(X) ⊆ C(σ X)` for every substitution `σ` (T2 §1). -/
def Structural (C : ConsOp Formula) : Prop :=
  ∀ (s : Subst) (X : Set Formula), Formula.subst s '' C X ⊆ C (Formula.subst s '' X)

/-- Pointwise form of structurality: `φ ∈ C X → σφ ∈ C (σX)`. -/
theorem structural_iff {C : ConsOp Formula} :
    Structural C ↔ ∀ (s : Subst) (X : Set Formula) (φ : Formula),
      φ ∈ C X → φ.subst s ∈ C (Formula.subst s '' X) := by
  constructor
  · intro h s X φ hφ
    exact h s X ⟨φ, hφ, rfl⟩
  · rintro h s X _ ⟨φ, hφ, rfl⟩
    exact h s X φ hφ

theorem Structural.mem_subst {C : ConsOp Formula} (hC : Structural C) {X : Set Formula}
    {φ : Formula} (h : φ ∈ C X) (s : Subst) : φ.subst s ∈ C (Formula.subst s '' X) :=
  structural_iff.1 hC s X φ h

/-- The theorems `C ∅` of a structural operator are closed under substitution. -/
theorem Structural.subst_mem_empty {C : ConsOp Formula} (hC : Structural C) {φ : Formula}
    (h : φ ∈ C ∅) (s : Subst) : φ.subst s ∈ C ∅ := by
  simpa using hC.mem_subst h s

/-- `X` is `C`-consistent (T2's "coherent" in a language with `⊥`): `⊥ ∉ C X`. -/
def Consistent (C : ConsOp Formula) (X : Set Formula) : Prop := bot ∉ C X

/-! ### Classical consequence `C₂` -/

/-- Classical propositional consequence `𝐂₂ X = {φ | X ⊨ φ}` as a consequence operator. -/
def Cn2 : ConsOp Formula where
  toFun X := {φ | SemCons X φ}
  extensive _ _ h := SemCons.of_mem h
  monotone _ _ hXY _ h := SemCons.mono hXY h
  idempotent X := by
    apply Set.Subset.antisymm
    · intro φ h
      exact SemCons.trans (fun ψ hψ => hψ) h
    · intro φ h
      exact SemCons.of_mem h

@[simp] theorem mem_Cn2 {X : Set Formula} {φ : Formula} : φ ∈ Cn2 X ↔ SemCons X φ := Iff.rfl

theorem Cn2_apply (X : Set Formula) : Cn2 X = {φ | SemCons X φ} := rfl

/-- `C₂` is the semantic operator `Th ∘ Mod` of the Boolean valuations. -/
theorem Cn2_eq_ofSat : Cn2 = ConsOp.ofSat (fun (v : Valuation) (φ : Formula) => φ.eval v = true) :=
  ConsOp.ext fun _ => rfl

/-- `C₂` is structural. -/
theorem Cn2_structural : Structural Cn2 := by
  rintro s X _ ⟨φ, hφ, rfl⟩
  exact SemCons.subst hφ s

/-- The theorems of `C₂` are exactly the tautologies. -/
theorem Cn2_empty : Cn2 ∅ = Taut := by
  ext φ
  exact SemCons.empty_iff

theorem Taut_subset_Cn2 (X : Set Formula) : Taut ⊆ Cn2 X := by
  rw [← Cn2_empty]; exact Cn2.mono (Set.empty_subset X)

/-- `X` is `C₂`-consistent iff it is satisfiable. -/
theorem Cn2_consistent_iff {X : Set Formula} : Consistent Cn2 X ↔ Satisfiable X := by
  unfold Consistent
  rw [mem_Cn2, SemCons.bot_iff_not_satisfiable, not_not]

/-- `C₂ X` is everything iff `X ⊨ ⊥` iff `X` is unsatisfiable. -/
theorem Cn2_eq_univ_iff {X : Set Formula} : Cn2 X = Set.univ ↔ ¬ Satisfiable X := by
  constructor
  · intro h
    rw [← SemCons.bot_iff_not_satisfiable, ← mem_Cn2, h]
    trivial
  · intro h
    rw [← SemCons.bot_iff_not_satisfiable] at h
    exact Set.eq_univ_of_forall fun φ => SemCons.of_bot h φ

/-- For `C₂`, coherence (non-triviality) and consistency coincide. -/
theorem Cn2_coherent_iff_consistent {X : Set Formula} :
    Cn2.Coherent X ↔ Consistent Cn2 X := by
  rw [ConsOp.Coherent, Cn2_consistent_iff, Ne, Cn2_eq_univ_iff, not_not]

/-! ### Compactness: `C₂` is finitary -/

section Compactness

open Classical

/-- `X` is satisfiable by a valuation agreeing with `c` below `n`, finitely: every finite
subset of `X` has such a model. -/
private def GoodAt (X : Set Formula) (c : Valuation) (n : ℕ) : Prop :=
  ∀ F : Finset Formula, ↑F ⊆ X → ∃ v : Valuation, Satisfies v ↑F ∧ ∀ i < n, v i = c i

private theorem goodAt_extend {X : Set Formula} {c : Valuation} {n : ℕ} (h : GoodAt X c n) :
    GoodAt X (Function.update c n true) (n + 1) ∨ GoodAt X (Function.update c n false) (n + 1) := by
  by_contra hcon
  rw [not_or] at hcon
  obtain ⟨h1, h2⟩ := hcon
  simp only [GoodAt, not_forall, not_exists, not_and] at h1 h2
  obtain ⟨F₁, hF₁, hv₁⟩ := h1
  obtain ⟨F₂, hF₂, hv₂⟩ := h2
  obtain ⟨v, hv, hvc⟩ := h (F₁ ∪ F₂) (by rw [Finset.coe_union]; exact Set.union_subset hF₁ hF₂)
  have hs₁ : Satisfies v ↑F₁ := satisfies_mono (by simp) hv
  have hs₂ : Satisfies v ↑F₂ := satisfies_mono (by simp) hv
  have agree : ∀ b : Bool, v n = b → ∀ i < n + 1, v i = Function.update c n b i := by
    intro b hb i hi
    rcases Nat.lt_succ_iff_lt_or_eq.1 hi with hi | rfl
    · rw [Function.update_of_ne (Nat.ne_of_lt hi)]; exact hvc i hi
    · rw [Function.update_self]; exact hb
  cases hvn : v n
  · obtain ⟨i, hi, hne⟩ := hv₂ v hs₂
    exact hne (agree false hvn i hi)
  · obtain ⟨i, hi, hne⟩ := hv₁ v hs₁
    exact hne (agree true hvn i hi)

/-- The staged construction of a model. -/
private noncomputable def stage (X : Set Formula) : ℕ → Valuation
  | 0 => fun _ => false
  | n + 1 =>
    if GoodAt X (Function.update (stage X n) n true) (n + 1) then
      Function.update (stage X n) n true
    else Function.update (stage X n) n false

private theorem stage_good {X : Set Formula} (h0 : GoodAt X (fun _ => false) 0) (n : ℕ) :
    GoodAt X (stage X n) n := by
  induction n with
  | zero => exact h0
  | succ n ih =>
    simp only [stage]
    split_ifs with h
    · exact h
    · exact (goodAt_extend ih).resolve_left h

private theorem stage_stable (X : Set Formula) {i n m : ℕ} (hi : i < n) (hnm : n ≤ m) :
    stage X m i = stage X n i := by
  induction m, hnm using Nat.le_induction with
  | base => rfl
  | succ m hnm ih =>
    have hne : i ≠ m := by omega
    simp only [stage]
    split_ifs <;> rw [Function.update_of_ne hne, ih]

/-- **Compactness theorem** for classical propositional logic: a set of formulas is
satisfiable as soon as each of its finite subsets is. -/
theorem compactness {X : Set Formula}
    (h : ∀ F : Finset Formula, ↑F ⊆ X → Satisfiable ↑F) : Satisfiable X := by
  have h0 : GoodAt X (fun _ => false) 0 := by
    intro F hF
    obtain ⟨v, hv⟩ := h F hF
    exact ⟨v, hv, fun i hi => absurd hi (Nat.not_lt_zero i)⟩
  refine ⟨fun i => stage X (i + 1) i, ?_⟩
  intro φ hφ
  set N := φ.atoms.sup id + 1
  obtain ⟨w, hw, hwc⟩ := stage_good h0 N {φ} (by simpa using hφ)
  have hwφ : φ.eval w = true := hw φ (by simp)
  rw [← hwφ]
  apply eval_congr
  intro n hn
  have hnN : n < N := Nat.lt_succ_of_le (Finset.le_sup (f := id) hn)
  rw [hwc n hnN]
  exact (stage_stable X (i := n) (n := n + 1) (m := N) (Nat.lt_succ_self n) hnN).symm

/-- Finite-premise form of compactness. -/
theorem SemCons.exists_finset {X : Set Formula} {φ : Formula} (h : SemCons X φ) :
    ∃ F : Finset Formula, ↑F ⊆ X ∧ SemCons ↑F φ := by
  by_contra hcon
  simp only [not_exists, not_and] at hcon
  have hsat : Satisfiable (insert (neg φ) X) := by
    apply compactness
    intro G hG
    have hsub : (↑(G.erase (neg φ)) : Set Formula) ⊆ X := by
      intro x hx
      rw [Finset.coe_erase] at hx
      rcases hG hx.1 with h1 | h1
      · exact absurd h1 hx.2
      · exact h1
    have hnot := hcon (G.erase (neg φ)) hsub
    simp only [SemCons, not_forall] at hnot
    obtain ⟨v, hv, hφv⟩ := hnot
    refine ⟨v, fun ψ hψ => ?_⟩
    by_cases hψφ : ψ = neg φ
    · subst hψφ
      simpa using hφv
    · exact hv ψ (by rw [Finset.coe_erase]; exact ⟨hψ, hψφ⟩)
  obtain ⟨v, hv⟩ := hsat
  rw [satisfies_insert] at hv
  have := h v hv.2
  simp [this] at hv

theorem semCons_iff_exists_finset {X : Set Formula} {φ : Formula} :
    SemCons X φ ↔ ∃ F : Finset Formula, ↑F ⊆ X ∧ SemCons ↑F φ :=
  ⟨SemCons.exists_finset, fun ⟨_, hF, h⟩ => SemCons.mono hF h⟩

/-- `C₂` is finitary (by compactness). -/
theorem Cn2_finitary : Cn2.Finitary := fun _ _ h => SemCons.exists_finset h

end Compactness

/-! ### The trivial operator -/

/-- The trivial operator `C_Fm` is structural. -/
theorem trivial_structural : Structural (ConsOp.trivial Formula) :=
  fun _ _ _ _ => Set.mem_univ _

theorem trivial_not_consistent (X : Set Formula) : ¬ Consistent (ConsOp.trivial Formula) X :=
  fun h => h (Set.mem_univ _)

/-- The identity operator is structural. -/
theorem id_structural : Structural (ConsOp.id Formula) := fun _ _ => subset_rfl

end InfLearn
