import InfLearn.Steps

/-!
# T1: stepwise soundness, version-space verification, "tonk beyond the horizon"

Formalisation of three results of `research/theory/T1-soundness-under-search.md`
(including the corrections of its *Verification log*).

## 1. Lemma 1.1 (reasoner soundness = stepwise soundness)

`lemma_1_1 : (∀ B, Cl A B ⊆ Cl R B) ↔ A ⊆ {(Π, j) | j ∈ Cl R Π}` -- exactly the paper's
statement, for an arbitrary judgment type `J` (the proof is the shared
`Cl_subset_Cl_iff_subset_Sound` of `InfLearn.Steps`).  We also record the "conversely"
sentence after the lemma (`concl_not_derivable_of_not_mem_Sound`).

## 2. Theorem 3.1 (version-space verification: soundness and optimality)

We model the paper's §1.2 interaction protocol for **deterministic** verifiers:
* a hypothesis class `H : Set (Set (Step J))`, human positive data `P0`;
* histories are lists of events `(query, answer, oracle label)`; the oracle label is
  returned exactly on `ESC` and is `1[q ∈ R*]`;
* a verifier is any function `History → Step → Answer`; a prover is any
  (adaptive, unrestricted) function `History → Step` -- it may depend on `R*`, on the
  verifier's code and on the whole history (they are fixed before the prover is chosen);
* `run V R π n` is the transcript after `n` rounds against target `R`;
* the version space at a history: `VSh H P0 h = VS H (P0 ∪ pos(h)) (neg(h))` where
  `VS H P N = {R ∈ H | P ⊆ R, R ∩ N = ∅}`.

The soundness notion is parametrised by `valid : Set (Step J) → Set (Step J)`:
`valid = id` is the paper's notion (Def. 1.2 with δ = 0: never accept `q ∉ R*`), and
`valid = Sound` is the "step-set closure" notion (never accept a step that is not derivable
in `R*`; by Lemma 1.1 this is exactly soundness of the induced reasoner).

* `thm_3_1_a`: the VS verifier (accept iff `q ∈ ⋂ VS`, reject iff `q ∉ ⋃ VS`, else escalate)
  is 0-sound, against every adaptive prover and at every time; `R* ∈ VS` throughout.
  `thm_3_1_a_reasoner`: hence every accepted step set gives a sound reasoner
  (`Cl_{accepted}(B) ⊆ Cl_{R*}(B)`).
* `thm_3_1_b`: deterministic form of (b): a deterministic 0-sound verifier never accepts
  `q ∉ ⋂ VS(h)` at any history `h` that is reachable (under any target and any prover).
  `vsVerifier_optimal`: so its acceptance region at `h` is contained in the VS verifier's.
* `thm_3_1_b_closure`, `vsVerifierSound_optimal`, `thm_3_1_a_closure`: the same for the
  step-set-closure soundness notion, where the optimal acceptance region is
  `⋂_{R ∈ VS} Sound R` (which contains `⋂ VS`).
* Static (single version space) forms: `thm_3_1_a_static`, `thm_3_1_b_static`
  (from `sInter_VS_subset`, `subset_sInter_VS_iff`, `reasoner_sound_for_all_VS_iff`,
  `sInter_VS_subset_iInter_Sound`).

The randomized/δ-sound version of (b) (joint probabilities over the verifier's coins) is
**not** formalised; only the deterministic special case stated explicitly in the paper's
(b) ("In particular, a deterministic δ-sound verifier with δ < 1 never accepts…"), which
for deterministic verifiers and provers is the same as 0-soundness.

## 3. Theorem 2.1 (tonk beyond the horizon)

Judgments are formulas (`J = Formula`), as in T1 §2.
* `Rstar`: the instances of ⊤I, ∧I, ∧E₁, ∧E₂, ∨I₁, ∨I₂ (`Rstar_sound : Rstar ⊆ SemSound`;
  `Rstar_eq_substClosure`: it is given by six pure schemas).
* `topConj j` = `⊤^(j) = ⊤ ∧ (⊤ ∧ ⋯)` with `j` conjuncts (`j ≥ 1`; `topConj 0 := ⊤` is a
  convention, so `T 0 = T 1`).
* `T j = {({A ∨ ⊤^(j)}, A) | A}` (`T_eq_substClosure`: a single pure one-metavariable schema).
* (i) `thm_2_1_i`: for every `R ⊇ inst(⊤I, ∧I, ∨I₂)` (in particular `Rstar`, or `Rstar` plus
  any other sound rules) and every `j`, `Cl_{R ∪ T_j}(∅)` is the set of **all** formulas;
  `thm_2_1_i_derivation`: an explicit linear derivation of length `j + 2` (`j ≥ 1`) whose
  first `j + 1` steps are ⊤I/∧I/∨I₂ steps (and not `T_j` steps) and whose last step is the
  `T_j` step; `tonk_not_semSound`: for non-tautologous `C` that last step is unsound, hence
  not in any sound `R*`.
* (ii) `T_disjoint`: the `T_j` (`j ≥ 1`) are pairwise disjoint;
  `thm_2_1_ii`: for every summable non-negative weight function `q` on steps (in particular
  every probability distribution on the countable set of steps), `Q(T_j) = ∑_{s ∈ T_j} q s → 0`.
* `thm_2_1_error_and_trivial`: hence for every such `Q` and `ε > 0`, eventually in `j`, the
  hypothesis `R ∪ T_j` has `Q`-error `Q((R ∪ T_j) ∆ R) < ε` and derives every formula.
* `T_not_subset_Sound` (via Lemma 1.1): `R ∪ T_j` is not a sound reasoner for any sound `R`.
-/

namespace InfLearn
namespace StepSoundness

open Filter Topology

universe u

/-! ## 1. Lemma 1.1 -/

section Lemma11

variable {J : Type u}

/-- **T1 Lemma 1.1 (reasoner soundness = stepwise soundness).**
`Cl_A(B) ⊆ Cl_{R*}(B)` for every `B` iff every accepted step `(Π, j) ∈ A` is derivable in
`R*`, i.e. `j ∈ Cl_{R*}(Π)`. -/
theorem lemma_1_1 (A R : Set (Step J)) :
    (∀ B : Set J, Cl A B ⊆ Cl R B) ↔ A ⊆ {s : Step J | s.concl ∈ Cl R ↑s.prem} :=
  Cl_subset_Cl_iff_subset_Sound

/-- The "conversely" remark after Lemma 1.1: one accepted non-derivable step `(Π, j)`
yields, from the leaves `Π`, a conclusion that is not derivable in `R*`. -/
theorem concl_not_derivable_of_not_mem_Sound {A R : Set (Step J)} {s : Step J} (hs : s ∈ A)
    (hns : s ∉ Sound R) : s.concl ∈ Cl A ↑s.prem ∧ s.concl ∉ Cl R ↑s.prem :=
  ⟨concl_mem_Cl hs subset_Cl, hns⟩

/-- The stronger condition `A ⊆ R*` used from T1 §1.1 on implies reasoner soundness. -/
theorem reasoner_sound_of_subset {A R : Set (Step J)} (h : A ⊆ R) (B : Set J) :
    Cl A B ⊆ Cl R B :=
  (lemma_1_1 A R).2 (h.trans subset_Sound) B

end Lemma11

/-! ### Linear derivations (used to count the steps in Thm 2.1(i)) -/

section LinDeriv

variable {J : Type u}

/-- A linear derivation from leaves `B`: a list of steps, each of whose premises is a leaf or
the conclusion of an earlier step of the list. -/
inductive LinDeriv (B : Set J) : List (Step J) → Prop
  | nil : LinDeriv B []
  | snoc {l : List (Step J)} {s : Step J} : LinDeriv B l →
      (∀ p ∈ s.prem, p ∈ B ∨ ∃ t ∈ l, t.concl = p) → LinDeriv B (l ++ [s])

/-- Every conclusion in a linear derivation using steps of `A` is in `Cl_A(B)`. -/
theorem LinDeriv.concl_mem_Cl {A : Set (Step J)} {B : Set J} {l : List (Step J)}
    (h : LinDeriv B l) (hA : ∀ s ∈ l, s ∈ A) : ∀ s ∈ l, s.concl ∈ Cl A B := by
  induction h with
  | nil => simp
  | @snoc l s _ hprem ih =>
    have ih' := ih (fun t ht => hA t (List.mem_append_left _ ht))
    intro t ht
    rcases List.mem_append.1 ht with ht | ht
    · exact ih' t ht
    · rw [List.mem_singleton] at ht
      subst ht
      refine InfLearn.concl_mem_Cl (hA _ (List.mem_append_right _ (List.mem_singleton_self _))) ?_
      intro p hp
      rcases hprem p (Finset.mem_coe.1 hp) with hpB | ⟨t', ht', rfl⟩
      · exact subset_Cl hpB
      · exact ih' t' ht'

end LinDeriv

/-! ## 2. Version spaces and Theorem 3.1 -/

section VersionSpace

variable {J : Type u}

/-- The version space `VS(P, N) = {R ∈ H : P ⊆ R, R ∩ N = ∅}` (T1 §3). -/
def VS (H : Set (Set (Step J))) (P N : Set (Step J)) : Set (Set (Step J)) :=
  {R | R ∈ H ∧ P ⊆ R ∧ ∀ q ∈ N, q ∉ R}

variable {H : Set (Set (Step J))} {P N : Set (Step J)} {R : Set (Step J)}

theorem mem_VS : R ∈ VS H P N ↔ R ∈ H ∧ P ⊆ R ∧ ∀ q ∈ N, q ∉ R := Iff.rfl

/-- Static Thm 3.1(a): if the target is in the version space, the accepted region
`⋂ VS` only contains valid steps. -/
theorem sInter_VS_subset (hR : R ∈ VS H P N) : ⋂₀ VS H P N ⊆ R :=
  Set.sInter_subset_of_mem hR

/-- Static Thm 3.1(a), reasoner form (via Lemma 1.1). -/
theorem sInter_VS_reasoner_sound (hR : R ∈ VS H P N) (B : Set J) :
    Cl (⋂₀ VS H P N) B ⊆ Cl R B :=
  reasoner_sound_of_subset (sInter_VS_subset hR) B

/-- Static Thm 3.1(b): an acceptance set that is sound (`⊆ R`) for every hypothesis of the
version space is contained in `⋂ VS`. -/
theorem subset_sInter_VS_iff {Acc : Set (Step J)} :
    Acc ⊆ ⋂₀ VS H P N ↔ ∀ R ∈ VS H P N, Acc ⊆ R :=
  Set.subset_sInter_iff

/-- Static Thm 3.1(b), step-set-closure form: an acceptance set gives a sound reasoner
for every hypothesis of the version space iff it is contained in `⋂_{R ∈ VS} Sound R`. -/
theorem reasoner_sound_for_all_VS_iff {Acc : Set (Step J)} :
    (∀ R ∈ VS H P N, ∀ B : Set J, Cl Acc B ⊆ Cl R B) ↔ Acc ⊆ ⋂ R ∈ VS H P N, Sound R := by
  simp only [Set.subset_iInter_iff, Cl_subset_Cl_iff_subset_Sound]

theorem sInter_VS_subset_iInter_Sound : ⋂₀ VS H P N ⊆ ⋂ R ∈ VS H P N, Sound R := by
  simp only [Set.subset_iInter_iff]
  intro R hR
  exact (sInter_VS_subset hR).trans subset_Sound

theorem iInter_Sound_reasoner_sound (hR : R ∈ VS H P N) (B : Set J) :
    Cl (⋂ R' ∈ VS H P N, Sound R') B ⊆ Cl R B :=
  reasoner_sound_for_all_VS_iff.2 subset_rfl R hR B

/-- **T1 Thm 3.1(a), static form.** If the target `R*` is in `H` and the data are truthful
(`P ⊆ R*`, `N ∩ R* = ∅`), accepting exactly the steps of `⋂ VS(P, N)` never accepts a step
outside `R*`, and the induced reasoner is sound: `Cl_{⋂ VS}(B) ⊆ Cl_{R*}(B)`. -/
theorem thm_3_1_a_static (hR : R ∈ H) (hP : P ⊆ R) (hN : ∀ q ∈ N, q ∉ R) :
    ⋂₀ VS H P N ⊆ R ∧ ∀ B : Set J, Cl (⋂₀ VS H P N) B ⊆ Cl R B :=
  ⟨sInter_VS_subset ⟨hR, hP, hN⟩, sInter_VS_reasoner_sound ⟨hR, hP, hN⟩⟩

/-- **T1 Thm 3.1(b), static deterministic form.** (1) An acceptance set that is sound
(`Acc ⊆ R`) for every hypothesis `R` of the version space is contained in `⋂ VS`.
(2) Step-set-closure version: an acceptance set whose reasoner is sound for every hypothesis of
the version space (equivalently, by Lemma 1.1, `Acc ⊆ Sound R` for all `R ∈ VS`) is contained in
`⋂_{R ∈ VS} Sound R`, which is itself such a set and contains `⋂ VS`. -/
theorem thm_3_1_b_static {Acc : Set (Step J)} :
    ((∀ R ∈ VS H P N, Acc ⊆ R) → Acc ⊆ ⋂₀ VS H P N) ∧
    ((∀ R ∈ VS H P N, ∀ B : Set J, Cl Acc B ⊆ Cl R B) → Acc ⊆ ⋂ R ∈ VS H P N, Sound R) ∧
    (∀ R ∈ VS H P N, ∀ B : Set J, Cl (⋂ R' ∈ VS H P N, Sound R') B ⊆ Cl R B) ∧
    ⋂₀ VS H P N ⊆ ⋂ R ∈ VS H P N, Sound R :=
  ⟨subset_sInter_VS_iff.2, reasoner_sound_for_all_VS_iff.1,
    fun _ hR B => iInter_Sound_reasoner_sound hR B, sInter_VS_subset_iInter_Sound⟩

/-! ### The interaction protocol (T1 §1.2), deterministic verifiers -/

/-- Verifier answers. -/
inductive Answer
  | acc
  | rej
  | esc
  deriving DecidableEq, Repr

/-- One round: the query, the verifier's answer and the oracle's label (present iff `ESC`). -/
structure Event (J : Type u) where
  query : Step J
  answer : Answer
  label : Option Bool

/-- A history (oldest round first). -/
abbrev History (J : Type u) := List (Event J)

/-- A deterministic verifier: an answer for every history and query (the human data `P0` is
fixed and may be built into the verifier). -/
abbrev Verifier (J : Type u) := History J → Step J → Answer

/-- An adaptive prover: the next query as a function of the history. Since it is chosen after
the target `R*` and the verifier, it may depend on both. -/
abbrev Prover (J : Type u) := History J → Step J

open Classical in
/-- The (truthful, deterministic) oracle: on `ESC` it returns the label `1[q ∈ R*]`. -/
noncomputable def oracle (R : Set (Step J)) (a : Answer) (q : Step J) : Option Bool :=
  if a = Answer.esc then some (decide (q ∈ R)) else none

/-- The event produced when query `q` is submitted at history `h` against target `R`. -/
noncomputable def respond (V : Verifier J) (R : Set (Step J)) (h : History J) (q : Step J) :
    Event J :=
  ⟨q, V h q, oracle R (V h q) q⟩

/-- The transcript of the first `n` rounds of verifier `V` and prover `π` against target `R`. -/
noncomputable def run (V : Verifier J) (R : Set (Step J)) (π : Prover J) : ℕ → History J
  | 0 => []
  | n + 1 => run V R π n ++ [respond V R (run V R π n) (π (run V R π n))]

/-- `R` agrees with every oracle label of `h`. -/
def Consistent (R : Set (Step J)) (h : History J) : Prop :=
  ∀ e ∈ h, ∀ b : Bool, e.label = some b → (b = true ↔ e.query ∈ R)

/-- Positively labelled queries of a history. -/
def posData (h : History J) : Set (Step J) :=
  {q | ∃ e ∈ h, e.query = q ∧ e.label = some true}

/-- Negatively labelled queries of a history. -/
def negData (h : History J) : Set (Step J) :=
  {q | ∃ e ∈ h, e.query = q ∧ e.label = some false}

/-- The version space at history `h`: computed from `P0` and all labels in `h`. -/
def VSh (H : Set (Set (Step J))) (P0 : Set (Step J)) (h : History J) : Set (Set (Step J)) :=
  VS H (P0 ∪ posData h) (negData h)

variable {P0 : Set (Step J)} {V : Verifier J} {π : Prover J}

theorem mem_VSh {h : History J} : R ∈ VSh H P0 h ↔ R ∈ H ∧ P0 ⊆ R ∧ Consistent R h := by
  constructor
  · rintro ⟨hH, hP, hN⟩
    refine ⟨hH, fun x hx => hP (Or.inl hx), ?_⟩
    intro e he b hb
    cases b with
    | true => exact ⟨fun _ => hP (Or.inr ⟨e, he, rfl, hb⟩), fun _ => rfl⟩
    | false =>
      exact ⟨fun h => absurd h (by simp), fun hq => absurd hq (hN _ ⟨e, he, rfl, hb⟩)⟩
  · rintro ⟨hH, hP0, hC⟩
    refine ⟨hH, Set.union_subset hP0 ?_, ?_⟩
    · rintro _ ⟨e, he, rfl, hb⟩
      exact (hC e he true hb).1 rfl
    · rintro _ ⟨e, he, rfl, hb⟩ hq
      exact absurd ((hC e he false hb).2 hq) (by simp)

@[simp] theorem run_zero : run V R π 0 = [] := rfl

theorem run_succ (n : ℕ) :
    run V R π (n + 1) = run V R π n ++ [respond V R (run V R π n) (π (run V R π n))] := rfl

@[simp] theorem length_run (n : ℕ) : (run V R π n).length = n := by
  induction n with
  | zero => rfl
  | succ n ih => simp [run_succ, ih]

theorem run_prefix {m n : ℕ} (h : m ≤ n) : run V R π m <+: run V R π n := by
  induction h with
  | refl => exact List.prefix_refl _
  | step _ ih => exact ih.trans (by rw [run_succ]; exact List.prefix_append _ _)

/-- Every event of a run is the response to the prover's query at an earlier prefix. -/
theorem exists_of_mem_run {n : ℕ} {e : Event J} (he : e ∈ run V R π n) :
    ∃ m < n, e = respond V R (run V R π m) (π (run V R π m)) := by
  induction n with
  | zero => simp at he
  | succ n ih =>
    rw [run_succ, List.mem_append, List.mem_singleton] at he
    rcases he with he | rfl
    · obtain ⟨m, hm, rfl⟩ := ih he
      exact ⟨m, by omega, rfl⟩
    · exact ⟨n, by omega, rfl⟩

theorem respond_mem_run_succ (n : ℕ) :
    respond V R (run V R π n) (π (run V R π n)) ∈ run V R π (n + 1) := by
  rw [run_succ]; simp

/-- All oracle labels are truthful: the target is consistent with its own runs. -/
theorem run_consistent (n : ℕ) : Consistent R (run V R π n) := by
  intro e he b hb
  obtain ⟨m, -, rfl⟩ := exists_of_mem_run he
  simp only [respond, oracle] at hb ⊢
  split_ifs at hb
  cases hb
  simp

/-- At every time, the target is in the version space (T1 Thm 3.1(a): "`R* ∈ VS` at all
times"), for every verifier and prover. -/
theorem target_mem_VSh (hR : R ∈ H) (hP0 : P0 ⊆ R) (n : ℕ) : R ∈ VSh H P0 (run V R π n) :=
  mem_VSh.2 ⟨hR, hP0, run_consistent n⟩

/-- If `R'` agrees with all labels of the run against `R`, then the run against `R'` is the
same (the verifier is deterministic and only sees labels). -/
theorem run_eq_of_consistent {R' : Set (Step J)} {n : ℕ} (hc : Consistent R' (run V R π n))
    {m : ℕ} (hm : m ≤ n) : run V R' π m = run V R π m := by
  induction m with
  | zero => rfl
  | succ m ih =>
    rw [run_succ, run_succ, ih (by omega)]
    have hmem : respond V R (run V R π m) (π (run V R π m)) ∈ run V R π n :=
      (run_prefix hm).subset (respond_mem_run_succ m)
    have key : oracle R' (V (run V R π m) (π (run V R π m))) (π (run V R π m)) =
        oracle R (V (run V R π m) (π (run V R π m))) (π (run V R π m)) := by
      unfold oracle
      split_ifs with ha
      · have h2 := hc _ hmem
        simp only [respond, oracle, ha, if_true] at h2
        have h3 := h2 _ rfl
        simp only [decide_eq_true_eq] at h3
        simp [h3]
      · rfl
    simp only [respond, key]

/-- Changing the prover only on histories of length `≥ n` does not change the first `n`
rounds. -/
theorem run_congr_prover {π' : Prover J} {n : ℕ}
    (hπ : ∀ h : History J, h.length < n → π' h = π h) {m : ℕ} (hm : m ≤ n) :
    run V R π' m = run V R π m := by
  induction m with
  | zero => rfl
  | succ m ih =>
    rw [run_succ, run_succ, ih (by omega), hπ _ (by rw [length_run]; omega)]

/-- Deterministic soundness of a verifier for the class `H` given human data `P0`, relative to
a validity notion `valid`: against every target `R ∈ H` with `P0 ⊆ R`, every prover and at every
time, every accepted query is in `valid R`. With `valid R = R` this is T1 Def. 1.2 with `δ = 0`
(for deterministic verifiers, `δ`-soundness with `δ < 1` is the same). With `valid = Sound` it
is soundness of the induced reasoner (Lemma 1.1). -/
def DetSound (valid : Set (Step J) → Set (Step J)) (V : Verifier J) (H : Set (Set (Step J)))
    (P0 : Set (Step J)) : Prop :=
  ∀ R ∈ H, P0 ⊆ R → ∀ (π : Prover J) (n : ℕ), ∀ e ∈ run V R π n,
    e.answer = Answer.acc → e.query ∈ valid R

/-- The set of queries accepted in the first `n` rounds. -/
def accepted (V : Verifier J) (R : Set (Step J)) (π : Prover J) (n : ℕ) : Set (Step J) :=
  {q | ∃ e ∈ run V R π n, e.answer = Answer.acc ∧ e.query = q}

open Classical in
/-- The version-space verifier relative to `valid`: accept iff `q ∈ valid R` for every `R` in
the current version space, reject iff `q ∈ valid R` for no such `R`, escalate otherwise. -/
noncomputable def vsVerifierWrt (valid : Set (Step J) → Set (Step J)) (H : Set (Set (Step J)))
    (P0 : Set (Step J)) : Verifier J := fun h q =>
  if ∀ R ∈ VSh H P0 h, q ∈ valid R then Answer.acc
  else if ∃ R ∈ VSh H P0 h, q ∈ valid R then Answer.esc
  else Answer.rej

/-- **The VS verifier** of T1 §3: accept iff `q ∈ ⋂ VS`, reject iff `q ∉ ⋃ VS`, otherwise
escalate. -/
noncomputable def vsVerifier (H : Set (Set (Step J))) (P0 : Set (Step J)) : Verifier J :=
  vsVerifierWrt (fun R => R) H P0

theorem vsVerifier_acc_iff {h : History J} {q : Step J} :
    vsVerifier H P0 h q = Answer.acc ↔ q ∈ ⋂₀ VSh H P0 h := by
  simp only [vsVerifier, vsVerifierWrt, Set.mem_sInter]
  split_ifs with h1 h2
  · exact iff_of_true rfl h1
  · exact iff_of_false (by decide) h1
  · exact iff_of_false (by decide) h1

theorem vsVerifier_rej_iff {h : History J} {q : Step J} (hne : (VSh H P0 h).Nonempty) :
    vsVerifier H P0 h q = Answer.rej ↔ q ∉ ⋃₀ VSh H P0 h := by
  simp only [vsVerifier, vsVerifierWrt, Set.mem_sUnion, not_exists, not_and]
  split_ifs with h1 h2
  · obtain ⟨R, hR⟩ := hne
    simp only [false_iff, not_forall, not_not]
    exact ⟨R, hR, h1 R hR⟩
  · simp only [false_iff, not_forall, not_not]
    obtain ⟨R, hR, hq⟩ := h2
    exact ⟨R, hR, hq⟩
  · simp only [not_exists, not_and] at h2
    simpa using h2

theorem vsVerifier_esc_iff {h : History J} {q : Step J} :
    vsVerifier H P0 h q = Answer.esc ↔ q ∈ ⋃₀ VSh H P0 h ∧ q ∉ ⋂₀ VSh H P0 h := by
  simp only [vsVerifier, vsVerifierWrt, Set.mem_sUnion, Set.mem_sInter]
  split_ifs with h1 h2 <;> simp_all

/-- The generic VS verifier is sound for its own validity notion. -/
theorem vsVerifierWrt_sound (valid : Set (Step J) → Set (Step J)) (H : Set (Set (Step J)))
    (P0 : Set (Step J)) : DetSound valid (vsVerifierWrt valid H P0) H P0 := by
  intro R hR hP0 π n e he hacc
  obtain ⟨m, -, rfl⟩ := exists_of_mem_run he
  have hRV := target_mem_VSh (V := vsVerifierWrt valid H P0) (π := π) hR hP0 m
  simp only [respond, vsVerifierWrt] at hacc ⊢
  split_ifs at hacc with h1 h2
  · exact h1 R hRV

/-- **T1 Thm 3.1(a).** The VS verifier is 0-sound, uniformly: for every target `R* ∈ H` with
`P0 ⊆ R*`, every (adaptive) prover and every time `n`, every accepted query is in `R*`. -/
theorem thm_3_1_a (H : Set (Set (Step J))) (P0 : Set (Step J)) :
    DetSound (fun R => R) (vsVerifier H P0) H P0 :=
  vsVerifierWrt_sound _ H P0

/-- Thm 3.1(a), reasoner form: the steps accepted by a sound verifier (e.g. the VS verifier)
up to any time generate a sound reasoner: `Cl_{accepted}(B) ⊆ Cl_{R*}(B)`. -/
theorem thm_3_1_a_reasoner {valid : Set (Step J) → Set (Step J)}
    (hvalid : ∀ R, valid R ⊆ Sound R) (hV : DetSound valid V H P0) (hR : R ∈ H)
    (hP0 : P0 ⊆ R) (π : Prover J) (n : ℕ) (B : Set J) :
    Cl (accepted V R π n) B ⊆ Cl R B := by
  refine (lemma_1_1 _ R).2 ?_ B
  rintro _ ⟨e, he, hacc, rfl⟩
  exact hvalid R (hV R hR hP0 π n e he hacc)

/-- Thm 3.1(a) for the VS verifier, reasoner form. -/
theorem vsVerifier_reasoner_sound (hR : R ∈ H) (hP0 : P0 ⊆ R) (π : Prover J) (n : ℕ)
    (B : Set J) : Cl (accepted (vsVerifier H P0) R π n) B ⊆ Cl R B :=
  thm_3_1_a_reasoner (fun _ => subset_Sound) (thm_3_1_a H P0) hR hP0 π n B

/-- **Thm 3.1(b), generic deterministic form.** Let `V` be deterministic and sound (relative to
`valid`). At any history `h` reachable by some prover against some target, `V` does not accept
any `q` such that `q ∉ valid R'` for some `R'` in the version space `VS(h)`.

Proof (paper): run the same prover against `R'` instead; since `R'` agrees with all labels,
the transcript is the same, then submit `q`; soundness for target `R'` forbids accepting. -/
theorem not_acc_of_exists_VSh {valid : Set (Step J) → Set (Step J)}
    (hV : DetSound valid V H P0) (R : Set (Step J)) (π : Prover J) (n : ℕ) {q : Step J}
    (hq : ∃ R' ∈ VSh H P0 (run V R π n), q ∉ valid R') :
    V (run V R π n) q ≠ Answer.acc := by
  classical
  obtain ⟨R', hR', hqR'⟩ := hq
  obtain ⟨hH, hP0, hc⟩ := mem_VSh.1 hR'
  intro hacc
  let π' : Prover J := fun h' => if h'.length = n then q else π h'
  have h1 : run V R' π' n = run V R π n := by
    rw [run_congr_prover (π := π) (π' := π') (n := n) ?_ le_rfl]
    · exact run_eq_of_consistent hc le_rfl
    · intro h' hlen
      simp [π', Nat.ne_of_lt hlen]
  have hmem : respond V R' (run V R π n) q ∈ run V R' π' (n + 1) := by
    have := respond_mem_run_succ (V := V) (R := R') (π := π') n
    rwa [h1, show π' (run V R π n) = q by simp [π']] at this
  exact hqR' (hV R' hH hP0 π' (n + 1) _ hmem hacc)

/-- **T1 Thm 3.1(b), deterministic form.** A deterministic 0-sound verifier never accepts a
query `q ∉ ⋂ VS`, where `VS` is computed from `P0` and all labels of the current history `h`
(at every history `h` produced by some prover against some target). -/
theorem thm_3_1_b (hV : DetSound (fun R => R) V H P0) (R : Set (Step J)) (π : Prover J)
    (n : ℕ) {q : Step J} (hq : q ∉ ⋂₀ VSh H P0 (run V R π n)) :
    V (run V R π n) q ≠ Answer.acc := by
  apply not_acc_of_exists_VSh hV
  simpa [Set.mem_sInter, not_forall] using hq

/-- **Optimality of the VS verifier (Thm 3.1).** At every reachable history, the acceptance
region of any deterministic 0-sound verifier is contained in that of the VS verifier. -/
theorem vsVerifier_optimal (hV : DetSound (fun R => R) V H P0) (R : Set (Step J))
    (π : Prover J) (n : ℕ) {q : Step J} (hacc : V (run V R π n) q = Answer.acc) :
    vsVerifier H P0 (run V R π n) q = Answer.acc := by
  rw [vsVerifier_acc_iff]
  by_contra hq
  exact thm_3_1_b hV R π n hq hacc

/-- **Thm 3.1(b), step-set-closure form.** A deterministic verifier that only accepts
`R*`-derivable steps (equivalently, by Lemma 1.1, whose accepted steps always give a sound
reasoner) never accepts `q ∉ ⋂_{R ∈ VS(h)} Sound R`. -/
theorem thm_3_1_b_closure (hV : DetSound Sound V H P0) (R : Set (Step J)) (π : Prover J)
    (n : ℕ) {q : Step J} (hq : q ∉ ⋂ R' ∈ VSh H P0 (run V R π n), Sound R') :
    V (run V R π n) q ≠ Answer.acc := by
  apply not_acc_of_exists_VSh hV
  simpa [Set.mem_iInter, not_forall] using hq

/-- The closure-form VS verifier (accept iff `q ∈ ⋂_{R ∈ VS} Sound R`). -/
noncomputable def vsVerifierSound (H : Set (Set (Step J))) (P0 : Set (Step J)) : Verifier J :=
  vsVerifierWrt Sound H P0

/-- Thm 3.1(a), closure form: the closure-form VS verifier only accepts `R*`-derivable steps. -/
theorem thm_3_1_a_closure (H : Set (Set (Step J))) (P0 : Set (Step J)) :
    DetSound Sound (vsVerifierSound H P0) H P0 :=
  vsVerifierWrt_sound _ H P0

/-- Optimality in the closure form. -/
theorem vsVerifierSound_optimal (hV : DetSound Sound V H P0) (R : Set (Step J))
    (π : Prover J) (n : ℕ) {q : Step J} (hacc : V (run V R π n) q = Answer.acc) :
    vsVerifierSound H P0 (run V R π n) q = Answer.acc := by
  classical
  by_contra hq
  apply not_acc_of_exists_VSh hV R π n _ hacc
  simp only [vsVerifierSound, vsVerifierWrt] at hq
  split_ifs at hq with h1
  · exact absurd rfl hq
  all_goals
    push Not at h1
    exact h1

/-- The VS verifier's acceptances are always among the closure-form verifier's. -/
theorem vsVerifier_acc_imp_vsVerifierSound_acc {h : History J} {q : Step J}
    (hacc : vsVerifier H P0 h q = Answer.acc) : vsVerifierSound H P0 h q = Answer.acc := by
  rw [vsVerifier_acc_iff] at hacc
  simp only [vsVerifierSound, vsVerifierWrt]
  rw [if_pos]
  intro R' hR'
  exact subset_Sound (Set.mem_sInter.1 hacc R' hR')

end VersionSpace

/-! ## 3. Theorem 2.1: tonk beyond the horizon -/

section Tonk

open Formula

/-- `⊤^(j) = ⊤ ∧ (⊤ ∧ ⋯)` with `j` conjuncts (`j ≥ 1`). `topConj 0 := ⊤` is a convention
(the paper only uses `j ≥ 1`). -/
def topConj : ℕ → Formula
  | 0 => Formula.top
  | 1 => Formula.top
  | j + 2 => Formula.and Formula.top (topConj (j + 1))

@[simp] theorem topConj_zero : topConj 0 = Formula.top := rfl
@[simp] theorem topConj_one : topConj 1 = Formula.top := rfl
theorem topConj_add_two (j : ℕ) :
    topConj (j + 2) = Formula.and Formula.top (topConj (j + 1)) := rfl

@[simp] theorem topConj_eval : ∀ (j : ℕ) (v : Valuation), (topConj j).eval v = true
  | 0, _ => rfl
  | 1, _ => rfl
  | j + 2, v => by simp [topConj_add_two, topConj_eval (j + 1) v]

@[simp] theorem topConj_subst : ∀ (j : ℕ) (σ : Subst), (topConj j).subst σ = topConj j
  | 0, _ => rfl
  | 1, _ => rfl
  | j + 2, σ => by simp [topConj_add_two, topConj_subst (j + 1) σ]

theorem topConj_ne_or (j : ℕ) (A B : Formula) : topConj j ≠ Formula.or A B := by
  match j with
  | 0 => simp
  | 1 => simp
  | j + 2 => simp [topConj_add_two]

theorem topConj_succ_inj : ∀ {j k : ℕ}, topConj (j + 1) = topConj (k + 1) → j = k
  | 0, 0, _ => rfl
  | 0, k + 1, h => by simp [topConj_add_two] at h
  | j + 1, 0, h => by simp [topConj_add_two] at h
  | j + 1, k + 1, h => by
    simp only [topConj_add_two, Formula.and.injEq, true_and] at h
    rw [topConj_succ_inj h]

/-! ### The rules -/

/-- ⊤I: `(∅, ⊤)`. -/
def topI : Step Formula := ⟨∅, Formula.top⟩
/-- ∧I: `({A, B}, A ∧ B)`. -/
def andI (A B : Formula) : Step Formula := ⟨{A, B}, Formula.and A B⟩
/-- ∧E₁: `({A ∧ B}, A)`. -/
def andE1 (A B : Formula) : Step Formula := ⟨{Formula.and A B}, A⟩
/-- ∧E₂: `({A ∧ B}, B)`. -/
def andE2 (A B : Formula) : Step Formula := ⟨{Formula.and A B}, B⟩
/-- ∨I₁: `({A}, A ∨ B)`. -/
def orI1 (A B : Formula) : Step Formula := ⟨{A}, Formula.or A B⟩
/-- ∨I₂: `({B}, A ∨ B)`. -/
def orI2 (A B : Formula) : Step Formula := ⟨{B}, Formula.or A B⟩
/-- The padding tonk step `({A ∨ ⊤^(j)}, A)`. -/
def tonk (j : ℕ) (A : Formula) : Step Formula := ⟨{Formula.or A (topConj j)}, A⟩

/-- The three schemas used by the derivation of Thm 2.1(i) (and added by Cor 2.2's `L⁺`):
instances of ⊤I, ∧I, ∨I₂. -/
def Rbase : Set (Step Formula) :=
  {s | s = topI ∨ (∃ A B, s = andI A B) ∨ (∃ A B, s = orI2 A B)}

/-- T1 §2's target calculus `R*`: all instances of ⊤I, ∧I, ∧E₁, ∧E₂, ∨I₁, ∨I₂.
(The paper allows "any other sound rules" too; all results below are stated for every `R`
with `Rbase ⊆ R`, and soundness only uses `R ⊆ SemSound`.) -/
def Rstar : Set (Step Formula) :=
  {s | s = topI ∨ (∃ A B, s = andI A B) ∨ (∃ A B, s = andE1 A B) ∨ (∃ A B, s = andE2 A B) ∨
    (∃ A B, s = orI1 A B) ∨ (∃ A B, s = orI2 A B)}

/-- The single-metavariable pure schema `T_j = {({A ∨ ⊤^(j)}, A) : A a formula}`. -/
def T (j : ℕ) : Set (Step Formula) := Set.range (tonk j)

theorem Rbase_subset_Rstar : Rbase ⊆ Rstar := by
  rintro s (h | h | h)
  · exact Or.inl h
  · exact Or.inr (Or.inl h)
  · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr h))))

/-- `R*` is (classically) sound. -/
theorem Rstar_sound : Rstar ⊆ SemSound := by
  rintro s (rfl | ⟨A, B, rfl⟩ | ⟨A, B, rfl⟩ | ⟨A, B, rfl⟩ | ⟨A, B, rfl⟩ | ⟨A, B, rfl⟩) <;>
    intro v hv
  · rfl
  · have hA := hv A (by simp [andI])
    have hB := hv B (by simp [andI])
    simp [andI, hA, hB]
  · have h := hv (Formula.and A B) (by simp [andE1])
    simp only [eval_and, Bool.and_eq_true] at h
    exact h.1
  · have h := hv (Formula.and A B) (by simp [andE2])
    simp only [eval_and, Bool.and_eq_true] at h
    exact h.2
  · have hA := hv A (by simp [orI1])
    simp [orI1, hA]
  · have hB := hv B (by simp [orI2])
    simp [orI2, hB]

theorem Rbase_sound : Rbase ⊆ SemSound := Rbase_subset_Rstar.trans Rstar_sound

theorem tonk_mem_T (j : ℕ) (A : Formula) : tonk j A ∈ T j := ⟨A, rfl⟩

theorem mem_T_iff {j : ℕ} {s : Step Formula} :
    s ∈ T j ↔ s.prem = {Formula.or s.concl (topConj j)} := by
  constructor
  · rintro ⟨A, rfl⟩
    rfl
  · intro h
    refine ⟨s.concl, ?_⟩
    cases s
    simp_all [tonk]

/-- The premise `C ∨ ⊤^(j)` of a `T_j` step is a tautology. -/
theorem tonk_premise_tautology (j : ℕ) (C : Formula) :
    Tautology (Formula.or C (topConj j)) := by
  intro v; simp

/-- For non-tautologous `C`, the `T_j` step concluding `C` is unsound. -/
theorem tonk_not_semSound {j : ℕ} {C : Formula} (hC : ¬ Tautology C) :
    tonk j C ∉ SemSound := by
  intro h
  apply hC
  intro v
  exact h v (fun ψ hψ => by
    simp only [tonk, Finset.coe_singleton, Set.mem_singleton_iff] at hψ
    subst hψ
    simp)

theorem not_tautology_var (n : ℕ) : ¬ Tautology (Formula.var n) :=
  fun h => by simpa using h (fun _ => false)

/-- Hence (for non-tautologous `C`) the `T_j` step is not in any sound `R*`. -/
theorem tonk_not_mem_of_sound {R : Set (Step Formula)} (hR : R ⊆ SemSound) {j : ℕ}
    {C : Formula} (hC : ¬ Tautology C) : tonk j C ∉ R :=
  fun h => tonk_not_semSound hC (hR h)

/-! ### The derivation of Thm 2.1(i) -/

/-- `⊤` (by ⊤I), then `⊤^(2), …, ⊤^(j)` (by `j - 1` applications of ∧I). -/
def topChain : ℕ → List (Step Formula)
  | 0 => []
  | 1 => [topI]
  | j + 2 => topChain (j + 1) ++ [andI Formula.top (topConj (j + 1))]

theorem topChain_add_two (j : ℕ) :
    topChain (j + 2) = topChain (j + 1) ++ [andI Formula.top (topConj (j + 1))] := rfl

theorem length_topChain : ∀ j, (topChain j).length = j
  | 0 => rfl
  | 1 => rfl
  | j + 2 => by simp [topChain_add_two, length_topChain (j + 1)]

theorem topI_mem_topChain : ∀ j, topI ∈ topChain (j + 1)
  | 0 => by simp [topChain]
  | j + 1 => by
    rw [topChain_add_two]
    exact List.mem_append_left _ (topI_mem_topChain j)

theorem andI_concl (A B : Formula) : (andI A B).concl = Formula.and A B := rfl

theorem topChain_concl : ∀ j, ∃ t ∈ topChain (j + 1), t.concl = topConj (j + 1)
  | 0 => ⟨topI, by simp [topChain], rfl⟩
  | j + 1 => ⟨andI Formula.top (topConj (j + 1)), by simp [topChain_add_two], by
      rw [andI_concl, topConj_add_two]⟩

theorem topChain_linDeriv : ∀ j, LinDeriv ∅ (topChain j)
  | 0 => LinDeriv.nil
  | 1 => LinDeriv.snoc (l := []) (s := topI) LinDeriv.nil (by simp [topI])
  | j + 2 => by
    rw [topChain_add_two]
    refine LinDeriv.snoc (topChain_linDeriv (j + 1)) ?_
    intro p hp
    simp only [andI, Finset.mem_insert, Finset.mem_singleton] at hp
    right
    rcases hp with rfl | rfl
    · exact ⟨topI, topI_mem_topChain j, rfl⟩
    · exact topChain_concl j

theorem topChain_sub_Rbase : ∀ j, ∀ s ∈ topChain j, s ∈ Rbase
  | 0 => by simp [topChain]
  | 1 => by simp [topChain, Rbase]
  | j + 2 => by
    intro s hs
    rw [topChain_add_two, List.mem_append, List.mem_singleton] at hs
    rcases hs with hs | rfl
    · exact topChain_sub_Rbase (j + 1) s hs
    · exact Or.inr (Or.inl ⟨_, _, rfl⟩)

theorem topI_not_mem_T (j : ℕ) : topI ∉ T j := by
  intro h
  rw [mem_T_iff] at h
  exact Finset.singleton_ne_empty _ h.symm

theorem andI_top_not_mem_T (j : ℕ) (X : Formula) : andI Formula.top X ∉ T j := by
  intro h
  rw [mem_T_iff] at h
  have : Formula.top ∈ (andI Formula.top X).prem := by simp [andI]
  rw [h, Finset.mem_singleton] at this
  cases this

theorem orI2_not_mem_T (j : ℕ) (C : Formula) : orI2 C (topConj j) ∉ T j := by
  intro h
  rw [mem_T_iff] at h
  have : topConj j ∈ (orI2 C (topConj j)).prem := by simp [orI2]
  rw [h, Finset.mem_singleton] at this
  exact topConj_ne_or _ _ _ this

theorem topChain_not_mem_T (j k : ℕ) : ∀ s ∈ topChain k, s ∉ T j := by
  intro s hs
  rcases topChain_sub_Rbase k s hs with rfl | ⟨A, B, rfl⟩ | ⟨A, B, rfl⟩
  · exact topI_not_mem_T j
  · -- every ∧I step of the chain has left conjunct `⊤`
    have : ∀ k, ∀ s ∈ topChain k, s = topI ∨ ∃ X, s = andI Formula.top X := by
      intro k
      induction k using Nat.strong_induction_on with
      | _ k ih =>
        match k, ih with
        | 0, _ => simp [topChain]
        | 1, _ => simp [topChain]
        | k + 2, ih =>
          intro s hs
          rw [topChain_add_two, List.mem_append, List.mem_singleton] at hs
          rcases hs with hs | rfl
          · exact ih (k + 1) (by omega) s hs
          · exact Or.inr ⟨_, rfl⟩
    rcases this k _ hs with h | ⟨X, hX⟩
    · exact absurd h (by simp [andI, topI])
    · rw [hX]; exact andI_top_not_mem_T j X
  · -- no ∨I₂ step occurs in the chain
    exfalso
    have : ∀ k, ∀ s ∈ topChain k, ∀ C D, s ≠ orI2 C D := by
      intro k
      induction k using Nat.strong_induction_on with
      | _ k ih =>
        match k, ih with
        | 0, _ => simp [topChain]
        | 1, _ => simp [topChain, topI, orI2]
        | k + 2, ih =>
          intro s hs C D
          rw [topChain_add_two, List.mem_append, List.mem_singleton] at hs
          rcases hs with hs | rfl
          · exact ih (k + 1) (by omega) s hs C D
          · simp [andI, orI2]
    exact this k _ hs A B rfl

/-- The `(j + 2)`-step derivation of `C` in `R* ∪ T_j` from T1 Thm 2.1(i). -/
def tonkDeriv (j : ℕ) (C : Formula) : List (Step Formula) :=
  (topChain j ++ [orI2 C (topConj j)]) ++ [tonk j C]

theorem tonkDeriv_linDeriv {j : ℕ} (hj : 1 ≤ j) (C : Formula) : LinDeriv ∅ (tonkDeriv j C) := by
  obtain ⟨j, rfl⟩ : ∃ i, j = i + 1 := ⟨j - 1, by omega⟩
  refine LinDeriv.snoc (LinDeriv.snoc (topChain_linDeriv _) ?_) ?_
  · intro p hp
    simp only [orI2, Finset.mem_singleton] at hp
    subst hp
    exact Or.inr (topChain_concl j)
  · intro p hp
    simp only [tonk, Finset.mem_singleton] at hp
    subst hp
    exact Or.inr ⟨orI2 C (topConj (j + 1)), by simp, rfl⟩

/-- **T1 Thm 2.1(i), explicit derivation.** For `j ≥ 1` and every formula `C`, there is a linear
derivation of `C` from `∅` of exactly `j + 2` steps, whose first `j + 1` steps are instances of
⊤I, ∧I, ∨I₂ (so lie in `R*`) and are not `T_j` steps, and whose last step is the `T_j` step
`({C ∨ ⊤^(j)}, C)`; its premise is a tautology, and for non-tautologous `C` the step is unsound
and hence not in any sound `R*`. -/
theorem thm_2_1_i_derivation {j : ℕ} (hj : 1 ≤ j) (C : Formula) :
    LinDeriv ∅ (tonkDeriv j C) ∧ (tonkDeriv j C).length = j + 2 ∧
    (∀ s ∈ topChain j ++ [orI2 C (topConj j)], s ∈ Rbase ∧ s ∉ T j) ∧
    tonkDeriv j C = (topChain j ++ [orI2 C (topConj j)]) ++ [tonk j C] ∧
    tonk j C ∈ T j ∧ (tonk j C).concl = C ∧
    Tautology (Formula.or C (topConj j)) ∧
    (¬ Tautology C → tonk j C ∉ SemSound) := by
  refine ⟨tonkDeriv_linDeriv hj C, ?_, ?_, rfl, tonk_mem_T j C, rfl,
    tonk_premise_tautology j C, tonk_not_semSound⟩
  · simp [tonkDeriv, length_topChain]
  · intro s hs
    rw [List.mem_append, List.mem_singleton] at hs
    rcases hs with hs | rfl
    · exact ⟨topChain_sub_Rbase j s hs, topChain_not_mem_T j j s hs⟩
    · exact ⟨Or.inr (Or.inr ⟨_, _, rfl⟩), orI2_not_mem_T j C⟩

theorem T_zero : T 0 = T 1 := rfl

/-- **T1 Thm 2.1(i).** For every rule set `R` containing the instances of ⊤I, ∧I, ∨I₂ (e.g.
`R*`, possibly with other sound rules) and every `j`, every formula is derivable from `∅` in
`R ∪ T_j`. -/
theorem thm_2_1_i {R : Set (Step Formula)} (hR : Rbase ⊆ R) (j : ℕ) (C : Formula) :
    C ∈ Cl (R ∪ T j) ∅ := by
  wlog hj : 1 ≤ j generalizing j
  · obtain rfl : j = 0 := by omega
    rw [T_zero]
    exact this 1 le_rfl
  have hall : ∀ s ∈ tonkDeriv j C, s ∈ R ∪ T j := by
    intro s hs
    simp only [tonkDeriv, List.mem_append, List.mem_singleton] at hs
    rcases hs with (hs | rfl) | rfl
    · exact Or.inl (hR (topChain_sub_Rbase j s hs))
    · exact Or.inl (hR (Or.inr (Or.inr ⟨_, _, rfl⟩)))
    · exact Or.inr (tonk_mem_T j C)
  exact (tonkDeriv_linDeriv hj C).concl_mem_Cl hall (tonk j C) (by simp [tonkDeriv])

/-- Thm 2.1(i), set form: `R ∪ T_j` trivializes the reasoner. -/
theorem thm_2_1_i_univ {R : Set (Step Formula)} (hR : Rbase ⊆ R) (j : ℕ) :
    Cl (R ∪ T j) ∅ = Set.univ :=
  Set.eq_univ_of_forall (thm_2_1_i hR j)

/-- The deterministic core of T1 Cor 2.2: whatever a learner outputs, adding `T_j` and the
(valid) schemas ⊤I, ∧I, ∨I₂ makes every formula derivable. -/
theorem cor_2_2_trivializes (L : Set (Step Formula)) (j : ℕ) :
    Cl (L ∪ Rbase ∪ T j) ∅ = Set.univ :=
  thm_2_1_i_univ Set.subset_union_right j

/-- For a sound `R ⊇ Rbase`, `R ∪ T_j` is an unsound reasoner: it derives the non-tautology
`p₀` from `∅`, while `R` only derives tautologies. -/
theorem thm_2_1_unsound {R : Set (Step Formula)} (hRb : Rbase ⊆ R) (hR : R ⊆ SemSound)
    (j : ℕ) : Formula.var 0 ∈ Cl (R ∪ T j) ∅ ∧ Formula.var 0 ∉ Cl R ∅ := by
  refine ⟨thm_2_1_i hRb j _, fun h => ?_⟩
  have := Cl_subset_Cn2 hR ∅ h
  rw [Cn2_empty] at this
  exact not_tautology_var 0 this

/-- Via Lemma 1.1: for every sound `R ⊇ Rbase`, `T_j` contains a step that is not derivable
in `R`. -/
theorem T_not_subset_Sound {R : Set (Step Formula)} (hRb : Rbase ⊆ R) (hR : R ⊆ SemSound)
    (j : ℕ) : ¬ (T j ⊆ Sound R) := by
  intro h
  have hsub : R ∪ T j ⊆ Sound R := Set.union_subset subset_Sound h
  have := (lemma_1_1 (R ∪ T j) R).2 hsub ∅
  exact (thm_2_1_unsound hRb hR j).2 (this (thm_2_1_unsound hRb hR j).1)

/-! ### Pure schemas -/

/-- The substitution `p₀ ↦ A`, `pₙ ↦ B` (`n ≥ 1`). -/
def σ2 (A B : Formula) : Subst := fun n => if n = 0 then A else B

@[simp] theorem σ2_zero (A B : Formula) : σ2 A B 0 = A := rfl
@[simp] theorem σ2_one (A B : Formula) : σ2 A B 1 = B := rfl

/-- The six schemas of `R*`, with metavariables `p₀, p₁`. -/
def RstarSchemas : Set (Step Formula) :=
  {topI, andI (.var 0) (.var 1), andE1 (.var 0) (.var 1), andE2 (.var 0) (.var 1),
    orI1 (.var 0) (.var 1), orI2 (.var 0) (.var 1)}

theorem topI_subst (σ : Subst) : topI.subst σ = topI := by
  simp [topI, Step.subst]

theorem andI_subst (σ : Subst) (A B : Formula) :
    (andI A B).subst σ = andI (A.subst σ) (B.subst σ) := by
  simp [andI, Step.subst, Finset.image_insert]

theorem andE1_subst (σ : Subst) (A B : Formula) :
    (andE1 A B).subst σ = andE1 (A.subst σ) (B.subst σ) := by
  simp [andE1, Step.subst]

theorem andE2_subst (σ : Subst) (A B : Formula) :
    (andE2 A B).subst σ = andE2 (A.subst σ) (B.subst σ) := by
  simp [andE2, Step.subst]

theorem orI1_subst (σ : Subst) (A B : Formula) :
    (orI1 A B).subst σ = orI1 (A.subst σ) (B.subst σ) := by
  simp [orI1, Step.subst]

theorem orI2_subst (σ : Subst) (A B : Formula) :
    (orI2 A B).subst σ = orI2 (A.subst σ) (B.subst σ) := by
  simp [orI2, Step.subst]

theorem tonk_subst (σ : Subst) (j : ℕ) (A : Formula) :
    (tonk j A).subst σ = tonk j (A.subst σ) := by
  simp [tonk, Step.subst]

/-- `R*` is given by finitely many (six) pure schemas: it is the set of all substitution
instances of `RstarSchemas`. -/
theorem Rstar_eq_substClosure : Rstar = substClosure RstarSchemas := by
  ext s
  constructor
  · rintro (rfl | ⟨A, B, rfl⟩ | ⟨A, B, rfl⟩ | ⟨A, B, rfl⟩ | ⟨A, B, rfl⟩ | ⟨A, B, rfl⟩)
    · exact ⟨topI, by simp [RstarSchemas], Subst.id, by simp⟩
    · exact ⟨andI (.var 0) (.var 1), by simp [RstarSchemas], σ2 A B, by simp [andI_subst]⟩
    · exact ⟨andE1 (.var 0) (.var 1), by simp [RstarSchemas], σ2 A B, by simp [andE1_subst]⟩
    · exact ⟨andE2 (.var 0) (.var 1), by simp [RstarSchemas], σ2 A B, by simp [andE2_subst]⟩
    · exact ⟨orI1 (.var 0) (.var 1), by simp [RstarSchemas], σ2 A B, by simp [orI1_subst]⟩
    · exact ⟨orI2 (.var 0) (.var 1), by simp [RstarSchemas], σ2 A B, by simp [orI2_subst]⟩
  · rintro ⟨t, ht, σ, rfl⟩
    simp only [RstarSchemas, Set.mem_insert_iff, Set.mem_singleton_iff] at ht
    rcases ht with rfl | rfl | rfl | rfl | rfl | rfl
    · exact Or.inl (topI_subst σ)
    · exact Or.inr (Or.inl ⟨_, _, andI_subst _ _ _⟩)
    · exact Or.inr (Or.inr (Or.inl ⟨_, _, andE1_subst _ _ _⟩))
    · exact Or.inr (Or.inr (Or.inr (Or.inl ⟨_, _, andE2_subst _ _ _⟩)))
    · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl ⟨_, _, orI1_subst _ _ _⟩))))
    · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr ⟨_, _, orI2_subst _ _ _⟩))))

/-- `T_j` is a single pure one-metavariable schema. -/
theorem T_eq_substClosure (j : ℕ) : T j = substClosure {tonk j (.var 0)} := by
  ext s
  constructor
  · rintro ⟨A, rfl⟩
    exact ⟨_, rfl, σ2 A A, by simp [tonk_subst]⟩
  · rintro ⟨t, rfl, σ, rfl⟩
    exact ⟨_, (tonk_subst σ j _).symm⟩

theorem Rstar_union_T_eq_substClosure (j : ℕ) :
    Rstar ∪ T j = substClosure (RstarSchemas ∪ {tonk j (.var 0)}) := by
  rw [Rstar_eq_substClosure, T_eq_substClosure]
  ext s
  constructor
  · rintro (⟨t, ht, σ, rfl⟩ | ⟨t, ht, σ, rfl⟩)
    · exact ⟨t, Or.inl ht, σ, rfl⟩
    · exact ⟨t, Or.inr ht, σ, rfl⟩
  · rintro ⟨t, (ht | ht), σ, rfl⟩
    · exact Or.inl ⟨t, ht, σ, rfl⟩
    · exact Or.inr ⟨t, ht, σ, rfl⟩

/-! ### Thm 2.1(ii): disjointness and vanishing mass -/

/-- **T1 Thm 2.1(ii), disjointness.** The schemas `T_j` (`j ≥ 1`) are pairwise disjoint. -/
theorem T_disjoint {j k : ℕ} (hj : 1 ≤ j) (hk : 1 ≤ k) (hjk : j ≠ k) : Disjoint (T j) (T k) := by
  obtain ⟨j, rfl⟩ : ∃ i, j = i + 1 := ⟨j - 1, by omega⟩
  obtain ⟨k, rfl⟩ : ∃ i, k = i + 1 := ⟨k - 1, by omega⟩
  rw [Set.disjoint_left]
  rintro _ ⟨A, rfl⟩ ⟨B, hB⟩
  simp only [tonk, Step.mk.injEq, Finset.singleton_inj, Formula.or.injEq] at hB
  exact hjk (by rw [topConj_succ_inj hB.1.2.symm])

theorem T_succ_pairwise_disjoint : Pairwise (Function.onFun Disjoint fun j => T (j + 1)) := by
  intro j k hjk
  exact T_disjoint (by omega) (by omega) (by omega)

/-- The mass `Q(X) = ∑_{a ∈ X} q a` of a set under a weight function `q`. -/
noncomputable def mass {α : Type*} (q : α → ℝ) (X : Set α) : ℝ := ∑' a : X, q a

section Mass

variable {α : Type*} {q : α → ℝ}

theorem mass_eq_tsum_indicator (X : Set α) : mass q X = ∑' a, X.indicator q a :=
  tsum_subtype X q

theorem mass_nonneg (hq0 : ∀ a, 0 ≤ q a) (X : Set α) : 0 ≤ mass q X :=
  tsum_nonneg fun a => hq0 a

theorem mass_mono (hq0 : ∀ a, 0 ≤ q a) (hq : Summable q) {X Y : Set α} (hXY : X ⊆ Y) :
    mass q X ≤ mass q Y := by
  rw [mass_eq_tsum_indicator, mass_eq_tsum_indicator]
  exact Summable.tsum_le_tsum (fun a => Set.indicator_le_indicator_of_subset hXY hq0 a)
    (hq.indicator X) (hq.indicator Y)

/-- For a summable non-negative weight function and a pairwise disjoint family of sets,
the masses of the sets tend to `0` (they are summable, with sum `≤ ∑ q`). -/
theorem tendsto_mass_of_pairwise_disjoint (hq0 : ∀ a, 0 ≤ q a) (hq : Summable q)
    {S : ℕ → Set α} (hS : Pairwise (Function.onFun Disjoint S)) :
    Tendsto (fun j => mass q (S j)) atTop (𝓝 0) := by
  have hsum : Summable (fun j => mass q (S j)) := by
    refine summable_of_sum_le (c := ∑' a, q a) (fun j => mass_nonneg hq0 (S j)) ?_
    intro F
    simp_rw [mass_eq_tsum_indicator]
    rw [← Summable.tsum_finsetSum (fun i _ => hq.indicator (S i))]
    refine Summable.tsum_le_tsum (fun a => ?_)
      (summable_sum fun i _ => hq.indicator (S i)) hq
    by_cases h : ∃ i ∈ F, a ∈ S i
    · obtain ⟨i, hi, ha⟩ := h
      rw [Finset.sum_eq_single i]
      · rw [Set.indicator_of_mem ha]
      · intro b _ hbi
        exact Set.indicator_of_notMem (fun hb => Set.disjoint_left.1 (hS hbi) hb ha) _
      · intro h; exact absurd hi h
    · push Not at h
      rw [Finset.sum_eq_zero (fun i hi => Set.indicator_of_notMem (h i hi) _)]
      exact hq0 a
  exact hsum.tendsto_atTop_zero

end Mass

/-- **T1 Thm 2.1(ii).** For every probability distribution `Q` on steps -- more generally every
summable non-negative weight function `q`, over valid steps, invalid steps or both --
`Q(T_j) → 0` as `j → ∞`. -/
theorem thm_2_1_ii {q : Step Formula → ℝ} (hq0 : ∀ s, 0 ≤ q s) (hq : Summable q) :
    Tendsto (fun j => mass q (T j)) atTop (𝓝 0) := by
  rw [← tendsto_add_atTop_iff_nat 1]
  exact tendsto_mass_of_pairwise_disjoint hq0 hq T_succ_pairwise_disjoint

/-- **The conclusion drawn after T1 Thm 2.1.** For every `Q` (summable non-negative weights on
steps) and every `ε > 0`, for all large `j` the hypothesis `R ∪ T_j` has `Q`-error
`Q((R ∪ T_j) ∆ R) < ε` and trivializes the reasoner (derives every formula from `∅`). -/
theorem thm_2_1_error_and_trivial {R : Set (Step Formula)} (hR : Rbase ⊆ R)
    {q : Step Formula → ℝ} (hq0 : ∀ s, 0 ≤ q s) (hq : Summable q) {ε : ℝ} (hε : 0 < ε) :
    ∀ᶠ j in atTop, mass q (symmDiff (R ∪ T j) R) < ε ∧ Cl (R ∪ T j) ∅ = Set.univ := by
  filter_upwards [(thm_2_1_ii hq0 hq).eventually (gt_mem_nhds hε)] with j hj
  refine ⟨lt_of_le_of_lt (mass_mono hq0 hq ?_) hj, thm_2_1_i_univ hR j⟩
  intro s hs
  rw [Set.mem_symmDiff] at hs
  rcases hs with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · rcases h1 with h1 | h1
    · exact absurd h1 h2
    · exact h1
  · exact absurd (Or.inl h1) h2

end Tonk

end StepSoundness
end InfLearn

/-! ## Axiom checks -/

#print axioms InfLearn.StepSoundness.lemma_1_1
#print axioms InfLearn.StepSoundness.concl_not_derivable_of_not_mem_Sound
#print axioms InfLearn.StepSoundness.thm_3_1_a
#print axioms InfLearn.StepSoundness.thm_3_1_a_reasoner
#print axioms InfLearn.StepSoundness.vsVerifier_reasoner_sound
#print axioms InfLearn.StepSoundness.thm_3_1_b
#print axioms InfLearn.StepSoundness.vsVerifier_optimal
#print axioms InfLearn.StepSoundness.thm_3_1_a_closure
#print axioms InfLearn.StepSoundness.thm_3_1_b_closure
#print axioms InfLearn.StepSoundness.vsVerifierSound_optimal
#print axioms InfLearn.StepSoundness.subset_sInter_VS_iff
#print axioms InfLearn.StepSoundness.thm_3_1_a_static
#print axioms InfLearn.StepSoundness.thm_3_1_b_static
#print axioms InfLearn.StepSoundness.reasoner_sound_for_all_VS_iff
#print axioms InfLearn.StepSoundness.thm_2_1_i
#print axioms InfLearn.StepSoundness.thm_2_1_i_derivation
#print axioms InfLearn.StepSoundness.thm_2_1_unsound
#print axioms InfLearn.StepSoundness.T_not_subset_Sound
#print axioms InfLearn.StepSoundness.Rstar_sound
#print axioms InfLearn.StepSoundness.Rstar_eq_substClosure
#print axioms InfLearn.StepSoundness.T_eq_substClosure
#print axioms InfLearn.StepSoundness.T_disjoint
#print axioms InfLearn.StepSoundness.thm_2_1_ii
#print axioms InfLearn.StepSoundness.thm_2_1_error_and_trivial
