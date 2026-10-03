import InfLearn.Steps

/-!
# T2 §2 / T4 §4.2: coherence games — the doctrinal paradox and halving bounds

Formalisation of results of `research/theory/T2-coherence-as-negative-data.md` (§2, as revised
in its *Verification log*, items A2–A4, A6) and of
`research/theory/T4-informal-math-latent-formalization.md` (§4.2).

## Protocol (T2 §2.2, T4 Def. 4.2)
* Hypotheses are indexed by a type `ι` (finite where weights are summed), `H : ι → Set S`
  (step sets over an arbitrary step type `S`; `S = Step J` where derivations matter).
* `Event S`: `(P) pos s`, `(N) neg P` (a detected bag), or `nothing`.
* `update H VS e`: the learner's deletion rule (`pos s` keeps `R ∋ s`; `neg P` keeps `R ⊉ P`).
* `vsRun H VS₀ e t`: the version space after `t` rounds of the environment `e : ℕ → Event S`
  (the environment is an arbitrary sequence, hence may be adaptive/adversarial).
* `LegalFor H tgt e`: the event is consistent with the target (`target_mem_vsRun`: the target
  is then never deleted).
* `majority w H VS = {s | w({R ∈ VS | s ∈ R}) > ½ w(VS)}`, `accepted H C = ⋂_{R ∈ C} R`.

## 1. T2 Theorem 2.4 (doctrinal paradox for verifier ensembles)
`T 0 = {p,q}`, `T 1 = {p,¬q}`, `T 2 = {¬p,q}`; `hyp i = Cn_CPC(Tᵢ)` as a set of sequents:
`(Π, c) ∈ hyp i ↔ c ∈ C₂(Tᵢ ∪ Π)` (`Sound_hyp`: it is cut-closed). With the uniform prior
`uniform3` and designated context `∅`:
* `thm_2_4`: every `hᵢ` is coherent (`Tᵢ` satisfiable, `⊥ ∉ Cl_{hᵢ}(∅)`); the five-step
  argument π (`piSteps = {⊢p, ⊢q, p,q⊢p∧q, ⊢¬(p∧q), p∧q,¬(p∧q)⊢⊥}`) derives `⊥` from `∅`;
  every step is accepted by majority aggregation (so the majority reasoner derives `⊥`); yet
  `Steps(π) ⊄ hᵢ` for every `i`, so the detection deletes nothing.
* `mem_majority_three`: with VS = 𝓗, majority = "accepted by at least two of the three".
* `thm_2_4_memberships`: the fifteen membership facts of the proof.
* `thm_2_4_environment`, `thm_2_4_constant_environment`: the claim — for every target, any
  environment that only exhibits π, presents positive data valid in all hᵢ (e.g. `tautStep`
  `⊢ p ∨ ¬p`) or stays silent, is legal for the target, never deletes a hypothesis, and π is
  available (accepted by the current majority) in every round.
* `thm_2_4_caveat`: the caveat — presenting `⊢p` deletes `h₃`; majority over `{h₁,h₂}` is
  the oligarchic `h₁ ∩ h₂`, and π is no longer available.

## 2. The abstract halving / weight bound
* `weight_le_pow_mul`: `W` non-increasing, `W(t+1) ≤ c·W(t)` at detections ⇒
  `W n ≤ c^k · W 0` (`k` = detections before `n`).
* `halving_bound`: `W(t+1) ≤ W(t)/2` at detections and `w* ≤ W t` ⇒ `2^k · w* ≤ W 0`;
  `halving_bound_log`: `k · log 2 ≤ log (W 0 / w*)` (i.e. `k ≤ log₂(W₀/w*)`);
  `halving_bound_total`: the set of all detection rounds is finite, with the same bound.

## 3. Oligarchic halving (T2 Lemma 2.1, Theorem 2.2, Proposition 2.3)
* `negative_bag` (Lemma 2.1): a derivation of `⊥` from `A` with steps `P`, and a hypothesis
  coherent on `A`, give `P ⊄ R`; `refuted_of_superset`: every `R ⊇ P` derives `⊥` from `A`.
* `oligarchic_halving`: finite weighted `VS`, coalition `C ⊆ VS` with `w(C) ≥ ½ w(VS)`,
  bag `P ⊆ ⋂ C`: the deletion removes every coalition member, keeps every `R ∈ VS` with
  `P ⊄ R` (`oligarchic_target_survives`: a clean target survives), and the survivors weigh
  `≤ w(VS) - w(C) ≤ ½ w(VS)`.
* `OHRun`, `thm_2_2` ((i) target never deleted, (ii) `2^D · w(R*) ≤ w(𝓗)`, log form, total
  finiteness), `thm_2_2_iii_iv` (`Cl_{⋂C}(B) ⊆ Cl_R(B)` for `R ∈ C`),
  `thm_2_2_of_derivations` (legality of (N)-rounds derived from Lemma 2.1 for genuine
  `⊥`-derivations from designated, target-coherent contexts), `thm_2_2_uniform`
  (`2^D ≤ |𝓗|`).
* `prop_2_3`: per-round halving against every legal detection ⇔ `R̂ ⊆ ⋂ C` for a coalition
  of weight `≥ ½` (finite version space).

## 4. T4 Theorem 4.3(a) (object game, weighted halving)
`majority_pos_halving`, `majority_obj_halving` (per-round), `ObjLegal`, `thm_4_3_a`
(`2^M · w(h*) ≤ w(𝓗)`, log form, finiteness), `thm_4_3_a_uniform` (`2^M ≤ |𝓗|`).

## 5. T4 Theorem 4.5 (bags of size ≤ r, super-majority learner)
`supermajority`, `sum_not_subset_le` (union bound), `supermajority_bag`, `BagLegal`,
`thm_4_5` (`(1+1/r)^M · w(h*) ≤ w(𝓗)`, `M·ln(1+1/r) ≤ ln(w(𝓗)/w(h*))`), `thm_4_5_uniform`
(`M ≤ ln|𝓗| / ln(1+1/r) ≤ (r+1) ln|𝓗|`).

## 6. T2 Theorem 2.5 (robust version, multiplicative penalties)
`penalize`, `wRun`, `falseAlarms`, `RobustOHRun`, `thm_2_5`:
`β^m · w₀(R*) ≤ ((1+β)/2)^D · W₀`, and for `β > 0`,
`D·ln(2/(1+β)) ≤ ln(W₀/w₀(R*)) + m·ln(1/β)`.

## Scope (what is *not* formalised)
* Hypothesis classes are **finite** (`Fintype ι`) where the paper allows countable classes with a
  prior; weights are arbitrary non-negative reals (not necessarily normalised), and bounds are
  stated as `2^k · w(R*) ≤ w(𝓗)`, which is the paper's `k ≤ log₂(1/w(R*))` when `w(𝓗) = 1`.
  Prop 2.3 is proved for finite version spaces only (the paper's σ-additivity argument for
  countable `VS` is not formalised).
* T4 Thm 4.3(b),(c) (comparison with the bag game, Littlestone dimension) are not formalised,
  nor the refinement "hypotheses with the same step relation merge, weights add".
-/

namespace InfLearn
namespace CoherenceGames

open Formula

universe u v

/-! ## 0. Generic online-protocol machinery -/

section Protocol

variable {ι : Type u} {S : Type v}

/-- Feedback events of T2 §2.2's online protocol. -/
inductive Event (S : Type v) : Type v
  /-- (P) a positive datum `s`. -/
  | pos (s : S)
  /-- (N) a detected incoherence (negative bag) with step set `P`. -/
  | neg (P : Set S)
  /-- no feedback. -/
  | nothing

namespace Event

/-- Is the event a detection (an (N)-round)? -/
def isNeg : Event S → Bool
  | neg _ => true
  | _ => false

/-- Is the event a feedback item (a *correction*, in T4's terminology)? -/
def isFeedback : Event S → Bool
  | nothing => false
  | _ => true

end Event

open scoped Classical in
/-- The learner's deletion rule. -/
noncomputable def update (H : ι → Set S) (VS : Finset ι) : Event S → Finset ι
  | .pos s => VS.filter (fun i => s ∈ H i)
  | .neg P => VS.filter (fun i => ¬ P ⊆ H i)
  | .nothing => VS

theorem mem_update_pos {H : ι → Set S} {VS : Finset ι} {s : S} {i : ι} :
    i ∈ update H VS (.pos s) ↔ i ∈ VS ∧ s ∈ H i := by
  simp [update]

theorem mem_update_neg {H : ι → Set S} {VS : Finset ι} {P : Set S} {i : ι} :
    i ∈ update H VS (.neg P) ↔ i ∈ VS ∧ ¬ P ⊆ H i := by
  simp [update]

@[simp] theorem update_nothing (H : ι → Set S) (VS : Finset ι) :
    update H VS .nothing = VS := rfl

end Protocol

section Protocol2

variable {ι : Type u} {S : Type v}

theorem update_subset (H : ι → Set S) (VS : Finset ι) (e : Event S) : update H VS e ⊆ VS := by
  cases e with
  | pos s => intro i hi; exact (mem_update_pos.1 hi).1
  | neg P => intro i hi; exact (mem_update_neg.1 hi).1
  | nothing => exact subset_rfl

/-- The version space after `t` rounds of the environment `e`, starting from `VS₀`. -/
noncomputable def vsRun (H : ι → Set S) (VS₀ : Finset ι) (e : ℕ → Event S) : ℕ → Finset ι
  | 0 => VS₀
  | t + 1 => update H (vsRun H VS₀ e t) (e t)

@[simp] theorem vsRun_zero (H : ι → Set S) (VS₀ : Finset ι) (e : ℕ → Event S) :
    vsRun H VS₀ e 0 = VS₀ := rfl

@[simp] theorem vsRun_succ (H : ι → Set S) (VS₀ : Finset ι) (e : ℕ → Event S) (t : ℕ) :
    vsRun H VS₀ e (t + 1) = update H (vsRun H VS₀ e t) (e t) := rfl

theorem vsRun_succ_subset (H : ι → Set S) (VS₀ : Finset ι) (e : ℕ → Event S) (t : ℕ) :
    vsRun H VS₀ e (t + 1) ⊆ vsRun H VS₀ e t := update_subset _ _ _

/-- An event is *legal for the target* `tgt` if a positive datum is valid in the target and a
detected bag is not contained in the target (Lemma 2.1 guarantees the latter for genuine
incoherences from target-coherent designated contexts; see `negative_bag`). -/
def LegalFor (H : ι → Set S) (tgt : ι) : Event S → Prop
  | .pos s => s ∈ H tgt
  | .neg P => ¬ P ⊆ H tgt
  | .nothing => True

/-- The target survives every legal deletion. -/
theorem mem_update_of_legal {H : ι → Set S} {VS : Finset ι} {tgt : ι} {e : Event S}
    (h : tgt ∈ VS) (he : LegalFor H tgt e) : tgt ∈ update H VS e := by
  cases e with
  | pos s => exact mem_update_pos.2 ⟨h, he⟩
  | neg P => exact mem_update_neg.2 ⟨h, he⟩
  | nothing => exact h

/-- **T2 Thm 2.2(i) (generic form).** If every event is legal for the target, the target is
never deleted. -/
theorem target_mem_vsRun {H : ι → Set S} {VS₀ : Finset ι} {e : ℕ → Event S} {tgt : ι}
    (h0 : tgt ∈ VS₀) (he : ∀ t, LegalFor H tgt (e t)) : ∀ t, tgt ∈ vsRun H VS₀ e t
  | 0 => h0
  | t + 1 => mem_update_of_legal (target_mem_vsRun h0 he t) (he t)

open scoped Classical in
/-- Weighted majority aggregation over a version space `VS` (T2 Thm 2.4, T4 Thm 4.3(a)):
`R̂ = {s | w({R ∈ VS | s ∈ R}) > ½ w(VS)}`. -/
noncomputable def majority (w : ι → ℝ) (H : ι → Set S) (VS : Finset ι) : Set S :=
  {s | (∑ i ∈ VS, w i) / 2 < ∑ i ∈ VS.filter (fun i => s ∈ H i), w i}

/-- The accepted set of a coalition `C`: the steps on which the whole coalition agrees,
`⋂_{R ∈ C} R`. -/
def accepted (H : ι → Set S) (C : Finset ι) : Set S := {s | ∀ i ∈ C, s ∈ H i}

theorem accepted_subset {H : ι → Set S} {C : Finset ι} {i : ι} (hi : i ∈ C) :
    accepted H C ⊆ H i := fun _ hs => hs i hi

end Protocol2

/-! ## 1. The doctrinal paradox (T2 Theorem 2.4) -/

section Doctrinal

/-- The atom `p`. -/
abbrev p : Formula := var 0
/-- The atom `q`. -/
abbrev q : Formula := var 1

/-- The three theories `T₁ = {p, q}`, `T₂ = {p, ¬q}`, `T₃ = {¬p, q}` (indexed `0, 1, 2`). -/
def T : Fin 3 → Set Formula
  | 0 => {p, q}
  | 1 => {p, neg q}
  | 2 => {neg p, q}

/-- The hypothesis `hᵢ = Cn_CPC(Tᵢ)`, read as a set of sequents (steps): the step `(Π, c)` is
accepted by `hᵢ` iff `c ∈ C₂(Tᵢ ∪ Π)`. -/
def hyp (i : Fin 3) : Set (Step Formula) := {s | s.concl ∈ Cn2 (T i ∪ ↑s.prem)}

theorem mem_hyp {i : Fin 3} {s : Step Formula} :
    s ∈ hyp i ↔ SemCons (T i ∪ ↑s.prem) s.concl := Iff.rfl

/-- `⊢ p`. -/
def s₁ : Step Formula := ⟨∅, p⟩
/-- `⊢ q`. -/
def s₂ : Step Formula := ⟨∅, q⟩
/-- `p, q ⊢ p ∧ q`. -/
def s₃ : Step Formula := ⟨{p, q}, Formula.and p q⟩
/-- `⊢ ¬(p ∧ q)`. -/
def s₄ : Step Formula := ⟨∅, neg (Formula.and p q)⟩
/-- `p ∧ q, ¬(p ∧ q) ⊢ ⊥`. -/
def s₅ : Step Formula := ⟨{Formula.and p q, neg (Formula.and p q)}, bot⟩

/-- `Steps(π)` for the five-step argument π. -/
def piSteps : Finset (Step Formula) := {s₁, s₂, s₃, s₄, s₅}

/-- A countermodel refutes membership of a step in `hᵢ`. -/
theorem not_mem_hyp_of {i : Fin 3} {s : Step Formula} (v : Valuation)
    (hv : Satisfies v (T i ∪ ↑s.prem)) (hc : s.concl.eval v = false) : s ∉ hyp i :=
  fun h => by
    have h' : s.concl.eval v = true := h v hv
    rw [hc] at h'
    exact Bool.false_ne_true h'

/-- The unique (on `p`, `q`) models of `T₁`, `T₂`, `T₃`. -/
def model : Fin 3 → Valuation
  | 0 => fun _ => true
  | 1 => fun n => decide (n = 0)
  | 2 => fun n => decide (n = 1)

theorem model_satisfies (i : Fin 3) : Satisfies (model i) (T i) := by
  fin_cases i <;> simp [T, model]

/-- Every `Tᵢ` is satisfiable, i.e. every `hᵢ` is coherent (`Cn2_consistent_iff`). -/
theorem T_satisfiable (i : Fin 3) : Satisfiable (T i) := ⟨model i, model_satisfies i⟩

theorem s₁_mem_hyp0 : s₁ ∈ hyp 0 := by intro v hv; simp_all [T, s₁]
theorem s₁_mem_hyp1 : s₁ ∈ hyp 1 := by intro v hv; simp_all [T, s₁]
theorem s₁_not_mem_hyp2 : s₁ ∉ hyp 2 :=
  not_mem_hyp_of (model 2) (by simp [T, s₁, model]) (by simp [s₁, model])
theorem s₂_mem_hyp0 : s₂ ∈ hyp 0 := by intro v hv; simp_all [T, s₂]
theorem s₂_not_mem_hyp1 : s₂ ∉ hyp 1 :=
  not_mem_hyp_of (model 1) (by simp [T, s₂, model]) (by simp [s₂, model])
theorem s₂_mem_hyp2 : s₂ ∈ hyp 2 := by intro v hv; simp_all [T, s₂]
theorem s₃_mem_hyp (i : Fin 3) : s₃ ∈ hyp i := by
  intro v hv; fin_cases i <;> simp_all [T, s₃]
theorem s₄_not_mem_hyp0 : s₄ ∉ hyp 0 :=
  not_mem_hyp_of (model 0) (by simp [T, s₄, model]) (by simp [s₄, model])
theorem s₄_mem_hyp1 : s₄ ∈ hyp 1 := by intro v hv; simp_all [T, s₄]
theorem s₄_mem_hyp2 : s₄ ∈ hyp 2 := by intro v hv; simp_all [T, s₄]
theorem s₅_mem_hyp (i : Fin 3) : s₅ ∈ hyp i := by
  intro v hv
  fin_cases i <;> simp [T, s₅] at hv <;> rcases hv with ⟨⟨h0, h1⟩, h2 | h2, -⟩ <;> simp_all

/-- `hᵢ`, read as a step set, only derives what `Tᵢ` classically entails:
`Cl_{hᵢ}(B) ⊆ C₂(Tᵢ ∪ B)`. -/
theorem Cl_hyp_subset (i : Fin 3) (B : Set Formula) : Cl (hyp i) B ⊆ Cn2 (T i ∪ B) := by
  refine Cl_subset (fun φ hφ => Cn2.subset_apply _ (Or.inr hφ)) ?_
  intro s hs hprem
  refine Cn2.mem_trans ?_ hs
  rintro φ (hφ | hφ)
  · exact Cn2.subset_apply _ (Or.inl hφ)
  · exact hprem hφ

/-- `hᵢ = Cn_CPC(Tᵢ)` is a consequence relation: it is closed under chaining (`Der(hᵢ) = hᵢ`). -/
theorem Sound_hyp (i : Fin 3) : Sound (hyp i) = hyp i := by
  exact Set.Subset.antisymm (fun s hs => Cl_hyp_subset i _ hs) subset_Sound

/-- **Every `hᵢ` is coherent** (on the designated context `∅`): `Tᵢ` is satisfiable,
`∅ ⊬_{hᵢ} ⊥`, and no chain of `hᵢ`-steps derives `⊥` from `∅`. -/
theorem hyp_coherent (i : Fin 3) :
    Satisfiable (T i) ∧ (⟨∅, bot⟩ : Step Formula) ∉ hyp i ∧ bot ∉ Cl (hyp i) ∅ := by
  have hcons : Consistent Cn2 (T i) := Cn2_consistent_iff.2 (T_satisfiable i)
  refine ⟨T_satisfiable i, fun h => hcons ?_, fun h => hcons ?_⟩
  · have h' : bot ∈ Cn2 (T i ∪ ↑(∅ : Finset Formula)) := h
    simpa using h'
  · simpa using Cl_hyp_subset i ∅ h

/-- **π derives `⊥` from the empty context**:
`⊢p, ⊢q, p,q ⊢ p∧q, ⊢¬(p∧q), p∧q,¬(p∧q) ⊢ ⊥`. -/
theorem bot_mem_Cl_piSteps : bot ∈ Cl (↑piSteps : Set (Step Formula)) ∅ := by
  have h1 : s₁.concl ∈ Cl (↑piSteps : Set (Step Formula)) ∅ :=
    concl_mem_Cl (by simp [piSteps]) (by simp [s₁])
  have h2 : s₂.concl ∈ Cl (↑piSteps : Set (Step Formula)) ∅ :=
    concl_mem_Cl (by simp [piSteps]) (by simp [s₂])
  have h3 : s₃.concl ∈ Cl (↑piSteps : Set (Step Formula)) ∅ := by
    refine concl_mem_Cl (by simp [piSteps]) ?_
    intro φ hφ
    simp only [s₃, Finset.coe_insert, Finset.coe_singleton, Set.mem_insert_iff,
      Set.mem_singleton_iff] at hφ
    rcases hφ with rfl | rfl
    exacts [h1, h2]
  have h4 : s₄.concl ∈ Cl (↑piSteps : Set (Step Formula)) ∅ :=
    concl_mem_Cl (by simp [piSteps]) (by simp [s₄])
  have h5 : s₅.concl ∈ Cl (↑piSteps : Set (Step Formula)) ∅ := by
    refine concl_mem_Cl (by simp [piSteps]) ?_
    intro φ hφ
    simp only [s₅, Finset.coe_insert, Finset.coe_singleton, Set.mem_insert_iff,
      Set.mem_singleton_iff] at hφ
    rcases hφ with rfl | rfl
    exacts [h3, h4]
  exact h5

/-- The uniform prior on `{h₁, h₂, h₃}`. -/
noncomputable def uniform3 : Fin 3 → ℝ := fun _ => 1 / 3

/-- With the uniform prior and `VS = 𝓗`, majority aggregation accepts exactly the steps
accepted by at least two of the three hypotheses. -/
theorem mem_majority_three {S : Type v} (H : Fin 3 → Set S) (s : S) :
    s ∈ majority uniform3 H Finset.univ ↔
      (s ∈ H 0 ∧ s ∈ H 1) ∨ (s ∈ H 0 ∧ s ∈ H 2) ∨ (s ∈ H 1 ∧ s ∈ H 2) := by
  simp only [majority, uniform3, Set.mem_setOf_eq, Finset.sum_filter, Fin.sum_univ_three]
  by_cases h0 : s ∈ H 0 <;> by_cases h1 : s ∈ H 1 <;> by_cases h2 : s ∈ H 2 <;>
    simp [h0, h1, h2] <;> norm_num

/-- **Every step of π is accepted by a majority** (two of three) of the hᵢ. -/
theorem piSteps_subset_majority :
    (↑piSteps : Set (Step Formula)) ⊆ majority uniform3 hyp Finset.univ := by
  intro s hs
  simp only [piSteps, Finset.coe_insert, Finset.coe_singleton, Set.mem_insert_iff,
    Set.mem_singleton_iff] at hs
  rw [mem_majority_three]
  rcases hs with rfl | rfl | rfl | rfl | rfl
  · exact Or.inl ⟨s₁_mem_hyp0, s₁_mem_hyp1⟩
  · exact Or.inr (Or.inl ⟨s₂_mem_hyp0, s₂_mem_hyp2⟩)
  · exact Or.inl ⟨s₃_mem_hyp 0, s₃_mem_hyp 1⟩
  · exact Or.inr (Or.inr ⟨s₄_mem_hyp1, s₄_mem_hyp2⟩)
  · exact Or.inl ⟨s₅_mem_hyp 0, s₅_mem_hyp 1⟩

/-- **π refutes none of the hᵢ**: `h₁` lacks `⊢¬(p∧q)`, `h₂` lacks `⊢q`, `h₃` lacks `⊢p`. -/
theorem piSteps_not_subset_hyp (i : Fin 3) : ¬ (↑piSteps : Set (Step Formula)) ⊆ hyp i := by
  intro h
  have mem : ∀ s ∈ piSteps, s ∈ hyp i := fun s hs => h hs
  fin_cases i
  · exact s₄_not_mem_hyp0 (mem s₄ (by simp [piSteps]))
  · exact s₂_not_mem_hyp1 (mem s₂ (by simp [piSteps]))
  · exact s₁_not_mem_hyp2 (mem s₁ (by simp [piSteps]))

/-- The detection by π deletes nothing. -/
theorem update_piSteps (VS : Finset (Fin 3)) : update hyp VS (.neg ↑piSteps) = VS := by
  ext i
  simp only [mem_update_neg, and_iff_left_iff_imp]
  exact fun _ => piSteps_not_subset_hyp i

/-- **T2 Theorem 2.4 (doctrinal paradox for verifier ensembles).**
With `hᵢ = Cn_CPC(Tᵢ)`, `T₁ = {p,q}`, `T₂ = {p,¬q}`, `T₃ = {¬p,q}`, uniform prior, and the
designated context `∅`:
1. every `hᵢ` is coherent;
2. the five-step argument π derives `⊥` from `∅`;
3. every step of π is accepted by (uniform-weight) majority aggregation over `𝓗`, so the
   majority-chained reasoner is incoherent;
4. yet `Steps(π) ⊄ hᵢ` for every `i`: π refutes none of the hᵢ, and the deletion set of the
   detection is empty. -/
theorem thm_2_4 :
    (∀ i, Satisfiable (T i) ∧ bot ∉ Cl (hyp i) ∅) ∧
    bot ∈ Cl (↑piSteps : Set (Step Formula)) ∅ ∧
    (↑piSteps : Set (Step Formula)) ⊆ majority uniform3 hyp Finset.univ ∧
    bot ∈ Cl (majority uniform3 hyp Finset.univ) ∅ ∧
    (∀ i, ¬ (↑piSteps : Set (Step Formula)) ⊆ hyp i) ∧
    update hyp Finset.univ (.neg ↑piSteps) = Finset.univ :=
  ⟨fun i => ⟨(hyp_coherent i).1, (hyp_coherent i).2.2⟩, bot_mem_Cl_piSteps,
    piSteps_subset_majority, Cl_mono_rules piSteps_subset_majority bot_mem_Cl_piSteps,
    piSteps_not_subset_hyp, update_piSteps _⟩

/-- The individual memberships behind Thm 2.4 (`⊢p ∈ h₁,h₂`; `⊢q ∈ h₁,h₃`;
`⊢¬(p∧q) ∈ h₂,h₃`; the two rule steps in all three; and the three missing steps). -/
theorem thm_2_4_memberships :
    (s₁ ∈ hyp 0 ∧ s₁ ∈ hyp 1 ∧ s₁ ∉ hyp 2) ∧
    (s₂ ∈ hyp 0 ∧ s₂ ∉ hyp 1 ∧ s₂ ∈ hyp 2) ∧
    (∀ i, s₃ ∈ hyp i) ∧
    (s₄ ∉ hyp 0 ∧ s₄ ∈ hyp 1 ∧ s₄ ∈ hyp 2) ∧
    (∀ i, s₅ ∈ hyp i) :=
  ⟨⟨s₁_mem_hyp0, s₁_mem_hyp1, s₁_not_mem_hyp2⟩, ⟨s₂_mem_hyp0, s₂_not_mem_hyp1, s₂_mem_hyp2⟩,
    s₃_mem_hyp, ⟨s₄_not_mem_hyp0, s₄_mem_hyp1, s₄_mem_hyp2⟩, s₅_mem_hyp⟩

/-- An uninformative (tautological) positive datum `⊢ p ∨ ¬p`. -/
def tautStep : Step Formula := ⟨∅, Formula.or p (neg p)⟩

theorem tautStep_mem_hyp (i : Fin 3) : tautStep ∈ hyp i := by
  intro v _
  cases h : v 0 <;> simp [tautStep, h]

/-- **T2 Theorem 2.4, the claim (environment form).** Fix any target `hᵢ`. Consider any
environment that, in every round, either exhibits the detected incoherence π, or presents a
positive datum valid in every hᵢ (e.g. `tautStep`), or stays silent. Then in every round the
version space is all of `𝓗`, so majority aggregation never changes; each event is legal for
the target (π is a genuine incoherence `Steps(π) ⊄ h_tgt`, positive data are valid); and π is
available in every round (its steps are accepted by the current majority). -/
theorem thm_2_4_environment (tgt : Fin 3) (e : ℕ → Event (Step Formula))
    (he : ∀ t, e t = .neg ↑piSteps ∨ e t = .nothing ∨ ∃ s, e t = .pos s ∧ ∀ i, s ∈ hyp i)
    (t : ℕ) :
    vsRun hyp Finset.univ e t = Finset.univ ∧ LegalFor hyp tgt (e t) ∧
      (↑piSteps : Set (Step Formula)) ⊆ majority uniform3 hyp (vsRun hyp Finset.univ e t) := by
  have hVS : ∀ t, vsRun hyp Finset.univ e t = Finset.univ := by
    intro t
    induction t with
    | zero => rfl
    | succ t ih =>
      rw [vsRun_succ, ih]
      rcases he t with h | h | ⟨s, h, hs⟩
      · rw [h, update_piSteps]
      · rw [h, update_nothing]
      · rw [h]
        ext i
        simp [mem_update_pos, hs i]
  refine ⟨hVS t, ?_, by rw [hVS t]; exact piSteps_subset_majority⟩
  rcases he t with h | h | ⟨s, h, hs⟩
  · rw [h]; exact piSteps_not_subset_hyp tgt
  · rw [h]; trivial
  · rw [h]; exact hs tgt

/-- Such environments exist: e.g. the prover exhibits π in every round. Every round is then
a (legal) detection, and no hypothesis is ever deleted. -/
theorem thm_2_4_constant_environment (tgt : Fin 3) (t : ℕ) :
    vsRun hyp Finset.univ (fun _ => .neg ↑piSteps) t = Finset.univ ∧
      LegalFor hyp tgt (Event.neg (↑piSteps : Set (Step Formula))) :=
  let h := thm_2_4_environment tgt (fun _ => .neg ↑piSteps) (fun _ => Or.inl rfl) t
  ⟨h.1, h.2.1⟩

/-- **T2 Theorem 2.4, caveat.** A discriminating positive datum breaks the paradox: if the
target is `h₁` and `⊢p` is presented, `h₃` is deleted, majority over `{h₁, h₂}` is the
(oligarchic) intersection `h₁ ∩ h₂`, and π is no longer available (`⊢q ∉ h₂`). -/
theorem thm_2_4_caveat :
    update hyp Finset.univ (.pos s₁) = {0, 1} ∧
    majority uniform3 hyp {0, 1} = hyp 0 ∩ hyp 1 ∧
    s₂ ∉ majority uniform3 hyp {0, 1} ∧
    ¬ (↑piSteps : Set (Step Formula)) ⊆ majority uniform3 hyp {0, 1} := by
  have hU : update hyp Finset.univ (.pos s₁) = {0, 1} := by
    ext i
    fin_cases i <;> simp [mem_update_pos, s₁_mem_hyp0, s₁_mem_hyp1, s₁_not_mem_hyp2]
  have hM : majority uniform3 hyp {0, 1} = hyp 0 ∩ hyp 1 := by
    ext s
    simp only [majority, uniform3, Set.mem_setOf_eq, Finset.sum_filter, Set.mem_inter_iff]
    rw [Finset.sum_pair (by decide), Finset.sum_pair (by decide)]
    by_cases h0 : s ∈ hyp 0 <;> by_cases h1 : s ∈ hyp 1 <;> simp [h0, h1]
  have h2 : s₂ ∉ majority uniform3 hyp {0, 1} := by
    rw [hM]; exact fun h => s₂_not_mem_hyp1 h.2
  exact ⟨hU, hM, h2, fun h => h2 (h (by simp [piSteps]))⟩

end Doctrinal

/-! ## 2. The abstract halving / weight bound -/

section Halving

theorem card_filter_range_succ (D : ℕ → Prop) [DecidablePred D] (n : ℕ) :
    ((Finset.range (n + 1)).filter D).card =
      ((Finset.range n).filter D).card + if D n then 1 else 0 := by
  rw [Finset.range_add_one, Finset.filter_insert]
  split_ifs with h
  · rw [Finset.card_insert_of_notMem]
    simp
  · simp

/-- **Multiplicative weight bound.** If `W` is non-increasing and drops by a factor `c ≥ 0`
at every "detection" round (`D t`), then after `n` rounds `W n ≤ c ^ k · W 0`, where
`k = #{t < n | D t}`. -/
theorem weight_le_pow_mul {W : ℕ → ℝ} {D : ℕ → Prop} [DecidablePred D] {c : ℝ} (hc : 0 ≤ c)
    (hmono : ∀ t, W (t + 1) ≤ W t) (hdet : ∀ t, D t → W (t + 1) ≤ c * W t) :
    ∀ n, W n ≤ c ^ ((Finset.range n).filter D).card * W 0
  | 0 => by simp
  | n + 1 => by
    have ih := weight_le_pow_mul hc hmono hdet n
    rw [card_filter_range_succ]
    by_cases h : D n
    · rw [if_pos h, pow_succ]
      calc W (n + 1) ≤ c * W n := hdet n h
        _ ≤ c * (c ^ ((Finset.range n).filter D).card * W 0) :=
          mul_le_mul_of_nonneg_left ih hc
        _ = c ^ ((Finset.range n).filter D).card * c * W 0 := by ring
    · rw [if_neg h, add_zero]
      exact (hmono n).trans ih

/-- **Abstract halving bound (core of T2 Thm 2.2(ii) and T4 Thm 4.3(a)).**
Let `W 0 ≥ W 1 ≥ ⋯` with `W (t+1) ≤ W t / 2` at every detection round and `w* ≤ W t`
throughout. Then the number `k` of detections among the first `n` rounds satisfies
`2 ^ k · w* ≤ W 0`. -/
theorem halving_bound {W : ℕ → ℝ} {D : ℕ → Prop} [DecidablePred D] {wstar : ℝ}
    (hmono : ∀ t, W (t + 1) ≤ W t) (hdet : ∀ t, D t → W (t + 1) ≤ W t / 2)
    (hlow : ∀ t, wstar ≤ W t) (n : ℕ) :
    2 ^ ((Finset.range n).filter D).card * wstar ≤ W 0 := by
  have h := weight_le_pow_mul (c := 1 / 2) (by norm_num) hmono
    (fun t ht => by have := hdet t ht; linarith) n
  set k := ((Finset.range n).filter D).card
  have h2 : (0 : ℝ) < 2 ^ k := by positivity
  calc 2 ^ k * wstar ≤ 2 ^ k * W n := mul_le_mul_of_nonneg_left (hlow n) h2.le
    _ ≤ 2 ^ k * ((1 / 2) ^ k * W 0) := mul_le_mul_of_nonneg_left h h2.le
    _ = W 0 := by rw [← mul_assoc, ← mul_pow]; norm_num

/-- The halving bound in logarithmic form: `k ≤ log₂ (W 0 / w*)`, i.e.
`k · log 2 ≤ log (W 0 / w*)`. -/
theorem halving_bound_log {W : ℕ → ℝ} {D : ℕ → Prop} [DecidablePred D] {wstar : ℝ}
    (hmono : ∀ t, W (t + 1) ≤ W t) (hdet : ∀ t, D t → W (t + 1) ≤ W t / 2)
    (hlow : ∀ t, wstar ≤ W t) (hpos : 0 < wstar) (n : ℕ) :
    (((Finset.range n).filter D).card : ℝ) * Real.log 2 ≤ Real.log (W 0 / wstar) := by
  have h := halving_bound hmono hdet hlow n
  rw [← Real.log_pow]
  apply Real.log_le_log (by positivity)
  rw [le_div_iff₀ hpos]
  exact h

/-- **The total number of detections is finite and bounded**: with `w* > 0`, the set of
detection rounds is finite and its cardinality `k` satisfies `2 ^ k · w* ≤ W 0`. -/
theorem halving_bound_total {W : ℕ → ℝ} {D : ℕ → Prop} [DecidablePred D] {wstar : ℝ}
    (hmono : ∀ t, W (t + 1) ≤ W t) (hdet : ∀ t, D t → W (t + 1) ≤ W t / 2)
    (hlow : ∀ t, wstar ≤ W t) (hpos : 0 < wstar) :
    ∃ hfin : {t | D t}.Finite, 2 ^ hfin.toFinset.card * wstar ≤ W 0 := by
  have hfin : {t | D t}.Finite := by
    by_contra hinf
    obtain ⟨m, hm⟩ := exists_nat_gt (W 0 / wstar)
    obtain ⟨F, hF, hFc⟩ := Set.Infinite.exists_subset_card_eq hinf m
    have hsub : F ⊆ (Finset.range (F.sup id + 1)).filter D := by
      intro t ht
      simp only [Finset.mem_filter, Finset.mem_range]
      exact ⟨Nat.lt_succ_of_le (Finset.le_sup (f := id) ht), hF ht⟩
    have hcard := Finset.card_le_card hsub
    have hb := halving_bound hmono hdet hlow (F.sup id + 1)
    have h1 : (m : ℝ) < 2 ^ m := by exact_mod_cast Nat.lt_two_pow_self
    have h2 : (2 : ℝ) ^ m ≤ 2 ^ ((Finset.range (F.sup id + 1)).filter D).card :=
      pow_le_pow_right₀ (by norm_num) (hFc ▸ hcard)
    rw [div_lt_iff₀ hpos] at hm
    nlinarith
  refine ⟨hfin, ?_⟩
  obtain ⟨M, hM⟩ := hfin.bddAbove
  have heq : (Finset.range (M + 1)).filter D = hfin.toFinset := by
    ext t
    simp only [Finset.mem_filter, Finset.mem_range, Set.Finite.mem_toFinset, Set.mem_setOf_eq]
    exact ⟨fun h => h.2, fun h => ⟨Nat.lt_succ_of_le (hM h), h⟩⟩
  have := halving_bound hmono hdet hlow (M + 1)
  rwa [heq] at this

end Halving

/-! ## 3. Oligarchic halving (T2 Lemma 2.1, Thm 2.2) -/

section Oligarchic

variable {ι : Type u} {S : Type v}

/-- **T2 Lemma 2.1 (negative bag).** If the steps `P` derive `j` (e.g. `⊥`) from a context `A`
on which the step set `R` is coherent (`j ∉ Cl_R(A)`), then `P ⊄ R`: at least one step of
the bag is invalid for `R`. -/
theorem negative_bag {J : Type u} {P R : Set (Step J)} {A : Set J} {j : J}
    (hπ : j ∈ Cl P A) (hR : j ∉ Cl R A) : ¬ P ⊆ R :=
  fun h => hR (Cl_mono_rules h hπ)

/-- Lemma 2.1, second bullet: every step-set hypothesis containing the bag derives `j` from
`A`, i.e. is refuted by the witness. -/
theorem refuted_of_superset {J : Type u} {P R : Set (Step J)} {A : Set J} {j : J}
    (hπ : j ∈ Cl P A) (h : P ⊆ R) : j ∈ Cl R A :=
  Cl_mono_rules h hπ

/-- **Oligarchic halving lemma (finite form; T2 Thm 2.2 proof of (ii)).**
Let `VS` be a finite weighted version space, `C ⊆ VS` a coalition of weight `≥ ½ w(VS)`,
and `P ⊆ ⋂ C` a detected bag (a subset of the accepted steps). The deletion
`VS ↦ {R ∈ VS | P ⊄ R}`
1. eliminates every coalition member,
2. keeps every `R ∈ VS` that does not contain the bag (in particular a clean target),
3. so the survivors lie in `VS \ C` and weigh at most `w(VS) - w(C) ≤ ½ w(VS)`. -/
theorem oligarchic_halving [DecidableEq ι] {w : ι → ℝ} (hw : ∀ i, 0 ≤ w i) {H : ι → Set S}
    {VS C : Finset ι} (hC : C ⊆ VS) (hhalf : ∑ i ∈ VS, w i ≤ 2 * ∑ i ∈ C, w i)
    {P : Set S} (hP : P ⊆ accepted H C) :
    (∀ i ∈ C, i ∉ update H VS (.neg P)) ∧
    (∀ i ∈ VS, ¬ P ⊆ H i → i ∈ update H VS (.neg P)) ∧
    update H VS (.neg P) ⊆ VS \ C ∧
    ∑ i ∈ update H VS (.neg P), w i ≤ (∑ i ∈ VS, w i) - ∑ i ∈ C, w i ∧
    ∑ i ∈ update H VS (.neg P), w i ≤ (∑ i ∈ VS, w i) / 2 := by
  have h1 : ∀ i ∈ C, i ∉ update H VS (.neg P) := fun i hi hmem =>
    (mem_update_neg.1 hmem).2 (hP.trans (accepted_subset hi))
  have h3 : update H VS (.neg P) ⊆ VS \ C := fun i hi =>
    Finset.mem_sdiff.2 ⟨(mem_update_neg.1 hi).1, fun hc => h1 i hc hi⟩
  have h4 : ∑ i ∈ update H VS (.neg P), w i ≤ (∑ i ∈ VS, w i) - ∑ i ∈ C, w i := by
    have hs := Finset.sum_sdiff (f := w) hC
    have := Finset.sum_le_sum_of_subset_of_nonneg h3 (fun i _ _ => hw i)
    linarith
  refine ⟨h1, fun i hi hP' => mem_update_neg.2 ⟨hi, hP'⟩, h3, h4, by linarith⟩

/-- In particular a *clean* target (one not containing the bag) survives the detection. -/
theorem oligarchic_target_survives {H : ι → Set S} {VS : Finset ι} {P : Set S} {tgt : ι}
    (h : tgt ∈ VS) (hclean : ¬ P ⊆ H tgt) : tgt ∈ update H VS (.neg P) :=
  mem_update_neg.2 ⟨h, hclean⟩

/-- **The OH learner** (T2 §2.2), run against an environment `e`: in round `t` it holds the
version space `VS_t = vsRun H univ e t`, chooses a coalition `coal t ⊆ VS_t` of weight
`≥ ½ w(VS_t)` and announces `R̂_t = ⋂ (coal t)`; every detected bag consists of accepted steps.
The coalition choice is arbitrary (it may depend on everything), encoding the learner's
"style". -/
structure OHRun [Fintype ι] (w : ι → ℝ) (H : ι → Set S) (e : ℕ → Event S)
    (coal : ℕ → Finset ι) : Prop where
  coal_subset : ∀ t, coal t ⊆ vsRun H Finset.univ e t
  coal_half : ∀ t, ∑ i ∈ vsRun H Finset.univ e t, w i ≤ 2 * ∑ i ∈ coal t, w i
  neg_accepted : ∀ t P, e t = .neg P → P ⊆ accepted H (coal t)

/-- The number of detections ((N)-rounds) among the first `n` rounds. -/
def detections (e : ℕ → Event S) (n : ℕ) : ℕ :=
  ((Finset.range n).filter (fun t => (e t).isNeg = true)).card

/-- The number of corrections (rounds with feedback) among the first `n` rounds. -/
def corrections (e : ℕ → Event S) (n : ℕ) : ℕ :=
  ((Finset.range n).filter (fun t => (e t).isFeedback = true)).card

theorem sum_vsRun_succ_le {w : ι → ℝ} (hw : ∀ i, 0 ≤ w i) (H : ι → Set S) (VS₀ : Finset ι)
    (e : ℕ → Event S) (t : ℕ) :
    ∑ i ∈ vsRun H VS₀ e (t + 1), w i ≤ ∑ i ∈ vsRun H VS₀ e t, w i :=
  Finset.sum_le_sum_of_subset_of_nonneg (vsRun_succ_subset H VS₀ e t) (fun i _ _ => hw i)

theorem le_sum_vsRun {w : ι → ℝ} (hw : ∀ i, 0 ≤ w i) {H : ι → Set S} {VS₀ : Finset ι}
    {e : ℕ → Event S} {tgt : ι} (h0 : tgt ∈ VS₀) (he : ∀ t, LegalFor H tgt (e t)) (t : ℕ) :
    w tgt ≤ ∑ i ∈ vsRun H VS₀ e t, w i :=
  Finset.single_le_sum (fun i _ => hw i) (target_mem_vsRun h0 he t)

/-- **T2 Theorem 2.2 (i), (ii)** for a finite hypothesis class `ι` with prior `w ≥ 0`.
Under OH, if every event is legal for the target (positive data are valid in it, detected
bags are not contained in it — which Lemma 2.1 guarantees, see `thm_2_2_of_derivations`):
* (i) the target is never deleted;
* (ii) if `w(tgt) > 0`, the number `k` of detections among the first `n` rounds satisfies
  `2^k · w(tgt) ≤ w(𝓗)` (so `k ≤ log₂ (1/w(tgt))` for a normalised prior), in log form
  `k · log 2 ≤ log (w(𝓗)/w(tgt))`; and the total number of detections is finite and obeys
  the same bound. -/
theorem thm_2_2 [Fintype ι] [DecidableEq ι] {w : ι → ℝ} (hw : ∀ i, 0 ≤ w i) {H : ι → Set S}
    {e : ℕ → Event S} {coal : ℕ → Finset ι} (hOH : OHRun w H e coal) {tgt : ι}
    (hlegal : ∀ t, LegalFor H tgt (e t)) :
    (∀ t, tgt ∈ vsRun H Finset.univ e t) ∧
    (0 < w tgt → ∀ n, 2 ^ detections e n * w tgt ≤ ∑ i, w i) ∧
    (0 < w tgt → ∀ n, (detections e n : ℝ) * Real.log 2 ≤ Real.log ((∑ i, w i) / w tgt)) ∧
    (0 < w tgt → ∃ hfin : {t | (e t).isNeg = true}.Finite,
      2 ^ hfin.toFinset.card * w tgt ≤ ∑ i, w i) := by
  set W : ℕ → ℝ := fun t => ∑ i ∈ vsRun H Finset.univ e t, w i with hWdef
  have hmono : ∀ t, W (t + 1) ≤ W t := sum_vsRun_succ_le hw H _ e
  have hdet : ∀ t, (e t).isNeg = true → W (t + 1) ≤ W t / 2 := by
    intro t ht
    cases het : e t with
    | pos s => rw [het] at ht; exact absurd ht (by simp [Event.isNeg])
    | nothing => rw [het] at ht; exact absurd ht (by simp [Event.isNeg])
    | neg P =>
      have := (oligarchic_halving hw (hOH.coal_subset t) (hOH.coal_half t)
        (hOH.neg_accepted t P het)).2.2.2.2
      simp only [hWdef, vsRun_succ, het]
      exact this
  have hlow : ∀ t, w tgt ≤ W t := le_sum_vsRun hw (Finset.mem_univ _) hlegal
  have hW0 : W 0 = ∑ i, w i := rfl
  refine ⟨target_mem_vsRun (Finset.mem_univ _) hlegal, fun _ n => ?_, fun hpos n => ?_,
    fun hpos => ?_⟩
  · rw [← hW0]; exact halving_bound hmono hdet hlow n
  · rw [← hW0]; exact halving_bound_log hmono hdet hlow hpos n
  · rw [← hW0]; exact halving_bound_total hmono hdet hlow hpos

/-- **T2 Theorem 2.2 (iii), (iv)** (step sets over judgments `J`). In every round the
accepted set `R̂_t = ⋂ (coal t)` is a single compositional rule set: chaining never leaves
what each coalition member accepts, `Der(R̂_t) ⊆ Der(R)` for `R ∈ coal t`; in particular, when
the target is in the coalition, the accepted set is sound, `Der(R̂_t) ⊆ Der(R*)`. -/
theorem thm_2_2_iii_iv {J : Type u} {H : ι → Set (Step J)} (C : Finset ι) :
    ∀ i ∈ C, ∀ B : Set J, Cl (accepted H C) B ⊆ Cl (H i) B :=
  fun _ hi _ => Cl_mono_rules (accepted_subset hi)

/-- **T2 Theorem 2.2 with genuine incoherences.** Step sets over judgments `J` with a falsum
`jbot`, a family `𝒜` of designated contexts on which the target is coherent. If every (N)-event
exhibits the step set of a derivation of `jbot` from some designated context and every
(P)-event is valid in the target, then all events are legal (by Lemma 2.1), so Theorem 2.2's
conclusions (i), (ii) hold. -/
theorem thm_2_2_of_derivations {J : Type u} [Fintype ι] [DecidableEq ι] {w : ι → ℝ}
    (hw : ∀ i, 0 ≤ w i) {H : ι → Set (Step J)} {e : ℕ → Event (Step J)}
    {coal : ℕ → Finset ι} (hOH : OHRun w H e coal) {tgt : ι} (jbot : J) (𝒜 : Set (Set J))
    (hcoh : ∀ A ∈ 𝒜, jbot ∉ Cl (H tgt) A)
    (hpos : ∀ t s, e t = .pos s → s ∈ H tgt)
    (hneg : ∀ t P, e t = .neg P → ∃ A ∈ 𝒜, jbot ∈ Cl P A) :
    (∀ t, tgt ∈ vsRun H Finset.univ e t) ∧
    (0 < w tgt → ∀ n, 2 ^ detections e n * w tgt ≤ ∑ i, w i) := by
  have hlegal : ∀ t, LegalFor H tgt (e t) := by
    intro t
    cases het : e t with
    | pos s => exact hpos t s het
    | neg P =>
      obtain ⟨A, hA, hπ⟩ := hneg t P het
      exact negative_bag hπ (hcoh A hA)
    | nothing => trivial
  have h := thm_2_2 hw hOH hlegal
  exact ⟨h.1, h.2.1⟩

/-- **T2 Theorem 2.2(ii), uniform prior**: at most `log₂ |𝓗|` detections, `2^k ≤ |𝓗|`. -/
theorem thm_2_2_uniform [Fintype ι] [DecidableEq ι] {H : ι → Set S} {e : ℕ → Event S}
    {coal : ℕ → Finset ι} (hOH : OHRun (fun _ => (1 : ℝ)) H e coal) {tgt : ι}
    (hlegal : ∀ t, LegalFor H tgt (e t)) (n : ℕ) :
    2 ^ detections e n ≤ Fintype.card ι := by
  have h := (thm_2_2 (fun _ => zero_le_one) hOH hlegal).2.1 zero_lt_one n
  simp only [mul_one, Finset.sum_const, Finset.card_univ, nsmul_eq_mul] at h
  exact_mod_cast h

/-- **T2 Proposition 2.3 (halving forces oligarchy), finite version-space form.**
For a finite weighted version space `VS` and an announced set `R̂`, the following are
equivalent:
* every possible detection — every finite bag `P ⊆ R̂` that is legal for some target in `VS`
  (`P ⊄ ⋂ VS`) — leaves at most half of `w(VS)` (i.e. deletes at least half);
* `R̂ ⊆ ⋂ C` for some coalition `C ⊆ VS` with `w(C) ≥ ½ w(VS)`.
(The proof of `→` is the paper's finite-VS argument: one witness step `s_R ∈ R̂ \ R` for each
`R ∈ VS` with `R̂ ⊄ R`.) -/
theorem prop_2_3 [DecidableEq ι] {w : ι → ℝ} (hw : ∀ i, 0 ≤ w i) {H : ι → Set S}
    {VS : Finset ι} {Rhat : Set S} :
    (∀ P : Finset S, (↑P : Set S) ⊆ Rhat → ¬ (↑P : Set S) ⊆ accepted H VS →
      ∑ i ∈ update H VS (.neg ↑P), w i ≤ (∑ i ∈ VS, w i) / 2) ↔
    ∃ C ⊆ VS, ∑ i ∈ VS, w i ≤ 2 * ∑ i ∈ C, w i ∧ Rhat ⊆ accepted H C := by
  classical
  constructor
  · intro hdet
    -- one witness step for every hypothesis not containing `R̂`
    let g : ι → Finset S := fun i =>
      if h : Rhat ⊆ H i then ∅ else {Classical.choose (Set.not_subset.1 h)}
    let P₀ : Finset S := VS.biUnion g
    have hg_sub : ∀ i, (↑(g i) : Set S) ⊆ Rhat := by
      intro i x hx
      by_cases h : Rhat ⊆ H i
      · simp [g, h] at hx
      · simp only [g, h, dite_false, Finset.coe_singleton, Set.mem_singleton_iff] at hx
        rw [hx]; exact (Classical.choose_spec (Set.not_subset.1 h)).1
    have hP₀R : (↑P₀ : Set S) ⊆ Rhat := by
      intro x hx
      simp only [P₀, Finset.coe_biUnion, Set.mem_iUnion] at hx
      obtain ⟨i, -, hx⟩ := hx
      exact hg_sub i hx
    have hkey : ∀ i ∈ VS, ((↑P₀ : Set S) ⊆ H i ↔ Rhat ⊆ H i) := by
      intro i hi
      constructor
      · intro hP
        by_contra h
        have hc := Classical.choose_spec (Set.not_subset.1 h)
        apply hc.2
        apply hP
        simp only [P₀, Finset.coe_biUnion, Set.mem_iUnion]
        exact ⟨i, hi, by simp [g, h]⟩
      · intro h
        exact hP₀R.trans h
    let C : Finset ι := VS.filter (fun i => Rhat ⊆ H i)
    have hCsub : C ⊆ VS := Finset.filter_subset _ _
    have hCacc : Rhat ⊆ accepted H C := fun x hx i hi =>
      (Finset.mem_filter.1 hi).2 hx
    refine ⟨C, hCsub, ?_, hCacc⟩
    have hsplit := Finset.sum_filter_add_sum_filter_not VS (fun i => Rhat ⊆ H i) w
    have hU : update H VS (.neg ↑P₀) = VS.filter (fun i => ¬ Rhat ⊆ H i) := by
      ext i
      simp only [mem_update_neg, Finset.mem_filter]
      constructor
      · rintro ⟨hi, h⟩; exact ⟨hi, fun h' => h ((hkey i hi).2 h')⟩
      · rintro ⟨hi, h⟩; exact ⟨hi, fun h' => h ((hkey i hi).1 h')⟩
    by_cases hlegal : (↑P₀ : Set S) ⊆ accepted H VS
    · -- no legal detection exists: every hypothesis contains `R̂`, so `C = VS`
      have hCeq : C = VS := by
        apply Finset.filter_true_of_mem
        intro i hi
        exact (hkey i hi).1 (fun x hx => hlegal hx i hi)
      rw [hCeq]
      have : 0 ≤ ∑ i ∈ VS, w i := Finset.sum_nonneg fun i _ => hw i
      linarith
    · have h := hdet P₀ hP₀R hlegal
      rw [hU] at h
      change ∑ i ∈ VS, w i ≤ 2 * ∑ i ∈ VS.filter (fun i => Rhat ⊆ H i), w i
      linarith
  · rintro ⟨C, hC, hhalf, hR⟩ P hP _
    exact (oligarchic_halving hw hC hhalf (hP.trans hR)).2.2.2.2

end Oligarchic

/-! ## 4. The object game with the weighted halving learner (T4 Theorem 4.3(a)) -/

section ObjectGame

variable {ι : Type u} {S : Type v}

/-- Feedback `(+) s` on a step outside the majority set keeps at most half the weight. -/
theorem majority_pos_halving {w : ι → ℝ} {H : ι → Set S} {VS : Finset ι} {s : S}
    (hs : s ∉ majority w H VS) :
    ∑ i ∈ update H VS (.pos s), w i ≤ (∑ i ∈ VS, w i) / 2 := by
  simp only [majority, Set.mem_setOf_eq, not_lt] at hs
  simpa [update] using hs

/-- Feedback `(−obj) s` on a step inside the majority set keeps less than half the weight. -/
theorem majority_obj_halving {w : ι → ℝ} {H : ι → Set S} {VS : Finset ι} {s : S}
    (hs : s ∈ majority w H VS) :
    ∑ i ∈ update H VS (.neg {s}), w i < (∑ i ∈ VS, w i) / 2 := by
  classical
  have hsplit := Finset.sum_filter_add_sum_filter_not VS (fun i => s ∈ H i) w
  have heq : update H VS (.neg {s}) = VS.filter (fun i => s ∉ H i) := by
    ext i; simp [mem_update_neg]
  rw [heq]
  simp only [majority, Set.mem_setOf_eq] at hs
  convert (show ∑ i ∈ VS.filter (fun i => s ∉ H i), w i < (∑ i ∈ VS, w i) / 2 by
    linarith [hs, hsplit]) using 2

/-- Legal feedback in T4's object game (Def. 4.2) against the weighted halving learner, whose
announcement in round `t` is `A_t = majority w H VS_t`:
`(+) s` with `s ∈ h* \ A_t` (deleting every `h ∌ s`), or `(−obj) s` with `s ∈ A_t \ h*`
(deleting every `h ∋ s`, encoded as the singleton bag `{s}`), or no feedback. -/
def ObjLegal [Fintype ι] (w : ι → ℝ) (H : ι → Set S) (e : ℕ → Event S) (tgt : ι) : Prop :=
  ∀ t, (∀ s, e t = .pos s → s ∈ H tgt ∧ s ∉ majority w H (vsRun H Finset.univ e t)) ∧
    (∀ P, e t = .neg P →
      ∃ s, P = {s} ∧ s ∈ majority w H (vsRun H Finset.univ e t) ∧ s ∉ H tgt)

/-- **T4 Theorem 4.3(a) (weighted halving in the object game).** For a finite class with
prior `w ≥ 0` and target `h*` with `w(h*) > 0`, against every (adaptive) legal environment the
target is never deleted, and the number `M` of corrections in the first `n` rounds satisfies
`2^M · w(h*) ≤ w(𝓗)` (i.e. `M ≤ log₂(1/w(h*))` for a normalised prior), also in log form;
the total number of corrections is finite with the same bound. -/
theorem thm_4_3_a [Fintype ι] {w : ι → ℝ} (hw : ∀ i, 0 ≤ w i) {H : ι → Set S}
    {e : ℕ → Event S} {tgt : ι} (hleg : ObjLegal w H e tgt) :
    (∀ t, tgt ∈ vsRun H Finset.univ e t) ∧
    (0 < w tgt → ∀ n, 2 ^ corrections e n * w tgt ≤ ∑ i, w i) ∧
    (0 < w tgt → ∀ n, (corrections e n : ℝ) * Real.log 2 ≤ Real.log ((∑ i, w i) / w tgt)) ∧
    (0 < w tgt → ∃ hfin : {t | (e t).isFeedback = true}.Finite,
      2 ^ hfin.toFinset.card * w tgt ≤ ∑ i, w i) := by
  have hlegal : ∀ t, LegalFor H tgt (e t) := by
    intro t
    cases het : e t with
    | pos s => exact ((hleg t).1 s het).1
    | neg P =>
      obtain ⟨s, rfl, -, hs⟩ := (hleg t).2 P het
      exact fun h => hs (h rfl)
    | nothing => trivial
  set W : ℕ → ℝ := fun t => ∑ i ∈ vsRun H Finset.univ e t, w i with hWdef
  have hmono : ∀ t, W (t + 1) ≤ W t := sum_vsRun_succ_le hw H _ e
  have hdet : ∀ t, (e t).isFeedback = true → W (t + 1) ≤ W t / 2 := by
    intro t ht
    cases het : e t with
    | nothing => rw [het] at ht; exact absurd ht (by simp [Event.isFeedback])
    | pos s =>
      simp only [hWdef, vsRun_succ, het]
      exact majority_pos_halving ((hleg t).1 s het).2
    | neg P =>
      obtain ⟨s, rfl, hs, -⟩ := (hleg t).2 P het
      simp only [hWdef, vsRun_succ, het]
      exact (majority_obj_halving hs).le
  have hlow : ∀ t, w tgt ≤ W t := le_sum_vsRun hw (Finset.mem_univ _) hlegal
  have hW0 : W 0 = ∑ i, w i := rfl
  refine ⟨target_mem_vsRun (Finset.mem_univ _) hlegal, fun _ n => ?_, fun hpos n => ?_,
    fun hpos => ?_⟩
  · rw [← hW0]; exact halving_bound hmono hdet hlow n
  · rw [← hW0]; exact halving_bound_log hmono hdet hlow hpos n
  · rw [← hW0]; exact halving_bound_total hmono hdet hlow hpos

/-- **T4 Theorem 4.3(a), uniform prior**: `2^M ≤ |𝓗|`, i.e. `M ≤ ⌊log₂ |𝓗|⌋`. -/
theorem thm_4_3_a_uniform [Fintype ι] {H : ι → Set S} {e : ℕ → Event S} {tgt : ι}
    (hleg : ObjLegal (fun _ => (1 : ℝ)) H e tgt) (n : ℕ) :
    2 ^ corrections e n ≤ Fintype.card ι := by
  have h := (thm_4_3_a (fun _ => zero_le_one) hleg).2.1 zero_lt_one n
  simp only [mul_one, Finset.sum_const, Finset.card_univ, nsmul_eq_mul] at h
  exact_mod_cast h

end ObjectGame

/-! ## 5. Bags of size `≤ r` and the super-majority learner (T4 Theorem 4.5) -/

section SuperMajority

variable {ι : Type u} {S : Type v}

open scoped Classical in
/-- The super-majority announcement `A = {s | w({h ∈ VS | s ∈ h}) > r/(r+1) · w(VS)}`
(T4 Thm 4.5; for `r = 1` this is `majority`). -/
noncomputable def supermajority (r : ℕ) (w : ι → ℝ) (H : ι → Set S) (VS : Finset ι) : Set S :=
  {s | (r : ℝ) / (r + 1) * ∑ i ∈ VS, w i < ∑ i ∈ VS.filter (fun i => s ∈ H i), w i}

theorem supermajority_pos {r : ℕ} {w : ι → ℝ} {H : ι → Set S} {VS : Finset ι} {s : S}
    (hs : s ∉ supermajority r w H VS) :
    ∑ i ∈ update H VS (.pos s), w i ≤ (r : ℝ) / (r + 1) * ∑ i ∈ VS, w i := by
  simp only [supermajority, Set.mem_setOf_eq, not_lt] at hs
  simpa [update] using hs

open scoped Classical in
/-- Union bound: the hypotheses not containing the bag `B` weigh at most the sum, over
`s ∈ B`, of the weight of the hypotheses missing `s`. -/
theorem sum_not_subset_le {w : ι → ℝ} (hw : ∀ i, 0 ≤ w i) (H : ι → Set S) (VS : Finset ι)
    (B : Finset S) :
    ∑ i ∈ update H VS (.neg ↑B), w i ≤
      ∑ s ∈ B, ∑ i ∈ VS, (if s ∈ H i then 0 else w i) := by
  rw [Finset.sum_comm]
  have hU : update H VS (.neg ↑B) = VS.filter (fun i => ¬ (↑B : Set S) ⊆ H i) := by
    ext i; simp [mem_update_neg]
  rw [hU, Finset.sum_filter]
  refine Finset.sum_le_sum fun i _ => ?_
  have hnn : ∀ s ∈ B, (0 : ℝ) ≤ if s ∈ H i then 0 else w i := fun s _ => by
    by_cases hs : s ∈ H i <;> simp [hs, hw i]
  by_cases h : (↑B : Set S) ⊆ H i
  · simp only [h, not_true_eq_false, if_false]
    exact Finset.sum_nonneg hnn
  · simp only [h, not_false_eq_true, if_true]
    obtain ⟨s, hsB, hs⟩ := Set.not_subset.1 h
    have hle := Finset.single_le_sum (f := fun s => if s ∈ H i then (0 : ℝ) else w i)
      hnn (Finset.mem_coe.1 hsB)
    simpa [hs] using hle

/-- A bag `B ⊆ A_t` with `|B| ≤ r` keeps at most `r/(r+1)` of the weight. -/
theorem supermajority_bag {r : ℕ} {w : ι → ℝ} (hw : ∀ i, 0 ≤ w i) {H : ι → Set S}
    {VS : Finset ι} {B : Finset S} (hB : (↑B : Set S) ⊆ supermajority r w H VS)
    (hcard : B.card ≤ r) :
    ∑ i ∈ update H VS (.neg ↑B), w i ≤ (r : ℝ) / (r + 1) * ∑ i ∈ VS, w i := by
  classical
  have hW : 0 ≤ ∑ i ∈ VS, w i := Finset.sum_nonneg fun i _ => hw i
  have hr : (0 : ℝ) < r + 1 := by positivity
  have hterm : ∀ s ∈ B, ∑ i ∈ VS, (if s ∈ H i then 0 else w i) ≤ (∑ i ∈ VS, w i) / (r + 1) := by
    intro s hsB
    have hs := hB (Finset.mem_coe.2 hsB)
    simp only [supermajority, Set.mem_setOf_eq] at hs
    have hsplit := Finset.sum_filter_add_sum_filter_not VS (fun i => s ∈ H i) w
    have h1 : ∑ i ∈ VS, (if s ∈ H i then 0 else w i) =
        ∑ i ∈ VS.filter (fun i => s ∉ H i), w i := by
      rw [Finset.sum_filter]
      refine Finset.sum_congr rfl fun i _ => ?_
      by_cases h : s ∈ H i <;> simp [h]
    rw [h1]
    have h2 : ∑ i ∈ VS.filter (fun i => s ∉ H i), w i < (∑ i ∈ VS, w i) / (r + 1) := by
      have hs' : (r : ℝ) / (r + 1) * ∑ i ∈ VS, w i <
          ∑ i ∈ VS.filter (fun i => s ∈ H i), w i := by
        convert hs using 2
      have : (∑ i ∈ VS, w i) / (r + 1) = (∑ i ∈ VS, w i) - (r : ℝ) / (r + 1) * ∑ i ∈ VS, w i := by
        field_simp; ring
      rw [this]
      linarith
    exact h2.le
  calc ∑ i ∈ update H VS (.neg ↑B), w i
      ≤ ∑ s ∈ B, ∑ i ∈ VS, (if s ∈ H i then 0 else w i) := sum_not_subset_le hw H VS B
    _ ≤ B.card • ((∑ i ∈ VS, w i) / (r + 1)) := Finset.sum_le_card_nsmul _ _ _ hterm
    _ = (B.card : ℝ) * ((∑ i ∈ VS, w i) / (r + 1)) := by rw [nsmul_eq_mul]
    _ ≤ (r : ℝ) * ((∑ i ∈ VS, w i) / (r + 1)) :=
        mul_le_mul_of_nonneg_right (by exact_mod_cast hcard) (div_nonneg hW hr.le)
    _ = (r : ℝ) / (r + 1) * ∑ i ∈ VS, w i := by ring

/-- Legal feedback in T4's bag game `(−bag_r)` against the super-majority learner
`A_t = supermajority r w H VS_t`: `(+) s ∈ h* \ A_t`, or a bag `B ⊆ A_t`, `|B| ≤ r`,
`B ⊄ h*` (deleting every `h ⊇ B`), or nothing. -/
def BagLegal [Fintype ι] (r : ℕ) (w : ι → ℝ) (H : ι → Set S) (e : ℕ → Event S) (tgt : ι) :
    Prop :=
  ∀ t, (∀ s, e t = .pos s → s ∈ H tgt ∧ s ∉ supermajority r w H (vsRun H Finset.univ e t)) ∧
    (∀ P, e t = .neg P → ∃ B : Finset S, P = ↑B ∧ B.card ≤ r ∧
      (↑B : Set S) ⊆ supermajority r w H (vsRun H Finset.univ e t) ∧ ¬ (↑B : Set S) ⊆ H tgt)

/-- **T4 Theorem 4.5 (bags of size `≤ r`).** The super-majority learner never deletes the
target and makes `M` corrections with `(1 + 1/r)^M · w(h*) ≤ w(𝓗)`, i.e.
`M · ln(1 + 1/r) ≤ ln(w(𝓗)/w(h*))`. -/
theorem thm_4_5 [Fintype ι] {r : ℕ} (hr : 1 ≤ r) {w : ι → ℝ} (hw : ∀ i, 0 ≤ w i)
    {H : ι → Set S} {e : ℕ → Event S} {tgt : ι} (hleg : BagLegal r w H e tgt) :
    (∀ t, tgt ∈ vsRun H Finset.univ e t) ∧
    (∀ n, (1 + 1 / (r : ℝ)) ^ corrections e n * w tgt ≤ ∑ i, w i) ∧
    (0 < w tgt → ∀ n,
      (corrections e n : ℝ) * Real.log (1 + 1 / (r : ℝ)) ≤ Real.log ((∑ i, w i) / w tgt)) := by
  have hlegal : ∀ t, LegalFor H tgt (e t) := by
    intro t
    cases het : e t with
    | pos s => exact ((hleg t).1 s het).1
    | neg P =>
      obtain ⟨B, rfl, -, -, hB⟩ := (hleg t).2 P het
      exact hB
    | nothing => trivial
  set W : ℕ → ℝ := fun t => ∑ i ∈ vsRun H Finset.univ e t, w i with hWdef
  have hmono : ∀ t, W (t + 1) ≤ W t := sum_vsRun_succ_le hw H _ e
  have hrpos : (0 : ℝ) < r := by exact_mod_cast hr
  have hc : (0 : ℝ) ≤ r / (r + 1) := by positivity
  have hdet : ∀ t, (e t).isFeedback = true → W (t + 1) ≤ (r : ℝ) / (r + 1) * W t := by
    intro t ht
    cases het : e t with
    | nothing => rw [het] at ht; exact absurd ht (by simp [Event.isFeedback])
    | pos s =>
      simp only [hWdef, vsRun_succ, het]
      exact supermajority_pos ((hleg t).1 s het).2
    | neg P =>
      obtain ⟨B, rfl, hcard, hB, -⟩ := (hleg t).2 P het
      simp only [hWdef, vsRun_succ, het]
      exact supermajority_bag hw hB hcard
  have hlow : ∀ t, w tgt ≤ W t := le_sum_vsRun hw (Finset.mem_univ _) hlegal
  have hW0 : W 0 = ∑ i, w i := rfl
  have hmain : ∀ n, (1 + 1 / (r : ℝ)) ^ corrections e n * w tgt ≤ ∑ i, w i := by
    intro n
    have h := weight_le_pow_mul hc hmono hdet n
    have hk : (0 : ℝ) ≤ (1 + 1 / (r : ℝ)) ^ corrections e n := by positivity
    have hone : (1 + 1 / (r : ℝ)) * ((r : ℝ) / (r + 1)) = 1 := by
      field_simp
    calc (1 + 1 / (r : ℝ)) ^ corrections e n * w tgt
        ≤ (1 + 1 / (r : ℝ)) ^ corrections e n * W n := mul_le_mul_of_nonneg_left (hlow n) hk
      _ ≤ (1 + 1 / (r : ℝ)) ^ corrections e n *
            (((r : ℝ) / (r + 1)) ^ corrections e n * W 0) := mul_le_mul_of_nonneg_left h hk
      _ = W 0 := by rw [← mul_assoc, ← mul_pow, hone, one_pow, one_mul]
  refine ⟨target_mem_vsRun (Finset.mem_univ _) hlegal, hmain, fun hpos n => ?_⟩
  rw [← Real.log_pow]
  apply Real.log_le_log (by positivity)
  rw [le_div_iff₀ hpos]
  exact hmain n

/-- `ln(1 + 1/r) ≥ 1/(r+1)`, giving T4 Thm 4.5's second form
`M ≤ ln|𝓗| / ln(1 + 1/r) ≤ (r + 1) ln|𝓗|`. -/
theorem inv_succ_le_log_one_add_inv {r : ℕ} (hr : 1 ≤ r) :
    1 / ((r : ℝ) + 1) ≤ Real.log (1 + 1 / (r : ℝ)) := by
  have hrpos : (0 : ℝ) < r := by exact_mod_cast hr
  have hx : (0 : ℝ) < (1 + 1 / (r : ℝ))⁻¹ := by positivity
  have h := Real.log_le_sub_one_of_pos hx
  rw [Real.log_inv] at h
  have : (1 + 1 / (r : ℝ))⁻¹ = (r : ℝ) / (r + 1) := by
    field_simp
  rw [this] at h
  have h2 : (r : ℝ) / (r + 1) - 1 = -(1 / ((r : ℝ) + 1)) := by
    field_simp; ring
  linarith

/-- **T4 Theorem 4.5, uniform prior**: `M ≤ ln|𝓗| / ln(1+1/r) ≤ (r+1) ln|𝓗|`. -/
theorem thm_4_5_uniform [Fintype ι] {r : ℕ} (hr : 1 ≤ r) {H : ι → Set S} {e : ℕ → Event S}
    {tgt : ι} (hleg : BagLegal r (fun _ => (1 : ℝ)) H e tgt) (n : ℕ) :
    (corrections e n : ℝ) * Real.log (1 + 1 / (r : ℝ)) ≤ Real.log (Fintype.card ι) ∧
    (corrections e n : ℝ) ≤ ((r : ℝ) + 1) * Real.log (Fintype.card ι) := by
  have h := (thm_4_5 hr (fun _ => zero_le_one) hleg).2.2 zero_lt_one n
  simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_one, div_one] at h
  refine ⟨h, ?_⟩
  have hl := inv_succ_le_log_one_add_inv hr
  have hr1 : (0 : ℝ) < (r : ℝ) + 1 := by positivity
  have hM : (0 : ℝ) ≤ corrections e n := Nat.cast_nonneg _
  have := mul_le_mul_of_nonneg_left hl hM
  rw [mul_one_div, div_le_iff₀ hr1] at this
  nlinarith

end SuperMajority

/-! ## 6. Robust version: multiplicative penalties (T2 Theorem 2.5) -/

section Robust

variable {ι : Type u} {S : Type v}

open scoped Classical in
/-- T2 §2.4's update: an (N)-round multiplies the weight of every `R ⊇ Steps(π)` by `β`;
a (P)-round deletes (sets to `0`) every `R ∌ s`. -/
noncomputable def penalize (β : ℝ) (H : ι → Set S) (w : ι → ℝ) : Event S → ι → ℝ
  | .pos s => fun i => if s ∈ H i then w i else 0
  | .neg P => fun i => if P ⊆ H i then β * w i else w i
  | .nothing => w

/-- The weights after `t` rounds. -/
noncomputable def wRun (β : ℝ) (H : ι → Set S) (w₀ : ι → ℝ) (e : ℕ → Event S) : ℕ → ι → ℝ
  | 0 => w₀
  | t + 1 => penalize β H (wRun β H w₀ e t) (e t)

open scoped Classical in
/-- The number of *false alarms* among the first `n` rounds: (N)-rounds whose bag lies inside
the target (possible only when the designated context was in fact target-incoherent). -/
noncomputable def falseAlarms (H : ι → Set S) (tgt : ι) (e : ℕ → Event S) (n : ℕ) : ℕ :=
  ((Finset.range n).filter (fun t => ∃ P, e t = .neg P ∧ P ⊆ H tgt)).card

/-- The robust OH learner: in round `t` it picks a coalition of weight `≥ ½ W_t` (current
weights) and announces its intersection; detected bags consist of accepted steps. (The
coalition is an arbitrary finite set of indices; allowing already-deleted, weight-0
hypotheses in it only shrinks the accepted set, so this generalises the paper's learner.) -/
structure RobustOHRun [Fintype ι] (β : ℝ) (w₀ : ι → ℝ) (H : ι → Set S) (e : ℕ → Event S)
    (coal : ℕ → Finset ι) : Prop where
  coal_half : ∀ t, ∑ i, wRun β H w₀ e t i ≤ 2 * ∑ i ∈ coal t, wRun β H w₀ e t i
  neg_accepted : ∀ t P, e t = .neg P → P ⊆ accepted H (coal t)

theorem wRun_nonneg {β : ℝ} (hβ : 0 ≤ β) (H : ι → Set S) {w₀ : ι → ℝ} (hw : ∀ i, 0 ≤ w₀ i)
    (e : ℕ → Event S) : ∀ t i, 0 ≤ wRun β H w₀ e t i
  | 0, i => hw i
  | t + 1, i => by
    have ih := wRun_nonneg hβ H hw e t
    simp only [wRun]
    cases e t with
    | pos s => simp only [penalize]; split_ifs <;> simp [ih i]
    | neg P => simp only [penalize]; split_ifs <;> simp [ih i, mul_nonneg hβ (ih i)]
    | nothing => exact ih i

/-- **T2 Theorem 2.5 (Littlestone–Warmuth weighted-majority bound for detections).**
Let `0 ≤ β ≤ 1`. Under the robust OH learner, with positive data valid in the target, after
`n` rounds with `D` detections and `m` false alarms,
`β^m · w₀(R*) ≤ ((1+β)/2)^D · W₀`; for `β > 0` and `w₀(R*) > 0` this is
`D · ln(2/(1+β)) ≤ ln(W₀/w₀(R*)) + m · ln(1/β)`. -/
theorem thm_2_5 [Fintype ι] {β : ℝ} (hβ0 : 0 ≤ β) (hβ1 : β ≤ 1) {w₀ : ι → ℝ}
    (hw : ∀ i, 0 ≤ w₀ i) {H : ι → Set S} {e : ℕ → Event S} {coal : ℕ → Finset ι}
    (hOH : RobustOHRun β w₀ H e coal) {tgt : ι}
    (hpos : ∀ t s, e t = .pos s → s ∈ H tgt) (n : ℕ) :
    β ^ falseAlarms H tgt e n * w₀ tgt ≤ ((1 + β) / 2) ^ detections e n * ∑ i, w₀ i ∧
    (0 < β → 0 < w₀ tgt →
      (detections e n : ℝ) * Real.log (2 / (1 + β)) ≤
        Real.log ((∑ i, w₀ i) / w₀ tgt) + (falseAlarms H tgt e n : ℝ) * Real.log (1 / β)) := by
  classical
  have hnn := wRun_nonneg hβ0 H hw e
  set W : ℕ → ℝ := fun t => ∑ i, wRun β H w₀ e t i with hWdef
  -- total weight never increases
  have hmono : ∀ t, W (t + 1) ≤ W t := by
    intro t
    simp only [hWdef, wRun]
    apply Finset.sum_le_sum
    intro i _
    cases e t with
    | pos s => simp only [penalize]; split_ifs <;> simp [hnn t i]
    | neg P =>
      simp only [penalize]; split_ifs
      · nlinarith [hnn t i]
      · exact le_rfl
    | nothing => exact le_rfl
  -- an (N)-round shrinks the total weight by the factor `(1+β)/2`
  have hdet : ∀ t, (e t).isNeg = true → W (t + 1) ≤ (1 + β) / 2 * W t := by
    intro t ht
    cases het : e t with
    | pos s => rw [het] at ht; exact absurd ht (by simp [Event.isNeg])
    | nothing => rw [het] at ht; exact absurd ht (by simp [Event.isNeg])
    | neg P =>
      have hacc := hOH.neg_accepted t P het
      have hhalf := hOH.coal_half t
      simp only [hWdef, wRun, het, penalize]
      -- split the new total into penalised and unpenalised parts
      have hsplit : ∑ i, (if P ⊆ H i then β * wRun β H w₀ e t i else wRun β H w₀ e t i) =
          ∑ i, wRun β H w₀ e t i -
            (1 - β) * ∑ i ∈ Finset.univ.filter (fun i => P ⊆ H i), wRun β H w₀ e t i := by
        rw [Finset.mul_sum, Finset.sum_filter, ← Finset.sum_sub_distrib]
        refine Finset.sum_congr rfl fun i _ => ?_
        split_ifs <;> ring
      have hcoal : ∑ i ∈ coal t, wRun β H w₀ e t i ≤
          ∑ i ∈ Finset.univ.filter (fun i => P ⊆ H i), wRun β H w₀ e t i := by
        apply Finset.sum_le_sum_of_subset_of_nonneg
        · intro i hi
          exact Finset.mem_filter.2 ⟨Finset.mem_univ _, hacc.trans (accepted_subset hi)⟩
        · intro i _ _; exact hnn t i
      convert (show ∑ i, wRun β H w₀ e t i -
            (1 - β) * ∑ i ∈ Finset.univ.filter (fun i => P ⊆ H i), wRun β H w₀ e t i ≤
          (1 + β) / 2 * ∑ i, wRun β H w₀ e t i by nlinarith) using 1
  have hc : 0 ≤ (1 + β) / 2 := by linarith
  have hWn := weight_le_pow_mul hc hmono hdet n
  -- the target weight is exactly `β^m w₀(R*)`
  have htgt : ∀ n, wRun β H w₀ e n tgt = β ^ falseAlarms H tgt e n * w₀ tgt := by
    intro n
    induction n with
    | zero => simp [wRun, falseAlarms]
    | succ n ih =>
      have hcount : falseAlarms H tgt e (n + 1) = falseAlarms H tgt e n +
          if (∃ P, e n = .neg P ∧ P ⊆ H tgt) then 1 else 0 := by
        unfold falseAlarms
        convert card_filter_range_succ _ n
      simp only [wRun]
      rw [hcount]
      cases het : e n with
      | pos s =>
        simp only [penalize, hpos n s het, if_true, ih]
        simp
      | nothing =>
        simp only [penalize, ih]
        simp
      | neg P =>
        by_cases hP : P ⊆ H tgt
        · have : ∃ P', Event.neg P = Event.neg P' ∧ P' ⊆ H tgt := ⟨P, rfl, hP⟩
          simp only [penalize, hP, if_true, ih, this, pow_succ]
          ring
        · have : ¬ ∃ P', Event.neg P = Event.neg P' ∧ P' ⊆ H tgt := by
            rintro ⟨P', h, h'⟩
            cases h
            exact hP h'
          simp only [penalize, hP, if_false, ih, this]
          simp
  have hle : wRun β H w₀ e n tgt ≤ W n :=
    Finset.single_le_sum (fun i _ => hnn n i) (Finset.mem_univ tgt)
  have hmain : β ^ falseAlarms H tgt e n * w₀ tgt ≤
      ((1 + β) / 2) ^ detections e n * ∑ i, w₀ i := by
    rw [← htgt n]
    exact hle.trans hWn
  refine ⟨hmain, fun hβ hw0 => ?_⟩
  set D := detections e n
  set m := falseAlarms H tgt e n
  have hW0 : 0 < ∑ i, w₀ i :=
    lt_of_lt_of_le hw0 (Finset.single_le_sum (fun i _ => hw i) (Finset.mem_univ tgt))
  have h1 : 0 < β ^ m * w₀ tgt := by positivity
  have h2 : 0 < ((1 + β) / 2) ^ D := by positivity
  have hlog := Real.log_le_log h1 hmain
  rw [Real.log_mul (by positivity) (by positivity), Real.log_mul (by positivity) (by positivity),
    Real.log_pow, Real.log_pow] at hlog
  have e1 : Real.log (2 / (1 + β)) = - Real.log ((1 + β) / 2) := by
    rw [← Real.log_inv, inv_div]
  have e2 : Real.log (1 / β) = - Real.log β := by
    rw [one_div, Real.log_inv]
  have e3 : Real.log ((∑ i, w₀ i) / w₀ tgt) = Real.log (∑ i, w₀ i) - Real.log (w₀ tgt) :=
    Real.log_div hW0.ne' hw0.ne'
  rw [e1, e2, e3]
  linarith

end Robust

end CoherenceGames
end InfLearn

#print axioms InfLearn.CoherenceGames.thm_2_4
#print axioms InfLearn.CoherenceGames.thm_2_4_memberships
#print axioms InfLearn.CoherenceGames.mem_majority_three
#print axioms InfLearn.CoherenceGames.thm_2_4_environment
#print axioms InfLearn.CoherenceGames.thm_2_4_constant_environment
#print axioms InfLearn.CoherenceGames.thm_2_4_caveat
#print axioms InfLearn.CoherenceGames.Sound_hyp
#print axioms InfLearn.CoherenceGames.weight_le_pow_mul
#print axioms InfLearn.CoherenceGames.halving_bound
#print axioms InfLearn.CoherenceGames.halving_bound_log
#print axioms InfLearn.CoherenceGames.halving_bound_total
#print axioms InfLearn.CoherenceGames.negative_bag
#print axioms InfLearn.CoherenceGames.oligarchic_halving
#print axioms InfLearn.CoherenceGames.oligarchic_target_survives
#print axioms InfLearn.CoherenceGames.thm_2_2
#print axioms InfLearn.CoherenceGames.thm_2_2_iii_iv
#print axioms InfLearn.CoherenceGames.thm_2_2_of_derivations
#print axioms InfLearn.CoherenceGames.thm_2_2_uniform
#print axioms InfLearn.CoherenceGames.prop_2_3
#print axioms InfLearn.CoherenceGames.thm_4_3_a
#print axioms InfLearn.CoherenceGames.thm_4_3_a_uniform
#print axioms InfLearn.CoherenceGames.thm_4_5
#print axioms InfLearn.CoherenceGames.thm_4_5_uniform
#print axioms InfLearn.CoherenceGames.thm_2_5
