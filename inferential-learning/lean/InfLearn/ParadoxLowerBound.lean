import InfLearn.CoherenceGames

/-!
# T4 §4.2, Theorem 4.4(b),(c): paradox feedback can cost `|𝓗| - 1` corrections

Formalisation of the lower bounds of `research/theory/T4-informal-math-latent-formalization.md`,
§4.2 (Definition 4.2, Theorem 4.4(b),(c), repaired statements; verification log items B3–B5,
B11), for **deterministic learners**.

## 0. The correction game (T4 Def. 4.2)
* Steps form an arbitrary type `S`; a hypothesis class is `H : ι → Set S`, the target is an
  index `j`.
* Feedback items are CoherenceGames' `Event S`: `(+) pos s`, a negative item `neg P`, or
  `nothing` (a silent round). `(−obj) s` is the negative item `neg {s}`; `(−bag_r) B` is
  `neg B` with `|B| ≤ r`. Which negative items the environment may use is a parameter
  `Bags : Set (Set S)`: `objBags` (singletons: the object game), `bagBags r` (finite bags of size
  `≤ r`: the bag game), or `chainBags n` (bags of genuine paradoxes, §2 below).
* `FbLegal Bags h A ev`: `ev` is a legal reply to the announcement `A` when the target is `h`:
  `(+) s` needs `s ∈ h \ A`; `neg P` needs `P ∈ Bags`, `P ⊆ A`, `P ⊄ h`. Silence is always
  legal. (`FbLegal.ne`: feedback is only possible when `A ≠ h`.)
* A **deterministic learner** `L : Learner S` maps the history of feedback items (oldest first)
  to the next announcement `A_t ⊆ S`, which need not be a hypothesis. Because `L` is
  deterministic, the announcements are determined by the feedback, so an adaptive adversary
  against `L` is the same thing as a feedback sequence `e : ℕ → Event S`;
  `ann L e t = L (hist e t)` is the announcement in round `t`.
* `PlayLegal Bags L h e`: every round's item is legal. `NonSilent`: the environment never stays
  silent when some legal feedback item exists. In all games below some item is legal whenever
  `A_t ≠ h*` (`exists_feedback_bagBags` for `r ≥ 1`, `exists_feedback_objBags`,
  `exists_feedback_chain`), so by `nonSilent_iff` this is exactly Def. 4.2's rule "if
  `A_t ≠ h*`, the environment returns one feedback item".
* A *correction* is a round with feedback (`CoherenceGames.corrections e n` counts those among
  the first `n` rounds).
* `Forces Bags H L m`: some target and some legal, non-silent play make `L` suffer `m`
  corrections in the first `m` rounds (`M ≥ m` against `L`).
  `Achieves Bags H L m`: against every target and every legal play (silent rounds allowed), `L`
  makes at most `m` corrections in total.
  `IsValue Bags H m := (∀ L, Forces Bags H L m) ∧ ∃ L, Achieves Bags H L m`, i.e. the optimal
  worst-case number of corrections `M(𝓗)` (over deterministic learners) is exactly `m`;
  `IsValue.unique` shows it is well defined.
* `forces_of_adversary`: a potential-based adversary state machine forces `φ(c₀)` corrections.
  `achieves_of_potential`: a version-space learner whose every correction lowers a potential
  `ψ` makes at most `ψ(𝓗)` corrections.
* **T4 Thm 4.3(b)** (`thm_4_3_b`, `thm_4_3_b_eq`): `M_obj(𝓗) ≤ M^{(r)}_bag(𝓗)` for every class
  and `r ≥ 1`, with equality at `r = 1`, as a consequence of `objBags ⊆ bagBags r`.

## 1. The single-culprit class (T4 Thm 4.4(b))
`S = Fin n` (suspect steps `b₀, …, b_{n-1}`), `single n j = S \ {b_j}`; `card_class`: there are
exactly `n` distinct hypotheses.
* `thm_4_4_b_bag_lower`: for every `r` and every deterministic learner, an adversary forces
  `min(r, n-1)` corrections in the bag game with bags of size `≤ r` (the paper's potential
  argument, `f(c) = min(r, c - 1)`).
* `thm_4_4_b_bag_upper`: the learner `bagLearner n r` (announce `S` while more than `r`
  candidates survive, then announce all steps but one surviving candidate) makes at most
  `min(r, n-1)` corrections.
* `thm_4_4_b_bag_value`: `M^{(r)}_bag(𝓗_n) = min(r, n-1)`;
  `thm_4_4_b_unbounded`: with unbounded bags (`r = |S| = n`), `M_bag(𝓗_n) = n - 1 = |𝓗_n| - 1`.
* `thm_4_4_b_obj_lower`, `thm_4_4_b_obj_upper`, `thm_4_4_b_obj_value`: `M_obj(𝓗_n) = 1`
  (`n ≥ 2`).
* `thm_4_4_b`: the separation, `M_obj(𝓗_n) = 1` while `M^{(r)}_bag(𝓗_n) = min(r, n-1)`.

## 2. The chain paradox: logic (T4 Thm 4.4(c), the sorites)
Sentences `q_k = p_k` (atoms); suspect steps `chainStep n i = (q_i ⇒ q_{i+1})` for `i < n`
(the paper's `b_{i+1}`); the single designated context `ctx n = {q₀, ¬q_n}`; hypothesis
`hypC n j = Cn_CPC(Tch n j)` read as a set of steps, where `Tch n j` has the axioms
`q_i → q_{i+1}` for `i ≠ j`.
* `chainStep_mem_hypC`: `h_j` validates `b_i` iff `i ≠ j`; `SemSound_subset_hypC`: every
  classically valid step is certified (valid in every `h_j`).
* `hypC_coherent`: every `h_j` is coherent on the designated context (the valuation
  `p_k ↦ (k ≤ j)` satisfies `Tch n j ∪ ctx n`), so the designation is truthful whatever the target.
* `paradox_derivation`: the chain steps plus one certified step derive `⊥` from `ctx n`.
* `essential_bag`: **every** derivation of `⊥` from `ctx n` whose steps are chain steps or
  certified steps uses **all** chain steps. `chainBags_eq`: the only paradox bag is the full
  chain `S`.
* `object_descent`, `object_refutes_iff`: every admissible object for `h_j` (a valuation of
  `Tch n j ∪ ctx n`) makes `q_k` true exactly for `k ≤ j`, so it refutes exactly the chain step
  `b_j`; `exists_object`: such an object exists.

## 3. The chain paradox: the game (T4 Thm 4.4(c))
`chainH n j = {i | chainStep n i ∈ hypC n j}` (= `single n j`, `chainH_eq`), negative feedback
restricted to `chainBags n` (bags of genuine paradoxes, derived from the logic).
* `thm_4_4_c_lower`: with paradox feedback, an adversary forces `n - 1 = |𝓗| - 1` corrections on
  every deterministic learner. `thm_4_4_c_upper`, `thm_4_4_c_value`: and `n - 1` is attained.
* `thm_4_4_c_obj_value`: with object feedback, `M_obj = 1` (`n ≥ 2`).

## Scope (what is *not* formalised)
* Only deterministic learners are treated (as the task asked); randomized learners are not.
* The chain hypotheses are the specific CPC readings `Cn_CPC({q_i → q_{i+1} : i ≠ j})`; the
  paper's generic "any chain of obvious lemmas" is covered only through this instance. The game
  layer abstracts from the logic exactly as Def. 4.2 does (`S` = the suspect steps; steps
  certified by the whole class, e.g. all classically valid steps, are dropped from bags).
  Dropping steps certified only by the *current* version space (`b_i` for eliminated `i`) would
  turn the reported bag `S` into the candidate set `C`; that bag deletes the same surviving
  hypotheses (none), so it carries no extra information, and our general learners, which see
  the whole history, lose nothing from it.
* The game-level lower bounds hold for arbitrary deterministic learners (functions of the
  feedback history), which is more general than the version-space learners of the paper.
* T4 Thm 4.4(a) (`M_bag ≤ el* ≤ |𝓗| - 1`) and Thm 4.3(c) (`M_obj = Ldim`) are not formalised
  here; Thm 4.3(b) is proved in the game formulation of this file.
-/

namespace InfLearn
namespace ParadoxLowerBound

open CoherenceGames (Event update vsRun corrections LegalFor target_mem_vsRun vsRun_succ
  card_filter_range_succ mem_update_pos mem_update_neg)

universe u v w

/-! ## 0. The correction game against deterministic learners -/

section Game

variable {S : Type u} {ι : Type v}

/-- A deterministic learner: its announcement `A_t ⊆ S` as a function of the feedback history
(oldest first; `Event.nothing` marks a silent round). -/
abbrev Learner (S : Type u) : Type u := List (Event S) → Set S

/-- The feedback history of the first `t` rounds. -/
def hist (e : ℕ → Event S) (t : ℕ) : List (Event S) := (List.range t).map e

@[simp] theorem hist_zero (e : ℕ → Event S) : hist e 0 = [] := rfl

theorem hist_succ (e : ℕ → Event S) (t : ℕ) : hist e (t + 1) = hist e t ++ [e t] := by
  simp [hist, List.range_succ]

/-- The learner's announcement in round `t` of the play `e`. -/
def ann (L : Learner S) (e : ℕ → Event S) (t : ℕ) : Set S := L (hist e t)

/-- Legal feedback (T4 Def. 4.2) to the announcement `A` when the target is `h`, in the game
whose negative channel admits the items `Bags`:
* `(+) s` with `s ∈ h \ A`;
* a negative item `P ∈ Bags` with `P ⊆ A` and `P ⊄ h` (`(−obj) s` is `P = {s}`; `(−bag_r)` is
  `|P| ≤ r`);
* silence. -/
def FbLegal (Bags : Set (Set S)) (h A : Set S) : Event S → Prop
  | .pos s => s ∈ h ∧ s ∉ A
  | .neg P => P ∈ Bags ∧ P ⊆ A ∧ ¬ P ⊆ h
  | .nothing => True

/-- The object channel `(−obj)`: singleton items `{s}`. -/
def objBags : Set (Set S) := {P | ∃ s, P = {s}}

/-- The bag channel `(−bag_r)`: finite bags of at most `r` steps. -/
def bagBags (r : ℕ) : Set (Set S) := {P | ∃ B : Finset S, P = ↑B ∧ B.card ≤ r}

/-- Every round of the play `e` is legal for the target `h`. -/
def PlayLegal (Bags : Set (Set S)) (L : Learner S) (h : Set S) (e : ℕ → Event S) : Prop :=
  ∀ t, FbLegal Bags h (ann L e t) (e t)

/-- The environment never stays silent when a legal feedback item exists. -/
def NonSilent (Bags : Set (Set S)) (L : Learner S) (h : Set S) (e : ℕ → Event S) : Prop :=
  ∀ t, (∃ ev : Event S, ev.isFeedback = true ∧ FbLegal Bags h (ann L e t) ev) →
    (e t).isFeedback = true

/-- **The adversary forces `m` corrections on `L`**: for some target and some legal, non-silent
play, each of the first `m` rounds is a correction. -/
def Forces (Bags : Set (Set S)) (H : ι → Set S) (L : Learner S) (m : ℕ) : Prop :=
  ∃ j e, PlayLegal Bags L (H j) e ∧ NonSilent Bags L (H j) e ∧ m ≤ corrections e m

/-- **`L` makes at most `m` corrections**: against every target and every legal play (silent
rounds allowed), the total number of corrections is at most `m`. -/
def Achieves (Bags : Set (Set S)) (H : ι → Set S) (L : Learner S) (m : ℕ) : Prop :=
  ∀ j e, PlayLegal Bags L (H j) e → ∀ t, corrections e t ≤ m

/-- **The optimal worst-case number of corrections over deterministic learners is `m`**
(`M_obj(𝓗)`, `M^{(r)}_bag(𝓗)` of T4 Def. 4.2): every learner can be forced to make `m`
corrections, and some learner never makes more. -/
def IsValue (Bags : Set (Set S)) (H : ι → Set S) (m : ℕ) : Prop :=
  (∀ L, Forces Bags H L m) ∧ ∃ L, Achieves Bags H L m

theorem corrections_le (e : ℕ → Event S) (m : ℕ) : corrections e m ≤ m := by
  unfold corrections
  exact (Finset.card_filter_le _ _).trans (Finset.card_range m).le

theorem corrections_succ (e : ℕ → Event S) (t : ℕ) :
    corrections e (t + 1) = corrections e t + if (e t).isFeedback = true then 1 else 0 :=
  card_filter_range_succ _ t

theorem eq_nothing_of_not_feedback {ev : Event S} (h : ev.isFeedback ≠ true) :
    ev = .nothing := by
  cases ev with
  | pos s => exact absurd rfl h
  | neg P => exact absurd rfl h
  | nothing => rfl

/-- Feedback is only possible when the announcement differs from the target. -/
theorem FbLegal.ne {Bags : Set (Set S)} {h A : Set S} {ev : Event S}
    (hl : FbLegal Bags h A ev) (hf : ev.isFeedback = true) : A ≠ h := by
  rintro rfl
  cases ev with
  | pos s => exact hl.2 hl.1
  | neg P => exact hl.2.2 hl.2.1
  | nothing => exact absurd hf (by simp [Event.isFeedback])

/-- Legal feedback never deletes the target (it is `LegalFor` in CoherenceGames' sense). -/
theorem legalFor_of_fbLegal {Bags : Set (Set S)} {H : ι → Set S} {j : ι} {A : Set S}
    {ev : Event S} (hl : FbLegal Bags (H j) A ev) : LegalFor H j ev := by
  cases ev with
  | pos s => exact hl.1
  | neg P => exact hl.2.2
  | nothing => trivial

theorem fbLegal_mono {Bags Bags' : Set (Set S)} (hB : Bags ⊆ Bags') {h A : Set S}
    {ev : Event S} (hl : FbLegal Bags h A ev) : FbLegal Bags' h A ev := by
  cases ev with
  | pos s => exact hl
  | neg P => exact ⟨hB hl.1, hl.2⟩
  | nothing => trivial

/-- A learner that is good against a richer environment is good against a poorer one. -/
theorem Achieves.mono_bags {Bags Bags' : Set (Set S)} (hB : Bags ⊆ Bags') {H : ι → Set S}
    {L : Learner S} {m : ℕ} (h : Achieves Bags' H L m) : Achieves Bags H L m :=
  fun j e hl => h j e fun t => fbLegal_mono hB (hl t)

theorem Achieves.mono {Bags : Set (Set S)} {H : ι → Set S} {L : Learner S} {m m' : ℕ}
    (h : Achieves Bags H L m) (hm : m ≤ m') : Achieves Bags H L m' :=
  fun j e hl t => (h j e hl t).trans hm

/-- **Sanity check**: forced corrections never exceed guaranteed ones. -/
theorem le_of_forces_achieves {Bags : Set (Set S)} {H : ι → Set S} {L : Learner S} {m m' : ℕ}
    (hF : Forces Bags H L m) (hA : Achieves Bags H L m') : m ≤ m' := by
  obtain ⟨j, e, hl, -, hm⟩ := hF
  exact hm.trans (hA j e hl m)

/-- If some legal feedback item exists whenever the announcement misses the target, `NonSilent`
is exactly Def. 4.2's rule "if `A_t ≠ h*`, the environment returns one feedback item". -/
theorem nonSilent_iff {Bags : Set (Set S)} {L : Learner S} {h : Set S} {e : ℕ → Event S}
    (hex : ∀ A : Set S, A ≠ h → ∃ ev : Event S, ev.isFeedback = true ∧ FbLegal Bags h A ev) :
    NonSilent Bags L h e ↔ ∀ t, ann L e t ≠ h → (e t).isFeedback = true := by
  constructor
  · intro hns t hne
    exact hns t (hex _ hne)
  · rintro hns t ⟨ev, hf, hl⟩
    exact hns t (hl.ne hf)

/-- In the bag game with `r ≥ 1` some feedback item is legal whenever `A ≠ h*`. -/
theorem exists_feedback_bagBags {r : ℕ} (hr : 1 ≤ r) {h A : Set S} (hne : A ≠ h) :
    ∃ ev : Event S, ev.isFeedback = true ∧ FbLegal (bagBags r) h A ev := by
  classical
  obtain ⟨s, hs⟩ : ∃ s, ¬ (s ∈ A ↔ s ∈ h) := by
    by_contra hc
    simp only [not_exists, not_not] at hc
    exact hne (Set.ext hc)
  by_cases hsA : s ∈ A
  · have hsh : s ∉ h := fun hsh => hs ⟨fun _ => hsh, fun _ => hsA⟩
    refine ⟨.neg ↑({s} : Finset S), rfl, ⟨{s}, rfl, by simpa using hr⟩, ?_, ?_⟩
    · simpa using hsA
    · simpa using hsh
  · have hsh : s ∈ h := by
      by_contra hsh
      exact hs ⟨fun h' => absurd h' hsA, fun h' => absurd h' hsh⟩
    exact ⟨.pos s, rfl, hsh, hsA⟩

/-- The minimax value is well defined. -/
theorem IsValue.unique {Bags : Set (Set S)} {H : ι → Set S} {m m' : ℕ}
    (h : IsValue Bags H m) (h' : IsValue Bags H m') : m = m' := by
  obtain ⟨L, hL⟩ := h.2
  obtain ⟨L', hL'⟩ := h'.2
  exact le_antisymm (le_of_forces_achieves (h.1 L') hL') (le_of_forces_achieves (h'.1 L) hL)

/-! ### Extending a forced prefix to a non-silent play -/

open scoped Classical in
/-- Greedy continuation: some legal feedback item if one exists, otherwise silence. -/
noncomputable def greedy (Bags : Set (Set S)) (L : Learner S) (h : Set S)
    (l : List (Event S)) : Event S :=
  if hx : ∃ ev : Event S, ev.isFeedback = true ∧ FbLegal Bags h (L l) ev then hx.choose
  else .nothing

/-- History of the play that follows `e` for `m` rounds and then continues greedily. -/
noncomputable def extRun (Bags : Set (Set S)) (L : Learner S) (h : Set S) (e : ℕ → Event S)
    (m : ℕ) : ℕ → List (Event S)
  | 0 => []
  | t + 1 => extRun Bags L h e m t ++
      [if t < m then e t else greedy Bags L h (extRun Bags L h e m t)]

/-- The play that follows `e` for `m` rounds and then continues greedily. -/
noncomputable def extEnv (Bags : Set (Set S)) (L : Learner S) (h : Set S) (e : ℕ → Event S)
    (m : ℕ) (t : ℕ) : Event S :=
  if t < m then e t else greedy Bags L h (extRun Bags L h e m t)

theorem hist_extEnv (Bags : Set (Set S)) (L : Learner S) (h : Set S) (e : ℕ → Event S)
    (m : ℕ) : ∀ t, hist (extEnv Bags L h e m) t = extRun Bags L h e m t
  | 0 => rfl
  | t + 1 => by
    rw [hist_succ, hist_extEnv Bags L h e m t]
    rfl

theorem hist_extEnv_of_le (Bags : Set (Set S)) (L : Learner S) (h : Set S) (e : ℕ → Event S)
    (m : ℕ) : ∀ t, t ≤ m → hist (extEnv Bags L h e m) t = hist e t
  | 0, _ => rfl
  | t + 1, ht => by
    rw [hist_succ, hist_succ, hist_extEnv_of_le Bags L h e m t (by omega)]
    simp [extEnv, show t < m by omega]

/-- A legal prefix of `m` corrections extends to a legal, non-silent play. -/
theorem exists_nonSilent_extension {Bags : Set (Set S)} {L : Learner S} {h : Set S}
    {e : ℕ → Event S} {m : ℕ} (hleg : ∀ t < m, FbLegal Bags h (ann L e t) (e t))
    (hfb : ∀ t < m, (e t).isFeedback = true) :
    ∃ e', PlayLegal Bags L h e' ∧ NonSilent Bags L h e' ∧ m ≤ corrections e' m := by
  classical
  set e' := extEnv Bags L h e m with he'
  have hann : ∀ t, t < m → ann L e' t = ann L e t := fun t ht => by
    simp only [ann, he', hist_extEnv_of_le Bags L h e m t ht.le]
  have hgreedy : ∀ t, ¬ t < m → e' t = greedy Bags L h (hist e' t) := fun t ht => by
    simp only [he', extEnv, if_neg ht, hist_extEnv]
  refine ⟨e', fun t => ?_, fun t hex => ?_, ?_⟩
  · by_cases ht : t < m
    · rw [hann t ht]
      simpa [he', extEnv, ht] using hleg t ht
    · rw [hgreedy t ht]
      unfold greedy
      split_ifs with hx
      · exact hx.choose_spec.2
      · trivial
  · by_cases ht : t < m
    · simpa [he', extEnv, ht] using hfb t ht
    · rw [hgreedy t ht]
      have hex' : ∃ ev : Event S, ev.isFeedback = true ∧ FbLegal Bags h (L (hist e' t)) ev :=
        hex
      unfold greedy
      rw [dif_pos hex']
      exact hex'.choose_spec.1
  · unfold corrections
    rw [Finset.filter_true_of_mem, Finset.card_range]
    intro t ht
    have ht' : t < m := Finset.mem_range.1 ht
    simpa [he', extEnv, ht'] using hfb t ht'

/-! ### Potential-based adversaries -/

section Adversary

variable {σ : Type w}

/-- The run of an adversary state machine `adv` (reading the announcement and its state) against
the learner `L`: the history and the adversary's state after `t` rounds. -/
def advRun (L : Learner S) (adv : Set S → σ → Event S × σ) (c₀ : σ) :
    ℕ → List (Event S) × σ
  | 0 => ([], c₀)
  | t + 1 =>
    ((advRun L adv c₀ t).1 ++ [(adv (L (advRun L adv c₀ t).1) (advRun L adv c₀ t).2).1],
      (adv (L (advRun L adv c₀ t).1) (advRun L adv c₀ t).2).2)

/-- The adversary's play, cut off (silent) after `m` rounds. -/
def advEnv (L : Learner S) (adv : Set S → σ → Event S × σ) (c₀ : σ) (m : ℕ) (t : ℕ) :
    Event S :=
  if t < m then (adv (L (advRun L adv c₀ t).1) (advRun L adv c₀ t).2).1 else .nothing

/-- **Potential-based adversary lemma.** Let the adversary keep a state `c` with a set
`cand c` of candidate targets (all consistent with the feedback so far) and a potential `φ c`.
If, whenever `φ c ≥ 1`, its reply to any announcement is a feedback item that is legal for
every surviving candidate, keeps a candidate alive, and lowers `φ` by at most one, then it
forces `φ c₀` corrections on every deterministic learner. -/
theorem forces_of_adversary {Bags : Set (Set S)} {H : ι → Set S} (L : Learner S)
    (cand : σ → Set ι) (φ : σ → ℕ) (adv : Set S → σ → Event S × σ) (c₀ : σ) {m : ℕ}
    (hm : φ c₀ = m) (h0 : (cand c₀).Nonempty)
    (hstep : ∀ A c, 1 ≤ φ c →
      (adv A c).1.isFeedback = true ∧ cand (adv A c).2 ⊆ cand c ∧
      (cand (adv A c).2).Nonempty ∧
      (∀ j ∈ cand (adv A c).2, FbLegal Bags (H j) A (adv A c).1) ∧
      φ c ≤ φ (adv A c).2 + 1) :
    Forces Bags H L m := by
  set R := advRun L adv c₀ with hR
  set e := advEnv L adv c₀ m with he
  have hRs : ∀ t, R (t + 1) = ((R t).1 ++ [(adv (L (R t).1) (R t).2).1],
      (adv (L (R t).1) (R t).2).2) := fun t => rfl
  have hhist : ∀ t, t ≤ m → hist e t = (R t).1 := by
    intro t
    induction t with
    | zero => intro _; rfl
    | succ t ih =>
      intro ht
      rw [hist_succ, ih (by omega), hRs]
      simp [he, advEnv, show t < m by omega, hR]
  have hinv : ∀ t, t ≤ m → m - t ≤ φ (R t).2 ∧ (cand (R t).2).Nonempty := by
    intro t
    induction t with
    | zero => intro _; exact ⟨by simp [hR, advRun, hm], h0⟩
    | succ t ih =>
      intro ht
      obtain ⟨ih1, ih2⟩ := ih (by omega)
      obtain ⟨-, -, hne, -, hφ⟩ := hstep (L (R t).1) (R t).2 (by omega)
      rw [hRs]
      exact ⟨by simp only; omega, hne⟩
  have hsub : ∀ k t, t + k ≤ m → cand (R (t + k)).2 ⊆ cand (R t).2 := by
    intro k
    induction k with
    | zero => intro t _; exact subset_rfl
    | succ k ih =>
      intro t htk
      have hφ : 1 ≤ φ (R (t + k)).2 := by have := (hinv (t + k) (by omega)).1; omega
      obtain ⟨-, hc, -, -, -⟩ := hstep (L (R (t + k)).1) (R (t + k)).2 hφ
      rw [← add_assoc, hRs]
      exact hc.trans (ih t (by omega))
  obtain ⟨j, hj⟩ := (hinv m le_rfl).2
  have hfb : ∀ t < m, (e t).isFeedback = true := by
    intro t ht
    have hφ : 1 ≤ φ (R t).2 := by have := (hinv t ht.le).1; omega
    simpa [he, advEnv, ht, hR] using (hstep (L (R t).1) (R t).2 hφ).1
  have hleg : ∀ t < m, FbLegal Bags (H j) (ann L e t) (e t) := by
    intro t ht
    have hφ : 1 ≤ φ (R t).2 := by have := (hinv t ht.le).1; omega
    obtain ⟨-, -, -, hl, -⟩ := hstep (L (R t).1) (R t).2 hφ
    have hjt : j ∈ cand (R (t + 1)).2 := by
      have := hsub (m - (t + 1)) (t + 1) (by omega)
      rw [show t + 1 + (m - (t + 1)) = m by omega] at this
      exact this hj
    rw [hRs] at hjt
    have hann : ann L e t = L (R t).1 := by rw [ann, hhist t ht.le]
    have het : e t = (adv (L (R t).1) (R t).2).1 := by simp [he, advEnv, ht, hR]
    rw [hann, het]
    exact hl j hjt
  obtain ⟨e', h1, h2, h3⟩ := exists_nonSilent_extension hleg hfb
  exact ⟨j, e', h1, h2, h3⟩

end Adversary

/-! ### Version-space learners with a potential -/

/-- The version space after a feedback history. -/
noncomputable def vsOf (H : ι → Set S) [Fintype ι] (l : List (Event S)) : Finset ι :=
  l.foldl (update H) Finset.univ

theorem vsOf_hist [Fintype ι] (H : ι → Set S) (e : ℕ → Event S) :
    ∀ t, vsOf H (hist e t) = vsRun H Finset.univ e t
  | 0 => rfl
  | t + 1 => by
    rw [hist_succ, vsRun_succ, ← vsOf_hist H e t]
    simp [vsOf, List.foldl_append]

/-- **Potential-based learner lemma.** If a learner announces a function of its version space,
and every legal correction (for a target in the version space) lowers a potential `ψ` by at
least one, then it makes at most `ψ(𝓗)` corrections against every legal play. -/
theorem achieves_of_potential [Fintype ι] {Bags : Set (Set S)} {H : ι → Set S}
    (annV : Finset ι → Set S) (ψ : Finset ι → ℕ)
    (hstep : ∀ (C : Finset ι) (j : ι) (ev : Event S), j ∈ C → ev.isFeedback = true →
      FbLegal Bags (H j) (annV C) ev → ψ (update H C ev) + 1 ≤ ψ C) :
    Achieves Bags H (fun l => annV (vsOf H l)) (ψ Finset.univ) := by
  intro j e hleg
  have hmem := target_mem_vsRun (Finset.mem_univ j) (fun t => legalFor_of_fbLegal (hleg t))
  have key : ∀ t, corrections e t + ψ (vsRun H Finset.univ e t) ≤ ψ Finset.univ := by
    intro t
    induction t with
    | zero => simp [corrections]
    | succ t ih =>
      rw [corrections_succ, vsRun_succ]
      have hl := hleg t
      simp only [ann, vsOf_hist] at hl
      by_cases hf : (e t).isFeedback = true
      · have := hstep _ j (e t) (hmem t) hf hl
        rw [if_pos hf]
        omega
      · rw [if_neg hf, eq_nothing_of_not_feedback hf]
        simpa using ih
  intro t
  have := key t
  omega

/-! ### T4 Theorem 4.3(b): `M_obj ≤ M^{(r)}_bag`, with equality at `r = 1` -/

theorem objBags_subset_bagBags {r : ℕ} (hr : 1 ≤ r) : (objBags : Set (Set S)) ⊆ bagBags r := by
  classical
  rintro _ ⟨s, rfl⟩
  exact ⟨{s}, by simp, by simpa using hr⟩

/-- At `r = 1` the legal moves of the bag game and the object game coincide (the empty bag is
never legal). -/
theorem fbLegal_bagBags_one_iff {h A : Set S} {ev : Event S} :
    FbLegal (bagBags 1) h A ev ↔ FbLegal objBags h A ev := by
  classical
  refine ⟨fun hl => ?_, fbLegal_mono (objBags_subset_bagBags le_rfl)⟩
  cases ev with
  | pos s => exact hl
  | nothing => trivial
  | neg P =>
    obtain ⟨⟨B, rfl, hB⟩, hA, hh⟩ := hl
    refine ⟨?_, hA, hh⟩
    rcases Nat.le_one_iff_eq_zero_or_eq_one.1 hB with h0 | h1
    · rw [Finset.card_eq_zero.1 h0] at hh
      exact absurd (by simp) hh
    · obtain ⟨s, rfl⟩ := Finset.card_eq_one.1 h1
      exact ⟨s, by simp⟩

/-- In the object game some feedback item is legal whenever `A ≠ h*`. -/
theorem exists_feedback_objBags {h A : Set S} (hne : A ≠ h) :
    ∃ ev : Event S, ev.isFeedback = true ∧ FbLegal objBags h A ev := by
  obtain ⟨ev, hf, hl⟩ := exists_feedback_bagBags le_rfl hne
  exact ⟨ev, hf, fbLegal_bagBags_one_iff.1 hl⟩

theorem forces_bagBags_one_iff {H : ι → Set S} {L : Learner S} {m : ℕ} :
    Forces (bagBags 1) H L m ↔ Forces objBags H L m := by
  have hl : ∀ h e, PlayLegal (bagBags 1) L h e ↔ PlayLegal objBags L h e := fun h e =>
    forall_congr' fun t => fbLegal_bagBags_one_iff
  have hn : ∀ h e, NonSilent (bagBags 1) L h e ↔ NonSilent objBags L h e := fun h e => by
    simp only [NonSilent, fbLegal_bagBags_one_iff]
  simp only [Forces, hl, hn]

theorem achieves_bagBags_one_iff {H : ι → Set S} {L : Learner S} {m : ℕ} :
    Achieves (bagBags 1) H L m ↔ Achieves objBags H L m := by
  have hl : ∀ h e, PlayLegal (bagBags 1) L h e ↔ PlayLegal objBags L h e := fun h e =>
    forall_congr' fun t => fbLegal_bagBags_one_iff
  simp only [Achieves, hl]

/-- **T4 Theorem 4.3(b), first part: `M_obj(𝓗) ≤ M^{(r)}_bag(𝓗)` for every `r ≥ 1`.** Every
object item is a legal bag item, so a bag learner's guarantee carries over to the object game
(for arbitrary step types and hypothesis classes). -/
theorem thm_4_3_b {H : ι → Set S} {r m m' : ℕ} (hr : 1 ≤ r) (hobj : IsValue objBags H m)
    (hbag : IsValue (bagBags r) H m') : m ≤ m' := by
  obtain ⟨L, hL⟩ := hbag.2
  exact le_of_forces_achieves (hobj.1 L) (hL.mono_bags (objBags_subset_bagBags hr))

/-- **T4 Theorem 4.3(b), second part: equality at `r = 1`.** -/
theorem thm_4_3_b_eq {H : ι → Set S} {m : ℕ} :
    IsValue (bagBags 1) H m ↔ IsValue objBags H m := by
  simp only [IsValue, forces_bagBags_one_iff, achieves_bagBags_one_iff]

end Game

/-! ## 1. The single-culprit class `𝓗_n` (T4 Theorem 4.4(b)) -/

section SingleCulprit

variable {n : ℕ}

/-- The single-culprit class `𝓗_n = {S \ {b_j} : j < n}` over `S = {b₀, …, b_{n-1}} = Fin n`:
exactly one of the `n` suspect steps is invalid. -/
def single (n : ℕ) (j : Fin n) : Set (Fin n) := {i | i ≠ j}

@[simp] theorem mem_single {i j : Fin n} : i ∈ single n j ↔ i ≠ j := Iff.rfl

theorem subset_single_iff {P : Set (Fin n)} {j : Fin n} : P ⊆ single n j ↔ j ∉ P :=
  ⟨fun h hj => h hj rfl, fun h _ hi hij => h (hij ▸ hi)⟩

theorem single_injective : Function.Injective (single n) := by
  intro j k h
  by_contra hjk
  have : j ∈ single n k := hjk
  rw [← h] at this
  exact this rfl

open scoped Classical in
/-- `|𝓗_n| = n`: the `n` hypotheses are pairwise distinct. -/
theorem card_class : (Finset.univ.image (single n)).card = n := by
  rw [Finset.card_image_of_injective _ single_injective, Finset.card_univ, Fintype.card_fin]

theorem mem_update_single_pos {C : Finset (Fin n)} {s i : Fin n} :
    i ∈ update (single n) C (.pos s) ↔ i ∈ C ∧ i ≠ s := by
  rw [mem_update_pos, mem_single]
  exact and_congr_right fun _ => ne_comm

theorem mem_update_single_neg {C : Finset (Fin n)} {P : Set (Fin n)} {i : Fin n} :
    i ∈ update (single n) C (.neg P) ↔ i ∈ C ∧ i ∈ P := by
  rw [mem_update_neg, subset_single_iff, not_not]

/-! ### The bag learner (upper bound `min(r, n-1)`) -/

/-- The bag learner's announcement given the version space `C`: while more than `r` candidates
survive (or none), announce all of `S`; otherwise announce all steps but the least surviving
candidate culprit. -/
noncomputable def bagAnn (r : ℕ) (C : Finset (Fin n)) : Set (Fin n) :=
  if h : C.Nonempty ∧ C.card ≤ r then {i | i ≠ C.min' h.1} else Set.univ

/-- The bag learner of T4 Thm 4.4(b) (upper bound). For `r = 1` it is also the optimal object
learner. -/
noncomputable def bagLearner (n r : ℕ) : Learner (Fin n) :=
  fun l => bagAnn r (vsOf (single n) l)

/-- The potential `f(c) = min(r, c - 1)` of the paper, in the form used by the learner. -/
def bagPot (r : ℕ) (C : Finset (Fin n)) : ℕ := if r < C.card then r else C.card - 1

theorem bagPot_univ (r : ℕ) : bagPot r (Finset.univ : Finset (Fin n)) = min r (n - 1) := by
  simp only [bagPot, Finset.card_univ, Fintype.card_fin]
  split_ifs with h <;> omega

/-- Every legal correction against the bag learner lowers `bagPot` by at least one. -/
theorem bagPot_step (r : ℕ) (C : Finset (Fin n)) (j : Fin n) (ev : Event (Fin n)) (hj : j ∈ C)
    (hf : ev.isFeedback = true) (hl : FbLegal (bagBags r) (single n j) (bagAnn r C) ev) :
    bagPot r (update (single n) C ev) + 1 ≤ bagPot r C := by
  classical
  have hCne : C.Nonempty := ⟨j, hj⟩
  unfold bagAnn at hl
  by_cases hr : C.card ≤ r
  · -- announce `S \ {c}` for the least candidate `c`
    have hcond : C.Nonempty ∧ C.card ≤ r := ⟨hCne, hr⟩
    rw [dif_pos hcond] at hl
    set c := C.min' hCne with hc
    have hcC : c ∈ C := C.min'_mem hCne
    have hpotC : bagPot r C = C.card - 1 := by simp [bagPot, not_lt.2 hr]
    cases ev with
    | nothing => exact absurd hf (by simp [Event.isFeedback])
    | pos s =>
      obtain ⟨hs, hsA⟩ := hl
      simp only [Set.mem_setOf_eq, not_not] at hsA
      -- `s = c ≠ j`, and the update is `C.erase c`
      have hupd : update (single n) C (.pos s) = C.erase c := by
        ext i; rw [mem_update_single_pos, Finset.mem_erase, hsA]; exact and_comm
      rw [hupd]
      have hjc : j ≠ c := fun h => hs (hsA.trans h.symm)
      have hcard := Finset.card_erase_of_mem hcC
      have hj' : j ∈ C.erase c := Finset.mem_erase.2 ⟨hjc, hj⟩
      have hpos := Finset.card_pos.2 ⟨j, hj'⟩
      have hle : (C.erase c).card ≤ r := by omega
      have hpot' : bagPot r (C.erase c) = (C.erase c).card - 1 := by simp [bagPot, not_lt.2 hle]
      rw [hpotC, hpot']
      omega
    | neg P =>
      obtain ⟨-, hPA, hPh⟩ := hl
      rw [subset_single_iff, not_not] at hPh
      set C' := update (single n) C (.neg P) with hC'
      have hsub : C' ⊆ C.erase c := by
        intro i hi
        rw [hC', mem_update_single_neg] at hi
        refine Finset.mem_erase.2 ⟨fun h => ?_, hi.1⟩
        have := hPA hi.2
        rw [h] at this
        exact this rfl
      have hjC' : j ∈ C' := by rw [hC', mem_update_single_neg]; exact ⟨hj, hPh⟩
      have hcard := Finset.card_erase_of_mem hcC
      have hle := Finset.card_le_card hsub
      have hpos := Finset.card_pos.2 ⟨j, hjC'⟩
      have hle' : C'.card ≤ r := by omega
      have hpot' : bagPot r C' = C'.card - 1 := by simp [bagPot, not_lt.2 hle']
      rw [hpotC, hpot']
      omega
  · -- announce all of `S`
    have hcond : ¬ (C.Nonempty ∧ C.card ≤ r) := fun h => hr h.2
    rw [dif_neg hcond] at hl
    have hpotC : bagPot r C = r := by simp [bagPot, lt_of_not_ge hr]
    cases ev with
    | nothing => exact absurd hf (by simp [Event.isFeedback])
    | pos s => exact absurd trivial hl.2
    | neg P =>
      obtain ⟨⟨B, rfl, hB⟩, -, hPh⟩ := hl
      rw [subset_single_iff, not_not] at hPh
      set C' := update (single n) C (.neg ↑B) with hC'
      have hsub : C' ⊆ B := by
        intro i hi
        rw [hC', mem_update_single_neg] at hi
        exact hi.2
      have hjC' : j ∈ C' := by rw [hC', mem_update_single_neg]; exact ⟨hj, hPh⟩
      have hle := Finset.card_le_card hsub
      have hpos := Finset.card_pos.2 ⟨j, hjC'⟩
      have hle' : C'.card ≤ r := by omega
      have hpot' : bagPot r C' = C'.card - 1 := by simp [bagPot, not_lt.2 hle']
      rw [hpotC, hpot']
      omega

/-- **T4 Thm 4.4(b), bag upper bound.** The bag learner makes at most `min(r, n-1)`
corrections in the bag game with bags of size `≤ r`, against every target and every legal
(adaptive, possibly silent) environment. -/
theorem thm_4_4_b_bag_upper (n r : ℕ) :
    Achieves (bagBags r) (single n) (bagLearner n r) (min r (n - 1)) := by
  rw [← bagPot_univ]
  exact achieves_of_potential (bagAnn r) (bagPot r) (bagPot_step r)

/-! ### The bag adversary (lower bound `min(r, n-1)`) -/

open scoped Classical in
/-- The adversary of T4 Thm 4.4(b), with state `C` = the surviving candidate culprits:
* if the learner rejects a candidate `i ∈ C`, answer `(+) b_i` (`C ← C \ {i}`);
* otherwise, if `|C| > r`, answer with a bag of `r` candidates (`C ← B`);
* otherwise answer with the bag `C` (deleting nothing). -/
noncomputable def advB (r : ℕ) (A : Set (Fin n)) (C : Finset (Fin n)) :
    Event (Fin n) × Finset (Fin n) :=
  if h : ∃ i ∈ C, i ∉ A then (.pos h.choose, C.erase h.choose)
  else if hr : r < C.card then
    (.neg ↑(Finset.exists_subset_card_eq hr.le).choose,
      (Finset.exists_subset_card_eq hr.le).choose)
  else (.neg ↑C, C)

theorem advB_step (r : ℕ) (A : Set (Fin n)) (C : Finset (Fin n))
    (hφ : 1 ≤ min r (C.card - 1)) :
    (advB r A C).1.isFeedback = true ∧ (↑(advB r A C).2 : Set (Fin n)) ⊆ ↑C ∧
    (↑(advB r A C).2 : Set (Fin n)).Nonempty ∧
    (∀ j ∈ (↑(advB r A C).2 : Set (Fin n)),
      FbLegal (bagBags r) (single n j) A (advB r A C).1) ∧
    min r (C.card - 1) ≤ min r ((advB r A C).2.card - 1) + 1 := by
  classical
  have hr1 : 1 ≤ r := by omega
  have hC2 : 2 ≤ C.card := by omega
  unfold advB
  split_ifs with h hr
  · obtain ⟨hiC, hiA⟩ := h.choose_spec
    have hcard := Finset.card_erase_of_mem hiC
    refine ⟨rfl, Finset.coe_subset.2 (Finset.erase_subset _ _), ?_, ?_, ?_⟩
    · exact Finset.coe_nonempty.2 (Finset.card_pos.1 (by rw [hcard]; omega))
    · intro j hj
      have hj' := Finset.mem_erase.1 (Finset.mem_coe.1 hj)
      exact ⟨fun h' => hj'.1 h'.symm, hiA⟩
    · simp only
      omega
  · simp only [not_exists, not_and, not_not] at h
    obtain ⟨hBC, hBcard⟩ := (Finset.exists_subset_card_eq hr.le).choose_spec
    set B := (Finset.exists_subset_card_eq hr.le).choose
    refine ⟨rfl, Finset.coe_subset.2 hBC, ?_, ?_, ?_⟩
    · exact Finset.coe_nonempty.2 (Finset.card_pos.1 (by rw [hBcard]; omega))
    · intro j hj
      refine ⟨⟨B, rfl, hBcard.le⟩, fun x hx => h x (hBC hx), ?_⟩
      rw [subset_single_iff, not_not]
      exact hj
    · simp only
      omega
  · simp only [not_exists, not_and, not_not] at h
    refine ⟨rfl, subset_rfl, Finset.coe_nonempty.2 (Finset.card_pos.1 (show 0 < C.card by omega)), ?_, ?_⟩
    · intro j hj
      refine ⟨⟨C, rfl, by omega⟩, fun x hx => h x hx, ?_⟩
      rw [subset_single_iff, not_not]
      exact hj
    · simp only
      omega

/-- **T4 Thm 4.4(b), bag lower bound.** For every bag size `r` and every deterministic learner,
the adversary forces `min(r, n-1)` corrections on the single-culprit class (with a legal,
non-silent play and a target consistent with all its answers). -/
theorem thm_4_4_b_bag_lower (n r : ℕ) (hn : 1 ≤ n) (L : Learner (Fin n)) :
    Forces (bagBags r) (single n) L (min r (n - 1)) := by
  refine forces_of_adversary L (fun C : Finset (Fin n) => (↑C : Set (Fin n)))
    (fun C => min r (C.card - 1)) (advB r) Finset.univ ?_ ?_ ?_
  · simp [Finset.card_univ, Fintype.card_fin]
  · exact ⟨⟨0, hn⟩, by simp⟩
  · intro A C hφ
    exact advB_step r A C hφ

/-- **T4 Thm 4.4(b): `M^{(r)}_bag(𝓗_n) = min(r, n-1)`.** -/
theorem thm_4_4_b_bag_value (n r : ℕ) (hn : 1 ≤ n) :
    IsValue (bagBags r) (single n) (min r (n - 1)) :=
  ⟨thm_4_4_b_bag_lower n r hn, bagLearner n r, thm_4_4_b_bag_upper n r⟩

/-- **T4 Thm 4.4(b), unbounded bags: `M_bag(𝓗_n) = n - 1 = |𝓗_n| - 1`** (bags of any size up to
`|S| = n`); also for every `r ≥ n - 1`. -/
theorem thm_4_4_b_unbounded (n r : ℕ) (hn : 1 ≤ n) (hr : n - 1 ≤ r) :
    IsValue (bagBags r) (single n) (n - 1) := by
  have := thm_4_4_b_bag_value n r hn
  rwa [min_eq_right hr] at this

/-- **T4 Thm 4.4(b), objects, upper bound: one correction suffices.** -/
theorem thm_4_4_b_obj_upper (n : ℕ) : Achieves objBags (single n) (bagLearner n 1) 1 :=
  (achieves_bagBags_one_iff.1 (thm_4_4_b_bag_upper n 1)).mono (min_le_left _ _)

/-- **T4 Thm 4.4(b), objects, lower bound: at least one correction is needed** (`n ≥ 2`). -/
theorem thm_4_4_b_obj_lower (n : ℕ) (hn : 2 ≤ n) (L : Learner (Fin n)) :
    Forces objBags (single n) L 1 := by
  have := thm_4_4_b_bag_lower n 1 (by omega) L
  rw [min_eq_left (by omega)] at this
  exact forces_bagBags_one_iff.1 this

/-- **T4 Thm 4.4(b): `M_obj(𝓗_n) = 1`.** -/
theorem thm_4_4_b_obj_value (n : ℕ) (hn : 2 ≤ n) : IsValue objBags (single n) 1 :=
  ⟨thm_4_4_b_obj_lower n hn, bagLearner n 1, thm_4_4_b_obj_upper n⟩

/-- **T4 Theorem 4.4(b) (single-culprit class), summary.** For `n ≥ 2` and every `r`:
`|𝓗_n| = n`, `M_obj(𝓗_n) = 1`, `M^{(r)}_bag(𝓗_n) = min(r, n-1)`, and with unbounded bags
(`r = |S| = n`) `M_bag(𝓗_n) = n - 1 = |𝓗_n| - 1`. -/
theorem thm_4_4_b (n r : ℕ) (hn : 2 ≤ n) :
    (Finset.univ.image (single n)).card = n ∧
    IsValue objBags (single n) 1 ∧
    IsValue (bagBags r) (single n) (min r (n - 1)) ∧
    IsValue (bagBags n) (single n) (n - 1) := by
  classical
  exact ⟨card_class, thm_4_4_b_obj_value n hn, thm_4_4_b_bag_value n r (by omega),
    thm_4_4_b_unbounded n n (by omega) (by omega)⟩

end SingleCulprit

/-! ## 2. The chain paradox: logic (T4 Theorem 4.4(c)) -/

section ChainLogic

open Formula

variable (n : ℕ)

/-- The suspect step `b_{i+1} = (q_i ⇒ q_{i+1})` (with `q_k = p_k`), for `i < n`. -/
def chainStep (i : Fin n) : Step Formula := ⟨{var (i : ℕ)}, var ((i : ℕ) + 1)⟩

/-- The single designated context `A = {q₀, ¬q_n}` ("`n` grains make a heap, `0` grains do
not", with `q_k` = "a pile of `n - k` grains is a heap"). -/
def ctx : Set Formula := {var 0, neg (var n)}

/-- The axioms of the reading `h_j`: `q_i → q_{i+1}` for every `i ≠ j`. -/
def Tch (j : Fin n) : Set Formula :=
  {φ | ∃ i : Fin n, i ≠ j ∧ φ = imp (var (i : ℕ)) (var ((i : ℕ) + 1))}

/-- The hypothesis `h_j = Cn_CPC(Tch n j)` read as a set of steps: `(Π, c) ∈ h_j` iff
`c ∈ C₂(Tch n j ∪ Π)`. -/
def hypC (j : Fin n) : Set (Step Formula) := {s | s.concl ∈ Cn2 (Tch n j ∪ ↑s.prem)}

/-- The certified (logical) step `q_n, ¬q_n ⊢ ⊥`. -/
def explStep : Step Formula := ⟨{var n, neg (var n)}, bot⟩

/-- The valuation `p_k ↦ (k ≤ j)`: a model of `h_j` on the designated context. -/
def vj (j : ℕ) : Valuation := fun k => decide (k ≤ j)

variable {n}

theorem satisfies_union {v : Valuation} {X Y : Set Formula} :
    Satisfies v (X ∪ Y) ↔ Satisfies v X ∧ Satisfies v Y :=
  ⟨fun h => ⟨fun ψ hψ => h ψ (Or.inl hψ), fun ψ hψ => h ψ (Or.inr hψ)⟩,
    fun h ψ hψ => hψ.elim (h.1 ψ) (h.2 ψ)⟩

theorem vj_satisfies_Tch (j : Fin n) : Satisfies (vj j) (Tch n j) := by
  rintro _ ⟨i, hij, rfl⟩
  have hij' : (i : ℕ) ≠ (j : ℕ) := fun h => hij (Fin.ext h)
  simp only [eval_imp, eval_var, vj]
  by_cases h : (i : ℕ) ≤ j
  · have : (i : ℕ) + 1 ≤ j := by omega
    simp [this]
  · simp [h]

theorem vj_satisfies_ctx (j : Fin n) : Satisfies (vj j) (ctx n) := by
  have hj := j.isLt
  simp only [ctx, satisfies_insert, satisfies_singleton, eval_var, eval_neg, vj]
  refine ⟨by simp, ?_⟩
  simp only [Bool.not_eq_eq_eq_not, Bool.not_true, decide_eq_false_iff_not, not_le]
  exact hj

/-- `Tch n j ∪ ctx n` is satisfiable. -/
theorem satisfiable_Tch_ctx (j : Fin n) : Satisfiable (Tch n j ∪ ctx n) :=
  ⟨vj j, satisfies_union.2 ⟨vj_satisfies_Tch j, vj_satisfies_ctx j⟩⟩

/-- **`h_j` validates `b_i` iff `i ≠ j`.** -/
theorem chainStep_mem_hypC {i j : Fin n} : chainStep n i ∈ hypC n j ↔ i ≠ j := by
  constructor
  · rintro h rfl
    have hsat : Satisfies (vj i) (Tch n i ∪ ↑(chainStep n i).prem) := by
      refine satisfies_union.2 ⟨vj_satisfies_Tch i, ?_⟩
      simp [chainStep, vj]
    have := h (vj i) hsat
    simp [chainStep, vj] at this
  · intro hij v hv
    have h1 := hv (imp (var (i : ℕ)) (var ((i : ℕ) + 1))) (Or.inl ⟨i, hij, rfl⟩)
    have h2 := hv (var (i : ℕ)) (Or.inr (by simp [chainStep]))
    simp only [eval_imp, eval_var, Bool.or_eq_true, Bool.not_eq_eq_eq_not, Bool.not_true] at h1 h2
    simp only [chainStep, eval_var]
    rcases h1 with h1 | h1
    · rw [h1] at h2; exact absurd h2 (by simp)
    · exact h1

/-- Every classically valid step is certified: it lies in every `h_j`. -/
theorem SemSound_subset_hypC (j : Fin n) : SemSound ⊆ hypC n j := by
  intro s hs v hv
  exact hs v (satisfies_mono Set.subset_union_right hv)

theorem explStep_mem_SemSound : explStep n ∈ SemSound := by
  intro v hv
  simp only [explStep, Finset.coe_insert, Finset.coe_singleton, satisfies_insert,
    satisfies_singleton, eval_neg] at hv
  rw [hv.1] at hv
  exact absurd hv.2 (by simp)

/-- `h_j`, read as a step set, only derives what `Tch n j` classically entails. -/
theorem Cl_hypC_subset (j : Fin n) (B : Set Formula) : Cl (hypC n j) B ⊆ Cn2 (Tch n j ∪ B) := by
  refine Cl_subset (fun φ hφ => Cn2.subset_apply _ (Or.inr hφ)) ?_
  intro s hs hprem
  refine Cn2.mem_trans ?_ hs
  rintro φ (hφ | hφ)
  · exact Cn2.subset_apply _ (Or.inl hφ)
  · exact hprem hφ

/-- **Every `h_j` is coherent on the designated context**: no chain of `h_j`-steps derives `⊥`
from `{q₀, ¬q_n}`. So the designation is truthful whatever the target. -/
theorem hypC_coherent (j : Fin n) : bot ∉ Cl (hypC n j) (ctx n) := by
  intro h
  have h' := Cl_hypC_subset j (ctx n) h
  obtain ⟨v, hv⟩ := satisfiable_Tch_ctx j
  have := h' v hv
  simp at this

/-- **The paradox exists**: the chain steps `b_1, …, b_n` together with the certified step
`q_n, ¬q_n ⊢ ⊥` derive `⊥` from the designated context. -/
theorem paradox_derivation :
    bot ∈ Cl (Set.range (chainStep n) ∪ {explStep n}) (ctx n) := by
  set P := Set.range (chainStep n) ∪ {explStep n}
  have hq : ∀ k ≤ n, var k ∈ Cl P (ctx n) := by
    intro k
    induction k with
    | zero => intro _; exact subset_Cl (by simp [ctx])
    | succ k ih =>
      intro hk
      have hs : chainStep n ⟨k, by omega⟩ ∈ P := Or.inl ⟨_, rfl⟩
      have := concl_mem_Cl (B := ctx n) hs (by
        intro φ hφ
        simp only [chainStep, Finset.coe_singleton, Set.mem_singleton_iff] at hφ
        rw [hφ]
        exact ih (by omega))
      simpa [chainStep] using this
  have hs : explStep n ∈ P := Or.inr rfl
  have := concl_mem_Cl (B := ctx n) hs (by
    intro φ hφ
    simp only [explStep, Finset.coe_insert, Finset.coe_singleton, Set.mem_insert_iff,
      Set.mem_singleton_iff] at hφ
    rcases hφ with rfl | rfl
    · exact hq n le_rfl
    · exact subset_Cl (by simp [ctx]))
  simpa [explStep] using this

/-- A step is *certified* if every hypothesis of the class validates it (it lies in `⋂ VS`);
certified steps are dropped from bags without loss. -/
def Certified (s : Step Formula) : Prop := ∀ j : Fin n, s ∈ hypC n j

/-- **Essential bag.** Every derivation of `⊥` from the designated context `{q₀, ¬q_n}` whose
steps are chain steps or certified steps uses **all** the chain steps. -/
theorem essential_bag {D : Set (Step Formula)} (hD : bot ∈ Cl D (ctx n))
    (hsteps : ∀ s ∈ D, s ∈ Set.range (chainStep n) ∨ Certified (n := n) s) (i : Fin n) :
    chainStep n i ∈ D := by
  by_contra hi
  have hsub : D ⊆ hypC n i := by
    intro s hs
    rcases hsteps s hs with ⟨k, rfl⟩ | hc
    · refine chainStep_mem_hypC.2 fun hki => hi ?_
      rw [← hki]
      exact hs
    · exact hc i
  exact hypC_coherent i (Cl_mono_rules hsub hD)

/-- Chain steps are never certified (for the culprit `i` itself, `b_i ∉ h_i`), so the bag of a
derivation `D` (its non-certified steps) is exactly its set of chain steps. -/
theorem chainStep_not_certified (i : Fin n) : ¬ Certified (n := n) (chainStep n i) :=
  fun h => chainStep_mem_hypC.1 (h i) rfl

variable (n) in
/-- **The paradox bags of the chain game**: the sets of suspect steps `{i | b_i ∈ D}` used by
derivations `D` of `⊥` from the designated context whose steps are chain steps or certified. -/
def chainBags : Set (Set (Fin n)) :=
  {P | ∃ D : Set (Step Formula), bot ∈ Cl D (ctx n) ∧
    (∀ s ∈ D, s ∈ Set.range (chainStep n) ∨ Certified (n := n) s) ∧
    P = {i | chainStep n i ∈ D}}

/-- **Every paradox is the same essential bag**: the only available bag is the full chain. -/
theorem chainBags_eq : chainBags n = {Set.univ} := by
  ext P
  simp only [chainBags, Set.mem_setOf_eq, Set.mem_singleton_iff]
  constructor
  · rintro ⟨D, hD, hsteps, rfl⟩
    ext i
    simp only [Set.mem_setOf_eq, Set.mem_univ, iff_true]
    exact essential_bag hD hsteps i
  · rintro rfl
    refine ⟨Set.range (chainStep n) ∪ {explStep n}, paradox_derivation, ?_, ?_⟩
    · rintro s (hs | hs)
      · exact Or.inl hs
      · rw [Set.mem_singleton_iff.1 hs]
        exact Or.inr fun j => SemSound_subset_hypC j explStep_mem_SemSound
    · ext i
      simp only [Set.mem_univ, Set.mem_setOf_eq, true_iff]
      exact Or.inl ⟨i, rfl⟩

/-- A valuation `u` *refutes* a step if it makes all premises true and the conclusion false. -/
def Refutes (u : Valuation) (s : Step Formula) : Prop :=
  (∀ φ ∈ s.prem, φ.eval u = true) ∧ s.concl.eval u = false

/-- **The object pins down the culprit.** Every admissible object for `h_j` with `u(q₀) = 1`,
`u(q_n) = 0` (a valuation of `Tch n j ∪ ctx n`) makes `q_k` true exactly for `k ≤ j`. -/
theorem object_descent (j : Fin n) (u : Valuation) (hu : Satisfies u (Tch n j ∪ ctx n)) :
    ∀ k ≤ n, (u k = true ↔ k ≤ j) := by
  obtain ⟨hT, hA⟩ := satisfies_union.1 hu
  simp only [ctx, satisfies_insert, satisfies_singleton, eval_var, eval_neg,
    Bool.not_eq_eq_eq_not, Bool.not_true] at hA
  have hj := j.isLt
  have himp : ∀ i : ℕ, i < n → i ≠ j → u i = true → u (i + 1) = true := by
    intro i hi hij hui
    have := hT (imp (var i) (var (i + 1))) ⟨⟨i, hi⟩, fun h => hij (congrArg Fin.val h), rfl⟩
    simp only [eval_imp, eval_var, hui, Bool.not_true, Bool.false_or] at this
    exact this
  -- upward: `u k` for `k ≤ j`
  have hup : ∀ k : ℕ, k ≤ j → u k = true := by
    intro k
    induction k with
    | zero => intro _; exact hA.1
    | succ k ih =>
      intro hk
      exact himp k (by omega) (by omega) (ih (by omega))
  -- downward: `¬ u k` for `j < k ≤ n`
  have hdown : ∀ d k : ℕ, k + d = n → (j : ℕ) < k → u k = false := by
    intro d
    induction d with
    | zero => intro k hk _; rw [show k = n by omega]; exact hA.2
    | succ d ih =>
      intro k hk hjk
      have h1 := ih (k + 1) (by omega) (by omega)
      cases huk : u k
      · rfl
      · have := himp k (by omega) (by omega) huk
        rw [h1] at this
        exact absurd this (by simp)
  intro k hk
  constructor
  · intro huk
    by_contra hjk
    have := hdown (n - k) k (by omega) (by omega)
    rw [huk] at this
    exact absurd this (by simp)
  · exact hup k

/-- **Descent on the chain stops at `b_j`**: an admissible object for `h_j` refutes the chain step
`b_i` iff `i = j`. So a single object yields the `(−obj)` item `b_{j*}`. -/
theorem object_refutes_iff (j : Fin n) (u : Valuation) (hu : Satisfies u (Tch n j ∪ ctx n))
    (i : Fin n) : Refutes u (chainStep n i) ↔ i = j := by
  have hd := object_descent j u hu
  have hi := i.isLt
  have h1 := hd i (by omega)
  have h2 := hd (i + 1) (by omega)
  simp only [Refutes, chainStep, Finset.mem_singleton, forall_eq, eval_var]
  constructor
  · rintro ⟨ha, hb⟩
    have hij : (i : ℕ) ≤ j := h1.1 ha
    have hji : ¬ ((i : ℕ) + 1 ≤ j) := fun h => by rw [h2.2 h] at hb; exact absurd hb (by simp)
    exact Fin.ext (by omega)
  · rintro rfl
    refine ⟨h1.2 le_rfl, ?_⟩
    cases hu' : u ((i : ℕ) + 1)
    · rfl
    · have := h2.1 hu'
      omega

/-- Such an admissible object exists for every target. -/
theorem exists_object (j : Fin n) :
    ∃ u, Satisfies u (Tch n j ∪ ctx n) ∧ Refutes u (chainStep n j) := by
  have hu : Satisfies (vj j) (Tch n j ∪ ctx n) :=
    satisfies_union.2 ⟨vj_satisfies_Tch j, vj_satisfies_ctx j⟩
  exact ⟨vj j, hu, (object_refutes_iff j (vj j) hu j).2 rfl⟩

end ChainLogic

/-! ## 3. The chain paradox: the correction game (T4 Theorem 4.4(c)) -/

section ChainGame

variable {n : ℕ}

variable (n) in
/-- The chain class over the suspect steps `S = Fin n`: `h_j` restricted to the chain steps. -/
def chainH (j : Fin n) : Set (Fin n) := {i | chainStep n i ∈ hypC n j}

theorem chainH_eq : chainH n = single n := by
  funext j
  ext i
  simp [chainH, chainStep_mem_hypC]

theorem chainBags_subset_bagBags : chainBags n ⊆ bagBags n := by
  classical
  rw [chainBags_eq]
  rintro _ rfl
  exact ⟨Finset.univ, by simp, by simp⟩

/-- In the chain game some feedback item is legal whenever `A ≠ h*` (so `NonSilent` is
Def. 4.2's rule, by `nonSilent_iff`). -/
theorem exists_feedback_chain {j : Fin n} {A : Set (Fin n)} (hne : A ≠ chainH n j) :
    ∃ ev : Event (Fin n), ev.isFeedback = true ∧ FbLegal (chainBags n) (chainH n j) A ev := by
  rw [chainH_eq] at hne ⊢
  by_cases h : ∃ i, i ≠ j ∧ i ∉ A
  · obtain ⟨i, hij, hiA⟩ := h
    exact ⟨.pos i, rfl, hij, hiA⟩
  · simp only [not_exists, not_and, not_not] at h
    have hjA : j ∈ A := by
      by_contra hjA
      apply hne
      ext i
      simp only [mem_single]
      constructor
      · intro hi hij
        exact hjA (hij ▸ hi)
      · intro hij
        exact h i hij
    have hA : A = Set.univ := Set.eq_univ_of_forall fun i => by
      by_cases hij : i = j
      · exact hij ▸ hjA
      · exact h i hij
    refine ⟨.neg Set.univ, rfl, by rw [chainBags_eq]; rfl, by rw [hA], ?_⟩
    rw [subset_single_iff, not_not]
    trivial

open scoped Classical in
/-- The adversary of T4 Thm 4.4(c), with state `C` = the surviving candidate culprits:
* if the learner rejects a candidate `i ∈ C`, answer `(+) b_i` (`C ← C \ {i}`);
* otherwise, if it rejects some (known-valid) step `i`, answer `(+) b_i` (deleting nothing);
* otherwise it accepts the whole chain: answer with the paradox bag `S` (deleting nothing). -/
noncomputable def advC (A : Set (Fin n)) (C : Finset (Fin n)) : Event (Fin n) × Finset (Fin n) :=
  if h : ∃ i ∈ C, i ∉ A then (.pos h.choose, C.erase h.choose)
  else if h' : ∃ i, i ∉ A then (.pos h'.choose, C)
  else (.neg Set.univ, C)

theorem advC_step (A : Set (Fin n)) (C : Finset (Fin n)) (hφ : 1 ≤ C.card - 1) :
    (advC A C).1.isFeedback = true ∧ (↑(advC A C).2 : Set (Fin n)) ⊆ ↑C ∧
    (↑(advC A C).2 : Set (Fin n)).Nonempty ∧
    (∀ j ∈ (↑(advC A C).2 : Set (Fin n)), FbLegal (chainBags n) (chainH n j) A (advC A C).1) ∧
    C.card - 1 ≤ ((advC A C).2.card - 1) + 1 := by
  classical
  rw [chainH_eq]
  unfold advC
  split_ifs with h h'
  · obtain ⟨hiC, hiA⟩ := h.choose_spec
    have hcard := Finset.card_erase_of_mem hiC
    refine ⟨rfl, Finset.coe_subset.2 (Finset.erase_subset _ _), ?_, ?_, ?_⟩
    · exact Finset.coe_nonempty.2 (Finset.card_pos.1 (by rw [hcard]; omega))
    · intro j hj
      have hj' := Finset.mem_erase.1 (Finset.mem_coe.1 hj)
      exact ⟨fun h' => hj'.1 h'.symm, hiA⟩
    · simp only
      omega
  · simp only [not_exists, not_and, not_not] at h
    have hiA := h'.choose_spec
    refine ⟨rfl, subset_rfl, Finset.coe_nonempty.2 (Finset.card_pos.1 (show 0 < C.card by omega)), ?_, ?_⟩
    · intro j hj
      refine ⟨fun hij => ?_, hiA⟩
      rw [hij] at hiA
      exact hiA (h j hj)
    · simp only
      omega
  · simp only [not_exists, not_not] at h'
    refine ⟨rfl, subset_rfl, Finset.coe_nonempty.2 (Finset.card_pos.1 (show 0 < C.card by omega)), ?_, ?_⟩
    · intro j _
      refine ⟨by rw [chainBags_eq]; rfl, fun x _ => h' x, ?_⟩
      rw [subset_single_iff, not_not]
      trivial
    · simp only
      omega

/-- **T4 Thm 4.4(c), lower bound.** With paradox feedback from the sorites-shaped chain (bags
of genuine `⊥`-derivations from the designated context `{q₀, ¬q_n}`), an adversary forces
`n - 1 = |𝓗| - 1` corrections on every deterministic learner. -/
theorem thm_4_4_c_lower (hn : 1 ≤ n) (L : Learner (Fin n)) :
    Forces (chainBags n) (chainH n) L (n - 1) := by
  refine forces_of_adversary L (fun C : Finset (Fin n) => (↑C : Set (Fin n)))
    (fun C => C.card - 1) advC Finset.univ ?_ ?_ ?_
  · simp [Finset.card_univ, Fintype.card_fin]
  · exact ⟨⟨0, hn⟩, by simp⟩
  · intro A C hφ
    exact advC_step A C hφ

/-- **T4 Thm 4.4(c), upper bound**: `n - 1` corrections suffice (eliminate one candidate per
correction). -/
theorem thm_4_4_c_upper : Achieves (chainBags n) (chainH n) (bagLearner n n) (n - 1) := by
  have h := (thm_4_4_b_bag_upper n n).mono_bags chainBags_subset_bagBags
  rw [min_eq_right (Nat.sub_le n 1)] at h
  rwa [chainH_eq]

/-- **T4 Thm 4.4(c): with paradox feedback, `M = n - 1 = |𝓗| - 1`.** -/
theorem thm_4_4_c_value (hn : 1 ≤ n) : IsValue (chainBags n) (chainH n) (n - 1) :=
  ⟨thm_4_4_c_lower hn, bagLearner n n, thm_4_4_c_upper⟩

/-- **T4 Thm 4.4(c), objects: one correction suffices and is needed (`n ≥ 2`).** -/
theorem thm_4_4_c_obj_value (hn : 2 ≤ n) : IsValue objBags (chainH n) 1 := by
  rw [chainH_eq]
  exact thm_4_4_b_obj_value n hn

/-- **T4 Theorem 4.4(c), summary.** In the chain paradox with `n ≥ 2` suspect steps:
* every `h_j` is coherent on the designated context `{q₀, ¬q_n}`;
* the only paradox bag is the full chain;
* with paradox feedback the minimax number of corrections is `n - 1 = |𝓗| - 1`;
* with object feedback it is `1`, and each admissible object for `h_j` refutes exactly `b_j`. -/
theorem thm_4_4_c (hn : 2 ≤ n) :
    (∀ j : Fin n, Formula.bot ∉ Cl (hypC n j) (ctx n)) ∧
    chainBags n = {Set.univ} ∧
    IsValue (chainBags n) (chainH n) (n - 1) ∧
    IsValue objBags (chainH n) 1 ∧
    (∀ (j : Fin n) (u : Valuation), Satisfies u (Tch n j ∪ ctx n) →
      ∀ i, Refutes u (chainStep n i) ↔ i = j) :=
  ⟨hypC_coherent, chainBags_eq, thm_4_4_c_value (by omega), thm_4_4_c_obj_value hn,
    fun j u hu i => object_refutes_iff j u hu i⟩

end ChainGame

end ParadoxLowerBound
end InfLearn

#print axioms InfLearn.ParadoxLowerBound.forces_of_adversary
#print axioms InfLearn.ParadoxLowerBound.exists_nonSilent_extension
#print axioms InfLearn.ParadoxLowerBound.nonSilent_iff
#print axioms InfLearn.ParadoxLowerBound.exists_feedback_bagBags
#print axioms InfLearn.ParadoxLowerBound.exists_feedback_objBags
#print axioms InfLearn.ParadoxLowerBound.IsValue.unique
#print axioms InfLearn.ParadoxLowerBound.achieves_of_potential
#print axioms InfLearn.ParadoxLowerBound.thm_4_3_b
#print axioms InfLearn.ParadoxLowerBound.thm_4_3_b_eq
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_b_bag_lower
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_b_bag_upper
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_b_bag_value
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_b_unbounded
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_b_obj_lower
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_b_obj_upper
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_b_obj_value
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_b
#print axioms InfLearn.ParadoxLowerBound.chainStep_mem_hypC
#print axioms InfLearn.ParadoxLowerBound.hypC_coherent
#print axioms InfLearn.ParadoxLowerBound.paradox_derivation
#print axioms InfLearn.ParadoxLowerBound.essential_bag
#print axioms InfLearn.ParadoxLowerBound.chainBags_eq
#print axioms InfLearn.ParadoxLowerBound.object_descent
#print axioms InfLearn.ParadoxLowerBound.object_refutes_iff
#print axioms InfLearn.ParadoxLowerBound.exists_object
#print axioms InfLearn.ParadoxLowerBound.exists_feedback_chain
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_c_lower
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_c_upper
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_c_value
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_c_obj_value
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_c
