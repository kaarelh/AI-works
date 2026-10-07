import InfLearn.Steps

/-!
# Blame: hitting-set duality (T7 Lemma 2.3) and descent along false lines (T4 Lemma 4.1)

## Part I — T7 Lemma 2.3 (Reiter's hitting-set duality)

Setting: a finite universe `U : Finset α` and a family `K : Set (Finset α)` of *conflicts*,
upward closed among the subsets of `U` (`UpClosed U K`).  A subset `M ⊆ U` is *clean* iff
`M ∉ K` (`IsClean`); under upward closure this is the same as "`M` contains no member of `K`"
(`isClean_iff_forall_not_subset`).  `minConflicts U K` (the paper's `𝒞`) is the set of
`⊆`-minimal conflicts, a *transversal* (hitting set) of a family `𝒞` is a `T ⊆ U` meeting every
member of `𝒞`, and minimality / maximality use Mathlib's `Minimal` / `Maximal` predicates.

* (a) `isMaxClean_iff`, `isMinTransversal_iff`, `setOf_isMaxClean_eq_image` :
  the maximal clean sets are exactly the complements (in `U`) of the minimal transversals
  of `𝒞`.
* (b) `exists_minTransversal_mem_iff` : `x` lies in some minimal transversal iff it lies in some
  minimal conflict (proved for an arbitrary antichain of subsets of `U` in
  `exists_minTransversal_mem_iff_of_antichain`).  Hence
  `mem_inter_maxClean_iff` / `iInter_maxClean_eq` : the intersection of all maximal clean sets
  is `U \ ⋃ 𝒞` (`U \ blameSet U K`), and `isClean_sdiff_blameSet` : that set is clean
  (this needs `∅ ∉ K`).
* (c) (bonus) `existsUnique_minTransversal_iff` : the minimal transversal is unique iff every
  minimal conflict is a singleton.

## Part II — T4 Lemma 4.1 (descent along false lines)

Two abstract forms of an informal argument whose lines live in a type `X`, with a valuation
`v : X → Bool`:

* **Tree form** (`ArgTree`): an inductive type with leaves `prem y`, inference nodes
  `infer y n sub` (conclusion `y`, antecedents the conclusions of the `n` subtrees `sub i`) and
  link nodes `link y sub` (`(sub).concl ⇝ y`).  `ArgTree.descend v` is the walk "start at the
  conclusion; at a false inference line move to its first false antecedent, at a false link
  target move to the source; stop when all antecedents are true".
  `ArgTree.descend_spec` : if all premises are true and the conclusion is false, the walk stops
  at a node of the tree that is a *false item* (an inference with all antecedents true and false
  conclusion, or a link with true source and false target).  The walk makes fewer than
  `depth α` moves (`moves_lt_depth`) and evaluates at most the maximal fan-in sum along a
  dependency path (`evals_le_maxPathFanIn`).  `descent_tree` is the bare existence statement,
  and `descent_tree_not_mem` / `descent_tree_not_semSound` the "if `v` is admissible the item
  found is invalid" clause.
* **Line-list (DAG) form** (`LineArg`): the paper's literal format, a finite list of lines each of
  which is a premise, an inference from a finset of *earlier* lines, or a link from an earlier
  line.  `LineArg.descent` : from any false line, a walk back along false dependencies reaches a
  false item, with the number of moves bounded by any height function that strictly decreases
  along dependencies; `LineArg.descent_depth` instantiates it with the paper's depth (length of
  the longest dependency path, `LineArg.depthAt`) and `LineArg.descent_index` with the line
  index.  `LineArg.descent_not_mem` is the "item found is `h`-invalid" clause.

Notes on faithfulness.
* `UpClosed U K` only asks upward closure *inside* `U`; `K` need not consist of subsets of `U`.
  The hypothesis `∅ ∉ K` is assumed exactly where it is needed (cleanness of `U \ ⋃ 𝒞`, and
  non-emptiness of the family of maximal clean sets); (a), (b) and (c) hold without it.
* The link side condition `str(y_i) = str(y_j)` of T4 §1.1 is irrelevant to descent and omitted.
-/

namespace InfLearn
namespace Blame

universe u

/-! ## Part I: T7 Lemma 2.3 -/

section HittingSet

variable {α : Type u}

/-- `K` is upward closed among the subsets of `U`. -/
def UpClosed (U : Finset α) (K : Set (Finset α)) : Prop :=
  ∀ ⦃A B : Finset α⦄, A ∈ K → A ⊆ B → B ⊆ U → B ∈ K

/-- `M` is a *clean* subset of `U`: `M ⊆ U` and `M ∉ K` (T7 Lemma 2.3). -/
def IsClean (U : Finset α) (K : Set (Finset α)) (M : Finset α) : Prop :=
  M ⊆ U ∧ M ∉ K

/-- `C` is a conflict inside `U`. -/
def IsConflict (U : Finset α) (K : Set (Finset α)) (C : Finset α) : Prop :=
  C ⊆ U ∧ C ∈ K

/-- The minimal conflicts `𝒞` (the `⊆`-minimal members of `K` inside `U`). -/
def minConflicts (U : Finset α) (K : Set (Finset α)) : Set (Finset α) :=
  {C | Minimal (IsConflict U K) C}

/-- `T` is a transversal (hitting set) of the family `𝒞` inside `U`. -/
def IsTransversal (U : Finset α) (𝒞 : Set (Finset α)) (T : Finset α) : Prop :=
  T ⊆ U ∧ ∀ C ∈ 𝒞, ∃ x ∈ C, x ∈ T

/-- `T` is a `⊆`-minimal transversal of `𝒞` inside `U`. -/
def IsMinTransversal (U : Finset α) (𝒞 : Set (Finset α)) (T : Finset α) : Prop :=
  Minimal (IsTransversal U 𝒞) T

/-- `M` is a `⊆`-maximal clean subset of `U`. -/
def IsMaxClean (U : Finset α) (K : Set (Finset α)) (M : Finset α) : Prop :=
  Maximal (IsClean U K) M

variable {U : Finset α} {K : Set (Finset α)} {𝒞 : Set (Finset α)}

/-! ### Basic facts about minimal conflicts -/

theorem minConflicts_subset {C : Finset α} (hC : C ∈ minConflicts U K) : C ⊆ U := hC.1.1

theorem minConflicts_mem {C : Finset α} (hC : C ∈ minConflicts U K) : C ∈ K := hC.1.2

/-- The minimal conflicts form an antichain. -/
theorem minConflicts_antichain {C E : Finset α} (hC : C ∈ minConflicts U K)
    (hE : E ∈ minConflicts U K) (h : E ⊆ C) : E = C :=
  (Minimal.eq_of_ge hC hE.1 h).symm

/-- Every conflict inside `U` contains a minimal conflict (finiteness). -/
theorem exists_minConflict_subset {A : Finset α} (hA : A ⊆ U) (hAK : A ∈ K) :
    ∃ C ∈ minConflicts U K, C ⊆ A := by
  obtain ⟨C, hCA, hC⟩ := exists_minimal_le_of_wellFoundedLT (IsConflict U K) A ⟨hA, hAK⟩
  exact ⟨C, hC, hCA⟩

/-- If `∅ ∉ K` then every minimal conflict is nonempty. -/
theorem minConflicts_nonempty (hempty : (∅ : Finset α) ∉ K) {C : Finset α}
    (hC : C ∈ minConflicts U K) : C.Nonempty := by
  rw [Finset.nonempty_iff_ne_empty]
  rintro rfl
  exact hempty (minConflicts_mem hC)

/-- Every transversal contains a minimal transversal (finiteness). -/
theorem exists_minTransversal_subset {T : Finset α} (hT : IsTransversal U 𝒞 T) :
    ∃ T' ⊆ T, IsMinTransversal U 𝒞 T' :=
  exists_minimal_le_of_wellFoundedLT (IsTransversal U 𝒞) T hT

/-! ### Cleanness -/

/-- Under upward closure, `M ⊆ U` is clean iff it contains no member of `K`
(the formulation "a set is clean iff it contains no conflict"). -/
theorem isClean_iff_forall_not_subset (hK : UpClosed U K) {M : Finset α} (hM : M ⊆ U) :
    IsClean U K M ↔ ∀ A ∈ K, ¬ A ⊆ M := by
  constructor
  · rintro ⟨-, hMK⟩ A hA hAM
    exact hMK (hK hA hAM hM)
  · intro h
    exact ⟨hM, fun hMK => h M hMK subset_rfl⟩

/-- Under upward closure, `M ⊆ U` is clean iff it contains no *minimal* conflict. -/
theorem isClean_iff_forall_minConflict (hK : UpClosed U K) {M : Finset α} (hM : M ⊆ U) :
    IsClean U K M ↔ ∀ C ∈ minConflicts U K, ¬ C ⊆ M := by
  rw [isClean_iff_forall_not_subset hK hM]
  constructor
  · intro h C hC
    exact h C (minConflicts_mem hC)
  · intro h A hA hAM
    obtain ⟨C, hC, hCA⟩ := exists_minConflict_subset (hAM.trans hM) hA
    exact h C hC (hCA.trans hAM)

/-- Cleanness is closed downward (inside `U`), given upward closure of `K`. -/
theorem IsClean.mono (hK : UpClosed U K) {M N : Finset α} (hM : IsClean U K M) (hNM : N ⊆ M) :
    IsClean U K N :=
  ⟨hNM.trans hM.1, fun hN => hM.2 (hK hN hNM hM.1)⟩

variable [DecidableEq α]

/-- **Key lemma for (a).** Under upward closure, `M ⊆ U` is clean iff its complement `U \ M`
is a transversal of the minimal conflicts. -/
theorem isClean_iff_isTransversal_sdiff (hK : UpClosed U K) {M : Finset α} (hM : M ⊆ U) :
    IsClean U K M ↔ IsTransversal U (minConflicts U K) (U \ M) := by
  rw [isClean_iff_forall_minConflict hK hM]
  constructor
  · intro h
    refine ⟨Finset.sdiff_subset, fun C hC => ?_⟩
    by_contra hne
    push Not at hne
    apply h C hC
    intro x hx
    have hxU : x ∈ U := minConflicts_subset hC hx
    by_contra hxM
    exact hne x hx (Finset.mem_sdiff.2 ⟨hxU, hxM⟩)
  · rintro ⟨-, hT⟩ C hC hCM
    obtain ⟨x, hxC, hxT⟩ := hT C hC
    exact (Finset.mem_sdiff.1 hxT).2 (hCM hxC)

/-! ### Lemma 2.3 (a) -/

/-- **T7 Lemma 2.3 (a), first form.** `M` is a maximal clean set iff `M ⊆ U` and its
complement `U \ M` is a minimal transversal of the minimal conflicts. -/
theorem isMaxClean_iff (hK : UpClosed U K) {M : Finset α} :
    IsMaxClean U K M ↔ M ⊆ U ∧ IsMinTransversal U (minConflicts U K) (U \ M) := by
  constructor
  · rintro ⟨hclean, hmax⟩
    have hM : M ⊆ U := hclean.1
    refine ⟨hM, (isClean_iff_isTransversal_sdiff hK hM).1 hclean, ?_⟩
    intro T' hT' hT'le
    -- `N := U \ T'` is clean and contains `M`
    have hN : IsClean U K (U \ T') := by
      rw [isClean_iff_isTransversal_sdiff hK Finset.sdiff_subset,
        Finset.sdiff_sdiff_eq_self hT'.1]
      exact hT'
    have hMN : M ⊆ U \ T' := by
      intro x hx
      refine Finset.mem_sdiff.2 ⟨hM hx, fun hxT => ?_⟩
      exact (Finset.mem_sdiff.1 (hT'le hxT)).2 hx
    have hNM : U \ T' ⊆ M := hmax hN hMN
    intro x hx
    obtain ⟨hxU, hxM⟩ := Finset.mem_sdiff.1 hx
    by_contra hxT
    exact hxM (hNM (Finset.mem_sdiff.2 ⟨hxU, hxT⟩))
  · rintro ⟨hM, hT, hmin⟩
    refine ⟨(isClean_iff_isTransversal_sdiff hK hM).2 hT, ?_⟩
    intro N hN hMN
    have hN' : IsTransversal U (minConflicts U K) (U \ N) :=
      (isClean_iff_isTransversal_sdiff hK hN.1).1 hN
    have h1 : U \ N ⊆ U \ M := Finset.sdiff_subset_sdiff subset_rfl hMN
    have h2 : U \ M ⊆ U \ N := hmin hN' h1
    intro x hxN
    by_contra hxM
    have hx : x ∈ U \ N := h2 (Finset.mem_sdiff.2 ⟨hN.1 hxN, hxM⟩)
    exact (Finset.mem_sdiff.1 hx).2 hxN

/-- **T7 Lemma 2.3 (a), converse form.** `T` is a minimal transversal of the minimal conflicts
iff `T ⊆ U` and `U \ T` is a maximal clean set. -/
theorem isMinTransversal_iff (hK : UpClosed U K) {T : Finset α} :
    IsMinTransversal U (minConflicts U K) T ↔ T ⊆ U ∧ IsMaxClean U K (U \ T) := by
  constructor
  · intro hT
    have hTU : T ⊆ U := hT.1.1
    refine ⟨hTU, (isMaxClean_iff hK).2 ⟨Finset.sdiff_subset, ?_⟩⟩
    rwa [Finset.sdiff_sdiff_eq_self hTU]
  · rintro ⟨hTU, h⟩
    have := ((isMaxClean_iff hK).1 h).2
    rwa [Finset.sdiff_sdiff_eq_self hTU] at this

/-- **T7 Lemma 2.3 (a).** The maximal clean sets are exactly the complements (in `U`) of the
minimal transversals of the minimal conflicts. -/
theorem setOf_isMaxClean_eq_image (hK : UpClosed U K) :
    {M | IsMaxClean U K M} = (U \ ·) '' {T | IsMinTransversal U (minConflicts U K) T} := by
  ext M
  simp only [Set.mem_setOf_eq, Set.mem_image]
  constructor
  · intro hM
    obtain ⟨hMU, hT⟩ := (isMaxClean_iff hK).1 hM
    exact ⟨U \ M, hT, Finset.sdiff_sdiff_eq_self hMU⟩
  · rintro ⟨T, hT, rfl⟩
    exact ((isMinTransversal_iff hK).1 hT).2

/-! ### Lemma 2.3 (b) -/

/-- Minimality of a transversal: every member `x` of a minimal transversal `T` has a *private*
member of `𝒞`, i.e. some `E ∈ 𝒞` with `E ∩ T = {x}` (in particular `x ∈ E`).
This is (b, ⇒) in the paper; it holds for any family `𝒞`. -/
theorem exists_private_of_mem_minTransversal {T : Finset α} (hT : IsMinTransversal U 𝒞 T)
    {x : α} (hx : x ∈ T) : ∃ E ∈ 𝒞, x ∈ E ∧ E ∩ T = {x} := by
  -- `T.erase x` is not a transversal, by minimality
  have hnot : ¬ IsTransversal U 𝒞 (T.erase x) := by
    intro h
    have : T ⊆ T.erase x := hT.2 h (Finset.erase_subset x T)
    exact Finset.notMem_erase x T (this hx)
  have hsub : T.erase x ⊆ U := (Finset.erase_subset x T).trans hT.1.1
  have : ∃ E ∈ 𝒞, ∀ z ∈ E, z ∉ T.erase x := by
    by_contra h
    push Not at h
    exact hnot ⟨hsub, h⟩
  obtain ⟨E, hE, hEx⟩ := this
  have hpriv : ∀ z ∈ E, z ∈ T → z = x := by
    intro z hzE hzT
    by_contra hzx
    exact hEx z hzE (Finset.mem_erase.2 ⟨hzx, hzT⟩)
  obtain ⟨y, hyE, hyT⟩ := hT.1.2 E hE
  have hyx : y = x := hpriv y hyE hyT
  subst hyx
  refine ⟨E, hE, hyE, ?_⟩
  rw [Finset.eq_singleton_iff_unique_mem]
  refine ⟨Finset.mem_inter.2 ⟨hyE, hyT⟩, fun z hz => ?_⟩
  obtain ⟨hzE, hzT⟩ := Finset.mem_inter.1 hz
  exact hpriv z hzE hzT

omit [DecidableEq α] in
/-- (b, ⇐) for an arbitrary antichain `𝒞` of subsets of `U`: every element of a member of `𝒞`
lies in some minimal transversal.  (Witness: a minimal transversal inside `(U \ C) ∪ {x}`.) -/
theorem exists_minTransversal_of_mem_of_antichain (h𝒞U : ∀ C ∈ 𝒞, C ⊆ U)
    (hanti : ∀ C ∈ 𝒞, ∀ E ∈ 𝒞, E ⊆ C → E = C) {C : Finset α} (hC : C ∈ 𝒞) {x : α}
    (hx : x ∈ C) : ∃ T, IsMinTransversal U 𝒞 T ∧ x ∈ T := by
  classical
  have hxU : x ∈ U := h𝒞U C hC hx
  have hT : IsTransversal U 𝒞 (insert x (U \ C)) := by
    refine ⟨Finset.insert_subset hxU Finset.sdiff_subset, fun E hE => ?_⟩
    by_cases hEC : E ⊆ C
    · have : E = C := hanti C hC E hE hEC
      subst this
      exact ⟨x, hx, Finset.mem_insert_self _ _⟩
    · obtain ⟨y, hyE, hyC⟩ := Finset.not_subset.1 hEC
      exact ⟨y, hyE, Finset.mem_insert_of_mem (Finset.mem_sdiff.2 ⟨h𝒞U E hE hyE, hyC⟩)⟩
  obtain ⟨T', hT'T, hT'⟩ := exists_minTransversal_subset hT
  refine ⟨T', hT', ?_⟩
  obtain ⟨y, hyC, hyT'⟩ := hT'.1.2 C hC
  have hy : y ∈ insert x (U \ C) := hT'T hyT'
  rcases Finset.mem_insert.1 hy with hyx | hy
  · exact hyx ▸ hyT'
  · exact absurd hyC (Finset.mem_sdiff.1 hy).2

omit [DecidableEq α] in
/-- **T7 Lemma 2.3 (b), general form.** For an antichain `𝒞` of subsets of `U`, an element lies
in some minimal transversal iff it lies in some member of `𝒞`. -/
theorem exists_minTransversal_mem_iff_of_antichain (h𝒞U : ∀ C ∈ 𝒞, C ⊆ U)
    (hanti : ∀ C ∈ 𝒞, ∀ E ∈ 𝒞, E ⊆ C → E = C) {x : α} :
    (∃ T, IsMinTransversal U 𝒞 T ∧ x ∈ T) ↔ ∃ C ∈ 𝒞, x ∈ C := by
  classical
  constructor
  · rintro ⟨T, hT, hx⟩
    obtain ⟨E, hE, hxE, -⟩ := exists_private_of_mem_minTransversal hT hx
    exact ⟨E, hE, hxE⟩
  · rintro ⟨C, hC, hx⟩
    exact exists_minTransversal_of_mem_of_antichain h𝒞U hanti hC hx

omit [DecidableEq α] in
/-- **T7 Lemma 2.3 (b).** An element lies in some minimal transversal of the minimal conflicts
iff it lies in some minimal conflict. -/
theorem exists_minTransversal_mem_iff {x : α} :
    (∃ T, IsMinTransversal U (minConflicts U K) T ∧ x ∈ T) ↔ ∃ C ∈ minConflicts U K, x ∈ C :=
  exists_minTransversal_mem_iff_of_antichain (fun _ hC => minConflicts_subset hC)
    (fun _ hC _ hE h => minConflicts_antichain hC hE h)

/-- The blame set `⋃ 𝒞` (the union of the minimal conflicts), as a finset. -/
noncomputable def blameSet (U : Finset α) (K : Set (Finset α)) : Finset α := by
  classical
  exact U.filter fun x => ∃ C ∈ minConflicts U K, x ∈ C

omit [DecidableEq α] in
theorem mem_blameSet {x : α} : x ∈ blameSet U K ↔ ∃ C ∈ minConflicts U K, x ∈ C := by
  classical
  unfold blameSet
  rw [Finset.mem_filter]
  constructor
  · exact fun h => h.2
  · rintro ⟨C, hC, hx⟩
    exact ⟨minConflicts_subset hC hx, C, hC, hx⟩

omit [DecidableEq α] in
/-- `blameSet U K` is the union of the minimal conflicts. -/
theorem coe_blameSet : (↑(blameSet U K) : Set α) = ⋃ C ∈ minConflicts U K, (↑C : Set α) := by
  ext x
  simp only [Finset.mem_coe, mem_blameSet, Set.mem_iUnion, exists_prop]

omit [DecidableEq α] in
/-- (b) restated: the union of the minimal transversals equals the union of the minimal
conflicts. -/
theorem coe_blameSet_eq_iUnion_minTransversal :
    (↑(blameSet U K) : Set α) =
      ⋃ T ∈ {T | IsMinTransversal U (minConflicts U K) T}, (↑T : Set α) := by
  ext x
  simp only [Finset.mem_coe, mem_blameSet, Set.mem_iUnion, Set.mem_setOf_eq, exists_prop]
  exact exists_minTransversal_mem_iff.symm

/-- **T7 Lemma 2.3 (b), second claim (pointwise).** `x` belongs to every maximal clean set
(and to `U`) iff `x ∈ U \ ⋃ 𝒞`. -/
theorem mem_inter_maxClean_iff (hK : UpClosed U K) {x : α} :
    (x ∈ U ∧ ∀ M, IsMaxClean U K M → x ∈ M) ↔ x ∈ U \ blameSet U K := by
  rw [Finset.mem_sdiff, mem_blameSet]
  constructor
  · rintro ⟨hxU, h⟩
    refine ⟨hxU, fun hx => ?_⟩
    obtain ⟨T, hT, hxT⟩ := exists_minTransversal_mem_iff.2 hx
    have hM := h _ ((isMinTransversal_iff hK).1 hT).2
    exact (Finset.mem_sdiff.1 hM).2 hxT
  · rintro ⟨hxU, hx⟩
    refine ⟨hxU, fun M hM => ?_⟩
    obtain ⟨-, hT⟩ := (isMaxClean_iff hK).1 hM
    by_contra hxM
    exact hx (exists_minTransversal_mem_iff.1 ⟨_, hT, Finset.mem_sdiff.2 ⟨hxU, hxM⟩⟩)

/-- `x ∈ ⋃ 𝒞` iff `x` lies outside some maximal clean set: the elements that a learner who
keeps only what *every* maximal clean set keeps must withhold are exactly `⋃ 𝒞`. -/
theorem mem_blameSet_iff_exists_maxClean (hK : UpClosed U K) {x : α} :
    x ∈ blameSet U K ↔ x ∈ U ∧ ∃ M, IsMaxClean U K M ∧ x ∉ M := by
  constructor
  · intro hx
    obtain ⟨C, hC, hxC⟩ := mem_blameSet.1 hx
    have hxU : x ∈ U := minConflicts_subset hC hxC
    refine ⟨hxU, ?_⟩
    by_contra h
    push Not at h
    exact (Finset.mem_sdiff.1 ((mem_inter_maxClean_iff hK).1 ⟨hxU, h⟩)).2 hx
  · rintro ⟨hxU, M, hM, hxM⟩
    by_contra hx
    exact hxM (((mem_inter_maxClean_iff hK).2 (Finset.mem_sdiff.2 ⟨hxU, hx⟩)).2 M hM)

omit [DecidableEq α] in
/-- If `∅ ∉ K`, `U` itself is a transversal of the minimal conflicts. -/
theorem isTransversal_univ (hempty : (∅ : Finset α) ∉ K) :
    IsTransversal U (minConflicts U K) U := by
  refine ⟨subset_rfl, fun C hC => ?_⟩
  obtain ⟨x, hx⟩ := minConflicts_nonempty hempty hC
  exact ⟨x, hx, minConflicts_subset hC hx⟩

/-- If `∅ ∉ K`, there is at least one maximal clean set (so the intersection below is over a
nonempty family). -/
theorem exists_isMaxClean (hK : UpClosed U K) (hempty : (∅ : Finset α) ∉ K) :
    ∃ M, IsMaxClean U K M := by
  obtain ⟨T, -, hT⟩ := exists_minTransversal_subset (isTransversal_univ (U := U) hempty)
  exact ⟨U \ T, ((isMinTransversal_iff hK).1 hT).2⟩

/-- **T7 Lemma 2.3 (b), second claim.** `⋂ {maximal clean sets} = U \ ⋃ 𝒞`. -/
theorem iInter_maxClean_eq (hK : UpClosed U K) (hempty : (∅ : Finset α) ∉ K) :
    (⋂ M ∈ {M | IsMaxClean U K M}, (↑M : Set α)) = ↑(U \ blameSet U K) := by
  obtain ⟨M₀, hM₀⟩ := exists_isMaxClean hK hempty
  ext x
  simp only [Set.mem_iInter, Set.mem_setOf_eq, Finset.mem_coe]
  rw [← mem_inter_maxClean_iff hK]
  constructor
  · intro h
    exact ⟨hM₀.1.1 (h M₀ hM₀), h⟩
  · exact fun h => h.2

/-- **T7 Lemma 2.3 (b), last claim.** `U \ ⋃ 𝒞` is clean (assuming `∅ ∉ K`; no upward closure
is needed for this). -/
theorem isClean_sdiff_blameSet (hempty : (∅ : Finset α) ∉ K) : IsClean U K (U \ blameSet U K) := by
  refine ⟨Finset.sdiff_subset, fun hK' => ?_⟩
  obtain ⟨C, hC, hCsub⟩ := exists_minConflict_subset Finset.sdiff_subset hK'
  obtain ⟨x, hx⟩ := minConflicts_nonempty hempty hC
  exact (Finset.mem_sdiff.1 (hCsub hx)).2 (mem_blameSet.2 ⟨C, hC, hx⟩)

/-- The intersection of the maximal clean sets is itself (the greatest) clean set contained in
every maximal clean set. -/
theorem isClean_iInter_maxClean (hK : UpClosed U K) (hempty : (∅ : Finset α) ∉ K) :
    ∃ A : Finset α, (↑A : Set α) = (⋂ M ∈ {M | IsMaxClean U K M}, (↑M : Set α)) ∧
      IsClean U K A :=
  ⟨U \ blameSet U K, (iInter_maxClean_eq hK hempty).symm, isClean_sdiff_blameSet hempty⟩

/-! ### Lemma 2.3 (c) (bonus) -/

omit [DecidableEq α] in
/-- **T7 Lemma 2.3 (c).** The minimal transversal of the minimal conflicts is unique iff every
minimal conflict is a singleton. -/
theorem existsUnique_minTransversal_iff :
    (∃! T, IsMinTransversal U (minConflicts U K) T) ↔ ∀ C ∈ minConflicts U K, ∃ x, C = {x} := by
  classical
  constructor
  · rintro ⟨T, hT, huniq⟩ C hC
    -- every minimal conflict lies inside `T`
    have hsub : ∀ E ∈ minConflicts U K, E ⊆ T := by
      intro E hE x hxE
      obtain ⟨T'', hT'', hxT''⟩ := exists_minTransversal_mem_iff.2 ⟨E, hE, hxE⟩
      rwa [huniq T'' hT''] at hxT''
    obtain ⟨x, hxC, hxT⟩ := hT.1.2 C hC
    obtain ⟨E, hE, hxE, hET⟩ := exists_private_of_mem_minTransversal hT hxT
    have hEx : E = {x} := by
      rw [← hET, Finset.inter_eq_left.2 (hsub E hE)]
    refine ⟨x, ?_⟩
    have hEC : E ⊆ C := by rw [hEx]; exact Finset.singleton_subset_iff.2 hxC
    rw [← hEx]
    exact (minConflicts_antichain hC hE hEC).symm
  · intro hsing
    set T₀ : Finset α := U.filter fun x => {x} ∈ minConflicts U K with hT₀
    -- every transversal contains `T₀`
    have hle : ∀ T, IsTransversal U (minConflicts U K) T → T₀ ⊆ T := by
      intro T hT x hx
      obtain ⟨-, hxC⟩ := Finset.mem_filter.1 hx
      obtain ⟨y, hy, hyT⟩ := hT.2 _ hxC
      rw [Finset.mem_singleton] at hy
      exact hy ▸ hyT
    have htr : IsTransversal U (minConflicts U K) T₀ := by
      refine ⟨Finset.filter_subset _ _, fun C hC => ?_⟩
      obtain ⟨x, rfl⟩ := hsing C hC
      refine ⟨x, Finset.mem_singleton_self x, Finset.mem_filter.2 ⟨?_, hC⟩⟩
      exact minConflicts_subset hC (Finset.mem_singleton_self x)
    have hmin : IsMinTransversal U (minConflicts U K) T₀ :=
      ⟨htr, fun T hT _ => hle T hT⟩
    refine ⟨T₀, hmin, fun T hT => ?_⟩
    exact le_antisymm (hT.2 htr (hle T hT.1)) (hle T hT.1)

end HittingSet

/-! ## Part II: T4 Lemma 4.1 (descent along false lines) -/

section Descent

/-! ### Tree form -/

/-- An argument in tree form over a type `X` of lines (occurrences):
* `prem y` : a premise (leaf);
* `infer y n sub` : an inference line `Γ ⇒ y` whose antecedents `Γ` are the conclusions of the
  `n` sub-arguments `sub i`;
* `link y sub` : a link `y' ⇝ y` from the conclusion `y'` of the sub-argument `sub`. -/
inductive ArgTree (X : Type u) : Type u
  | prem (y : X) : ArgTree X
  | infer (y : X) (n : ℕ) (sub : Fin n → ArgTree X) : ArgTree X
  | link (y : X) (sub : ArgTree X) : ArgTree X

namespace ArgTree

variable {X : Type u}

/-- The conclusion (last line) of an argument tree. -/
def concl : ArgTree X → X
  | prem y => y
  | infer y _ _ => y
  | link y _ => y

/-- All premises (leaves) of the argument are true under `v`. -/
def PremsTrue (v : X → Bool) : ArgTree X → Prop
  | prem y => v y = true
  | infer _ _ sub => ∀ i, PremsTrue v (sub i)
  | link _ sub => PremsTrue v sub

/-- A *false item* at the root of `t`: an inference line all of whose antecedents are true and
whose conclusion is false, or a link with true source and false target. -/
def IsFalseItem (v : X → Bool) : ArgTree X → Prop
  | prem _ => False
  | infer y _ sub => (∀ i, v (sub i).concl = true) ∧ v y = false
  | link y sub => v sub.concl = true ∧ v y = false

/-- `Occurs s t` : `s` is a node (sub-argument) of `t`. -/
inductive Occurs : ArgTree X → ArgTree X → Prop
  | refl (t : ArgTree X) : Occurs t t
  | infer {s : ArgTree X} {y : X} {n : ℕ} {sub : Fin n → ArgTree X} (i : Fin n) :
      Occurs s (sub i) → Occurs s (infer y n sub)
  | link {s : ArgTree X} {y : X} {sub : ArgTree X} :
      Occurs s sub → Occurs s (link y sub)

/-- The first antecedent (in the order `0, 1, …, n-1`) whose line is false under `v`. -/
def firstFalse (v : X → Bool) {n : ℕ} (sub : Fin n → ArgTree X) : Option (Fin n) :=
  (List.finRange n).find? fun i => !v (sub i).concl

theorem firstFalse_eq_none {v : X → Bool} {n : ℕ} {sub : Fin n → ArgTree X} :
    firstFalse v sub = none ↔ ∀ i, v (sub i).concl = true := by
  unfold firstFalse
  rw [List.find?_eq_none]
  simp [List.mem_finRange]

theorem firstFalse_eq_some {v : X → Bool} {n : ℕ} {sub : Fin n → ArgTree X} {i : Fin n}
    (h : firstFalse v sub = some i) : v (sub i).concl = false := by
  have := List.find?_some h
  simpa using this

/-- **The descent walk** (T4 Lemma 4.1, proof).  Start at the root.  At an inference line: if
all antecedents are true, stop here; otherwise move to the first false antecedent.  At a link:
if the source is true, stop here; otherwise move to the source.  Returns the node where it
stops (`none` only if it runs into a premise, which cannot happen when premises are true). -/
def descend (v : X → Bool) : ArgTree X → Option (ArgTree X)
  | prem _ => none
  | infer y n sub =>
      match firstFalse v sub with
      | none => some (infer y n sub)
      | some i => descend v (sub i)
  | link y sub => if v sub.concl = true then some (link y sub) else descend v sub

/-- Number of moves made by the descent walk. -/
def moves (v : X → Bool) : ArgTree X → ℕ
  | prem _ => 0
  | infer _ _ sub =>
      match firstFalse v sub with
      | none => 0
      | some i => moves v (sub i) + 1
  | link _ sub => if v sub.concl = true then 0 else moves v sub + 1

/-- Number of line evaluations made by the descent walk: at every visited inference line all
its `n` antecedents are (at most) evaluated, at every visited link its source. -/
def evals (v : X → Bool) : ArgTree X → ℕ
  | prem _ => 0
  | infer _ n sub =>
      n + match firstFalse v sub with
        | none => 0
        | some i => evals v (sub i)
  | link _ sub => 1 + if v sub.concl = true then 0 else evals v sub

/-- The depth of an argument: the number of inference/link lines on a longest dependency path
(premises have depth `0`). -/
def depth : ArgTree X → ℕ
  | prem _ => 0
  | infer _ _ sub => (Finset.univ.sup fun i => depth (sub i)) + 1
  | link _ sub => depth sub + 1

/-- The maximum, over dependency paths from the conclusion to a premise, of the sum of the
fan-ins of the lines on the path (a link has fan-in `1`). -/
def maxPathFanIn : ArgTree X → ℕ
  | prem _ => 0
  | infer _ n sub => n + Finset.univ.sup fun i => maxPathFanIn (sub i)
  | link _ sub => 1 + maxPathFanIn sub

/-- **T4 Lemma 4.1 (descent), algorithmic form, tree version.** If all premises of `t` are true
under `v` and its conclusion is false, the descent walk stops at a node `c` of `t` that is a false
item: an inference line with all antecedents true and false conclusion, or a link with true
source and false target. -/
theorem descend_spec (v : X → Bool) (t : ArgTree X) (hprem : PremsTrue v t)
    (hconcl : v t.concl = false) :
    ∃ c, descend v t = some c ∧ Occurs c t ∧ IsFalseItem v c := by
  induction t with
  | prem y =>
    simp only [PremsTrue] at hprem
    simp only [concl] at hconcl
    rw [hprem] at hconcl
    exact absurd hconcl (by decide)
  | infer y n sub ih =>
    simp only [concl] at hconcl
    simp only [PremsTrue] at hprem
    cases h : firstFalse v sub with
    | none =>
      refine ⟨infer y n sub, ?_, Occurs.refl _, firstFalse_eq_none.1 h, hconcl⟩
      simp [descend, h]
    | some i =>
      obtain ⟨c, hc, hocc, hfalse⟩ := ih i (hprem i) (firstFalse_eq_some h)
      refine ⟨c, ?_, Occurs.infer i hocc, hfalse⟩
      simp [descend, h, hc]
  | link y sub ih =>
    simp only [concl] at hconcl
    simp only [PremsTrue] at hprem
    by_cases h : v sub.concl = true
    · exact ⟨link y sub, by simp [descend, h], Occurs.refl _, h, hconcl⟩
    · have h' : v sub.concl = false := by simpa using h
      obtain ⟨c, hc, hocc, hfalse⟩ := ih hprem h'
      exact ⟨c, by simp [descend, h, hc], Occurs.link hocc, hfalse⟩

/-- **T4 Lemma 4.1 (descent), existence form, tree version.** An argument whose premises are
true and whose conclusion is false under `v` contains a false item. -/
theorem descent_tree (v : X → Bool) (t : ArgTree X) (hprem : PremsTrue v t)
    (hconcl : v t.concl = false) : ∃ c, Occurs c t ∧ IsFalseItem v c := by
  obtain ⟨c, -, hocc, hfalse⟩ := descend_spec v t hprem hconcl
  exact ⟨c, hocc, hfalse⟩

/-- **T4 Lemma 4.1, move bound.** Under the hypotheses of the lemma, the descent walk makes
fewer than `depth t` moves. -/
theorem moves_lt_depth (v : X → Bool) (t : ArgTree X) (hprem : PremsTrue v t)
    (hconcl : v t.concl = false) : moves v t < depth t := by
  induction t with
  | prem y =>
    simp only [PremsTrue] at hprem
    simp only [concl] at hconcl
    rw [hprem] at hconcl
    exact absurd hconcl (by decide)
  | infer y n sub ih =>
    simp only [PremsTrue] at hprem
    cases h : firstFalse v sub with
    | none => simp [moves, depth, h]
    | some i =>
      have := ih i (hprem i) (firstFalse_eq_some h)
      have hle : depth (sub i) ≤ Finset.univ.sup fun i => depth (sub i) :=
        Finset.le_sup (f := fun i => depth (sub i)) (Finset.mem_univ i)
      simp only [moves, depth, h]
      omega
  | link y sub ih =>
    simp only [PremsTrue] at hprem
    by_cases h : v sub.concl = true
    · simp [moves, depth, h]
    · have h' : v sub.concl = false := by simpa using h
      have := ih hprem h'
      simp only [moves, depth, h]
      simp
      omega

/-- **T4 Lemma 4.1, evaluation bound.** The descent walk evaluates at most
`maxPathFanIn t` lines: the sum of the fan-ins along one dependency path. (No hypotheses are
needed: the walk follows a single dependency path.) -/
theorem evals_le_maxPathFanIn (v : X → Bool) (t : ArgTree X) : evals v t ≤ maxPathFanIn t := by
  induction t with
  | prem y => simp [evals, maxPathFanIn]
  | infer y n sub ih =>
    cases h : firstFalse v sub with
    | none => simp [evals, maxPathFanIn, h]
    | some i =>
      have hle : maxPathFanIn (sub i) ≤ Finset.univ.sup fun i => maxPathFanIn (sub i) :=
        Finset.le_sup (f := fun i => maxPathFanIn (sub i)) (Finset.mem_univ i)
      have := ih i
      simp only [evals, maxPathFanIn, h]
      omega
  | link y sub ih =>
    by_cases h : v sub.concl = true
    · simp [evals, maxPathFanIn, h]
    · have := ih
      simp only [evals, maxPathFanIn, h]
      simp
      omega

/-- The step `(Γ ⇒ y)` performed at the root of `t`, if `t` is an inference or a link
(a link `y' ⇝ y` is the one-premise step `({y'} ⇒ y)`, as in T4 §1.1). -/
def rootStep [DecidableEq X] : ArgTree X → Option (Step X)
  | prem _ => none
  | infer y _ sub => some ⟨Finset.univ.image fun i => (sub i).concl, y⟩
  | link y sub => some ⟨{sub.concl}, y⟩

theorem IsFalseItem.exists_rootStep [DecidableEq X] {v : X → Bool} {c : ArgTree X}
    (h : IsFalseItem v c) :
    ∃ s, rootStep c = some s ∧ (∀ p ∈ s.prem, v p = true) ∧ v s.concl = false := by
  cases c with
  | prem y => exact h.elim
  | infer y n sub =>
    refine ⟨_, rfl, ?_, h.2⟩
    intro p hp
    obtain ⟨i, -, rfl⟩ := Finset.mem_image.1 hp
    exact h.1 i
  | link y sub =>
    refine ⟨_, rfl, ?_, h.2⟩
    intro p hp
    rw [Finset.mem_singleton.1 hp]
    exact h.1

/-- **T4 Lemma 4.1, last clause (abstract).** Let `R` be a set of steps all of which preserve
`v`-truth (e.g. the `h`-valid steps, when `v` is `h`-admissible).  If the premises of `t` are true
and its conclusion false under `v`, the descent walk finds a node of `t` whose step is *not*
in `R`. -/
theorem descent_tree_not_mem [DecidableEq X] (v : X → Bool) (R : Set (Step X))
    (hR : ∀ s ∈ R, (∀ p ∈ s.prem, v p = true) → v s.concl = true)
    (t : ArgTree X) (hprem : PremsTrue v t) (hconcl : v t.concl = false) :
    ∃ c s, descend v t = some c ∧ Occurs c t ∧ rootStep c = some s ∧ s ∉ R := by
  obtain ⟨c, hc, hocc, hfalse⟩ := descend_spec v t hprem hconcl
  obtain ⟨s, hs, hsprem, hsconcl⟩ := hfalse.exists_rootStep
  refine ⟨c, s, hc, hocc, hs, fun hsR => ?_⟩
  rw [hR s hsR hsprem] at hsconcl
  exact absurd hsconcl (by decide)

/-- **T4 Lemma 4.1, last clause, classical propositional instance.** For an argument tree over
propositional formulas, if a valuation `w` makes all premises true and the conclusion false, the
descent walk finds a node whose step is not classically sound (`∉ SemSound`). -/
theorem descent_tree_not_semSound (w : Valuation) (t : ArgTree Formula)
    (hprem : PremsTrue (fun φ => φ.eval w) t) (hconcl : t.concl.eval w = false) :
    ∃ c s, descend (fun φ => φ.eval w) t = some c ∧ Occurs c t ∧ rootStep c = some s ∧
      s ∉ SemSound := by
  refine descent_tree_not_mem (fun φ => φ.eval w) SemSound ?_ t hprem hconcl
  intro s hs hprem'
  exact hs w (fun ψ hψ => hprem' ψ hψ)

end ArgTree

/-! ### Line-list (DAG) form, the paper's literal format -/

/-- The justification of a line of an argument with `m` lines. -/
inductive Just (m : ℕ) : Type
  /-- a premise -/
  | prem : Just m
  /-- an inference `Γ ⇒ y_j` from the lines `Γ` -/
  | infer (Γ : Finset (Fin m)) : Just m
  /-- a link `y_i ⇝ y_j` -/
  | link (i : Fin m) : Just m

/-- The lines a justification depends on. -/
def Just.deps {m : ℕ} : Just m → Finset (Fin m)
  | prem => ∅
  | infer Γ => Γ
  | link i => {i}

/-- An informal argument (T4 §1.1): a finite list of lines `y_0, …, y_{len-1}`, each of which is
a premise, an inference from a finite set of *earlier* lines, or a link from an *earlier* line.
(The side condition `str(y_i) = str(y_j)` on links plays no role in descent and is omitted.) -/
structure LineArg (X : Type u) where
  /-- number of lines -/
  len : ℕ
  /-- the lines -/
  line : Fin len → X
  /-- the justification of each line -/
  just : Fin len → Just len
  /-- dependencies point to earlier lines -/
  earlier : ∀ j, ∀ i ∈ (just j).deps, i < j

namespace LineArg

variable {X : Type u} (α : LineArg X) (v : X → Bool)

/-- Line `j` is a *false item* under `v`: an inference line with all antecedents true and false
conclusion, or a link with true source and false target. -/
def IsFalseItem (j : Fin α.len) : Prop :=
  (∃ Γ, α.just j = .infer Γ ∧ (∀ k ∈ Γ, v (α.line k) = true) ∧ v (α.line j) = false) ∨
    (∃ i, α.just j = .link i ∧ v (α.line i) = true ∧ v (α.line j) = false)

/-- `Walk α v j i n` : starting from line `j`, the walk reaches line `i` after `n` moves, each
move going from a line to one of its *false* dependencies. -/
inductive Walk : Fin α.len → Fin α.len → ℕ → Prop
  | refl (j : Fin α.len) : Walk j j 0
  | step {j k i : Fin α.len} {n : ℕ} : k ∈ (α.just j).deps → v (α.line k) = false →
      Walk k i n → Walk j i (n + 1)

/-- **T4 Lemma 4.1 (descent), line-list form.** Suppose all premise lines are true under `v`, and
let `ht` be any height function that strictly decreases along dependencies (for instance the
line index, or the depth = length of the longest dependency path below a line).  Then from any
false line `j` a walk back along false dependencies reaches a false item `i` after at most
`ht j - ht i ≤ ht j` moves. -/
theorem descent (hprem : ∀ j, α.just j = .prem → v (α.line j) = true)
    (ht : Fin α.len → ℕ) (hht : ∀ j, ∀ k ∈ (α.just j).deps, ht k < ht j)
    (j : Fin α.len) (hj : v (α.line j) = false) :
    ∃ i n, α.Walk v j i n ∧ n + ht i ≤ ht j ∧ α.IsFalseItem v i := by
  induction j using WellFoundedLT.induction with
  | ind j ih =>
    cases hJ : α.just j with
    | prem =>
      rw [hprem j hJ] at hj
      exact absurd hj (by decide)
    | infer Γ =>
      by_cases hall : ∀ k ∈ Γ, v (α.line k) = true
      · exact ⟨j, 0, Walk.refl j, by omega, Or.inl ⟨Γ, hJ, hall, hj⟩⟩
      · push Not at hall
        obtain ⟨k, hkΓ, hk⟩ := hall
        have hk' : v (α.line k) = false := by simpa using hk
        have hdep : k ∈ (α.just j).deps := by rw [hJ]; exact hkΓ
        obtain ⟨i, n, hw, hn, hi⟩ := ih k (α.earlier j k hdep) hk'
        have := hht j k hdep
        exact ⟨i, n + 1, Walk.step hdep hk' hw, by omega, hi⟩
    | link k =>
      by_cases hk : v (α.line k) = true
      · exact ⟨j, 0, Walk.refl j, by omega, Or.inr ⟨k, hJ, hk, hj⟩⟩
      · have hk' : v (α.line k) = false := by simpa using hk
        have hdep : k ∈ (α.just j).deps := by rw [hJ]; exact Finset.mem_singleton_self k
        obtain ⟨i, n, hw, hn, hi⟩ := ih k (α.earlier j k hdep) hk'
        have := hht j k hdep
        exact ⟨i, n + 1, Walk.step hdep hk' hw, by omega, hi⟩

/-- **T4 Lemma 4.1, line-list form, with the line index as height.** If all premises are true
and some line `j` (e.g. the conclusion) is false, a false item is reached from `j` by a walk
back along false lines of at most `j` moves. -/
theorem descent_index (hprem : ∀ j, α.just j = .prem → v (α.line j) = true)
    (j : Fin α.len) (hj : v (α.line j) = false) :
    ∃ i n, α.Walk v j i n ∧ n ≤ (j : ℕ) ∧ α.IsFalseItem v i := by
  obtain ⟨i, n, hw, hn, hi⟩ :=
    α.descent v hprem (fun j => (j : ℕ)) (fun j k hk => α.earlier j k hk) j hj
  exact ⟨i, n, hw, by omega, hi⟩

/-- The depth of line `j`: the length (number of dependency edges) of a longest dependency path
starting at `j` (T4 §1.1: "the depth of α is the length of its longest dependency path"). -/
def depthAt (j : Fin α.len) : ℕ :=
  (α.just j).deps.attach.sup fun k => depthAt k.1 + 1
termination_by (j : ℕ)
decreasing_by exact α.earlier j k.1 k.2

theorem depthAt_lt {j k : Fin α.len} (hk : k ∈ (α.just j).deps) : α.depthAt k < α.depthAt j := by
  have h := Finset.le_sup (f := fun k : {x // x ∈ (α.just j).deps} => α.depthAt k.1 + 1)
    (Finset.mem_attach _ ⟨k, hk⟩)
  rw [depthAt.eq_1 α j]
  exact Nat.lt_of_succ_le h

/-- **T4 Lemma 4.1, line-list form, with the paper's depth bound.** If all premises are true and
line `j` (e.g. the conclusion) is false, a false item is reached from `j` by a walk back along
false lines of at most `depthAt j` moves. -/
theorem descent_depth (hprem : ∀ j, α.just j = .prem → v (α.line j) = true)
    (j : Fin α.len) (hj : v (α.line j) = false) :
    ∃ i n, α.Walk v j i n ∧ n ≤ α.depthAt j ∧ α.IsFalseItem v i := by
  obtain ⟨i, n, hw, hn, hi⟩ :=
    α.descent v hprem α.depthAt (fun _ _ hk => α.depthAt_lt hk) j hj
  exact ⟨i, n, hw, by omega, hi⟩

/-- The step performed at line `j` (inference `Γ ⇒ y_j`, or link `y_i ⇝ y_j` read as the
one-premise step `{y_i} ⇒ y_j`), if `j` is not a premise. -/
def itemStep [DecidableEq X] (j : Fin α.len) : Option (Step X) :=
  match α.just j with
  | .prem => none
  | .infer Γ => some ⟨Γ.image α.line, α.line j⟩
  | .link i => some ⟨{α.line i}, α.line j⟩

/-- **T4 Lemma 4.1, last clause, line-list form.** If every step in `R` preserves `v`-truth
(e.g. `R` = the `h`-valid steps and `v` is `h`-admissible), the item found by descent from a false
line is not in `R`. -/
theorem descent_not_mem [DecidableEq X] (R : Set (Step X))
    (hR : ∀ s ∈ R, (∀ p ∈ s.prem, v p = true) → v s.concl = true)
    (hprem : ∀ j, α.just j = .prem → v (α.line j) = true)
    (j : Fin α.len) (hj : v (α.line j) = false) :
    ∃ i n s, α.Walk v j i n ∧ n ≤ (j : ℕ) ∧ α.itemStep i = some s ∧ s ∉ R := by
  obtain ⟨i, n, hw, hn, hi⟩ := α.descent_index v hprem j hj
  have key : ∃ s, α.itemStep i = some s ∧ (∀ p ∈ s.prem, v p = true) ∧ v s.concl = false := by
    rcases hi with ⟨Γ, hJ, hall, hfalse⟩ | ⟨k, hJ, htrue, hfalse⟩
    · refine ⟨⟨Γ.image α.line, α.line i⟩, by simp [itemStep, hJ], ?_, hfalse⟩
      intro p hp
      obtain ⟨k, hk, rfl⟩ := Finset.mem_image.1 hp
      exact hall k hk
    · refine ⟨⟨{α.line k}, α.line i⟩, by simp [itemStep, hJ], ?_, hfalse⟩
      intro p hp
      rw [Finset.mem_singleton.1 hp]
      exact htrue
  obtain ⟨s, hs, hsprem, hsconcl⟩ := key
  refine ⟨i, n, s, hw, hn, hs, fun hsR => ?_⟩
  rw [hR s hsR hsprem] at hsconcl
  exact absurd hsconcl (by decide)

end LineArg

end Descent

end Blame
end InfLearn

/-! ## Sanity checks -/

section Examples

open InfLearn.Blame

/-- A two-step argument `p, (p ⇒ q), (q ⇒ r)` with `v p = v q = true`, `v r = false`:
descent blames the last inference. -/
example :
    let t : ArgTree ℕ := .infer 2 1 fun _ => .infer 1 1 fun _ => .prem 0
    ArgTree.descend (fun n => decide (n < 2)) t = some t := by
  rfl

/-- With `v q = false` the walk moves one line back and blames `p ⇒ q`. -/
example :
    let t : ArgTree ℕ := .infer 2 1 fun _ => .infer 1 1 fun _ => .prem 0
    ArgTree.descend (fun n => decide (n < 1)) t = some (.infer 1 1 fun _ => .prem 0) := by
  rfl

end Examples

/-! ## Axiom checks -/

#print axioms InfLearn.Blame.isClean_iff_forall_not_subset
#print axioms InfLearn.Blame.isClean_iff_isTransversal_sdiff
#print axioms InfLearn.Blame.isMaxClean_iff
#print axioms InfLearn.Blame.isMinTransversal_iff
#print axioms InfLearn.Blame.setOf_isMaxClean_eq_image
#print axioms InfLearn.Blame.exists_private_of_mem_minTransversal
#print axioms InfLearn.Blame.exists_minTransversal_mem_iff_of_antichain
#print axioms InfLearn.Blame.exists_minTransversal_mem_iff
#print axioms InfLearn.Blame.coe_blameSet_eq_iUnion_minTransversal
#print axioms InfLearn.Blame.mem_inter_maxClean_iff
#print axioms InfLearn.Blame.mem_blameSet_iff_exists_maxClean
#print axioms InfLearn.Blame.exists_isMaxClean
#print axioms InfLearn.Blame.iInter_maxClean_eq
#print axioms InfLearn.Blame.isClean_sdiff_blameSet
#print axioms InfLearn.Blame.isClean_iInter_maxClean
#print axioms InfLearn.Blame.existsUnique_minTransversal_iff
#print axioms InfLearn.Blame.ArgTree.descend_spec
#print axioms InfLearn.Blame.ArgTree.descent_tree
#print axioms InfLearn.Blame.ArgTree.moves_lt_depth
#print axioms InfLearn.Blame.ArgTree.evals_le_maxPathFanIn
#print axioms InfLearn.Blame.ArgTree.descent_tree_not_mem
#print axioms InfLearn.Blame.ArgTree.descent_tree_not_semSound
#print axioms InfLearn.Blame.LineArg.descent
#print axioms InfLearn.Blame.LineArg.descent_index
#print axioms InfLearn.Blame.LineArg.descent_depth
#print axioms InfLearn.Blame.LineArg.descent_not_mem
