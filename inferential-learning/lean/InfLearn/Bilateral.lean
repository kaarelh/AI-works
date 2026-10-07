import InfLearn.Carnap

/-!
# Bilateral completeness: Scott relations, positions and valuations (T6 §2)

Formalization of T6 §2 ("Positions: bilateral completeness is Stone duality"):
Definition 2.1, Theorem 2.2 (bilateral Lindenbaum), Corollary 2.3 (strong bilateral
completeness), Theorem 2.4 (the duality, with both closure operators) and Theorem 2.6
(structural Scott relations; Lindenbaum bundles).

## Setting (T6 §2)
* `α` is an **arbitrary** type of "formulas" (T6: "Fix a set `Fm`"). Theorem 2.6 needs `Fm`
  to be a term algebra and is stated for the project's `Formula`.
* `Sequent α`: a finite multiple-conclusion sequent `Γ ▷ Δ` (`Γ, Δ : Finset α`).
* A valuation is an arbitrary map `v : α → Bool`. It need not be compositional.
  `v ⊨ Γ ▷ Δ` (`Sequent.Sat`) iff `v` falsifies some `γ ∈ Γ` or verifies some `δ ∈ Δ`.
* `Val S` (`= Mod S`, written `Val(⊢)` in Thm 2.2 and `Mod(S)` in Cor 2.3) and `Th V` form
  the Galois connection of T6 Fact 1.2. They agree with `ConsOp.Mod`/`ConsOp.Th`
  (`Val_eq_Mod`, `Th_eq_Th`).
* A *position* `[X : Y]` is a pair of arbitrary sets (`X Y : Set α`). It is `R`-incoherent
  (`Incoherent R X Y`) if some `Γ ▷ Δ ∈ R` has `Γ ⊆ X` and `Δ ⊆ Y`. `MaxCoherent R X Y`:
  coherent and maximal under componentwise inclusion.
* `IsScott R` (Def 2.1): closed under (Ov) `Γ ∩ Δ ≠ ∅ ⇒ Γ ▷ Δ`, (Wk)
  `Γ ▷ Δ ⇒ Γ ∪ Γ' ▷ Δ ∪ Δ'` and (Cut) `Γ, φ ▷ Δ` and `Γ ▷ φ, Δ ⇒ Γ ▷ Δ`.
  `gen S` (`⟨S⟩`) is the least Scott relation containing `S` (intersection of all of them).
  `Derives S` is the inductive (derivation) presentation of `⟨S⟩` (`gen_eq_derives`).

## Main results (paper reference → Lean)
* Def 2.1, "intersections of Scott relations are Scott relations": `isScott_sInter`,
  `isScott_gen`, `subset_gen`, `gen_subset`, `gen_eq_derives`.
* Thm 2.2 (bilateral Lindenbaum):
  - existence of maximal extensions (Zorn): `exists_maxCoherent` (holds for every `R`);
  - maximal coherent positions are disjoint and exhaustive: `Coherent.disjoint`,
    `MaxCoherent.exhaustive`; the valuation `charFn X` is admissible:
    `MaxCoherent.charFn_mem_Val`;
  - (a) `thm_2_2_a` (every coherent position is realized by an admissible valuation),
    `thm_2_2_a_max` (it extends to a maximal coherent position that is the true/false split
    of an admissible valuation), `coherent_iff_realizable`;
  - (b) `thm_2_2_b` (maximal coherent positions = `[v⁻¹(1) : v⁻¹(0)]`, `v ∈ Val(⊢)`).
* Cor 2.3 (strong bilateral completeness): `cor_2_3 : Th (Val S) = gen S` for every set `S`
  of sequents; soundness half `gen_subset_Th_Val`; consequence-operator form
  `cor_2_3_consOp`; Prop 1.3 instance ("Sam's image"): `isScott_iff_Th_Val_eq`,
  `isScott_iff_exists_Th`; `Val_gen`, `coherent_gen_iff`, `mem_gen_iff`; sanity check
  `mem_gen_empty` (`⟨∅⟩` = the overlap sequents).
* Thm 2.4 (duality, both closure operators): syntactic closure = `cor_2_3`; semantic
  closure `Val_Th : Val (Th V) = closure V` (product/Cantor topology on `α → Bool`);
  `isClosed_Val`; the dual lattice isomorphism `scottClosedIso :
  {R // IsScott R} ≃o {V // IsClosed V}ᵒᵈ` (`Val`, `Th` mutually inverse).
* Thm 2.6 (on `Formula`):
  - (a) `thm_2_6_a : IsScott R → (Structural R ↔ SubstInvariant (Val R))`,
    `thm_2_6_a_closed`, `structural_gen`, and the restricted dual isomorphism
    `structuralClosedIso : {R // IsScott R ∧ Structural R} ≃o {V // IsClosed V ∧ SubstInvariant V}ᵒᵈ`;
  - (b) logical matrices `LogicalMatrix` with `interp`/`Validates`; the Lindenbaum matrix
    `lindenbaum v = ⟨Fm, v⁻¹(1)⟩` (`lindenbaum_interp`: assignments are substitutions);
    `thm_2_6_b_validates` (each `L_v`, `v ∈ Val ⊢`, validates every sequent of a structural
    `⊢`), `thm_2_6_b_eq` (`⊢` = the sequents valid in all `L_v`), `thm_2_6_b_realize`
    (every coherent position is realized in some `L_v` by the identity assignment).
* Bridge to `Carnap.lean` (T2 §4): `ofMSeq`, `mseqEquiv`, `carnap_Val_eq`,
  `carnap_mrel_eq`, `cor_2_3_mseq : Carnap.mrel (Carnap.Val S) = ofMSeq ⁻¹' gen (ofMSeq '' S)`,
  `substInvariant_iff_structuralMeaning`; with the truth-table schemata of T2 Thm 4.4,
  `Val_gen_TT : Val ⟨TT⟩ = BV` and `coherent_TT_iff` (a position is `⟨TT⟩`-coherent iff a
  Boolean valuation realizes it).

## Deviations from the paper
* Remark 2.5 (Stone duality for the free Boolean algebra) is not formalized.
* In Thm 2.6 the term algebra is the project's fixed language `Formula` (atoms `ℕ`,
  connectives `⊥ ⊤ ¬ ∧ ∨ →`), and `LogicalMatrix` is a matrix for exactly this signature.
  Thms 2.2–2.4 are proved for an arbitrary type `α` of formulas, as in the paper.
* Everything else in §2 (Def 2.1, Thm 2.2, Cor 2.3, Thm 2.4, Thm 2.6) is formalized as
  stated. `exists_maxCoherent` (the Zorn step) is proved for every set of finite sequents,
  not only Scott relations; (Ov) and (Cut) are used only to show that the maximal position is
  disjoint and exhaustive.
-/

namespace InfLearn
namespace Bilateral

/-! ## Sequents, valuations, `Val` and `Th` -/

section Sequents

variable {α : Type*}

/-- A finite multiple-conclusion sequent `Γ ▷ Δ` over an arbitrary set `α` of formulas
(T6 §2). Read as a position, it is `[Γ : Δ]`: "assert all of `Γ`, deny all of `Δ`". -/
@[ext] structure Sequent (α : Type*) where
  /-- The antecedent `Γ`. -/
  ante : Finset α
  /-- The succedent `Δ`. -/
  succ : Finset α

namespace Sequent

/-- `v ⊨ Γ ▷ Δ` iff `v` falsifies some `γ ∈ Γ` or verifies some `δ ∈ Δ` (T6 §2). -/
def Sat (v : α → Bool) (s : Sequent α) : Prop :=
  (∃ a ∈ s.ante, v a = false) ∨ ∃ b ∈ s.succ, v b = true

theorem not_sat_iff {v : α → Bool} {s : Sequent α} :
    ¬ s.Sat v ↔ (∀ a ∈ s.ante, v a = true) ∧ ∀ b ∈ s.succ, v b = false := by
  simp [Sat, not_or]

/-- The implicational reading: if `v[Γ] = 1` then `v(δ) = 1` for some `δ ∈ Δ`. -/
theorem sat_iff_imp {v : α → Bool} {s : Sequent α} :
    s.Sat v ↔ ((∀ a ∈ s.ante, v a = true) → ∃ b ∈ s.succ, v b = true) := by
  constructor
  · rintro (⟨a, ha, hva⟩ | h) hall
    · rw [hall a ha] at hva; exact absurd hva (by simp)
    · exact h
  · intro h
    by_contra hns
    obtain ⟨h1, h2⟩ := not_sat_iff.1 hns
    obtain ⟨b, hb, hvb⟩ := h h1
    rw [h2 b hb] at hvb; exact absurd hvb (by simp)

/-- Satisfaction depends only on the values at the formulas the sequent mentions. -/
theorem sat_congr {s : Sequent α} {v w : α → Bool}
    (ha : ∀ a ∈ s.ante, v a = w a) (hs : ∀ b ∈ s.succ, v b = w b) :
    s.Sat v ↔ s.Sat w := by
  unfold Sat
  constructor
  · rintro (⟨a, h, hv⟩ | ⟨b, h, hv⟩)
    · exact Or.inl ⟨a, h, (ha a h).symm.trans hv⟩
    · exact Or.inr ⟨b, h, (hs b h).symm.trans hv⟩
  · rintro (⟨a, h, hv⟩ | ⟨b, h, hv⟩)
    · exact Or.inl ⟨a, h, (ha a h).trans hv⟩
    · exact Or.inr ⟨b, h, (hs b h).trans hv⟩

end Sequent

/-- `Val(S)` (= `Mod(S)` of T6 Cor 2.3): the valuations satisfying every sequent of `S`.
For a Scott relation `⊢`, `Val(⊢)` is the set of *admissible* valuations. -/
def Val (S : Set (Sequent α)) : Set (α → Bool) := {v | ∀ s ∈ S, s.Sat v}

/-- `Th(V)`: the sequents satisfied by every valuation in `V`. -/
def Th (V : Set (α → Bool)) : Set (Sequent α) := {s | ∀ v ∈ V, s.Sat v}

/-- `Val` is the `Mod` of the general Galois connection of `ConsOp.lean` (T6 §1.1). -/
theorem Val_eq_Mod (S : Set (Sequent α)) :
    Val S = ConsOp.Mod (fun (v : α → Bool) (s : Sequent α) => s.Sat v) S := rfl

/-- `Th` is the `Th` of the general Galois connection of `ConsOp.lean` (T6 §1.1). -/
theorem Th_eq_Th (V : Set (α → Bool)) :
    Th V = ConsOp.Th (fun (v : α → Bool) (s : Sequent α) => s.Sat v) V := rfl

/-- The Galois connection (T6 Fact 1.2). -/
theorem subset_Val_iff (S : Set (Sequent α)) (V : Set (α → Bool)) :
    V ⊆ Val S ↔ S ⊆ Th V :=
  ⟨fun h _ hs _ hv => h hv _ hs, fun h _ hv _ hs => h hs _ hv⟩

theorem Val_anti {S S' : Set (Sequent α)} (h : S ⊆ S') : Val S' ⊆ Val S :=
  fun _ hv s hs => hv s (h hs)

theorem Th_anti {V W : Set (α → Bool)} (h : V ⊆ W) : Th W ⊆ Th V :=
  fun _ hs v hv => hs v (h hv)

theorem subset_Th_Val (S : Set (Sequent α)) : S ⊆ Th (Val S) := fun _ hs _ hv => hv _ hs

theorem subset_Val_Th (V : Set (α → Bool)) : V ⊆ Val (Th V) := fun _ hv _ hs => hs _ hv

theorem Val_Th_Val (S : Set (Sequent α)) : Val (Th (Val S)) = Val S :=
  Set.Subset.antisymm (Val_anti (subset_Th_Val S)) (subset_Val_Th _)

end Sequents

/-! ## Positions and coherence -/

section Positions

variable {α : Type*}

/-- The true-set `v⁻¹(1)`. -/
def trueSet (v : α → Bool) : Set α := {a | v a = true}

/-- The false-set `v⁻¹(0)`. -/
def falseSet (v : α → Bool) : Set α := {a | v a = false}

@[simp] theorem mem_trueSet {v : α → Bool} {a : α} : a ∈ trueSet v ↔ v a = true := Iff.rfl

@[simp] theorem mem_falseSet {v : α → Bool} {a : α} : a ∈ falseSet v ↔ v a = false := Iff.rfl

/-- `v` realizes the position `[X : Y]`: `v[X] = 1` and `v[Y] = 0`. -/
def Realizes (v : α → Bool) (X Y : Set α) : Prop :=
  (∀ a ∈ X, v a = true) ∧ ∀ b ∈ Y, v b = false

/-- The position `[X : Y]` is `R`-incoherent if some `Γ ▷ Δ ∈ R` has `Γ ⊆ X` and `Δ ⊆ Y`
(Restall's reading, T6 §2 / T2 §1). -/
def Incoherent (R : Set (Sequent α)) (X Y : Set α) : Prop :=
  ∃ s ∈ R, (↑s.ante : Set α) ⊆ X ∧ (↑s.succ : Set α) ⊆ Y

/-- The position `[X : Y]` is `R`-coherent: no finite `Γ ⊆ X`, `Δ ⊆ Y` with `Γ ▷ Δ ∈ R`. -/
def Coherent (R : Set (Sequent α)) (X Y : Set α) : Prop := ¬ Incoherent R X Y

/-- A maximal `R`-coherent position (componentwise inclusion). -/
def MaxCoherent (R : Set (Sequent α)) (X Y : Set α) : Prop :=
  Coherent R X Y ∧ ∀ X' Y' : Set α, X ⊆ X' → Y ⊆ Y' → Coherent R X' Y' → X' = X ∧ Y' = Y

/-- The characteristic function `χ_X` of a set of formulas. -/
noncomputable def charFn (X : Set α) : α → Bool := fun a => @decide (a ∈ X) (Classical.dec _)

@[simp] theorem charFn_eq_true {X : Set α} {a : α} : charFn X a = true ↔ a ∈ X := by
  simp [charFn]

@[simp] theorem charFn_eq_false {X : Set α} {a : α} : charFn X a = false ↔ a ∉ X := by
  simp [charFn]

@[simp] theorem trueSet_charFn (X : Set α) : trueSet (charFn X) = X := by
  ext a; simp

theorem Coherent.mono {R : Set (Sequent α)} {X Y X' Y' : Set α} (h : Coherent R X' Y')
    (hX : X ⊆ X') (hY : Y ⊆ Y') : Coherent R X Y :=
  fun ⟨s, hs, ha, hsu⟩ => h ⟨s, hs, ha.trans hX, hsu.trans hY⟩

theorem Coherent.anti_rel {R R' : Set (Sequent α)} {X Y : Set α} (h : Coherent R' X Y)
    (hR : R ⊆ R') : Coherent R X Y :=
  fun ⟨s, hs, ha, hsu⟩ => h ⟨s, hR hs, ha, hsu⟩

/-- A position realized by a valuation satisfying `R` is `R`-coherent (the easy direction of
Thm 2.2(a)). -/
theorem coherent_of_realizes {R : Set (Sequent α)} {X Y : Set α} {v : α → Bool}
    (hv : v ∈ Val R) (h : Realizes v X Y) : Coherent R X Y := by
  rintro ⟨s, hs, ha, hsu⟩
  exact Sequent.not_sat_iff.2 ⟨fun a haa => h.1 a (ha haa), fun b hb => h.2 b (hsu hb)⟩
    (hv s hs)

/-- A finite set of requirements, each met by some member of a nonempty chain, is met by a
single member of the chain (requirements are upward closed). -/
theorem chain_finset_bound {β γ : Type*} [Preorder γ] {c : Set γ}
    (hc : IsChain (· ≤ ·) c) (hne : c.Nonempty) (P : β → γ → Prop)
    (hP : ∀ b x y, x ≤ y → P b x → P b y) (F : Finset β) (hF : ∀ b ∈ F, ∃ x ∈ c, P b x) :
    ∃ x ∈ c, ∀ b ∈ F, P b x := by
  classical
  induction F using Finset.induction_on with
  | empty =>
    obtain ⟨x, hx⟩ := hne
    exact ⟨x, hx, fun b hb => absurd hb (Finset.notMem_empty b)⟩
  | insert a F _ ih =>
    obtain ⟨x₁, hx₁, h₁⟩ := hF a (Finset.mem_insert_self a F)
    obtain ⟨x₂, hx₂, h₂⟩ := ih fun b hb => hF b (Finset.mem_insert_of_mem hb)
    rcases hc.total hx₁ hx₂ with h12 | h21
    · refine ⟨x₂, hx₂, fun b hb => ?_⟩
      rcases Finset.mem_insert.1 hb with rfl | hb
      · exact hP _ _ _ h12 h₁
      · exact h₂ b hb
    · refine ⟨x₁, hx₁, fun b hb => ?_⟩
      rcases Finset.mem_insert.1 hb with rfl | hb
      · exact h₁
      · exact hP _ _ _ h21 (h₂ b hb)

/-- **Thm 2.2(a), Zorn step.** Every `R`-coherent position extends to a maximal `R`-coherent
position. This holds for *every* set `R` of (finite) sequents: the union of a chain of
coherent positions is coherent because a witness `Γ ▷ Δ` is finite. -/
theorem exists_maxCoherent {R : Set (Sequent α)} {X Y : Set α} (h : Coherent R X Y) :
    ∃ X' Y' : Set α, X ⊆ X' ∧ Y ⊆ Y' ∧ MaxCoherent R X' Y' := by
  let P : Set (Set α × Set α) := {p | Coherent R p.1 p.2}
  have hchain : ∀ c ⊆ P, IsChain (· ≤ ·) c → ∀ y ∈ c, ∃ ub ∈ P, ∀ z ∈ c, z ≤ ub := by
    intro c hcP hc y hy
    refine ⟨(⋃ p ∈ c, p.1, ⋃ p ∈ c, p.2), ?_, fun z hz =>
      ⟨Set.subset_biUnion_of_mem (u := fun p : Set α × Set α => p.1) hz,
       Set.subset_biUnion_of_mem (u := fun p : Set α × Set α => p.2) hz⟩⟩
    rintro ⟨s, hsR, hsa, hss⟩
    obtain ⟨p, hpc, hp⟩ := chain_finset_bound hc ⟨y, hy⟩
      (fun (a : α) (p : Set α × Set α) => a ∈ p.1) (fun _ _ _ hxy h => hxy.1 h) s.ante
      (fun a ha => by
        obtain ⟨p, hp, hap⟩ := Set.mem_iUnion₂.1 (hsa (Finset.mem_coe.2 ha))
        exact ⟨p, hp, hap⟩)
    obtain ⟨q, hqc, hq⟩ := chain_finset_bound hc ⟨y, hy⟩
      (fun (a : α) (p : Set α × Set α) => a ∈ p.2) (fun _ _ _ hxy h => hxy.2 h) s.succ
      (fun a ha => by
        obtain ⟨p, hp, hap⟩ := Set.mem_iUnion₂.1 (hss (Finset.mem_coe.2 ha))
        exact ⟨p, hp, hap⟩)
    rcases hc.total hpc hqc with hpq | hqp
    · exact hcP hqc ⟨s, hsR, fun a ha => hpq.1 (hp a ha), fun b hb => hq b hb⟩
    · exact hcP hpc ⟨s, hsR, fun a ha => hp a ha, fun b hb => hqp.2 (hq b hb)⟩
  obtain ⟨m, hxm, hm⟩ := zorn_le_nonempty₀ P hchain (X, Y) h
  refine ⟨m.1, m.2, hxm.1, hxm.2, hm.1, fun X' Y' hX hY hc => ?_⟩
  have := hm.2 (y := (X', Y')) hc ⟨hX, hY⟩
  exact ⟨Set.Subset.antisymm this.1 hX, Set.Subset.antisymm this.2 hY⟩

end Positions

/-! ## Scott relations (Definition 2.1) -/

section Scott

variable {α : Type*} [DecidableEq α]

/-- **Definition 2.1.** A *Scott relation* is a set of finite sequents closed under
(Ov) overlap, (Wk) weakening and (Cut). -/
structure IsScott (R : Set (Sequent α)) : Prop where
  /-- (Ov) `Γ ▷ Δ` whenever `Γ ∩ Δ ≠ ∅`. -/
  overlap : ∀ Γ Δ : Finset α, (Γ ∩ Δ).Nonempty → (⟨Γ, Δ⟩ : Sequent α) ∈ R
  /-- (Wk) `Γ ▷ Δ ⇒ Γ ∪ Γ' ▷ Δ ∪ Δ'`. -/
  weaken : ∀ Γ Δ Γ' Δ' : Finset α, (⟨Γ, Δ⟩ : Sequent α) ∈ R →
    (⟨Γ ∪ Γ', Δ ∪ Δ'⟩ : Sequent α) ∈ R
  /-- (Cut) `Γ, φ ▷ Δ` and `Γ ▷ φ, Δ ⇒ Γ ▷ Δ`. -/
  cut : ∀ (Γ Δ : Finset α) (φ : α), (⟨insert φ Γ, Δ⟩ : Sequent α) ∈ R →
    (⟨Γ, insert φ Δ⟩ : Sequent α) ∈ R → (⟨Γ, Δ⟩ : Sequent α) ∈ R

/-- Weakening to arbitrary supersets. -/
theorem IsScott.mono {R : Set (Sequent α)} (hR : IsScott R) {s : Sequent α} (hs : s ∈ R)
    {Γ Δ : Finset α} (hΓ : s.ante ⊆ Γ) (hΔ : s.succ ⊆ Δ) : (⟨Γ, Δ⟩ : Sequent α) ∈ R := by
  have := hR.weaken s.ante s.succ Γ Δ hs
  rwa [Finset.union_eq_right.2 hΓ, Finset.union_eq_right.2 hΔ] at this

/-- Intersections of Scott relations are Scott relations (T6 after Def 2.1); the empty
intersection is the universal relation. -/
theorem isScott_sInter {F : Set (Set (Sequent α))} (hF : ∀ R ∈ F, IsScott R) :
    IsScott (⋂₀ F) where
  overlap Γ Δ h := Set.mem_sInter.2 fun R hR => (hF R hR).overlap Γ Δ h
  weaken Γ Δ Γ' Δ' h :=
    Set.mem_sInter.2 fun R hR => (hF R hR).weaken Γ Δ Γ' Δ' (Set.mem_sInter.1 h R hR)
  cut Γ Δ φ h₁ h₂ := Set.mem_sInter.2 fun R hR =>
    (hF R hR).cut Γ Δ φ (Set.mem_sInter.1 h₁ R hR) (Set.mem_sInter.1 h₂ R hR)

theorem isScott_univ : IsScott (Set.univ : Set (Sequent α)) := by
  simpa using isScott_sInter (F := (∅ : Set (Set (Sequent α)))) (by simp)

/-- **Soundness of (Ov), (Wk), (Cut)** (proof of T6 Cor 2.3): `Th(V)` is a Scott relation for
every set `V` of valuations. -/
theorem isScott_Th (V : Set (α → Bool)) : IsScott (Th V) where
  overlap Γ Δ h v _ := by
    obtain ⟨a, ha⟩ := h
    rw [Finset.mem_inter] at ha
    cases hva : v a
    · exact Or.inl ⟨a, ha.1, hva⟩
    · exact Or.inr ⟨a, ha.2, hva⟩
  weaken Γ Δ Γ' Δ' h v hv := by
    rcases h v hv with ⟨a, ha, hva⟩ | ⟨b, hb, hvb⟩
    · exact Or.inl ⟨a, Finset.mem_union_left _ ha, hva⟩
    · exact Or.inr ⟨b, Finset.mem_union_left _ hb, hvb⟩
  cut Γ Δ φ h₁ h₂ v hv := by
    cases hvφ : v φ
    · rcases h₂ v hv with ⟨a, ha, hva⟩ | ⟨b, hb, hvb⟩
      · exact Or.inl ⟨a, ha, hva⟩
      · rcases Finset.mem_insert.1 hb with rfl | hb
        · rw [hvφ] at hvb; exact absurd hvb (by simp)
        · exact Or.inr ⟨b, hb, hvb⟩
    · rcases h₁ v hv with ⟨a, ha, hva⟩ | ⟨b, hb, hvb⟩
      · rcases Finset.mem_insert.1 ha with rfl | ha
        · rw [hvφ] at hva; exact absurd hva (by simp)
        · exact Or.inl ⟨a, ha, hva⟩
      · exact Or.inr ⟨b, hb, hvb⟩

/-- `⟨S⟩`: the least Scott relation containing `S` (the intersection of all of them). -/
def gen (S : Set (Sequent α)) : Set (Sequent α) := ⋂₀ {R | IsScott R ∧ S ⊆ R}

theorem isScott_gen (S : Set (Sequent α)) : IsScott (gen S) := isScott_sInter fun _ hR => hR.1

theorem subset_gen (S : Set (Sequent α)) : S ⊆ gen S :=
  fun _ hs => Set.mem_sInter.2 fun _ hR => hR.2 hs

theorem gen_subset {S R : Set (Sequent α)} (hR : IsScott R) (h : S ⊆ R) : gen S ⊆ R :=
  Set.sInter_subset_of_mem ⟨hR, h⟩

theorem gen_mono {S S' : Set (Sequent α)} (h : S ⊆ S') : gen S ⊆ gen S' :=
  gen_subset (isScott_gen S') (h.trans (subset_gen S'))

theorem gen_eq_self {R : Set (Sequent α)} (hR : IsScott R) : gen R = R :=
  Set.Subset.antisymm (gen_subset hR subset_rfl) (subset_gen R)

theorem isScott_iff_gen_eq {R : Set (Sequent α)} : IsScott R ↔ gen R = R :=
  ⟨gen_eq_self, fun h => h ▸ isScott_gen R⟩

/-- Derivations from `S` by (Ov), (Wk), (Cut): the inductive presentation of `⟨S⟩`. -/
inductive Derives (S : Set (Sequent α)) : Sequent α → Prop
  | base {s : Sequent α} : s ∈ S → Derives S s
  | overlap (Γ Δ : Finset α) : (Γ ∩ Δ).Nonempty → Derives S ⟨Γ, Δ⟩
  | weaken {Γ Δ : Finset α} (Γ' Δ' : Finset α) : Derives S ⟨Γ, Δ⟩ → Derives S ⟨Γ ∪ Γ', Δ ∪ Δ'⟩
  | cut {Γ Δ : Finset α} (φ : α) :
      Derives S ⟨insert φ Γ, Δ⟩ → Derives S ⟨Γ, insert φ Δ⟩ → Derives S ⟨Γ, Δ⟩

/-- "Generate by (Ov), (Wk), (Cut)" (T6 Thm 2.4): `⟨S⟩` is the set of derivable sequents. -/
theorem gen_eq_derives (S : Set (Sequent α)) : gen S = {s | Derives S s} := by
  apply Set.Subset.antisymm
  · exact gen_subset ⟨fun Γ Δ h => Derives.overlap Γ Δ h, fun _ _ Γ' Δ' h => Derives.weaken Γ' Δ' h,
      fun _ _ φ h₁ h₂ => Derives.cut φ h₁ h₂⟩ fun _ hs => Derives.base hs
  · intro s hs
    induction hs with
    | base h => exact subset_gen S h
    | overlap Γ Δ h => exact (isScott_gen S).overlap Γ Δ h
    | weaken Γ' Δ' _ ih => exact (isScott_gen S).weaken _ _ Γ' Δ' ih
    | cut φ _ _ ih₁ ih₂ => exact (isScott_gen S).cut _ _ φ ih₁ ih₂

/-! ## Theorem 2.2: bilateral Lindenbaum -/

/-- Under (Ov), a coherent position is disjoint: no formula is both asserted and denied. -/
theorem Coherent.disjoint {R : Set (Sequent α)} (hR : IsScott R) {X Y : Set α}
    (h : Coherent R X Y) {a : α} (haX : a ∈ X) (haY : a ∈ Y) : False :=
  h ⟨⟨{a}, {a}⟩, hR.overlap {a} {a} (by simp), by simpa using haX, by simpa using haY⟩

/-- **Thm 2.2, proof of (a), exhaustiveness.** A maximal coherent position decides every
formula (uses (Wk) and (Cut)). -/
theorem MaxCoherent.exhaustive {R : Set (Sequent α)} (hR : IsScott R) {X Y : Set α}
    (h : MaxCoherent R X Y) (a : α) : a ∈ X ∨ a ∈ Y := by
  by_contra hcon
  rw [not_or] at hcon
  obtain ⟨haX, haY⟩ := hcon
  have h₁ : Incoherent R (insert a X) Y := by
    by_contra hc
    have e := (h.2 _ _ (Set.subset_insert a X) subset_rfl hc).1
    exact haX (by rw [← e]; exact Set.mem_insert a X)
  have h₂ : Incoherent R X (insert a Y) := by
    by_contra hc
    have e := (h.2 _ _ subset_rfl (Set.subset_insert a Y) hc).2
    exact haY (by rw [← e]; exact Set.mem_insert a Y)
  obtain ⟨s₁, hs₁R, hs₁a, hs₁s⟩ := h₁
  obtain ⟨s₂, hs₂R, hs₂a, hs₂s⟩ := h₂
  apply h.1
  refine ⟨⟨s₁.ante.erase a ∪ s₂.ante, s₁.succ ∪ s₂.succ.erase a⟩, ?_, ?_, ?_⟩
  · apply hR.cut _ _ a
    · apply hR.mono hs₁R
      · intro x hx
        by_cases hxa : x = a
        · rw [hxa]; exact Finset.mem_insert_self _ _
        · exact Finset.mem_insert_of_mem (Finset.mem_union_left _ (Finset.mem_erase.2 ⟨hxa, hx⟩))
      · exact Finset.subset_union_left
    · apply hR.mono hs₂R
      · exact Finset.subset_union_right
      · intro x hx
        by_cases hxa : x = a
        · rw [hxa]; exact Finset.mem_insert_self _ _
        · exact Finset.mem_insert_of_mem (Finset.mem_union_right _ (Finset.mem_erase.2 ⟨hxa, hx⟩))
  · intro x hx
    rcases Finset.mem_union.1 (Finset.mem_coe.1 hx) with hx | hx
    · obtain ⟨hxa, hx⟩ := Finset.mem_erase.1 hx
      exact (Set.mem_insert_iff.1 (hs₁a (Finset.mem_coe.2 hx))).resolve_left hxa
    · exact hs₂a (Finset.mem_coe.2 hx)
  · intro x hx
    rcases Finset.mem_union.1 (Finset.mem_coe.1 hx) with hx | hx
    · exact hs₁s (Finset.mem_coe.2 hx)
    · obtain ⟨hxa, hx⟩ := Finset.mem_erase.1 hx
      exact (Set.mem_insert_iff.1 (hs₂s (Finset.mem_coe.2 hx))).resolve_left hxa

/-- **Thm 2.2, proof of (a), last step.** If `[X : Y]` is maximal coherent then `v := χ_X`
satisfies every sequent of `⊢`, i.e. `v ∈ Val(⊢)`. -/
theorem MaxCoherent.charFn_mem_Val {R : Set (Sequent α)} (hR : IsScott R) {X Y : Set α}
    (h : MaxCoherent R X Y) : charFn X ∈ Val R := by
  intro s hs
  by_contra hns
  obtain ⟨h₁, h₂⟩ := Sequent.not_sat_iff.1 hns
  exact h.1 ⟨s, hs, fun a ha => charFn_eq_true.1 (h₁ a ha),
    fun b hb => (h.exhaustive hR b).resolve_left (charFn_eq_false.1 (h₂ b hb))⟩

/-- A maximal coherent position is the true/false split of `χ_X`. -/
theorem MaxCoherent.eq_split {R : Set (Sequent α)} (hR : IsScott R) {X Y : Set α}
    (h : MaxCoherent R X Y) : X = trueSet (charFn X) ∧ Y = falseSet (charFn X) := by
  refine ⟨(trueSet_charFn X).symm, ?_⟩
  ext b
  simp only [mem_falseSet, charFn_eq_false]
  constructor
  · intro hbY hbX; exact h.1.disjoint hR hbX hbY
  · intro hbX; exact (h.exhaustive hR b).resolve_left hbX

/-- **Theorem 2.2(a) (bilateral Lindenbaum).** Let `⊢` be a Scott relation. Every
`⊢`-coherent position `[X : Y]` is realized by an admissible valuation `v ∈ Val(⊢)`:
`v[X] = 1` and `v[Y] = 0`. -/
theorem thm_2_2_a {R : Set (Sequent α)} (hR : IsScott R) {X Y : Set α} (h : Coherent R X Y) :
    ∃ v ∈ Val R, Realizes v X Y := by
  obtain ⟨X', Y', hX, hY, hm⟩ := exists_maxCoherent h
  exact ⟨charFn X', hm.charFn_mem_Val hR, fun a ha => charFn_eq_true.2 (hX ha),
    fun b hb => charFn_eq_false.2 fun hb' => hm.1.disjoint hR hb' (hY hb)⟩

/-- For `v ∈ Val(⊢)` the position `[v⁻¹(1) : v⁻¹(0)]` is maximal coherent
(Thm 2.2(b), (⇐)). -/
theorem maxCoherent_of_mem_Val {R : Set (Sequent α)} (hR : IsScott R) {v : α → Bool}
    (hv : v ∈ Val R) : MaxCoherent R (trueSet v) (falseSet v) := by
  refine ⟨coherent_of_realizes hv ⟨fun _ ha => ha, fun _ hb => hb⟩,
    fun X' Y' hX hY hc => ⟨?_, ?_⟩⟩
  · ext a
    refine ⟨fun ha => ?_, fun ha => hX ha⟩
    cases hva : v a
    · exact absurd (hY (show a ∈ falseSet v from hva)) fun haY => hc.disjoint hR ha haY
    · exact hva
  · ext b
    refine ⟨fun hb => ?_, fun hb => hY hb⟩
    cases hvb : v b
    · exact hvb
    · exact absurd (hX (show b ∈ trueSet v from hvb)) fun hbX => hc.disjoint hR hbX hb

/-- **Theorem 2.2(a), maximal form.** Every `⊢`-coherent position extends to a maximal
`⊢`-coherent position, and that maximal position is `[v⁻¹(1) : v⁻¹(0)]` for an admissible
valuation `v ∈ Val(⊢)`. -/
theorem thm_2_2_a_max {R : Set (Sequent α)} (hR : IsScott R) {X Y : Set α}
    (h : Coherent R X Y) :
    ∃ v ∈ Val R, X ⊆ trueSet v ∧ Y ⊆ falseSet v ∧ MaxCoherent R (trueSet v) (falseSet v) := by
  obtain ⟨v, hv, h₁, h₂⟩ := thm_2_2_a hR h
  exact ⟨v, hv, h₁, h₂, maxCoherent_of_mem_Val hR hv⟩

/-- **Theorem 2.2(b).** The maximal `⊢`-coherent positions are exactly the pairs
`[v⁻¹(1) : v⁻¹(0)]` with `v ∈ Val(⊢)`. -/
theorem thm_2_2_b {R : Set (Sequent α)} (hR : IsScott R) {X Y : Set α} :
    MaxCoherent R X Y ↔ ∃ v ∈ Val R, X = trueSet v ∧ Y = falseSet v := by
  constructor
  · intro h
    exact ⟨charFn X, h.charFn_mem_Val hR, h.eq_split hR⟩
  · rintro ⟨v, hv, rfl, rfl⟩
    exact maxCoherent_of_mem_Val hR hv

/-- Thm 2.2, reading: a position is `⊢`-coherent iff some admissible valuation realizes it. -/
theorem coherent_iff_realizable {R : Set (Sequent α)} (hR : IsScott R) {X Y : Set α} :
    Coherent R X Y ↔ ∃ v ∈ Val R, Realizes v X Y :=
  ⟨thm_2_2_a hR, fun ⟨_, hv, h⟩ => coherent_of_realizes hv h⟩

/-! ## Corollary 2.3: strong bilateral completeness -/

/-- **Cor 2.3, soundness half.** `⟨S⟩ ⊆ Th(Mod(S))`. -/
theorem gen_subset_Th_Val (S : Set (Sequent α)) : gen S ⊆ Th (Val S) :=
  gen_subset (isScott_Th _) (subset_Th_Val S)

/-- **Corollary 2.3 (strong bilateral completeness).** For every set `S` of sequents,
`Th(Mod(S)) = ⟨S⟩`. -/
theorem cor_2_3 (S : Set (Sequent α)) : Th (Val S) = gen S := by
  refine Set.Subset.antisymm ?_ (gen_subset_Th_Val S)
  intro s hs
  by_contra hns
  have hcoh : Coherent (gen S) ↑s.ante ↑s.succ := by
    rintro ⟨t, ht, hta, hts⟩
    exact hns ((isScott_gen S).mono ht (Finset.coe_subset.1 hta) (Finset.coe_subset.1 hts))
  obtain ⟨v, hv, hva, hvs⟩ := thm_2_2_a (isScott_gen S) hcoh
  exact Sequent.not_sat_iff.2 ⟨fun a ha => hva a ha, fun b hb => hvs b hb⟩
    (hs v (Val_anti (subset_gen S) hv))

/-- Cor 2.3 as an identity of consequence operators on sets of sequents: the semantic
operator `Th ∘ Mod` of the satisfaction relation equals generation by (Ov), (Wk), (Cut). -/
theorem cor_2_3_consOp (S : Set (Sequent α)) :
    ConsOp.ofSat (fun (v : α → Bool) (s : Sequent α) => s.Sat v) S = gen S :=
  cor_2_3 S

/-- For a Scott relation, `Th(Val(⊢)) = ⊢`. -/
theorem Th_Val_of_isScott {R : Set (Sequent α)} (hR : IsScott R) : Th (Val R) = R :=
  (cor_2_3 R).trans (gen_eq_self hR)

/-- T6 Prop 1.3 / "Sam's image" in the bilateral setting: the Galois-closed sets of
sequents are exactly the Scott relations. -/
theorem isScott_iff_Th_Val_eq {R : Set (Sequent α)} : IsScott R ↔ Th (Val R) = R :=
  ⟨Th_Val_of_isScott, fun h => h ▸ isScott_Th _⟩

/-- The image of `Th` is exactly the set of Scott relations. -/
theorem isScott_iff_exists_Th {R : Set (Sequent α)} : IsScott R ↔ ∃ V : Set (α → Bool), Th V = R :=
  ⟨fun h => ⟨Val R, Th_Val_of_isScott h⟩, fun ⟨_, h⟩ => h ▸ isScott_Th _⟩

theorem Val_gen (S : Set (Sequent α)) : Val (gen S) = Val S := by
  rw [← cor_2_3, Val_Th_Val]

/-- A position is `⟨S⟩`-coherent iff it is realized by some valuation satisfying `S`. -/
theorem coherent_gen_iff {S : Set (Sequent α)} {X Y : Set α} :
    Coherent (gen S) X Y ↔ ∃ v ∈ Val S, Realizes v X Y := by
  rw [coherent_iff_realizable (isScott_gen S), Val_gen]

/-- Completeness in sequent form: `Γ ▷ Δ ∈ ⟨S⟩` iff every valuation satisfying `S`
satisfies `Γ ▷ Δ`. -/
theorem mem_gen_iff {S : Set (Sequent α)} {s : Sequent α} :
    s ∈ gen S ↔ ∀ v ∈ Val S, s.Sat v := by
  rw [← cor_2_3]; rfl

/-- Sanity check (non-vacuity): the least Scott relation `⟨∅⟩` consists exactly of the
overlap sequents. -/
theorem mem_gen_empty {s : Sequent α} : s ∈ gen (∅ : Set (Sequent α)) ↔ (s.ante ∩ s.succ).Nonempty := by
  constructor
  · intro hs
    by_contra hne
    have := (mem_gen_iff.1 hs) (charFn ↑s.ante) (fun _ h => absurd h (Set.notMem_empty _))
    refine Sequent.not_sat_iff.2 ⟨fun a ha => charFn_eq_true.2 ha, fun b hb => ?_⟩ this
    exact charFn_eq_false.2 fun hb' => hne ⟨b, Finset.mem_inter.2 ⟨hb', hb⟩⟩
  · intro h
    exact (isScott_gen _).overlap s.ante s.succ h

end Scott

/-! ## Theorem 2.4: the duality with the Cantor topology -/

section Duality

variable {α : Type*}

/-- Closure in the product (Cantor) topology on `α → Bool`: `w ∈ closure V` iff every finite
set of formulas sees some `v ∈ V` agreeing with `w` there. -/
theorem mem_closure_iff_agree {V : Set (α → Bool)} {w : α → Bool} :
    w ∈ closure V ↔ ∀ F : Finset α, ∃ v ∈ V, ∀ a ∈ F, v a = w a := by
  rw [mem_closure_iff_nhds]
  constructor
  · intro h F
    have hU : {v : α → Bool | ∀ a ∈ F, v a = w a} ∈ nhds w := by
      rw [nhds_pi, Filter.mem_pi']
      refine ⟨F, fun a => {w a}, fun a => ?_, ?_⟩
      · rw [nhds_discrete]; exact Filter.mem_pure.2 rfl
      · intro v hv a ha; exact hv a ha
    obtain ⟨v, hvU, hvV⟩ := h _ hU
    exact ⟨v, hvV, hvU⟩
  · intro h t ht
    rw [nhds_pi, Filter.mem_pi'] at ht
    obtain ⟨I, u, hu, hIu⟩ := ht
    obtain ⟨v, hvV, hv⟩ := h I
    refine ⟨v, hIu fun a ha => ?_, hvV⟩
    rw [hv a ha]
    have := hu a
    rw [nhds_discrete] at this
    exact this

/-- Each sequent defines a closed (indeed clopen) set of valuations. -/
theorem isClosed_sat [DecidableEq α] (s : Sequent α) : IsClosed {v : α → Bool | s.Sat v} := by
  apply isClosed_of_closure_subset
  intro w hw
  obtain ⟨v, hv, hvw⟩ := mem_closure_iff_agree.1 hw (s.ante ∪ s.succ)
  exact (Sequent.sat_congr (fun a ha => hvw a (Finset.mem_union_left _ ha))
    (fun b hb => hvw b (Finset.mem_union_right _ hb))).1 hv

/-- `Val(S)` is always closed in the Cantor topology. -/
theorem isClosed_Val (S : Set (Sequent α)) : IsClosed (Val S) := by
  classical
  have : Val S = ⋂ s ∈ S, {v : α → Bool | s.Sat v} := by ext v; simp [Val]
  rw [this]
  exact isClosed_biInter fun s _ => isClosed_sat s

/-- **Theorem 2.4, semantic closure.** `Mod(Th(V)) = closure V` (T2 Lemma 4.1(a) for
arbitrary `α`). -/
theorem Val_Th (V : Set (α → Bool)) : Val (Th V) = closure V := by
  classical
  ext w
  constructor
  · intro hw
    rw [mem_closure_iff_agree]
    intro F
    by_contra hne
    push Not at hne
    let s : Sequent α := ⟨F.filter (fun a => w a = true), F.filter (fun a => w a = false)⟩
    have hs : s ∈ Th V := by
      intro v hv
      obtain ⟨a, haF, ha⟩ := hne v hv
      cases hwa : w a
      · refine Or.inr ⟨a, Finset.mem_filter.2 ⟨haF, hwa⟩, ?_⟩
        rw [hwa] at ha
        simpa using ha
      · refine Or.inl ⟨a, Finset.mem_filter.2 ⟨haF, hwa⟩, ?_⟩
        rw [hwa] at ha
        simpa using ha
    rcases hw s hs with ⟨a, ha, hwa⟩ | ⟨b, hb, hwb⟩
    · rw [(Finset.mem_filter.1 ha).2] at hwa; exact absurd hwa (by simp)
    · rw [(Finset.mem_filter.1 hb).2] at hwb; exact absurd hwb (by simp)
  · intro hw s hs
    obtain ⟨v, hvV, hv⟩ := mem_closure_iff_agree.1 hw (s.ante ∪ s.succ)
    exact (Sequent.sat_congr (fun a ha => hv a (Finset.mem_union_left _ ha))
      (fun b hb => hv b (Finset.mem_union_right _ hb))).1 (hs v hvV)

theorem Th_closure (V : Set (α → Bool)) : Th (closure V) = Th V := by
  apply Set.Subset.antisymm (Th_anti subset_closure)
  intro s hs v hv
  rw [← Val_Th] at hv
  exact hv s hs

theorem Val_Th_of_isClosed {V : Set (α → Bool)} (hV : IsClosed V) : Val (Th V) = V := by
  rw [Val_Th, hV.closure_eq]

variable [DecidableEq α]

/-- For Scott relations, `Val` is an order embedding into `(Set (α → Bool))ᵒᵈ`. -/
theorem Val_subset_Val_iff {R R' : Set (Sequent α)} (hR : IsScott R) (hR' : IsScott R') :
    Val R' ⊆ Val R ↔ R ⊆ R' := by
  constructor
  · intro h
    rw [← Th_Val_of_isScott hR, ← Th_Val_of_isScott hR']
    exact Th_anti h
  · exact Val_anti

/-- **Theorem 2.4 (the duality).** `⊢ ↦ Val(⊢)` and `V ↦ Th(V)` are mutually inverse,
inclusion-reversing bijections between Scott relations and closed subsets of `2^Fm`. -/
def scottClosedIso :
    {R : Set (Sequent α) // IsScott R} ≃o {V : Set (α → Bool) // IsClosed V}ᵒᵈ where
  toFun R := OrderDual.toDual ⟨Val R.1, isClosed_Val _⟩
  invFun V := ⟨Th (OrderDual.ofDual V).1, isScott_Th _⟩
  left_inv R := Subtype.ext (Th_Val_of_isScott R.2)
  right_inv V := by
    change OrderDual.toDual (⟨Val (Th (OrderDual.ofDual V).1), _⟩ : {V : Set (α → Bool) // IsClosed V}) = V
    rw [← OrderDual.toDual_ofDual V]
    congr 1
    exact Subtype.ext (Val_Th_of_isClosed (OrderDual.ofDual V).2)
  map_rel_iff' {R R'} := by
    change (⟨Val R'.1, _⟩ : {V : Set (α → Bool) // IsClosed V}) ≤ ⟨Val R.1, _⟩ ↔ R ≤ R'
    rw [Subtype.mk_le_mk, Val_subset_Val_iff R.2 R'.2]
    rfl

@[simp] theorem scottClosedIso_apply (R : {R : Set (Sequent α) // IsScott R}) :
    (OrderDual.ofDual (scottClosedIso R)).1 = Val R.1 := rfl

@[simp] theorem scottClosedIso_symm_apply (V : {V : Set (α → Bool) // IsClosed V}ᵒᵈ) :
    (scottClosedIso.symm V).1 = Th (OrderDual.ofDual V).1 := rfl

end Duality

/-! ## Theorem 2.6: structural Scott relations and Lindenbaum bundles (on `Formula`) -/

section Structural

open Formula

/-- The substitution instance `σΓ ▷ σΔ` of a sequent. -/
def Sequent.subst (σ : Subst) (s : Sequent Formula) : Sequent Formula :=
  ⟨s.ante.image (Formula.subst σ), s.succ.image (Formula.subst σ)⟩

/-- A set of sequents is *structural* if it is closed under substitution:
`Γ ▷ Δ ∈ ⊢ ⇒ σΓ ▷ σΔ ∈ ⊢`. -/
def Structural (R : Set (Sequent Formula)) : Prop := ∀ s ∈ R, ∀ σ : Subst, s.subst σ ∈ R

/-- A set of valuations is *substitution-invariant* if it is closed under `v ↦ v ∘ σ`. -/
def SubstInvariant (V : Set (Formula → Bool)) : Prop :=
  ∀ v ∈ V, ∀ σ : Subst, (fun φ => v (φ.subst σ)) ∈ V

/-- Substitution-invariance is `Carnap.StructuralMeaning` (T2 §4). -/
theorem substInvariant_iff_structuralMeaning {V : Set (Formula → Bool)} :
    SubstInvariant V ↔ Carnap.StructuralMeaning V := Iff.rfl

/-- The key identity: `v ∘ σ ⊨ Γ ▷ Δ` iff `v ⊨ σΓ ▷ σΔ`. -/
theorem Sequent.sat_comp_subst (v : Formula → Bool) (σ : Subst) (s : Sequent Formula) :
    s.Sat (fun φ => v (φ.subst σ)) ↔ (s.subst σ).Sat v := by
  simp [Sequent.Sat, Sequent.subst]

/-- **Thm 2.6(a), (⇒)** (for every set `S` of sequents): if `S` is structural then `Val(S)` is
substitution-invariant. -/
theorem substInvariant_Val {S : Set (Sequent Formula)} (hS : Structural S) :
    SubstInvariant (Val S) :=
  fun v hv σ s hs => (Sequent.sat_comp_subst v σ s).2 (hv _ (hS s hs σ))

/-- **Thm 2.6(a), (⇐)** (for every set `V` of valuations): if `V` is substitution-invariant
then `Th(V)` is structural. -/
theorem structural_Th {V : Set (Formula → Bool)} (hV : SubstInvariant V) : Structural (Th V) :=
  fun s hs σ v hv => (Sequent.sat_comp_subst v σ s).1 (hs _ (hV v hv σ))

/-- **Theorem 2.6(a).** A Scott relation `⊢` is structural iff `Val(⊢)` is closed under
`v ↦ v ∘ σ`. -/
theorem thm_2_6_a {R : Set (Sequent Formula)} (hR : IsScott R) :
    Structural R ↔ SubstInvariant (Val R) := by
  refine ⟨substInvariant_Val, fun h => ?_⟩
  rw [← Th_Val_of_isScott hR]
  exact structural_Th h

/-- Thm 2.6(a), semantic side: a closed `V` is substitution-invariant iff `Th(V)` is
structural. -/
theorem thm_2_6_a_closed {V : Set (Formula → Bool)} (hV : IsClosed V) :
    SubstInvariant V ↔ Structural (Th V) := by
  refine ⟨structural_Th, fun h => ?_⟩
  rw [← Val_Th_of_isClosed hV]
  exact substInvariant_Val h

/-- Generation preserves structurality: `⟨S⟩` is structural when `S` is. -/
theorem structural_gen {S : Set (Sequent Formula)} (hS : Structural S) : Structural (gen S) := by
  rw [← cor_2_3]
  exact structural_Th (substInvariant_Val hS)

/-- **Theorem 2.6(a), duality form.** Structural Scott relations are dually isomorphic to the
closed, substitution-invariant sets of valuations (restriction of `scottClosedIso`). -/
def structuralClosedIso :
    {R : Set (Sequent Formula) // IsScott R ∧ Structural R} ≃o
      {V : Set (Formula → Bool) // IsClosed V ∧ SubstInvariant V}ᵒᵈ where
  toFun R := OrderDual.toDual ⟨Val R.1, isClosed_Val _, substInvariant_Val R.2.2⟩
  invFun V := ⟨Th (OrderDual.ofDual V).1, isScott_Th _, structural_Th (OrderDual.ofDual V).2.2⟩
  left_inv R := Subtype.ext (Th_Val_of_isScott R.2.1)
  right_inv V := by
    change OrderDual.toDual (⟨Val (Th (OrderDual.ofDual V).1), _⟩ :
      {V : Set (Formula → Bool) // IsClosed V ∧ SubstInvariant V}) = V
    rw [← OrderDual.toDual_ofDual V]
    congr 1
    exact Subtype.ext (Val_Th_of_isClosed (OrderDual.ofDual V).2.1)
  map_rel_iff' {R R'} := by
    change (⟨Val R'.1, _⟩ : {V : Set (Formula → Bool) // IsClosed V ∧ SubstInvariant V}) ≤
      ⟨Val R.1, _⟩ ↔ R ≤ R'
    rw [Subtype.mk_le_mk, Val_subset_Val_iff R.2.1 R'.2.1]
    rfl

/-! ### Logical matrices and the Lindenbaum bundle (Thm 2.6(b)) -/

/-- A *logical matrix* for the signature `{⊥, ⊤, ¬, ∧, ∨, →}`: an algebra of that signature
together with a set `D` of designated elements. -/
structure LogicalMatrix where
  /-- The carrier of the algebra. -/
  carrier : Type
  /-- Interpretation of `⊥`. -/
  bot : carrier
  /-- Interpretation of `⊤`. -/
  top : carrier
  /-- Interpretation of `¬`. -/
  neg : carrier → carrier
  /-- Interpretation of `∧`. -/
  and : carrier → carrier → carrier
  /-- Interpretation of `∨`. -/
  or : carrier → carrier → carrier
  /-- Interpretation of `→`. -/
  imp : carrier → carrier → carrier
  /-- The designated elements. -/
  D : Set carrier

namespace LogicalMatrix

/-- The value of a formula under an assignment `h` of the atoms (the homomorphic extension). -/
def interp (M : LogicalMatrix) (h : ℕ → M.carrier) : Formula → M.carrier
  | .var n => h n
  | .bot => M.bot
  | .top => M.top
  | .neg a => M.neg (interp M h a)
  | .and a b => M.and (interp M h a) (interp M h b)
  | .or a b => M.or (interp M h a) (interp M h b)
  | .imp a b => M.imp (interp M h a) (interp M h b)

/-- `M` validates `Γ ▷ Δ` under every assignment: whenever all of `Γ` are designated, some
member of `Δ` is designated. -/
def Validates (M : LogicalMatrix) (s : Sequent Formula) : Prop :=
  ∀ h : ℕ → M.carrier, (∀ γ ∈ s.ante, M.interp h γ ∈ M.D) → ∃ δ ∈ s.succ, M.interp h δ ∈ M.D

end LogicalMatrix

/-- The Lindenbaum matrix `L_v = ⟨Fm, v⁻¹(1)⟩`: the term algebra itself, with the true-set of
`v` designated. -/
def lindenbaum (v : Formula → Bool) : LogicalMatrix where
  carrier := Formula
  bot := .bot
  top := .top
  neg := .neg
  and := .and
  or := .or
  imp := .imp
  D := trueSet v

/-- Assignments into the term algebra are substitutions: `⟦φ⟧_σ = σφ`. -/
theorem lindenbaum_interp (v : Formula → Bool) (σ : Subst) (φ : Formula) :
    (lindenbaum v).interp σ φ = φ.subst σ := by
  induction φ with
  | var n => rfl
  | bot => rfl
  | top => rfl
  | neg a ih => exact congrArg Formula.neg ih
  | and a b iha ihb => exact congrArg₂ Formula.and iha ihb
  | or a b iha ihb => exact congrArg₂ Formula.or iha ihb
  | imp a b iha ihb => exact congrArg₂ Formula.imp iha ihb

/-- `L_v` validates `Γ ▷ Δ` iff `v ∘ σ ⊨ Γ ▷ Δ` for every substitution `σ`. -/
theorem lindenbaum_validates_iff (v : Formula → Bool) (s : Sequent Formula) :
    (lindenbaum v).Validates s ↔ ∀ σ : Subst, s.Sat (fun φ => v (φ.subst σ)) := by
  simp only [LogicalMatrix.Validates, Sequent.sat_iff_imp]
  refine forall_congr' fun σ => ?_
  simp only [lindenbaum_interp]
  rfl

/-- **Theorem 2.6(b)(i).** If `⊢` is structural, then for every `v ∈ Val(⊢)` the Lindenbaum
matrix `L_v` validates every sequent of `⊢` under every assignment. -/
theorem thm_2_6_b_validates {R : Set (Sequent Formula)} (hS : Structural R)
    {v : Formula → Bool} (hv : v ∈ Val R) {s : Sequent Formula} (hs : s ∈ R) :
    (lindenbaum v).Validates s :=
  (lindenbaum_validates_iff v s).2 fun σ => substInvariant_Val hS v hv σ s hs

/-- **Theorem 2.6(b)(ii).** A structural Scott relation is exactly the set of sequents valid in
all its Lindenbaum matrices `L_v`, `v ∈ Val(⊢)`. -/
theorem thm_2_6_b_eq {R : Set (Sequent Formula)} (hR : IsScott R) (hS : Structural R) :
    R = {s | ∀ v ∈ Val R, (lindenbaum v).Validates s} := by
  ext s
  refine ⟨fun hs v hv => thm_2_6_b_validates hS hv hs, fun h => ?_⟩
  rw [← Th_Val_of_isScott hR]
  intro v hv
  have := (lindenbaum_validates_iff v s).1 (h v hv) Formula.var
  simpa using this

/-- **Theorem 2.6(b)(iii).** Every `⊢`-coherent position is realized in some Lindenbaum
matrix `L_v` (`v ∈ Val(⊢)`) by the identity assignment. -/
theorem thm_2_6_b_realize {R : Set (Sequent Formula)} (hR : IsScott R) {X Y : Set Formula}
    (h : Coherent R X Y) :
    ∃ v ∈ Val R, (∀ φ ∈ X, (lindenbaum v).interp Formula.var φ ∈ (lindenbaum v).D) ∧
      ∀ φ ∈ Y, (lindenbaum v).interp Formula.var φ ∉ (lindenbaum v).D := by
  obtain ⟨v, hv, h₁, h₂⟩ := thm_2_2_a hR h
  refine ⟨v, hv, fun φ hφ => ?_, fun φ hφ => ?_⟩
  · rw [lindenbaum_interp, subst_id]; exact h₁ φ hφ
  · rw [lindenbaum_interp, subst_id]
    change ¬ v φ = true
    rw [h₂ φ hφ]; simp

end Structural

/-! ## Bridge to `Carnap.lean` (T2 §4) -/

section CarnapBridge

/-- `Carnap.MSeq` is the same notion of finite multiple-conclusion sequent over `Formula`. -/
def ofMSeq (s : Carnap.MSeq) : Sequent Formula := ⟨s.ante, s.succ⟩

/-- The two sequent types are equivalent. -/
def mseqEquiv : Carnap.MSeq ≃ Sequent Formula where
  toFun := ofMSeq
  invFun s := ⟨s.ante, s.succ⟩
  left_inv _ := rfl
  right_inv _ := rfl

theorem carnap_sat_iff (v : Formula → Bool) (s : Carnap.MSeq) :
    s.Sat v ↔ (ofMSeq s).Sat v :=
  (Sequent.sat_iff_imp (v := v) (s := ofMSeq s)).symm

theorem carnap_Val_eq (S : Set Carnap.MSeq) : Carnap.Val S = Val (ofMSeq '' S) := by
  ext v
  simp only [Carnap.Val, Val, Set.mem_setOf_eq, Set.forall_mem_image, carnap_sat_iff]

theorem carnap_mrel_eq (V : Set (Formula → Bool)) : Carnap.mrel V = ofMSeq ⁻¹' Th V := by
  ext s
  simp only [Carnap.mem_mrel, Set.mem_preimage, Th, Set.mem_setOf_eq, carnap_sat_iff]

/-- **Cor 2.3 in the vocabulary of `Carnap.lean`.** For every set `S` of `Carnap.MSeq`
sequents, the multiple-conclusion consequence of `Val(S)` is the Scott relation generated by
`S`. -/
theorem cor_2_3_mseq (S : Set Carnap.MSeq) :
    Carnap.mrel (Carnap.Val S) = ofMSeq ⁻¹' gen (ofMSeq '' S) := by
  rw [carnap_mrel_eq, carnap_Val_eq, cor_2_3]

/-- With the truth-table schemata `TT` of T2 Thm 4.4 (as formalized in `Carnap.lean`), the
admissible valuations of the generated Scott relation are exactly the Boolean valuations
(T6 §2, Reading after Thm 2.6; uses `Carnap.Val_TTall`). -/
theorem Val_gen_TT : Val (gen (ofMSeq '' Carnap.TTall)) = Carnap.BV := by
  rw [Val_gen, ← carnap_Val_eq, Carnap.Val_TTall]

/-- Thm 2.2 for the truth-table Scott relation `⟨TT⟩`: a position `[X : Y]` is coherent iff
some Boolean (truth-table) valuation makes all of `X` true and all of `Y` false. -/
theorem coherent_TT_iff {X Y : Set Formula} :
    Coherent (gen (ofMSeq '' Carnap.TTall)) X Y ↔
      ∃ a : Valuation, (∀ φ ∈ X, φ.eval a = true) ∧ ∀ φ ∈ Y, φ.eval a = false := by
  rw [coherent_iff_realizable (isScott_gen _), Val_gen_TT]
  constructor
  · rintro ⟨v, ⟨a, rfl⟩, h⟩; exact ⟨a, h⟩
  · rintro ⟨a, h⟩; exact ⟨_, ⟨a, rfl⟩, h⟩

end CarnapBridge

end Bilateral
end InfLearn

#print axioms InfLearn.Bilateral.isScott_Th
#print axioms InfLearn.Bilateral.gen_eq_derives
#print axioms InfLearn.Bilateral.exists_maxCoherent
#print axioms InfLearn.Bilateral.thm_2_2_a
#print axioms InfLearn.Bilateral.thm_2_2_a_max
#print axioms InfLearn.Bilateral.thm_2_2_b
#print axioms InfLearn.Bilateral.coherent_iff_realizable
#print axioms InfLearn.Bilateral.cor_2_3
#print axioms InfLearn.Bilateral.cor_2_3_consOp
#print axioms InfLearn.Bilateral.isScott_iff_Th_Val_eq
#print axioms InfLearn.Bilateral.mem_gen_iff
#print axioms InfLearn.Bilateral.Val_Th
#print axioms InfLearn.Bilateral.isClosed_Val
#print axioms InfLearn.Bilateral.scottClosedIso
#print axioms InfLearn.Bilateral.thm_2_6_a
#print axioms InfLearn.Bilateral.thm_2_6_a_closed
#print axioms InfLearn.Bilateral.structural_gen
#print axioms InfLearn.Bilateral.structuralClosedIso
#print axioms InfLearn.Bilateral.thm_2_6_b_validates
#print axioms InfLearn.Bilateral.thm_2_6_b_eq
#print axioms InfLearn.Bilateral.thm_2_6_b_realize
#print axioms InfLearn.Bilateral.cor_2_3_mseq
#print axioms InfLearn.Bilateral.mem_gen_empty
#print axioms InfLearn.Bilateral.Val_gen_TT
#print axioms InfLearn.Bilateral.coherent_TT_iff
