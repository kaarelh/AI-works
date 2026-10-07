# Track "cases": learning ∀xφ from its instances (Q1) and learning the ZF(C) schemas (Q2)

Status labels: **proved** (complete proof here), **computed** (script run here; command and output file named),
**known** (literature; citations I am unsure of are marked "(I believe)"), **conjecture**.
All scripts are in this directory and are run as `cd research/tracks/cases && python3 <script>`; outputs are the
`.out` files of the same name. Library files: `st_core.py` (set-theory templates, de Bruijn, matching, subsumption,
the two first-order encodings, the n-ary higher-order pattern lgg), `st_enum.py` (covering-template enumerators),
`st_pool.py` (bodies φ). The first-order lgg is always the parent report's T1 code
(`inferential-learning/research/theory/T1-code/terms.py`, `lgg_list`).

References to the parent report use its labels (lem:setting:recover = Plotkin's witness lemma, thm:setting:lgg,
lem:setting:guard = most specific guards, lem:imitation:cautious, thm:imitation:anchor, thm:imitation:coupon);
"prior C3, C6.1, C9" refer to `prior/induction/second-order-notes.md`.

---------------------------------------------------------------------------------------------------------------

## 0. Answers in brief

**Q1 (∀xφ from sentences φ(t)).**

1. *What is learned is the instance schema, and plain first-order anti-unification learns it.* The target
   σ_φ = φ(z₁,…,z_k) (term metavariables at the free occurrences of the x_i) is a first-order pattern.
   Data D = {φ(t̄_j)} is an anchor iff lgg(D) ≡ σ_φ iff Plotkin's witness events hold:
   (R_i) the closed terms substituted for x_i do not all have the same root symbol, and (D_{ii'}) for i ≠ i' some
   datum substitutes different terms for x_i and x_{i'} (Thm A2, proved; computed on 141 736 data sets).
   Repeated occurrences of x are tied automatically and need no event; closed subterms of φ that coincide with
   data terms are harmless; one datum is never an anchor; two suffice. The same events characterize anchors in
   the determinate second-order class DT° (Prop A2′; in SO° they do not, by an explicit counterexample). Rates: P[no anchor after N] = Σ_f p_f^N for one variable,
   exact formulas for two, ≤ c·e^{−Nρ} in general (Thm A3; computed against Monte Carlo with the T1 lgg).
2. *The instance schema is not the sentence ∀xφ (the ω-gap).* For a structure M with closed-term substructure
   M₀: "M ⊨ ∀xφ iff M ⊨ φ(t) for all closed t, for every φ" holds iff M₀ ≼ M (Tarski–Vaught; Prop A5). It holds
   in term-generated structures such as (ℕ;0,S,+,·), and fails in ℝ as an ordered field (φ(x) = ¬(x·x = 1+1)), in
   V with closed terms ∅,{·,·},∪ (φ(x) = "x is not inductive", refuted by Infinity), and in nonstandard models of
   PA. Derivability: Q ⊢ 0+n̄ = n̄ for every n, but Q ⊬ ∀x(0+x = x) (explicit model, Ex. A8, proved + computed).
3. *Consequences for a learner (Prop A10, A11).* From closed instances the sound target is the closed-instance
   schema. Whether the cautious learner silently takes the ω-step depends on whether parameters (free names)
   are allowed as instances: if they are, the learned schema contains φ(p), whose universal closure is ∀xφ,
   so the learner commits the ω-rule step after the first anchor; with a guard "closed(z)" in the guard family,
   the most-specific-guard learner learns closedness from closed data and never commits it; one datum at a
   parameter (closure-normal form) drops the guard, and then ∀xφ is derivable by trusted Gen. The ω-step is
   truth-safe exactly when M₀ ≼ M. A false ∀xφ whose closed instances are all true is never refuted by
   evaluating closed instances; it is refuted by the coherence channel iff it is inconsistent with the
   designated truths (RCF refutes ∀x¬(x·x=2), the ordered-field axioms do not).

**Q2 (ZF(C) schemas).**

4. *All ZF schemas are higher-order (Miller) patterns, hence in DT°* — Separation, Collection, Replacement
   (∃! primitive, ∃! spelled out, Jech's image form), ∈-induction; Foundation is a single sentence. This is
   the structural difference from PA induction (whose P(0), P(Sx) are not pattern occurrences): the language
   {∈,=} has no function symbols, so schema instances only *rename* variables.
5. *Anchors (Thm E, proved; computed):* for a pattern target with one metavariable P of arity n, D is an anchor
   in any class between the pattern templates and SO° iff (R) the bodies' main symbols are not all equal and
   (N_i) for each argument i of P some body has argument i free. Two instances suffice. Consequently the
   higher-order pattern lgg (Pfenning 1991; Baumgartner–Kutsia–Levy–Villaret 2017) recovers every ZF schema
   from any anchor, and is sound before (Cor F; computed on 120 pairs and 400 triples per schema).
   Rates: exact inclusion–exclusion formula (Thm G; computed).
6. *Whether first-order lgg works depends on the formulation and the encoding (Thm B1).* A pattern template is
   a (guarded) first-order pattern in the **named** encoding iff P has the same argument *names* at every
   occurrence, and in the **de Bruijn** encoding iff P has the same argument *indices* at every occurrence.
   Results (table in §2.2):
   - Separation: first-order in both encodings, but **with a freshness guard in both** (the Russell instance
     φ := x ∉ y is an instance of the unguarded lgg; it is refuted from "some set has an element"). The
     most-specific-guard learner learns the guard from genuine data (computed).
   - ∈-induction: **not** first-order in the named encoding (φ(y) vs φ(x)), but **first-order in de Bruijn**
     (both are "the innermost bound variable"); well-formedness is the only guard needed (computed).
   - Collection and Replacement with ∃! primitive (Kunen's form, φ may mention the domain A): first-order in
     the named encoding with guard Y ∉ FV(φ), **not** first-order in de Bruijn (A is #2 in the antecedent, #3 in
     the consequent).
   - Replacement with ∃! spelled out (Kunen's form): not first-order in either encoding; but in the named
     encoding the first-order lgg is a single guarded schema all of whose instances are ZF-theorems (they
     follow from Collection): *truth-sound over-generalization, invisible to every refutation* (Prop C3).
   - Replacement in Jech's image form: not first-order in either encoding; two instances give an lgg with a
     ZF-refutable instance.
   - For the non-first-order cases (∈-ind named; Jech-Replacement both; Coll/Repl∃!/Repl-spelled de Bruijn)
     **no finite union of first-order schemas (with freshness guards) covers the schema without a false
     member** (Thm C2, via a deep-leaf lemma, proved; hypotheses computed).
7. *Corrections to the brief's §5 proposal:* ∈-induction is a de Bruijn first-order pattern (the brief says it is
   not first-order); freshness is automatic only in the λ/pattern encoding, not in the de Bruijn *first-order*
   encoding (Separation needs "#1 not loose"; Collection without A needs "#2 not loose", capture by index
   shift); Collection with A in φ is not a de Bruijn first-order pattern; spelled-out Replacement in Kunen's
   form gives a truth-sound (not false) first-order lgg. The brief's main claim — all ZF schemas are in the
   pattern fragment, pattern anti-unification and the DT° learner both work — is confirmed.

---------------------------------------------------------------------------------------------------------------

## 1. Conventions and the three encodings

* Sentences are trees. A *schema* in the first-order sense is a tree with metavariables at some leaves
  (parent report, def:setting:schema); inst(σ) its ground instances, ⪰ "at least as general".
* **Named encoding.** Object variables are constants of the step signature; binders are `all(x, body)`.
  A schema is formed textually; freshness/substitutability side conditions are *guards* (lem:setting:guard),
  here from the family Φ = {fresh(v, Z): v a variable name of the frame, Z a formula metavariable}.
* **de Bruijn first-order encoding.** Bound variables are indices #k (constants); a first-order metavariable at
  depth d may be instantiated by a de Bruijn term whose loose indices refer to the d enclosing binders. Only
  well-formed (closed) results are sentences; guards "loose(Z) ⊆ I" when needed.
* **λ / pattern encoding (DT°).** As in the brief §3 and prior §1: metavariables of type ι^n→o are applied to
  metavariable-free argument terms, values are closed λ-bodies λz̄.β whose free names are parameters only,
  instances are obtained by one-step plugging. A *pattern occurrence* applies the metavariable to pairwise
  distinct bound variables. PAT = templates all of whose occurrences are pattern occurrences (Miller 1991),
  DT° = every metavariable has one rigid pattern occurrence, SO° = all occurrences rigid with metavariable-free
  arguments (no determinacy). PAT ⊆ DT° ⊆ SO°.
* **Closure-normal form.** Data are formulas whose free names are parameters, read under universal closure; the
  outer parameter prefix ∀w̄ of a schema instance is dropped. The frame's own variables (Separation's z,
  Replacement's A) stay bound in the frame (§2.1).

---------------------------------------------------------------------------------------------------------------

## PART 1. Q1: learning ∀xφ from instances φ(t)

### 1.1 Formalization

Fix a first-order language L with at least one constant and a formula φ(x₁,…,x_k), each x_i free in φ (a variable
that does not occur free can be dropped; if none occurs, the target is the single sentence φ). Let
σ_φ := φ[z₁/x₁,…,z_k/x_k] with term metavariables z_i placed at the *free* occurrences of x_i (bound occurrences
of the same name are untouched; in the named encoding they are constants).

* closed-instance schema: inst_c(φ) = {φ(t̄): t̄ closed L-terms} = inst(σ_φ) when the step language has no
  parameters;
* open-instance schema: inst_o(φ) = {φ(t̄): t̄ terms over L ∪ Par} with parameters Par (closure-normal form). In
  the named encoding a guard "t_i is free for x_i in φ" is needed (φ(x) = ∃y¬(y = x), t := y gives ∃y¬(y = y));
  in de Bruijn/locally nameless syntax no capture is possible.

Metavariables are sorted (term positions only); the lgg of sorted data is sorted. Throughout, (H) denotes the
richness assumption: for every k there are closed terms t₁…t_k pairwise distinct and t′₁…t′_k pairwise distinct
with root(t_i) ≠ root(t′_i). It holds for the PA language (t_i = S^i0, t′_i = 0+S^i0) and the ordered-field
language (t_i = 1+…, t′_i = 1·(…)).

### 1.2 Prop A1 (instance sets determine schemas) — proved

Under (H), for first-order schemas σ (metavariables at term positions) and τ: inst(σ) ⊆ inst(τ) iff σ ⪯ τ.

*Proof.* (⇐) trivial. (⇒) Put θ₀(z_i) = t_i and θ₁(z_i) = t′_i. The roots of θ₀z_i, θ₁z_i differ, and θ₀z_i ≠ θ₀z_{i′}
for i ≠ i′, so both witness events of lem:setting:recover hold and lgg(σθ₀, σθ₁) ≡ σ. Both instances lie in
inst(τ), so τ ⪰ lgg(σθ₀, σθ₁) ≡ σ by thm:setting:lgg. ∎

(computed: `q1_lgg.py` (2) — for all six test formulas the lgg of the two generic instances equals σ_φ.)

### 1.3 Thm A2 (anchors for the instance schema) — proved; computed

Let D = {φ(t̄₁),…,φ(t̄_N)} ⊆ inst_c(φ), N ≥ 1, (H). Then TFAE:
(i) D is an anchor for inst_c(φ) in H₁ (single first-order schemas);
(ii) lgg(D) ≡ σ_φ;
(iii) (R_i) for each i, the roots of t_{1,i},…,t_{N,i} are not all equal; and (D_{ii′}) for each i < i′ there is j
with t_{j,i} ≠ t_{j,i′}.

*Proof.* (ii)⇔(iii) is lem:setting:recover with θ_j(z_i) = t_{j,i}; every z_i occurs in σ_φ. (ii)⇒(i): every τ with
D ⊆ inst(τ) has τ ⪰ lgg(D) ≡ σ_φ. (i)⇒(ii): lgg(D) ∈ H₁ covers D, so inst(lgg D) ⊇ inst(σ_φ), so σ_φ ⪯ lgg(D) by
A1; and lgg(D) ⪯ σ_φ since σ_φ covers D. ∎

Corner cases, all covered by the theorem:
* *Tied positions.* If x_i occurs m times, σ_φ has z_i m times; Reynolds' table assigns one variable per column,
  and all m columns equal (t_{1,i},…,t_{N,i}). No witness event beyond (R_i) is needed.
* *Several variables.* (D_{ii′}) is needed: on diagonal data φ(t,t) the lgg of x+y=y+x is z+z=z+z, a sound
  specialization (computed).
* *Closed subterms of φ equal to data terms.* Columns at non-x positions are constant, so they never merge with
  an x-column unless all data terms equal that constant, which is already a failure of (R_i). Example computed:
  φ = (x+S0 = Sx) with data terms S0 and 0 recovers σ_φ; with S0 and SS0 (both root S) the lgg is
  S(z)+S0 = SS(z), the (R)-failure.
* *Bound occurrences of the same name* (named encoding, φ = x=0 ∧ ∀x(x=x)): constant columns; recovered.
* *Anchor size.* One datum is never an anchor (R fails); two data t̄, t̄′ with pairwise distinct components and
  componentwise different roots are an anchor.

*Evidence.* `q1_lgg.py` (1) → `q1_lgg.out`: closed-term pool of size ≤ 4 (12 terms); all pairs and triples for
four one-variable formulas (286 data sets each) and 70 296 data sets each for two two-variable formulas:
"lgg ≡ σ_φ ⟺ (R)∧(D)" on all of them.

**Prop A2′ (the same events in DT°; not in SO°) — proved; computed.** If the hypothesis class is enlarged to the
determinate second-order templates DT° (metavariables of any arity, each with a rigid pattern occurrence, other
occurrences with metavariable-free arguments), D ⊆ inst_c(φ) is still an anchor iff (R) and (D). In SO° (no pattern
occurrence required) this fails for the PA language.
*Proof (DT°).* (⇒ fails if (R) or (D) fails) the first-order witnesses of A2 lie in DT°. (⇐) Let T ∈ DT° cover D. By
(R) every x-position is a disagreement position, so T's rigid skeleton is a prefix of φ's skeleton (prior C2(a)).
Let M have a pattern occurrence M(ū¹) at c₁ (ū¹ distinct bound variables) and further occurrences M(ū^s) at c_s;
in datum j its body β_j is unique: D_j|c₁ with the variables ū¹ abstracted (other context variables cannot occur).
Let κ(c) := σ_φ|c. At a z_i-position p of κ(c₁), D_j|c₁ has the closed term t_{j,i}; holes of β_j sit only at
occurrences of the variables ū¹, so β_j|p = t_{j,i} and D_j|c_s = β_j[ū^s] also has t_{j,i} at p. Positions of
κ(c₁) and κ(c_s) agree off hole positions; if κ(c_s) had a rigid symbol at p, all t_{j,i} would share its root
(contradicting (R_i)), and if κ(c_s) had z_{i′} at a position where κ(c₁) is rigid, all t_{j,i′} would share that root
or be variables (contradicting (R_{i′}) or closedness). So κ(c_s)|p = z_{i′} with t_{j,i′} = t_{j,i} for all j, whence
i′ = i by (D_{ii′}). Let B_M be κ(c₁) with its context-variable leaves replaced by the corresponding holes; then
B_M[ū^s] = κ(c_s) for all s, and σ(M) := λh̄.B_M gives Tσ↓ = σ_φ, i.e. T ⪰ σ_φ. ∎
*SO° counterexample (computed, `q1_lgg.py` (5)).* For φ(x) = (x+0 = x), T := f(S0) + f(0) = f(S0) (f a unary term
metavariable with ground arguments only, so T ∉ DT°) covers 0+0=0 (f := λh.0) and S0+0=S0 (f := λh.h), a pair with
(R), but misses SS0+0 = SS0: a body β with β[0] = 0 is h or 0, and then β[S0] ∈ {S0, 0}. This is the Q1 analogue of
the prior C7 "shielding" phenomenon; determinacy removes it.

### 1.4 Thm A3 (rates) — proved; computed

Data i.i.d.: t̄ ~ Λ. Let p_{i,f} = Λ(root t_i = f) and c_{ii′} = Λ(t_i = t_{i′}).
(a) k = 1: P[D_N is not an anchor] = Σ_f p_f^N exactly.
(b) k = 2: P = Σ_f a_f^N + Σ_g b_g^N + c^N − Σ_{f,g} d_{fg}^N − Σ_f e_f^N, with a_f = Λ(root t₁ = f),
b_g = Λ(root t₂ = g), c = Λ(t₁ = t₂), d_{fg} = Λ(root t₁ = f, root t₂ = g), e_f = Λ(root t₁ = f, t₁ = t₂). For
i.i.d. components with root law p and term law μ: P = 2S − S² + c^N − C, S = Σ_f p_f^N, C = Σ_f c_f^N,
c_f = Σ_{root t = f} μ(t)².
(c) In general P ≤ Σ_i Σ_f p_{i,f}^N + Σ_{i<i′} c_{ii′}^N ≤ (2k + C(k,2)) e^{−Nρ} (thm:imitation:coupon with π = 1).

*Proof.* "Not an anchor" = ⋃_i ¬R_i ∪ ⋃ ¬D_{ii′} (A2). (a) ¬R = disjoint union of A_f = "all roots f". (b)
Inclusion–exclusion over A = ⋃_f A_f, B = ⋃_g B_g, E = ¬D: A_f ∩ A_{f′} = ∅ for f ≠ f′, P(A_f ∩ B_g) = d_{fg}^N,
P(A_f ∩ E) = P(B_f ∩ E) = e_f^N, and A_f ∩ B_g ∩ E = ∅ unless f = g, when it is A_f ∩ E. (c) Union bound. ∎

*Evidence (computed, `q1_lgg.py` (4)).* Root law 0:.4, S:.3, +:.2, ·:.1 (Galton–Watson, depth ≤ 4), 20 000 trials:

| N | exact k=1 | MC k=1 | exact k=2 | MC k=2 | bound k=1 | bound k=2 |
|---|---|---|---|---|---|---|
| 2 | .3000 | .2979 | .5157 | .5173 | .736 | 1 |
| 4 | .0354 | .0341 | .0699 | .0684 | .271 | .677 |
| 6 | .0049 | .0046 | .0098 | .0096 | .100 | .249 |
| 10 | .00011 | .00010 | .00022 | .00025 | .013 | .034 |

N for δ = 0.01: exact 6 (k = 1) and 6 (k = 2); the theorem's sufficient N: 11 and 13 (ρ = 0.5).

### 1.5 Open-term data, guards and the hidden ω-step — Prop A4 — proved; computed

(a) inst_o(φ) contains φ(p̄) with distinct parameters, whose universal closure is (α-equivalent to) ∀x̄φ; every
member of inst_o(φ) is FOL-derivable from ∀x̄φ, and ∀x̄φ from φ(p̄) by Gen. So, with trusted first-order logic,
inst_o(φ) and ∀x̄φ are interderivable.

(b) If the step language contains parameters and metavariables range over all terms of the step language, then
inst_c(φ) is *not* H₁-closed: cl_{H₁}(inst_c φ) := ⋂{inst τ: τ ⊇ inst_c φ} = inst(σ_φ) = inst_o(φ) ⊋ inst_c(φ).
Hence (prior C6.1) once the closed data contain an anchor, the cautious H₁-verifier accepts φ(p̄), i.e. it takes
the ω-rule step "all closed instances ⇒ ∀x̄φ" although no datum licenses it.
*Proof.* Every τ ⊇ inst_c(φ) contains an anchor, hence τ ⪰ σ_φ (A2, whose proof only uses closed data); σ_φ itself
contains inst_c(φ). ∎

(c) With the guard family Φ ∋ closed(z_i) ("the term substituted for z_i contains no parameter"),
inst_c(φ) = inst(σ_φ, {closed(z_i)}) is realizable; by lem:setting:guard the learned guard set is the set of guards
true on all data, so closed data teach closedness and the learner never accepts φ(p̄); one datum with a parameter
at z_i deletes closed(z_i).

*Evidence.* `q1_lgg.py` (3): data 0+0=0, 0+S0=S0 → lgg 0+z=z with learned guard closed(z): accepts 0+SS0=SS0,
rejects 0+p₂=p₂ and 0+p₁·p₂ = p₁·p₂; after adding 0+(p₁+S0) = p₁+S0 the guard is gone and 0+p₂=p₂ (≡ ∀x(0+x=x)) is
accepted.

### 1.6 The ω-gap

**Prop A5 (when closed instances decide universals) — proved; known in substance (Tarski–Vaught test).** Let M be
an L-structure (L with a constant) and M₀ = {t^M : t closed} the closed-term substructure. TFAE:
(i) for every L-formula φ(x̄): M ⊨ ∀x̄φ iff M ⊨ φ(t̄) for all closed t̄;
(ii) M₀ ≼ M.
In particular (i) holds when M is term-generated (M₀ = M), e.g. (ℕ; 0, S, +, ·), and in every model of true
arithmetic (ℕ ≼ M).
*Proof.* (ii)⇒(i): if M ⊨ φ(t̄) for all closed t̄ then M₀ ⊨ ∀x̄φ (elementarity, every element of M₀ is some t^M),
so M ⊨ ∀x̄φ; the converse direction of (i) is ∀-elimination. (i)⇒(ii): Tarski–Vaught criterion. Let
M ⊨ ∃xψ(x, ā) with ā = s̄^M ∈ M₀. If no b ∈ M₀ had M ⊨ ψ(b, ā), then M ⊨ ¬ψ(t, s̄) for all closed t, and (i) with
φ := ¬ψ(x, s̄) gives M ⊨ ∀x¬ψ(x, s̄), a contradiction. ∎

**Ex. A6 (ℝ as an ordered field) — proved.** L = {0,1,+,−,·,<}. Every closed term denotes an integer (induction
on terms). With φ(x) := ¬(x·x = 1+1): ℝ ⊨ φ(t) for every closed t (n² ≠ 2 for n ∈ ℤ), but ℝ ⊭ ∀xφ (√2). RCF
⊢ ∃x(x·x = 1+1) (positive elements have square roots), so the false universal is refutable from the designated
theory RCF; it is not refutable from the ordered-field axioms OF, since ℚ ⊨ OF + ∀x¬(x·x = 1+1).

**Ex. A7 (set theory with closed-term-forming symbols) — proved.** L = {∈, ∅, p, u} with p(a,b) = {a,b},
u(a,b) = a∪b. Closed terms denote exactly the hereditarily finite sets. Let Ind(x) := ∅ ∈ x ∧ ∀y∈x u(y, p(y,y)) ∈ x
and φ(x) := ¬Ind(x). Every closed term denotes a finite set, and an inductive set is infinite, so V ⊨ φ(t) for all
closed t; ZF ⊢ ∃x Ind(x) (Infinity), so ∀xφ is false and refuted by Infinity. (Each closed instance is a true
Δ₀ sentence about HF sets; I believe each is provable already in very weak set theories, but only truth is used.)
The brief's variant φ(x) := "x is finite" (x is in bijection with some natural number) behaves the same way: all
closed instances are true, ∀x finite(x) is refuted by Infinity; ¬Ind is used here because it is Δ₀ in L.

**Ex. A7′ (nonstandard models of PA) — proved.** If M ⊨ PA + ¬Con(PA) and Prf is a Δ₀ proof predicate, all closed
instances ¬Prf(n̄, ⌜⊥⌝) hold in M (true Δ₀ sentences hold in every model of Q), while M ⊨ ∃x Prf(x, ⌜⊥⌝). So even
within arithmetic the ω-step is truth-safe only in the right model.

**Ex. A8 (derivability: Q) — proved; computed.** Q ⊢ 0 + n̄ = n̄ for every n (n = 0: axiom x+0 = x; step:
0 + S n̄ = S(0 + n̄) = S n̄ by x+Sy = S(x+y) and the induction hypothesis). Q ⊬ ∀x(0+x = x): take the domain
ℕ ∪ {a, b}, standard on ℕ, with
- S a = a, S b = b;
- n + a = n + b = b; a + n = a, b + n = b; a+a = a+b = a; b+a = b+b = b;
- x·0 = 0; a·n = b·n = b (n ≥ 1); n·a = n·b = a (n ≥ 1), 0·a = 0·b = 0; a·a = a·b = b·a = b·b = a.

Check of Q1–Q7 by cases: S is injective with 0 ∉ ran S and every x ≠ 0 a successor (a = Sa, b = Sb). Q4: x+0 = x.
Q5 x+Sy = S(x+y): y standard — for x ∈ {a,b}, x+n = x and S x = x; y ∈ {a,b} — Sy = y and every x+y ∈ {a,b} is a
fixed point of S. Q6 holds. Q7 x·Sy = x·y + x: y standard — a·(n+1) = b = a·n + a (0+a = b, b+a = b), b similarly
(0+b = b, b+b = b); y ∈ {a,b} — need z + x = z for z = x·y: x = 0 trivial; x = n ≥ 1, z = a: a+n = a; x = a, z = a:
a+a = a; x = b, z = a: a+b = a. In this model 0+a = b ≠ a. So Q + {all closed instances of 0+x=x} ⊬ ∀x(0+x = x).
(The phenomenon is standard; that Q does not prove 0+x = x is a textbook fact — I believe e.g. Boolos–Burgess–
Jeffrey, *Computability and Logic*, ch. 16 exercises; the model here is my own.)
*Evidence.* `q1_qmodel.py` → `q1_qmodel.out`: all seven axioms hold on all tuples from {0..40} ∪ {a, b}; 0+a = b.

**Prop A9 (parameters + Gen) — proved (trivial).** In closure-normal form the datum φ(p) at a parameter p *is*
∀xφ (its universal closure); with trusted Gen, ∀xφ is derivable from it in one step. So with open-term data
the ω-gap disappears (A4(a)).

### 1.7 Consequences for a learner — Prop A10, A11 — proved

**A10 (what is soundly learnable).**
1. From closed instances, the soundly learnable object is inst_c(φ), with anchor (R)+(D) and the rates of A3;
   the learner must carry a closedness guard (A4(c)), otherwise it commits the ω-step (A4(b)).
2. The ω-step (accept ∀x̄φ, equivalently φ(p̄)) is *truth-safe for all genuine closed-instance schemas* iff the
   intended structure M satisfies M₀ ≼ M (A5): yes for ℕ, no for ℝ, V, or a nonstandard model of PA.
3. It is *derivable* from the instances only via an ω-rule; first-order theories are ω-incomplete in general
   (A8: Q plus all closed instances does not prove ∀x(0+x=x)).
4. If the community itself uses instances at parameters (as in Lean/Coq practice, where `∀x, φ x` is applied to
   variables), the open-instance schema is the target and ∀x̄φ is obtained soundly (A9).

**A11 (refutation).** Let ∀xφ be false in the intended M while every closed instance is true.
(a) No refutation that ends in evaluating closed instances φ(t) (the parent's "∀E then W" singleton-blame
pattern) ever condemns ∀xφ, since every such evaluation returns true.
(b) A coherence refutation from designated true premises Γ exists iff Γ ∪ {∀xφ} is inconsistent (completeness):
Γ = RCF refutes ∀x¬(x·x = 1+1); Γ = OF does not (ℚ). ZF refutes ∀x¬Ind(x) (Infinity).
(c) In a term-generated M (ℕ) the situation cannot arise: by A5 a false ∀xφ has a false closed instance; if
the evaluation channel decides φ's closed instances (φ ∈ Δ₀), search finds it — the parent's "arithmetic is
Popperian" for Π₁.
So where the bold step is safe (M₀ ≼ M) a false universal always has a false closed instance; elsewhere (ℝ, V) a
wrong ω-step can only be caught through the designated theory, and sometimes not at all.

---------------------------------------------------------------------------------------------------------------

## PART 2. Q2: the ZF(C) schemas

### 2.1 Formulations — known (citations)

* **Kunen** (*Set Theory: An Introduction to Independence Proofs*, 1980, Ch. I; I believe also in the 2011
  edition): Comprehension ∀z∀w̄∃y∀x(x∈y ↔ x∈z ∧ φ), FV(φ) ⊆ {x, z, w̄} (so y ∉ FV(φ));
  Replacement ∀A∀w̄(∀x∈A ∃!y φ → ∃Y∀x∈A ∃y∈Y φ), FV(φ) ⊆ {x, y, A, w̄} (Y ∉ FV(φ));
  Foundation ∀x(∃y(y∈x) → ∃y(y∈x ∧ ¬∃z(z∈x ∧ z∈y))). (Wording from memory: I believe this is exact up to notation.)
* **Jech** (*Set Theory*, 3rd millennium ed., 2003, Ch. 1, axioms 1.1–1.9; I believe): Separation
  ∀X∀p∃Y∀u(u∈Y ↔ u∈X ∧ φ(u,p)); Replacement ∀x∀y∀z(φ(x,y,p) ∧ φ(x,z,p) → y = z) → ∀X∃Y∀y(y∈Y ↔ ∃x∈X φ(x,y,p));
  Regularity ∀S(S ≠ ∅ → ∃x∈S S∩x = ∅).
* **Collection** ∀A∀w̄(∀x∈A ∃y φ → ∃Y∀x∈A ∃y∈Y φ) and **∈-induction** ∀x(∀y∈x φ(y) → φ(x)) → ∀xφ(x) are not axioms
  of ZFC but theorem schemas of ZF (Collection via ranks/reflection; ∈-induction via transitive closures and
  Foundation) — known. Conversely ∈-induction with parameter S proves Foundation: for φ(x) := x ∉ S, if S had no
  ∈-minimal element then ∀y∈x (y ∉ S) → x ∉ S holds for all x, so ∀x(x ∉ S) and S = ∅ (proved, two lines).
* **ZFC proper:** Extensionality, Pairing, Union, Power set, Infinity, Separation (schema), Replacement (schema),
  Foundation (one sentence), Choice; plus Empty set/Set existence depending on the text.

**Closure-normal forms used here** (parameters w̄ dropped; frame variables stay bound; P is the template's
metavariable, written with the textbook argument names; `st_core.SCHEMAS`):

| name | template T* | P's arguments |
|---|---|---|
| Sep (Kunen) | ∀z∃y∀x(x∈y ↔ x∈z ∧ P(x,z)) | (x, z) |
| SepJ (Jech) | ∀X∃Y∀u(u∈Y ↔ u∈X ∧ P(u)) | (u) |
| EInd | ∀x(∀y(y∈x → P(y)) → P(x)) → ∀xP(x) | (y), (x), (x) |
| Coll | ∀A(∀x(x∈A → ∃y P(x,y,A)) → ∃Y∀x(x∈A → ∃y(y∈Y ∧ P(x,y,A)))) | (x,y,A) twice |
| ReplU (Kunen, ∃! primitive) | ∀A(∀x(x∈A → ∃!y P(x,y,A)) → ∃Y∀x(x∈A → ∃y(y∈Y ∧ P(x,y,A)))) | (x,y,A) twice |
| ReplS (∃! spelled out) | ∀A(∀x(x∈A → ∃y(P(x,y,A) ∧ ∀u(P(x,u,A) → u=y))) → ∃Y∀x(x∈A → ∃y(y∈Y ∧ P(x,y,A)))) | (x,y,A), (x,u,A), (x,y,A) |
| ReplJ (Jech) | ∀x∀y∀u(P(x,y) ∧ P(x,u) → y=u) → ∀X∃Y∀y(y∈Y ↔ ∃x(x∈X ∧ P(x,y))) | (x,y), (x,u), (x,y) |
| Found | ∀S(∃x x∈S → ∃x(x∈S ∧ ∀y(y∈x → ¬y∈S))) | — (ground) |

All are sentences after plugging any body λz̄.φ (φ closed except holes and parameters).

### 2.2 Thm B1 (classification of encodings) — proved; computed

Let T* be a pattern template with one metavariable P of arity n and occurrences P(ā₁),…,P(ā_m), ā_k pairwise
distinct bound variables in scope. In the named encoding let N_k be the *names* of ā_k; in the de Bruijn encoding
let I_k be the *indices* of ā_k at occurrence k.
(a) T* ∈ PAT ⊆ DT° (a Miller pattern).
(b) inst(T*) equals the instance set of a single first-order schema with freshness guards in the named encoding
iff N₁ = … = N_m. Then the schema is F[A,…,A] (the frame with one formula metavariable A at every P-position) with
guards {fresh(v, A): v a frame-bound name, v ∉ N₁}.
(c) the same holds in the de Bruijn encoding iff I₁ = … = I_m, with guard loose(A) ⊆ I₁; this guard is implied by
well-formedness iff I₁ = {0,…,d−1} where d is the least binder depth of an occurrence.

*Proof.* (a) by inspection. (b)/(c) "if": an instance of the guarded first-order schema assigns A a formula ψ whose
free frame names lie in N (named) or whose loose indices lie in I (dB). Let β := ψ with the names/indices of N
(resp. I) replaced by the holes in argument order. At every occurrence the arguments have the same names
(resp. indices), so β[ā_k] = ψ for all k and the instance is T*[P := λz̄.β]. Conversely T*[P := λz̄.β] gives
β[ā_k], the same text for all k, satisfying the guard. "Only if": suppose N_k ≠ N_l (resp. I_k ≠ I_l) and σ is a
guarded first-order schema with inst(σ, G) = inst(T*). Take the genuine data s₁, s₂ with bodies
φ₁ = ⋀_i (z_i = z_i) and φ₂ = ¬φ₁. Their lgg L has a metavariable at every P-position (roots ∧ vs ¬ differ) and
the columns at occurrences k, l differ (φ₁ mentions every argument), so L has distinct metavariables A_k ≠ A_l.
Since s₁, s₂ ∈ inst(σ), σ ⪰ L, say L = σρ. Let s₃ := L with A_k's block := ⊤ = ∀w(w=w) and all other blocks
:= ⊥ = ¬⊤. Then s₃ = σ(ρθ₃) and every guard satisfied by s₁ is satisfied by s₃: the value ρθ₃(Z) of each
σ-metavariable has as free names (loose indices) only those of the rigid part of ρ(Z), which are also free in
ρθ_{s₁}(Z). So s₃ ∈ inst(σ, G). But s₃ ∉ inst(T*): a body giving the closed ⊤ at occurrence k must be ⊤ itself
(plugging variables into a body with holes leaves variables), so occurrence l would also be ⊤, not ⊥. ∎

*Evidence.* `z1_encodings.py` (1) computes the criterion from the frames; (5) builds s₃ for every non-first-order
case: an instance of the lgg, not a schema instance (all 7 cases). (4): for EInd in de Bruijn, of 3000 random A
with loose indices ⊆ {#0,#1}, the 1051 well-formed instances of the first-order pattern are all EInd instances and
the rest are ill-formed.

**Table (proved by B1; criterion computed in `z1_encodings.out` (1)).**

| schema | PAT / DT° | named first-order | de Bruijn first-order |
|---|---|---|---|
| Sep | yes | yes, guard fresh(y, A) | yes, guard "#1 not loose" (not implied) |
| SepJ | yes | yes, guards fresh(X, A), fresh(Y, A) | yes, guard loose(A) ⊆ {#0} |
| EInd | yes | **no** (y vs x) | **yes**, guard implied by well-formedness |
| Coll | yes | yes, guard fresh(Y, A) | **no** (A is #2 vs #3) |
| ReplU | yes | yes, guard fresh(Y, A) | **no** |
| ReplS | yes | no (y vs u) | no |
| ReplJ | yes | no | no |
| Coll/ReplU with φ(x,y) only | yes | yes, guards fresh(Y), fresh(A) | yes, guard loose ⊆ {#0,#1} (not implied: #2 is A in the antecedent, Y in the consequent) |
| Found | ground | ground | ground |

The table answers "is it a first-order pattern, with what guards, is it a Miller pattern, is it determinate" for
each schema. Without its guard every guarded entry has a false instance (§2.4).

### 2.3 What the first-order lgg does — Prop B2 — proved; computed

For data D ⊆ inst(T*) with (R), the first-order lgg (either encoding) is the frame with a metavariable at each
P-position, and positions k, l carry the same metavariable iff φ_j[ā_k] = φ_j[ā_l] (as text in that encoding) for
all j, iff every argument position i at which ā_k and ā_l differ is unused by all φ_j.
*Proof.* Frame positions are common columns; by (R) every P-position is a disagreement column; Reynolds' table
merges equal columns. φ[ā_k] = φ[ā_l] iff the substitutions agree on FV(φ) (substitution injectivity: at a free
occurrence of z_i the two results carry a_{k,i} and a_{l,i}). ∎

`z1_encodings.out` (2) tabulates the blocks for all 110/107/106 pool pairs with (R), keyed by (N_i). Summary:
* EInd: named blocks {1},{2,3} iff N; de Bruijn always {1,2,3}.
* Coll, ReplU: named always {1,2}; de Bruijn {1},{2} iff N_A.
* ReplS: named {1,3},{2} iff N_y; de Bruijn three blocks when N_x and N_A.
* ReplJ: named {1,3},{2} iff N_y; de Bruijn three blocks when N_x and N_y.

So on anchor data (R + all N_i) the first-order lgg decouples exactly the non-first-order cases of the table;
when it ties everything (some N_i fails), it is a sound but incomplete specialization.

### 2.4 Two instances suffice for a false lgg instance — proved; computed

For each non-first-order case, two genuine instances (two atoms with different roots) and an instance of their
lgg that is false, with the falsity proof. All are checked to be instances of the computed lgg and not schema
instances in `z1_encodings.out` (3). ⊤ := ∀w(w=w), ⊥ := ¬⊤.

1. **EInd, named.** Data EInd(x = x), EInd(¬x ∈ a). lgg: ∀x(∀y(y∈x → A) → B) → ∀xB. Instance
   F₁ := ∀x(∀y(y∈x → ¬y=y) → ∀w¬w∈x) → ∀x∀w¬w∈x. The antecedent is valid (∀y(y∈x → ⊥) is ∀w¬w∈x), so F₁ is
   logically equivalent to the Π₁ sentence ∀x∀w¬(w∈x), whose Δ₀ matrix fails at the HF sets x = {∅}, w = ∅; by
   Δ₀-absoluteness (HF is transitive) F₁ is false in V. ZF refutes it from "some set has an element".
2. **ReplJ, named.** Data ReplJ(x∈y), ReplJ(¬x=a). lgg: ∀x∀y∀u(A ∧ B → y=u) → ∀X∃Y∀y(y∈Y ↔ ∃x(x∈X ∧ A)).
   Instance A := y=y, B := ¬u=u: the antecedent is valid and the consequent says, at X = {∅}, that there is a
   set of all sets. ZF refutes it: Y ∈ Y contradicts Foundation (or Separation yields Russell's set).
3. **ReplJ, de Bruijn** (three blocks): A₁ := ⊥, A₂ := ⊥, A₃ := (y = y): the same false sentence up to the
   antecedent's form.
4. **Coll, de Bruijn.** Data Coll(y = x), Coll(¬x = A). lgg decouples occurrences 1, 2. Instance A₁ := y=y,
   A₂ := ⊥: ∀A(∀x∈A ∃y(y=y) → ∃Y∀x∈A ∃y(y∈Y ∧ ⊥)), logically equivalent to ∀A¬∃x(x∈A); refuted by the HF witness
   A = {∅} (Σ₁ negation, Δ₀-absolute).
5. **ReplU, de Bruijn.** Same data; A₁ := (y = x) (∃!y(y = x) is valid), A₂ := ⊥: equivalent to ∀A¬∃x(x∈A).
6. **ReplS, de Bruijn.** Same data; A₁ := (y = x), A₂ := ⊥, A₃ := ⊥: the antecedent ∀x∈A∃y(y=x ∧ ∀u(⊥ → u=y)) is
   valid, the instance is equivalent to ∀A¬∃x(x∈A).
7. **Guard violations** (the guarded first-order patterns of the table):
   - Sep without fresh(y): Russell's instance ∀z∃y∀x(x∈y ↔ x∈z ∧ ¬x∈y) — both encodings (§2.6).
   - Coll / ReplU / ReplS, named, without fresh(Y): φ := (y = Y) gives ∀A(∀x∈A ∃y(y = Y) → ∃Y∀x∈A∃y(y∈Y ∧ y=Y)):
     the antecedent holds (Y is a parameter there), the consequent forces Y ∈ Y for A ≠ ∅; ZF refutes it by
     Foundation (ReplS: add B := ¬u=u for the uniqueness clause).
   - Coll with φ(x,y) only, de Bruijn, without "#2 not loose": A := (#0 = #2) reads y = A in the antecedent and
     y = Y in the consequent: ∀A(∀x∈A∃y(y=A) → ∃Y∀x∈A∃y(y∈Y ∧ y=Y)), false as before (`z1_encodings.out` (3b)).

### 2.5 No finite union of first-order schemas — Lemma C1, Thm C2 — proved; computed

**Lemma C1 (deep leaf).** Let s be a sentence tree, ℓ a leaf of s, and τ a first-order schema with s ∈ inst(τ) and
|τ| < depth(ℓ). Then τ has a metavariable occurrence Z at a proper prefix q of ℓ with depth(q) < |τ|. If
moreover s|q occurs in s only at q, then Z occurs in τ only at q, and s[q ← v] ∈ inst(τ) for every closed formula
v; with freshness guards (named) or loose-index guards (de Bruijn), s[q ← v] satisfies them.
*Proof.* Follow the path to ℓ in τ: τ has fewer than |τ| nodes, so the path leaves τ's tree at depth < |τ| at a
leaf of τ. That leaf is not a constant, since s continues below it; so it is a metavariable Z at a proper prefix
q of ℓ. If Z also occurred at q′, then s|q′ = θ(Z) = s|q, so q′ = q by uniqueness. Changing θ(Z) to v changes s at
q only. Guards on Z: v is closed, so it has no free names and no loose indices; other metavariables keep their
values. ∎

**Thm C2.** In each case below, every finite set {τ₁,…,τ_r} of first-order schemas (with freshness guards) whose
union contains all instances of the schema contains a false sentence (indeed one refutable in ZF from "some set
has an element", Foundation, and Separation/Pairing):
(i) EInd in the named encoding; (ii) ReplJ in both encodings; (iii) Coll, ReplU and ReplS in the de Bruijn encoding.
The list is exactly the non-first-order cases of the table except ReplS in the named encoding, and that exception is
necessary: there a single guarded first-order schema covers ReplS without false members (Prop C3). Every finite
union still contains non-instances there (Lemma C1 applies verbatim; only falsity fails).

*Proof.* Take n with 2n > max|τ_i|, the genuine instance s_n below, and τ_i covering it. By Lemma C1 (uniqueness is
checked below) τ_i contains s_n[q ← v] for the prefix q determined by τ_i and *each* closed v; it suffices that for
every proper prefix q of the designated leaf one of v ∈ {⊤, ⊥} makes s_n[q ← v] false. Below, "make the slot false"
means choosing v with ¬^{e}v ≡ ⊥ where e is the number of negations between q and the slot root (positions on the
path inside the slot are reached through ¬, ∀ and ∧ only, and ∀w v ≡ v).
(i) φ_n(x) := ¬^{2n}∀w¬(w∈x) ("x is empty"); s_n = EInd(φ_n), named; leaf: the y in occurrence 1 (φ_n(y)).
  q = root: v := ⊥. q = antecedent or its ∀x-body: v := ⊤; then s ≡ ∀xφ_n(x) ≡ "every set is empty", false.
  q = ∀y(y∈x → φ_n(y)) or its body: v := ⊥; the antecedent becomes ∀x(⊥ → φ_n(x)), true; conclusion false.
  q inside φ_n(y): make the slot false; then ∀y(y∈x → ⊥) says "x is empty", the antecedent reads
  ∀x(x empty → x empty), true, the conclusion is false.
(ii) φ_n(x,y) := ¬^{2n}(x ∈ y); leaf: u in occurrence 2 (φ_n(x,u)). The consequent C := ∀X∃Y∀y(y∈Y ↔ ∃x∈X x∈y) is
  false: at X = {∅}, Y would contain every y with ∅ ∈ y; y₀ := {∅, Y} gives Y ∈ y₀ ∈ Y, contradicting Foundation
  (or, without Foundation, R := {y ∈ Y: y ∉ y} and y₁ := R ∪ {∅} give y₁ ∈ y₁ ↔ y₁ ∉ y₁). q = root: ⊥. q = the
  antecedent, its ∀y, ∀u levels or its implication: ⊤ (antecedent true, C false). q = the conjunction: ⊥
  ((⊥ → y=u) is true). q inside φ_n(x,u): make the slot false (the conjunction becomes ⊥).
(iii) φ_n(x,y,A) := ¬^{2n}(y = x ∧ x ∈ A); leaf: the A in the consequent occurrence (occurrence 2 for Coll/ReplU,
  3 for ReplS). The antecedent is true for every A (y := x is the unique witness). Every proper prefix q on the
  path is the root (v := ⊥), the ∀A body (v := ⊥: ∀A⊥), or a subformula of the consequent containing the leaf;
  there v := ⊥ above the slot (∃Y⊥, ∃Y∀x⊥, ∀x(x∈A → ⊥), ∃y⊥, (y∈Y ∧ φ) := ⊥) and "make the slot false" inside it
  (including (y=x ∧ x∈A) := ⊥ and x∈A := ⊥ under the even chain) make the consequent false whenever A ≠ ∅, so
  ∀A(true → false-for-nonempty-A) is false.
Uniqueness of s_n|q along the path: in (i) the path subterms contain y and occurrences 2, 3 contain x; in (ii) and
(iii) the argument tuples of the designated occurrence differ from all others (de Bruijn: (#2,#0) vs (#2,#1),
(#0,#1); (#1,#0,#3) vs (#1,#0,#2), (#2,#0,#3)), and the frame subterms on the path are distinct. ∎

*Evidence.* `z5_deepleaf.py` → `z5_deepleaf.out`: for n ≤ 10 every subterm along each designated path is unique in
s_n; for 2 136 random first-order generalizations τ of s_n with |τ| < depth(leaf) (n = 2, 4, 8), τ contains both
s_n[q ← ⊤] and s_n[q ← ⊥] at the metavariable q on the path (lemma C1's conclusion).

This is the ZF analogue of the prior result for PA induction (family 0+(…(0+x)) = x).

### 2.6 Prop C3 (spelled-out Replacement, named: a truth-sound over-generalization) — proved; computed

Let L_S := ∀A(∀x(x∈A → ∃y(B₁ ∧ ∀u(B₂ → u=y))) → ∃Y∀x(x∈A → ∃y(y∈Y ∧ B₁))) with guard fresh(Y, B₁) — the named
first-order lgg of ReplS data with (R) and N_y (`z1_encodings.out` (2)). Every guarded instance of L_S is a ZF
theorem; inst(L_S) ⊋ inst(ReplS).
*Proof.* The antecedent implies ∀x∈A ∃y B₁ (drop the second conjunct). B₁ may mention x, y, A, u (u is not bound at
either occurrence of B₁, so it is a parameter at both) and other parameters, but not Y (guard). Collection with
these parameters gives ∃Y∀x∈A∃y∈Y B₁, and ZF ⊢ Collection. Strictness: B₂ := ⊥ gives a non-instance. ∎
So in the named encoding the first-order learner on spelled-out Replacement data is *truth-sound but not exact*,
and no refutation (world or coherence) can ever detect the over-generalization. Without the guard the capture
instance of §2.4(7) is false. Contrast: in Jech's image form the decoupling yields false instances (§2.4(2)), because
the consequent "Y is exactly the image" is not implied by the antecedent's existence part.

### 2.7 Separation without the freshness guard; guard learning — Prop D1 — proved; computed

(a) The unguarded lgg of Sep data (named: ∀z∃y∀x(x∈y ↔ x∈z ∧ A); de Bruijn: the same with A at depth 3) has the
instance φ := ¬(x∈y): R := ∀z∃y∀x(x∈y ↔ x∈z ∧ ¬x∈y). From the designated true axiom ∃z∃x(x∈z): fix such z, x₀ and
the y given by R; then x₀∈y ↔ ¬x₀∈y. So R is refuted in pure logic from "some set has an element" (which ZF proves,
e.g. {∅}).
(b) Most specific guards (lem:setting:guard, Φ = {fresh(v, A): v ∈ {x, y, z}}): genuine data never have y free, so
fresh(y, A) is always learned and R is never accepted. The learned guard set equals the target {fresh(y, A)} iff
some datum has x free and some has z free, i.e. iff (N_x) and (N_z) — the same events as the DT° anchor (Thm E).
For Coll/ReplU (named) the target guard is fresh(Y, A); exact iff N_x, N_y, N_A.
*Evidence.* `z4_guards.py` → `z4_guards.out`: on all pool pairs with (R) (107 Sep, 106 Coll, 106 ReplU):
"learned = target" ⟺ all N_i on 107/107, 106/106, 106/106; the capture instance (Russell for Sep, y = Y for
Coll/ReplU) is an instance of the lgg and rejected by the learned guards in every case.

### 2.8 Thm E (anchors for pattern targets; all ZF schemas) — proved; computed

Let T* = F[P(ā₁),…,P(ā_m)] be a pattern template over {∈,=} with one metavariable P of arity n (metavariable-free
frame F, ā_k distinct bound variables), D = {T*[P := λz̄.φ_j]: j ≤ N} finite. For every class H with
PAT ⊆ H ⊆ SO°, D is an anchor for inst(T*) in H iff
(R) the main symbols of φ₁,…,φ_N are not all equal, and (N_i) for each i ≤ n some φ_j has z_i free.

*Proof of "if" (for H = SO°, hence for all smaller H).* Let T ∈ SO° cover D.
Step 1 (skeleton). The root of φ_j[ā_k] is root(φ_j); by (R) every slot position p_k is a disagreement position,
and frame positions are common. By the rigid-prefix lemma (prior C2(a)) T's rigid skeleton is a prefix of F and its
metavariable occurrences sit at frame positions or at slot positions.
Step 2 (one body-template per metavariable). Let M have occurrences M(ū¹) at c₁, …, M(ū^r) at c_r (ū^s bound
variables), bodies β_j with β_j[ū^s] = D_j|c_s, and put κ(c) := T*|c, so D_j|c = κ(c)[P := φ_j].
  * At a P-position p of κ(c₁), D_j|c₁ has root(φ_j), a formula symbol, so β_j|p is not a hole and D_j|c_s has the
    same root at p; if κ(c_s) had a frame symbol at p, all φ_j would share it, contradicting (R). So κ(c₁) and κ(c_s)
    have P-occurrences at the same relative positions and the same frame symbols elsewhere (data contents agree
    off hole positions).
  * Bound variables of κ(c₁) whose binder lies *inside* κ(c₁) are bound inside β_j as well and are kept; they
    appear identically in κ(c_s) (the contents agree off hole positions).
  * Each frame leaf v of κ(c₁) that is free relative to c₁ is produced by a hole of β₁ (β₁ is closed except holes,
    and arguments are bound variables): β₁|q = h_m with u¹_m = v; record m.
  * For the i-th argument v of a P-occurrence P(ā) of κ(c₁) at p, with v free relative to c₁: by (N_i) pick j_i with
    z_i free in φ_{j_i}; at a free occurrence q′ of z_i, β_{j_i}|(p·q′) = h_m with u¹_m = v; record m.
  Let B_M be κ(c₁) with every such leaf/argument replaced by its recorded hole. Then B_M[ū¹] = κ(c₁), and for every
  s: at a frame leaf, β₁[ū^s] gives u^s_m, which is κ(c_s)'s leaf there (frame parts do not depend on the datum);
  at the i-th argument of the P-occurrence at p, β_{j_i}[ū^s] = D_{j_i}|c_s has φ_{j_i}[b̄] at p (b̄ the arguments of
  κ(c_s) there) and u^s_m at the free occurrence q′ of z_i, so u^s_m = b_i. Hence B_M[ū^s] = κ(c_s) for all s. (Term
  metavariables at frame leaves are the special case κ(c) = a variable.) The argument uses that occurrence
  arguments are bound variables — true for templates over {∈,=}, which have no closed terms; with closed
  argument terms (PA language) the analogous SO° claim fails (Prop A2′'s counterexample).
Step 3. σ(M) := λh̄.B_M for every metavariable gives Tσ↓ = T*, so T ⪰ T* and inst(T) ⊇ inst(T*).

*Proof of "only if" (witnesses in PAT, hence in every H ⊇ PAT).*
* (R) fails, all roots f: replace each P(ā_k) by Φ_f(ā_k) with Φ_∈(ā) = g₁(ā) ∈ g₂(ā), Φ_=(ā) = g₁(ā) = g₂(ā)
  (function metavariables; values projections or parameters), Φ_¬(ā) = ¬Q(ā), Φ_∘(ā) = Q₁(ā) ∘ Q₂(ā) for binary
  ∘, Φ_Q(ā) = Qw.R(ā, w) for Q ∈ {∀, ∃, ∃!}. Every occurrence is a pattern occurrence; the template covers D
  (atoms of the language have variables or parameters as arguments) and misses T*[P := λz̄.ψ] for ψ with another
  root.
* (N_i) fails: replace each P(ā_k) by P′(ā_k minus its i-th entry); this covers D and misses T*[P := λz̄.(z_i = z_i)],
  whose content at a slot has the deleted variable free. ∎

**Per schema** (anchor events; two instances suffice in every case):

| schema | anchor iff | minimal anchor example (bodies) |
|---|---|---|
| Sep | (R), N_x, N_z | x∈z, ¬(x=a) |
| SepJ | (R), N_u | u∈a, ¬(u=u) |
| EInd | (R), N_x | x∈x, ¬(x=x) |
| Coll, ReplU, ReplS | (R), N_x, N_y, N_A | y=x, ¬(x=A) |
| ReplJ | (R), N_x, N_y | x∈y, ¬(x=a) |
| Found (ground) | the sentence itself | one instance |

If the community never lets φ mention the bounding set z (resp. the domain A), the learner stays at the sound
specialization with P(x) (resp. P(x,y)) — e.g. Jech's Separation instead of Kunen's.

*Remarks.* (1) Two instances suffice; one never does. (2) In {∈,=} there are no function symbols, so the
"shielding" phenomenon that separates SO° from DT° for PA induction (prior C7, condition (B)) cannot occur; DT° and
SO° have the same anchors here. (3) With (R) + all (N_i) the cautious DT° verifier accepts exactly inst(T*), and
before that it is sound (T* ∈ DT° covers D; lem:imitation:cautious(a)).

*Remark (several metavariables; not needed for ZF).* If T* had two metavariables P ≠ Q, the proof of "if" goes
through when additionally, for every P-slot k and Q-slot l, no datum-independent argument renaming makes
φ_{P,j}[ā_k] = φ_{Q,j}[b̄_l] hold for all j — a (D)-type event; otherwise a template merging the two slots covers D
and is not ⪰ T*. (Proof sketch: the merged metavariable's body-template would have to equal both P(ā_k) and Q(b̄_l).)

**Lemmas for the enumeration (E1–E4) — proved.** Every covering template T is ⪰ one produced by the reduced
enumerator `st_enum.enumerate_dt_reduced`, so D is an anchor iff all produced templates are ⪰ T*:
E1 rigid-prefix lemma (prior C2(a)); E2 term metavariables at common positions can be replaced by their (forced,
datum-independent) value, which specializes T and keeps coverage; E3 in DT° an argument whose hole is unused by the
(unique) bodies of all data can be deleted at all occurrences (a specialization that keeps coverage and
determinacy), so the own pattern occurrence's arguments are exactly the free context variables of its column, in
canonical order (argument permutation = renaming); E4 every other occurrence of the metavariable has its arguments
forced by the data (each hole is used in some datum).

*Evidence.* `z2_anchors.py` → `z2_anchors.out` (430 s on 4 cores).
* Phase A, all 7 schemas, all 16 singletons and all 120 pairs of each pool: no singleton is an anchor; for pairs
  with (R) the reduced DT° enumeration (complete for anchor-hood by E1–E4) gives anchor ⟺ all (N_i); for pairs
  without (R) the most specific covering DT° template on the maximal common prefix
  (`st_enum.most_specific_own`, root-specialized, e.g. ∀z∃y∀x(x∈y ↔ x∈z ∧ f₀(x,z) ∈ f₁(x,z)) for bodies x∈z, z∈x)
  is not ⪰ T*. Agreement "anchor ⟺ (R) ∧ all (N_i)": 120/120 for every schema (anchors: Sep 97, SepJ 104, EInd 104,
  Coll/ReplU/ReplS 62, ReplJ 97). Typical non-anchor witness with (R) but not N_A (ReplU, bodies y=x, x∈y):
  ∀A(P₀(A) → ∃Y∀x(P₁(x,A) → P₂(x,Y))).
* Phase B, Sep, SepJ, EInd, all pairs with (R) (107, 110, 110): the full data-directed enumeration in DT° and in SO°
  (arity ≤ 3; every run finished within its 10 s limit) agrees with (R) ∧ (N) on every pair. Every anchor pair has
  the *same* number of covering templates (Sep: DT° 986, SO° 4078; SepJ: 1325, 7103; EInd: 77, 2459) — consistent
  with the fact that for an anchor the covering templates are exactly the generalizations of T* (the analogue of
  prior C4's 26 generalizations of T_ind).
* `z2b_fullcheck.py` → `z2b_fullcheck.out` (stopped by a 20-minute budget): the full DT° enumeration on the large
  Coll frame finished for 2 anchor pairs (64 943 covering templates each, all ⪰ T*, 750–940 s each) and for 3
  non-anchor pairs (Coll ×2, ReplJ ×1, bad template found at once); all agree with the reduced enumerator and with
  (R) ∧ (N). The three ReplJ anchor pairs did not finish in the budget and are not counted.

### 2.9 Cor F (pattern anti-unification recovers every ZF schema) — proved; computed

Let L_pat(D) be the least general pattern generalization (exists and is unique: Pfenning 1991; Baumgartner,
Kutsia, Levy, Villaret 2017 — known). For D ⊆ inst(T*) (T* a pattern template as in Thm E): L_pat(D) ⪯ T*, and
L_pat(D) ≡ T* iff (R) ∧ all (N_i).
*Proof.* T* ∈ PAT covers D, so L_pat ⪯ T*. If (R) ∧ (N), Thm E (H = PAT) gives L_pat ⪰ T*. Otherwise the PAT
witnesses of Thm E cover D and do not contain inst(T*), and they are ⪰ L_pat, so L_pat ≢ T*. ∎

*Evidence.* `z3_pattern_lgg.py` → `z3_pattern_lgg.out`: own n-ary implementation (common prefix; generalization
variable applied to the bound variables free in the column; merge of columns equal up to a permutation of the
arguments — BKLV's merge rule). On all 120 pairs and 400 random triples per schema: the result is a pattern
template, covers the data, is ⪯ T*, and is ≡ T* iff (R) ∧ (N) (agreement 120/120 and 400/400 for all 7 schemas).
Example: from Coll(y = x) and Coll(¬x = A) it returns Coll's template verbatim. The same code style on PA induction
(prior so_core) returns the unsound T12 = (A ∧ ∀x(P(x) → Q(x))) → ∀xP(x) — the prior C9 contrast.
The permutation merge matters: Replacement's P(x,y) and P(x,u) columns are equal only up to renaming y ↔ u.

### 2.10 Thm G (rates for the ZF learners) — proved; computed

Bodies i.i.d. from μ. With C_{F,I} := {φ: (F = * or root(φ) = F) and no z_i, i ∈ I, free in φ},
P[D_N is not an anchor] = Σ_{(F,I) ≠ (*,∅)} (−1)^{[F≠*] + |I| + 1} μ(C_{F,I})^N
(sum over F ∈ {*} ∪ roots, I ⊆ {1..n}), ≤ Σ_f p_f^N + Σ_i (1−q_i)^N, where p_f = μ(root f), q_i = μ(z_i free).
*Proof.* "Not an anchor" = ⋃_f A_f ∪ ⋃_i B_i (Thm E), A_f = all roots f, B_i = z_i never free. The A_f are pairwise
disjoint, and ⋂ of A_f (or none) with B_i, i ∈ I, is "all samples in C_{F,I}"; inclusion–exclusion. ∎
*Evidence.* `z6_rates.py` → `z6_rates.out`: uniform and atom-skewed laws on the 16-body pools, 3000 Monte-Carlo
trials with the pattern lgg: exact and MC agree within sampling error for all N ∈ {2,…,12}. N needed for δ = 0.01:
Sep 5 / 9 (uniform / skewed), EInd 4 / 6, Coll and ReplS 10 / 16 (three (N_i) events), ReplJ 5 / 9.

---------------------------------------------------------------------------------------------------------------

## 3. Relation to the brief's proposed answers (§5)

* Q1: confirmed, with precision: anchor = Plotkin's events specialized (Thm A2), same in DT° but not in SO° (A2′); the ω-gap
  is characterized exactly by M₀ ≼ M (A5); the hidden ω-step occurs in the *cautious* learner whenever parameters
  are instances and no closedness guard is in the class (A4(b)) — a point the brief does not make.
* Q2, confirmed: all ZF schemas are in the pattern fragment, pattern anti-unification and the DT° learner work,
  anchors are (R) + argument-use events (Thm E, Cor F).
* Q2, corrected (Thm B1, Prop B2, C2, C3): ∈-induction is a first-order pattern in de Bruijn syntax; freshness is
  not automatic in the de Bruijn *first-order* encoding (Separation; Collection without A); Collection/∃!-Replacement
  with A in φ are first-order only in the named encoding; spelled-out Replacement (Kunen) yields a truth-sound
  first-order lgg in the named encoding, false lgg instances only in de Bruijn; Jech's Replacement yields false
  instances in both. The robust statement is Thm B1: *first-order iff P's argument tuple is literally the same at
  every occurrence in the chosen syntax*.
* For the method question (Q3, not this track): ZF and Q1 data are pattern targets, so any learner whose class
  contains PAT and whose anchors are Thm E's applies; DT° is needed only for PA-style schemas.

## 4. Files, commands, outputs

| script | claims | output | time |
|---|---|---|---|
| `q1_lgg.py` | A1, A2 (computed), A4(c), A3 rates vs MC | `q1_lgg.out` | ~85 s |
| `q1_qmodel.py` | Ex. A8 model of Q | `q1_qmodel.out` | <1 s |
| `z1_encodings.py` | B1 criterion, B2 blocks, §2.4 false instances, (3b) dB capture, (4) EInd-dB, (5) only-if | `z1_encodings.out` | ~5 s |
| `z2_anchors.py` | Thm E (reduced DT°; full DT°/SO° on small frames) | `z2_anchors.out` | ~7 min (4 cores) |
| `z2b_fullcheck.py` | Thm E, full DT° on the large frames (5 of 8 pairs finished) | `z2b_fullcheck.out` | 20 min budget (4 cores) |
| `z3_pattern_lgg.py` | Cor F; PA contrast | `z3_pattern_lgg.out` | ~10 s |
| `z4_guards.py` | Prop D1 | `z4_guards.out` | ~2 s |
| `z5_deepleaf.py` | Lemma C1 hypotheses and conclusion on random τ | `z5_deepleaf.out` | ~5 s |
| `z6_rates.py` | Thm G | `z6_rates.out` | ~3 min |

## 5. Caveats and uncertain citations

* Computations cover pools of 16 bodies per arity (atoms, connectives, one internal quantifier, parameters); the
  theorems are proved for all bodies. The SO° enumeration is bounded to arity ≤ 3 (DT° needs no bound by E3).
* "False" claims are proved by short ZF arguments or by Δ₀-absoluteness from HF witnesses; no general truth
  evaluator for set theory is used.
* The named encoding assumes the community writes the frame with the textbook variable names. If frame variable
  names vary between data, they become metavariables with distinctness guards; not analysed here.
* Citations: Kunen 1980 axiom wording and numbering; Jech 2003 axiom wording (1.3, 1.7, 1.8); the location in
  Boolos–Burgess–Jeffrey of "Q ⊬ ∀x(0+x=x)"; the provability of Collection in ZF is standard (via ranks, e.g. Lévy
  1979, *Basic Set Theory* — I believe); Tarski–Vaught 1957 for the elementary-substructure test; Pfenning 1991 and
  Baumgartner–Kutsia–Levy–Villaret 2017 (JAR 58) for pattern anti-unification — I have not run their implementation;
  mine is n-ary with a permutation merge.

## 6. Open problems (for the paper / other tracks)

* Several metavariables: Thm E is proved for one metavariable; the (D)-type event for two is only sketched (§2.8).
* SO° anchors for Q1 in languages with closed terms (an analogue of prior C7's condition (B)); only the
  counterexample of A2′ is given.
* Escalation counts of the DT° verifier on ZF data before an anchor (prior C11 is open for PA as well).
* Named encodings in which the community varies the frame's variable names (metavariables for names with
  distinctness guards) — not analysed.
* Prop C3 is stated over ZF; over bases without Foundation the status of "Collection from Replacement" (and hence of
  the truth-soundness of the named spelled-out-Replacement lgg) should be checked against the literature.
* Untagged mixtures of ZF schemas and of instance schemas φ(z) (Q3) belong to the method tracks; this track only
  supplies the per-schema anchors and the encoding classification.
