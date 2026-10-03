import InfLearn.Prop.Basic

/-!
# Abstract step systems (T1 §1.1, used by T7 §1.1)

* `Step J` : a step `(Π, j)` with a finite set of premises `Π : Finset J` and a conclusion
  `j : J`, over an arbitrary type `J` of judgments.
* A rule set is just `A : Set (Step J)`.
* `Derivable A B j` : `j` has a finite `A`-derivation from the leaves `B` (inductive).
* `Cl A B : Set J` : the closure `Cl_A(B)` = the set of `A`-derivable judgments from `B`;
  it is the least superset of `B` closed under `A` (`Cl_subset`, `Cl_eq_sInter`).
* `StepClosed A X` : `X` is closed under the steps of `A`.
* `ClOp A : ConsOp J` : `Cl A` packaged as a (finitary, `ClOp_finitary`) consequence operator.
* `Sound R := {(Π, j) | j ∈ Cl_R(Π)}` : the derivable steps of `R` (T1's `Sound(R*)`).
* T1 Lemma 1.1 (`Cl_subset_Cl_iff_subset_Sound`): `(∀ B, Cl A B ⊆ Cl R B) ↔ A ⊆ Sound R`,
  and its generalisation `ClOp_le_iff` to arbitrary consequence operators.

For steps over propositional formulas (`J = Formula`):
* `Step.subst`, `SubstClosed A`, `substClosure D` (all substitution instances of `D`);
* `ClOp_structural` : a substitution-closed rule set yields a structural operator;
* `ClOp_substClosure_le` : `ClOp (substClosure D)` is the *least* structural consequence
  operator validating `D` (T2's `⟨D⟩`);
* `SemSound` : the classically sound steps, with `Cl_subset_Cn2`.
-/

namespace InfLearn

universe u

/-- A step `(Π, j)`: a finite set `prem` of premises and a conclusion `concl`. -/
structure Step (J : Type u) where
  /-- The premises `Π` (a finite set of judgments). -/
  prem : Finset J
  /-- The conclusion `j`. -/
  concl : J
  deriving DecidableEq

variable {J : Type u}

/-- `Derivable A B j` : `j` has a (finite) derivation from leaves in `B`
using steps from the rule set `A`. -/
inductive Derivable (A : Set (Step J)) (B : Set J) : J → Prop
  /-- Leaves: members of `B` are derivable. -/
  | base {j : J} : j ∈ B → Derivable A B j
  /-- Apply a step of `A` whose premises are all derivable. -/
  | step {s : Step J} : s ∈ A → (∀ p ∈ s.prem, Derivable A B p) → Derivable A B s.concl

/-- The closure `Cl_A(B)`: all judgments derivable from `B` with steps of `A`. -/
def Cl (A : Set (Step J)) (B : Set J) : Set J := {j | Derivable A B j}

/-- `X` is closed under the rule set `A`: `(Π, j) ∈ A` and `Π ⊆ X` imply `j ∈ X`. -/
def StepClosed (A : Set (Step J)) (X : Set J) : Prop :=
  ∀ s ∈ A, (↑s.prem : Set J) ⊆ X → s.concl ∈ X

/-- The derivable steps of `R`: `Sound R = {(Π, j) | j ∈ Cl_R(Π)}` (T1 §1.1). -/
def Sound (R : Set (Step J)) : Set (Step J) := {s | s.concl ∈ Cl R ↑s.prem}

section Closure

variable {A A' R : Set (Step J)} {B B' X : Set J} {j : J}

@[simp] theorem mem_Cl : j ∈ Cl A B ↔ Derivable A B j := Iff.rfl

theorem mem_Sound {s : Step J} : s ∈ Sound R ↔ s.concl ∈ Cl R ↑s.prem := Iff.rfl

/-- `B ⊆ Cl_A(B)`. -/
theorem subset_Cl : B ⊆ Cl A B := fun _ h => Derivable.base h

/-- `Cl_A(B)` is closed under `A`. -/
theorem Cl_stepClosed : StepClosed A (Cl A B) := fun _ hs hprem =>
  Derivable.step hs fun _ hp => hprem (Finset.mem_coe.2 hp)

/-- Applying one step of `A` to derivable premises. -/
theorem concl_mem_Cl {s : Step J} (hs : s ∈ A) (hprem : (↑s.prem : Set J) ⊆ Cl A B) :
    s.concl ∈ Cl A B := Cl_stepClosed s hs hprem

/-- **Leastness**: `Cl_A(B)` is contained in every `A`-closed superset of `B`. -/
theorem Cl_subset (hB : B ⊆ X) (hX : StepClosed A X) : Cl A B ⊆ X := by
  intro j hj
  induction hj with
  | base h => exact hB h
  | step hs _ ih => exact hX _ hs fun p hp => ih p (Finset.mem_coe.1 hp)

/-- `Cl_A(B)` is the least `A`-closed superset of `B` (the paper's definition). -/
theorem Cl_eq_sInter : Cl A B = ⋂₀ {X | B ⊆ X ∧ StepClosed A X} := by
  apply Set.Subset.antisymm
  · exact Set.subset_sInter fun X hX => Cl_subset hX.1 hX.2
  · exact Set.sInter_subset_of_mem ⟨subset_Cl, Cl_stepClosed⟩

/-- Monotonicity in the rule set. -/
theorem Cl_mono_rules (h : A ⊆ A') : Cl A B ⊆ Cl A' B :=
  Cl_subset subset_Cl fun _ hs hprem => concl_mem_Cl (h hs) hprem

/-- Monotonicity in the leaves. -/
theorem Cl_mono_base (h : B ⊆ B') : Cl A B ⊆ Cl A B' :=
  Cl_subset (h.trans subset_Cl) Cl_stepClosed

/-- Monotonicity in both arguments. -/
theorem Cl_mono (hA : A ⊆ A') (hB : B ⊆ B') : Cl A B ⊆ Cl A' B' :=
  (Cl_mono_rules hA).trans (Cl_mono_base hB)

/-- Idempotence. -/
@[simp] theorem Cl_idem : Cl A (Cl A B) = Cl A B :=
  Set.Subset.antisymm (Cl_subset subset_rfl Cl_stepClosed) subset_Cl

theorem Cl_eq_self_iff : Cl A X = X ↔ StepClosed A X := by
  constructor
  · intro h; rw [← h]; exact Cl_stepClosed
  · intro h; exact Set.Subset.antisymm (Cl_subset subset_rfl h) subset_Cl

theorem Cl_subset_iff_of_stepClosed (hX : StepClosed A X) : Cl A B ⊆ X ↔ B ⊆ X :=
  ⟨fun h => subset_Cl.trans h, fun h => Cl_subset h hX⟩

/-- With no rules nothing new is derivable. -/
@[simp] theorem Cl_empty_rules : Cl (∅ : Set (Step J)) B = B :=
  Set.Subset.antisymm (Cl_subset subset_rfl fun _ hs => absurd hs (Set.notMem_empty _)) subset_Cl

/-- Unions of rule sets: `Cl_{A ∪ A'}` contains both closures. -/
theorem Cl_union_rules_left : Cl A B ⊆ Cl (A ∪ A') B := Cl_mono_rules Set.subset_union_left
theorem Cl_union_rules_right : Cl A' B ⊆ Cl (A ∪ A') B := Cl_mono_rules Set.subset_union_right

/-! ### The derivable steps `Sound R` -/

/-- Every rule is a derivable step. -/
theorem subset_Sound : R ⊆ Sound R := fun _ hs =>
  concl_mem_Cl hs (subset_Cl (A := R))

theorem Sound_mono (h : R ⊆ A) : Sound R ⊆ Sound A := fun _ hs => Cl_mono_rules h hs

/-- Using derivable steps as rules derives nothing new. -/
@[simp] theorem Cl_Sound : Cl (Sound R) B = Cl R B := by
  apply Set.Subset.antisymm
  · refine Cl_subset subset_Cl ?_
    intro s hs hprem
    have : Cl R ↑s.prem ⊆ Cl R B := by
      rw [← Cl_idem (A := R) (B := B)]
      exact Cl_mono_base hprem
    exact this hs
  · exact Cl_mono_rules subset_Sound

@[simp] theorem Sound_Sound : Sound (Sound R) = Sound R := by
  ext s
  simp only [mem_Sound, Cl_Sound]

/-- **T1 Lemma 1.1 (reasoner soundness = stepwise soundness).**
`Cl_A(B) ⊆ Cl_R(B)` for every `B` iff every step of `A` is derivable in `R`. -/
theorem Cl_subset_Cl_iff_subset_Sound : (∀ B, Cl A B ⊆ Cl R B) ↔ A ⊆ Sound R := by
  constructor
  · intro h s hs
    exact h _ (concl_mem_Cl hs subset_Cl)
  · intro h B
    refine Cl_subset subset_Cl ?_
    intro s hs hprem
    have hsR : s.concl ∈ Cl R ↑s.prem := h hs
    have : Cl R ↑s.prem ⊆ Cl R B := by
      rw [← Cl_idem (A := R) (B := B)]
      exact Cl_mono_base hprem
    exact this hsR

/-! ### Finite support of derivations -/

open Classical in
/-- Every derivable judgment has a derivation using finitely many rules and leaves. -/
theorem exists_finite_of_mem_Cl (h : j ∈ Cl A B) :
    ∃ (A₀ : Finset (Step J)) (B₀ : Finset J), ↑A₀ ⊆ A ∧ ↑B₀ ⊆ B ∧ j ∈ Cl ↑A₀ ↑B₀ := by
  induction h with
  | @base j hj =>
    exact ⟨∅, {j}, by simp, by simpa using hj, subset_Cl (by simp)⟩
  | @step s hs _ ih =>
    choose A₁ B₁ hA₁ hB₁ hd using ih
    refine ⟨insert s (s.prem.attach.biUnion fun p => A₁ p.1 p.2),
      s.prem.attach.biUnion fun p => B₁ p.1 p.2, ?_, ?_, ?_⟩
    · intro t ht
      simp only [Finset.coe_insert, Set.mem_insert_iff, Finset.mem_coe, Finset.mem_biUnion,
        Finset.mem_attach, true_and] at ht
      rcases ht with rfl | ⟨p, hp⟩
      · exact hs
      · exact hA₁ p.1 p.2 hp
    · intro b hb
      simp only [Finset.coe_biUnion, Finset.mem_coe, Finset.mem_attach, Set.iUnion_true,
        Set.mem_iUnion] at hb
      obtain ⟨p, hp⟩ := hb
      exact hB₁ p.1 p.2 hp
    · refine concl_mem_Cl (by simp) ?_
      intro p hp
      have hp' : p ∈ s.prem := Finset.mem_coe.1 hp
      refine Cl_mono ?_ ?_ (hd p hp')
      · intro t ht
        simp only [Finset.coe_insert, Set.mem_insert_iff, Finset.mem_coe, Finset.mem_biUnion,
          Finset.mem_attach, true_and]
        exact Or.inr ⟨⟨p, hp'⟩, ht⟩
      · intro b hb
        simp only [Finset.coe_biUnion, Finset.mem_coe, Finset.mem_attach, Set.iUnion_true,
          Set.mem_iUnion]
        exact ⟨⟨p, hp'⟩, hb⟩

/-- Compactness of derivability in the leaves. -/
theorem exists_finset_base_of_mem_Cl (h : j ∈ Cl A B) :
    ∃ B₀ : Finset J, ↑B₀ ⊆ B ∧ j ∈ Cl A ↑B₀ := by
  obtain ⟨A₀, B₀, hA, hB, hj⟩ := exists_finite_of_mem_Cl h
  exact ⟨B₀, hB, Cl_mono_rules hA hj⟩

/-- Compactness of derivability in the rules. -/
theorem exists_finset_rules_of_mem_Cl (h : j ∈ Cl A B) :
    ∃ A₀ : Finset (Step J), ↑A₀ ⊆ A ∧ j ∈ Cl ↑A₀ B := by
  obtain ⟨A₀, B₀, hA, hB, hj⟩ := exists_finite_of_mem_Cl h
  exact ⟨A₀, hA, Cl_mono_base hB hj⟩

end Closure

/-! ### `Cl_A` as a consequence operator -/

/-- The consequence operator `B ↦ Cl_A(B)` generated by a rule set. -/
def ClOp (A : Set (Step J)) : ConsOp J where
  toFun := Cl A
  extensive _ := subset_Cl
  monotone _ _ h := Cl_mono_base h
  idempotent _ := Cl_idem

@[simp] theorem ClOp_apply (A : Set (Step J)) (B : Set J) : ClOp A B = Cl A B := rfl

/-- Rule-generated consequence operators are finitary. -/
theorem ClOp_finitary (A : Set (Step J)) : (ClOp A).Finitary :=
  fun _ _ h => exists_finset_base_of_mem_Cl h

/-- `ClOp A ≤ C` iff every step of `A` is valid in `C` (`j ∈ C Π`). -/
theorem ClOp_le_iff {A : Set (Step J)} {C : ConsOp J} :
    ClOp A ≤ C ↔ ∀ s ∈ A, s.concl ∈ C ↑s.prem := by
  constructor
  · intro h s hs
    exact h _ (concl_mem_Cl hs subset_Cl)
  · intro h B
    refine Cl_subset (C.subset_apply B) ?_
    intro s hs hprem
    exact C.mem_trans hprem (h s hs)

theorem ClOp_mono {A A' : Set (Step J)} (h : A ⊆ A') : ClOp A ≤ ClOp A' :=
  fun _ => Cl_mono_rules h

/-! ### Steps over propositional formulas -/

section Formula

/-- Apply a substitution to a step (premises and conclusion). -/
def Step.subst (σ : Subst) (s : Step Formula) : Step Formula :=
  ⟨s.prem.image (Formula.subst σ), s.concl.subst σ⟩

@[simp] theorem Step.subst_prem (σ : Subst) (s : Step Formula) :
    (s.subst σ).prem = s.prem.image (Formula.subst σ) := rfl

@[simp] theorem Step.subst_concl (σ : Subst) (s : Step Formula) :
    (s.subst σ).concl = s.concl.subst σ := rfl

theorem Step.coe_subst_prem (σ : Subst) (s : Step Formula) :
    (↑(s.subst σ).prem : Set Formula) = Formula.subst σ '' ↑s.prem := by
  simp

theorem Step.subst_subst (σ τ : Subst) (s : Step Formula) :
    (s.subst τ).subst σ = s.subst (Subst.comp σ τ) := by
  cases s
  simp only [Step.subst, Finset.image_image, Step.mk.injEq]
  constructor
  · congr 1
    funext φ
    simp
  · simp

/-- A rule set is substitution-closed (a union of instance sets of pure schemas). -/
def SubstClosed (A : Set (Step Formula)) : Prop := ∀ s ∈ A, ∀ σ : Subst, s.subst σ ∈ A

/-- All substitution instances of the steps in `D`. -/
def substClosure (D : Set (Step Formula)) : Set (Step Formula) :=
  {t | ∃ s ∈ D, ∃ σ : Subst, t = s.subst σ}

@[simp] theorem Step.subst_id (s : Step Formula) : s.subst Subst.id = s := by
  cases s
  simp only [Step.subst, Step.mk.injEq]
  have : (Formula.subst Subst.id) = id := funext Subst.subst_id'
  rw [this, Finset.image_id]
  simp

theorem subset_substClosure (D : Set (Step Formula)) : D ⊆ substClosure D :=
  fun s hs => ⟨s, hs, Subst.id, (Step.subst_id s).symm⟩

theorem substClosure_substClosed (D : Set (Step Formula)) : SubstClosed (substClosure D) := by
  rintro _ ⟨s, hs, τ, rfl⟩ σ
  exact ⟨s, hs, Subst.comp σ τ, Step.subst_subst σ τ s⟩

/-- Derivations are preserved by substitution when the rule set is substitution-closed. -/
theorem Cl_subst {A : Set (Step Formula)} (hA : SubstClosed A) {B : Set Formula}
    {φ : Formula} (h : φ ∈ Cl A B) (σ : Subst) : φ.subst σ ∈ Cl A (Formula.subst σ '' B) := by
  induction h with
  | base hj => exact subset_Cl ⟨_, hj, rfl⟩
  | @step s hs _ ih =>
    have := concl_mem_Cl (B := Formula.subst σ '' B) (hA s hs σ) ?_
    · simpa using this
    · rw [Step.coe_subst_prem]
      rintro _ ⟨p, hp, rfl⟩
      exact ih p (Finset.mem_coe.1 hp)

/-- A substitution-closed rule set generates a structural consequence operator. -/
theorem ClOp_structural {A : Set (Step Formula)} (hA : SubstClosed A) : Structural (ClOp A) :=
  structural_iff.2 fun σ _ _ h => Cl_subst hA h σ

/-- `⟨D⟩ := ClOp (substClosure D)` is the least structural consequence operator in which all
steps of `D` are valid (T2 §3.2). -/
theorem ClOp_substClosure_le {D : Set (Step Formula)} {C : ConsOp Formula}
    (hC : Structural C) (hD : ∀ s ∈ D, s.concl ∈ C ↑s.prem) : ClOp (substClosure D) ≤ C := by
  rw [ClOp_le_iff]
  rintro _ ⟨s, hs, σ, rfl⟩
  have := hC.mem_subst (hD s hs) σ
  simpa [Step.coe_subst_prem] using this

theorem ClOp_substClosure_structural (D : Set (Step Formula)) :
    Structural (ClOp (substClosure D)) :=
  ClOp_structural (substClosure_substClosed D)

/-- The classically (CPC-)sound steps: `Π ⊨ j`. -/
def SemSound : Set (Step Formula) := {s | SemCons ↑s.prem s.concl}

@[simp] theorem mem_SemSound {s : Step Formula} : s ∈ SemSound ↔ SemCons ↑s.prem s.concl :=
  Iff.rfl

theorem SemSound_substClosed : SubstClosed SemSound := by
  intro s hs σ
  rw [mem_SemSound, Step.coe_subst_prem]
  exact SemCons.subst hs σ

/-- Steps that are all classically sound only derive classical consequences. -/
theorem Cl_subset_Cn2 {A : Set (Step Formula)} (hA : A ⊆ SemSound) (B : Set Formula) :
    Cl A B ⊆ Cn2 B :=
  ClOp_le_iff.2 (fun _ hs => hA hs) B

theorem ClOp_le_Cn2_iff {A : Set (Step Formula)} : ClOp A ≤ Cn2 ↔ A ⊆ SemSound :=
  ClOp_le_iff

end Formula

end InfLearn
