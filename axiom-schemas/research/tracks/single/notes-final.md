# Track "single" — final notes: learning ONE determinate second-order template (class DT°), and what this gives for unions

This is the complete, corrected record of the track, revised after the adversarial referee report
`referee.md`. It supersedes `notes.md`, which is kept unchanged for reference. Every referee point and its
resolution is listed in the **Verification log** (§14). The main changes are:
- ground templates are handled explicitly in Theorem E and Proposition F.5 (ZFC's single axioms are
  ground);
- prior conjecture C11 is stated as **refuted** in its linear form; the quadratic bound holds and is tight;
- a lower bound for the κ-terms of Theorem E (Proposition E.2);
- a linear escalation bound for binder-free first data (Proposition F.9), and the triangle constraints on
  equation kills (Lemma F.10);
- the encoding behind the untagged escalation lower bound (Corollary F.4);
- (Rich) cannot be dropped from Theorem D's "only if" direction (Example D.7);
- a new §10 (Theorem H) on the complexity of the untagged cautious verifier and of the refutation test of
  DTRC step 2.

Status labels: **proved** (complete proof here), **computed** (script run here; command and output file
named), **known** (literature), **conjecture**, **open**. Scripts and outputs are in this directory
(`/home/user/AI-works/axiom-schemas/research/tracks/single/`). Library files:
- `dtcore.py`: language, instantiation, matching, subsumption;
- `dtfeat.py`: common prefix, features, the cautious verifier, saturated templates, lgg criterion,
  potential;
- `dtenum.py`: an *independent* bounded brute-force enumerator of covering templates, adapted from
  `prior/induction/so_enum.py`;
- `dtwitness.py`: witness events;
- `dtrandom.py`: random templates and data;
- `dtunion.py` (new in this revision): brute-force union verifier, the failure types of Lemma H.1, the
  2-SAT verifier for k = 2, and the reductions of Theorems H.3 and H.4.

The referee's independent code is in `referee_checks/` (it does not import the author's files).

---------------------------------------------------------------------------------------------------

## 0. Results in brief

| # | question | answer | status |
|---|---|---|---|
| (a) | matching a sentence against T ∈ DT° (term and formula metavariables of any arity, parameters) | at most one matcher; computed in time O(\|T\|+\|s\|); generality T ≥ T' is the same test on frozen T' | proved (Thm A); computed (e1) |
| (b)(i) | is every covering template above a minimal one? | **yes**, for every nonempty finite D | proved (Thm B) |
| (b)(ii) | finitely many minimal covering templates? | **yes**: every minimal one is *saturated*, and there are finitely many saturated ones up to renaming. Prior conjecture C8.3 is **true for DT°** (false for DT, by the prior referee's antichain) | proved (Thm B); computed (e2, e3) |
| (b)(iii) | if D ⊆ inst(T), T ∈ DT°: is a minimal covering template below T? | **yes** (what the clustering method needs) | proved (Thm B(d)) |
| — | the cautious verifier itself | Acc(D) = the set of sentences having every *feature* of D. This is a polynomial-time test, although \|Min(D)\| can be 4^n | proved (Thm C, Prop G.2); computed (e3, e2) |
| (c) | anchors of inst(T*) in DT° | D is an anchor **iff (R\*) ∧ (N) ∧ (U)**: root variation at every occurrence, non-vacuity of every argument place, no coincidence (no equation d\|r = d\|σ[ū] holding in all data except those T* itself imposes) | proved (Thm D). The "if" half needs no assumption; "only if" needs the richness assumption (Rich), and (Rich) cannot be dropped (Example D.7); computed (e4, e5) |
| (c) | wrong candidates | (R)+(N)+(D) is insufficient (Prop D.5: ∀x(0=f(x)) with f ↦ 0, f ↦ z). (R\*)+(N)+(U restricted to pattern occurrences) is insufficient (Prop D.4: a coincidence through an *ancestor* of the pattern occurrence) | proved; computed |
| (c) | specializations | first-order patterns: (R)+(D) = Plotkin–Reynolds. Any template with one formula metavariable (PA induction, ZF Separation, Replacement, ∈-induction): (R)+(N) | proved (Cor D.1–D.3); computed (e5: 2550 random data sets, 0 disagreements) |
| (d) | unions of ≤ k DT° templates | **Finite thickness fails** (infinitely many templates through one sentence), but **DT° has finite elasticity**. So unions of ≤ k templates have finite elasticity (Wright; Motoki–Shinohara–Wright), every target in H_k(DT°) has a finite anchor, and the cautious verifier over H_k(DT°) is eventually exact on every text. Explicit sufficient anchor condition (corrected): per schema, the data are *nonempty* and not covered by k failure sets; nonemptiness matters for ground members such as ZFC's single axioms. Untagged escalation lower bound: ⌊(N−1)/k⌋^k with a k-ary relation symbol, (⌊(N−1)/k⌋−1)^k over =, +, S, 0 | proved (Cor F.2, Prop F.3, Cor F.4, Prop F.5, F.6); computed (e9, e15, e16) |
| (d′) | cost of untagged verification and of refutation tests (new) | The cautious verifier over H_k(DT°): polynomial for k ≤ 2 (2-SAT); **coNP-complete for every fixed k ≥ 3** (graph k-colouring); with k in the input, coNP-complete even for quantifier-free data (set cover), but polynomial for binder-free data and fixed k. The **refutation test of DTRC step 2** ("some minimal covering template of D has no instance in a given finite set R of refuted sentences") is **NP-complete**, already for \|D\| = 2. It is polynomial whenever D has an lgg, e.g. when D contains an anchor (under (Rich)) | proved (Thm H); computed (e11, e14) |
| (e) | tagged sample complexity | For N ≥ 1: P[D_N not an anchor] ≤ Σ_σ (1−ρ_σ)^(N−1) + Σ_{M,m} (1−ν_{M,m})^N + Σ_{(σ,r)} (1−κ_{σ,r})^⌊N/2⌋ ≤ c(T\*)(1−λ)^⌊N/2⌋, which is 0 for ground T\*. Tagged: P[not exact] ≤ √e Σ_i c̄_i exp(−3Nπ_iλ_i/8), with c̄_i = max(c_i, 1), and λ_i = 1 for ground tags. Lower bounds (under (Rich)): (1−ρ_σ)^N, (1−ν)^N and (new) β_{σ,r}^N. With finite support the κ-event has exact rate β, which can be smaller than the √(1−κ) of the upper bound | proved (Thm E, Prop E.2); computed (e7, e10) |
| (f) | escalations; prior C11 | **Prior C11 (escalations linear in the first datum) is false**: for DT° and DT, for the universal template and for the PA-induction target (Prop F.8). The quadratic replacement holds and is tight. From a first datum d: ≤ \|d\| + Σ_p b(p) + \|d\|(\|d\|−1) escalations. From no data, Esc(DT°;N) = Θ(N²), with 2 + ⌊(N+1)/5⌋² ≤ Esc ≤ 2N²+1. For a binder-free first datum: ≤ 2\|d\| − 1 (Prop F.9). Whether the equation-kill part is linear in general is Conjecture F.7 (open; Lemma F.10 constrains it) | proved (Thm F, Prop F.8, F.9, Lemma F.10); conjecture F.7; computed (e6, e6b, e8, e12, e13) |
| (g) | complexity of Min(D) | Min(D) can have 4^n elements for \|D\| = O(n), so it cannot be output in polynomial time. But membership in Acc(D) is polynomial; an lgg exists iff a polynomial-time checkable condition holds, and then it is computed in polynomial time. Under (Rich), once D contains an anchor for T*, the lgg exists and equals T* | proved (Thm C, Prop G.1–G.3, Cor G.4); polynomial-delay enumeration and counting of Min(D) open |

Corrections to the prior notes that come out of this track:
- **C8.2** reported 8 minimal templates for {Ind(x=x), Ind(0=x)} (search bound: size ≤ 23). In DT° there
  are exactly **4**. One of them has size 24, so the bounded search missed it, and 5 templates above it
  looked minimal; 3 of the reported 8 are genuinely minimal. Computed (`e2_examples.out`: brute force at
  size ≤ 24 finds exactly the 4), and confirmed independently by the referee (`referee_checks/t1_c82.out`,
  `referee_checks/t1b_c82_prior8.out`).
- **SOCL** (prior §2) enumerates Min(D) and intersects. This is exponential in the worst case (Prop G.2).
  It should be replaced by the *feature verifier* of Thm C, which accepts the same set in polynomial time.
- **C11** (escalations at most linear in the first escalated datum) is **refuted**: Prop F.8 gives
  1 + m² escalations after a first datum of size 5m − 1 (universal template) or 20m + 1 (PA-induction
  target). The quadratic form of Thm F is the correct statement.

---------------------------------------------------------------------------------------------------

## 1. Setting and definitions

**Object language.** A first-order signature: function symbols (constants included), relation symbols,
connectives, and the binders ∀, ∃ (one bound variable, body a formula). Following the brief (§3,
closure-normal form), data are formulas whose free variables are *parameters*, read under universal
closure; formally, parameters are an infinite supply of extra constants a, b, c, …. Bound variables are
**de Bruijn indices**: at a position with b binders above it, index k < b refers to the (k+1)-th binder
going up. Formulas are therefore equal iff α-equivalent. A *sentence* has no free index (parameters are
allowed). The scripts use the signature 0, S, +, ·, parameters a, b, c, =, ∈, ¬, ∧, ∨, →, ↔, ∀, ∃.

**Positions.** p ≤ q: p is a prefix (ancestor-or-self) of q; p ⊥ q: incomparable. t|p is the subterm at
p; b(p) is the number of binders strictly above p; every position has a sort ι (term) or o (formula).
The *root symbol* of a term/formula is its head symbol, where for an index the "symbol" is the index
itself (and for a hole z_m it is z_m).

**Bodies.** A body of type ι^n → s (s ∈ {ι, o}) is λz_1…z_n.β with β an object term (s = ι) or formula
(s = o) that is closed except for the holes z_m (parameters allowed; β may contain binders).
*Plugging* β[ū] replaces each z_m by u_m, shifted by the number of binders of β above that hole; no
capture is possible, since β's own binders are de Bruijn and the u_m are relative to the outside.

**Templates.** A template is built like a sentence, except that at positions of sort s there may be
*occurrences* M(t_1, …, t_n) of metavariables M : ι^n → s (lowercase names for s = ι, uppercase for
s = o), where the t_i are **metavariable-free** object terms, which may contain indices bound above the
occurrence and parameters. Occ(T) is the set of occurrence positions; since arguments contain no
metavariables, all occurrences are rigid and Occ(T) is an antichain. skel(T) is the set of the other
positions outside argument lists (the *rigid skeleton*). An occurrence is a *pattern occurrence* if its
arguments are pairwise distinct indices (n = 0: every occurrence). **DT°** = templates in which every
metavariable has at least one pattern occurrence. (This is the class DT° of the brief §3 and of the prior
notes; DT, with nested arguments, is not considered.)

**Instances.** A (ground) substitution θ maps each metavariable to a body of its type; Tθ replaces each
occurrence M(t̄) by θ(M)[t̄] (one-step β-reduction; no new redex arises because bodies are first-order
and arguments metavariable-free). inst(T) = {Tθ : θ}.

**Generality.** T ≥ T' iff T' = Tσ for a substitution σ that maps each metavariable of T to a *template
body* λz̄.γ, where γ may contain occurrences N(ū) of metavariables with metavariable-free arguments ū
(over holes, γ's own indices and parameters). Composition gives transitivity, and T ≥ T' implies
inst(T) ⊇ inst(T'). T ≡ T' iff T ≥ T' ≥ T.

**Data notions** (D a nonempty finite set of sentences).
- **Common prefix** C(D): the root is in C(D) iff all d ∈ D have the same root symbol; p·i ∈ C(D) iff
  p ∈ C(D) and all d|p·i have the same root symbol (indices count as symbols). C(D) is prefix-closed.
- **Slots** slots(D): positions p ∉ C(D) whose parent is in C(D) (or p = root ∉ C(D)).
  **Admissible positions** A(D) = C(D) ∪ slots(D).
- **Scope of a slot**: Y_σ(D) = ⋃_{d∈D} FV(d|σ), the set of indices (relative to σ) free in some datum
  at σ.
- **Features** of a sentence q (all positions below are positions of q):
  - Sym(p), p ∈ C(D): q|p has the root symbol common to D at p;
  - Scope(σ), σ ∈ slots(D): FV(q|σ) ⊆ Y_σ(D);
  - Eq(σ, r, ū), σ ∈ slots(D), r ∈ A(D), σ ⊥ r, same sort, ū a map from Y_σ(D) to terms in scope at r:
    FV(q|σ) ⊆ Y_σ(D) and q|r = (q|σ)[ū] (replace each free index y of q|σ by u_y, shifted under the
    binders inside q|σ).
  A *D-feature* is one that every d ∈ D has. **Feat(D)** = the sentences having every D-feature.
- **Cautious verifier** (lem:imitation:cautious of the parent paper): Acc(D) = ⋂{inst(T) : T ∈ DT°,
  D ⊆ inst(T)}. Min(D) = the ≥-minimal covering templates. D ⊆ inst(T*) is an **anchor** (for inst(T*) in
  DT°) iff every T ∈ DT° with D ⊆ inst(T) has inst(T) ⊇ inst(T*), i.e. iff Acc(D) = inst(T*).
  For D = ∅ the intersection runs over all of DT°, and Acc(∅) = ∅ (two distinct ground templates have
  disjoint instance sets); so the empty set is never an anchor.

**Basic lemmas** (all proved; elementary).

*Lemma 1.1 (preservation).* If p ∈ skel(T) then (Tθ)|p has the same root symbol as T|p; if p ∈ Occ(T)
carries M(t̄) then (Tθ)|p = θ(M)[t̄]. (Plugging replaces occurrences by bodies; nothing else moves.)

*Lemma 1.2 (substitution facts).* Let β be closed except holes.
- (i) Composition: (β[t̄])[ū] = β[t̄[ū]], where ū substitutes for free indices (the only free indices of
  β[t̄] are those of t̄).
- (ii) Injectivity: if z_m occurs in β and β[ā] = β[ā'] then a_m = a'_m (compare at an occurrence of z_m).
- (iii) If β's root is a symbol (not a hole), β[ā] has the same root; formula bodies always have
  symbol roots.

*Lemma 1.3 (forcing, pairwise).* Fix positions σ ⊥ r present in every d ∈ D, and let
Y = ⋃_{d∈D} FV(d|σ). (i) There is at most one ū on Y with d|r = (d|σ)[ū] for all d ∈ D. (ii) Such a ū
exists iff one exists for every pair {d, d'} ⊆ D. *Proof.* Matching d|σ against d|r with the free indices of d|σ as first-order variables
either fails or yields a partial map e_d defined exactly on FV(d|σ) (each variable occurrence reads off
the subterm of d|r at the same place, lowered through the local binders; it fails if that subterm
mentions a local binder or if two occurrences disagree). A common ū exists iff no e_d fails and the e_d
agree on common arguments; this is a pairwise condition, and ū is determined on ⋃_d FV(d|σ) = Y. ∎

---------------------------------------------------------------------------------------------------

## 2. Theorem A (matching) — proved; computed

**Theorem A.** Let T ∈ DT° and s a sentence.
- (a) There is at most one θ (on the metavariables of T) with Tθ = s.
- (b) The following decides s ∈ inst(T) and returns θ, in time O(|T| + |s|) (unit-cost index
  arithmetic): walk skel(T) against s, failing on a symbol clash; for each metavariable M take one pattern
  occurrence M(y_1..y_n) at position p and set θ(M) := λz̄.(s|p)[z_m/y_m], failing if s|p has a free
  index outside {y_1..y_n}; then check every other occurrence M(t̄) at q by comparing s|q with
  θ(M)[t̄] lazily.
- (c) For T, T' ∈ DT°: T ≥ T' iff freeze(T') ∈ inst(T), where freeze turns each metavariable of T' into a
  fresh rigid symbol of the same type. So generality is decidable in linear time.
- (d) (prior C1(b), proved in the prior session; not a literature result) Without determinacy (class SO°: metavariable-free arguments, no pattern
  occurrence required) membership is still polynomial (independent projection/imitation per position,
  Huet–Lang style), but the number of matchers can be 2^Ω(|s|) (P(0) against a sentence with k zeros).

*Proof.* (a) By Lemma 1.1, (Tθ)|p = θ(M)[ȳ] at a pattern occurrence; since the y_m are distinct indices
and θ(M) is closed except holes, θ(M) = λz̄.(s|p)[z_m/y_m] is forced, and FV(s|p) ⊆ ȳ is necessary.
(b) Correctness follows from (a) and Lemma 1.1. Time: the skeleton walk is O(|skel(T)|). Abstraction at
a pattern occurrence costs O(|s|p|). The lazy check at q walks θ(M) and s|q in lock step; a non-hole node
of θ(M) consumes one node of s|q, a hole z_m is compared with t_m (shifted) and consumes |t_m| ≥ 1 nodes
of s|q; the walk stops at the first mismatch. So the cost at q is O(|s|q| + |t̄|). Occurrence positions
are pairwise incomparable, so Σ_q |s|q| ≤ |s|, and Σ_q |t̄_q| ≤ |T|. (c) If T' = Tσ, freezing the
metavariables of T' inside the bodies σ(M) gives a ground substitution with T(freeze∘σ) = freeze(T').
Conversely a ground matcher θ of freeze(T') yields σ by unfreezing; the unfrozen bodies are template
bodies because a frozen symbol can only be applied to metavariable-free terms. Then apply (b) over the
signature extended by the frozen symbols. (d) is prior C1(b). ∎

Parameters are constants here, so they may occur in bodies; nothing changes. If one wants inst(T)
closed under renaming of parameters (data are read under closure), it suffices that T itself mentions no
parameter rigidly; templates learned from data that share a parameter at the same place do mention it,
which is a (sound) specialization.

*Computed* (`python3 e1_matching.py` → `e1_matching.out`): on 1500 random DT° templates (1–2
metavariables of the six types ι→ι, ι²→ι, ι, ι→o, ι²→o, o; derived occurrences with random argument
terms) and random substitutions, the full projection/imitation count of matchers is exactly 1 in 1500/1500
cases and det_match returns the generating θ in 1500/1500; on 1500 perturbed queries det_match agrees
with the general SO° membership test; 400/400 random pairs T ≥ Tσ are recognized by freezing. Timing on
Ind(φ) and Replacement instances of size 3·10^2 … 3.3·10^6 grows linearly (0.0003 s … 5.5 s in Python).

---------------------------------------------------------------------------------------------------

## 3. Two structural lemmas — proved

**Lemma R (equivalence is renaming).** For T, T' ∈ DT°: T ≥ T' ≥ T iff T' arises from T by a bijective
renaming of metavariables together with a permutation of each metavariable's argument places.

*Proof.* "If" is clear. Let T' = Tσ and T = T'σ'; then T = Tτ with τ = σ;σ'. Let M(ȳ) be a pattern
occurrence of M at p. By Lemma 1.1, τ(M)[ȳ] = T|p = M(ȳ). Write τ(M) = λz̄.γ. Then γ is not a hole (a hole
plugs to an index) and its root is not a rigid symbol, so γ = M(γ_1..γ_n) with γ_j[ȳ] = y_j. Each γ_j is
a metavariable-free term at depth 0 of the body, hence contains no index of its own; γ_j[ȳ] = y_j forces
γ_j = z_j (ȳ distinct). So τ is the identity.
Now write σ(M) = λz̄.γ'. Since γ'σ' = M(z̄), the root of γ' is an occurrence N(ū) of a metavariable of
T' (a rigid root or a hole would survive σ'), and σ'(N) = λw̄.M(δ̄) with δ_j[ū] = z_j, so δ_j = w_π(j) and
u_π(j) = z_j. Distinct M give distinct N (σ'(N) has root M). Every metavariable of T' occurs in Tσ, hence
as the root of some σ(M) (the ū are metavariable-free), so M ↦ N is a bijection. Finally N has a pattern
occurrence in T', which is the image N(ū[t̄]) of some occurrence M(t̄) of T; each u_l[t̄] is an index, and
a non-hole u_l would give a non-index term, so u_l = z_ρ(l); distinctness of the u_l[t̄] makes ρ
injective, and ρ∘π = id makes it surjective. So σ(M) = λz̄.N(z_ρ(1), …, z_ρ(n)) with ρ a permutation. ∎

**Lemma P (rigid prefix).** If D ⊆ inst(T) then skel(T) ⊆ C(D), with the same symbols, and
Occ(T) ⊆ A(D). *Proof.* Lemma 1.1 for each datum; the parent of an occurrence is in skel(T) ⊆ C(D). ∎

---------------------------------------------------------------------------------------------------

## 4. Theorem B (well-foundedness and finitariness of minimal covering templates) — proved

Let D be nonempty and finite, T ∈ DT° with D ⊆ inst(T) ("T covers D"). For d ∈ D let θ_d be the unique
matcher (Thm A) and β_M^d := θ_d(M). Call T **saturated** (for D) if
- (S1) every argument place m of every metavariable M is used: z_m occurs in β_M^d for some d ∈ D;
- (S2) for every metavariable M the roots of the β_M^d (d ∈ D) are not all equal (a hole z_m counts as
  the root symbol z_m).

**Theorem B.** Let D be nonempty and finite.
- (a) Every covering T ∈ DT° is ≥ some saturated covering T' ∈ DT°.
- (b) In a saturated covering template: skel ⊆ C(D); every pattern occurrence of M sits at a slot σ and
  its argument *set* is exactly Y_σ(D); every occurrence sits in A(D); the arguments of every occurrence
  are determined by D, its position, and the pattern slot of its metavariable. Hence there are finitely
  many saturated covering templates up to renaming: at most 2^|A(D)| · |slots(D)|^|A(D)|.
- (c) Every minimal covering template is saturated (up to renaming). **Min(D) is finite up to renaming,
  and every covering template is ≥ some minimal covering template.**
- (d) In particular, if D ⊆ inst(T*) with T* ∈ DT°, some minimal covering template T_m satisfies
  T* ≥ T_m, hence inst(T_m) ⊆ inst(T*).

*Proof.* (a) Two reduction steps, each producing T ≥ T' with T' ∈ DT° covering D:
- *Step V (vacuous place).* If z_m occurs in no β_M^d, let σ(M) := λz̄.M'(z_1..z_{m−1}, z_{m+1}..z_n),
  M' fresh. Pattern occurrences stay pattern occurrences (a sub-list of distinct indices); D is covered
  with θ'_d(M') := β_M^d (holes renumbered).
- *Step H (common root).* If all β_M^d have the same root:
  - if it is a hole z_m, let σ(M) := λz̄.z_m (M is term-valued; its occurrences become their m-th
    argument);
  - if it is a symbol f with children 1..k, child j under e_j ∈ {0,1} binders of f, let
    σ(M) := λz̄.f(M_1(z̄, 0^{e_1}), …, M_k(z̄, 0^{e_k})), with fresh M_j of arity n + e_j, where 0^{e} is
    the index 0 (the variable bound by f) if e = 1 and nothing if e = 0. (Inside the binder the holes are
    shifted by plugging.) A pattern occurrence M(ȳ) becomes f(…, M_j(ȳ↑, 0), …): distinct indices, so a
    pattern occurrence. D is covered with θ'_d(M_j) := the j-th child of β_M^d with the index bound by f
    replaced by the new hole.
  Measure μ(T) = (|C(D)| − |skel(T)|, Σ_M arity(M)) ∈ ℕ² with the lexicographic order (skel(T) ⊆ C(D)
  by Lemma P). Step H strictly increases |skel| (the root symbol, or the index y_m, becomes rigid at least
  at the pattern position); Step V keeps skel and lowers Σ arity. So the process stops, and it stops
  exactly at a saturated template. Generality is transitive.
(b) skel ⊆ C(D) is Lemma P. Let M(ȳ) be a pattern occurrence at σ. d|σ = β_M^d[ȳ], whose root is the
root of β_M^d if that is a symbol, and y_m if β_M^d = z_m. Since the y_m are distinct indices, the roots
of the d|σ are all equal iff the roots of the β_M^d are; by (S2) they are not, so σ ∉ C(D), and its parent
is in skel ⊆ C(D): σ is a slot. By (S1) every y_m is free in some d|σ, so {ȳ} ⊆ Y_σ(D); covering forces
FV(d|σ) ⊆ {ȳ}, so Y_σ(D) ⊆ {ȳ}. Every occurrence is in A(D) by Lemma P. For an occurrence M(t̄) at q,
β_M^d = (d|σ)[z̄/ȳ] is determined by the pattern slot σ, and by (S1) and Lemma 1.2(ii) each t_m is read
off a datum d whose β_M^d contains z_m. So a saturated template is determined by its occurrence set
Q ⊆ A(D) (which also determines the skeleton: C(D) above Q) and, for each q ∈ Q, the pattern slot of the
metavariable occurring there; hence the bound.
(c) If T is minimal, (a) gives T ≥ T' saturated, minimality gives T' ≥ T, and Lemma R makes T a renaming
of T', hence saturated. For an arbitrary covering T, the set S_T of saturated covering templates T' with
T ≥ T' is finite up to renaming and nonempty; ≥ is a partial order on renaming classes (Lemma R); take
T_m ≥-minimal in S_T. If U covers D and T_m ≥ U, then U ≥ U' for some saturated U' (by (a)), and
T ≥ T_m ≥ U ≥ U', so U' ∈ S_T and T_m ≥ U'; minimality in S_T gives U' ≡ T_m, so U ≡ T_m. Thus T_m is
minimal among all covering templates. (d) is (c) with T = T*. ∎

*Contrast with DT.* With nested arguments (class DT), prior referee r3 exhibited the infinite antichain
T_k = (0=0 & Ax(f(x)=x → f^k(Sx)=Sx)) → Ax f(x)=x of minimal covering templates of {Ind(x=x),
Ind(0=x)}. Theorem B shows the restriction to metavariable-free arguments removes this: the nesting
f^k(Sx) is exactly what makes derived arguments unforced. In DT° the same data have exactly 4 minimal
covering templates (computed, `e2_examples.out`, §11):
(f(0)=f(0) & …), (f(0)=0 & …), (0=f(0) & …), (0=0 & …), each with body Ax.(f(x)=x → f(Sx)=Sx) → Ax f(x)=x;
only the second is ≤ T_ind. The prior count "8" (C8.2) came from the size bound 23 (the first template
has size 24).

---------------------------------------------------------------------------------------------------

## 5. Theorem C (the cautious verifier checks features) — proved; computed

For nonempty finite D define two kinds of covering templates:
- **T_0(D)**: the skeleton C(D) (symbols from the data) with a fresh metavariable M_σ(Y_σ) at every slot
  σ (arguments: the indices of Y_σ(D) in increasing order; a pattern occurrence).
- **T_φ** for a D-feature φ = Eq(σ_0, r, ū): C(D) cut at r (everything strictly below r removed), fresh
  M_σ(Y_σ) at every slot not below r, and M_{σ_0}(ū) at r (σ_0 is not below r since σ_0 ⊥ r).

Both are in DT° and cover D (take θ_d(M_σ) := (d|σ)[z̄/Y_σ], closed except holes because
FV(d|σ) ⊆ Y_σ; at r, θ_d(M_{σ_0})[ū] = (d|σ_0)[ū] = d|r because φ is a D-feature).

**Theorem C.** For every nonempty finite set D of sentences,

    Acc(D) = Feat(D) = inst(T_0(D)) ∩ ⋂_{φ an Eq-feature of D} inst(T_φ).

*Proof.* (1) inst(T_0) is exactly the set of sentences with all Sym and Scope features (Thm A: read
θ(M_σ) off q|σ). inst(T_φ) ⊇ Feat(D): a q with all D-features has the skeleton of T_φ, satisfies Scope at
every slot, and q|r = (q|σ_0)[ū], so q = T_φθ with θ(M_σ) := (q|σ)[z̄/Y_σ]. Conversely every D-feature is
implied by one of these templates (inst(T_φ) ⊆ {q : q has φ}, since q|σ_0 = θ(M)[Y] and
q|r = θ(M)[ū]). So Feat(D) equals the displayed intersection, and Acc(D) ⊆ Feat(D) because T_0 and the
T_φ cover D.
(2) Acc(D) ⊇ Feat(D): let T cover D. By Thm B(a) T ≥ T' with T' saturated and covering, so
inst(T) ⊇ inst(T'). By Thm B(b), inst(T') is the set of sentences that have (i) Sym(p) for p ∈ skel(T')
⊆ C(D), (ii) Scope(σ_M) at a chosen pattern slot σ_M of each M (argument set Y_{σ_M}(D)), (iii)
Eq(σ_M, r, t̄_r) for every other occurrence M(t̄_r) at r. Each of these is a D-feature: for (iii), r ∈ A(D)
(Lemma P), r ⊥ σ_M (distinct occurrences are incomparable), the sorts agree, and T' covers D. Given q with
these features, θ(M) := (q|σ_M)[z̄/ȳ] is a body by (ii), and (i), (iii) give T'θ = q. So
Feat(D) ⊆ inst(T'). ∎

**Corollary C.1 (polynomial cautious verifier; proved).** Let m = |A(D)| ≤ min_{d∈D}|d| and
n = Σ_{d∈D}|d|. The D-features can be listed in time O(m²·n) (for each of ≤ m² pairs (σ, r), Lemma 1.3
reads ū off one datum and checks all data in O(n)); there are O(m²) of them; a query q is then
decided in time O(m²·|q|). No enumeration of Min(D) is needed, although |Min(D)| can be exponential
(Prop G.2).

*Reading.* The cautious DT° verifier accepts q iff (i) q has the data's common skeleton, (ii) no slot of q
mentions a bound variable that no datum mentions there, and (iii) every equation of the form "the
content at r is the content at slot σ with its variables replaced by ū" that holds in *all* data also
holds in q. Equations (iii) are the second-order analogue of Plotkin's "equal columns get equal
variables". T_0(D) is the pattern anti-unifier without merging (cf. Pfenning 1991; Baumgartner–Kutsia–
Levy–Villaret 2017); merging equal-up-to-renaming columns is the special case of (iii) where ū is a
permutation of indices.

*Computed* (`python3 e3_finitary.py 120 7` etc. → `e3_finitary_*.out`, see §11): on random data sets
the set Min(D) computed from Sat(D) (Thm B) equals the set of minimal templates found by the independent
brute-force enumerator whenever the enumeration bound contains the Sat-minimal templates; every
enumerated covering template is above a Sat-minimal one; and Feat(D)-membership equals membership in the
intersection of all enumerated covering templates on every query of a pool built from instances of the
minimal templates and of the generating template.

---------------------------------------------------------------------------------------------------

## 6. Theorem D (the general anchor theorem) — proved; computed

Let T* ∈ DT° and D = {s_1, …, s_N} with s_i = T*θ_i (N ≥ 1); write β_M^i := θ_i(M). For an occurrence
σ ∈ Occ(T*) carrying M(t̄_σ) let Y*_σ := ⋃_m FV(t_{σ,m}) (indices relative to σ). Call a pair (σ, r)
with σ ∈ Occ(T*), r ∈ skel(T*) ∪ Occ(T*), r ⊥ σ, of the same sort, **valid** if r carries an
occurrence M(t̄_r) of the *same* metavariable and t̄_r = t̄_σ[ū_0] for some ū_0 (t̄_r is an instance of
t̄_σ, the variables being Y*_σ). Valid pairs give equations that hold on all of inst(T*) (Lemma 1.2(i)).

**Witness events.**
- **(R\*)** (root variation at every occurrence): for every σ ∈ Occ(T*), the roots of s_1|σ, …, s_N|σ
  are not all equal. (At a pattern occurrence this says that the roots of the values β_M^i are not all
  equal — Plotkin's (R); at a derived occurrence M(t̄) it is a condition on the plugged values β_M^i[t̄].)
- **(N)** (non-vacuity): for every metavariable M and argument place m, some β_M^i contains z_m.
- **(U)** (no coincidence): for every pair (σ, r) as above that is not valid, there is no ū (on Y*_σ)
  with s_i|r = (s_i|σ)[ū] for all i.

**Richness assumption (Rich).** The signature has a relation symbol R of arity ≥ 1 (so formula bodies
with a prescribed hole and with two different roots exist), and, if T* has a term-valued metavariable,
there are closed terms with at least two different root symbols (automatic with parameters, or with 0
and S). This holds for arithmetic and for set theory with parameters.

**Theorem D.** Under (Rich), D is an anchor for inst(T*) in DT° iff (R\*), (N) and (U) hold.

*Proof.* (⇐) By Lemma 1.1, skel(T*) ⊆ C(D); by (R\*) no occurrence is in C(D); so C(D) = skel(T*),
slots(D) = Occ(T*) and A(D) = skel(T*) ∪ Occ(T*). By (N), Y_σ(D) = ⋃_i ⋃_{m: z_m ∈ β^i} FV(t_{σ,m}) = Y*_σ.
Let q = T*θ. q has every Sym feature (Lemma 1.1) and every Scope feature (FV(q|σ) ⊆ Y*_σ). Let
Eq(σ, r, ū) be a D-feature. By (U) the pair is valid: t̄_r = t̄_σ[ū_0]. By (N) and Lemma 1.3(i), ū = ū_0 on
Y*_σ. Then q|r = θ(M)[t̄_σ[ū]] = (θ(M)[t̄_σ])[ū] = (q|σ)[ū] (Lemma 1.2(i)). So q ∈ Feat(D) = Acc(D)
(Thm C): inst(T*) ⊆ Acc(D), i.e. D is an anchor.
(⇒) If D is an anchor, every D-feature holds on all of inst(T*) (Thm C). We exhibit an instance violating
a D-feature whenever an event fails (other metavariables arbitrary):
- (R\*) fails at σ ∈ Occ(T*), common root h: σ ∈ C(D) (its ancestors are in skel(T*)), so Sym(σ) is a
  D-feature. Choose θ(M) with a symbol root ≠ h (Rich); by Lemma 1.2(iii) (T*θ)|σ has that root.
- (R\*) holds, (N) fails at (M, m): at a pattern occurrence M(ȳ) at σ, y_m ∉ Y_σ(D), so Scope(σ) is a
  D-feature; choose θ(M) containing z_m (z_m itself, or R(z_m, …)); then y_m ∈ FV((T*θ)|σ).
- (R\*), (N) hold, (U) fails at a non-valid (σ, r) with ū: then Eq(σ, r, ū) is a D-feature. If
  r ∈ skel(T*) with rigid root g, choose θ(M) with a symbol root ≠ g; then (T*θ)|σ[ū] has that root and
  (T*θ)|r has g. If r carries M' ≠ M (same sort), choose θ(M), θ(M') with different symbol roots. If r
  carries M(t̄_r) with t̄_r ≠ t̄_σ[ū], pick m with t_{r,m} ≠ t_{σ,m}[ū] and θ(M) := λz̄.z_m (term-valued) or
  λz̄.R(z_m, …, z_m) (formula-valued); the two sides then differ in that argument. ∎

So the brief's candidates are right in spirit but must be read occurrence-wise: (R) has to hold at
every *derived* occurrence as well, and (D) is only the simplest coincidence.

**Corollary D.1 (first-order patterns = Plotkin–Reynolds; proved).** If all metavariables of T* are
0-ary (a first-order schema, possibly inside binders), then (R\*) ∧ (N) ∧ (U) ⟺ (R) ∧ (D): for every
metavariable the values do not all have the same root, and distinct metavariables differ in some datum.
*Proof.* Every occurrence is a pattern occurrence and s_i|σ = β^i, so (R\*) = (R); (N) is vacuous;
Y*_σ = ∅, so (U) at (σ, r) asks whether s_i|r = β_M^i for all i. If r ∈ skel(T*) its root is fixed, which
(R) excludes; if r carries M' ≠ M this is "β_M^i = β_{M'}^i for all i", i.e. failure of (D); if r carries
M the pair is valid. ∎
So in the much larger class DT° a first-order target has *the same* anchors as in the class of
first-order schemas (lem:setting:recover of the parent paper). Using DT° costs no data on first-order
targets. This covers question Q1 of the brief: the instance schema φ(c) (c a term metavariable) of a
universal sentence ∀xφ(x) is anchored by two instances φ(t_1), φ(t_2) whose terms have different root
symbols (e.g. φ(0), φ(S0), or φ(a), φ(b) with parameters), plus (D) if several variables.

**Corollary D.2 (formula metavariables; proved).** If all metavariables of T* are formula-valued, then
(R\*) ⟺ (R) (value roots not all equal), and under (R) ∧ (N), (U) ⟺ (D⁺): for distinct metavariables M ≠ M'
and occurrences σ of M, r of M', there is no ū with β_{M'}^i[t̄_r] = (β_M^i[t̄_σ])[ū] for all i.
In particular **for a template with a single formula metavariable, D is an anchor iff (R) ∧ (N).**
*Proof.* Formula bodies have symbol roots that survive plugging (Lemma 1.2(iii)), so the root of s_i|σ is
the root of β^i at every occurrence: (R\*) = (R). For r ∈ skel(T*) a coincidence would make all roots
of β_M^i equal to the rigid root at r, contradicting (R). For r an occurrence of M:
β^i[t̄_r] = β^i[t̄_σ[ū]] for all i forces t̄_r = t̄_σ[ū] by (N) and Lemma 1.2(ii), so the pair is valid
or there is no coincidence. Term-valued occurrences have the wrong sort. What remains is (D⁺). ∎

**Corollary D.3 (PA induction and ZF; proved).** In closure-normal form, de Bruijn notation,
- PA induction T_ind = P(0) ∧ ∀x(P(x) → P(Sx)) → ∀x P(x): anchors iff (R) ∧ (N) — prior C3, now
  as a one-line consequence of Thm D (for DT°).
- Separation T_sep = ∀a∃b∀x(x∈b ↔ x∈a ∧ P(x, a)) (b cannot occur in P: freshness is built in): anchors iff
  (R) ∧ (N_x) ∧ (N_a), i.e. motives with different main connectives, some motive mentioning x, some
  mentioning a. (If the presentation forbids a in φ, the template is P(x) and (N_a) disappears. If no
  datum mentions a, the learner stays at the strictly smaller, logically equivalent-in-the-presence-of-
  parameters schema with P(x, a) replaced by P'(x).)
- Replacement with ∃! spelled out, T_rep = ∀a(∀x(x∈a → ∃y(P(x,y,a) ∧ ∀z(P(x,z,a) → z=y))) →
  ∃b∀x(x∈a → ∃y(y∈b ∧ P(x,y,a)))): all three occurrences are pattern occurrences (a Miller pattern);
  anchors iff (R) ∧ (N_x) ∧ (N_y) ∧ (N_a).
- ∈-induction T_∈ = ∀x(∀y(y∈x → P(y)) → P(x)) → ∀x P(x): anchors iff (R) ∧ (N).
- Single axioms (Extensionality, Pairing, …) are ground templates; each instance is its own anchor.
In each case one datum is never an anchor and two can be.

*Remark (de Bruijn and first-order lgg).* In de Bruijn notation the three occurrences of P in T_∈ are the
*same* term P(index 0), so first-order anti-unification of de Bruijn trees that allows a 0-ary
metavariable to capture index 0 recovers ∈-induction exactly; Replacement's occurrences P(1,0,2) and
P(2,0,3) differ, and Ind's P(0), P(x) differ, so for those first-order anti-unification fails. For
Separation the capture-permitting first-order schema ∀a∃b∀x(x∈b ↔ x∈a ∧ A) is *unsound*: A may capture
b (index 1), giving e.g. ∀a∃b∀x(x∈b ↔ x∈a ∧ ¬x∈b), which is refutable (take a ≠ ∅); in DT° the pattern
occurrence P(x, a) excludes b by construction (the freshness side condition is built in, as the brief
says). (Remark, proved by inspection; not used elsewhere.)

**Proposition D.4 ((U) restricted to pattern occurrences is not enough; proved, computed).** Let
T* = ∀x∀y(S f(x,y) = 0) ∧ ∀x∀y(f(x, Sy) = 0) with f : ι²→ι, and D the instances for f := λz_1z_2.z_1,
λz_1z_2.z_2, λz_1z_2.S z_1:

    d_1 = ∀x∀y(Sx = 0) ∧ ∀x∀y(x = 0),  d_2 = ∀x∀y(Sy = 0) ∧ ∀x∀y(Sy = 0),  d_3 = ∀x∀y(SSx = 0) ∧ ∀x∀y(Sx = 0).

(R), (R\*), (N), (D) hold, and so does (U) for every pair whose first component is the pattern
occurrence f(x,y). But D is not an anchor: with σ the derived occurrence f(x, Sy) and r the rigid
position of S f(x,y), the equation d|r = (d|σ)[x ↦ Sx, y ↦ y] holds in all three data, so the template
∀x∀y(f'(y, Sx) = 0) ∧ ∀x∀y(f'(y, x) = 0) covers D; it misses T*[f := 0] = ∀x∀y(S0=0) ∧ ∀x∀y(0=0).
Here r is an *ancestor* of the pattern occurrence, so the coincidence cannot be routed through it; (U)
must range over derived occurrences σ as well.
*Proof.* Direct verification of the three equations and of the two non-memberships. Computed in
`e2_examples.out` (4a) and `e8_counterexamples.out`: the brute-force enumerator (size ≤ 18, arguments
≤ 2, arity ≤ 2) independently finds exactly two minimal covering templates, T* (up to argument order) and
the displayed one, in agreement with Sat(D).

**Proposition D.5 ((R) + (N) + (D) is not enough; proved, computed).** T* = ∀x(0 = f(x)) with data
f := λz.0 and f := λz.z, i.e. D = {∀x(0=0), ∀x(0=x)}. (R), (R\*), (N) hold and (D) is vacuous, but
∀x(f(0) = f(x)) covers D and misses ∀x(0 = Sx) = T*[f := λz.Sz]. The coincidence is the equation "content
at the rigid 0 = content at the slot with x := 0", which holds in both data. Found (in a larger form) by
the random search e4, checked by hand, and by brute force in `e8_counterexamples.out` (minimal covering
templates: ∀x(0 = f(x)) and ∀x(f(0) = f(x))).

**Example D.6 (projections versus rigid variables; computed).** T* = ∀x∀y(f(x,y) = 0) ∧ ∀x(x = 0), with
f := λz_1z_2.z_1 and λz_1z_2.z_2. (R\*), (N) hold, but ∀x∀y(f(x,y) = 0) ∧ ∀x(f(x,x) = 0) covers D. For
term-valued metavariables (U) is a genuine condition even with a single metavariable and pattern-only
occurrences.

**Example D.7 ((Rich) cannot be dropped from the "only if" direction; proved; new in revision).** In pure
set theory without parameters (signature ∈, =; no closed terms) the only term bodies are projections
λz̄.z_m: a body of type ι^n→ι is a term over holes, and there are no function symbols, constants or (inside
a term) binders. For T* = ∀x(f(x) ∈ x), f : ι→ι, this gives inst(T*) = {∀x(x ∈ x)}. So the single datum
D = {∀x(x∈x)} is an anchor (every covering template contains D = inst(T*)), but (R\*) fails (one datum,
one root). Without closed terms of two root symbols, term-valued metavariables can be degenerate, and the
anchor condition is strictly weaker than (R\*) ∧ (N) ∧ (U). With parameters (closure-normal form) (Rich)
holds, since two distinct parameters are closed terms with different roots. ∎

*Computed* (§11, `e4_anchor_random_seed*.out`, `e5_specializations.out`): on random DT° targets with
1–2 metavariables of all six types and random data (N = 2, 3), the prediction (R\*) ∧ (N) ∧ (U) agreed
with the feature-based anchor status in all 248 cases (111 anchors, 137 non-anchors; every non-anchor
certified by an explicit instance of T* outside Acc(D)); the independent brute-force enumerator (size
≤ |T*|+2, arguments ≤ 2, 25 s per case) decided 149 of them and agreed in 144; the 5 disagreements were
all "enumerator says anchor" and each was checked to be a bound artifact (no witnessing feature template
fits the enumeration bounds). The feature verifier never accepted a query rejected by an enumerated
covering template. The wrong candidates (R)∧(N)∧(D) and (R\*)∧(N)∧(D) were wrong in 27 and 17 of the
248 cases (always "says anchor, is not"); (R\*)∧(N)∧(U restricted to pattern occurrences) was never
wrong on random data, so its failure (Prop D.4) needs the special structure built there. For FO patterns (571 random cases),
Ind, Separation, Replacement and ∈-induction (≈ 500 random data sets each, N = 1–3) the predicted
equivalences of Cor. D.1–D.3 held in every case. The referee's independent implementation
(`referee_checks/t3_random.py`, `t3b_lowdiv.py`, `t4_zf.py`, with enumeration bounds that contain T_0(D)
and every T_φ) found prediction = feature truth on 540/540 random targets, prediction = brute force on
519/519 decided cases (so the 5 "bound artifacts" above disappear with adequate bounds), and Cor D.3
confirmed on 1,169 data sets against features and 116 against brute force.

---------------------------------------------------------------------------------------------------


## 7. Theorem E (tagged sample complexity) — proved; computed

Let Λ be a law with countable support on ground substitutions for T*, θ_1, θ_2, … i.i.d. ~ Λ and
D_N = {T*θ_1, …, T*θ_N}. Define
- ρ_σ := 1 − max_h Λ(root of (T*θ)|σ = h), for σ ∈ Occ(T*);
- ν_{M,m} := Λ(z_m occurs in θ(M));
- U(T*) := the non-valid pairs (σ, r) of §6. For (σ, r) ∈ U(T*) and ū a map on Y*_σ let
  A_{σ,r,ū} := {θ : (T*θ)|r = ((T*θ)|σ)[ū]}. Then
  κ_{σ,r} := Λ⊗Λ{(θ, θ') : no ū has θ, θ' ∈ A_{σ,r,ū}}, and β_{σ,r} := sup_ū Λ(A_{σ,r,ū});
- c(T*) := |Occ(T*)| + Σ_M arity(M) + |U(T*)| ≤ |Occ(T*)|·(1 + |T*|) + Σ_M arity(M);
- λ := the minimum of all ρ_σ, ν_{M,m}, κ_{σ,r}.

**Ground templates (convention; added in revision).** If T* has no metavariable (for example a single
axiom of ZFC), all three index sets are empty. Then c(T*) = 0, and we set λ := 1. Write
c̄ := max(c(T*), 1). For a ground T*, inst(T*) = {T*}, and Acc({T*}) = {T*}: by Thm C, C({T*}) is all of
T* and there are no slots. So D_N is an anchor iff N ≥ 1.

**Theorem E.** The upper bounds use only the "if" half of Thm D and need no assumption. The lower bounds
use (Rich).
- (a) For N ≥ 1:

      P[D_N not an anchor] ≤ Σ_σ (1−ρ_σ)^(N−1) + Σ_{M,m} (1−ν_{M,m})^N + Σ_{(σ,r)∈U(T*)} (1−κ_{σ,r})^⌊N/2⌋
                           ≤ c(T*)·(1−λ)^⌊N/2⌋.

  Both sides are 0 for a ground T*. For N = 0, D_0 = ∅ is never an anchor (Acc(∅) = ∅).
  Lower bound (under (Rich)):

      P[D_N not an anchor] ≥ max( max_σ (1−ρ_σ)^N , max_{M,m} (1−ν_{M,m})^N , max_{(σ,r)∈U(T*)} β_{σ,r}^N ).

  The ρ- and ν-terms of the upper bound have matching lower bounds. For the κ-terms the lower bound is
  β^N, and its relation to (1−κ)^⌊N/2⌋ is given by Prop E.2.
- (b) λ > 0 iff the (possibly infinite) set {T*θ : θ ∈ supp Λ} satisfies (R\*), (N), (U). In that case,
  for every δ ∈ (0, 1], the cautious verifier is exact with probability ≥ 1−δ once
  N ≥ 1 + (2/λ) ln(c̄/δ). For a ground T*, any N ≥ 1 suffices.
- (c) Tagged rules (prior thm:imitation:coupon setting): k templates T_i* ∈ DT° (ground ones allowed),
  tag i with probability π_i, parameters c̄_i and λ_i (λ_i ≤ 1; for ground tags c̄_i = 1 and λ_i = 1).
  Then

      P[the per-tag cautious DT° verifier is not exact after N tagged steps] ≤ √e Σ_i c̄_i exp(−3Nπ_iλ_i/8),

  so N ≥ max_i (8/(3π_iλ_i)) ln(√e·k·c̄_i/δ) suffices. Order 1/(π_iλ_i) is necessary in general:
  - P[not exact] ≥ (1 − π_iρ)^N if some head at a pattern occurrence of T_i* has probability 1 − ρ;
  - P[not exact] ≥ (1 − π_i)^N for every tag (no datum of tag i), and this is the exact value for a
    ground tag.

*Proof.* (a) Let N ≥ 1. By Thm D (⇐), which needs no (Rich),
"not an anchor" ⊆ ¬(R\*) ∪ ¬(N) ∪ ((R\*) ∧ (N) ∧ ¬(U)). For a ground T* all three events are empty, which
is consistent: every nonempty D ⊆ inst(T*) equals {T*} and is an anchor. Now bound each event.
- P[all roots at σ equal] = Σ_h p_h^N ≤ p_max^(N−1) Σ_h p_h = (1−ρ_σ)^(N−1).
- P[z_m never used] = (1−ν)^N.
- Under (N), valid pairs cannot fail (forcing, Lemma 1.3(i)). For a non-valid pair, a coincidence on D_N
  implies (Lemma 1.3(ii)) that each of the ⌊N/2⌋ disjoint pairs (θ_1, θ_2), (θ_3, θ_4), … has a common ū.
  These pairs are independent, each with probability 1−κ.

The union bound gives the first inequality. Each term is ≤ (1−λ)^⌊N/2⌋, since N−1 ≥ ⌊N/2⌋ for N ≥ 1;
this gives the second.

Lower bounds: under (Rich) each single failure event is a non-anchor event (Thm D (⇒)).
P[all N roots at σ equal the most likely head] = (1−ρ_σ)^N, P[z_m unused] = (1−ν)^N, and
P[coincidence at (σ, r)] ≥ β^N by Prop E.2.

(b) Each event has positive probability iff some element (or pair) of the support witnesses it; for (U)
this is Lemma 1.3(ii). Then (1−λ)^⌊N/2⌋ ≤ e^(−λ⌊N/2⌋) ≤ e^(−λ(N−1)/2), and c̄·e^(−λ(N−1)/2) ≤ δ iff
N ≥ 1 + (2/λ) ln(c̄/δ). For a ground T* the failure probability is 0 for N ≥ 1.

(c) The version space factors over tags (parent thm:caution:tagged), so
P[not exact] ≤ Σ_i P[the tag-i data are not an anchor]. Condition on n_i ~ Bin(N, π_i). For all n_i ≥ 0,

    P[not anchor | n_i] ≤ c̄_i (1−λ_i)^⌊n_i/2⌋:

- for n_i ≥ 1 this is (a);
- for n_i = 0 the right side is c̄_i ≥ 1;
- for a ground tag the left side is [n_i = 0], and the right side is 0^⌊n_i/2⌋ ≥ [n_i = 0] (with 0^0 = 1).

Then (1−λ)^⌊n/2⌋ ≤ e^(λ/2) e^(−λn/2) ≤ √e e^(−λn/2) (since λ ≤ 1), and
E[e^(−a n_i)] = (1 − π_i(1−e^(−a)))^N ≤ exp(−Nπ_i(1−e^(−a))). Finally 1 − e^(−a) ≥ 3a/4 for
a = λ/2 ≤ 1/2.

Lower bounds: P[all tag-i data share the head h at σ, or there are none] = (1 − π_i + π_i(1−ρ))^N
= (1 − π_iρ)^N, and P[n_i = 0] = (1−π_i)^N. ∎

For a single formula metavariable (Ind, ZF schemas), the event (R\*) ∧ (N) ∧ ¬(U) is empty (Cor D.2), and
all occurrence events coincide with (R). So the κ-terms can be dropped, and the bound becomes
(1−ρ)^(N−1) + Σ_m (1−ν_m)^N. For Ind this is prior C5(b)'s Σ_f p_f^N + (1−q)^N, up to the
inclusion–exclusion term.

**Proposition E.2 (the κ-terms: lower bound and exact rate; proved, computed; new in revision).** Fix a
non-valid pair (σ, r) ∈ U(T*) and write β := β_{σ,r}, κ := κ_{σ,r}.
- (i) P[some ū has θ_1, …, θ_N ∈ A_{σ,r,ū}] ≥ β^N. Under (Rich) this event implies that D_N is not an
  anchor, so P[D_N not an anchor] ≥ β^N.
- (ii) β² ≤ 1 − κ. Hence the rate √(1−κ) of the pair-splitting term (1−κ)^⌊N/2⌋ is ≥ β.
- (iii) Suppose Λ has finite support. Let 𝒦 be the family of maximal subsets K of supp Λ such that some
  ū has K ⊆ A_{σ,r,ū} (the maximal compatible sets; by Lemma 1.3(ii), compatibility is a pairwise
  condition). Then

      P[coincidence at (σ, r) on D_N] = Σ_{∅≠𝒥⊆𝒦} (−1)^(|𝒥|+1) Λ(⋂𝒥)^N,   and   β^N ≤ P ≤ |𝒦|·β^N.

  So the exact exponential rate of the κ-event is β. This can be strictly smaller than √(1−κ), so the
  pair-splitting bound need not be tight in rate. It is tight when |𝒦| = 1, since then 1−κ = β².

*Proof.* (i) For each ū, P[all θ_i ∈ A_ū] = Λ(A_ū)^N; take the supremum. Under (Rich), a coincidence at a
non-valid pair is a failure of (U). Hence D_N is not an anchor: by Thm D (⇒) when (R\*) and (N) hold, and
by Thm D otherwise.
(ii) For every ū, 1−κ = Λ⊗Λ{θ, θ' ∈ A_ū' for some ū'} ≥ Λ(A_ū)².
(iii) The event says that the set of sampled support points is compatible, i.e. lies in some A_ū, i.e.
lies in some K ∈ 𝒦. Inclusion–exclusion over 𝒦 gives the formula. Each Λ(K)^N ≤ β^N, so P ≤ |𝒦|β^N.
β is attained by a maximal compatible set (A_ū ∩ supp is compatible for every ū), so P ≥ β^N. ∎

*Examples* (computed, `python3 e10_rates_revision.py` → `e10_rates_revision.out`).
- **The referee's law** T* = ∀x(0 = f(x)), f ~ {0: .4, z: .3, Sz: .3}.
  - The coincidence pair (slot, rigid 0) has β = 0.7, from the compatible set {0, z}.
  - The exact probability is P[not anchor] = 0.7^N + 0.3^N.
  - The old lower bound max((1−ρ)^N, (1−ν)^N) = 0.4^N misses the rate. The new one, 0.7^N, has it.
  - At N = 8: exact 0.057714, new lower bound 0.057648, old lower bound 0.000655, Thm E upper bound
    0.059942.
- **A law with |𝒦| = 3**: T* = ∀x∀y(f(x) = g(y)), f ~ U{z, Sz}, g ~ U{z, 0, Sz} independent.
  - At (σ_f, σ_g): β = 1/3, |𝒦| = 3, √(1−κ) = 0.408.
  - At N = 8 the exact coincidence probability is 1.54·10⁻⁴, against β^N = 1.52·10⁻⁴ and
    (1−κ)^(N/2) = 7.7·10⁻⁴.
- **The three laws of e7**: every non-valid pair has |𝒦| = 1, so there the κ-term of Thm E(a) is exact
  for even N.

*Computed.*
- `python3 e7_rates.py` → `e7_rates.out`: exact ρ, ν, κ for three targets and laws, and a Monte Carlo
  estimate of P[not anchor] against the bound (§11). That Monte Carlo decides anchor status by Thm D's own
  events, which is circular as a check of Thm E. The referee's exact computation
  (`referee_checks/t7_rates_exact.out`) decides anchor status by feature search and confirms the bound at
  every N ∈ {2, 4, 8, 12, 16, 24} for all three laws.
- `python3 e10_rates_revision.py` → `e10_rates_revision.out`:
  - ground templates: Acc({Extensionality}) = {Extensionality}, and (1−π)^N ≤ √e·exp(−3Nπ/8) for
    π ∈ {.05, .2, .5}, N ≤ 100;
  - Prop E.2(iii) holds on every non-valid pair of five laws;
  - exact P[not anchor] by inclusion–exclusion over support subsets for the two small laws. Anchor status
    there is by Thm D's events, cross-checked against the feature-template test `anchor_by_features`
    with 0 disagreements.

---------------------------------------------------------------------------------------------------

## 8. Theorem F (escalations, finite elasticity, unions) — proved; computed

For nonempty D write Π(D) = (C(D), (Y_σ(D))_σ, E(D)) with E(D) the set of pairs (σ, r) for which some
Eq(σ, r, ū) is a D-feature.

**Lemma F.1 (monotone, and every escalation moves Π; proved).** Let D ⊆ D'. (i) C(D') ⊆ C(D);
A(D') ⊆ A(D); a position that is a slot for D and still in A(D') is a slot for D'; Y_σ(D) ⊆ Y_σ(D')
whenever σ is a slot for both. (ii) If C(D') = C(D) and Y(D') = Y(D) then E(D') ⊆ E(D), with the same ū.
(iii) If q ∉ Acc(D) then Π(D ∪ {q}) ≠ Π(D).
*Proof.* (i) is immediate from the definitions (Y_σ is a union over data). (ii) A feature on D' restricts
to D; ū is forced on Y_σ(D) = Y_σ(D') by Lemma 1.3. (iii) If Π is unchanged, q has every Sym feature
(C unchanged), every Scope feature (Y unchanged) and every Eq feature (E unchanged, ū forced by D), so
q ∈ Feat(D) = Acc(D) by Thm C. ∎

**Theorem F (escalation bound; proved).** Let d be a sentence with n positions, and let
q_2, q_3, …, q_m be sentences with q_j ∉ Acc({d, q_2, …, q_{j−1}}) for every j. Then

    m − 1 ≤ n + Σ_{p a position of d} b(p) + #{(σ, r) : σ ⊥ r positions of d} ≤ n + n·b_max + n(n−1).

Consequently (parent thm:caution:esc) the cautious DT° verifier, started from one datum d, escalates at
most that many times against any honest prover, and Esc(DT°; N) ≤ 1 + N + N(N−1) + N·(N−1) ≤ 2N² + 1
(the first query from no data is always escalated, Acc(∅) = ∅). A linear lower bound already holds for
first-order targets: Esc(DT°; N) ≥ N + 1 for N ≥ 5, by the chain S^k(0)=0, S^k(a)=0, S^{k−1}(0)=0, …, 0=0, 0=S0, ¬(0=0) with k = N − 3 (each query lies
outside the previous acceptance set, which is successively {q}, {S^k(t)=0}, {S^{k−1}(t)=0}, …, {t=0},
{t=t'}; all queries have size ≤ N; checked for N = 5, 8, 12, 16 in `e8_counterexamples.out`).
*Proof.* By Lemma F.1 each step does at least one of: (α) shrink C; (β) keep C and enlarge some Y_σ;
(γ) keep C and Y and remove a pair from E. (α) happens at most |C({d})| = n times. A position σ is a slot
during one interval of steps (it enters when it leaves C, and leaves A for ever when its parent leaves C),
and during that interval Y_σ only grows inside {0, …, b(σ)−1}; so (β) happens at most Σ_σ b(σ) times.
A pair (σ, r) can be in E only while σ is a slot and r ∈ A, a single interval; once removed it never
returns, because a feature holding on a larger data set restricts to the smaller one (Lemma 1.3); so (γ)
happens at most once per ordered incomparable pair of positions of d. ∎

**Status of prior conjecture C11 (corrected in revision).** Prior C11 conjectured that the cautious
verifier escalates, against an adversarial prover, at most *linearly* in the size of the first escalated
datum. **This linear form is false** (Prop F.8 below). It fails:
- in DT°;
- in the class DT of the prior notes, because DT ⊇ DT° gives Acc_DT(D) ⊆ Acc_DT°(D), so every DT°
  escalation is also a DT escalation;
- for the universal template;
- for the PA-induction target.

What holds is the quadratic bound of Thm F (the "O(|first datum|²)" form suggested by the prior referee),
and it is tight. (notes.md said "This proves prior conjecture C11 in the polynomial form"; that wording was
misleading and is withdrawn.)

**Proposition F.8 (quadratic lower bound; C11 refuted; proved, computed).** Let m ≥ 1 and b = m. Let
d_1 = ∀^b(0=0 ∧ … ∧ 0=0) with m atoms, and d_2 the same with every left-hand side replaced by the
parameter a. For j ≤ m and k < b let q_{j,k} be d_1 with the j-th left-hand side replaced by the k-th
bound variable.
- (i) Take the order d_1, d_2, q_{1,0}, …, q_{1,b−1}, q_{2,0}, …, q_{m,b−1}. Every query lies outside the
  acceptance set of its predecessors. All are instances of the universal template (a 0-ary formula
  metavariable), so this is an honest chain, and all have size b + 4m − 1 = 5m − 1. Hence, for N ≥ 4,

      Esc(DT°; N) ≥ 2 + ⌊(N+1)/5⌋²     (take m = ⌊(N+1)/5⌋, so 5m − 1 ≤ N),

  and with Thm F, Esc(DT°; N) = Θ(N²). (notes.md wrote 2 + ((N+1)/5)², which is exact only for
  N ≡ 4 mod 5.)
- (ii) PA-induction target (the referee's construction, `referee_checks/t5b_escalation_ind.py`). The
  sentences Ind(d_1), Ind(d_2), Ind(q_{j,k}) (motives in which x does not occur) are instances of T_ind
  and have size 20m + 1. In the same order, each lies outside the acceptance set of its predecessors. So
  against the PA-induction target, 1 + m² = 1 + ((n−1)/20)² escalations follow a first datum of size n.
  This is superlinear, so no bound of the form c·n holds: for m > 20c + 1 the count exceeds c·n. The
  refutation is asymptotic; for small m the counts (5, 10, 17, 26 for n = 41, 61, 81, 101) are below n.

*Proof.* (i) d_1 and d_2 differ exactly at the m left-hand sides (roots 0 and a). So C({d_1, d_2}) is
everything else, and the left-hand sides are slots with empty scope. Each q_{j,k} agrees with d_1 off the
slots, so C does not change along the chain. At slot j, q_{j,k} has the bound variable number k free
(relative to the slot). Earlier data have, at slot j, only 0, a, or other bound variables k' ≠ k. So
q_{j,k} violates Scope(slot j) of its predecessors, and q_{j,k} ∉ Feat = Acc (Thm C).

The same conclusion follows without Thm C's hard direction. T_0(predecessors) is a covering DT° template
and misses q_{j,k}, and Acc ⊆ inst(T_0).

The size is b binders, m − 1 conjunctions and 3m symbols in the atoms.

(ii) The motive occurs four times in Ind(φ). After Ind(d_1) and Ind(d_2), the left-hand sides in all four
copies are slots. Their scopes contain no index bound by the motive's own b binders: the variable x does
not occur, and d_1, d_2 have no indices at the slots. Ind(q_{j,k}) puts the motive's k-th bound variable
at slot j of each copy, which no predecessor has. Size: 4(5m−1) + 5. ∎

*Computed.*
- `e8_counterexamples.out`: m = 2, 4, 6, 8 give chains of length 6, 18, 38, 66.
- `python3 e12_c11_refuted.py` → `e12_c11_refuted.out`:
  - universal template, N ∈ {4, 5, 9, 14, 19, 23, 24, 29, 34} with m = ⌊(N+1)/5⌋: exactly 2 + m²
    escalations, max size ≤ N;
  - PA-induction target, m = b = 2, …, 5: first datum of size 41, 61, 81, 101, followed by 5, 10, 17, 26
    escalations; every query is an instance of T_ind;
  - every step is certified twice: by the feature verifier, and by an explicit covering T_0 that misses
    the query.
- The referee's `t5_escalation.py` and `t5b_escalation_ind.py` agree.

The quadratic term comes from the scope (β) steps, which need deep binder nesting. What remains open is
whether the equation-kill (γ) steps can be superlinear.

Evidence that they cannot:
- The greedy adversarial search e6 (60 random first data of 3–18 positions) found chains of length at
  most 2.14·n (n = |d|). The ratio chain/bound was at most 0.71 overall, at most 0.33 for n ≥ 10, and it
  decreases with n.
- A structured search (e6b) fixes the skeleton ∀x(t_1=0 ∧ … ∧ t_m=0), starts from up to 145 equation
  pairs among m ≤ 12 slots, and greedily kills as few pairs per escalation as it can. It achieved at most
  17 kill-steps for m = 12, about 1.4·m (`e6b_escalation_structured.out`).
- The referee's greedy search (`referee_checks/t10_gamma.out`) found at most m − 1 kill-steps for
  m = 3, …, 6 slots under two binders.

Neither search found the scope-growth chains of Prop F.8, so greedy search is weak evidence.

**Conjecture F.7 (open).** The number of (γ)-steps is O(n), hence Esc(DT°; N) = O(N·(1 + b_max)) for
sentences of binder depth ≤ b_max. The obstacle to a proof: surviving equation pairs need not form an
equivalence relation. Eq features compose like a preorder (Lemma F.10(a)) and obey a cancellation rule
(Lemma F.10(b)), and chains of preorders on m points can have length of order m². Prop F.9 proves the
conjecture when all scopes are empty, and the Remark after Lemma F.10 locates the difficulty.

**Proposition F.9 (binder-free first datum: linear; proved, computed; new in revision).**
- (i) For any escalation chain d, q_2, …, q_m as in Thm F, at most n − 1 (γ)-steps (n = |d|) remove a pair
  (σ, r) whose source has empty scope, Y_σ = ∅.
- (ii) If d contains no binder, then m − 1 ≤ 2n − 1. Hence for binder-free sentences, from no data,
  N + 1 ≤ Esc ≤ 2N (N ≥ 5; the lower bound is the binder-free chain of Thm F).

*Proof.* (i) For a data set D containing d, define the relation ~_D on positions of d: p ~_D p' iff
p = p', or p and p' are positions of every datum of D with d'|p = d'|p' for all d' ∈ D. This is an
equivalence relation, and it refines as D grows.

Consider a (γ)-step D → D' = D ∪ {q}. It does not change C or Y, hence not slots(D) or A(D). Suppose it
removes (σ, r) with Y_σ(D) = ∅. Then Eq(σ, r, ∅) was a D-feature, so σ ~_D r (positions in A(D) exist
in all data). It is not a D'-feature, although σ is still a slot and r still admissible, so q|r ≠ q|σ
and σ ≁_{D'} r. This is a strict refinement. An equivalence relation on n points can refine strictly at
most n − 1 times.

(ii) If d has no binder, every slot σ has b(σ) = 0, since its ancestors lie in C with d's symbols. So
Y_σ = ∅ always: there are no (β)-steps, and every (γ)-step is of the kind in (i). With at most n
(α)-steps, m − 1 ≤ n + (n − 1). From no data, add 1 for the first escalation. ∎

*Computed* (`python3 e13_escalation_structure.py 3 40` → `e13_escalation_structure.out`): 40 greedy
adversarial chains from binder-free first data of 8–18 positions. No chain exceeded 2n − 1 (max
chain/n = 1.00), and every (γ)-step strictly refined ~.

So Conjecture F.7 is only about (γ)-steps in which every removed pair has a source with nonempty scope.

**Lemma F.10 (triangle constraints on equation kills; proved; suggested by the referee).** Let D ⊆ D'
with C(D') = C(D) and Y(D') = Y(D), and write ū_ab for the forced substitution of a pair (a, b) in E.
- (a) (composition) If (k,i), (i,j) ∈ E(D'), k ⊥ j, and k, j have the same sort, then (k,j) ∈ E(D')
  with ū_kj = ū_ki[ū_ij] on Y_k.
- (b) If (k,i), (k,j), (i,j) ∈ E(D) and (k,i), (k,j) ∈ E(D'), then (i,j) ∈ E(D').
- (c) If (i,k), (k,j), (i,j) ∈ E(D) and (i,k), (k,j) ∈ E(D'), then (i,j) ∈ E(D').

Hence a (γ)-step that removes (i,j) also removes one of (k,i), (k,j) for every common in-neighbour k, and
one of (i,k), (k,j) for every intermediate k. A step can remove a single pair only if that pair has no
common in-neighbour and no intermediate slot.

*Proof.* First, ū_ki[ū_ij] is defined on Y_k. For y ∈ Y_k, ū_ki(y) is read off a datum d with
y ∈ FV(d|k), so FV(ū_ki(y)) ⊆ FV(d|i) ⊆ Y_i = dom ū_ij.
(a) For d' ∈ D', d'|j = (d'|i)[ū_ij] = ((d'|k)[ū_ki])[ū_ij] = (d'|k)[ū_ki[ū_ij]] (composition of
substitutions, as in Lemma 1.2(i)). Here k is a slot and j ∈ A.
(b) By (a) on D and uniqueness (Lemma 1.3(i)), ū_kj = ū_ki[ū_ij] on Y_k. Let q ∈ D' \ D. The
D'-substitutions of (k,i) and (k,j) restrict to the forced D-substitutions, and the domains are
unchanged. So q|i = (q|k)[ū_ki] and q|j = (q|k)[ū_kj] = (q|k)[ū_ki[ū_ij]] = ((q|k)[ū_ki])[ū_ij]
= (q|i)[ū_ij]. Moreover FV(q|i) ⊆ Y_i(D') = Y_i(D). So Eq(i, j, ū_ij) holds on D'.
(c) Apply (a) to D'. Its substitution ū_ik[ū_kj] equals ū_ij on D by uniqueness. ∎

*Computed* (e13): 587 composition instances, and 935 instances each of (b) and (c), 240 of them in steps
that removed some pair; no failure.

**Remark (where the difficulty of F.7 sits; proved, elementary; not used).** Inside a phase in which C and
Y are fixed, give each surviving pair (σ, r) its forced ū_σr. On the node set
V := A ∪ {(σ, ū_σr)}, the relation "same value in every datum" is an equivalence relation, where the value
of a node (σ, ū) in d is (d|σ)[ū] and the value of r is d|r. It refines with each datum, and (σ, r)
survives iff (σ, ū_σr) ≡ r. So a phase has fewer than |V| (γ)-steps. This is linear when every slot uses
O(1) distinct substitutions, but |V| can be of order n², and phases are separated by up to n + Σb
(α)/(β)-steps.

**Corollary F.2 (finite elasticity; proved).** The class {inst(T) : T ∈ DT°} has finite elasticity (no
infinite w_0, w_1, … and T_1, T_2, … with {w_0..w_{n−1}} ⊆ inst(T_n) ∌ w_n): such a sequence has
w_n ∉ Acc({w_0..w_{n−1}}) for n ≥ 1, so its length is bounded by Thm F with d = w_0.

**Proposition F.3 (infinite thickness; proved, computed).** s = ∀x(0=0) ∧ (0=0) lies in
inst(∀x P(x) ∧ P(t)) for every closed term t (P := λz.(0=0)), and these instance sets are pairwise
different (P := λz.(z=z) gives ∀x(x=x) ∧ (t=t), which lies in the t-template only). So DT° does not have
finite thickness; the prior suspicion (vacuous value + derived occurrence with arbitrary argument) is
confirmed, but it does not hurt identification, by F.2.

**Corollary F.4 (unions of at most k templates; known + proved; lower bound made explicit in revision).**
- (i) By Wright (1989), with the correction of Motoki, Shinohara and Wright (1991), finite elasticity is
  preserved under unions of at most k members. So H_k(DT°) = {⋃_{l≤k} inst(T_l)} has finite elasticity.
  Hence every target in H_k(DT°) has a finite anchor (parent prop:imitation:elastic): if some target had
  none, one could build an infinite elastic sequence. And the cautious verifier over H_k(DT°) is sound at
  all times and exact from some finite time on every text for the target.
- (ii) Lower bound. The parent theorem thm:caution:untagged(i) is stated for a term signature with a k-ary
  p, a unary g and a constant c. Over sentences:
  - if the signature has a k-ary relation symbol P, a unary function symbol g and a constant c, the
    parent's chain transfers verbatim with P in place of p, and Esc(H_k(DT°); N) ≥ ⌊(N−1)/k⌋^k;
  - over the arithmetic signature (=, +, S, 0), encode P(t_1, …, t_k) := (t_1 + (t_2 + ⋯ + t_k)) = 0,
    with overhead k + 1 symbols instead of 1. Then Esc(H_k(DT°); N) ≥ (⌊(N−1)/k⌋ − 1)^k for N ≥ 2k + 1.

  The exponent k survives the encoding; the constants change. (notes.md cited ⌊(N−1)/k⌋^k without the
  encoding step.)

*Proof of (ii), encoded form.* Let n + 1 := ⌊(N−1)/k⌋ − 1 ≥ 1. The queries are
q_a := (S^{a_1}0 + (⋯ + S^{a_k}0)) = 0 for a ∈ {0, …, n}^k, ordered by non-increasing Σ_j a_j. Each has
size k + 1 + Σ_j (a_j + 1) ≤ k + 1 + k(n + 1) ≤ N. All are instances of the DT° target
(x_1 + ⋯ + x_k) = 0, whose metavariables are 0-ary term metavariables.

Every earlier query a' has a'_j ≥ a_j + 1 for some j. Otherwise a' ≤ a componentwise with a' ≠ a, so
Σa' < Σa, a contradiction. Hence the earlier queries lie in ⋃_j inst(T_j), where
T_j := (x_1 + ⋯ + S^{a_j+1}(x_j) + ⋯ + x_k) = 0 ∈ DT°, and this union misses q_a. So
q_a ∉ Acc_{H_k}(earlier queries); the first query is escalated because Acc(∅) = ∅. With a k-ary P, the
same proof works with P(…) and overhead 1. ∎

*Computed* (`python3 e16_union_lower_bound.py` → `e16_union_lower_bound.out`):
- (k, n+1) = (1, 6), (2, 3), (2, 4), (3, 2) give (n+1)^k = 6, 9, 16, 8 escalations on sentences of size
  ≤ N = 8, 9, 11, 10;
- in each case (⌊(N−1)/k⌋ − 1)^k = (n+1)^k, and all queries are honest;
- each step is certified by the explicit k-union and, for the first 12 steps, by the brute-force union
  verifier.

**Proposition F.5 (explicit untagged anchors; proved; corrected for ground members in revision).** Let the
target be ⋃_{i≤k'} inst(T_i*) with k' ≤ k and T_i* ∈ DT°. For T* let Fail(T*) be the family of sets of
substitutions
- F_{σ,h} = {θ : root((T*θ)|σ) = h};
- F_{M,m} = {θ : z_m ∉ θ(M)};
- F_{σ,r,ū} = {θ : (T*θ)|r = ((T*θ)|σ)[ū]}, for non-valid pairs (σ, r).

Let Θ_i = {θ : T_i*θ ∈ D}. Suppose that, for each i, Θ_i is not contained in the union of any j ≤ k members
of Fail(T_i*), **j = 0 included**: that is, Θ_i ≠ ∅ and Θ_i is not covered by k members of Fail(T_i*).
Then D is an anchor for the union in H_k(DT°). For a ground T_i* (a single axiom), Fail(T_i*) = ∅, and the
condition says exactly that the axiom itself is among the data.

*Proof.* Let ⋃_{l≤k} inst(T_l) ⊇ D. Assign each datum of Θ_i to some T_l covering it. This splits Θ_i
into at most k nonempty parts, and into at least one part since Θ_i ≠ ∅. Suppose no part were an anchor
for inst(T_i*). Then each part would fail (R\*), (N) or (U) (Thm D, "if" half, contrapositive; a nonempty
part of a ground template is always an anchor), i.e. lie in a member of Fail(T_i*). So Θ_i would be
covered by at most k members, contrary to the hypothesis. Hence some part is an anchor, and its template
contains inst(T_i*). ∎

notes.md omitted Θ_i ≠ ∅. For ground members its hypothesis then held vacuously with no datum of the
axiom, and the conclusion fails. Computed (`python3 e15_ground_union.py` → `e15_ground_union.out`), with
target Ind ∪ {Extensionality} and k = 2:
- with 3 Ind data and no Extensionality datum, the union verifier rejects Extensionality;
- with Extensionality added to the data, it accepts it, and it accepts fresh Ind instances in both cases.

For a single formula metavariable, Fail reduces to "all roots equal f" and "argument m unused" (Cor D.2),
which is exactly the failure family of the prior untagged PA analysis. Prop F.5 uses only the "if" half of
Thm D, so it needs no richness assumption.

**Proposition F.6 (the untagged cautious verifier reduces to the single-template one; proved).** For a
finite D and k ≥ 1, q ∈ ⋂{U ∈ H_k(DT°) : D ⊆ U} iff for every partition of D into at most k nonempty
blocks some block B has q ∈ Acc(B). Hence the cautious verifier over H_k(DT°) is decidable, in time
(number of partitions of D into ≤ k blocks) × poly (by Thm C).

*Proof.* A k-union ⋃_l inst(T_l) covers D iff some partition of D into ≤ k blocks has each block covered
by its own T_l (blocks may be empty; an empty block's template is unconstrained). For a fixed partition,
"q ∈ ⋃_l inst(T_l) for all choices of covering T_l" is, by independence of the choices,
"q ∈ Acc(B_l) for some l". Here Acc(∅) = ∅, because two distinct ground templates have disjoint instance
sets. ∎

This test ranges over the partitions of D, exponentially many. **This track gives no efficient untagged
verifier for k ≥ 3, and §10 (Theorem H) shows that none exists unless P = NP**: the problem is
coNP-complete for every fixed k ≥ 3. For k = 2 there is a polynomial algorithm (Thm H.2).

*Computed* (`python3 e9_union.py` → `e9_union.out`). Unlabeled data: 3 instances of PA induction (motives
x=x, ¬x=0, ∀y y=x) and 3 of ∈-induction (motives x∈a, ¬x∈x, ∃u u∈x), mixed. The union verifier of Prop
F.6 over H_k(DT°):
- k = 1 (target not realizable): accepts the false s* = (0=0 ∧ ∀x(x=x → Sx=Sx)) → ∀x x=0 and two other
  non-instances;
- k = 2 and k = 3: accepts all five fresh instances tried (Ind(x+0=x), Ind(∃y y=Sx), Ind(x=0 → 0=x),
  ∈-Ind(x∈b ∧ b∈x), ∈-Ind(∀y y∈x)) and rejects s*, a mixed Ind/∈-Ind sentence and an ∈-Ind-shaped
  non-instance.

For k = 2 this is predicted by Prop F.5: three roots per schema cannot be covered by two root-failure
sets. For k = 3, Prop F.5's sufficient condition fails for each schema separately, but the cross-schema
interaction still forces exactness on these queries. The referee reproduced this with independent code
(`referee_checks/t8_union.out`).

*Computed* (`python3 e6_escalation.py 60 5` → `e6_escalation.out`): along every greedy adversarial chain
the potential (|C|, Σ_σ(b(σ) − |Y_σ|), |E|) strictly decreased lexicographically at each escalation, and
the chains stayed far below the bound (§11).

---------------------------------------------------------------------------------------------------

## 9. Theorem G (complexity of the version space) — proved

**Proposition G.1 (polynomial parts).** Matching and generality: linear (Thm A). Listing the D-features,
deciding q ∈ Acc(D): polynomial (Cor C.1). Deciding whether D is an anchor for a *given* T*: polynomial
(compute (R\*), (N), (U); |U(T*)| ≤ |Occ|·|T*| pairs, each decided by Lemma 1.3 in O(Σ|d|)).

**Proposition G.2 (exponentially many minimal templates; proved, computed).** Let C_n be the
conjunction of n copies of 0=0 and D_n = {∀x(x=x) ∧ C_n, ∀x(0=0) ∧ C_n} (total size 8n + 8).
Then |Min(D_n)| = 4^n.
*Proof.* C(D_n) = ∀x(□ = □) ∧ C_n; the two slots have column (x, 0) and Y = {x}; the D_n-features are the
two slot-to-slot equations (ū = x) and, for each of the 2n occurrences of the term 0 in C_n and each slot,
the equation "content = slot content with x := 0". By Thm B(b) a saturated template is the skeleton with
f(x) at both slots (merged, as minimality requires) and, at each of the 2n zeros, either the rigid 0 or
the derived f(0); distinct choices A ≠ B give incomparable templates (the instance f := λz.Sz has S0
exactly at the positions in A), and none of them has a proper specialization that still covers D_n (f's
values x and 0 have different roots). ∎ Computed: |Min| = 4, 16, 64 for n = 1, 2, 3 from Sat(D)
(`e2_examples.out`), and 4, 16 for n = 1, 2 by brute force. Acc(D_n) is nevertheless decided in
polynomial time (Thm C): it is {∀x(t(x) = t(x)) ∧ C_n : t[0/x] = 0}, which is D_n itself (t ∈ {x, 0}).

**Proposition G.3 (existence of an lgg is polynomial; proved, computed).** D has a least covering
template iff (i) no Eq-feature of D has r ∈ C(D), and (ii) in the directed graph on slots(D) with an edge
σ → r for every slot-to-slot Eq-feature, every weakly connected component K has a *source* s ∈ K with
s → x for all x ∈ K∖{s}. Then the lgg is T_all: C(D) with M_K(Y_s) at the source s of each component and
M_K(ū_{s,x}) at its other slots x.
*Proof.* (⇐) T_all ∈ DT° covers D. For q = T_allθ: Sym and Scope hold (FV(ū_{s,x}) ⊆ Y_x since ū_{s,x} is
read off data at x). For a feature (σ, r, ū) (both slots by (i), same component K):
q|r = θ(M_K)[ū_{s,r}] and q|σ[ū] = θ(M_K)[ū_{s,σ}[ū]]; on D both ū_{s,r} and ū_{s,σ}[ū] solve the (s, r)
equation, so they coincide (Lemma 1.3(i)). So inst(T_all) ⊆ Feat(D) = Acc(D) ⊆ inst(T_all). Syntactic
leastness: for covering U take a saturated U' ≤ U (Thm B) and map each metavariable K of U' with pattern
slot σ_K to λz̄.T_all|σ_K[z̄/ȳ]; each other occurrence of K at r gives a D-feature (σ_K, r, t̄), so r is a
slot by (i), in the same component, and T_all|r = T_all|σ_K[t̄] by forcing; so U'σ = T_all.
(⇒) Let T_ℓ be least. T_ℓ ≤ T_0 makes every position of C(D) rigid in T_ℓ. If a feature (σ, r, ū) had
r ∈ C(D), then T_ℓ ≤ T_φ would give T_ℓ|σ = τ(M_σ)[Y_σ], an occurrence N(t̄) (σ is a slot and its parent is
rigid), hence T_ℓ|r = N(t̄'[ū]), an occurrence at a rigid position: contradiction. So all occurrences of
T_ℓ are at slots and each slot is an occurrence. The same argument shows that a feature σ → r makes σ
and r occurrences of the same metavariable; for a metavariable N with pattern occurrence s, s → x holds
for every other occurrence x (T_ℓ covers D), so N's occurrences form one component with source s. ∎
Prior C8.1 (G1/G2) is the case where (ii) fails; G.2's D_n is the case where (i) fails.

**Corollary G.4 (an anchor determines its template, in polynomial time; proved).** Under (Rich), if D is
an anchor for inst(T*) in DT°, then T* is the least covering template of D (up to renaming), and the
construction of Prop G.3 returns it in polynomial time. *Proof.* By Thm D, (R\*), (N), (U) hold, so
C(D) = skel(T*), slots(D) = Occ(T*), and every Eq-feature is a valid pair (σ, r): r is an occurrence of the
same metavariable. So no feature lands in C(D) (condition (i)), and the slot graph has an edge σ → r only
between occurrences of one metavariable, with every pattern occurrence s of M satisfying s → x for all
occurrences x of M (condition (ii)). T_all puts M_K(Y_s) at s and M_K(ū_{s,x}) = M_K(t̄_x) at x (forcing), so
T_all is T* up to renaming. ∎ This generalizes prior C4 ("T_ind is the lgg of every anchor") to all of DT°;
it is the polynomial case of question (g): once the data contain an anchor, the version space has a least
element and it is computed in polynomial time.

**Open (g).** Whether Min(D) can be enumerated with polynomial delay; whether counting |Min(D)| is
#P-hard; the complexity of the size-bounded classes DT°_s (prior C6.2 shows that these matter for
soundness). Everything the *single-template* verifier needs is polynomial. Hardness appears with unions
(the cautious verifier over H_k(DT°) is coNP-complete for fixed k ≥ 3) and with negative data (the DTRC
step-2 refutation test is NP-complete): see §10.

---------------------------------------------------------------------------------------------------

## 10. Theorem H (untagged learning: complexity of the union verifier and of the refutation test) — proved; computed (new in revision)

This section answers the referee's "missing" item 3. Write Acc_k(D) := ⋂{U ∈ H_k(DT°) : D ⊆ U}, the
cautious verifier over unions of at most k DT° templates. By Prop F.6, q ∉ Acc_k(D) iff D has a partition
into at most k blocks B with q ∉ Acc(B), where Acc(∅) = ∅. So "q ∈ Acc_k(D)" is in coNP for every k: a
certificate of non-membership is a partition, and each block is checked by Thm C.

**Lemma H.1 (q-relative failure types; proved).** Fix a sentence q. Say that d *agrees with q above p* if
every strict ancestor of p is a position of d with the same root symbol as in q; then p is a position of
d. For a nonempty finite set B of sentences, q ∉ Acc(B) iff B fits one of the following *types*, all
indexed by positions of q:
- **Sym(p, h)**, with h ≠ root(q|p): every d ∈ B agrees with q above p and has root h at p.
- **Scope(σ, y)**, with y ∈ FV(q|σ): every d ∈ B agrees with q above σ, and y ∉ FV(d|σ).
- **Eq(σ, r)**, with σ ⊥ r of the same sort. Every d ∈ B agrees with q above σ and above r. For each
  d ∈ B, the matcher e_d exists: the partial map on FV(d|σ) with d|r = (d|σ)[e_d] (Lemma 1.3). The e_d
  (d ∈ B) are pairwise compatible. And either e_q does not exist, or e_q is incompatible with e_d for some
  d ∈ B.

There are at most |q|·(|Σ_D| + 2·b_max(q)) + |q|² types, where Σ_D is the set of non-index symbols
occurring in D, and b_max(q) is the binder depth of q (an index root at p is one of the < b(p) indices).
For each type, the condition on B is a conjunction of:
- B ⊆ a fixed set;
- B is a clique of a fixed compatibility graph (Eq-types);
- B meets a fixed set of *witnesses* (only for Eq-types where e_q exists).

*Proof.* (⇒) Since q ∉ Feat(B), q lacks some B-feature. Take the first applicable case.
- q lacks Sym(p) for some p ∈ C(B). Let p' be the topmost position on the path to p where q's root differs
  from B's common root h'. Its strict ancestors agree with q, so p' is a position of q, and B fits
  Sym(p', h').
- q has every Sym feature but lacks Scope(σ). The strict ancestors of σ lie in C(B) with q's symbols.
  Take y ∈ FV(q|σ) ∖ Y_σ(B); B fits Scope(σ, y).
- q has every Sym and Scope feature but lacks Eq(σ, r, ū). The ancestors of σ and r agree with q. Each
  e_d exists and is the restriction of ū to FV(d|σ), so the e_d are pairwise compatible. Also
  FV(q|σ) ⊆ Y_σ(B) = dom ū and q|r ≠ (q|σ)[ū]. So either e_q does not exist, or e_q(y) ≠ ū(y) for some
  y ∈ FV(q|σ) ⊆ Y_σ(B), and ū(y) = e_d(y) for some d with y ∈ FV(d|σ). B fits Eq(σ, r).

(⇐) By induction on the size of q|σ (resp. q|p). In every case the named positions lie in A(B), because
their strict ancestors lie in C(B) with q's symbols.
- **Sym(p, h).** Then p ∈ C(B), so Sym(p) is a B-feature, and q lacks it.
- **Scope(σ, y).**
  - If σ is a slot of B, Scope(σ) is a B-feature that q lacks, since y ∉ Y_σ(B).
  - If σ ∈ C(B) with common root g, and q's root at σ differs, Sym(σ) fails.
  - Otherwise g is not an index: g = y would put y into every FV(d|σ), and another index would give
    FV(q|σ) = {g} ∌ y. So y occurs (shifted, if g binds) in some child q|σ·i. B fits Scope(σ·i, y'),
    where y' is the shifted index, and induction applies.
- **Eq(σ, r).**
  - *σ is a slot of B.* Let ū := ⋃_{d∈B} e_d on Y_σ(B); it is well defined by compatibility. Then
    Eq(σ, r, ū) is a B-feature (σ ⊥ r, r ∈ A(B), same sort). q has it only if FV(q|σ) ⊆ Y_σ(B) and
    q|r = (q|σ)[ū], i.e. only if e_q exists and e_q ⊆ ū. The type excludes this.
  - *σ ∈ C(B) with common root g, and q's root at σ differs.* Then Sym(σ) fails.
  - *g is an index, free at σ.* Then d|r = e_d(g) for each d, and compatibility makes all d|r equal to one
    term u. So r and all positions below it in u lie in C(B). Since q|σ = g, e_q exists with
    e_q(g) = q|r, and the type forces q|r ≠ u. So a Sym feature fails at some position of u.
  - *g is a non-index symbol f.* Then every d|r = (d|σ)[e_d] has root f, so r ∈ C(B), and if q|r has
    another root, Sym(r) fails. Otherwise pass to the children. For each child i, the restricted matchers
    e_d^(i) exist and are pairwise compatible; under a binder, the local index is mapped to itself. The
    failure of e_q (non-existence, or incompatibility with some e_d) shows up at some child i, with some
    index z free in q|σ·i, as one of: q's child matcher does not exist; q's child matcher maps z to a
    wrong value (for the local index z, a value other than itself); or two children of q disagree on z.
    - If some d ∈ B has z free in d|σ·i, compatibility fixes the correct value, and B fits
      Eq(σ·i, r·i). In the disagreement case, choose the child whose value is wrong.
    - Otherwise B fits Scope(σ·i, z).

    Induction applies in both cases. ∎

**Theorem H.2 (two schemas: polynomial; proved, computed).** For k ≤ 2, "q ∈ Acc_k(D)" is decidable in
polynomial time.

*Proof.* k = 1 is Thm C. For k = 2: q ∉ Acc_2(D) iff q ∉ Acc(D), or there are types τ_1, τ_2 (Lemma H.1)
and a partition D = B_1 ⊔ B_2 with B_l fitting τ_l.

Fix (τ_1, τ_2) and, for Eq-types that need one, witnesses w_l ∈ B_l (|D|² choices). Then "B_l fits τ_l"
is a conjunction of clauses with at most two literals in the variables x_d ("d ∈ B_1"):
- d ∉ allowed_1 ⇒ ¬x_d;
- d ∉ allowed_2 ⇒ x_d;
- d, d' incompatible for τ_1 ⇒ ¬x_d ∨ ¬x_{d'};
- d, d' incompatible for τ_2 ⇒ x_d ∨ x_{d'};
- x_{w_1} and ¬x_{w_2}.

2-SAT is solvable in linear time (Aspvall–Plass–Tarjan 1979), and there are polynomially many tuples
(τ_1, τ_2, w_1, w_2). The algorithm first checks q ∈ Acc(D) (Thm C). After that, a satisfying assignment
with an empty block cannot occur: it would make D itself fit a type, i.e. q ∉ Acc(D) by Lemma H.1. So
every solution is a genuine 2-partition. ∎

**Theorem H.3 (three or more schemas: coNP-complete; proved, computed).** For every fixed k ≥ 3, deciding
q ∈ Acc_k(D) is coNP-complete.

*Proof.* Membership: see above. Hardness: reduction from graph k-colourability, which is NP-complete for
each fixed k ≥ 3 (Karp 1972; Garey–Johnson–Stockmeyer 1976).

*Construction.* Let G = (V, E), V = {1, …, n}, E = {e_1, …, e_m}, each edge oriented as
e = (tail, head). Under m binders ∀y_1…∀y_m:
- tup_u := t_{u,1} + (t_{u,2} + (⋯ + (t_{u,m} + 0))), with t_{u,i} = y_i if u ∈ e_i and 0 otherwise;
- c_u is the substitution y_i ↦ 0 if u is the tail of e_i, and y_i ↦ S0 if u is its head;
- d_u := ∀y_1…∀y_m (S^u(tup_u) = 0 ∧ S^u(tup_u[c_u]) = 0);
- q := ∀y_1…∀y_m (S^n(0) = 0 ∧ S^(n+1)(0) = 0).

Write σ_w and r_w for the positions at S-depth w in the left-hand sides of the first and the second
conjunct. The size is O(n(n + m)).

*Claim: for nonempty B ⊆ D, q ∉ Acc(B) iff the vertices of B form an independent set of G.* Hence
q ∉ Acc_k(D) iff V partitions into at most k independent sets, iff G is k-colourable.

(Independent ⇒ q ∉ Acc(B).)
- If |B| = 1: Acc({d_u}) = {d_u} ∌ q.
- If |B| ≥ 2: let w be the least vertex of B. Every d_u ∈ B has S at depths < w on both sides. At depth w,
  d_w has root + and the others have S. So σ_w and r_w are slots of B.
- For u ∈ B, d_u|r_w = S^(u−w)(tup_u[c_u]) = (d_u|σ_w)[c_u]. B is independent, so no y_i is free in two
  members. Hence the restrictions of the c_u to the free indices are compatible, and their union ū makes
  Eq(σ_w, r_w, ū) a B-feature.
- q|σ_w = S^(n−w)(0) and q|r_w = S^(n+1−w)(0) are closed and different, so q lacks this feature.

(B contains an edge {u, v} ⇒ q ∈ Acc(B).) Acc is monotone in the data, so it suffices to show
q ∈ Feat({d_u, d_v}). Let w = min(u, v); then
C({d_u, d_v}) = ∀^m(S^w(□) = 0 ∧ S^w(□) = 0), with slots σ_w and r_w.
- q has every Sym feature, since n > w, and every Scope feature, since its contents there are closed.
- Eq features with source σ_w:
  - (σ_w, r_w): the edge's index y_e is free at σ_w in both data, and c_u(y_e) ≠ c_v(y_e) (0 for the
    tail, S0 for the head). So there is no common ū.
  - (σ_w, p) for the other admissible term positions p ⊥ σ_w: these are the right-hand 0's and the S-chain
    positions of the second conjunct above r_w. The datum with vertex w has root + at σ_w (and so after
    any substitution), while these positions carry 0 or S.
- Eq features with source r_w: its scope is empty (the c_u are closed), so they are equalities. The
  datum with vertex w has root + at r_w. The other candidates carry 0 or S, except σ_w, which contains a
  free index while r_w is closed.

So the only {d_u, d_v}-features are Sym and Scope features, and q has them. ∎

**Theorem H.4 (k in the input; binder-free data; proved, computed).**
- (i) If k is part of the input, deciding q ∈ Acc_k(D) is coNP-complete. This holds already for
  quantifier-free data over ∧, =, S, 0; all covering templates involved are first-order patterns.
- (ii) For binder-free D and fixed k, the problem is polynomial.

*Proof.* (i) Reduction from Set Cover (Karp 1972). Take a universe {1, …, n}, sets F_1, …, F_t and a
bound k. Let d_u := ⋀_{j≤t} (c_{uj} = 0), with c_{uj} = 0 if u ∈ F_j and S0 otherwise, and
q := ⋀_{j≤t} (S0 = 0).

If some u lies in no F_j, then d_u = q ∈ D and there is no cover; consistently, q ∈ Acc_k(D). Otherwise
read off the types of q (Lemma H.1). Let ℓ_j be the left-hand side of conjunct j: data have root 0 or S
there, q has S.
- Sym(ℓ_j, 0) has allowed set exactly {d_u : u ∈ F_j}.
- No other Sym-types exist: below an S at ℓ_j, data and q both have 0. No Scope-types exist (no indices).
- An Eq-type needs e_q to fail, i.e. q|σ ≠ q|r. Compatible types (q|σ = q|r) are void, since all
  matchers are empty maps.
- The pairs with q|σ ≠ q|r and data able to satisfy d|σ = d|r are (ℓ_j, a 0-position), (a 0-position,
  ℓ_j), and (ℓ_j·1, ℓ_{j'}) with u ∉ F_j. All of them force d|ℓ_{j'} = 0 for some j' (j' = j in the first
  two), so their allowed sets lie inside some {d_u : u ∈ F_{j'}}.
- Formula-sort pairs are void: an equation never equals a conjunction.

So a block fails iff it lies inside some {d_u : u ∈ F_j}. Hence q ∉ Acc_k(D) iff k of the sets cover the
universe.

(ii) For binder-free D every matcher e_d is the empty map. So every Eq-type has no incompatible pairs, and
needs no witness unless e_q exists; in that case e_q is compatible with every e_d = ∅, and the type is
void. So every type has the form "B ⊆ allowed(τ)", a downward-closed fixed set, and there are polynomially
many. Then q ∉ Acc_k(D) iff D is covered by at most k allowed sets, which is decided by trying all
k-tuples. ∎

**Theorem H.5 (the refutation test of DTRC step 2 is NP-complete; proved, computed).** Problem: given a
finite set D and a finite set R of sentences (the refuted instances found so far), decide whether some
T ∈ Min(D) has inst(T) ∩ R = ∅.
- (i) This holds iff some covering T ∈ DT° has inst(T) ∩ R = ∅, iff some saturated covering template
  does. The problem is in NP.
- (ii) It is NP-hard, already for |D| = 2 with one binder.
- (iii) It is polynomial when D has an lgg (Prop G.3), since then Min(D) = {lgg}. By Cor G.4 this is the
  case, under (Rich), whenever D contains an anchor of some DT° template; for example, a within-schema
  merge in which one cluster already contains an anchor of the schema.
- A polynomial sufficient condition for blocking a merge: R ∩ Acc(D) ≠ ∅.

*Proof.* (i) A minimal template is saturated (Thm B(c)) and covering. Conversely, if some covering T avoids
R, then some minimal T_m ≤ T (Thm B(c)) has inst(T_m) ⊆ inst(T), so it avoids R; by Thm B(a) the same
holds with "saturated". A saturated template is determined by an occurrence set Q ⊆ A(D) and a pattern
slot per metavariable (Thm B(b)). This is a certificate of polynomial size, and it is checked by matching
(Thm A).

(ii) Reduction from CNF-SAT. Take variables x_1, …, x_n and distinct parameters a_1, …, a_n. Let
D = {d_1, d_2} with d_1 := ∀x ⋀_j (x = a_j) and d_2 := ∀x ⋀_j (a_j = a_j).

*The D-features.* C(D) is everything except the left-hand sides σ_j (column (x, a_j), scope {x}); the
right-hand sides z_j carry the rigid a_j. Besides Sym and Scope, the D-features are exactly
Eq(σ_j, z_j, x ↦ a_j):
- σ_i → σ_j fails on d_2, since a_i ≠ a_j;
- σ_i → z_j would need a_i = a_j;
- there are no formula slots.

*Min(D).* By Thm B(b), an occurrence at a position of C(D) must be derived via a feature, and features
land only at the z_j. So the saturated covering templates are T_A := ∀x ⋀_j (f_j(x) = ζ_j) for A ⊆ [n],
with ζ_j = f_j(a_j) for j ∈ A and ζ_j = a_j otherwise. They are pairwise incomparable (f_j := Sz separates
them), so Min(D) = {T_A : A ⊆ [n]}.

*The refuted sentences.* For a clause C let n_C := ∀x ⋀_j γ_j, with
- γ_j = (x = a_j) if x_j does not occur in C;
- γ_j = (Sx = a_j) if x_j ∈ C;
- γ_j = (Sx = S a_j) if ¬x_j ∈ C.

Then n_C ∈ inst(T_A) iff A, read as "x_j is true iff j ∈ A", falsifies C. Indeed, by Thm A the matcher
must take f_j := λz.z where γ_j = (x = a_j), and both choices of ζ_j fit, since z[a_j] = a_j. Where γ_j
has left side Sx, it must take f_j := λz.Sz. Then ζ_j = a_j fits only (Sx = a_j), and
ζ_j = f_j(a_j) = S a_j fits only (Sx = S a_j).

So some T ∈ Min(D) avoids R := {n_C : C ∈ φ} iff φ is satisfiable. The size is O(n·|φ|).

(iii) Prop G.3, Cor G.4, and the definition of Acc: if r ∈ Acc(D) ∩ R, every covering template has r as
an instance. ∎

*Caveat (open).* In this reduction d_1 is not a true sentence. Whether the test stays hard when D consists
of true sentences and R of false ones in a fixed structure, as in DTRC's use of a world oracle, is open.

*Computed.*
- `python3 e11_union_complexity.py S 300`, S = 1, 2 → `e11_union_complexity_seed{1,2}.out`:
  - Lemma H.1 on 600 random cases (mixtures of 1–3 random DT° templates, low-diversity bodies; 3–6 data):
    "q ∉ Acc(B)" equals "B fits a type" on all 118,818 pairs (B ⊆ D nonempty, q). The cases produced
    15,220 Eq-types with non-trivial compatibility graphs.
  - Thm H.2: the 2-SAT verifier equals the brute-force partition verifier on all 5,918 queries. Of these,
    3,276 lie in Acc(D) but are rejected by the H_2 verifier, 36 of them only through an Eq-type whose
    compatibility graph matters.
  - Thm H.3: for K3, C4, C5, K4, the 5-wheel, the Petersen graph and 6 random graphs (n ≤ 10, m ≤ 15),
    q_G ∈ Acc_k(D_G) iff χ(G) > k, for k = 1, …, 4 (brute-force partition verifier). The 2-SAT verifier
    agrees at k = 2, and for n ≤ 7 the claim was checked on all subsets B.
  - Thm H.4: on 25 random set systems, q ∈ Acc_k(D) iff no k sets cover, for all k ≤ t. No binder-free
    Eq-type had incompatible pairs.
- `python3 e14_dtrc_step2.py 1 6 60` → `e14_dtrc_step2.out`:
  - for n ≤ 6, |Sat(D)| = |Min(D)| = 2^n, and these are the T_A;
  - the clause semantics holds for all clauses with ≤ 3 literals and all A;
  - on 60 random CNFs per n, the test (over Min(D), and over all of Sat(D)) equals satisfiability in
    360/360 cases.

**What this means for Q3 / DTRC** (reading of the theorems; the theorems are worst-case statements):
- The exact untagged cautious verifier, i.e. the version space over H_k(DT°) that DTRC offers as an
  optional step 4, is polynomial for k ≤ 2 and coNP-complete for every fixed k ≥ 3. Prop F.6's
  enumeration of partitions is the natural exponential algorithm.
- The refutation test of DTRC step 2 is NP-complete in general. It is polynomial for merges whose union
  has an lgg, in particular whenever the union contains an anchor (under (Rich)).
- Hard instances need clusters whose union has many incomparable minimal templates (as in Prop G.2).
  Whether typical schema data are hard is not addressed.

---------------------------------------------------------------------------------------------------

## 11. Computations (commands and outputs)

All commands are run in this directory with Python 3.11 (`cd` here first). Each takes seconds to a few
minutes; times were measured on a shared, heavily loaded 4-core machine.

The enumerator `dtenum.py` does not use the theory of §§4–6: it enumerates prefixes of the common prefix,
fillers from a term pool and all sharings, and keeps the determinate covering templates. So agreement with
it is an independent check within its bounds. The referee's own code (`referee_checks/`) is a second,
fully independent implementation; its results are summarized in the Verification log (§14).

| command | checks | output | result |
|---|---|---|---|
| `python3 e1_matching.py` | Thm A | `e1_matching.out` | unique matcher 1500/1500; recovery 1500/1500; perturbed queries agree 1500/1500; generality by freezing 400/400; linear timing up to \|s\| = 3.3·10^6 |
| `python3 e2_examples.py` | Thm B on {Ind(x=x), Ind(0=x)}; Prop G.2; Prop F.3; D.4–D.6 | `e2_examples.out` | \|Sat\| = 35, \|Min\| = 4; brute force at size ≤ 24 finds the same 4 and every enumerated template (2749) is above one of them; at size ≤ 23, 8 apparent minima (5 artifacts) as in prior C8.2; \|Min(D_n)\| = 4, 16, 64; thickness witnesses. Re-run in revision: identical up to timings |
| `python3 e3_finitary.py 120 7` | Thm B, Thm C, Prop G.3 vs brute force (random data) | `e3_finitary_seed7.out` | 81 completed cases (of 120: 30 skipped because a Sat-minimal template exceeds the enumeration bounds, 9 with duplicate data): Min(D) agree 81/81; every enumerated covering template above a Sat-minimal one 81/81; Acc = Feat on 5804/5804 queries (4945 accepted); lgg criterion 81/81 |
| `python3 e3_finitary.py 120 8 low` | the same on low-diversity data (many coincidences) | `e3_finitary_seed8_low.out` | 22 completed cases (of 50; the rest skipped for duplicate data or by the size/time guards; C and the lgg criterion were checked on 20 of the 22), with \|Min(D)\| ∈ {1, 2, 4, 8, 9, 16}: Min(D) agree 22/22; every enumerated template above a Sat-minimal one 22/22; Acc = Feat on 1817/1817 queries; lgg criterion 20/20 |
| `python3 e4_anchor_random.py 70 S 2`, S = 11..13; `… 60 14 2` | Thm D vs features vs brute force; wrong candidates | `e4_anchor_random_seed{11,12,13,14}.out` | 248 random (T*, D): prediction = feature truth 248/248; brute force decides 149 and agrees on 144; the other 5 are verified bound artifacts (the referee, with bounds containing T_0 and all T_φ, found no disagreement on 519 decided cases); (R)(N)(D) wrong 27×, (R\*)(N)(D) wrong 17× |
| `python3 e5_specializations.py` | Cor D.1–D.3 | `e5_specializations.out` | FO 571/571 ((R*)(N)(U) ⟺ (R)(D), and = feature truth); Ind 495/495, Separation 495/495, Replacement 498/498, ∈-Ind 491/491 ((R*)(N)(U) ⟺ (R)(N), and = feature truth). Re-run in revision: output identical |
| `python3 e6_escalation.py 60 5` | Thm F (potential strictly decreases; bound) | `e6_escalation.out` | 0 potential violations; all chains within the bound; max chain 2.14·\|d\| |
| `python3 e6b_escalation_structured.py 1` | (γ)-steps on a fixed skeleton | `e6b_escalation_structured.out` | m = 3,4,5,6,8,10,12 slots: 4,5,7,9,13,13,17 kill-steps from 4,11,29,37,61,98,145 initial pairs |
| `python3 e7_rates.py`, `python3 e7b_rates_check.py` | Thm E | `e7_rates.out`, `e7b_rates_check.out` | Monte Carlo P[not anchor] (anchor status by Thm D's events, hence circular as a check of Thm E) is below the bound at every N, up to Monte Carlo error. At N = 24: Ind: Monte Carlo 0.0015 ≤ bound 0.0054 (exact, referee t7: 0.00100); Prop D.4 template: Monte Carlo 0.0050 (20000 runs: 0.00455 ± 0.00048) vs bound 0.00479 (exact 0.00476); Separation: Monte Carlo 0.0210 ± 0.003 vs bound 0.0202 (exact 0.02023; the bound is essentially the exact term (1−ν_a)^N, which is also a lower bound). (notes.md listed the Ind numbers as "0.0054 vs 0.0015", bound first, which read like a violation; it is not one) |
| `python3 e8_counterexamples.py` | D.4, D.5, D.6 by brute force; Thm F lower-bound chains | `e8_counterexamples.out` | brute-force minimal sets equal Sat-minimal sets in all three; the non-anchor witnesses are found; chains of length N+1 with queries of size ≤ N for N = 5, 8, 12, 16; scope-growth chains 6, 18, 38, 66 |
| `python3 e9_union.py` | Prop F.5, F.6 (two schemas, unlabeled) | `e9_union.out` | k = 1 unsound (accepts s*); k = 2, 3 exact on the 8 test queries |
| `python3 e10_rates_revision.py` (new) | Thm E for ground templates; Prop E.2 | `e10_rates_revision.out` | Acc({Ext}) = {Ext}; (1−π)^N ≤ √e e^(−3Nπ/8) on the grid; β^N ≤ exact coincidence probability ≤ \|𝒦\|β^N on all non-valid pairs of 5 laws; referee law: exact P[not anchor] 0.057714, new lower bound 0.057648 (old 0.000655) at N = 8; gap law: β = 1/3 < √(1−κ) = 0.408 |
| `python3 e11_union_complexity.py S 300`, S = 1, 2 (new) | Lemma H.1, Thm H.2, H.3, H.4 | `e11_union_complexity_seed{1,2}.out` | Lemma H.1: 118,818/118,818; Thm H.2 (2-SAT) = brute force 5,918/5,918; colouring reduction correct on 12 graphs for k = 1..4; set-cover reduction correct on 25 instances |
| `python3 e12_c11_refuted.py` (new) | Prop F.8 for general N; C11 refuted for Ind | `e12_c11_refuted.out` | 2 + ⌊(N+1)/5⌋² escalations at sizes ≤ N for 9 values of N; Ind: first datum 41, 61, 81, 101, then 5, 10, 17, 26 escalations; all certified twice |
| `python3 e13_escalation_structure.py 3 40` (new) | Prop F.9, Lemma F.10 | `e13_escalation_structure.out` | binder-free chains ≤ 2n−1, every (γ)-step refines ~; composition 587, (b) 935, (c) 935 instances, 0 failures |
| `python3 e14_dtrc_step2.py 1 6 60` (new) | Thm H.5 | `e14_dtrc_step2.out` | \|Min(D)\| = 2^n = {T_A} for n ≤ 6; test = satisfiability on 360/360 random CNFs |
| `python3 e15_ground_union.py` (new) | Prop F.5 ground correction | `e15_ground_union.out` | without an Extensionality datum, k = 2 rejects Extensionality; with it, accepts |
| `python3 e16_union_lower_bound.py` (new) | Cor F.4(ii) encoding | `e16_union_lower_bound.out` | (n+1)^k = (⌊(N−1)/k⌋−1)^k escalations for (k, n+1) = (1,6), (2,3), (2,4), (3,2), certified |

---------------------------------------------------------------------------------------------------

## 12. Relation to the literature (known; my reading)

- **Plotkin (1970), Reynolds (1970)**: first-order lgg; witness events (R), (D) (parent
  lem:setting:recover). Cor D.1 shows that DT° anchors reduce to these on first-order targets.
- **Huet (1975/76), Huet–Lang (1978)**: second-order matching, finitely many matchers.
  - Baxter (1977) is cited for NP-completeness of second-order matching. This is the usual attribution,
    taken over from the prior notes; neither author nor referee has checked the original (**unverified**).
    Its hardness uses arguments that contain metavariables, so it does not apply to DT° or SO°.
  - Theorem A is the trivial special case of Miller's pattern unification (one pattern occurrence per
    metavariable) followed by evaluation.
- **Miller (1991)**: higher-order patterns, unitary unification. **Pfenning (1991)** and
  **Baumgartner–Kutsia–Levy–Villaret (2017)**: unique lggs for patterns; T_0(D) plus merges of
  renaming-equal columns is that lgg. DT° extends patterns by derived occurrences, and Thm C shows the
  cost: the version space has many minimal elements (Prop G.2), but its intersection is still
  polynomially described by equations ("features").
- **Cerna–Kutsia** (surveys and generic frameworks for higher-order generalization) and
  **Hirata–Ogawa–Harao (2004)** (second-order generalization): non-unitary generalization classes exist.
  I have not checked whether DT° or Thm C appear there (**unsure**).
- **Gold (1967)** and **Angluin (1980)**: identification in the limit. **Wright (1989)** and
  **Motoki–Shinohara–Wright (1991)**: finite elasticity and unions (used in Cor F.4). **Shinohara**: pattern
  languages and elementary formal systems with bounded clauses (finite elasticity of rich classes).
  **Arimura–Shinohara–Otsuki (1994)** study minimal multiple generalizations for unions of pattern
  languages; I have not checked whether their complexity results overlap with Thm H (**unsure**).
- **Lange–Zeugmann**: strong-monotonic learning; anchors are its ⊆-tell-tales (parent paper).
- **Vaught (1967)**: schematic axiomatizability; DT° is a learnable, determinate version.
- Complexity facts used in Thm H (**known**):
  - Karp (1972): Set Cover and chromatic number are NP-complete;
  - Garey–Johnson–Stockmeyer (1976): 3-colourability is NP-complete (k ≥ 3 by adding universal vertices);
  - Cook (1971): SAT is NP-complete;
  - Aspvall–Plass–Tarjan (1979): 2-SAT in linear time.

---------------------------------------------------------------------------------------------------

## 13. Caveats and open problems

- **Richness.** Thm D's "only if" uses (Rich), and Example D.7 shows that it cannot be dropped. Without
  closed terms of two root symbols (e.g. pure set theory without parameters), term-valued metavariables
  are degenerate (λz̄.z_m only), and the anchor condition is strictly weaker than (R\*) ∧ (N) ∧ (U). With
  parameters (closure-normal form) (Rich) always holds. **Open:** the exact anchor condition without
  (Rich).
- **Syntactic vs semantic generality.** Minimality is with respect to ≥. The verifier only uses instance
  sets, and Thms C and D are stated for instance sets. I did not prove that inst(T) ⊇ inst(T') implies
  T ≥ T' in general; it is not needed. **Open.**
- **Parameters** are treated as constants. Data that share a parameter name at the same place yield
  templates that mention it; this is sound but not renaming-invariant. Canonical parameter naming in the
  data, or renaming-closure of the learned set, is a modelling choice left to the method track. **Open**
  as a theory question.
- **Ground templates.** They are handled throughout this revision:
  - one datum is an anchor;
  - Thm E uses c̄ = 1 and λ = 1 for them;
  - Prop F.5 needs Θ_i ≠ ∅.

  They matter for ZFC's single axioms in the untagged setting: a ground axiom is learned only if it is
  itself among the data.
- **Open:**
  - Conjecture F.7: is the equation-kill part of the escalation count linear? The total is Θ(N²) by
    Thm F and Prop F.8, with the quadratic part coming from binder depth. Prop F.9 proves the conjecture
    when all scopes are empty, and Lemma F.10 constrains the general case.
  - polynomial-delay enumeration of Min(D), and counting \|Min(D)\|;
  - size-bounded classes DT°_s (prior C6.2 shows that they matter for soundness);
  - whether Thm H.5 stays NP-hard when D is true and R false in a fixed world;
  - complexity of the union verifier under realistic restrictions, e.g. bounded binder depth with fixed
    k ≥ 3. Thm H.3 uses m binders; for binder-free data and fixed k the problem is polynomial (Thm H.4).
  - lower bounds for the κ-terms with infinite support (Prop E.2(iii) is for finite support).
- **What DTRC can use from this track:**
  - (b)(iii): within-schema merges always have a minimal template below the true template (Thm B(d));
  - the per-cluster verifier is the polynomial feature verifier (Thm C);
  - per-schema anchors are (R\*)+(N)+(U) (Thm D), which for every ZF schema and for PA induction are just
    (R)+(N) (Cor D.3);
  - untagged anchors exist for every k (Cor F.4) and are explicit under Prop F.5, whose condition requires
    every ground axiom to be among the data;
  - the exact untagged verifier is polynomial for k ≤ 2 but coNP-complete for fixed k ≥ 3 (Thm H);
  - the step-2 refutation test is NP-complete in general but polynomial when the merged set has an lgg,
    in particular when it contains an anchor (Thm H.5).

---------------------------------------------------------------------------------------------------

## 14. Verification log (referee report `referee.md` → resolution)

Each referee verdict, the resolution, and where it is now. "Re-run" means that I re-ran code in this
revision. The referee's independent checks are in `referee_checks/` (outputs `t*.out`).

| id | referee verdict | issue raised | resolution | where |
|---|---|---|---|---|
| A (matching) | holds | (d) was labelled "known" but is prior C1(b), proved in the prior session | Relabelled "prior C1(b), proved in the prior session; not a literature result". No change to the mathematics | §2, Thm A(d) |
| R (equivalence = renaming) | holds | none | unchanged | §3 |
| B (finitariness; C8.3 for DT°) | holds | none | unchanged. The referee's `t1_c82.py` independently finds every one of 2771 enumerated covering templates above one of the 4 minimal ones | §4 |
| B-corr (C8.2 correction) | holds | none | unchanged. The referee's `referee_checks/t1_c82.out` and `referee_checks/t1b_c82_prior8.out` confirm exactly 4 minimal templates (3 of the prior 8 genuinely minimal). `e2_examples.py` re-run: identical up to timings | §0, §4 |
| C (Acc = Feat) | holds | none | unchanged. Referee: Feat(D) = brute-force intersection on 125,109 queries over 519 data sets, with enumeration bounds containing T_0 and all T_φ, so the check is exact | §5 |
| D (anchor theorem) | holds | none (the "if" half needs no (Rich), as stated) | Unchanged. Added Example D.7: (Rich) cannot be dropped from "only if" (pure set theory without parameters: T* = ∀x(f(x) ∈ x) has a one-datum anchor although (R\*) fails); this addresses "anchors without (Rich)" in "missing" item 4 partially | §6 |
| D1–D3 (specializations) | holds | none | unchanged. `e5_specializations.py` re-run: output identical. Referee `t4_zf`: 1,169/1,169 and 116/116 | §6 |
| D4–D6 (wrong candidates) | holds | none | unchanged. Referee `referee_checks/t2_hand.out` reproduces all three | §6 |
| E (sample complexity) | holds with fix | (1) Ground templates: c = 0 and λ = min ∅; (b) wrongly claimed exactness at N = 0, and (c) gave 0 to a ground tag without data. (2) The summary claimed "matching lower bounds" for all terms | (1) Fixed. Ground convention c = 0, λ := 1, c̄ := max(c, 1); N ≥ 1 in (a), (b); (c) stated with c̄_i, with an explicit lower bound (1−π_i)^N that is exact for ground tags; proof of (c) checks n_i = 0 and the ground case. Computed: e10 part (1). (2) The matching-lower-bound claim is now restricted to the ρ- and ν-terms. New Prop E.2 gives the κ lower bound β^N and the exact rate for finite support (\|𝒦\| = 1 ⇒ tight; an example with β < √(1−κ)). Computed: e10 parts (2), (3) | §7 |
| F (escalation bound; C11) | holds with fix (framing) | C11 (linear) is refuted, not "proved in quadratic form"; the F.8 lower bound needs a floor for general N | Now stated as "prior C11 (linear) is false, for DT° and DT, universal template and PA-induction target; the quadratic bound holds and is tight". Prop F.8 states 2 + ⌊(N+1)/5⌋², with part (ii) for the Ind target (the referee's t5b construction, credited) and a proof. Computed: e12 (general N, Ind m = 2..5, each step certified by feature verifier and explicit T_0) | §0, §8 (Prop F.8 and the C11 paragraph) |
| F-elastic (thickness, elasticity, unions) | holds with minor fix | the union lower bound ⌊(N−1)/k⌋^k comes from a term-signature theorem and needs an encoding | Cor F.4(ii): verbatim with a k-ary relation symbol; over =, +, S, 0 via (t_1 + ⋯ + t_k) = 0, giving (⌊(N−1)/k⌋−1)^k, with full proof. Computed: e16 | §8 Cor F.4 |
| F5–F6 (explicit untagged anchors; union verifier) | holds with fix | F.5 fails for ground T_i* (Fail = ∅ makes the hypothesis vacuous) | Hypothesis now "Θ_i not contained in the union of any j ≤ k members of Fail(T_i*), j = 0 included" (⇔ Θ_i ≠ ∅ and not covered by k members); proof updated. For a ground axiom the condition says that the axiom is a datum. Computed: e15 shows the failure of the old statement | §8 Prop F.5 |
| G2 (\|Min(D_n)\| = 4^n) | holds | none | unchanged | §9 |
| G3–G4 (lgg criterion) | holds | the summary omitted (Rich) for "lgg = T*" | (Rich) added to the summary table and to every mention of Cor G.4 | §0, §9, §10 |
| F7 (Conjecture F.7) | unclear (correctly a conjecture) | evidence weak; suggested ingredient: transitivity forcing | Kept as a conjecture. Added: Lemma F.10 (the referee's triangle constraints, with a proof, credited), Prop F.9 (proved: conjecture true for empty scopes; binder-free first datum gives ≤ 2n−1), and a Remark locating the difficulty (number of distinct substitutions per slot). Computed: e13 | §8 |

**Points in the referee's §1, item 4 (minor statements):**
- Cor F.4 encoding: done (above).
- The F.8 floor: done (above).
- "(Ind: 0.0054 vs 0.0015 at N = 24)" read like a violation. Rewritten as "Monte Carlo 0.0015 ≤ bound
  0.0054 (exact 0.00100)" (§11).
- The e7 Monte Carlo is circular, since anchor status comes from Thm D's events. This is now stated in §7
  and §11, with the referee's exact check (t7) cited as the non-circular evidence; e10 adds exact
  computations cross-checked against the feature-template test.

**"Missing" items:**
1. *Ground templates.* Done in Thm E (a)–(c), Prop F.5, and §13 (one datum is an anchor; c̄ = 1, λ = 1;
   Θ_i ≠ ∅). Evidence: e10 part (1), e15.
2. *C11 refuted, for DT° and for the Ind target.* Done: §0 ("Corrections"), §8, Prop F.8(ii). It is also
   refuted for DT, since Acc_DT ⊆ Acc_DT°. Evidence: e8, e12, referee t5 and t5b.
3. *Unions: Prop F.6 is exponential; no polynomial test for DTRC step 2.*
   - Now stated explicitly after Prop F.6.
   - Addressed by the new §10 (Theorem H): Lemma H.1 (q-relative failure types); Thm H.2 (k = 2:
     polynomial via 2-SAT); Thm H.3 (each fixed k ≥ 3: coNP-complete, by k-colouring); Thm H.4 (k in the
     input: coNP-complete even for quantifier-free data; binder-free with fixed k: polynomial); Thm H.5
     (the DTRC step-2 test is NP-complete for |D| = 2, polynomial when the merged data have an lgg, in
     particular when they contain an anchor under (Rich); R ∩ Acc(D) ≠ ∅ is a polynomial sufficient
     condition for blocking).
   - Evidence: e11, e14.
   - Remaining open: hardness when D is true and R false in a fixed world; restricted settings
     (bounded binder depth with k ≥ 3).
4. *Open items flagged by the author:*
   - anchors without (Rich): partially addressed (Example D.7: the condition is then strictly weaker; the
     exact condition is open);
   - semantic vs syntactic generality: open;
   - parameter-renaming invariance: open (modelling choice);
   - polynomial-delay enumeration and counting of Min(D): open;
   - size-bounded classes: open;
   - Conjecture F.7: open, with Prop F.9 and Lemma F.10 as partial results.
5. *κ-terms of Thm E without a lower bound.* Done: Prop E.2 (β^N lower bound under (Rich); exact rate β
   for finite support, between β^N and |𝒦|β^N; comparison with √(1−κ)). Evidence: e10.

**Citations (referee §4.5).** Baxter (1977) is now explicitly marked "unverified" (§12).
Hirata–Ogawa–Harao and Cerna–Kutsia remain marked "unsure". The new citations Karp 1972,
Garey–Johnson–Stockmeyer 1976, Cook 1971 and Aspvall–Plass–Tarjan 1979 are standard. Arimura–Shinohara–Otsuki
1994 is marked "unsure" as to overlap.

**Nothing was withdrawn.** Every result of notes.md is retained, corrected where indicated above. Changed
statements: Thm A(d) (label only), Thm E (ground convention, N ≥ 1, c̄, lower bounds), Prop F.5 (Θ_i ≠ ∅),
Prop F.8 (floor; Ind part; C11 framing), Cor F.4 (encoding). New: Example D.7, Prop E.2, Prop F.9,
Lemma F.10 with a Remark, and Lemma H.1 and Theorems H.2–H.5.

**Re-runs in this revision:**
- `e5_specializations.py`: identical output;
- `e2_examples.py`: identical up to timing lines;
- new scripts e10–e16, with outputs saved next to them;
- e11 was also run with seed 3 (100 cases) during development: 0 disagreements; not saved.
