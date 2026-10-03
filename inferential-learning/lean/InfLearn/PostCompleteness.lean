import InfLearn.Steps

/-!
# Structural Post-completeness of classical consequence (T2 §3; T7 Lemma 6.1)

This file formalizes:

* **T2 Theorem 3.1** (structural Post-completeness): every structural consequence operator
  `C` with `Cn2 ≤ C` (i.e. `C ⊇ 𝐂₂`) is `Cn2` or the trivial operator `C_Fm`.
  - `Post.eq_Cn2_or_eq_trivial` : the full language `{⊥, ⊤, ¬, ∧, ∨, →}` (the shared
    `Formula` type), proved with the substitution `σ_v = Subst.ofVal v` (atoms ↦ `⊤`/`⊥`).
  - `Post.frag_eq_Cn2F_or_eq_trivial` : *every* connective fragment `L` that contains `→`, or
    contains `¬` together with `∧` or `∨`, with consequence operators on the fragment's own
    formula type `FragFm L` and structurality with respect to the fragment's substitutions.
    The paper's two cases are the corollaries `Post.frag_postComplete_neg` ("`¬` and one of
    `∧, ∨, →`") and `Post.impFrag_postComplete` (the pure `{→}` language).  These use
    `⊤₀ := p₀ → p₀`, `¬(p₀ ∧ ¬p₀)` or `p₀ ∨ ¬p₀` and `⊥₀ := ¬⊤₀`, and, for `→`-fragments
    without `¬`/`⊥`, the paper's `σ_v(p) ∈ {p₀ → p₀, p₀}`.
* **T2 Theorem 3.3** (coherence pins CPC):
  - `Post.eq_Cn2_of_coherent`, `Post.eq_Cn2_of_consistent`, `Post.eq_Cn2_of_satisfiable_coherent` :
    a structural `C ⊇ Cn2` with one coherent context is `Cn2`.
  - (a) `Post.versionSpace_eq_singleton_iff` : for `D ⊆ 𝐂₂` and a satisfiable `A₀`,
    `𝒮(D, A₀) = {𝐂₂} ↔ ⟨D⟩ = 𝐂₂`.
  - (b) `Post.learner_identifies` : the "least eligible index" learner identifies `𝐂₂` in the
    limit on every text, its conjectures never decrease and never exceed `i*`, and
    `Post.learner_mindChanges_le` gives at most `i*` mind changes.
  - (c) `Post.Cn2Add_*` shows that structurality cannot be dropped, and
    `Post.trivial_ne_Cn2` / `Post.trivial_validates` that the coherence datum cannot be dropped.
* **T2 Prop 3.5(a)**, consequence-level form (structural completeness, a by-product of the same
  argument): `Post.le_Cn2_of_empty_eq_Taut`, so `𝐂₂` is the largest structural consequence
  operator whose theorems are the tautologies.
* **T7 Lemma 6.1** (closed-instance refutability, Post's substitution):
  `Post.schema_invalid_iff_closedRefutation` and
  `Post.exists_invalid_instance_iff_closedRefutation`.  The size and count claims are
  `Post.size_subst_ofVal` (each formula keeps its size), `Post.stepSize_closedInstance_le`,
  `Post.closedInstance_isClosed`, `Post.mem_candidates` and
  `Post.card_candidates_le` (at most `2 ^ v(τ)` candidates).  The resulting finite decision
  criterion is `Post.mem_SemSound_iff_candidates`.

Everything lives in the namespace `InfLearn.Post`.
-/

namespace InfLearn

namespace Post

open Formula

/-! ## Part 1. Thm 3.1 for the full language -/

section Full

variable {C : ConsOp Formula}

/-- Step 3 of the proof of T2 Thm 3.1: for structural `C`, if `φ ∈ C X` and a substitution
maps `X` into the theorems `C ∅`, then it maps `φ` into the theorems too. -/
theorem subst_mem_empty_of_image_subset (hC : Structural C) {X : Set Formula} {φ : Formula}
    (hφ : φ ∈ C X) (s : Subst) (hX : Formula.subst s '' X ⊆ C ∅) : φ.subst s ∈ C ∅ :=
  C.mem_trans hX (hC.mem_subst hφ s)

/-- If `C ⊇ 𝐂₂` then every tautology is a `C`-theorem: `Taut = 𝐂₂(∅) ⊆ C(∅)`. -/
theorem Taut_subset_empty (h2 : Cn2 ≤ C) : Taut ⊆ C ∅ := by
  rw [← Cn2_empty]; exact h2 ∅

/-- Step 2 of the proof of T2 Thm 3.1: if `v ⊨ X` then `σ_v X ⊆ Taut`. -/
theorem image_ofVal_subset_Taut {v : Valuation} {X : Set Formula} (hv : Satisfies v X) :
    Formula.subst (Subst.ofVal v) '' X ⊆ Taut := by
  rintro _ ⟨ψ, hψ, rfl⟩ u
  rw [eval_subst_ofVal]
  exact hv ψ hψ

/-- Step 2 of the proof of T2 Thm 3.1: if `v(φ) = 0` then `σ_v φ` is a contradiction. -/
theorem eval_subst_ofVal_of_false {v : Valuation} {φ : Formula} (h : φ.eval v = false)
    (u : Valuation) : (φ.subst (Subst.ofVal v)).eval u = false := by
  rw [eval_subst_ofVal]; exact h

/-- If `C` proves everything from no premises, then `C` is the trivial operator. -/
theorem eq_trivial_of_empty_eq_univ (h : C ∅ = Set.univ) : C = ConsOp.trivial Formula := by
  apply ConsOp.ext
  intro X
  rw [ConsOp.trivial_apply]
  apply Set.eq_univ_of_univ_subset
  rw [← h]
  exact C.apply_empty_subset X

/-- Step 4 of the proof of T2 Thm 3.1: if a contradiction is a `C`-theorem and `C ⊇ 𝐂₂`, then
`C(∅) = Fm`. -/
theorem empty_eq_univ_of_unsat_mem (h2 : Cn2 ≤ C) {ψ : Formula} (hψ : ψ ∈ C ∅)
    (hu : ∀ u, ψ.eval u = false) : C ∅ = Set.univ := by
  apply Set.eq_univ_of_univ_subset
  intro χ _
  have hχ : χ ∈ Cn2 {ψ} := by
    intro u hu'
    have := hu' ψ rfl
    rw [hu u] at this
    exact absurd this Bool.false_ne_true
  exact C.mem_trans (Set.singleton_subset_iff.2 hψ) (h2 {ψ} hχ)

/-- **T2 Theorem 3.1 (structural Post-completeness of `𝐂₂`), full language.**
Every structural consequence operator `C ⊇ 𝐂₂` (not necessarily finitary) is either `𝐂₂` or the
trivial operator `C_Fm`. -/
theorem eq_Cn2_or_eq_trivial (hC : Structural C) (h2 : Cn2 ≤ C) :
    C = Cn2 ∨ C = ConsOp.trivial Formula := by
  by_cases hle : C ≤ Cn2
  · exact Or.inl (le_antisymm hle h2)
  · right
    simp only [ConsOp.le_def, not_forall] at hle
    obtain ⟨X, hX⟩ := hle
    obtain ⟨φ, hφC, hφ2⟩ := Set.not_subset.1 hX
    simp only [mem_Cn2, SemCons, not_forall] at hφ2
    obtain ⟨v, hv, hφv⟩ := hφ2
    have hφv' : φ.eval v = false := by simpa using hφv
    have hmem : φ.subst (Subst.ofVal v) ∈ C ∅ :=
      subst_mem_empty_of_image_subset hC hφC (Subst.ofVal v)
        ((image_ofVal_subset_Taut hv).trans (Taut_subset_empty h2))
    exact eq_trivial_of_empty_eq_univ
      (empty_eq_univ_of_unsat_mem h2 hmem (eval_subst_ofVal_of_false hφv'))

/-- The trivial operator is not `𝐂₂` (it proves `⊥` from `∅`). -/
theorem trivial_ne_Cn2 : ConsOp.trivial Formula ≠ Cn2 := by
  intro h
  have : bot ∈ Cn2 ∅ := by rw [← h]; trivial
  have := (SemCons.empty_iff.1 this) (fun _ => false)
  simp at this

/-- The two members of the dichotomy are structural extensions of `𝐂₂`, so Thm 3.1 is sharp. -/
theorem structural_extensions_Cn2 :
    {C : ConsOp Formula | Structural C ∧ Cn2 ≤ C} = {Cn2, ConsOp.trivial Formula} := by
  ext C
  simp only [Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff]
  constructor
  · rintro ⟨hC, h2⟩; exact eq_Cn2_or_eq_trivial hC h2
  · rintro (rfl | rfl)
    · exact ⟨Cn2_structural, le_refl _⟩
    · exact ⟨trivial_structural, ConsOp.le_trivial _⟩

/-! ### Coherence pins CPC (T2 Thm 3.3, first step of (a)) -/

/-- **Coherence pins CPC.** A structural `C ⊇ 𝐂₂` with one coherent context (`C A ≠ Fm`) is
`𝐂₂`. -/
theorem eq_Cn2_of_coherent (hC : Structural C) (h2 : Cn2 ≤ C) {A : Set Formula}
    (hA : C.Coherent A) : C = Cn2 :=
  (eq_Cn2_or_eq_trivial hC h2).resolve_right (by rintro rfl; exact hA rfl)

/-- The same, with coherence read as consistency (`A ⊬_C ⊥`). -/
theorem eq_Cn2_of_consistent (hC : Structural C) (h2 : Cn2 ≤ C) {A : Set Formula}
    (hA : Consistent C A) : C = Cn2 :=
  eq_Cn2_of_coherent hC h2 (fun h => hA (h ▸ Set.mem_univ _))

/-- The form in the task statement: a designated classically satisfiable context `A` with
`C A ≠ Fm`.  The satisfiability hypothesis is not needed: it follows from the conclusion. -/
theorem eq_Cn2_of_satisfiable_coherent (hC : Structural C) (h2 : Cn2 ≤ C) {A : Set Formula}
    (_hsat : Satisfiable A) (hA : C A ≠ Set.univ) : C = Cn2 :=
  eq_Cn2_of_coherent hC h2 hA

/-- For structural `C ⊇ 𝐂₂`: `C = 𝐂₂` iff some context is `C`-coherent. -/
theorem eq_Cn2_iff_exists_coherent (hC : Structural C) (h2 : Cn2 ≤ C) :
    C = Cn2 ↔ ∃ A, C.Coherent A := by
  constructor
  · rintro rfl
    refine ⟨∅, ?_⟩
    rw [Cn2_coherent_iff_consistent, Cn2_consistent_iff]
    exact ⟨fun _ => false, satisfies_empty _⟩
  · rintro ⟨A, hA⟩; exact eq_Cn2_of_coherent hC h2 hA

/-! ### Structural completeness (T2 Prop 3.5(a), consequence-level form) -/

/-- Every structural consequence operator whose theorems are exactly the tautologies is
contained in `𝐂₂` (structural completeness of CPC).  Together with `Cn2_structural` and
`Cn2_empty`, `𝐂₂` is the largest such operator. -/
theorem le_Cn2_of_empty_eq_Taut (hC : Structural C) (hT : C ∅ = Taut) : C ≤ Cn2 := by
  intro X φ hφ v hv
  have hmem : φ.subst (Subst.ofVal v) ∈ C ∅ :=
    subst_mem_empty_of_image_subset hC hφ (Subst.ofVal v)
      (hT ▸ image_ofVal_subset_Taut hv)
  rw [hT] at hmem
  have := hmem (fun _ => false)
  rwa [eval_subst_ofVal] at this

end Full

/-! ## Part 2. T2 Thm 3.3(a): the structural version space -/

section VersionSpace

/-- `h` validates every step of `D` (the paper's `D ⊆ h`). -/
def Validates (h : ConsOp Formula) (D : Set (Step Formula)) : Prop :=
  ∀ s ∈ D, s.concl ∈ h ↑s.prem

/-- The structural version space `𝒮(D, A₀) = {h structural : D ⊆ h, A₀ ⊬_h ⊥}` (T2 §3.2).
Hypotheses `h` are arbitrary (not necessarily finitary) structural consequence operators. -/
def versionSpace (D : Set (Step Formula)) (A₀ : Set Formula) : Set (ConsOp Formula) :=
  {h | Structural h ∧ Validates h D ∧ Consistent h A₀}

/-- `⟨D⟩`, the least structural consequence operator validating `D`
(see `ClOp_substClosure_le`). -/
abbrev gen (D : Set (Step Formula)) : ConsOp Formula := ClOp (substClosure D)

theorem gen_le_Cn2 {D : Set (Step Formula)} (hD : D ⊆ SemSound) : gen D ≤ Cn2 := by
  rw [ClOp_le_Cn2_iff]
  rintro _ ⟨s, hs, σ, rfl⟩
  exact SemSound_substClosed s (hD hs) σ

theorem gen_validates (D : Set (Step Formula)) : Validates (gen D) D := fun _ hs =>
  concl_mem_Cl (subset_substClosure D hs) subset_Cl

theorem Cn2_mem_versionSpace {D : Set (Step Formula)} {A₀ : Set Formula} (hD : D ⊆ SemSound)
    (hA : Satisfiable A₀) : Cn2 ∈ versionSpace D A₀ :=
  ⟨Cn2_structural, fun _ hs => hD hs, Cn2_consistent_iff.2 hA⟩

theorem gen_mem_versionSpace {D : Set (Step Formula)} {A₀ : Set Formula} (hD : D ⊆ SemSound)
    (hA : Satisfiable A₀) : gen D ∈ versionSpace D A₀ :=
  ⟨ClOp_substClosure_structural D, gen_validates D,
    fun h => (Cn2_consistent_iff.2 hA) (gen_le_Cn2 hD A₀ h)⟩

/-- Every member of the version space extends `⟨D⟩`. -/
theorem gen_le_of_mem_versionSpace {D : Set (Step Formula)} {A₀ : Set Formula}
    {h : ConsOp Formula} (hh : h ∈ versionSpace D A₀) : gen D ≤ h :=
  ClOp_substClosure_le hh.1 hh.2.1

/-- **T2 Theorem 3.3(a) (finite collapse).** For classically valid data `D` and a designated
satisfiable context `A₀`: `𝒮(D, A₀) = {𝐂₂}` iff `⟨D⟩ = 𝐂₂`.  (The claim that a *finite* `D`
suffices rests on the cited completeness of a Hilbert system, which is not formalized here.) -/
theorem versionSpace_eq_singleton_iff {D : Set (Step Formula)} {A₀ : Set Formula}
    (hD : D ⊆ SemSound) (hA : Satisfiable A₀) :
    versionSpace D A₀ = {Cn2} ↔ gen D = Cn2 := by
  constructor
  · intro h
    have := gen_mem_versionSpace hD hA
    rw [h] at this
    exact this
  · intro hg
    ext h
    rw [Set.mem_singleton_iff]
    constructor
    · intro hh
      have h2 : Cn2 ≤ h := hg ▸ gen_le_of_mem_versionSpace hh
      exact eq_Cn2_of_consistent hh.1 h2 hh.2.2
    · rintro rfl; exact Cn2_mem_versionSpace hD hA

end VersionSpace

/-! ## Part 3. T2 Thm 3.3(b): identification in the limit without bias -/

section Identification

open Classical

variable (H : ℕ → ConsOp Formula) (A₀ : Set Formula) (t : ℕ → Step Formula)

/-- Index `i` is *eligible* after the first `n` data `t 0, …, t (n-1)`: `H i` validates
them and `A₀ ⊬_{H i} ⊥`. -/
def Eligible (n i : ℕ) : Prop :=
  (∀ k < n, (t k).concl ∈ H i ↑(t k).prem) ∧ Consistent (H i) A₀

/-- The learner `M` of T2 Thm 3.3(b): output the least eligible index (`0` if none). It is
defined classically, so the paper's "uniformly decidable" hypothesis, which is only needed
to make `M` computable, is not used. -/
noncomputable def learner (n : ℕ) : ℕ :=
  if h : ∃ i, Eligible H A₀ t n i then Nat.find h else 0

variable {H A₀ t}

theorem Eligible.anti {n m i : ℕ} (hnm : n ≤ m) (h : Eligible H A₀ t m i) :
    Eligible H A₀ t n i :=
  ⟨fun k hk => h.1 k (lt_of_lt_of_le hk hnm), h.2⟩

theorem eligible_star {istar : ℕ} (hstar : H istar = Cn2) (hA : Satisfiable A₀)
    (ht : ∀ k, t k ∈ SemSound) (n : ℕ) : Eligible H A₀ t n istar := by
  refine ⟨fun k _ => ?_, ?_⟩
  · rw [hstar]; exact ht k
  · rw [hstar]; exact Cn2_consistent_iff.2 hA

/-- Every index below `i*` is eventually and permanently rejected. -/
theorem eventually_not_eligible (hH : ∀ i, Structural (H i))
    (ht : SemSound ⊆ Set.range t) {j : ℕ} (hj : H j ≠ Cn2) :
    ∃ N, ∀ n ≥ N, ¬ Eligible H A₀ t n j := by
  by_cases h2 : Cn2 ≤ H j
  · -- `H j ⊇ 𝐂₂`, so `H j = C_Fm` by Thm 3.1, which `A₀` rejects at once.
    have htriv := (eq_Cn2_or_eq_trivial (hH j) h2).resolve_left hj
    refine ⟨0, fun n _ he => he.2 ?_⟩
    rw [htriv]; trivial
  · -- Some classically valid finite step is not in `H j`; it appears in the text.
    simp only [ConsOp.le_def, not_forall] at h2
    obtain ⟨X, hX⟩ := h2
    obtain ⟨φ, hφ2, hφH⟩ := Set.not_subset.1 hX
    obtain ⟨F, hFX, hF⟩ := SemCons.exists_finset hφ2
    obtain ⟨k, hk⟩ := ht (show (⟨F, φ⟩ : Step Formula) ∈ SemSound from hF)
    refine ⟨k + 1, fun n hn he => hφH ?_⟩
    have := he.1 k (by omega)
    rw [hk] at this
    exact (H j).mono hFX this

/-- **T2 Theorem 3.3(b) (identification without bias).** Let `(H i)` be any family of
structural consequence operators and `i*` the least index of `𝐂₂`.  On every text `t` for `𝐂₂`
(an enumeration of exactly the classically valid finite-premise steps) and with a satisfiable
designated context `A₀`, the least-eligible-index learner
* never conjectures beyond `i*`,
* never decreases its conjecture, and
* converges to `i*`.

This holds for every ordering of the family. -/
theorem learner_identifies (hH : ∀ i, Structural (H i)) {istar : ℕ} (hstar : H istar = Cn2)
    (hmin : ∀ j < istar, H j ≠ Cn2) (hA : Satisfiable A₀) (ht : Set.range t = SemSound) :
    (∀ n, learner H A₀ t n ≤ istar) ∧ Monotone (learner H A₀ t) ∧
      ∃ N, ∀ n ≥ N, learner H A₀ t n = istar := by
  have htS : ∀ k, t k ∈ SemSound := fun k => ht ▸ Set.mem_range_self k
  have hex : ∀ n, ∃ i, Eligible H A₀ t n i := fun n => ⟨istar, eligible_star hstar hA htS n⟩
  have hl : ∀ n, learner H A₀ t n = Nat.find (hex n) := fun n => by
    simp only [learner, dif_pos (hex n)]
  have hle : ∀ n, learner H A₀ t n ≤ istar := fun n => by
    rw [hl]; exact Nat.find_min' _ (eligible_star hstar hA htS n)
  refine ⟨hle, ?_, ?_⟩
  · intro n m hnm
    rw [hl, hl]
    exact Nat.find_min' _ ((Nat.find_spec (hex m)).anti hnm)
  · -- all indices below `i*` are rejected from some time on
    have key : ∀ m ≤ istar, ∃ N, ∀ n ≥ N, ∀ j < m, ¬ Eligible H A₀ t n j := by
      intro m
      induction m with
      | zero => exact fun _ => ⟨0, fun _ _ j hj => absurd hj (Nat.not_lt_zero j)⟩
      | succ m ih =>
        intro hm
        obtain ⟨N₁, hN₁⟩ := ih (Nat.le_of_succ_le hm)
        obtain ⟨N₂, hN₂⟩ := eventually_not_eligible hH (by rw [ht])
          (hmin m (Nat.lt_of_succ_le hm))
        refine ⟨max N₁ N₂, fun n hn j hj => ?_⟩
        rcases Nat.lt_succ_iff_lt_or_eq.1 hj with hj | rfl
        · exact hN₁ n (le_of_max_le_left hn) j hj
        · exact hN₂ n (le_of_max_le_right hn)
    obtain ⟨N, hN⟩ := key istar le_rfl
    refine ⟨N, fun n hn => le_antisymm (hle n) ?_⟩
    rw [hl]
    by_contra hlt
    rw [not_le] at hlt
    exact hN n hn _ hlt (Nat.find_spec (hex n))

/-- A non-decreasing `ℕ`-valued sequence changes value at most `f N - f 0` times before `N`. -/
theorem card_changes_le {f : ℕ → ℕ} (hf : Monotone f) (N : ℕ) :
    ((Finset.range N).filter (fun n => f (n + 1) ≠ f n)).card ≤ f N - f 0 := by
  induction N with
  | zero => simp
  | succ N ih =>
    rw [Finset.range_add_one, Finset.filter_insert]
    have h1 : f N ≤ f (N + 1) := hf (Nat.le_succ N)
    have h0 : f 0 ≤ f N := hf (Nat.zero_le N)
    split_ifs with h
    · rw [Finset.card_insert_of_notMem (by simp)]
      have : f N < f (N + 1) := lt_of_le_of_ne h1 (Ne.symm h)
      omega
    · omega

/-- **T2 Thm 3.3(b), mind-change bound:** at most `i*` mind changes, on every text. -/
theorem learner_mindChanges_le (hH : ∀ i, Structural (H i)) {istar : ℕ}
    (hstar : H istar = Cn2) (hmin : ∀ j < istar, H j ≠ Cn2) (hA : Satisfiable A₀)
    (ht : Set.range t = SemSound) (N : ℕ) :
    ((Finset.range N).filter
      (fun n => learner H A₀ t (n + 1) ≠ learner H A₀ t n)).card ≤ istar := by
  obtain ⟨hle, hmono, -⟩ := learner_identifies hH hstar hmin hA ht
  exact (card_changes_le hmono N).trans ((Nat.sub_le _ _).trans (hle N))

end Identification

/-! ## Part 4. T2 Thm 3.3(c): each assumption is needed -/

section Needed

/-- `𝐂₂` plus the non-structural axiom `⊳ p`: `X ↦ 𝐂₂(X ∪ {p})`. -/
def Cn2Add (p : ℕ) : ConsOp Formula :=
  ConsOp.mk' (fun X => Cn2 (insert (var p) X))
    (fun _ => (Set.subset_insert _ _).trans (Cn2.subset_apply _))
    (fun _ _ h => Cn2.mono (Set.insert_subset_insert h))
    (fun _ => Cn2.apply_subset_of_subset
      (Set.insert_subset (Cn2.mem_apply_of_mem (Set.mem_insert _ _)) subset_rfl))

theorem Cn2_le_Cn2Add (p : ℕ) : Cn2 ≤ Cn2Add p := fun _ =>
  Cn2.mono (Set.subset_insert _ _)

/-- `Cn2Add p` contains every text for `𝐂₂`. -/
theorem Cn2Add_validates (p : ℕ) : Validates (Cn2Add p) SemSound := fun _ hs =>
  Cn2_le_Cn2Add p _ hs

/-- `Cn2Add p` is `A₀`-coherent when `A₀` is satisfiable and `p` does not occur in `A₀`. -/
theorem Cn2Add_consistent {p : ℕ} {A₀ : Set Formula} (hA : Satisfiable A₀)
    (hp : ∀ ψ ∈ A₀, p ∉ ψ.atoms) : Consistent (Cn2Add p) A₀ := by
  obtain ⟨v, hv⟩ := hA
  intro hbot
  have := hbot (Function.update v p true) ?_
  · simp at this
  · rw [satisfies_insert]
    refine ⟨by simp, fun ψ hψ => ?_⟩
    rw [← hv ψ hψ]
    apply eval_congr
    intro n hn
    have : n ≠ p := fun h => hp ψ hψ (h ▸ hn)
    simp [Function.update_of_ne this]

theorem Cn2Add_ne_Cn2 (p : ℕ) : Cn2Add p ≠ Cn2 := by
  intro h
  have hp : var p ∈ Cn2Add p ∅ :=
    show var p ∈ Cn2 (insert (var p) ∅) from Cn2.mem_apply_of_mem (Set.mem_insert _ _)
  rw [h] at hp
  have := (SemCons.empty_iff.1 hp) (fun _ => false)
  simp at this

/-- **T2 Thm 3.3(c), structurality is needed:** `Cn2Add p` extends `𝐂₂`, validates every
classically valid step, is `A₀`-coherent for a satisfiable `A₀` not mentioning `p`, and differs
from `𝐂₂`.  By Thm 3.1 it is therefore not structural. -/
theorem Cn2Add_not_structural (p : ℕ) : ¬ Structural (Cn2Add p) := by
  intro hS
  have hcons : Consistent (Cn2Add p) ∅ :=
    Cn2Add_consistent ⟨fun _ => false, satisfies_empty _⟩ (fun _ h => h.elim)
  exact Cn2Add_ne_Cn2 p (eq_Cn2_of_consistent hS (Cn2_le_Cn2Add p) hcons)

/-- **T2 Thm 3.3(c), a coherence datum is needed:** `C_Fm` is structural, extends `𝐂₂`, contains
every text, and is not `𝐂₂`. -/
theorem trivial_validates (D : Set (Step Formula)) :
    Validates (ConsOp.trivial Formula) D := fun _ _ => Set.mem_univ _

end Needed

/-! ## Part 5. Thm 3.1 for connective fragments (incl. the pure `{→}` language) -/

section Fragment

variable {L : Set Conn}

/-- The formulas of the fragment `L`: those whose connectives all lie in `L`. -/
abbrev FragFm (L : Set Conn) := {φ : Formula // φ.InFrag L}

/-- Substitutions of the fragment: atoms are sent to fragment formulas. -/
abbrev FragSubst (L : Set Conn) := ℕ → FragFm L

/-- Applying a fragment substitution to a fragment formula. -/
def fsubst (s : FragSubst L) (φ : FragFm L) : FragFm L :=
  ⟨φ.val.subst (fun n => (s n).val), InFrag.subst (fun n => (s n).prop) φ.prop⟩

/-- The atom `pₙ` as a fragment formula. -/
def fvar (n : ℕ) : FragFm L := ⟨var n, trivial⟩

/-- Structurality of an operator on the fragment's formulas (`σ C(X) ⊆ C(σ X)` for every
endomorphism `σ` of the fragment's formula algebra). -/
def FragStructural (C : ConsOp (FragFm L)) : Prop :=
  ∀ (s : FragSubst L) (X : Set (FragFm L)) (φ : FragFm L), φ ∈ C X → fsubst s φ ∈ C (fsubst s '' X)

/-- Classical consequence `𝐂₂` restricted to the fragment `L`. -/
def Cn2F (L : Set Conn) : ConsOp (FragFm L) :=
  ConsOp.mk' (fun X => {φ | SemCons (Subtype.val '' X) φ.val})
    (fun _ φ h => SemCons.of_mem ⟨φ, h, rfl⟩)
    (fun _ _ hXY _ h => SemCons.mono (Set.image_mono hXY) h)
    (fun _ _ h => SemCons.trans (by rintro _ ⟨ψ, hψ, rfl⟩; exact hψ) h)

theorem mem_Cn2F {X : Set (FragFm L)} {φ : FragFm L} :
    φ ∈ Cn2F L X ↔ SemCons (Subtype.val '' X) φ.val := Iff.rfl

/-- `𝐂₂` on the fragment is structural. -/
theorem Cn2F_structural : FragStructural (Cn2F L) := by
  intro s X φ hφ
  rw [mem_Cn2F]
  have := SemCons.subst hφ (fun n => (s n).val)
  have himg : Subtype.val '' (fsubst s '' X) =
      Formula.subst (fun n => (s n).val) '' (Subtype.val '' X) := by
    rw [Set.image_image, Set.image_image]; rfl
  rw [himg]
  exact this

variable {C : ConsOp (FragFm L)}

theorem frag_subst_mem_empty (hC : FragStructural C) {X : Set (FragFm L)} {φ : FragFm L}
    (hφ : φ ∈ C X) (s : FragSubst L) (hX : fsubst s '' X ⊆ C ∅) : fsubst s φ ∈ C ∅ :=
  C.mem_trans hX (hC s X φ hφ)

theorem frag_taut_mem_empty (h2 : Cn2F L ≤ C) {ψ : FragFm L} (hψ : Tautology ψ.val) :
    ψ ∈ C ∅ :=
  h2 ∅ (fun v _ => hψ v)

theorem frag_eq_trivial_of_empty_eq_univ (h : C ∅ = Set.univ) :
    C = ConsOp.trivial (FragFm L) := by
  apply ConsOp.ext
  intro X
  rw [ConsOp.trivial_apply]
  apply Set.eq_univ_of_univ_subset
  rw [← h]
  exact C.apply_empty_subset X

theorem frag_empty_eq_univ_of_unsat_mem (h2 : Cn2F L ≤ C) {ψ : FragFm L} (hψ : ψ ∈ C ∅)
    (hu : ∀ u, ψ.val.eval u = false) : C ∅ = Set.univ := by
  apply Set.eq_univ_of_univ_subset
  intro χ _
  have hχ : χ ∈ Cn2F L {ψ} := by
    intro u hu'
    have := hu' ψ.val ⟨ψ, rfl, rfl⟩
    rw [hu u] at this
    exact absurd this Bool.false_ne_true
  exact C.mem_trans (Set.singleton_subset_iff.2 hψ) (h2 {ψ} hχ)

/-- If the atom `p₀` is a theorem of a structural `C`, every formula is (its instance). -/
theorem frag_empty_eq_univ_of_var_mem (hC : FragStructural C) (h0 : fvar 0 ∈ C ∅) :
    C ∅ = Set.univ := by
  apply Set.eq_univ_of_univ_subset
  intro χ _
  have := hC (fun _ => χ) ∅ (fvar 0) h0
  rw [Set.image_empty] at this
  exact this

/-- Case 1 of the proof: the fragment has a tautology `⊤₀` and a contradiction `⊥₀`.
Then `σ_v(p) := ⊤₀ / ⊥₀` along `v` works exactly as for the full language. -/
theorem frag_eq_Cn2F_or_eq_trivial_of_const {T F : FragFm L} (hT : Tautology T.val)
    (hF : ∀ u, F.val.eval u = false) (hC : FragStructural C) (h2 : Cn2F L ≤ C) :
    C = Cn2F L ∨ C = ConsOp.trivial (FragFm L) := by
  by_cases hle : C ≤ Cn2F L
  · exact Or.inl (le_antisymm hle h2)
  · right
    simp only [ConsOp.le_def, not_forall] at hle
    obtain ⟨X, hX⟩ := hle
    obtain ⟨φ, hφC, hφ2⟩ := Set.not_subset.1 hX
    simp only [mem_Cn2F, SemCons, not_forall] at hφ2
    obtain ⟨v, hv, hφv⟩ := hφ2
    let σ : FragSubst L := fun n => if v n then T else F
    have hσ : ∀ (ψ : FragFm L) u, (fsubst σ ψ).val.eval u = ψ.val.eval v := by
      intro ψ u
      simp only [fsubst, eval_subst]
      congr 1
      funext n
      cases h : v n
      · simp [σ, h, hF u]
      · simp [σ, h, hT u]
    have hX' : fsubst σ '' X ⊆ C ∅ := by
      rintro _ ⟨ψ, hψ, rfl⟩
      apply frag_taut_mem_empty h2
      intro u
      rw [hσ]
      exact hv ψ.val ⟨ψ, hψ, rfl⟩
    have hmem := frag_subst_mem_empty hC hφC σ hX'
    apply frag_eq_trivial_of_empty_eq_univ
    refine frag_empty_eq_univ_of_unsat_mem h2 hmem (fun u => ?_)
    rw [hσ]
    simpa using hφv

/-- Formulas without `¬` and `⊥` are true under the all-true valuation. -/
theorem eval_allTrue_of_InFrag (hneg : Conn.neg ∉ L) (hbot : Conn.bot ∉ L) {ψ : Formula}
    (h : ψ.InFrag L) : ψ.eval (fun _ => true) = true := by
  induction ψ with
  | var n => rfl
  | bot => exact absurd h hbot
  | top => rfl
  | neg a _ => exact absurd h.1 hneg
  | and a b iha ihb => simp [iha h.2.1, ihb h.2.2]
  | or a b iha ihb => simp [iha h.2.1]
  | imp a b iha ihb => simp [ihb h.2.2]

/-- Case 2 of the proof (the paper's pure `{→}` argument, for any `→`-fragment without `¬`
and `⊥`): `σ_v(p) := p₀ → p₀` if `v(p) = 1` and `σ_v(p) := p₀` otherwise. -/
theorem frag_eq_Cn2F_or_eq_trivial_of_imp_pos (himp : Conn.imp ∈ L) (hneg : Conn.neg ∉ L)
    (hbot : Conn.bot ∉ L) (hC : FragStructural C) (h2 : Cn2F L ≤ C) :
    C = Cn2F L ∨ C = ConsOp.trivial (FragFm L) := by
  by_cases hle : C ≤ Cn2F L
  · exact Or.inl (le_antisymm hle h2)
  · right
    simp only [ConsOp.le_def, not_forall] at hle
    obtain ⟨X, hX⟩ := hle
    obtain ⟨φ, hφC, hφ2⟩ := Set.not_subset.1 hX
    simp only [mem_Cn2F, SemCons, not_forall] at hφ2
    obtain ⟨v, hv, hφv⟩ := hφ2
    have hφv' : φ.val.eval v = false := by simpa using hφv
    let T : FragFm L := ⟨imp (var 0) (var 0), by simp [InFrag, himp]⟩
    let σ : FragSubst L := fun n => if v n then T else fvar 0
    -- `σ_v ψ` evaluates under `u` like `ψ` under `n ↦ v n ∨ u p₀`
    have hσ : ∀ (ψ : FragFm L) u,
        (fsubst σ ψ).val.eval u = ψ.val.eval (fun n => v n || u 0) := by
      intro ψ u
      simp only [fsubst, eval_subst]
      congr 1
      funext n
      cases h : v n
      · simp [σ, h, fvar]
      · cases h0 : u 0 <;> simp [σ, h, T, h0]
    have hval : ∀ (ψ : FragFm L) u, u 0 = false → (fsubst σ ψ).val.eval u = ψ.val.eval v := by
      intro ψ u hu
      rw [hσ]
      congr 1
      funext n
      simp [hu]
    have hval' : ∀ (ψ : FragFm L) u, u 0 = true → (fsubst σ ψ).val.eval u = true := by
      intro ψ u hu
      rw [hσ]
      have : (fun n => v n || u 0) = fun _ => true := by funext n; simp [hu]
      rw [this]
      exact eval_allTrue_of_InFrag hneg hbot ψ.prop
    have hX' : fsubst σ '' X ⊆ C ∅ := by
      rintro _ ⟨ψ, hψ, rfl⟩
      apply frag_taut_mem_empty h2
      intro u
      cases hu : u 0
      · rw [hval ψ u hu]; exact hv ψ.val ⟨ψ, hψ, rfl⟩
      · exact hval' ψ u hu
    have hmem := frag_subst_mem_empty hC hφC σ hX'
    -- `σ_v φ ≡₂ p₀`, so `p₀ ∈ 𝐂₂{σ_v φ} ⊆ C(C ∅) = C ∅`
    have hp0 : fvar 0 ∈ Cn2F L {fsubst σ φ} := by
      intro u hu
      have h1 := hu _ ⟨fsubst σ φ, rfl, rfl⟩
      show u 0 = true
      cases hu0 : u 0
      · rw [hval φ u hu0, hφv'] at h1; exact h1
      · rfl
    have h0 : fvar 0 ∈ C ∅ := C.mem_trans (Set.singleton_subset_iff.2 hmem) (h2 _ hp0)
    exact frag_eq_trivial_of_empty_eq_univ (frag_empty_eq_univ_of_var_mem hC h0)

/-- **T2 Theorem 3.1 for connective fragments.** If the fragment `L` contains `→`, or contains
`¬` together with `∧` or `∨`, then every structural consequence operator on the `L`-formulas
extending classical consequence is `𝐂₂` or trivial.  This is slightly more general than the
paper's hypothesis "`¬` and one of `∧, ∨, →`, or pure `{→}`": any fragment with `→` works. -/
theorem frag_eq_Cn2F_or_eq_trivial
    (hL : Conn.imp ∈ L ∨ (Conn.neg ∈ L ∧ (Conn.and ∈ L ∨ Conn.or ∈ L)))
    (hC : FragStructural C) (h2 : Cn2F L ≤ C) :
    C = Cn2F L ∨ C = ConsOp.trivial (FragFm L) := by
  rcases hL with himp | ⟨hneg, hand | hor⟩
  · by_cases hneg : Conn.neg ∈ L
    · exact frag_eq_Cn2F_or_eq_trivial_of_const
        (T := ⟨imp (var 0) (var 0), by simp [InFrag, himp]⟩)
        (F := ⟨neg (imp (var 0) (var 0)), by simp [InFrag, himp, hneg]⟩)
        (fun u => by simp) (fun u => by simp) hC h2
    · by_cases hbot : Conn.bot ∈ L
      · exact frag_eq_Cn2F_or_eq_trivial_of_const
          (T := ⟨imp (var 0) (var 0), by simp [InFrag, himp]⟩)
          (F := ⟨bot, by simpa [InFrag] using hbot⟩)
          (fun u => by simp) (fun u => by simp) hC h2
      · exact frag_eq_Cn2F_or_eq_trivial_of_imp_pos himp hneg hbot hC h2
  · exact frag_eq_Cn2F_or_eq_trivial_of_const
      (T := ⟨neg (and (var 0) (neg (var 0))), by simp [InFrag, hand, hneg]⟩)
      (F := ⟨and (var 0) (neg (var 0)), by simp [InFrag, hand, hneg]⟩)
      (fun u => by simp) (fun u => by simp) hC h2
  · exact frag_eq_Cn2F_or_eq_trivial_of_const
      (T := ⟨or (var 0) (neg (var 0)), by simp [InFrag, hor, hneg]⟩)
      (F := ⟨neg (or (var 0) (neg (var 0))), by simp [InFrag, hor, hneg]⟩)
      (fun u => by simp) (fun u => by simp) hC h2

/-- **T2 Thm 3.1, first case as stated:** the language contains `¬` and one of `∧, ∨, →`. -/
theorem frag_postComplete_neg (hneg : Conn.neg ∈ L)
    (h : Conn.and ∈ L ∨ Conn.or ∈ L ∨ Conn.imp ∈ L) (hC : FragStructural C)
    (h2 : Cn2F L ≤ C) : C = Cn2F L ∨ C = ConsOp.trivial (FragFm L) := by
  apply frag_eq_Cn2F_or_eq_trivial _ hC h2
  rcases h with h | h | h
  · exact Or.inr ⟨hneg, Or.inl h⟩
  · exact Or.inr ⟨hneg, Or.inr h⟩
  · exact Or.inl h

/-- **T2 Thm 3.1, second case as stated:** the pure implicational language `{→}`. -/
theorem impFrag_postComplete {C : ConsOp (FragFm {Conn.imp})} (hC : FragStructural C)
    (h2 : Cn2F {Conn.imp} ≤ C) : C = Cn2F {Conn.imp} ∨ C = ConsOp.trivial _ :=
  frag_eq_Cn2F_or_eq_trivial (Or.inl rfl) hC h2

end Fragment

/-! ## Part 6. T7 Lemma 6.1: closed-instance refutability -/

section ClosedInstances

/-- A formula is *closed* (variable-free). -/
def IsClosedFormula (φ : Formula) : Prop := φ.atoms = ∅

/-- The truth value `W(φ)` of a formula in the "world" of closed formulas: evaluation under an
arbitrary fixed valuation, which does not matter for closed `φ` (`eval_eq_closedValue`). -/
def closedValue (φ : Formula) : Bool := φ.eval (fun _ => false)

theorem eval_eq_closedValue {φ : Formula} (h : IsClosedFormula φ) (u : Valuation) :
    φ.eval u = closedValue φ :=
  eval_congr (fun n hn => by rw [IsClosedFormula] at h; rw [h] at hn; simp at hn)

/-- `⊤/⊥`-instances are closed. -/
theorem isClosedFormula_subst_ofVal (w : Valuation) (φ : Formula) :
    IsClosedFormula (φ.subst (Subst.ofVal w)) := by
  unfold IsClosedFormula
  induction φ with
  | var n => simp only [subst_var, Subst.ofVal]; split <;> rfl
  | bot => rfl
  | top => rfl
  | neg a iha => simpa [atoms] using iha
  | and a b iha ihb => simp [atoms, iha, ihb]
  | or a b iha ihb => simp [atoms, iha, ihb]
  | imp a b iha ihb => simp [atoms, iha, ihb]

/-- `⊤/⊥`-instances have the same size as the schema. -/
theorem size_subst_ofVal (w : Valuation) (φ : Formula) :
    (φ.subst (Subst.ofVal w)).size = φ.size := by
  induction φ with
  | var n => simp only [subst_var, Subst.ofVal]; split <;> rfl
  | bot => rfl
  | top => rfl
  | neg a iha => simp [size, iha]
  | and a b iha ihb => simp [size, iha, ihb]
  | or a b iha ihb => simp [size, iha, ihb]
  | imp a b iha ihb => simp [size, iha, ihb]

theorem closedValue_subst_ofVal (w : Valuation) (φ : Formula) :
    closedValue (φ.subst (Subst.ofVal w)) = φ.eval w := by
  simp [closedValue]

/-- A schema (a step with metavariables as atoms) is *classically valid* if every instance is
classically sound. -/
def SchemaValid (τ : Step Formula) : Prop := ∀ θ : Subst, τ.subst θ ∈ SemSound

theorem schemaValid_iff (τ : Step Formula) : SchemaValid τ ↔ τ ∈ SemSound := by
  constructor
  · intro h; simpa using h Subst.id
  · intro h θ; exact SemSound_substClosed τ h θ

/-- The closed `⊤/⊥`-instance `τ[c_x/x]` of `τ` along `w` (`c_x = ⊤` iff `w x = 1`). -/
def closedInstance (τ : Step Formula) (w : Valuation) : Step Formula :=
  τ.subst (Subst.ofVal w)

/-- All formulas of a closed instance are closed. -/
theorem closedInstance_isClosed (τ : Step Formula) (w : Valuation) :
    (∀ p ∈ (closedInstance τ w).prem, IsClosedFormula p) ∧
      IsClosedFormula (closedInstance τ w).concl := by
  refine ⟨fun p hp => ?_, isClosedFormula_subst_ofVal w _⟩
  simp only [closedInstance, Step.subst_prem, Finset.mem_image] at hp
  obtain ⟨q, _, rfl⟩ := hp
  exact isClosedFormula_subst_ofVal w q

/-- Total size of a step (premises and conclusion). -/
def stepSize (τ : Step Formula) : ℕ := ∑ p ∈ τ.prem, p.size + τ.concl.size

/-- A closed instance is no larger than the schema: each formula keeps its size
(`size_subst_ofVal`), and distinct premises may coincide after substitution. -/
theorem stepSize_closedInstance_le (τ : Step Formula) (w : Valuation) :
    stepSize (closedInstance τ w) ≤ stepSize τ := by
  unfold stepSize closedInstance
  simp only [Step.subst_prem, Step.subst_concl, size_subst_ofVal]
  apply Nat.add_le_add_right
  refine (Finset.sum_image_le_of_nonneg (fun _ _ => Nat.zero_le _)).trans (le_of_eq ?_)
  simp [size_subst_ofVal]

/-- `w` gives a *closed refutation* of `τ`: the closed instance has `W`-true premises and a
`W`-false conclusion. -/
def ClosedRefutation (τ : Step Formula) (w : Valuation) : Prop :=
  (∀ p ∈ (closedInstance τ w).prem, closedValue p = true) ∧
    closedValue (closedInstance τ w).concl = false

/-- **T7 Lemma 6.1 (closed-instance refutability; Post's substitution).**  A pure schema `τ` is
classically invalid iff some substitution of `⊤/⊥` for its metavariables gives a closed
instance whose premises are `W`-true and whose conclusion is `W`-false. -/
theorem schema_invalid_iff_closedRefutation (τ : Step Formula) :
    ¬ SchemaValid τ ↔ ∃ w, ClosedRefutation τ w := by
  rw [schemaValid_iff, mem_SemSound]
  constructor
  · intro h
    simp only [SemCons, not_forall] at h
    obtain ⟨v, hv, hc⟩ := h
    refine ⟨v, fun p hp => ?_, ?_⟩
    · simp only [closedInstance, Step.subst_prem, Finset.mem_image] at hp
      obtain ⟨q, hq, rfl⟩ := hp
      rw [closedValue_subst_ofVal]
      exact hv q hq
    · simp only [closedInstance, Step.subst_concl, closedValue_subst_ofVal]
      simpa using hc
  · rintro ⟨w, hp, hc⟩ hsem
    apply Bool.false_ne_true
    rw [← hc]
    simp only [closedInstance, Step.subst_concl, closedValue_subst_ofVal]
    apply hsem w
    intro q hq
    have := hp (q.subst (Subst.ofVal w))
      (by simp only [closedInstance, Step.subst_prem]; exact Finset.mem_image_of_mem _ hq)
    rwa [closedValue_subst_ofVal] at this

/-- T7 Lemma 6.1, as in its proof: if *some* instance `τθ` is classically invalid, then a
closed `⊤/⊥` instance refutes `τ`, and conversely. -/
theorem exists_invalid_instance_iff_closedRefutation (τ : Step Formula) :
    (∃ θ : Subst, τ.subst θ ∉ SemSound) ↔ ∃ w, ClosedRefutation τ w := by
  rw [← schema_invalid_iff_closedRefutation, SchemaValid, not_forall]

/-- The metavariables of a schema. -/
def stepAtoms (τ : Step Formula) : Finset ℕ := τ.prem.biUnion Formula.atoms ∪ τ.concl.atoms

/-- Extend an assignment of the metavariables of `τ` by `false` elsewhere. -/
def extendVal (S : Finset ℕ) (g : S → Bool) : Valuation :=
  fun n => if h : n ∈ S then g ⟨n, h⟩ else false

/-- The candidate closed instances of `τ`: one for each `⊤/⊥`-assignment of its metavariables. -/
noncomputable def candidates (τ : Step Formula) : Finset (Step Formula) :=
  Finset.univ.image (fun g : stepAtoms τ → Bool => closedInstance τ (extendVal _ g))

/-- At most `2 ^ v(τ)` candidates. -/
theorem card_candidates_le (τ : Step Formula) :
    (candidates τ).card ≤ 2 ^ (stepAtoms τ).card := by
  refine Finset.card_image_le.trans ?_
  rw [Finset.card_univ, Fintype.card_fun, Fintype.card_bool, Fintype.card_coe]

/-- The closed instance depends only on `w` restricted to the metavariables of `τ`. -/
theorem closedInstance_congr (τ : Step Formula) {w w' : Valuation}
    (h : ∀ n ∈ stepAtoms τ, w n = w' n) : closedInstance τ w = closedInstance τ w' := by
  have hφ : ∀ φ : Formula, φ.atoms ⊆ stepAtoms τ →
      φ.subst (Subst.ofVal w) = φ.subst (Subst.ofVal w') := by
    intro φ hφ
    apply subst_congr
    intro n hn
    simp only [Subst.ofVal, h n (hφ hn)]
  simp only [closedInstance, Step.subst]
  congr 1
  · apply Finset.image_congr
    intro p hp
    apply hφ
    intro n hn
    simp only [stepAtoms, Finset.mem_union, Finset.mem_biUnion]
    exact Or.inl ⟨p, hp, hn⟩
  · apply hφ
    intro n hn
    simp only [stepAtoms, Finset.mem_union]
    exact Or.inr hn

/-- Every closed `⊤/⊥` instance is among the candidates. -/
theorem mem_candidates (τ : Step Formula) (w : Valuation) :
    closedInstance τ w ∈ candidates τ := by
  refine Finset.mem_image.2 ⟨fun n => w n.val, Finset.mem_univ _, ?_⟩
  apply closedInstance_congr
  intro n hn
  simp [extendVal, hn]

/-- The decision procedure behind T7 Lemma 6.1: `τ` is classically valid iff none of its at most
`2 ^ v(τ)` candidate closed instances has `W`-true premises and a `W`-false conclusion. -/
theorem mem_SemSound_iff_candidates (τ : Step Formula) :
    τ ∈ SemSound ↔ ∀ c ∈ candidates τ,
      (∀ p ∈ c.prem, closedValue p = true) → closedValue c.concl = true := by
  rw [← schemaValid_iff]
  constructor
  · intro hv c hc hp
    obtain ⟨g, _, rfl⟩ := Finset.mem_image.1 hc
    by_contra hcon
    exact (schema_invalid_iff_closedRefutation τ).2 ⟨_, hp, by simpa using hcon⟩ hv
  · intro h
    by_contra hv
    obtain ⟨w, hp, hc⟩ := (schema_invalid_iff_closedRefutation τ).1 hv
    have := h _ (mem_candidates τ w) hp
    rw [hc] at this
    exact Bool.false_ne_true this

end ClosedInstances

end Post

end InfLearn

/-! ## Axiom checks -/

#print axioms InfLearn.Post.eq_Cn2_or_eq_trivial
#print axioms InfLearn.Post.structural_extensions_Cn2
#print axioms InfLearn.Post.eq_Cn2_of_coherent
#print axioms InfLearn.Post.eq_Cn2_of_consistent
#print axioms InfLearn.Post.eq_Cn2_of_satisfiable_coherent
#print axioms InfLearn.Post.eq_Cn2_iff_exists_coherent
#print axioms InfLearn.Post.le_Cn2_of_empty_eq_Taut
#print axioms InfLearn.Post.versionSpace_eq_singleton_iff
#print axioms InfLearn.Post.learner_identifies
#print axioms InfLearn.Post.learner_mindChanges_le
#print axioms InfLearn.Post.Cn2Add_not_structural
#print axioms InfLearn.Post.Cn2Add_consistent
#print axioms InfLearn.Post.frag_eq_Cn2F_or_eq_trivial
#print axioms InfLearn.Post.frag_postComplete_neg
#print axioms InfLearn.Post.impFrag_postComplete
#print axioms InfLearn.Post.Cn2F_structural
#print axioms InfLearn.Post.schema_invalid_iff_closedRefutation
#print axioms InfLearn.Post.exists_invalid_instance_iff_closedRefutation
#print axioms InfLearn.Post.card_candidates_le
#print axioms InfLearn.Post.stepSize_closedInstance_le
#print axioms InfLearn.Post.size_subst_ofVal
#print axioms InfLearn.Post.mem_SemSound_iff_candidates
