import InfLearn.StepSoundness

/-!
# T1 Thm 3.9 (unstructured classes) and the deterministic form of T1 Thm 3.2

Formalisation of two results of `research/theory/T1-soundness-under-search.md` §3 (as
repaired in its *Verification log*), in the deterministic interaction protocol of
`InfLearn.StepSoundness` (verifiers `History → Step → Answer`, adaptive provers
`History → Step`, `run`, the truthful escalation oracle, the version space `VSh`, `DetSound`).

## Cost (T1 Def. 1.3)

* `cost V R π n`: the number of rounds among the first `n` in which a **valid** query
  (`q ∈ R*`) is not accepted outright (it is escalated or rejected). Invalid queries are never
  charged ("one-sided cost").
* `escCount V R π n`: the number of escalations among the first `n` rounds.
* `HonestRun V R π n`: every query of the first `n` rounds is valid; `Honest R π`: the prover
  only ever issues valid queries (`Honest.honestRun`).
* `worstCost V H P0 : ℕ∞`: the supremum of the cost over targets `R* ∈ H` with `P0 ⊆ R*`,
  provers and horizons `n` such that the run is honest; `Esc H P0 : ℕ∞` is the infimum of
  `worstCost` over deterministic 0-sound verifiers (`DetSound (fun R => R)`). This is the
  paper's `Esc(H | P0)` restricted to deterministic verifiers (for 0-sound verifiers the paper
  notes the lower bounds hold almost surely, so the randomized notion is not needed for the
  0-sound statements below).

## T1 Thm 3.2 (escalation dimension = positive elasticity), deterministic form

* `ElasticChain H P0 R l`: the paper's elastic chain in `R`: every `s_i ∈ R` and
  `s_i ∉ ⋂ VS(P0 ∪ {s_1, …, s_{i-1}})`; `elasticChain_iff` gives the witness form
  (`∃ R_i ∈ H, P0 ∪ {s_<i} ⊆ R_i ∌ s_i`). `el H R P0 : ℕ∞` is the supremum of chain lengths.
* **Lower bound** `thm_3_2_lower`: if a prover issues an elastic chain `s_1, …, s_m` in `R`
  in its first `m` rounds (`Issues π l`; it may behave arbitrarily afterwards), then against
  target `R` **every** deterministic 0-sound verifier escalates or rejects each `s_i` (it never
  accepts one); the run is honest and its cost is exactly `m`.
* **Upper bound** `thm_3_2_upper`: against an honest run, the VS verifier's escalated queries
  form an elastic chain in `R*` and its cost is the number of escalations.
* `thm_3_2`: `Esc H P0 = ⨆_{R ∈ H, P0 ⊆ R} el H R P0`, and `vsVerifier_attains`: the VS
  verifier attains it. Arbitrary (possibly infinite) `H`.
  The randomized half ("expected cost `≥ (1 − δ) m` for δ-sound randomized verifiers") is not
  formalised (randomized verifiers are not modelled).

## T1 Thm 3.9 (unstructured classes)

* `vsVerifier_escCount_le` (the KWIK enumeration bound): for a finite class
  `H : Finset (Set (Step J))`, target `R* ∈ H` with `P0 ⊆ R*`, **every** prover (honest or not)
  and every horizon, the VS verifier escalates at most `|{R ∈ H : P0 ⊆ R}| − 1 ≤ |H| − 1`
  times: each escalation removes at least one hypothesis from the version space
  (`vsFin_ssubset_of_esc`) and `R*` is never removed.
* `thm_3_9_upper`: hence its cost is `≤ |H| − 1`, and `= #escalations` on honest runs;
  `thm_3_9_Esc_le`: `Esc H P0 ≤ |{R ∈ H : P0 ⊆ R}| − 1`, in particular `Esc H ≤ |H| − 1`.
* `coSingleton U = {U \ {u} : u ∈ U}` (`card_coSingleton : |coSingleton U| = |U|`).
  `thm_3_9_coSingleton_lower`: for target `R* = U \ {u*}`, **every** duplicate-free
  enumeration of `U \ {u*}` (in any order) issued by a prover forces **every** deterministic
  0-sound verifier to escalate or reject each of these `|U| − 1` valid queries.
  `exists_honest_prover_coSingleton`: such a prover can be chosen fully honest when `|U| ≥ 2`.
* `thm_3_9_coSingleton`: `Esc(coSingleton U) = |U| − 1 = |coSingleton U| − 1`, attained by the
  VS verifier; so the bound `Esc H ≤ |H| − 1` is tight.
* `exists_class_Esc_eq`: for every `N` there is a class of `N` hypotheses with
  `Esc = N − 1` (with `N = 2^L`: "a class of `2^L` hypotheses can need `2^L − 1`
  escalations").

Not formalised: the closing remark of Thm 3.9 about single schemas (that is Thm 3.4).
-/

namespace InfLearn
namespace Unstructured

open StepSoundness

universe u

variable {J : Type u}

/-! ## 1. Cost of a run (T1 Def. 1.3) -/

section Cost

variable {V : Verifier J} {R : Set (Step J)} {π : Prover J} {n : ℕ}

open Classical in
/-- **Cost** of the first `n` rounds (T1 Def. 1.3): the number of rounds in which a valid query
(`q ∈ R*`) is not accepted outright (it is escalated or rejected). -/
noncomputable def cost (V : Verifier J) (R : Set (Step J)) (π : Prover J) (n : ℕ) : ℕ :=
  (run V R π n).countP (fun e => decide (e.query ∈ R ∧ e.answer ≠ Answer.acc))

/-- The number of escalations in the first `n` rounds. -/
noncomputable def escCount (V : Verifier J) (R : Set (Step J)) (π : Prover J) (n : ℕ) : ℕ :=
  (run V R π n).countP (fun e => decide (e.answer = Answer.esc))

/-- The first `n` rounds are honest: every query is valid (`q ∈ R*`). -/
def HonestRun (V : Verifier J) (R : Set (Step J)) (π : Prover J) (n : ℕ) : Prop :=
  ∀ e ∈ run V R π n, e.query ∈ R

/-- An honest prover (T1 Def. 1.3): all its queries are in `R*`. -/
def Honest (R : Set (Step J)) (π : Prover J) : Prop := ∀ h : History J, π h ∈ R

theorem Honest.honestRun (hπ : Honest R π) (n : ℕ) : HonestRun V R π n := by
  intro e he
  obtain ⟨m, -, rfl⟩ := exists_of_mem_run he
  exact hπ _

theorem HonestRun.mono {m : ℕ} (hon : HonestRun V R π n) (hmn : m ≤ n) : HonestRun V R π m :=
  fun e he => hon e ((run_prefix hmn).subset he)

theorem cost_le (V : Verifier J) (R : Set (Step J)) (π : Prover J) (n : ℕ) :
    cost V R π n ≤ n := by
  unfold cost
  exact (List.countP_le_length).trans (length_run (V := V) (R := R) (π := π) n).le

theorem cost_eq_of_forall (h : ∀ e ∈ run V R π n, e.query ∈ R ∧ e.answer ≠ Answer.acc) :
    cost V R π n = n := by
  unfold cost
  rw [List.countP_eq_length.2 (fun e he => by simpa using h e he), length_run]

/-- The oracle label of an event of a run. -/
theorem label_eq_of_mem_run {e : Event J} (he : e ∈ run V R π n) :
    e.label = oracle R e.answer e.query := by
  obtain ⟨m, -, rfl⟩ := exists_of_mem_run he
  rfl

open Classical in
theorem label_of_esc {e : Event J} (he : e ∈ run V R π n) (hesc : e.answer = Answer.esc) :
    e.label = some (decide (e.query ∈ R)) := by
  rw [label_eq_of_mem_run he, hesc]
  simp [oracle]

theorem escCount_succ (n : ℕ) :
    escCount V R π (n + 1) = escCount V R π n +
      if V (run V R π n) (π (run V R π n)) = Answer.esc then 1 else 0 := by
  unfold escCount
  rw [run_succ, List.countP_append, List.countP_singleton]
  simp [respond]

/-- The queries escalated in a history, in order. -/
def escQueries (h : History J) : List (Step J) :=
  (h.filter (fun e => decide (e.answer = Answer.esc))).map Event.query

theorem length_escQueries : (escQueries (run V R π n)).length = escCount V R π n := by
  simp [escQueries, escCount, List.countP_eq_length_filter]

theorem escQueries_append_singleton (h : History J) (e : Event J) :
    escQueries (h ++ [e]) =
      if e.answer = Answer.esc then escQueries h ++ [e.query] else escQueries h := by
  unfold escQueries
  split_ifs with he <;> simp [List.filter_append, he]

end Cost

/-! ## 2. The VS verifier never rejects a valid query -/

section VSValid

variable {H : Set (Set (Step J))} {P0 : Set (Step J)} {R : Set (Step J)} {π : Prover J}
  {n : ℕ}

/-- Against a target `R* ∈ H` with `P0 ⊆ R*`, the VS verifier never rejects a valid query
(`q ∈ R* ⊆ ⋃ VS`). -/
theorem vsVerifier_ne_rej (hR : R ∈ H) (hP0 : P0 ⊆ R) {e : Event J}
    (he : e ∈ run (vsVerifier H P0) R π n) (hq : e.query ∈ R) : e.answer ≠ Answer.rej := by
  obtain ⟨m, -, rfl⟩ := exists_of_mem_run he
  have hRV := target_mem_VSh (V := vsVerifier H P0) (π := π) hR hP0 m
  intro hrej
  simp only [respond] at hrej hq
  rw [vsVerifier_rej_iff ⟨R, hRV⟩] at hrej
  exact hrej ⟨R, hRV, hq⟩

/-- So the VS verifier's cost is at most its number of escalations (against any prover). -/
theorem vsVerifier_cost_le_escCount (hR : R ∈ H) (hP0 : P0 ⊆ R) (π : Prover J) (n : ℕ) :
    cost (vsVerifier H P0) R π n ≤ escCount (vsVerifier H P0) R π n := by
  unfold cost escCount
  apply List.countP_mono_left
  intro e he hp
  simp only [decide_eq_true_eq] at hp ⊢
  have hrej := vsVerifier_ne_rej hR hP0 he hp.1
  cases h : e.answer <;> simp_all

/-- On an honest run the VS verifier's cost is exactly its number of escalations. -/
theorem vsVerifier_cost_eq_escCount (hR : R ∈ H) (hP0 : P0 ⊆ R)
    (hon : HonestRun (vsVerifier H P0) R π n) :
    cost (vsVerifier H P0) R π n = escCount (vsVerifier H P0) R π n := by
  unfold cost escCount
  apply List.countP_congr
  intro e he
  have hq := hon e he
  have hrej := vsVerifier_ne_rej hR hP0 he hq
  simp only [decide_eq_true_eq]
  cases h : e.answer <;> simp_all

end VSValid

/-! ## 3. Elastic chains (T1 §3, "positive elasticity") -/

section Elastic

variable {H : Set (Set (Step J))} {P0 R : Set (Step J)} {l : List (Step J)}

/-- An **elastic chain in `R`** (T1 §3): a sequence `s_1, …, s_m ∈ R` with
`s_i ∉ ⋂ VS(P0 ∪ {s_1, …, s_{i-1}})` for every `i` (the version space of `H` for these
positive data and no negative data). -/
def ElasticChain (H : Set (Set (Step J))) (P0 R : Set (Step J)) (l : List (Step J)) : Prop :=
  ∀ (i : ℕ) (hi : i < l.length), l[i] ∈ R ∧ l[i] ∉ ⋂₀ VS H (P0 ∪ {x | x ∈ l.take i}) ∅

theorem notMem_sInter_VS_iff {P : Set (Step J)} {s : Step J} :
    s ∉ ⋂₀ VS H P ∅ ↔ ∃ R' ∈ H, P ⊆ R' ∧ s ∉ R' := by
  simp only [Set.mem_sInter, not_forall, VS, Set.mem_setOf_eq, Set.mem_empty_iff_false,
    false_imp_iff, implies_true, and_true, exists_prop, and_assoc]

/-- The witness form of elastic chains (T1 §3: "Equivalently, there are `R_i ∈ H` with
`P0 ∪ {s_<i} ⊆ R_i ∌ s_i`"). -/
theorem elasticChain_iff : ElasticChain H P0 R l ↔
    ∀ (i : ℕ) (hi : i < l.length), l[i] ∈ R ∧
      ∃ R' ∈ H, P0 ⊆ R' ∧ (∀ x ∈ l.take i, x ∈ R') ∧ l[i] ∉ R' := by
  unfold ElasticChain
  refine forall_congr' fun i => forall_congr' fun hi => and_congr_right' ?_
  rw [notMem_sInter_VS_iff]
  refine exists_congr fun R' => and_congr_right' ?_
  rw [Set.union_subset_iff, and_assoc]
  rfl

theorem elasticChain_nil : ElasticChain H P0 R [] := fun i hi => absurd hi (by simp)

theorem ElasticChain.mem (hl : ElasticChain H P0 R l) {x : Step J} (hx : x ∈ l) : x ∈ R := by
  obtain ⟨i, hi, rfl⟩ := List.mem_iff_getElem.1 hx
  exact (hl i hi).1

theorem elasticChain_append_singleton {s : Step J} :
    ElasticChain H P0 R (l ++ [s]) ↔
      ElasticChain H P0 R l ∧ s ∈ R ∧ s ∉ ⋂₀ VS H (P0 ∪ {x | x ∈ l}) ∅ := by
  constructor
  · intro h
    refine ⟨fun i hi => ?_, ?_⟩
    · have := h i (by simp; omega)
      rwa [List.getElem_append_left hi, List.take_append_of_le_length hi.le] at this
    · have := h l.length (by simp)
      rwa [List.getElem_concat_length rfl, List.take_append_of_le_length le_rfl,
        List.take_length] at this
  · rintro ⟨hl, hs, hs'⟩ i hi
    simp only [List.length_append, List.length_singleton] at hi
    rcases Nat.lt_succ_iff_lt_or_eq.1 hi with hi | rfl
    · rw [List.getElem_append_left hi, List.take_append_of_le_length hi.le]
      exact hl i hi
    · rw [List.getElem_concat_length rfl, List.take_append_of_le_length le_rfl, List.take_length]
      exact ⟨hs, hs'⟩

/-- The elasticity `el(H, R | P0)`: the supremum of the lengths of elastic chains in `R`. -/
noncomputable def el (H : Set (Set (Step J))) (R P0 : Set (Step J)) : ℕ∞ :=
  ⨆ (l : List (Step J)) (_ : ElasticChain H P0 R l), (l.length : ℕ∞)

/-- `sup_{R ∈ H, R ⊇ P0} el(H, R | P0)`. -/
noncomputable def maxEl (H : Set (Set (Step J))) (P0 : Set (Step J)) : ℕ∞ :=
  ⨆ (R : Set (Step J)) (_ : R ∈ H) (_ : P0 ⊆ R), el H R P0

end Elastic

/-! ## 4. Thm 3.2, lower bound: elastic chains force escalation -/

section Lower

variable {H : Set (Set (Step J))} {P0 R : Set (Step J)} {V : Verifier J} {π : Prover J}
  {l : List (Step J)}

/-- The prover issues the list `l` (in order) in its first `l.length` rounds; afterwards it may
do anything. -/
def Issues (π : Prover J) (l : List (Step J)) : Prop :=
  ∀ (h : History J) (hh : h.length < l.length), π h = l[h.length]

/-- The non-adaptive prover issuing `l`, then the default step `d` forever. -/
def listProver (l : List (Step J)) (d : Step J) : Prover J := fun h => l.getD h.length d

theorem listProver_issues (l : List (Step J)) (d : Step J) : Issues (listProver l d) l := by
  intro h hh
  simp [listProver, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hh]

theorem listProver_honest {d : Step J} (hl : ∀ x ∈ l, x ∈ R) (hd : d ∈ R) :
    Honest R (listProver l d) := by
  intro h
  simp only [listProver, List.getD_eq_getElem?_getD]
  by_cases hh : h.length < l.length
  · rw [List.getElem?_eq_getElem hh]
    exact hl _ (List.getElem_mem hh)
  · rw [List.getElem?_eq_none (by omega)]
    exact hd

theorem Issues.query_eq (hπ : Issues π l) {m : ℕ} (hm : m < l.length) :
    π (run V R π m) = l[m] := by
  have := hπ (run V R π m) (by rw [length_run]; exact hm)
  simpa [length_run] using this

/-- The queries of the first `n ≤ |l|` rounds are `l.take n`. -/
theorem Issues.map_query_run (hπ : Issues π l) :
    ∀ n, n ≤ l.length → (run V R π n).map Event.query = l.take n
  | 0, _ => by simp
  | n + 1, hn => by
    rw [run_succ, List.map_append, hπ.map_query_run n (by omega), List.map_singleton]
    simp only [respond]
    rw [hπ.query_eq (by omega), List.take_concat_get']

/-- Consistency transfers between targets that both contain all queries of the history. -/
theorem consistent_of_queries {R' : Set (Step J)} {h : History J} (hc : Consistent R h)
    (hq : ∀ e ∈ h, e.query ∈ R ∧ e.query ∈ R') : Consistent R' h := by
  intro e he b hb
  have h1 := hc e he b hb
  have h2 := hq e he
  constructor
  · intro _; exact h2.2
  · intro _; exact h1.2 h2.1

/-- **T1 Thm 3.2, lower bound (deterministic, δ = 0).** Let `s_1, …, s_m` be an elastic chain
in `R` and let the prover issue it in its first `m` rounds. Then against target `R`, **every**
deterministic 0-sound verifier fails to accept each `s_i`: every one of these (valid) queries is
escalated or rejected. -/
theorem chain_not_acc (hV : DetSound (fun R => R) V H P0) (hl : ElasticChain H P0 R l)
    (hπ : Issues π l) : ∀ e ∈ run V R π l.length, e.query ∈ R ∧ e.answer ≠ Answer.acc := by
  intro e he
  obtain ⟨m, hm, rfl⟩ := exists_of_mem_run he
  have hq := hπ.query_eq (V := V) (R := R) hm
  obtain ⟨hmR, R', hR'H, hP0', htake, hmR'⟩ := (elasticChain_iff.1 hl) m hm
  simp only [respond]
  rw [hq]
  refine ⟨hmR, ?_⟩
  apply not_acc_of_exists_VSh hV R π m
  refine ⟨R', mem_VSh.2 ⟨hR'H, hP0', ?_⟩, hmR'⟩
  refine consistent_of_queries (run_consistent m) fun e' he' => ?_
  have hqm : e'.query ∈ l.take m := by
    rw [← hπ.map_query_run m hm.le]
    exact List.mem_map_of_mem he'
  exact ⟨hl.mem (List.mem_of_mem_take hqm), htake _ hqm⟩

/-- **T1 Thm 3.2, lower bound, cost form.** For every elastic chain `l` in `R`, every
deterministic 0-sound verifier, and every prover issuing `l` first: the first `|l|` rounds are
honest, each of them is escalated or rejected, and the cost is exactly `|l|`. -/
theorem thm_3_2_lower (hV : DetSound (fun R => R) V H P0) (hl : ElasticChain H P0 R l)
    (hπ : Issues π l) :
    HonestRun V R π l.length ∧
    (∀ e ∈ run V R π l.length, e.answer = Answer.esc ∨ e.answer = Answer.rej) ∧
    cost V R π l.length = l.length := by
  have h := chain_not_acc hV hl hπ
  refine ⟨fun e he => (h e he).1, fun e he => ?_, cost_eq_of_forall h⟩
  have := (h e he).2
  cases hA : e.answer <;> simp_all

end Lower

/-! ## 5. Thm 3.2, upper bound: the VS verifier escalates along an elastic chain -/

section Upper

variable {H : Set (Set (Step J))} {P0 R : Set (Step J)} {π : Prover J} {n : ℕ}

/-- Against an honest run, the queries escalated by the VS verifier form an elastic chain in
the target (T1 Thm 3.2, upper-bound proof). -/
theorem vsVerifier_escQueries_chain (hon : HonestRun (vsVerifier H P0) R π n) :
    ElasticChain H P0 R (escQueries (run (vsVerifier H P0) R π n)) := by
  classical
  induction n with
  | zero => simpa [escQueries] using (elasticChain_nil : ElasticChain H P0 R [])
  | succ n ih =>
    have hon' : HonestRun (vsVerifier H P0) R π n := hon.mono (Nat.le_succ n)
    rw [run_succ, escQueries_append_singleton]
    split_ifs with hesc
    · rw [elasticChain_append_singleton]
      refine ⟨ih hon', hon _ (respond_mem_run_succ n), ?_⟩
      simp only [respond] at hesc ⊢
      obtain ⟨-, hnot⟩ := vsVerifier_esc_iff.1 hesc
      simp only [Set.mem_sInter, not_forall, exists_prop] at hnot
      obtain ⟨R', hR', hq⟩ := hnot
      rw [notMem_sInter_VS_iff]
      obtain ⟨hH, hP0', hc⟩ := mem_VSh.1 hR'
      refine ⟨R', hH, Set.union_subset hP0' ?_, hq⟩
      intro x hx
      simp only [Set.mem_setOf_eq, escQueries, List.mem_map, List.mem_filter,
        decide_eq_true_eq] at hx
      obtain ⟨e, ⟨he, hesc'⟩, rfl⟩ := hx
      have hlab := label_of_esc he hesc'
      have hx := hon' e he
      exact (hc e he true (by rw [hlab]; simp [hx])).1 rfl
    · exact ih hon'

/-- **T1 Thm 3.2, upper bound (deterministic).** Against a target `R* ∈ H` with `P0 ⊆ R*` and
an honest run, the VS verifier's cost equals its number of escalations, and the escalated
queries form an elastic chain in `R*`; so its cost is at most `el(H, R* | P0)`. -/
theorem thm_3_2_upper (hR : R ∈ H) (hP0 : P0 ⊆ R) (hon : HonestRun (vsVerifier H P0) R π n) :
    cost (vsVerifier H P0) R π n = (escQueries (run (vsVerifier H P0) R π n)).length ∧
    ElasticChain H P0 R (escQueries (run (vsVerifier H P0) R π n)) ∧
    (cost (vsVerifier H P0) R π n : ℕ∞) ≤ el H R P0 := by
  have h1 : cost (vsVerifier H P0) R π n = (escQueries (run (vsVerifier H P0) R π n)).length :=
    by rw [vsVerifier_cost_eq_escCount hR hP0 hon, length_escQueries]
  have h2 := vsVerifier_escQueries_chain hon
  refine ⟨h1, h2, ?_⟩
  rw [h1]
  exact le_iSup₂_of_le (f := fun (l : List (Step J)) (_ : ElasticChain H P0 R l) =>
    (l.length : ℕ∞)) _ h2 le_rfl

end Upper

/-! ## 6. `Esc` and Thm 3.2 (escalation dimension = positive elasticity) -/

section Esc

variable {H : Set (Set (Step J))} {P0 : Set (Step J)} {V : Verifier J}

/-- The worst-case cost of a verifier: the supremum over targets `R* ∈ H` with `P0 ⊆ R*`,
provers and horizons `n` with an honest run, of the cost of the first `n` rounds. -/
noncomputable def worstCost (V : Verifier J) (H : Set (Set (Step J))) (P0 : Set (Step J)) :
    ℕ∞ :=
  ⨆ (R : Set (Step J)) (_ : R ∈ H) (_ : P0 ⊆ R) (π : Prover J) (n : ℕ)
    (_ : HonestRun V R π n), (cost V R π n : ℕ∞)

/-- **Escalation cost** `Esc(H | P0)` (T1 Def. 1.3) over deterministic verifiers: the infimum,
over deterministic 0-sound verifiers, of the worst-case cost on honest query sequences. -/
noncomputable def Esc (H : Set (Set (Step J))) (P0 : Set (Step J)) : ℕ∞ :=
  ⨅ (V : Verifier J) (_ : DetSound (fun R => R) V H P0), worstCost V H P0

theorem le_worstCost {R : Set (Step J)} (hR : R ∈ H) (hP0 : P0 ⊆ R) (π : Prover J) (n : ℕ)
    (hon : HonestRun V R π n) : (cost V R π n : ℕ∞) ≤ worstCost V H P0 :=
  le_iSup₂_of_le R hR <| le_iSup_of_le hP0 <| le_iSup₂_of_le π n <| le_iSup_of_le hon le_rfl

theorem worstCost_le_iff {k : ℕ∞} : worstCost V H P0 ≤ k ↔
    ∀ R ∈ H, P0 ⊆ R → ∀ (π : Prover J) (n : ℕ), HonestRun V R π n → (cost V R π n : ℕ∞) ≤ k :=
  by simp only [worstCost, iSup_le_iff]

theorem Esc_le_worstCost (hV : DetSound (fun R => R) V H P0) : Esc H P0 ≤ worstCost V H P0 :=
  iInf₂_le V hV

/-- The VS verifier's worst-case cost is at most `sup_R el(H, R | P0)`. -/
theorem worstCost_vsVerifier_le : worstCost (vsVerifier H P0) H P0 ≤ maxEl H P0 := by
  rw [worstCost_le_iff]
  intro R hR hP0 π n hon
  exact (thm_3_2_upper hR hP0 hon).2.2.trans (le_iSup₂_of_le R hR (le_iSup_of_le hP0 le_rfl))

/-- Every elastic chain in an admissible target gives a lower bound on the worst-case cost of
every deterministic 0-sound verifier. -/
theorem length_le_worstCost (hV : DetSound (fun R => R) V H P0) {R : Set (Step J)} (hR : R ∈ H)
    (hP0 : P0 ⊆ R) {l : List (Step J)} (hl : ElasticChain H P0 R l) :
    (l.length : ℕ∞) ≤ worstCost V H P0 := by
  cases l with
  | nil => simp
  | cons s t =>
    obtain ⟨hon, -, hcost⟩ := thm_3_2_lower hV hl (listProver_issues (s :: t) s)
    rw [← hcost]
    exact le_worstCost hR hP0 _ _ hon

theorem maxEl_le_worstCost (hV : DetSound (fun R => R) V H P0) : maxEl H P0 ≤ worstCost V H P0 :=
  iSup₂_le fun R hR => iSup_le fun hP0 => iSup₂_le fun _ hl => length_le_worstCost hV hR hP0 hl

/-- **T1 Thm 3.2 (escalation dimension = positive elasticity), deterministic verifiers.**
`Esc(H | P0) = sup_{R ∈ H, R ⊇ P0} el(H, R | P0)`. -/
theorem thm_3_2 (H : Set (Set (Step J))) (P0 : Set (Step J)) : Esc H P0 = maxEl H P0 :=
  le_antisymm ((Esc_le_worstCost (thm_3_1_a H P0)).trans worstCost_vsVerifier_le)
    (le_iInf₂ fun _ hV => maxEl_le_worstCost hV)

/-- **T1 Thm 3.2: the VS verifier attains `Esc(H | P0)`.** -/
theorem vsVerifier_attains (H : Set (Set (Step J))) (P0 : Set (Step J)) :
    worstCost (vsVerifier H P0) H P0 = Esc H P0 :=
  le_antisymm (worstCost_vsVerifier_le.trans (thm_3_2 H P0).ge)
    (Esc_le_worstCost (thm_3_1_a H P0))

end Esc

/-! ## 7. Thm 3.9, upper bound: finite classes (the KWIK enumeration bound) -/

section Finite

variable {H : Finset (Set (Step J))} {P0 R : Set (Step J)} {π : Prover J} {n : ℕ}

open Classical in
/-- The hypotheses of `H` compatible with the human data: `{R ∈ H : P0 ⊆ R}`. -/
noncomputable def admissible (H : Finset (Set (Step J))) (P0 : Set (Step J)) :
    Finset (Set (Step J)) :=
  H.filter (fun R => P0 ⊆ R)

theorem mem_admissible : R ∈ admissible H P0 ↔ R ∈ H ∧ P0 ⊆ R := by
  classical
  simp [admissible]

theorem admissible_card_le : (admissible H P0).card ≤ H.card := by
  classical
  unfold admissible
  exact Finset.card_filter_le _ _

theorem admissible_empty : admissible H (∅ : Set (Step J)) = H := by
  ext R
  simp [mem_admissible]

open Classical in
/-- The version space at history `h`, as a finset. -/
noncomputable def vsFin (H : Finset (Set (Step J))) (P0 : Set (Step J)) (h : History J) :
    Finset (Set (Step J)) :=
  H.filter (fun R => R ∈ VSh (↑H) P0 h)

theorem mem_vsFin {h : History J} : R ∈ vsFin H P0 h ↔ R ∈ VSh (↑H) P0 h := by
  classical
  simp only [vsFin, Finset.mem_filter, and_iff_right_iff_imp]
  intro hR
  exact Finset.mem_coe.1 (mem_VSh.1 hR).1

theorem vsFin_nil : vsFin H P0 [] = admissible H P0 := by
  ext R
  rw [mem_vsFin, mem_admissible, mem_VSh, Finset.mem_coe]
  constructor
  · exact fun h => ⟨h.1, h.2.1⟩
  · exact fun h => ⟨h.1, h.2, fun e he => absurd he (by simp)⟩

theorem vsFin_append_subset (h : History J) (e : Event J) :
    vsFin H P0 (h ++ [e]) ⊆ vsFin H P0 h := by
  intro R' hR'
  rw [mem_vsFin, mem_VSh] at hR' ⊢
  exact ⟨hR'.1, hR'.2.1, fun e' he' => hR'.2.2 e' (List.mem_append_left _ he')⟩

/-- Each escalation of the VS verifier removes at least one hypothesis from the version
space (whatever the target and the label). -/
theorem vsFin_ssubset_of_esc (h : History J) (q : Step J)
    (hesc : vsVerifier (↑H) P0 h q = Answer.esc) :
    vsFin H P0 (h ++ [respond (vsVerifier ↑H P0) R h q]) ⊂ vsFin H P0 h := by
  classical
  rw [Finset.ssubset_iff_of_subset (vsFin_append_subset h _)]
  obtain ⟨hU, hI⟩ := vsVerifier_esc_iff.1 hesc
  have hlab : (respond (vsVerifier ↑H P0) R h q).label = some (decide (q ∈ R)) := by
    simp [respond, oracle, hesc]
  have hmem : respond (vsVerifier ↑H P0) R h q ∈ h ++ [respond (vsVerifier ↑H P0) R h q] := by
    simp
  by_cases hqR : q ∈ R
  · -- label `true`: the hypotheses missing `q` are removed
    simp only [Set.mem_sInter, not_forall, exists_prop] at hI
    obtain ⟨R', hR', hq'⟩ := hI
    refine ⟨R', mem_vsFin.2 hR', fun hR'' => hq' ?_⟩
    have hc := (mem_VSh.1 (mem_vsFin.1 hR'')).2.2 _ hmem true (by rw [hlab]; simp [hqR])
    exact hc.1 rfl
  · -- label `false`: the hypotheses containing `q` are removed
    obtain ⟨R', hR', hq'⟩ := hU
    refine ⟨R', mem_vsFin.2 hR', fun hR'' => ?_⟩
    have hc := (mem_VSh.1 (mem_vsFin.1 hR'')).2.2 _ hmem false (by rw [hlab]; simp [hqR])
    exact absurd (hc.2 hq') (by simp)

theorem vsFin_card_add_escCount (R : Set (Step J)) (π : Prover J) (n : ℕ) :
    (vsFin H P0 (run (vsVerifier ↑H P0) R π n)).card + escCount (vsVerifier ↑H P0) R π n ≤
      (admissible H P0).card := by
  induction n with
  | zero => simp [escCount, vsFin_nil]
  | succ n ih =>
    rw [escCount_succ, run_succ]
    split_ifs with hesc
    · have := Finset.card_lt_card (vsFin_ssubset_of_esc (R := R) _ _ hesc)
      omega
    · have := Finset.card_le_card (vsFin_append_subset (H := H) (P0 := P0)
        (run (vsVerifier ↑H P0) R π n)
        (respond (vsVerifier ↑H P0) R (run (vsVerifier ↑H P0) R π n)
          (π (run (vsVerifier ↑H P0) R π n))))
      omega

/-- **T1 Thm 3.9, KWIK enumeration bound.** For a finite class `H`, a target `R* ∈ H` with
`P0 ⊆ R*` and **any** prover (honest or not), the VS verifier escalates at most
`|{R ∈ H : P0 ⊆ R}| − 1` times, at every horizon. -/
theorem vsVerifier_escCount_le (hR : R ∈ H) (hP0 : P0 ⊆ R) (π : Prover J) (n : ℕ) :
    escCount (vsVerifier ↑H P0) R π n ≤ (admissible H P0).card - 1 := by
  have h1 := vsFin_card_add_escCount (H := H) (P0 := P0) R π n
  have h2 : R ∈ vsFin H P0 (run (vsVerifier ↑H P0) R π n) :=
    mem_vsFin.2 (target_mem_VSh (Finset.mem_coe.2 hR) hP0 n)
  have h3 := Finset.card_pos.2 ⟨R, h2⟩
  omega

/-- **T1 Thm 3.9, upper bound.** For a finite class `H`, a target `R* ∈ H` with `P0 ⊆ R*`, and
every prover and horizon: the VS verifier's cost is at most its number of escalations, which is
at most `|{R ∈ H : P0 ⊆ R}| − 1 ≤ |H| − 1`; on honest runs the cost *equals* the number of
escalations. -/
theorem thm_3_9_upper (hR : R ∈ H) (hP0 : P0 ⊆ R) (π : Prover J) (n : ℕ) :
    cost (vsVerifier ↑H P0) R π n ≤ escCount (vsVerifier ↑H P0) R π n ∧
    escCount (vsVerifier ↑H P0) R π n ≤ (admissible H P0).card - 1 ∧
    (admissible H P0).card - 1 ≤ H.card - 1 ∧
    (HonestRun (vsVerifier ↑H P0) R π n →
      cost (vsVerifier ↑H P0) R π n = escCount (vsVerifier ↑H P0) R π n) :=
  ⟨vsVerifier_cost_le_escCount (Finset.mem_coe.2 hR) hP0 π n,
    vsVerifier_escCount_le hR hP0 π n, Nat.sub_le_sub_right admissible_card_le 1,
    vsVerifier_cost_eq_escCount (Finset.mem_coe.2 hR) hP0⟩

/-- Thm 3.9 upper bound, the paper's form (`P0 = ∅`, honest prover): the VS verifier escalates
at most `|H| − 1` times, and this is its cost. -/
theorem thm_3_9_upper_honest (hR : R ∈ H) (hπ : Honest R π) (n : ℕ) :
    cost (vsVerifier ↑H ∅) R π n = escCount (vsVerifier ↑H ∅) R π n ∧
    escCount (vsVerifier ↑H ∅) R π n ≤ H.card - 1 := by
  obtain ⟨-, h2, -, h4⟩ := thm_3_9_upper hR (Set.empty_subset R) π n
  rw [admissible_empty] at h2
  exact ⟨h4 (hπ.honestRun n), h2⟩

/-- **T1 Thm 3.9, `Esc(H | P0) ≤ |{R ∈ H : P0 ⊆ R}| − 1`** (attained by the VS verifier). -/
theorem thm_3_9_Esc_le (H : Finset (Set (Step J))) (P0 : Set (Step J)) :
    worstCost (vsVerifier ↑H P0) ↑H P0 ≤ (((admissible H P0).card - 1 : ℕ) : ℕ∞) ∧
    Esc ↑H P0 ≤ (((admissible H P0).card - 1 : ℕ) : ℕ∞) := by
  have h : worstCost (vsVerifier ↑H P0) ↑H P0 ≤ (((admissible H P0).card - 1 : ℕ) : ℕ∞) := by
    rw [worstCost_le_iff]
    intro R hR hP0 π n _
    exact_mod_cast (vsVerifier_cost_le_escCount hR hP0 π n).trans
      (vsVerifier_escCount_le (Finset.mem_coe.1 hR) hP0 π n)
  exact ⟨h, (Esc_le_worstCost (thm_3_1_a ↑H P0)).trans h⟩

/-- **T1 Thm 3.9: `Esc(H) ≤ |H| − 1`** for finite `H`. -/
theorem thm_3_9_Esc_le_card (H : Finset (Set (Step J))) :
    Esc ↑H (∅ : Set (Step J)) ≤ ((H.card - 1 : ℕ) : ℕ∞) := by
  simpa [admissible_empty] using (thm_3_9_Esc_le H (∅ : Set (Step J))).2

/-- Consequently every elastic chain in an admissible target of a finite class has length
`≤ |{R ∈ H : P0 ⊆ R}| − 1`. -/
theorem elasticChain_length_le (hR : R ∈ H) (hP0 : P0 ⊆ R) {l : List (Step J)}
    (hl : ElasticChain (↑H) P0 R l) : l.length ≤ (admissible H P0).card - 1 := by
  have h1 := length_le_worstCost (thm_3_1_a ↑H P0) (Finset.mem_coe.2 hR) hP0 hl
  have h2 := (thm_3_9_Esc_le H P0).1
  exact_mod_cast h1.trans h2

end Finite

/-! ## 8. Thm 3.9, lower bound: the co-singleton class -/

section CoSingleton

variable {U : Finset (Step J)} {u : Step J} {V : Verifier J} {π : Prover J}
  {l : List (Step J)}

open Classical in
/-- The **co-singleton class** `{U \ {u} : u ∈ U}`. -/
noncomputable def coSingleton (U : Finset (Step J)) : Finset (Set (Step J)) :=
  U.image (fun u => (↑U : Set (Step J)) \ {u})

theorem mem_coSingleton {R : Set (Step J)} :
    R ∈ coSingleton U ↔ ∃ u ∈ U, (↑U : Set (Step J)) \ {u} = R := by
  classical
  simp [coSingleton]

theorem sdiff_mem_coSingleton (hu : u ∈ U) : (↑U : Set (Step J)) \ {u} ∈ coSingleton U :=
  mem_coSingleton.2 ⟨u, hu, rfl⟩

theorem card_coSingleton (U : Finset (Step J)) : (coSingleton U).card = U.card := by
  classical
  unfold coSingleton
  apply Finset.card_image_of_injOn
  intro v hv w hw hvw
  by_contra hne
  have : w ∈ (↑U : Set (Step J)) \ {v} := ⟨hw, fun h => hne (Set.mem_singleton_iff.1 h).symm⟩
  rw [hvw] at this
  exact this.2 rfl

/-- Any duplicate-free list of elements of `U \ {u*}`, in any order, is an elastic chain in the
co-singleton target `U \ {u*}` (with `P0 = ∅`): the witness for `s_i` is `U \ {s_i}`. -/
theorem coSingleton_elasticChain (hnd : l.Nodup) (hl : ∀ x ∈ l, x ∈ U ∧ x ≠ u) :
    ElasticChain (↑(coSingleton U)) ∅ ((↑U : Set (Step J)) \ {u}) l := by
  rw [elasticChain_iff]
  intro i hi
  obtain ⟨hU, hne⟩ := hl _ (List.getElem_mem hi)
  refine ⟨⟨hU, hne⟩, (↑U : Set (Step J)) \ {l[i]}, sdiff_mem_coSingleton hU,
    Set.empty_subset _, ?_, fun h => h.2 rfl⟩
  intro x hx
  obtain ⟨j, hj, rfl⟩ := List.mem_take_iff_getElem.1 hx
  refine ⟨(hl _ (List.getElem_mem _)).1, fun h => ?_⟩
  have := (hnd.getElem_inj_iff).1 (Set.mem_singleton_iff.1 h)
  omega

theorem length_eq_of_enum (hu : u ∈ U) (hnd : l.Nodup) (hl : ∀ x, x ∈ l ↔ x ∈ U ∧ x ≠ u) :
    l.length = U.card - 1 := by
  classical
  rw [← List.toFinset_card_of_nodup hnd, ← Finset.card_erase_of_mem hu]
  congr 1
  ext x
  simp [hl, and_comm]

/-- **T1 Thm 3.9, lower bound (co-singleton class).** Let `|U| = N`, `u* ∈ U` and target
`R* = U \ {u*}` (with `P0 = ∅`). If a prover issues the `N − 1` elements of `U \ {u*}` in any
order (a duplicate-free enumeration `l`), then **every** deterministic 0-sound verifier for
`{U \ {u} : u ∈ U}` escalates or rejects each of these valid queries: the run is honest, every
round is ESC or REJ, and the cost is `N − 1`. -/
theorem thm_3_9_coSingleton_lower (hV : DetSound (fun R => R) V (↑(coSingleton U)) ∅)
    (hu : u ∈ U) (hnd : l.Nodup) (hl : ∀ x, x ∈ l ↔ x ∈ U ∧ x ≠ u) (hπ : Issues π l) :
    l.length = U.card - 1 ∧
    HonestRun V ((↑U : Set (Step J)) \ {u}) π l.length ∧
    (∀ e ∈ run V ((↑U : Set (Step J)) \ {u}) π l.length,
      e.answer = Answer.esc ∨ e.answer = Answer.rej) ∧
    cost V ((↑U : Set (Step J)) \ {u}) π l.length = U.card - 1 := by
  have hc := coSingleton_elasticChain (U := U) (u := u) hnd (fun x hx => (hl x).1 hx)
  obtain ⟨h1, h2, h3⟩ := thm_3_2_lower hV hc hπ
  have hlen := length_eq_of_enum hu hnd hl
  exact ⟨hlen, h1, h2, h3.trans hlen⟩

/-- When `|U| ≥ 2` the prover of `thm_3_9_coSingleton_lower` can be taken **honest** (all its
queries, also after the first `|U| − 1` rounds, lie in `R* = U \ {u*}`); it is non-adaptive. -/
theorem exists_honest_prover_coSingleton (hu : u ∈ U) (hU : 2 ≤ U.card) :
    ∃ (l : List (Step J)) (π : Prover J), l.Nodup ∧ (∀ x, x ∈ l ↔ x ∈ U ∧ x ≠ u) ∧
      Issues π l ∧ Honest ((↑U : Set (Step J)) \ {u}) π := by
  classical
  let l := (U.erase u).toList
  have hl : ∀ x, x ∈ l ↔ x ∈ U ∧ x ≠ u := by
    intro x; simp [l, Finset.mem_toList, and_comm]
  have hlen : l.length = U.card - 1 := by
    simp [l, Finset.length_toList, Finset.card_erase_of_mem hu]
  have h0 : 0 < l.length := by omega
  refine ⟨l, listProver l l[0], Finset.nodup_toList _, hl, listProver_issues _ _, ?_⟩
  refine listProver_honest (fun x hx => ?_) ?_
  · obtain ⟨h1, h2⟩ := (hl x).1 hx
    exact ⟨h1, h2⟩
  · obtain ⟨h1, h2⟩ := (hl _).1 (List.getElem_mem h0)
    exact ⟨h1, h2⟩

/-- **T1 Thm 3.9 (attained).** For the co-singleton class `H = {U \ {u} : u ∈ U}`,
`Esc(H) = |U| − 1 = |H| − 1`, and the VS verifier attains it. -/
theorem thm_3_9_coSingleton (U : Finset (Step J)) :
    Esc (↑(coSingleton U)) (∅ : Set (Step J)) = ((U.card - 1 : ℕ) : ℕ∞) ∧
    worstCost (vsVerifier ↑(coSingleton U) ∅) (↑(coSingleton U)) (∅ : Set (Step J)) =
      ((U.card - 1 : ℕ) : ℕ∞) ∧
    (coSingleton U).card - 1 = U.card - 1 := by
  classical
  have hcard := card_coSingleton U
  have hle : Esc (↑(coSingleton U)) (∅ : Set (Step J)) ≤ ((U.card - 1 : ℕ) : ℕ∞) := by
    have := thm_3_9_Esc_le_card (coSingleton U)
    rwa [hcard] at this
  have hge : ((U.card - 1 : ℕ) : ℕ∞) ≤ Esc (↑(coSingleton U)) (∅ : Set (Step J)) := by
    rcases U.eq_empty_or_nonempty with rfl | ⟨u, hu⟩
    · simp
    · refine le_iInf₂ fun V hV => ?_
      have hnd := Finset.nodup_toList (U.erase u)
      have hl : ∀ x, x ∈ (U.erase u).toList ↔ x ∈ U ∧ x ≠ u := by
        intro x; simp [Finset.mem_toList, and_comm]
      have hc := coSingleton_elasticChain (U := U) (u := u) hnd (fun x hx => (hl x).1 hx)
      have := length_le_worstCost hV (sdiff_mem_coSingleton hu) (Set.empty_subset _) hc
      rwa [length_eq_of_enum hu hnd hl] at this
  have hEsc := le_antisymm hle hge
  refine ⟨hEsc, ?_, by rw [hcard]⟩
  rw [vsVerifier_attains, hEsc]

/-- "A class of `N` hypotheses can need `N − 1` escalations" (with `N = 2^L`: a class of `2^L`
hypotheses described by `L` bits can need `2^L − 1` escalations): for every `N` there is a
class `H` of exactly `N` hypotheses (over steps with judgments in `ℕ`) with `Esc(H) = N − 1`. -/
theorem exists_class_Esc_eq (N : ℕ) :
    ∃ H : Finset (Set (Step ℕ)), H.card = N ∧
      Esc (↑H) (∅ : Set (Step ℕ)) = ((N - 1 : ℕ) : ℕ∞) := by
  let U : Finset (Step ℕ) := (Finset.range N).image (fun i => (⟨∅, i⟩ : Step ℕ))
  have hU : U.card = N := by
    rw [Finset.card_image_of_injective _ (fun i j h => by simpa using h), Finset.card_range]
  refine ⟨coSingleton U, by rw [card_coSingleton, hU], ?_⟩
  rw [(thm_3_9_coSingleton U).1, hU]

end CoSingleton

end Unstructured
end InfLearn

#print axioms InfLearn.Unstructured.chain_not_acc
#print axioms InfLearn.Unstructured.thm_3_2_lower
#print axioms InfLearn.Unstructured.thm_3_2_upper
#print axioms InfLearn.Unstructured.thm_3_2
#print axioms InfLearn.Unstructured.vsVerifier_attains
#print axioms InfLearn.Unstructured.vsVerifier_escCount_le
#print axioms InfLearn.Unstructured.thm_3_9_upper
#print axioms InfLearn.Unstructured.thm_3_9_upper_honest
#print axioms InfLearn.Unstructured.thm_3_9_Esc_le
#print axioms InfLearn.Unstructured.thm_3_9_Esc_le_card
#print axioms InfLearn.Unstructured.elasticChain_length_le
#print axioms InfLearn.Unstructured.thm_3_9_coSingleton_lower
#print axioms InfLearn.Unstructured.exists_honest_prover_coSingleton
#print axioms InfLearn.Unstructured.thm_3_9_coSingleton
#print axioms InfLearn.Unstructured.exists_class_Esc_eq
