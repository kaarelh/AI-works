# Track "cases" — final record: learning ∀xφ from its instances (Q1) and learning the ZF(C) schemas (Q2)

Revised after the adversarial referee report (`referee.md`). This file supersedes `notes.md` and is
self-contained: every statement of `notes.md` is restated here, corrected where the referee found a problem;
material added in the revision is marked **[new]** or **[revised]**. The section *Verification log* at the end
lists every referee point and its resolution. Nothing from `notes.md` has been dropped.

Status labels: **proved** (complete proof here), **computed** (script run here; command and output file named),
**known** (literature; citations I am unsure of are marked "(I believe)" or "unverified"), **conjecture**, **open**.
All scripts are in this directory and are run as `cd research/tracks/cases && python3 <script> [args]`; outputs
are the `.out` files named in §4. Library files: `st_core.py` (set-theory templates, de Bruijn terms, plugging,
SO°-matching, subsumption, the two first-order encodings, the n-ary higher-order pattern lgg), `st_enum.py`
(covering-template enumerators), `st_pool.py` (bodies φ), `dt_search.py` **[new]** (bounded search for covering
second-order templates that miss a probe instance). The first-order lgg is always the parent report's T1 code
(`inferential-learning/research/theory/T1-code/terms.py`, `lgg_list`).

References to the parent report use its labels (lem:setting:recover = Plotkin's witness lemma, thm:setting:lgg,
lem:setting:guard = most specific guards, lem:imitation:cautious, thm:imitation:anchor, thm:imitation:coupon);
"prior C2(a), C4, C6.1, C7, C9" refer to `prior/induction/second-order-notes.md`.

---------------------------------------------------------------------------------------------------------------

## 0. Answers in brief

**Q1 (∀xφ from sentences φ(t)).**

1. *What is learned is the instance schema; first-order anti-unification learns it, provided metavariables cannot
   take bound variables* **[revised]**. The target σ_φ = φ(z₁,…,z_k) (term metavariables at the free occurrences
   of the x_i) is a first-order pattern. D = {φ(t̄_j)} is an anchor iff lgg(D) ≡ σ_φ iff Plotkin's witness events
   hold: (R_i) the closed terms substituted for x_i do not all have the same root symbol, and (D_{ii′}) for i ≠ i′
   some datum substitutes different terms for x_i and x_{i′} (Thm A2, proved; computed on 141 736 data sets, and by
   the referee on 36 000 random formulas with binders). Repeated occurrences are tied automatically; closed
   subterms of φ that coincide with data terms are harmless; one datum is never an anchor, two suffice. The same
   events characterize anchors in the determinate class DT° (Prop A2′, proved; **now also computed**, 99/99 pairs
   on five formulas, three with binders); in SO° they do not (explicit counterexamples, also with binders). Rates:
   P[no anchor after N] = Σ_f p_f^N for one variable, exact formulas for two, ≤ (2k + C(k,2))·e^{−Nρ} in general
   with ρ defined as in the parent report (Thm A3).
   **Variable convention.** Under the λ/locally-nameless convention of the brief (metavariable values contain no
   bound variables, only parameters), inst(σ_φ) is exactly the closed-instance schema (or, with parameters, the
   open-instance schema). In the *named* or *de Bruijn first-order* syntax, where a term metavariable may take a
   bound-variable name or an index, inst(σ_φ) also contains **capture instances** whenever some free x_i lies under
   a binder, e.g. ∃y¬(y = y) from φ(x) = ∃y¬(y = x); these can be false in every structure (Prop A4′, proved;
   computed). Then the unguarded cautious verifier is unsound outright, not merely ω-incomplete. A guard
   "nobound(z)" (no bound variable in the value of z) is learned from genuine data by the most-specific-guard rule
   and restores exactness.
2. *The instance schema is not the sentence ∀xφ (the ω-gap).* For a structure M with closed-term substructure
   M₀: "M ⊨ ∀xφ iff M ⊨ φ(t) for all closed t, for every φ" holds iff M₀ ≼ M (Tarski–Vaught; Prop A5). It holds
   in term-generated structures such as (ℕ;0,S,+,·), and fails in ℝ as an ordered field (φ(x) = ¬(x·x = 1+1)), in
   V with closed terms ∅,{·,·},∪ (φ(x) = "x is not inductive", refuted by Infinity), and in nonstandard models of
   PA. Derivability: Q ⊢ 0+n̄ = n̄ for every n, but Q ⊬ ∀x(0+x = x) (explicit model, Ex. A8, proved + computed).
3. *Consequences for a learner (Prop A10, A11).* From closed instances the sound target is the closed-instance
   schema. Whether the cautious learner silently takes the ω-step depends on whether parameters are allowed as
   instances: if they are, the learned schema contains φ(p̄), whose universal closure is ∀x̄φ, so the learner
   commits the ω-rule step after the first anchor; with a guard "closed(z)" the most-specific-guard learner learns
   closedness from closed data and never commits it; one datum at a parameter drops the guard, and then ∀x̄φ is
   derivable by trusted Gen. **[revised]** In the named/de Bruijn first-order syntax the unguarded learner in
   addition accepts capture instances (point 1), which a refutation channel may never catch if they are only
   false outside the intended model, and which are false everywhere in the worst case. The ω-step is truth-safe
   exactly when M₀ ≼ M. A false ∀xφ whose closed instances are all true is never refuted by evaluating closed
   instances; it is refuted by the coherence channel iff it is inconsistent with the designated truths.

**Q2 (ZF(C) schemas).**

4. *All ZF schemas are higher-order (Miller) patterns, hence in DT°* — Separation, Collection, Replacement
   (∃! as a primitive binder, ∃! spelled out, Jech's image form), ∈-induction. Foundation and every other ZFC axiom
   except the two schemas is a single sentence, its own anchor **[new remark]**. The language {∈,=} has no function
   symbols, so schema instances only *rename* variables; this is the structural difference from PA induction.
5. *Anchors (Thm E, proved; computed):* for a pattern target with one metavariable P of arity n, D is an anchor
   in any class between the pattern templates and SO° iff (R) the bodies' main symbols are not all equal and (N_i)
   for each argument i of P some body has argument i free. Two instances suffice. The higher-order pattern lgg
   (Pfenning 1991; Baumgartner–Kutsia–Levy–Villaret 2017) recovers every ZF schema from any anchor and is sound
   before (Cor F). Rates: exact inclusion–exclusion formula (Thm G).
   **[new] Several metavariables (Thm E′, proved; computed).** For pattern targets with several metavariables a
   third, Plotkin-(D)-type event is needed, and *it depends on the class*: in PAT it says that no bijective
   renaming of arguments turns one metavariable's bodies into another's in all data; in DT° no map at all (also
   non-injective, also into parameters) may do so; in SO° root-level distinctness suffices and the DT° event is
   necessary. All three classes have different anchors (explicit separating examples). ZF does not need this, but
   untagged mixtures (Q3) will.
6. *Whether first-order lgg works depends on the formulation and the encoding (Thm B1).* A pattern template is a
   (guarded) first-order pattern in the **named** encoding with textbook names iff P has the same argument *names*
   at every occurrence, and in the **de Bruijn** encoding iff P has the same argument *indices* at every occurrence.
   Results (table §2.2): Separation first-order in both, but with a freshness guard in both (Russell instance);
   ∈-induction not first-order named, first-order de Bruijn; Collection and ∃!-Replacement first-order named (guard
   Y ∉ FV(φ)), not de Bruijn; spelled-out Replacement (Kunen-style) first-order in neither, but its named lgg is a
   truth-sound over-generalization (Prop C3); Jech's Replacement first-order in neither, with ZF-refutable lgg
   instances. For the non-first-order cases no finite union of first-order schemas (with freshness guards) covers
   the schema without a false member (Thm C2).
   **[new] α-variation (Prop B1α).** If the community α-renames the frame's bound variables, the named criterion
   becomes "P is applied to the same *binders* at every occurrence": only Separation (both forms) survives;
   Collection, ∃!-Replacement and spelled-out Replacement become non-first-order in the named encoding, Thm C2
   extends to them, and the truth-sound over-generalization of Prop C3 disappears (the lgg acquires ZF-refutable
   instances).
7. *Corrections to the brief's §5 proposal:* ∈-induction is a de Bruijn first-order pattern; freshness is automatic
   only in the λ/pattern encoding, not in the de Bruijn *first-order* encoding (Separation needs "#1 not loose";
   Collection without A needs "#2 not loose"); Collection with A in φ is not a de Bruijn first-order pattern;
   spelled-out Replacement in Kunen's form gives a truth-sound (not false) first-order lgg with textbook names. The
   brief's main claim — all ZF schemas are in the pattern fragment, pattern anti-unification and the DT° learner
   both work — is confirmed (and confirmed independently by the referee).
8. **[new]** *C3 sharpened (Prop C3′, proved):* over any base theory B, all guarded instances of that named lgg are
   B-theorems iff B proves the Collection schema. So its truth-soundness over ZF without Foundation is exactly the
   question whether ZF − Foundation proves Collection (status unknown to me).

---------------------------------------------------------------------------------------------------------------

## 1. Conventions and the encodings

* Sentences are trees. A *schema* in the first-order sense is a tree with metavariables at some leaves (parent
  report, def:setting:schema); inst(σ) its ground instances, ⪰ "at least as general".
* **Named encoding.** Object variables are constants of the step signature; binders are `all(x, body)`. A schema
  is formed textually; freshness/substitutability side conditions are *guards* (lem:setting:guard), here from the
  family Φ = {fresh(v, Z): v a variable name of the frame, Z a formula metavariable}. Unless said otherwise, data
  use the textbook names for the frame's variables (Part 2); §2.2a drops this assumption.
* **de Bruijn first-order encoding.** Bound variables are indices #k (constants); a first-order metavariable at
  depth d may be instantiated by a de Bruijn term whose loose indices refer to the d enclosing binders. Only
  well-formed (closed) results are steps; guards "loose(Z) ⊆ I" when needed.
* **λ / pattern encoding (DT°).** As in the brief §3 and prior §1: metavariables of type ι^n→o or ι^n→ι are applied
  to metavariable-free argument terms, values are closed λ-bodies λz̄.β whose free names are parameters only,
  instances are obtained by one-step plugging. A *pattern occurrence* applies the metavariable to pairwise
  distinct bound variables. PAT = templates all of whose occurrences are pattern occurrences (Miller 1991),
  DT° = every metavariable has a rigid pattern occurrence, SO° = all occurrences rigid with metavariable-free
  arguments (no determinacy). PAT ⊆ DT° ⊆ SO°.
* **Closure-normal form.** Data are formulas whose free names are parameters, read under universal closure; the
  outer parameter prefix ∀w̄ of a schema instance is dropped. The frame's own variables (Separation's z,
  Replacement's A) stay bound in the frame (§2.1).
* **[revised] Variable convention for Part 1.** The default is the λ convention (term metavariables take terms
  whose only variables are parameters). The named (N) and de Bruijn first-order (dB) syntaxes for Q1 are treated
  explicitly in §1.5 (Prop A4′); there a term metavariable may take any term of the step language, including
  bound-variable names or indices.

---------------------------------------------------------------------------------------------------------------

## PART 1. Q1: learning ∀xφ from instances φ(t)

### 1.1 Formalization [revised]

Fix a first-order language L with at least one constant and a formula φ(x₁,…,x_k), each x_i free in φ (a variable
that does not occur free can be dropped; if none occurs, the target is the single sentence φ). Let
σ_φ := φ[z₁/x₁,…,z_k/x_k] with term metavariables z_i placed at the *free* occurrences of x_i (bound occurrences of
the same name are untouched; in the named encoding they are constants).

* closed-instance schema: inst_c(φ) = {φ(t̄): t̄ closed (variable-free) L-terms};
* open-instance schema: inst_o(φ) = {φ(t̄): t̄ terms over L ∪ Par, the substitution capture-free}, with parameters
  Par (closure-normal form).

**Convention-dependence (proved).** Under the λ convention, inst(σ_φ) = inst_c(φ) if the step language has no
parameters and inst(σ_φ) = inst_o(φ) if it has: the admissible values are exactly the terms over L (resp. L ∪ Par),
and such terms contain no variable that a binder of φ could capture. In the named first-order syntax, by contrast,
a metavariable may take a bound-variable name: φ(x) = ∃y¬(y = x) and z := y give ∃y¬(y = y). In the de Bruijn
*first-order* syntax capture happens by index: ∃¬(#0 = z) with z := #0. (The sentence "in de Bruijn syntax no capture
is possible" of `notes.md` was true only of the λ/locally-nameless convention, in which metavariable values have
no loose indices; Part 2 shows index capture for Separation and Collection, §2.4(7).) Prop A4′ (§1.5) gives the exact
extent of capture.

Metavariables are sorted (term positions only); the lgg of sorted data is sorted. Throughout, (H) denotes the
richness assumption: for every k there are closed terms t₁…t_k pairwise distinct and t′₁…t′_k pairwise distinct with
root(t_i) ≠ root(t′_i). It holds for the PA language (t_i = S^i0, t′_i = 0+S^i0) and the ordered-field language
(t_i = 1+(…), t′_i = 1·(…)).

### 1.2 Prop A1 (instance sets determine schemas) — proved

Under (H), for first-order schemas σ (metavariables at term positions) and τ: inst(σ) ⊆ inst(τ) iff σ ⪯ τ. Only
closed instances of σ are used, so the statement and proof hold in all three syntaxes.

*Proof.* (⇐) trivial. (⇒) Put θ₀(z_i) = t_i and θ₁(z_i) = t′_i. The roots of θ₀z_i, θ₁z_i differ, and θ₀z_i ≠ θ₀z_{i′}
for i ≠ i′, so both witness events of lem:setting:recover hold and lgg(σθ₀, σθ₁) ≡ σ. Both instances lie in inst(τ),
so τ ⪰ lgg(σθ₀, σθ₁) ≡ σ by thm:setting:lgg. ∎

(computed: `q1_lgg.py` (2) — for all six test formulas the lgg of the two generic instances equals σ_φ.)

### 1.3 Thm A2 (anchors for the instance schema) — proved; computed

Let D = {φ(t̄₁),…,φ(t̄_N)} ⊆ inst_c(φ), N ≥ 1, (H). Then TFAE:
(i) D is an anchor for inst_c(φ) in H₁ (single first-order schemas): every τ ∈ H₁ with D ⊆ inst(τ) has
inst(τ) ⊇ inst_c(φ);
(ii) lgg(D) ≡ σ_φ;
(iii) (R_i) for each i, the roots of t_{1,i},…,t_{N,i} are not all equal; and (D_{ii′}) for each i < i′ there is j with
t_{j,i} ≠ t_{j,i′}.
The theorem holds in all three syntaxes (λ, N, dB): anchor-hood only asks for inst(τ) ⊇ inst_c(φ), and all
instances used in the proof are closed.

*Proof.* (ii)⇔(iii) is lem:setting:recover with θ_j(z_i) = t_{j,i}; every z_i occurs in σ_φ. (ii)⇒(i): every τ with
D ⊆ inst(τ) has τ ⪰ lgg(D) ≡ σ_φ, so inst(τ) ⊇ inst(σ_φ) ⊇ inst_c(φ). (i)⇒(ii): lgg(D) ∈ H₁ covers D, so
inst(lgg D) ⊇ inst_c(φ), which contains the two closed (H)-instances of A1's proof; hence lgg(D) ⪰ σ_φ; and
lgg(D) ⪯ σ_φ since σ_φ covers D. ∎

Corner cases, all covered by the theorem:
* *Tied positions.* If x_i occurs m times, σ_φ has z_i m times; Reynolds' table assigns one variable per column, and
  all m columns equal (t_{1,i},…,t_{N,i}). No witness event beyond (R_i) is needed.
* *Several variables.* (D_{ii′}) is needed: on diagonal data φ(t,t) the lgg of x+y=y+x is z+z=z+z, a sound
  specialization (computed).
* *Closed subterms of φ equal to data terms.* Columns at non-x positions are constant, so they never merge with an
  x-column unless all data terms equal that constant, which is already a failure of (R_i). Example computed:
  φ = (x+S0 = Sx) with data terms S0 and 0 recovers σ_φ; with S0 and SS0 (both root S) the lgg is
  S(z)+S0 = SS(z), the (R)-failure.
* *Bound occurrences of the same name* (named encoding, φ = x=0 ∧ ∀x(x=x)): constant columns; recovered.
* *Anchor size.* One datum is never an anchor (R fails); two data t̄, t̄′ with pairwise distinct components and
  componentwise different roots are an anchor.

*Evidence.* `q1_lgg.py` (1) → `q1_lgg.out`: closed-term pool of size ≤ 4 (12 terms); all pairs and triples for four
one-variable formulas (286 data sets each) and 70 296 data sets each for two two-variable formulas: "lgg ≡ σ_φ ⟺
(R)∧(D)" on all of them (re-run in this revision: identical output). Independent: the referee's own lgg on 600 random
PA formulas with binders, up to three variables, repeated occurrences and closed subterms from the data pool:
36 000/36 000 (`referee_code/r1_q1.out` (1)).

**Prop A2′ (the same events in DT°; not in SO°) — proved; computed [evidence extended].** If the hypothesis class is
enlarged to the determinate second-order templates DT° (λ convention; metavariables of any arity, each with a rigid
pattern occurrence, other occurrences applied to metavariable-free argument terms, which in the PA language include
closed terms such as S0), D ⊆ inst_c(φ) is still an anchor iff (R) and (D). In SO° (no pattern occurrence required)
this fails for the PA language, with and without binders in φ.

*Proof (DT°).* (⇒ fails if (R) or (D) fails) the first-order witnesses of A2 lie in DT°. (⇐) Let T ∈ DT° cover D. By
(R) every x-position is a disagreement position, so T's rigid skeleton is a prefix of φ's skeleton (prior C2(a)).
Let M have a pattern occurrence M(ū¹) at c₁ (ū¹ distinct bound variables) and further occurrences M(ū^s) at c_s; in
datum j its body β_j is unique on the used holes: D_j|c₁ with the variables ū¹ abstracted (other context variables
cannot occur, as β_j has no free bound variables). Let κ(c) := σ_φ|c. At a z_i-position p of κ(c₁), D_j|c₁ has the
closed term t_{j,i}; holes of β_j sit only at occurrences of the variables ū¹, so β_j|p = t_{j,i} and
D_j|c_s = β_j[ū^s] also has t_{j,i} at p. Positions of κ(c₁) and κ(c_s) agree off hole positions; if κ(c_s) had a rigid
symbol at p, all t_{j,i} would share its root (contradicting (R_i)), and if κ(c_s) had z_{i′} at a position where κ(c₁)
is rigid, all t_{j,i′} would share that root, or (if the position is a hole of β_j) all t_{j,i′} would equal the same
argument term of M(ū^s) — a bound variable (impossible: t_{j,i′} closed) or one closed term (contradicting (R_{i′})).
So κ(c_s)|p = z_{i′} with t_{j,i′} = t_{j,i} for all j, whence i′ = i by (D_{ii′}). Let B_M be κ(c₁) with its
context-variable leaves replaced by the corresponding holes; then B_M[ū^s] = κ(c_s) for all s, and σ(M) := λh̄.B_M
gives Tσ↓ = σ_φ, i.e. T ⪰ σ_φ. ∎

*SO° counterexample (computed, `q1_lgg.py` (5); referee brute force over 2278 bodies, `referee_code/r1_q1.out` (3)).*
For φ(x) = (x+0 = x), T := f(S0) + f(0) = f(S0) (f a unary term metavariable with ground arguments only, so T ∉ DT°)
covers 0+0=0 (f := λh.0) and S0+0=S0 (f := λh.h), a pair with (R), but misses SS0+0 = SS0: a body β with β[0] = 0 is
h or 0, and then β[S0] ∈ {S0, 0}. This is the Q1 analogue of the prior C7 "shielding" phenomenon; determinacy
removes it.

*Evidence for the DT° half and SO° failures with binders* **[new]** (`q1_dt.py` → `q1_dt.out`, 7 s). Bounded search
`dt_search.search` over single-group templates (one shared metavariable at up to 3 pairwise incomparable positions,
arguments from the bound variables in scope and the closed terms 0, S0, arity ≤ 2 (≤ 1 for groups of size 3); fresh
fully applied metavariables elsewhere), probes = 9 genuine instances; a pair is "non-anchor" iff some covering
template misses a probe. (Why one shared group is the relevant search space: in the proof above a covering T fails to
be ⪰ σ_φ only through one metavariable whose occurrences cannot be reconciled; replacing all other metavariables by
fresh fully applied single occurrences keeps coverage. The search is bounded, so a "no witness" verdict is evidence.)

| φ | pairs | DT°: anchor ⟺ prediction | DT° covering templates seen | SO°: anchors / pairs with the DT° events |
|---|---|---|---|---|
| x+0=x | 21 | 21/21 | 110 | 16/17 |
| ∀y(x+y=y+x) | 21 | 21/21 | 301 | 16/17 |
| ∀y(y=x → x=y) ∧ x=x | 21 | 21/21 | 1130 | 16/17 |
| ∃y(y=Sx) | 21 | 21/21 | 131 | 16/17 |
| x+y=y+x (two variables; (R₁),(R₂),(D₁₂)) | 15 | 15/15 | 78 | 5/6 |

SO° non-anchors with the DT° events, from data terms 0 and S0 (each misses the instance at SS0 or SSS0; templates
as printed in `q1_dt.out`): ∀y(G(0,S0) + G(y,y) = y + F(y)); ∀y(G(y,y) → F(y) = y) ∧ G(0,S0) (G formula-valued:
λh₁h₂.(h₁ = 0) on the first datum, λh₁h₂.(h₂ = S0) on the second); ∃y(G(y,y) = S G(0,S0)); and, for two variables,
G(0,S0) = G(S0,0) on data (0,S0),(S0,0). In each, G uses its first argument on one datum and its second on the other;
without a pattern occurrence nothing forces the two choices to agree. (The referee found the same phenomenon independently, `referee_code/r5_q1_dt.out`.)

### 1.4 Thm A3 (rates) — proved; computed [statement completed]

Data i.i.d.: t̄ ~ Λ. Let p_{i,f} = Λ(root t_i = f) and c_{ii′} = Λ(t_i = t_{i′}).
(a) k = 1: P[D_N is not an anchor] = Σ_f p_f^N exactly.
(b) k = 2: P = Σ_f a_f^N + Σ_g b_g^N + c^N − Σ_{f,g} d_{fg}^N − Σ_f e_f^N, with a_f = Λ(root t₁ = f),
b_g = Λ(root t₂ = g), c = Λ(t₁ = t₂), d_{fg} = Λ(root t₁ = f, root t₂ = g), e_f = Λ(root t₁ = f, t₁ = t₂). For i.i.d.
components with root law p and term law μ: P = 2S − S² + c^N − C, S = Σ_f p_f^N, C = Σ_f c_f^N,
c_f = Σ_{root t = f} μ(t)².
(c) In general P ≤ Σ_i Σ_f p_{i,f}^N + Σ_{i<i′} c_{ii′}^N ≤ (2k + C(k,2))(1−ρ)^N ≤ (2k + C(k,2)) e^{−Nρ}, where, as
in thm:imitation:coupon (with π = 1, one schema), ρ_i := max_{G} min(Λ(root t_i ∈ G), Λ(root t_i ∉ G)) (the best root
split), r_{ii′} := Λ(t_i ≠ t_{i′}), and ρ := min(min_i ρ_i, min_{i<i′} r_{ii′}).

*Proof.* "Not an anchor" = ⋃_i ¬R_i ∪ ⋃ ¬D_{ii′} (A2). (a) ¬R = disjoint union of A_f = "all roots f". (b)
Inclusion–exclusion over A = ⋃_f A_f, B = ⋃_g B_g, E = ¬D: A_f ∩ A_{f′} = ∅ for f ≠ f′, P(A_f ∩ B_g) = d_{fg}^N,
P(A_f ∩ E) = P(B_f ∩ E) = e_f^N, and A_f ∩ B_g ∩ E = ∅ unless f = g, when it is A_f ∩ E. (c) Union bound; for each
i, the events "all roots = f" (f ∈ G) are disjoint subsets of "all roots in G" for the best split G, so
Σ_f p_{i,f}^N ≤ Λ(root ∈ G)^N + Λ(root ∉ G)^N ≤ 2(1−ρ_i)^N; and c_{ii′}^N = (1 − r_{ii′})^N; finally 1−ρ ≤ e^{−ρ}. ∎

*Evidence (computed, `q1_lgg.py` (4)).* Root law 0:.4, S:.3, +:.2, ·:.1 (Galton–Watson, depth ≤ 4), 20 000 trials:

| N | exact k=1 | MC k=1 | exact k=2 | MC k=2 | bound k=1 | bound k=2 |
|---|---|---|---|---|---|---|
| 2 | .3000 | .2979 | .5157 | .5173 | .736 | 1 |
| 4 | .0354 | .0341 | .0699 | .0684 | .271 | .677 |
| 6 | .0049 | .0046 | .0098 | .0096 | .100 | .249 |
| 10 | .00011 | .00010 | .00022 | .00025 | .013 | .034 |

The exact values agree with Monte Carlo and lie below the bound of (c). N for δ = 0.01: exact 6 (k = 1) and 6
(k = 2); the bound's sufficient N: 11 and 13 (ρ = 0.5) — a factor of about 2. The referee re-derived (b) and checked
it against Monte Carlo for a non-i.i.d. joint law (P[t₂ = t₁ forced] = 0.3; `referee_code/r1_q1.out` (5)).

### 1.5 Open-term data, guards, capture and the hidden ω-step — Prop A4, A4′

**Prop A4 [revised] — proved; computed.**
(a) inst_o(φ) contains φ(p̄) with distinct parameters, whose universal closure is (α-equivalent to) ∀x̄φ; every member
of inst_o(φ) is FOL-derivable from ∀x̄φ, and ∀x̄φ from φ(p̄) by Gen. So, with trusted first-order logic, inst_o(φ) and
∀x̄φ are interderivable.
(b) *Under the λ convention*, if the step language contains parameters, inst_c(φ) is not H₁-closed:
cl_{H₁}(inst_c φ) := ⋂{inst τ: τ ∈ H₁, inst τ ⊇ inst_c φ} = inst(σ_φ) = inst_o(φ) ⊋ inst_c(φ). Hence (prior C6.1) once the
closed data contain an anchor, the cautious H₁-verifier accepts φ(p̄), i.e. it takes the ω-rule step "all closed
instances ⇒ ∀x̄φ" although no datum licenses it. *In the named/de Bruijn first-order syntax*,
cl_{H₁}(inst_c φ) = inst(σ_φ) is larger still: it contains the capture instances of Prop A4′.
*Proof.* Every τ ⊇ inst_c(φ) contains an anchor (two closed (H)-instances), hence τ ⪰ σ_φ (A2); σ_φ itself contains
inst_c(φ). So cl = inst(σ_φ), which is inst_o(φ) under the λ convention (§1.1). ∎
(c) With the guard family Φ ∋ closed(z_i) ("the value of z_i contains no variable or parameter"),
inst_c(φ) = inst(σ_φ, {closed(z_i)}) is realizable in every syntax; by lem:setting:guard the learned guard set is the
set of guards true on all data, so closed data teach closedness and the learner never accepts φ(p̄) (nor any capture
instance, since closed values contain no variables); one datum with a parameter at z_i deletes closed(z_i).

*Evidence.* `q1_lgg.py` (3): data 0+0=0, 0+S0=S0 → lgg 0+z=z with learned guard closed(z): accepts 0+SS0=SS0, rejects
0+p₂=p₂ and 0+p₁·p₂ = p₁·p₂; after adding 0+(p₁+S0) = p₁+S0 the guard is gone and 0+p₂=p₂ (≡ ∀x(0+x=x)) is accepted.

**Prop A4′ (capture in the named and de Bruijn first-order syntax) [new] — proved; computed.** Work in syntax (N) or
(dB) (§1). Say that a value θ(z_i) is *captured* if it contains a variable bound at some free occurrence of x_i in φ
(N: a name y such that the occurrence lies in the scope of a binder of y; dB: an index that, read at the occurrence,
refers to an enclosing binder). Let Cap(φ) be the set of steps σ_φθ in which some θ(z_i) is captured.
(a) inst(σ_φ) = inst_c(φ) ∪ inst_o(φ) ∪ Cap(φ) (the middle term only when parameters are steps), and Cap(φ) is
disjoint from inst_o(φ).
(b) Cap(φ) ≠ ∅ exactly in these cases: (N), steps = sentences: some x_i has a variable name bound at *every* free
occurrence of x_i; (N), free names read as parameters: some free occurrence of some x_i lies in the scope of a binder;
(dB): for some i every free occurrence of x_i lies under at least one binder.
(c) Capture instances can be false in every structure although every genuine instance is true in every structure
with at least two elements: φ(x) = ∃y¬(y = x), capture ∃y¬(y = y). They can be false in the intended model although
∀xφ is logically valid: φ(x) = ∃y(y = Sx), capture ∃y(y = Sy), false in ℕ.
(d) Consequently, whenever Cap(φ) ≠ ∅, the unguarded cautious H₁ verifier, once the data contain an anchor, accepts
sentences outside inst_o(φ), some of which (for suitable φ) are false in every structure: it is unsound outright,
not merely ω-incomplete.
(e) Guards: let Φ ⊇ {closed(z_i), nocap(z_i)}, where nocap(z_i) says that θ(z_i) is captured at no free occurrence of
x_i (the free-for condition; with parameter names disjoint from bound-variable names it is "θ(z_i) contains no
bound-variable name / no index", i.e. the λ convention as a guard). Most specific guards: on closed data both are
learned, and the accepted set is inst_c(φ); after a parameter datum at z_i, closed(z_i) is dropped but nocap(z_i) is
kept (genuine data are capture-free), and the accepted set is inst_o(φ). Capture instances are never accepted.

*Proof.* (a) Let σ_φθ be a step. If no θ(z_i) is captured, then in (N) the substitution is free for every x_i and
σ_φθ = φ(θ̄) is a genuine instance — closed if the values are variable-free, otherwise an instance at terms whose
names are not bound at any occurrence, i.e. parameters (or, if steps are sentences, impossible); in (dB) a
non-captured value has no index below the depth of any occurrence, and none at or above it either (the step is well
formed), so it has no index at all and σ_φθ is a closed or parameter instance. Otherwise σ_φθ ∈ Cap(φ). The reverse
inclusions are by definition. Disjointness: every z_i occurs in σ_φ, so the text σ_φθ determines each θ(z_i) (the
subtree at an occurrence of z_i), and whether θ(z_i) is captured is a property of that text.
(b) (N), sentences: if y is bound at every free occurrence of x_i, then θ(z_i) := y (other values closed) gives a
sentence in Cap. Conversely, if σ_φθ ∈ Cap is a sentence and θ(z_i) contains the captured name y, then every copy of
θ(z_i), one at each free occurrence of x_i, contains y, and y must be bound at each (the result has no free names),
so y is bound at every free occurrence. (N), parameters: θ(z_i) := y with y bound above some occurrence is a step
(free copies of y elsewhere read as a parameter); conversely capture needs a binder above an occurrence. (dB): if
every free occurrence of x_i has depth ≥ 1, θ(z_i) := #0 is well formed at all of them and captured; conversely a
captured value contains some #k, and well-formedness at each occurrence o requires k < depth(o), so every depth ≥ 1.
(c) ∃y¬(y=y) is false in every structure; ∃y¬(y=t) holds in every structure with ≥ 2 elements whatever t denotes.
∀x∃y(y = Sx) is logically valid (take y := Sx); ∃y(y = Sy) is false in ℕ since S has no fixed point.
(d) By A4(b), cl_{H₁}(inst_c φ) = inst(σ_φ) ⊇ Cap(φ) (A2's anchor argument uses closed instances only, so it holds in
(N) and (dB)); prior C6.1 then says that the cautious verifier accepts all of it after an anchor. With φ as in (c) the
accepted capture instance is false in every structure.
(e) Closed values satisfy both guards, so closed data teach both; inst(σ_φ, {closed, nocap}) = inst_c(φ) since
closedness implies nocap. A genuine parameter instance satisfies nocap and violates closed, so only closed(z_i) is
deleted; inst(σ_φ, {nocap(z_i)} ∪ …) consists of the steps with no captured value, which by (a) are the genuine
instances. ∎

*Evidence.* `q1_capture.py` → `q1_capture.out` (< 1 s):
(1) lgg(φ(0), φ(S0)) = ∃y¬(y=z) for φ = ∃y¬(y=x); ∃y¬(y=y) is an instance of it, a sentence, not a closed instance, and
false in all pure-equality structures of sizes 1–5, while every closed instance is true in sizes 2–5; for
φ = ∃y(y = Sx), the capture ∃y(y = Sy) is an instance of the lgg.
(2) Decomposition of inst(σ_φ) over all 40 substituted terms of size ≤ 3 over {0, S, +, x, y, p, q} for seven φ:
closed 4, parameter 14, capture 0 or 12; the capture sentences exist exactly as (b) predicts (e.g. none for
x=x ∧ ∀y(x=y), where y is not bound at every free occurrence of x; capture formulas exist there when free names
read as parameters). The script asserts the prediction for every φ.
(3) Guards {closed, nobound}: closed data → both learned; accepts SS0, rejects the parameter q and the captures y,
y+p. After a datum at p+S0: only nobound learned; accepts q, still rejects y and y+p. The unguarded verifier accepts
∃y¬(y=y) in both cases.
(4) de Bruijn: lgg ∃¬(#0 = z), capture ∃¬(#0 = #0) is an instance; the learned guard "no loose index in z" rejects it.

### 1.6 The ω-gap

**Prop A5 (when closed instances decide universals) — proved; known in substance (Tarski–Vaught test).** Let M be an
L-structure (L with a constant) and M₀ = {t^M : t closed} the closed-term substructure. TFAE:
(i) for every L-formula φ(x̄): M ⊨ ∀x̄φ iff M ⊨ φ(t̄) for all closed t̄;
(ii) M₀ ≼ M.
In particular (i) holds when M is term-generated (M₀ = M), e.g. (ℕ; 0, S, +, ·), and in every model of true arithmetic
(ℕ ≼ M).
*Proof.* (ii)⇒(i): if M ⊨ φ(t̄) for all closed t̄ then M₀ ⊨ ∀x̄φ (elementarity, every element of M₀ is some t^M), so
M ⊨ ∀x̄φ; the converse direction of (i) is ∀-elimination. (i)⇒(ii): Tarski–Vaught criterion. Let M ⊨ ∃xψ(x, ā) with
ā = s̄^M ∈ M₀. If no b ∈ M₀ had M ⊨ ψ(b, ā), then M ⊨ ¬ψ(t, s̄) for all closed t, and (i) with φ := ¬ψ(x, s̄) gives
M ⊨ ∀x¬ψ(x, s̄), a contradiction. ∎ (Tarski–Vaught 1957, Compositio Math. 13, for the criterion.)

**Ex. A6 (ℝ as an ordered field) — proved.** L = {0,1,+,−,·,<}. Every closed term denotes an integer (induction on
terms). With φ(x) := ¬(x·x = 1+1): ℝ ⊨ φ(t) for every closed t (n² ≠ 2 for n ∈ ℤ), but ℝ ⊭ ∀xφ (√2). RCF
⊢ ∃x(x·x = 1+1) (positive elements have square roots), so the false universal is refutable from the designated theory
RCF; it is not refutable from the ordered-field axioms OF, since ℚ ⊨ OF + ∀x¬(x·x = 1+1).

**Ex. A7 (set theory with closed-term-forming symbols) — proved.** L = {∈, ∅, p, u} with p(a,b) = {a,b},
u(a,b) = a∪b. Closed terms denote exactly the hereditarily finite sets. Let Ind(x) := ∅ ∈ x ∧ ∀y∈x u(y, p(y,y)) ∈ x and
φ(x) := ¬Ind(x). Every closed term denotes a finite set, and an inductive set is infinite, so V ⊨ φ(t) for all closed
t; ZF ⊢ ∃x Ind(x) (Infinity), so ∀xφ is false and refuted by Infinity. (Each closed instance is a true Δ₀ sentence
about HF sets; I believe each is provable already in very weak set theories, but only truth is used.) The brief's
variant φ(x) := "x is finite" behaves the same way: all closed instances are true, ∀x finite(x) is refuted by
Infinity; ¬Ind is used here because it is Δ₀ in L.

**Ex. A7′ (nonstandard models of PA) — proved.** If M ⊨ PA + ¬Con(PA) and Prf is a Δ₀ proof predicate, all closed
instances ¬Prf(n̄, ⌜⊥⌝) hold in M (true Δ₀ sentences hold in every model of Q: Σ₁-completeness), while
M ⊨ ∃x Prf(x, ⌜⊥⌝). So even within arithmetic the ω-step is truth-safe only in the right model.

**Ex. A8 (derivability: Q) — proved; computed.** Q ⊢ 0 + n̄ = n̄ for every n (n = 0: axiom x+0 = x; step:
0 + S n̄ = S(0 + n̄) = S n̄ by x+Sy = S(x+y) and the induction hypothesis). Q ⊬ ∀x(0+x = x): take the domain ℕ ∪ {a, b},
standard on ℕ, with
- S a = a, S b = b;
- n + a = n + b = b; a + n = a, b + n = b; a+a = a+b = a; b+a = b+b = b;
- x·0 = 0; a·n = b·n = b (n ≥ 1); n·a = n·b = a (n ≥ 1), 0·a = 0·b = 0; a·a = a·b = b·a = b·b = a.

Check of Q1–Q7 by cases: S is injective with 0 ∉ ran S and every x ≠ 0 a successor (a = Sa, b = Sb). Q4: x+0 = x. Q5
x+Sy = S(x+y): y standard — for x ∈ {a,b}, x+n = x and S x = x; y ∈ {a,b} — Sy = y and every x+y ∈ {a,b} is a fixed
point of S. Q6 holds. Q7 x·Sy = x·y + x: y standard — a·(n+1) = b = a·n + a (0+a = b, b+a = b), b similarly
(0+b = b, b+b = b); y ∈ {a,b} — need z + x = z for z = x·y: x = 0 trivial; x = n ≥ 1, z = a: a+n = a; x = a, z = a:
a+a = a; x = b, z = a: a+b = a. In this model 0+a = b ≠ a. So Q + {all closed instances of 0+x=x} ⊬ ∀x(0+x = x). (That Q
does not prove 0+x = x is a textbook fact — unverified location, I believe Boolos–Burgess–Jeffrey, *Computability and
Logic*, ch. 16 exercises; the model here is my own.)
*Evidence.* `q1_qmodel.py` → `q1_qmodel.out` (re-run: identical): all seven axioms hold on all tuples from
{0..40} ∪ {a, b}; 0+a = b. Independently the referee checked {0..60} ∪ {a,b} (`referee_code/r1_q1.out` (4)).

**Prop A9 (parameters + Gen) — proved (trivial).** In closure-normal form the datum φ(p) at a parameter p *is* ∀xφ (its
universal closure); with trusted Gen, ∀xφ is derivable from it in one step. So with open-term data the ω-gap
disappears (A4(a)).

### 1.7 Consequences for a learner — Prop A10, A11 — proved [A10 revised]

**A10 (what is soundly learnable).**
1. From closed instances, the soundly learnable object is inst_c(φ), with anchor (R)+(D) and the rates of A3. The
   learner must carry a closedness guard (A4(c)), otherwise it commits the ω-step (A4(b)); and in the named or de
   Bruijn first-order syntax it must in addition carry the nocap/λ restriction (A4′(e)) — otherwise, whenever some
   free x_i lies under a binder, it accepts capture instances, which can be false in every structure (A4′(c,d)).
   Under the λ convention the second requirement is automatic.
2. The ω-step (accept ∀x̄φ, equivalently φ(p̄)) is *truth-safe for all genuine closed-instance schemas* iff the
   intended structure M satisfies M₀ ≼ M (this is Prop A5): yes for ℕ, no for ℝ, V, or a nonstandard model of PA.
3. It is *derivable* from the instances only via an ω-rule; first-order theories are ω-incomplete in general (A8: Q
   plus all closed instances does not prove ∀x(0+x=x)).
4. If the community itself uses instances at parameters (as in Lean/Coq practice, where `∀x, φ x` is applied to
   variables), the open-instance schema is the target and ∀x̄φ is obtained soundly (A9); the nocap guard (or the λ
   convention) is still needed in the named/de Bruijn first-order syntax.

**A11 (refutation).** Let ∀xφ be false in the intended M while every closed instance is true.
(a) No refutation that ends in evaluating closed instances φ(t) (the parent's "∀E then W" singleton-blame pattern)
ever condemns ∀xφ, since every such evaluation returns true.
(b) A coherence refutation from designated true premises Γ exists iff Γ ∪ {∀xφ} is inconsistent (completeness):
Γ = RCF refutes ∀x¬(x·x = 1+1); Γ = OF does not (ℚ). ZF refutes ∀x¬Ind(x) (Infinity).
(c) In a term-generated M (ℕ) the situation cannot arise: by A5 a false ∀xφ has a false closed instance; if the
evaluation channel decides φ's closed instances (φ ∈ Δ₀), search finds it — the parent's "arithmetic is Popperian"
for Π₁.
So where the bold step is safe (M₀ ≼ M) a false universal always has a false closed instance; elsewhere (ℝ, V) a
wrong ω-step can only be caught through the designated theory, and sometimes not at all.
(d) **[new]** Capture instances (A4′) are refutable by pure logic when they are logically false (∃y¬(y=y)); when they
are false only in the intended model (∃y(y=Sy) in ℕ: a Σ₁ sentence whose negation is a true Π₁ sentence), a
refutation needs a designated theory proving the negation: Q does not prove ∀y¬(y = Sy) (in the model of Ex. A8,
Sa = a), PA does (induction). No closed-instance evaluation bears on a capture instance, which is not an instance of
anything the evaluation channel tests. So the world channel alone does not protect an unguarded learner against
capture; the guard (or the λ convention) does.
