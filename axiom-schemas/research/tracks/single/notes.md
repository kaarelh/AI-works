# Track "single": learning ONE determinate second-order template (class DT°)

Status labels: **proved** (complete proof here), **computed** (script run here; command and output
file named), **known** (literature), **conjecture**, **open**. Scripts and outputs are in this directory
(`/home/user/AI-works/axiom-schemas/research/tracks/single/`); library files are `dtcore.py`
(language, instantiation, matching, subsumption), `dtfeat.py` (common prefix, features, the cautious
verifier, saturated templates, lgg criterion, potential), `dtenum.py` (an *independent* bounded
brute-force enumerator of covering templates, adapted from `prior/induction/so_enum.py`),
`dtwitness.py` (witness events), `dtrandom.py` (random templates and data).

---------------------------------------------------------------------------------------------------

## 0. Results in brief

| # | question | answer | status |
|---|---|---|---|
| (a) | matching a sentence against T ∈ DT° (term and formula metavariables of any arity, parameters) | at most one matcher; computed in time O(\|T\|+\|s\|); generality T ≥ T' is the same test on frozen T' | proved (Thm A); computed (e1) |
| (b)(i) | is every covering template above a minimal one? | **yes**, for every nonempty finite D | proved (Thm B) |
| (b)(ii) | finitely many minimal covering templates? | **yes**: every minimal one is *saturated*, and there are finitely many saturated ones up to renaming; prior conjecture C8.3 is **true for DT°** (false for DT, prior referee) | proved (Thm B); computed (e2, e3) |
| (b)(iii) | if D ⊆ inst(T), T ∈ DT°: is a minimal covering template below T? | **yes** (what the clustering method needs) | proved (Thm B(d)) |
| — | the cautious verifier itself | Acc(D) = set of sentences having every *feature* of D; a polynomial-time test, although \|Min(D)\| can be 4^n | proved (Thm C, Prop G.2); computed (e3, e2) |
| (c) | anchors of inst(T*) in DT° | D is an anchor **iff (R\*) ∧ (N) ∧ (U)**: occurrence-wise root variation, non-vacuity of every argument place, no coincidence (no equation d\|r = d\|σ[ū] holding in all data except the ones T* itself imposes) | proved (Thm D, under a mild richness assumption on the signature); computed (e4, e5) |
| (c) | wrong candidates | (R)+(N)+(D) is insufficient (Prop D.5: ∀x(0=f(x)) with f ↦ 0, f ↦ z); (R\*)+(N)+(U restricted to pattern occurrences) is insufficient (Prop D.4: a coincidence through an *ancestor* of the pattern occurrence) | proved; computed |
| (c) | specializations | first-order patterns: (R)+(D) = Plotkin–Reynolds; any template with one formula metavariable (PA induction, ZF Separation, Replacement, ∈-induction): (R)+(N) | proved (Cor D.1–D.3); computed (e5: 2550 random data sets, 0 disagreements) |
| (d) | unions of ≤ k DT° templates | **finite thickness fails** (infinitely many templates through one sentence), but **DT° has finite elasticity**, so unions of ≤ k have finite elasticity (Wright; Motoki–Shinohara–Wright), every target in H_k(DT°) has a finite anchor, and the cautious verifier over H_k(DT°) is eventually exact on every text. An explicit sufficient anchor condition: per schema, the data are not covered by k "failure sets"; the union verifier reduces to the single-template one over partitions of D | proved (Cor F.2, Prop F.3, Cor F.4, Prop F.5, F.6) |
| (e) | tagged sample complexity | P[D_N not an anchor] ≤ Σ_q (1−ρ_q)^(N−1) + Σ_{M,m} (1−ν_{M,m})^N + Σ_{(σ,r)} (1−κ_{σ,r})^⌊N/2⌋; tagged: P[not exact] ≤ √e Σ_i c_i exp(−3Nπ_iλ_i/8) | proved (Thm E); computed (e7) |
| (f) | escalations of the cautious DT° verifier (prior C11) | after a first datum d: at most \|d\| + Σ_p b(p) + \|d\|(\|d\|−1) escalations against any honest prover; from no data **Esc(DT°;N) = Θ(N²)**: ≤ 2N²+1, and ≥ 2 + ((N+1)/5)² (scope growth through N/5 slots under N/5 binders); with binder depth ≤ b the scope-growth part is ≤ N·b and the rest is conjecturally O(N) | proved (Thm F, Prop F.8); conjecture F.7; computed (e6, e6b, e8) |
| (g) | complexity of Min(D) | Min(D) can have 4^n elements for \|D\| = O(n), so it cannot be output in polynomial time; but membership in Acc(D) is polynomial, an lgg exists iff a polynomial-time checkable condition holds, and then it is computed in polynomial time; once D contains an anchor for T*, the lgg exists and equals T* | proved (Thm C, Prop G.1–G.3, Cor G.4); hardness of *counting* Min(D) open |

Two corrections to the prior notes come out of this:
- **C8.2** reported 8 minimal templates for {Ind(x=x), Ind(0=x)} (search bound: size ≤ 23). In DT° there are
  exactly **4**. One of them has size 24, so the bounded search missed it, and 5 templates above it looked
  minimal; 3 of the reported 8 are genuinely minimal. Computed, `e2_examples.out` (brute force at size
  ≤ 24 finds exactly the 4).
- **SOCL** (prior §2) enumerates Min(D) and intersects. This is exponential in the worst case (Prop G.2).
  It should be replaced by the *feature verifier* of Thm C, which accepts the same set in polynomial time.

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
- (d) (prior C1(b), known) Without determinacy (class SO°: metavariable-free arguments, no pattern
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
covering templates (computed, `e2_examples.out`, §10):
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

*Computed* (`python3 e3_finitary.py 120 7` etc. → `e3_finitary_*.out`, see §10): on random data sets
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

*Computed* (§10, `e4_anchor_random_seed*.out`, `e5_specializations.out`): on random DT° targets with
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
equivalences of Cor. D.1–D.3 held in every case.

---------------------------------------------------------------------------------------------------

## 7. Theorem E (tagged sample complexity) — proved; computed

Let Λ be a law with countable support on ground substitutions for T*, θ_1, θ_2, … i.i.d. ~ Λ and
D_N = {T*θ_1, …, T*θ_N}. Define
- ρ_σ := 1 − max_h Λ(root of (T*θ)|σ = h), for σ ∈ Occ(T*);
- ν_{M,m} := Λ(z_m occurs in θ(M));
- U(T*) := the non-valid pairs (σ, r) of §6, and κ_{σ,r} := Λ⊗Λ{(θ, θ') : no ū satisfies
  (T*θ)|r = ((T*θ)|σ)[ū] and (T*θ')|r = ((T*θ')|σ)[ū]};
- c(T*) := |Occ(T*)| + Σ_M arity(M) + |U(T*)| ≤ |Occ(T*)|·(1 + |T*|) + Σ_M arity(M);
- λ := the minimum of all ρ_σ, ν_{M,m}, κ_{σ,r}.

**Theorem E.** (The upper bounds use only the "if" half of Thm D and need no assumption; the lower bounds
use (Rich).)
- (a) P[D_N is not an anchor] ≤ Σ_σ (1−ρ_σ)^(N−1) + Σ_{M,m} (1−ν_{M,m})^N + Σ_{(σ,r)∈U(T*)} (1−κ_{σ,r})^⌊N/2⌋
  ≤ c(T*)·(1−λ)^⌊N/2⌋, and P[D_N is not an anchor] ≥ max(max_σ (1−ρ_σ)^N, max (1−ν_{M,m})^N).
- (b) λ > 0 iff the (possibly infinite) set {T*θ : θ ∈ supp Λ} satisfies (R\*), (N), (U); then the
  cautious verifier is exact with probability ≥ 1−δ once N ≥ 1 + (2/λ) ln(c(T*)/δ).
- (c) Tagged rules (prior thm:imitation:coupon setting): k templates T_i* ∈ DT°, tag i with probability
  π_i, parameters c_i, λ_i (λ_i ≤ 1). Then P[the per-tag cautious DT° verifier is not exact after N tagged
  steps] ≤ √e Σ_i c_i exp(−3Nπ_iλ_i/8), so N ≥ max_i (8/(3π_iλ_i)) ln(√e·k·c_i/δ) suffices. Order
  1/(π_iλ_i) is necessary in general: P[not exact] ≥ (1 − π_iρ)^N if some head at a pattern occurrence of
  T_i* has probability 1 − ρ.

*Proof.* (a) "Not an anchor" ⊆ ¬(R\*) ∪ ¬(N) ∪ ((R\*) ∧ (N) ∧ ¬(U)) (Thm D). P[all roots at σ equal] =
Σ_h p_h^N ≤ p_max^(N−1) Σ_h p_h = (1−ρ_σ)^(N−1). P[z_m never used] = (1−ν)^N. Under (N), valid pairs
cannot fail (forcing, Lemma 1.3(i)); for a non-valid pair, a coincidence on D_N implies (Lemma 1.3(ii))
that each of the ⌊N/2⌋ disjoint pairs (θ_1,θ_2), (θ_3,θ_4), … fails to refute it; these are independent,
each with probability 1−κ. Union bound. Lower bounds: each single failure event is a non-anchor event.
(b) Each event has positive probability iff some element/pair of the support witnesses it (Lemma 1.3(ii)
for (U)); then use (1−λ)^⌊N/2⌋ ≤ e^{−λ(N−1)/2}. (c) The version space factors over tags (parent
thm:caution:tagged), so P[not exact] ≤ Σ_i c_i E[(1−λ_i)^⌊n_i/2⌋], n_i ~ Bin(N, π_i);
(1−λ)^⌊n/2⌋ ≤ e^{λ/2} e^{−λn/2} ≤ √e e^{−λn/2}, E[e^{−an}] = (1 − π(1−e^{−a}))^N ≤ exp(−Nπ(1−e^{−a})),
and 1 − e^{−a} ≥ 3a/4 for a = λ/2 ≤ 1/2. ∎

For a single formula metavariable (Ind, ZF schemas) U(T*) contributes nothing beyond (R) and (N) (Cor
D.2), and all occurrence events coincide with (R), so the bound is (1−ρ)^(N−1) + Σ_m (1−ν_m)^N; for Ind
this is prior C5(b)'s Σ_f p_f^N + (1−q)^N up to the inclusion–exclusion term.

*Computed* (`python3 e7_rates.py` → `e7_rates.out`): exact ρ, ν, κ for three targets and laws, Monte Carlo
P[not anchor] versus the bound (see §10).

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

This proves prior conjecture C11 in the polynomial form suggested by referee C ("O(|first datum|²)"),
and the quadratic order is attained:

**Proposition F.8 (quadratic lower bound; proved, computed).** Let m ≥ 1, b = m,
d_1 = ∀^b(0=0 ∧ … ∧ 0=0) with m atoms, d_2 the same with every left-hand side replaced by the parameter a,
and for j ≤ m, k < b let q_{j,k} be d_1 with the j-th left-hand side replaced by the k-th bound variable.
In the order d_1, d_2, q_{1,0}, …, q_{1,b−1}, q_{2,0}, …, q_{m,b−1}, every query lies outside the acceptance
set of its predecessors; all are instances of the universal template (a 0-ary formula metavariable), so
this is an honest elastic chain. All have size N = b + 4m − 1 = 5m − 1, so Esc(DT°; N) ≥ 2 + m·b = 2 + ((N+1)/5)².
*Proof.* After d_1, d_2 the left-hand sides are slots with empty scope. q_{j,k} has the index k free at
slot j, and no earlier datum has it there, so q_{j,k} violates Scope(slot j). ∎ Checked for m = 2, 4, 6, 8
(`e8_counterexamples.out`: chains of length 6, 18, 38, 66, every query escalated). So Esc(DT°;N) = Θ(N²).

The quadratic term comes from the scope (β) steps, which need deep binder nesting. What remains open is
whether the equation-kill (γ) steps can be superlinear. Evidence that they cannot: the greedy adversarial search (e6, 60 random
first data of 3–18 positions) found chains of length at most 2.14·n (n = |d|); the ratio chain/bound
was at most 0.71 overall and at most 0.33 for n ≥ 10, and it decreases with n; a structured search (e6b) that fixes the skeleton ∀x(t_1=0 ∧ … ∧ t_m=0), starts from
up to 145 equation pairs among m ≤ 12 slots and greedily kills as few pairs per escalation as it can,
achieved at most 17 kill-steps for m = 12 (about 1.4·m; `e6b_escalation_structured.out`). (Neither
search found the scope-growth chains of Prop F.8, so greedy search is weak evidence.) **Conjecture F.7:**
the number of (γ)-steps is O(n), hence Esc(DT°; N) = O(N·(1 + b_max)) for sentences of binder depth
≤ b_max. The obstacle to a proof is that surviving equation pairs need not form an equivalence relation (Eq features compose like
a preorder, and are closed under a left-cancellation rule), and chains of preorders on m points can have
length of order m².

**Corollary F.2 (finite elasticity; proved).** The class {inst(T) : T ∈ DT°} has finite elasticity (no
infinite w_0, w_1, … and T_1, T_2, … with {w_0..w_{n−1}} ⊆ inst(T_n) ∌ w_n): such a sequence has
w_n ∉ Acc({w_0..w_{n−1}}) for n ≥ 1, so its length is bounded by Thm F with d = w_0.

**Proposition F.3 (infinite thickness; proved, computed).** s = ∀x(0=0) ∧ (0=0) lies in
inst(∀x P(x) ∧ P(t)) for every closed term t (P := λz.(0=0)), and these instance sets are pairwise
different (P := λz.(z=z) gives ∀x(x=x) ∧ (t=t), which lies in the t-template only). So DT° does not have
finite thickness; the prior suspicion (vacuous value + derived occurrence with arbitrary argument) is
confirmed, but it does not hurt identification, by F.2.

**Corollary F.4 (unions of at most k templates; known + proved).** By Wright (1989), with the correction
of Motoki, Shinohara and Wright (1991), finite elasticity is preserved under unions of at most k members.
So H_k(DT°) = {⋃_{l≤k} inst(T_l)} has finite elasticity; hence every target in H_k(DT°) has a finite
anchor (parent prop:imitation:elastic), and the cautious verifier over H_k(DT°) is sound at all times and
exact from some finite time on every text for the target. Lower bounds transfer upward: first-order
unions are DT° unions, so Esc(H_k(DT°); N) ≥ ⌊(N−1)/k⌋^k (parent thm:caution:untagged(i)).

**Proposition F.5 (explicit untagged anchors; proved).** Let the target be ⋃_{i≤k'} inst(T_i*) with
k' ≤ k and T_i* ∈ DT°. For T* let Fail(T*) be the family of sets of substitutions
F_{σ,h} = {θ : root((T*θ)|σ) = h}, F_{M,m} = {θ : z_m ∉ θ(M)}, F_{σ,r,ū} = {θ : (T*θ)|r = ((T*θ)|σ)[ū]}
for non-valid pairs (σ, r). If for each i the set Θ_i = {θ : T_i*θ ∈ D} is not covered
by any k members of Fail(T_i*), then D is an anchor for the union in H_k(DT°).
*Proof.* Let ⋃_{l≤k} inst(T_l) ⊇ D. Assign each datum of Θ_i to some T_l covering it; this splits Θ_i into
≤ k parts. If no part were an anchor for T_i*, each part would fail (R\*), (N) or (U) (Thm D), i.e. lie in a
member of Fail(T_i*); so some part is an anchor, and its template contains inst(T_i*). ∎
For a single formula metavariable, Fail reduces to "all roots equal f" and "argument m unused" (Cor D.2),
which is exactly the failure family of the prior untagged PA analysis. (Prop F.5 uses only the "if" half
of Thm D, so it needs no richness assumption.)

**Proposition F.6 (the untagged cautious verifier reduces to the single-template one; proved).** For a
finite D and k ≥ 1, q ∈ ⋂{U ∈ H_k(DT°) : D ⊆ U} iff for every partition of D into at most k nonempty
blocks some block B has q ∈ Acc(B). Hence the cautious verifier over H_k(DT°) is decidable, in time
(number of partitions of D into ≤ k blocks) × poly (by Thm C).
*Proof.* A k-union ⋃_l inst(T_l) covers D iff some partition of D into ≤ k blocks has each block covered by
its own T_l (blocks may be empty; an empty block's template is unconstrained). For a fixed partition,
"q ∈ ⋃_l inst(T_l) for all choices of covering T_l" is, by independence of the choices, "q ∈ Acc(B_l) for
some l", where Acc(∅) = ∅ because two distinct ground templates have disjoint instance sets. ∎ Making this
efficient for large D (clustering) is the business of the method track.

*Computed* (`python3 e9_union.py` → `e9_union.out`): unlabeled data = 3 instances of PA induction (motives
x=x, ¬x=0, ∀y y=x) and 3 of ∈-induction (motives x∈a, ¬x∈x, ∃u u∈x), mixed. The union verifier of Prop
F.6 over H_k(DT°):
- k = 1 (target not realizable): accepts the false s* = (0=0 ∧ ∀x(x=x → Sx=Sx)) → ∀x x=0 and two other
  non-instances;
- k = 2 and k = 3: accepts all five fresh instances tried (Ind(x+0=x), Ind(∃y y=Sx), Ind(x=0 → 0=x),
  ∈-Ind(x∈b ∧ b∈x), ∈-Ind(∀y y∈x)) and rejects s*, a mixed Ind/∈-Ind sentence and an ∈-Ind-shaped
  non-instance.
For k = 2 this is predicted by Prop F.5 (three roots per schema cannot be covered by two root-failure
sets); for k = 3 Prop F.5's sufficient condition fails for each schema separately, but the cross-schema
interaction still forces exactness on these queries.

*Computed* (`python3 e6_escalation.py 60 5` → `e6_escalation.out`): along every greedy adversarial chain
the potential (|C|, Σ_σ(b(σ) − |Y_σ|), |E|) strictly decreased lexicographically at each escalation; the
chains stayed far below the bound (§10).

---------------------------------------------------------------------------------------------------

## 9. Theorem G (complexity of the version space) — proved

**Proposition G.1 (polynomial parts).** Matching and generality: linear (Thm A). Listing the D-features,
deciding q ∈ Acc(D): polynomial (Cor C.1). Deciding whether D is an anchor for a *given* T*: polynomial
(compute (R\*), (N), (U); |U(T*)| ≤ |Occ|·|T*| pairs, each decided by Lemma 1.3 in O(Σ|d|)).

**Proposition G.2 (exponentially many minimal templates; proved, computed).** Let C_n be the
conjunction of n copies of 0=0 and D_n = {∀x(x=x) ∧ C_n, ∀x(0=0) ∧ C_n} (total size 8n + 8). Then
|Min(D_n)| = 4^n.
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
#P-hard; complexity of the size-bounded classes DT°_s (prior C6.2 shows these matter for soundness). I
found no NP-hardness for any natural decision problem about the unbounded class: everything that the
verifier needs is polynomial.

---------------------------------------------------------------------------------------------------

## 10. Computations (commands and outputs)

All commands are run in this directory with Python 3.11 (`cd` here first); each takes seconds to a few
minutes (times below were measured on a shared, heavily loaded 4-core machine). The enumerator `dtenum.py`
does not use the theory of §§4–6 (it enumerates prefixes of the common prefix, fillers from a term pool
and all sharings, and keeps the determinate covering templates), so agreement with it is an independent
check within its bounds.

| command | checks | output | result |
|---|---|---|---|
| `python3 e1_matching.py` | Thm A | `e1_matching.out` | unique matcher 1500/1500; recovery 1500/1500; perturbed queries agree 1500/1500; generality by freezing 400/400; linear timing up to \|s\| = 3.3·10^6 |
| `python3 e2_examples.py` | Thm B on {Ind(x=x), Ind(0=x)}; Prop G.2; Prop F.3; D.4–D.6 | `e2_examples.out` | \|Sat\| = 35, \|Min\| = 4; brute force at size ≤ 24 finds the same 4 and every enumerated template (2749) is above one of them; at size ≤ 23, 8 apparent minima (5 artifacts) as in prior C8.2; \|Min(D_n)\| = 4, 16, 64; thickness witnesses |
| `python3 e3_finitary.py 120 7` | Thm B, Thm C, Prop G.3 vs brute force (random data) | `e3_finitary_seed7.out` | 81 completed cases (of 120: 30 skipped because a Sat-minimal template exceeds the enumeration bounds, 9 with duplicate data): Min(D) agree 81/81; every enumerated covering template above a Sat-minimal one 81/81; Acc = Feat on 5804/5804 queries (4945 accepted); lgg criterion 81/81 |
| `python3 e3_finitary.py 120 8 low` | the same on low-diversity data (many coincidences) | `e3_finitary_seed8_low.out` | 22 completed cases (of 50; the rest skipped for duplicate data or by the size/time guards; C and the lgg criterion were checked on 20 of the 22), with \|Min(D)\| ∈ {1, 2, 4, 8, 9, 16}: Min(D) agree 22/22; every enumerated template above a Sat-minimal one 22/22; Acc = Feat on 1817/1817 queries; lgg criterion 20/20 |
| `python3 e4_anchor_random.py 70 S 2`, S = 11..13; `… 60 14 2` | Thm D vs features vs brute force; wrong candidates | `e4_anchor_random_seed{11,12,13,14}.out` | 248 random (T*, D): prediction = feature truth 248/248; brute force decides 149, agrees 144, the 5 others are verified bound artifacts; (R)(N)(D) wrong 27×, (R\*)(N)(D) wrong 17× |
| `python3 e5_specializations.py` | Cor D.1–D.3 | `e5_specializations.out` | FO 571/571 ((R*)(N)(U) ⟺ (R)(D), and = feature truth); Ind 495/495, Separation 495/495, Replacement 498/498, ∈-Ind 491/491 ((R*)(N)(U) ⟺ (R)(N), and = feature truth) |
| `python3 e6_escalation.py 60 5` | Thm F (potential strictly decreases; bound) | `e6_escalation.out` | 0 potential violations; all chains within the bound; max chain 2.14·\|d\| |
| `python3 e6b_escalation_structured.py 1` | (γ)-steps on a fixed skeleton | `e6b_escalation_structured.out` | m = 3,4,5,6,8,10,12 slots: 4,5,7,9,13,13,17 kill-steps from 4,11,29,37,61,98,145 initial pairs |
| `python3 e7_rates.py`, `python3 e7b_rates_check.py` | Thm E | `e7_rates.out`, `e7b_rates_check.out` | the Monte Carlo estimate is below the bound at every N, up to Monte Carlo error (Ind: 0.0054 vs 0.0015 at N = 24; Prop D.4 template: 0.00479 vs 0.00455 ± 0.00048 at N = 24, 20000 runs; Separation: bound 0.0202 vs 0.0210 ± 0.003 at N = 24, where the bound is essentially the exact term (1−ν_a)^N, which is also a lower bound) |
| `python3 e8_counterexamples.py` | D.4, D.5, D.6 by brute force; Thm F lower-bound chain | `e8_counterexamples.out` | brute-force minimal sets equal Sat-minimal sets in all three; the non-anchor witnesses are found; chains of length N+1 with queries of size ≤ N for N = 5, 8, 12, 16 |
| `python3 e9_union.py` | Prop F.5, F.6 (two schemas, unlabeled) | `e9_union.out` | k = 1 unsound (accepts s*); k = 2, 3 exact on the 8 test queries |


---------------------------------------------------------------------------------------------------

## 11. Relation to the literature (known; my reading)

- **Plotkin (1970), Reynolds (1970)**: first-order lgg; witness events (R), (D) (parent
  lem:setting:recover). Cor D.1 shows DT° anchors reduce to these on first-order targets.
- **Huet (1975/76), Huet–Lang (1978)**: second-order matching, finitely many matchers; Baxter (1977) for
  NP-completeness of second-order matching (attribution as in the prior notes; not re-checked).
  Theorem A is the trivial special case of Miller's pattern unification (one pattern occurrence per
  metavariable) followed by evaluation.
- **Miller (1991)**: higher-order patterns, unitary unification. **Pfenning (1991)**,
  **Baumgartner–Kutsia–Levy–Villaret (2017)**: unique lggs for patterns; T_0(D) plus merges of
  renaming-equal columns is that lgg. DT° extends patterns by derived occurrences; Thm C shows the cost:
  the version space has many minimal elements (Prop G.2), but its intersection is still polynomially
  described by equations ("features").
- **Cerna–Kutsia** (surveys/generic frameworks for higher-order generalization) and **Hirata–Ogawa–Harao
  (2004)** (second-order generalization): non-unitary generalization classes exist; I have not checked
  whether DT° or Thm C appear there (**unsure**).
- **Gold (1967)**, **Angluin (1980)**: identification in the limit; **Wright (1989)**,
  **Motoki–Shinohara–Wright (1991)**: finite elasticity and unions (used in Cor F.4). **Shinohara**: pattern
  languages / elementary formal systems with bounded clauses (finite elasticity of rich classes).
- **Lange–Zeugmann**: strong-monotonic learning; anchors are its ⊆-tell-tales (parent paper).
- **Vaught (1967)**: schematic axiomatizability; DT° is a learnable, determinate version.

---------------------------------------------------------------------------------------------------

## 12. Caveats and open problems

- **Richness.** Thm D's "only if" uses (Rich). Without closed terms of two root symbols (e.g. pure set
  theory without parameters) term-valued metavariables are degenerate (λz̄.z_m only), and the anchor
  condition becomes weaker. With parameters (closure-normal form) (Rich) always holds.
- **Syntactic vs semantic generality.** Minimality is w.r.t. ≥; the verifier only uses instance sets, and
  Thm C/D are stated for instance sets. I did not prove that inst(T) ⊇ inst(T') implies T ≥ T' in
  general (it is not needed).
- **Parameters** are treated as constants. Data that share a parameter name at the same place yield
  templates that mention it; this is sound but not renaming-invariant. Canonical parameter naming in the
  data, or renaming-closure of the learned set, is a modelling choice left to the method track.
- **Open:** whether the equation-kill part of the escalation count is linear (Conjecture F.7; the total is
  Θ(N²) by Thm F and Prop F.8, the quadratic part coming from binder depth); polynomial-delay enumeration and
  counting of Min(D); refutation-guided clustering (DTRC step 2) needs a test "some minimal covering
  template has no refuted instance", and Min(D) can be exponential — the polynomial feature description of
  Acc(D) does not obviously give such a test; size-bounded classes.
- **What DTRC can use from this track:** (b)(iii) within-schema merges always have a minimal template
  below the true template (Thm B(d)); the per-cluster verifier is the polynomial feature verifier (Thm C);
  per-schema anchors are (R\*)+(N)+(U) (Thm D), which for every ZF schema and for PA induction are just
  (R)+(N) (Cor D.3); untagged anchors exist for every k (Cor F.4) and are explicit under Prop F.5.
